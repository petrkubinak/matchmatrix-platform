# ============================================================
# MATCHMATRIX 110_H AUTONOMOUS PYTHON LAUNCHER V1
# ============================================================
# CO TO JE:
# - Python launcher pro autonomní OPS frontu.
#
# K ČEMU TO JE:
# - Načte jednu povolenou akci z ops.v_launcher_next_action_v1.
# - Přepne ji do RUNNING.
# - Spustí odpovídající existující worker.
# - Podle výsledku zapíše SUCCESS nebo FAILED.
#
# KDE TO UVIDÍME:
# - Panel V18
# - AI OPS
# - AUTONOMNÍ FRONTA
# - RESULT COLLECTOR
#
# JAK SE TO VYUŽIJE:
# - SQL rozhodne, co je bezpečné.
# - Tento Python to reálně spustí.
# - Výsledek se vrátí zpět do OPS.
# ============================================================

import os
import sys
import subprocess
import psycopg2
from pathlib import Path
from dotenv import load_dotenv


BASE_DIR = Path(r"C:\MatchMatrix-platform")
ENV_PATH = BASE_DIR / ".env"
PYTHON_EXE = r"C:\Python314\python.exe"

load_dotenv(ENV_PATH)

print("=" * 80)
print("ENV FILE:", ENV_PATH)
print("HOST:", os.getenv("POSTGRES_HOST"))
print("PORT:", os.getenv("POSTGRES_PORT"))
print("DB:", os.getenv("POSTGRES_DB"))
print("USER:", os.getenv("POSTGRES_USER"))
print("PASS EXISTS:", bool(os.getenv("POSTGRES_PASSWORD")))
print("=" * 80)

def get_conn():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        dbname=os.getenv("POSTGRES_DB", "matchmatrix"),
        user=os.getenv("POSTGRES_USER", "matchmatrix"),
        password=os.getenv("POSTGRES_PASSWORD", "matchmatrix_pass")
    )


def fetch_next_action(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT
                queue_id,
                action_type,
                provider,
                sport_code,
                entity,
                league_id,
                season,
                run_group,
                launch_reason_cz
            FROM ops.v_launcher_next_action_v1
            LIMIT 1;
        """)
        return cur.fetchone()


def mark_running(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM ops.fn_mark_next_autonomous_action_running_v1();")
        result = cur.fetchone()
    conn.commit()
    return result


def finish_action(conn, queue_id, success, message):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT *
            FROM ops.fn_finish_autonomous_action_v1(%s, %s, %s);
            """,
            (queue_id, success, message)
        )
        result = cur.fetchone()
    conn.commit()
    return result


def build_worker_command(action):
    queue_id, action_type, provider, sport_code, entity, league_id, season, run_group, reason = action

    # --------------------------------------------------------
    # ZATÍM PODPOROVANÉ:
    # RUN_PLANNER_TARGET přes existující ingest cycle.
    #
    # POZDĚJI SEM DOPLNÍME:
    # - PEOPLE pipeline
    # - MEDIA pipeline
    # - ODDS special worker
    # - provider switch
    # --------------------------------------------------------

    if action_type != "RUN_PLANNER_TARGET":
        raise ValueError(f"Nepodporovaný action_type: {action_type}")

    worker_path = BASE_DIR / "workers" / "run_ingest_cycle_v3.py"

    if not worker_path.exists():
        raise FileNotFoundError(f"Worker neexistuje: {worker_path}")

    cmd = [
        PYTHON_EXE,
        str(worker_path),
        "--provider", provider,
        "--sport", sport_code,
        "--entity", entity,
        "--run-group", run_group,
        "--limit", "1"
    ]

    # league_id zatím run_ingest_cycle_v3 nepodporuje
    # season zatím run_ingest_cycle_v3 nepodporuje
    #if league_id:
    #   cmd.extend(["--league-id", str(league_id)])
    #
    #if season:
    #    cmd.extend(["--season", str(season)])

    return cmd


def main():
    print("=" * 80)
    print("MATCHMATRIX 110_H AUTONOMOUS PYTHON LAUNCHER V1")
    print("=" * 80)

    conn = get_conn()

    try:
        action = fetch_next_action(conn)

        if not action:
            print("Žádná povolená autonomní akce k dispozici.")
            return

        queue_id = action[0]

        print(f"NALEZENA AKCE QUEUE ID: {queue_id}")
        print(f"DETAIL: {action}")

        mark_result = mark_running(conn)
        print(f"MARK RUNNING: {mark_result}")

        cmd = build_worker_command(action)

        print("-" * 80)
        print("SPOUŠTÍM WORKER:")
        print(" ".join(cmd))
        print("-" * 80)

        completed = subprocess.run(
            cmd,
            cwd=str(BASE_DIR),
            capture_output=True,
            text=True,
            timeout=900
        )

        output_text = (completed.stdout or "")[-4000:]
        error_text = (completed.stderr or "")[-4000:]

        if completed.returncode == 0:
            msg = "WORKER OK\n" + output_text
            finish_result = finish_action(conn, queue_id, True, msg)
            print(f"FINISH SUCCESS: {finish_result}")
        else:
            msg = "WORKER FAILED\nSTDOUT:\n" + output_text + "\nSTDERR:\n" + error_text
            finish_result = finish_action(conn, queue_id, False, msg)
            print(f"FINISH FAILED: {finish_result}")

    except Exception as e:
        print(f"CHYBA LAUNCHERU: {e}")

        try:
            if "queue_id" in locals():
                finish_action(conn, queue_id, False, f"LAUNCHER ERROR: {e}")
        except Exception as inner:
            print(f"CHYBA PŘI ZÁPISU FAILED: {inner}")

        raise

    finally:
        conn.close()

    print("=" * 80)
    print("DONE")
    print("=" * 80)


if __name__ == "__main__":
    main()