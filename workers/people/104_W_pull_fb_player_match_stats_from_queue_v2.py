# -*- coding: utf-8 -*-
"""
MATCHMATRIX 104_W - PULL FB PLAYER MATCH STATS FROM QUEUE V2

Co skript dělá:
- bere pending joby z ops.fixture_player_stats_queue
- volá API-Football /fixtures/players
- ukládá RAW do staging.stg_api_payloads
- chrání API limit pomocí sleep + 429 backoff

Kam výsledek vede:
- staging.stg_api_payloads

K čemu slouží:
- production-safe harvest player match statistics

Web/app využití:
- player detail
- player form
- fantasy scoring
- AI prediction
- momentum
"""

import os
import time
import argparse
import requests
import psycopg2
from psycopg2.extras import RealDictCursor, Json
from dotenv import load_dotenv


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, ".env")

PROVIDER = "api_football"
SPORT_CODE = "FB"
SPORT_ID = 1
ENTITY = "fixture_player_stats"
QUEUE_TABLE = "ops.fixture_player_stats_queue"
API_URL = "https://v3.football.api-sports.io/fixtures/players"


def get_conn():
    load_dotenv(ENV_PATH)
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", ""),
    )


def get_api_key():
    load_dotenv(ENV_PATH)

    for key_name in [
        "APISPORTS_KEY",
        "API_FOOTBALL_KEY",
        "APIFOOTBALL_KEY",
        "API_SPORTS_KEY",
        "RAPIDAPI_KEY",
        "RAPID_API_KEY",
        "API_KEY",
    ]:
        value = os.getenv(key_name)
        if value and value.strip():
            print(f"API KEY FOUND: {key_name}")
            return value.strip()

    raise RuntimeError("API key nebyl nalezen v .env")


def claim_jobs(conn, limit):
    sql = f"""
    WITH picked AS (
        SELECT id
        FROM {QUEUE_TABLE}
        WHERE provider = %(provider)s
          AND sport_id = %(sport_id)s
          AND entity = %(entity)s
          AND status = 'pending'
          AND COALESCE(next_run, now()) <= now()
        ORDER BY priority ASC, kickoff DESC NULLS LAST, id ASC
        LIMIT %(limit)s
        FOR UPDATE SKIP LOCKED
    )
    UPDATE {QUEUE_TABLE} q
    SET
        status = 'running',
        attempts = attempts + 1,
        last_attempt = now(),
        updated_at = now()
    FROM picked
    WHERE q.id = picked.id
    RETURNING
        q.id,
        q.match_id,
        q.provider_fixture_id,
        q.league_id,
        q.season,
        q.kickoff,
        q.run_group,
        q.attempts;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "sport_id": SPORT_ID,
                "entity": ENTITY,
                "limit": limit,
            },
        )
        rows = cur.fetchall()

    conn.commit()
    return rows


def call_api(api_key, fixture_id, timeout_sec):
    headers = {
        "x-apisports-key": api_key,
        "Accept": "application/json",
    }

    params = {"fixture": str(fixture_id)}

    response = requests.get(
        API_URL,
        headers=headers,
        params=params,
        timeout=timeout_sec,
    )

    try:
        payload = response.json()
    except Exception:
        payload = {"raw_text": response.text}

    return response.status_code, params, payload


def get_response_count(payload):
    response_data = payload.get("response") if isinstance(payload, dict) else None
    return len(response_data) if isinstance(response_data, list) else 0


def insert_raw_payload(conn, job, params, payload, http_status, response_count):
    sql = """
    INSERT INTO staging.stg_api_payloads (
        provider,
        sport_code,
        entity_type,
        endpoint_name,
        external_id,
        season,
        fetched_at,
        payload_json,
        parse_status,
        parse_message,
        created_at
    )
    VALUES (
        %(provider)s,
        %(sport_code)s,
        %(entity_type)s,
        %(endpoint_name)s,
        %(external_id)s,
        %(season)s,
        now(),
        %(payload_json)s,
        %(parse_status)s,
        %(parse_message)s,
        now()
    )
    RETURNING id;
    """

    if http_status == 200 and response_count > 0:
        parse_status = "pending"
    elif http_status == 200 and response_count == 0:
        parse_status = "empty"
    else:
        parse_status = "http_error"

    parse_message = (
        f"fixture={job['provider_fixture_id']}; "
        f"http_status={http_status}; "
        f"response_count={response_count}; "
        f"params={params}"
    )

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
                "entity_type": ENTITY,
                "endpoint_name": "/fixtures/players",
                "external_id": str(job["provider_fixture_id"]),
                "season": job["season"],
                "payload_json": Json(payload),
                "parse_status": parse_status,
                "parse_message": parse_message[:1000],
            },
        )
        raw_id = cur.fetchone()[0]

    conn.commit()
    return raw_id


def mark_done(conn, queue_id, raw_id, response_count):
    sql = f"""
    UPDATE {QUEUE_TABLE}
    SET
        status = CASE
            WHEN %(response_count)s > 0 THEN 'done'
            ELSE 'empty'
        END,
        result_message = %(message)s,
        updated_at = now()
    WHERE id = %(queue_id)s;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "queue_id": queue_id,
                "response_count": response_count,
                "message": f"RAW saved id={raw_id}; response_count={response_count}",
            },
        )

    conn.commit()


