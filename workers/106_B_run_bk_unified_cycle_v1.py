# =============================================================================
# MATCHMATRIX BK UNIFIED CYCLE V1
# =============================================================================
#
# CO SKRIPT DĚLÁ:
# -----------------------------------------------------------------------------
# Spouští kompletní Basketball unified ingest cycle:
#
# 1. Python parsers
# 2. Unified merge
#
# FLOW:
#
# RAW payloads
#     ->
# Python parsers
#     ->
# staging
#     ->
# unified merge
#     ->
# public
#
# CÍL:
# -----------------------------------------------------------------------------
# Vytvořit plně automatický Basketball ingest cycle
# bez ručních SQL kroků.
#
# Tento skript bude později používán:
#
# - automation panelem
# - schedulerem
# - planner orchestrací
# - full multi-sport orchestration
#
# WEB / APP VÝSLEDEK:
# -----------------------------------------------------------------------------
# Automaticky aktualizuje:
#
# - zápasy
# - týmy
# - ligy
# - hráče
#
# pro Basketball sekci MatchMatrix platformy.
#
# =============================================================================

import subprocess
import sys
from pathlib import Path


# =============================================================================
# PATHS
# =============================================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")

PYTHON_EXE = Path(sys.executable)

BK_PARSERS_RUNNER = (
    BASE_DIR
    / "workers"
    / "parsers"
    / "105_Z_run_bk_core_parsers_v1.py"
)

BK_MERGE_RUNNER = (
    BASE_DIR
    / "workers"
    / "106_A_run_bk_core_merge_v1.py"
)


# =============================================================================
# RUNNER
# =============================================================================

def run_script(script_path: Path):

    print("=" * 80)
    print(f"RUNNING: {script_path.name}")
    print("=" * 80)

    result = subprocess.run(
        [str(PYTHON_EXE), str(script_path)],
        cwd=str(BASE_DIR)
    )

    if result.returncode != 0:
        print("=" * 80)
        print(f"FAILED: {script_path.name}")
        print("=" * 80)
        sys.exit(result.returncode)

    print("=" * 80)
    print(f"DONE: {script_path.name}")
    print("=" * 80)
    print()


# =============================================================================
# MAIN
# =============================================================================

def main():

    print("=" * 80)
    print("MATCHMATRIX BK UNIFIED CYCLE V1")
    print("=" * 80)

    # -------------------------------------------------------------------------
    # STEP 1
    # PARSERS
    # -------------------------------------------------------------------------

    run_script(BK_PARSERS_RUNNER)

    # -------------------------------------------------------------------------
    # STEP 2
    # MERGE
    # -------------------------------------------------------------------------

    run_script(BK_MERGE_RUNNER)

    print("=" * 80)
    print("BK UNIFIED CYCLE FINISHED")
    print("=" * 80)


if __name__ == "__main__":
    main()