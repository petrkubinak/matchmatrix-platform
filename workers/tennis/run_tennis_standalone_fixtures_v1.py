"""
MATCHMATRIX WORKER 19_3_Q
TN Standalone Tennis Fixtures Worker V1

CO TO JE:
- Samostatný worker pro TN CORE fixtures.
- Nahrazuje chybné routování přes GenericApiSportProvider / API-Sport.

K ČEMU TO JE:
- Tennis nesmí běžet přes pull_api_sport_fixtures.ps1.
- Tento worker zpracuje planner joby:
  provider = tennis_standalone
  sport_code = TN
  entity = fixtures
  run_group = PC2_CORE_TN_STANDALONE

KDE TO UVIDÍME:
- PC2 Command Center
- ops.ingest_planner
- budoucí Tennis Core harvest

JAK SE TO VYUŽIJE:
- Panel spustí tento worker.
- Worker najde pending ATP/WTA joby.
- Zatím provede bezpečný CLAIM + ověření routingu.
- Pokud nebude nalezen konkrétní tennis puller, zapíše ROUTING_ERROR s jasnou zprávou.
"""

from __future__ import annotations

import argparse
import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime

try:
    import psycopg2
except ImportError:
    print("ERROR: Chybí knihovna psycopg2. Nainstaluj: pip install psycopg2-binary")
    sys.exit(2)


BASE_DIR = Path(__file__).resolve().parents[2]
PYTHON_EXE = sys.executable


def get_conn():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "matchmatrix"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", "postgres"),
    )


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


def find_existing_tennis_puller() -> Path | None:
    candidates = [
        BASE_DIR / "workers" / "tennis" / "pull_tennis_fixtures_v1.py",
        BASE_DIR / "workers" / "tennis" / "pull_rapidapi_tennis_fixtures_v1.py",
        BASE_DIR / "workers" / "tennis" / "pull_api_tennis_fixtures_v1.py",
        BASE_DIR / "ingest" / "tennis" / "pull_tennis_fixtures_v1.py",
        BASE_DIR / "ingest" / "Tennis" / "pull_tennis_fixtures_v1.py",
    ]

    for path in candidates:
        if path.exists():
            return path

    return None


def run_existing_puller(puller: Path, league_id: str, season: str, run_group: str) -> int:
    cmd = [
        PYTHON_EXE,
        str(puller),
        "--league-id",
        league_id,
        "--season",
        season,
        "--run-group",
        run_group,
    ]

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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--season", default="2024")
    parser.add_argument("--run-group", default="PC2_CORE_TN_STANDALONE")
    parser.add_argument("--limit", type=int, default=10)
    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX TN STANDALONE TENNIS FIXTURES WORKER V1")
    print("=" * 80)
    print(f"BASE_DIR  : {BASE_DIR}")
    print(f"PYTHON_EXE: {PYTHON_EXE}")
    print(f"RUN_GROUP : {args.run_group}")
    print(f"SEASON    : {args.season}")
    print(f"LIMIT     : {args.limit}")
    print("=" * 80)

    puller = find_existing_tennis_puller()

    if puller:
        print(f"TENNIS PULLER FOUND: {puller}")
    else:
        print("TENNIS PULLER NOT FOUND.")
        print("Worker provede CLAIM a zapíše routing_error, aby bylo jasné, co doplnit.")

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

            if not puller:
                finish_job(
                    conn,
                    job_id,
                    "routing_error",
                    (
                        "RESULT: ROUTING_ERROR | Chybí konkrétní tennis puller. "
                        "Doplň jeden z podporovaných souborů: "
                        "workers/tennis/pull_tennis_fixtures_v1.py nebo "
                        "workers/tennis/pull_rapidapi_tennis_fixtures_v1.py"
                    ),
                )
                errors += 1
                continue

            rc = run_existing_puller(puller, str(league_id), str(season), str(run_group))

            if rc == 0:
                finish_job(conn, job_id, "done", "RESULT: OK")
                processed += 1
            else:
                finish_job(conn, job_id, "failed", f"RESULT: ERROR | return_code={rc}")
                errors += 1

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