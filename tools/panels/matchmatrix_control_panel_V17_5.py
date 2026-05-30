"""
MATCHMATRIX CONTROL PANEL V17.5
====================================================

FIALOVO-RŮŽOVÝ RUNTIME GOVERNANCE PANEL

CO TO JE:
- Enterprise orchestration dashboard
- Autonomous scheduler control panel
- Runtime governance UI

CO ZOBRAZUJE:
- RUN NEXT queue
- Runtime dashboard
- Active runs
- Runtime summary
- RUN NEXT audit
- Execution log

NA CO TO JE:
- orchestration governance
- scheduler diagnostics
- retry governance
- autonomous execution
- runtime analytics

WEB/APLIKACE:
- Budoucí admin dashboard MatchMatrix
- Scheduler operations center
"""

import os
import queue
import threading
import subprocess
from datetime import datetime

import tkinter as tk
from tkinter import ttk, messagebox

import psycopg2
import psycopg2.extras

# =========================================================
# CONFIG
# =========================================================

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

# =========================================================
# COLORS
# =========================================================

BG_MAIN = "#120018"
BG_PANEL = "#1c0826"

PURPLE = "#7c3aed"
PINK = "#ff4fd8"

GREEN = "#00ff99"
YELLOW = "#ffd84d"
RED = "#ff4d6d"

TEXT = "#f5e9ff"

# =========================================================
# DB
# =========================================================

def db_rows(sql):
    conn = None

    try:
        conn = psycopg2.connect(**DB_CONFIG)

        with conn.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor
        ) as cur:

            cur.execute(sql)
            rows = cur.fetchall()

        return rows

    except Exception as e:
        return [{"ERROR": str(e)}]

    finally:
        if conn:
            conn.close()

# =========================================================
# APP
# =========================================================

