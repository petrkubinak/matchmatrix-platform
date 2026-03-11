import json
import os
from contextlib import contextmanager

import psycopg2


def get_conn():
    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise RuntimeError("Chybí DB_DSN")
    return psycopg2.connect(dsn)


def start_job_run(job_code: str, params: dict | None = None) -> int:
    params = params or {}
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO ops.job_runs (job_code, status, params)
                VALUES (%s, 'running', %s::jsonb)
                RETURNING id
                """,
                (job_code, json.dumps(params)),
            )
            job_run_id = cur.fetchone()[0]
        conn.commit()
    return int(job_run_id)


def finish_job_run(job_run_id: int, status: str, message: str | None = None, details: dict | None = None, rows_affected: int | None = None):
    details = details or {}
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE ops.job_runs
                   SET finished_at = now(),
                       status = %s,
                       message = %s,
                       details = %s::jsonb,
                       rows_affected = %s
                 WHERE id = %s
                """,
                (status, message, json.dumps(details), rows_affected, job_run_id),
            )
        conn.commit()


@contextmanager
def logged_job(job_code: str, params: dict | None = None):
    job_run_id = start_job_run(job_code, params=params)
    try:
        yield job_run_id
        finish_job_run(job_run_id, status="success", message="OK")
    except Exception as e:
        finish_job_run(job_run_id, status="error", message=str(e), details={"error": str(e)})
        raise