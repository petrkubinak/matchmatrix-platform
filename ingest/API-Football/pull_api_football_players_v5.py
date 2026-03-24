from __future__ import annotations

import argparse
import os
import time
import json
from contextlib import closing
from pathlib import Path

import requests
import psycopg2
from psycopg2.extras import RealDictCursor, execute_values
from dotenv import load_dotenv


# ==========================================================
# MATCHMATRIX - API-FOOTBALL PLAYERS INGEST V5
#
# Kam uložit:
# C:\MatchMatrix-platform\ingest\API-Football\pull_api_football_players_v5.py
#
# Režim 1 - planner-native single run:
# python C:\MatchMatrix-platform\ingest\API-Football\pull_api_football_players_v5.py --league-id 210 --season 2022 --run-id 288 --job-id 1246
#
# Režim 2 - batch režim (claim pending jobs z planneru):
# python C:\MatchMatrix-platform\ingest\API-Football\pull_api_football_players_v5.py
# ==========================================================


# ==========================================================
# LOAD .ENV - vždy ze stejné složky jako je skript
# C:\MatchMatrix-platform\ingest\API-Football\.env
# ==========================================================
ENV_PATH = Path(__file__).resolve().parent / ".env"

if not ENV_PATH.exists():
    raise RuntimeError(f".env nebyl nalezen: {ENV_PATH}")

load_dotenv(dotenv_path=ENV_PATH)


# ==========================================================
# CONSTANTS
# ==========================================================
API_BASE = os.getenv("APISPORTS_BASE", "https://v3.football.api-sports.io").strip()

PROVIDER_CODE = "api_football"
SPORT_CODE = "football"
ENTITY = "players"


# ==========================================================
# ARGUMENTS
# ==========================================================
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix API-Football Players Ingest V4")

    parser.add_argument("--league-id", default=None, help="Provider league ID pro single-run režim")
    parser.add_argument("--season", default=None, help="Season pro single-run režim, např. 2022")
    parser.add_argument("--run-id", type=int, default=None, help="Skutečný ingest/planner run_id")
    parser.add_argument("--job-id", type=int, default=None, help="Planner job ID")
    parser.add_argument("--limit", type=int, default=None, help="Limit jobů pro batch režim")
    parser.add_argument("--sleep-sec", type=float, default=None, help="Sleep mezi API requesty")
    parser.add_argument("--no-mark-done", action="store_true", help="Neměnit planner status na done/error")

    return parser.parse_args()


# ==========================================================
# HELPERS
# ==========================================================
def print_header(title: str) -> None:
    print("=" * 80)
    print(title)
    print("=" * 80)


def get_db_connection():
    """
    DB připojení z .env
    """
    pg_host = os.getenv("PGHOST", "localhost").strip()
    pg_port = os.getenv("PGPORT", "5432").strip()
    pg_db = os.getenv("PGDATABASE", "matchmatrix").strip()
    pg_user = os.getenv("PGUSER", "matchmatrix").strip()
    pg_password = os.getenv("PGPASSWORD", "").strip()

    if not pg_password:
        raise RuntimeError(f"Chybí PGPASSWORD v .env. Načtený .env: {ENV_PATH}")

    conn = psycopg2.connect(
        host=pg_host,
        port=pg_port,
        dbname=pg_db,
        user=pg_user,
        password=pg_password,
    )
    conn.set_client_encoding("UTF8")
    return conn


def get_api_key() -> str:
    api_key = os.getenv("APISPORTS_KEY", "").strip()
    if not api_key:
        raise RuntimeError(f"Chybí APISPORTS_KEY v .env. Načtený .env: {ENV_PATH}")
    return api_key


def mask_key(api_key: str) -> str:
    if len(api_key) <= 10:
        return "*" * len(api_key)
    return f"{api_key[:6]}...{api_key[-4:]}"


def get_api_headers(api_key: str) -> dict:
    return {
        "x-apisports-key": api_key,
        "Accept": "application/json",
        "User-Agent": "MatchMatrix/players-ingest-v4",
    }


def parse_height_cm(value):
    if value is None:
        return None
    text = str(value).strip().lower().replace("cm", "").strip()
    try:
        return int(text)
    except Exception:
        return None


