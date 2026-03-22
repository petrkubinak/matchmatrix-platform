from __future__ import annotations

import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS FETCH ONLY V1
# Přechodový wrapper:
# spouští pouze fetch players payloadů
# bez dalších SQL / bridge / merge kroků
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

PULL_PLAYERS_PS1 = BASE_DIR / "ingest" / "API-Football" / "pull_api_football_players.ps1"


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
        print_header("MATCHMATRIX PLAYERS FETCH ONLY V1")
        print(f"BASE_DIR   : {BASE_DIR}")
        print(f"PYTHON_EXE : {PYTHON_EXE}")
        print()

        ensure_exists(PYTHON_EXE, "Python interpreter")

        run_powershell_file(
            "STEP 1 - FETCH API-FOOTBALL PLAYERS PAYLOADS",
            PULL_PLAYERS_PS1,
        )

        print_header("PLAYERS FETCH ONLY V1 - FINISHED SUCCESSFULLY")
        return 0

    except Exception as exc:
        print()
        print_header("PLAYERS FETCH ONLY V1 - FAILED")
        print(f"CHYBA: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())