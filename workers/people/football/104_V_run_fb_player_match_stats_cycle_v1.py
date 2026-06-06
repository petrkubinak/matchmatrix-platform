# -*- coding: utf-8 -*-
"""
MATCHMATRIX 104_V - RUN FB PLAYER MATCH STATS CYCLE V1

Co skript dělá:
- spustí celý FB player match stats cycle:
    1) queue builder
    2) puller
    3) parser

Kam výsledek vede:
- ops.fixture_player_stats_queue
- staging.stg_api_payloads
- public.player_match_statistics

K čemu to slouží:
- automatický PEOPLE harvesting subsystem

Jak se využije na webu/aplikaci:
- player form engine
- fantasy scoring
- AI prediction layer
- player momentum
- player match detail
"""

import os
import sys
import time
import argparse
import subprocess


BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

QUEUE_BUILDER = (
    r"C:\MatchMatrix-platform\workers\people"
    r"\104_S_build_fb_player_match_stats_queue_v1.py"
)

PULLER = (
    r"C:\MatchMatrix-platform\workers\people"
    r"\104_T_pull_fb_player_match_stats_from_queue_v1.py"
)

PARSER = (
    r"C:\MatchMatrix-platform\workers\parsers"
    r"\104_U_parse_fb_player_match_stats_queue_payloads_v1.py"
)


def run_step(title, command):
    print("=" * 80)
    print(title)
    print("=" * 80)

    print("COMMAND:")
    print(" ".join(command))
    print("-" * 80)

    started = time.time()

    result = subprocess.run(command)

    duration = round(time.time() - started, 2)

    print("-" * 80)
    print(f"EXIT CODE : {result.returncode}")
    print(f"DURATION  : {duration} sec")

    if result.returncode != 0:
        raise RuntimeError(f"{title} FAILED")

    print("=" * 80)
    print("STEP DONE")
    print("=" * 80)
    print()

    return duration


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("--queue-limit", type=int, default=100)
    parser.add_argument("--pull-limit", type=int, default=20)
    parser.add_argument("--parse-limit", type=int, default=50)
    parser.add_argument("--timeout-sec", type=int, default=30)

    args = parser.parse_args()

    print("=" * 80)
    print("MATCHMATRIX FB PLAYER MATCH STATS CYCLE V1")
    print("=" * 80)

    total_started = time.time()

    # -------------------------------------------------------------------------
    # 1) QUEUE BUILDER
    # -------------------------------------------------------------------------

    run_step(
        "STEP 1 - BUILD QUEUE",
        [
            PYTHON_EXE,
            QUEUE_BUILDER,
            "--limit",
            str(args.queue_limit),
        ],
    )

    # -------------------------------------------------------------------------
    # 2) PULLER
    # -------------------------------------------------------------------------

    run_step(
        "STEP 2 - PULL RAW PAYLOADS",
        [
            PYTHON_EXE,
            PULLER,
            "--limit",
            str(args.pull_limit),
            "--timeout-sec",
            str(args.timeout_sec),
        ],
    )

    # -------------------------------------------------------------------------
    # 3) PARSER
    # -------------------------------------------------------------------------

    run_step(
        "STEP 3 - PARSE PAYLOADS",
        [
            PYTHON_EXE,
            PARSER,
            "--limit",
            str(args.parse_limit),
        ],
    )

    total_duration = round(time.time() - total_started, 2)

    print("=" * 80)
    print("MATCHMATRIX FB PLAYER MATCH STATS CYCLE COMPLETE")
    print("=" * 80)
    print(f"TOTAL DURATION: {total_duration} sec")
    print("=" * 80)


if __name__ == "__main__":
    main()