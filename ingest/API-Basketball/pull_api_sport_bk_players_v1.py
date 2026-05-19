# ============================================================
# API-SPORT BASKETBALL PLAYERS INGEST V1
# endpoint: /players (team + season)
# ============================================================

import os
import time
import psycopg2
import requests
from datetime import datetime
from dotenv import load_dotenv

# =========================
# CONFIG
# =========================

load_dotenv(r"C:\MatchMatrix-platform\ingest\.env")

API_KEY = os.getenv("APISPORTS_KEY")
BASE_URL = "https://v1.basketball.api-sports.io"

HEADERS = {
    "x-apisports-key": API_KEY
}

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

SLEEP = 1.2

# =========================
# DB
# =========================

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

# =========================
# MAIN
# =========================

def run():

    conn = get_conn()
    cur = conn.cursor()

    print("=" * 80)
    print("MATCHMATRIX BK PLAYERS INGEST V1")
    print("=" * 80)

    cur.execute("""
        SELECT id, provider_league_id, season
        FROM ops.ingest_targets
        WHERE provider = 'api_sport'
          AND sport_code = 'BK'
          AND enabled = TRUE
        LIMIT 5
    """)

    targets = cur.fetchall()

    print(f"Targets: {len(targets)}")

    for target in targets:
        target_id, league_id, season = target

        print(f"\n--- TARGET {target_id} league={league_id} season={season} ---")

        # získáme týmy z DB
        cur.execute("""
            SELECT DISTINCT external_team_id
            FROM staging.stg_provider_teams
            WHERE provider = 'api_sport'
              AND sport_code = 'basketball'
              AND external_league_id = %s
              AND season = %s
        """, (league_id, season))

        teams = cur.fetchall()

        print(f"Teams found: {len(teams)}")

        for (team_id,) in teams:

            url = f"{BASE_URL}/players"
            params = {
                "team": team_id,
                "season": season
            }

            print(f"CALL team={team_id}")

            response = requests.get(url, headers=HEADERS, params=params)
            data = response.json()

            cur.execute("""
                INSERT INTO staging.stg_api_payloads
                (provider, sport_code, endpoint_name, external_id, season, payload_json, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, NOW())
            """, (
                "api_sport",
                "basketball",
                "players",
                str(team_id),
                str(season),
                json.dumps(data)
            ))

            conn.commit()

            time.sleep(SLEEP)

    cur.close()
    conn.close()

    print("\nHOTOVO")


if __name__ == "__main__":
    run()