import sys
import psycopg2
from datetime import datetime

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass"
}


def db():
    return psycopg2.connect(**DB_CONFIG)


def map_api_sport_code(api_sport_code: str) -> str:
    sport_code_map = {
        "football": "FB",
        "hockey": "HK",
        "basketball": "BK",
        "tennis": "TN",
    }

    internal_code = sport_code_map.get(api_sport_code.lower())
    if not internal_code:
        raise Exception(f"Unsupported api sport code: {api_sport_code}")

    return internal_code


def get_sport_id(api_sport_code: str) -> int:
    internal_code = map_api_sport_code(api_sport_code)

    q = """
    SELECT id
    FROM public.sports
    WHERE code = %s
    LIMIT 1
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q, (internal_code,))
            row = cur.fetchone()

    if not row:
        raise Exception(f"Sport not found in public.sports for code={internal_code}")

    return row[0]


def load_raw_fixtures(sport_code: str):
    q = """
    SELECT rp.id, rp.payload
    FROM public.api_raw_payloads rp
    WHERE rp.source = 'api_sport'
      AND rp.endpoint = 'fixtures'
      AND rp.run_id = (
          SELECT r.id
          FROM public.api_import_runs r
          WHERE r.source = 'api_sport'
            AND r.details ->> 'endpoint' = 'fixtures'
            AND r.details ->> 'sport_code' = %s
            AND r.status = 'ok'
          ORDER BY r.id DESC
          LIMIT 1
      )
    LIMIT 1
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q, (sport_code,))
            return cur.fetchone()


def find_league_id(ext_league_id: str, sport_id: int):
    q = """
    SELECT id
    FROM public.leagues
    WHERE ext_source = 'api_sport'
      AND ext_league_id = %s
      AND sport_id = %s
    LIMIT 1
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q, (str(ext_league_id), sport_id))
            row = cur.fetchone()

    return row[0] if row else None

def upsert_league_from_fixture(league_obj: dict, sport_id: int):
    ext_league_id = league_obj.get("id")
    league_name = league_obj.get("name")
    country = league_obj.get("country")

    if not ext_league_id or not league_name:
        return None

    q_update = """
    UPDATE public.leagues
    SET
        sport_id = %s,
        name = %s,
        country = %s,
        updated_at = now()
    WHERE ext_source = 'api_sport'
      AND ext_league_id = %s
    RETURNING id
    """

    q_insert = """
    INSERT INTO public.leagues (
        sport_id,
        name,
        country,
        ext_source,
        ext_league_id,
        created_at,
        updated_at
    )
    VALUES (%s, %s, %s, %s, %s, now(), now())
    RETURNING id
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                q_update,
                (
                    sport_id,
                    league_name,
                    country,
                    str(ext_league_id),
                ),
            )
            row = cur.fetchone()

            if row:
                return row[0]

            cur.execute(
                q_insert,
                (
                    sport_id,
                    league_name,
                    country,
                    "api_sport",
                    str(ext_league_id),
                ),
            )
            return cur.fetchone()[0]

