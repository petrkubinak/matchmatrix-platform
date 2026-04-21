# parse_api_tennis_fixtures_v1.py
# =========================================================
# Tennis fixtures parser
# RAW -> staging.api_tennis_fixtures
# Zdroj: tennisapi1 live events endpoint
# =========================================================

import os
import json
from datetime import datetime, timezone
import psycopg2
import psycopg2.extras
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


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def ts_to_dt(ts):
    if ts is None:
        return None
    try:
        return datetime.fromtimestamp(int(ts), tz=timezone.utc)
    except Exception:
        return None


def normalize_status(event):
    status = (event.get("status") or {})
    status_type = status.get("type")
    status_desc = status.get("description")

    if status_type and status_desc:
        return f"{status_type}:{status_desc}"
    if status_type:
        return status_type
    if status_desc:
        return status_desc
    return None


def extract_events(payload):
    if isinstance(payload, str):
        payload = json.loads(payload)

    if isinstance(payload, dict):
        if isinstance(payload.get("events"), list):
            return payload["events"]

    return []


def parse_event(event):
    provider_match_id = event.get("id")
    home = event.get("homeTeam") or {}
    away = event.get("awayTeam") or {}
    tournament = event.get("tournament") or {}
    unique_tournament = tournament.get("uniqueTournament") or {}

    league_name = (
        unique_tournament.get("name")
        or tournament.get("name")
        or (event.get("season") or {}).get("name")
    )

    return {
        "provider_match_id": None if provider_match_id is None else str(provider_match_id),
        "league_name": league_name,
        "player_1": home.get("name"),
        "player_2": away.get("name"),
        "match_time": ts_to_dt(event.get("startTimestamp")),
        "status": normalize_status(event),
        "raw_payload": event,
    }


def upsert_fixture(conn, run_id, row):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO staging.api_tennis_fixtures (
                run_id,
                provider,
                sport_code,
                provider_match_id,
                league_name,
                player_1,
                player_2,
                match_time,
                status,
                raw_payload
            )
            VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s::jsonb
            )
            ON CONFLICT (provider, sport_code, provider_match_id)
            DO UPDATE SET
                run_id = EXCLUDED.run_id,
                league_name = EXCLUDED.league_name,
                player_1 = EXCLUDED.player_1,
                player_2 = EXCLUDED.player_2,
                match_time = EXCLUDED.match_time,
                status = EXCLUDED.status,
                raw_payload = EXCLUDED.raw_payload,
                updated_at = now()
        """, (
            run_id,
            PROVIDER,
            SPORT_CODE,
            row["provider_match_id"],
            row["league_name"],
            row["player_1"],
            row["player_2"],
            row["match_time"],
            row["status"],
            json.dumps(row["raw_payload"])
        ))


def run(run_id):
    print("======================================")
    print("MATCHMATRIX TENNIS FIXTURES PARSER")
    print("======================================")
    print(f"RUN_ID: {run_id}")

    conn = get_connection()

    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute("""
                SELECT id, payload
                FROM staging.api_tennis_fixtures_raw
                WHERE run_id = %s
                ORDER BY id
            """, (run_id,))
            raw_rows = cur.fetchall()

        raw_count = len(raw_rows)
        parsed_count = 0

        for raw_row in raw_rows:
            events = extract_events(raw_row["payload"])

            for event in events:
                row = parse_event(event)

                # bez provider_match_id fixture nebereme
                if not row["provider_match_id"]:
                    continue

                upsert_fixture(conn, run_id, row)
                parsed_count += 1

        conn.commit()

        print(f"RAW ROWS       : {raw_count}")
        print(f"PARSED UPSERTS : {parsed_count}")
        print("DONE")

    finally:
        conn.close()


if __name__ == "__main__":
    run(1776783947)