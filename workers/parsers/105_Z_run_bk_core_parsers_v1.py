# =============================================================================
# MATCHMATRIX BK CORE PARSERS RUNNER V1
# =============================================================================
#
# CO SKRIPT DĚLÁ:
# -----------------------------------------------------------------------------
# Spouští kompletní Basketball (BK) CORE parsovací flow:
#
# 1. Fixtures parser
# 2. Leagues parser
# 3. Teams parser
# 4. Players parser
#
# Flow:
#
# RAW payloads
#     ->
# Python parsers
#     ->
# staging tabulky
#
# CÍL:
# -----------------------------------------------------------------------------
# Sjednotit BK pipeline do stejného patternu jako FB:
#
# planner
# -> pull
# -> RAW
# -> Python parser
# -> staging
# -> merge
# -> public
#
# Tento runner bude později používán:
#
# - unified ingest cycle
# - planner orchestrace
# - scheduler
# - automatické harvesty
#
# WEB / APP VÝSLEDEK:
# -----------------------------------------------------------------------------
# Data po parsování vstupují do:
#
# public.matches
# public.leagues
# public.teams
# public.players
#
# odkud budou:
#
# - zápasy
# - výsledky
# - tabulky
# - soupisky
# - statistiky
#
# zobrazovány na webu/appce MatchMatrix.
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

PARSERS = [
    BASE_DIR / "workers" / "parsers" / "105_V_parse_api_sport_bk_fixtures_to_staging_v1.py",
    BASE_DIR / "workers" / "parsers" / "105_W_parse_api_sport_bk_leagues_to_staging_v1.py",
    BASE_DIR / "workers" / "parsers" / "105_X_parse_api_sport_bk_teams_to_staging_v1.py",
    BASE_DIR / "workers" / "parsers" / "105_Y_parse_api_sport_bk_players_to_staging_v1.py",
]


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
        print(f"ERROR: {script_path.name}")
        sys.exit(result.returncode)

    print(f"DONE: {script_path.name}")
    print()


# =============================================================================
# MAIN
# =============================================================================

def main():

    print("=" * 80)
    print("MATCHMATRIX BK CORE PARSERS RUNNER V1")
    print("=" * 80)

    for parser in PARSERS:
        run_script(parser)

    print("=" * 80)
    print("ALL BK PARSERS FINISHED")
    print("=" * 80)


if __name__ == "__main__":
    main()