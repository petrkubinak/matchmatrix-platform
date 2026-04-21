# pull_api_tennis_leagues_v1.py
# =========================================================
# Tennis leagues pull
# čte API base URL + endpoint z OPS
# ukládá RAW payload do staging.api_tennis_leagues_raw
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
ENTITY = "leagues"

RAPIDAPI_KEY = os.getenv("RAPIDAPI_KEY")
RAPIDAPI_TENNIS_HOST = os.getenv("RAPIDAPI_TENNIS_HOST")
RAPIDAPI_TENNIS_BASE = os.getenv("RAPIDAPI_TENNIS_BASE")
RAPIDAPI_TENNIS_LEAGUES_PATH = os.getenv("RAPIDAPI_TENNIS_LEAGUES_PATH")

if not RAPIDAPI_KEY:
    raise Exception("Missing RAPIDAPI_KEY in ingest/.env")

if not RAPIDAPI_TENNIS_HOST:
    raise Exception("Missing RAPIDAPI_TENNIS_HOST in ingest/.env")

if not RAPIDAPI_TENNIS_BASE:
    raise Exception("Missing RAPIDAPI_TENNIS_BASE in ingest/.env")

if not RAPIDAPI_TENNIS_LEAGUES_PATH:
    raise Exception("Missing RAPIDAPI_TENNIS_LEAGUES_PATH in ingest/.env")


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def save_raw(conn, run_id, provider_league_id, season, payload):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO staging.api_tennis_leagues_raw
            (run_id, provider, sport_code, provider_league_id, season, payload)
            VALUES (%s, %s, %s, %s, %s, %s::jsonb)
        """, (
            run_id,
            PROVIDER,
            SPORT_CODE,
            None if provider_league_id is None else str(provider_league_id),
            None if season is None else str(season),
            json.dumps(payload)
        ))
    conn.commit()


def fetch_leagues():
    url = f"{RAPIDAPI_TENNIS_BASE.rstrip('/')}{RAPIDAPI_TENNIS_LEAGUES_PATH}"
    headers = {
        "X-RapidAPI-Key": RAPIDAPI_KEY,
        "X-RapidAPI-Host": RAPIDAPI_TENNIS_HOST,
    }

    print(f"URL          : {url}")
    print(f"RAPID HOST   : {RAPIDAPI_TENNIS_HOST}")

    response = requests.get(url, headers=headers, timeout=30)

    if response.status_code != 200:
        raise Exception(f"API ERROR: {response.status_code} - {response.text}")

    return response.json()


def detect_items(data):
    if isinstance(data, dict):
        if isinstance(data.get("response"), list):
            return data["response"]
        if isinstance(data.get("results"), list):
            return data["results"]
        if isinstance(data.get("data"), list):
            return data["data"]

    if isinstance(data, list):
        return data

    raise Exception("Unexpected response format")


def detect_provider_league_id(item):
    if isinstance(item, dict):
        return (
            item.get("id")
            or item.get("tournament_id")
            or item.get("competition_id")
            or (item.get("league") or {}).get("id")
            or (item.get("tournament") or {}).get("id")
        )
    return None


def detect_season(item):
    if isinstance(item, dict):
        return (
            item.get("season")
            or item.get("year")
            or (item.get("league") or {}).get("season")
            or (item.get("tournament") or {}).get("season")
        )
    return None


def run():
    print("======================================")
    print("MATCHMATRIX TENNIS LEAGUES PULL")
    print("======================================")

    run_id = int(time.time())
    print(f"RUN_ID: {run_id}")

    conn = get_connection()
    try:
        data = fetch_leagues()
        items = detect_items(data)

        count = 0
        for item in items:
            provider_league_id = detect_provider_league_id(item)
            season = detect_season(item)
            save_raw(conn, run_id, provider_league_id, season, item)
            count += 1

        print(f"RAW SAVED: {count}")
        print("DONE")
    finally:
        conn.close()


if __name__ == "__main__":
    run()