from __future__ import annotations

import argparse
from datetime import datetime

import psycopg2


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Extract teams from staging fixtures into staging teams"
    )

    parser.add_argument("--provider", required=True, help="Např. api_football")
    parser.add_argument("--sport", required=True, help="Např. football")
    parser.add_argument("--league-id", required=True, help="External/provider league id")
    parser.add_argument("--season", required=True, help="Season as text, např. 2022")

    return parser.parse_args()


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def print_header(args):
    print("=" * 70)
    print("MATCHMATRIX: EXTRACT TEAMS FROM FIXTURES")
    print("=" * 70)
    print("START TIME :", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("PROVIDER   :", args.provider)
    print("SPORT      :", args.sport)
    print("LEAGUE ID  :", args.league_id)
    print("SEASON     :", args.season)
    print("=" * 70)


def count_existing_teams(conn, provider: str, sport: str, league_id: str, season: str) -> int:
    sql = """
        SELECT COUNT(*)
        FROM staging.stg_provider_teams
        WHERE provider = %s
          AND sport_code = %s
          AND external_league_id = %s
          AND season = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (provider, sport, league_id, season))
        return cur.fetchone()[0]


def count_fixture_rows(conn, provider: str, sport: str, league_id: str, season: str) -> int:
    sql = """
        SELECT COUNT(*)
        FROM staging.stg_provider_fixtures
        WHERE provider = %s
          AND sport_code = %s
          AND external_league_id = %s
          AND season = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (provider, sport, league_id, season))
        return cur.fetchone()[0]


def insert_teams_from_fixtures(conn, provider: str, sport: str, league_id: str, season: str) -> int:
    """
    Vloží unikátní team IDs odvozené z fixtures.
    team_name a country_name zde fallbackově neznáme, proto je necháme NULL.
    raw_payload_id zde také neznáme, necháme NULL.
    is_active nastavíme na TRUE.
    """

    sql = """
        INSERT INTO staging.stg_provider_teams
        (
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
            src.provider,
            src.sport_code,
            src.external_team_id,
            NULL AS team_name,
            NULL AS country_name,
            src.external_league_id,
            src.season,
            NULL AS raw_payload_id,
            TRUE AS is_active,
            NOW() AS created_at,
            NOW() AS updated_at
        FROM
        (
            SELECT DISTINCT
                f.provider,
                f.sport_code,
                f.external_league_id,
                f.season,
                f.home_team_external_id AS external_team_id
            FROM staging.stg_provider_fixtures f
            WHERE f.provider = %s
              AND f.sport_code = %s
              AND f.external_league_id = %s
              AND f.season = %s
              AND f.home_team_external_id IS NOT NULL

            UNION

            SELECT DISTINCT
                f.provider,
                f.sport_code,
                f.external_league_id,
                f.season,
                f.away_team_external_id AS external_team_id
            FROM staging.stg_provider_fixtures f
            WHERE f.provider = %s
              AND f.sport_code = %s
              AND f.external_league_id = %s
              AND f.season = %s
              AND f.away_team_external_id IS NOT NULL
        ) src
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM staging.stg_provider_teams t
            WHERE t.provider = src.provider
              AND t.sport_code = src.sport_code
              AND t.external_league_id = src.external_league_id
              AND t.season = src.season
              AND t.external_team_id = src.external_team_id
        )
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                provider, sport, league_id, season,
                provider, sport, league_id, season,
            ),
        )
        inserted = cur.rowcount

    conn.commit()
    return inserted


def main() -> int:
    args = parse_args()
    print_header(args)

    conn = get_connection()
    try:
        fixtures_count = count_fixture_rows(conn, args.provider, args.sport, args.league_id, args.season)
        teams_before = count_existing_teams(conn, args.provider, args.sport, args.league_id, args.season)

        print("Fixtures found      :", fixtures_count)
        print("Teams before insert :", teams_before)

        if fixtures_count == 0:
            print("No fixtures found. Nothing to extract.")
            return 1

        inserted = insert_teams_from_fixtures(conn, args.provider, args.sport, args.league_id, args.season)
        teams_after = count_existing_teams(conn, args.provider, args.sport, args.league_id, args.season)

        print("Teams inserted      :", inserted)
        print("Teams after insert  :", teams_after)
        print("=" * 70)
        print("Done.")
        print("=" * 70)

        return 0

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())