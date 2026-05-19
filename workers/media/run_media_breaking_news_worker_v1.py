# ============================================================
# run_media_breaking_news_worker_v1.py
# MATCHMATRIX MEDIA BREAKING NEWS WORKER V1
# ============================================================

from __future__ import annotations

import psycopg


DB_DSN = (
    "host=localhost "
    "port=5432 "
    "dbname=matchmatrix "
    "user=matchmatrix "
    "password=matchmatrix_pass"
)


def load_job(conn):
    sql = """
    SELECT id, request_payload
    FROM ops.media_refresh_queue
    WHERE request_type = 'breaking_news_score'
      AND status = 'pending'
      AND attempts < max_attempts
    ORDER BY priority ASC, created_at ASC
    LIMIT 1;
    """
    return conn.execute(sql).fetchone()


def mark_running(conn, job_id):
    conn.execute("""
        UPDATE ops.media_refresh_queue
        SET status = 'running',
            attempts = attempts + 1,
            updated_at = now()
        WHERE id = %s;
    """, (job_id,))


def mark_done(conn, job_id, affected_rows):
    conn.execute("""
        UPDATE ops.media_refresh_queue
        SET status = 'done',
            last_refresh_at = now(),
            next_allowed_refresh_at = now() + (min_refresh_interval_minutes || ' minutes')::interval,
            result_message = %s,
            updated_at = now()
        WHERE id = %s;
    """, (f"Breaking news scoring completed. Articles marked: {affected_rows}", job_id))


def mark_error(conn, job_id, error_text):
    conn.execute("""
        UPDATE ops.media_refresh_queue
        SET status = 'error',
            result_message = %s,
            updated_at = now()
        WHERE id = %s;
    """, (error_text[:1000], job_id))


def apply_breaking_score(conn, patterns):
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
        is_breaking_news = true,
        breaking_score = 100,
        hot_score = COALESCE(quality_score, 0) + 100,
        velocity_score = 100,
        updated_at = now()
    WHERE is_feed_eligible = true
      AND ({where_sql});
    """

    result = conn.execute(sql, tuple(params))
    return result.rowcount


def main():
    print("=" * 80)
    print("MATCHMATRIX MEDIA BREAKING NEWS WORKER V1")
    print("=" * 80)

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    try:
        job = load_job(conn)

        if not job:
            print("NO PENDING BREAKING_NEWS_SCORE JOB")
            return

        job_id = job[0]
        payload = job[1] or {}
        patterns = payload.get("patterns", [])

        print(f"JOB ID: {job_id}")
        print(f"PATTERNS: {patterns}")

        mark_running(conn, job_id)

        affected_rows = apply_breaking_score(conn, patterns)

        mark_done(conn, job_id, affected_rows)

        print(f"DONE | ARTICLES MARKED: {affected_rows}")

    except Exception as e:
        print(f"ERROR: {e}")
        if "job_id" in locals():
            mark_error(conn, job_id, str(e))

    finally:
        conn.close()

    print("=" * 80)


if __name__ == "__main__":
    main()