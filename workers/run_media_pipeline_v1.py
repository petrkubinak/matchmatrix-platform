# ============================================================
# run_media_pipeline_v1.py
# MATCHMATRIX MEDIA PIPELINE V1
#
# Hlavní orchestrátor MEDIA vrstvy.
#
# Spouští:
# - official_site ingest
# - RSS ingest
# - media merge
#
# Budoucí rozšíření:
# - youtube
# - social
# - highlights
# - AI summaries
# - scheduler
#
# Spuštění:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_media_pipeline_v1.py
# ============================================================

from __future__ import annotations

import subprocess
import sys
import psycopg
from datetime import datetime
from pathlib import Path


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")

PYTHON_EXE = Path(r"C:\Python314\python.exe")

DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)

MEDIA_WORKERS = [
    BASE_DIR / "workers" / "media" / "pull_official_site_media_articles_v1.py",
    BASE_DIR / "workers" / "media" / "pull_rss_media_articles_v1.py",
    BASE_DIR / "workers" / "media" / "parse_article_details_v1.py",
    BASE_DIR / "workers" / "media" / "merge_media_articles_to_public_v1.py",
    BASE_DIR / "workers" / "media" / "match_article_entities_v1.py",
    BASE_DIR / "workers" / "media" / "score_media_articles_v1.py",
]


# ============================================================
# HELPERS
# ============================================================

def log(message: str) -> None:
    print(
        f"[{datetime.now().strftime('%H:%M:%S')}] {message}",
        flush=True
    )


def run_worker(worker_path: Path) -> int:

    if not worker_path.exists():
        log(f"WORKER NOT FOUND: {worker_path}")
        return 99

    cmd = [
        str(PYTHON_EXE),
        str(worker_path)
    ]

    log("=" * 80)
    log(f"RUN WORKER: {worker_path.name}")
    log("=" * 80)

    process = subprocess.Popen(
        cmd,
        cwd=str(BASE_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    while True:

        line = process.stdout.readline()

        if not line and process.poll() is not None:
            break

        if line:
            print(line.rstrip())

    return process.returncode

# ============================================================
# DB JOB RUNS
# ============================================================

def create_job_run(conn):

    sql = """
    INSERT INTO ops.media_job_runs
    (
        pipeline_name,
        worker_name,
        layer,
        status,
        started_at
    )
    VALUES
    (
        'run_media_pipeline_v1',
        'run_media_pipeline_v1.py',
        'media',
        'running',
        now()
    )
    RETURNING id
    """

    row = conn.execute(sql).fetchone()

    return row[0]


def finish_job_run(
    conn,
    job_run_id,
    status,
    success,
    failed,
):

    sql = """
    UPDATE ops.media_job_runs
    SET
        status = %s,
        finished_at = now(),
        duration_seconds =
            EXTRACT(EPOCH FROM (now() - started_at))::INTEGER,
        processed_rows = %s,
        error_rows = %s,
        message = %s
    WHERE id = %s
    """

    conn.execute(
        sql,
        (
            status,
            success,
            failed,
            f"workers_ok={success}; workers_failed={failed}",
            job_run_id,
        ),
    )

# ============================================================
# MAIN
# ============================================================

def main() -> int:

    log("=" * 80)
    log("MATCHMATRIX MEDIA PIPELINE V1")
    log("=" * 80)

    log(f"BASE_DIR  : {BASE_DIR}")
    log(f"PYTHON_EXE: {PYTHON_EXE}")

    log("WORKERS:")
    for worker in MEDIA_WORKERS:
        log(f" - {worker.name}")

    log("=" * 80)

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    job_run_id = create_job_run(conn)

    log(f"JOB RUN ID: {job_run_id}")

    success = 0
    failed = 0

    for worker in MEDIA_WORKERS:

        rc = run_worker(worker)

        if rc == 0:
            success += 1
            log(f"WORKER OK: {worker.name}")
        else:
            failed += 1
            log(f"WORKER FAILED ({rc}): {worker.name}")

    log("=" * 80)
    log("MEDIA PIPELINE SUMMARY")
    log("=" * 80)

    log(f"SUCCESS: {success}")
    log(f"FAILED : {failed}")

    if failed > 0:

        finish_job_run(
            conn,
            job_run_id,
            status="error",
            success=success,
            failed=failed,
        )

        conn.close()

        log("RESULT : ERROR")
        return 1

    finish_job_run(
        conn,
        job_run_id,
        status="ok",
        success=success,
        failed=failed,
    )

    conn.close()

    log("RESULT : OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())