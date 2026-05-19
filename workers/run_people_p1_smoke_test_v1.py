"""
run_people_p1_smoke_test_v1.py

Účel:
- smoke test P1 people endpointů:
  1) api_football / FB / players
  2) api_football / FB / coaches
  3) api_sport / BK / players
  4) api_sport / BK / coaches

Důležité:
- nestahuje produkční data
- neparsuje do public
- pouze ověří HTTP odpověď + počet položek v response
- aktualizuje ops.provider_people_audit
"""

import os
import json
import urllib.request
import urllib.error
import psycopg
from datetime import datetime, timezone


# FIX: natvrdo DSN bez závislosti na rozbitém ENV
DB_DSN = "host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass"

API_KEY = (
    os.getenv("APISPORTS_KEY")
    or os.getenv("API_SPORTS_KEY")
    or os.getenv("RAPIDAPI_KEY")
)

TESTS = [
    {
        "provider": "api_football",
        "sport_code": "FB",
        "entity": "players",
        "url": "https://v3.football.api-sports.io/players?league=39&season=2024&page=1",
        "host_header": None,
        "key_header": "x-apisports-key",
    },
    {
        "provider": "api_football",
        "sport_code": "FB",
        "entity": "coaches",
        "url": "https://v3.football.api-sports.io/coachs?team=33",
        "host_header": None,
        "key_header": "x-apisports-key",
    },
    {
        "provider": "api_sport",
        "sport_code": "BK",
        "entity": "players",
        "url": "https://v1.basketball.api-sports.io/players?team=139&season=2024-2025",
        "host_header": None,
        "key_header": "x-apisports-key",
    },
    {
        "provider": "api_sport",
        "sport_code": "BK",
        "entity": "coaches",
        "url": "https://v1.basketball.api-sports.io/coachs?team=139",
        "host_header": None,
        "key_header": "x-apisports-key",
    },
]


def fetch_json(test: dict) -> tuple[bool, int, str, dict]:
    if not API_KEY:
        return False, 0, "Missing API key env APISPORTS_KEY / API_SPORTS_KEY / RAPIDAPI_KEY", {}

    req = urllib.request.Request(test["url"])
    req.add_header(test["key_header"], API_KEY)

    if test.get("host_header"):
        req.add_header("x-rapidapi-host", test["host_header"])

    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            status_code = response.status
            raw = response.read().decode("utf-8", errors="replace")
            payload = json.loads(raw)

        items = payload.get("response", [])
        count = len(items) if isinstance(items, list) else 0

        ok = status_code == 200
        msg = f"HTTP {status_code}; response_count={count}"
        return ok, count, msg, payload

    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return False, 0, f"HTTP ERROR {e.code}: {body[:500]}", {}

    except Exception as e:
        return False, 0, f"ERROR: {type(e).__name__}: {e}", {}


def update_audit(conn, test: dict, ok: bool, count: int, message: str) -> None:
    endpoint_exists = ok
    endpoint_tested = True
    endpoint_returns_data = ok and count > 0

    if endpoint_returns_data:
        technical_status = "ENDPOINT_EXISTS"
        data_quality_status = "BASIC_OK"
        final_verdict = "ENDPOINT_EXISTS"
        alternative_provider_needed = False
        next_step = "Připravit RAW pull + parser do staging.stg_provider_players/coaches."
    elif ok:
        technical_status = "ENDPOINT_EXISTS_EMPTY"
        data_quality_status = "EMPTY_OR_BAD_SCOPE"
        final_verdict = "WAIT_SCOPE_FIX"
        alternative_provider_needed = True
        next_step = "Endpoint odpověděl, ale bez dat. Ověřit league/team/season parametry nebo jiný provider."
    else:
        technical_status = "BLOCKED_PROVIDER"
        data_quality_status = "UNKNOWN"
        final_verdict = "BLOCKED_PROVIDER"
        alternative_provider_needed = True
        next_step = "Ověřit API dokumentaci / tarif / název endpointu. Pokud se nepotvrdí, hledat alternativního providera."

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.provider_people_audit
            SET
                endpoint_exists = %s,
                endpoint_tested = %s,
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
                endpoint_exists,
                endpoint_tested,
                endpoint_returns_data,
                technical_status,
                data_quality_status,
                final_verdict,
                alternative_provider_needed,
                f"People P1 smoke test {datetime.now(timezone.utc).isoformat()} | {message}",
                next_step,
                test["provider"],
                test["sport_code"],
                test["entity"],
            ),
        )


def main() -> None:
    print("=== MATCHMATRIX PEOPLE P1 SMOKE TEST V1 ===")

    with psycopg.connect(DB_DSN) as conn:
        for test in TESTS:
            label = f"{test['provider']} | {test['sport_code']} | {test['entity']}"
            print(f"\n--- {label} ---")

            ok, count, message, _payload = fetch_json(test)
            print(message)

            update_audit(conn, test, ok, count, message)

        conn.commit()

    print("\nDONE: ops.provider_people_audit updated.")


if __name__ == "__main__":
    main()