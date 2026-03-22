import os
import requests
import psycopg2

API_KEY = os.getenv("API_FOOTBALL_KEY")

DB = {
    "host": "localhost",
    "database": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass"
}

API_URL = "https://v3.football.api-sports.io/teams"

conn = psycopg2.connect(**DB)
cur = conn.cursor()

print("=== MATCHMATRIX: MISSING TEAMS FROM FIXTURES ===")

cur.execute("""
select distinct
    x.api_team_id
from (
    select home_team_external_id as api_team_id
    from staging.stg_provider_fixtures
    where provider='api_football'
    and sport_code='football'

    union

    select away_team_external_id
    from staging.stg_provider_fixtures
    where provider='api_football'
    and sport_code='football'
) x
where not exists (
    select 1
    from staging.api_football_teams t
    where t.team_id::text = x.api_team_id
)
""")

teams = [r[0] for r in cur.fetchall()]

print("Missing teams:", len(teams))

headers = {
    "x-apisports-key": API_KEY
}

insert_sql = """
insert into staging.api_football_teams
(team_id,name,logo)
values (%s,%s,%s)
on conflict do nothing
"""

for team_id in teams:

    url = f"{API_URL}?id={team_id}"

    r = requests.get(url, headers=headers)
    data = r.json()

    if not data["response"]:
        continue

    team = data["response"][0]["team"]

    cur.execute(
        insert_sql,
        (
            team["id"],
            team["name"],
            team["logo"]
        )
    )

    conn.commit()

    print("Inserted team:", team["name"])

print("Done.")