# ============================================================
# run_bk_api_sport_people_smoke_test_v1.py
# MatchMatrix - API-Sport Basketball people smoke test
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_bk_api_sport_people_smoke_test_v1.py
#
# Co dělá:
# - testuje BK players/coaches přes api_sport / basketball
# - nic nemerguje
# - pouze ověří endpointy a aktualizuje ops.provider_people_audit
#
# Spuštění:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_bk_api_sport_people_smoke_test_v1.py --entity players --league-id 117 --season 2023-2024 --team-id 2329
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_bk_api_sport_people_smoke_test_v1.py --entity coaches --league-id 117 --season 2023-2024 --team-id 2329
# ============================================================

from __future__ import annotations

import argparse
import json
import os
from datetime import datetime
from pathlib import Path

import psycopg2
import requests
from dotenv import load_dotenv


BASE_DIR = Path(r"C:\MatchMatrix-platform")

ENV_PATHS = [
    BASE_DIR / "ingest" / "API-Sport" / ".env",
    BASE_DIR / "ingest" / "API-Basketball" / ".env",
    BASE_DIR / "ingest" / ".env",
]

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

PROVIDER = "api_sport"
SPORT_CODE_AUDIT = "BK"
SPORT_CODE_STAGING = "basketball"


def log(msg: str) -> None:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="BK api_sport people smoke test")
    parser.add_argument("--entity", required=True, choices=["players", "coaches"])
    parser.add_argument("--league-id", required=True)
    parser.add_argument("--season", required=True)
    parser.add_argument("--team-id", required=True)
    parser.add_argument("--timeout-sec", type=int, default=60)
    return parser.parse_args()


def load_env() -> Path:
    for env_path in ENV_PATHS:
        if env_path.exists():
            load_dotenv(dotenv_path=env_path)
            return env_path

    raise RuntimeError(
        "Nenalezen .env. Hledané cesty: "
        + ", ".join(str(p) for p in ENV_PATHS)
    )


def get_api_config() -> tuple[str, dict]:
    base = (
        os.getenv("APISPORTS_BASKETBALL_BASE")
        or os.getenv("API_BASKETBALL_BASE")
        or os.getenv("BASKETBALL_API_BASE")
        or os.getenv("APISPORT_BASKETBALL_BASE")
        or "https://v1.basketball.api-sports.io"
    ).strip().rstrip("/")

    api_key = (
        os.getenv("APISPORTS_KEY")
        or os.getenv("API_SPORTS_KEY")
        or os.getenv("APISPORTS_BASKETBALL_KEY")
        or os.getenv("API_BASKETBALL_KEY")
        or ""
    ).strip()

    rapid_key = (
        os.getenv("RAPIDAPI_KEY")
        or os.getenv("X_RAPIDAPI_KEY")
        or ""
    ).strip()

    rapid_host = (
        os.getenv("RAPIDAPI_BASKETBALL_HOST")
        or os.getenv("API_BASKETBALL_HOST")
        or ""
    ).strip()

    if api_key:
        headers = {
            "x-apisports-key": api_key,
            "Accept": "application/json",
            "User-Agent": "MatchMatrix/bk-api-sport-people-smoke-test-v1",
        }
        return base, headers

    if rapid_key and rapid_host:
        headers = {
            "X-RapidAPI-Key": rapid_key,
            "X-RapidAPI-Host": rapid_host,
            "Accept": "application/json",
            "User-Agent": "MatchMatrix/bk-api-sport-people-smoke-test-v1",
        }
        return base, headers

    raise RuntimeError(
        "Chybí API key v .env. Hledám APISPORTS_KEY / API_SPORTS_KEY "
        "nebo RAPIDAPI_KEY + RAPIDAPI_BASKETBALL_HOST."
    )


def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)


def build_candidate_requests(entity: str, league_id: str, season: str, team_id: str) -> list[tuple[str, dict]]:
    candidates: list[tuple[str, dict]] = []

    if entity == "players":
        candidates.extend([
            ("/players", {"team": team_id, "season": season}),
            ("/players", {"team": team_id}),
            ("/players", {"league": league_id, "season": season}),
            ("/players", {"league": league_id}),
        ])

    if entity == "coaches":
        candidates.extend([
            ("/coachs", {"team": team_id}),
            ("/coaches", {"team": team_id}),
            ("/coachs", {"league": league_id, "season": season}),
            ("/coaches", {"league": league_id, "season": season}),
            ("/coachs", {"league": league_id}),
            ("/coaches", {"league": league_id}),
        ])

    return candidates


def call_api(base: str, headers: dict, endpoint: str, params: dict, timeout_sec: int) -> tuple[int, str, dict | None]:
    url = f"{base}{endpoint}"

    response = requests.get(
        url,
        headers=headers,
        params=params,
        timeout=timeout_sec,
    )

    try:
        payload = response.json()
    except Exception:
        payload = None

    return response.status_code, response.url, payload


