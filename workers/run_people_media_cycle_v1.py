# ============================================================
# run_people_media_cycle_v1.py
# MatchMatrix - People + Media automation wrapper
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_people_media_cycle_v1.py
#
# Co dělá:
# - bezpečně spouští PEOPLE vrstvu
# - MEDIA/HIGHLIGHTS vrstvu zatím jen eviduje jako připravenou
# - zapisuje běh do ops.job_runs
#
# Spuštění:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_people_media_cycle_v1.py --layer people --sport FB --provider api_football --run-group FB_PEOPLE
#
# Bezpečný test bez spuštění workerů:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_people_media_cycle_v1.py --layer all --dry-run
# ============================================================

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

import psycopg2


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

PEOPLE_WORKERS = {
    ("api_football", "FB", "players"): BASE_DIR / "workers" / "run_players_fetch_only_v1.py",
    ("api_football", "FB", "player_season_stats"): BASE_DIR / "workers" / "run_players_parse_only_v1.py",
}

PEOPLE_ENTITIES = [
    "players",
    "player_profiles",
    "player_season_stats",
    "player_stats",
    "coaches",
]

MEDIA_ENTITIES = [
    "highlights",
    "articles",
    "comments",
    "videos",
]


def log(message: str) -> None:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {message}", flush=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix People + Media Cycle V1")

    parser.add_argument(
        "--layer",
        choices=["people", "media", "all"],
        default="all",
        help="Vrstva ke spuštění."
    )

    parser.add_argument(
        "--provider",
        default=None,
        help="Provider filtr, např. api_football."
    )

    parser.add_argument(
        "--sport",
        default=None,
        help="Sport filtr, např. FB."
    )

    parser.add_argument(
        "--entity",
        default=None,
        help="Volitelně konkrétní entita."
    )

    parser.add_argument(
        "--run-group",
        default=None,
        help="Run group, např. FB_PEOPLE."
    )

    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=600,
        help="Timeout pro child worker."
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Pouze vypíše co by se spustilo."
    )

    return parser.parse_args()


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def create_job_run(args: argparse.Namespace) -> int:
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
        "layer": args.layer,
        "provider": args.provider,
        "sport": args.sport,
        "entity": args.entity,
        "run_group": args.run_group,
        "timeout_sec": args.timeout_sec,
        "dry_run": args.dry_run,
    }

    conn = get_connection()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    sql,
                    (
                        "people_media_cycle_v1",
                        "running",
                        json.dumps(params),
                        "People/media cycle started.",
                        json.dumps({}),
                        0,
                    ),
                )
                return int(cur.fetchone()[0])
    finally:
        conn.close()


