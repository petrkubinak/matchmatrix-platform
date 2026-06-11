"""
MATCHMATRIX WORKER 19_3_R
TN Standalone Tennis Fixtures Worker V2

CO TO JE:
- Samostatný worker pro TN CORE fixtures.
- Opravuje routing TN mimo GenericApiSportProvider/API-Sport.
- Umí použít existující puller:
  C:\\MatchMatrix-platform\\ingest\\API-Tennis\\pull_api_tennis_fixtures_v1.py
- Po pullu se pokusí spustit parser:
  C:\\MatchMatrix-platform\\ingest\\API-Tennis\\parse_api_tennis_fixtures_v1.py

K ČEMU TO JE:
- Tennis nesmí běžet přes pull_api_sport_fixtures.ps1.
- Worker zpracuje planner joby provider=tennis_standalone, sport_code=TN, entity=fixtures.

KDE TO UVIDÍME:
- PC2 Command Center
- ops.ingest_planner
- staging.api_tennis_fixtures_raw
- staging.api_tennis_fixtures

JAK SE TO VYUŽIJE:
- Panel spustí tento worker.
- Worker claimne ATP/WTA joby.
- Spustí existující API-Tennis puller.
- Najde nový run_id v RAW tabulce.
- Spustí parser nad tímto run_id.
- Zapíše DONE / FAILED / ROUTING_ERROR do ops.ingest_planner.
"""

from __future__ import annotations

import argparse
import importlib.util
import os
import subprocess
import sys
from pathlib import Path

try:
    import psycopg2
except ImportError:
    print("ERROR: Chybí knihovna psycopg2. Nainstaluj: pip install psycopg2-binary")
    sys.exit(2)


BASE_DIR = Path(__file__).resolve().parents[2]
PYTHON_EXE = sys.executable

TENNIS_PULLER = BASE_DIR / "ingest" / "API-Tennis" / "pull_api_tennis_fixtures_v1.py"
TENNIS_PARSER = BASE_DIR / "ingest" / "API-Tennis" / "parse_api_tennis_fixtures_v1.py"


def get_conn():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "matchmatrix"),
        password=os.getenv("PGPASSWORD", "matchmatrix_pass"),
    )


def get_latest_raw_run_id(conn) -> int | None:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT max(run_id)
            FROM staging.api_tennis_fixtures_raw
            WHERE provider = 'api_tennis'
              AND sport_code = 'TN'
            """
        )
        value = cur.fetchone()[0]
        return int(value) if value is not None else None


def claim_jobs(conn, run_group: str, limit: int):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id, provider, sport_code, entity, provider_league_id, season, run_group
            FROM ops.ingest_planner
            WHERE provider = 'tennis_standalone'
              AND sport_code = 'TN'
              AND entity = 'fixtures'
              AND run_group = %s
              AND status = 'pending'
              AND next_run <= now()
            ORDER BY priority, id
            LIMIT %s
            FOR UPDATE SKIP LOCKED
            """,
            (run_group, limit),
        )
        jobs = cur.fetchall()

        for job in jobs:
            cur.execute(
                """
                UPDATE ops.ingest_planner
                SET
                    status = 'running',
                    attempts = attempts + 1,
                    last_attempt = now(),
                    updated_at = now()
                WHERE id = %s
                """,
                (job[0],),
            )

    conn.commit()
    return jobs


