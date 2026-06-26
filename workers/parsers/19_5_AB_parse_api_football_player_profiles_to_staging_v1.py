# ============================================================================
# MATCHMATRIX 19_5_AB
# parse_api_football_player_profiles_to_staging_v1.py
#
# CO TO JE:
#   Parser raw payloadů API-Football player profiles.
#
# K ČEMU TO JE:
#   Vezme data ze staging.stg_api_payloads a převede je do
#   staging.stg_provider_player_profiles.
#
# KDE TO UVIDÍME:
#   staging.stg_provider_player_profiles
#
# JAK SE TO VYUŽIJE:
#   Doplní profilovou vrstvu hráčů před Photo Layer 2.0.
#   Zlepší identitu hráčů, týmový kontext, pozice, fotky, výšku a váhu.
# ============================================================================

import os
import sys
import json
from pathlib import Path
from typing import Any, Optional

import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv


ENV_PATH = Path(r"C:\MatchMatrix-platform\.env")
load_dotenv(dotenv_path=ENV_PATH)


DB = {
    "host": os.getenv("PGHOST"),
    "port": int(os.getenv("PGPORT", "5432")),
    "dbname": os.getenv("PGDATABASE"),
    "user": os.getenv("PGUSER"),
    "password": os.getenv("PGPASSWORD"),
}


LIMIT_DEFAULT = 500


def db_connect():
    return psycopg2.connect(**DB)


def clean_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    value = str(value).strip()
    return value if value else None


def to_int(value: Any) -> Optional[int]:
    if value is None or value == "":
        return None
    try:
        return int(value)
    except Exception:
        return None


def parse_height_cm(value: Any) -> Optional[int]:
    if not value:
        return None
    text = str(value).lower().replace("cm", "").strip()
    return to_int(text)


def parse_weight_kg(value: Any) -> Optional[int]:
    if not value:
        return None
    text = str(value).lower().replace("kg", "").strip()
    return to_int(text)


def fetch_pending_payloads(conn, limit: int):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                id,
                external_id,
                payload_json
            FROM staging.stg_api_payloads
            WHERE provider = 'api_football'
              AND entity_type = 'player_profiles'
              AND endpoint_name = 'players'
              AND COALESCE(parse_status, 'pending') = 'pending'
            ORDER BY fetched_at ASC, id ASC
            LIMIT %s
            """,
            (limit,),
        )
        return cur.fetchall()


def upsert_profile(conn, payload_id: int, external_id: str, item: dict):
    player = item.get("player") or {}
    statistics = item.get("statistics") or []

    stat0 = statistics[0] if statistics else {}
    team = stat0.get("team") or {}
    league = stat0.get("league") or {}
    games = stat0.get("games") or {}

    provider = "api_football"
    sport_code = "FB"

    external_player_id = clean_text(player.get("id") or external_id)

    player_name = clean_text(player.get("name"))
    first_name = clean_text(player.get("firstname"))
    last_name = clean_text(player.get("lastname"))
    display_name = player_name
    short_name = player_name

    birth = player.get("birth") or {}

    birth_date = clean_text(birth.get("date"))
    birth_place = clean_text(birth.get("place"))
    birth_country = clean_text(birth.get("country"))

    nationality = clean_text(player.get("nationality"))
    height_cm = parse_height_cm(player.get("height"))
    weight_kg = parse_weight_kg(player.get("weight"))

    preferred_foot = None
    shirt_number = None

    position_name = clean_text(games.get("position"))
    position_code = position_name

    photo_url = clean_text(player.get("photo"))
    is_injured = player.get("injured")
    if is_injured is None:
        is_injured = False

    is_active = True

    external_team_id = clean_text(team.get("id"))
    team_name = clean_text(team.get("name"))

    external_league_id = clean_text(league.get("id"))
    league_name = clean_text(league.get("name"))
    season = clean_text(league.get("season"))

    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO staging.stg_provider_player_profiles (
                provider,
                sport_code,
                external_player_id,
                player_name,
                first_name,
                last_name,
                display_name,
                short_name,
                birth_date,
                birth_place,
                birth_country,
                nationality,
                height_cm,
                weight_kg,
                preferred_foot,
                shirt_number,
                position_code,
                position_name,
                photo_url,
                is_injured,
                is_active,
                external_team_id,
                team_name,
                external_league_id,
                league_name,
                season,
                source_endpoint,
                created_at,
                updated_at
            )
            VALUES (
                %s,%s,%s,%s,%s,%s,%s,%s,
                %s::date,%s,%s,%s,%s,%s,%s,
                %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
                %s,%s,NOW(),NOW()
            )
            ON CONFLICT DO NOTHING
            """,
            (
                provider,
                sport_code,
                external_player_id,
                player_name,
                first_name,
                last_name,
                display_name,
                short_name,
                birth_date,
                birth_place,
                birth_country,
                nationality,
                height_cm,
                weight_kg,
                preferred_foot,
                shirt_number,
                position_code,
                position_name,
                photo_url,
                is_injured,
                is_active,
                external_team_id,
                team_name,
                external_league_id,
                league_name,
                season,
                "players",
            ),
        )


def mark_payload(conn, payload_id: int, status: str, note: str = ""):
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET
                parse_status = %s
            WHERE id = %s
            """,
            (status, payload_id),
        )


def parse_payload(payload_json: Any) -> dict:
    if isinstance(payload_json, dict):
        return payload_json
    if isinstance(payload_json, str):
        return json.loads(payload_json)
    return dict(payload_json)


def main():
    limit = LIMIT_DEFAULT

    if len(sys.argv) >= 2:
        limit = int(sys.argv[1])

    print("=" * 80)
    print("MATCHMATRIX 19_5_AB - PARSE API-FOOTBALL PLAYER PROFILES TO STAGING")
    print("=" * 80)
    print(f"LIMIT: {limit}")

    conn = db_connect()

    processed = 0
    inserted_items = 0
    empty_payloads = 0
    errors = 0

    try:
        rows = fetch_pending_payloads(conn, limit)
        print(f"PENDING PAYLOADS: {len(rows)}")

        for payload_id, external_id, payload_json in rows:
            try:
                payload = parse_payload(payload_json)
                response_items = payload.get("response") or []

                if not response_items:
                    empty_payloads += 1
                    mark_payload(conn, payload_id, "empty", "No response items")
                    conn.commit()
                    continue

                for item in response_items:
                    upsert_profile(conn, payload_id, str(external_id), item)
                    inserted_items += 1

                mark_payload(conn, payload_id, "parsed")
                conn.commit()
                processed += 1

            except Exception as e:
                conn.rollback()
                errors += 1
                mark_payload(conn, payload_id, "error", str(e))
                conn.commit()
                print(f"ERROR payload_id={payload_id} external_id={external_id}: {e}")

        print("-" * 80)
        print("SUMMARY")
        print(f"processed_payloads : {processed}")
        print(f"inserted_items     : {inserted_items}")
        print(f"empty_payloads     : {empty_payloads}")
        print(f"errors             : {errors}")
        print("DONE")

    finally:
        conn.close()


if __name__ == "__main__":
    main()