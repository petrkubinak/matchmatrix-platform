# -*- coding: utf-8 -*-
"""
MATCHMATRIX 104_T - PULL FB PLAYER MATCH STATS FROM QUEUE V1

Co skript dělá:
- vezme pending řádky z ops.fixture_player_stats_queue
- zavolá API-Football endpoint /fixtures/players
- uloží RAW payload do staging.stg_api_payloads
- označí queue row jako done / error / empty

Kam výsledek vede:
- staging.stg_api_payloads

K čemu to slouží:
- automatizace stahování player match statistics

Jak se využije na webu/aplikaci:
- player match detail
- player form engine
- fantasy scoring
- AI prediction layer
- player momentum
"""

import os
import json
import argparse
import datetime as dt
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
API_HOST = "v3.football.api-sports.io"
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

    possible_keys = [
        "APISPORTS_KEY",
        "API_FOOTBALL_KEY",
        "APIFOOTBALL_KEY",
        "API_SPORTS_KEY",
        "RAPIDAPI_KEY",
        "RAPID_API_KEY",
        "API_KEY",
    ]

    for key_name in possible_keys:
        value = os.getenv(key_name)

        if value and value.strip():
            print(f"API KEY FOUND: {key_name}")
            return value.strip()

    raise RuntimeError(
        "API key nebyl nalezen v .env"
    )


def ensure_payload_table(conn):
    sql = """
    CREATE SCHEMA IF NOT EXISTS staging;

    CREATE TABLE IF NOT EXISTS staging.stg_api_payloads (
        id BIGSERIAL PRIMARY KEY,
        provider TEXT NOT NULL,
        sport_code TEXT NULL,
        entity TEXT NOT NULL,
        endpoint TEXT NULL,
        params JSONB NULL,
        payload JSONB NULL,
        response_count INTEGER NULL,
        http_status INTEGER NULL,
        status TEXT NULL,
        run_group TEXT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    """
    with conn.cursor() as cur:
        cur.execute(sql)
    conn.commit()


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

    params = {
        "fixture": str(fixture_id),
    }

    response = requests.get(
        API_URL,
        headers=headers,
        params=params,
        timeout=timeout_sec,
    )

    try:
        payload = response.json()
    except Exception:
        payload = {
            "raw_text": response.text,
        }

    return response.status_code, params, payload


def get_response_count(payload):
    if not isinstance(payload, dict):
        return 0

    response_data = payload.get("response")
    if isinstance(response_data, list):
        return len(response_data)

    return 0


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

    parse_status = "pending" if http_status == 200 and response_count > 0 else "empty"

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

    message = f"RAW saved id={raw_id}; response_count={response_count}"

    with conn.cursor() as cur:
        cur.execute(
            sql,
            {
                "queue_id": queue_id,
                "raw_id": raw_id,
                "response_count": response_count,
                "message": message,
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


def print_header(limit):
    print("=" * 80)
    print("MATCHMATRIX FB PLAYER MATCH STATS QUEUE PULLER V1")
    print("=" * 80)
    print(f"PROVIDER : {PROVIDER}")
    print(f"SPORT    : {SPORT_CODE}")
    print(f"ENTITY   : {ENTITY}")
    print(f"LIMIT    : {limit}")
    print("=" * 80)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=5)
    parser.add_argument("--timeout-sec", type=int, default=30)
    parser.add_argument("--retry-minutes", type=int, default=30)
    args = parser.parse_args()

    print_header(args.limit)

    api_key = get_api_key()
    conn = get_conn()

    total_ok = 0
    total_empty = 0
    total_error = 0

    try:
        ensure_payload_table(conn)
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
        print(f"OK    : {total_ok}")
        print(f"EMPTY : {total_empty}")
        print(f"ERROR : {total_error}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()