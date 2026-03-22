from __future__ import annotations

import argparse
import json
import os
import socket
import subprocess
import sys
from datetime import datetime
from typing import Optional, Tuple

import psycopg2
from psycopg2.extras import RealDictCursor


# ==========================================================
# MATCHMATRIX
# INGEST CYCLE V3
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py
#
# Co dělá:
# 1) získá worker lock
# 2) vytvoří audit do ops.job_runs
# 3) spustí planner worker
# 4) pokud planner něco zpracoval, spustí merge worker
# 5) zapíše výsledek cyklu do ops.job_runs
# 6) uvolní worker lock
#
# Spuštění:
# python C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py
#
# Příklad:
# python C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py --limit 10
# python C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py --provider api_football --sport football --limit 5
# python C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py --skip-merge
# ==========================================================


BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

PLANNER_WORKER = os.path.join(BASE_DIR, "workers", "run_ingest_planner_jobs.py")
MERGE_WORKER = os.path.join(BASE_DIR, "workers", "run_unified_staging_to_public_merge_v3.py")
TEAMS_EXTRACTOR = os.path.join(BASE_DIR, "workers", "extract_teams_from_fixtures_v2.py")
PLAYERS_PIPELINE = os.path.join(BASE_DIR, "workers", "run_players_fetch_only_v1.py")
PLAYERS_PARSE = os.path.join(BASE_DIR, "workers", "run_players_parse_only_v1.py")
LOCK_NAME = "ingest_cycle_v3"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

LOCK_NAME = "ingest_cycle_v3"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="MatchMatrix Ingest Cycle V3"
    )

    parser.add_argument(
        "--limit",
        type=int,
        default=10,
        help="Maximální počet planner jobů ke zpracování v jednom cyklu."
    )

    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=300,
        help="Timeout pro planner worker child ingest proces."
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
        help="Volitelný filtr run_group, např. FOOTBALL_MAINTENANCE"
    )

    parser.add_argument(
        "--max-attempts",
        type=int,
        default=3,
        help="Maximální počet pokusů planner jobu."
    )

    parser.add_argument(
        "--skip-merge",
        action="store_true",
        help="Pouze planner worker, bez merge kroku."
    )

    parser.add_argument(
        "--lock-ttl-minutes",
        type=int,
        default=120,
        help="Doba platnosti worker locku v minutách."
    )

    return parser.parse_args()


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def get_owner_id() -> str:
    host = socket.gethostname()
    pid = os.getpid()
    ts = datetime.now().strftime("%Y%m%d%H%M%S")
    return f"{host}:{pid}:{ts}"


def run_command(command: list[str], title: str) -> Tuple[int, str]:
    print("=" * 80)
    print(title)
    print("=" * 80)
    print("RUN:", " ".join(command))
    print("=" * 80)

    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        cwd=BASE_DIR
    )

    stdout_data, _ = process.communicate()
    output_text = stdout_data or ""

    print(output_text)
    print("=" * 80)
    print(f"{title} RETURNCODE:", process.returncode)
    print("=" * 80)

    return process.returncode, output_text


def build_planner_command(args: argparse.Namespace) -> list[str]:
    command = [
        PYTHON_EXE,
        PLANNER_WORKER,
        "--limit", str(args.limit),
        "--timeout-sec", str(args.timeout_sec),
        "--max-attempts", str(args.max_attempts),
    ]

    if args.provider:
        command.extend(["--provider", args.provider])

    if args.sport:
        command.extend(["--sport", args.sport])

    if args.entity:
        command.extend(["--entity", args.entity])

    if args.run_group:
        command.extend(["--run-group", args.run_group])

    return command


def build_teams_extractor_command() -> list[str]:
    return [
        PYTHON_EXE,
        TEAMS_EXTRACTOR,
    ]

def build_players_pipeline_command() -> list[str]:
    return [
        PYTHON_EXE,
        PLAYERS_PIPELINE,
    ]

def build_players_parse_command() -> list[str]:
    return [
        PYTHON_EXE,
        PLAYERS_PARSE,
    ]  

