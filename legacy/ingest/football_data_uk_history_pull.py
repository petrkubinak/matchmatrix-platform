# MatchMatrix-platform/ingest/football_data_uk_history_pull.py
import os
import csv
import io
import re
import requests
import psycopg2
from datetime import datetime

DB_DSN = os.environ["DB_DSN"]

BASE_URL = "https://www.football-data.co.uk/mmz4281"
SEASONS_BACK = int(os.getenv("FD_SEASONS_BACK", "8"))

# diagnostika - max kolik "MISSING ..." tisknout (jen kdyby něco ještě chybělo)
MAX_MISSING_PRINTS = int(os.getenv("FD_MAX_MISSING_PRINTS", "50"))


def db():
    return psycopg2.connect(DB_DSN)


def norm_team_key(name: str) -> str:
    """Normalizace názvu týmu, aby se matchovalo CSV vs DB."""
    if not name:
        return ""

    s = name.lower().strip()

    # odstraníme běžné koncovky
    for suffix in [" fc", " afc", " cf", " sc", " ac", " football club"]:
        if s.endswith(suffix):
            s = s[:-len(suffix)].strip()

    # lehké sjednocení některých vzorů (pomáhá u anglických týmů)
    s = s.replace("tottenham hotspur", "tottenham")

    # odstraníme tečky/čárky/apostrofy apod.
    s = s.replace("’", "'")
    s = re.sub(r"[^\w\s]", "", s)

    # zredukujeme vícenásobné mezery
    s = " ".join(s.split())

    return s


