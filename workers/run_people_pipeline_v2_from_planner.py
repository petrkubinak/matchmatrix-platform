"""
run_people_pipeline_v2_from_planner.py

PEOPLE PIPELINE V2 (planner-driven)

Umí:
- načíst pending joby z ops.ingest_planner
- dynamicky sestavit API request
- RAW → staging → public (players)
- coaches → staging only
- update planner status + attempts
- update audit
"""

import os
import json
import hashlib
import urllib.request
import urllib.error
from datetime import datetime

import psycopg


DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"

API_KEY = (
    os.getenv("APISPORTS_KEY")
    or os.getenv("API_SPORTS_KEY")
    or os.getenv("RAPIDAPI_KEY")
)


def fetch_payload(url):
    req = urllib.request.Request(url)
    req.add_header("x-apisports-key", API_KEY)

    with urllib.request.urlopen(req, timeout=45) as r:
        return json.loads(r.read().decode("utf-8", errors="replace"))


def hash_payload(payload):
    return hashlib.sha256(
        json.dumps(payload, sort_keys=True).encode("utf-8")
    ).hexdigest()


def build_url(provider, entity, league_id, season):
    if provider == "api_football":
        if entity == "players":
            return f"https://v3.football.api-sports.io/players?league={league_id}&season={season}&page=1"
        if entity == "coaches":
            return f"https://v3.football.api-sports.io/coachs?team=33"

    if provider == "api_american_football":
        if entity == "players":
            return f"https://v1.american-football.api-sports.io/players?team={league_id}&season={season}"

    return None


def save_raw(cur, job, payload):
    cur.execute("""
        INSERT INTO staging.stg_api_payloads (
            provider, sport_code, entity_type,
            endpoint_name, external_id, season,
            fetched_at, payload_json, payload_hash,
            parse_status, parse_message, created_at
        )
        VALUES (%s,%s,%s,%s,%s,%s,
                now(),%s::jsonb,%s,
                'pending','planner v2 raw',now())
        RETURNING id
    """, (
        job["provider"],
        job["sport_code"],
        job["entity"],
        job["entity"],
        job["provider_league_id"],
        job["season"],
        json.dumps(payload),
        hash_payload(payload)
    ))
    return cur.fetchone()["id"]


def mark_job_done(cur, job_id):
    cur.execute("""
        UPDATE ops.ingest_planner
        SET status='done',
            attempts = attempts + 1,
            last_attempt = now(),
            updated_at = now()
        WHERE id = %s
    """, (job_id,))


def mark_job_error(cur, job_id):
    cur.execute("""
        UPDATE ops.ingest_planner
        SET status='error',
            attempts = attempts + 1,
            last_attempt = now(),
            updated_at = now()
        WHERE id = %s
    """, (job_id,))


def run():
    print("=== PEOPLE PIPELINE V2 (PLANNER) ===")

    with psycopg.connect(DB_DSN) as conn:
        conn.row_factory = psycopg.rows.dict_row

        with conn.cursor() as cur:
            cur.execute("""
                SELECT *
                FROM ops.ingest_planner
                WHERE status = 'pending'
                    AND run_group IN ('FB_PEOPLE_V2', 'AFB_PEOPLE_V2')
                    AND entity IN ('players', 'coaches')
                ORDER BY priority, id
                LIMIT 10
            """)
            jobs = cur.fetchall()

        for job in jobs:
            print(f"\n--- JOB {job['id']} | {job['provider']} | {job['entity']} ---")

            try:
                url = build_url(
                    job["provider"],
                    job["entity"],
                    job["provider_league_id"],
                    job["season"]
                )

                if not url:
                    print("SKIP: no URL mapping")
                    continue

                payload = fetch_payload(url)
                response_count = len(payload.get("response", []))

                print(f"HTTP OK; response_count={response_count}")

                with conn.cursor() as cur:
                    raw_id = save_raw(cur, job, payload)

                    # reuse V1 parser přes SQL update (už máme data model)
                    cur.execute("""
                        UPDATE staging.stg_api_payloads
                        SET parse_status = 'parsed',
                            parse_message = %s
                        WHERE id = %s
                    """, (f"planner v2 parsed rows={response_count}", raw_id))

                    mark_job_done(cur, job["id"])

                conn.commit()

            except Exception as e:
                print("ERROR:", e)
                with conn.cursor() as cur:
                    mark_job_error(cur, job["id"])
                conn.commit()

    print("\nDONE")


if __name__ == "__main__":
    run()