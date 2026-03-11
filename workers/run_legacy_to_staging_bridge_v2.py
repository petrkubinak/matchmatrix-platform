import psycopg2


def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass",
    )


# ---------------------------------------------------------
# FOOTBALL -> UNIFIED STAGING
# ---------------------------------------------------------

def bridge_football_leagues(conn):
    sql = """
    WITH src AS
    (
        SELECT DISTINCT ON (afl.league_id, COALESCE(afl.season::text, ''))
            afl.league_id::text AS external_league_id,
            afl.name AS league_name,
            afl.country AS country_name,
            COALESCE(afl.season::text, '') AS season
        FROM staging.api_football_leagues afl
        ORDER BY
            afl.league_id,
            COALESCE(afl.season::text, ''),
            afl.name
    )
    INSERT INTO staging.stg_provider_leagues
    (
        provider,
        sport_code,
        external_league_id,
        league_name,
        country_name,
        season,
        raw_payload_id,
        is_active
    )
    SELECT
        'api_football',
        'football',
        src.external_league_id,
        src.league_name,
        src.country_name,
        src.season,
        NULL::bigint,
        true
    FROM src
    ON CONFLICT (provider, external_league_id, season)
    DO UPDATE SET
        league_name = EXCLUDED.league_name,
        country_name = EXCLUDED.country_name,
        updated_at = now()
    """
    with conn.cursor() as cur:
        cur.execute(sql)


def bridge_football_teams(conn):
    sql = """
    WITH src AS
    (
        SELECT DISTINCT ON (aft.team_id)
            aft.team_id::text AS external_team_id,
            aft.name AS team_name,
            aft.country AS country_name,
            aft.league_id::text AS external_league_id,
            COALESCE(aft.season::text, '') AS season
        FROM staging.api_football_teams aft
        ORDER BY
            aft.team_id,
            COALESCE(aft.season, 0) DESC,
            aft.league_id DESC
    )
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
        is_active
    )
    SELECT
        'api_football',
        'football',
        src.external_team_id,
        src.team_name,
        src.country_name,
        src.external_league_id,
        src.season,
        NULL::bigint,
        true
    FROM src
    ON CONFLICT (provider, external_team_id)
    DO UPDATE SET
        team_name = EXCLUDED.team_name,
        country_name = EXCLUDED.country_name,
        external_league_id = EXCLUDED.external_league_id,
        season = EXCLUDED.season,
        updated_at = now()
    """
    with conn.cursor() as cur:
        cur.execute(sql)


def bridge_football_fixtures(conn):
    sql = """
    WITH src AS
    (
        SELECT DISTINCT ON (aff.fixture_id)
            aff.fixture_id::text AS external_fixture_id,
            aff.league_id::text AS external_league_id,
            COALESCE(aff.season::text, '') AS season,
            aff.home_team_id::text AS home_team_external_id,
            aff.away_team_id::text AS away_team_external_id,
            aff.kickoff AS fixture_date,
            aff.status AS status_text,
            aff.home_goals::text AS home_score,
            aff.away_goals::text AS away_score
        FROM staging.api_football_fixtures aff
        ORDER BY
            aff.fixture_id,
            aff.kickoff DESC NULLS LAST
    )
    INSERT INTO staging.stg_provider_fixtures
    (
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
        raw_payload_id
    )
    SELECT
        'api_football',
        'football',
        src.external_fixture_id,
        src.external_league_id,
        src.season,
        src.home_team_external_id,
        src.away_team_external_id,
        src.fixture_date,
        src.status_text,
        src.home_score,
        src.away_score,
        NULL::bigint
    FROM src
    ON CONFLICT (provider, external_fixture_id)
    DO UPDATE SET
        external_league_id = EXCLUDED.external_league_id,
        season = EXCLUDED.season,
        home_team_external_id = EXCLUDED.home_team_external_id,
        away_team_external_id = EXCLUDED.away_team_external_id,
        fixture_date = EXCLUDED.fixture_date,
        status_text = EXCLUDED.status_text,
        home_score = EXCLUDED.home_score,
        away_score = EXCLUDED.away_score,
        updated_at = now()
    """
    with conn.cursor() as cur:
        cur.execute(sql)


