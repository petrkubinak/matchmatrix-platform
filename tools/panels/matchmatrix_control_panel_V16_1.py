# MATCHMATRIX CONTROL PANEL V16.1
# Soubor: C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V16_1.py
#
# CO TO JE:
# - Orchestration Control Center pro MatchMatrix.
# - Čte DB view: ops.v_automation_execution_queue.
# - Přidává zoom přes Ctrl + kolečko myši.
#
# K ČEMU TO JE:
# - Přehled, co lze spustit, co je blokované a co čeká.
#
# KDE TO POUŽIJEME:
# - Lokální admin panel MatchMatrix.
#
# SPUŠTĚNÍ:
# cd C:\MatchMatrix-platform
# C:\Python314\python.exe tools\matchmatrix_control_panel_V16_1.py

import os
import tkinter as tk
from tkinter import ttk, messagebox
import tkinter.font as tkfont

import psycopg2
from psycopg2.extras import RealDictCursor


APP_TITLE = "MatchMatrix Control Panel V16.1 - Automation Execution Queue"

DB_CONFIG = {
    "host": os.getenv("MATCHMATRIX_DB_HOST", "localhost"),
    "port": int(os.getenv("MATCHMATRIX_DB_PORT", "5432")),
    "dbname": os.getenv("MATCHMATRIX_DB_NAME", "matchmatrix"),
    "user": os.getenv("MATCHMATRIX_DB_USER", "matchmatrix"),
    "password": os.getenv("MATCHMATRIX_DB_PASSWORD", "matchmatrix_pass"),
}


QUERY = """
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
    primary_runtime_status,
    planner_status,
    current_state,
    run_group,
    priority,
    next_run,
    blocked_providers,
    worker_script,
    source_endpoint,
    target_table
FROM ops.v_automation_execution_queue
ORDER BY
    CASE execution_state
        WHEN 'CAN_RUN_NOW' THEN 1
        WHEN 'FAILOVER_READY' THEN 2
        WHEN 'WAITING_NEXT_RUN' THEN 3
        WHEN 'WAITING_PLANNER' THEN 4
        WHEN 'NOT_AUTOMATION_READY' THEN 5
        WHEN 'BLOCKED_PROVIDER' THEN 6
        WHEN 'BLOCKED_LOCK' THEN 7
        ELSE 9
    END,
    sport_code,
    entity;
"""


