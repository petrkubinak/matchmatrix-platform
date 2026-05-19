from __future__ import annotations

import argparse
import os
import subprocess
import sys

# ==========================================================
# MATCHMATRIX
# HARVEST MASTER V1
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_harvest_master_v1.py
#
# Účel:
# Nadřazený orchestrátor pro vrstvy:
# - core
# - odds
# - people
# - media
# ==========================================================

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

CORE_CYCLE = os.path.join(BASE_DIR, "workers", "run_ingest_cycle_v3.py")
ODDS_CYCLE = os.path.join(BASE_DIR, "workers", "run_odds_cycle_v1.py")
PEOPLE_CYCLE = os.path.join(BASE_DIR, "workers", "run_people_pipeline_v22_from_planner.py")
MEDIA_CYCLE = os.path.join(BASE_DIR, "workers", "run_media_cycle_v1.py")

def build_process_env() -> dict:
    env = os.environ.copy()
    env["PGHOST"] = str(DB_CONFIG["host"])
    env["PGPORT"] = str(DB_CONFIG["port"])
    env["PGDATABASE"] = str(DB_CONFIG["dbname"])
    env["PGUSER"] = str(DB_CONFIG["user"])
    env["PGPASSWORD"] = str(DB_CONFIG["password"])
    env["DB_DSN"] = (
        f"host={env['PGHOST']} "
        f"port={env['PGPORT']} "
        f"dbname={env['PGDATABASE']} "
        f"user={env['PGUSER']} "
        f"password={env['PGPASSWORD']}"
    )
    return env

def parse_args():
    parser = argparse.ArgumentParser(description="MatchMatrix Harvest Master V1")

    parser.add_argument(
        "--layer",
        required=True,
        choices=["core", "odds", "people", "media", "all"],
        help="Kterou vrstvu spustit"
    )

    parser.add_argument("--provider", default=None)
    parser.add_argument("--sport", default=None)
    parser.add_argument("--entity", default=None)
    parser.add_argument("--run-group", default=None)

    # důležité: parametry z panelu
    parser.add_argument("--limit", type=int, default=10)
    parser.add_argument("--timeout-sec", type=int, default=300)
    parser.add_argument("--max-attempts", type=int, default=3)

    return parser.parse_args()


def run_command(command: list[str], title: str) -> int:
    print("=" * 80)
    print(title)
    print("=" * 80)
    print("RUN:", " ".join(command))
    print("=" * 80)

    process = subprocess.Popen(
        command,
        cwd=BASE_DIR,
        env=build_process_env()
    )
    process.wait()

    print("=" * 80)
    print(f"{title} FINISHED, RC={process.returncode}")
    print("=" * 80)

    return process.returncode

def build_people_command(args) -> list[str]:
    cmd = [
        PYTHON_EXE,
        PEOPLE_CYCLE,
        "--limit", str(args.limit),
        "--timeout-sec", str(args.timeout_sec),
    ]

    if args.provider:
        cmd += ["--provider", args.provider]

    if args.sport:
        cmd += ["--sport", args.sport]

    if args.entity:
        cmd += ["--entity", args.entity]

    if args.run_group:
        cmd += ["--run-group", args.run_group]

    return cmd

def build_core_command(args) -> list[str]:
    cmd = [
        PYTHON_EXE,
        CORE_CYCLE,
        "--limit", str(args.limit),
        "--timeout-sec", str(args.timeout_sec),
        "--max-attempts", str(args.max_attempts),
    ]

    if args.provider:
        cmd += ["--provider", args.provider]

    if args.sport:
        cmd += ["--sport", args.sport]

    if args.entity:
        cmd += ["--entity", args.entity]

    if args.run_group:
        cmd += ["--run-group", args.run_group]

    return cmd


def main() -> int:
    args = parse_args()

    print("=" * 80)
    print("MATCHMATRIX HARVEST MASTER V1")
    print("=" * 80)
    print("LAYER       :", args.layer)
    print("LIMIT       :", args.limit)
    print("TIMEOUT SEC :", args.timeout_sec)
    print("MAX ATTEMPTS:", args.max_attempts)
    print("=" * 80)

    if args.layer in ["core", "all"]:
        if not os.path.exists(CORE_CYCLE):
            print(f"ERROR: CORE script nenalezen: {CORE_CYCLE}")
            return 1

        rc = run_command(
            build_core_command(args),
            "CORE CYCLE"
        )

        if rc != 0:
            print("ERROR: CORE selhal")
            return rc

    if args.layer in ["odds", "all"]:
        if not os.path.exists(ODDS_CYCLE):
            print("ODDS pipeline zatím neexistuje – SKIP")
        else:
            rc = run_command([PYTHON_EXE, ODDS_CYCLE], "ODDS CYCLE")
            if rc != 0:
                return rc

    if args.layer in ["people", "all"]:
        if not os.path.exists(PEOPLE_CYCLE):
            print("PEOPLE pipeline zatím neexistuje – SKIP")
        else:
            rc = run_command(build_people_command(args), "PEOPLE CYCLE")
            if rc != 0:
                return rc

    if args.layer in ["media", "all"]:
        if not os.path.exists(MEDIA_CYCLE):
            print("MEDIA pipeline zatím neexistuje – SKIP")
        else:
            rc = run_command([PYTHON_EXE, MEDIA_CYCLE], "MEDIA CYCLE")
            if rc != 0:
                return rc

    print("=" * 80)
    print("HARVEST MASTER FINISHED OK")
    print("=" * 80)

    return 0


if __name__ == "__main__":
    sys.exit(main())