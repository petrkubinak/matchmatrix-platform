# ============================================================
# MatchMatrix
# PLAYER SEASON STATISTICS STAGE PARSER V1
#
# Source:
#   staging.stg_api_payloads
#
# Target:
#   staging.stg_provider_player_season_stats
#
# Filters:
#   provider = api_football
#   entity_type = players
#   endpoint_name = players
# ============================================================

import os
from contextlib import closing
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


ENV_PATH = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=ENV_PATH)

PROVIDER = "api_football"
SPORT_CODE = "football"
ENTITY_TYPE = "players"
ENDPOINT_NAME = "players"


def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", ""),
    )
    conn.set_client_encoding("UTF8")
    return conn


def fetch_payloads(cur):
    cur.execute(
        """
        SELECT
            id,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            payload_json
        FROM staging.stg_api_payloads
        WHERE provider = %s
          AND entity_type = %s
          AND endpoint_name = %s
        ORDER BY id
        """,
        (PROVIDER, ENTITY_TYPE, ENDPOINT_NAME),
    )
    return cur.fetchall()


def safe_get(dct, *keys, default=None):
    cur = dct
    for key in keys:
        if not isinstance(cur, dict):
            return default
        cur = cur.get(key)
        if cur is None:
            return default
    return cur


def emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
              player_external_id, team_external_id, source_endpoint, stat_name, stat_value):
    if player_external_id is None:
        return

    rows_to_insert.append(
        (
            provider,
            SPORT_CODE,
            None if external_league_id is None else str(external_league_id),
            None if season is None else str(season),
            str(player_external_id),
            None if team_external_id is None else str(team_external_id),
            stat_name,
            None if stat_value is None else str(stat_value),
            payload_id,
            source_endpoint,
        )
    )


def parse_one_payload(payload_row):
    payload_id = payload_row["id"]
    provider = payload_row["provider"]
    payload = payload_row["payload_json"]

    rows_to_insert = []

    if not isinstance(payload, dict):
        return rows_to_insert

    if payload.get("errors"):
        return rows_to_insert

    response = payload.get("response", [])
    if not isinstance(response, list):
        return rows_to_insert

    for item in response:
        if not isinstance(item, dict):
            continue

        player = item.get("player", {}) or {}
        statistics = item.get("statistics", []) or []

        player_external_id = player.get("id")
        if player_external_id is None:
            continue

        for stat in statistics:
            if not isinstance(stat, dict):
                continue

            team_external_id = safe_get(stat, "team", "id")
            external_league_id = safe_get(stat, "league", "id")
            season = safe_get(stat, "league", "season")
            source_endpoint = ENDPOINT_NAME

            games = stat.get("games", {}) or {}
            substitutes = stat.get("substitutes", {}) or {}
            shots = stat.get("shots", {}) or {}
            goals = stat.get("goals", {}) or {}
            passes = stat.get("passes", {}) or {}
            tackles = stat.get("tackles", {}) or {}
            duels = stat.get("duels", {}) or {}
            dribbles = stat.get("dribbles", {}) or {}
            fouls = stat.get("fouls", {}) or {}
            cards = stat.get("cards", {}) or {}
            penalty = stat.get("penalty", {}) or {}

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "appearances", games.get("appearences"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "lineups", games.get("lineups"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "minutes_played", games.get("minutes"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "rating", games.get("rating"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "shots_total", shots.get("total"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "shots_on_target", shots.get("on"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "goals", goals.get("total"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "assists", goals.get("assists"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "saves", goals.get("saves"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "passes_total", passes.get("total"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "passes_key", passes.get("key"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "passes_accuracy", passes.get("accuracy"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "tackles_total", tackles.get("total"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "tackles_blocks", tackles.get("blocks"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "tackles_interceptions", tackles.get("interceptions"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "duels_total", duels.get("total"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "duels_won", duels.get("won"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "dribbles_attempts", dribbles.get("attempts"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "dribbles_success", dribbles.get("success"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "fouls_drawn", fouls.get("drawn"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "fouls_committed", fouls.get("committed"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "yellow_cards", cards.get("yellow"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "red_cards", cards.get("red"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "penalty_won", penalty.get("won"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "penalty_committed", penalty.get("commited"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "penalty_scored", penalty.get("scored"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "penalty_missed", penalty.get("missed"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "penalty_saved", penalty.get("saved"))

            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "substitute_in", substitutes.get("in"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "substitute_out", substitutes.get("out"))
            emit_stat(rows_to_insert, payload_id, provider, external_league_id, season,
                      player_external_id, team_external_id, source_endpoint, "substitute_bench", substitutes.get("bench"))

    return rows_to_insert


def delete_existing_rows_for_payload(cur, payload_id):
    cur.execute(
        """
        DELETE FROM staging.stg_provider_player_season_stats
        WHERE raw_payload_id = %s
        """,
        (payload_id,),
    )


def bulk_insert_rows(cur, rows):
    if not rows:
        return 0

    cur.executemany(
        """
        INSERT INTO staging.stg_provider_player_season_stats
        (
            provider,
            sport_code,
            external_league_id,
            season,
            player_external_id,
            team_external_id,
            stat_name,
            stat_value,
            raw_payload_id,
            source_endpoint
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
        rows,
    )
    return len(rows)


def main():
    print("=== MATCHMATRIX: PLAYER SEASON STATISTICS STAGE PARSER V1 ===")
    print("Zdroj : staging.stg_api_payloads")
    print("Cíl   : staging.stg_provider_player_season_stats")
    print()

    processed_payloads = 0
    inserted_rows = 0

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/5] Nastavuji timeouty...")
                cur.execute("SET lock_timeout = '5s';")
                cur.execute("SET statement_timeout = '10min';")
                print("      OK")

                print("[2/5] Načítám payloady...")
                payloads = fetch_payloads(cur)
                print(f"      payloads found: {len(payloads)}")

                print("[3/5] Parsuji payloady...")
                for payload in payloads:
                    processed_payloads += 1
                    payload_id = payload["id"]

                    delete_existing_rows_for_payload(cur, payload_id)
                    rows = parse_one_payload(payload)
                    inserted_rows += bulk_insert_rows(cur, rows)

                print("      parsing OK")

                print("[4/5] COMMIT...")
                conn.commit()
                print("      COMMIT OK")

                print("[5/5] Kontrola...")
                cur.execute("SELECT COUNT(*) AS cnt FROM staging.stg_provider_player_season_stats;")
                stg_cnt = cur.fetchone()["cnt"]

                print(f"      staging.stg_provider_player_season_stats: {stg_cnt}")
                print()
                print("SUMMARY")
                print("--------------------------------------------------")
                print(f"processed payloads : {processed_payloads}")
                print(f"inserted rows      : {inserted_rows}")

        print()
        print("Hotovo.")
        return 0

    except psycopg2.Error as e:
        print()
        print("CHYBA PSYCOPG2:")
        print(str(e))
        return 1
    except Exception as e:
        print()
        print("CHYBA OBECNÁ:")
        print(str(e))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())