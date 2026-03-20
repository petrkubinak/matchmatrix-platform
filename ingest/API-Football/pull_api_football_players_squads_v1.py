import os
import json
import time
from contextlib import closing
from pathlib import Path

import requests
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


# ==========================================================
# LOAD .ENV
# ==========================================================

ENV_PATH = Path(__file__).resolve().parents[2] / ".env"
load_dotenv(dotenv_path=ENV_PATH)

API_BASE = os.getenv("APISPORTS_BASE", "https://v3.football.api-sports.io").strip()

PROVIDER_CODE = "api_football_squads"
SOURCE_PROVIDER = "api_football"
SPORT_CODE = "football"
ENTITY = "team_squad"


def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", ""),
    )
    conn.set_client_encoding("UTF8")
    return conn


def get_api_key():
    api_key = os.getenv("APISPORTS_KEY", "").strip()
    if not api_key:
        raise RuntimeError("Chybí APISPORTS_KEY v .env.")
    return api_key


def get_api_headers(api_key: str):
    return {
        "x-apisports-key": api_key,
        "Accept": "application/json",
        "User-Agent": "MatchMatrix/players-squads-v1",
    }


def claim_jobs(cur, limit: int):
    cur.execute(
        """
        WITH picked AS (
            SELECT id
            FROM ops.player_enrichment_plan
            WHERE provider = %s
              AND sport_code = %s
              AND entity = %s
              AND status IN ('pending', 'error')
              AND (next_run IS NULL OR next_run <= NOW())
            ORDER BY priority, id
            FOR UPDATE SKIP LOCKED
            LIMIT %s
        )
        UPDATE ops.player_enrichment_plan p
        SET status = 'running',
            attempts = COALESCE(attempts, 0) + 1,
            updated_at = NOW()
        WHERE p.id IN (SELECT id FROM picked)
        RETURNING
            p.id,
            p.provider,
            p.sport_code,
            p.entity,
            p.external_team_id,
            p.external_league_id,
            p.season,
            p.run_group,
            p.priority,
            p.attempts;
        """,
        (PROVIDER_CODE, SPORT_CODE, ENTITY, limit),
    )
    return cur.fetchall()


def mark_job_done(cur, job_id: int):
    cur.execute(
        """
        UPDATE ops.player_enrichment_plan
        SET status = 'done',
            updated_at = NOW(),
            last_error = NULL
        WHERE id = %s
        """,
        (job_id,),
    )


def mark_job_error(cur, job_id: int, error_text: str, retry_minutes: int = 180):
    cur.execute(
        """
        UPDATE ops.player_enrichment_plan
        SET status = 'error',
            last_error = %s,
            next_run = NOW() + (%s || ' minutes')::interval,
            updated_at = NOW()
        WHERE id = %s
        """,
        (error_text[:2000], retry_minutes, job_id),
    )


def api_get_team_squad(session: requests.Session, headers: dict, team_id: str) -> dict:
    url = f"{API_BASE}/players/squads"
    params = {"team": team_id}

    response = session.get(url, headers=headers, params=params, timeout=60)

    print(f"HTTP STATUS: {response.status_code}")
    print(f"URL        : {response.url}")

    if response.status_code != 200:
        raise RuntimeError(
            f"API request failed. status={response.status_code}, "
            f"url={response.url}, body={response.text[:2000]}"
        )

    return response.json()


def insert_source_payload(
    cur,
    external_team_id: str,
    external_league_id: str | None,
    season: str | None,
    request_url: str,
    request_params: dict,
    payload: dict,
) -> int:
    payload_text = json.dumps(payload, ensure_ascii=False)
    params_text = json.dumps(request_params, ensure_ascii=False)

    cur.execute(
        """
        INSERT INTO staging.stg_player_source_payloads (
            provider,
            sport_code,
            entity_type,
            external_team_id,
            external_league_id,
            season,
            endpoint_name,
            request_url,
            request_params,
            payload_json,
            parse_status
        )
        VALUES (
            %s, %s, 'player_profile',
            %s, %s, %s, %s, %s, %s::jsonb, %s::jsonb, 'pending'
        )
        RETURNING id
        """,
        (
            PROVIDER_CODE,
            SPORT_CODE,
            external_team_id,
            external_league_id,
            season,
            "players/squads",
            request_url,
            params_text,
            payload_text,
        ),
    )
    return int(cur.fetchone()["id"])


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


