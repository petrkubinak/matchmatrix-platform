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
# LOAD .ENV FROM PROJECT ROOT
# C:\MatchMatrix-platform\.env
# ==========================================================

ENV_PATH = Path(__file__).resolve().parents[2] / ".env"
load_dotenv(dotenv_path=ENV_PATH)


# ==========================================================
# CONSTANTS
# ==========================================================

API_BASE = os.getenv("APISPORTS_BASE", "https://v3.football.api-sports.io").strip()

PROVIDER_CODE = "api_football"
SPORT_CODE = "football"
ENTITY = "players"


def get_db_connection():
    """
    DB připojení z .env
    """
    conn = psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", ""),
    )
    conn.set_client_encoding("UTF8")
    return conn


def get_api_key() -> str:
    """
    Bere centrální APISPORTS_KEY z .env
    """
    api_key = os.getenv("APISPORTS_KEY", "").strip()
    if not api_key:
        raise RuntimeError("Chybí APISPORTS_KEY v .env.")
    return api_key


def mask_key(api_key: str) -> str:
    """
    Jen bezpečný fingerprint do logu
    """
    if len(api_key) <= 10:
        return "*" * len(api_key)
    return f"{api_key[:6]}...{api_key[-4:]}"


def get_api_headers(api_key: str):
    return {
        "x-apisports-key": api_key,
        "Accept": "application/json",
        "User-Agent": "MatchMatrix/players-ingest-v4",
    }


def claim_planner_jobs(cur, limit: int):
    """
    Vezme pending jobs z planneru.
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
        (PROVIDER_CODE, SPORT_CODE, ENTITY, limit),
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


def api_get_players(session: requests.Session, league_id: str, season: str, page: int, headers: dict) -> dict:
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
    """
    Pomocná funkce:
    - None / "" -> False
    - jinak True
    Pozn.: "0" je validní hodnota.
    """
    if value is None:
        return False
    if isinstance(value, str) and value.strip() == "":
        return False
    return True


def _count_filled_stats(stat_row: dict) -> int:
    """
    Spočítá, kolik skutečně vyplněných statistik je v jednom statistics[] bloku.
    Tím vybíráme nejlepší blok pro player+league+season.
    """
    if not isinstance(stat_row, dict):
        return -1

    fields_to_check = [
        ("games", "appearences"),      # API někdy používá appearences
        ("games", "appearances"),      # obrana pro případ jiné varianty
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
        ("penalty", "commited"),       # API často používá commited
        ("penalty", "committed"),      # obrana pro případ opraveného názvu
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

    Tohle opravuje hlavní bug původní verze, která brala jen statistics[0].
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


def extract_players_rows(payload: dict, league_id: str, season: str):
    """
    Rozparsuje response[] do rows pro staging.players_import

    KLÍČOVÁ OPRAVA:
    - nebere statistics[0]
    - vybírá nejlepší statistics blok podle league_id + season + počtu vyplněných statistik
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
                None,                                           # run_id -> doplní se raw_payload_id
                str(provider_league_id) if provider_league_id is not None else str(league_id),
                str(provider_team_id) if provider_team_id is not None else None,
                str(season),
                league_name,
                "/players",
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
        %s, %s, %s, %s, %s::jsonb, %s, %s, %s, %s, %s, %s
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
            source_endpoint
        )
        VALUES %s
    """

    execute_values(cur, sql, rows, template=template, page_size=500)
    return len(rows)


def process_job(conn, session, job: dict, headers: dict, request_sleep_sec: float):
    planner_id = job["id"]
    league_id = str(job["provider_league_id"])
    season = str(job["season"])

    print(f"--- JOB {planner_id} | league={league_id} | season={season} | run_group={job['run_group']} ---")

    total_inserted = 0
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
            headers=headers
        )

        response_items = payload.get("response", []) or []
        paging = payload.get("paging", {}) or {}
        current_page = paging.get("current", page)
        total_pages = paging.get("total", page)

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            print("Ukládám raw payload do staging.stg_api_payloads...")
            raw_payload_id = insert_raw_payload(cur, league_id, season, payload)
            conn.commit()
            print(f"raw_payload_id={raw_payload_id}")

        rows = extract_players_rows(payload, league_id, season)

        rows = [
            (
                r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                r[11], r[12], r[13], r[14], r[15], raw_payload_id,
                r[17], r[18], r[19], r[20], r[21]
            )
            for r in rows
        ]

        if rows:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                inserted = bulk_insert_players_import(cur, rows)
                conn.commit()
                total_inserted += inserted
                print(f"Uloženo {inserted} hráčů.")
        else:
            print("API nevrátilo žádné hráče na této stránce.")

        if not response_items:
            break

        if current_page >= total_pages:
            break

        page += 1
        time.sleep(request_sleep_sec)

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        mark_job_done(cur, planner_id)
        conn.commit()

    print(f"JOB HOTOV | planner_id={planner_id} | inserted={total_inserted}")
    return total_inserted


def main():
    limit = int(os.getenv("MM_PLAYERS_JOB_LIMIT", "1"))
    request_sleep_sec = float(os.getenv("MM_API_SLEEP_SEC", "1.2"))

    api_key = get_api_key()
    headers = get_api_headers(api_key)

    print("=== MATCHMATRIX: API-FOOTBALL PLAYERS INGEST V4 ===")
    print(f"API base         : {API_BASE}")
    print(f"API key fp       : {mask_key(api_key)}")
    print(f"Job limit        : {limit}")
    print(f"Sleep per request: {request_sleep_sec}s")
    print()

    session = requests.Session()

    with closing(get_db_connection()) as conn:
        conn.autocommit = False

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            jobs = claim_planner_jobs(cur, limit)
            conn.commit()

        if not jobs:
            print("Žádné pending players joby.")
            return 0

        print(f"Nalezeno jobů: {len(jobs)}")
        grand_total = 0

        for job in jobs:
            planner_id = job["id"]

            try:
                inserted = process_job(
                    conn=conn,
                    session=session,
                    job=job,
                    headers=headers,
                    request_sleep_sec=request_sleep_sec,
                )
                grand_total += inserted

            except Exception as e:
                conn.rollback()

                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    mark_job_error(cur, planner_id, retry_minutes=180)
                    conn.commit()

                print(f"CHYBA JOB {planner_id}: {e}")

        print()
        print(f"Celkem vloženo do staging.players_import: {grand_total}")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())