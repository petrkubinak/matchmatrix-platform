# ============================================================
# MATCHMATRIX – MULTISPORT PLAYERS INGEST V1
# BSB / RGB / HB
# ============================================================

import sys
import requests
from contextlib import closing

from psycopg2.extras import RealDictCursor

import pull_api_football_players_v4 as base_players


PROVIDER_MAP = {
    "BSB": "api_baseball",
    "RGB": "api_rugby",
    "HB": "api_handball",
}

API_BASE_MAP = {
    "BSB": "https://v1.baseball.api-sports.io",
    "RGB": "https://v1.rugby.api-sports.io",
    "HB": "https://v1.handball.api-sports.io",
}


def run_players_ingest(sport_code: str) -> int:
    sport_code = sport_code.upper().strip()

    if sport_code not in PROVIDER_MAP:
        print("Použití: python workers\\run_players_multisport_v1.py BSB|RGB|HB")
        return 1

    provider = PROVIDER_MAP[sport_code]
    api_base = API_BASE_MAP[sport_code]

    # Přepíšeme globální konstanty v původním FB workeru
    base_players.PROVIDER_CODE = provider
    base_players.SPORT_CODE = sport_code
    base_players.API_BASE = api_base
    base_players.ENTITY = "players"

    print("===========================================")
    print("MATCHMATRIX – MULTISPORT PLAYERS INGEST V1")
    print(f"SPORT    : {sport_code}")
    print(f"PROVIDER : {provider}")
    print(f"API BASE : {api_base}")
    print("===========================================")

    api_key = base_players.get_api_key()
    headers = base_players.get_api_headers(api_key)
    session = requests.Session()

    with closing(base_players.get_db_connection()) as conn:
        conn.autocommit = False

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            jobs = base_players.claim_planner_jobs(cur, limit=1)
            conn.commit()

        if not jobs:
            print("Žádné pending players joby.")
            return 0

        print(f"Nalezeno jobů: {len(jobs)}")

        for job in jobs:
            planner_id = job["id"]

            try:
                base_players.process_job(
                    conn=conn,
                    session=session,
                    job=job,
                    headers=headers,
                    request_sleep_sec=1.5,
                )

            except Exception as e:
                conn.rollback()

                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    base_players.mark_job_error(cur, planner_id)
                    conn.commit()

                print(f"CHYBA JOB {planner_id}: {e}")

    print("HOTOVO.")
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Použití: python workers\\run_players_multisport_v1.py BSB|RGB|HB")
        raise SystemExit(1)

    raise SystemExit(run_players_ingest(sys.argv[1]))