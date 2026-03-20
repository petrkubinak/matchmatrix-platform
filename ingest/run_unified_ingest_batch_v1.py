from __future__ import annotations

import argparse
import os
import json
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

import psycopg2


BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

UNIFIED_RUNNER = os.path.join(
    BASE_DIR,
    "ingest",
    "run_unified_ingest_v1.py"
)

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="MatchMatrix Unified Ingest Batch V1"
    )

    parser.add_argument("--provider", required=True)
    parser.add_argument("--sport", required=True)
    parser.add_argument("--entity", required=True)
    parser.add_argument("--run-group", required=True)

    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=300,
        help="Timeout pro jeden child ingest proces v sekundách."
    )

    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Limit počtu lig pro test"
    )

    parser.add_argument(
        "--max-workers",
        type=int,
        default=1,
        help="Počet paralelních workerů. Pro začátek doporučeno 3."
    )

    return parser.parse_args()


def load_db_connection():
    print("DB connection:")
    print(" host:", DB_CONFIG["host"])
    print(" port:", DB_CONFIG["port"])
    print(" db  :", DB_CONFIG["dbname"])
    print(" user:", DB_CONFIG["user"])

    return psycopg2.connect(**DB_CONFIG)


def load_targets(conn, provider, sport, run_group):
    sql = """
        SELECT
            provider_league_id,
            season
        FROM ops.ingest_targets
        WHERE provider = %s
          AND sport_code = %s
          AND run_group = %s
          AND enabled = true
        ORDER BY provider_league_id
    """

    with conn.cursor() as cur:
        cur.execute(sql, (provider, sport, run_group))
        rows = cur.fetchall()

    return rows

def create_job_run(conn, args) -> int:
    sql = """
        INSERT INTO ops.job_runs
        (
            job_code,
            started_at,
            status,
            params,
            message,
            details,
            rows_affected
        )
        VALUES
        (
            %s,
            NOW(),
            %s,
            %s::jsonb,
            %s,
            %s::jsonb,
            %s
        )
        RETURNING id
    """

    params = {
        "provider": args.provider,
        "sport": args.sport,
        "entity": args.entity,
        "run_group": args.run_group,
        "limit": args.limit,
        "timeout_sec": args.timeout_sec,
        "max_workers": args.max_workers,
    }

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                "unified_ingest_batch",
                "running",
                json.dumps(params),
                "Batch ingest started.",
                json.dumps({}),
                0,
            ),
        )
        job_run_id = cur.fetchone()[0]

    conn.commit()
    return job_run_id


