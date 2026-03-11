import os
import subprocess
import sys

from lib.job_logger import logged_job


ROOT = r"C:\MatchMatrix-platform"

SCRIPTS = {
    "compute_mmr": os.path.join(ROOT, "ingest", "compute_mmr_ratings.py"),
    "predict_v3": os.path.join(ROOT, "ingest", "predict_matches_V3.py"),
    "sql_task": os.path.join(ROOT, "ops", "run_sql_task.py"),
}


def run_step(cmd: list[str], env: dict):
    print("RUN:", " ".join(cmd))
    result = subprocess.run(cmd, env=env, check=True)
    return result.returncode


def main():
    env = os.environ.copy()

    with logged_job("daily_pipeline", params={"pipeline": "ratings->features->predictions->ticket_settlement"}):
        # 1) ratings
        run_step([sys.executable, SCRIPTS["compute_mmr"]], env)

        # 2) build match features
        run_step(
            [
                sys.executable,
                SCRIPTS["sql_task"],
                "build_match_features",
                open(r"C:\MatchMatrix-platform\MatchMatrix-platform\Scripts\03_generation\020_mm_ui_run_tickets_with_stake.sql\023_mm_build_match_features.sql").read(),
            ],
            env,
        )

        # 3) predictions
        run_step([sys.executable, SCRIPTS["predict_v3"]], env)

        # 4) refresh ticket runtime settlement
        run_step(
            [
                sys.executable,
                SCRIPTS["sql_task"],
                "refresh_ticket_run_settlements",
                "SELECT public.fn_refresh_ticket_run_settlements();",
            ],
            env,
        )

    print("Daily pipeline OK")


if __name__ == "__main__":
    main()