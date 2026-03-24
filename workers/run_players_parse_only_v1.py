from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS PARSE ONLY V1
# ------------------------------------------------------------
# Přechodový wrapper:
# spouští pouze parse player profiles
#
# Kam uložit:
# C:\MatchMatrix-platform\workers\run_players_parse_only_v1.py
#
# Příklad spuštění:
# python C:\MatchMatrix-platform\workers\run_players_parse_only_v1.py --provider api_football --sport football --league-id 119 --season 2022 --run-id 281 --job-id 1218
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

PARSE_PROFILES_PY = BASE_DIR / "ingest" / "parse_api_football_player_profiles_v1.py"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MatchMatrix Players Parse Only V1")

    parser.add_argument("--provider", required=False, default="api_football", help="Provider, např. api_football")
    parser.add_argument("--sport", required=False, default="football", help="Sport, např. football")
    parser.add_argument("--league-id", required=False, default=None, help="Provider league ID")
    parser.add_argument("--season", required=False, default=None, help="Season, např. 2022")
    parser.add_argument("--run-id", required=False, default=None, help="Run ID pro cílený parse")
    parser.add_argument("--job-id", required=False, default=None, help="Planner job ID")
    parser.add_argument("--limit", required=False, default=None, help="Volitelný limit záznamů")
    parser.add_argument("--dry-run", action="store_true", help="Volitelně dry-run, pokud parser podporuje")

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


def build_parse_cmd(args: argparse.Namespace) -> list[str]:
    """
    Poskládá command pro parse_api_football_player_profiles_v1.py.

    Argumenty přidáváme jen pokud jsou vyplněné,
    aby wrapper fungoval i když parser zatím bere jen část z nich.
    """
    cmd = [str(PYTHON_EXE), str(PARSE_PROFILES_PY)]

    if args.provider not in (None, ""):
        cmd.extend(["--provider", str(args.provider)])

    if args.sport not in (None, ""):
        cmd.extend(["--sport", str(args.sport)])

    if args.league_id not in (None, ""):
        cmd.extend(["--league-id", str(args.league_id)])

    if args.season not in (None, ""):
        cmd.extend(["--season", str(args.season)])

    # DOČASNĚ run_id parseru neposíláme,
    # protože raw payload storage je teď navázaná na league_id + season,
    # ne na ingest run_id.
    # if args.run_id not in (None, ""):
    #     cmd.extend(["--run-id", str(args.run_id)])

    if args.job_id not in (None, ""):
        cmd.extend(["--job-id", str(args.job_id)])

    if args.limit not in (None, ""):
        cmd.extend(["--limit", str(args.limit)])

    if args.dry_run:
        cmd.append("--dry-run")

    return cmd


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
        print(f"PARSER      : {PARSE_PROFILES_PY}")
        print()

        ensure_exists(PYTHON_EXE, "Python interpreter")
        ensure_exists(PARSE_PROFILES_PY, "Parse profiles script")

        cmd = build_parse_cmd(args)

        run_cmd(
            cmd,
            "STEP 1 - PARSE PLAYER PROFILES",
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