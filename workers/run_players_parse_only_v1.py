from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS PARSE ONLY V1
# ------------------------------------------------------------
# Stabilní dlouhodobý wrapper pro PARSE player season stats.
#
# Kam uložit:
#   C:\MatchMatrix-platform\workers\run_players_parse_only_v1.py
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

PARSER_PY = BASE_DIR / "workers" / "run_player_season_statistics_stage_parser_v1.py"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix Players Parse Only V1")

    parser.add_argument("--provider", required=False, default="api_football")
    parser.add_argument("--sport", required=False, default="football")
    parser.add_argument("--league-id", required=False, default=None)
    parser.add_argument("--season", required=False, default=None)
    parser.add_argument("--run-id", required=False, default=None)
    parser.add_argument("--job-id", required=False, default=None)

    return parser.parse_args()


def print_header(title: str) -> None:
    print("=" * 80)
    print(title)
    print("=" * 80)


def ensure_exists(path: Path, label: str) -> None:
    if not path.exists():
        raise FileNotFoundError(f"{label} nebyl nalezen: {path}")


def run_cmd(cmd: list[str], title: str) -> None:
    print_header(title)
    print("CMD:", " ".join(str(x) for x in cmd))
    print("-" * 80)

    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        universal_newlines=True,
        bufsize=1,
        cwd=str(BASE_DIR),
    )

    assert process.stdout is not None
    for line in process.stdout:
        print(line.rstrip())

    process.wait()

    if process.returncode != 0:
        raise RuntimeError(f"Krok selhal s return code {process.returncode}: {title}")

    print("-" * 80)
    print("HOTOVO OK")
    print()


def main() -> int:
    args = parse_args()

    try:
        print_header("MATCHMATRIX PLAYERS PARSE ONLY V1")
        print(f"BASE_DIR    : {BASE_DIR}")
        print(f"PYTHON_EXE  : {PYTHON_EXE}")
        print(f"PROVIDER    : {args.provider}")
        print(f"SPORT       : {args.sport}")
        print(f"LEAGUE_ID   : {args.league_id}")
        print(f"SEASON      : {args.season}")
        print(f"RUN_ID      : {args.run_id}")
        print(f"JOB_ID      : {args.job_id}")
        print(f"PARSER      : {PARSER_PY}")
        print()

        ensure_exists(PYTHON_EXE, "Python interpreter")
        ensure_exists(PARSER_PY, "Season stats parser script")

        cmd = [str(PYTHON_EXE), str(PARSER_PY)]

        run_cmd(
            cmd,
            "STEP 1 - PARSE PLAYER SEASON STATS",
        )

        print_header("Players parse finished OK.")
        return 0

    except Exception as exc:
        print()
        print_header("PLAYERS PARSE ONLY V1 - FAILED")
        print(f"CHYBA: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())