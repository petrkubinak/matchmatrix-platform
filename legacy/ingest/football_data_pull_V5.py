# football_data_pull_V5.py
# MatchMatrix ingest: football-data.org (v4)
#
# Krátké připomenutí:
# - "loop" = opakování stejné akce pro více položek (zde pro každou ligu a každý zápas)
# - "guard" = ochranná kontrola, která špatná data nepustí dál (zde přeskočí vadný zápas)
#
# DB kompatibilita:
# - matches_status_chk dovoluje jen: 'SCHEDULED' a 'FINISHED'
# - matches_score_status_chk:
#     FINISHED => home_score i away_score NOT NULL
#     jinak    => oba score NULL
# - chk_teams_different:
#     home_team_id <> away_team_id

import os
import time
import random
import requests
import psycopg2
from psycopg2.extras import Json
from datetime import datetime, timezone

BASE = "https://api.football-data.org/v4"
SOURCE = "football_data"


# ----------------------------
# DB helpers
# ----------------------------
def db():
    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise RuntimeError(
            "Missing env DB_DSN. Example: host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=..."
        )
    conn = psycopg2.connect(dsn)
    conn.autocommit = False
    return conn


def start_run(conn, source: str):
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.api_import_runs(source, status, started_at, details)
            VALUES (%s, %s, now(), %s)
            RETURNING id
            """,
            (source, "running", Json({})),
        )
        run_id = cur.fetchone()[0]
    conn.commit()
    return run_id


def finish_run(conn, run_id: int, status: str, details: dict | None = None):
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE public.api_import_runs
               SET status=%s,
                   finished_at=now(),
                   details=%s
             WHERE id=%s
            """,
            (status, Json(details or {}), run_id),
        )
    conn.commit()


def save_raw(conn, run_id: int, source: str, endpoint: str, payload):
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.api_raw_payloads(run_id, source, endpoint, payload)
            VALUES (%s, %s, %s, %s)
            """,
            (run_id, source, endpoint, Json(payload)),
        )
    conn.commit()


def get_sport_id(conn, sport_code: str = "FB") -> int:
    with conn.cursor() as cur:
        cur.execute("SELECT id FROM public.sports WHERE upper(code)=upper(%s) LIMIT 1", (sport_code,))
        row = cur.fetchone()
        if row:
            return int(row[0])

    with conn.cursor() as cur:
        cur.execute("SELECT id FROM public.sports WHERE lower(name)=lower(%s) LIMIT 1", (sport_code,))
        row = cur.fetchone()
        if row:
            return int(row[0])

    raise RuntimeError(f"Sport '{sport_code}' not found in public.sports (expected code or name).")


# ----------------------------
# HTTP helpers
# ----------------------------
def _sleep_on_rate_limit(resp, attempt: int, base: int = 10, cap: int = 120):
    ra = resp.headers.get("Retry-After")
    if ra:
        try:
            wait = int(ra)
        except ValueError:
            wait = base
    else:
        wait = min(cap, base * (2 ** attempt)) + random.uniform(0, 3.0)

    print(f"RATE LIMIT {resp.status_code}, cekam {wait:.1f}s... (pokus {attempt + 1}/5)")
    time.sleep(wait)


def api_get(path: str, token: str, params=None, retries: int = 5):
    url = f"{BASE}{path}"
    headers = {"X-Auth-Token": token}

    for attempt in range(retries):
        resp = requests.get(url, headers=headers, params=params, timeout=30)
        if resp.status_code == 429:
            _sleep_on_rate_limit(resp, attempt)
            continue
        resp.raise_for_status()
        return resp.json()

    raise RuntimeError("Rate limit: vycerpany pokusy")


# ----------------------------
# UPSERTS
# ----------------------------
def upsert_league(conn, sport_id: int, ext_league_id: str, name: str, country: str | None):
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.leagues (sport_id, name, country, ext_source, ext_league_id)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (ext_source, ext_league_id) DO UPDATE
              SET name=EXCLUDED.name,
                  country=EXCLUDED.country,
                  sport_id=EXCLUDED.sport_id
            RETURNING id
            """,
            (sport_id, name, country, SOURCE, str(ext_league_id)),
        )
        league_id = cur.fetchone()[0]
    conn.commit()
    return league_id


def upsert_team(conn, ext_team_id: str, name: str, ext_source: str = SOURCE) -> int:
    ext_team_id = str(ext_team_id)

    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.teams (name, ext_source, ext_team_id)
            VALUES (%s, %s, %s)
            ON CONFLICT (ext_source, ext_team_id)
            DO UPDATE SET
                name = EXCLUDED.name
            RETURNING id
            """,
            (name, ext_source, ext_team_id),
        )
        team_id = cur.fetchone()[0]

    conn.commit()
    return team_id


def normalize_status_and_score(api_status: str | None, score_obj: dict | None):
    """
    DB-safe normalizace:
      - Pokud existuje fullTime skóre => FINISHED + skóre
      - Jinak => SCHEDULED + NULL skóre
    (DB povoluje jen SCHEDULED/FINISHED.)
    """
    home = away = None
    if isinstance(score_obj, dict):
        ft = score_obj.get("fullTime") or {}
        home = ft.get("home")
        away = ft.get("away")

    if home is not None and away is not None:
        return ("FINISHED", int(home), int(away))

    return ("SCHEDULED", None, None)


def upsert_match(
    conn,
    sport_id: int,
    league_db_id: int,
    home_id: int,
    away_id: int,
    kickoff,
    status: str,
    home_score,
    away_score,
    season=None,
    ext_match_id: str | None = None,
):
    ext_source = SOURCE
    status = (status or "").upper()

    # enforce DB score constraint:
    if status == "FINISHED":
        if home_score is None or away_score is None:
            status = "SCHEDULED"
            home_score = None
            away_score = None
    else:
        home_score = None
        away_score = None

    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.matches(
                sport_id, league_id, home_team_id, away_team_id,
                kickoff, status, ext_source, ext_match_id,
                home_score, away_score, season
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            ON CONFLICT (ext_source, ext_match_id) DO UPDATE SET
                sport_id     = EXCLUDED.sport_id,
                league_id    = EXCLUDED.league_id,
                home_team_id = EXCLUDED.home_team_id,
                away_team_id = EXCLUDED.away_team_id,
                kickoff      = EXCLUDED.kickoff,
                status       = EXCLUDED.status,
                home_score   = EXCLUDED.home_score,
                away_score   = EXCLUDED.away_score,
                season       = EXCLUDED.season,
                updated_at   = now()
            RETURNING id
            """,
            (
                sport_id,
                league_db_id,
                home_id,
                away_id,
                kickoff,
                status,
                ext_source,
                ext_match_id,
                home_score,
                away_score,
                season,
            ),
        )
        match_id = cur.fetchone()[0]

    conn.commit()
    return match_id


