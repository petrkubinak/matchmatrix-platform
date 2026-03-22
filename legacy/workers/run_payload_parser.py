import psycopg2
import json
from psycopg2.extras import RealDictCursor


# -----------------------------------------------------
# DB CONNECTION
# -----------------------------------------------------

def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass",
    )


# -----------------------------------------------------
# LOAD UNPARSED PAYLOADS
# -----------------------------------------------------

def load_pending_payloads(conn, limit=50):

    sql = """
    SELECT *
    FROM staging.stg_api_payloads
    WHERE parse_status = 'pending'
    ORDER BY id
    LIMIT %s
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql, (limit,))
        return cur.fetchall()


# -----------------------------------------------------
# MARK PARSED
# -----------------------------------------------------

def mark_payload_status(conn, payload_id, status, message=None):

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE staging.stg_api_payloads
            SET
                parse_status = %s,
                parse_message = %s
            WHERE id = %s
            """,
            (status, message, payload_id)
        )


# -----------------------------------------------------
# PARSE LEAGUES
# -----------------------------------------------------

def parse_leagues(conn, payload):

    data = payload["payload_json"]

    if isinstance(data, str):
        data = json.loads(data)

    leagues = data.get("response", [])

    for item in leagues:

        league = item.get("league", {})
        country = item.get("country", {})

        external_id = str(league.get("id"))
        league_name = league.get("name")
        country_name = country.get("name")

        with conn.cursor() as cur:

            cur.execute(
                """
                INSERT INTO staging.stg_provider_leagues
                (
                    provider,
                    sport_code,
                    external_league_id,
                    league_name,
                    country_name,
                    season,
                    raw_payload_id
                )
                VALUES (%s,%s,%s,%s,%s,%s,%s)
                ON CONFLICT (provider, external_league_id, season)
                DO UPDATE SET
                    league_name = EXCLUDED.league_name,
                    country_name = EXCLUDED.country_name,
                    updated_at = now()
                """,
                (
                    payload["provider"],
                    payload["sport_code"],
                    external_id,
                    league_name,
                    country_name,
                    payload["season"],
                    payload["id"]
                )
            )


# -----------------------------------------------------
# PARSE TEAMS
# -----------------------------------------------------

def parse_teams(conn, payload):

    data = payload["payload_json"]

    if isinstance(data, str):
        data = json.loads(data)

    teams = data.get("response", [])

    for item in teams:

        team = item.get("team", {})

        external_team_id = str(team.get("id"))
        team_name = team.get("name")
        country = team.get("country")

        with conn.cursor() as cur:

            cur.execute(
                """
                INSERT INTO staging.stg_provider_teams
                (
                    provider,
                    sport_code,
                    external_team_id,
                    team_name,
                    country_name,
                    raw_payload_id
                )
                VALUES (%s,%s,%s,%s,%s,%s)
                ON CONFLICT (provider, external_team_id)
                DO UPDATE SET
                    team_name = EXCLUDED.team_name,
                    country_name = EXCLUDED.country_name,
                    updated_at = now()
                """,
                (
                    payload["provider"],
                    payload["sport_code"],
                    external_team_id,
                    team_name,
                    country,
                    payload["id"]
                )
            )


# -----------------------------------------------------
# PARSE FIXTURES
# -----------------------------------------------------

def parse_fixtures(conn, payload):

    data = payload["payload_json"]

    if isinstance(data, str):
        data = json.loads(data)

    fixtures = data.get("response", [])

    for item in fixtures:

        fixture = item.get("fixture", {})
        teams = item.get("teams", {})
        goals = item.get("goals", {})

        fixture_id = str(fixture.get("id"))

        home_team = teams.get("home", {}).get("id")
        away_team = teams.get("away", {}).get("id")

        fixture_date = fixture.get("date")

        home_score = goals.get("home")
        away_score = goals.get("away")

        with conn.cursor() as cur:

            cur.execute(
                """
                INSERT INTO staging.stg_provider_fixtures
                (
                    provider,
                    sport_code,
                    external_fixture_id,
                    season,
                    home_team_external_id,
                    away_team_external_id,
                    fixture_date,
                    home_score,
                    away_score,
                    raw_payload_id
                )
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                ON CONFLICT (provider, external_fixture_id)
                DO UPDATE SET
                    home_score = EXCLUDED.home_score,
                    away_score = EXCLUDED.away_score,
                    updated_at = now()
                """,
                (
                    payload["provider"],
                    payload["sport_code"],
                    fixture_id,
                    payload["season"],
                    str(home_team),
                    str(away_team),
                    fixture_date,
                    str(home_score),
                    str(away_score),
                    payload["id"]
                )
            )


# -----------------------------------------------------
# DISPATCH PARSER
# -----------------------------------------------------

def process_payload(conn, payload):

    entity = payload["entity_type"]

    if entity == "leagues":
        parse_leagues(conn, payload)

    elif entity == "teams":
        parse_teams(conn, payload)

    elif entity == "fixtures":
        parse_fixtures(conn, payload)

    else:
        raise Exception(f"Unknown entity_type: {entity}")


# -----------------------------------------------------
# MAIN
# -----------------------------------------------------

def main():

    conn = get_conn()

    try:

        payloads = load_pending_payloads(conn)

        if not payloads:
            print("No payloads to parse.")
            return

        for payload in payloads:

            pid = payload["id"]

            print(f"Parsing payload {pid} ({payload['entity_type']})")

            try:

                process_payload(conn, payload)

                mark_payload_status(conn, pid, "parsed", "OK")

            except Exception as e:

                mark_payload_status(conn, pid, "error", str(e))

            conn.commit()

    finally:

        conn.close()


if __name__ == "__main__":
    main()