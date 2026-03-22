import os
import time
import json
import requests
import psycopg2
from psycopg2.extras import Json

# ============================================================
# MATCHMATRIX
# Repair missing teams from fixtures for API-Football
# ------------------------------------------------------------
# Co dělá:
# 1) najde chybějící external team_id ve fixtures
# 2) stáhne detail týmu z API-Football /teams?id=...
# 3) uloží do staging.api_football_teams
# 4) vypíše souhrn: inserted / skipped / not_found / failed
#
# Poznámka:
# - worker je bezpečný pro opakované spuštění
# - používá ON CONFLICT DO NOTHING
# - ukládá i raw payload pro budoucí audit
# ============================================================


# -----------------------------
# ENV / konfigurace
# -----------------------------
API_KEY = os.getenv("API_FOOTBALL_KEY")

DB = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "database": os.getenv("DB_NAME", "matchmatrix"),
    "user": os.getenv("DB_USER", "matchmatrix"),
    "password": os.getenv("DB_PASSWORD", "matchmatrix_pass"),
}

API_URL = "https://v3.football.api-sports.io/teams"
REQUEST_TIMEOUT = 30
SLEEP_BETWEEN_CALLS = 1.0
MAX_RETRIES = 3


def fail(msg: str) -> None:
    print(f"FATAL: {msg}")
    raise SystemExit(1)


def api_get_team(team_id: str, headers: dict) -> dict | None:
    """
    Zavolá API-Football /teams?id=TEAM_ID
    Vrací dict payload nebo None při not_found.
    Při tvrdé chybě vyhodí výjimku.
    """
    params = {"id": team_id}

    last_error = None

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = requests.get(
                API_URL,
                headers=headers,
                params=params,
                timeout=REQUEST_TIMEOUT
            )

            # HTTP chyba
            if response.status_code != 200:
                last_error = f"HTTP {response.status_code} | body={response.text[:300]}"
                time.sleep(1.5 * attempt)
                continue

            data = response.json()

            # API error blok
            if isinstance(data, dict):
                errors = data.get("errors")
                if errors:
                    last_error = f"API errors={errors}"
                    time.sleep(1.5 * attempt)
                    continue

            # standardní response
            api_response = data.get("response", [])
            if not api_response:
                return None

            return data

        except requests.RequestException as e:
            last_error = f"RequestException: {e}"
            time.sleep(1.5 * attempt)
        except Exception as e:
            last_error = f"Unexpected error: {e}"
            time.sleep(1.5 * attempt)

    raise RuntimeError(f"API call failed for team_id={team_id} | {last_error}")


def main() -> None:
    print("=== MATCHMATRIX: REPAIR MISSING TEAMS FROM FIXTURES V2 ===")

    if not API_KEY:
        fail("Chybí ENV proměnná API_FOOTBALL_KEY.")

    headers = {
        "x-apisports-key": API_KEY
    }

    conn = psycopg2.connect(**DB)
    conn.autocommit = False
    cur = conn.cursor()

    try:
        # --------------------------------------------------------
        # 1) Najdi chybějící team external IDs z unified fixtures
        # --------------------------------------------------------
        cur.execute("""
            select distinct
                x.api_team_id
            from (
                select home_team_external_id as api_team_id
                from staging.stg_provider_fixtures
                where provider = 'api_football'
                  and sport_code = 'football'
                  and home_team_external_id is not null

                union

                select away_team_external_id as api_team_id
                from staging.stg_provider_fixtures
                where provider = 'api_football'
                  and sport_code = 'football'
                  and away_team_external_id is not null
            ) x
            where not exists (
                select 1
                from staging.api_football_teams t
                where t.team_id::text = x.api_team_id::text
            )
            order by x.api_team_id
        """)

        teams = [str(r[0]).strip() for r in cur.fetchall() if r[0] is not None]

        print(f"Missing teams: {len(teams)}")

        if not teams:
            print("Inserted: 0")
            print("Skipped: 0")
            print("Not found: 0")
            print("Failed: 0")
            print("Done.")
            return

        # --------------------------------------------------------
        # 2) Insert SQL
        # --------------------------------------------------------
        insert_sql = """
            insert into staging.api_football_teams
            (
                team_id,
                name,
                code,
                country,
                founded,
                national,
                logo,
                venue_name,
                venue_city,
                raw,
                fetched_at
            )
            values
            (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, now()
            )
            on conflict do nothing
        """

        inserted = 0
        skipped = 0
        not_found = 0
        failed = 0

        # --------------------------------------------------------
        # 3) Loop přes missing team IDs
        # --------------------------------------------------------
        for i, team_id in enumerate(teams, start=1):
            try:
                payload = api_get_team(team_id, headers=headers)

                if payload is None:
                    not_found += 1
                    print(f"[{i}/{len(teams)}] NOT FOUND team_id={team_id}")
                    continue

                row = payload["response"][0]
                team = row.get("team", {}) or {}
                venue = row.get("venue", {}) or {}

                cur.execute(
                    insert_sql,
                    (
                        team.get("id"),
                        team.get("name"),
                        team.get("code"),
                        team.get("country"),
                        team.get("founded"),
                        team.get("national"),
                        team.get("logo"),
                        venue.get("name"),
                        venue.get("city"),
                        Json(payload)
                    )
                )

                # rowcount:
                # 1 = insert proběhl
                # 0 = conflict do nothing
                if cur.rowcount == 1:
                    inserted += 1
                    print(f"[{i}/{len(teams)}] INSERTED team_id={team_id} | {team.get('name')}")
                else:
                    skipped += 1
                    print(f"[{i}/{len(teams)}] SKIPPED team_id={team_id} | already exists")

                conn.commit()

            except Exception as e:
                conn.rollback()
                failed += 1
                print(f"[{i}/{len(teams)}] FAILED team_id={team_id} | {e}")

            time.sleep(SLEEP_BETWEEN_CALLS)

        print("-" * 60)
        print(f"Inserted: {inserted}")
        print(f"Skipped: {skipped}")
        print(f"Not found: {not_found}")
        print(f"Failed: {failed}")
        print("Done.")

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()