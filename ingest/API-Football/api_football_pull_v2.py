
import os
import sys
import requests
import psycopg2
import json
from datetime import datetime

DB_CONN = "host=localhost dbname=matchmatrix user=postgres password=postgres"
BASE_URL = os.getenv("APISPORTS_BASE", "https://v3.football.api-sports.io")
API_KEY = os.getenv("APISPORTS_KEY")

HEADERS = {
    "x-apisports-key": API_KEY
}

def create_run():
    with psycopg2.connect(DB_CONN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO public.api_import_runs (source, started_at, status)
                VALUES ('api-football', now(), 'running')
                RETURNING id;
            """)
            run_id = cur.fetchone()[0]
    return run_id

def save_raw(run_id, endpoint, payload):
    with psycopg2.connect(DB_CONN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO public.api_raw_payloads (run_id, source, endpoint, fetched_at, payload)
                VALUES (%s, 'api-football', %s, now(), %s);
            """, (run_id, endpoint, json.dumps(payload)))

def pull_teams(run_id, league_id, season):
    endpoint = f"/teams?league={league_id}&season={season}"
    r = requests.get(BASE_URL + endpoint, headers=HEADERS)
    data = r.json()
    save_raw(run_id, endpoint, data)

    teams = data.get("response", [])
    with psycopg2.connect(DB_CONN) as conn:
        with conn.cursor() as cur:
            for t in teams:
                team = t["team"]
                venue = t.get("venue", {})
                cur.execute("""
                    INSERT INTO staging.api_football_teams
                    (run_id, league_id, season, team_id, name, code, country, founded, national, logo, venue_name, raw, fetched_at)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,now());
                """, (
                    run_id,
                    league_id,
                    season,
                    team.get("id"),
                    team.get("name"),
                    team.get("code"),
                    team.get("country"),
                    team.get("founded"),
                    team.get("national"),
                    team.get("logo"),
                    venue.get("name"),
                    json.dumps(t)
                ))

def pull_fixtures(run_id, league_id, season, date_from, date_to):
    endpoint = f"/fixtures?league={league_id}&season={season}&from={date_from}&to={date_to}"
    r = requests.get(BASE_URL + endpoint, headers=HEADERS)
    data = r.json()
    save_raw(run_id, endpoint, data)

    fixtures = data.get("response", [])
    with psycopg2.connect(DB_CONN) as conn:
        with conn.cursor() as cur:
            for f in fixtures:
                fixture = f["fixture"]
                teams = f["teams"]
                goals = f["goals"]
                cur.execute("""
                    INSERT INTO staging.api_football_fixtures
                    (run_id, league_id, season, fixture_id, kickoff, status, home_team_id, away_team_id, home_goals, away_goals, raw, fetched_at)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,now());
                """, (
                    run_id,
                    league_id,
                    season,
                    fixture.get("id"),
                    fixture.get("date"),
                    fixture.get("status", {}).get("short"),
                    teams["home"]["id"],
                    teams["away"]["id"],
                    goals.get("home"),
                    goals.get("away"),
                    json.dumps(f)
                ))

if __name__ == "__main__":
    run_id = create_run()
    print(f"Created run_id: {run_id}")
