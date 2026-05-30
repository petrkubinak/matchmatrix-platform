"""
MATCHMATRIX CONTROL PANEL V17.4
Runtime Governance + Autonomous RUN NEXT Panel

CO TO JE:
- Kompletní ovládací panel pro orchestration scheduler.
- Navazuje na SQL sérii 107_A až 107_Z.

K ČEMU TO JE:
- Ukazuje RUN NEXT queue.
- Ukazuje runtime dashboard.
- Ukazuje audit, proč worker je / není spuštěn.
- Umí spustit první bezpečný RUN NEXT worker.

KDE TO UVIDÍME:
- Lokální Tkinter panel.
- Čte:
  - ops.v_run_next_queue_v1
  - ops.v_scheduler_runtime_dashboard_v1
  - ops.v_run_next_audit_v1

JAK SE TO VYUŽIJE NA WEBU/APLIKACI:
- Později stejná data půjdou do admin dashboardu.
- Bude z toho scheduler health, runtime monitoring a orchestration governance.
"""

import os
import sys
import json
import time
import queue
import threading
import subprocess
from datetime import datetime

import tkinter as tk
from tkinter import ttk, messagebox

import psycopg2
import psycopg2.extras


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

REFRESH_MS = 5000

WORKER_COMMANDS = {
    "CORE_INGEST_V3": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "run_ingest_cycle_v3.py"),
        "--limit", "10",
    ],
    "PEOPLE_PIPELINE_V22": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "run_people_pipeline_v22_from_planner.py"),
        "--limit", "10",
    ],
}


# ============================================================
# DB HELPERS
# ============================================================

def db_rows(sql, params=None):
    conn = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params or {})
            return cur.fetchall()
    except Exception as e:
        print("DB ERROR:", e)
        return []
    finally:
        if conn:
            conn.close()


# ============================================================
# APP
# ============================================================