def build_merge_command() -> list[str]:
    return [
        PYTHON_EXE,
        MERGE_WORKER,
    ]

def parse_processed_jobs(output_text: str) -> int:
    marker = "Processed jobs:"
    for line in output_text.splitlines():
        if marker in line:
            try:
                return int(line.split(marker, 1)[1].strip())
            except Exception:
                return 0
    return 0


def acquire_lock(conn, lock_name: str, owner_id: str, ttl_minutes: int) -> bool:
    """
    Získá lock, pokud:
    - neexistuje
    - nebo je expirovaný
    - nebo už patří stejnému ownerovi
    """
    sql = """
        INSERT INTO ops.worker_locks
        (
            lock_name,
            owner_id,
            acquired_at,
            expires_at,
            heartbeat_at,
            note,
            created_at,
            updated_at
        )
        VALUES
        (
            %s,
            %s,
            NOW(),
            NOW() + (%s || ' minutes')::interval,
            NOW(),
            %s,
            NOW(),
            NOW()
        )
        ON CONFLICT (lock_name)
        DO UPDATE
        SET
            owner_id = EXCLUDED.owner_id,
            acquired_at = CASE
                WHEN ops.worker_locks.expires_at IS NULL
                     OR ops.worker_locks.expires_at <= NOW()
                     OR ops.worker_locks.owner_id = EXCLUDED.owner_id
                THEN NOW()
                ELSE ops.worker_locks.acquired_at
            END,
            expires_at = CASE
                WHEN ops.worker_locks.expires_at IS NULL
                     OR ops.worker_locks.expires_at <= NOW()
                     OR ops.worker_locks.owner_id = EXCLUDED.owner_id
                THEN NOW() + (%s || ' minutes')::interval
                ELSE ops.worker_locks.expires_at
            END,
            heartbeat_at = CASE
                WHEN ops.worker_locks.expires_at IS NULL
                     OR ops.worker_locks.expires_at <= NOW()
                     OR ops.worker_locks.owner_id = EXCLUDED.owner_id
                THEN NOW()
                ELSE ops.worker_locks.heartbeat_at
            END,
            note = CASE
                WHEN ops.worker_locks.expires_at IS NULL
                     OR ops.worker_locks.expires_at <= NOW()
                     OR ops.worker_locks.owner_id = EXCLUDED.owner_id
                THEN EXCLUDED.note
                ELSE ops.worker_locks.note
            END,
            updated_at = NOW()
        WHERE
            ops.worker_locks.expires_at IS NULL
            OR ops.worker_locks.expires_at <= NOW()
            OR ops.worker_locks.owner_id = EXCLUDED.owner_id
        RETURNING owner_id
    """

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                lock_name,
                owner_id,
                ttl_minutes,
                f"Ingest cycle V3 lock owner {owner_id}",
                ttl_minutes,
            ),
        )
        row = cur.fetchone()

    conn.commit()
    return row is not None


