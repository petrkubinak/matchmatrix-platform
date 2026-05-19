import subprocess
import time
import os

PYTHON_EXE = r"C:\Python314\python.exe"
WORKER = r"C:\MatchMatrix-platform\workers\run_people_pipeline_v22_from_planner.py"

# === KONFIGURACE ===
RUN_GROUP = "PEOPLE_READY_2024"
LIMIT = 20
SLEEP_BETWEEN_RUNS = 60  # sekundy mezi dávkami
MAX_LOOPS = 9999         # kolikrát se má otočit (prakticky nekonečno)

def run_batch():
    cmd = [
        PYTHON_EXE,
        WORKER,
        "--provider", "api_football",
        "--sport", "FB",
        "--entity", "players",
        "--run-group", RUN_GROUP,
        "--limit", str(LIMIT),
        "--max-pages", "5",
        "--sleep-sec", "1.5",
        "--http-retries", "5",
        "--retry-sleep-sec", "20",
        "--timeout-sec", "300"
    ]

    print("=" * 80)
    print("RUN PEOPLE BATCH")
    print("CMD:", " ".join(cmd))
    print("=" * 80)

    result = subprocess.run(cmd)
    return result.returncode


def main():
    print("=== MATCHMATRIX PEOPLE SCHEDULER V1 ===")
    print(f"RUN_GROUP: {RUN_GROUP}")
    print(f"LIMIT: {LIMIT}")
    print(f"SLEEP: {SLEEP_BETWEEN_RUNS}s")

    loop = 0

    while loop < MAX_LOOPS:
        loop += 1
        print(f"\n--- LOOP {loop} ---")

        code = run_batch()

        if code != 0:
            print("❌ Worker error, čekám 120s...")
            time.sleep(120)
            continue

        print(f"✔ Batch hotový, čekám {SLEEP_BETWEEN_RUNS}s...")
        time.sleep(SLEEP_BETWEEN_RUNS)


if __name__ == "__main__":
    main()