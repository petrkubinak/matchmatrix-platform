# -*- coding: utf-8 -*-
r"""
parse_api_rugby_teams_to_staging.py

Kam ulozit:
C:\MatchMatrix-platform\ingest\API-Rugby\parse_api_rugby_teams_to_staging.py

Co dela:
1) nacte posledni RAW JSON z:
   C:\MatchMatrix-platform\data\raw\api_rugby\teams\
2) rozparsuje response[]
3) zapise data do staging.stg_provider_teams

Spusteni:
C:\Python314\python.exe C:\MatchMatrix-platform\ingest\API-Rugby\parse_api_rugby_teams_to_staging.py
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence

import psycopg2
from dotenv import load_dotenv

load_dotenv(r"C:\MatchMatrix-platform\.env")

PYTHON_TAG = "RGB TEAMS PARSER"
PROVIDER = "api_rugby"
SPORT_CODE = "rugby"
RAW_DIR = Path(r"C:\MatchMatrix-platform\data\raw\api_rugby\teams")


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
    files = sorted(RAW_DIR.glob("api_rugby_teams_*.json"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not files:
        raise FileNotFoundError(f"V {RAW_DIR} nebyl nalezen zadny RAW rugby teams JSON.")
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


def extract_league_and_season_from_filename(raw_file: Path) -> tuple[Optional[str], Optional[str]]:
    # api_rugby_teams_39_season_2024_YYYYMMDD_HHMMSS.json
    name = raw_file.stem
    parts = name.split("_")
    league = None
    season = None

    try:
        idx = parts.index("teams")
        if len(parts) > idx + 1:
            league = parts[idx + 1]
    except ValueError:
        pass

    try:
        idx = parts.index("season")
        if len(parts) > idx + 1:
            season = parts[idx + 1]
    except ValueError:
        pass

    return league, season


def extract_rows(payload: Dict[str, Any], external_league_id: Optional[str], season: Optional[str]) -> List[Dict[str, Any]]:
    response = payload.get("response", [])
    if not isinstance(response, list):
        raise RuntimeError("payload.response neni list.")

    rows: List[Dict[str, Any]] = []

    for item in response:
        if not isinstance(item, dict):
            continue

        external_team_id = norm_text(item.get("id"))
        team_name = norm_text(item.get("name"))

        country_value = item.get("country")
        if isinstance(country_value, dict):
            country_name = norm_text(country_value.get("name"))
        else:
            country_name = norm_text(country_value)

        if not external_team_id or not team_name:
            continue

        rows.append(
            {
                "provider": PROVIDER,
                "sport_code": SPORT_CODE,
                "external_team_id": external_team_id,
                "team_name": team_name,
                "country_name": country_name,
                "external_league_id": external_league_id,
                "season": season,
                "raw_payload_id": None,
                "is_active": True,
            }
        )

    return rows


def insert_rows(conn, rows: Sequence[Dict[str, Any]]) -> int:
    if not rows:
        return 0

    league_id = rows[0]["external_league_id"]
    season = rows[0]["season"]

    delete_sql = """
    DELETE FROM staging.stg_provider_teams
    WHERE provider = %s
      AND sport_code = %s
      AND (
            (%s IS NULL AND external_league_id IS NULL)
            OR external_league_id = %s
          )
      AND (
            (%s IS NULL AND season IS NULL)
            OR season = %s
          )
    """

    insert_sql = """
    INSERT INTO staging.stg_provider_teams (
        provider,
        sport_code,
        external_team_id,
        team_name,
        country_name,
        external_league_id,
        season,
        raw_payload_id,
        is_active
    )
    VALUES (
        %(provider)s,
        %(sport_code)s,
        %(external_team_id)s,
        %(team_name)s,
        %(country_name)s,
        %(external_league_id)s,
        %(season)s,
        %(raw_payload_id)s,
        %(is_active)s
    )
    """

    with conn.cursor() as cur:
        cur.execute(delete_sql, (PROVIDER, SPORT_CODE, league_id, league_id, season, season))
        cur.executemany(insert_sql, rows)

    return len(rows)


def main() -> int:
    conn = None
    try:
        log("Start parseru raw -> staging pro rugby teams")

        raw_file = find_latest_raw_file()
        log(f"RAW file: {raw_file}")

        league_id, season = extract_league_and_season_from_filename(raw_file)
        log(f"league_id={league_id} | season={season}")

        payload = load_payload(raw_file)
        log(f"results={payload.get('results')}")

        rows = extract_rows(payload, league_id, season)
        log(f"Rozparsovano rows: {len(rows)}")

        conn = get_conn()
        conn.autocommit = False

        inserted = insert_rows(conn, rows)
        conn.commit()

        log(f"Vlozeno do staging.stg_provider_teams: {inserted}")
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