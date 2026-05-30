"""
MATCHMATRIX CONTROL PANEL V17.7
========================================================

INTERNÍ ORCHESTRATION OPERATIONS CENTER
(ČESKÁ ADMIN VERZE)

CO TO JE:
- Interní admin panel MatchMatrix.
- Runtime governance dashboard.
- Scheduler operations center.

CO ZOBRAZUJE:
- Stav systému
- Frontu ke spuštění
- Plánovačquality18@myhongli.com
- Upozornění
- Poslední chyby
- Aktivní běhy
- Log spuštění

POUZE PRO INTERNÍ POUŽITÍ.
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
# BARVY
# =========================================================

BG = "#120018"
PANEL = "#1d0828"

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

        return [{"CHYBA": str(e)}]

    finally:

        if conn:
            conn.close()

# =========================================================
# APP
# =========================================================

class MatchMatrixAdminPanel(tk.Tk):

    def __init__(self):

        super().__init__()

        self.title(
            "MATCHMATRIX CONTROL PANEL V17.7"
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
            bg="#09000d",
            height=70
        )

        header.pack(fill="x")

        tk.Label(
            header,
            text="MATCHMATRIX OPERATIONS CENTER",
            bg="#09000d",
            fg=PINK,
            font=("Segoe UI", 22, "bold")
        ).pack(
            side="left",
            padx=15,
            pady=10
        )

        self.system_state = tk.Label(
            header,
            text="READY",
            bg="#09000d",
            fg=GREEN,
            font=("Segoe UI", 12, "bold")
        )

        self.system_state.pack(
            side="right",
            padx=15
        )

        # KPI
        self.kpi_bar = tk.Frame(
            self,
            bg=BG
        )

        self.kpi_bar.pack(
            fill="x",
            pady=3
        )

        self.kpi_stav = self.create_kpi(
            "STAV",
            "READY",
            GREEN
        )

        self.kpi_pending = self.create_kpi(
            "ČEKAJÍCÍ",
            "0",
            YELLOW
        )

        self.kpi_alerty = self.create_kpi(
            "ALERTY",
            "0",
            RED
        )

        self.kpi_safe = self.create_kpi(
            "SAFE",
            "0",
            PURPLE
        )

        self.kpi_conf = self.create_kpi(
            "DŮVĚRA",
            "0",
            PINK
        )

        # BUTTONS
        btn_bar = tk.Frame(
            self,
            bg=BG
        )

        btn_bar.pack(fill="x")

        self.make_button(
            btn_bar,
            "OBNOVIT",
            "#452060",
            self.refresh_all
        )

        self.make_button(
            btn_bar,
            "RUN NEXT SAFE",
            "#6d14aa",
            self.run_next_safe
        )

        self.make_button(
            btn_bar,
            "VYMAZAT LOG",
            "#90115d",
            self.clear_log
        )

        # MAIN GRID
        main = tk.Frame(
            self,
            bg=BG
        )

        main.pack(
            fill="both",
            expand=True,
            padx=5,
            pady=5
        )

        main.columnconfigure(0, weight=3)
        main.columnconfigure(1, weight=2)

        main.rowconfigure(0, weight=2)
        main.rowconfigure(1, weight=2)
        main.rowconfigure(2, weight=2)
        main.rowconfigure(3, weight=2)

        # LEFT
        self.feed_tree = self.create_section(
            main,
            "UDÁLOSTI ORCHESTRACE",
            0,
            0
        )

        self.run_next_tree = self.create_section(
            main,
            "FRONTA KE SPUŠTĚNÍ",
            1,
            0
        )

        self.audit_tree = self.create_section(
            main,
            "AUDIT ORCHESTRACE",
            2,
            0
        )

        # RIGHT
        self.alerts_tree = self.create_section(
            main,
            "UPOZORNĚNÍ",
            0,
            1
        )

        self.dashboard_tree = self.create_section(
            main,
            "STAV SCHEDULERU",
            1,
            1
        )

        self.cooldown_tree = self.create_section(
            main,
            "PLANNER COOLDOWN",
            2,
            1
        )

        self.worker_health_tree = self.create_section(
            main,
            "WORKER HEALTH",
            2,
            1
        )

        self.log_text = self.create_log_section(
            main,
            "LOG SPUŠTĚNÍ",
            3,
            0
        )

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
            highlightthickness=2
        )

        frame.pack(
            side="left",
            padx=5,
            pady=3
        )

        tk.Label(
            frame,
            text=title,
            bg=PANEL,
            fg=color,
            font=("Segoe UI", 10, "bold")
        ).pack(
            padx=20,
            pady=(7, 0)
        )

        lbl = tk.Label(
            frame,
            text=value,
            bg=PANEL,
            fg="white",
            font=("Segoe UI", 18, "bold")
        )

        lbl.pack(
            padx=20,
            pady=(0, 7)
        )

        return lbl

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
            padx=5,
            pady=5
        )

    # =====================================================
    # SECTION
    # =====================================================

    def create_section(
        self,
        parent,
        title,
        row,
        col
    ):

        frame = tk.Frame(
            parent,
            bg=PANEL
        )

        frame.grid(
            row=row,
            column=col,
            sticky="nsew",
            padx=4,
            pady=4
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
            background="#2d004d"
        )

        return tree

    # =====================================================
    # LOG
    # =====================================================

    def create_log_section(
        self,
        parent,
        title,
        row,
        col
    ):

        frame = tk.Frame(
            parent,
            bg=PANEL
        )

        frame.grid(
            row=row,
            column=col,
            sticky="nsew",
            padx=4,
            pady=4
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
            bg="#050008",
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

        return log

    # =====================================================
    # REFRESH
    # =====================================================

    def refresh_all(self):

        self.load_summary()
        self.load_feed()
        self.load_run_next()
        self.load_alerts()
        self.load_dashboard()
        self.load_worker_health()
        self.load_cooldown()
        self.load_audit()

        self.after(
            REFRESH_MS,
            self.refresh_all
        )

    # =====================================================
    # LOADERS
    # =====================================================

    def load_summary(self):

        rows = db_query("""
            SELECT *
            FROM ops.v_operations_center_summary_v1;
        """)

        if not rows:
            return

        row = rows[0]

        self.kpi_stav.config(
            text=row["operations_state"]
        )

        self.kpi_pending.config(
            text=str(row["pending_jobs"])
        )

        self.kpi_alerty.config(
            text=str(row["alert_groups"])
        )

        self.kpi_safe.config(
            text=str(
                row["safe_autonomous_workers"]
            )
        )

        self.kpi_conf.config(
            text=str(
                row["avg_confidence_score"]
            )
        )

        color = row["operations_color"]

        if color == "GREEN":
            fg = GREEN
        elif color == "YELLOW":
            fg = YELLOW
        elif color == "RED":
            fg = RED
        else:
            fg = PURPLE

        self.system_state.config(
            text=row["operations_state"],
            fg=fg
        )

    def load_feed(self):

        sql = """
        SELECT
            feed_type,
            object_name,
            severity,
            message,
            event_time
        FROM ops.v_runtime_operations_center_feed_v1
        ORDER BY event_time DESC
        LIMIT 80;
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
            final_priority_score
        FROM ops.v_run_next_queue_v1
        ORDER BY run_next_rank;
        """

        self.populate_tree(
            self.run_next_tree,
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

    def load_dashboard(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            dashboard_state
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY execution_confidence_score DESC;
        """

        self.populate_tree(
            self.dashboard_tree,
            db_query(sql)
        )

    def load_worker_health(self):

        sql = """
        SELECT
            worker_code,
            scheduler_health_tier,
            recent_health_tier,
            execution_confidence_score,
            dashboard_state,
            autonomous_safe
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY execution_confidence_score DESC;
        """

        self.populate_tree(
            self.worker_health_tree,
            db_query(sql)
        )

    def load_audit(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            autonomous_safe,
            included_in_run_next,
            audit_reason
        FROM ops.v_run_next_audit_v1
        ORDER BY included_in_run_next DESC;
        """

        self.populate_tree(
            self.audit_tree,
            db_query(sql)
        )

    def load_cooldown(self):

        sql = """
        SELECT
            league_id,
            season,
            empty_runs,
            empty_pct,
            planner_target_state,
            suggested_retry_after,
            suggested_action
        FROM ops.v_planner_cooldown_candidates_v1
        ORDER BY target_rank, empty_runs DESC;
        """

        self.populate_tree(
            self.cooldown_tree,
            db_query(sql)
        )

    # =====================================================
    # TREE
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
                "SPUŠTĚNO",
                "Worker už běží."
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
                "Nic ke spuštění."
            )

            return

        worker = rows[0]["worker_code"]

        if worker not in WORKER_COMMANDS:

            messagebox.showerror(
                "CHYBA",
                f"Není definovaný command pro {worker}"
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
                f"CHYBA: {e}"
            )

        self.worker_running = False

    # =====================================================
    # LOG
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

    app = MatchMatrixAdminPanel()

    app.mainloop()