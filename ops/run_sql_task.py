import os
import sys
import psycopg2

from lib.job_logger import logged_job


def main():
    if len(sys.argv) < 3:
        raise RuntimeError("Použití: python run_sql_task.py <job_code> <sql>")

    job_code = sys.argv[1]
    sql_text = sys.argv[2]

    dsn = os.environ.get("DB_DSN")
    if not dsn:
        raise RuntimeError("Chybí DB_DSN")

    with logged_job(job_code, params={"sql": sql_text}):
        with psycopg2.connect(dsn) as conn:
            with conn.cursor() as cur:
                cur.execute(sql_text)
            conn.commit()

    print("OK:", job_code)


if __name__ == "__main__":
    main()