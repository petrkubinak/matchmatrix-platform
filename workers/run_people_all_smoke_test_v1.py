"""
run_people_all_smoke_test_v1.py

Účel:
- ověřit people endpointy pro další sporty
- nic neparsuje do public
- jen aktualizuje ops.provider_people_audit

Poznámka:
- API-Sport používá endpoint "coachs", ne "coaches"
"""

import os
import json
import urllib.request
import urllib.error
from datetime import datetime, timezone

import psycopg


DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"

API_KEY = (
    os.getenv("APISPORTS_KEY")
    or os.getenv("API_SPORTS_KEY")
    or os.getenv("RAPIDAPI_KEY")
)

TESTS = [
    # Hockey
    ("api_hockey", "HK", "players", "https://v1.hockey.api-sports.io/players?team=1&season=2024"),
    ("api_hockey", "HK", "coaches", "https://v1.hockey.api-sports.io/coachs?team=1"),

    # Volleyball
    ("api_volleyball", "VB", "players", "https://v1.volleyball.api-sports.io/players?team=1&season=2024"),
    ("api_volleyball", "VB", "coaches", "https://v1.volleyball.api-sports.io/coachs?team=1"),

    # Handball
    ("api_handball", "HB", "players", "https://v1.handball.api-sports.io/players?team=1&season=2024"),
    ("api_handball", "HB", "coaches", "https://v1.handball.api-sports.io/coachs?team=1"),

    # American football
    ("api_american_football", "AFB", "players", "https://v1.american-football.api-sports.io/players?team=1&season=2024"),
    ("api_american_football", "AFB", "coaches", "https://v1.american-football.api-sports.io/coachs?team=1"),

    # Baseball
    ("api_baseball", "BSB", "players", "https://v1.baseball.api-sports.io/players?team=1&season=2024"),
    ("api_baseball", "BSB", "coaches", "https://v1.baseball.api-sports.io/coachs?team=1"),

    # Rugby
    ("api_rugby", "RGB", "players", "https://v1.rugby.api-sports.io/players?team=1&season=2024"),
    ("api_rugby", "RGB", "coaches", "https://v1.rugby.api-sports.io/coachs?team=1"),

    # BK coaches scope retest
    ("api_sport", "BK", "coaches", "https://v1.basketball.api-sports.io/coachs?team=139"),
]


def fetch_json(url: str):
    if not API_KEY:
        return False, 0, "Missing API key env APISPORTS_KEY / API_SPORTS_KEY / RAPIDAPI_KEY"

    req = urllib.request.Request(url)
    req.add_header("x-apisports-key", API_KEY)

    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            raw = response.read().decode("utf-8", errors="replace")
            payload = json.loads(raw)

        items = payload.get("response", [])
        count = len(items) if isinstance(items, list) else 0
        return response.status == 200, count, f"HTTP {response.status}; response_count={count}"

    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return False, 0, f"HTTP ERROR {e.code}: {body[:400]}"

    except Exception as e:
        return False, 0, f"ERROR: {type(e).__name__}: {e}"


def update_audit(conn, provider, sport_code, entity, ok, count, message):
    if ok and count > 0:
        technical_status = "ENDPOINT_EXISTS"
        data_quality_status = "BASIC_OK"
        final_verdict = "ENDPOINT_EXISTS"
        alternative_provider_needed = False
        next_step = "Zařadit do společné people pipeline: RAW pull -> staging parser -> provider_map/public merge."
    elif ok:
        technical_status = "ENDPOINT_EXISTS_EMPTY"
        data_quality_status = "EMPTY_OR_BAD_SCOPE"
        final_verdict = "WAIT_SCOPE_FIX"
        alternative_provider_needed = True
        next_step = "Endpoint odpověděl, ale bez dat. Ověřit správné team/league/season parametry nebo hledat alternativního providera."
    else:
        technical_status = "BLOCKED_PROVIDER"
        data_quality_status = "UNKNOWN"
        final_verdict = "BLOCKED_PROVIDER"
        alternative_provider_needed = True
        next_step = "Endpoint není použitelný v aktuálním smoke testu. Ověřit dokumentaci/tarif, jinak hledat alternativního providera."

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.provider_people_audit
            SET
                endpoint_exists = %s,
                endpoint_tested = true,
                endpoint_returns_data = %s,
                technical_status = %s,
                data_quality_status = %s,
                final_verdict = %s,
                alternative_provider_needed = %s,
                evidence_note = %s,
                next_step = %s,
                updated_at = now()
            WHERE provider = %s
              AND sport_code = %s
              AND entity = %s;
            """,
            (
                ok,
                ok and count > 0,
                technical_status,
                data_quality_status,
                final_verdict,
                alternative_provider_needed,
                f"People ALL smoke test {datetime.now(timezone.utc).isoformat()} | {message}",
                next_step,
                provider,
                sport_code,
                entity,
            ),
        )


def main():
    print("=== MATCHMATRIX PEOPLE ALL SMOKE TEST V1 ===")

    with psycopg.connect(DB_DSN) as conn:
        for provider, sport_code, entity, url in TESTS:
            print(f"\n--- {provider} | {sport_code} | {entity} ---")
            ok, count, message = fetch_json(url)
            print(message)
            update_audit(conn, provider, sport_code, entity, ok, count, message)

        conn.commit()

    print("\nDONE: ops.provider_people_audit updated.")


if __name__ == "__main__":
    main()