# MATCHMATRIX CONTROL PANEL V16.2
#
# CO TO JE:
# - Operational dashboard pro MatchMatrix orchestration layer.
#
# K ČEMU TO JE:
# - Přehled automation readiness
# - coverage monitoring
# - provider routing
# - orchestration control
#
# HLAVNÍ NOVINKY:
# - dashboard cards
# - tabs
# - coverage tab
# - auto refresh
# - zoom
# - status bar
#
# SPUŠTĚNÍ:
# cd C:\MatchMatrix-platform
# C:\Python314\python.exe tools\matchmatrix_control_panel_V16_2.py

import os
import tkinter as tk
from tkinter import ttk, messagebox
import tkinter.font as tkfont
from datetime import datetime

import psycopg2
from psycopg2.extras import RealDictCursor


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


class MatchMatrixPanelV162(tk.Tk):

    def __init__(self):
        super().__init__()

        self.title("MatchMatrix Control Panel V16.2")
        self.geometry("1800x950")
        self.minsize(1200, 700)

        self.zoom_size = 9

        self.rows_execution = []
        self.rows_coverage = []

        self.auto_refresh_ms = 0

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

    # ==========================================================
    # UI
    # ==========================================================

    def configure_styles(self):

        self.style.configure(
            "Treeview",
            font=self.text_font,
            rowheight=self.zoom_size + 14
        )

        self.style.configure(
            "Treeview.Heading",
            font=self.heading_font
        )

    def build_ui(self):

        # =========================
        # TOP DASHBOARD
        # =========================

        top = ttk.Frame(self)
        top.pack(fill="x", padx=8, pady=5)

        self.card_total = self.create_card(top, "TOTAL", "#f0f0f0")
        self.card_ready = self.create_card(top, "READY", "#d9f7d9")
        self.card_blocked = self.create_card(top, "BLOCKED", "#ffd6d6")
        self.card_failover = self.create_card(top, "FAILOVER", "#d9ecff")
        self.card_waiting = self.create_card(top, "WAITING", "#fff5cc")

        # =========================
        # TOOLBAR
        # =========================

        toolbar = ttk.Frame(self)
        toolbar.pack(fill="x", padx=8, pady=5)

        ttk.Button(toolbar, text="Refresh", command=self.load_all).pack(side="left")

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

        # =========================
        # NOTEBOOK
        # =========================

        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=8, pady=5)

        self.tab_all = ttk.Frame(self.notebook)
        self.tab_coverage = ttk.Frame(self.notebook)
        self.tab_failures = ttk.Frame(self.notebook)

        self.notebook.add(self.tab_all, text="ALL")
        self.notebook.add(self.tab_coverage, text="COVERAGE")
        self.notebook.add(self.tab_failures, text="FAILURES")

        self.tree_execution = self.create_tree(self.tab_all)
        self.tree_coverage = self.create_tree(self.tab_coverage)
        self.tree_failures = self.create_tree(self.tab_failures)

        self.setup_execution_tree()
        self.setup_coverage_tree()
        self.setup_failures_tree()

        # =========================
        # STATUS BAR
        # =========================

        self.status_var = tk.StringVar()
        self.status_var.set("READY")

        status = ttk.Label(
            self,
            textvariable=self.status_var,
            anchor="w"
        )

        status.pack(fill="x", side="bottom", padx=5, pady=3)

        # =========================
        # ZOOM
        # =========================

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

    # ==========================================================
    # TREE SETUP
    # ==========================================================

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

    # ==========================================================
    # DB
    # ==========================================================

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

            self.render_execution()
            self.render_coverage()
            self.render_failures()
            self.update_cards()

            now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

            self.status_var.set(
                f"DB CONNECTED | LAST REFRESH: {now} | EXECUTION ROWS: {len(self.rows_execution)}"
            )

        except Exception as exc:

            messagebox.showerror("DB ERROR", str(exc))

    # ==========================================================
    # RENDER
    # ==========================================================

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

    # ==========================================================
    # CARDS
    # ==========================================================

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

    # ==========================================================
    # AUTO REFRESH
    # ==========================================================

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

    # ==========================================================
    # DETAIL
    # ==========================================================

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

    # ==========================================================
    # ZOOM
    # ==========================================================

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

    app = MatchMatrixPanelV162()

    app.mainloop()