class MatchMatrixPanel(tk.Tk):

    def __init__(self):

        super().__init__()

        self.title("MATCHMATRIX CONTROL PANEL V17.5")
        self.geometry("1920x1050")
        self.configure(bg=BG_MAIN)

        self.scale = 1.0

        self.log_queue = queue.Queue()
        self.worker_running = False

        self.setup_style()
        self.build_ui()

        self.refresh_all()

        self.after(300, self.process_log_queue)

    # =====================================================
    # STYLE
    # =====================================================

    def setup_style(self):

        style = ttk.Style()
        style.theme_use("clam")

        style.configure(
            "Treeview",
            background="#180020",
            foreground=TEXT,
            fieldbackground="#180020",
            bordercolor=PURPLE,
            rowheight=26,
            font=("Segoe UI", 10),
        )

        style.configure(
            "Treeview.Heading",
            background=PURPLE,
            foreground="white",
            font=("Segoe UI", 10, "bold"),
        )

        style.map(
            "Treeview",
            background=[("selected", PINK)],
            foreground=[("selected", "black")],
        )

    # =====================================================
    # UI
    # =====================================================

    def build_ui(self):

        # HEADER
        header = tk.Frame(self, bg="#09000d", height=70)
        header.pack(fill="x")

        title = tk.Label(
            header,
            text="MATCHMATRIX CONTROL PANEL V17.5",
            bg="#09000d",
            fg=PINK,
            font=("Segoe UI", 22, "bold")
        )
        title.pack(side="left", padx=15, pady=10)

        self.status_label = tk.Label(
            header,
            text="READY",
            bg="#09000d",
            fg=GREEN,
            font=("Segoe UI", 12, "bold")
        )
        self.status_label.pack(side="right", padx=15)

        # KPI BAR
        self.kpi_bar = tk.Frame(self, bg=BG_MAIN)
        self.kpi_bar.pack(fill="x", pady=5)

        self.kpi_active = self.create_kpi_card(
            "ACTIVE RUNS", "0", PURPLE
        )

        self.kpi_ready = self.create_kpi_card(
            "READY", "0", PINK
        )

        self.kpi_blocked = self.create_kpi_card(
            "BLOCKED", "0", RED
        )

        self.kpi_health = self.create_kpi_card(
            "HEALTH", "IDLE", GREEN
        )

        # BUTTON BAR
        btn_bar = tk.Frame(self, bg=BG_MAIN)
        btn_bar.pack(fill="x")

        self.create_button(
            btn_bar,
            "REFRESH",
            "#35204a",
            self.refresh_all
        )

        self.create_button(
            btn_bar,
            "RUN NEXT SAFE",
            "#5f0f99",
            self.run_next_safe
        )

        self.create_button(
            btn_bar,
            "CLEAR LOG",
            "#7d114f",
            self.clear_log
        )

        # MAIN PANES
        main = ttk.PanedWindow(self, orient="vertical")
        main.pack(fill="both", expand=True)

        # RUN NEXT
        self.run_next_tree = self.create_section(
            main,
            "RUN NEXT QUEUE"
        )

        # DASHBOARD
        self.dashboard_tree = self.create_section(
            main,
            "SCHEDULER RUNTIME DASHBOARD"
        )

        # BOTTOM
        bottom = ttk.PanedWindow(main, orient="horizontal")

        self.audit_tree = self.create_section(
            bottom,
            "RUN NEXT AUDIT"
        )

        self.log_text = self.create_log_section(
            bottom,
            "EXECUTION LOG"
        )

        main.add(bottom, weight=2)

        # ZOOM
        self.bind("<Control-MouseWheel>", self.zoom)

    # =====================================================
    # KPI
    # =====================================================

    def create_kpi_card(self, title, value, color):

        frame = tk.Frame(
            self.kpi_bar,
            bg=BG_PANEL,
            bd=2,
            relief="solid",
            highlightbackground=color,
            highlightcolor=color,
            highlightthickness=2
        )

        frame.pack(side="left", padx=8, pady=5)

        tk.Label(
            frame,
            text=title,
            bg=BG_PANEL,
            fg=color,
            font=("Segoe UI", 10, "bold")
        ).pack(padx=25, pady=(8, 0))

        value_label = tk.Label(
            frame,
            text=value,
            bg=BG_PANEL,
            fg="white",
            font=("Segoe UI", 18, "bold")
        )
        value_label.pack(padx=25, pady=(0, 8))

        return value_label

    # =====================================================
    # BUTTON
    # =====================================================

    def create_button(self, parent, text, color, cmd):

        btn = tk.Button(
            parent,
            text=text,
            command=cmd,
            bg=color,
            fg="white",
            activebackground=PINK,
            activeforeground="black",
            font=("Segoe UI", 10, "bold"),
            width=18,
            bd=0
        )

        btn.pack(side="left", padx=8, pady=6)

    # =====================================================
    # SECTION
    # =====================================================

    def create_section(self, parent, title):

        frame = tk.Frame(parent, bg=BG_PANEL)

        tk.Label(
            frame,
            text=title,
            bg=BG_PANEL,
            fg=PINK,
            font=("Segoe UI", 13, "bold")
        ).pack(anchor="w", padx=8, pady=5)

        wrap = tk.Frame(frame, bg=BG_PANEL)
        wrap.pack(fill="both", expand=True)

        tree = ttk.Treeview(wrap, show="headings")

        vsb = ttk.Scrollbar(
            wrap,
            orient="vertical",
            command=tree.yview
        )

        hsb = ttk.Scrollbar(
            wrap,
            orient="horizontal",
            command=tree.xview
        )

        tree.configure(
            yscrollcommand=vsb.set,
            xscrollcommand=hsb.set
        )

        tree.grid(row=0, column=0, sticky="nsew")
        vsb.grid(row=0, column=1, sticky="ns")
        hsb.grid(row=1, column=0, sticky="ew")

        wrap.rowconfigure(0, weight=1)
        wrap.columnconfigure(0, weight=1)

        tree.tag_configure(
            "green",
            background="#083b2b"
        )

        tree.tag_configure(
            "yellow",
            background="#4a3b00"
        )

        tree.tag_configure(
            "red",
            background="#4a0018"
        )

        tree.tag_configure(
            "purple",
            background="#2d004d"
        )

        parent.add(frame, weight=1)

        return tree

    # =====================================================
    # LOG
    # =====================================================

    def create_log_section(self, parent, title):

        frame = tk.Frame(parent, bg=BG_PANEL)

        tk.Label(
            frame,
            text=title,
            bg=BG_PANEL,
            fg=PINK,
            font=("Segoe UI", 13, "bold")
        ).pack(anchor="w", padx=8, pady=5)

        log = tk.Text(
            frame,
            bg="#07000a",
            fg=TEXT,
            insertbackground="white",
            font=("Consolas", 10),
            wrap="word"
        )

        log.pack(fill="both", expand=True, padx=5, pady=5)

        parent.add(frame, weight=1)

        return log

    # =====================================================
    # REFRESH
    # =====================================================

    def refresh_all(self):

        self.load_run_next()
        self.load_dashboard()
        self.load_audit()
        self.load_summary()

        self.after(REFRESH_MS, self.refresh_all)

    # =====================================================
    # LOADERS
    # =====================================================

    def load_run_next(self):

        sql = """
        SELECT
            run_next_rank,
            worker_code,
            execution_decision,
            retry_policy,
            autonomous_safe,
            orchestration_mode,
            final_priority_score
        FROM ops.v_run_next_queue_v1
        ORDER BY run_next_rank;
        """

        rows = db_rows(sql)

        self.populate_tree(self.run_next_tree, rows)

    def load_dashboard(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            dashboard_state,
            dashboard_health_color,
            included_in_run_next
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY execution_confidence_score DESC;
        """

        rows = db_rows(sql)

        self.populate_tree(self.dashboard_tree, rows)

    def load_audit(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            autonomous_safe,
            final_ready_for_run_next,
            audit_reason,
            included_in_run_next
        FROM ops.v_run_next_audit_v1
        ORDER BY included_in_run_next DESC;
        """

        rows = db_rows(sql)

        self.populate_tree(self.audit_tree, rows)

    def load_summary(self):

        sql = """
        SELECT *
        FROM ops.v_active_runs_summary_v1;
        """

        rows = db_rows(sql)

        if not rows:
            return

        row = rows[0]

        self.kpi_active.config(
            text=str(row.get("active_lock_count", 0))
        )

        ready_count = len(
            db_rows("""
                SELECT 1
                FROM ops.v_run_next_queue_v1
            """)
        )

        self.kpi_ready.config(text=str(ready_count))

        blocked_count = len(
            db_rows("""
                SELECT 1
                FROM ops.v_scheduler_runtime_dashboard_v1
                WHERE execution_decision IN (
                    'BLOCK',
                    'BLOCK_TEMPORARY'
                )
            """)
        )

        self.kpi_blocked.config(
            text=str(blocked_count)
        )

        self.kpi_health.config(
            text=row.get(
                "active_runs_status",
                "IDLE"
            )
        )

    # =====================================================
    # TREE
    # =====================================================

    def populate_tree(self, tree, rows):

        tree.delete(*tree.get_children())

        if not rows:
            return

        cols = list(rows[0].keys())

        tree["columns"] = cols

        for col in cols:

            tree.heading(col, text=col)

            width = 130

            if "message" in col:
                width = 350

            if "reason" in col:
                width = 350

            tree.column(
                col,
                width=width,
                anchor="center"
            )

        for row in rows:

            values = []

            txt = ""

            for c in cols:

                v = row[c]

                if isinstance(v, datetime):
                    v = v.strftime(
                        "%Y-%m-%d %H:%M:%S"
                    )

                values.append(v)

                txt += str(v).upper()

            tag = "purple"

            if "GREEN" in txt:
                tag = "green"

            elif "YELLOW" in txt:
                tag = "yellow"

            elif "RED" in txt:
                tag = "red"

            tree.insert(
                "",
                "end",
                values=values,
                tags=(tag,)
            )

    # =====================================================
    # RUN NEXT
    # =====================================================

    def run_next_safe(self):

        if self.worker_running:

            messagebox.showwarning(
                "RUNNING",
                "Worker already running."
            )

            return

        rows = db_rows("""
            SELECT
                worker_code
            FROM ops.v_run_next_queue_v1
            ORDER BY run_next_rank
            LIMIT 1;
        """)

        if not rows:

            messagebox.showinfo(
                "RUN NEXT",
                "No runnable worker."
            )

            return

        worker = rows[0]["worker_code"]

        if worker not in WORKER_COMMANDS:

            messagebox.showerror(
                "ERROR",
                f"No command for {worker}"
            )

            return

        cmd = WORKER_COMMANDS[worker]

        self.log(
            f"RUN NEXT: {worker}"
        )

        thread = threading.Thread(
            target=self.run_worker_thread,
            args=(cmd,),
            daemon=True
        )

        thread.start()

    # =====================================================
    # THREAD
    # =====================================================

    def run_worker_thread(self, cmd):

        self.worker_running = True

        try:

            proc = subprocess.Popen(
                cmd,
                cwd=BASE_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace"
            )

            for line in proc.stdout:

                self.log_queue.put(
                    line.rstrip()
                )

            proc.wait()

        except Exception as e:

            self.log_queue.put(
                f"ERROR: {e}"
            )

        self.worker_running = False

    # =====================================================
    # LOG
    # =====================================================

    def process_log_queue(self):

        try:

            while True:

                msg = self.log_queue.get_nowait()

                self.log(msg)

        except queue.Empty:
            pass

        self.after(300, self.process_log_queue)

    def log(self, msg):

        ts = datetime.now().strftime("%H:%M:%S")

        self.log_text.insert(
            "end",
            f"[{ts}] {msg}\n"
        )

        self.log_text.see("end")

    def clear_log(self):

        self.log_text.delete(
            "1.0",
            "end"
        )

    # =====================================================
    # ZOOM
    # =====================================================

    def zoom(self, event):

        if event.delta > 0:
            self.scale += 0.05
        else:
            self.scale -= 0.05

        self.scale = max(
            0.7,
            min(self.scale, 2.0)
        )

        style = ttk.Style()

        size = int(10 * self.scale)

        style.configure(
            "Treeview",
            rowheight=int(26 * self.scale),
            font=("Segoe UI", size)
        )

        style.configure(
            "Treeview.Heading",
            font=("Segoe UI", size, "bold")
        )

# =========================================================
# MAIN
# =========================================================

if __name__ == "__main__":

    app = MatchMatrixPanel()

    app.mainloop()