class MatchMatrixPanelV161(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title(APP_TITLE)
        self.geometry("1700x900")
        self.minsize(1000, 600)

        self.zoom_size = 9
        self.rows = []
        self.filtered_rows = []

        self.default_font = tkfont.nametofont("TkDefaultFont")
        self.text_font = tkfont.Font(family="Segoe UI", size=self.zoom_size)
        self.heading_font = tkfont.Font(family="Segoe UI", size=self.zoom_size, weight="bold")

        self._build_ui()
        self._bind_zoom()
        self.load_data()

    def _build_ui(self):
        self.style = ttk.Style(self)
        self.style.configure("Treeview", font=self.text_font, rowheight=self.zoom_size + 14)
        self.style.configure("Treeview.Heading", font=self.heading_font)

        top = ttk.Frame(self)
        top.pack(fill="x", padx=8, pady=6)

        ttk.Label(top, text="Sport:").pack(side="left")
        self.sport_filter = ttk.Entry(top, width=10)
        self.sport_filter.pack(side="left", padx=5)

        ttk.Label(top, text="Execution state:").pack(side="left", padx=(12, 0))
        self.state_filter = ttk.Combobox(
            top,
            width=24,
            values=[
                "",
                "CAN_RUN_NOW",
                "FAILOVER_READY",
                "WAITING_NEXT_RUN",
                "WAITING_PLANNER",
                "NOT_AUTOMATION_READY",
                "BLOCKED_PROVIDER",
                "BLOCKED_LOCK",
                "WAITING_RUNTIME",
            ],
        )
        self.state_filter.pack(side="left", padx=5)

        ttk.Button(top, text="Refresh", command=self.load_data).pack(side="left", padx=8)
        ttk.Button(top, text="Apply filter", command=self.apply_filter).pack(side="left")
        ttk.Button(top, text="Clear filter", command=self.clear_filter).pack(side="left", padx=5)

        ttk.Label(top, text="Zoom: Ctrl + kolečko myši").pack(side="left", padx=18)

        self.summary_label = ttk.Label(top, text="")
        self.summary_label.pack(side="right")

        table_frame = ttk.Frame(self)
        table_frame.pack(fill="both", expand=True, padx=8, pady=4)

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
            "primary_runtime_status",
            "planner_status",
            "current_state",
            "run_group",
            "priority",
            "next_run",
            "blocked_providers",
            "worker_script",
            "source_endpoint",
            "target_table",
        ]

        self.tree = ttk.Treeview(table_frame, columns=columns, show="headings")
        self.tree.grid(row=0, column=0, sticky="nsew")

        y_scroll = ttk.Scrollbar(table_frame, orient="vertical", command=self.tree.yview)
        y_scroll.grid(row=0, column=1, sticky="ns")

        x_scroll = ttk.Scrollbar(table_frame, orient="horizontal", command=self.tree.xview)
        x_scroll.grid(row=1, column=0, sticky="ew")

        self.tree.configure(yscrollcommand=y_scroll.set, xscrollcommand=x_scroll.set)

        table_frame.rowconfigure(0, weight=1)
        table_frame.columnconfigure(0, weight=1)

        self.base_widths = {
            "sport_code": 70,
            "entity": 150,
            "primary_provider": 165,
            "fallback_provider": 165,
            "routing_status": 220,
            "automation_ready": 115,
            "execution_state": 175,
            "execution_reason": 280,
            "primary_status": 145,
            "primary_runtime_status": 145,
            "planner_status": 120,
            "current_state": 120,
            "run_group": 230,
            "priority": 80,
            "next_run": 190,
            "blocked_providers": 220,
            "worker_script": 280,
            "source_endpoint": 160,
            "target_table": 280,
        }

        for col in columns:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=self.base_widths.get(col, 130), anchor="w", stretch=True)

        self.tree.tag_configure("CAN_RUN_NOW", background="#d9f7d9")
        self.tree.tag_configure("FAILOVER_READY", background="#d9ecff")
        self.tree.tag_configure("WAITING", background="#fff5cc")
        self.tree.tag_configure("BLOCKED", background="#ffd6d6")
        self.tree.tag_configure("DEFAULT", background="white")

        bottom = ttk.Frame(self)
        bottom.pack(fill="x", padx=8, pady=6)

        ttk.Label(
            bottom,
            text="Zelená = lze spustit | Modrá = failover | Žlutá = čeká | Červená = blokováno",
        ).pack(side="left")

    def _bind_zoom(self):
        self.bind_all("<Control-MouseWheel>", self.on_zoom)
        self.bind_all("<Control-Button-4>", lambda event: self.change_zoom(1))
        self.bind_all("<Control-Button-5>", lambda event: self.change_zoom(-1))

    def on_zoom(self, event):
        if event.delta > 0:
            self.change_zoom(1)
        else:
            self.change_zoom(-1)

    def change_zoom(self, step):
        new_size = self.zoom_size + step
        if new_size < 7:
            new_size = 7
        if new_size > 18:
            new_size = 18

        self.zoom_size = new_size
        self.text_font.configure(size=self.zoom_size)
        self.heading_font.configure(size=self.zoom_size)

        self.style.configure("Treeview", font=self.text_font, rowheight=self.zoom_size + 14)
        self.style.configure("Treeview.Heading", font=self.heading_font)

        scale = self.zoom_size / 9
        for col, base_width in self.base_widths.items():
            self.tree.column(col, width=int(base_width * scale))

    def get_connection(self):
        return psycopg2.connect(**DB_CONFIG)

    def load_data(self):
        try:
            with self.get_connection() as conn:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    cur.execute(QUERY)
                    self.rows = cur.fetchall()

            self.filtered_rows = list(self.rows)
            self.render_rows()
            self.update_summary()

        except Exception as exc:
            messagebox.showerror("DB error", str(exc))

    def apply_filter(self):
        sport = self.sport_filter.get().strip().upper()
        state = self.state_filter.get().strip()

        result = []
        for row in self.rows:
            if sport and str(row.get("sport_code", "")).upper() != sport:
                continue
            if state and str(row.get("execution_state", "")) != state:
                continue
            result.append(row)

        self.filtered_rows = result
        self.render_rows()
        self.update_summary()

    def clear_filter(self):
        self.sport_filter.delete(0, tk.END)
        self.state_filter.set("")
        self.filtered_rows = list(self.rows)
        self.render_rows()
        self.update_summary()

    def get_tag(self, execution_state):
        if execution_state == "CAN_RUN_NOW":
            return "CAN_RUN_NOW"
        if execution_state == "FAILOVER_READY":
            return "FAILOVER_READY"
        if execution_state in ("WAITING_NEXT_RUN", "WAITING_PLANNER", "WAITING_RUNTIME"):
            return "WAITING"
        if execution_state in ("BLOCKED_PROVIDER", "BLOCKED_LOCK", "NOT_AUTOMATION_READY"):
            return "BLOCKED"
        return "DEFAULT"

    def render_rows(self):
        self.tree.delete(*self.tree.get_children())

        for row in self.filtered_rows:
            values = [
                row.get("sport_code", ""),
                row.get("entity", ""),
                row.get("primary_provider", ""),
                row.get("fallback_provider", ""),
                row.get("routing_status", ""),
                row.get("automation_ready", ""),
                row.get("execution_state", ""),
                row.get("execution_reason", ""),
                row.get("primary_status", ""),
                row.get("primary_runtime_status", ""),
                row.get("planner_status", ""),
                row.get("current_state", ""),
                row.get("run_group", ""),
                row.get("priority", ""),
                row.get("next_run", ""),
                row.get("blocked_providers", ""),
                row.get("worker_script", ""),
                row.get("source_endpoint", ""),
                row.get("target_table", ""),
            ]

            self.tree.insert("", "end", values=values, tags=(self.get_tag(row.get("execution_state", "")),))

    def update_summary(self):
        total = len(self.filtered_rows)
        can_run = sum(1 for r in self.filtered_rows if r.get("execution_state") == "CAN_RUN_NOW")
        failover = sum(1 for r in self.filtered_rows if r.get("execution_state") == "FAILOVER_READY")
        blocked = sum(
            1
            for r in self.filtered_rows
            if r.get("execution_state") in ("BLOCKED_PROVIDER", "BLOCKED_LOCK", "NOT_AUTOMATION_READY")
        )

        self.summary_label.config(
            text=f"Rows: {total} | CAN_RUN_NOW: {can_run} | BLOCKED/NOT_READY: {blocked} | FAILOVER: {failover}"
        )


if __name__ == "__main__":
    app = MatchMatrixPanelV161()
    app.mainloop()