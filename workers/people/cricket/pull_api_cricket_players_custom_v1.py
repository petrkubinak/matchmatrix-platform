"""
MATCHMATRIX WORKER
pull_api_cricket_players_custom_v1.py

CO TO JE:
- Custom downloader pro cricket players mimo unified ingest.

K ČEMU TO JE:
- api_cricket / CK / players není podporováno přes run_unified_ingest_v1.py.
- Tento worker vezme pending job z ops.ingest_planner a uloží raw payload do staging.stg_api_payloads.

KDE TO UVIDÍME:
- staging.stg_api_payloads
- ops.ingest_planner

JAK SE TO VYUŽIJE:
- Později parser převede raw cricket players payload do public.players / player_provider_map.
"""

import os
import sys
import json
import argparse
from datetime import datetime, timezone

import requests
import psycopg2
from psycopg2.extras import Json


BASE_DIR = r"C:\MatchMatrix-platform"


def load_env_file(path):
    if not os.path.exists(path):
        return

    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()

            if not line or line.startswith("#") or "=" not in line:
                continue

            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")

            os.environ.setdefault(key, value)


def get_db_connection():
    load_env_file(os.path.join(BASE_DIR, ".env"))
    load_env_file(os.path.join(BASE_DIR, "ingest", ".env"))

    dsn = os.getenv("DATABASE_URL")

    if dsn:
        return psycopg2.connect(dsn)

    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        dbname=os.getenv("POSTGRES_DB", "matchmatrix"),
        user=os.getenv("POSTGRES_USER", "matchmatrix"),
        password=os.getenv("POSTGRES_PASSWORD", "matchmatrix_pass"),
    )


def get_api_key():
    load_env_file(os.path.join(BASE_DIR, "ingest", ".env"))
    load_env_file(os.path.join(BASE_DIR, "ingest", "API-Cricket", ".env"))

    return (
        os.getenv("API_CRICKET_KEY")
        or os.getenv("APISPORTS_API_KEY")
        or os.getenv("API_SPORTS_KEY")
        or os.getenv("RAPIDAPI_KEY")
    )


def claim_planner_job(conn, run_group, limit_provider=None):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id, provider, sport_code, entity, provider_league_id, season, run_group
            FROM ops.ingest_planner
            WHERE status = 'pending'
              AND provider = COALESCE(%s, provider)
              AND sport_code = 'CK'
              AND entity = 'players'
              AND run_group = %s
            ORDER BY priority ASC, id ASC
            LIMIT 1
            FOR UPDATE SKIP LOCKED;
            """,
            (limit_provider, run_group),
        )

        row = cur.fetchone()

        if not row:
            return None

        planner_id = row[0]

        cur.execute(
            """
            UPDATE ops.ingest_planner
            SET
                status = 'running',
                attempts = COALESCE(attempts, 0) + 1,
                last_attempt = NOW(),
                updated_at = NOW()
            WHERE id = %s;
            """,
            (planner_id,),
        )

        conn.commit()

        return {
            "id": row[0],
            "provider": row[1],
            "sport_code": row[2],
            "entity": row[3],
            "provider_league_id": row[4],
            "season": row[5],
            "run_group": row[6],
        }


def mark_planner(conn, planner_id, status, message):
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.ingest_planner
            SET
                status = %s,
                updated_at = NOW()
            WHERE id = %s;
            """,
            (status, planner_id),
        )

    conn.commit()
    print(message)


def insert_payload(conn, job, endpoint_name, payload):
    with conn.cursor() as cur:
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
                parse_status,
                parse_message
            )
            VALUES (
                %s, %s, %s, %s, %s, %s, %s, 'pending', %s
            );
            """,
            (
                job["provider"],
                job["sport_code"],
                job["entity"],
                endpoint_name,
                job["provider_league_id"],
                job["season"],
                Json(payload),
                "CK players custom raw payload downloaded",
            ),
        )

    conn.commit()


def fetch_api_cricket_players(job):
    api_key = get_api_key()

    if not api_key:
        raise RuntimeError("Chybí API key. Nastav API_CRICKET_KEY nebo APISPORTS_API_KEY v .env.")

    base_url = os.getenv("API_CRICKET_BASE_URL", "https://v1.cricket.api-sports.io")
    endpoint = "/players"

    url = base_url.rstrip("/") + endpoint

    headers = {
        "x-apisports-key": api_key,
    }

    params = {}

    if job["provider_league_id"]:
        params["league"] = job["provider_league_id"]

    if job["season"]:
        params["season"] = job["season"]

    print("REQUEST:", url)
    print("PARAMS :", params)

    response = requests.get(url, headers=headers, params=params, timeout=60)

    payload = {
        "request_url": response.url,
        "status_code": response.status_code,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
        "response": None,
        "text": None,
    }

    try:
        payload["response"] = response.json()
    except Exception:
        payload["text"] = response.text

    if response.status_code >= 400:
        raise RuntimeError(f"API HTTP ERROR {response.status_code}: {response.text[:500]}")

    return payload


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-group", required=True)
    parser.add_argument("--provider", default="api_cricket")
    parser.add_argument("--limit", type=int, default=1)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX CK PLAYERS CUSTOM DOWNLOADER V1")
    print("=" * 80)
    print("RUN GROUP:", args.run_group)
    print("PROVIDER :", args.provider)
    print("=" * 80)

    conn = get_db_connection()

    processed = 0

    try:
        for _ in range(args.limit):
            job = claim_planner_job(conn, args.run_group, args.provider)

            if not job:
                print("Žádný pending planner job.")
                break

            print("CLAIMED:", job)

            try:
                payload = fetch_api_cricket_players(job)
                insert_payload(conn, job, "players", payload)
                mark_planner(conn, job["id"], "done", f"DONE planner_id={job['id']}")
                processed += 1

            except Exception as exc:
                mark_planner(conn, job["id"], "error", f"ERROR planner_id={job['id']} | {exc}")

    finally:
        conn.close()

    print("=" * 80)
    print("DONE | PROCESSED:", processed)
    print("=" * 80)


if __name__ == "__main__":
    main()