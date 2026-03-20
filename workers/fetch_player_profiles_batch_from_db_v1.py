# ============================================================================
# fetch_player_profiles_batch_from_db_v1.py
# Cíl:
#   Načíst player IDs z work.missing_player_profile_batches podle batch_no,
#   stáhnout profiles z API-Football
#   a uložit do staging.stg_api_payloads
#
# Spuštění:
#   python fetch_player_profiles_batch_from_db_v1.py 1
#   python fetch_player_profiles_batch_from_db_v1.py 2
#   ...
# ============================================================================

import os
import sys
import time
import json
from pathlib import Path

import psycopg2
import requests
from dotenv import load_dotenv


# =========================
# LOAD ENV
# =========================
ENV_PATH = Path(r"C:\MatchMatrix-platform\.env")
load_dotenv(dotenv_path=ENV_PATH)

API_KEY = os.getenv("APISPORTS_KEY")
BASE_URL = os.getenv("APISPORTS_BASE", "https://v3.football.api-sports.io")

DB = {
    "host": os.getenv("PGHOST"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE"),
    "user": os.getenv("PGUSER"),
    "password": os.getenv("PGPASSWORD"),
}

HEADERS = {
    "x-apisports-key": API_KEY
}


def validate_env() -> None:
    required = {
        "APISPORTS_KEY": API_KEY,
        "PGHOST": DB["host"],
        "PGDATABASE": DB["dbname"],
        "PGUSER": DB["user"],
        "PGPASSWORD": DB["password"],
    }
    missing = [k for k, v in required.items() if not v]
    if missing:
        raise RuntimeError(f"Chybí proměnné v .env: {', '.join(missing)}")


def get_batch_no() -> int:
    if len(sys.argv) < 2:
        raise RuntimeError(
            "Chybí batch_no. Spuštění: python fetch_player_profiles_batch_from_db_v1.py 1"
        )
    try:
        batch_no = int(sys.argv[1])
    except ValueError as e:
        raise RuntimeError("batch_no musí být celé číslo.") from e
    if batch_no <= 0:
        raise RuntimeError("batch_no musí být > 0.")
    return batch_no


def fetch_player_ids(conn, batch_no: int) -> list[int]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT player_external_id
            FROM work.missing_player_profile_batches
            WHERE provider = 'api_football'
              AND sport_code = 'football'
              AND batch_no = %s
            ORDER BY rn
            """,
            (batch_no,),
        )
        rows = cur.fetchall()

    player_ids: list[int] = []
    for row in rows:
        try:
            player_ids.append(int(row[0]))
        except (TypeError, ValueError):
            print(f"SKIP invalid player_external_id: {row[0]}")
    return player_ids


def insert_payload(conn, player_id: int, data: dict) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO staging.stg_api_payloads (
                provider,
                sport_code,
                entity_type,
                endpoint_name,
                external_id,
                payload_json,
                fetched_at,
                parse_status
            )
            VALUES (%s, %s, %s, %s, %s, %s::jsonb, NOW(), %s)
            """,
            (
                "api_football",
                "football",
                "player_profiles",
                "players",
                str(player_id),
                json.dumps(data, ensure_ascii=False),
                "pending",
            ),
        )


def main() -> None:
    validate_env()
    batch_no = get_batch_no()

    print("TEST DB CONNECT...")
    conn = psycopg2.connect(**DB)
    print("DB OK")

    try:
        player_ids = fetch_player_ids(conn, batch_no)
        print(f"BATCH NO: {batch_no}")
        print(f"PLAYER IDS IN BATCH: {len(player_ids)}")

        if not player_ids:
            print("Žádná player IDs pro tento batch.")
            return

        ok_count = 0
        error_count = 0

        for idx, pid in enumerate(player_ids, start=1):
            url = f"{BASE_URL}/players?id={pid}"
            print(f"[{idx}/{len(player_ids)}] Fetching player {pid}")

            try:
                response = requests.get(url, headers=HEADERS, timeout=60)
                response.raise_for_status()
                data = response.json()

                insert_payload(conn, pid, data)
                conn.commit()
                ok_count += 1

                # free plan limit ~ 10 req/min -> držíme bezpečný odstup
                time.sleep(6.5)

            except Exception as e:
                conn.rollback()
                error_count += 1
                print(f"ERROR for player {pid}: {e}")

        print("SUMMARY")
        print(f"Batch no       : {batch_no}")
        print(f"Total players  : {len(player_ids)}")
        print(f"Inserted       : {ok_count}")
        print(f"Errors         : {error_count}")
        print("DONE")

    finally:
        conn.close()


if __name__ == "__main__":
    main()