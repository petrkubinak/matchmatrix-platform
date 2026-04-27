# -*- coding: utf-8 -*-
"""
pull_api_cricket_leagues_v1.py
---------------------------------------------------------
CRICKET leagues raw pull
Tok:
    RapidAPI / Cricbuzz
        -> staging.stg_api_payloads

Primární endpoint:
    /series/v1/international

Poznámka:
- ukládáme raw payload do generické raw tabulky
- parser pak naváže přes parse_api_cricket_leagues_v1.py
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
from datetime import datetime
from typing import Any, Dict, Optional

import psycopg2
import requests
from psycopg2.extras import Json

try:
    from dotenv import load_dotenv
except ImportError:
    load_dotenv = None


# ---------------------------------------------------------
# KONFIG
# ---------------------------------------------------------
PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "leagues"

DEFAULT_ENV_PATH = r"C:\MatchMatrix-platform\ingest\API-Cricket\.env"

BASE_URL = "https://cricbuzz-cricket.p.rapidapi.com"
ENDPOINT_NAME = "series_v1_international"
ENDPOINT_PATH = "/series/v1/international"


# ---------------------------------------------------------
# ENV / DB
# ---------------------------------------------------------
def load_environment() -> None:
    if load_dotenv and os.path.exists(DEFAULT_ENV_PATH):
        load_dotenv(DEFAULT_ENV_PATH)


def get_required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing required ENV variable: {name}")
    return value


def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", "matchmatrix_pass"),
    )


# ---------------------------------------------------------
# API
# ---------------------------------------------------------
def fetch_payload() -> Dict[str, Any]:
    api_key = get_required_env("RAPIDAPI_KEY")
    api_host = os.getenv("RAPIDAPI_HOST", "cricbuzz-cricket.p.rapidapi.com")

    url = f"{BASE_URL}{ENDPOINT_PATH}"
    headers = {
        "x-rapidapi-key": api_key,
        "x-rapidapi-host": api_host,
        "Content-Type": "application/json",
    }

    response = requests.get(url, headers=headers, timeout=60)
    response.raise_for_status()
    return response.json()


# ---------------------------------------------------------
# POMOCNÉ FUNKCE
# ---------------------------------------------------------
def to_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def payload_hash(payload: Dict[str, Any]) -> str:
    raw = json.dumps(payload, ensure_ascii=False, sort_keys=True).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def detect_external_id(payload: Dict[str, Any]) -> Optional[str]:
    """
    Pro leagues payload zkusíme najít hlavní 'series' / list context id.
    Když nebude, necháme NULL.
    """
    # časté top-level kandidáty
    for key in ("seriesId", "id", "categoryId"):
        if key in payload and payload[key] is not None:
            return to_text(payload[key])

    # fallback: když je payload list-type, necháme NULL
    return None


def detect_season(payload: Dict[str, Any]) -> Optional[str]:
    for key in ("season", "seriesSeason", "year"):
        if key in payload and payload[key] is not None:
            return to_text(payload[key])
    return None


# ---------------------------------------------------------
# DB INSERT
# ---------------------------------------------------------
def insert_raw_payload(conn, payload: Dict[str, Any]) -> int:
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
            %s, %s, %s, %s, %s, %s, now(), %s, %s, 'pending', NULL, now()
        )
        RETURNING id;
    """

    ext_id = detect_external_id(payload)
    season = detect_season(payload)
    p_hash = payload_hash(payload)

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                PROVIDER,
                SPORT_CODE,
                ENTITY_TYPE,
                ENDPOINT_NAME,
                ext_id,
                season,
                Json(payload),
                p_hash,
            ),
        )
        return cur.fetchone()[0]


# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------
def main() -> int:
    load_environment()

    print("======================================")
    print("MATCHMATRIX CRICKET LEAGUES PULL")
    print("======================================")
    print(f"URL  : {BASE_URL}{ENDPOINT_PATH}")
    print(f"HOST : cricbuzz-cricket.p.rapidapi.com")

    conn = None
    try:
        payload = fetch_payload()
        conn = get_db_connection()
        conn.autocommit = False

        payload_id = insert_raw_payload(conn, payload)
        conn.commit()

        print(f"RAW SAVED: payload_id={payload_id}")
        print("DONE")
        return 0

    except Exception as exc:
        if conn:
            conn.rollback()
        print(f"ERROR: {type(exc).__name__}: {exc}")
        return 1

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())