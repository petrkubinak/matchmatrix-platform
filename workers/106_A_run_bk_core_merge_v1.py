# =============================================================================
# MATCHMATRIX BK CORE MERGE RUNNER V1
# =============================================================================
#
# CO SKRIPT DĚLÁ:
# -----------------------------------------------------------------------------
# Spouští unified staging -> public merge
# pro Basketball (BK).
#
# FLOW:
#
# staging.stg_provider_*
#     ->
# unified merge
#     ->
# public.*
#
# CÍL:
# -----------------------------------------------------------------------------
# Napojit BK na stejnou architekturu jako Football:
#
# provider
# -> RAW
# -> Python parser
# -> staging
# -> unified merge
# -> public
#
# Tento runner bude později používán:
#
# - ingest orchestrace
# - planner jobs
# - scheduler
# - automation panel
#
# WEB / APP VÝSLEDEK:
# -----------------------------------------------------------------------------
# Aktualizuje:
#
# public.matches
# public.leagues
# public.teams
# public.players
#
# Data budou následně používána:
#
# - výsledky zápasů
# - livescore
# - tabulky
# - statistiky
# - AI analytika
# - media linking
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

MERGE_SCRIPT = (
    BASE_DIR
    / "workers"
    / "run_unified_staging_to_public_merge_v3.py"
)


# =============================================================================
# MAIN
# =============================================================================

def main():

    print("=" * 80)
    print("MATCHMATRIX BK CORE MERGE RUNNER V1")
    print("=" * 80)

    cmd = [
        str(PYTHON_EXE),
        str(MERGE_SCRIPT),
        "--provider", "api_sport",
        "--sport", "BK"
    ]

    print("RUN COMMAND:")
    print(" ".join(cmd))
    print("=" * 80)

    result = subprocess.run(
        cmd,
        cwd=str(BASE_DIR)
    )

    if result.returncode != 0:
        print("=" * 80)
        print("BK MERGE FAILED")
        print("=" * 80)
        sys.exit(result.returncode)

    print("=" * 80)
    print("BK MERGE FINISHED")
    print("=" * 80)


if __name__ == "__main__":
    main()