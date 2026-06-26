# ============================================================
# MATCHMATRIX 110_N AUTONOMOUS DISPATCH LAUNCHER V1
# ============================================================
# CO TO JE:
# - Nový Python launcher, který už nevybírá worker ručně.
#
# K ČEMU TO JE:
# - Čte ops.v_launcher_dispatch_next_v1.
# - Spustí worker vybraný přes DB pravidla.
# - Zapíše SUCCESS / FAILED zpět do autonomní fronty.
#
# KDE TO UVIDÍME:
# - Panel V18
# - AUTONOMNÍ FRONTA
# - SPUSTIT DALŠÍ
# - RESULT COLLECTOR
#
# JAK SE TO VYUŽIJE:
# - SQL/AI OPS rozhodne, co se má spustit.
# - Tento launcher pouze provede vybraný dispatch.
# ============================================================

from __future__ import annotations

import os
import subprocess
from pathlib import Path

import psycopg2
from psycopg2.extras import RealDictCursor


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": int(os.getenv("POSTGRES_PORT", "5432")),
    "dbname": os.getenv("POSTGRES_DB", "matchmatrix"),
    "user": os.getenv("POSTGRES_USER", "matchmatrix"),
    "password": os.getenv("POSTGRES_PASSWORD", "matchmatrix_pass"),
}


def get_conn():
    return psycopg2.connect(**DB_CONFIG)


def fetch_dispatch(conn):
    sql = """
        SELECT *
        FROM ops.v_ranked_launcher_dispatch_next_v1
        LIMIT 1;
    """
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(sql)
        return cur.fetchone()


def mark_running(conn, queue_id: int):
    sql = """
        UPDATE ops.autonomous_execution_queue
        SET
            execution_status = 'RUNNING',
            started_at = now()
        WHERE id = %s
          AND execution_status = 'PENDING';
    """
    with conn.cursor() as cur:
        cur.execute(sql, (queue_id,))
        affected = cur.rowcount
    conn.commit()
    return affected == 1


def finish_action(conn, queue_id: int, success: bool, message: str):
    sql = """
        SELECT *
        FROM ops.fn_finish_autonomous_action_v1(%s, %s, %s);
    """
    with conn.cursor() as cur:
        cur.execute(sql, (queue_id, success, message))
        row = cur.fetchone()
    conn.commit()
    return row


def build_command(row) -> list[str]:
    worker_code = row["worker_code"]
    worker_path = BASE_DIR / str(row["worker_path"]).replace("/", os.sep)

    if not worker_path.exists():
        raise FileNotFoundError(f"Worker neexistuje: {worker_path}")

    cmd = [
        str(PYTHON_EXE),
        str(worker_path),
    ]

    provider = row.get("provider")
    sport = row.get("sport_code")
    entity = row.get("entity")
    run_group = row.get("run_group")
    season = row.get("season")
    league_id = row.get("league_id")

    # --------------------------------------------------------
    # RUN_PLANNER_TARGET
    # Používá planner worker.
    # DŮLEŽITÉ:
    # run_ingest_planner_jobs.py filtruje provider/sport/entity/run_group.
    # Konkrétní league_id + season si bere z ops.ingest_planner.
    # Proto je sem nepředáváme jako CLI argument.
    # --------------------------------------------------------
    if worker_code == "INGEST_PLANNER_WORKER":
        cmd.extend(["--limit", "1"])
        cmd.extend(["--timeout-sec", "300"])
        cmd.extend(["--max-attempts", "3"])

        if provider:
            cmd.extend(["--provider", str(provider)])

        if sport:
            cmd.extend(["--sport", str(sport)])

        if entity:
            cmd.extend(["--entity", str(entity)])

        if run_group:
            cmd.extend(["--run-group", str(run_group)])

        return cmd

    # --------------------------------------------------------
    # PEOPLE PIPELINE V22
    # --------------------------------------------------------
    if worker_code == "PEOPLE_PIPELINE_V22":
        cmd.extend(["--limit", "1"])
        cmd.extend(["--timeout-sec", "300"])
        cmd.extend(["--max-pages", "5"])

        if provider:
            cmd.extend(["--provider", str(provider)])

        if sport:
            cmd.extend(["--sport", str(sport)])

        if entity:
            cmd.extend(["--entity", str(entity)])

        if run_group:
            cmd.extend(["--run-group", str(run_group)])

        return cmd

    # --------------------------------------------------------
    # FULL HARVEST
    # --------------------------------------------------------
    if worker_code == "FULL_HARVEST_CYCLE_V1":
        cmd.extend(["--limit", "1"])
        cmd.extend(["--timeout-sec", "600"])

        if provider:
            cmd.extend(["--provider", str(provider)])

        if sport:
            cmd.extend(["--sport", str(sport)])

        if entity:
            cmd.extend(["--entity", str(entity)])

        if run_group:
            cmd.extend(["--run-group", str(run_group)])

        return cmd

    # --------------------------------------------------------
    # HARVEST MASTER
    # Bez layeru zatím default core.
    # --------------------------------------------------------
    if worker_code == "HARVEST_MASTER_V1":
        cmd.extend(["--layer", "core"])
        cmd.extend(["--limit", "1"])

        if provider:
            cmd.extend(["--provider", str(provider)])

        if sport:
            cmd.extend(["--sport", str(sport)])

        if entity:
            cmd.extend(["--entity", str(entity)])

        if run_group:
            cmd.extend(["--run-group", str(run_group)])

        return cmd

    # --------------------------------------------------------
    # HK PLAYERS PIPELINE / HK FETCH
    # --------------------------------------------------------
    if worker_code in ("HK_PLAYERS_PIPELINE_V1", "HK_PLAYERS_FETCH_V1"):
        if league_id:
            cmd.extend(["--league-id", str(league_id)])

        if season:
            cmd.extend(["--season", str(season)])

        return cmd

    # --------------------------------------------------------
    # API-Football players fetch wrapper
    # --------------------------------------------------------
    if worker_code == "PLAYERS_FETCH_ONLY_V1":
        if provider:
            cmd.extend(["--provider", str(provider)])

        if sport:
            cmd.extend(["--sport", str(sport)])

        if league_id and season:
            cmd.extend(["--league-id", str(league_id)])
            cmd.extend(["--season", str(season)])
            cmd.extend(["--run-id", str(row["queue_id"])])

        return cmd

    # --------------------------------------------------------
    # Default worker bez parametrů:
    # media, odds, merge, analytics
    # --------------------------------------------------------
    return cmd


