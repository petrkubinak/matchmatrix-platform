# -*- coding: utf-8 -*-
"""
MATCHMATRIX WORKER
pull_api_cricket_squad_players_v1.py

CO TO JE:
- Stáhne hráče pro každý cricket squad z Cricbuzz RapidAPI.

K ČEMU TO JE:
- Navazuje na payload series_v1_squads.
- Z každého squadId stáhne detail /series/v1/{series_id}/squads/{squad_id}.
- Uloží RAW hráče do staging.stg_api_payloads.

KDE TO UVIDÍME:
- staging.stg_api_payloads
- provider = api_cricket
- sport_code = CK
- entity_type = players
- endpoint_name = series_v1_squad_players

JAK SE TO VYUŽIJE:
- Další parser převede hráče do staging.stg_provider_players.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import time
from typing import Any, Dict, List

import psycopg2
import requests
from dotenv import load_dotenv
from psycopg2.extras import Json, RealDictCursor


BASE_DIR = r"C:\MatchMatrix-platform"
ENV_PATH = os.path.join(BASE_DIR, "ingest", "API-Cricket", ".env")

PROVIDER = "api_cricket"
SPORT_CODE = "CK"
ENTITY_TYPE = "players"
SOURCE_ENDPOINT = "series_v1_squads"
TARGET_ENDPOINT = "series_v1_squad_players"


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


def payload_hash(payload: Dict[str, Any]) -> str:
    raw = json.dumps(payload, ensure_ascii=False, sort_keys=True).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def get_required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing required ENV variable: {name}")
    return value


def fetch_source_squads_payload(conn, payload_id: int | None) -> Dict[str, Any] | None:
    sql = """
        SELECT
            id,
            external_id,
            season,
            payload_json
        FROM staging.stg_api_payloads
        WHERE provider = %s
          AND sport_code = %s
          AND entity_type = %s
          AND endpoint_name = %s
          AND parse_status = 'pending'
    """

    params = [PROVIDER, SPORT_CODE, ENTITY_TYPE, SOURCE_ENDPOINT]

    if payload_id:
        sql += " AND id = %s"
        params.append(payload_id)

    sql += " ORDER BY id DESC LIMIT 1"

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, params)
        return cur.fetchone()


def extract_squads(source_row: Dict[str, Any]) -> List[Dict[str, Any]]:
    payload = source_row["payload_json"]
    response = payload.get("response") or {}

    series_id = str(response.get("seriesId") or payload.get("series_id") or source_row["external_id"])
    series_name = response.get("seriesName")
    season = source_row["season"]

    squads = []

    for item in response.get("squads", []):
        if item.get("isHeader"):
            continue

        squad_id = item.get("squadId")
        team_id = item.get("teamId")
        squad_name = item.get("squadType")

        if not squad_id:
            continue

        squads.append({
            "series_id": str(series_id),
            "series_name": series_name,
            "season": season,
            "squad_id": str(squad_id),
            "team_id": str(team_id) if team_id is not None else None,
            "squad_name": squad_name,
            "image_id": item.get("imageId"),
            "source_payload_id": source_row["id"],
        })

    return squads


def fetch_squad_players(series_id: str, squad_id: str) -> Dict[str, Any]:
    base = os.getenv("RAPIDAPI_CRICKET_BASE", "https://cricbuzz-cricket.p.rapidapi.com").rstrip("/")
    host = os.getenv("RAPIDAPI_CRICKET_HOST", "cricbuzz-cricket.p.rapidapi.com")
    key = get_required_env("RAPIDAPI_KEY")

    path = f"/series/v1/{series_id}/squads/{squad_id}"
    url = base + path

    headers = {
        "x-rapidapi-key": key,
        "x-rapidapi-host": host,
        "Content-Type": "application/json",
    }

    response = requests.get(url, headers=headers, timeout=60)

    payload = {
        "request_url": response.url,
        "status_code": response.status_code,
        "series_id": series_id,
        "squad_id": squad_id,
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


def insert_raw_payload(conn, squad: Dict[str, Any], payload: Dict[str, Any]) -> int:
    wrapped_payload = {
        "series_id": squad["series_id"],
        "series_name": squad["series_name"],
        "season": squad["season"],
        "team_id": squad["team_id"],
        "squad_id": squad["squad_id"],
        "squad_name": squad["squad_name"],
        "source_payload_id": squad["source_payload_id"],
        "payload": payload,
    }

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
                TARGET_ENDPOINT,
                squad["squad_id"],
                squad["season"],
                Json(wrapped_payload),
                payload_hash(wrapped_payload),
                "CK squad players raw payload downloaded",
            ),
        )
        return cur.fetchone()[0]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--payload-id", type=int, default=None)
    parser.add_argument("--limit", type=int, default=20)
    parser.add_argument("--sleep-sec", type=float, default=0.5)
    args = parser.parse_args()

    load_environment()

    print("=" * 80)
    print("MATCHMATRIX CK SQUAD PLAYERS DOWNLOADER V1")
    print("=" * 80)

    conn = None
    inserted_total = 0

    try:
        conn = get_db_connection()
        conn.autocommit = False

        source = fetch_source_squads_payload(conn, args.payload_id)

        if not source:
            print("Nenalezen pending payload series_v1_squads.")
            return 0

        squads = extract_squads(source)
        print(f"SOURCE PAYLOAD ID: {source['id']}")
        print(f"SQUADS FOUND     : {len(squads)}")

        for squad in squads[:args.limit]:
            print("-" * 80)
            print(f"SQUAD: {squad['squad_name']} | squad_id={squad['squad_id']} | team_id={squad['team_id']}")

            try:
                payload = fetch_squad_players(squad["series_id"], squad["squad_id"])
                payload_id = insert_raw_payload(conn, squad, payload)
                conn.commit()

                inserted_total += 1
                print(f"RAW SAVED: payload_id={payload_id}")

                time.sleep(args.sleep_sec)

            except Exception as exc:
                conn.rollback()
                print(f"ERROR squad_id={squad['squad_id']} | {type(exc).__name__}: {exc}")

        print("=" * 80)
        print(f"DONE | INSERTED PAYLOADS: {inserted_total}")
        print("=" * 80)
        return 0

    except Exception as exc:
        if conn:
            conn.rollback()
        print(f"FATAL ERROR: {type(exc).__name__}: {exc}")
        return 1

    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())