from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.parse import urlencode

import psycopg2
import psycopg2.extras
import requests

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
DEFAULT_BASE_URL = "https://v1.hockey.api-sports.io"
DEFAULT_PROVIDER = "api_hockey"
DEFAULT_SPORT_CODE = "HK"
DEFAULT_ENTITY = "players"
DEFAULT_LOG_DIR = PROJECT_ROOT / "logs"
DEFAULT_PROJECT_DIR = PROJECT_ROOT / "ingest" / "API-Hockey"

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": int(os.getenv("POSTGRES_PORT", "5432")),
    "dbname": os.getenv("POSTGRES_DB", "matchmatrix"),
    "user": os.getenv("POSTGRES_USER", "matchmatrix"),
    "password": os.getenv("POSTGRES_PASSWORD", "matchmatrix_pass"),
}

API_KEY_ENV_CANDIDATES = [
    "API_HOCKEY_KEY",
    "API_SPORTS_KEY",
    "APISPORTS_KEY",
    "RAPIDAPI_KEY",
]

PAYLOAD_COLUMN_CANDIDATES = [
    ("provider", DEFAULT_PROVIDER),
    ("sport_code", DEFAULT_SPORT_CODE),
    ("entity", DEFAULT_ENTITY),
    ("source_endpoint", None),
    ("endpoint", None),
    ("request_url", None),
    ("url", None),
    ("request_params", None),
    ("parameters", None),
    ("provider_league_id", None),
    ("league_id", None),
    ("provider_team_id", None),
    ("team_id", None),
    ("season", None),
    ("run_id", None),
    ("job_id", None),
    ("status", "pending"),
    ("http_status", None),
    ("payload_json", None),
    ("payload", None),
    ("raw_payload", None),
    ("response_json", None),
    ("response_body", None),
    ("raw_response", None),
    ("fetched_at", None),
    ("created_at", None),
    ("updated_at", None),
    ("notes", None),
]


@dataclass
class FetchResult:
    url: str
    endpoint: str
    params: dict[str, Any]
    status_code: int
    payload: dict[str, Any]
    raw_path: Path


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def detect_api_key() -> str:
    for key_name in API_KEY_ENV_CANDIDATES:
        value = os.getenv(key_name)
        if value:
            return value
    raise SystemExit(
        "Missing API key. Set one of: " + ", ".join(API_KEY_ENV_CANDIDATES)
    )


def build_candidate_requests(team_id: str | None, league_id: str | None, season: str | None) -> list[tuple[str, dict[str, Any]]]:
    candidates: list[tuple[str, dict[str, Any]]] = []
    if team_id and season:
        candidates.append(("players", {"team": team_id, "season": season}))
    if team_id:
        candidates.append(("players", {"team": team_id}))
    if league_id and season:
        candidates.append(("players", {"league": league_id, "season": season}))
    if league_id:
        candidates.append(("players", {"league": league_id}))
    if season:
        candidates.append(("players", {"season": season}))
    candidates.append(("players", {}))
    # Some APIs use squads/rosters instead of players; keep fallback explicit.
    if team_id:
        candidates.append(("rosters", {"team": team_id}))
        candidates.append(("squads", {"team": team_id}))
    return candidates


def is_endpoint_missing(payload: dict[str, Any]) -> bool:
    errors = payload.get("errors")
    if isinstance(errors, dict):
        text = json.dumps(errors, ensure_ascii=False).lower()
        return "endpoint" in text and "do not exist" in text
    if isinstance(errors, list):
        text = json.dumps(errors, ensure_ascii=False).lower()
        return "endpoint" in text and "do not exist" in text
    return False


def choose_request(
    base_url: str,
    headers: dict[str, str],
    team_id: str | None,
    league_id: str | None,
    season: str | None,
    timeout_sec: int,
) -> FetchResult:
    session = requests.Session()
    last_result: FetchResult | None = None

    for endpoint, params in build_candidate_requests(team_id, league_id, season):
        url = f"{base_url.rstrip('/')}/{endpoint}"
        response = session.get(url, headers=headers, params=params, timeout=timeout_sec)
        response.raise_for_status()
        payload = response.json()

        raw_name = (
            f"temp_{DEFAULT_PROVIDER}_{DEFAULT_ENTITY}_{endpoint}_"
            f"{team_id or league_id or 'global'}_{season or 'na'}.json"
        )
        raw_path = DEFAULT_LOG_DIR / raw_name
        raw_path.parent.mkdir(parents=True, exist_ok=True)
        raw_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

        result = FetchResult(
            url=response.url,
            endpoint=endpoint,
            params=params,
            status_code=response.status_code,
            payload=payload,
            raw_path=raw_path,
        )
        last_result = result

        if is_endpoint_missing(payload):
            continue
        return result

    if last_result is None:
        raise RuntimeError("No candidate request was executed.")
    raise RuntimeError(
        "No working hockey players endpoint found. "
        f"Last tried endpoint={last_result.endpoint} url={last_result.url}"
    )


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def get_existing_columns(schema: str, table: str) -> list[str]:
    sql = """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
    """
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, (schema, table))
            return [row[0] for row in cur.fetchall()]


