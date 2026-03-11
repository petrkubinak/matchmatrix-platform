import psycopg2


def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass",
    )


def bridge_football_odds(conn):

    sql = """
    WITH src AS
    (
        SELECT DISTINCT ON
        (
            afo.fixture_id,
            afo.bookmaker_id,
            afo.market,
            afo.outcome
        )
            afo.fixture_id::text AS external_fixture_id,
            afo.bookmaker_id::text AS bookmaker_name,
            afo.market AS market_type,
            afo.outcome AS outcome_name,
            afo.odd_value::numeric AS odds_value,
            afo.fetched_at AS odds_timestamp
        FROM staging.api_football_odds afo
        ORDER BY
            afo.fixture_id,
            afo.bookmaker_id,
            afo.market,
            afo.outcome,
            afo.fetched_at DESC
    )
    INSERT INTO staging.stg_provider_odds
    (
        provider,
        sport_code,
        external_fixture_id,
        bookmaker_name,
        market_type,
        outcome_name,
        odds_value,
        odds_timestamp,
        raw_payload_id
    )
    SELECT
        'api_football',
        'football',
        src.external_fixture_id,
        src.bookmaker_name,
        src.market_type,
        src.outcome_name,
        src.odds_value,
        src.odds_timestamp,
        NULL::bigint
    FROM src
    """
    with conn.cursor() as cur:
        cur.execute(sql)


def get_count(conn, table_name):

    with conn.cursor() as cur:
        cur.execute(f"SELECT COUNT(*) FROM {table_name}")
        return cur.fetchone()[0]


def main():

    conn = get_conn()

    try:

        print("=== LEGACY -> UNIFIED ODDS BRIDGE ===")
        print()

        bridge_football_odds(conn)

        conn.commit()

        print(
            "staging.stg_provider_odds:",
            get_count(conn, "staging.stg_provider_odds"),
        )

        print()
        print("Hotovo. Odds byly presunuty do unified staging.")

    except Exception as e:

        conn.rollback()

        print("Chyba odds bridge:", e)

        raise

    finally:

        conn.close()


if __name__ == "__main__":
    main()