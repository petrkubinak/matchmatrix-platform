import os
from pathlib import Path
from dotenv import load_dotenv
import requests
import psycopg2
import json
from datetime import datetime, UTC

# ================================
# LOAD .env
# ================================

ENV_PATH = Path(r"C:\MatchMatrix-platform\.env")
load_dotenv(dotenv_path=ENV_PATH, override=True)

print("ENV PATH EXISTS:", ENV_PATH.exists())
print("PGHOST:", repr(os.getenv("PGHOST")))
print("PGPORT:", repr(os.getenv("PGPORT")))
print("PGDATABASE:", repr(os.getenv("PGDATABASE")))
print("PGUSER:", repr(os.getenv("PGUSER")))
print("PGPASSWORD:", repr(os.getenv("PGPASSWORD")))
print("DB_DSN:", repr(os.getenv("DB_DSN")))

def get_conn():
    host = os.getenv("PGHOST")
    port = os.getenv("PGPORT")
    dbname = os.getenv("PGDATABASE")
    user = os.getenv("PGUSER")
    password = os.getenv("PGPASSWORD")

    if not all([host, port, dbname, user, password]):
        raise RuntimeError(
            f"Missing DB env vars | "
            f"PGHOST={repr(host)} PGPORT={repr(port)} "
            f"PGDATABASE={repr(dbname)} PGUSER={repr(user)} "
            f"PGPASSWORD={repr(password)}"
        )

    return psycopg2.connect(
        host=host.strip(),
        port=port.strip(),
        dbname=dbname.strip(),
        user=user.strip(),
        password=password.strip()
    )

# ================================
# CONFIG
# ================================

API_KEY = os.getenv("APISPORTS_KEY")

BASE_URL = "https://v3.football.api-sports.io/coachs"

HEADERS = {
    "x-apisports-key": API_KEY
}

PROVIDER = "api_football"
SPORT_CODE = "FB"

# ================================
# FETCH COACHES
# ================================

def fetch_coaches_by_team(team_id):
    params = {"team": team_id}

    response = requests.get(BASE_URL, headers=HEADERS, params=params)

    if response.status_code != 200:
        print(f"ERROR API {response.status_code}: {response.text}")
        return []

    data = response.json()
    return data.get("response", [])


# ================================
# INSERT TO STAGING
# ================================

def insert_coach(conn, coach, team_id):
    cur = conn.cursor()

    coach_id = coach.get("id")
    coach_name = coach.get("name")
    first_name = coach.get("firstname")
    last_name = coach.get("lastname")
    nationality = coach.get("nationality")

    birth = coach.get("birth") or {}
    birth_date = birth.get("date")
    birth_place = birth.get("place")
    birth_country = birth.get("country")

    photo_url = coach.get("photo")

    team = coach.get("team") or {}
    team_external_id = str(team.get("id")) if team.get("id") is not None else str(team_id)
    team_name = team.get("name")

    # career bereme jen jako historické stopy.
    # league_external_id a season teď z endpointu coachs nevyčteme.
    career = coach.get("career") or []

    if not career:
        cur.execute("""
            INSERT INTO staging.stg_provider_coaches (
                provider,
                sport_code,
                external_coach_id,
                coach_name,
                first_name,
                last_name,
                nationality,
                team_external_id,
                team_name,
                league_external_id,
                season,
                birth_date,
                birth_place,
                birth_country,
                photo_url,
                is_active,
                created_at,
                updated_at
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, now(), now())
            ON CONFLICT DO NOTHING
        """, (
            PROVIDER,
            SPORT_CODE,
            str(coach_id) if coach_id is not None else None,
            coach_name,
            first_name,
            last_name,
            nationality,
            team_external_id,
            team_name,
            None,
            None,
            birth_date,
            birth_place,
            birth_country,
            photo_url,
            True
        ))
    else:
        for c in career:
            career_team = c.get("team") or {}

            career_team_id = career_team.get("id")
            career_team_name = career_team.get("name")

            # league_external_id a season v payloadu nejsou
            cur.execute("""
                INSERT INTO staging.stg_provider_coaches (
                    provider,
                    sport_code,
                    external_coach_id,
                    coach_name,
                    first_name,
                    last_name,
                    nationality,
                    team_external_id,
                    team_name,
                    league_external_id,
                    season,
                    birth_date,
                    birth_place,
                    birth_country,
                    photo_url,
                    is_active,
                    created_at,
                    updated_at
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, now(), now())
                ON CONFLICT DO NOTHING
            """, (
                PROVIDER,
                SPORT_CODE,
                str(coach_id) if coach_id is not None else None,
                coach_name,
                first_name,
                last_name,
                nationality,
                str(career_team_id) if career_team_id is not None else team_external_id,
                career_team_name if career_team_name else team_name,
                None,
                None,
                birth_date,
                birth_place,
                birth_country,
                photo_url,
                True
            ))

    conn.commit()


# ================================
# MAIN
# ================================

def main():
    conn = get_conn()

    # ⚠️ jednoduchý test – 1 tým
    team_ids = [33]  # např. Manchester United

    for team_id in team_ids:
        print(f"Fetching team {team_id}")

        coaches = fetch_coaches_by_team(team_id)

        print(f"Found coaches: {len(coaches)}")

        for idx, coach in enumerate(coaches, start=1):
    	    print(f"\n=== COACH #{idx} RAW ===")
    	    insert_coach(conn, coach, team_id)

    conn.close()
    print("DONE")


if __name__ == "__main__":
    main()