# pull_api_cricket_fixtures_v1.py
# =========================================================
# Cricket fixtures/live pull (RapidAPI Cricbuzz)
# RAW -> staging.stg_api_payloads
# =========================================================

import os
import json
import time
import hashlib
import requests
import psycopg2
from dotenv import load_dotenv

load_dotenv(r"C:\MatchMatrix-platform\ingest\API-Cricket\.env")

DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE", "matchmatrix"),
    "user": os.getenv("PGUSER", "matchmatrix"),
    "password": os.getenv("PGPASSWORD", "matchmatrix_pass"),
}

PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "fixtures"
ENDPOINT_NAME = "matches_v1_live"

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")
RAPIDAPI_CRICKET_HOST = os.getenv("RAPIDAPI_CRICKET_HOST")
RAPIDAPI_CRICKET_BASE = os.getenv("RAPIDAPI_CRICKET_BASE")
RAPIDAPI_CRICKET_FIXTURES_PATH = os.getenv("RAPIDAPI_CRICKET_FIXTURES_PATH")

if not RAPIDAPI_KEY:
    raise Exception("Missing RAPIDAPI_KEY")

if not RAPIDAPI_CRICKET_HOST:
    raise Exception("Missing RAPIDAPI_CRICKET_HOST")

if not RAPIDAPI_CRICKET_BASE:
    raise Exception("Missing RAPIDAPI_CRICKET_BASE")

if not RAPIDAPI_CRICKET_FIXTURES_PATH:
    raise Exception("Missing RAPIDAPI_CRICKET_FIXTURES_PATH")


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def build_payload_hash(payload: dict) -> str:
    """
    Stabilní hash JSON payloadu pro snadnější deduplikaci/audit.
    """
    payload_text = json.dumps(payload, ensure_ascii=False, sort_keys=True)
    return hashlib.sha256(payload_text.encode("utf-8")).hexdigest()


def save_raw_payload(conn, payload: dict, external_id: str | None = None, season: str | None = None) -> int:
    """
    Uloží RAW payload do generické staging tabulky.
    """
    payload_hash = build_payload_hash(payload)

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
                fetched_at,
                payload_json,
                payload_hash,
                parse_status
            )
            VALUES (%s, %s, %s, %s, %s, %s, NOW(), %s::jsonb, %s, 'pending')
            RETURNING id
            """,
            (
                PROVIDER,
                SPORT_CODE,
                ENTITY_TYPE,
                ENDPOINT_NAME,
                external_id,
                season,
                json.dumps(payload, ensure_ascii=False),
                payload_hash,
            )
        )
        payload_id = cur.fetchone()[0]

    conn.commit()
    return payload_id


def fetch_data() -> dict:
    """
    Pull live cricket matches z RapidAPI.
    Endpoint podle curl:
    GET https://cricbuzz-cricket.p.rapidapi.com/matches/v1/live
    """
    url = f"{RAPIDAPI_CRICKET_BASE.rstrip('/')}{RAPIDAPI_CRICKET_FIXTURES_PATH}"

    headers = {
        "x-rapidapi-key": RAPIDAPI_KEY,
        "x-rapidapi-host": RAPIDAPI_CRICKET_HOST,
        "Content-Type": "application/json",
    }

    print(f"URL  : {url}")
    print(f"HOST : {RAPIDAPI_CRICKET_HOST}")

    response = requests.get(url, headers=headers, timeout=30)

    if response.status_code != 200:
        raise Exception(f"API ERROR: {response.status_code} - {response.text}")

    return response.json()


def run():
    print("======================================")
    print("MATCHMATRIX CRICKET FIXTURES PULL")
    print("======================================")

    run_id = int(time.time())
    print(f"RUN_ID: {run_id}")

    conn = get_connection()

    try:
        data = fetch_data()
        payload_id = save_raw_payload(conn, data)

        print(f"RAW SAVED: payload_id={payload_id}")
        print("DONE")

    finally:
        conn.close()


if __name__ == "__main__":
    run()