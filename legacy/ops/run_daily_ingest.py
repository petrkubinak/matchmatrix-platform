import subprocess
import sys
from pathlib import Path

ROOT = Path(r"C:\MatchMatrix-platform")
OPS_DIR = ROOT / "ops"
INGEST_DIR = ROOT / "ingest"

PYTHON_EXE = sys.executable

# Aktivní sporty pro denní ingest
SPORTS = [
    "football",
    "hockey",
    "basketball",
]

# Joby, které chceme denně tahat
DAILY_PROVIDER_JOBS = {
    "football": [
        "football_leagues",
        "football_fixtures_daily",
    ],
    "hockey": [
        "hockey_leagues",
        "hockey_fixtures_daily",
    ],
    "basketball": [
        "basketball_leagues",
        "basketball_fixtures_daily",
    ],
}

# Parsers, které chceme po fetchi spustit
DAILY_PARSERS = {
    "football": [
        "parse_api_sport_leagues.py",
        "parse_api_sport_fixtures.py",
    ],
    "hockey": [
        "parse_api_sport_leagues.py",
        "parse_api_sport_fixtures.py",
    ],
    "basketball": [
        "parse_api_sport_leagues.py",
        "parse_api_sport_fixtures.py",
    ],
}


def run_cmd(cmd: list[str]) -> int:
    print("\nRUN:", " ".join(str(x) for x in cmd))
    result = subprocess.run(cmd, cwd=str(ROOT))
    return result.returncode


def run_provider_job(sport_code: str, job_code: str) -> bool:
    cmd = [
        PYTHON_EXE,
        str(OPS_DIR / "run_provider_job.py"),
        "api_sport",
        sport_code,
        job_code,
    ]
    rc = run_cmd(cmd)
    return rc == 0


def run_parser(script_name: str, sport_code: str) -> bool:
    cmd = [
        PYTHON_EXE,
        str(INGEST_DIR / script_name),
        sport_code,
    ]
    rc = run_cmd(cmd)
    return rc == 0


def main():
    overall_ok = True

    print("=== MATCHMATRIX DAILY INGEST START ===")

    for sport_code in SPORTS:
        print(f"\n=== SPORT: {sport_code.upper()} ===")

        jobs = DAILY_PROVIDER_JOBS.get(sport_code, [])
        parsers = DAILY_PARSERS.get(sport_code, [])

        # 1) Provider fetch
        for job_code in jobs:
            ok = run_provider_job(sport_code, job_code)
            if not ok:
                overall_ok = False
                print(f"ERROR: provider job failed: {sport_code} / {job_code}")

        # 2) Canonical parsers
        for parser_name in parsers:
            ok = run_parser(parser_name, sport_code)
            if not ok:
                overall_ok = False
                print(f"ERROR: parser failed: {sport_code} / {parser_name}")

    print("\n=== MATCHMATRIX DAILY INGEST END ===")

    if overall_ok:
        print("DAILY INGEST OK")
        sys.exit(0)
    else:
        print("DAILY INGEST FINISHED WITH ERRORS")
        sys.exit(1)


if __name__ == "__main__":
    main()