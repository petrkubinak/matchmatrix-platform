# ============================================================
# run_media_queue_workers_v1.py
# MATCHMATRIX MEDIA QUEUE WORKERS RUNNER V1
# ============================================================

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")

WORKERS = [
    BASE_DIR / "workers" / "media" / "run_media_quality_filter_worker_v1.py",
    BASE_DIR / "workers" / "media" / "run_media_breaking_news_worker_v1.py",
]


def run_worker(worker_path: Path) -> int:
    print("=" * 80)
    print(f"RUN WORKER: {worker_path}")
    print("=" * 80)

    result = subprocess.run(
        [str(PYTHON_EXE), str(worker_path)],
        cwd=str(BASE_DIR),
        text=True,
        capture_output=False,
    )

    print(f"EXIT CODE: {result.returncode}")
    return result.returncode


def main() -> int:
    print("=" * 80)
    print("MATCHMATRIX MEDIA QUEUE WORKERS RUNNER V1")
    print("=" * 80)

    exit_code = 0

    for worker in WORKERS:
        if not worker.exists():
            print(f"MISSING WORKER: {worker}")
            exit_code = 1
            continue

        code = run_worker(worker)

        if code != 0:
            exit_code = code

    print("=" * 80)
    print("MEDIA QUEUE WORKERS DONE")
    print("=" * 80)

    return exit_code


if __name__ == "__main__":
    sys.exit(main())