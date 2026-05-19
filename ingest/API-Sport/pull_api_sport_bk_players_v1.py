# ============================================================
# pull_api_sport_bk_players_v1.py
# MatchMatrix - API-Sport Basketball Players Pull V1
#
# Kam uložit:
# C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_bk_players_v1.py
#
# Co dělá:
# - bere pending joby z ops.player_enrichment_plan
# - provider=api_sport, sport_code=basketball, entity=players
# - volá API endpoint /players?team=...&season=...
# - ukládá RAW payload do staging.stg_api_payloads
# - označuje job jako done/error
#
# Bezpečný test 2 joby:
# C:\Python314\python.exe C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_bk_players_v1.py --limit 2
# ============================================================

from __future__ import annotations

import argparse
import json
import os
import time
from datetime import datetime
from pathlib import Path

import psycopg2
import requests
from dotenv import load_dotenv


BASE_DIR = Path(r"C:\MatchMatrix-platform")
ENV_PATH = BASE_DIR / "ingest" / ".env"

PROVIDER = "api_sport"
SPORT_CODE = "basketball"
ENTITY = "players"
RUN_GROUP = "BK_PEOPLE"
API_BASE = "https://v1.basketball.api-sports.io"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def log(message: str) -> None:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {message}", flush=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix BK players pull V1")
    parser.add_argument("--limit", type=int, default=2)
    parser.add_argument("--sleep-sec", type=float, default=1.2)
    return parser.parse_args()


def load_env() -> None:
    if not ENV_PATH.exists():
        raise RuntimeError(f".env nenalezen: {ENV_PATH}")
    load_dotenv(dotenv_path=ENV_PATH)


def get_api_key() -> str:
    api_key = (
        os.getenv("APISPORTS_KEY")
        or os.getenv("API_SPORTS_KEY")
        or ""
    ).strip()

    if not api_key:
        raise RuntimeError("Chybí APISPORTS_KEY nebo API_SPORTS_KEY v C:\\MatchMatrix-platform\\ingest\\.env")

    return api_key


def get_conn():
    return psycopg2.connect(**DB_CONFIG)


def claim_jobs(conn, limit: int):
    sql = """
        WITH picked AS (
            SELECT id
            FROM ops.player_enrichment_plan
            WHERE provider = %s
              AND sport_code = %s
              AND entity = %s
              AND run_group = %s
              AND status = 'pending'
              AND (next_run IS NULL OR next_run <= NOW())
            ORDER BY priority, id
            FOR UPDATE SKIP LOCKED
            LIMIT %s
        )
        UPDATE ops.player_enrichment_plan p
        SET
            status = 'running',
            attempts = COALESCE(attempts, 0) + 1,
            updated_at = NOW()
        WHERE p.id IN (SELECT id FROM picked)
        RETURNING
            p.id,
            p.external_team_id,
            p.external_league_id,
            p.season,
            p.run_group,
            p.priority,
            p.attempts;
    """

    with conn.cursor() as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, ENTITY, RUN_GROUP, limit))
        rows = cur.fetchall()

    conn.commit()
    return rows


def mark_job_done(conn, job_id: int, message: str):
    sql = """
        UPDATE ops.player_enrichment_plan
        SET
            status = 'done',
            last_error = NULL,
            updated_at = NOW()
        WHERE id = %s;
    """

    with conn.cursor() as cur:
        cur.execute(sql, (job_id,))

    conn.commit()


def mark_job_error(conn, job_id: int, error_message: str, retry_minutes: int = 180):
    sql = """
        UPDATE ops.player_enrichment_plan
        SET
            status = 'error',
            last_error = %s,
            next_run = NOW() + (%s || ' minutes')::interval,
            updated_at = NOW()
        WHERE id = %s;
    """

    with conn.cursor() as cur:
        cur.execute(sql, (error_message[:2000], retry_minutes, job_id))

    conn.commit()


