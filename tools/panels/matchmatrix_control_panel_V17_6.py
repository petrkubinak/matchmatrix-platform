"""
MATCHMATRIX CONTROL PANEL V17.6
========================================================

RUNTIME OPERATIONS CENTER

CO TO JE:
- Enterprise orchestration operations center
- Runtime governance dashboard
- Autonomous scheduler control center

CO ZOBRAZUJE:
- Runtime operations feed
- Scheduler state
- Planner pressure
- Runtime alerts
- RUN NEXT queue
- Active runtime state

NA CO TO JE:
- orchestration governance
- scheduler diagnostics
- autonomous execution
- retry governance
- runtime monitoring

WEB/APLIKACE:
- budoucí admin operations center
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

BG = "#120018"
PANEL = "#1b0826"

PURPLE = "#8b5cf6"
PINK = "#ff4fd8"

GREEN = "#00ff99"
YELLOW = "#ffd84d"
RED = "#ff5577"

TEXT = "#f5e9ff"

# =========================================================
# DB
# =========================================================

def db_query(sql):

    conn = None

    try:

        conn = psycopg2.connect(**DB_CONFIG)

        with conn.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor
        ) as cur:

            cur.execute(sql)

            return cur.fetchall()

    except Exception as e:

        return [{"ERROR": str(e)}]

    finally:

        if conn:
            conn.close()

# =========================================================
# APP
# =========================================================

class RuntimeOperationsCenter(tk.Tk):

    def __init__(self):

        super().__init__()

        self.title(
            "MATCHMATRIX CONTROL PANEL V17.6"
        )

        self.geometry("1920x1040")
        self.configure(bg=BG)

        self.scale = 1.0

        self.log_queue = queue.Queue()

        self.worker_running = False

        self.setup_style()
        self.build_ui()

        self.refresh_all()

        self.after(300, self.process_logs)

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
            rowheight=24,
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
        header = tk.Frame(
            self,
            bg="#0a0010",
            height=70
        )

        header.pack(fill="x")

        tk.Label(
            header,
            text="MATCHMATRIX RUNTIME OPERATIONS CENTER",
            bg="#0a0010",
            fg=PINK,
            font=("Segoe UI", 22, "bold")
        ).pack(
            side="left",
            padx=15,
            pady=10
        )

        self.status_label = tk.Label(
            header,
            text="READY",
            bg="#0a0010",
            fg=GREEN,
            font=("Segoe UI", 12, "bold")
        )

        self.status_label.pack(
            side="right",
            padx=15
        )

        # KPI BAR
        self.kpi_bar = tk.Frame(
            self,
            bg=BG
        )

        self.kpi_bar.pack(
            fill="x",
            pady=4
        )

        self.kpi_scheduler = self.create_kpi(
            "SCHEDULER",
            "READY",
            GREEN
        )

        self.kpi_pending = self.create_kpi(
            "PENDING",
            "0",
            YELLOW
        )

        self.kpi_alerts = self.create_kpi(
            "ALERTS",
            "0",
            RED
        )

        self.kpi_safe = self.create_kpi(
            "SAFE",
            "0",
            PURPLE
        )

        self.kpi_conf = self.create_kpi(
            "CONFIDENCE",
            "0",
            PINK
        )

        # BUTTON BAR
        btn_bar = tk.Frame(
            self,
            bg=BG
        )

        btn_bar.pack(fill="x")

        self.make_button(
            btn_bar,
            "REFRESH",
            "#41215c",
            self.refresh_all
        )

        self.make_button(
            btn_bar,
            "RUN NEXT SAFE",
            "#6410a5",
            self.run_next_safe
        )

        self.make_button(
            btn_bar,
            "CLEAR LOG",
            "#8f105d",
            self.clear_log
        )

        # MAIN
        main = ttk.PanedWindow(
            self,
            orient="vertical"
        )

        main.pack(
            fill="both",
            expand=True
        )

        # TOP
        top = ttk.PanedWindow(
            main,
            orient="horizontal"
        )

        self.feed_tree = self.create_tree_section(
            top,
            "RUNTIME OPERATIONS FEED"
        )

        self.run_next_tree = self.create_tree_section(
            top,
            "RUN NEXT QUEUE"
        )

        main.add(top, weight=2)

        # MIDDLE
        middle = ttk.PanedWindow(
            main,
            orient="horizontal"
        )

        self.dashboard_tree = self.create_tree_section(
            middle,
            "SCHEDULER DASHBOARD"
        )

        self.alerts_tree = self.create_tree_section(
            middle,
            "RUNTIME ALERTS"
        )

        main.add(middle, weight=2)

        # BOTTOM
        bottom = ttk.PanedWindow(
            main,
            orient="horizontal"
        )

        self.audit_tree = self.create_tree_section(
            bottom,
            "RUN NEXT AUDIT"
        )

        self.log_text = self.create_log_section(
            bottom,
            "EXECUTION LOG"
        )

        main.add(bottom, weight=2)

        self.bind(
            "<Control-MouseWheel>",
            self.zoom
        )

    # =====================================================
    # KPI
    # =====================================================

    def create_kpi(
        self,
        title,
        value,
        color
    ):

        frame = tk.Frame(
            self.kpi_bar,
            bg=PANEL,
            highlightbackground=color,
            highlightcolor=color,
            highlightthickness=2
        )

        frame.pack(
            side="left",
            padx=6,
            pady=4
        )

        tk.Label(
            frame,
            text=title,
            bg=PANEL,
            fg=color,
            font=("Segoe UI", 10, "bold")
        ).pack(
            padx=20,
            pady=(8, 0)
        )

        value_lbl = tk.Label(
            frame,
            text=value,
            bg=PANEL,
            fg="white",
            font=("Segoe UI", 18, "bold")
        )

        value_lbl.pack(
            padx=20,
            pady=(0, 8)
        )

        return value_lbl

    # =====================================================
    # BUTTON
    # =====================================================

    def make_button(
        self,
        parent,
        text,
        color,
        cmd
    ):

        tk.Button(
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
        ).pack(
            side="left",
            padx=6,
            pady=6
        )

    # =====================================================
    # TREE
    # =====================================================

    def create_tree_section(
        self,
        parent,
        title
    ):

        frame = tk.Frame(
            parent,
            bg=PANEL
        )

        tk.Label(
            frame,
            text=title,
            bg=PANEL,
            fg=PINK,
            font=("Segoe UI", 12, "bold")
        ).pack(
            anchor="w",
            padx=8,
            pady=4
        )

        wrap = tk.Frame(
            frame,
            bg=PANEL
        )

        wrap.pack(
            fill="both",
            expand=True
        )

        tree = ttk.Treeview(
            wrap,
            show="headings"
        )

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

        tree.grid(
            row=0,
            column=0,
            sticky="nsew"
        )

        vsb.grid(
            row=0,
            column=1,
            sticky="ns"
        )

        hsb.grid(
            row=1,
            column=0,
            sticky="ew"
        )

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
            background="#2b0a4d"
        )

        parent.add(frame, weight=1)

        return tree

    # =====================================================
    # LOG
    # =====================================================

    def create_log_section(
        self,
        parent,
        title
    ):

        frame = tk.Frame(
            parent,
            bg=PANEL
        )

        tk.Label(
            frame,
            text=title,
            bg=PANEL,
            fg=PINK,
            font=("Segoe UI", 12, "bold")
        ).pack(
            anchor="w",
            padx=8,
            pady=4
        )

        log = tk.Text(
            frame,
            bg="#060009",
            fg=TEXT,
            insertbackground="white",
            font=("Consolas", 10),
            wrap="word"
        )

        log.pack(
            fill="both",
            expand=True,
            padx=5,
            pady=5
        )

        parent.add(frame, weight=1)

        return log

    # =====================================================
    # REFRESH
    # =====================================================

    def refresh_all(self):

        self.load_feed()
        self.load_run_next()
        self.load_dashboard()
        self.load_alerts()
        self.load_audit()
        self.load_kpis()

        self.after(
            REFRESH_MS,
            self.refresh_all
        )

    # =====================================================
    # LOADERS
    # =====================================================

    def load_feed(self):

        sql = """
        SELECT
            feed_type,
            object_type,
            object_name,
            severity,
            color,
            message,
            event_time
        FROM ops.v_runtime_operations_center_feed_v1
        ORDER BY event_time DESC
        LIMIT 100;
        """

        self.populate_tree(
            self.feed_tree,
            db_query(sql)
        )

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

        self.populate_tree(
            self.run_next_tree,
            db_query(sql)
        )

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

        self.populate_tree(
            self.dashboard_tree,
            db_query(sql)
        )

    def load_alerts(self):

        sql = """
        SELECT
            alert_type,
            source_object,
            alert_severity,
            alert_count,
            last_alert_message,
            last_alert_time
        FROM ops.v_runtime_alerts_grouped_v1
        ORDER BY last_alert_time DESC;
        """

        self.populate_tree(
            self.alerts_tree,
            db_query(sql)
        )

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

        self.populate_tree(
            self.audit_tree,
            db_query(sql)
        )

    # =====================================================
    # KPI LOADER
    # =====================================================

    def load_kpis(self):

        sched = db_query("""
            SELECT *
            FROM ops.v_scheduler_queue_summary_v1;
        """)

        plan = db_query("""
            SELECT *
            FROM ops.v_planner_queue_summary_v1;
        """)

        alerts = db_query("""
            SELECT COUNT(*) AS cnt
            FROM ops.v_runtime_alerts_v1;
        """)

        if sched:

            row = sched[0]

            self.kpi_scheduler.config(
                text=row.get(
                    "scheduler_state",
                    "READY"
                )
            )

            self.kpi_safe.config(
                text=str(
                    row.get(
                        "safe_autonomous_workers",
                        0
                    )
                )
            )

            self.kpi_conf.config(
                text=str(
                    round(
                        float(
                            row.get(
                                "avg_confidence_score",
                                0
                            )
                        ),
                        1
                    )
                )
            )

        if plan:

            row = plan[0]

            self.kpi_pending.config(
                text=str(
                    row.get(
                        "pending_jobs",
                        0
                    )
                )
            )

        if alerts:

            self.kpi_alerts.config(
                text=str(
                    alerts[0]["cnt"]
                )
            )

    # =====================================================
    # TREE POPULATE
    # =====================================================

    def populate_tree(
        self,
        tree,
        rows
    ):

        tree.delete(
            *tree.get_children()
        )

        if not rows:
            return

        cols = list(rows[0].keys())

        tree["columns"] = cols

        for col in cols:

            tree.heading(
                col,
                text=col
            )

            width = 140

            if "message" in col:
                width = 380

            tree.column(
                col,
                width=width,
                anchor="center"
            )

        for row in rows:

            vals = []

            txt = ""

            for c in cols:

                v = row[c]

                if isinstance(v, datetime):
                    v = v.strftime(
                        "%Y-%m-%d %H:%M:%S"
                    )

                vals.append(v)

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
                values=vals,
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

        rows = db_query("""
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

    def run_worker_thread(
        self,
        cmd
    ):

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
    # LOGS
    # =====================================================

    def process_logs(self):

        try:

            while True:

                msg = self.log_queue.get_nowait()

                self.log(msg)

        except queue.Empty:
            pass

        self.after(
            300,
            self.process_logs
        )

    def log(
        self,
        msg
    ):

        ts = datetime.now().strftime(
            "%H:%M:%S"
        )

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

    def zoom(
        self,
        event
    ):

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
            rowheight=int(
                24 * self.scale
            ),
            font=("Segoe UI", size)
        )

        style.configure(
            "Treeview.Heading",
            font=(
                "Segoe UI",
                size,
                "bold"
            )
        )

# =========================================================
# MAIN
# =========================================================

if __name__ == "__main__":

    app = RuntimeOperationsCenter()

    app.mainloop()