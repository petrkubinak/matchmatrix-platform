import os
import psycopg2
import re
from psycopg2.extras import RealDictCursor

DB_DSN = os.environ["DB_DSN"]

# ---------- DB helpers ----------

def db():
    return psycopg2.connect(DB_DSN)


# ---------- Team name normalization / matching ----------

def norm_team_key(name: str) -> str:
    """Normalizace názvu týmu pro matchování napříč zdroji (TheOdds vs DB)."""
    if not name:
        return ""

    s = name.lower().strip()

    # sjednocení apostrofů
    s = s.replace("’", "'")

    # cílené přepisy (TheOdds často posílá plné názvy, v DB bývají zkratky)
    # Udržuj minimální množství pravidel – přidej další až podle logu.
    rewrites = {
        "manchester united": "man united",
        "manchester city": "man city",
        "nottingham forest": "nott m forest",
        "brighton and hove albion": "brighton",
    }
    # použij rewrite i když je za názvem ještě něco (např. "Nottingham Forest FC", "Manchester City U21")
    for k, v in rewrites.items():
        if s == k or s.startswith(k + " "):
            s = v + s[len(k):]
            break

    # odstraníme běžné koncovky
    for suffix in [" football club", " fc", " afc", " cf", " sc", " ac"]:
        if s.endswith(suffix):
            s = s[: -len(suffix)].strip()

    # odstraníme tečky/čárky/apostrofy apod. (ponecháme písmena, čísla, mezery)
    s = re.sub(r"[^\w\s]", "", s)

    # zredukujeme vícenásobné mezery
    s = " ".join(s.split())
    return s


def build_team_map(conn) -> dict[str, int]:
    """Vytvoří mapu normalizovaný_název -> team_id z:

    - teams.name
    - team_aliases.alias (všechny zdroje; TheOdds se tím zlepší hned)
    """
    team_map: dict[str, int] = {}

    # teams.name
    with conn.cursor() as cur:
        cur.execute("SELECT id, name FROM public.teams")
        for tid, name in cur.fetchall():
            key = norm_team_key(name or "")
            if key and key not in team_map:
                team_map[key] = int(tid)

    # team_aliases (pokud existuje tabulka)
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema='public' AND table_name='team_aliases'
            """
        )
        has_aliases = cur.fetchone() is not None

    if has_aliases:
        with conn.cursor() as cur:
            cur.execute("SELECT team_id, alias FROM public.team_aliases")
            for tid, alias in cur.fetchall():
                key = norm_team_key(alias or "")
                if key and key not in team_map:
                    team_map[key] = int(tid)

    return team_map


def resolve_team_id(conn, team_map: dict[str, int], team_name: str) -> int | None:
    """Najde team_id podle normalizované mapy.

    Když najde, pokusí se uložit alias do team_aliases pro source='theodds'
    (aby příště matchovalo i bez speciálních pravidel).
    """
    key = norm_team_key(team_name or "")
    if not key:
        return None

    tid = team_map.get(key)
    if tid is None:
        return None

    # pokusně uložíme alias pro theodds
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO public.team_aliases(team_id, alias, source)
                VALUES (%s, %s, 'theodds')
                ON CONFLICT (alias, source) DO NOTHING
                """,
                (tid, team_name),
            )
    except Exception:
        # kdyby insert selhal, nesmíme nechat transakci v aborted stavu
        try:
            conn.rollback()
        except Exception:
            pass

    return tid


def get_h2h_market_id(conn):
    with conn.cursor() as cur:
        cur.execute("select id from markets where lower(code)=lower('h2h') limit 1")
        r = cur.fetchone()
        if not r:
            raise RuntimeError("Market h2h neexistuje v tabulce markets (code='h2h')")
        return r[0]


def get_market_outcome_map(conn, market_id):
    """Vrátí mapu kódů outcome -> market_outcome_id.

    Pro h2h očekáváme: 1 / X / 2.
    """
    with conn.cursor() as cur:
        cur.execute(
            "select id, code from market_outcomes where market_id=%s",
            (market_id,),
        )
        return {code: mid for (mid, code) in cur.fetchall()}


def get_or_create_bookmaker(conn, btitle: str, bregion: str, bkey: str):
    """
    Bezpečné bez ON CONFLICT – funguje i když v DB není UNIQUE constraint.
    Identifikace: (ext_source='theodds', ext_bookmaker_key=bkey) – uprav sloupce podle své tabulky.
    """
    with conn.cursor() as cur:
        # 1) zkus najít existující
        cur.execute(
            """
            select id
            from bookmakers
            where ext_source = 'theodds'
              and ext_bookmaker_key = %s
            limit 1
            """,
            (bkey,),
        )
        row = cur.fetchone()
        if row:
            return row[0]

        # 2) vytvoř
        try:
            cur.execute(
                """
                insert into bookmakers (name, region, ext_source, ext_bookmaker_key)
                values (%s, %s, 'theodds', %s)
                returning id
                """,
                (btitle, bregion, bkey),
            )
            new_id = cur.fetchone()[0]
            conn.commit()
            return new_id
        except Exception:
            # pokud mezitím vložil někdo jiný → rollback + znovu select
            conn.rollback()
            cur.execute(
                """
                select id
                from bookmakers
                where ext_source = 'theodds'
                  and ext_bookmaker_key = %s
                limit 1
                """,
                (bkey,),
            )
            row = cur.fetchone()
            return row[0] if row else None


