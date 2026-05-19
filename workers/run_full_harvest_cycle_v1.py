# ============================================================
# run_full_harvest_cycle_v1.py
# MatchMatrix - full harvest wrapper
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_full_harvest_cycle_v1.py
#
# Co dělá:
# 1) spustí core ingest cycle V3
# 2) volitelně spustí people/media cycle V1
#
# Bezpečný test:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_full_harvest_cycle_v1.py --dry-run
#
# Ostrý core běh:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_full_harvest_cycle_v1.py --provider api_football --sport FB --entity fixtures --run-group EU_top --limit 5
#
# Ostrý people test:
# C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_full_harvest_cycle_v1.py --include-people --people-dry-run
# ============================================================

from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import datetime
from pathlib import Path


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

CORE_CYCLE = BASE_DIR / "workers" / "run_ingest_cycle_v3.py"
PEOPLE_MEDIA_CYCLE = BASE_DIR / "workers" / "run_people_media_cycle_v1.py"


def log(message: str) -> None:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {message}", flush=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix Full Harvest Cycle V1")

    parser.add_argument("--provider", default=None)
    parser.add_argument("--sport", default=None)
    parser.add_argument("--entity", default=None)
    parser.add_argument("--run-group", default=None)

    parser.add_argument("--limit", type=int, default=10)
    parser.add_argument("--timeout-sec", type=int, default=600)
    parser.add_argument("--max-attempts", type=int, default=3)

    parser.add_argument("--skip-core", action="store_true")
    parser.add_argument("--skip-merge", action="store_true")

    parser.add_argument("--include-people", action="store_true")
    parser.add_argument("--include-media", action="store_true")

    parser.add_argument("--people-layer", choices=["people", "media", "all"], default="people")
    parser.add_argument("--people-dry-run", action="store_true")

    parser.add_argument("--dry-run", action="store_true")

    return parser.parse_args()


def run_command(cmd: list[str], title: str) -> int:
    log("=" * 80)
    log(title)
    log("=" * 80)
    log("RUN: " + " ".join(cmd))
    log("=" * 80)

    process = subprocess.Popen(
        cmd,
        cwd=str(BASE_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    assert process.stdout is not None
    for line in process.stdout:
        print(line.rstrip(), flush=True)

    process.wait()

    log("=" * 80)
    log(f"{title} RETURNCODE: {process.returncode}")
    log("=" * 80)

    return int(process.returncode)


def build_core_command(args: argparse.Namespace) -> list[str]:
    cmd = [
        str(PYTHON_EXE),
        str(CORE_CYCLE),
        "--limit", str(args.limit),
        "--timeout-sec", str(args.timeout_sec),
        "--max-attempts", str(args.max_attempts),
    ]

    if args.provider:
        cmd.extend(["--provider", args.provider])

    if args.sport:
        cmd.extend(["--sport", args.sport])

    if args.entity:
        cmd.extend(["--entity", args.entity])

    if args.run_group:
        cmd.extend(["--run-group", args.run_group])

    if args.skip_merge:
        cmd.append("--skip-merge")

    return cmd


def build_people_media_command(args: argparse.Namespace) -> list[str]:
    layer = args.people_layer

    if args.include_media and not args.include_people:
        layer = "media"

    if args.include_media and args.include_people:
        layer = "all"

    cmd = [
        str(PYTHON_EXE),
        str(PEOPLE_MEDIA_CYCLE),
        "--layer", layer,
        "--timeout-sec", str(args.timeout_sec),
    ]

    if args.provider:
        cmd.extend(["--provider", args.provider])

    if args.sport:
        cmd.extend(["--sport", args.sport])

    if args.people_dry_run:
        cmd.append("--dry-run")

    return cmd


def validate_files() -> bool:
    ok = True

    for path in [CORE_CYCLE, PEOPLE_MEDIA_CYCLE]:
        if not path.exists():
            log(f"ERROR: Soubor neexistuje: {path}")
            ok = False

    return ok


def print_header(args: argparse.Namespace) -> None:
    log("=" * 80)
    log("MATCHMATRIX FULL HARVEST CYCLE V1")
    log("=" * 80)
    log(f"BASE_DIR       : {BASE_DIR}")
    log(f"PYTHON_EXE     : {PYTHON_EXE}")
    log(f"CORE_CYCLE     : {CORE_CYCLE}")
    log(f"PEOPLE_MEDIA   : {PEOPLE_MEDIA_CYCLE}")
    log(f"PROVIDER       : {args.provider}")
    log(f"SPORT          : {args.sport}")
    log(f"ENTITY         : {args.entity}")
    log(f"RUN_GROUP      : {args.run_group}")
    log(f"LIMIT          : {args.limit}")
    log(f"TIMEOUT_SEC    : {args.timeout_sec}")
    log(f"INCLUDE_PEOPLE : {args.include_people}")
    log(f"INCLUDE_MEDIA  : {args.include_media}")
    log(f"DRY_RUN        : {args.dry_run}")
    log("=" * 80)


def main() -> int:
    args = parse_args()
    print_header(args)

    if not validate_files():
        return 1

    core_cmd = build_core_command(args)
    people_cmd = build_people_media_command(args)

    if args.dry_run:
        log("DRY RUN - nic se nespouští.")
        log("CORE CMD:")
        log(" ".join(core_cmd))
        log("PEOPLE/MEDIA CMD:")
        log(" ".join(people_cmd))
        return 0

    if not args.skip_core:
        rc = run_command(core_cmd, "STEP 1 - CORE INGEST CYCLE V3")
        if rc != 0:
            log("RESULT: ERROR - core cycle failed.")
            return rc
    else:
        log("STEP 1 - CORE skipped.")

    if args.include_people or args.include_media:
        rc = run_command(people_cmd, "STEP 2 - PEOPLE / MEDIA CYCLE V1")
        if rc != 0:
            log("RESULT: ERROR - people/media cycle failed.")
            return rc
    else:
        log("STEP 2 - PEOPLE / MEDIA skipped.")

    log("=" * 80)
    log("FULL HARVEST RESULT: OK")
    log("=" * 80)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())