# ----------------------------
# Parsing helpers
# ----------------------------
def _parse_kickoff(match_obj: dict):
    s = match_obj.get("utcDate")
    if not s:
        return None
    try:
        dt = datetime.fromisoformat(s.replace("Z", "+00:00"))
        return dt.astimezone(timezone.utc)
    except Exception:
        return s


def _extract_season(matches_payload: dict):
    season = (matches_payload.get("filters", {}) or {}).get("season")
    if season is None:
        season = (matches_payload.get("resultSet", {}) or {}).get("season")
    if season is None:
        return None
    try:
        return int(season)
    except Exception:
        return season


# ----------------------------
# Main import flow
# ----------------------------
def main():
    conn = db()
    run_id = None

    skipped_invalid_teams = 0
    skipped_missing_team_ids = 0

    try:
        token = os.environ.get("FOOTBALL_DATA_TOKEN")
        if not token:
            raise RuntimeError("Missing env FOOTBALL_DATA_TOKEN (football-data.org token).")

        sport_id = get_sport_id(conn, "FB")

        run_id = start_run(conn, SOURCE)
        print("Spoustim import z football-data.org...")

        comps_endpoint = "/competitions"
        comps = api_get(comps_endpoint, token)
        save_raw(conn, run_id, SOURCE, comps_endpoint, comps)

        competitions = comps.get("competitions", [])
        print(f"Competitions: {len(competitions)}")

        for c in competitions:
            ext_league_id = c.get("id")
            league_name = c.get("name") or c.get("code") or f"competition_{ext_league_id}"
            area = c.get("area") or {}
            country = area.get("name")

            league_id = upsert_league(conn, sport_id, str(ext_league_id), league_name, country)

            matches_endpoint = f"/competitions/{ext_league_id}/matches"
            matches_payload = api_get(matches_endpoint, token)
            save_raw(conn, run_id, SOURCE, matches_endpoint, matches_payload)

            season = _extract_season(matches_payload)

            matches = matches_payload.get("matches", [])
            print(f"League {league_name}: matches={len(matches)}")

            for m in matches:
                ext_match_id = str(m.get("id"))
                kickoff = _parse_kickoff(m)

                status_db, home_score, away_score = normalize_status_and_score(
                    m.get("status"),
                    m.get("score"),
                )

                home = m.get("homeTeam") or {}
                away = m.get("awayTeam") or {}
                ext_home_id = home.get("id")
                ext_away_id = away.get("id")

                # GUARD 1: chybí team id => přeskočit
                if ext_home_id is None or ext_away_id is None:
                    skipped_missing_team_ids += 1
                    print(f"SKIP match {ext_match_id}: missing team id (home={ext_home_id}, away={ext_away_id})")
                    continue

                ext_home_id = str(ext_home_id)
                ext_away_id = str(ext_away_id)

                # GUARD 2: stejný tým proti sobě => přeskočit (kvůli chk_teams_different)
                if ext_home_id == ext_away_id:
                    skipped_invalid_teams += 1
                    print(f"SKIP match {ext_match_id}: same team ids (home={ext_home_id}, away={ext_away_id})")
                    continue

                home_team_id = upsert_team(conn, ext_home_id, home.get("name") or f"team_{ext_home_id}")
                away_team_id = upsert_team(conn, ext_away_id, away.get("name") or f"team_{ext_away_id}")

                # Extra safety: pokud by přesto DB ids byly stejné, přeskočíme
                if home_team_id == away_team_id:
                    skipped_invalid_teams += 1
                    print(f"SKIP match {ext_match_id}: same DB team ids (home_id={home_team_id}, away_id={away_team_id})")
                    continue

                upsert_match(
                    conn,
                    sport_id=sport_id,
                    league_db_id=league_id,
                    home_id=home_team_id,
                    away_id=away_team_id,
                    kickoff=kickoff,
                    status=status_db,
                    home_score=home_score,
                    away_score=away_score,
                    ext_match_id=ext_match_id,
                    season=season,
                )

        details = {
            "note": "import finished",
            "skipped_missing_team_ids": skipped_missing_team_ids,
            "skipped_invalid_teams": skipped_invalid_teams,
        }
        finish_run(conn, run_id, "ok", details)
        print(
            f"OK run_id={run_id} | skipped_missing_team_ids={skipped_missing_team_ids} | "
            f"skipped_invalid_teams={skipped_invalid_teams}"
        )

    except Exception as e:
        if run_id:
            try:
                finish_run(conn, run_id, "error", {"error": str(e)})
            except Exception:
                pass
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
