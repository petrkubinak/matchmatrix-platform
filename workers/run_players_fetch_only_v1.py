from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS FETCH ONLY V1
# ------------------------------------------------------------
# Stabilní dlouhodobý wrapper pro players fetch.
#
# Účel:
#   1) SINGLE MODE
#      - pro cílené spuštění jedné ligy/sezóny
#      - používá argumenty:
#        --league-id --season --run-id [--job-id]
#
#   2) BATCH MODE
#      - pro panel / scheduler / Mission Control V9
#      - bez povinných argumentů
#      - interně spustí pull_api_football_players_v5.py bez parametrů,
#        takže si claimne pending jobs z planneru sám
#
# Kam uložit:
#   C:\MatchMatrix-platform\workers\run_players_fetch_only_v1.py
#
# Poznámka:
#   Tohle je správná dlouhodobá vrstva mezi panelem a ingest skriptem.
#   Panel nemá sahat přímo na ingest script.
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

PULL_PLAYERS_PY = BASE_DIR / "ingest" / "API-Football" / "pull_api_football_players_v5.py"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="MatchMatrix Players Fetch Only V1"
    )

    parser.add_argument(
        "--provider",
        required=False,
        default="api_football",
        help="Provider, např. api_football"
    )

    parser.add_argument(
        "--sport",
        required=False,
        default="football",
        help="Sport, např. football"
    )

    parser.add_argument(
        "--league-id",
        required=False,
        default=None,
        help="Provider league ID pro single-run režim"
    )

    parser.add_argument(
        "--season",
        required=False,
        default=None,
        help="Season pro single-run režim, např. 2022"
    )

    parser.add_argument(
        "--run-id",
        required=False,
        default=None,
        help="Skutečný run_id pro single-run režim"
    )

    parser.add_argument(
        "--job-id",
        required=False,
        default=None,
        help="Planner job ID pro single-run režim"
    )

    parser.add_argument(
        "--limit",
        required=False,
        default=None,
        help="Volitelný limit pro batch režim"
    )

    parser.add_argument(
        "--sleep-sec",
        required=False,
        default=None,
        help="Volitelný sleep mezi requesty"
    )

    parser.add_argument(
        "--no-mark-done",
        action="store_true",
        help="Nepřepisovat planner status na done/error"
    )

    return parser.parse_args()


def print_header(title: str) -> None:
    print("=" * 80)
    print(title)
    print("=" * 80)


def ensure_exists(path: Path, label: str) -> None:
    if not path.exists():
        raise FileNotFoundError(f"{label} nebyl nalezen: {path}")


def is_single_mode(args: argparse.Namespace) -> bool:
    return all([
        args.league_id not in (None, ""),
        args.season not in (None, ""),
        args.run_id not in (None, ""),
    ])


def validate_args(args: argparse.Namespace) -> None:
    """
    Validace režimů:
    - SINGLE MODE: musí mít league-id + season + run-id
    - BATCH MODE: může běžet i bez nich
    """
    has_any_single_arg = any([
        args.league_id not in (None, ""),
        args.season not in (None, ""),
        args.run_id not in (None, ""),
        args.job_id not in (None, ""),
    ])

    if has_any_single_arg and not is_single_mode(args):
        raise RuntimeError(
            "Pro SINGLE MODE musí být současně vyplněno: "
            "--league-id, --season, --run-id. "
            "Jinak spusť wrapper bez těchto parametrů v BATCH MODE."
        )


def build_fetch_cmd(args: argparse.Namespace) -> list[str]:
    """
    Poskládá command pro pull_api_football_players_v5.py

    SINGLE MODE:
      - pošle cílovou ligu/sezónu/run-id/job-id

    BATCH MODE:
      - nepošle league-id/season/run-id
      - ingest script si sám claimne pending jobs z planneru
    """
    cmd = [str(PYTHON_EXE), str(PULL_PLAYERS_PY)]

    if is_single_mode(args):
        cmd.extend(["--league-id", str(args.league_id)])
        cmd.extend(["--season", str(args.season)])
        cmd.extend(["--run-id", str(args.run_id)])

        if args.job_id not in (None, ""):
            cmd.extend(["--job-id", str(args.job_id)])
    else:
        if args.limit not in (None, ""):
            cmd.extend(["--limit", str(args.limit)])

        if args.sleep_sec not in (None, ""):
            cmd.extend(["--sleep-sec", str(args.sleep_sec)])

        if args.no_mark_done:
            cmd.append("--no-mark-done")

    return cmd


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
        validate_args(args)

        print_header("MATCHMATRIX PLAYERS FETCH ONLY V1")
        print(f"BASE_DIR    : {BASE_DIR}")
        print(f"PYTHON_EXE  : {PYTHON_EXE}")
        print(f"PROVIDER    : {args.provider}")
        print(f"SPORT       : {args.sport}")
        print(f"LEAGUE_ID   : {args.league_id}")
        print(f"SEASON      : {args.season}")
        print(f"RUN_ID      : {args.run_id}")
        print(f"JOB_ID      : {args.job_id}")
        print(f"LIMIT       : {args.limit}")
        print(f"SLEEP_SEC   : {args.sleep_sec}")
        print(f"NO_MARK_DONE: {args.no_mark_done}")
        print(f"MODE        : {'SINGLE' if is_single_mode(args) else 'BATCH'}")
        print(f"FETCH_PY    : {PULL_PLAYERS_PY}")
        print()

        ensure_exists(PYTHON_EXE, "Python interpreter")
        ensure_exists(PULL_PLAYERS_PY, "Players Python fetch script")

        cmd = build_fetch_cmd(args)

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