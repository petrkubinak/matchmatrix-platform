# -*- coding: utf-8 -*-
r"""
parse_api_baseball_leagues_to_staging.py

Kam ulozit:
C:\MatchMatrix-platform\ingest\API-Sport\parse_api_baseball_leagues_to_staging.py

Co dela:
1) nacte posledni RAW payload pro api_baseball / baseball / leagues ze staging.stg_api_payloads
2) rozparsuje response[]
3) zapise data do staging.stg_provider_leagues

Spusteni:
C:\Python314\python.exe C:\MatchMatrix-platform\ingest\API-Sport\parse_api_baseball_leagues_to_staging.py
"""

from __future__ import annotations

import json
import os
import sys
from typing import Any, Dict, List, Optional, Sequence

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

load_dotenv(r"C:\MatchMatrix-platform\.env")

PYTHON_TAG = "BSB LEAGUES PARSER"
PROVIDER = "api_baseball"
SPORT_CODE = "baseball"
ENTITY_VALUE = "leagues"


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
    print(f"[{PYTHON_TAG}] DB_DSN used: {dsn}")
    return psycopg2.connect(dsn)


def log(msg: str) -> None:
    print(f"[{PYTHON_TAG}] {msg}")


def norm_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    text = str(value).strip()
    return text if text else None


def get_table_columns(conn, schema_name: str, table_name: str) -> List[str]:
    sql = """
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = %s
      AND table_name = %s
    ORDER BY ordinal_position
    """
    with conn.cursor() as cur:
        cur.execute(sql, (schema_name, table_name))
        rows = cur.fetchall()
    return [r[0] for r in rows]


def pick_column(available: Sequence[str], candidates: Sequence[str]) -> Optional[str]:
    available_set = set(available)
    for c in candidates:
        if c in available_set:
            return c
    return None


def fetch_latest_baseball_leagues_payload(conn) -> Dict[str, Any]:
    cols = get_table_columns(conn, "staging", "stg_api_payloads")
    log(f"stg_api_payloads columns: {', '.join(cols)}")

    provider_col = pick_column(cols, ["provider"])
    sport_col = pick_column(cols, ["sport_code", "sport"])
    entity_col = pick_column(cols, ["entity", "entity_type"])
    payload_col = pick_column(cols, ["payload_json", "payload", "raw_payload"])
    id_col = pick_column(cols, ["id"])
    created_col = pick_column(cols, ["created_at"])

    if not provider_col or not sport_col or not entity_col or not payload_col or not id_col:
        raise RuntimeError("V staging.stg_api_payloads chybi nektery z potrebnych sloupcu.")

    sql = f"""
    SELECT *
    FROM staging.stg_api_payloads
    WHERE {provider_col} = %s
      AND {sport_col} = %s
      AND {entity_col} = %s
    ORDER BY {id_col} DESC
    LIMIT 1
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (PROVIDER, SPORT_CODE, ENTITY_VALUE))
        row = cur.fetchone()

    if not row:
        raise RuntimeError("Nenalezen zadny RAW payload pro api_baseball / baseball / leagues.")

    payload_value = row.get(payload_col)
    if payload_value is None:
        raise RuntimeError("Posledni RAW payload ma prazdny payload JSON.")

    if isinstance(payload_value, str):
        payload = json.loads(payload_value)
    else:
        payload = payload_value

    if not isinstance(payload, dict):
        raise RuntimeError("Payload nema ocekavanou JSON object strukturu.")

    row["_payload_json_parsed"] = payload
    row["_created_col_name"] = created_col
    return row


def extract_league_rows(raw_row: Dict[str, Any]) -> List[Dict[str, Any]]:
    payload = raw_row["_payload_json_parsed"]

    errors = payload.get("errors")
    if errors not in (None, [], {}):
        raise RuntimeError(f"RAW payload obsahuje API errors: {errors}")

    response = payload.get("response", [])
    if not isinstance(response, list):
        raise RuntimeError("payload.response neni list.")

    raw_payload_id = raw_row.get("id")
    prepared: List[Dict[str, Any]] = []

    for item in response:
        if not isinstance(item, dict):
            continue

        external_league_id = norm_text(item.get("id"))
        league_name = norm_text(item.get("name"))
        league_type = norm_text(item.get("type"))
        country = item.get("country") or {}
        country_name = norm_text(country.get("name")) if isinstance(country, dict) else None

        if not external_league_id or not league_name:
            continue

        prepared.append(
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
                "external_league_id": external_league_id,
                "league_name": league_name,
                "country_name": country_name,
                "league_type": league_type,
                "raw_payload_id": raw_payload_id,
                "is_active": True,
            }
        )

    return prepared


def upsert_stg_provider_leagues(conn, rows: Sequence[Dict[str, Any]]) -> int:
    if not rows:
        return 0

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

    with conn.cursor() as cur:
        cur.execute(delete_sql, (PROVIDER, SPORT_CODE))
        cur.executemany(insert_sql, rows)

    return len(rows)


def main() -> int:
    conn = None
    try:
        conn = get_conn()
        conn.autocommit = False

        log("Start parseru raw -> staging pro baseball leagues")

        raw_row = fetch_latest_baseball_leagues_payload(conn)
        payload = raw_row["_payload_json_parsed"]

        results = payload.get("results")
        log(f"RAW payload nalezen | id={raw_row.get('id')} | results={results}")

        rows = extract_league_rows(raw_row)
        inserted_count = upsert_stg_provider_leagues(conn, rows)
        conn.commit()

        log(f"Celkem rozparsovano: {len(rows)}")
        log(f"Vlozeno do staging.stg_provider_leagues: {inserted_count}")
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