def main() -> int:
    print("=" * 80)
    print("MATCHMATRIX 110_N AUTONOMOUS DISPATCH LAUNCHER V1")
    print("=" * 80)

    conn = get_conn()

    try:
        row = fetch_dispatch(conn)

        if not row:
            print("Žádný READY_TO_LAUNCH dispatch není k dispozici.")
            return 0

        queue_id = int(row["queue_id"])

        print(f"QUEUE ID     : {queue_id}")
        print(f"ACTION       : {row['action_code']}")
        print(f"WORKER       : {row['worker_code']}")
        print(f"WORKER PATH  : {row['worker_path']}")
        print(f"PROVIDER     : {row.get('provider')}")
        print(f"SPORT        : {row.get('sport_code')}")
        print(f"ENTITY       : {row.get('entity')}")
        print(f"LEAGUE       : {row.get('league_id')}")
        print(f"SEASON       : {row.get('season')}")
        print(f"RUN GROUP    : {row.get('run_group')}")
        print(f"RISK         : {row.get('dispatch_risk_cz')}")
        print("=" * 80)

        ok_mark = mark_running(conn, queue_id)
        if not ok_mark:
            print("Akci se nepodařilo přepnout do RUNNING. Možná ji už převzal jiný proces.")
            return 1

        cmd = build_command(row)

        print("RUN:")
        print(" ".join(cmd))
        print("=" * 80)

        completed = subprocess.run(
            cmd,
            cwd=str(BASE_DIR),
            capture_output=True,
            text=True,
            timeout=1200,
        )

        stdout_tail = (completed.stdout or "")[-8000:]
        stderr_tail = (completed.stderr or "")[-8000:]

        if completed.returncode == 0:
            message = (
                "WORKER OK\n"
                f"RETURN_CODE={completed.returncode}\n\n"
                f"STDOUT:\n{stdout_tail}"
            )
            result = finish_action(conn, queue_id, True, message)
            print(f"FINISH SUCCESS: {result}")
            return 0

        message = (
            "WORKER FAILED\n"
            f"RETURN_CODE={completed.returncode}\n\n"
            f"STDOUT:\n{stdout_tail}\n\n"
            f"STDERR:\n{stderr_tail}"
        )
        result = finish_action(conn, queue_id, False, message)
        print(f"FINISH FAILED: {result}")
        return 1

    except subprocess.TimeoutExpired as exc:
        print(f"TIMEOUT: {exc}")

        if "queue_id" in locals():
            finish_action(conn, queue_id, False, f"LAUNCHER TIMEOUT: {exc}")

        return 1

    except Exception as exc:
        print(f"LAUNCHER ERROR: {exc}")

        if "queue_id" in locals():
            try:
                finish_action(conn, queue_id, False, f"LAUNCHER ERROR: {exc}")
            except Exception:
                pass

        return 1

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())