def parse_weight_kg(value):
    if value is None:
        return None
    text = str(value).strip().lower().replace("kg", "").strip()
    try:
        return int(text)
    except Exception:
        return None


# ==========================================================
# PLANNER
# ==========================================================
def claim_planner_jobs(cur, limit: int):
    """
    Batch režim:
    vezme pending players joby z planneru.
    Priorita: sezóna 2024 nejdřív.
    """
    cur.execute(
        """
        WITH picked AS (
            SELECT id
            FROM ops.ingest_planner
            WHERE provider = %s
              AND sport_code = %s
              AND entity = %s
              AND status = 'pending'
              AND (next_run IS NULL OR next_run <= NOW())
            ORDER BY
                CASE WHEN season = '2024' THEN 0 ELSE 1 END,
                priority,
                id
            FOR UPDATE SKIP LOCKED
            LIMIT %s
        )
        UPDATE ops.ingest_planner p
        SET status = 'running',
            attempts = COALESCE(attempts, 0) + 1,
            updated_at = NOW()
        WHERE p.id IN (SELECT id FROM picked)
        RETURNING
            p.id,
            p.provider,
            p.sport_code,
            p.entity,
            p.provider_league_id,
            p.season,
            p.run_group,
            p.priority,
            p.attempts;
        """,
        (PROVIDER_CODE, "FB", ENTITY, limit),
    )
    return cur.fetchall()


def mark_job_done(cur, planner_id: int):
    cur.execute(
        """
        UPDATE ops.ingest_planner
        SET status = 'done',
            updated_at = NOW()
        WHERE id = %s;
        """,
        (planner_id,),
    )


def mark_job_error(cur, planner_id: int, retry_minutes: int = 180):
    cur.execute(
        """
        UPDATE ops.ingest_planner
        SET status = 'error',
            next_run = NOW() + (%s || ' minutes')::interval,
            updated_at = NOW()
        WHERE id = %s;
        """,
        (retry_minutes, planner_id),
    )


# ==========================================================
# API
# ==========================================================
def api_get_players(
    session: requests.Session,
    league_id: str,
    season: str,
    page: int,
    headers: dict,
) -> dict:
    """
    API call:
    /players?league={league_id}&season={season}&page={page}
    """
    url = f"{API_BASE}/players"
    params = {
        "league": league_id,
        "season": season,
        "page": page,
    }

    response = session.get(url, headers=headers, params=params, timeout=60)

    print(f"HTTP STATUS: {response.status_code}")
    print(f"URL        : {response.url}")

    if response.status_code != 200:
        body_preview = response.text[:3000]
        raise RuntimeError(
            f"API request failed. status={response.status_code}, "
            f"url={response.url}, body={body_preview}"
        )

    return response.json()


# ==========================================================
# RAW PAYLOAD STORAGE
# ==========================================================
def insert_raw_payload(cur, league_id: str, season: str, payload: dict) -> int:
    """
    Uloží raw payload do unified raw storage.
    """
    payload_text = json.dumps(payload, ensure_ascii=False)

    cur.execute(
        """
        INSERT INTO staging.stg_api_payloads (
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            payload_json,
            parse_status
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s::jsonb, 'pending')
        RETURNING id;
        """,
        (
            PROVIDER_CODE,
            SPORT_CODE,
            ENTITY,
            "players",
            str(league_id),
            str(season),
            payload_text,
        ),
    )
    return cur.fetchone()["id"]


# ==========================================================
# STAGING PLAYERS_IMPORT
# ==========================================================
def delete_existing_import_for_target(cur, league_id: str, season: str):
    """
    Smaže starý import pro stejnou ligu + sezónu.
    """
    cur.execute(
        """
        DELETE FROM staging.players_import
        WHERE provider_code = %s
          AND provider_league_id = %s
          AND season = %s;
        """,
        (PROVIDER_CODE, str(league_id), str(season)),
    )


def _is_non_empty_stat_value(value) -> bool:
    if value is None:
        return False
    if isinstance(value, str) and value.strip() == "":
        return False
    return True


