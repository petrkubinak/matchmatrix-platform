from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from typing import Any, Dict, Optional

import psycopg2
from psycopg2.extras import RealDictCursor


# ==========================================================
# MATCHMATRIX
# INGEST PLANNER WORKER V1
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py
#
# Spuštění:
# python C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py
#
# Příklad:
# python C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py --limit 10
# python C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py --limit 50 --timeout-sec 300
# python C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py --loop --poll-sec 30
# ==========================================================


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


# ----------------------------------------------------------
# ARGUMENTS
# ----------------------------------------------------------
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="MatchMatrix Ingest Planner Worker V1"
    )

    parser.add_argument(
        "--limit",
        type=int,
        default=10,
        help="Maximální počet planner jobů ke zpracování v jednom běhu."
    )

    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=300,
        help="Timeout pro jeden child ingest proces v sekundách."
    )

    parser.add_argument(
        "--poll-sec",
        type=int,
        default=30,
        help="Interval polling loopu v sekundách při --loop."
    )

    parser.add_argument(
        "--loop",
        action="store_true",
        help="Nepřetržitý polling planner fronty."
    )

    parser.add_argument(
        "--provider",
        default=None,
        help="Volitelný filtr provideru, např. api_football"
    )

    parser.add_argument(
        "--sport",
        default=None,
        help="Volitelný filtr sportu, např. football"
    )

    parser.add_argument(
        "--entity",
        default=None,
        help="Volitelný filtr entity, např. fixtures"
    )

    parser.add_argument(
        "--run-group",
        default=None,
        help="Volitelný filtr run_group, např. FREE_TEST_PRIMARY"
    )

    parser.add_argument(
        "--max-attempts",
        type=int,
        default=3,
        help="Maximální počet pokusů. Job nad limit už se nebude znovu brát."
    )

    return parser.parse_args()


# ----------------------------------------------------------
# DB
# ----------------------------------------------------------
def get_connection():
    return psycopg2.connect(**DB_CONFIG)


# ----------------------------------------------------------
# LOGIKA DETEKCE VÝSLEDKU
# ----------------------------------------------------------
def detect_result(output_text: str, process_returncode: int) -> str:
    """
    Převod výstupu child procesu na logický výsledek.
    Vrací: OK / WARNING / ERROR / UNKNOWN
    """

    text = output_text or ""

    if "FATAL ERROR:" in text:
        return "ERROR"

    if "NOT IMPLEMENTED:" in text:
        return "ERROR"

    if "API errors" in text:
        return "ERROR"

    if "Unified ingest finished with ERROR." in text:
        return "ERROR"

    if "No fixtures returned." in text:
        return "WARNING"

    if "No teams returned." in text:
        return "WARNING"

    if "Unified ingest finished with WARNING." in text:
        return "WARNING"

    if "Unified ingest finished OK." in text:
        return "OK"

    if process_returncode == 0:
        return "OK"

    if process_returncode != 0:
        return "ERROR"

    return "UNKNOWN"


# ----------------------------------------------------------
# JOB_RUNS AUDIT
# ----------------------------------------------------------
def create_job_run(conn, planner_row: Dict[str, Any]) -> int:
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
        "planner_id": planner_row["id"],
        "provider": planner_row["provider"],
        "sport": planner_row["sport_code"],
        "entity": planner_row["entity"],
        "provider_league_id": planner_row["provider_league_id"],
        "season": planner_row["season"],
        "run_group": planner_row["run_group"],
        "priority": planner_row["priority"],
        "attempts": planner_row["attempts"],
    }

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                "ingest_planner_worker",
                "running",
                json.dumps(params),
                "Planner job started.",
                json.dumps({}),
                0,
            ),
        )
        job_run_id = cur.fetchone()[0]

    conn.commit()
    return job_run_id


def finish_job_run(
    conn,
    job_run_id: int,
    status: str,
    message: str,
    details: dict,
    rows_affected: int = 1,
) -> None:
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


