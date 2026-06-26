# ============================================================================
# MATCHMATRIX 19_5_AL
# AUTONOMOUS HARVEST LOOP V1
#
# KAM ULOŽIT:
#   C:\MatchMatrix-platform\workers\ops\
#
# NÁZEV SOUBORU:
#   19_5_AL_autonomous_harvest_loop_v1.py
#
# CO TO JE:
#   Bezpečná autonomní harvest smyčka pro PC2 / OPS panel.
#
# K ČEMU TO JE:
#   Bere další akce z ops.v_automation_ready_queue_v4, spouští workery
#   a při chybě zapisuje problém do ops.fix_tasks.
#
# KDE TO UVIDÍME:
#   OPS Panel, Autonomní OPS, runtime výstup terminálu, fix_tasks.
#
# JAK SE TO VYUŽIJE:
#   Systém může stahovat data podle priorit sportů a entit.
#   Když narazí na problém, nezastaví se, ale přeskočí na další bezpečný úkol.
# ============================================================================

import argparse
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import psycopg2
import psycopg2.extras


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = r"C:\Python314\python.exe"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}


def db_connect():
    return psycopg2.connect(**DB_CONFIG)


def fetch_next_candidates(conn, limit: int):
    sql = """
        SELECT
            sport_code,
            sport_name,
            entity,
            candidate_provider,
            primary_provider,
            fallback_provider,
            runtime_execution_state,
            run_group,
            resolved_worker_script,
            provider_route_state,
            provider_gap,
            runtime_state,
            production_readiness,
            source_endpoint,
            target_table,
            next_action,
            provider_priority,
            fetch_priority,
            merge_priority,
            routing_rank
        FROM ops.v_automation_ready_queue_v4
        WHERE runtime_execution_state = 'CAN_RUN_NOW_RUNTIME'
          AND resolved_worker_script IS NOT NULL
          AND TRIM(resolved_worker_script) <> ''
          AND COALESCE(provider_gap, '') <> 'GAP_NO_WORKER'
        ORDER BY
            routing_rank,
            provider_priority,
            fetch_priority,
            merge_priority
        LIMIT %s
    """

    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(sql, (limit,))
        return cur.fetchall()


def insert_fix_task(conn, row, message: str, suggested_fix: str):
    sql = """
        INSERT INTO ops.fix_tasks (
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            parse_status,
            severity,
            short_message,
            full_message,
            suggested_fix,
            task_status,
            source_system,
            created_at
        )
        VALUES (
            %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NOW()
        )
    """

    provider = row.get("candidate_provider") or row.get("primary_provider")
    sport_code = row.get("sport_code")
    entity = row.get("entity")
    endpoint = row.get("source_endpoint") or entity

    short_message = f"AUTONOMOUS HARVEST FAILED: {provider}/{sport_code}/{entity}"

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                provider,
                sport_code,
                entity,
                endpoint,
                "error",
                "HIGH",
                short_message[:500],
                message[:4000],
                suggested_fix[:4000],
                "OPEN",
                "19_5_AL_autonomous_harvest_loop_v1",
            ),
        )

    conn.commit()


def build_command(row, dry_run: bool):
    worker_script = str(row["resolved_worker_script"]).replace("/", os.sep)
    worker_path = BASE_DIR / worker_script

    if not worker_path.exists():
        raise FileNotFoundError(f"Worker neexistuje: {worker_path}")

    cmd = [PYTHON_EXE, str(worker_path)]

    sport_code = row.get("sport_code")
    entity = row.get("entity")
    run_group = row.get("run_group")

    # Speciální bezpečný režim pro people pipeline.
    if "run_people_pipeline_v22_from_planner.py" in worker_script:
        if sport_code:
            cmd += ["--sport", str(sport_code)]
        if entity:
            cmd += ["--entity", str(entity)]
        if run_group:
            cmd += ["--run-group", str(run_group)]
        cmd += ["--limit", "10"]

    # Obecný ingest cycle zatím spouštíme bez extra parametrů.
    # Je bezpečnější nehádat parametry, dokud nepotvrdíme jeho CLI.
    elif "run_ingest_cycle_v3.py" in worker_script:
        pass

    return cmd


def run_candidate(row, dry_run: bool, timeout_sec: int):
    cmd = build_command(row, dry_run)

    print("=" * 90)
    print("AUTONOMOUS HARVEST CANDIDATE")
    print(f"SPORT      : {row.get('sport_code')}")
    print(f"ENTITY     : {row.get('entity')}")
    print(f"PROVIDER   : {row.get('candidate_provider')}")
    print(f"RUN GROUP  : {row.get('run_group')}")
    print(f"WORKER     : {row.get('resolved_worker_script')}")
    print(f"COMMAND    : {' '.join(cmd)}")

    if dry_run:
        print("DRY RUN    : command not executed")
        return 0, "DRY_RUN_OK"

    completed = subprocess.run(
        cmd,
        cwd=str(BASE_DIR),
        capture_output=True,
        text=True,
        timeout=timeout_sec,
        shell=False,
    )

    output = ""
    if completed.stdout:
        output += completed.stdout
    if completed.stderr:
        output += "\nSTDERR:\n" + completed.stderr

    print(output[-5000:])
    print(f"RETURN CODE: {completed.returncode}")

    return completed.returncode, output


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=5)
    parser.add_argument("--timeout", type=int, default=900)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    print("=" * 90)
    print("MATCHMATRIX 19_5_AL - AUTONOMOUS HARVEST LOOP V1")
    print("=" * 90)
    print(f"LIMIT   : {args.limit}")
    print(f"TIMEOUT : {args.timeout}")
    print(f"DRY RUN : {args.dry_run}")
    print("-" * 90)

    conn = db_connect()

    ok_count = 0
    fail_count = 0
    skipped_count = 0

    try:
        candidates = fetch_next_candidates(conn, args.limit)
        print(f"CANDIDATES LOADED: {len(candidates)}")

        if not candidates:
            print("Žádná bezpečná akce k běhu.")
            return 0

        for row in candidates:
            try:
                return_code, output = run_candidate(
                    row=row,
                    dry_run=args.dry_run,
                    timeout_sec=args.timeout,
                )

                if return_code == 0:
                    ok_count += 1
                else:
                    fail_count += 1
                    insert_fix_task(
                        conn,
                        row,
                        message=output,
                        suggested_fix=(
                            "Prověřit worker, provider scope, run_group, API odpověď "
                            "a případně vrátit úkol zpět do fronty po opravě."
                        ),
                    )

            except Exception as e:
                fail_count += 1
                message = str(e)
                print(f"ERROR: {message}")

                try:
                    insert_fix_task(
                        conn,
                        row,
                        message=message,
                        suggested_fix=(
                            "Ověřit resolved_worker_script, parametry workeru, "
                            "existenci souboru a provider scope."
                        ),
                    )
                except Exception as fix_error:
                    print(f"FIX TASK INSERT FAILED: {fix_error}")

                continue

        print("-" * 90)
        print("SUMMARY")
        print(f"OK      : {ok_count}")
        print(f"FAILED  : {fail_count}")
        print(f"SKIPPED : {skipped_count}")
        print("DONE")

        return 0

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())