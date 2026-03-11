"""
MatchMatrix
Generic provider job runner

Spouští ingest joby definované v tabulce:
ops.provider_jobs

Použití:

python run_provider_job.py api_sport football football_leagues
"""

import sys
import json
import requests
import psycopg2
from datetime import datetime, timezone


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass"
}


API_KEYS = {
    "api_sport": "446eb3ca03324b2965f8c48a35eee30d"
}

API_BASE_URLS = {
    ("api_sport", "football"): "https://v3.football.api-sports.io",
    ("api_sport", "hockey"): "https://v1.hockey.api-sports.io",
    ("api_sport", "basketball"): "https://v1.basketball.api-sports.io",
    ("api_sport", "mma"): "https://v1.mma.api-sports.io",
    # doplníme postupně další sporty:
    # ("api_sport", "baseball"): "...",
    # ("api_sport", "tennis"): "...",
}

def db():
    return psycopg2.connect(**DB_CONFIG)

def build_query_params(job: dict) -> dict:
    endpoint = job["endpoint_code"]
    today = datetime.now(timezone.utc).date()

    # pro fixtures daily použij dnešní datum
    if endpoint == "fixtures":
        return {
            "date": "2026-03-08"
        }

    return {}

def load_job(provider, sport_code, job_code):
    q = """
    SELECT
        provider,
        sport_code,
        job_code,
        endpoint_code,
        ingest_mode,
        enabled,
        priority,
        batch_size,
        max_requests_per_run,
        retry_limit,
        cooldown_seconds,
        days_back,
        days_forward,
        notes
    FROM ops.provider_jobs
    WHERE provider = %s
      AND sport_code = %s
      AND job_code = %s
      AND enabled = TRUE
    LIMIT 1
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q, (provider, sport_code, job_code))
            row = cur.fetchone()

    if not row:
        return None

    return {
        "provider": row[0],
        "sport_code": row[1],
        "job_code": row[2],
        "endpoint_code": row[3],
        "ingest_mode": row[4],
        "enabled": row[5],
        "priority": row[6],
        "batch_size": row[7],
        "max_requests_per_run": row[8],
        "retry_limit": row[9],
        "cooldown_seconds": row[10],
        "days_back": row[11],
        "days_forward": row[12],
        "notes": row[13],
    }


def start_import_run(provider, sport_code, endpoint, job_code):
    q = """
    INSERT INTO public.api_import_runs
    (source, started_at, status, details)
    VALUES (%s, now(), %s, %s::jsonb)
    RETURNING id
    """

    details = {
        "provider": provider,
        "sport_code": sport_code,
        "endpoint": endpoint,
        "job_code": job_code
    }

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q, (provider, "running", json.dumps(details)))
            return cur.fetchone()[0]


def finish_import_run(run_id, status, extra_details=None):
    q = """
    UPDATE public.api_import_runs
    SET finished_at = now(),
        status = %s,
        details = COALESCE(details, '{}'::jsonb) || %s::jsonb
    WHERE id = %s
    """

    extra_details = extra_details or {}

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q, (status, json.dumps(extra_details), run_id))


def save_payload(run_id, provider, endpoint, payload):
    q = """
    INSERT INTO public.api_raw_payloads
    (run_id, source, endpoint, fetched_at, payload)
    VALUES (%s, %s, %s, now(), %s::jsonb)
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q, (run_id, provider, endpoint, json.dumps(payload)))


def call_api_sport(sport_code, endpoint, params=None):
    base_url = API_BASE_URLS.get(("api_sport", sport_code))

    if not base_url:
        raise Exception(f"Missing API base URL for sport_code={sport_code}")

    url = f"{base_url}/{endpoint}"

    headers = {
        "x-apisports-key": API_KEYS["api_sport"]
    }

    r = requests.get(url, headers=headers, params=params or {}, timeout=30)

    if r.status_code != 200:
        raise Exception(f"API error {r.status_code}: {r.text[:500]}")

    return r.json()


def run_job(provider, sport_code, job_code):

    job = load_job(provider, sport_code, job_code)

    if not job:
        print("Job not found")
        return

    endpoint = job["endpoint_code"]

    print(f"Running job {job_code} endpoint={endpoint}")

    run_id = start_import_run(provider, sport_code, endpoint, job_code)

    try:

        params = build_query_params(job)

        if provider == "api_sport":
            payload = call_api_sport(sport_code, endpoint, params)
        else:
            raise Exception("Unknown provider")

        save_payload(run_id, provider, endpoint, payload)

        finish_import_run(run_id, "ok", {
            "message": "Payload fetched and stored successfully",
            "endpoint": endpoint,
            "job_code": job_code,
            "provider": provider,
            "sport_code": sport_code,
            "params": params
        })

        print("Job finished OK")

    except Exception as e:

        finish_import_run(run_id, "error", {
            "error": str(e),
            "endpoint": endpoint,
            "job_code": job_code,
            "provider": provider,
            "sport_code": sport_code
        })

        print("Job failed", e)

if __name__ == "__main__":

    if len(sys.argv) != 4:
        print("Usage: run_provider_job.py provider sport_code job_code")
        sys.exit(1)

    provider = sys.argv[1]
    sport = sys.argv[2]
    job = sys.argv[3]

    run_job(provider, sport, job)