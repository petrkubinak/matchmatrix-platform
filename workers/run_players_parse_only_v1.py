from __future__ import annotations

import subprocess
import sys
from pathlib import Path


# ============================================================
# MATCHMATRIX - PLAYERS PARSE ONLY V1
# ------------------------------------------------------------
# Přechodový wrapper:
# spouští pouze parse player profiles
# ============================================================

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

PARSE_PROFILES_PY = BASE_DIR / "ingest" / "parse_api_football_player_profiles_v1.py"


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
    try:
        print_header("MATCHMATRIX PLAYERS PARSE ONLY V1")

        ensure_exists(PARSE_PROFILES_PY, "Parse profiles script")

        run_cmd(
            [str(PYTHON_EXE), str(PARSE_PROFILES_PY)],
            "STEP - PARSE PLAYER PROFILES",
        )

        print_header("PLAYERS PARSE ONLY V1 - FINISHED SUCCESSFULLY")
        return 0

    except Exception as exc:
        print()
        print_header("PLAYERS PARSE ONLY V1 - FAILED")
        print(f"CHYBA: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())