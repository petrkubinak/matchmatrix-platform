import os
from contextlib import closing
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor, execute_values
from dotenv import load_dotenv


# ==========================================================
# LOAD .ENV
# ==========================================================

ENV_PATH = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=ENV_PATH)

SPORT_CODE = "football"


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


def main():
    print("=== MATCHMATRIX: PLAYERS BRIDGE V4 ===")
    print("Zdroj : staging.players_import")
    print("Cíl   : staging.stg_provider_players")
    print()

    try:
        with closing(get_db_connection()) as conn:
            conn.autocommit = False

            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                print("[1/6] Nastavuji timeouty...")
                cur.execute("SET lock_timeout = '5s';")
                cur.execute("SET statement_timeout = '10min';")
                print("      OK")

                print("[2/6] Kontrola zdroje...")
                cur.execute("SELECT COUNT(*) AS cnt FROM staging.players_import;")
                src_count = cur.fetchone()["cnt"]
                print(f"      staging.players_import: {src_count}")

                print("[3/6] Načítám deduplikovaný zdroj...")
                cur.execute(
                    """
                    SELECT
                        provider,
                        sport_code,
                        external_player_id,
                        player_name,
                        first_name,
                        last_name,
                        short_name,
                        birth_date,
                        nationality,
                        position_code,
                        height_cm,
                        weight_kg,
                        preferred_foot,
                        external_team_id,
                        external_league_id,
                        team_name,
                        league_name,
                        season,
                        raw_payload_id,
                        source_endpoint,
                        is_active
                    FROM (
                        SELECT
                            COALESCE(provider_code, 'api_football')::text AS provider,
                            %s::text AS sport_code,
                            provider_player_id::text AS external_player_id,
                            player_name::text AS player_name,
                            first_name::text AS first_name,
                            last_name::text AS last_name,
                            NULL::text AS short_name,
                            birth_date AS birth_date,
                            nationality::text AS nationality,
                            position_code::text AS position_code,
                            height_cm AS height_cm,
                            weight_kg AS weight_kg,
                            preferred_foot::text AS preferred_foot,
                            COALESCE(provider_team_id, team_provider_id)::text AS external_team_id,
                            provider_league_id::text AS external_league_id,
                            team_name::text AS team_name,
                            league_name::text AS league_name,
                            season::text AS season,
                            run_id::bigint AS raw_payload_id,
                            source_endpoint::text AS source_endpoint,
                            COALESCE(is_active, TRUE) AS is_active,
                            ROW_NUMBER() OVER (
                                PARTITION BY COALESCE(provider_code, 'api_football'), provider_player_id
                                ORDER BY
                                    CASE WHEN provider_league_id IS NOT NULL THEN 0 ELSE 1 END,
                                    CASE WHEN season IS NOT NULL THEN 0 ELSE 1 END,
                                    CASE WHEN source_endpoint = '/players' THEN 0 ELSE 1 END,
                                    CASE WHEN run_id IS NOT NULL THEN 0 ELSE 1 END,
                                    provider_player_id::text DESC
                            ) AS rn
                        FROM staging.players_import
                        WHERE provider_player_id IS NOT NULL
                    ) q
                    WHERE q.rn = 1
                    ORDER BY provider, external_player_id;
                    """,
                    (SPORT_CODE,),
                )

                rows = cur.fetchall()
                print(f"      načteno deduplikovaných řádků: {len(rows)}")

                if not rows:
                    print("[4/6] Zdroj je prázdný, rollback a konec.")
                    conn.rollback()
                    return 0

                data = []
                for r in rows:
                    data.append(
                        (
                            r["provider"],
                            r["sport_code"],
                            r["external_player_id"],
                            r["player_name"],
                            r["first_name"],
                            r["last_name"],
                            r["short_name"],
                            r["birth_date"],
                            r["nationality"],
                            r["position_code"],
                            r["height_cm"],
                            r["weight_kg"],
                            r["preferred_foot"],
                            r["external_team_id"],
                            r["external_league_id"],
                            r["team_name"],
                            r["league_name"],
                            r["season"],
                            r["raw_payload_id"],
                            r["source_endpoint"],
                            r["is_active"],
                        )
                    )

                print("[4/6] UPSERT do staging.stg_provider_players...")

                sql = """
                    INSERT INTO staging.stg_provider_players (
                        provider,
                        sport_code,
                        external_player_id,
                        player_name,
                        first_name,
                        last_name,
                        short_name,
                        birth_date,
                        nationality,
                        position_code,
                        height_cm,
                        weight_kg,
                        preferred_foot,
                        external_team_id,
                        external_league_id,
                        team_name,
                        league_name,
                        season,
                        raw_payload_id,
                        source_endpoint,
                        is_active
                    )
                    VALUES %s
                    ON CONFLICT (provider, external_player_id)
                    DO UPDATE SET
                        sport_code         = EXCLUDED.sport_code,
                        player_name        = EXCLUDED.player_name,
                        first_name         = EXCLUDED.first_name,
                        last_name          = EXCLUDED.last_name,
                        short_name         = EXCLUDED.short_name,
                        birth_date         = EXCLUDED.birth_date,
                        nationality        = EXCLUDED.nationality,
                        position_code      = EXCLUDED.position_code,
                        height_cm          = EXCLUDED.height_cm,
                        weight_kg          = EXCLUDED.weight_kg,
                        preferred_foot     = EXCLUDED.preferred_foot,
                        external_team_id   = EXCLUDED.external_team_id,
                        external_league_id = EXCLUDED.external_league_id,
                        team_name          = EXCLUDED.team_name,
                        league_name        = EXCLUDED.league_name,
                        season             = EXCLUDED.season,
                        raw_payload_id     = EXCLUDED.raw_payload_id,
                        source_endpoint    = EXCLUDED.source_endpoint,
                        is_active          = EXCLUDED.is_active,
                        updated_at         = NOW();
                """

                execute_values(cur, sql, data, page_size=500)
                print("      UPSERT OK")

                print("[5/6] COMMIT...")
                conn.commit()
                print("      COMMIT OK")

                print("[6/6] Kontrola cíle...")
                cur.execute("SELECT COUNT(*) AS cnt FROM staging.stg_provider_players;")
                target_count = cur.fetchone()["cnt"]
                print(f"      staging.stg_provider_players: {target_count}")

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