def upsert_team(team_name: str, ext_team_id: str):
    q_update = """
    UPDATE public.teams
    SET
        name = %s,
        updated_at = now()
    WHERE ext_source = 'api_sport'
      AND ext_team_id = %s
    RETURNING id
    """

    q_insert = """
    INSERT INTO public.teams (
        name,
        ext_source,
        ext_team_id,
        created_at,
        updated_at
    )
    VALUES (%s, %s, %s, now(), now())
    RETURNING id
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(q_update, (team_name, str(ext_team_id)))
            row = cur.fetchone()

            if row:
                return row[0]

            cur.execute(q_insert, (team_name, 'api_sport', str(ext_team_id)))
            return cur.fetchone()[0]


def normalize_status(api_status: str) -> str:
    s = (api_status or "").upper()

    if s in ("FT", "AET", "PEN", "FINISHED", "AFTER_PENALTIES"):
        return "FINISHED"
    if s in ("NS", "TBD", "SCHEDULED", "TIMED", "NOT_STARTED"):
        return "SCHEDULED"
    if s in ("1H", "2H", "HT", "LIVE", "IN_PLAY", "Q1", "Q2", "Q3", "Q4", "OT"):
        return "LIVE"
    if s in ("CANC", "CANCELLED", "ABD"):
        return "CANCELLED"
    if s in ("PST", "POSTPONED"):
        return "POSTPONED"

    return "SCHEDULED"


def parse_kickoff(value):
    if value is None:
        return None

    if isinstance(value, str):
        # API-SPORTS typicky vrací ISO string, PostgreSQL si ho umí vzít i jako text
        return value

    return str(value)


def extract_scores(item: dict, normalized_status: str):
    """
    Vrací home_score, away_score
    Jen pro FINISHED, jinak NULL kvůli CHECK constraintu v public.matches.
    """
    if normalized_status != "FINISHED":
        return None, None

    goals = item.get("goals")
    if isinstance(goals, dict):
        return goals.get("home"), goals.get("away")

    scores = item.get("scores")
    if isinstance(scores, dict):
        home = scores.get("home")
        away = scores.get("away")

        if isinstance(home, dict):
            home = home.get("total")
        if isinstance(away, dict):
            away = away.get("total")

        return home, away

    return None, None


def upsert_match(match_row: dict):
    q_update = """
    UPDATE public.matches
    SET
        league_id = %s,
        home_team_id = %s,
        away_team_id = %s,
        kickoff = %s,
        status = %s,
        home_score = %s,
        away_score = %s,
        season = %s,
        sport_id = %s,
        updated_at = now()
    WHERE ext_source = 'api_sport'
      AND ext_match_id = %s
    RETURNING id
    """

    q_insert = """
    INSERT INTO public.matches (
        league_id,
        home_team_id,
        away_team_id,
        kickoff,
        ext_source,
        ext_match_id,
        status,
        home_score,
        away_score,
        season,
        sport_id,
        updated_at
    )
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, now())
    RETURNING id
    """

    with db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                q_update,
                (
                    match_row["league_id"],
                    match_row["home_team_id"],
                    match_row["away_team_id"],
                    match_row["kickoff"],
                    match_row["status"],
                    match_row["home_score"],
                    match_row["away_score"],
                    match_row["season"],
                    match_row["sport_id"],
                    match_row["ext_match_id"],
                ),
            )
            row = cur.fetchone()

            if row:
                return row[0]

            cur.execute(
                q_insert,
                (
                    match_row["league_id"],
                    match_row["home_team_id"],
                    match_row["away_team_id"],
                    match_row["kickoff"],
                    "api_sport",
                    match_row["ext_match_id"],
                    match_row["status"],
                    match_row["home_score"],
                    match_row["away_score"],
                    match_row["season"],
                    match_row["sport_id"],
                ),
            )
            return cur.fetchone()[0]


def extract_fixture_items(payload: dict):
    response = payload.get("response", [])
    return response if isinstance(response, list) else []


def run(sport_code: str):
    sport_id = get_sport_id(sport_code)
    row = load_raw_fixtures(sport_code)

    if not row:
        print(f"No api_sport/fixtures payload found for sport_code={sport_code}")
        return

    payload_id, payload = row
    items = extract_fixture_items(payload)

    print(f"Sport code: {sport_code}")
    print(f"Sport ID: {sport_id}")
    print(f"Payload ID: {payload_id}")
    print(f"Fixtures found in payload: {len(items)}")

    imported = 0
    skipped = 0

    for idx, item in enumerate(items, start=1):
        try:
            fixture = item.get("fixture", {})
            league = item.get("league", {})
            teams = item.get("teams", {})

            ext_match_id = fixture.get("id")
            kickoff = parse_kickoff(fixture.get("date"))

            status_obj = fixture.get("status") or {}
            api_status = status_obj.get("short") or status_obj.get("long")
            status = normalize_status(api_status)

            ext_league_id = league.get("id")
            season = league.get("season")

            home = teams.get("home", {})
            away = teams.get("away", {})

            home_name = home.get("name")
            away_name = away.get("name")
            home_ext_id = home.get("id")
            away_ext_id = away.get("id")

            if not ext_match_id or not kickoff or not home_name or not away_name:
                skipped += 1
                print(f"SKIP item #{idx}: missing required fixture/team fields")
                continue

            home_team_id = upsert_team(home_name, home_ext_id)
            away_team_id = upsert_team(away_name, away_ext_id)

            league_id = find_league_id(ext_league_id, sport_id)

            league_id = find_league_id(ext_league_id, sport_id)

            if league_id is None:
                league_id = upsert_league_from_fixture(league, sport_id)

                if league_id is None:
                    print(
                        f"WARNING missing league mapping and cannot auto-create: "
                        f"sport_code={sport_code}, sport_id={sport_id}, ext_league_id={ext_league_id}, season={season}"
                    )
        
            home_score, away_score = extract_scores(item, status)

            upsert_match({
                "league_id": league_id,
                "home_team_id": home_team_id,
                "away_team_id": away_team_id,
                "kickoff": kickoff,
                "status": status,
                "home_score": home_score,
                "away_score": away_score,
                "season": str(season) if season is not None else None,
                "sport_id": sport_id,
                "ext_match_id": str(ext_match_id),
            })

            imported += 1

        except Exception as e:
            skipped += 1
            print(f"SKIP item #{idx}: {e}")

    print(f"Imported/updated fixtures: {imported}")
    print(f"Skipped fixtures: {skipped}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python parse_api_sport_fixtures.py <sport_code>")
        sys.exit(1)

    run(sys.argv[1])