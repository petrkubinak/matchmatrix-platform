import psycopg2
from datetime import datetime


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def as_dict(value):
    return value if isinstance(value, dict) else {}


def as_list(value):
    return value if isinstance(value, list) else []


def safe_text(value):
    if value is None:
        return None
    text = str(value).strip()
    return text if text != "" else None


def extract_league_id(item: dict, external_id: str | None):
    league = as_dict(item.get("league"))
    league_id = safe_text(league.get("id"))
    if league_id:
        return league_id

    if external_id and "_" in external_id:
        return safe_text(external_id.split("_")[0])

    return safe_text(external_id)


def extract_fixture_id(item: dict):
    fixture = as_dict(item.get("fixture"))
    game = as_dict(item.get("game"))

    return (
        safe_text(item.get("id"))
        or safe_text(game.get("id"))
        or safe_text(fixture.get("id"))
    )


def extract_fixture_date(item: dict):
    fixture = as_dict(item.get("fixture"))
    game = as_dict(item.get("game"))

    return (
        safe_text(item.get("date"))
        or safe_text(game.get("date"))
        or safe_text(fixture.get("date"))
    )


def extract_status_text(item: dict):
    fixture = as_dict(item.get("fixture"))
    game = as_dict(item.get("game"))

    status = as_dict(item.get("status"))
    if not status:
        status = as_dict(fixture.get("status"))
    if not status:
        status = as_dict(game.get("status"))

    return (
        safe_text(status.get("short"))
        or safe_text(status.get("long"))
        or safe_text(item.get("status"))
        or safe_text(fixture.get("status"))
        or safe_text(game.get("status"))
        or "SCHEDULED"
    )


def extract_team_ids(item: dict):
    teams = as_dict(item.get("teams"))

    home = as_dict(teams.get("home"))
    away = as_dict(teams.get("away"))

    # fallbacky pro jiné struktury
    if not home and isinstance(item.get("home"), dict):
        home = as_dict(item.get("home"))

    if not away and isinstance(item.get("away"), dict):
        away = as_dict(item.get("away"))

    home_id = safe_text(home.get("id"))
    away_id = safe_text(away.get("id"))

    return home_id, away_id


def extract_scores(item: dict):
    goals = as_dict(item.get("goals"))
    scores = as_dict(item.get("scores"))

    home_score = (
        safe_text(goals.get("home"))
        or safe_text(scores.get("home"))
        or safe_text(item.get("home_score"))
    )

    away_score = (
        safe_text(goals.get("away"))
        or safe_text(scores.get("away"))
        or safe_text(item.get("away_score"))
    )

    return home_score, away_score


def upsert_fixture(cur, payload_id, provider, sport_code, season, external_id, item):
    external_fixture_id = extract_fixture_id(item)
    if not external_fixture_id:
        return False, "missing external_fixture_id"

    external_league_id = extract_league_id(item, external_id)
    fixture_date = extract_fixture_date(item)
    status_text = extract_status_text(item)
    home_team_external_id, away_team_external_id = extract_team_ids(item)
    home_score, away_score = extract_scores(item)

    # 1) update existing row
    cur.execute(
        """
        UPDATE staging.stg_provider_fixtures
        SET
            external_league_id = COALESCE(%s, external_league_id),
            season = COALESCE(%s, season),
            home_team_external_id = COALESCE(%s, home_team_external_id),
            away_team_external_id = COALESCE(%s, away_team_external_id),
            fixture_date = COALESCE(%s::timestamptz, fixture_date),
            status_text = COALESCE(%s, status_text),
            home_score = COALESCE(%s, home_score),
            away_score = COALESCE(%s, away_score),
            raw_payload_id = %s,
            updated_at = NOW()
        WHERE provider = %s
          AND sport_code = %s
          AND external_fixture_id = %s
        """,
        (
            external_league_id,
            season,
            home_team_external_id,
            away_team_external_id,
            fixture_date,
            status_text,
            home_score,
            away_score,
            payload_id,
            provider,
            sport_code,
            external_fixture_id,
        ),
    )

    if cur.rowcount > 0:
        return True, "updated"

    # 2) insert new row
    cur.execute(
        """
        INSERT INTO staging.stg_provider_fixtures
        (
            provider,
            sport_code,
            external_fixture_id,
            external_league_id,
            season,
            home_team_external_id,
            away_team_external_id,
            fixture_date,
            status_text,
            home_score,
            away_score,
            raw_payload_id,
            created_at,
            updated_at
        )
        VALUES
        (
            %s, %s, %s, %s, %s, %s, %s, %s::timestamptz, %s, %s, %s, %s, NOW(), NOW()
        )
        """,
        (
            provider,
            sport_code,
            external_fixture_id,
            external_league_id,
            season,
            home_team_external_id,
            away_team_external_id,
            fixture_date,
            status_text,
            home_score,
            away_score,
            payload_id,
        ),
    )

    return True, "inserted"


def main():
    conn = get_connection()
    cur = conn.cursor()

    print("=== PARSE FIXTURES (SHORT) ===")

    cur.execute(
        """
        SELECT
            id,
            provider,
            sport_code,
            endpoint_name,
            external_id,
            season,
            payload_json
        FROM staging.stg_api_payloads
        WHERE entity_type = 'fixtures'
          AND parse_status = 'pending'
        ORDER BY id
        """
    )

    rows = cur.fetchall()
    print("Payloads:", len(rows))

    parsed_rows = 0
    inserted_or_updated = 0
    errors = 0

    for row in rows:
        payload_id, provider, sport_code, endpoint_name, external_id, season, payload = row

        try:
            payload = as_dict(payload)
            response_items = as_list(payload.get("response"))

            local_count = 0

            for item in response_items:
                item = as_dict(item)
                ok, _ = upsert_fixture(
                    cur=cur,
                    payload_id=payload_id,
                    provider=provider,
                    sport_code=sport_code,
                    season=safe_text(season),
                    external_id=safe_text(external_id),
                    item=item,
                )
                if ok:
                    local_count += 1

            cur.execute(
                """
                UPDATE staging.stg_api_payloads
                SET
                    parse_status = 'processed',
                    parse_message = %s
                WHERE id = %s
                """,
                (f"fixtures parsed OK | rows={local_count}", payload_id),
            )

            parsed_rows += 1
            inserted_or_updated += local_count

        except Exception as exc:
            errors += 1
            cur.execute(
                """
                UPDATE staging.stg_api_payloads
                SET
                    parse_status = 'error',
                    parse_message = %s
                WHERE id = %s
                """,
                (f"fixtures parse error: {str(exc)[:500]}", payload_id),
            )
            print(f"ERROR payload_id={payload_id}: {exc}")

    conn.commit()
    cur.close()
    conn.close()

    print("Processed payloads:", parsed_rows)
    print("Fixtures upserted :", inserted_or_updated)
    print("Errors            :", errors)
    print("DONE")


if __name__ == "__main__":
    main()