# ============================================================
# run_media_velocity_snapshot_worker_v1.py
# MATCHMATRIX MEDIA VELOCITY SNAPSHOT WORKER V1
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
    SELECT
        id,
        request_payload
    FROM ops.media_refresh_queue
    WHERE request_type = 'velocity_snapshot'
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
    conn.execute("""
        UPDATE ops.media_refresh_queue
        SET
            status = 'running',
            attempts = attempts + 1,
            updated_at = now()
        WHERE id = %s;
    """, (job_id,))


def mark_done(conn, job_id, inserted_rows):
    conn.execute("""
        UPDATE ops.media_refresh_queue
        SET
            status = 'done',
            last_refresh_at = now(),
            next_allowed_refresh_at =
                now() + (min_refresh_interval_minutes || ' minutes')::interval,
            result_message = %s,
            updated_at = now()
        WHERE id = %s;
    """, (
        f"Velocity snapshot completed. Snapshots inserted: {inserted_rows}",
        job_id,
    ))


def mark_error(conn, job_id, error_text):
    conn.execute("""
        UPDATE ops.media_refresh_queue
        SET
            status = 'error',
            result_message = %s,
            updated_at = now()
        WHERE id = %s;
    """, (error_text[:1000], job_id))


def insert_velocity_snapshots(conn):
    sql = """
    INSERT INTO ops.media_article_velocity_log (
        article_id,
        feed_score,
        breaking_score,
        hot_score,
        velocity_score,
        is_breaking_news,
        is_video,
        playoff_related,
        source_name,
        sport_code
    )
    SELECT
        article_id,
        feed_score,
        breaking_score,
        hot_score,
        velocity_score,
        is_breaking_news,
        is_video,
        playoff_related,
        source_name,
        sport_code
    FROM public.v_homepage_media_feed_v2;
    """

    result = conn.execute(sql)
    return result.rowcount


def main():
    print("=" * 80)
    print("MATCHMATRIX MEDIA VELOCITY SNAPSHOT WORKER V1")
    print("=" * 80)

    conn = psycopg.connect(DB_DSN)
    conn.autocommit = True

    try:
        job = load_job(conn)

        if not job:
            print("NO PENDING VELOCITY_SNAPSHOT JOB")
            return

        job_id = job[0]

        print(f"JOB ID: {job_id}")

        mark_running(conn, job_id)

        inserted_rows = insert_velocity_snapshots(conn)

        mark_done(conn, job_id, inserted_rows)

        print(f"DONE | SNAPSHOTS INSERTED: {inserted_rows}")

    except Exception as e:
        print(f"ERROR: {e}")

        if "job_id" in locals():
            mark_error(conn, job_id, str(e))

    finally:
        conn.close()

    print("=" * 80)


if __name__ == "__main__":
    main()