def finish_job_run(
    job_run_id: int,
    status: str,
    message: str,
    details: dict,
    rows_affected: int = 0,
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

    conn = get_connection()
    try:
        with conn:
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
    finally:
        conn.close()


def load_enabled_people_media_plan(args: argparse.Namespace) -> list[dict]:
    wanted_entities: list[str] = []

    if args.layer in ("people", "all"):
        wanted_entities.extend(PEOPLE_ENTITIES)

    if args.layer in ("media", "all"):
        wanted_entities.extend(MEDIA_ENTITIES)

    if args.entity:
        wanted_entities = [args.entity]

    sql = """
        SELECT
            provider,
            sport_code,
            entity,
            default_run_group,
            worker_script,
            notes,
            priority
        FROM ops.ingest_entity_plan
        WHERE enabled = TRUE
          AND entity = ANY(%s)
    """
    params: list = [wanted_entities]

    if args.provider:
        sql += "\n  AND provider = %s"
        params.append(args.provider)

    if args.sport:
        sql += "\n  AND sport_code = %s"
        params.append(args.sport)

    if args.run_group:
        sql += "\n  AND default_run_group = %s"
        params.append(args.run_group)

    sql += "\nORDER BY sport_code, provider, priority, entity"

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(sql, tuple(params))
            rows = cur.fetchall()
            cols = [desc[0] for desc in cur.description]
            return [dict(zip(cols, row)) for row in rows]
    finally:
        conn.close()


def resolve_worker(row: dict) -> Optional[Path]:
    provider = str(row.get("provider") or "")
    sport = str(row.get("sport_code") or "")
    entity = str(row.get("entity") or "")

    registry_worker = PEOPLE_WORKERS.get((provider, sport, entity))
    if registry_worker:
        return registry_worker

    worker_script = row.get("worker_script")
    if worker_script:
        return BASE_DIR / str(worker_script).replace("/", os.sep)

    return None


def run_worker(path: Path, timeout_sec: int, args: argparse.Namespace, row: dict) -> tuple[int, str]:
    if not path.exists():
        return 99, f"Worker neexistuje: {path}"

    cmd = [str(PYTHON_EXE), str(path)]

    log("RUN: " + " ".join(cmd))

    process = subprocess.Popen(
        cmd,
        cwd=str(BASE_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    try:
        output, _ = process.communicate(timeout=timeout_sec)
    except subprocess.TimeoutExpired:
        process.kill()
        output, _ = process.communicate()
        return 98, f"TIMEOUT after {timeout_sec}s\n{output or ''}"

    return process.returncode, output or ""


def print_header(args: argparse.Namespace) -> None:
    log("=" * 80)
    log("MATCHMATRIX PEOPLE + MEDIA CYCLE V1")
    log("=" * 80)
    log(f"BASE_DIR    : {BASE_DIR}")
    log(f"PYTHON_EXE  : {PYTHON_EXE}")
    log(f"LAYER       : {args.layer}")
    log(f"PROVIDER    : {args.provider}")
    log(f"SPORT       : {args.sport}")
    log(f"ENTITY      : {args.entity}")
    log(f"RUN GROUP   : {args.run_group}")
    log(f"TIMEOUT SEC : {args.timeout_sec}")
    log(f"DRY RUN     : {args.dry_run}")
    log("=" * 80)


def main() -> int:
    args = parse_args()
    print_header(args)

    job_run_id = create_job_run(args)
    executed: list[dict] = []
    skipped: list[dict] = []
    errors: list[dict] = []

    try:
        rows = load_enabled_people_media_plan(args)
        log(f"PLAN ROWS: {len(rows)}")

        for row in rows:
            provider = row["provider"]
            sport = row["sport_code"]
            entity = row["entity"]
            run_group = row.get("default_run_group") or "-"

            log("-" * 80)
            log(f"ITEM: provider={provider} sport={sport} entity={entity} run_group={run_group}")

            if entity in MEDIA_ENTITIES:
                msg = "MEDIA layer je zatím placeholder - worker se bezpečně nespouští."
                log("SKIP: " + msg)
                skipped.append({**row, "reason": msg})
                continue

            worker = resolve_worker(row)

            if worker is None:
                msg = "Není definovaný worker pro tuto people entitu."
                log("SKIP: " + msg)
                skipped.append({**row, "reason": msg})
                continue

            if args.dry_run:
                msg = f"DRY RUN - spustil by se worker: {worker}"
                log(msg)
                skipped.append({**row, "reason": msg})
                continue

            rc, output = run_worker(worker, args.timeout_sec, args, row)

            print(output)

            executed.append({
                **row,
                "worker": str(worker),
                "returncode": rc,
            })

            if rc != 0:
                errors.append({
                    **row,
                    "worker": str(worker),
                    "returncode": rc,
                    "output_tail": output[-4000:],
                })
                break

        details = {
            "executed": executed,
            "skipped": skipped,
            "errors": errors,
        }

        if errors:
            finish_job_run(
                job_run_id=job_run_id,
                status="error",
                message="People/media cycle finished with errors.",
                details=details,
                rows_affected=len(executed),
            )
            log("RESULT: ERROR")
            return 1

        finish_job_run(
            job_run_id=job_run_id,
            status="ok",
            message="People/media cycle finished OK.",
            details=details,
            rows_affected=len(executed),
        )

        log("=" * 80)
        log("SUMMARY")
        log("=" * 80)
        log(f"Executed: {len(executed)}")
        log(f"Skipped : {len(skipped)}")
        log(f"Errors  : {len(errors)}")
        log("RESULT  : OK")
        log("=" * 80)
        return 0

    except Exception as exc:
        details = {
            "exception": str(exc),
            "executed": executed,
            "skipped": skipped,
            "errors": errors,
        }
        finish_job_run(
            job_run_id=job_run_id,
            status="error",
            message=f"People/media cycle fatal error: {exc}",
            details=details,
            rows_affected=len(executed),
        )
        log(f"FATAL ERROR: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())