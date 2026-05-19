"""
run_people_pipeline_candidates_raw_pull_v1.py

Účel:
- RAW pull pro potvrzené PEOPLE kandidáty
- ukládá pouze do staging.stg_api_payloads
- neparsuje do public

Potvrzené větve:
- api_football / FB / players
- api_football / FB / coaches
- api_sport / BK / players
- api_american_football / AFB / players
"""

import os
import json
import hashlib
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

TARGETS = [
    {
        "provider": "api_football",
        "sport_code": "FB",
        "entity_type": "players",
        "endpoint_name": "players",
        "external_id": "league=39",
        "season": "2024",
        "url": "https://v3.football.api-sports.io/players?league=39&season=2024&page=1",
    },
    {
        "provider": "api_football",
        "sport_code": "FB",
        "entity_type": "coaches",
        "endpoint_name": "coachs",
        "external_id": "team=33",
        "season": None,
        "url": "https://v3.football.api-sports.io/coachs?team=33",
    },
    {
        "provider": "api_sport",
        "sport_code": "BK",
        "entity_type": "players",
        "endpoint_name": "players",
        "external_id": "team=139",
        "season": "2024-2025",
        "url": "https://v1.basketball.api-sports.io/players?team=139&season=2024-2025",
    },
    {
        "provider": "api_american_football",
        "sport_code": "AFB",
        "entity_type": "players",
        "endpoint_name": "players",
        "external_id": "team=1",
        "season": "2024",
        "url": "https://v1.american-football.api-sports.io/players?team=1&season=2024",
    },
]


def fetch_payload(url: str) -> dict:
    if not API_KEY:
        raise RuntimeError("Missing API key: APISPORTS_KEY / API_SPORTS_KEY / RAPIDAPI_KEY")

    req = urllib.request.Request(url)
    req.add_header("x-apisports-key", API_KEY)

    with urllib.request.urlopen(req, timeout=45) as response:
        raw = response.read().decode("utf-8", errors="replace")
        return json.loads(raw)


def payload_hash(payload: dict) -> str:
    payload_text = json.dumps(payload, sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(payload_text.encode("utf-8")).hexdigest()


def insert_raw_payload(conn, target: dict, payload: dict) -> int:
    h = payload_hash(payload)

    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO staging.stg_api_payloads (
                provider,
                sport_code,
                entity_type,
                endpoint_name,
                external_id,
                season,
                fetched_at,
                payload_json,
                payload_hash,
                parse_status,
                parse_message,
                created_at
            )
            VALUES (
                %s, %s, %s, %s, %s, %s, now(), %s::jsonb, %s, 'pending', %s, now()
            )
            RETURNING id;
            """,
            (
                target["provider"],
                target["sport_code"],
                target["entity_type"],
                target["endpoint_name"],
                target["external_id"],
                target["season"],
                json.dumps(payload, ensure_ascii=False),
                h,
                "RAW people candidate pull v1",
            ),
        )
        return cur.fetchone()[0]


def update_people_audit(conn, target: dict, ok: bool, count: int, msg: str) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.provider_people_audit
            SET
                evidence_note = %s,
                next_step = %s,
                updated_at = now()
            WHERE provider = %s
              AND sport_code = %s
              AND entity = %s;
            """,
            (
                f"RAW pull {datetime.now(timezone.utc).isoformat()} | {msg}",
                "RAW uložen do staging.stg_api_payloads. Další krok: parser do staging.stg_provider_players/coaches.",
                target["provider"],
                target["sport_code"],
                target["entity_type"],
            ),
        )


def main() -> None:
    print("=== MATCHMATRIX PEOPLE CANDIDATES RAW PULL V1 ===")

    with psycopg.connect(DB_DSN) as conn:
        for target in TARGETS:
            label = f"{target['provider']} | {target['sport_code']} | {target['entity_type']}"
            print(f"\n--- {label} ---")

            try:
                payload = fetch_payload(target["url"])
                response = payload.get("response", [])
                count = len(response) if isinstance(response, list) else 0

                raw_id = insert_raw_payload(conn, target, payload)

                msg = f"OK raw_payload_id={raw_id}; response_count={count}"
                print(msg)

                update_people_audit(conn, target, True, count, msg)

            except urllib.error.HTTPError as e:
                body = e.read().decode("utf-8", errors="replace")
                msg = f"HTTP ERROR {e.code}: {body[:300]}"
                print(msg)
                update_people_audit(conn, target, False, 0, msg)

            except Exception as e:
                msg = f"ERROR {type(e).__name__}: {e}"
                print(msg)
                update_people_audit(conn, target, False, 0, msg)

        conn.commit()

    print("\nDONE: RAW payloads saved to staging.stg_api_payloads.")


if __name__ == "__main__":
    main()