# ----------------------------------------------------------
# PLANNER QUEUE
# ----------------------------------------------------------
def claim_next_planner_job(
    conn,
    provider: Optional[str],
    sport: Optional[str],
    entity: Optional[str],
    run_group: Optional[str],
    max_attempts: int,
) -> Optional[Dict[str, Any]]:
    """
    Vezme 1 pending planner job a atomicky ho přepne na running.
    Používá FOR UPDATE SKIP LOCKED, takže je připravené i pro budoucí paralelní workery.
    """
    sql = """
        WITH next_job AS (
            SELECT p.id
            FROM ops.ingest_planner p
            WHERE p.status = 'pending'
              AND COALESCE(p.attempts, 0) < %s
              AND (%s IS NULL OR p.provider = %s)
              AND (%s IS NULL OR p.sport_code = %s)
              AND (%s IS NULL OR p.entity = %s)
              AND (%s IS NULL OR p.run_group = %s)
              AND (
                    p.next_run IS NULL
                    OR p.next_run <= NOW()
                  )
            ORDER BY
                COALESCE(p.priority, 999999),
                p.id
            FOR UPDATE SKIP LOCKED
            LIMIT 1
        )
        UPDATE ops.ingest_planner p
        SET
            status = 'running',
            attempts = COALESCE(p.attempts, 0) + 1,
            last_attempt = NOW(),
            updated_at = NOW()
        FROM next_job
        WHERE p.id = next_job.id
        RETURNING
            p.id,
            p.provider,
            p.sport_code,
            p.entity,
            p.provider_league_id,
            p.season,
            p.run_group,
            p.priority,
            p.status,
            p.attempts,
            p.last_attempt,
            p.next_run,
            p.created_at,
            p.updated_at
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            sql,
            (
                max_attempts,
                provider, provider,
                sport, sport,
                entity, entity,
                run_group, run_group,
            ),
        )
        row = cur.fetchone()

    conn.commit()
    return row


def mark_planner_done(conn, planner_id: int) -> None:
    sql = """
        UPDATE ops.ingest_planner
        SET
            status = 'done',
            next_run = NULL,
            updated_at = NOW()
        WHERE id = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (planner_id,))
    conn.commit()


def mark_planner_error(
    conn,
    planner_id: int,
    retry_after_minutes: Optional[int] = None,
) -> None:
    """
    Při chybě necháme status='error'.
    Volitelně lze nastavit next_run pro pozdější ruční/automatický retry.
    """
    if retry_after_minutes is None:
        sql = """
            UPDATE ops.ingest_planner
            SET
                status = 'error',
                updated_at = NOW()
            WHERE id = %s
        """
        params = (planner_id,)
    else:
        sql = """
            UPDATE ops.ingest_planner
            SET
                status = 'error',
                next_run = NOW() + (%s || ' minutes')::interval,
                updated_at = NOW()
            WHERE id = %s
        """
        params = (retry_after_minutes, planner_id)

    with conn.cursor() as cur:
        cur.execute(sql, params)
    conn.commit()


