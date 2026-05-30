import tkinter as tk
from tkinter import scrolledtext, messagebox
import subprocess
import threading
import datetime
import os
import json

BASE_PATH = r"C:\MatchMatrix-platform"
LOG_DIR = rf"{BASE_PATH}\logs\control_panel"
STATE_FILE = rf"{LOG_DIR}\panel_state.json"

if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR)

# ==========================================================
# MATCHMATRIX CONTROL PANEL V2
# ==========================================================
# Sekce:
# - DAILY DATA
# - CORE PIPELINE
# - CONTEXT DATA
# - TICKET ENGINE
#
# Poznámka:
# - některé kroky níže jsou připravené jako placeholdery
# - pokud soubor neexistuje, panel to ukáže v logu
# ==========================================================

SECTIONS = [
    {
        "name": "DAILY DATA",
        "steps": [
            {
                "name": "Pull football fixtures",
                "script": rf"{BASE_PATH}\ingest\parse_api_sport_fixtures.py",
                "description": "Načte / zpracuje fixtures z provider zdrojů.",
            },
            {
                "name": "Pull football odds",
                "script": rf"{BASE_PATH}\ingest\theodds_pull.py",
                "description": "Stáhne odds data.",
            },
            {
                "name": "Parse odds",
                "script": rf"{BASE_PATH}\ingest\theodds_parse.py",
                "description": "Zpracuje raw odds do DB.",
            },
            {
                "name": "Pull football data UK history",
                "script": rf"{BASE_PATH}\ingest\football_data_uk_history_pull.py",
                "description": "Doplní historická data z football-data UK.",
            },
        ],
    },
    {
        "name": "CORE PIPELINE",
        "steps": [
            {
                "name": "Players bridge",
                "script": rf"{BASE_PATH}\workers\run_players_bridge_v1.py",
                "description": "Naplní staging.stg_provider_players z players_import.",
            },
            {
                "name": "Unified staging → public merge",
                "script": rf"{BASE_PATH}\workers\run_unified_staging_to_public_merge_v1.py",
                "description": "Merge z unified staging do public core tabulek.",
            },
            {
                "name": "Compute MMR ratings",
                "script": rf"{BASE_PATH}\ingest\compute_mmr_ratings.py",
                "description": "Přepočítá mm_match_ratings a mm_team_ratings.",
            },
            {
                "name": "Predict matches",
                "script": rf"{BASE_PATH}\ingest\predict_matches_V3.py",
                "description": "Spočítá budoucí predikce do public.ml_predictions.",
            },
        ],
    },
    {
        "name": "CONTEXT DATA",
        "steps": [
            {
                "name": "Pull articles",
                "script": rf"{BASE_PATH}\context\pull_articles.py",
                "description": "Placeholder pro ingest článků a preview textů.",
            },
            {
                "name": "Pull injuries / news",
                "script": rf"{BASE_PATH}\context\pull_injuries_news.py",
                "description": "Placeholder pro news a injury signály.",
            },
            {
                "name": "Pull comments / sentiment",
                "script": rf"{BASE_PATH}\context\pull_comments_sentiment.py",
                "description": "Placeholder pro komentáře a sentiment vrstvu.",
            },
        ],
    },
    {
        "name": "TICKET ENGINE",
        "steps": [
            {
                "name": "Build candidate pool",
                "script": rf"{BASE_PATH}\ticket_engine\build_candidate_pool.py",
                "description": "Placeholder pro kandidátní pool zápasů.",
            },
            {
                "name": "Generate blocks",
                "script": rf"{BASE_PATH}\ticket_engine\generate_blocks.py",
                "description": "Placeholder pro bloky Ticket Engine.",
            },
            {
                "name": "Generate final tickets",
                "script": rf"{BASE_PATH}\ticket_engine\generate_final_tickets.py",
                "description": "Placeholder pro finální tikety.",
            },
        ],
    },
]