def find_match_id(conn, home_team_id: int, away_team_id: int, kickoff_iso: str):
    """Najde match podle home/away a kickoff okna (+/- 12 hod). kickoff_iso je ISO (např. ...Z)."""
    with conn.cursor() as cur:
        cur.execute(
            """
            select id
            from matches
            where home_team_id=%s
              and away_team_id=%s
              and kickoff between ((%s)::timestamptz AT TIME ZONE 'UTC') - interval '12 hours'
                              and ((%s)::timestamptz AT TIME ZONE 'UTC') + interval '12 hours'
            order by abs(
                extract(epoch from (kickoff - ((%s)::timestamptz AT TIME ZONE 'UTC')))
            ) asc
            limit 1
            """,
            (home_team_id, away_team_id, kickoff_iso, kickoff_iso, kickoff_iso),
        )
        r = cur.fetchone()
        return r[0] if r else None


def odds_exists(conn, match_id: int, bookmaker_id: int, market_outcome_id: int, odd_value: float):
    """Volitelná pojistka proti duplicitám (rychlé ověření)."""
    with conn.cursor() as cur:
        cur.execute(
            """
            select 1
            from odds
            where match_id=%s
              and bookmaker_id=%s
              and market_outcome_id=%s
              and odd_value=%s
            limit 1
            """,
            (match_id, bookmaker_id, market_outcome_id, odd_value),
        )
        return cur.fetchone() is not None


# ---------- MAIN ----------

def main():
    conn = db()
    print("conn type:", type(conn), conn)
    team_map = build_team_map(conn)
    print("TEAM MAP loaded:", len(team_map))

    try:
        market_id = get_h2h_market_id(conn)
        outcome_map = get_market_outcome_map(conn, market_id)

        # načteme RAW payloady z TheOdds (odds endpointy)
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                select endpoint, payload
                from api_raw_payloads
                where source='theodds'
                  and endpoint like '/sports/%/odds'
                order by id asc
                """
            )
            rows = cur.fetchall()

        inserted = 0
        skipped_no_match = 0
        skipped_no_team = 0

        for row in rows:
            payload = row.get("payload")

            # TheOdds RAW payload může být:
            # - list eventů (nejčastější, když taháš /odds)
            # - dict s klíčem "data"
            # - dict s chybou {"message": ..., "error_code": ...}
            if payload is None:
                continue

            if isinstance(payload, list):
                data = payload
            elif isinstance(payload, dict):
                if isinstance(payload.get("data"), list):
                    data = payload.get("data") or []
                else:
                    msg = payload.get("message") or payload.get("error") or str(payload)[:200]
                    print("SKIP payload (not events list):", msg)
                    continue
            else:
                print("SKIP payload (unexpected type):", type(payload))
                continue

            for event in data:
                home = event.get("home_team")
                away = event.get("away_team")
                commence_time = event.get("commence_time")
                if not home or not away or not commence_time:
                    continue

                home_id = resolve_team_id(conn, team_map, home)
                away_id = resolve_team_id(conn, team_map, away)
                if not home_id or not away_id:
                    print("NO TEAM MATCH:", home, "vs", away)
                    skipped_no_team += 1
                    continue

                match_id = find_match_id(conn, home_id, away_id, commence_time)
                if not match_id:
                    skipped_no_match += 1
                    continue

                for bookmaker in event.get("bookmakers", []) or []:
                    bkey = bookmaker.get("key")
                    btitle = bookmaker.get("title")
                    bregion = bookmaker.get("region")
                    if not bkey or not btitle:
                        continue

                    bookmaker_id = get_or_create_bookmaker(conn, btitle, bregion, bkey)

                    for market in bookmaker.get("markets", []) or []:
                        if market.get("key") != "h2h":
                            continue

                        for outcome in market.get("outcomes", []) or []:
                            name = outcome.get("name")  # u h2h je to jméno týmu nebo "Draw"
                            price = outcome.get("price")
                            if name is None or price is None:
                                continue

                            # map na 1/X/2
                            if name == home:
                                mcode = "1"
                            elif name == away:
                                mcode = "2"
                            else:
                                mcode = "X"

                            market_outcome_id = outcome_map.get(mcode)
                            if not market_outcome_id:
                                continue

                            if odds_exists(conn, match_id, bookmaker_id, market_outcome_id, float(price)):
                                continue

                            try:
                                with conn.cursor() as cur2:
                                    cur2.execute(
                                        """
                                        insert into odds(
                                            match_id,
                                            bookmaker_id,
                                            market_outcome_id,
                                            odd_value,
                                            collected_at
                                        )
                                        values (%s, %s, %s, %s, now())
                                        """,
                                        (match_id, bookmaker_id, market_outcome_id, float(price)),
                                    )
                                inserted += 1
                            except Exception as e:
                                try:
                                    conn.rollback()
                                except Exception:
                                    pass
                                print("DB ERROR insert odds:", e)
                                continue

        conn.commit()
        print("Inserted odds:", inserted)
        print("Skipped (no team match):", skipped_no_team)
        print("Skipped (no DB match):", skipped_no_match)

    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
