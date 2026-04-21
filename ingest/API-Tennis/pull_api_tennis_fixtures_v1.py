# pull_api_tennis_fixtures_v1.py
# =========================================================
# Tennis fixtures pull (RapidAPI live events provider)
# RAW -> staging.api_tennis_fixtures_raw
# =========================================================

import os
import json
import time
import requests
import psycopg2
from dotenv import load_dotenv

load_dotenv(r"C:\MatchMatrix-platform\ingest\API-Tennis\.env")

DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE", "matchmatrix"),
    "user": os.getenv("PGUSER", "matchmatrix"),
    "password": os.getenv("PGPASSWORD", "matchmatrix_pass"),
}

PROVIDER = "api_tennis"
SPORT_CODE = "TN"

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")
RAPIDAPI_TENNIS_FIXTURES_HOST = os.getenv("RAPIDAPI_TENNIS_FIXTURES_HOST")
RAPIDAPI_TENNIS_FIXTURES_BASE = os.getenv("RAPIDAPI_TENNIS_FIXTURES_BASE")
RAPIDAPI_TENNIS_FIXTURES_PATH = os.getenv("RAPIDAPI_TENNIS_FIXTURES_PATH")

if not RAPIDAPI_KEY:
    raise Exception("Missing RAPIDAPI_KEY")

if not RAPIDAPI_TENNIS_FIXTURES_HOST:
    raise Exception("Missing RAPIDAPI_TENNIS_FIXTURES_HOST")

if not RAPIDAPI_TENNIS_FIXTURES_BASE:
    raise Exception("Missing RAPIDAPI_TENNIS_FIXTURES_BASE")

if not RAPIDAPI_TENNIS_FIXTURES_PATH:
    raise Exception("Missing RAPIDAPI_TENNIS_FIXTURES_PATH")


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def save_raw(conn, run_id, payload):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO staging.api_tennis_fixtures_raw
            (run_id, provider, sport_code, payload)
            VALUES (%s, %s, %s, %s::jsonb)
        """, (
            run_id,
            PROVIDER,
            SPORT_CODE,
            json.dumps(payload)
        ))
    conn.commit()


def fetch_data():
    url = f"{RAPIDAPI_TENNIS_FIXTURES_BASE.rstrip('/')}{RAPIDAPI_TENNIS_FIXTURES_PATH}"

    headers = {
        "X-RapidAPI-Key": RAPIDAPI_KEY,
        "X-RapidAPI-Host": RAPIDAPI_TENNIS_FIXTURES_HOST,
        "Content-Type": "application/json",
    }

    print(f"URL        : {url}")
    print(f"HOST       : {RAPIDAPI_TENNIS_FIXTURES_HOST}")

    response = requests.get(url, headers=headers, timeout=30)

    if response.status_code != 200:
        raise Exception(f"API ERROR: {response.status_code} - {response.text}")

    return response.json()


def run():
    print("======================================")
    print("MATCHMATRIX TENNIS FIXTURES PULL")
    print("======================================")

    run_id = int(time.time())
    print(f"RUN_ID: {run_id}")

    conn = get_connection()

    try:
        data = fetch_data()
        save_raw(conn, run_id, data)

        print("RAW SAVED: 1 payload")
        print("DONE")

    finally:
        conn.close()


if __name__ == "__main__":
    run()