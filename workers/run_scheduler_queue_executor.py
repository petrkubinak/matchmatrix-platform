import psycopg2
from psycopg2.extras import RealDictCursor


# ---------------------------------------------------------
# DB CONNECTION
# ---------------------------------------------------------

def get_conn():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="matchmatrix",
        user="matchmatrix",
        password="matchmatrix_pass",
    )


# ---------------------------------------------------------
# LOAD NEXT JOB FROM QUEUE
# ---------------------------------------------------------

def fetch_next_pending(conn):

    sql = """
    SELECT *
    FROM ops.scheduler_queue
    WHERE queue_day = CURRENT_DATE
      AND status = 'pending'
    ORDER BY
        tier ASC,
        max_requests_per_run DESC,
        id ASC
    LIMIT 1
    """

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql)
        return cur.fetchone()


# ---------------------------------------------------------
# UPDATE STATUS
# ---------------------------------------------------------

def update_status(conn, queue_id, new_status, message=None):

    with conn.cursor() as cur:

        cur.execute(
            """
            UPDATE ops.scheduler_queue
            SET
                status = %s,
                started_at = CASE WHEN %s = 'running' THEN now() ELSE started_at END,
                finished_at = CASE WHEN %s IN ('done','error') THEN now() ELSE finished_at END,
                message = %s
            WHERE id = %s
            """,
            (new_status, new_status, new_status, message, queue_id)
        )


# ---------------------------------------------------------
# SIMULATE PROVIDER CALL
# ---------------------------------------------------------

def simulate_provider_run(row):

    sport = row["sport_code"]
    provider = row["provider"]
    league = row["provider_league_id"]

    print(
        f"SIMULACE RUN → sport={sport} | provider={provider} | league={league}"
    )

    # Zatím jen simulace
    return True, "Simulated OK"


# ---------------------------------------------------------
# MAIN EXECUTOR
# ---------------------------------------------------------

def main():

    conn = get_conn()

    try:

        row = fetch_next_pending(conn)

        if not row:
            print("Žádný pending záznam.")
            return

        queue_id = row["id"]

        print(f"Zpracovávám queue ID: {queue_id}")

        # nastav running
        update_status(conn, queue_id, "running", "Executor started")
        conn.commit()

        ok, message = simulate_provider_run(row)

        if ok:
            update_status(conn, queue_id, "done", message)
        else:
            update_status(conn, queue_id, "error", message)

        conn.commit()

        print(f"Hotovo → {message}")

    except Exception as e:

        conn.rollback()
        print("Chyba:", e)

    finally:
        conn.close()


# ---------------------------------------------------------

if __name__ == "__main__":
    main()