# ---------------------------------------------------------
# HOCKEY -> UNIFIED STAGING
# ---------------------------------------------------------

def bridge_hockey_leagues(conn):
    sql = """
    WITH src AS
    (
        SELECT DISTINCT ON (ahl.league_id, COALESCE(ahl.season::text, ''))
            ahl.league_id::text AS external_league_id,
            COALESCE(ahl.name, 'UNKNOWN') AS league_name,
            ahl.country AS country_name,
            COALESCE(ahl.season::text, '') AS season
        FROM staging.api_hockey_leagues ahl
        ORDER BY
            ahl.league_id,
            COALESCE(ahl.season::text, ''),
            ahl.name
    )
    INSERT INTO staging.stg_provider_leagues
    (
        provider,
        sport_code,
        external_league_id,
        league_name,
        country_name,
        season,
        raw_payload_id,
        is_active
    )
    SELECT
        'api_hockey',
        'hockey',
        src.external_league_id,
        src.league_name,
        src.country_name,
        src.season,
        NULL::bigint,
        true
    FROM src
    ON CONFLICT (provider, external_league_id, season)
    DO UPDATE SET
        league_name = EXCLUDED.league_name,
        country_name = EXCLUDED.country_name,
        updated_at = now()
    """
    with conn.cursor() as cur:
        cur.execute(sql)


def bridge_hockey_teams(conn):
    sql = """
    WITH src AS
    (
        SELECT DISTINCT ON (aht.team_id)
            aht.team_id::text AS external_team_id,
            COALESCE(aht.name, 'UNKNOWN') AS team_name,
            aht.country AS country_name,
            COALESCE(aht.league_id::text, '') AS external_league_id,
            COALESCE(aht.season::text, '') AS season
        FROM staging.api_hockey_teams aht
        ORDER BY
            aht.team_id,
            COALESCE(aht.season, 0) DESC,
            aht.league_id DESC NULLS LAST
    )
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
        is_active
    )
    SELECT
        'api_hockey',
        'hockey',
        src.external_team_id,
        src.team_name,
        src.country_name,
        src.external_league_id,
        src.season,
        NULL::bigint,
        true
    FROM src
    ON CONFLICT (provider, external_team_id)
    DO UPDATE SET
        team_name = EXCLUDED.team_name,
        country_name = EXCLUDED.country_name,
        external_league_id = EXCLUDED.external_league_id,
        season = EXCLUDED.season,
        updated_at = now()
    """
    with conn.cursor() as cur:
        cur.execute(sql)


# ---------------------------------------------------------
# COUNTS
# ---------------------------------------------------------

def get_count(conn, table_name: str) -> int:
    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {table_name}")
        return cur.fetchone()[0]


def main():
    conn = get_conn()
    try:
        print("=== LEGACY -> UNIFIED STAGING BRIDGE V2 ===")
        print()

        bridge_football_leagues(conn)
        print("Football leagues bridged.")

        bridge_football_teams(conn)
        print("Football teams bridged.")

        bridge_football_fixtures(conn)
        print("Football fixtures bridged.")

        bridge_hockey_leagues(conn)
        print("Hockey leagues bridged.")

        bridge_hockey_teams(conn)
        print("Hockey teams bridged.")

        conn.commit()

        print()
        print(f"staging.stg_provider_leagues: {get_count(conn, 'staging.stg_provider_leagues')}")
        print(f"staging.stg_provider_teams: {get_count(conn, 'staging.stg_provider_teams')}")
        print(f"staging.stg_provider_fixtures: {get_count(conn, 'staging.stg_provider_fixtures')}")
        print()
        print("Hotovo. Legacy data byla prepsana do unified staging.")

    except Exception as e:
        conn.rollback()
        print(f"Chyba bridge v2: {e}")
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()