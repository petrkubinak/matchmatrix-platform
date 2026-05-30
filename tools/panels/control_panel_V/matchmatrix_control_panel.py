import tkinter as tk
from tkinter import scrolledtext
import subprocess
import threading
import datetime
import os

BASE_PATH = r"C:\MatchMatrix-platform"

STEPS = [
    ("Players bridge", rf"{BASE_PATH}\workers\run_players_bridge_v1.py"),
    ("Unified staging → public merge", rf"{BASE_PATH}\workers\run_unified_staging_to_public_merge_v1.py"),
    ("Compute MMR ratings", rf"{BASE_PATH}\ingest\compute_mmr_ratings.py"),
    ("Predict matches", rf"{BASE_PATH}\ingest\predict_matches_V3.py"),
]

LOG_DIR = rf"{BASE_PATH}\logs\control_panel"

if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR)


class ControlPanel:

    def __init__(self, root):
        self.root = root
        self.root.title("MatchMatrix Control Panel V1")
        self.root.geometry("900x600")

        self.status_labels = []

        self.create_ui()

    def create_ui(self):

        title = tk.Label(self.root, text="MatchMatrix Pipeline Control Panel", font=("Arial", 16, "bold"))
        title.pack(pady=10)

        frame = tk.Frame(self.root)
        frame.pack(fill="x", padx=20)

        for i, (name, script) in enumerate(STEPS):

            row = tk.Frame(frame)
            row.pack(fill="x", pady=5)

            label = tk.Label(row, text=name, width=30, anchor="w")
            label.pack(side="left")

            status = tk.Label(row, text="Čeká", width=12, bg="lightgray")
            status.pack(side="left", padx=5)

            btn = tk.Button(row, text="Spustit", command=lambda s=script, idx=i: self.run_step(s, idx))
            btn.pack(side="left", padx=5)

            self.status_labels.append(status)

        run_all_btn = tk.Button(self.root, text="Spustit celý pipeline", command=self.run_all)
        run_all_btn.pack(pady=10)

        self.log = scrolledtext.ScrolledText(self.root, height=20)
        self.log.pack(fill="both", expand=True, padx=20, pady=10)

    def write_log(self, text):

        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        line = f"[{timestamp}] {text}\n"

        self.log.insert(tk.END, line)
        self.log.see(tk.END)

    def run_script(self, script, index):

        self.status_labels[index].config(text="Běží", bg="orange")
        self.write_log(f"Spouštím {script}")

        log_file = os.path.join(LOG_DIR, f"log_{index}_{datetime.date.today()}.txt")

        try:

            process = subprocess.Popen(
                ["python", script],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True
            )

            with open(log_file, "a", encoding="utf8") as f:

                for line in process.stdout:
                    self.write_log(line.strip())
                    f.write(line)

            process.wait()

            if process.returncode == 0:
                self.status_labels[index].config(text="Hotovo", bg="lightgreen")
                self.write_log("Dokončeno")
            else:
                self.status_labels[index].config(text="Chyba", bg="red")
                self.write_log("Chyba při běhu")

        except Exception as e:

            self.status_labels[index].config(text="Chyba", bg="red")
            self.write_log(str(e))

    def run_step(self, script, index):

        thread = threading.Thread(target=self.run_script, args=(script, index))
        thread.start()

    def run_all(self):

        def pipeline():

            for i, (name, script) in enumerate(STEPS):
                self.run_script(script, i)

        thread = threading.Thread(target=pipeline)
        thread.start()


root = tk.Tk()
app = ControlPanel(root)

root.mainloop()