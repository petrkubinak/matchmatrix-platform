from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS PIPELINE FULL V1
# ------------------------------------------------------------
# Jednotný orchestrátor pro players flow:
# 1) fetch players payloads
# 2) parse do stg_provider_player_season_stats
# 3) deduplikace + index
# 4) připravit missing profile IDs + batche
# 5) fetch missing profiles z DB batchů
# 6) parse player profiles
# 7) doplnit public.players + provider map
# 8) doplnit missing teams + team provider map
# 9) finální merge do public.player_season_statistics
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

PULL_PLAYERS_PS1 = BASE_DIR / "ingest" / "API-Football" / "pull_api_football_players.ps1"
FETCH_PROFILES_BATCH = BASE_DIR / "workers" / "fetch_player_profiles_batch_from_db_v1.py"
PARSE_PROFILES_PY = BASE_DIR / "ingest" / "parse_api_football_player_profiles_v1.py"

# SQL soubory držíme v db/migrations, protože tam je máš rozjeté
SQL_STEPS: list[tuple[str, Path]] = [
    ("Parse players payloads -> stg_provider_player_season_stats",
     BASE_DIR / "db" / "migrations" / "055_parse_api_football_players_to_stg_player_season_stats.sql"),

    ("Deduplicate stg_provider_player_season_stats",
     BASE_DIR / "db" / "migrations" / "057_deduplicate_stg_provider_player_season_stats.sql"),

    ("Add unique index stg_provider_player_season_stats",
     BASE_DIR / "db" / "migrations" / "057_add_unique_index_stg_provider_player_season_stats.sql"),

    ("Create work.missing_player_profile_ids",
     BASE_DIR / "db" / "sql" / "071_create_work_missing_player_profile_ids.sql"),

    ("Create missing player profile batches",
     BASE_DIR / "db" / "sql" / "073_create_missing_player_profile_batches.sql"),

    ("Insert missing players from profiles",
     BASE_DIR / "db" / "migrations" / "076_insert_missing_players_from_profiles.sql"),

    ("Insert missing player provider map",
     BASE_DIR / "db" / "migrations" / "082_insert_missing_player_provider_map.sql"),

    ("Insert missing teams from players payloads",
     BASE_DIR / "db" / "migrations" / "088_insert_missing_teams_from_players_payloads.sql"),

    ("Insert missing team provider map",
     BASE_DIR / "db" / "migrations" / "089_insert_missing_team_provider_map.sql"),

    ("Final merge player season statistics",
     BASE_DIR / "db" / "migrations" / "097_merge_player_season_stats_final_business_dedup.sql"),
]


def print_header(title: str) -> None:
    print("=" * 80)
    print(title)
    print("=" * 80)


def ensure_exists(path: Path, label: str) -> None:
    if not path.exists():
        raise FileNotFoundError(f"{label} nebyl nalezen: {path}")


def run_cmd(cmd: list[str], title: str) -> None:
    print_header(title)
    print("CMD:", " ".join(cmd))
    print("-" * 80)

    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        universal_newlines=True,
        bufsize=1,
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


def build_psql_cmd(sql_file: Path) -> list[str]:
    # Používá systémové psql z PATH.
    # Připojení bere z env: PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD.
    return [
        "psql",
        "-v", "ON_ERROR_STOP=1",
        "-f", str(sql_file),
    ]


def run_sql_file(title: str, sql_file: Path) -> None:
    ensure_exists(sql_file, "SQL soubor")
    cmd = build_psql_cmd(sql_file)
    run_cmd(cmd, title)


def run_python_file(title: str, py_file: Path, extra_args: list[str] | None = None) -> None:
    ensure_exists(py_file, "Python soubor")
    cmd = [str(PYTHON_EXE), str(py_file)]
    if extra_args:
        cmd.extend(extra_args)
    run_cmd(cmd, title)


def run_powershell_file(title: str, ps1_file: Path, extra_args: list[str] | None = None) -> None:
    ensure_exists(ps1_file, "PowerShell soubor")
    cmd = [
        "powershell",
        "-ExecutionPolicy", "Bypass",
        "-File", str(ps1_file),
    ]
    if extra_args:
        cmd.extend(extra_args)
    run_cmd(cmd, title)


def main() -> int:
    try:
        print_header("MATCHMATRIX PLAYERS PIPELINE FULL V1")
        print(f"BASE_DIR   : {BASE_DIR}")
        print(f"PYTHON_EXE : {PYTHON_EXE}")
        print()

        ensure_exists(PYTHON_EXE, "Python interpreter")

        # ------------------------------------------------------------
        # STEP 1 - Fetch players payloads
        # ------------------------------------------------------------
        # Tohle volá existující PS1 pull skript.
        # Kdyby ses rozhodl později přejít na jiný worker, změníš jen tuto cestu.
        run_powershell_file(
            "STEP 1 - FETCH API-FOOTBALL PLAYERS PAYLOADS",
            PULL_PLAYERS_PS1,
        )

        # ------------------------------------------------------------
        # STEP 2-5 - SQL season stats flow
        # ------------------------------------------------------------
        for idx, (title, sql_path) in enumerate(SQL_STEPS[:5], start=2):
            run_sql_file(f"STEP {idx} - {title}", sql_path)

        # ------------------------------------------------------------
        # STEP 6 - Fetch missing profiles by prepared DB batches
        # ------------------------------------------------------------
        run_python_file(
            "STEP 6 - FETCH MISSING PLAYER PROFILES FROM DB BATCHES",
            FETCH_PROFILES_BATCH,
        )

        # ------------------------------------------------------------
        # STEP 7 - Parse fetched player profiles
        # ------------------------------------------------------------
        run_python_file(
            "STEP 7 - PARSE PLAYER PROFILES",
            PARSE_PROFILES_PY,
        )

        # ------------------------------------------------------------
        # STEP 8-12 - Public completion + final merge
        # ------------------------------------------------------------
        for offset, (title, sql_path) in enumerate(SQL_STEPS[5:], start=8):
            run_sql_file(f"STEP {offset} - {title}", sql_path)

        print_header("PLAYERS PIPELINE FULL V1 - FINISHED SUCCESSFULLY")
        return 0

    except Exception as exc:
        print()
        print_header("PLAYERS PIPELINE FULL V1 - FAILED")
        print(f"CHYBA: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())