# ==========================================================
# MATCHMATRIX
# PLAYERS IMPORT -> UNIFIED STAGING PLAYERS
# ==========================================================

import psycopg2

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

print("=== PLAYERS IMPORT -> UNIFIED STAGING ===")

sql = """
INSERT INTO staging.stg_provider_players
(
    provider,
    sport_code,
    external_player_id,
    player_name,
    birth_date,
    nationality,
    external_team_id,
    season
)
SELECT DISTINCT
    pi.provider_code,
    'football' AS sport_code,
    pi.provider_player_id,
    pi.player_name,
    pi.birth_date,
    pi.nationality,
    pi.team_provider_id,
    pi.season
FROM staging.players_import pi
WHERE pi.provider_player_id IS NOT NULL
ON CONFLICT (provider, external_player_id)
DO UPDATE SET
    player_name = EXCLUDED.player_name,
    birth_date = EXCLUDED.birth_date,
    nationality = EXCLUDED.nationality,
    external_team_id = EXCLUDED.external_team_id,
    season = EXCLUDED.season,
    updated_at = now();
"""


def main() -> None:
    with psycopg2.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()

    print("Hotovo.")


if __name__ == "__main__":
    main()