def _count_filled_stats(stat_row: dict) -> int:
    """
    Spočítá, kolik skutečně vyplněných statistik je v jednom statistics[] bloku.
    """
    if not isinstance(stat_row, dict):
        return -1

    fields_to_check = [
        ("games", "appearences"),
        ("games", "appearances"),
        ("games", "lineups"),
        ("games", "minutes"),
        ("games", "rating"),
        ("goals", "total"),
        ("goals", "assists"),
        ("shots", "total"),
        ("shots", "on"),
        ("passes", "total"),
        ("passes", "key"),
        ("passes", "accuracy"),
        ("tackles", "total"),
        ("tackles", "interceptions"),
        ("tackles", "blocks"),
        ("duels", "total"),
        ("duels", "won"),
        ("dribbles", "attempts"),
        ("dribbles", "success"),
        ("fouls", "drawn"),
        ("fouls", "committed"),
        ("cards", "yellow"),
        ("cards", "red"),
        ("penalty", "won"),
        ("penalty", "commited"),
        ("penalty", "committed"),
        ("penalty", "scored"),
        ("penalty", "missed"),
        ("penalty", "saved"),
        ("substitutes", "in"),
        ("substitutes", "out"),
        ("substitutes", "bench"),
    ]

    score = 0
    for parent_key, child_key in fields_to_check:
        parent = stat_row.get(parent_key, {}) or {}
        if not isinstance(parent, dict):
            continue
        value = parent.get(child_key)
        if _is_non_empty_stat_value(value):
            score += 1

    return score


def _select_best_statistics_block(statistics: list, expected_league_id: str, expected_season: str):
    """
    Vybere nejlepší statistics[] blok.

    Priorita:
    1) stejná liga + stejná sezóna + nejvíc vyplněných statistik
    2) stejná liga + nejvíc vyplněných statistik
    3) jakýkoliv blok s nejvíc vyplněnými statistikami
    4) fallback na první blok
    """
    valid_stats = [s for s in (statistics or []) if isinstance(s, dict)]

    if not valid_stats:
        return {}

    expected_league_id = str(expected_league_id) if expected_league_id is not None else None
    expected_season = str(expected_season) if expected_season is not None else None

    scored = []
    for s in valid_stats:
        league_obj = s.get("league", {}) or {}
        league_id = league_obj.get("id")
        season = league_obj.get("season")

        scored.append(
            {
                "row": s,
                "league_id": str(league_id) if league_id is not None else None,
                "season": str(season) if season is not None else None,
                "score": _count_filled_stats(s),
            }
        )

    exact = [
        x for x in scored
        if x["league_id"] == expected_league_id and x["season"] == expected_season
    ]
    if exact:
        exact.sort(key=lambda x: x["score"], reverse=True)
        return exact[0]["row"]

    same_league = [x for x in scored if x["league_id"] == expected_league_id]
    if same_league:
        same_league.sort(key=lambda x: x["score"], reverse=True)
        return same_league[0]["row"]

    scored.sort(key=lambda x: x["score"], reverse=True)
    return scored[0]["row"]


