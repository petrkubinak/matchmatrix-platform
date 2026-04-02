# -*- coding: utf-8 -*-
"""
444_auto_multi_run.py

AUTO MULTI RUN pro MatchMatrix
- spustí SAFE_01
- spustí SAFE_02
- spustí SAFE_03
- vše zapíše do jednoho souhrnu

POZNÁMKA:
Níže je 1 místo určené k úpravě:
BUILD_CMD(...) -> pokud má 436_auto_safe_seeder_v3.py jiné CLI argumenty,
upraví se jen tato jedna funkce.
"""

from __future__ import annotations

import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")
SAFE_WORKER = BASE_DIR / "workers" / "436_auto_safe_seeder_v3.py"

STRATEGIES = [
    "AUTO_SAFE_01",
    "AUTO_SAFE_02",
    "AUTO_SAFE_03",
]


@dataclass
class RunResult:
    strategy: str
    return_code: int
    duration_sec: float
    ok: bool


def log(msg: str) -> None:
    print(msg, flush=True)


def build_cmd(strategy: str) -> list[str]:
    """
    UPRAV POUZE TADY, pokud 436 worker používá jiné argumenty.

    Výchozí varianta:
    python 436_auto_safe_seeder_v3.py --strategy AUTO_SAFE_01
    """
    return [
        str(PYTHON_EXE),
        str(SAFE_WORKER),
        "--strategy-code",
        strategy,
    ]


def run_one(strategy: str) -> RunResult:
    started = time.time()
    cmd = build_cmd(strategy)

    log("=" * 80)
    log(f"MATCHMATRIX AUTO MULTI RUN | START STRATEGY: {strategy}")
    log(f"RUN: {' '.join(cmd)}")
    log("=" * 80)

    completed = subprocess.run(cmd, cwd=str(BASE_DIR))
    duration = round(time.time() - started, 2)

    ok = completed.returncode == 0

    log("-" * 80)
    log(
        f"END STRATEGY: {strategy} | RC={completed.returncode} | "
        f"DURATION={duration}s | OK={ok}"
    )
    log("-" * 80)

    return RunResult(
        strategy=strategy,
        return_code=completed.returncode,
        duration_sec=duration,
        ok=ok,
    )


def main() -> int:
    log("=" * 80)
    log("MATCHMATRIX - 444 AUTO MULTI RUN")
    log("=" * 80)
    log(f"BASE_DIR   : {BASE_DIR}")
    log(f"PYTHON_EXE : {PYTHON_EXE}")
    log(f"WORKER     : {SAFE_WORKER}")
    log(f"STRATEGIES : {', '.join(STRATEGIES)}")
    log("=" * 80)

    if not PYTHON_EXE.exists():
        log(f"ERROR: Python nebyl nalezen: {PYTHON_EXE}")
        return 2

    if not SAFE_WORKER.exists():
        log(f"ERROR: Worker nebyl nalezen: {SAFE_WORKER}")
        return 3

    results: list[RunResult] = []

    for strategy in STRATEGIES:
        result = run_one(strategy)
        results.append(result)

    log("")
    log("=" * 80)
    log("MATCHMATRIX - 444 AUTO MULTI RUN SUMMARY")
    log("=" * 80)

    ok_count = 0
    fail_count = 0

    for r in results:
        status = "OK" if r.ok else "FAIL"
        log(
            f"{r.strategy:15} | {status:4} | "
            f"RC={r.return_code:2} | {r.duration_sec:8.2f}s"
        )
        if r.ok:
            ok_count += 1
        else:
            fail_count += 1

    log("-" * 80)
    log(f"TOTAL STRATEGIES : {len(results)}")
    log(f"OK               : {ok_count}")
    log(f"FAIL             : {fail_count}")
    log("=" * 80)

    return 0 if fail_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())