class MatchMatrixPanelV174(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("MatchMatrix Control Panel V17.4 — Runtime Governance")
        self.geometry("1850x980")
        self.configure(bg="#101010")

        self.log_queue = queue.Queue()
        self.is_running_worker = False
        self.scale_value = 1.0

        self._setup_style()
        self._build_layout()
        self._bind_events()

        self.refresh_all()
        self.after(300, self.process_log_queue)

    # --------------------------------------------------------
    # STYLE
    # --------------------------------------------------------

    def _setup_style(self):
        self.style = ttk.Style()
        self.style.theme_use("clam")

        self.style.configure(
            "Treeview",
            background="#181818",
            foreground="#eeeeee",
            fieldbackground="#181818",
            rowheight=25,
            font=("Segoe UI", 10),
        )

        self.style.configure(
            "Treeview.Heading",
            background="#2b2b2b",
            foreground="#ffffff",
            font=("Segoe UI", 10, "bold"),
        )

        self.style.map(
            "Treeview",
            background=[("selected", "#375a7f")],
            foreground=[("selected", "#ffffff")],
        )

    # --------------------------------------------------------
    # LAYOUT
    # --------------------------------------------------------

    def _build_layout(self):
        header = tk.Frame(self, bg="#0d0d0d")
        header.pack(fill="x")

        title = tk.Label(
            header,
            text="MATCHMATRIX CONTROL PANEL V17.4 — Runtime Governance / Autonomous Scheduler",
            bg="#0d0d0d",
            fg="white",
            font=("Segoe UI", 16, "bold"),
        )
        title.pack(side="left", padx=12, pady=10)

        self.status_label = tk.Label(
            header,
            text="READY",
            bg="#0d0d0d",
            fg="#55ff77",
            font=("Segoe UI", 11, "bold"),
        )
        self.status_label.pack(side="right", padx=12)

        button_bar = tk.Frame(self, bg="#151515")
        button_bar.pack(fill="x", padx=0, pady=0)

        tk.Button(
            button_bar,
            text="REFRESH",
            command=self.refresh_all,
            bg="#263238",
            fg="white",
            font=("Segoe UI", 10, "bold"),
            width=18,
        ).pack(side="left", padx=8, pady=8)

        tk.Button(
            button_bar,
            text="RUN NEXT SAFE",
            command=self.run_next_safe,
            bg="#1b5e20",
            fg="white",
            font=("Segoe UI", 10, "bold"),
            width=18,
        ).pack(side="left", padx=8, pady=8)

        tk.Button(
            button_bar,
            text="CLEAR LOG",
            command=self.clear_log,
            bg="#3e2723",
            fg="white",
            font=("Segoe UI", 10, "bold"),
            width=18,
        ).pack(side="left", padx=8, pady=8)

        self.last_refresh_label = tk.Label(
            button_bar,
            text="Last refresh: -",
            bg="#151515",
            fg="#cccccc",
            font=("Segoe UI", 10),
        )
        self.last_refresh_label.pack(side="right", padx=12)

        main_pane = ttk.PanedWindow(self, orient="vertical")
        main_pane.pack(fill="both", expand=True, padx=8, pady=8)

        # RUN NEXT
        run_frame = self._section_frame("RUN NEXT QUEUE")
        self.run_next_tree = self._make_tree(run_frame)
        main_pane.add(run_frame, weight=1)

        # DASHBOARD
        dash_frame = self._section_frame("SCHEDULER RUNTIME DASHBOARD")
        self.dashboard_tree = self._make_tree(dash_frame)
        main_pane.add(dash_frame, weight=2)

        # AUDIT + LOG
        bottom_pane = ttk.PanedWindow(main_pane, orient="horizontal")

        audit_frame = self._section_frame("RUN NEXT AUDIT")
        self.audit_tree = self._make_tree(audit_frame)
        bottom_pane.add(audit_frame, weight=2)

        log_frame = self._section_frame("EXECUTION LOG")
        self.log_text = tk.Text(
            log_frame,
            bg="#050505",
            fg="#e0e0e0",
            insertbackground="white",
            font=("Consolas", 10),
            wrap="word",
        )
        self.log_text.pack(fill="both", expand=True, padx=6, pady=6)
        bottom_pane.add(log_frame, weight=1)

        main_pane.add(bottom_pane, weight=2)

    def _section_frame(self, title):
        frame = tk.Frame(self, bg="#111111", bd=1, relief="solid")
        label = tk.Label(
            frame,
            text=title,
            bg="#111111",
            fg="#ffffff",
            font=("Segoe UI", 12, "bold"),
        )
        label.pack(anchor="w", padx=8, pady=4)
        return frame

    def _make_tree(self, parent):
        wrap = tk.Frame(parent, bg="#111111")
        wrap.pack(fill="both", expand=True, padx=6, pady=6)

        tree = ttk.Treeview(wrap, show="headings")
        yscroll = ttk.Scrollbar(wrap, orient="vertical", command=tree.yview)
        xscroll = ttk.Scrollbar(wrap, orient="horizontal", command=tree.xview)

        tree.configure(yscrollcommand=yscroll.set, xscrollcommand=xscroll.set)

        tree.grid(row=0, column=0, sticky="nsew")
        yscroll.grid(row=0, column=1, sticky="ns")
        xscroll.grid(row=1, column=0, sticky="ew")

        wrap.rowconfigure(0, weight=1)
        wrap.columnconfigure(0, weight=1)

        tree.tag_configure("green", background="#123d1b", foreground="#ffffff")
        tree.tag_configure("yellow", background="#4d4a12", foreground="#ffffff")
        tree.tag_configure("red", background="#4d1212", foreground="#ffffff")
        tree.tag_configure("blue", background="#12304d", foreground="#ffffff")

        return tree

    def _bind_events(self):
        self.bind("<Control-MouseWheel>", self.zoom)

    # --------------------------------------------------------
    # ZOOM
    # --------------------------------------------------------

    def zoom(self, event):
        if event.delta > 0:
            self.scale_value += 0.05
        else:
            self.scale_value -= 0.05

        self.scale_value = max(0.7, min(self.scale_value, 2.0))

        font_size = int(10 * self.scale_value)
        row_height = int(25 * self.scale_value)

        self.style.configure("Treeview", rowheight=row_height, font=("Segoe UI", font_size))
        self.style.configure("Treeview.Heading", font=("Segoe UI", font_size, "bold"))

    # --------------------------------------------------------
    # REFRESH
    # --------------------------------------------------------

    def refresh_all(self):
        self.status_label.config(text="REFRESHING...", fg="#ffcc00")

        self.load_run_next()
        self.load_dashboard()
        self.load_audit()

        self.last_refresh_label.config(
            text=f"Last refresh: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        )
        self.status_label.config(text="READY", fg="#55ff77")

        self.after(REFRESH_MS, self.refresh_all)

    def load_run_next(self):
        sql = """
        SELECT
            run_next_rank,
            worker_code,
            worker_name,
            sport_code,
            entity,
            candidate_provider,
            run_group,
            execution_decision,
            retry_policy,
            autonomous_safe,
            orchestration_mode,
            execution_confidence_score,
            final_priority_score,
            resolved_worker_script,
            timeout_sec,
            max_attempts,
            planner_job_id
        FROM ops.v_run_next_queue_v1
        ORDER BY run_next_rank;
        """
        self.populate_tree(self.run_next_tree, db_rows(sql))

    def load_dashboard(self):
        sql = """
        SELECT
            worker_code,
            worker_name,
            sport_code,
            entity,
            candidate_provider,
            run_group,
            execution_decision,
            retry_policy,
            autonomous_safe,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            retry_risk,
            recent_retry_risk,
            total_runs,
            success_runs,
            failed_runs,
            warning_runs,
            success_rate_pct,
            avg_duration_seconds,
            dashboard_state,
            dashboard_health_color,
            included_in_run_next,
            last_status,
            last_message,
            last_started_at
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY included_in_run_next DESC,
                 execution_confidence_score DESC NULLS LAST,
                 worker_code;
        """
        self.populate_tree(self.dashboard_tree, db_rows(sql))

    def load_audit(self):
        sql = """
        SELECT
            worker_code,
            worker_name,
            sport_code,
            entity,
            candidate_provider,
            run_group,
            execution_decision,
            retry_policy,
            autonomous_safe,
            orchestration_mode,
            execution_confidence_score,
            final_priority_score,
            ready_for_scheduler,
            final_ready_for_run_next,
            worker_already_running,
            has_pending_planner_job,
            planner_guard_state,
            run_next_state,
            audit_reason,
            included_in_run_next
        FROM ops.v_run_next_audit_v1
        ORDER BY included_in_run_next DESC,
                 final_priority_score DESC NULLS LAST,
                 worker_code;
        """
        self.populate_tree(self.audit_tree, db_rows(sql))

    def populate_tree(self, tree, rows):
        tree.delete(*tree.get_children())

        if not rows:
            tree["columns"] = []
            return

        columns = list(rows[0].keys())
        tree["columns"] = columns

        for col in columns:
            tree.heading(col, text=col)
            width = 135
            if col in ("last_message", "audit_reason", "resolved_worker_script"):
                width = 330
            elif col in ("worker_code", "worker_name"):
                width = 210
            elif col in ("execution_confidence_score", "final_priority_score"):
                width = 170
            tree.column(col, width=width, anchor="center", stretch=True)

        for row in rows:
            values = []
            row_text = ""

            for col in columns:
                val = row.get(col)
                if isinstance(val, datetime):
                    val = val.strftime("%Y-%m-%d %H:%M:%S")
                elif val is None:
                    val = ""
                else:
                    val = str(val)
                values.append(val)
                row_text += " " + val

            tag = self.row_tag(row_text)
            tree.insert("", "end", values=values, tags=(tag,))

    def row_tag(self, text):
        upper = text.upper()

        if "RED" in upper or "BLOCK" in upper or "CRITICAL" in upper:
            return "red"
        if "YELLOW" in upper or "RISKY" in upper or "WARNING" in upper or "LIMITED" in upper:
            return "yellow"
        if "GREEN" in upper or "READY" in upper or "SAFE_AUTONOMOUS" in upper or "ELITE" in upper:
            return "green"
        return "blue"

    # --------------------------------------------------------
    # RUN NEXT
    # --------------------------------------------------------

    def run_next_safe(self):
        if self.is_running_worker:
            messagebox.showwarning("RUNNING", "Worker už běží.")
            return

        rows = db_rows("""
            SELECT
                run_next_rank,
                worker_code,
                worker_name,
                run_group,
                resolved_worker_script,
                timeout_sec,
                max_attempts,
                execution_decision,
                autonomous_safe
            FROM ops.v_run_next_queue_v1
            ORDER BY run_next_rank
            LIMIT 1;
        """)

        if not rows:
            messagebox.showinfo("RUN NEXT", "Není dostupný žádný SAFE RUN NEXT worker.")
            return

        job = rows[0]
        worker_code = job["worker_code"]

        if worker_code not in WORKER_COMMANDS:
            messagebox.showerror(
                "RUN NEXT",
                f"Worker {worker_code} nemá v panelu definovaný příkaz.\n"
                f"Doplň WORKER_COMMANDS."
            )
            return

        cmd = WORKER_COMMANDS[worker_code]

        self.log(f"RUN NEXT SELECTED: {worker_code}")
        self.log("CMD: " + " ".join(cmd))

        thread = threading.Thread(target=self._run_command_thread, args=(cmd, worker_code), daemon=True)
        thread.start()

    def _run_command_thread(self, cmd, worker_code):
        self.is_running_worker = True
        self.log_queue.put(("STATUS", f"RUNNING {worker_code}"))

        try:
            proc = subprocess.Popen(
                cmd,
                cwd=BASE_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
            )

            for line in proc.stdout:
                self.log_queue.put(("LOG", line.rstrip()))

            code = proc.wait()

            if code == 0:
                self.log_queue.put(("LOG", f"WORKER FINISHED OK: {worker_code}"))
            else:
                self.log_queue.put(("LOG", f"WORKER FAILED: {worker_code} | exit_code={code}"))

        except Exception as e:
            self.log_queue.put(("LOG", f"RUN ERROR: {e}"))

        finally:
            self.is_running_worker = False
            self.log_queue.put(("STATUS", "READY"))
            self.log_queue.put(("REFRESH", ""))

    # --------------------------------------------------------
    # LOG
    # --------------------------------------------------------

    def log(self, msg):
        ts = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert("end", f"[{ts}] {msg}\n")
        self.log_text.see("end")

    def clear_log(self):
        self.log_text.delete("1.0", "end")

    def process_log_queue(self):
        try:
            while True:
                msg_type, msg = self.log_queue.get_nowait()

                if msg_type == "LOG":
                    self.log(msg)
                elif msg_type == "STATUS":
                    self.status_label.config(text=msg, fg="#ffcc00" if msg != "READY" else "#55ff77")
                elif msg_type == "REFRESH":
                    self.refresh_all()

        except queue.Empty:
            pass

        self.after(300, self.process_log_queue)


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    app = MatchMatrixPanelV174()
    app.mainloop()