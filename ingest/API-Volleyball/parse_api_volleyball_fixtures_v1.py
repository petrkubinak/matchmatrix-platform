from __future__ import annotations

import subprocess
import sys
from pathlib import Path

BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = r"C:\Python314\python.exe"
WORKER = BASE_DIR / "workers" / "run_parse_api_sport_fixtures_v1.py"

cmd = [
    PYTHON_EXE,
    str(WORKER),
    "--provider", "api_volleyball",
    "--sport", "volleyball",
]

print("MATCHMATRIX VB FIXTURES PARSE")
print("CMD:", " ".join(cmd))

if not WORKER.exists():
    print(f"ERROR: worker neexistuje: {WORKER}")
    sys.exit(1)

result = subprocess.run(cmd, cwd=str(BASE_DIR))
sys.exit(result.returncode)