def parse_date(date_str: str):
    """football-data.co.uk typicky dd/mm/yy, někdy dd/mm/yyyy."""
    if not date_str:
        return None
    s = date_str.strip()
    for fmt in ("%d/%m/%y", "%d/%m/%Y"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            pass
    return None


def get_season_codes():
    """
    Vrací list sezon ve formátu '2425' atd.
    (tj. 2024/25 -> '2425')
    """
    now = datetime.now().year
    seasons = []
    for i in range(SEASONS_BACK):
        start = now - i - 1
        end = start + 1
        seasons.append(f"{str(start)[-2:]}{str(end)[-2:]}")
    return seasons


def fetch_csv(url: str):
    r = requests.get(url, timeout=30)
    if r.status_code != 200:
        print("SKIP CSV:", url, "(HTTP", r.status_code, ")")
        return None
    return r.text


def table_exists(conn, table_name: str) -> bool:
    with conn.cursor() as cur:
        cur.execute(
            """
            select 1
            from information_schema.tables
            where table_schema='public' and table_name=%s
            """,
            (table_name,),
        )
        return cur.fetchone() is not None


def build_team_map(conn):
    """
    dict: normalized_name -> team_id
    - vždy přidá teams.name
    - pokud existuje team_aliases, přidá i aliasy pro source='football_data_uk'
    """
    use_aliases = table_exists(conn, "team_aliases")
    team_map: dict[str, int] = {}

    with conn.cursor() as cur:
        cur.execute("select id, name from teams")
        for tid, name in cur.fetchall():
            key = norm_team_key(name)
            if key:
                team_map[key] = tid

        if use_aliases:
            cur.execute(
                """
                select a.team_id, a.alias
                from team_aliases a
                where a.source = 'football_data_uk'
                """
            )
            for tid, alias in cur.fetchall():
                key = norm_team_key(alias)
                if key:
                    team_map[key] = tid

    return team_map, use_aliases


def get_or_create_team_id(conn, team_map: dict, team_name: str) -> int:
    """
    Vrátí team_id:
    - pokud existuje v mapě -> vrátí
    - jinak INSERT do teams jako ext_source='football_data_uk' + ext_team_id=team_name
      (idempotentně přes ON CONFLICT), pak SELECT id a vrátí
    """
    key = norm_team_key(team_name)
    if not key:
        raise ValueError("Empty team name")

    existing = team_map.get(key)
    if existing:
        return existing

    with conn.cursor() as cur:
        # Bez znalosti tvých unique constraintů je nejbezpečnější:
        # 1) pokus o insert
        # 2) když selže (duplicate), prostě selectneme id podle ext_source/ext_team_id nebo name
        try:
            cur.execute(
                """
                insert into teams (name, ext_source, ext_team_id)
                values (%s, 'football_data_uk', %s)
                returning id
                """,
                (team_name, team_name),
            )
            tid = cur.fetchone()[0]
        except Exception:
            conn.rollback()
            conn.autocommit = False
            with conn.cursor() as cur2:
                # Preferujeme ext_source/ext_team_id, ale když tam není unique,
                # aspoň zkusíme najít podle name.
                cur2.execute(
                    """
                    select id
                    from teams
                    where (ext_source='football_data_uk' and ext_team_id=%s)
                       or name=%s
                    order by id desc
                    limit 1
                    """,
                    (team_name, team_name),
                )
                row = cur2.fetchone()
                if not row:
                    raise
                tid = row[0]

    team_map[key] = tid
    return tid


def upsert_match(conn, league_id, home_id, away_id, kickoff_dt, hs, as_, season_code, ext_id):
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into matches(
                sport_id,
                league_id,
                home_team_id,
                away_team_id,
                kickoff,
                status,
                home_score,
                away_score,
                season,
                ext_source,
                ext_match_id
            )
            values (
                (select sport_id from leagues where id=%s),
                %s,%s,%s,%s,
                'FINISHED',
                %s,%s,%s,
                'football_data_uk',
                %s
            )
            on conflict (ext_source, ext_match_id) do update
              set sport_id    = excluded.sport_id,
                  league_id   = excluded.league_id,
                  home_team_id= excluded.home_team_id,
                  away_team_id= excluded.away_team_id,
                  home_score  = excluded.home_score,
                  away_score  = excluded.away_score,
                  status      = 'FINISHED',
                  kickoff     = excluded.kickoff,
                  season      = excluded.season
            """,
            (
                league_id,  # subselect sport_id
                league_id,
                home_id,
                away_id,
                kickoff_dt,
                hs,
                as_,
                season_code,
                ext_id,
            ),
        )


def main():
    conn = db()
    conn.autocommit = False

    seasons = get_season_codes()

    # ligy k importu = ty, co mají ext_csv_code
    with conn.cursor() as cur:
        cur.execute(
            """
            select id, ext_csv_code
            from leagues
            where ext_csv_code is not null
            order by id
            """
        )
        leagues = cur.fetchall()

    team_map, used_aliases = build_team_map(conn)
    print("TEAM MAP loaded. aliases_used=", used_aliases, "entries=", len(team_map))

    total = 0
    missing_prints = 0

    for league_id, code in leagues:
        for season in seasons:
            url = f"{BASE_URL}/{season}/{code}.csv"
            print("Fetching:", url)

            csv_text = fetch_csv(url)
            if not csv_text:
                continue

            reader = csv.DictReader(io.StringIO(csv_text))
            required_cols = {"Date", "HomeTeam", "AwayTeam", "FTHG", "FTAG"}
            if not required_cols.issubset(set(reader.fieldnames or [])):
                print("SKIP CSV (missing columns):", url, "fields=", reader.fieldnames)
                continue

            for row in reader:
                home = (row.get("HomeTeam") or "").strip()
                away = (row.get("AwayTeam") or "").strip()
                hs = (row.get("FTHG") or "").strip()
                as_ = (row.get("FTAG") or "").strip()

                if not home or not away or hs == "" or as_ == "":
                    continue

                # ✅ AUTO-CREATE týmů, aby se zápasy neskipovaly
                try:
                    home_id = get_or_create_team_id(conn, team_map, home)
                    away_id = get_or_create_team_id(conn, team_map, away)
                except Exception as e:
                    if missing_prints < MAX_MISSING_PRINTS:
                        print("TEAM CREATE/LOOKUP ERROR:", e, "home=", home, "away=", away)
                        missing_prints += 1
                    continue

                date_obj = parse_date(row.get("Date") or "")
                if date_obj is None:
                    continue

                ext_id = f"{league_id}|{season}|{row.get('Date')}|{home}|{away}"

                try:
                    upsert_match(
                        conn,
                        league_id=league_id,
                        home_id=home_id,
                        away_id=away_id,
                        kickoff_dt=date_obj,
                        hs=int(hs),
                        as_=int(as_),
                        season_code=season,
                        ext_id=ext_id,
                    )
                    total += 1
                except Exception as e:
                    print("ROW ERROR:", e, "row=", row)
                    conn.rollback()
                    conn.autocommit = False
                    continue

            conn.commit()

    print("IMPORT DONE. Matches:", total)
    conn.close()


if __name__ == "__main__":
    main()
