import os, json, requests, psycopg2
from psycopg2.extras import Json
from datetime import datetime, timezone

FD_TOKEN = os.environ["FOOTBALL_DATA_TOKEN"]
DB_DSN = os.environ["DB_DSN"]  # např. "host=localhost dbname=matchmatrix user=postgres password=..."

BASE = "https://api.football-data.org/v4"

def api_get(path, params=None):
    r = requests.get(BASE + path, params=params, headers={"X-Auth-Token": FD_TOKEN}, timeout=30)
    r.raise_for_status()
    return r.json()

def db():
    return psycopg2.connect(DB_DSN)

def start_run(conn, source):
    with conn.cursor() as cur:
        cur.execute("insert into public.api_import_runs(source) values (%s) returning id", (source,))
        return cur.fetchone()[0]

def finish_run(conn, run_id, status="ok", details=None):
    with conn.cursor() as cur:
        cur.execute("""
            update public.api_import_runs
               set finished_at = now(), status=%s, details=%s
             where id=%s
        """, (status, Json(details or {}), run_id))

def save_raw(conn, run_id, source, endpoint, payload):
    with conn.cursor() as cur:
        cur.execute("""
            insert into public.api_raw_payloads(run_id, source, endpoint, payload)
            values (%s,%s,%s,%s)
        """, (run_id, source, endpoint, Json(payload)))

def upsert_league(conn, ext_id, name):
    with conn.cursor() as cur:
        cur.execute("""
            insert into public.leagues(name, ext_source, ext_league_id)
            values (%s,'football_data',%s)
            on conflict (ext_source, ext_league_id) do update set name=excluded.name
            returning id
        """, (name, str(ext_id)))
        return cur.fetchone()[0]

def upsert_team(conn, ext_id, name):
    with conn.cursor() as cur:
        cur.execute("""
            insert into public.teams(name, ext_source, ext_team_id)
            values (%s,'football_data',%s)
            on conflict (ext_source, ext_team_id) do update set name=excluded.name
            returning id
        """, (name, str(ext_id)))
        return cur.fetchone()[0]

def upsert_match(conn, ext_id, league_id, home_team_id, away_team_id, kickoff):
    with conn.cursor() as cur:
        cur.execute("""
            insert into public.matches(league_id, home_team_id, away_team_id, kickoff, ext_source, ext_match_id)
            values (%s,%s,%s,%s,'football_data',%s)
            on conflict (ext_source, ext_match_id) do update
              set league_id=excluded.league_id,
                  home_team_id=excluded.home_team_id,
                  away_team_id=excluded.away_team_id,
                  kickoff=excluded.kickoff
            returning id
        """, (league_id, home_team_id, away_team_id, kickoff, str(ext_id)))
        return cur.fetchone()[0]

def main():
    conn = db()
    conn.autocommit = False
    run_id = None
    try:
        run_id = start_run(conn, "football_data")

        # 1) competitions (ligy) - v praxi si vybereš jen TOP
        comps = api_get("/competitions")
        save_raw(conn, run_id, "football_data", "/competitions", comps)

        # příklad: projedeme prvních 5 soutěží
        for c in comps.get("competitions", [])[:5]:
            league_db_id = upsert_league(conn, c["id"], c.get("name") or c.get("code") or f"comp_{c['id']}")

            # 2) teams in competition
            teams = api_get(f"/competitions/{c['id']}/teams")
            save_raw(conn, run_id, "football_data", f"/competitions/{c['id']}/teams", teams)
            team_map = {}
            for t in teams.get("teams", []):
                team_map[t["id"]] = upsert_team(conn, t["id"], t["name"])

            # 3) matches next 14 days
            now = datetime.now(timezone.utc)
            date_from = now.date().isoformat()
            date_to = (now.date()).isoformat()  # klidně rozšiř později
            matches = api_get(f"/competitions/{c['id']}/matches", params={"dateFrom": date_from, "dateTo": date_to})
            save_raw(conn, run_id, "football_data", f"/competitions/{c['id']}/matches", matches)

            for m in matches.get("matches", []):
                home_id = team_map.get(m["homeTeam"]["id"])
                away_id = team_map.get(m["awayTeam"]["id"])
                if not home_id or not away_id:
                    continue
                kickoff = m.get("utcDate")  # ISO string
                upsert_match(conn, m["id"], league_db_id, home_id, away_id, kickoff)

        finish_run(conn, run_id, "ok", {"note": "basic import done"})
        conn.commit()
        print("OK run_id=", run_id)

    except Exception as e:
        if run_id:
            finish_run(conn, run_id, "error", {"error": str(e)})
        conn.rollback()
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    main()
