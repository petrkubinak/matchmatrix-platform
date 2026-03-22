import os
import time
import json
import re
import unicodedata
from typing import Any, Iterable

import psycopg2
import requests
from psycopg2.extras import RealDictCursor

# ----------------------------
# MatchMatrix – The Odds API ingest (multi-league)
# ----------------------------
#
# Co skript dělá:
# 1) Načte všechny leagues.theodds_key z DB
# 2) Pro každou ligu zavolá The Odds API /sports/{sport_key}/odds
# 3) Uloží RAW payload do api_raw_payloads
# 4) Naparsuje kurzy do odds (market h2h → 1/X/2)
# 5) Ignoruje HTTP 422 (Starter plán) a nespadne při jedné chybné lize
#
# Env:
# - DB_DSN            (povinné)
# - THEODDS_API_KEY   (povinné)
# - THEODDS_BASE_URL  (default https://api.the-odds-api.com/v4)
# - THEODDS_REGIONS   (default eu)
# - THEODDS_MARKETS   (default h2h)
# - THEODDS_SLEEP_SEC (default 1.2)
# - THEODDS_MAX_LEAGUES (volitelné, např. 10 – pro omezení počtu lig)
#

DB_DSN = os.environ["DB_DSN"]
THEODDS_API_KEY = os.environ.get("THEODDS_API_KEY")  # povinné – ověří se v main()

THEODDS_BASE_URL = os.environ.get("THEODDS_BASE_URL", "https://api.the-odds-api.com/v4").rstrip("/")
THEODDS_REGIONS = os.environ.get("THEODDS_REGIONS", "eu")
THEODDS_MARKETS = os.environ.get("THEODDS_MARKETS", "h2h")
THEODDS_SLEEP_SEC = float(os.environ.get("THEODDS_SLEEP_SEC", "1.2"))
THEODDS_MAX_LEAGUES = os.environ.get("THEODDS_MAX_LEAGUES")


# ---------- DB helpers ----------

def db():
    return psycopg2.connect(DB_DSN)


def start_import_run(conn, source: str = "theodds") -> int:
    """Založí api_import_runs a vrátí run_id."""
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into public.api_import_runs(source, status, details)
            values (%s, 'running', %s::jsonb)
            returning id
            """,
            (source, json.dumps({"script": "theodds_parse.py"})),
        )
        run_id = int(cur.fetchone()[0])
    conn.commit()
    return run_id


def finish_import_run(conn, run_id: int, status: str, details: dict[str, Any]):
    with conn.cursor() as cur:
        cur.execute(
            """
            update public.api_import_runs
               set finished_at = now(),
                   status = %s,
                   details = %s::jsonb
             where id = %s
            """,
            (status, json.dumps(details), run_id),
        )
    conn.commit()


def insert_raw_payload(conn, run_id: int, source: str, endpoint: str, payload: Any):
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into public.api_raw_payloads(run_id, source, endpoint, payload)
            values (%s, %s, %s, %s::jsonb)
            """,
            (run_id, source, endpoint, json.dumps(payload)),
        )
    conn.commit()


def load_theodds_keys_from_db(conn) -> list[str]:
    """Načte všechny leagues.theodds_key (unikátní, neprázdné)."""
    with conn.cursor() as cur:
        cur.execute(
            """
            select distinct theodds_key
            from public.leagues
            where theodds_key is not null
              and btrim(theodds_key) <> ''
            order by theodds_key
            """
        )
        keys = [r[0] for r in cur.fetchall() if r and r[0]]

    if THEODDS_MAX_LEAGUES:
        try:
            n = int(THEODDS_MAX_LEAGUES)
            if n > 0:
                keys = keys[:n]
        except Exception:
            pass

    return keys


# ---------- Team name normalization / matching ----------

def _strip_diacritics(s: str) -> str:
    return "".join(ch for ch in unicodedata.normalize("NFKD", s) if not unicodedata.combining(ch))


