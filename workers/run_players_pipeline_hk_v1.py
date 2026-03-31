from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = os.getenv("PYTHON_EXE", r"C:\Python314\python.exe")
WORKERS_DIR = PROJECT_ROOT / "workers"

FETCH_SCRIPT = WORKERS_DIR / "run_players_fetch_hk_only_v1.py"
PARSE_SCRIPT = WORKERS_DIR / "run_players_parse_hk_only_v1.py"
PUBLIC_MERGE_SCRIPT = WORKERS_DIR / "run_players_public_merge_v2.py"
BRIDGE_SCRIPT = WORKERS_DIR / "run_players_bridge_v4.py"
SEASON_STATS_BRIDGE_SCRIPT = WORKERS_DIR / "run_players_season_stats_bridge_v3.py"


def run_step(label: str, cmd: list[str], allow_missing: bool = False) -> None:
    print("=" * 80)
    print(label)
    print("RUN:", " ".join(cmd))
    print("=" * 80)

    if allow_missing and not Path(cmd[1]).exists():
        print(f"SKIP: missing optional script {cmd[1]}")
        return

    result = subprocess.run(cmd, text=True)
    if result.returncode != 0:
        raise SystemExit(result.returncode)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="HK players pipeline v1.")
    parser.add_argument("--team-id")
    parser.add_argument("--league-id")
    parser.add_argument("--season")
    parser.add_argument("--run-id", type=int)
    parser.add_argument("--skip-merge", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    common = []
    if args.team_id:
        common += ["--team-id", args.team_id]
    if args.league_id:
        common += ["--league-id", args.league_id]
    if args.season:
        common += ["--season", args.season]
    if args.run_id is not None:
        common += ["--run-id", str(args.run_id)]

    run_step("STEP 1 - HK PLAYERS FETCH", [PYTHON_EXE, str(FETCH_SCRIPT), *common])
    run_step("STEP 2 - HK PLAYERS PARSE", [PYTHON_EXE, str(PARSE_SCRIPT)])

    if not args.skip_merge:
        run_step("STEP 3 - PLAYERS BRIDGE", [PYTHON_EXE, str(BRIDGE_SCRIPT)], allow_missing=True)
        run_step("STEP 4 - PLAYERS PUBLIC MERGE", [PYTHON_EXE, str(PUBLIC_MERGE_SCRIPT)], allow_missing=True)
        run_step("STEP 5 - PLAYERS SEASON STATS BRIDGE", [PYTHON_EXE, str(SEASON_STATS_BRIDGE_SCRIPT)], allow_missing=True)

    print("DONE: HK players pipeline v1")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
