# MATCHMATRIX CONTROL PANEL V17.2
#
# CO TO JE:
# - Live orchestration + runtime operating console pro MatchMatrix platform.
#
# K ČEMU TO JE:
# - Přehled automation readiness
# - coverage monitoring
# - provider routing
# - orchestration control
# - bezpečné spouštění workerů
# - runtime monitoring
# - media monitoring
# - active worker tracking
# - execution audit
# - scheduler candidates monitoring
# - RUN NEXT scheduler execution
# - SAFE EXECUTION MODE přes ops.v_execution_lock_guard_v1
#
# HLAVNÍ NOVINKY V17.1:
# - světlý UI vzhled
# - zvýrazněné záložky
# - SCHEDULER tab
# - RUN NEXT tlačítko
# - TOP scheduler candidate auto-pick
# - background execution z RUN NEXT
# - RUN NEXT používá pouze execution_allowed = true
# - Scheduler tab ukazuje worker lock stav
#
# SPUŠTĚNÍ:
# cd C:\MatchMatrix-platform
# C:\Python314\python.exe tools\matchmatrix_control_panel_V17_2.py

import tkinter as tk
from tkinter import ttk, messagebox
import tkinter.font as tkfont
from datetime import datetime

import psycopg2
import threading
from psycopg2.extras import RealDictCursor

from matchmatrix_worker_launcher_v1 import (
    command_to_text,
    run_worker
)


DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

QUERY_EXECUTION = """
SELECT
    sport_code,
    entity,
    primary_provider,
    fallback_provider,
    routing_status,
    automation_ready,
    execution_state,
    execution_reason,
    primary_status,
    planner_status,
    current_state,
    run_group,
    blocked_providers
FROM ops.v_automation_execution_queue
ORDER BY sport_code, entity;
"""

QUERY_COVERAGE = """
SELECT
    sport_code,
    entity,
    primary_provider,
    fallback_provider,
    routing_status,
    automation_ready,
    execution_state
FROM ops.v_automation_execution_queue
ORDER BY sport_code, entity;
"""

QUERY_RUNTIME_LOGS = """
SELECT
    to_char(created_at, 'YYYY-MM-DD HH24:MI:SS') AS created_at,
    worker_name,
    status,
    duration_sec,
    return_code,
    command_text,
    log_file
FROM ops.runtime_execution_history
ORDER BY created_at DESC
LIMIT 200;
"""

QUERY_MEDIA_HEALTH = """
SELECT
    source_name,
    source_type,
    sport_code,
    health_status,
    found_urls,
    inserted_rows,
    updated_rows,
    skipped_rows,
    last_run_at,
    worker_script
FROM ops.media_source_health_audit
ORDER BY last_run_at DESC NULLS LAST;
"""

QUERY_ACTIVE_RUNS = """
SELECT
    worker_name,
    execution_state,
    pid,
    owner_id,
    lock_name,
    to_char(started_at, 'YYYY-MM-DD HH24:MI:SS') AS started_at,
    to_char(last_heartbeat, 'YYYY-MM-DD HH24:MI:SS') AS last_heartbeat,
    command_text
FROM ops.active_worker_runs
ORDER BY started_at DESC;
"""
QUERY_SCHEDULER = """
SELECT
    orchestration_priority_rank,
    effective_layer_order,
    sport_code,
    entity,
    candidate_provider,
    COALESCE(run_group, '') AS run_group,
    worker_code,
    worker_name,
    timeout_sec,
    max_attempts,
    worker_status,
    ready_for_scheduler,
    orchestration_state,
    worker_already_running,
    execution_allowed,
    resolved_worker_script
FROM ops.v_orchestration_priority_queue_v2
WHERE ready_for_scheduler = true
ORDER BY orchestration_priority_rank
LIMIT 100;
"""