def heartbeat_lock(conn, lock_name: str, owner_id: str, ttl_minutes: int) -> None:
    sql = """
        UPDATE ops.worker_locks
        SET
            expires_at = NOW() + (%s || ' minutes')::interval,
            heartbeat_at = NOW(),
            updated_at = NOW()
        WHERE lock_name = %s
          AND owner_id = %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (ttl_minutes, lock_name, owner_id))
    conn.commit()


def release_lock(conn, lock_name: str, owner_id: str) -> None:
    sql = """
        UPDATE ops.worker_locks
        SET
            expires_at = NOW() - interval '1 second',
            heartbeat_at = NOW(),
            note = %s,
            updated_at = NOW()
        WHERE lock_name = %s
          AND owner_id = %s
    """
    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                f"Released by {owner_id}",
                lock_name,
                owner_id,
            ),
        )
    conn.commit()


def create_job_run(conn, args: argparse.Namespace, owner_id: str) -> int:
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
        "limit": args.limit,
        "timeout_sec": args.timeout_sec,
        "provider": args.provider,
        "sport": args.sport,
        "entity": args.entity,
        "run_group": args.run_group,
        "max_attempts": args.max_attempts,
        "skip_merge": args.skip_merge,
        "lock_ttl_minutes": args.lock_ttl_minutes,
        "lock_name": LOCK_NAME,
        "owner_id": owner_id,
    }

    with conn.cursor() as cur:
        cur.execute(
            sql,
            (
                "ingest_cycle_v3",
                "running",
                json.dumps(params),
                "Ingest cycle V3 started.",
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
    rows_affected: int,
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


def print_header(args: argparse.Namespace, owner_id: str) -> None:
    print("=" * 80)
    print("MATCHMATRIX INGEST CYCLE V3")
    print("=" * 80)
    print("TEAMS EXTRACTOR  :", TEAMS_EXTRACTOR)
    print("BASE_DIR         :", BASE_DIR)
    print("PYTHON_EXE       :", PYTHON_EXE)
    print("PLANNER          :", PLANNER_WORKER)
    print("MERGE            :", MERGE_WORKER)
    print("LIMIT            :", args.limit)
    print("TIMEOUT SEC      :", args.timeout_sec)
    print("PROVIDER         :", args.provider)
    print("SPORT            :", args.sport)
    print("ENTITY           :", args.entity)
    print("RUN GROUP        :", args.run_group)
    print("MAX ATTEMPTS     :", args.max_attempts)
    print("SKIP MERGE       :", args.skip_merge)
    print("LOCK NAME        :", LOCK_NAME)
    print("LOCK TTL MINUTES :", args.lock_ttl_minutes)
    print("OWNER ID         :", owner_id)
    print("=" * 80)


def main() -> int:
    args = parse_args()
    owner_id = get_owner_id()
    print_header(args, owner_id)

    if not os.path.exists(PLANNER_WORKER):
        print(f"ERROR: Planner worker nebyl nalezen: {PLANNER_WORKER}")
        return 1

    if not os.path.exists(MERGE_WORKER):
        print(f"ERROR: Merge worker nebyl nalezen: {MERGE_WORKER}")
        return 1

    if not os.path.exists(TEAMS_EXTRACTOR):
        print(f"ERROR: Teams extractor nebyl nalezen: {TEAMS_EXTRACTOR}")
        return 1

    if not os.path.exists(PLAYERS_PIPELINE):
        print(f"ERROR: Players pipeline nebyl nalezen: {PLAYERS_PIPELINE}")
        return 1

    if not os.path.exists(PLAYERS_PARSE):
        print(f"ERROR: Players parse nebyl nalezen: {PLAYERS_PARSE}")
        return 1
    
    conn = get_connection()
    try:
        lock_ok = acquire_lock(conn, LOCK_NAME, owner_id, args.lock_ttl_minutes)
    finally:
        conn.close()

    if not lock_ok:
        print("ERROR: Nepodařilo se získat worker lock. Jiný ingest cycle pravděpodobně běží.")
        return 1

    job_run_id: Optional[int] = None

    try:
        conn = get_connection()
        try:
            job_run_id = create_job_run(conn, args, owner_id)
        finally:
            conn.close()

        planner_command = build_planner_command(args)
        planner_rc, planner_output = run_command(
            planner_command,
            "STEP 1 - PLANNER WORKER"
        )

        processed_jobs = parse_processed_jobs(planner_output)

        conn = get_connection()
        try:
            heartbeat_lock(conn, LOCK_NAME, owner_id, args.lock_ttl_minutes)
        finally:
            conn.close()

        if planner_rc != 0:
            details = {
                "planner_returncode": planner_rc,
                "planner_output": planner_output,
                "processed_jobs": processed_jobs,
                "merge_executed": False,
                "owner_id": owner_id,
                "lock_name": LOCK_NAME,
            }

            conn = get_connection()
            try:
                finish_job_run(
                    conn=conn,
                    job_run_id=job_run_id,
                    status="error",
                    message="Planner worker failed.",
                    details=details,
                    rows_affected=processed_jobs,
                )
            finally:
                conn.close()

            print("ERROR: Planner worker skončil s chybou.")
            return 1

        if processed_jobs <= 0:
            details = {
                "planner_returncode": planner_rc,
                "planner_output": planner_output,
                "processed_jobs": 0,
                "merge_executed": False,
                "owner_id": owner_id,
                "lock_name": LOCK_NAME,
            }

            conn = get_connection()
            try:
                finish_job_run(
                    conn=conn,
                    job_run_id=job_run_id,
                    status="ok",
                    message="Ingest cycle finished OK (no work).",
                    details=details,
                    rows_affected=0,
                )
            finally:
                conn.close()

            print("Planner worker nezpracoval žádný job. Merge se nespustí.")
            return 0

        if args.skip_merge:
            details = {
                "planner_returncode": planner_rc,
                "planner_output": planner_output,
                "processed_jobs": processed_jobs,
                "teams_extractor_executed": False,
                "merge_executed": False,
                "merge_skipped": True,
                "owner_id": owner_id,
                "lock_name": LOCK_NAME,
            }

            conn = get_connection()
            try:
                finish_job_run(
                    conn=conn,
                    job_run_id=job_run_id,
                    status="ok",
                    message="Ingest cycle finished OK (merge skipped).",
                    details=details,
                    rows_affected=processed_jobs,
                )
            finally:
                conn.close()

            print("Merge byl přeskočen přes --skip-merge.")
            return 0

        teams_command = build_teams_extractor_command()
        teams_rc, teams_output = run_command(
            teams_command,
            "STEP 1B - EXTRACT TEAMS FROM FIXTURES RAW"
        )

        conn = get_connection()
        try:
            heartbeat_lock(conn, LOCK_NAME, owner_id, args.lock_ttl_minutes)
        finally:
            conn.close()

        if teams_rc != 0:
            details = {
                "planner_returncode": planner_rc,
                "planner_output": planner_output,
                "processed_jobs": processed_jobs,
                "teams_extractor_executed": True,
                "teams_extractor_returncode": teams_rc,
                "teams_extractor_output": teams_output,
                "merge_executed": False,
                "owner_id": owner_id,
                "lock_name": LOCK_NAME,
            }

            conn = get_connection()
            try:
                finish_job_run(
                    conn=conn,
                    job_run_id=job_run_id,
                    status="error",
                    message="Teams extractor failed.",
                    details=details,
                    rows_affected=processed_jobs,
                )
            finally:
                conn.close()

            print("ERROR: Teams extractor skončil s chybou.")
            return 1

        #players_command = build_players_pipeline_command()
        #players_rc, players_output = run_command(
        #    players_command,
        #    "STEP 1C - PLAYERS FETCH ONLY"
        #)

        #conn = get_connection()
        #try:
        #    heartbeat_lock(conn, LOCK_NAME, owner_id, args.lock_ttl_minutes)
        #finally:
        #    conn.close()

        #if players_rc != 0:
        #    details = {
        #        "planner_returncode": planner_rc,
        #        "planner_output": planner_output,
        #        "processed_jobs": processed_jobs,
        #        "teams_extractor_executed": True,
        #        "teams_extractor_returncode": teams_rc,
        #        "teams_extractor_output": teams_output,
        #        "players_pipeline_executed": True,
        #        "players_pipeline_returncode": players_rc,
        #        "players_pipeline_output": players_output,
        #        "players_parse_executed": True,
        #        "players_parse_returncode": players_parse_rc,
        #        "players_parse_output": players_parse_output,
        #        "merge_executed": False,
        #        "owner_id": owner_id,
        #        "lock_name": LOCK_NAME,
        #    }

        #   conn = get_connection()
        #    try:
        #        finish_job_run(
        #            conn=conn,
        #            job_run_id=job_run_id,
        #            status="error",
        #            message="Players pipeline failed.",
        #            details=details,
        #            rows_affected=processed_jobs,
        #        )
        #    finally:
        #        conn.close()

        #    print("ERROR: Players pipeline skončila s chybou.")
        #    return 1    

        #players_parse_command = build_players_parse_command()
        #players_parse_rc, players_parse_output = run_command(
        #    players_parse_command,
        #    "STEP 1D - PLAYERS PARSE ONLY"
        #)

        #conn = get_connection()
        #try:
        #    heartbeat_lock(conn, LOCK_NAME, owner_id, args.lock_ttl_minutes)
        #finally:
        #    conn.close()

        #if players_parse_rc != 0:
        #    details = {
        #        "planner_returncode": planner_rc,
        #        "planner_output": planner_output,
        #        "processed_jobs": processed_jobs,
        #        "teams_extractor_executed": True,
        #        "teams_extractor_returncode": teams_rc,
        #        "teams_extractor_output": teams_output,
        #        "players_pipeline_executed": True,
        #        "players_pipeline_returncode": players_rc,
        #        "players_pipeline_output": players_output,
        #        "players_parse_executed": True,
        #        "players_parse_returncode": players_parse_rc,
        #        "players_parse_output": players_parse_output,
        #        "merge_executed": False,
        #        "owner_id": owner_id,
        #        "lock_name": LOCK_NAME,
        #    }

        #    conn = get_connection()
        #    try:
        #        finish_job_run(
        #            conn=conn,
        #            job_run_id=job_run_id,
        #            status="error",
        #            message="Players parse failed.",
        #            details=details,
        #            rows_affected=processed_jobs,
        #        )
        #    finally:
        #        conn.close()

        #    print("ERROR: Players parse skončil s chybou.")
        #    return 1

        merge_command = build_merge_command()
        merge_rc, merge_output = run_command(
            merge_command,
            "STEP 2 - STAGING TO PUBLIC MERGE"
        )

        conn = get_connection()
        try:
            heartbeat_lock(conn, LOCK_NAME, owner_id, args.lock_ttl_minutes)
        finally:
            conn.close()

        if merge_rc != 0:
            details = {
                "planner_returncode": planner_rc,
                "planner_output": planner_output,
                "processed_jobs": processed_jobs,
                "teams_extractor_executed": True,
                "teams_extractor_returncode": teams_rc,
                "teams_extractor_output": teams_output,
                "merge_executed": True,
                "merge_returncode": merge_rc,
                "merge_output": merge_output,
                "owner_id": owner_id,
                "lock_name": LOCK_NAME,
            }

            conn = get_connection()
            try:
                finish_job_run(
                    conn=conn,
                    job_run_id=job_run_id,
                    status="error",
                    message="Merge worker failed.",
                    details=details,
                    rows_affected=processed_jobs,
                )
            finally:
                conn.close()

            print("ERROR: Merge worker skončil s chybou.")
            return 1

        details = {
            "planner_returncode": planner_rc,
            "planner_output": planner_output,
            "processed_jobs": processed_jobs,
            "teams_extractor_executed": True,
            "teams_extractor_returncode": teams_rc,
            "teams_extractor_output": teams_output,
            "merge_executed": True,
            "merge_returncode": merge_rc,
            "merge_output": merge_output,
            "owner_id": owner_id,
            "lock_name": LOCK_NAME,
        }

        conn = get_connection()
        try:
            finish_job_run(
                conn=conn,
                job_run_id=job_run_id,
                status="ok",
                message="Ingest cycle V3 finished OK.",
                details=details,
                rows_affected=processed_jobs,
            )
        finally:
            conn.close()

        print("=" * 80)
        print("INGEST CYCLE SUMMARY")
        print("=" * 80)
        print("Processed planner jobs:", processed_jobs)
        print("Teams extractor       : YES")
        print("Merge executed        : YES")
        print("Final status          : OK")
        print("=" * 80)

        return 0

    except Exception as exc:
        if job_run_id is not None:
            details = {
                "exception": str(exc),
                "owner_id": owner_id,
                "lock_name": LOCK_NAME,
            }
            conn = get_connection()
            try:
                finish_job_run(
                    conn=conn,
                    job_run_id=job_run_id,
                    status="error",
                    message=f"Ingest cycle V3 fatal error: {exc}",
                    details=details,
                    rows_affected=0,
                )
            finally:
                conn.close()

        print(f"FATAL ERROR: {exc}")
        return 1

    finally:
        conn = get_connection()
        try:
            release_lock(conn, LOCK_NAME, owner_id)
        finally:
            conn.close()


if __name__ == "__main__":
    sys.exit(main())