def norm_team_key(name: str) -> str:
    """Normalizace názvu týmu pro matchování napříč zdroji (TheOdds vs canonical teams).

    Cíl: aby 'Paris Saint-Germain' == 'Paris Saint Germain', '1. FC Köln' == 'FC Koln', atd.
    """
    if not name:
        return ""

    s = name.strip().replace("’", "'")
    s = _strip_diacritics(s).lower()

    # odstranění prefixů typu "1. "
    s = re.sub(r"^\d+\.\s*", "", s)

    # odstranění běžných klubových prefixů
    s = re.sub(r"^(fc|sc|ac|as|sv|fk|rc|tsg)\s+", "", s)

    # odstraníme běžné koncovky
    for suffix in [" football club", " fc", " afc", " cf", " sc", " ac"]:
        if s.endswith(suffix):
            s = s[: -len(suffix)].strip()

    # cílené přepisy – držíme MINIMUM (přidávej až podle logu)
    rewrites = {
        "paris saint germain": "paris saint-germain",
        "borussia monchengladbach": "borussia mönchengladbach",
    }
    # Pozn.: rewrites děláme až po základním čištění; pro match používáme opět norm klíč,
    # takže diakritika/pomlčky nehrají roli. Tohle je jen pro sjednocení specifických případů.
    if s in rewrites:
        s = rewrites[s]

    # interpunkce pryč (ponecháme písmena/čísla/mezery)
    s = re.sub(r"[^a-z0-9\s]+", " ", s)
    s = " ".join(s.split())
    return s
def load_team_maps(conn) -> tuple[dict[str, int], dict[str, int]]:
    """Vrátí dvě mapy pro rychlé mapování týmů:
    - alias_map: norm(alias z team_aliases pro source='theodds') -> team_id
    - team_map: norm(canonical jména v teams) -> team_id, kde canonical = teams.name (+ ext_team_id pro football_data_uk)

    Důvod: nechceme míchat aliasy z jiných sources (football_data_uk, apod.) do mapování TheOdds.
    """
    alias_map: dict[str, int] = {}
    team_map: dict[str, int] = {}

    # canonical teams
    with conn.cursor() as cur:
        cur.execute("SELECT id, name, ext_source, ext_team_id FROM public.teams")
        for tid, name, ext_source, ext_team_id in cur.fetchall():
            tid = int(tid)

            k1 = norm_team_key(name or "")
            if k1 and k1 not in team_map:
                team_map[k1] = tid

            # football_data_uk má často ext_team_id jako "oficiální" jméno – bereme také
            if ext_source == "football_data_uk" and ext_team_id:
                k2 = norm_team_key(ext_team_id or "")
                if k2 and k2 not in team_map:
                    team_map[k2] = tid

    # theodds aliasy (pokud tabulka existuje)
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
            cur.execute(
                """
                SELECT team_id, alias
                FROM public.team_aliases
                WHERE source = 'theodds'
                """
            )
            for tid, alias in cur.fetchall():
                k = norm_team_key(alias or "")
                if k and k not in alias_map:
                    alias_map[k] = int(tid)

    return alias_map, team_map