class MatchMatrixControlPanel:

    def __init__(self, root):
        self.root = root
        self.root.title("MatchMatrix Control Panel V2")
        self.root.geometry("1180x760")
        self.root.option_add("*Font", "Tahoma 9")

        self.step_widgets = []
        self.section_headers = []
        self.is_pipeline_running = False

        self._build_ui()
        self._load_state()

    # ------------------------------------------------------
    # UI
    # ------------------------------------------------------
    def _build_ui(self):
        header = tk.Frame(self.root)
        header.pack(fill="x", padx=12, pady=10)

        title = tk.Label(
            header,
            text="MatchMatrix Control Panel V2",
            font=("Segoe UI", 15, "bold"),
            anchor="w",
        )
        title.pack(side="left")

        btn_frame = tk.Frame(header)
        btn_frame.pack(side="right")

        tk.Button(
            btn_frame,
            text="Spustit celý pipeline",
            command=self.run_full_pipeline,
            width=18,
            font=("Arial", 8),
        ).pack(side="left", padx=4)

        tk.Button(
            btn_frame,
            text="Uložit stav",
            command=self._save_state,
            width=12,
            font=("Arial", 8),
        ).pack(side="left", padx=4)

        tk.Button(
            btn_frame,
            text="Vyčistit log",
            command=self.clear_log,
            width=12,
            font=("Arial", 8),
        ).pack(side="left", padx=4)

        body = tk.PanedWindow(self.root, orient="horizontal", sashrelief="raised", sashwidth=6)
        body.pack(fill="both", expand=True, padx=12, pady=6)

        left = tk.Frame(body)
        right = tk.Frame(body)

        body.add(left, minsize=430)   # minimum pro levý panel
        body.add(right, minsize=420)  # minimum pro pravý panel

        # Scrollovatelná levá část
        left_inner = tk.Frame(left)
        left_inner.pack(fill="both", expand=True)

        canvas = tk.Canvas(left_inner, width=560, height=650, highlightthickness=0)
        scrollbar = tk.Scrollbar(left_inner, orient="vertical", command=canvas.yview)
        self.scrollable_frame = tk.Frame(canvas)

        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Levá část: sekce a kroky
        step_index = 0
        for section in SECTIONS:
            self._build_section_header(self.scrollable_frame, section["name"])

            for step in section["steps"]:
                self._build_step_row(self.scrollable_frame, step, step_index, section["name"])
                step_index += 1

        # Pravá část: log + souhrn
        summary_frame = tk.LabelFrame(right, text="Souhrn")
        summary_frame.pack(fill="x", pady=(0, 8))

        self.summary_label = tk.Label(
            summary_frame,
            text="Připraveno. Panel čeká na spuštění.",
            justify="left",
            anchor="w",
            padx=8,
            pady=8,
        )
        self.summary_label.pack(fill="x")

        log_frame = tk.LabelFrame(right, text="Log běhu")
        log_frame.pack(fill="both", expand=True)

        self.log = scrolledtext.ScrolledText(log_frame, wrap="word", font=("Consolas", 9))
        self.log.pack(fill="both", expand=True, padx=6, pady=6)

    def _build_section_header(self, parent, title):
        frame = tk.Frame(parent, bd=1, relief="solid", bg="#d9e8fb")
        frame.pack(fill="x", pady=(6, 3))

        lbl = tk.Label(
            frame,
            text=title,
            bg="#d9e8fb",
            font=("Arial", 10, "bold"),
            anchor="w",
            padx=6,
            pady=4,
        )
        lbl.pack(fill="x")
        self.section_headers.append(lbl)

    def _build_step_row(self, parent, step, index, section_name):
        row = tk.Frame(parent, bd=1, relief="groove")
        row.pack(fill="x", pady=2)

        row.grid_columnconfigure(0, weight=0)  # název
        row.grid_columnconfigure(1, weight=0)  # status
        row.grid_columnconfigure(2, weight=1)  # poslední běh / popis
        row.grid_columnconfigure(3, weight=0)  # tlačítka

        name_lbl = tk.Label(
            row,
            text=step["name"],
            width=22,
            anchor="w",
            padx=5,
            pady=3,
            font=("Arial", 9, "bold"),
        )
        name_lbl.grid(row=0, column=0, sticky="w")

        status_lbl = tk.Label(
            row,
            text="Čeká",
            width=8,
            bg="lightgray",
            fg="black",
            pady=2,
            font=("Arial", 8, "bold"),
        )
        status_lbl.grid(row=0, column=1, sticky="w", padx=(4, 4))

        last_run_lbl = tk.Label(
            row,
            text="Poslední běh: -",
            anchor="w",
            font=("Arial", 8),
        )
        last_run_lbl.grid(row=0, column=2, columnspan=2, sticky="w", padx=(4, 4), pady=(3, 0))

        desc_lbl = tk.Label(
            row,
            text=step["description"],
            anchor="w",
            fg="#444444",
            font=("Arial", 8),
        )
        desc_lbl.grid(row=1, column=0, columnspan=3, sticky="w", padx=6, pady=(0, 3))

        btns = tk.Frame(row)
        btns.grid(row=1, column=3, sticky="e", padx=(6, 6), pady=(0, 3))

        btn_run = tk.Button(
            btns,
            text="Spustit",
            width=7,
            font=("Arial", 8),
            command=lambda idx=index: self.run_one_step(idx),
        )
        btn_run.pack(side="left", padx=(0, 4))

        btn_from_here = tk.Button(
            btns,
            text="Od tohoto kroku",
            width=12,
            font=("Arial", 8),
            command=lambda idx=index: self.run_from_step(idx),
        )
        btn_from_here.pack(side="left", padx=4)

        btn_open = tk.Button(
            btns,
            text="Otevřít soubor",
            width=11,
            font=("Arial", 8),
            command=lambda p=step["script"]: self.open_in_explorer(p),
        )
        btn_open.pack(side="left", padx=(4, 0))

        step_data = {
            "index": index,
            "section": section_name,
            "name": step["name"],
            "script": step["script"],
            "description": step["description"],
            "row": row,
            "status_label": status_lbl,
            "last_run_label": last_run_lbl,
            "run_button": btn_run,
            "from_button": btn_from_here,
            "open_button": btn_open,
            "status": "Čeká",
            "last_run": None,
            "last_result": "",
        }
        self.step_widgets.append(step_data)

    # ------------------------------------------------------
    # Utility
    # ------------------------------------------------------
    def write_log(self, text):
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        line = f"[{timestamp}] {text}\n"
        self.log.insert(tk.END, line)
        self.log.see(tk.END)
        self.log.update_idletasks()

    def clear_log(self):
        self.log.delete("1.0", tk.END)

    def update_summary(self, text):
        self.summary_label.config(text=text)

    def set_step_status(self, index, status_text, color, last_result=""):
        step = self.step_widgets[index]
        step["status"] = status_text
        step["last_result"] = last_result
        step["status_label"].config(text=status_text, bg=color)

        run_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        step["last_run"] = run_time
        step["last_run_label"].config(text=f"Poslední běh: {run_time}")

    def open_in_explorer(self, path):
        if os.path.exists(path):
            subprocess.Popen(["explorer", "/select,", path])
        else:
            messagebox.showwarning("Soubor nenalezen", f"Soubor neexistuje:\n{path}")

    def get_flat_steps(self):
        return self.step_widgets

    def disable_all_buttons(self):
        for step in self.step_widgets:
            step["run_button"].config(state="disabled")
            step["from_button"].config(state="disabled")
            step["open_button"].config(state="disabled")

    def enable_all_buttons(self):
        for step in self.step_widgets:
            step["run_button"].config(state="normal")
            step["from_button"].config(state="normal")
            step["open_button"].config(state="normal")

    def _step_log_file(self, step_index):
        day = datetime.date.today().isoformat()
        return os.path.join(LOG_DIR, f"step_{step_index:02d}_{day}.log")

    def _save_state(self):
        data = []
        for step in self.step_widgets:
            data.append(
                {
                    "index": step["index"],
                    "section": step["section"],
                    "name": step["name"],
                    "script": step["script"],
                    "description": step["description"],
                    "status": step["status"],
                    "last_run": step["last_run"],
                    "last_result": step["last_result"],
                }
            )

        with open(STATE_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        self.write_log(f"Stav panelu uložen do: {STATE_FILE}")

    def _load_state(self):
        if not os.path.exists(STATE_FILE):
            return

        try:
            with open(STATE_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)

            state_map = {row["index"]: row for row in data}

            for step in self.step_widgets:
                saved = state_map.get(step["index"])
                if not saved:
                    continue

                step["status"] = saved.get("status", "Čeká")
                step["last_run"] = saved.get("last_run")
                step["last_result"] = saved.get("last_result", "")

                color = "lightgray"
                if step["status"] == "Hotovo":
                    color = "lightgreen"
                elif step["status"] == "Chyba":
                    color = "red"
                elif step["status"] == "Běží":
                    color = "orange"

                step["status_label"].config(text=step["status"], bg=color)
                if step["last_run"]:
                    step["last_run_label"].config(text=f"Poslední běh: {step['last_run']}")

        except Exception as e:
            self.write_log(f"Chyba při načítání stavu panelu: {e}")

    # ------------------------------------------------------
    # Running
    # ------------------------------------------------------
    def _run_script(self, step_index):
        step = self.step_widgets[step_index]
        script = step["script"]
        name = step["name"]

        if not os.path.exists(script):
            self.set_step_status(step_index, "Chyba", "red", "Soubor neexistuje")
            self.write_log(f"[{name}] Soubor neexistuje: {script}")
            return False

        self.set_step_status(step_index, "Běží", "orange", "")
        self.update_summary(f"Běží: {name}")
        self.write_log(f"Spouštím {script}")

        log_file = self._step_log_file(step_index)

        try:
            process = subprocess.Popen(
                ["python", script],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
            )

            with open(log_file, "a", encoding="utf-8") as f:
                for line in process.stdout:
                    clean_line = line.rstrip("\n")
                    self.write_log(clean_line)
                    f.write(line)

            process.wait()

            if process.returncode == 0:
                self.set_step_status(step_index, "Hotovo", "lightgreen", "OK")
                self.write_log("Dokončeno")
                self._save_state()
                return True
            else:
                self.set_step_status(step_index, "Chyba", "red", f"Exit code {process.returncode}")
                self.write_log("Chyba při běhu")
                self._save_state()
                return False

        except Exception as e:
            self.set_step_status(step_index, "Chyba", "red", str(e))
            self.write_log(str(e))
            self._save_state()
            return False

    def run_one_step(self, index):
        if self.is_pipeline_running:
            messagebox.showinfo("Probíhá běh", "Momentálně už běží jiný krok nebo pipeline.")
            return

        def worker():
            self.is_pipeline_running = True
            self.disable_all_buttons()
            try:
                self._run_script(index)
                self.update_summary(f"Hotovo: {self.step_widgets[index]['name']}")
            finally:
                self.enable_all_buttons()
                self.is_pipeline_running = False

        threading.Thread(target=worker, daemon=True).start()

    def run_from_step(self, start_index):
        if self.is_pipeline_running:
            messagebox.showinfo("Probíhá běh", "Momentálně už běží jiný krok nebo pipeline.")
            return

        def worker():
            self.is_pipeline_running = True
            self.disable_all_buttons()
            try:
                self.write_log(f"Spouštím pipeline od kroku {start_index + 1}: {self.step_widgets[start_index]['name']}")
                ok = True
                for idx in range(start_index, len(self.step_widgets)):
                    ok = self._run_script(idx)
                    if not ok:
                        self.update_summary(f"Pipeline zastavena na kroku: {self.step_widgets[idx]['name']}")
                        break
                if ok:
                    self.update_summary("Pipeline od zvoleného kroku dokončena.")
            finally:
                self.enable_all_buttons()
                self.is_pipeline_running = False

        threading.Thread(target=worker, daemon=True).start()

    def run_full_pipeline(self):
        if self.is_pipeline_running:
            messagebox.showinfo("Probíhá běh", "Momentálně už běží jiný krok nebo pipeline.")
            return

        def worker():
            self.is_pipeline_running = True
            self.disable_all_buttons()
            try:
                self.write_log("=== Spouštím celý pipeline ===")
                ok = True
                for idx in range(len(self.step_widgets)):
                    ok = self._run_script(idx)
                    if not ok:
                        self.update_summary(f"Pipeline zastavena na kroku: {self.step_widgets[idx]['name']}")
                        break
                if ok:
                    self.update_summary("Celý pipeline byl úspěšně dokončen.")
            finally:
                self.enable_all_buttons()
                self.is_pipeline_running = False

        threading.Thread(target=worker, daemon=True).start()


if __name__ == "__main__":
    root = tk.Tk()
    app = MatchMatrixControlPanel(root)
    root.mainloop()