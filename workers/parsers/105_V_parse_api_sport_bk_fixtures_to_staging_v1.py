"""
MATCHMATRIX BK FIXTURES PARSER TO STAGING V1

Co to je:
- Python parser pro API-Sport Basketball fixtures/games RAW payloady.

K čemu to je:
- Nahrazuje SQL parser pro BK fixtures.
- Převádí staging.stg_api_payloads -> staging.stg_provider_fixtures.

Kde se výsledek projeví:
- staging.stg_provider_fixtures

Jak se využije na webu:
- BK zápasy budou mít správné datum, týmy, ligu, status a skóre.
- Následný merge aktualizuje public.matches pro výsledky, tabulky, team power a AI.
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


def parse_payload(conn, raw_payload_id: int) -> int:
    sql = """
    WITH games AS (
        SELECT
            p.id AS raw_payload_id,
            jsonb_array_elements(p.payload_json -> 'response') AS game
        FROM staging.stg_api_payloads p
        WHERE p.id = %s
          AND p.provider = 'api_sport'
          AND p.sport_code IN ('BK', 'basketball')
          AND p.entity_type = 'fixtures'
          AND p.endpoint_name IN ('games', 'fixtures')
          AND jsonb_typeof(p.payload_json -> 'response') = 'array'
    ),
    normalized AS (
        SELECT
            'api_sport'::text AS provider,
            'BK'::text AS sport_code,
            game ->> 'id' AS external_fixture_id,
            game #>> '{league,id}' AS external_league_id,
            game #>> '{league,season}' AS season,
            game #>> '{teams,home,id}' AS home_team_external_id,
            game #>> '{teams,away,id}' AS away_team_external_id,
            (game ->> 'date')::timestamptz AS fixture_date,
            game #>> '{status,short}' AS status_text,
            game #>> '{scores,home,total}' AS home_score,
            game #>> '{scores,away,total}' AS away_score,
            raw_payload_id
        FROM games
        WHERE game ->> 'id' IS NOT NULL
    ),
    updated AS (
        UPDATE staging.stg_provider_fixtures f
        SET
            sport_code = n.sport_code,
            external_league_id = n.external_league_id,
            season = n.season,
            home_team_external_id = n.home_team_external_id,
            away_team_external_id = n.away_team_external_id,
            fixture_date = n.fixture_date,
            status_text = n.status_text,
            home_score = n.home_score,
            away_score = n.away_score,
            raw_payload_id = n.raw_payload_id,
            updated_at = NOW()
        FROM normalized n
        WHERE f.provider = n.provider
          AND f.external_fixture_id = n.external_fixture_id
        RETURNING f.external_fixture_id
    ),
    inserted AS (
        INSERT INTO staging.stg_provider_fixtures (
            provider,
            sport_code,
            external_fixture_id,
            external_league_id,
            season,
            home_team_external_id,
            away_team_external_id,
            fixture_date,
            status_text,
            home_score,
            away_score,
            raw_payload_id,
            created_at,
            updated_at
        )
        SELECT
            n.provider,
            n.sport_code,
            n.external_fixture_id,
            n.external_league_id,
            n.season,
            n.home_team_external_id,
            n.away_team_external_id,
            n.fixture_date,
            n.status_text,
            n.home_score,
            n.away_score,
            n.raw_payload_id,
            NOW(),
            NOW()
        FROM normalized n
        WHERE NOT EXISTS (
            SELECT 1
            FROM staging.stg_provider_fixtures f
            WHERE f.provider = n.provider
              AND f.external_fixture_id = n.external_fixture_id
        )
        RETURNING external_fixture_id
    )
    SELECT
        (SELECT COUNT(*) FROM updated) + (SELECT COUNT(*) FROM inserted) AS affected_rows;
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (raw_payload_id,))
        affected = cur.fetchone()["affected_rows"]

        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET parse_status = 'parsed',
                parse_message = 'BK fixtures parsed to staging.stg_provider_fixtures',
                created_at = created_at
            WHERE id = %s
            """,
            (raw_payload_id,),
        )

    return affected


def find_payloads(conn, limit: int):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            """
            SELECT id
            FROM staging.stg_api_payloads
            WHERE provider = 'api_sport'
              AND sport_code IN ('BK', 'basketball')
              AND entity_type = 'fixtures'
              AND endpoint_name IN ('games', 'fixtures')
              AND COALESCE(parse_status, 'pending') <> 'parsed'
            ORDER BY id DESC
            LIMIT %s
            """,
            (limit,),
        )
        return [row["id"] for row in cur.fetchall()]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw-payload-id", type=int, default=None)
    parser.add_argument("--limit", type=int, default=10)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX BK FIXTURES PYTHON PARSER V1")
    print("=" * 80)

    conn = get_conn()
    try:
        payload_ids = [args.raw_payload_id] if args.raw_payload_id else find_payloads(conn, args.limit)

        if not payload_ids:
            print("NO PENDING BK FIXTURE PAYLOADS")
            return 0

        total = 0
        for payload_id in payload_ids:
            affected = parse_payload(conn, payload_id)
            conn.commit()
            total += affected
            print(f"RAW PAYLOAD {payload_id}: affected staging rows = {affected}")

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