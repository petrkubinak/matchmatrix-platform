from __future__ import annotations

import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS PIPELINE TRANSITIONAL V1
# ------------------------------------------------------------
# Stabilní neinteraktivní players pipeline pro panel V9.
#
# Co dělá:
#   1) fetch players payloads
#   2) bridge players_import -> stg_provider_players
#   3) merge stg_provider_players -> public.players + player_provider_map
#   4) parse player season stats -> stg_provider_player_season_stats
#   5) merge player season stats -> public.player_season_statistics
#
# Kam uložit:
#   C:\MatchMatrix-platform\workers\run_players_pipeline_transitional_v1.py
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

FETCH_WORKER = BASE_DIR / "workers" / "run_players_fetch_only_v1.py"
BRIDGE_WORKER = BASE_DIR / "workers" / "run_players_bridge_v4.py"
PUBLIC_PLAYERS_MERGE_WORKER = BASE_DIR / "workers" / "run_players_public_merge_v2.py"
PARSE_WORKER = BASE_DIR / "workers" / "run_players_parse_only_v1.py"
SEASON_STATS_PUBLIC_MERGE_WORKER = BASE_DIR / "workers" / "run_player_season_statistics_public_merge_v1.py"


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


def run_python_file(title: str, py_file: Path, extra_args: list[str] | None = None) -> None:
    ensure_exists(py_file, "Python soubor")

    cmd = [str(PYTHON_EXE), str(py_file)]
    if extra_args:
        cmd.extend(extra_args)

    run_cmd(cmd, title)


def main() -> int:
    try:
        print_header("MATCHMATRIX PLAYERS PIPELINE TRANSITIONAL V1")
        print(f"BASE_DIR                         : {BASE_DIR}")
        print(f"PYTHON_EXE                       : {PYTHON_EXE}")
        print(f"FETCH_WORKER                     : {FETCH_WORKER}")
        print(f"BRIDGE_WORKER                    : {BRIDGE_WORKER}")
        print(f"PUBLIC_PLAYERS_MERGE_WORKER      : {PUBLIC_PLAYERS_MERGE_WORKER}")
        print(f"PARSE_WORKER                     : {PARSE_WORKER}")
        print(f"SEASON_STATS_PUBLIC_MERGE_WORKER : {SEASON_STATS_PUBLIC_MERGE_WORKER}")
        print()

        ensure_exists(PYTHON_EXE, "Python interpreter")

        run_python_file(
            "STEP 1 - FETCH API-FOOTBALL PLAYERS PAYLOADS",
            FETCH_WORKER,
        )

        run_python_file(
            "STEP 2 - BRIDGE PLAYERS IMPORT TO STAGING",
            BRIDGE_WORKER,
        )

        run_python_file(
            "STEP 3 - MERGE PLAYERS TO PUBLIC",
            PUBLIC_PLAYERS_MERGE_WORKER,
        )

        run_python_file(
            "STEP 4 - PARSE PLAYER SEASON STATS TO STAGING",
            PARSE_WORKER,
        )

        run_python_file(
            "STEP 5 - MERGE PLAYER SEASON STATS TO PUBLIC",
            SEASON_STATS_PUBLIC_MERGE_WORKER,
        )

        print_header("PLAYERS PIPELINE TRANSITIONAL V1 - FINISHED SUCCESSFULLY")
        return 0

    except Exception as exc:
        print()
        print_header("PLAYERS PIPELINE TRANSITIONAL V1 - FAILED")
        print(f"CHYBA: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())