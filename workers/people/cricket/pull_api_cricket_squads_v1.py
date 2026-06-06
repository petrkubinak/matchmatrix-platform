# -*- coding: utf-8 -*-
"""
MATCHMATRIX WORKER
pull_api_cricket_squads_v1.py

CO TO JE:
- Custom downloader pro Cricket squads z RapidAPI Cricbuzz.

K ČEMU TO JE:
- Cricket players nejdou přes unified ingest.
- Squads endpoint je první krok PEOPLE vrstvy pro cricket.
- Stáhne raw payload /series/v1/{series_id}/squads do staging.stg_api_payloads.

KDE TO UVIDÍME:
- staging.stg_api_payloads
- provider = api_cricket
- sport_code = CK
- entity_type = players
- endpoint_name = series_v1_squads

JAK SE TO VYUŽIJE:
- Další parser z payloadu vytáhne squadId, teamId a potom hráče.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from typing import Any, Dict

import psycopg2
import requests
from dotenv import load_dotenv
from psycopg2.extras import Json


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, "ingest", "API-Cricket", ".env")

PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "players"
ENDPOINT_NAME = "series_v1_squads"


def load_environment() -> None:
    if os.path.exists(ENV_PATH):
        load_dotenv(ENV_PATH)


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", "matchmatrix_pass"),
    )


def get_required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing required ENV variable: {name}")
    return value


def payload_hash(payload: Dict[str, Any]) -> str:
    raw = json.dumps(payload, ensure_ascii=False, sort_keys=True).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def fetch_squads(series_id: str) -> Dict[str, Any]:
    base = os.getenv("RAPIDAPI_CRICKET_BASE", "https://cricbuzz-cricket.p.rapidapi.com").rstrip("/")
    host = os.getenv("RAPIDAPI_CRICKET_HOST", "cricbuzz-cricket.p.rapidapi.com")
    key = get_required_env("RAPIDAPI_KEY")

    path = f"/series/v1/{series_id}/squads"
    url = base + path

    headers = {
        "x-rapidapi-key": key,
        "x-rapidapi-host": host,
        "Content-Type": "application/json",
    }

    print("REQUEST:", url)

    response = requests.get(url, headers=headers, timeout=60)

    payload = {
        "request_url": response.url,
        "status_code": response.status_code,
        "series_id": series_id,
        "response": None,
        "text": None,
    }

    try:
        payload["response"] = response.json()
    except Exception:
        payload["text"] = response.text

    if response.status_code >= 400:
        raise RuntimeError(f"HTTP {response.status_code}: {response.text[:500]}")

    return payload


def insert_raw_payload(conn, series_id: str, season: str, payload: Dict[str, Any]) -> int:
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
            payload_hash,
            parse_status,
            parse_message,
            created_at
        )
        VALUES (
            %s, %s, %s, %s, %s, %s, NOW(), %s, %s, 'pending', %s, NOW()
        )
        RETURNING id;
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                PROVIDER,
                SPORT_CODE,
                ENTITY_TYPE,
                ENDPOINT_NAME,
                series_id,
                season,
                Json(payload),
                payload_hash(payload),
                "CK squads raw payload downloaded",
            ),
        )
        return cur.fetchone()[0]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--series-id", required=True, help="Cricbuzz series id, např. 7607 pro IPL 2024")
    parser.add_argument("--season", default="2024")
    args = parser.parse_args()

    load_environment()

    print("=" * 80)
    print("MATCHMATRIX CK SQUADS CUSTOM DOWNLOADER V1")
    print("=" * 80)
    print("SERIES ID:", args.series_id)
    print("SEASON   :", args.season)
    print("=" * 80)

    conn = None

    try:
        payload = fetch_squads(args.series_id)

        conn = get_db_connection()
        conn.autocommit = False

        payload_id = insert_raw_payload(conn, args.series_id, args.season, payload)
        conn.commit()

        print("RAW SAVED: payload_id=", payload_id)
        print("DONE")
        return 0

    except Exception as exc:
        if conn:
            conn.rollback()
        print("ERROR:", type(exc).__name__, exc)
        return 1

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())