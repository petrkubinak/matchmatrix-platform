from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS FETCH ONLY V1
# ------------------------------------------------------------
# Přechodový wrapper:
# spouští pouze fetch players payloadů
# bez dalších SQL / bridge / merge kroků
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_players_fetch_only_v1.py
#
# Příklad spuštění:
# python C:\MatchMatrix-platform\workers\run_players_fetch_only_v1.py --provider api_football --sport football --league-id 119 --season 2022 --run-id 281 --job-id 1218
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

PULL_PLAYERS_PY = BASE_DIR / "ingest" / "API-Football" / "pull_api_football_players_v5.py"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix Players Fetch Only V1")

    parser.add_argument("--provider", required=False, default="api_football", help="Provider, např. api_football")
    parser.add_argument("--sport", required=False, default="football", help="Sport, např. football")
    parser.add_argument("--league-id", required=True, help="Provider league ID")
    parser.add_argument("--season", required=True, help="Season, např. 2022")
    parser.add_argument("--run-id", required=True, help="Run ID pro payload/logging")
    parser.add_argument("--job-id", required=False, default=None, help="Planner job ID")

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
        print_header("MATCHMATRIX PLAYERS FETCH ONLY V1")
        print(f"BASE_DIR    : {BASE_DIR}")
        print(f"PYTHON_EXE  : {PYTHON_EXE}")
        print(f"PROVIDER    : {args.provider}")
        print(f"SPORT       : {args.sport}")
        print(f"LEAGUE_ID   : {args.league_id}")
        print(f"SEASON      : {args.season}")
        print(f"RUN_ID      : {args.run_id}")
        print(f"JOB_ID      : {args.job_id}")
        print(f"FETCH_PY    : {PULL_PLAYERS_PY}")
        print()

        ensure_exists(PYTHON_EXE, "Python interpreter")
        ensure_exists(PULL_PLAYERS_PY, "Players Python fetch script")

        cmd = [
            str(PYTHON_EXE),
            str(PULL_PLAYERS_PY),
            "--league-id", str(args.league_id),
            "--season", str(args.season),
            "--run-id", str(args.run_id),
        ]

        if args.job_id not in (None, ""):
            cmd.extend(["--job-id", str(args.job_id)])

        run_cmd(
            cmd,
            "STEP 1 - FETCH API-FOOTBALL PLAYERS (PY V5)",
        )

        print_header("Players fetch finished OK.")
        return 0

    except Exception as exc:
        print()
        print_header("PLAYERS FETCH ONLY V1 - FAILED")
        print(f"CHYBA: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())