def summarize_payload(payload: dict | None) -> tuple[int, dict]:
    if not isinstance(payload, dict):
        return 0, {
            "payload_type": str(type(payload)),
            "response_count": 0,
        }

    response_data = payload.get("response")
    errors = payload.get("errors")
    paging = payload.get("paging")
    parameters = payload.get("parameters")

    response_count = len(response_data) if isinstance(response_data, list) else 0

    return response_count, {
        "keys": list(payload.keys()),
        "parameters": parameters,
        "errors": errors,
        "paging": paging,
        "response_count": response_count,
    }


def update_people_audit(
    entity: str,
    endpoint_name: str,
    returns_data: bool,
    evidence_note: str,
    next_step: str,
) -> None:
    sql = """
        UPDATE ops.provider_people_audit
        SET
            endpoint_name = %s,
            endpoint_exists = TRUE,
            endpoint_tested = TRUE,
            endpoint_returns_data = %s,
            technical_status = %s,
            data_quality_status = %s,
            final_verdict = %s,
            evidence_note = %s,
            next_step = %s,
            updated_at = NOW()
        WHERE provider = %s
          AND sport_code = %s
          AND entity = %s;
    """

    if returns_data:
        technical_status = "runtime_tested"
        data_quality_status = "SMOKE_OK"
        final_verdict = "RUNNABLE"
    else:
        technical_status = "runtime_tested"
        data_quality_status = "NO_DATA"
        final_verdict = "WAIT_PROVIDER"

    conn = get_db_connection()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    sql,
                    (
                        endpoint_name,
                        returns_data,
                        technical_status,
                        data_quality_status,
                        final_verdict,
                        evidence_note,
                        next_step,
                        PROVIDER,
                        SPORT_CODE_AUDIT,
                        entity,
                    ),
                )
    finally:
        conn.close()


def main() -> int:
    args = parse_args()

    env_loaded = load_env()
    base, headers = get_api_config()

    log("=" * 80)
    log("MATCHMATRIX BK API-SPORT PEOPLE SMOKE TEST V1")
    log("=" * 80)
    log(f"ENV loaded : {env_loaded}")
    log(f"Provider   : {PROVIDER}")
    log(f"Sport audit: {SPORT_CODE_AUDIT}")
    log(f"Sport data : {SPORT_CODE_STAGING}")
    log(f"Entity     : {args.entity}")
    log(f"Base       : {base}")
    log(f"League ID  : {args.league_id}")
    log(f"Season     : {args.season}")
    log(f"Team ID    : {args.team_id}")
    log("=" * 80)

    candidates = build_candidate_requests(
        entity=args.entity,
        league_id=str(args.league_id),
        season=str(args.season),
        team_id=str(args.team_id),
    )

    best_endpoint = ""
    best_params: dict = {}
    best_url = ""
    best_status = None
    best_count = 0
    best_summary: dict = {}

    for endpoint, params in candidates:
        log("-" * 80)
        log(f"TEST endpoint={endpoint} params={params}")

        try:
            status, url, payload = call_api(
                base=base,
                headers=headers,
                endpoint=endpoint,
                params=params,
                timeout_sec=args.timeout_sec,
            )

            response_count, summary = summarize_payload(payload)

            log(f"HTTP STATUS    : {status}")
            log(f"URL            : {url}")
            log(f"RESPONSE COUNT : {response_count}")
            log(f"SUMMARY        : {json.dumps(summary, ensure_ascii=False)[:2000]}")

            if response_count > best_count:
                best_endpoint = endpoint
                best_params = params
                best_url = url
                best_status = status
                best_count = response_count
                best_summary = summary

        except Exception as exc:
            log(f"ERROR: {exc}")

    returns_data = best_count > 0

    if returns_data:
        evidence_note = (
            f"BK {args.entity} smoke test OK. "
            f"endpoint={best_endpoint}; params={best_params}; response_count={best_count}; url={best_url}"
        )
        next_step = "Připravit pull worker + parser pro api_sport/BK people."
        endpoint_name = best_endpoint
    else:
        evidence_note = (
            f"BK {args.entity} smoke test bez dat. "
            f"Testováno league={args.league_id}, season={args.season}, team={args.team_id}."
        )
        next_step = "Ověřit jiný endpoint/provider nebo jiný team/league/season."
        endpoint_name = f"/{args.entity}"

    update_people_audit(
        entity=args.entity,
        endpoint_name=endpoint_name,
        returns_data=returns_data,
        evidence_note=evidence_note,
        next_step=next_step,
    )

    log("=" * 80)
    log("RESULT")
    log("=" * 80)
    log(f"returns_data : {returns_data}")
    log(f"best_endpoint: {best_endpoint}")
    log(f"best_params  : {best_params}")
    log(f"best_status  : {best_status}")
    log(f"best_count   : {best_count}")
    log(f"best_summary : {json.dumps(best_summary, ensure_ascii=False)[:2000]}")
    log("=" * 80)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())