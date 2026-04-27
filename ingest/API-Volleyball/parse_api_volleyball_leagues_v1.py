from __future__ import annotations

import subprocess
import sys
from pathlib import Path

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = r"C:\Python314\python.exe"

CANDIDATES = [
    BASE_DIR / "workers" / "run_parse_api_sport_leagues_v1.py",
    BASE_DIR / "workers" / "run_parse_provider_leagues_v1.py",
]

worker = next((p for p in CANDIDATES if p.exists()), None)

print("MATCHMATRIX VB LEAGUES PARSE")

if worker is None:
    print("ERROR: nebyl nalezen generic leagues parser.")
    print("Hledano:")
    for p in CANDIDATES:
        print(" -", p)
    sys.exit(1)

cmd = [
    PYTHON_EXE,
    str(worker),
    "--provider", "api_volleyball",
    "--sport", "VB",
]

print("CMD:", " ".join(cmd))
result = subprocess.run(cmd, cwd=str(BASE_DIR))
sys.exit(result.returncode)