def mark_planner_pending_again(
    conn,
    planner_id: int,
    retry_after_minutes: int = 10,
) -> None:
    """
    Varianta pro WARNING / dočasný stav:
    job vrátíme do pending a posuneme next_run.
    """
    sql = """
        UPDATE ops.ingest_planner
        SET
            status = 'pending',
            next_run = NOW() + (%s || ' minutes')::interval,
            updated_at = NOW()
        WHERE id = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (retry_after_minutes, planner_id))
    conn.commit()


# ----------------------------------------------------------
# CHILD PROCESS
# ----------------------------------------------------------
def build_command(planner_row: Dict[str, Any]) -> list[str]:
    sport_map = {
        "FB": "football",
        "HK": "hockey",
        "BK": "basketball",
        "TN": "tennis",
        "MMA": "mma",
        "VB": "volleyball",
        "HB": "handball",
        "BSB": "baseball",
        "RGB": "rugby",
        "CK": "cricket",
        "FH": "field_hockey",
        "AFB": "american_football",
        "ESP": "esports",
    }

    planner_sport = str(planner_row["sport_code"])
    ingest_sport = sport_map.get(planner_sport, planner_sport.lower())

    command = [
        PYTHON_EXE,
        UNIFIED_RUNNER,
        "--provider", str(planner_row["provider"]),
        "--sport", ingest_sport,
        "--entity", str(planner_row["entity"]),
    ]

    if planner_row.get("provider_league_id") not in (None, ""):
        command.extend(["--league-id", str(planner_row["provider_league_id"])])

    if planner_row.get("season") not in (None, ""):
        command.extend(["--season", str(planner_row["season"])])

    if planner_row.get("run_group") not in (None, ""):
        command.extend(["--run-group", str(planner_row["run_group"])])

    return command


def run_child_process(command: list[str], timeout_sec: int) -> Dict[str, Any]:
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
        timed_out = False

    except subprocess.TimeoutExpired:
        process.kill()
        stdout_data, _ = process.communicate()
        output_text = (stdout_data or "") + f"\nTIMEOUT after {timeout_sec} seconds."
        result = "ERROR"
        timed_out = True

    return {
        "returncode": process.returncode,
        "output_text": output_text,
        "result": result,
        "timed_out": timed_out,
        "command": command,
    }


# ----------------------------------------------------------
# PROCESS 1 JOB
# ----------------------------------------------------------
def process_single_job(args: argparse.Namespace) -> bool:
    """
    Zpracuje jeden planner job.
    Vrací True pokud byl nějaký job zpracován, jinak False.
    """

    conn = get_connection()
    try:
        planner_row = claim_next_planner_job(
            conn=conn,
            provider=args.provider,
            sport=args.sport,
            entity=args.entity,
            run_group=args.run_group,
            max_attempts=args.max_attempts,
        )
    finally:
        conn.close()

    if not planner_row:
        return False

    planner_id = planner_row["id"]

    print("=" * 80)
    print("PLANNER JOB CLAIMED")
    print("=" * 80)
    print(f"planner_id        : {planner_row['id']}")
    print(f"provider          : {planner_row['provider']}")
    print(f"sport             : {planner_row['sport_code']}")
    print(f"entity            : {planner_row['entity']}")
    print(f"provider_league_id: {planner_row['provider_league_id']}")
    print(f"season            : {planner_row['season']}")
    print(f"run_group         : {planner_row['run_group']}")
    print(f"priority          : {planner_row['priority']}")
    print(f"attempts          : {planner_row['attempts']}")
    print("=" * 80)

    conn = get_connection()
    try:
        job_run_id = create_job_run(conn, planner_row)
    finally:
        conn.close()

    command = build_command(planner_row)

    print("RUN:", " ".join(command))
    child = run_child_process(command, args.timeout_sec)

    print("-" * 80)
    print(child["output_text"])
    print("-" * 80)
    print("RESULT:", child["result"])
    print("RETURNCODE:", child["returncode"])
    print("-" * 80)

    details = {
        "planner_id": planner_id,
        "provider": planner_row["provider"],
        "sport": planner_row["sport_code"],
        "entity": planner_row["entity"],
        "provider_league_id": planner_row["provider_league_id"],
        "season": planner_row["season"],
        "run_group": planner_row["run_group"],
        "priority": planner_row["priority"],
        "attempts_after_claim": planner_row["attempts"],
        "command": child["command"],
        "returncode": child["returncode"],
        "result": child["result"],
        "timed_out": child["timed_out"],
        "output_text": child["output_text"],
    }

    # Planner status + job_runs status
    # planner: pending / running / done / error
    # job_runs: ok / warning / error
    if child["result"] == "OK":
        conn = get_connection()
        try:
            mark_planner_done(conn, planner_id)
            finish_job_run(
                conn=conn,
                job_run_id=job_run_id,
                status="ok",
                message="Planner job finished OK.",
                details=details,
                rows_affected=1,
            )
        finally:
            conn.close()

    elif child["result"] == "WARNING":
        # WARNING často znamená dočasný nebo prázdný výsledek.
        # Vrátíme job zpět do pending za 10 minut.
        conn = get_connection()
        try:
            mark_planner_pending_again(conn, planner_id, retry_after_minutes=10)
            finish_job_run(
                conn=conn,
                job_run_id=job_run_id,
                status="warning",
                message="Planner job finished with WARNING. Re-queued to pending.",
                details=details,
                rows_affected=1,
            )
        finally:
            conn.close()

    else:
        conn = get_connection()
        try:
            mark_planner_error(conn, planner_id)
            finish_job_run(
                conn=conn,
                job_run_id=job_run_id,
                status="error",
                message="Planner job finished with ERROR.",
                details=details,
                rows_affected=1,
            )
        finally:
            conn.close()

    return True


# ----------------------------------------------------------
# MAIN
# ----------------------------------------------------------
def print_header(args: argparse.Namespace) -> None:
    print("=" * 80)
    print("MATCHMATRIX INGEST PLANNER WORKER V1")
    print("=" * 80)
    print("BASE_DIR     :", BASE_DIR)
    print("PYTHON_EXE   :", PYTHON_EXE)
    print("RUNNER       :", UNIFIED_RUNNER)
    print("LIMIT        :", args.limit)
    print("TIMEOUT SEC  :", args.timeout_sec)
    print("LOOP         :", args.loop)
    print("POLL SEC     :", args.poll_sec)
    print("PROVIDER     :", args.provider)
    print("SPORT        :", args.sport)
    print("ENTITY       :", args.entity)
    print("RUN GROUP    :", args.run_group)
    print("MAX ATTEMPTS :", args.max_attempts)
    print("=" * 80)


def main() -> int:
    args = parse_args()
    print_header(args)

    if not os.path.exists(UNIFIED_RUNNER):
        print(f"ERROR: Unified runner nebyl nalezen: {UNIFIED_RUNNER}")
        return 1

    processed_count = 0

    if not args.loop:
        for _ in range(args.limit):
            has_job = process_single_job(args)
            if not has_job:
                print("Planner queue je prázdná nebo nic neodpovídá filtrům.")
                break
            processed_count += 1

        print("=" * 80)
        print("WORKER SUMMARY")
        print("=" * 80)
        print("Processed jobs:", processed_count)
        print("=" * 80)
        return 0

    # Loop režim
    while True:
        cycle_processed = 0

        for _ in range(args.limit):
            has_job = process_single_job(args)
            if not has_job:
                break
            cycle_processed += 1
            processed_count += 1

        print("=" * 80)
        print("LOOP CYCLE SUMMARY")
        print("=" * 80)
        print("Processed in cycle:", cycle_processed)
        print("Processed total   :", processed_count)
        print("=" * 80)

        if cycle_processed == 0:
            print(f"Žádný planner job. Čekám {args.poll_sec} sekund...")
            time.sleep(args.poll_sec)


if __name__ == "__main__":
    sys.exit(main())