def _insert_theodds_alias_if_missing(conn, team_id: int, alias_raw: str) -> None:
    """Vloží alias pro source='theodds' jen pokud ještě neexistuje (case-insensitive).
    Nepotřebuje UNIQUE index.
    """
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.team_aliases(team_id, alias, source)
            SELECT %s, %s, 'theodds'
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.team_aliases ta
                WHERE ta.source = 'theodds'
                  AND lower(ta.alias) = lower(%s)
            )
            """,
            (team_id, alias_raw, alias_raw),
        )


def resolve_team_id_theodds(
    conn,
    alias_map: dict[str, int],
    team_map: dict[str, int],
    team_name_raw: str,
    auto_insert_alias: bool = True,
) -> int | None:
    """Mapuje tým z TheOdds -> teams.id

    1) přes existující aliasy (team_aliases.source='theodds')
    2) přes canonical teams (teams.name / teams.ext_team_id pro football_data_uk)
    3) pokud 2) uspěje, uloží alias do team_aliases (aby příště stačil krok 1)
    """
    key = norm_team_key(team_name_raw or "")
    if not key:
        return None

    tid = alias_map.get(key)
    if tid is not None:
        return tid

    tid = team_map.get(key)
    if tid is None:
        return None

    if auto_insert_alias:
        try:
            _insert_theodds_alias_if_missing(conn, tid, team_name_raw)
            conn.commit()
        except Exception:
            try:
                conn.rollback()
            except Exception:
                pass

    alias_map[key] = tid
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


def get_or_create_bookmaker(conn, btitle: str, bregion: str | None, bkey: str):
    """Bezpečné bez ON CONFLICT – funguje i když v DB není UNIQUE constraint.
    Identifikace: (ext_source='theodds', ext_bookmaker_key=bkey)
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


# ---------- The Odds API ----------

def fetch_odds_for_sport(sport_key: str) -> tuple[int, Any, str]:
    """Vrátí (status_code, parsed_json_or_text, endpoint_str)."""
    endpoint = f"/sports/{sport_key}/odds"
    url = f"{THEODDS_BASE_URL}{endpoint}"
    params = {
        "apiKey": THEODDS_API_KEY,
        "regions": THEODDS_REGIONS,
        "markets": THEODDS_MARKETS,
        "oddsFormat": "decimal",
        "dateFormat": "iso",
    }

    try:
        resp = requests.get(url, params=params, timeout=30)
    except Exception as e:
        # síťová chyba → uložíme jako "payload" strukturovaně
        return 0, {"error": "request_failed", "message": str(e), "sport_key": sport_key}, endpoint

    status = int(resp.status_code)

    # snažíme se o JSON, fallback na text
    try:
        payload = resp.json()
    except Exception:
        payload = {"raw_text": resp.text[:2000], "sport_key": sport_key}

    return status, payload, endpoint


# ---------- Parsing odds payload → DB odds ----------

def iter_events_from_payload(payload: Any) -> Iterable[dict[str, Any]]:
    """TheOdds payload může být:
    - list eventů
    - dict s klíčem "data"
    - dict s chybou
    """
    if payload is None:
        return []
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict) and isinstance(payload.get("data"), list):
        return payload.get("data") or []
    return []


def parse_and_insert_odds(
    conn,
    sport_key: str,
    alias_map: dict[str, int],
    team_map: dict[str, int],
    outcome_map: dict[str, int],
    payload: Any,
    unmatched: dict[str, dict[str, Any]],
) -> tuple[int, int, int]:
    """Naparsuje a vloží odds. Vrací (inserted, skipped_no_team, skipped_no_match).
    unmatched: sběr týmů, které nešly namapovat na teams.id.
    """
    inserted = 0
    skipped_no_team = 0
    skipped_no_match = 0

    events = iter_events_from_payload(payload)
    for event in events:
        home_team_name = event.get("home_team")
        away_team_name = event.get("away_team")
        commence_time = event.get("commence_time")
        if not home_team_name or not away_team_name or not commence_time:
            continue

        home_id = resolve_team_id_theodds(conn, alias_map, team_map, home_team_name)
        away_id = resolve_team_id_theodds(conn, alias_map, team_map, away_team_name)
        if not home_id or not away_id:
            print("NO TEAM MATCH:", home_team_name, "vs", away_team_name)
            if not home_id:
                add_unmatched_team(unmatched, sport_key, home_team_name)
            if not away_id:
                add_unmatched_team(unmatched, sport_key, away_team_name)
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
            if not bookmaker_id:
                continue

            for market in bookmaker.get("markets", []) or []:
                if market.get("key") != "h2h":
                    continue

                for outcome in market.get("outcomes", []) or []:
                    name = outcome.get("name")  # u h2h je to jméno týmu nebo "Draw"
                    price = outcome.get("price")
                    if name is None or price is None:
                        continue

                    # map na 1/X/2
                    if name == home_team_name:
                        mcode = "1"
                    elif name == away_team_name:
                        mcode = "2"
                    else:
                        mcode = "X"

                    market_outcome_id = outcome_map.get(mcode)
                    if not market_outcome_id:
                        continue

                    odd_value = float(price)
                    if odds_exists(conn, match_id, bookmaker_id, market_outcome_id, odd_value):
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
                                (match_id, bookmaker_id, market_outcome_id, odd_value),
                            )
                        conn.commit()
                        inserted += 1
                    except Exception as e:
                        try:
                            conn.rollback()
                        except Exception:
                            pass
                        print("DB ERROR insert odds:", e)
                        continue

    return inserted, skipped_no_team, skipped_no_match


