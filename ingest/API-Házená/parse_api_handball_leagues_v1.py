import json
import psycopg2
from datetime import datetime

DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"


def main():
    print("=" * 70)
    print("MATCHMATRIX - PARSE HB LEAGUES V1")
    print("=" * 70)

    conn = psycopg2.connect(DB_DSN)
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            payload_json
        FROM staging.stg_api_payloads
        WHERE provider = 'api_handball'
          AND entity_type = 'leagues'
        ORDER BY id DESC
        LIMIT 1
    """)

    row = cur.fetchone()

    if not row:
        print("❌ Žádný HB leagues payload nenalezen.")
        cur.close()
        conn.close()
        return

    payload_id, payload_json = row

    if isinstance(payload_json, str):
        data = json.loads(payload_json)
    else:
        data = payload_json

    response = data.get("response", [])

    inserted = 0
    skipped = 0

    for league in response:
        external_league_id = str(league.get("id")) if league.get("id") is not None else None
        league_name = league.get("name")
        country = league.get("country") or {}
        country_name = country.get("name") if isinstance(country, dict) else None
        seasons = league.get("seasons") or []

        if not external_league_id or not league_name:
            skipped += 1
            continue

        if not seasons:
            seasons = [{"season": None, "current": True}]

        for season_row in seasons:
            season = season_row.get("season") if isinstance(season_row, dict) else None

            cur.execute("""
                INSERT INTO staging.stg_provider_leagues (
                    provider,
                    sport_code,
                    external_league_id,
                    league_name,
                    country_name,
                    season,
                    raw_payload_id,
                    is_active,
                    created_at,
                    updated_at
                )
                SELECT
                    %s, %s, %s, %s, %s, %s, %s, %s, now(), now()
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM staging.stg_provider_leagues x
                    WHERE x.provider = %s
                      AND x.sport_code = %s
                      AND x.external_league_id = %s
                      AND COALESCE(x.season, '') = COALESCE(%s, '')
                )
            """, (
                "api_handball",
                "HB",
                external_league_id,
                league_name,
                country_name,
                str(season) if season is not None else None,
                payload_id,
                True,
                "api_handball",
                "HB",
                external_league_id,
                str(season) if season is not None else None,
            ))

            inserted += cur.rowcount

    conn.commit()

    print(f"Payload ID : {payload_id}")
    print(f"Response   : {len(response)}")
    print(f"Inserted   : {inserted}")
    print(f"Skipped    : {skipped}")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()