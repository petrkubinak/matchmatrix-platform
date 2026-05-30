"""
MATCHMATRIX BK PLAYERS PARSER TO STAGING V1

Co to je:
- Python parser pro API-Sport Basketball players RAW payloady.

K čemu to je:
- Převádí staging.stg_api_payloads -> staging.stg_provider_players.

Kde se výsledek projeví:
- staging.stg_provider_players

Jak se využije na webu:
- Basketbaloví hráči budou použiti pro player pages, statistiky,
  team rosters, AI modely a media matching.
"""

import os
import sys
import argparse
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

BASE_DIR = r"C:\MatchMatrix-platform"
load_dotenv(os.path.join(BASE_DIR, ".env"))


def get_conn():
    return psycopg2.connect(os.getenv("DATABASE_URL"))


def find_payloads(conn, limit: int):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id
            FROM staging.stg_api_payloads
            WHERE provider = 'api_sport'
              AND sport_code IN ('BK', 'basketball')
              AND entity_type = 'players'
              AND endpoint_name = 'players'
              AND COALESCE(parse_status, 'pending') <> 'parsed'
            ORDER BY id DESC
            LIMIT %s
            """,
            (limit,),
        )
        return [r["id"] for r in cur.fetchall()]


def parse_payload(conn, raw_payload_id: int) -> int:
    sql = """
    WITH players AS (
        SELECT
            p.id AS raw_payload_id,
            jsonb_array_elements(p.payload_json -> 'response') AS player
        FROM staging.stg_api_payloads p
        WHERE p.id = %s
          AND p.provider = 'api_sport'
          AND p.sport_code IN ('BK', 'basketball')
          AND p.entity_type = 'players'
          AND p.endpoint_name = 'players'
          AND jsonb_typeof(p.payload_json -> 'response') = 'array'
    ),
    normalized AS (
        SELECT
            'api_sport'::text AS provider,
            'BK'::text AS sport_code,

            player ->> 'id' AS external_player_id,

            NULLIF(TRIM(
                COALESCE(player ->> 'firstname', '') || ' ' ||
                COALESCE(player ->> 'lastname', '')
            ), '') AS player_name,

            player ->> 'firstname' AS first_name,
            player ->> 'lastname' AS last_name,
            player ->> 'short_name' AS short_name,

            NULLIF(player ->> 'birthdate', '')::date AS birth_date,

            COALESCE(
                player #>> '{country,name}',
                player ->> 'nationality'
            ) AS nationality,

            player #>> '{team,id}' AS external_team_id,
            player #>> '{team,name}' AS team_name,

            player #>> '{league,id}' AS external_league_id,
            player #>> '{league,name}' AS league_name,

            NULLIF(player ->> 'season', '') AS season,

            player ->> 'position' AS position_code,

            raw_payload_id,
            TRUE AS is_active,
            'players'::text AS source_endpoint

        FROM players
        WHERE player ->> 'id' IS NOT NULL
    ),
    updated AS (
        UPDATE staging.stg_provider_players p
        SET
            sport_code = n.sport_code,
            player_name = COALESCE(n.player_name, p.player_name),
            first_name = n.first_name,
            last_name = n.last_name,
            short_name = n.short_name,
            birth_date = n.birth_date,
            nationality = n.nationality,
            external_team_id = n.external_team_id,
            team_name = n.team_name,
            external_league_id = n.external_league_id,
            league_name = n.league_name,
            season = n.season,
            position_code = n.position_code,
            raw_payload_id = n.raw_payload_id,
            is_active = n.is_active,
            source_endpoint = n.source_endpoint,
            updated_at = NOW()
        FROM normalized n
        WHERE p.provider = n.provider
          AND p.external_player_id = n.external_player_id
        RETURNING p.external_player_id
    ),
    inserted AS (
        INSERT INTO staging.stg_provider_players (
            provider,
            sport_code,
            external_player_id,
            player_name,
            birth_date,
            nationality,
            external_team_id,
            season,
            raw_payload_id,
            is_active,
            created_at,
            updated_at,
            first_name,
            last_name,
            short_name,
            position_code,
            external_league_id,
            team_name,
            league_name,
            source_endpoint
        )
        SELECT
            n.provider,
            n.sport_code,
            n.external_player_id,
            n.player_name,
            n.birth_date,
            n.nationality,
            n.external_team_id,
            n.season,
            n.raw_payload_id,
            n.is_active,
            NOW(),
            NOW(),
            n.first_name,
            n.last_name,
            n.short_name,
            n.position_code,
            n.external_league_id,
            n.team_name,
            n.league_name,
            n.source_endpoint
        FROM normalized n
        WHERE NOT EXISTS (
            SELECT 1
            FROM staging.stg_provider_players p
            WHERE p.provider = n.provider
              AND p.external_player_id = n.external_player_id
        )
        RETURNING external_player_id
    )
    SELECT
        (SELECT COUNT(*) FROM updated) +
        (SELECT COUNT(*) FROM inserted) AS affected_rows;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (raw_payload_id,))
        affected = cur.fetchone()["affected_rows"]

        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET parse_status = 'parsed',
                parse_message = 'BK players parsed to staging.stg_provider_players'
            WHERE id = %s
            """,
            (raw_payload_id,),
        )

    return affected


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw-payload-id", type=int, default=None)
    parser.add_argument("--limit", type=int, default=10)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX BK PLAYERS PARSER V1")
    print("=" * 80)

    conn = get_conn()

    try:
        payload_ids = (
            [args.raw_payload_id]
            if args.raw_payload_id
            else find_payloads(conn, args.limit)
        )

        if not payload_ids:
            print("NO PENDING BK PLAYER PAYLOADS")
            return 0

        total = 0

        for payload_id in payload_ids:
            affected = parse_payload(conn, payload_id)
            conn.commit()
            total += affected
            print(f"RAW PAYLOAD {payload_id}: affected rows = {affected}")

        print("=" * 80)
        print(f"DONE | TOTAL AFFECTED ROWS: {total}")
        return 0

    except Exception as e:
        conn.rollback()
        print(f"ERROR: {e}")
        return 1

    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())