def extract_players_rows(payload: dict, league_id: str, season: str, run_id: int):
    """
    Rozparsuje response[] do rows pro staging.players_import

    DŮLEŽITÉ:
    - používá skutečný run_id
    - ne raw_payload_id
    - nebere slepě statistics[0]
    """
    rows = []
    response_items = payload.get("response", []) or []

    for item in response_items:
        player = item.get("player", {}) or {}
        statistics = item.get("statistics", []) or []

        provider_player_id = player.get("id")
        player_name = player.get("name")

        if not provider_player_id or not player_name:
            continue

        stat0 = _select_best_statistics_block(
            statistics=statistics,
            expected_league_id=league_id,
            expected_season=season,
        )

        team = stat0.get("team", {}) if isinstance(stat0, dict) else {}
        league = stat0.get("league", {}) if isinstance(stat0, dict) else {}
        games = stat0.get("games", {}) if isinstance(stat0, dict) else {}
        birth = player.get("birth", {}) or {}

        birth_date = birth.get("date")
        nationality = player.get("nationality")
        first_name = player.get("firstname")
        last_name = player.get("lastname")
        height_cm = parse_height_cm(player.get("height"))
        weight_kg = parse_weight_kg(player.get("weight"))
        position_code = games.get("position")

        provider_team_id = team.get("id")
        team_name = team.get("name")

        provider_league_id = league.get("id") or league_id
        league_name = league.get("name")
        photo_url = player.get("photo")

        rows.append(
            (
                PROVIDER_CODE,                                  # provider_code
                str(provider_player_id),                        # provider_player_id
                str(player_name),                               # player_name
                first_name,                                     # first_name
                last_name,                                      # last_name
                birth_date,                                     # birth_date
                nationality,                                    # nationality
                height_cm,                                      # height_cm
                weight_kg,                                      # weight_kg
                None,                                           # preferred_foot
                position_code,                                  # position_code
                str(provider_team_id) if provider_team_id is not None else None,  # team_provider_id
                team_name,                                      # team_name
                str(season),                                    # season_code
                True,                                           # is_active
                json.dumps(item, ensure_ascii=False),           # raw_json
                int(run_id),                                    # run_id
                str(provider_league_id) if provider_league_id is not None else str(league_id),
                str(provider_team_id) if provider_team_id is not None else None,
                str(season),
                league_name,
                "/players",
                photo_url,
            )
        )

    return rows


def bulk_insert_players_import(cur, rows):
    """
    Bulk insert do staging.players_import
    """
    if not rows:
        return 0

    template = """
    (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
        %s, %s, %s, %s, %s::jsonb, %s, %s, %s, %s, %s, %s, %s
    )
    """

    sql = """
        INSERT INTO staging.players_import (
            provider_code,
            provider_player_id,
            player_name,
            first_name,
            last_name,
            birth_date,
            nationality,
            height_cm,
            weight_kg,
            preferred_foot,
            position_code,
            team_provider_id,
            team_name,
            season_code,
            is_active,
            raw_json,
            run_id,
            provider_league_id,
            provider_team_id,
            season,
            league_name,
            source_endpoint,
            photo_url
        )
        VALUES %s
    """

    execute_values(cur, sql, rows, template=template, page_size=500)
    return len(rows)


# ==========================================================
# JOB PROCESSING
# ==========================================================
def process_single_target(
    conn,
    session,
    league_id: str,
    season: str,
    run_id: int,
    headers: dict,
    request_sleep_sec: float,
):
    """
    Zpracuje jednu ligu+sezónu do staging.players_import
    """
    print(f"TARGET | league={league_id} | season={season} | run_id={run_id}")

    total_inserted = 0
    total_raw_payloads = 0
    page = 1

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        print("Čistím starý players_import pro ligu/sezónu...")
        delete_existing_import_for_target(cur, league_id, season)
        conn.commit()

    while True:
        print(f"Stahuji /players league={league_id} season={season} page={page}")

        payload = api_get_players(
            session=session,
            league_id=league_id,
            season=season,
            page=page,
            headers=headers,
        )

        response_items = payload.get("response", []) or []
        paging = payload.get("paging", {}) or {}
        current_page = paging.get("current", page)
        total_pages = paging.get("total", page)
        errors_obj = payload.get("errors", {}) or {}

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            print("Ukládám raw payload do staging.stg_api_payloads...")
            raw_payload_id = insert_raw_payload(cur, league_id, season, payload)
            conn.commit()
            total_raw_payloads += 1
            print(f"raw_payload_id={raw_payload_id}")

        rows = extract_players_rows(
            payload=payload,
            league_id=league_id,
            season=season,
            run_id=run_id,
        )

        if rows:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                inserted = bulk_insert_players_import(cur, rows)
                conn.commit()
                total_inserted += inserted
                print(f"Uloženo {inserted} hráčů.")
        else:
            print("API nevrátilo žádné hráče na této stránce.")

        # Free plán typicky vrací chybu na page 4.
        # Pokud zároveň není response, považujeme to za korektní konec.
        if errors_obj and not response_items:
            print("API errors:", json.dumps(errors_obj, ensure_ascii=False))
            print("No more players returned.")
            break

        if not response_items:
            break

        if current_page >= total_pages:
            break

        page += 1
        time.sleep(request_sleep_sec)

    print(f"TARGET HOTOV | league={league_id} | season={season} | run_id={run_id} | inserted={total_inserted} | raw_payloads={total_raw_payloads}")
    return total_inserted


