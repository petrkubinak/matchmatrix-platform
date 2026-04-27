# ============================================================
# worker_template_multisport_v1.py
# MatchMatrix generic multisport worker
#
# Použití:
# python workers\worker_template_multisport_v1.py --provider api_american_football --sport AFB --entity fixtures --run-group AFB_CORE
# ============================================================

import argparse
import subprocess
import sys
from pathlib import Path
from datetime import datetime


BASE_DIR = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = Path(r"C:\Python314\python.exe")


# ------------------------------------------------------------
# Registry: tady se postupně doplňují sporty/entity
# ------------------------------------------------------------
JOB_REGISTRY = {
    ("api_american_football", "AFB", "teams"): {
        "pull": BASE_DIR / "ingest/API-American-Football/pull_api_american_football_teams.ps1",
        "parse": None,
        "merge": BASE_DIR / "workers/merge_runner_multisport_v1.py",
        "note": "AFB teams už normalizované do stg_provider_teams",
    },
    ("api_american_football", "AFB", "fixtures"): {
        "pull": BASE_DIR / "ingest/API-American-Football/pull_api_american_football_fixtures.ps1",
        "parse": None,
        "merge": BASE_DIR / "workers/merge_runner_multisport_v1.py",
        "note": "AFB fixtures už normalizované do stg_provider_fixtures",
    },

    ("api_handball", "HB", "leagues"): {
        "pull": BASE_DIR / "ingest/API-Handball/pull_api_handball_leagues.ps1",
        "parse": BASE_DIR / "ingest/API-Handball/parse_api_handball_leagues_v1.py",
        "merge": None,
        "note": "HB leagues confirmed",
    },

    ("api_handball", "HB", "teams"): {
        "pull": BASE_DIR / "ingest/API-Handball/pull_api_handball_teams.ps1",
        "parse": None,
        "merge": None,
        "note": "HB teams confirmed, ale team_name enrichment je TODO",
    },
    ("api_handball", "HB", "fixtures"): {
        "pull": BASE_DIR / "ingest/API-Handball/pull_api_handball_fixtures.ps1",
        "parse": None,
        "merge": None,
        "note": "HB fixtures confirmed, public.matches=2517",
    },

    ("api_cricket", "CK", "leagues"): {
        "pull": BASE_DIR / "ingest/API-Cricket/pull_api_cricket_leagues_v1.py",
        "parse": BASE_DIR / "ingest/API-Cricket/parse_api_cricket_leagues_v1.py",
        "merge": None,
        "note": "CK leagues confirmed",
    },
    ("api_cricket", "CK", "teams"): {
        "pull": BASE_DIR / "ingest/API-Cricket/pull_api_cricket_teams_v1.py",
        "parse": BASE_DIR / "ingest/API-Cricket/parse_api_cricket_teams_v1.py",
        "merge": None,
        "note": "CK teams confirmed",
    },
    ("api_cricket", "CK", "fixtures"): {
        "pull": BASE_DIR / "ingest/API-Cricket/pull_api_cricket_fixtures_v1.py",
        "parse": BASE_DIR / "ingest/API-Cricket/parse_api_cricket_fixtures_v1.py",
        "merge": None,
        "note": "CK fixtures confirmed",
    },
}


def log(msg: str) -> None:
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)


def run_script(path: Path, timeout_sec: int, cli_args=None) -> None:
    if path is None:
        return

    cli_args = cli_args or []

    if not path.exists():
        raise FileNotFoundError(f"Soubor neexistuje: {path}")

    suffix = path.suffix.lower()

    if suffix == ".py":
        cmd = [str(PYTHON_EXE), str(path)] + cli_args
    elif suffix == ".ps1":
        cmd = [
            "powershell",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(path),
        ]
    elif suffix == ".sql":
        raise RuntimeError("SQL merge zatím nespouštíme automaticky v template v1.")
    else:
        raise RuntimeError(f"Nepodporovaný typ souboru: {path}")

    log(f"RUN: {' '.join(cmd)}")
    result = subprocess.run(
        cmd,
        cwd=str(BASE_DIR),
        timeout=timeout_sec,
        text=True,
        capture_output=True,
    )

    if result.stdout:
        print(result.stdout)

    if result.stderr:
        print(result.stderr, file=sys.stderr)

    if result.returncode != 0:
        raise RuntimeError(f"Skript skončil chybou: {path} | exit={result.returncode}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--provider", required=True)
    parser.add_argument("--sport", required=True)
    parser.add_argument("--entity", required=True)
    parser.add_argument("--run-group", required=True)
    parser.add_argument("--timeout-sec", type=int, default=300)
    parser.add_argument("--skip-pull", action="store_true")
    parser.add_argument("--skip-parse", action="store_true")
    parser.add_argument("--skip-merge", action="store_true")
    args = parser.parse_args()

    key = (args.provider, args.sport, args.entity)

    log("=" * 70)
    log("MATCHMATRIX MULTISPORT WORKER TEMPLATE V1")
    log("=" * 70)
    log(f"Provider : {args.provider}")
    log(f"Sport    : {args.sport}")
    log(f"Entity   : {args.entity}")
    log(f"RunGroup : {args.run_group}")
    log("=" * 70)

    job = JOB_REGISTRY.get(key)

    if not job:
        log(f"ERROR: Kombinace není v JOB_REGISTRY: {key}")
        return 2

    log(f"NOTE: {job.get('note', '')}")

    try:
        if not args.skip_pull:
            log("STEP 1/3: pull")
            run_script(job.get("pull"), args.timeout_sec)
        else:
            log("STEP 1/3: pull skipped")

        if not args.skip_parse:
            log("STEP 2/3: parse")
            run_script(job.get("parse"), args.timeout_sec)
        else:
            log("STEP 2/3: parse skipped")

        if not args.skip_merge:
            log("STEP 3/3: merge")
            run_script(
                job.get("merge"),
                args.timeout_sec,
                [
                    "--provider", args.provider,
                    "--sport", args.sport,
                    "--entity", args.entity,
                    "--run-group", args.run_group,
                ],
            )
        else:
            log("STEP 3/3: merge skipped")

        log("RESULT: OK")
        return 0

    except Exception as e:
        log(f"RESULT: ERROR | {e}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())