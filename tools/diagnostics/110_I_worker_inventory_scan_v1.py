# ============================================================
# MATCHMATRIX 110_I WORKER INVENTORY SCAN V1
# ============================================================
#
# CO TO JE:
# Inventura všech Python skriptů v:
# - workers
# - ingest
#
# K ČEMU TO JE:
# - vytvoří centrální seznam workerů
# - zjistí co existuje
# - zjistí co chybí
# - připraví podklady pro autonomní OPS
# - připraví podklady pro Control Panel
#
# KDE TO UVIDÍME:
# output/worker_inventory.csv
#
# JAK SE TO VYUŽIJE:
# - registr workerů
# - mapování akcí AI -> worker
# - automatické spouštění
# - audit coverage
#
# ============================================================

from pathlib import Path
import csv

BASE_DIR = Path(r"C:\MatchMatrix-platform")

SCAN_DIRS = [
    BASE_DIR / "workers",
    BASE_DIR / "ingest"
]

OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(exist_ok=True)

OUTPUT_FILE = OUTPUT_DIR / "worker_inventory.csv"

KEYWORDS = [
    "run_",
    "pull_",
    "parse_",
    "merge_",
    "build_",
    "extract_",
    "scheduler",
    "planner",
    "harvest",
    "media",
    "people"
]


def detect_type(filename: str):

    f = filename.lower()

    if "planner" in f:
        return "PLANNER"

    if "scheduler" in f:
        return "SCHEDULER"

    if "harvest" in f:
        return "HARVEST"

    if "media" in f:
        return "MEDIA"

    if "people" in f:
        return "PEOPLE"

    if "merge" in f:
        return "MERGE"

    if "parse" in f:
        return "PARSER"

    if "pull" in f:
        return "PULL"

    if "extract" in f:
        return "EXTRACT"

    if "run_" in f:
        return "RUNNER"

    return "OTHER"


def main():

    print("=" * 80)
    print("MATCHMATRIX WORKER INVENTORY SCAN V1")
    print("=" * 80)

    rows = []

    for scan_dir in SCAN_DIRS:

        if not scan_dir.exists():
            continue

        for file in scan_dir.rglob("*.py"):

            rel_path = file.relative_to(BASE_DIR)

            rows.append([
                detect_type(file.name),
                file.name,
                str(rel_path),
                str(file.parent)
            ])

    rows.sort(key=lambda x: (x[0], x[1]))

    with open(
        OUTPUT_FILE,
        "w",
        newline="",
        encoding="utf-8"
    ) as f:

        writer = csv.writer(f, delimiter=";")

        writer.writerow([
            "script_type",
            "file_name",
            "relative_path",
            "folder"
        ])

        writer.writerows(rows)

    print()
    print(f"SCRIPTS FOUND: {len(rows)}")
    print()
    print("OUTPUT:")
    print(OUTPUT_FILE)
    print()
    print("DONE")


if __name__ == "__main__":
    main()