# ---------- MAIN ----------

def load_league_team_coverage(conn) -> dict[str, int]:
    """Vrátí mapu {theodds_key: teams_present} podle vazeb přes matches.
    Používáme to pro Variant A: odds parsujeme jen u lig, kde máme slušnou týmovou coverage v DB.
    """
    cov: dict[str, int] = {}
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT l.theodds_key,
                   COUNT(DISTINCT t.id) AS teams_present
            FROM public.leagues l
            LEFT JOIN public.matches m ON m.league_id = l.id
            LEFT JOIN public.teams t ON t.id IN (m.home_team_id, m.away_team_id)
            WHERE l.theodds_key IS NOT NULL
            GROUP BY l.theodds_key
            """
        )
        for k, teams_present in cur.fetchall():
            if k:
                cov[str(k)] = int(teams_present or 0)
    return cov


def add_unmatched_team(unmatched: dict[str, dict[str, Any]], sport_key: str, team_name: str) -> None:
    """Sběr unikátních 'neznámých' týmů pro report."""
    if not team_name:
        return
    key = team_name.strip().lower()
    if not key:
        return
    rec = unmatched.get(key)
    if rec is None:
        unmatched[key] = {"name": team_name.strip(), "count": 1, "leagues": {sport_key}}
    else:
        rec["count"] = int(rec.get("count", 0)) + 1
        rec.setdefault("leagues", set()).add(sport_key)


def write_unmatched_team_reports(run_id: int, unmatched: dict[str, dict[str, Any]]) -> None:
    """Vytvoří 2 soubory do aktuální složky:
    - unmatched_theodds_<run_id>.csv (týmy, které nešly namapovat na teams.id)
    - unmatched_theodds_<run_id>.sql (skeleton INSERTů do team_aliases)
    """
    if not unmatched:
        return

    csv_path = f"unmatched_theodds_{run_id}.csv"
    sql_path = f"unmatched_theodds_{run_id}.sql"

    import csv
    rows = sorted(
        (
            (v.get("name"), v.get("count", 0), ",".join(sorted(list(v.get("leagues", set())))))
            for v in unmatched.values()
        ),
        key=lambda r: (-int(r[1] or 0), (r[0] or "").lower()),
    )
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["team_name", "count", "leagues"])
        for name, cnt, leagues in rows:
            w.writerow([name, cnt, leagues])

    with open(sql_path, "w", encoding="utf-8") as f:
        f.write(f"-- Unmatched theodds team names from run_id={run_id}\n")
        f.write("-- DOPLN team_id (vyhledej v public.teams) a spusť.\n\n")
        for name, cnt, leagues in rows:
            safe = (name or "").replace("'", "''")
            f.write(f"-- seen {cnt}x in leagues: {leagues}\n")
            f.write("INSERT INTO public.team_aliases(team_id, alias, source)\n")
            f.write(f"VALUES (/* team_id */ NULL, '{safe}', 'theodds');\n\n")


def main():
    if not THEODDS_API_KEY:
        raise RuntimeError("Chybí env THEODDS_API_KEY")

    conn = db()
    run_id = None

    unmatched_teams: dict[str, dict[str, Any]] = {}

    totals = {
        "leagues_total": 0,
        "leagues_ok": 0,
        "leagues_422": 0,
        "leagues_error": 0,
        "raw_saved": 0,
        "odds_inserted": 0,
        "skipped_no_team": 0,
        "skipped_no_match": 0,
    }

    try:
        run_id = start_import_run(conn, source="theodds")
        print("RUN_ID:", run_id)

        alias_map, team_map = load_team_maps(conn)
        print("TEAM MAP loaded:", len(team_map))

        market_id = get_h2h_market_id(conn)
        outcome_map = get_market_outcome_map(conn, market_id)

        sport_keys = load_theodds_keys_from_db(conn)
    min_teams_present = int(os.getenv('THEODDS_MIN_TEAMS_PRESENT', '35'))
    league_coverage = load_league_team_coverage(conn)
        totals["leagues_total"] = len(sport_keys)
        print("Leagues from DB (theodds_key):", len(sport_keys))

        for i, sport_key in enumerate(sport_keys, start=1):
            print(f"[{i}/{len(sport_keys)}] Fetching: {sport_key}")
            status, payload, endpoint = fetch_odds_for_sport(sport_key)

            # vždy uložíme RAW (i chyby) – ať je dohledatelné co se stalo
            raw_payload = {
                "sport_key": sport_key,
                "status_code": status,
                "payload": payload,
            }
            try:
                insert_raw_payload(conn, run_id, "theodds", endpoint, raw_payload)
                totals["raw_saved"] += 1
            except Exception as e:
                try:
                    conn.rollback()
                except Exception:
                    pass
                print("DB ERROR insert api_raw_payloads:", e)

            # 422 = Starter plán omezení → ignorovat
            if status == 422:
                totals["leagues_422"] += 1
                print("SKIP 422 (plan limitation):", sport_key)
                time.sleep(THEODDS_SLEEP_SEC)
                continue

            # síťová chyba (status=0) nebo jiné HTTP chyby
            if status == 0 or status >= 400:
                totals["leagues_error"] += 1
                msg = None
                if isinstance(payload, dict):
                    msg = payload.get("message") or payload.get("error") or payload.get("raw_text")
                print("ERROR league:", sport_key, "status:", status, "msg:", (msg or "")[:200])
                time.sleep(THEODDS_SLEEP_SEC)
                continue

            teams_present = league_coverage.get(sport_key, 0)
            if teams_present < min_teams_present:
                totals["leagues_raw_only"] += 1
                print(f"RAW-only league (teams_present={teams_present} < {min_teams_present}):", sport_key)
                time.sleep(THEODDS_SLEEP_SEC)
                continue

            # OK → parse odds
            try:
                ins, sk_team, sk_match = parse_and_insert_odds(
                    conn,
                    sport_key,
                    alias_map,
                    team_map,
                    outcome_map,
                    payload,
                    unmatched_teams,
                )
                totals["odds_inserted"] += ins
                totals["skipped_no_team"] += sk_team
                totals["skipped_no_match"] += sk_match
                totals["leagues_ok"] += 1
                print("Inserted odds:", ins, "(league:", sport_key, ")")
            except Exception as e:
                totals["leagues_error"] += 1
                try:
                    conn.rollback()
                except Exception:
                    pass
                print("ERROR parsing/inserting league:", sport_key, e)

            time.sleep(THEODDS_SLEEP_SEC)

        write_unmatched_team_reports(run_id, unmatched_teams)

        finish_import_run(conn, run_id, status="ok", details=totals)
        print("DONE. Summary:", totals)

    except Exception as e:
        if conn:
            try:
                conn.rollback()
            except Exception:
                pass
        if run_id is not None:
            try:
                finish_import_run(conn, run_id, status="error", details={**totals, "error": str(e)})
            except Exception:
                pass
        raise
    finally:
        try:
            conn.close()
        except Exception:
            pass


if __name__ == "__main__":
    main()
