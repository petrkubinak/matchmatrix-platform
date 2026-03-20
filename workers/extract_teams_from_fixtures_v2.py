import psycopg2


def get_connection():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        database="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass"
    )


def main():
    conn = get_connection()
    cur = conn.cursor()

    print("=== EXTRACT TEAMS FROM FIXTURES RAW ===")

    cur.execute("""
        SELECT
            league_id,
            season,
            raw
        FROM staging.api_football_fixtures
        ORDER BY fetched_at DESC
    """)

    rows = cur.fetchall()

    teams = {}

    for league_id, season, raw in rows:
        if raw is None:
            continue

        fixture = raw if isinstance(raw, dict) else {}

        teams_data = fixture.get("teams", {})
        home = teams_data.get("home", {})
        away = teams_data.get("away", {})

        if home.get("id") and home.get("name"):
            key = str(home["id"])
            teams[key] = {
                "team_name": home["name"],
                "external_league_id": str(league_id) if league_id is not None else None,
                "season": str(season) if season is not None else None
            }

        if away.get("id") and away.get("name"):
            key = str(away["id"])
            teams[key] = {
                "team_name": away["name"],
                "external_league_id": str(league_id) if league_id is not None else None,
                "season": str(season) if season is not None else None
            }

    affected = 0

    for external_team_id, item in teams.items():
        cur.execute("""
            INSERT INTO staging.stg_provider_teams
            (
                provider,
                sport_code,
                external_team_id,
                team_name,
                external_league_id,
                season,
                created_at,
                updated_at
            )
            VALUES
            (
                'api_football',
                'football',
                %s,
                %s,
                %s,
                %s,
                now(),
                now()
            )
            ON CONFLICT (provider, external_team_id)
            DO UPDATE SET
                team_name = EXCLUDED.team_name,
                external_league_id = COALESCE(EXCLUDED.external_league_id, staging.stg_provider_teams.external_league_id),
                season = COALESCE(EXCLUDED.season, staging.stg_provider_teams.season),
                updated_at = now()
        """, (
            external_team_id,
            item["team_name"],
            item["external_league_id"],
            item["season"]
        ))

        affected += cur.rowcount

    conn.commit()

    print("Teams upserted:", affected)

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()