def insert_payload_to_staging(
    result: FetchResult,
    run_id: int | None,
    team_id: str | None,
    league_id: str | None,
    season: str | None,
) -> int | None:
    schema = "staging"
    table = "stg_api_payloads"
    columns = get_existing_columns(schema, table)
    if not columns:
        print("WARN: staging.stg_api_payloads not found; payload stored only in log file.")
        return None

    fetched_at = now_utc()
    values_by_column: dict[str, Any] = {
        "provider": DEFAULT_PROVIDER,
        "sport_code": DEFAULT_SPORT_CODE,
        "entity": DEFAULT_ENTITY,
        "source_endpoint": result.endpoint,
        "endpoint": result.endpoint,
        "request_url": result.url,
        "url": result.url,
        "request_params": psycopg2.extras.Json(result.params),
        "parameters": psycopg2.extras.Json(result.params),
        "provider_league_id": league_id,
        "league_id": league_id,
        "provider_team_id": team_id,
        "team_id": team_id,
        "season": season,
        "run_id": run_id,
        "status": "pending",
        "http_status": result.status_code,
        "payload_json": psycopg2.extras.Json(result.payload),
        "payload": psycopg2.extras.Json(result.payload),
        "raw_payload": psycopg2.extras.Json(result.payload),
        "response_json": psycopg2.extras.Json(result.payload),
        "response_body": json.dumps(result.payload, ensure_ascii=False),
        "raw_response": json.dumps(result.payload, ensure_ascii=False),
        "fetched_at": fetched_at,
        "created_at": fetched_at,
        "updated_at": fetched_at,
        "notes": f"HK players raw fetch | endpoint={result.endpoint} | results={result.payload.get('results')}",
    }

    insert_cols = [col for col in columns if col in values_by_column]
    if not insert_cols:
        print("WARN: staging.stg_api_payloads exists but no compatible columns were detected.")
        return None

    placeholders = ", ".join(["%s"] * len(insert_cols))
    sql = f"INSERT INTO {schema}.{table} ({', '.join(insert_cols)}) VALUES ({placeholders})"
    returning_id = "id" in columns
    if returning_id:
        sql += " RETURNING id"

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, [values_by_column[col] for col in insert_cols])
            inserted_id = cur.fetchone()[0] if returning_id else None
        conn.commit()
    return inserted_id


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Fetch API-Hockey players payload into staging.stg_api_payloads.")
    parser.add_argument("--team-id", dest="team_id")
    parser.add_argument("--league-id", dest="league_id")
    parser.add_argument("--season")
    parser.add_argument("--run-id", dest="run_id", type=int)
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL)
    parser.add_argument("--timeout-sec", type=int, default=60)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    api_key = detect_api_key()
    headers = {
        "x-apisports-key": api_key,
        "Accept": "application/json",
    }

    print("=== MATCHMATRIX: HK PLAYERS FETCH ===")
    print(f"provider={DEFAULT_PROVIDER} sport={DEFAULT_SPORT_CODE} entity={DEFAULT_ENTITY}")
    print(f"team_id={args.team_id} league_id={args.league_id} season={args.season} run_id={args.run_id}")

    result = choose_request(
        base_url=args.base_url,
        headers=headers,
        team_id=args.team_id,
        league_id=args.league_id,
        season=args.season,
        timeout_sec=args.timeout_sec,
    )

    payload_id = insert_payload_to_staging(
        result=result,
        run_id=args.run_id,
        team_id=args.team_id,
        league_id=args.league_id,
        season=args.season,
    )

    print(f"URL: {result.url}")
    print(f"endpoint={result.endpoint} results={result.payload.get('results')}")
    print(f"raw_file={result.raw_path}")
    print(f"staging_payload_id={payload_id}")

    if is_endpoint_missing(result.payload):
        print("ERROR: endpoint returned 'do not exist'.")
        return 2
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except requests.HTTPError as exc:
        print(f"HTTP ERROR: {exc}")
        raise
    except Exception as exc:
        print(f"FATAL: {exc}")
        raise
