# -*- coding: utf-8 -*-
r"""
parse_api_rugby_fixtures_to_staging.py

Kam ulozit:
C:\MatchMatrix-platform\ingest\API-Rugby\parse_api_rugby_fixtures_to_staging.py

Co dela:
1) nacte posledni RAW JSON z:
   C:\MatchMatrix-platform\data\raw\api_rugby\fixtures\
2) rozparsuje response[]
3) zapise data do staging.stg_provider_fixtures

Spusteni:
C:\Python314\python.exe C:\MatchMatrix-platform\ingest\API-Rugby\parse_api_rugby_fixtures_to_staging.py
"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence

import psycopg2
from dotenv import load_dotenv

load_dotenv(r"C:\MatchMatrix-platform\.env")

PYTHON_TAG = "RGB FIXTURES PARSER"
PROVIDER = "api_rugby"
SPORT_CODE = "rugby"
RAW_DIR = Path(r"C:\MatchMatrix-platform\data\raw\api_rugby\fixtures")


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
    files = sorted(RAW_DIR.glob("api_rugby_fixtures_*.json"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not files:
        raise FileNotFoundError(f"V {RAW_DIR} nebyl nalezen zadny RAW rugby fixtures JSON.")
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
    # api_rugby_fixtures_51_season_2024_YYYYMMDD_HHMMSS.json
    name = raw_file.stem
    parts = name.split("_")
    league = None
    season = None

    try:
        idx = parts.index("fixtures")
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


def parse_dt(value: Any) -> Optional[datetime]:
    if value is None:
        return None

    if isinstance(value, dict):
        for key in ("date", "start", "datetime"):
            if value.get(key):
                value = value.get(key)
                break

    text = norm_text(value)
    if not text:
        return None

    try:
        return datetime.fromisoformat(text.replace("Z", "+00:00"))
    except Exception:
        return None


def extract_rows(payload: Dict[str, Any], external_league_id: Optional[str], season: Optional[str]) -> List[Dict[str, Any]]:
    response = payload.get("response", [])
    if not isinstance(response, list):
        raise RuntimeError("payload.response neni list.")

    rows: List[Dict[str, Any]] = []

    for item in response:
        if not isinstance(item, dict):
            continue

        # 🔥 rugby struktura = flat
        external_fixture_id = norm_text(item.get("id"))
        fixture_date = parse_dt(item.get("date"))

        status_obj = item.get("status") or {}
        status_short = norm_text(status_obj.get("short"))
        status_long = norm_text(status_obj.get("long"))

        league = item.get("league") or {}
        teams = item.get("teams") or {}
        scores = item.get("scores") or {}

        home = teams.get("home") or {}
        away = teams.get("away") or {}

        home_score = scores.get("home")
        away_score = scores.get("away")

        if (
            external_fixture_id
            and fixture_date
            and home.get("id")
            and away.get("id")
        ):
            rows.append(
                {
                    "provider": PROVIDER,
                    "sport_code": SPORT_CODE,
                    "external_fixture_id": external_fixture_id,
                    "external_league_id": norm_text(league.get("id")) or external_league_id,
                    "league_name": norm_text(league.get("name")),
                    "season": season,
                    "fixture_date": fixture_date,
                    "status_short": status_short,
                    "status_long": status_long,
                    "external_home_team_id": norm_text(home.get("id")),
                    "home_team_name": norm_text(home.get("name")),
                    "external_away_team_id": norm_text(away.get("id")),
                    "away_team_name": norm_text(away.get("name")),
                    "home_score": home_score,
                    "away_score": away_score,
                    "raw_payload_id": None,
                }
            )

    return rows

def insert_rows(conn, rows: Sequence[Dict[str, Any]]) -> int:
    if not rows:
        return 0

    league_id = rows[0]["external_league_id"]
    season = rows[0]["season"]

    delete_sql = """
    DELETE FROM staging.stg_provider_fixtures
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
    INSERT INTO staging.stg_provider_fixtures (
        provider,
        sport_code,
        external_fixture_id,
        external_league_id,
        season,
        home_team_external_id,
        away_team_external_id,
        fixture_date,
        status_text,
        home_score,
        away_score,
        raw_payload_id
    )
    VALUES (
        %(provider)s,
        %(sport_code)s,
        %(external_fixture_id)s,
        %(external_league_id)s,
        %(season)s,
        %(home_team_external_id)s,
        %(away_team_external_id)s,
        %(fixture_date)s,
        %(status_text)s,
        %(home_score)s,
        %(away_score)s,
        %(raw_payload_id)s
    )
    """

    prepared = []
    for row in rows:
        prepared.append(
            {
                "provider": row["provider"],
                "sport_code": row["sport_code"],
                "external_fixture_id": row["external_fixture_id"],
                "external_league_id": row["external_league_id"],
                "season": row["season"],
                "home_team_external_id": row["external_home_team_id"],
                "away_team_external_id": row["external_away_team_id"],
                "fixture_date": row["fixture_date"],
                "status_text": row["status_long"] or row["status_short"],
                "home_score": row["home_score"],
                "away_score": row["away_score"],
                "raw_payload_id": row["raw_payload_id"],
            }
        )

    with conn.cursor() as cur:
        cur.execute(delete_sql, (PROVIDER, SPORT_CODE, league_id, league_id, season, season))
        cur.executemany(insert_sql, prepared)

    return len(prepared)

def main() -> int:
    conn = None
    try:
        log("Start parseru raw -> staging pro rugby fixtures")

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

        log(f"Vlozeno do staging.stg_provider_fixtures: {inserted}")
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