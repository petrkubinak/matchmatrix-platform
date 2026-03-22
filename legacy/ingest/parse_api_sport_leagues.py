import sys
import psycopg2

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass"
}


def db():
    return psycopg2.connect(**DB_CONFIG)


def get_sport_id(api_sport_code: str) -> int:
    """
    Mapování API sport kódu na interní MatchMatrix kód ve public.sports.code
    """
    sport_code_map = {
        "football": "FB",
        "hockey": "HK",
        "basketball": "BK",
        "tennis": "TN",
    }

    internal_code = sport_code_map.get(api_sport_code.lower())

    if not internal_code:
        raise Exception(f"Unsupported api sport code: {api_sport_code}")

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
        raise Exception(
            f"Mapped sport code not found in public.sports: api={api_sport_code} -> internal={internal_code}"
        )

    return row[0]


def load_raw_leagues(sport_code: str):
    """
    Načte poslední OK payload pro konkrétní sport z api_import_runs/api_raw_payloads.
    """
    q = """
    SELECT rp.id, rp.payload
    FROM public.api_raw_payloads rp
    WHERE rp.source = 'api_sport'
      AND rp.endpoint = 'leagues'
      AND rp.run_id = (
          SELECT r.id
          FROM public.api_import_runs r
          WHERE r.source = 'api_sport'
            AND r.details ->> 'endpoint' = 'leagues'
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


def normalize_league_item(item: dict) -> dict | None:
    """
    Podporuje více tvarů payloadu:
    1) nested "league"
    2) flat item
    3) nested "competition"
    """
    if not isinstance(item, dict):
        return None

    league_id = None
    league_name = None
    country_name = None

    # Varianta A: nested "league"
    if isinstance(item.get("league"), dict):
        league_obj = item["league"]
        league_id = league_obj.get("id")
        league_name = league_obj.get("name")

        country_obj = item.get("country")
        if isinstance(country_obj, dict):
            country_name = country_obj.get("name")
        elif isinstance(country_obj, str):
            country_name = country_obj

    # Varianta B: flat item
    else:
        league_id = item.get("id") or item.get("league_id")
        league_name = item.get("name") or item.get("league_name")

        country_obj = item.get("country")
        if isinstance(country_obj, dict):
            country_name = country_obj.get("name")
        elif isinstance(country_obj, str):
            country_name = country_obj

    # Varianta C: jiný nested klíč
    if league_id is None and isinstance(item.get("competition"), dict):
        c = item["competition"]
        league_id = c.get("id")
        league_name = c.get("name")

    if league_id is None or league_name is None:
        return None

    return {
        "ext_source": "api_sport",
        "ext_league_id": str(league_id),
        "name": league_name,
        "country": country_name,
    }


def upsert_league(league: dict, sport_id: int):
    q_update = """
    UPDATE public.leagues
    SET
        sport_id = %s,
        name = %s,
        country = %s,
        updated_at = now()
    WHERE ext_source = %s
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
                    league["name"],
                    league["country"],
                    league["ext_source"],
                    league["ext_league_id"],
                ),
            )
            row = cur.fetchone()

            if row is None:
                cur.execute(
                    q_insert,
                    (
                        sport_id,
                        league["name"],
                        league["country"],
                        league["ext_source"],
                        league["ext_league_id"],
                    ),
                )


def run(sport_code: str):
    sport_id = get_sport_id(sport_code)
    row = load_raw_leagues(sport_code)

    if not row:
        print(f"No api_sport/leagues payload found for sport_code={sport_code}")
        return

    payload_id, payload = row
    response_items = payload.get("response", [])

    print(f"Sport code: {sport_code}")
    print(f"Sport ID: {sport_id}")
    print(f"Payload ID: {payload_id}")
    print(f"Leagues found in payload: {len(response_items)}")

    imported = 0
    skipped = 0

    for idx, item in enumerate(response_items, start=1):
        league = normalize_league_item(item)

        if league is None:
            skipped += 1
            print(f"SKIP item #{idx}: unsupported shape")
            continue

        upsert_league(league, sport_id)
        imported += 1

    print(f"Imported/updated leagues: {imported}")
    print(f"Skipped leagues: {skipped}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python parse_api_sport_leagues.py <sport_code>")
        sys.exit(1)

    run(sys.argv[1])