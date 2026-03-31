from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

import psycopg2


PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
PULL_SCRIPT = PROJECT_ROOT / "ingest" / "API-Sport" / "pull_api_basketball_players.ps1"

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": int(os.getenv("POSTGRES_PORT", "5432")),
    "dbname": os.getenv("POSTGRES_DB", "matchmatrix"),
    "user": os.getenv("POSTGRES_USER", "matchmatrix"),
    "password": os.getenv("POSTGRES_PASSWORD", "matchmatrix_pass"),
}


def log(msg: str) -> None:
    print(msg, flush=True)


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def load_json_file(path: Path) -> dict:
    raw = path.read_bytes()

    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]

    text = raw.decode("utf-8", errors="replace").lstrip("\ufeff").strip()
    return json.loads(text)


def fetch_targets(limit: int) -> list[dict]:
    sql = """
        SELECT
            id,
            provider,
            sport_code,
            provider_league_id,
            season,
            run_group
        FROM ops.ingest_targets
        WHERE enabled = TRUE
          AND provider = 'api_sport'
          AND sport_code = 'BK'
          AND provider_league_id IS NOT NULL
          AND BTRIM(provider_league_id) <> ''
        ORDER BY
            CASE WHEN season IS NULL THEN 1 ELSE 0 END,
            season DESC NULLS LAST,
            id
        LIMIT %s
    """

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(sql, (limit,))
            rows = cur.fetchall()
    finally:
        conn.close()

    result = []
    for row in rows:
        result.append(
            {
                "target_id": row[0],
                "provider": row[1],
                "sport_code": row[2],
                "league_id": str(row[3]) if row[3] is not None else "",
                "season": str(row[4]) if row[4] is not None else "",
                "run_group": row[5] or "",
            }
        )
    return result


def insert_payload(
    run_id: str,
    endpoint: str,
    league_id: str,
    season: str,
    payload_obj: dict,
) -> None:
    sql = """
        INSERT INTO staging.stg_api_payloads
        (
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            payload_json,
            parse_status,
            parse_message,
            created_at
        )
        VALUES
        (
            %s, %s, %s, %s, %s, %s, %s::jsonb, %s, %s, NOW()
        )
    """

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                sql,
                (
                    "api_sport",
                    "BK",
                    "players",
                    endpoint,
                    league_id or None,
                    season or None,
                    json.dumps(payload_obj, ensure_ascii=False),
                    "pending",
                    f"run_id={run_id}",
                ),
            )
        conn.commit()
    finally:
        conn.close()


def run_pull(league_id: str, season: str, run_id: str, raw_out: Path) -> None:
    cmd = [
        "powershell",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(PULL_SCRIPT),
        "-LeagueId",
        league_id,
        "-Season",
        season,
        "-RunId",
        run_id,
        "-OutputPath",
        str(raw_out),
    ]

    log("RUN: " + " ".join(cmd))
    completed = subprocess.run(cmd, check=False)

    if completed.returncode != 0:
        raise RuntimeError(f"Pull script failed with exit code {completed.returncode}")


def main() -> int:
    parser = argparse.ArgumentParser(description="MatchMatrix BK players fetch only v1")
    parser.add_argument("--limit", type=int, default=3, help="Kolik targetů vzít z DB")
    args = parser.parse_args()

    if not PULL_SCRIPT.exists():
        raise FileNotFoundError(f"Chybí pull script: {PULL_SCRIPT}")

    raw_dir = PROJECT_ROOT / "logs" / "bk_players_raw"
    raw_dir.mkdir(parents=True, exist_ok=True)

    log("=== MATCHMATRIX: BK PLAYERS FETCH ONLY V1 ===")

    targets = fetch_targets(limit=args.limit)
    if not targets:
        log("Nenalezen žádný BK target v ops.ingest_targets.")
        return 1

    log(f"Targets loaded: {len(targets)}")

    ok = 0
    fail = 0

    for item in targets:
        target_id = item["target_id"]
        league_id = item["league_id"]
        season = item["season"]

        if not season:
            log(f"SKIP target_id={target_id} league_id={league_id} :: missing season")
            continue

        run_id = f"BK_PLAYERS_{target_id}_{season}"
        raw_out = raw_dir / f"bk_players_target_{target_id}_league_{league_id}_season_{season}.json"

        try:
            log("-" * 80)
            log(f"TARGET id={target_id} league_id={league_id} season={season}")

            run_pull(
                league_id=league_id,
                season=season,
                run_id=run_id,
                raw_out=raw_out,
            )

            if not raw_out.exists():
                raise RuntimeError(f"Output JSON nebyl vytvořen: {raw_out}")

            payload_obj = load_json_file(raw_out)
            response_count = payload_obj.get("results", None)
            endpoint_name = str(payload_obj.get("get", "players"))

            insert_payload(
                run_id=run_id,
                endpoint=endpoint_name,
                league_id=league_id,
                season=season,
                payload_obj=payload_obj,
            )

            log(f"DB OK target_id={target_id} results={response_count}")
            ok += 1

        except Exception as exc:
            log(f"FAIL target_id={target_id} :: {exc}")
            fail += 1

    log("=" * 80)
    log(f"DONE ok={ok} fail={fail}")
    return 0 if ok > 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())