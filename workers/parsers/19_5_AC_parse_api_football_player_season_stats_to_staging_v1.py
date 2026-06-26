# ============================================================================
# MATCHMATRIX 19_5_AC
# parse_api_football_player_season_stats_to_staging_v1.py
#
# CO TO JE:
#   Parser sezónních statistik hráčů z API-Football payloadů.
#
# K ČEMU TO JE:
#   Zpracuje response[].statistics[] ze staging.stg_api_payloads
#   a uloží výkonové statistiky hráčů do staging.stg_provider_player_season_stats.
#
# KDE TO UVIDÍME:
#   staging.stg_provider_player_season_stats
#
# JAK SE TO VYUŽIJE:
#   Data budou sloužit pro Player Rating, Player Form, porovnání hráčů,
#   detail hráče na webu a později pro predikční modely.
# ============================================================================

import os
import sys
import json
from pathlib import Path
from typing import Any, Optional

import psycopg2
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

LIMIT_DEFAULT = 100


def db_connect():
    return psycopg2.connect(**DB)


def clean_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    value = str(value).strip()
    return value if value else None


def flatten_dict(data: dict, prefix: str = "") -> dict:
    """
    Převede vnořený JSON na ploché názvy statistik.
    Např. goals.total, games.minutes, cards.yellow.
    """
    result = {}

    for key, value in data.items():
        stat_key = f"{prefix}.{key}" if prefix else str(key)

        if isinstance(value, dict):
            result.update(flatten_dict(value, stat_key))
        elif isinstance(value, list):
            result[stat_key] = json.dumps(value, ensure_ascii=False)
        else:
            result[stat_key] = value

    return result


def fetch_payloads(conn, limit: int):
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
              AND parse_status IN ('done', 'parsed')
            ORDER BY fetched_at DESC, id DESC
            LIMIT %s
            """,
            (limit,),
        )
        return cur.fetchall()


def insert_stat(
    conn,
    provider: str,
    sport_code: str,
    external_league_id: Optional[str],
    season: Optional[str],
    player_external_id: Optional[str],
    team_external_id: Optional[str],
    stat_name: str,
    stat_value: Any,
    raw_payload_id: int,
    source_endpoint: str,
):
    if stat_value is None:
        return

    stat_value_text = clean_text(stat_value)
    if stat_value_text is None:
        return

    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO staging.stg_provider_player_season_stats (
                provider,
                sport_code,
                external_league_id,
                season,
                player_external_id,
                team_external_id,
                stat_name,
                stat_value,
                raw_payload_id,
                source_endpoint,
                created_at,
                updated_at
            )
            VALUES (
                %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NOW(),NOW()
            )
            """,
            (
                provider,
                sport_code,
                external_league_id,
                season,
                player_external_id,
                team_external_id,
                stat_name,
                stat_value_text,
                raw_payload_id,
                source_endpoint,
            ),
        )


def parse_payload(payload_json: Any) -> dict:
    if isinstance(payload_json, dict):
        return payload_json
    if isinstance(payload_json, str):
        return json.loads(payload_json)
    return dict(payload_json)


def parse_one_payload(conn, payload_id: int, external_id: str, payload_json: Any) -> int:
    payload = parse_payload(payload_json)
    response_items = payload.get("response") or []

    inserted = 0

    for item in response_items:
        player = item.get("player") or {}
        statistics = item.get("statistics") or []

        player_external_id = clean_text(player.get("id") or external_id)

        for stat_block in statistics:
            team = stat_block.get("team") or {}
            league = stat_block.get("league") or {}

            team_external_id = clean_text(team.get("id"))
            external_league_id = clean_text(league.get("id"))
            season = clean_text(league.get("season"))

            flat_stats = flatten_dict(stat_block)

            for stat_name, stat_value in flat_stats.items():
                if stat_name in (
                    "team.id",
                    "team.name",
                    "team.logo",
                    "league.id",
                    "league.name",
                    "league.country",
                    "league.logo",
                    "league.flag",
                    "league.season",
                ):
                    continue

                insert_stat(
                    conn=conn,
                    provider="api_football",
                    sport_code="FB",
                    external_league_id=external_league_id,
                    season=season,
                    player_external_id=player_external_id,
                    team_external_id=team_external_id,
                    stat_name=stat_name,
                    stat_value=stat_value,
                    raw_payload_id=payload_id,
                    source_endpoint="players",
                )
                inserted += 1

    return inserted


def main():
    limit = LIMIT_DEFAULT

    if len(sys.argv) >= 2:
        limit = int(sys.argv[1])

    print("=" * 80)
    print("MATCHMATRIX 19_5_AC - PARSE API-FOOTBALL PLAYER SEASON STATS TO STAGING")
    print("=" * 80)
    print(f"LIMIT: {limit}")

    conn = db_connect()

    processed_payloads = 0
    inserted_stats = 0
    empty_payloads = 0
    errors = 0

    try:
        rows = fetch_payloads(conn, limit)
        print(f"PAYLOADS TO PARSE: {len(rows)}")

        for payload_id, external_id, payload_json in rows:
            try:
                inserted = parse_one_payload(conn, payload_id, str(external_id), payload_json)

                if inserted == 0:
                    empty_payloads += 1
                else:
                    inserted_stats += inserted
                    processed_payloads += 1

                conn.commit()

            except Exception as e:
                conn.rollback()
                errors += 1
                print(f"ERROR payload_id={payload_id} external_id={external_id}: {e}")

        print("-" * 80)
        print("SUMMARY")
        print(f"processed_payloads : {processed_payloads}")
        print(f"inserted_stats     : {inserted_stats}")
        print(f"empty_payloads     : {empty_payloads}")
        print(f"errors             : {errors}")
        print("DONE")

    finally:
        conn.close()


if __name__ == "__main__":
    main()