def finish_job_run(conn, job_run_id: int, status: str, message: str, details: dict, rows_affected: int) -> None:
    sql = """
        UPDATE ops.job_runs
        SET
            finished_at = NOW(),
            status = %s,
            message = %s,
            details = %s::jsonb,
            rows_affected = %s
        WHERE id = %s
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                status,
                message,
                json.dumps(details),
                rows_affected,
                job_run_id,
            ),
        )

    conn.commit()

def detect_result(output_text: str, process_returncode: int) -> str:
    if "API errors" in output_text:
        return "ERROR"

    if "No fixtures returned." in output_text:
        return "WARNING"

    if "No teams returned." in output_text:
        return "WARNING"

    if "inserted into staging" in output_text:
        return "OK"

    if process_returncode != 0:
        return "ERROR"

    return "UNKNOWN"


def run_single(provider, sport, entity, league_id, season, timeout_sec):
    command = [
        PYTHON_EXE,
        UNIFIED_RUNNER,
        "--provider", provider,
        "--sport", sport,
        "--entity", entity,
        "--league-id", str(league_id),
        "--season", str(season),
    ]

    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        cwd=BASE_DIR
    )

    try:
        stdout_data, _ = process.communicate(timeout=timeout_sec)
        output_text = stdout_data or ""
        result = detect_result(output_text, process.returncode)

    except subprocess.TimeoutExpired:
        process.kill()
        stdout_data, _ = process.communicate()
        output_text = (stdout_data or "") + f"\nTIMEOUT after {timeout_sec} seconds."
        result = "ERROR"

    return {
        "league_id": league_id,
        "season": season,
        "result": result,
        "returncode": process.returncode,
        "command": command,
        "output_text": output_text,
    }


def print_job_result(job_result):
    print("-" * 70)
    print(f"LEAGUE ID: {job_result['league_id']} | SEASON: {job_result['season']}")
    print("RUN:", " ".join(job_result["command"]))
    print(job_result["output_text"])
    print("RESULT:", job_result["result"])


def main():
    args = parse_args()

    print("=" * 70)
    print("MATCHMATRIX UNIFIED INGEST BATCH V1")
    print("=" * 70)
    print("Provider   :", args.provider)
    print("Sport      :", args.sport)
    print("Entity     :", args.entity)
    print("RunGroup   :", args.run_group)
    print("MaxWorkers :", args.max_workers)

    if args.limit:
        print("Limit      :", args.limit)

    print("=" * 70)

    conn = load_db_connection()

    try:
        targets = load_targets(
            conn,
            args.provider,
            args.sport,
            args.run_group
        )

        total_found = len(targets)
        if args.limit:
            targets = targets[:args.limit]

        job_run_id = create_job_run(conn, args)

    finally:
        conn.close()

    total_found = len(targets)
    print("Targets found:", total_found)
    print()

    if args.limit:
        targets = targets[:args.limit]

    if not targets:
        print("Nebyl nalezen žádný aktivní target v ops.ingest_targets.")
        return 1

    stats = {
        "OK": 0,
        "WARNING": 0,
        "ERROR": 0,
        "UNKNOWN": 0,
    }

    league_results = []

    # Sekvenční režim
    if args.max_workers <= 1:
        for league_id, season in targets:
            job_result = run_single(
                args.provider,
                args.sport,
                args.entity,
                league_id,
                season,
                args.timeout_sec
            )
            stats[job_result["result"]] += 1

            league_results.append({
                "league_id": job_result["league_id"],
                "season": job_result["season"],
                "result": job_result["result"]
            })

            print_job_result(job_result)

    # Paralelní režim
    else:
        with ThreadPoolExecutor(max_workers=args.max_workers) as executor:
            futures = [
            executor.submit(
                run_single,
                args.provider,
                args.sport,
                args.entity,
                league_id,
                season,
                args.timeout_sec
            )
                for league_id, season in targets
            ]

            for future in as_completed(futures):
                job_result = future.result()
                stats[job_result["result"]] += 1

                league_results.append({
                    "league_id": job_result["league_id"],
                    "season": job_result["season"],
                    "result": job_result["result"]
                })

                print_job_result(job_result)

    print()
    print("=" * 70)
    print("BATCH SUMMARY")
    print("=" * 70)
    print(f"TARGETS TOTAL: {len(targets)}")
    for key, value in stats.items():
        print(f"{key:10s}: {value}")
    print("=" * 70)

    final_status = "ok"
    if stats["ERROR"] > 0:
        final_status = "error"
    elif stats["WARNING"] > 0:
        final_status = "warning"

    final_message = (
        f"Batch finished. OK={stats['OK']}, "
        f"WARNING={stats['WARNING']}, "
        f"ERROR={stats['ERROR']}, "
        f"UNKNOWN={stats['UNKNOWN']}"
    )

    details = {
        "stats": stats,
        "leagues": league_results,
        "provider": args.provider,
        "sport": args.sport,
        "entity": args.entity,
        "run_group": args.run_group,
        "limit": args.limit,
        "max_workers": args.max_workers,
        "timeout_sec": args.timeout_sec,
        "targets_found": total_found,
        "targets_processed": len(targets),
    }

    conn = load_db_connection()
    try:
        finish_job_run(
            conn=conn,
            job_run_id=job_run_id,
            status=final_status,
            message=final_message,
            details=details,
            rows_affected=len(targets),
        )
    finally:
        conn.close()

    return 1 if final_status == "error" else 0


if __name__ == "__main__":
    sys.exit(main())