def finish_job(conn, job_id: int, status: str, message: str):
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.ingest_planner
            SET
                status = %s,
                updated_at = now()
            WHERE id = %s
            """,
            (status, job_id),
        )
    conn.commit()
    print(message)


def run_pull_script() -> int:
    if not TENNIS_PULLER.exists():
        print(f"TENNIS PULLER NOT FOUND: {TENNIS_PULLER}")
        return 99

    cmd = [PYTHON_EXE, str(TENNIS_PULLER)]
    print("RUN TENNIS PULLER:")
    print(" ".join(cmd))

    proc = subprocess.run(
        cmd,
        cwd=str(BASE_DIR),
        text=True,
        capture_output=True,
        timeout=300,
    )

    if proc.stdout:
        print(proc.stdout)
    if proc.stderr:
        print(proc.stderr)

    return proc.returncode


def run_parser_module(run_id: int) -> bool:
    if not TENNIS_PARSER.exists():
        print(f"TENNIS PARSER NOT FOUND: {TENNIS_PARSER}")
        return False

    print(f"RUN TENNIS PARSER MODULE: {TENNIS_PARSER}")
    print(f"PARSER RUN_ID: {run_id}")

    spec = importlib.util.spec_from_file_location("parse_api_tennis_fixtures_v1", str(TENNIS_PARSER))
    if spec is None or spec.loader is None:
        print("ERROR: Parser module nelze načíst.")
        return False

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    if not hasattr(module, "run"):
        print("ERROR: Parser nemá funkci run(run_id).")
        return False

    module.run(run_id)
    return True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--season", default="2024")
    parser.add_argument("--run-group", default="PC2_CORE_TN_STANDALONE")
    parser.add_argument("--limit", type=int, default=10)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX TN STANDALONE TENNIS FIXTURES WORKER V2")
    print("=" * 80)
    print(f"BASE_DIR  : {BASE_DIR}")
    print(f"PYTHON_EXE: {PYTHON_EXE}")
    print(f"RUN_GROUP : {args.run_group}")
    print(f"SEASON    : {args.season}")
    print(f"LIMIT     : {args.limit}")
    print(f"PULLER    : {TENNIS_PULLER}")
    print(f"PARSER    : {TENNIS_PARSER}")
    print("=" * 80)

    conn = get_conn()

    try:
        jobs = claim_jobs(conn, args.run_group, args.limit)

        if not jobs:
            print("Žádné pending TN standalone joby.")
            return 0

        processed = 0
        errors = 0

        for job in jobs:
            job_id, provider, sport_code, entity, league_id, season, run_group = job

            print("=" * 80)
            print("TN JOB CLAIMED")
            print("=" * 80)
            print(f"planner_id        : {job_id}")
            print(f"provider          : {provider}")
            print(f"sport_code        : {sport_code}")
            print(f"entity            : {entity}")
            print(f"provider_league_id: {league_id}")
            print(f"season            : {season}")
            print(f"run_group         : {run_group}")

            if not TENNIS_PULLER.exists():
                finish_job(
                    conn,
                    job_id,
                    "routing_error",
                    f"RESULT: ROUTING_ERROR | Chybí tennis puller: {TENNIS_PULLER}",
                )
                errors += 1
                continue

            before_run_id = get_latest_raw_run_id(conn)
            print(f"RAW RUN_ID BEFORE: {before_run_id}")

            rc = run_pull_script()
            if rc != 0:
                finish_job(conn, job_id, "failed", f"RESULT: ERROR | puller return_code={rc}")
                errors += 1
                continue

            after_run_id = get_latest_raw_run_id(conn)
            print(f"RAW RUN_ID AFTER : {after_run_id}")

            if after_run_id is None or after_run_id == before_run_id:
                finish_job(
                    conn,
                    job_id,
                    "failed",
                    "RESULT: ERROR | Puller doběhl, ale nevznikl nový RAW run_id.",
                )
                errors += 1
                continue

            parser_ok = run_parser_module(after_run_id)
            if not parser_ok:
                finish_job(conn, job_id, "failed", "RESULT: ERROR | Parser failed or missing.")
                errors += 1
                continue

            finish_job(conn, job_id, "done", f"RESULT: OK | raw_run_id={after_run_id}")
            processed += 1

        print("=" * 80)
        print("WORKER SUMMARY")
        print("=" * 80)
        print(f"Processed OK: {processed}")
        print(f"Errors      : {errors}")

        return 0 if errors == 0 else 1

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())
