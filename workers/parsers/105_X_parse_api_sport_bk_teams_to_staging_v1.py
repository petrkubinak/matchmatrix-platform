"""
MATCHMATRIX BK TEAMS PARSER TO STAGING V1
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
        cur.execute("""
            SELECT id
            FROM staging.stg_api_payloads
            WHERE provider = 'api_sport'
              AND sport_code IN ('BK', 'basketball')
              AND entity_type = 'teams'
              AND endpoint_name = 'teams'
              AND COALESCE(parse_status, 'pending') <> 'parsed'
            ORDER BY id DESC
            LIMIT %s
        """, (limit,))
        return [r["id"] for r in cur.fetchall()]


def parse_payload(conn, raw_payload_id: int) -> int:
    sql = """
    WITH teams AS (
        SELECT
            p.id AS raw_payload_id,
            jsonb_array_elements(p.payload_json -> 'response') AS team
        FROM staging.stg_api_payloads p
        WHERE p.id = %s
          AND p.provider = 'api_sport'
          AND p.sport_code IN ('BK', 'basketball')
          AND p.entity_type = 'teams'
          AND p.endpoint_name = 'teams'
          AND jsonb_typeof(p.payload_json -> 'response') = 'array'
    ),
    normalized AS (
        SELECT
            'api_sport'::text AS provider,
            'BK'::text AS sport_code,
            team ->> 'id' AS external_team_id,
            team ->> 'name' AS team_name,
            team #>> '{country,name}' AS country_name,
            team #>> '{league,id}' AS external_league_id,
            team #>> '{league,season}' AS season,
            raw_payload_id,
            TRUE AS is_active
        FROM teams
        WHERE team ->> 'id' IS NOT NULL
    ),
    updated AS (
        UPDATE staging.stg_provider_teams t
        SET
            sport_code = n.sport_code,
            team_name = n.team_name,
            country_name = n.country_name,
            external_league_id = n.external_league_id,
            season = n.season,
            raw_payload_id = n.raw_payload_id,
            is_active = n.is_active,
            updated_at = NOW()
        FROM normalized n
        WHERE t.provider = n.provider
          AND t.external_team_id = n.external_team_id
        RETURNING t.external_team_id
    ),
    inserted AS (
        INSERT INTO staging.stg_provider_teams (
            provider,
            sport_code,
            external_team_id,
            team_name,
            country_name,
            external_league_id,
            season,
            raw_payload_id,
            is_active,
            created_at,
            updated_at
        )
        SELECT
            provider,
            sport_code,
            external_team_id,
            team_name,
            country_name,
            external_league_id,
            season,
            raw_payload_id,
            is_active,
            NOW(),
            NOW()
        FROM normalized n
        WHERE NOT EXISTS (
            SELECT 1
            FROM staging.stg_provider_teams t
            WHERE t.provider = n.provider
              AND t.external_team_id = n.external_team_id
        )
        RETURNING external_team_id
    )
    SELECT
        (SELECT COUNT(*) FROM updated) +
        (SELECT COUNT(*) FROM inserted) AS affected_rows;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (raw_payload_id,))
        affected = cur.fetchone()["affected_rows"]

        cur.execute("""
            UPDATE staging.stg_api_payloads
            SET parse_status = 'parsed',
                parse_message = 'BK teams parsed to staging.stg_provider_teams'
            WHERE id = %s
        """, (raw_payload_id,))

    return affected


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw-payload-id", type=int, default=None)
    parser.add_argument("--limit", type=int, default=10)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX BK TEAMS PARSER V1")
    print("=" * 80)

    conn = get_conn()

    try:
        payload_ids = [args.raw_payload_id] if args.raw_payload_id else find_payloads(conn, args.limit)

        if not payload_ids:
            print("NO PENDING BK TEAM PAYLOADS")
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