def mark_rate_limited(conn, queue_id, raw_id, retry_minutes):
    sql = f"""
    UPDATE {QUEUE_TABLE}
    SET
        status = 'pending',
        result_message = %(message)s,
        next_run = now() + (%(retry_minutes)s || ' minutes')::interval,
        updated_at = now()
    WHERE id = %(queue_id)s;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "queue_id": queue_id,
                "retry_minutes": retry_minutes,
                "message": f"HTTP 429 rate limit; RAW saved id={raw_id}; retry after {retry_minutes} minutes",
            },
        )

    conn.commit()


def mark_error(conn, queue_id, error_message, retry_minutes):
    sql = f"""
    UPDATE {QUEUE_TABLE}
    SET
        status = CASE
            WHEN attempts >= 3 THEN 'error'
            ELSE 'pending'
        END,
        result_message = %(message)s,
        next_run = now() + (%(retry_minutes)s || ' minutes')::interval,
        updated_at = now()
    WHERE id = %(queue_id)s;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "queue_id": queue_id,
                "message": str(error_message)[:1000],
                "retry_minutes": retry_minutes,
            },
        )

    conn.commit()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=5)
    parser.add_argument("--timeout-sec", type=int, default=30)
    parser.add_argument("--sleep-sec", type=float, default=2.0)
    parser.add_argument("--retry-minutes", type=int, default=30)
    parser.add_argument("--rate-limit-retry-minutes", type=int, default=120)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX FB PLAYER MATCH STATS QUEUE PULLER V2")
    print("=" * 80)
    print(f"LIMIT     : {args.limit}")
    print(f"SLEEP SEC : {args.sleep_sec}")
    print("=" * 80)

    api_key = get_api_key()
    conn = get_conn()

    total_ok = 0
    total_empty = 0
    total_rate_limited = 0
    total_error = 0

    try:
        jobs = claim_jobs(conn, args.limit)
        print(f"CLAIMED JOBS: {len(jobs)}")
        print("-" * 80)

        for job in jobs:
            queue_id = job["id"]
            fixture_id = job["provider_fixture_id"]

            try:
                print(f"QUEUE {queue_id} | FIXTURE {fixture_id} | MATCH {job['match_id']}")

                http_status, params, payload = call_api(
                    api_key=api_key,
                    fixture_id=fixture_id,
                    timeout_sec=args.timeout_sec,
                )

                response_count = get_response_count(payload)

                raw_id = insert_raw_payload(
                    conn=conn,
                    job=job,
                    params=params,
                    payload=payload,
                    http_status=http_status,
                    response_count=response_count,
                )

                if http_status == 429:
                    mark_rate_limited(
                        conn=conn,
                        queue_id=queue_id,
                        raw_id=raw_id,
                        retry_minutes=args.rate_limit_retry_minutes,
                    )
                    total_rate_limited += 1
                    print(f"  RATE LIMITED | HTTP 429 | raw_id={raw_id}")
                    break

                mark_done(
                    conn=conn,
                    queue_id=queue_id,
                    raw_id=raw_id,
                    response_count=response_count,
                )

                if response_count > 0:
                    total_ok += 1
                    print(f"  OK | HTTP {http_status} | response_count={response_count} | raw_id={raw_id}")
                else:
                    total_empty += 1
                    print(f"  EMPTY | HTTP {http_status} | response_count=0 | raw_id={raw_id}")

                time.sleep(args.sleep_sec)

            except Exception as exc:
                conn.rollback()
                total_error += 1
                mark_error(
                    conn=conn,
                    queue_id=queue_id,
                    error_message=exc,
                    retry_minutes=args.retry_minutes,
                )
                print(f"  ERROR: {exc}")

        print("=" * 80)
        print("DONE")
        print(f"OK           : {total_ok}")
        print(f"EMPTY        : {total_empty}")
        print(f"RATE LIMITED : {total_rate_limited}")
        print(f"ERROR        : {total_error}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()