def process_planner_job(
    conn,
    session,
    job: dict,
    headers: dict,
    request_sleep_sec: float,
    mark_done_enabled: bool = True,
):
    """
    Batch režim přes planner claim uvnitř tohoto skriptu.
    Pozn.: run_id zde používáme = planner_id, protože externí job_run_id tento režim nezná.
    """
    planner_id = int(job["id"])
    league_id = str(job["provider_league_id"])
    season = str(job["season"])
    run_id = planner_id

    print(f"--- JOB {planner_id} | league={league_id} | season={season} | run_group={job['run_group']} ---")

    inserted = process_single_target(
        conn=conn,
        session=session,
        league_id=league_id,
        season=season,
        run_id=run_id,
        headers=headers,
        request_sleep_sec=request_sleep_sec,
    )

    if mark_done_enabled:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            mark_job_done(cur, planner_id)
            conn.commit()

    print(f"JOB HOTOV | planner_id={planner_id} | inserted={inserted}")
    return inserted


# ==========================================================
# MAIN
# ==========================================================
def main():
    args = parse_args()

    limit = args.limit if args.limit is not None else int(os.getenv("MM_PLAYERS_JOB_LIMIT", "1"))
    request_sleep_sec = args.sleep_sec if args.sleep_sec is not None else float(os.getenv("MM_API_SLEEP_SEC", "1.2"))

    api_key = get_api_key()
    headers = get_api_headers(api_key)

    print(f"LOAD .env         : {ENV_PATH}")
    print_header("MATCHMATRIX: API-FOOTBALL PLAYERS INGEST V4")
    print(f"API base         : {API_BASE}")
    print(f"API key fp       : {mask_key(api_key)}")
    print(f"Job limit        : {limit}")
    print(f"Sleep per request: {request_sleep_sec}s")
    print(f"Single mode      : {bool(args.league_id and args.season and args.run_id)}")
    print()

    session = requests.Session()

    with closing(get_db_connection()) as conn:
        conn.autocommit = False

        # --------------------------------------------------
        # REŽIM 1 - SINGLE TARGET
        # --------------------------------------------------
        if args.league_id and args.season and args.run_id:
            try:
                inserted = process_single_target(
                    conn=conn,
                    session=session,
                    league_id=str(args.league_id),
                    season=str(args.season),
                    run_id=int(args.run_id),
                    headers=headers,
                    request_sleep_sec=request_sleep_sec,
                )

                if args.job_id and not args.no_mark_done:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        mark_job_done(cur, int(args.job_id))
                        conn.commit()

                print()
                print(f"Celkem vloženo do staging.players_import: {inserted}")
                return 0

            except Exception as e:
                conn.rollback()

                if args.job_id and not args.no_mark_done:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        mark_job_error(cur, int(args.job_id), retry_minutes=180)
                        conn.commit()

                print(f"CHYBA SINGLE RUN: {e}")
                return 1

        # --------------------------------------------------
        # REŽIM 2 - BATCH CLAIM Z PLANNERU
        # --------------------------------------------------
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            jobs = claim_planner_jobs(cur, limit)
            conn.commit()

        if not jobs:
            print("Žádné pending players joby.")
            return 0

        print(f"Nalezeno jobů: {len(jobs)}")
        grand_total = 0

        for job in jobs:
            planner_id = int(job["id"])

            try:
                inserted = process_planner_job(
                    conn=conn,
                    session=session,
                    job=job,
                    headers=headers,
                    request_sleep_sec=request_sleep_sec,
                    mark_done_enabled=not args.no_mark_done,
                )
                grand_total += inserted

            except Exception as e:
                conn.rollback()

                if not args.no_mark_done:
                    with conn.cursor(cursor_factory=RealDictCursor) as cur:
                        mark_job_error(cur, planner_id, retry_minutes=180)
                        conn.commit()

                print(f"CHYBA JOB {planner_id}: {e}")

        print()
        print(f"Celkem vloženo do staging.players_import: {grand_total}")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())