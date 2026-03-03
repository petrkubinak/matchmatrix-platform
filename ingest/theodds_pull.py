import os
import requests
import psycopg2
from psycopg2.extras import Json
from datetime import datetime, timezone, timedelta

# Povinné proměnné prostředí (nastavuješ v .bat)
API_KEY = os.environ["THEODDS_API_KEY"]
DB_DSN = os.environ["DB_DSN"]

BASE = "https://api.the-odds-api.com/v4"

# Stabilní ligy (zatím 1 liga, ať nepálíš free limit)
SPORT_KEYS = [
    "soccer_epl",
]


def db():
    return psycopg2.connect(DB_DSN)


def start_run(conn, source: str) -> int:
    """Založí řádek v api_import_runs a vrátí run_id (kvůli NOT NULL v api_raw_payloads.run_id)."""
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.api_import_runs(source, status, started_at)
            VALUES (%s, %s, now())
            RETURNING id
            """,
            (source, "running"),
        )
        return int(cur.fetchone()[0])


def finish_run(conn, run_id: int, status: str, details=None) -> None:
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


def save_payload(conn, run_id: int, endpoint: str, payload) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO public.api_raw_payloads(run_id, source, endpoint, fetched_at, payload)
            VALUES (%s, 'theodds', %s, now(), %s)
            """,
            (run_id, endpoint, Json(payload)),
        )


def main():
    # Parametry z .bat (můžeš měnit bez zásahu do kódu)
    regions = os.getenv("ODDS_REGIONS", "uk")
    markets = os.getenv("ODDS_MARKETS", "h2h")
    days_ahead = int(os.getenv("ODDS_DAYS_AHEAD", "3"))

    print("Spoustim RAW import z TheOddsAPI...")
    print("SPORT_KEYS:", SPORT_KEYS)
    print("ODDS_REGIONS:", regions, "| ODDS_MARKETS:", markets, "| ODDS_DAYS_AHEAD:", days_ahead)

    conn = db()
    run_id = start_run(conn, "theodds")

    try:
        now = datetime.now(timezone.utc)
        to_time = now + timedelta(days=days_ahead)

        # TheOdds vyžaduje format 'YYYY-MM-DDTHH:MM:SSZ'
        now_str = now.strftime("%Y-%m-%dT%H:%M:%SZ")
        to_time_str = to_time.strftime("%Y-%m-%dT%H:%M:%SZ")

        total_events = 0

        for sport in SPORT_KEYS:
            endpoint = f"/sports/{sport}/odds"
            print("Fetching:", endpoint)

            r = requests.get(
                BASE + endpoint,
                params={
                    "apiKey": API_KEY,
                    "regions": regions,
                    "markets": markets,
                    "oddsFormat": "decimal",
                    "dateFormat": "iso",
                    "commenceTimeFrom": now_str,
                    "commenceTimeTo": to_time_str,
                },
                timeout=30,
            )

            print("Status:", r.status_code)
            # při ladění stačí pár znaků
            print("Response:", r.text[:300])

            if r.status_code != 200:
                print("ERROR:", r.status_code, sport)
                continue

            data = r.json()

            if not isinstance(data, list):
                print("Unexpected response type (expected list):", type(data))
                continue

            save_payload(conn, run_id, endpoint, data)
            total_events += len(data)
            print("Saved:", sport, "events:", len(data))

        finish_run(conn, run_id, "ok", {"sports": SPORT_KEYS, "total_events": total_events})
        conn.commit()
        print("DONE. total_events=", total_events)

    except Exception as e:
        # uložíme error do runu + commit, ať to vidíš v DB
        try:
            finish_run(conn, run_id, "error", {"error": str(e)})
            conn.commit()
        finally:
            raise

    finally:
        conn.close()


if __name__ == "__main__":
    main()
