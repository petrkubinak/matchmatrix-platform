# ============================================================
# run_bk_people_smoke_test_v1.py
# MatchMatrix - BK people smoke test
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_bk_people_smoke_test_v1.py
#
# Co dělá:
# - otestuje api_basketball players/coaches endpointy
# - nic nemerguje do public
# - uloží výsledek do ops.provider_people_audit
#
# Spuštění:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_bk_people_smoke_test_v1.py --entity players --league-id 12 --season 2024
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_bk_people_smoke_test_v1.py --entity coaches --league-id 12 --season 2024
# ============================================================

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from datetime import datetime

import psycopg2
import requests
from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parents[1]
ENV_PATHS = [
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

PROVIDER = "api_basketball"
SPORT = "BK"


def log(msg: str) -> None:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)


def load_env() -> Path:
    for env_path in ENV_PATHS:
        if env_path.exists():
            load_dotenv(dotenv_path=env_path)
            return env_path
    raise RuntimeError("Nenalezen žádný .env pro API-Basketball ani ingest.")


def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="BK people smoke test")
    parser.add_argument("--entity", required=True, choices=["players", "coaches"])
    parser.add_argument("--league-id", required=True)
    parser.add_argument("--season", required=True)
    parser.add_argument("--team-id", default=None)
    parser.add_argument("--timeout-sec", type=int, default=60)
    return parser.parse_args()


def get_api_config() -> tuple[str, str, dict]:
    base = (
        os.getenv("APISPORTS_BASKETBALL_BASE")
        or os.getenv("API_BASKETBALL_BASE")
        or os.getenv("BASKETBALL_API_BASE")
        or "https://v1.basketball.api-sports.io"
    ).strip().rstrip("/")

    key = (
        os.getenv("APISPORTS_KEY")
        or os.getenv("API_SPORTS_KEY")
        or os.getenv("APISPORTS_BASKETBALL_KEY")
        or os.getenv("API_BASKETBALL_KEY")
        or ""
    ).strip()

    if not key:
        raise RuntimeError("Chybí API key v .env. Hledám APISPORTS_KEY / API_SPORTS_KEY / API_BASKETBALL_KEY.")

    headers = {
        "x-apisports-key": key,
        "Accept": "application/json",
        "User-Agent": "MatchMatrix/bk-people-smoke-test-v1",
    }

    return base, key, headers


def build_candidate_requests(entity: str, league_id: str, season: str, team_id: str | None) -> list[tuple[str, dict]]:
    candidates: list[tuple[str, dict]] = []

    if entity == "players":
        candidates.append(("/players", {"league": league_id, "season": season}))
        if team_id:
            candidates.append(("/players", {"team": team_id, "season": season}))
            candidates.append(("/players", {"team": team_id}))
    elif entity == "coaches":
        if team_id:
            candidates.append(("/coachs", {"team": team_id}))
            candidates.append(("/coaches", {"team": team_id}))
        candidates.append(("/coachs", {"league": league_id, "season": season}))
        candidates.append(("/coaches", {"league": league_id, "season": season}))

    return candidates


def call_api(base: str, headers: dict, endpoint: str, params: dict, timeout_sec: int) -> tuple[int, str, dict | None]:
    url = f"{base}{endpoint}"
    response = requests.get(url, headers=headers, params=params, timeout=timeout_sec)

    try:
        payload = response.json()
    except Exception:
        payload = None

    return response.status_code, response.url, payload


def summarize_payload(payload: dict | None) -> tuple[int, dict]:
    if not isinstance(payload, dict):
        return 0, {"payload_type": str(type(payload))}

    response_data = payload.get("response")
    errors = payload.get("errors")
    paging = payload.get("paging")

    response_count = len(response_data) if isinstance(response_data, list) else 0

    return response_count, {
        "errors": errors,
        "paging": paging,
        "response_count": response_count,
        "keys": list(payload.keys()),
    }


def update_people_audit(
    entity: str,
    endpoint_name: str,
    ok: bool,
    tested: bool,
    returns_data: bool,
    note: str,
    next_step: str,
) -> None:
    sql = """
        UPDATE ops.provider_people_audit
        SET
            endpoint_name = %s,
            endpoint_exists = %s,
            endpoint_tested = %s,
            endpoint_returns_data = %s,
            technical_status = %s,
            final_verdict = %s,
            evidence_note = %s,
            next_step = %s,
            updated_at = NOW()
        WHERE provider = %s
          AND sport_code = %s
          AND entity = %s;
    """

    technical_status = "runtime_tested" if ok else "blocked"
    final_verdict = "RUNNABLE" if returns_data else ("WAIT_PROVIDER" if tested else "WAIT_TEST")

    conn = get_db_connection()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    sql,
                    (
                        endpoint_name,
                        ok,
                        tested,
                        returns_data,
                        technical_status,
                        final_verdict,
                        note,
                        next_step,
                        PROVIDER,
                        SPORT,
                        entity,
                    ),
                )
    finally:
        conn.close()


def main() -> int:
    args = parse_args()

    env_loaded = load_env()
    base, key, headers = get_api_config()

    log("=" * 80)
    log("MATCHMATRIX BK PEOPLE SMOKE TEST V1")
    log("=" * 80)
    log(f"ENV loaded : {env_loaded}")
    log(f"Provider   : {PROVIDER}")
    log(f"Sport      : {SPORT}")
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
        team_id=args.team_id,
    )

    best = {
        "endpoint": None,
        "params": None,
        "status": None,
        "url": None,
        "response_count": 0,
        "summary": {},
    }

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

            if response_count > best["response_count"]:
                best = {
                    "endpoint": endpoint,
                    "params": params,
                    "status": status,
                    "url": url,
                    "response_count": response_count,
                    "summary": summary,
                }

        except Exception as exc:
            log(f"ERROR: {exc}")

    returns_data = int(best["response_count"] or 0) > 0
    tested = True
    ok = returns_data

    if returns_data:
        note = (
            f"BK {args.entity} smoke test OK. "
            f"endpoint={best['endpoint']} params={best['params']} response_count={best['response_count']}"
        )
        next_step = "Připravit pull worker + staging parser pro BK people."
        endpoint_name = str(best["endpoint"])
    else:
        note = "BK people smoke test nenašel endpoint s daty pro zadaný league/season/team."
        next_step = "Zkusit smoke test s konkrétním team-id z BK team_provider_map nebo ověřit provider dokumentaci."
        endpoint_name = candidates[0][0] if candidates else f"/{args.entity}"

    update_people_audit(
        entity=args.entity,
        endpoint_name=endpoint_name,
        ok=ok,
        tested=tested,
        returns_data=returns_data,
        note=note,
        next_step=next_step,
    )

    log("=" * 80)
    log("RESULT")
    log("=" * 80)
    log(f"returns_data : {returns_data}")
    log(f"best_endpoint: {best['endpoint']}")
    log(f"best_params  : {best['params']}")
    log(f"best_count   : {best['response_count']}")
    log("=" * 80)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())