# -*- coding: utf-8 -*-
r"""
parse_api_rugby_leagues_to_staging.py

Kam ulozit:
C:\MatchMatrix-platform\ingest\API-Rugby\parse_api_rugby_leagues_to_staging.py

Co dela:
1) nacte posledni RAW JSON z:
   C:\MatchMatrix-platform\data\raw\api_rugby\leagues\
2) rozparsuje response[]
3) zapise data do staging.stg_provider_leagues

Spusteni:
C:\Python314\python.exe C:\MatchMatrix-platform\ingest\API-Rugby\parse_api_rugby_leagues_to_staging.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
import os

load_dotenv(r"C:\MatchMatrix-platform\.env")

PYTHON_TAG = "RGB LEAGUES PARSER"
PROVIDER = "api_rugby"
SPORT_CODE = "rugby"

RAW_DIR = Path(r"C:\MatchMatrix-platform\data\raw\api_rugby\leagues")


def log(msg: str) -> None:
    print(f"[{PYTHON_TAG}] {msg}")


def get_dsn() -> str:
    raw = os.environ.get("DB_DSN", "").strip()
    if raw:
        lowered = raw.lower()
        if lowered.startswith("set db_dsn="):
            raw = raw.split("=", 1)[1].strip()
        elif lowered.startswith("db_dsn="):
            raw = raw.split("=", 1)[1].strip()
        if raw:
            return raw

    return "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"


def get_conn():
    dsn = get_dsn()
    log(f"DB_DSN used: {dsn}")
    return psycopg2.connect(dsn)


def norm_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def find_latest_raw_file() -> Path:
    if not RAW_DIR.exists():
        raise FileNotFoundError(f"Slozka neexistuje: {RAW_DIR}")

    files = sorted(RAW_DIR.glob("api_rugby_leagues_*.json"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not files:
        raise FileNotFoundError(f"V {RAW_DIR} nebyl nalezen zadny RAW rugby leagues JSON.")
    return files[0]


def load_payload(raw_file: Path) -> Dict[str, Any]:
    with raw_file.open("r", encoding="utf-8-sig") as f:
        payload = json.load(f)

    if not isinstance(payload, dict):
        raise RuntimeError("Payload nema ocekavanou JSON object strukturu.")

    errors = payload.get("errors")
    if errors not in (None, [], {}):
        raise RuntimeError(f"RAW payload obsahuje API errors: {errors}")

    return payload


def extract_rows(payload: Dict[str, Any]) -> List[Dict[str, Any]]:
    response = payload.get("response", [])
    if not isinstance(response, list):
        raise RuntimeError("payload.response neni list.")

    rows: List[Dict[str, Any]] = []

    for item in response:
        if not isinstance(item, dict):
            continue

        external_league_id = norm_text(item.get("id"))
        league_name = norm_text(item.get("name"))
        league_type = norm_text(item.get("type"))

        country_value = item.get("country")
        if isinstance(country_value, dict):
            country_name = norm_text(country_value.get("name"))
        else:
            country_name = norm_text(country_value)

        if not external_league_id or not league_name:
            continue

        rows.append(
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
                "external_league_id": external_league_id,
                "league_name": league_name,
                "country_name": country_name,
                "league_type": league_type,
                "is_active": True,
            }
        )

    return rows


def insert_rows(conn, rows: Sequence[Dict[str, Any]], raw_file_name: str) -> int:
    if not rows:
        return 0

    raw_payload_id = None

    delete_sql = """
    DELETE FROM staging.stg_provider_leagues
    WHERE provider = %s
      AND sport_code = %s
    """

    insert_sql = """
    INSERT INTO staging.stg_provider_leagues (
        provider,
        sport_code,
        external_league_id,
        league_name,
        country_name,
        raw_payload_id,
        is_active
    )
    VALUES (
        %(provider)s,
        %(sport_code)s,
        %(external_league_id)s,
        %(league_name)s,
        %(country_name)s,
        %(raw_payload_id)s,
        %(is_active)s
    )
    """

    prepared = []
    for row in rows:
        prepared.append(
            {
                **row,
                "raw_payload_id": raw_payload_id
            }
        )

    with conn.cursor() as cur:
        cur.execute(delete_sql, (PROVIDER, SPORT_CODE))
        cur.executemany(insert_sql, prepared)

    return len(prepared)


def main() -> int:
    conn = None
    try:
        log("Start parseru raw -> staging pro rugby leagues")

        raw_file = find_latest_raw_file()
        log(f"RAW file: {raw_file}")

        payload = load_payload(raw_file)
        log(f"results={payload.get('results')}")

        rows = extract_rows(payload)
        log(f"Rozparsovano rows: {len(rows)}")

        conn = get_conn()
        conn.autocommit = False

        inserted = insert_rows(conn, rows, raw_file.name)
        conn.commit()

        log(f"Vlozeno do staging.stg_provider_leagues: {inserted}")
        log("Hotovo OK")
        return 0

    except Exception as exc:
        if conn is not None:
            conn.rollback()
        log(f"CHYBA: {exc}")
        return 1

    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())