def upsert_profile(
    cur,
    payload_id: int,
    team_id: str,
    league_id: str | None,
    season: str | None,
    team_name: str | None,
    row: dict,
):
    player_id = row.get("id")
    if not player_id:
        return

    player_name = row.get("name")
    first_name = row.get("firstname")
    last_name = row.get("lastname")
    age = row.get("age")
    number = row.get("number")
    position_name = row.get("position")
    photo_url = row.get("photo")

    # squads endpoint obvykle nevrací vše; ukládáme jen to, co máme
    cur.execute(
        """
        INSERT INTO staging.stg_provider_player_profiles (
            provider,
            sport_code,
            external_player_id,
            player_name,
            first_name,
            last_name,
            display_name,
            birth_date,
            nationality,
            height_cm,
            weight_kg,
            shirt_number,
            position_name,
            photo_url,
            is_active,
            external_team_id,
            team_name,
            external_league_id,
            season,
            source_payload_id,
            source_endpoint,
            updated_at
        )
        VALUES (
            %s, %s, %s, %s, %s, %s, %s, NULL, NULL, NULL, NULL,
            %s, %s, %s, TRUE, %s, %s, %s, %s, %s, %s, NOW()
        )
        ON CONFLICT (provider, external_player_id)
        DO UPDATE SET
            player_name        = EXCLUDED.player_name,
            first_name         = COALESCE(EXCLUDED.first_name, staging.stg_provider_player_profiles.first_name),
            last_name          = COALESCE(EXCLUDED.last_name, staging.stg_provider_player_profiles.last_name),
            display_name       = COALESCE(EXCLUDED.display_name, staging.stg_provider_player_profiles.display_name),
            shirt_number       = COALESCE(EXCLUDED.shirt_number, staging.stg_provider_player_profiles.shirt_number),
            position_name      = COALESCE(EXCLUDED.position_name, staging.stg_provider_player_profiles.position_name),
            photo_url          = COALESCE(EXCLUDED.photo_url, staging.stg_provider_player_profiles.photo_url),
            is_active          = EXCLUDED.is_active,
            external_team_id   = COALESCE(EXCLUDED.external_team_id, staging.stg_provider_player_profiles.external_team_id),
            team_name          = COALESCE(EXCLUDED.team_name, staging.stg_provider_player_profiles.team_name),
            external_league_id = COALESCE(EXCLUDED.external_league_id, staging.stg_provider_player_profiles.external_league_id),
            season             = COALESCE(EXCLUDED.season, staging.stg_provider_player_profiles.season),
            source_payload_id  = EXCLUDED.source_payload_id,
            source_endpoint    = EXCLUDED.source_endpoint,
            updated_at         = NOW()
        """,
        (
            PROVIDER_CODE,
            SPORT_CODE,
            str(player_id),
            player_name,
            first_name,
            last_name,
            player_name,
            number,
            position_name,
            photo_url,
            str(team_id),
            team_name,
            league_id,
            season,
            payload_id,
            "/players/squads",
        ),
    )


def process_job(conn, session, headers: dict, job: dict, sleep_sec: float):
    job_id = job["id"]
    team_id = str(job["external_team_id"])
    league_id = job.get("external_league_id")
    season = job.get("season")

    print(f"--- JOB {job_id} | team={team_id} | league={league_id} | season={season} ---")

    payload = api_get_team_squad(session=session, headers=headers, team_id=team_id)

    request_url = f"{API_BASE}/players/squads"
    request_params = {"team": team_id}

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        payload_id = insert_source_payload(
            cur=cur,
            external_team_id=team_id,
            external_league_id=league_id,
            season=season,
            request_url=request_url,
            request_params=request_params,
            payload=payload,
        )
        conn.commit()

    response_items = payload.get("response", []) or []
    total_profiles = 0

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        for item in response_items:
            team = item.get("team", {}) or {}
            team_name = team.get("name")
            players = item.get("players", []) or []

            for p in players:
                upsert_profile(
                    cur=cur,
                    payload_id=payload_id,
                    team_id=team_id,
                    league_id=league_id,
                    season=season,
                    team_name=team_name,
                    row=p,
                )
                total_profiles += 1

        mark_job_done(cur, job_id)
        conn.commit()

    print(f"payload_id={payload_id}")
    print(f"profiles upserted={total_profiles}")

    time.sleep(sleep_sec)
    return total_profiles


def main():
    limit = int(os.getenv("MM_PLAYERS_JOB_LIMIT", "3"))
    sleep_sec = float(os.getenv("MM_API_SLEEP_SEC", "1.2"))

    print("=== MATCHMATRIX: API-FOOTBALL PLAYERS SQUADS V1 ===")
    print(f"API base         : {API_BASE}")
    print(f"Job limit        : {limit}")
    print(f"Sleep per request: {sleep_sec}s")
    print()

    api_key = get_api_key()
    headers = get_api_headers(api_key)
    session = requests.Session()

    processed_jobs = 0
    total_profiles = 0

    with closing(get_db_connection()) as conn:
        conn.autocommit = False

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            jobs = claim_jobs(cur, limit)
            conn.commit()

        if not jobs:
            print("Žádné ready squads joby.")
            return 0

        print(f"Nalezeno jobů: {len(jobs)}")

        for job in jobs:
            try:
                count = process_job(
                    conn=conn,
                    session=session,
                    headers=headers,
                    job=job,
                    sleep_sec=sleep_sec,
                )
                processed_jobs += 1
                total_profiles += count

            except Exception as e:
                conn.rollback()
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    mark_job_error(cur, job["id"], str(e), retry_minutes=180)
                    conn.commit()
                print(f"CHYBA JOB {job['id']}: {e}")

    print()
    print(f"Processed jobs   : {processed_jobs}")
    print(f"Profiles upserted: {total_profiles}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())