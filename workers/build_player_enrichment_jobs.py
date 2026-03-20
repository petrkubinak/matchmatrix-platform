import os
from contextlib import closing
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv


ENV_PATH = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=ENV_PATH)


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
    print("=== MATCHMATRIX: BUILD PLAYER ENRICHMENT JOBS ===")

    with closing(get_db_connection()) as conn:
        conn.autocommit = False

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                """
                INSERT INTO ops.player_enrichment_plan (
                    provider,
                    sport_code,
                    entity,
                    player_id,
                    source_provider,
                    source_external_player_id,
                    external_team_id,
                    external_league_id,
                    season,
                    run_group,
                    priority,
                    status,
                    attempts,
                    next_run
                )
                SELECT
                    'api_football_squads' AS provider,
                    'football' AS sport_code,
                    'player_profile' AS entity,
                    ppm.player_id,
                    ppm.provider AS source_provider,
                    ppm.provider_player_id AS source_external_player_id,
                    NULL,
                    NULL,
                    NULL,
                    'PLAYERS_ENRICHMENT_PREP' AS run_group,
                    20 AS priority,
                    'pending' AS status,
                    0 AS attempts,
                    NOW() AS next_run
                FROM public.player_provider_map ppm
                WHERE ppm.provider = 'api_football'
                  AND NOT EXISTS (
                      SELECT 1
                      FROM ops.player_enrichment_plan pep
                      WHERE pep.provider = 'api_football_squads'
                        AND pep.sport_code = 'football'
                        AND pep.entity = 'player_profile'
                        AND COALESCE(pep.source_provider, '') = COALESCE(ppm.provider, '')
                        AND COALESCE(pep.source_external_player_id, '') = COALESCE(ppm.provider_player_id, '')
                  );
                """
            )

            inserted = cur.rowcount
            conn.commit()

    print(f"Inserted enrichment jobs: {inserted}")
    print("Hotovo.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())