def insert_raw_payload(conn, team_id: str, league_id: str, season: str, payload: dict) -> int:
    payload_text = json.dumps(payload, ensure_ascii=False)

    sql = """
        INSERT INTO staging.stg_api_payloads
        (
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            payload_json,
            parse_status,
            created_at
        )
        VALUES
        (
            %s, %s, %s, %s, %s, %s, %s::jsonb, 'pending', NOW()
        )
        RETURNING id;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                PROVIDER,
                SPORT_CODE,
                ENTITY,
                "players",
                str(team_id),
                str(season),
                payload_text,
            ),
        )
        raw_payload_id = cur.fetchone()[0]

    conn.commit()
    return int(raw_payload_id)


def call_players_api(headers: dict, team_id: str, season: str) -> dict:
    url = f"{API_BASE}/players"
    params = {
        "team": str(team_id),
        "season": str(season),
    }

    response = requests.get(url, headers=headers, params=params, timeout=60)

    log(f"HTTP STATUS: {response.status_code}")
    log(f"URL        : {response.url}")

    if response.status_code != 200:
        raise RuntimeError(f"API error status={response.status_code}, body={response.text[:1000]}")

    return response.json()


def main() -> int:
    args = parse_args()

    load_env()
    api_key = get_api_key()

    headers = {
        "x-apisports-key": api_key,
        "Accept": "application/json",
        "User-Agent": "MatchMatrix/bk-players-pull-v1",
    }

    log("=" * 80)
    log("MATCHMATRIX BK PLAYERS PULL V1 - QUEUE MODE")
    log("=" * 80)
    log(f"BASE_DIR   : {BASE_DIR}")
    log(f"ENV        : {ENV_PATH}")
    log(f"PROVIDER   : {PROVIDER}")
    log(f"SPORT_CODE : {SPORT_CODE}")
    log(f"ENTITY     : {ENTITY}")
    log(f"RUN_GROUP  : {RUN_GROUP}")
    log(f"LIMIT      : {args.limit}")
    log("=" * 80)

    conn = get_conn()

    try:
        jobs = claim_jobs(conn, args.limit)
        log(f"Claimed jobs: {len(jobs)}")

        if not jobs:
            log("Žádné pending BK players joby.")
            return 0

        total_payloads = 0
        total_players = 0
        errors = 0

        for job in jobs:
            job_id, team_id, league_id, season, run_group, priority, attempts = job

            log("-" * 80)
            log(f"JOB {job_id} | team={team_id} | league={league_id} | season={season} | attempts={attempts}")

            try:
                if not team_id or not season:
                    raise RuntimeError(f"Chybí team_id nebo season. team_id={team_id}, season={season}")

                payload = call_players_api(
                    headers=headers,
                    team_id=str(team_id),
                    season=str(season),
                )

                response_items = payload.get("response", []) or []
                response_count = len(response_items) if isinstance(response_items, list) else 0

                raw_payload_id = insert_raw_payload(
                    conn=conn,
                    team_id=str(team_id),
                    league_id=str(league_id),
                    season=str(season),
                    payload=payload,
                )

                log(f"raw_payload_id : {raw_payload_id}")
                log(f"response_count : {response_count}")

                total_payloads += 1
                total_players += response_count

                mark_job_done(
                    conn,
                    int(job_id),
                    f"OK raw_payload_id={raw_payload_id}, response_count={response_count}",
                )

                time.sleep(float(args.sleep_sec))

            except Exception as exc:
                errors += 1
                conn.rollback()
                mark_job_error(conn, int(job_id), str(exc))
                log(f"ERROR JOB {job_id}: {exc}")

        log("=" * 80)
        log("SUMMARY")
        log("=" * 80)
        log(f"Jobs processed  : {len(jobs)}")
        log(f"Raw payloads    : {total_payloads}")
        log(f"Players returned: {total_players}")
        log(f"Errors          : {errors}")
        log("RESULT          : OK" if errors == 0 else "RESULT          : ERROR")
        log("=" * 80)

        return 0 if errors == 0 else 1

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())