class MatchMatrixPanelV170(tk.Tk):

    def __init__(self):
        super().__init__()

        self.title("MatchMatrix Control Panel V17.2 ORCHESTRATION SAFE MODE")
        self.geometry("1800x950")
        self.minsize(1200, 700)

        self.zoom_size = 9
        self.rows_execution = []
        self.rows_coverage = []
        self.rows_runtime = []
        self.rows_media = []
        self.rows_active = []
        self.rows_scheduler = []
        self.auto_refresh_ms = 5000

        self.text_font = tkfont.Font(family="Segoe UI", size=self.zoom_size)
        self.heading_font = tkfont.Font(
            family="Segoe UI",
            size=self.zoom_size,
            weight="bold"
        )

        self.style = ttk.Style(self)
        self.configure_styles()
        self.build_ui()
        self.load_all()
        self.schedule_refresh()

    def configure_styles(self):

        self.style.theme_use("clam")

        self.style.configure(
            "Treeview",
            font=self.text_font,
            rowheight=self.zoom_size + 14,
            background="#ffffff",
            fieldbackground="#ffffff",
            foreground="#111111"
        )

        self.style.configure(
            "Treeview.Heading",
            font=self.heading_font,
            background="#eef3ff",
            foreground="#111111",
            relief="raised"
        )

        self.style.configure(
            "TNotebook",
            background="#f4f6fb",
            borderwidth=0
        )

        self.style.configure(
            "TNotebook.Tab",
            font=("Segoe UI", 10, "bold"),
            padding=(16, 8),
            background="#e8edf7",
            foreground="#222222"
        )

        self.style.map(
            "TNotebook.Tab",
            background=[
                ("selected", "#1f6feb"),
                ("active", "#d7e6ff")
            ],
            foreground=[
                ("selected", "#ffffff"),
                ("active", "#000000")
            ]
        )

        self.style.configure(
            "TButton",
            font=("Segoe UI", 9, "bold"),
            padding=(10, 5)
        )

    def build_ui(self):

        top = ttk.Frame(self)
        top.pack(fill="x", padx=8, pady=5)

        self.card_total = self.create_card(top, "TOTAL", "#f0f0f0")
        self.card_ready = self.create_card(top, "READY", "#d9f7d9")
        self.card_blocked = self.create_card(top, "BLOCKED", "#ffd6d6")
        self.card_failover = self.create_card(top, "FAILOVER", "#d9ecff")
        self.card_waiting = self.create_card(top, "WAITING", "#fff5cc")
        self.card_active = self.create_card(top, "ACTIVE", "#e8d9ff")

        toolbar = ttk.Frame(self)
        toolbar.pack(fill="x", padx=8, pady=5)

        ttk.Button(toolbar, text="Refresh", command=self.load_all).pack(side="left")

        ttk.Separator(toolbar, orient="vertical").pack(
            side="left",
            fill="y",
            padx=10
        )

        ttk.Button(
            toolbar,
            text="COPY RUN COMMAND",
            command=self.copy_run_command
        ).pack(side="left", padx=5)

        ttk.Button(
            toolbar,
            text="RUN SELECTED",
            command=self.run_selected
        ).pack(side="left", padx=5)

        ttk.Button(
            toolbar,
            text="RUN NEXT",
            command=self.run_next_scheduler_job
        ).pack(side="left", padx=5)

        ttk.Label(toolbar, text="Auto refresh:").pack(side="left", padx=(15, 5))

        self.refresh_combo = ttk.Combobox(
            toolbar,
            width=10,
            values=["OFF", "15 s", "30 s", "60 s"]
        )
        self.refresh_combo.set("OFF")
        self.refresh_combo.pack(side="left")

        ttk.Button(
            toolbar,
            text="Apply",
            command=self.apply_auto_refresh
        ).pack(side="left", padx=5)

        ttk.Label(
            toolbar,
            text="Zoom: Ctrl + kolečko myši"
        ).pack(side="left", padx=20)

        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=8, pady=5)

        self.tab_all = ttk.Frame(self.notebook)
        self.tab_coverage = ttk.Frame(self.notebook)
        self.tab_failures = ttk.Frame(self.notebook)
        self.tab_runtime = ttk.Frame(self.notebook)
        self.tab_media = ttk.Frame(self.notebook)
        self.tab_active = ttk.Frame(self.notebook)
        self.tab_scheduler = ttk.Frame(self.notebook)

        self.notebook.add(self.tab_all, text="ALL")
        self.notebook.add(self.tab_coverage, text="COVERAGE")
        self.notebook.add(self.tab_failures, text="FAILURES")
        self.notebook.add(self.tab_runtime, text="RUNTIME")
        self.notebook.add(self.tab_media, text="MEDIA")
        self.notebook.add(self.tab_active, text="ACTIVE RUNS")
        self.notebook.add(self.tab_scheduler, text="SCHEDULER")

        self.tree_execution = self.create_tree(self.tab_all)
        self.tree_coverage = self.create_tree(self.tab_coverage)
        self.tree_failures = self.create_tree(self.tab_failures)
        self.tree_runtime = self.create_tree(self.tab_runtime)
        self.tree_media = self.create_tree(self.tab_media)
        self.tree_active = self.create_tree(self.tab_active)
        self.tree_scheduler = self.create_tree(self.tab_scheduler)

        self.setup_execution_tree()
        self.setup_coverage_tree()
        self.setup_failures_tree()
        self.setup_runtime_tree()
        self.setup_media_tree()
        self.setup_active_tree()
        self.setup_scheduler_tree()

        self.status_var = tk.StringVar()
        self.status_var.set("READY")

        status = ttk.Label(
            self,
            textvariable=self.status_var,
            anchor="w"
        )
        status.pack(fill="x", side="bottom", padx=5, pady=3)

        self.bind_all("<Control-MouseWheel>", self.on_zoom)

    def create_card(self, parent, title, color):

        frame = tk.Frame(
            parent,
            bg=color,
            bd=1,
            relief="solid"
        )
        frame.pack(side="left", padx=5, pady=5)

        title_lbl = tk.Label(
            frame,
            text=title,
            bg=color,
            font=("Segoe UI", 10, "bold")
        )
        title_lbl.pack(padx=20, pady=(8, 0))

        value_lbl = tk.Label(
            frame,
            text="0",
            bg=color,
            font=("Segoe UI", 18, "bold")
        )
        value_lbl.pack(padx=20, pady=(0, 8))

        return value_lbl

    def create_tree(self, parent):

        frame = ttk.Frame(parent)
        frame.pack(fill="both", expand=True)

        tree = ttk.Treeview(frame, show="headings")

        y_scroll = ttk.Scrollbar(
            frame,
            orient="vertical",
            command=tree.yview
        )

        x_scroll = ttk.Scrollbar(
            frame,
            orient="horizontal",
            command=tree.xview
        )

        tree.configure(
            yscrollcommand=y_scroll.set,
            xscrollcommand=x_scroll.set
        )

        tree.grid(row=0, column=0, sticky="nsew")
        y_scroll.grid(row=0, column=1, sticky="ns")
        x_scroll.grid(row=1, column=0, sticky="ew")

        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=1)

        tree.tag_configure("READY", background="#d9f7d9")
        tree.tag_configure("BLOCKED", background="#ffd6d6")
        tree.tag_configure("WAITING", background="#fff5cc")
        tree.tag_configure("FAILOVER", background="#d9ecff")

        tree.bind("<Double-1>", self.on_double_click)

        return tree

    def setup_execution_tree(self):

        columns = [
            "sport_code",
            "entity",
            "primary_provider",
            "fallback_provider",
            "routing_status",
            "automation_ready",
            "execution_state",
            "execution_reason",
            "primary_status",
            "planner_status",
            "current_state",
            "run_group",
            "blocked_providers"
        ]

        self.tree_execution["columns"] = columns

        for col in columns:
            self.tree_execution.heading(col, text=col)
            self.tree_execution.column(col, width=180)

    def setup_coverage_tree(self):

        columns = [
            "sport_code",
            "entity",
            "primary_provider",
            "fallback_provider",
            "routing_status",
            "automation_ready",
            "execution_state"
        ]

        self.tree_coverage["columns"] = columns

        for col in columns:
            self.tree_coverage.heading(col, text=col)
            self.tree_coverage.column(col, width=180)

    def setup_failures_tree(self):

        columns = [
            "sport_code",
            "entity",
            "primary_provider",
            "execution_state",
            "routing_status"
        ]

        self.tree_failures["columns"] = columns

        for col in columns:
            self.tree_failures.heading(col, text=col)
            self.tree_failures.column(col, width=220)

    def setup_runtime_tree(self):

        columns = [
            "created_at",
            "worker_name",
            "status",
            "duration_sec",
            "return_code",
            "command_text",
            "log_file"
        ]

        self.tree_runtime["columns"] = columns

        for col in columns:

            self.tree_runtime.heading(col, text=col)

            width = 180

            if col == "command_text":
                width = 500

            if col == "log_file":
                width = 350

            self.tree_runtime.column(col, width=width)
    
    def setup_media_tree(self):

        columns = [
            "source_name",
            "source_type",
            "sport_code",
            "health_status",
            "found_urls",
            "inserted_rows",
            "updated_rows",
            "skipped_rows",
            "last_run_at",
            "worker_script"
        ]

        self.tree_media["columns"] = columns

        for col in columns:

            self.tree_media.heading(col, text=col)

            width = 180

            if col == "worker_script":
                width = 350

            self.tree_media.column(col, width=width)

    def setup_active_tree(self):

        columns = [
            "worker_name",
            "execution_state",
            "pid",
            "owner_id",
            "lock_name",
            "started_at",
            "last_heartbeat",
            "command_text"
        ]

        self.tree_active["columns"] = columns

        for col in columns:
            self.tree_active.heading(col, text=col)

            width = 180

            if col == "command_text":
                width = 600

            self.tree_active.column(col, width=width)

    def setup_scheduler_tree(self):

        columns = [
            "orchestration_priority_rank",
            "effective_layer_order",
            "sport_code",
            "entity",
            "candidate_provider",
            "run_group",
            "worker_code",
            "worker_name",
            "timeout_sec",
            "max_attempts",
            "worker_status",
            "ready_for_scheduler",
            "orchestration_state",
            "worker_already_running",
            "execution_allowed",
            "resolved_worker_script"
        ]

        self.tree_scheduler["columns"] = columns

        for col in columns:
            self.tree_scheduler.heading(col, text=col)

            width = 180

            if col == "resolved_worker_script":
                width = 400

            if col in ("orchestration_priority_rank", "effective_layer_order", "timeout_sec", "max_attempts"):
                width = 120

            if col in ("ready_for_scheduler", "worker_already_running", "execution_allowed"):
                width = 140

            self.tree_scheduler.column(col, width=width)

    def get_connection(self):

        return psycopg2.connect(**DB_CONFIG)

    def load_all(self):

        try:
            with self.get_connection() as conn:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:

                    cur.execute(QUERY_EXECUTION)
                    self.rows_execution = cur.fetchall()

                    cur.execute(QUERY_COVERAGE)
                    self.rows_coverage = cur.fetchall()

                    cur.execute(QUERY_RUNTIME_LOGS)
                    self.rows_runtime = cur.fetchall()

                    cur.execute(QUERY_MEDIA_HEALTH)
                    self.rows_media = cur.fetchall()

                    cur.execute(QUERY_ACTIVE_RUNS)
                    self.rows_active = cur.fetchall()

                    cur.execute(QUERY_SCHEDULER)
                    self.rows_scheduler = cur.fetchall()

            self.render_execution()
            self.render_coverage()
            self.render_failures()
            self.render_runtime()
            self.render_media()
            self.render_active()
            self.render_scheduler()
            self.update_cards()

            now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

            self.status_var.set(
                f"ACTIVE WORKERS: {len(self.rows_active)} | "
                f"LAST REFRESH: {now} | "
                f"EXECUTION ROWS: {len(self.rows_execution)} | "
                f"RUNTIME ROWS: {len(self.rows_runtime)} | "
                f"SCHEDULER ROWS: {len(self.rows_scheduler)}"
            )

        except Exception as exc:
            messagebox.showerror("DB ERROR", str(exc))

    def get_tag(self, state):

        if state == "CAN_RUN_NOW":
            return "READY"

        if state == "FAILOVER_READY":
            return "FAILOVER"

        if state in (
            "BLOCKED_PROVIDER",
            "BLOCKED_LOCK",
            "NOT_AUTOMATION_READY"
        ):
            return "BLOCKED"

        return "WAITING"

    def render_execution(self):

        self.tree_execution.delete(
            *self.tree_execution.get_children()
        )

        for row in self.rows_execution:

            values = list(row.values())

            self.tree_execution.insert(
                "",
                "end",
                values=values,
                tags=(self.get_tag(row["execution_state"]),)
            )

    def render_coverage(self):

        self.tree_coverage.delete(
            *self.tree_coverage.get_children()
        )

        for row in self.rows_coverage:

            values = list(row.values())

            self.tree_coverage.insert(
                "",
                "end",
                values=values,
                tags=(self.get_tag(row["execution_state"]),)
            )

    def render_failures(self):

        self.tree_failures.delete(
            *self.tree_failures.get_children()
        )

        for row in self.rows_execution:

            if row["execution_state"] not in (
                "BLOCKED_PROVIDER",
                "NOT_AUTOMATION_READY",
                "FAILOVER_READY"
            ):
                continue

            values = [
                row["sport_code"],
                row["entity"],
                row["primary_provider"],
                row["execution_state"],
                row["routing_status"]
            ]

            self.tree_failures.insert(
                "",
                "end",
                values=values,
                tags=(self.get_tag(row["execution_state"]),)
            )

    def render_runtime(self):

        self.tree_runtime.delete(
            *self.tree_runtime.get_children()
        )

        for row in self.rows_runtime:

            values = list(row.values())

            tag = "WAITING"

            status = str(row["status"]).upper()

            if status == "SUCCESS":
                tag = "READY"

            elif status == "ERROR":
                tag = "BLOCKED"

            elif status == "WARNING":
                tag = "FAILOVER"

            self.tree_runtime.insert(
                "",
                "end",
                values=values,
                tags=(tag,)
            )

    def render_media(self):

        self.tree_media.delete(
            *self.tree_media.get_children()
        )

        for row in self.rows_media:

            values = list(row.values())

            tag = "WAITING"

            health = str(
                row["health_status"]
            ).upper()

            if health in ("OK", "SUCCESS", "HEALTHY"):
                tag = "READY"

            elif health in ("ERROR", "FAILED"):
                tag = "BLOCKED"

            elif health in ("WARNING", "PARTIAL"):
                tag = "FAILOVER"

            self.tree_media.insert(
                "",
                "end",
                values=values,
                tags=(tag,)
            )

    def render_active(self):

        self.tree_active.delete(
            *self.tree_active.get_children()
        )

        for row in self.rows_active:

            values = list(row.values())

            self.tree_active.insert(
                "",
                "end",
                values=values,
                tags=("FAILOVER",)
            )

    def render_scheduler(self):

        self.tree_scheduler.delete(
            *self.tree_scheduler.get_children()
        )

        for row in self.rows_scheduler:

            tag = "READY"

            if row.get("worker_already_running") or not row.get("ready_for_scheduler"):
                tag = "BLOCKED"

            self.tree_scheduler.insert(
                "",
                "end",
                values=(
                    row["orchestration_priority_rank"],
                    row["effective_layer_order"],
                    row["sport_code"],
                    row["entity"],
                    row["candidate_provider"],
                    row["run_group"],
                    row["worker_code"],
                    row["worker_name"],
                    row["timeout_sec"],
                    row["max_attempts"],
                    row["worker_status"],
                    row["ready_for_scheduler"],
                    row["orchestration_state"],
                    row["worker_already_running"],
                    row["execution_allowed"],
                    row["resolved_worker_script"]
                ),
                tags=(tag,)
            )

    def update_cards(self):

        total = len(self.rows_execution)

        ready = sum(
            1
            for r in self.rows_execution
            if r["execution_state"] == "CAN_RUN_NOW"
        )

        blocked = sum(
            1
            for r in self.rows_execution
            if r["execution_state"] in (
                "BLOCKED_PROVIDER",
                "NOT_AUTOMATION_READY",
                "BLOCKED_LOCK"
            )
        )

        failover = sum(
            1
            for r in self.rows_execution
            if r["execution_state"] == "FAILOVER_READY"
        )

        waiting = total - ready - blocked - failover

        self.card_total.config(text=str(total))
        self.card_ready.config(text=str(ready))
        self.card_blocked.config(text=str(blocked))
        self.card_failover.config(text=str(failover))
        self.card_waiting.config(text=str(waiting))

        active = len(self.rows_active)

        self.card_active.config(
            text=str(active)
        )

    def get_selected_row(self):

        tree = self.tree_execution
        selected = tree.selection()

        if not selected:
            messagebox.showwarning(
                "NO SELECTION",
                "Vyber řádek v záložce ALL."
            )
            return None

        item = tree.item(selected[0])
        values = item["values"]
        columns = self.tree_execution["columns"]

        return dict(zip(columns, values))

    def resolve_worker(self, row):

        entity = str(row.get("entity", "")).lower()

        if entity in ("media", "articles", "highlights", "comments"):
            return "run_media_pipeline_v1"

        if entity in ("players", "coaches", "player_stats"):
            return "run_people_pipeline_v22_from_planner"

        return "run_ingest_cycle_v3"

    def resolve_worker_from_script(self, worker_script):

        script = str(worker_script).replace("\\", "/").lower()

        if "run_media_pipeline_v1.py" in script:
            return "run_media_pipeline_v1"

        if "run_people_pipeline_v22_from_planner.py" in script:
            return "run_people_pipeline_v22_from_planner"

        if "run_unified_staging_to_public_merge_v3.py" in script:
            return "run_unified_staging_to_public_merge_v3"

        return "run_ingest_cycle_v3"

    def copy_run_command(self):

        row = self.get_selected_row()

        if not row:
            return

        worker = self.resolve_worker(row)
        run_group = row.get("run_group")

        args = []

        if run_group and str(run_group).lower() != "none":
            args.extend(["--run-group", str(run_group)])

        cmd = command_to_text(worker, args)

        self.clipboard_clear()
        self.clipboard_append(cmd)

        self.status_var.set(
            f"COMMAND COPIED | {cmd}"
        )

        messagebox.showinfo(
            "COMMAND COPIED",
            cmd
        )

    def run_selected(self):

        row = self.get_selected_row()

        if not row:
            return

        execution_state = str(
            row.get("execution_state", "")
        )

        if execution_state not in (
            "CAN_RUN_NOW",
            "FAILOVER_READY"
        ):
            messagebox.showwarning(
                "BLOCKED",
                f"Execution blocked:\n\n{execution_state}"
            )
            return

        worker = self.resolve_worker(row)
        run_group = row.get("run_group")

        args = []

        if run_group and str(run_group).lower() != "none":
            args.extend(["--run-group", str(run_group)])

        confirm = messagebox.askyesno(
            "RUN WORKER",
            f"Spustit worker na pozadí?\n\n{worker}\n\nRUN GROUP:\n{run_group}"
        )

        if not confirm:
            return

        self.status_var.set(
            f"BACKGROUND RUNNING | {worker}"
        )

        thread = threading.Thread(
            target=self.run_worker_background,
            args=(worker, args),
            daemon=True
        )

        thread.start()

    def run_next_scheduler_job(self):

        if not self.rows_scheduler:
            messagebox.showwarning(
                "NO SCHEDULER JOB",
                "Scheduler queue je prázdná."
            )
            return

        row = self.rows_scheduler[0]

        priority_rank = row["orchestration_priority_rank"]
        layer_order = row["effective_layer_order"]
        sport_code = row["sport_code"]
        entity = row["entity"]
        provider = row["candidate_provider"]
        run_group = row["run_group"]
        worker_script = row["resolved_worker_script"]
        worker_already_running = row.get("worker_already_running")
        execution_allowed = row.get("execution_allowed")
        ready_for_scheduler = row.get("ready_for_scheduler")
        orchestration_state = row.get("orchestration_state")
        timeout_sec = int(row.get("timeout_sec") or 600)

        if worker_already_running or not execution_allowed or not ready_for_scheduler:
            messagebox.showwarning(
                "RUN NEXT BLOCKED",
                "RUN NEXT je blokovaný execution lock guardem.\n\n"
                f"SPORT: {sport_code}\n"
                f"ENTITY: {entity}\n"
                f"PROVIDER: {provider}\n"
                f"WORKER SCRIPT: {worker_script}\n\n"
                "Důvod: worker už běží, není execution_allowed nebo není ready_for_scheduler."
            )
            return

        worker = self.resolve_worker_from_script(worker_script)

        args = []

        if run_group and str(run_group).strip():
            args.extend(["--run-group", str(run_group)])

        confirm = messagebox.askyesno(
            "RUN NEXT",
            f"Spustit TOP scheduler job?\n\n"
            f"PRIORITY: {priority_rank}\n"
            f"LAYER ORDER: {layer_order}\n"
            f"SPORT: {sport_code}\n"
            f"ENTITY: {entity}\n"
            f"PROVIDER: {provider}\n"
            f"RUN GROUP: {run_group}\n"
            f"ORCHESTRATION STATE: {orchestration_state}\n"
            f"READY FOR SCHEDULER: {ready_for_scheduler}\n"
            f"EXECUTION ALLOWED: {execution_allowed}\n"
            f"TIMEOUT: {timeout_sec} sec\n\n"
            f"WORKER:\n{worker}"
        )

        if not confirm:
            return

        self.status_var.set(
            f"RUN NEXT STARTED | {sport_code} | {entity} | {worker}"
        )

        thread = threading.Thread(
            target=self.run_worker_background,
            args=(worker, args, timeout_sec),
            daemon=True
        )

        thread.start()

    def run_worker_background(self, worker, args, timeout_sec=600):

        try:
            result = run_worker(
                worker_key=worker,
                args=args,
                timeout_sec=timeout_sec
            )

            self.after(
                0,
                lambda: self.on_worker_finished(result, worker)
            )

        except Exception as exc:
            self.after(
                0,
                lambda: self.on_worker_error(exc)
            )

    def on_worker_finished(self, result, worker):

        self.show_execution_result(result)

        self.status_var.set(
            f"DONE | RC={result['return_code']} | {worker}"
        )

        self.load_all()

    def on_worker_error(self, exc):

        messagebox.showerror(
            "EXECUTION ERROR",
            str(exc)
        )

        self.status_var.set("EXECUTION ERROR")

        self.load_all()

    def show_execution_result(self, result):

        win = tk.Toplevel(self)
        win.title("EXECUTION RESULT")
        win.geometry("1200x700")

        text = tk.Text(
            win,
            wrap="word",
            font=("Consolas", 10)
        )

        text.pack(fill="both", expand=True)

        summary = f"""
=========================================================
MATCHMATRIX EXECUTION RESULT
=========================================================

SUCCESS:
{result['success']}

RETURN CODE:
{result['return_code']}

DURATION:
{result['duration_sec']} sec

COMMAND:
{result['command']}

LOG FILE:
{result['log_file']}

=========================================================
STDOUT
=========================================================

{result['stdout']}

=========================================================
STDERR
=========================================================

{result['stderr']}
"""

        text.insert("1.0", summary)

    def apply_auto_refresh(self):

        value = self.refresh_combo.get()

        mapping = {
            "OFF": 0,
            "15 s": 15000,
            "30 s": 30000,
            "60 s": 60000
        }

        self.auto_refresh_ms = mapping.get(value, 0)

        if self.auto_refresh_ms > 0:
            self.schedule_refresh()

    def schedule_refresh(self):

        if self.auto_refresh_ms <= 0:
            return

        self.load_all()

        self.after(
            self.auto_refresh_ms,
            self.schedule_refresh
        )

    def on_double_click(self, event):

        tree = event.widget
        selected = tree.selection()

        if not selected:
            return

        item = tree.item(selected[0])
        values = item["values"]

        detail = tk.Toplevel(self)
        detail.title("DETAIL")
        detail.geometry("900x500")

        text = tk.Text(
            detail,
            wrap="word",
            font=("Consolas", 10)
        )

        text.pack(fill="both", expand=True)

        for value in values:
            text.insert("end", f"{value}\n")

    def on_zoom(self, event):

        if event.delta > 0:
            self.zoom_size += 1
        else:
            self.zoom_size -= 1

        if self.zoom_size < 7:
            self.zoom_size = 7

        if self.zoom_size > 18:
            self.zoom_size = 18

        self.text_font.configure(size=self.zoom_size)
        self.heading_font.configure(size=self.zoom_size)

        self.style.configure(
            "Treeview",
            font=self.text_font,
            rowheight=self.zoom_size + 14
        )

        self.style.configure(
            "Treeview.Heading",
            font=self.heading_font
        )


if __name__ == "__main__":

    app = MatchMatrixPanelV170()
    app.mainloop()