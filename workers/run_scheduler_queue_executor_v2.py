import subprocess
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
# FETCH NEXT PENDING ITEM
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
# STATUS UPDATE
# ---------------------------------------------------------

def update_status(conn, queue_id, new_status, message=None):
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.scheduler_queue
            SET
                status = %s,
                started_at = CASE WHEN %s = 'running' THEN now() ELSE started_at END,
                finished_at = CASE WHEN %s IN ('done','error','skipped') THEN now() ELSE finished_at END,
                message = %s
            WHERE id = %s
            """,
            (new_status, new_status, new_status, message, queue_id)
        )


def log_status_change(conn, queue_id, old_status, new_status, message=None):
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO ops.scheduler_queue_log
            (
                queue_id,
                old_status,
                new_status,
                message
            )
            VALUES (%s, %s, %s, %s)
            """,
            (queue_id, old_status, new_status, message)
        )


# ---------------------------------------------------------
# API BUDGET UPDATE
# ---------------------------------------------------------

def consume_budget(conn, sport_code, used_requests=1):
    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE ops.api_budget_status
            SET
                requests_used = requests_used + %s,
                last_updated = now()
            WHERE sport_code = %s
              AND request_day = CURRENT_DATE
            """,
            (used_requests, sport_code)
        )


# ---------------------------------------------------------
# PROVIDER EXECUTION
# ---------------------------------------------------------

def run_powershell_script(script_path):
    cmd = [
        "powershell.exe",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        script_path
    ]

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace"
    )

    stdout = (result.stdout or "").strip()
    stderr = (result.stderr or "").strip()

    success = result.returncode == 0
    message = stdout if stdout else stderr

    if not message:
        message = f"Process finished with code {result.returncode}"

    return success, message


def execute_provider_job(row):
    sport_code = row["sport_code"]
    provider = row["provider"]
    provider_league_id = row["provider_league_id"]

    # -----------------------------------------------------
    # FOOTBALL = REAL TEST RUN
    # -----------------------------------------------------
    if sport_code == "football" and provider == "api_football":
        script = r"C:\MatchMatrix-platform\ingest\API-Football\pull_api_football_fixtures.ps1"
        print(
            f"REAL RUN → sport={sport_code} | provider={provider} | league={provider_league_id}"
        )
        return run_powershell_script(script)

    # -----------------------------------------------------
    # HOCKEY = SAFE SIMULATION FOR NOW
    # -----------------------------------------------------
    if sport_code == "hockey" and provider == "api_hockey":
        print(
            f"SIMULACE HOCKEY → sport={sport_code} | provider={provider} | league={provider_league_id}"
        )
        return True, "Simulated hockey OK"

    # -----------------------------------------------------
    # BASKETBALL = SAFE SIMULATION FOR NOW
    # -----------------------------------------------------
    if sport_code == "basketball":
        print(
            f"SIMULACE BASKETBALL → sport={sport_code} | provider={provider} | league={provider_league_id}"
        )
        return True, "Simulated basketball OK"

    # -----------------------------------------------------
    # DEFAULT
    # -----------------------------------------------------
    print(
        f"SKIPPED → sport={sport_code} | provider={provider} | league={provider_league_id}"
    )
    return False, f"No executor mapping for sport={sport_code}, provider={provider}"


# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------

def main():
    conn = get_conn()

    try:
        row = fetch_next_pending(conn)

        if not row:
            print("Žádný pending záznam ve scheduler_queue.")
            return

        queue_id = row["id"]
        old_status = row["status"]
        sport_code = row["sport_code"]

        print(f"ID fronty zpracování: {queue_id}")

        update_status(conn, queue_id, "running", "Executor v2 started")
        log_status_change(conn, queue_id, old_status, "running", "Executor v2 started")
        conn.commit()

        ok, message = execute_provider_job(row)

        if ok:
            update_status(conn, queue_id, "done", message)
            log_status_change(conn, queue_id, "running", "done", message)

            # pro free test zatím odečteme 1 request za 1 queue item
            consume_budget(conn, sport_code, used_requests=1)
        else:
            update_status(conn, queue_id, "error", message)
            log_status_change(conn, queue_id, "running", "error", message)

        conn.commit()

        print(f"Hotovo → {message}")

    except Exception as e:
        conn.rollback()
        print(f"Chyba executoru v2: {e}")
        raise

    finally:
        conn.close()


if __name__ == "__main__":
    main()