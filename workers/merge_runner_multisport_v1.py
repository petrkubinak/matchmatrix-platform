# ============================================================
# merge_runner_multisport_v1.py
# REAL MERGE: staging.stg_provider_* -> public.*
# ============================================================

import argparse
import psycopg2
from datetime import datetime

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)


def get_sport_id(cur, sport_code):
    cur.execute("""
        SELECT id
        FROM public.sports
        WHERE code = %s OR upper(name) = upper(%s)
        LIMIT 1
    """, (sport_code, sport_code))
    row = cur.fetchone()
    if not row:
        raise RuntimeError(f"Sport nenalezen v public.sports: {sport_code}")
    return row[0]


def merge_teams(cur, provider, sport_code):
    sport_id = get_sport_id(cur, sport_code)

    cur.execute("""
        SELECT DISTINCT
            external_team_id,
            team_name,
            country_name
        FROM staging.stg_provider_teams
        WHERE provider = %s
          AND sport_code = %s
          AND external_team_id IS NOT NULL
          AND team_name IS NOT NULL
    """, (provider, sport_code))

    rows = cur.fetchall()
    inserted_teams = 0
    inserted_maps = 0

    for external_team_id, team_name, country_name in rows:
        cur.execute("""
            SELECT team_id
            FROM public.team_provider_map
            WHERE provider = %s
              AND provider_team_id = %s
            LIMIT 1
        """, (provider, external_team_id))
        map_row = cur.fetchone()

        if map_row:
            continue

        cur.execute("""
            SELECT id
            FROM public.teams
            WHERE sport_id = %s
              AND lower(name) = lower(%s)
            LIMIT 1
        """, (sport_id, team_name))
        team_row = cur.fetchone()

        if team_row:
            team_id = team_row[0]
        else:
            cur.execute("""
                INSERT INTO public.teams (sport_id, name, country)
                VALUES (%s, %s, %s)
                RETURNING id
            """, (sport_id, team_name, country_name))
            team_id = cur.fetchone()[0]
            inserted_teams += 1

        cur.execute("""
            INSERT INTO public.team_provider_map (
                team_id,
                provider,
                provider_team_id
            )
            SELECT %s, %s, %s
            WHERE NOT EXISTS (
                SELECT 1
                FROM public.team_provider_map
                WHERE provider = %s
                  AND provider_team_id = %s
            )
        """, (team_id, provider, external_team_id, provider, external_team_id))
        inserted_maps += cur.rowcount

    return inserted_teams, inserted_maps


def merge_fixtures(cur, provider, sport_code):
    sport_id = get_sport_id(cur, sport_code)

    cur.execute("""
        SELECT DISTINCT
            f.external_fixture_id,
            f.external_league_id,
            f.season,
            f.home_team_external_id,
            f.away_team_external_id,
            f.fixture_date,
            f.status_text,
            f.home_score,
            f.away_score
        FROM staging.stg_provider_fixtures f
        WHERE f.provider = %s
          AND f.sport_code = %s
          AND f.external_fixture_id IS NOT NULL
          AND f.fixture_date IS NOT NULL
    """, (provider, sport_code))

    rows = cur.fetchall()
    inserted_matches = 0
    skipped = 0

    for r in rows:
        (
            external_fixture_id,
            external_league_id,
            season,
            home_ext,
            away_ext,
            fixture_date,
            status_text,
            home_score,
            away_score,
        ) = r

        cur.execute("""
            SELECT id
            FROM public.matches
            WHERE ext_source = %s
              AND ext_match_id = %s
            LIMIT 1
        """, (provider, external_fixture_id))
        if cur.fetchone():
            continue

        cur.execute("""
            SELECT team_id
            FROM public.team_provider_map
            WHERE provider = %s
              AND provider_team_id = %s
            LIMIT 1
        """, (provider, home_ext))
        home = cur.fetchone()

        cur.execute("""
            SELECT team_id
            FROM public.team_provider_map
            WHERE provider = %s
              AND provider_team_id = %s
            LIMIT 1
        """, (provider, away_ext))
        away = cur.fetchone()

        if not home or not away:
            skipped += 1
            continue

        cur.execute("""
            SELECT id
            FROM public.leagues
            WHERE ext_source = %s
              AND ext_league_id = %s
            LIMIT 1
        """, (provider, external_league_id))
        league = cur.fetchone()
        league_id = league[0] if league else None

        status = "FINISHED" if status_text in ("FT", "AOT", "AP") else "SCHEDULED"

        cur.execute("""
            INSERT INTO public.matches (
                league_id,
                home_team_id,
                away_team_id,
                kickoff,
                ext_source,
                ext_match_id,
                status,
                home_score,
                away_score,
                season,
                sport_id,
                updated_at
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
        """, (
            league_id,
            home[0],
            away[0],
            fixture_date,
            provider,
            external_fixture_id,
            status,
            int(home_score) if home_score not in (None, "") else None,
            int(away_score) if away_score not in (None, "") else None,
            season,
            sport_id,
        ))

        inserted_matches += 1

    return inserted_matches, skipped


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--provider", required=True)
    parser.add_argument("--sport", required=True)
    parser.add_argument("--entity", required=True)
    parser.add_argument("--run-group", required=False)
    args = parser.parse_args()

    log("=" * 60)
    log("MATCHMATRIX MERGE RUNNER V1 - REAL MERGE")
    log("=" * 60)
    log(f"Provider: {args.provider}")
    log(f"Sport   : {args.sport}")
    log(f"Entity  : {args.entity}")

    conn = psycopg2.connect(**DB_CONFIG)

    try:
        with conn:
            with conn.cursor() as cur:
                teams_inserted, maps_inserted = merge_teams(cur, args.provider, args.sport)
                log(f"TEAMS inserted      : {teams_inserted}")
                log(f"PROVIDER MAP inserted: {maps_inserted}")

                if args.entity == "fixtures":
                    matches_inserted, skipped = merge_fixtures(cur, args.provider, args.sport)
                    log(f"MATCHES inserted    : {matches_inserted}")
                    log(f"MATCHES skipped     : {skipped}")

        log("RESULT: OK")

    except Exception as e:
        conn.rollback()
        log(f"RESULT: ERROR | {e}")
        raise

    finally:
        conn.close()


if __name__ == "__main__":
    main()