import json
import psycopg2
from pathlib import Path
from datetime import datetime

# === CONFIG ===
RAW_FILE = Path(
    r"C:\MatchMatrix-platform\data\raw\api_american_football\teams\api_american_football_teams_league_1_season_2024_20260410_154500.json"
)

LEAGUE_ID = "1"
SEASON = "2024"
PROVIDER = "api_american_football"

DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"


def main():
    if not RAW_FILE.exists():
        raise FileNotFoundError(f"Soubor neexistuje: {RAW_FILE}")

    print("=" * 70)
    print("MATCHMATRIX - PARSE AFB TEAMS → STAGING")
    print("=" * 70)
    print(f"RAW FILE: {RAW_FILE}")

    # 👇 BOM fix
    with RAW_FILE.open("r", encoding="utf-8-sig") as f:
        data = json.load(f)

    response = data.get("response", [])
    print(f"Items in response: {len(response)}")

    if not response:
        print("Nic ke zpracování.")
        return

    conn = psycopg2.connect(DB_DSN)
    cur = conn.cursor()

    insert_sql = """
        insert into staging.stg_api_american_football_teams (
            provider,
            league_id,
            season,
            provider_team_id,
            team_name,
            team_code,
            city,
            coach,
            owner,
            stadium,
            established,
            logo_url,
            country_name,
            country_code,
            country_flag_url,
            raw_json
        )
        values (
            %s, %s, %s,
            %s, %s, %s, %s, %s, %s, %s, %s, %s,
            %s, %s, %s,
            %s
        )
    """

    inserted = 0

    for team in response:
        country = team.get("country", {}) or {}

        cur.execute(
            insert_sql,
            (
                PROVIDER,
                LEAGUE_ID,
                SEASON,
                str(team.get("id")),
                team.get("name"),
                team.get("code"),
                team.get("city"),
                team.get("coach"),
                team.get("owner"),
                team.get("stadium"),
                team.get("established"),
                team.get("logo"),
                country.get("name"),
                country.get("code"),
                country.get("flag"),
                json.dumps(team)
            )
        )

        inserted += 1

    conn.commit()
    cur.close()
    conn.close()

    print("-" * 70)
    print(f"INSERTED ROWS: {inserted}")
    print("DONE")
    print("=" * 70)


if __name__ == "__main__":
    main()