# ============================================================
# run_media_quality_filter_worker_v1.py
# MATCHMATRIX MEDIA QUALITY FILTER WORKER V1
#
# Účel:
# - načte pending job typu quality_filter z ops.media_refresh_queue
# - vezme blacklist_patterns z request_payload
# - označí články jako is_feed_eligible = false
# - job označí jako done
# ============================================================

from __future__ import annotations

import json
import psycopg


DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


def load_quality_filter_job(conn):
    sql = """
    SELECT
        id,
        request_payload
    FROM ops.media_refresh_queue
    WHERE request_type = 'quality_filter'
      AND status = 'pending'
      AND (
            next_allowed_refresh_at IS NULL
            OR next_allowed_refresh_at <= now()
          )
      AND attempts < max_attempts
    ORDER BY priority ASC, created_at ASC
    LIMIT 1;
    """
    return conn.execute(sql).fetchone()


def mark_running(conn, job_id):
    sql = """
    UPDATE ops.media_refresh_queue
    SET
        status = 'running',
        attempts = attempts + 1,
        updated_at = now()
    WHERE id = %s;
    """
    conn.execute(sql, (job_id,))


def mark_done(conn, job_id, affected_rows):
    sql = """
    UPDATE ops.media_refresh_queue
    SET
        status = 'done',
        last_refresh_at = now(),
        next_allowed_refresh_at = now() + (min_refresh_interval_minutes || ' minutes')::interval,
        result_message = %s,
        updated_at = now()
    WHERE id = %s;
    """
    conn.execute(sql, (f"Quality filter completed. Hidden articles: {affected_rows}", job_id))


def mark_error(conn, job_id, error_text):
    sql = """
    UPDATE ops.media_refresh_queue
    SET
        status = 'error',
        result_message = %s,
        updated_at = now()
    WHERE id = %s;
    """
    conn.execute(sql, (error_text[:1000], job_id))


def apply_quality_filter(conn, patterns):
    if not patterns:
        return 0

    conditions = []
    params = []

    for pattern in patterns:
        like_pattern = f"%{str(pattern).lower()}%"
        conditions.append("LOWER(title) LIKE %s")
        params.append(like_pattern)
        conditions.append("LOWER(url) LIKE %s")
        params.append(like_pattern)

    where_sql = " OR ".join(conditions)

    sql = f"""
    UPDATE public.articles
    SET
        is_feed_eligible = false,
        updated_at = now()
    WHERE is_feed_eligible = true
      AND ({where_sql});
    """

    result = conn.execute(sql, tuple(params))
    return result.rowcount


def main():
    print("=" * 80)
    print("MATCHMATRIX MEDIA QUALITY FILTER WORKER V1")
    print("=" * 80)

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    try:
        job = load_quality_filter_job(conn)

        if not job:
            print("NO PENDING QUALITY_FILTER JOB")
            return

        job_id = job[0]
        payload = job[1] or {}

        print(f"JOB ID: {job_id}")

        patterns = payload.get("blacklist_patterns", [])

        print(f"BLACKLIST PATTERNS: {patterns}")

        mark_running(conn, job_id)

        affected_rows = apply_quality_filter(conn, patterns)

        mark_done(conn, job_id, affected_rows)

        print(f"DONE | HIDDEN ARTICLES: {affected_rows}")

    except Exception as e:
        print(f"ERROR: {e}")

        try:
            if "job_id" in locals():
                mark_error(conn, job_id, str(e))
        except Exception:
            pass

    finally:
        conn.close()

    print("=" * 80)


if __name__ == "__main__":
    main()