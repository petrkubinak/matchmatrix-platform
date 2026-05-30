"""
MATCHMATRIX CONTROL PANEL V17.9
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

REFRESH_MS = 8000

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
            "MATCHMATRIX CONTROL PANEL V17.9"
        )

        self.geometry("1920x1040")

        self.configure(bg=BG)

        self.scale = 1.0

        self.log_queue = queue.Queue()

        self.worker_running = False

        self.blink_state = False

        self.system_pulse_state = False

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
        header = tk.Frame(self, bg="#09000d", height=70)
        header.pack(fill="x")

        tk.Label(
            header,
            text="▰ MATCHMATRIX OPERATIONS CENTER",
            bg="#09000d",
            fg=PINK,
            font=("Segoe UI", 24, "bold")
        ).pack(side="left", padx=15, pady=10)

        self.clock_label = tk.Label(
            header,
            text="",
            bg="#09000d",
            fg="white",
            font=("Segoe UI", 18, "bold")
        )
        self.clock_label.pack(side="right", padx=15)

        self.system_state = tk.Label(
            header,
            text="READY",
            bg="#09000d",
            fg=GREEN,
            font=("Segoe UI", 13, "bold")
        )
        self.system_state.pack(side="right", padx=15)

        # KPI
        self.kpi_bar = tk.Frame(self, bg=BG)
        self.kpi_bar.pack(fill="x", pady=4)

        self.kpi_stav = self.create_kpi("🛡 STAV", "READY", GREEN)
        self.kpi_pending = self.create_kpi("⏳ ČEKAJÍCÍ", "0", YELLOW)
        self.kpi_alerty = self.create_kpi("🔔 ALERTY", "0", RED)
        self.kpi_safe = self.create_kpi("✅ SAFE", "0", PURPLE)
        self.kpi_conf = self.create_kpi("📈 DŮVĚRA", "0", PINK)

        # BUTTONS
        btn_bar = tk.Frame(self, bg=BG)
        btn_bar.pack(fill="x")

        self.make_button(btn_bar, "↻ OBNOVIT", "#452060", self.refresh_all)
        self.make_button(btn_bar, "▶ RUN NEXT SAFE", "#006b3c", self.run_next_safe)
        self.make_button(btn_bar, "🗑 VYMAZAT LOG", "#90115d", self.clear_log)

        # NOTEBOOK
        # HLAVNÍ OBSAH + SPODNÍ LIŠTA ZÁLOŽEK
        self.content_area = tk.Frame(self, bg=BG)
        self.content_area.pack(fill="both", expand=True, padx=8, pady=(6, 4))

        self.bottom_tabs = tk.Frame(self, bg="#100018", height=78)
        self.bottom_tabs.pack(fill="x", side="bottom", padx=8, pady=(2, 8))

        self.tabs = {}
        self.current_tab = None

        tab_dashboard = tk.Frame(self.content_area, bg=BG)
        tab_scheduler = tk.Frame(self.content_area, bg=BG)
        tab_workers = tk.Frame(self.content_area, bg=BG)
        tab_runtime = tk.Frame(self.content_area, bg=BG)
        tab_payloads = tk.Frame(self.content_area, bg=BG)
        tab_logs = tk.Frame(self.content_area, bg=BG)

        self.tabs = {
            "DASHBOARD": tab_dashboard,
            "SCHEDULER": tab_scheduler,
            "WORKERS": tab_workers,
            "ACTIVE RUNS": tab_runtime,
            "PAYLOADS": tab_payloads,
            "LOGS": tab_logs,
        }

        for frame in self.tabs.values():
            frame.place(relx=0, rely=0, relwidth=1, relheight=1)

        self.create_bottom_tab("▦", "DASHBOARD")
        self.create_bottom_tab("◷", "SCHEDULER")
        self.create_bottom_tab("👥", "WORKERS")
        self.create_bottom_tab("▶", "ACTIVE RUNS")
        self.create_bottom_tab("▣", "PAYLOADS")
        self.create_bottom_tab("▤", "LOGS")

        self.show_tab("DASHBOARD")
        
        # DASHBOARD GRID
        for i in range(3):
            tab_dashboard.columnconfigure(i, weight=1)

        for i in range(3):
            tab_dashboard.rowconfigure(i, weight=1)

        self.orchestration_summary_tree = self.create_section(
            tab_dashboard, "⚙ ORCHESTRATION SUMMARY", 0, 0
        )

        self.run_next_tree = self.create_section(
            tab_dashboard, "▶ FRONTA KE SPUŠTĚNÍ", 0, 1
        )

        self.dashboard_tree = self.create_section(
            tab_dashboard, "📊 STAV SCHEDULERU", 0, 2
        )

        self.alerts_tree = self.create_section(
            tab_dashboard, "🔔 UPOZORNĚNÍ", 1, 0
        )

        self.feed_tree = self.create_section(
            tab_dashboard, "🧭 UDÁLOSTI ORCHESTRACE", 1, 1
        )

        self.worker_health_tree = self.create_section(
            tab_dashboard, "🧩 WORKER HEALTH", 1, 2
        )

        self.pending_payloads_tree = self.create_section(
            tab_dashboard, "▣ ČEKAJÍCÍ PAYLOADY", 2, 0
        )

        self.cooldown_tree = self.create_section(
            tab_dashboard, "❄ PLANNER COOLDOWN", 2, 1
        )

        self.active_runs_tree = self.create_section(
            tab_dashboard, "▶ AKTIVNÍ BĚHY", 2, 2
        )

        # DETAIL TABS
        tab_scheduler.columnconfigure(0, weight=1)
        tab_scheduler.rowconfigure(0, weight=1)
        self.audit_tree = self.create_section(
            tab_scheduler, "AUDIT ORCHESTRACE", 0, 0
        )

        tab_workers.columnconfigure(0, weight=1)
        tab_workers.rowconfigure(0, weight=1)
        self.workers_detail_tree = self.create_section(
            tab_workers, "🧩 DETAIL WORKERŮ", 0, 0
        )
        self.workers_detail_tree.bind(
            "<Double-1>", self.open_worker_detail
        )

        tab_runtime.columnconfigure(0, weight=1)
        tab_runtime.rowconfigure(0, weight=1)
        self.active_runs_detail_tree = self.create_section(
            tab_runtime, "▶ DETAIL AKTIVNÍCH BĚHŮ", 0, 0
        )

        tab_payloads.columnconfigure(0, weight=1)
        tab_payloads.rowconfigure(0, weight=1)

        tab_logs.columnconfigure(0, weight=1)
        tab_logs.rowconfigure(0, weight=1)
        self.log_text = self.create_log_section(
            tab_logs, "LOG SPUŠTĚNÍ", 0, 0
        )

        self.bind("<Control-MouseWheel>", self.zoom)

        self.blink_critical_rows()
        self.update_clock()
        self.pulse_system_state()

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
        column,
        colspan=1
    ):

        frame = tk.Frame(
            parent,
            bg=PANEL
        )

        frame.grid(
            row=row,
            column=column,
            columnspan=colspan,
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

        tree.tag_configure(
            "critical_blink_on",
            background="#ff0055",
            foreground="white"
        )

        tree.tag_configure(
            "critical_blink_off",
            background="#4a0018",
            foreground="white"
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

        self.load_orchestration_summary()
        self.load_summary()
        self.load_feed()
        self.load_run_next()
        self.load_alerts()
        self.load_dashboard()
        self.load_worker_health()
        self.load_cooldown()
        self.load_active_runs()
        self.load_pending_payloads()

        # Detailní audit načti jen když je aktivní záložka SCHEDULER
        if self.current_tab == "SCHEDULER":
            self.load_audit()

        self.after(
            REFRESH_MS,
            self.refresh_all
        )

    # =====================================================
    # LOADERS
    # =====================================================

    def load_orchestration_summary(self):

        sql = """
        SELECT
            orchestration_layer,
            scheduler_state,
            rows_count,
            runtime_ready_count,
            scheduler_ready_count,
            panel_ready_count,
            ready_pct
        FROM ops.v_panel_orchestration_summary_v1
        ORDER BY
            orchestration_layer,
            scheduler_state;
        """

        self.populate_tree(
            self.orchestration_summary_tree,
            db_query(sql)
        )
        
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

    def load_workers_detail(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            autonomous_safe,
            included_in_run_next,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            dashboard_state
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY
            execution_confidence_score DESC,
            worker_code;
        """

        self.populate_tree(
            self.workers_detail_tree,
            db_query(sql)
        )

    def open_worker_detail(self, event):

        selected = self.workers_detail_tree.selection()

        if not selected:
            return

        item = self.workers_detail_tree.item(selected[0])
        values = item.get("values", [])

        if not values:
            return

        worker_code = str(values[0]).strip()

        detail_window = tk.Toplevel(self)
        detail_window.title(f"WORKER DETAIL :: {worker_code}")
        detail_window.geometry("1500x850")
        detail_window.configure(bg=BG)

        tk.Label(
            detail_window,
            text=f"🧩 WORKER DETAIL :: {worker_code}",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 20, "bold")
        ).pack(anchor="w", padx=15, pady=10)

        body = tk.Frame(detail_window, bg=BG)
        body.pack(fill="both", expand=True, padx=10, pady=10)

        body.columnconfigure(0, weight=1)
        body.columnconfigure(1, weight=1)
        body.rowconfigure(0, weight=1)
        body.rowconfigure(1, weight=1)

        # 1) Aktuální runtime dashboard
        current_tree = self.create_section(
            body,
            "📊 AKTUÁLNÍ STAV WORKERU",
            0,
            0
        )

        sql_current = f"""
        SELECT
            worker_code,
            execution_decision,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            dashboard_state,
            autonomous_safe
        FROM ops.v_scheduler_runtime_dashboard_v1
        WHERE worker_code = '{worker_code}';
        """

        self.populate_tree(
            current_tree,
            db_query(sql_current)
        )

        # 2) RUN NEXT audit
        audit_tree = self.create_section(
            body,
            "🧭 RUN NEXT AUDIT",
            0,
            1
        )

        sql_audit = f"""
        SELECT
            worker_code,
            execution_decision,
            autonomous_safe,
            included_in_run_next,
            audit_reason
        FROM ops.v_run_next_audit_v1
        WHERE worker_code = '{worker_code}';
        """

        self.populate_tree(
            audit_tree,
            db_query(sql_audit)
        )

        # 3) Poslední orchestration události
        events_tree = self.create_section(
            body,
            "🕒 POSLEDNÍ UDÁLOSTI",
            1,
            0
        )

        sql_events = f"""
        SELECT
            feed_type,
            object_name,
            severity,
            message,
            event_time
        FROM ops.v_runtime_operations_center_feed_v1
        WHERE
            UPPER(COALESCE(object_name, '')) LIKE UPPER('%{worker_code}%')
            OR UPPER(COALESCE(message, '')) LIKE UPPER('%{worker_code}%')
        ORDER BY event_time DESC
        LIMIT 30;
        """

        self.populate_tree(
            events_tree,
            db_query(sql_events)
        )

        # 4) Alerty k workeru
        alerts_tree = self.create_section(
            body,
            "🔔 ALERTY WORKERU",
            1,
            1
        )

        sql_alerts = f"""
        SELECT
            alert_type,
            source_object,
            alert_severity,
            alert_count,
            last_alert_message,
            last_alert_time
        FROM ops.v_runtime_alerts_grouped_v1
        WHERE
            UPPER(COALESCE(source_object, '')) LIKE UPPER('%{worker_code}%')
            OR UPPER(COALESCE(last_alert_message, '')) LIKE UPPER('%{worker_code}%')
        ORDER BY last_alert_time DESC
        LIMIT 30;
        """

        self.populate_tree(
            alerts_tree,
            db_query(sql_alerts)
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

    def load_active_runs(self):

        sql = """
        SELECT
            lock_name,
            owner_id,
            acquired_at,
            heartbeat_at,
            running_seconds,
            heartbeat_age_seconds,
            seconds_to_expire,
            live_state,
            live_color,
            note,
            is_active
        FROM ops.v_active_runs_live_v1
        ORDER BY acquired_at DESC;
        """

        self.populate_tree(
            self.active_runs_tree,
            db_query(sql)
        )

    def load_active_runs_detail(self):

        sql = """
        SELECT
            lock_name,
            owner_id,
            acquired_at,
            heartbeat_at,
            expires_at,
            running_seconds,
            heartbeat_age_seconds,
            seconds_to_expire,
            live_state,
            live_color,
            note,
            created_at,
            updated_at,
            is_active
        FROM ops.v_active_runs_live_v1
        ORDER BY acquired_at DESC;
        """

        self.populate_tree(
            self.active_runs_detail_tree,
            db_query(sql)
        )

    def load_pending_payloads(self):

        sql = """
        SELECT
            provider,
            sport_code,
            entity_type,
            parse_status,
            COUNT(*) AS pending_rows
        FROM staging.stg_api_payloads
        WHERE LOWER(parse_status) IN (
            'pending',
            'failed',
            'empty'
        )
        GROUP BY
            provider,
            sport_code,
            entity_type,
            parse_status
        ORDER BY pending_rows DESC;
        """

        self.populate_tree(
            self.pending_payloads_tree,
            db_query(sql)
        )    

    # =====================================================
    # TREE
    # =====================================================

    def populate_tree(self, tree, rows):

        tree.delete(*tree.get_children())

        if not rows:
            tree.configure(displaycolumns=())

            tree["columns"] = ["info"]
            tree["displaycolumns"] = ["info"]

            tree.heading("info", text="INFO")
            tree.column("info", width=300, anchor="center")

            tree.insert("", "end", values=("Žádná aktivní data",))
            return

        cols = [str(c) for c in rows[0].keys()]

        tree.configure(displaycolumns=())

        tree["columns"] = cols
        tree["displaycolumns"] = cols

        for col in cols:
            tree.heading(col, text=col)

            width = 130

            if (
                "message" in col.lower()
                or "reason" in col.lower()
                or "note" in col.lower()
            ):
                width = 350

            tree.column(col, width=width, anchor="center")

        for row in rows:

            vals = []
            txt = ""

            for c in cols:
                v = row.get(c, "")

                if isinstance(v, datetime):
                    v = v.strftime("%Y-%m-%d %H:%M:%S")

                vals.append(v)
                txt += str(v).upper()

            tag = "purple"

            if (
                "GREEN" in txt
                or "OK" in txt
                or "READY" in txt
                or "HEALTHY" in txt
            ):
                tag = "green"

            elif (
                "YELLOW" in txt
                or "WARNING" in txt
                or "COOLDOWN" in txt
            ):
                tag = "yellow"

            elif (
                "RED" in txt
                or "CRITICAL" in txt
                or "FAILED" in txt
                or "ERROR" in txt
            ):
                tag = "red"

            tree.insert("", "end", values=vals, tags=(tag,))

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

    def update_clock(self):

        now = datetime.now().strftime("%H:%M:%S")

        self.clock_label.config(
            text=f"{now}  ● LIVE",
            fg=GREEN
        )

        self.after(
            1000,
            self.update_clock
        )

    def blink_critical_rows(self):

        self.blink_state = not self.blink_state

        for tree in [
            self.alerts_tree,
            self.feed_tree,
            self.worker_health_tree
        ]:
            for item in tree.get_children():
                values = tree.item(item, "values")
                row_text = " ".join(str(v).upper() for v in values)

                if "CRITICAL" in row_text or "FAILED_WORKER" in row_text:
                    tree.item(
                        item,
                        tags=("critical_blink_on" if self.blink_state else "critical_blink_off",)
                    )

        self.after(800, self.blink_critical_rows)

    def pulse_system_state(self):

        self.system_pulse_state = not self.system_pulse_state

        state_text = self.system_state.cget("text").upper()

        if "CRITICAL" in state_text or "ERROR" in state_text:
            color_on = RED
            color_off = "#4a0018"

        elif "WARNING" in state_text or "COOLDOWN" in state_text:
            color_on = YELLOW
            color_off = "#4a3b00"

        else:
            color_on = GREEN
            color_off = "#083b2b"

        self.system_state.config(
            fg=color_on if self.system_pulse_state else color_off
        )

        self.after(900, self.pulse_system_state)

    def create_bottom_tab(self, icon, name):

        btn = tk.Button(
            self.bottom_tabs,
            text=f"{icon}\n{name}",
            bg="#190020",
            fg="#f0c8ff",
            activebackground="#bf0a73",
            activeforeground="white",
            relief="solid",
            bd=1,
            font=("Segoe UI", 11, "bold"),
            command=lambda n=name: self.show_tab(n)
        )

        btn.pack(
            side="left",
            fill="both",
            expand=True,
            padx=5,
            pady=6
        )

        self.tabs[f"{name}_button"] = btn


    def show_tab(self, name):

        for key, frame in self.tabs.items():
            if isinstance(frame, tk.Frame):
                frame.lower()

        self.tabs[name].lift()
        self.current_tab = name

        if name == "SCHEDULER":
            self.load_audit()

        if name == "WORKERS":
            self.load_workers_detail()

        if name == "ACTIVE RUNS":
            self.load_active_runs_detail()

        for key, item in self.tabs.items():
            if key.endswith("_button"):
                item.config(bg="#190020", fg="#f0c8ff")

        btn_key = f"{name}_button"
        if btn_key in self.tabs:
            self.tabs[btn_key].config(
                bg="#bf0a73",
                fg="white"
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