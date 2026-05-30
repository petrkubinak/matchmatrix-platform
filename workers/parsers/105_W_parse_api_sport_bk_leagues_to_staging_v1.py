"""
MATCHMATRIX BK LEAGUES PARSER TO STAGING V1

Co to je:
- Python parser pro API-Sport Basketball leagues RAW payloady.

K čemu to je:
- Převádí staging.stg_api_payloads -> staging.stg_provider_leagues.

Kde se výsledek projeví:
- staging.stg_provider_leagues

Jak se využije na webu:
- Basketbalové ligy budou základ pro stránky lig, zápasy, standings,
  team power, media linking a AI výpočty.
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
    database_url = os.getenv("DATABASE_URL")
    if database_url:
        return psycopg2.connect(database_url)

    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    )


def find_payloads(conn, limit: int):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id
            FROM staging.stg_api_payloads
            WHERE provider = 'api_sport'
              AND sport_code IN ('BK', 'basketball')
              AND entity_type = 'leagues'
              AND endpoint_name = 'leagues'
              AND COALESCE(parse_status, 'pending') <> 'parsed'
            ORDER BY id DESC
            LIMIT %s
            """,
            (limit,),
        )
        return [row["id"] for row in cur.fetchall()]


def parse_payload(conn, raw_payload_id: int) -> int:
    sql = """
    WITH leagues AS (
        SELECT
            p.id AS raw_payload_id,
            jsonb_array_elements(p.payload_json -> 'response') AS league
        FROM staging.stg_api_payloads p
        WHERE p.id = %s
          AND p.provider = 'api_sport'
          AND p.sport_code IN ('BK', 'basketball')
          AND p.entity_type = 'leagues'
          AND p.endpoint_name = 'leagues'
          AND jsonb_typeof(p.payload_json -> 'response') = 'array'
    ),
    normalized AS (
        SELECT
            'api_sport'::text AS provider,
            'BK'::text AS sport_code,
            league ->> 'id' AS external_league_id,
            league ->> 'name' AS league_name,
            league #>> '{country,name}' AS country_name,
            NULLIF(league ->> 'season', '') AS season,
            raw_payload_id,
            TRUE AS is_active
        FROM leagues
        WHERE league ->> 'id' IS NOT NULL
    ),
    updated AS (
        UPDATE staging.stg_provider_leagues l
        SET
            sport_code = n.sport_code,
            league_name = n.league_name,
            country_name = n.country_name,
            season = n.season,
            raw_payload_id = n.raw_payload_id,
            is_active = n.is_active,
            updated_at = NOW()
        FROM normalized n
        WHERE l.provider = n.provider
          AND l.external_league_id = n.external_league_id
        RETURNING l.external_league_id
    ),
    inserted AS (
        INSERT INTO staging.stg_provider_leagues (
            provider,
            sport_code,
            external_league_id,
            league_name,
            country_name,
            season,
            raw_payload_id,
            is_active,
            created_at,
            updated_at
        )
        SELECT
            n.provider,
            n.sport_code,
            n.external_league_id,
            n.league_name,
            n.country_name,
            n.season,
            n.raw_payload_id,
            n.is_active,
            NOW(),
            NOW()
        FROM normalized n
        WHERE NOT EXISTS (
            SELECT 1
            FROM staging.stg_provider_leagues l
            WHERE l.provider = n.provider
              AND l.external_league_id = n.external_league_id
        )
        RETURNING external_league_id
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
            SET
                parse_status = 'parsed',
                parse_message = 'BK leagues parsed to staging.stg_provider_leagues'
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
    print("MATCHMATRIX BK LEAGUES PARSER V1")
    print("=" * 80)

    conn = get_conn()

    try:
        payload_ids = (
            [args.raw_payload_id]
            if args.raw_payload_id
            else find_payloads(conn, args.limit)
        )

        if not payload_ids:
            print("NO PENDING BK LEAGUES PAYLOADS")
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