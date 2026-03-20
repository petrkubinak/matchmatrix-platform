import tkinter as tk
from tkinter import scrolledtext
import subprocess
import threading
import os
from datetime import datetime

# ============================================================
# MATCHMATRIX CONTROL PANEL V3
# ============================================================

BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

# ------------------------------------------------------------
# Pipeline kroky
# ------------------------------------------------------------

PIPELINE_STEPS = [

    {
        "name": "Run multisport scheduler V4",
        "description": "Spustí unified multisport ingest scheduler",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "workers", "run_multisport_scheduler_v4.py")
        ]
    },
    
    {
        "name": "Football Fixtures Batch",
        "description": "Batch ingest football fixtures (run_group, parallel)",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "ingest", "run_unified_ingest_batch_v1.py"),
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "fixtures",
            "--run-group", "FOOTBALL_MAINTENANCE",
            "--limit", "5",
            "--max-workers", "3"
        ]
    },

    {
        "name": "Football Teams Batch",
        "description": "Batch ingest football teams (run_group, parallel)",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "ingest", "run_unified_ingest_batch_v1.py"),
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "teams",
            "--run-group", "FOOTBALL_MAINTENANCE",
            "--limit", "5",
            "--max-workers", "3"
        ]
    },

    {
        "name": "Pull football fixtures",
        "description": "Unified ingest football fixtures",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "ingest", "run_unified_ingest_v1.py"),
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "fixtures",
	    "--season", "2025"	
        ]
    },

    {
        "name": "Pull football odds",
        "description": "Unified ingest football odds",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "ingest", "run_unified_ingest_v1.py"),
            "--provider", "api_football",
            "--sport", "football",
            "--entity", "odds"
        ]
    },

    {
        "name": "Players bridge",
        "description": "Bridge staging players to public",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "workers", "run_players_bridge_v1.py")
        ]
    },

    {
        "name": "Unified staging → public merge",
        "description": "Merge unified staging to public",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "workers", "run_unified_staging_to_public_merge_v1.py")
        ]
    },

    {
        "name": "Compute MMR ratings",
        "description": "Compute match ratings",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "ingest", "compute_mmr_ratings.py")
        ]
    },

    {
        "name": "Predict matches",
        "description": "Generate match predictions",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "ingest", "predict_matches_v3.py")
        ]
    },

    {
        "name": "Generate tickets",
        "description": "Ticket engine",
        "command": [
            PYTHON_EXE,
            os.path.join(BASE_DIR, "ops", "run_ticket_generation.py")
        ]
    },

]


# ------------------------------------------------------------
# GUI
# ------------------------------------------------------------

class MatchMatrixPanel:

    def __init__(self, root):

        self.root = root
        root.title("MatchMatrix Control Panel V3")
        root.geometry("1100x650")

        header = tk.Label(root, text="MatchMatrix Control Panel V3",
                          font=("Arial", 16, "bold"))
        header.pack(pady=10)

        self.steps_frame = tk.Frame(root)
        self.steps_frame.pack(fill="x", padx=10)

        self.log = scrolledtext.ScrolledText(root, height=20)
        self.log.pack(fill="both", expand=True, padx=10, pady=10)

        self.build_steps()

        btn_run_all = tk.Button(root, text="Spustit celý pipeline",
                                command=self.run_all_pipeline)
        btn_run_all.pack(pady=5)

    # --------------------------------------------------------

    def log_write(self, text):

        now = datetime.now().strftime("%H:%M:%S")
        self.log.insert(tk.END, f"[{now}] {text}\n")
        self.log.see(tk.END)

    # --------------------------------------------------------

    def build_steps(self):

        for i, step in enumerate(PIPELINE_STEPS):

            frame = tk.Frame(self.steps_frame)
            frame.pack(fill="x", pady=2)

            label = tk.Label(frame, text=step["name"], width=35, anchor="w")
            label.pack(side="left")

            btn = tk.Button(
                frame,
                text="Spustit",
                command=lambda s=step: self.run_step_thread(s)
            )
            btn.pack(side="right")

    # --------------------------------------------------------

    def run_step_thread(self, step):

        thread = threading.Thread(target=self.run_step, args=(step,))
        thread.start()

    # --------------------------------------------------------

    def run_step(self, step):

        self.log_write(f"Spouštím: {step['name']}")

        try:

            process = subprocess.Popen(
                step["command"],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True
            )

            for line in process.stdout:
                self.log_write(line.strip())

            process.wait()

            if process.returncode == 0:
                self.log_write(f"{step['name']} OK")
            else:
                self.log_write(f"{step['name']} CHYBA")

        except Exception as e:
            self.log_write(f"Chyba: {e}")

    # --------------------------------------------------------

    def run_all_pipeline(self):

        def worker():

            for step in PIPELINE_STEPS:
                self.run_step(step)

        threading.Thread(target=worker).start()


# ------------------------------------------------------------
# MAIN
# ------------------------------------------------------------

if __name__ == "__main__":

    root = tk.Tk()
    app = MatchMatrixPanel(root)
    root.mainloop()