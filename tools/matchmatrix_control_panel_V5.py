from __future__ import annotations

import os
import subprocess
import threading
import tkinter as tk
from datetime import datetime
from pathlib import Path
from tkinter import messagebox, scrolledtext, ttk

import psycopg2


# ============================================================
# MATCHMATRIX CONTROL PANEL V5
# REWORKED IN MISSION CONTROL V7 STYLE
# ============================================================

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
BASE_DIR = PROJECT_ROOT
PYTHON_EXE = str(PROJECT_ROOT.parent / "Python314" / "python.exe") if False else r"C:\Python314\python.exe"

BATCH_RUNNER = str(PROJECT_ROOT / "ingest" / "run_unified_ingest_batch_v1.py")
SCHEDULER_RUNNER = str(PROJECT_ROOT / "workers" / "run_multisport_scheduler_v4.py")
PLAYERS_PIPELINE_RUNNER = str(PROJECT_ROOT / "workers" / "run_players_pipeline_full_v1.py")

NAV_PATHS = {
    "Projekt root": PROJECT_ROOT,
    "Workers": PROJECT_ROOT / "workers",
    "Ingest": PROJECT_ROOT / "ingest",
    "API-Football": PROJECT_ROOT / "ingest" / "API-Football",
    "DB": PROJECT_ROOT / "db",
    "Reports": PROJECT_ROOT / "reports",
    "OPS Admin": PROJECT_ROOT / "ops_admin",
    "Frontend root": PROJECT_ROOT / "fronted",
    "MatchMatrix web": PROJECT_ROOT / "fronted" / "matchmatrix-web",
    "Docs": PROJECT_ROOT / "docs",
    "Dump": PROJECT_ROOT / "Dump",
    "Scripts": PROJECT_ROOT / "Scripts",
}

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

FALLBACK_RUN_GROUP_OPTIONS = [
    "FOOTBALL_MAINTENANCE",
    "FOOTBALL_MAINTENANCE_TOP",
    "MAINTENANCE_FREE",
    "BACKFILL_FREE_2022",
    "BACKFILL_FREE_2023",
    "BACKFILL_FREE_2024",
    "MAINTENANCE_PRO",
    "BACKFILL_PRO_RECENT",
]

DEFAULT_PROVIDER_BY_SPORT = {
    "football": "api_football",
    "hockey": "api_hockey",
    "basketball": "api_basketball",
    "tennis": "api_tennis",
    "mma": "api_mma",
    "volleyball": "api_volleyball",
    "handball": "api_handball",
    "baseball": "api_baseball",
    "rugby": "api_rugby",
    "cricket": "api_cricket",
    "field_hockey": "api_field_hockey",
    "american_football": "api_american_football",
    "esports": "api_esports",
}

ENTITY_PROFILE_MAP = {
    "custom": [],
    "core_ingest": ["leagues", "teams", "fixtures", "odds"],
    "full_ingest": [
        "leagues",
        "teams",
        "fixtures",
        "odds",
        "players",
        "player_profiles",
        "player_season_stats",
        "player_stats",
    ],
    "players_only": [
        "players",
        "player_profiles",
        "player_season_stats",
        "player_stats",
    ],
    "fixtures_only": ["fixtures", "odds"],
}

# -----------------------------------------
# Barvy / styl z Mission Control V7
# -----------------------------------------
BG = "#1C1330"
CARD = "#2A1B47"
CARD_2 = "#332055"
FG = "#F6EEFF"
MUTED = "#C9B8E8"
ACCENT = "#C77DFF"
ACCENT_2 = "#FF8BD1"
ACCENT_3 = "#8B5CF6"
GOOD = "#54E38E"
WARN = "#FFC857"
BAD = "#FF6B8A"
LINE = "#5B3A8A"
TEXTBOX_BG = "#130C23"


def now_str() -> str:
    return datetime.now().strftime("%H:%M:%S")


def open_path(path: Path) -> None:
    try:
        if not path.exists():
            messagebox.showwarning("Chybí cesta", f"Cesta neexistuje:\n{path}")
            return
        os.startfile(path)
    except Exception as e:
        messagebox.showerror("Chyba", f"Nelze otevřít cestu:\n{path}\n\n{e}")


class MetricCard(tk.Frame):
    def __init__(self, parent, title: str, value: str = "0", subtitle: str = "", color: str = ACCENT):
        super().__init__(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.configure(padx=12, pady=10)

        self.title_lbl = tk.Label(self, text=title, bg=CARD, fg=MUTED, font=("Segoe UI", 10, "bold"))
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(self, text=value, bg=CARD, fg=FG, font=("Segoe UI", 20, "bold"))
        self.value_lbl.pack(anchor="w", pady=(2, 0))

        self.sub_lbl = tk.Label(self, text=subtitle, bg=CARD, fg=color, font=("Segoe UI", 9))
        self.sub_lbl.pack(anchor="w", pady=(4, 0))

    def update_card(self, value, subtitle: str = "", color: str = ACCENT) -> None:
        self.value_lbl.config(text=str(value))
        self.sub_lbl.config(text=subtitle, fg=color)


class ProgressBarCard(tk.Frame):
    def __init__(self, parent, title: str, color: str = ACCENT):
        super().__init__(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.color = color
        self.configure(padx=12, pady=10)

        self.title_lbl = tk.Label(self, text=title, bg=CARD, fg=MUTED, font=("Segoe UI", 10, "bold"))
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(self, text="0 %", bg=CARD, fg=FG, font=("Segoe UI", 16, "bold"))
        self.value_lbl.pack(anchor="w", pady=(4, 2))

        self.canvas = tk.Canvas(self, height=16, bg=CARD, highlightthickness=0, bd=0)
        self.canvas.pack(fill="x", pady=(2, 2))

        self.sub_lbl = tk.Label(self, text="", bg=CARD, fg=MUTED, font=("Segoe UI", 9))
        self.sub_lbl.pack(anchor="w", pady=(4, 0))

        self._value = 0
        self.bind("<Configure>", lambda e: self.redraw(self._value))

    def redraw(self, value: int) -> None:
        self._value = max(0, min(100, int(value)))
        self.canvas.delete("all")
        w = max(20, self.canvas.winfo_width())
        self.canvas.create_rectangle(0, 2, w, 14, fill="#24173C", outline=LINE)
        fill_w = int((w - 2) * (self._value / 100))
        self.canvas.create_rectangle(1, 3, max(1, fill_w), 13, fill=self.color, outline=self.color)

    def update_bar(self, value: int, subtitle: str = "") -> None:
        self.value_lbl.config(text=f"{int(value)} %")
        self.sub_lbl.config(text=subtitle)
        self.redraw(value)


class MatchMatrixPanelV5:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("TicketMatrixPlatform Mission Control V5")
        self.root.geometry("1480x940")
        self.root.minsize(1280, 820)
        self.root.configure(bg=BG)

        self.is_running = False

        self.db_sport_options: list[str] = []
        self.db_run_group_options: list[str] = []
        self.db_entity_options: list[str] = []

        self._setup_style()
        self._build_ui()
        self.refresh_dynamic_options(initial=True)

        self.log_write("Panel připraven.")
        self.log_write("V5 přepsán do stylu Mission Control V7.")

    # --------------------------------------------------------
    # Styling
    # --------------------------------------------------------
    def _setup_style(self) -> None:
        style = ttk.Style()
        try:
            style.theme_use("clam")
        except Exception:
            pass

        style.configure("MM.TFrame", background=BG)
        style.configure("MM.TLabelframe", background=BG, foreground=FG, bordercolor=LINE)
        style.configure("MM.TLabelframe.Label", background=BG, foreground=ACCENT_2, font=("Segoe UI", 10, "bold"))
        style.configure("MM.TCheckbutton", background=BG, foreground=FG, font=("Segoe UI", 10))
        style.map("MM.TCheckbutton", background=[("active", BG)], foreground=[("active", FG)])

        style.configure("Accent.TButton", background=ACCENT_3, foreground=FG, borderwidth=0, padding=8, font=("Segoe UI", 10, "bold"))
        style.map("Accent.TButton", background=[("active", ACCENT), ("pressed", ACCENT_2)], foreground=[("active", BG), ("pressed", BG)])

        style.configure("Ghost.TButton", background=CARD_2, foreground=FG, borderwidth=0, padding=8, font=("Segoe UI", 10))
        style.map("Ghost.TButton", background=[("active", ACCENT_3), ("pressed", ACCENT)], foreground=[("active", FG), ("pressed", BG)])

        style.configure("MM.TLabel", background=BG, foreground=FG, font=("Segoe UI", 10))
        style.configure("MM.TEntry", fieldbackground=TEXTBOX_BG, foreground=FG)
        style.configure("MM.TCombobox", fieldbackground=TEXTBOX_BG, foreground=FG)

    # --------------------------------------------------------
    # DB loaders
    # --------------------------------------------------------
    def get_connection(self):
        return psycopg2.connect(**DB_CONFIG)

    def load_sports_from_db(self) -> list[str]:
        sql = """
            SELECT DISTINCT sport_code
            FROM ops.ingest_targets
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(sport_code), '') <> ''
            ORDER BY sport_code
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def load_run_groups_from_db(self) -> list[str]:
        sql = """
            SELECT DISTINCT run_group
            FROM ops.ingest_targets
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(run_group), '') <> ''
            ORDER BY run_group
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def load_entities_from_db(self) -> list[str]:
        sql = """
            SELECT DISTINCT entity
            FROM ops.ingest_entity_plan
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(entity), '') <> ''
            ORDER BY priority, entity
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def refresh_dynamic_options(self, initial: bool = False) -> None:
        try:
            sports = self.load_sports_from_db()
            run_groups = self.load_run_groups_from_db()
            entities = self.load_entities_from_db()

            if not sports:
                sports = list(DEFAULT_PROVIDER_BY_SPORT.keys())

            if not run_groups:
                run_groups = FALLBACK_RUN_GROUP_OPTIONS[:]

            if not entities:
                entities = [
                    "leagues",
                    "teams",
                    "fixtures",
                    "odds",
                    "players",
                    "player_profiles",
                    "player_season_stats",
                    "player_stats",
                ]

            self.db_sport_options = sports
            self.db_run_group_options = run_groups
            self.db_entity_options = entities

            self.reload_sports_listbox()
            self.reload_run_group_combobox()
            self.reload_entities_listbox()
            self.update_dashboard_cards()

            if not initial:
                self.log_write("Dynamické volby načteny z DB.")
                self.log_write(f"Sporty: {', '.join(self.db_sport_options)}")
                self.log_write(f"Run groups: {', '.join(self.db_run_group_options)}")
                self.log_write(f"Entity: {', '.join(self.db_entity_options)}")

        except Exception as e:
            self.db_sport_options = list(DEFAULT_PROVIDER_BY_SPORT.keys())
            self.db_run_group_options = FALLBACK_RUN_GROUP_OPTIONS[:]
            self.db_entity_options = [
                "leagues",
                "teams",
                "fixtures",
                "odds",
                "players",
                "player_profiles",
                "player_season_stats",
                "player_stats",
            ]

            self.reload_sports_listbox()
            self.reload_run_group_combobox()
            self.reload_entities_listbox()
            self.update_dashboard_cards()

            if not initial:
                self.log_write(f"DB load warning: {e}")
                self.log_write("Použit fallback seznam sportů, entity a run_group.")

    # --------------------------------------------------------
    # UI
    # --------------------------------------------------------
    def _build_ui(self) -> None:
        main = ttk.Frame(self.root, style="MM.TFrame", padding=14)
        main.pack(fill="both", expand=True)

        self.build_header(main)

        top = tk.Frame(main, bg=BG)
        top.pack(fill="x", pady=(0, 10))

        settings = ttk.LabelFrame(top, text="Batch Control", style="MM.TLabelframe", padding=10)
        settings.pack(side="left", fill="both", expand=True, padx=(0, 8))

        navigator = ttk.LabelFrame(top, text="Project Navigator", style="MM.TLabelframe", padding=10)
        navigator.pack(side="left", fill="y")

        self.build_selection_area(settings)
        self.build_action_area(settings)
        self.build_navigator(navigator)

        self.build_dashboard(main)
        self.build_log_area(main)

    def build_header(self, parent) -> None:
        header = tk.Frame(parent, bg=BG)
        header.pack(fill="x", pady=(0, 10))

        tk.Label(
            header,
            text="TICKETMATRIXPLATFORM MISSION CONTROL V5",
            bg=BG,
            fg=FG,
            font=("Segoe UI", 22, "bold"),
        ).pack(anchor="w")

        tk.Label(
            header,
            text="Multi-sport + Multi-entity batch launcher (DB-driven sports / entities / run_groups)",
            bg=BG,
            fg=MUTED,
            font=("Segoe UI", 10),
        ).pack(anchor="w", pady=(2, 4))

        tk.Label(header, text=f"Project root: {PROJECT_ROOT}", bg=BG, fg=MUTED, font=("Segoe UI", 9)).pack(anchor="w")
        tk.Label(header, text=f"Python exe: {PYTHON_EXE}", bg=BG, fg=MUTED, font=("Segoe UI", 9)).pack(anchor="w")

    def build_selection_area(self, parent) -> None:
        wrapper = tk.Frame(parent, bg=BG)
        wrapper.pack(fill="x", pady=(0, 8))

        # Levý blok - sporty
        sports_frame = tk.Frame(wrapper, bg=BG)
        sports_frame.grid(row=0, column=0, padx=8, pady=4, sticky="nw")

        tk.Label(sports_frame, text="Sporty", bg=BG, fg=FG, font=("Segoe UI", 10, "bold")).pack(anchor="w")
        self.sports_listbox = tk.Listbox(
            sports_frame,
            selectmode=tk.MULTIPLE,
            exportselection=False,
            height=12,
            width=26,
            bg=TEXTBOX_BG,
            fg=FG,
            selectbackground=ACCENT_3,
            selectforeground=FG,
            relief="flat",
        )
        self.sports_listbox.pack()

        sports_btns = tk.Frame(sports_frame, bg=BG)
        sports_btns.pack(fill="x", pady=5)

        ttk.Button(sports_btns, text="Vybrat vše", style="Ghost.TButton",
                   command=lambda: self.select_all(self.sports_listbox)).pack(side="left", padx=2)
        ttk.Button(sports_btns, text="Vymazat", style="Ghost.TButton",
                   command=lambda: self.clear_selection(self.sports_listbox)).pack(side="left", padx=2)
        ttk.Button(sports_btns, text="Refresh DB", style="Ghost.TButton",
                   command=self.refresh_dynamic_options).pack(side="left", padx=2)

        # Prostřední blok - entity
        entities_frame = tk.Frame(wrapper, bg=BG)
        entities_frame.grid(row=0, column=1, padx=8, pady=4, sticky="nw")

        tk.Label(entities_frame, text="Entity", bg=BG, fg=FG, font=("Segoe UI", 10, "bold")).pack(anchor="w")
        self.entities_listbox = tk.Listbox(
            entities_frame,
            selectmode=tk.MULTIPLE,
            exportselection=False,
            height=12,
            width=26,
            bg=TEXTBOX_BG,
            fg=FG,
            selectbackground=ACCENT_3,
            selectforeground=FG,
            relief="flat",
        )
        self.entities_listbox.pack()

        entities_btns = tk.Frame(entities_frame, bg=BG)
        entities_btns.pack(fill="x", pady=5)

        ttk.Button(entities_btns, text="Vybrat vše", style="Ghost.TButton",
                   command=lambda: self.select_all(self.entities_listbox)).pack(side="left", padx=2)
        ttk.Button(entities_btns, text="Vymazat", style="Ghost.TButton",
                   command=lambda: self.clear_selection(self.entities_listbox)).pack(side="left", padx=2)

        # Pravý blok - nastavení
        settings_frame = tk.Frame(wrapper, bg=BG)
        settings_frame.grid(row=0, column=2, padx=8, pady=4, sticky="nw")

        tk.Label(settings_frame, text="Nastavení batch běhu", bg=BG, fg=FG, font=("Segoe UI", 10, "bold")).grid(row=0, column=0, columnspan=2, sticky="w", pady=(0, 6))

        tk.Label(settings_frame, text="Run group", bg=BG, fg=FG).grid(row=1, column=0, sticky="w", pady=3)
        self.run_group_var = tk.StringVar()
        self.run_group_combo = ttk.Combobox(settings_frame, textvariable=self.run_group_var, width=28, state="readonly")
        self.run_group_combo.grid(row=1, column=1, sticky="w", pady=3)

        tk.Label(settings_frame, text="Entity profil", bg=BG, fg=FG).grid(row=2, column=0, sticky="w", pady=3)
        self.profile_var = tk.StringVar(value="custom")
        self.profile_combo = ttk.Combobox(
            settings_frame,
            textvariable=self.profile_var,
            width=28,
            state="readonly",
            values=list(ENTITY_PROFILE_MAP.keys()),
        )
        self.profile_combo.grid(row=2, column=1, sticky="w", pady=3)
        self.profile_combo.bind("<<ComboboxSelected>>", self.on_profile_changed)

        tk.Label(settings_frame, text="Provider mode", bg=BG, fg=FG).grid(row=3, column=0, sticky="w", pady=3)
        self.provider_mode_var = tk.StringVar(value="auto")
        provider_mode_combo = ttk.Combobox(
            settings_frame,
            textvariable=self.provider_mode_var,
            width=28,
            state="readonly",
            values=["auto", "manual"],
        )
        provider_mode_combo.grid(row=3, column=1, sticky="w", pady=3)
        provider_mode_combo.bind("<<ComboboxSelected>>", self.on_provider_mode_changed)

        tk.Label(settings_frame, text="Manual provider", bg=BG, fg=FG).grid(row=4, column=0, sticky="w", pady=3)
        self.manual_provider_var = tk.StringVar()
        self.manual_provider_entry = ttk.Entry(settings_frame, textvariable=self.manual_provider_var, width=31)
        self.manual_provider_entry.grid(row=4, column=1, sticky="w", pady=3)

        tk.Label(settings_frame, text="Limit", bg=BG, fg=FG).grid(row=5, column=0, sticky="w", pady=3)
        self.limit_var = tk.StringVar(value="5")
        ttk.Entry(settings_frame, textvariable=self.limit_var, width=12).grid(row=5, column=1, sticky="w", pady=3)

        tk.Label(settings_frame, text="Max workers", bg=BG, fg=FG).grid(row=6, column=0, sticky="w", pady=3)
        self.max_workers_var = tk.StringVar(value="3")
        ttk.Entry(settings_frame, textvariable=self.max_workers_var, width=12).grid(row=6, column=1, sticky="w", pady=3)

        tk.Label(settings_frame, text="Timeout sec", bg=BG, fg=FG).grid(row=7, column=0, sticky="w", pady=3)
        self.timeout_sec_var = tk.StringVar(value="300")
        ttk.Entry(settings_frame, textvariable=self.timeout_sec_var, width=12).grid(row=7, column=1, sticky="w", pady=3)

        self.on_provider_mode_changed()

    def build_action_area(self, parent) -> None:
        action_frame = tk.Frame(parent, bg=BG)
        action_frame.pack(fill="x", pady=(4, 0))

        ttk.Button(
            action_frame,
            text="Spustit batch kombinace",
            style="Accent.TButton",
            command=self.run_batch_combinations_thread,
        ).pack(side="left", padx=5, pady=8)

        ttk.Button(
            action_frame,
            text="Spustit multisport scheduler V4",
            style="Ghost.TButton",
            command=self.run_scheduler_thread,
        ).pack(side="left", padx=5, pady=8)

        ttk.Button(
            action_frame,
            text="Spustit players pipeline full",
            style="Ghost.TButton",
            command=self.run_players_pipeline_thread,
        ).pack(side="left", padx=5, pady=8)

        ttk.Button(
            action_frame,
            text="Refresh sporty + entity + run_group z DB",
            style="Ghost.TButton",
            command=self.refresh_dynamic_options,
        ).pack(side="left", padx=5, pady=8)

        ttk.Button(
            action_frame,
            text="Vyčistit log",
            style="Ghost.TButton",
            command=self.clear_logs,
        ).pack(side="left", padx=5, pady=8)

    def build_navigator(self, parent) -> None:
        nav_row = 0
        nav_col = 0
        for name, path in NAV_PATHS.items():
            ttk.Button(
                parent,
                text=name,
                style="Ghost.TButton",
                command=lambda p=path: open_path(p)
            ).grid(row=nav_row, column=nav_col, padx=4, pady=4, sticky="ew")

            nav_col += 1
            if nav_col >= 2:
                nav_col = 0
                nav_row += 1

    def build_dashboard(self, parent) -> None:
        dashboard = tk.Frame(parent, bg=BG)
        dashboard.pack(fill="x", pady=(0, 10))

        row1 = tk.Frame(dashboard, bg=BG)
        row1.pack(fill="x", pady=(0, 8))

        self.card_sports = MetricCard(row1, "Sporty", "0", "načteno z DB", ACCENT)
        self.card_sports.pack(side="left", fill="both", expand=True, padx=4)

        self.card_entities = MetricCard(row1, "Entity", "0", "načteno z DB", ACCENT_2)
        self.card_entities.pack(side="left", fill="both", expand=True, padx=4)

        self.card_run_groups = MetricCard(row1, "Run groups", "0", "načteno z DB", ACCENT)
        self.card_run_groups.pack(side="left", fill="both", expand=True, padx=4)

        self.card_status = MetricCard(row1, "Stav panelu", "READY", "čeká na akci", GOOD)
        self.card_status.pack(side="left", fill="both", expand=True, padx=4)

        row2 = tk.Frame(dashboard, bg=BG)
        row2.pack(fill="x")

        self.bar_sports = ProgressBarCard(row2, "SPORT COVERAGE", ACCENT)
        self.bar_sports.pack(side="left", fill="both", expand=True, padx=4)

        self.bar_entities = ProgressBarCard(row2, "ENTITY COVERAGE", ACCENT_3)
        self.bar_entities.pack(side="left", fill="both", expand=True, padx=4)

        self.bar_selection = ProgressBarCard(row2, "CURRENT SELECTION", ACCENT_2)
        self.bar_selection.pack(side="left", fill="both", expand=True, padx=4)

    def build_log_area(self, parent) -> None:
        body = tk.PanedWindow(parent, orient="horizontal", bg=BG, sashwidth=8, sashrelief="flat")
        body.pack(fill="both", expand=True)

        left = tk.Frame(body, bg=BG)
        right = tk.Frame(body, bg=BG)
        body.add(left, minsize=500)
        body.add(right, minsize=650)

        left_wrap = ttk.LabelFrame(left, text="Vizualizace a přehled", style="MM.TLabelframe", padding=8)
        left_wrap.pack(fill="both", expand=True, padx=(0, 6))

        right_wrap = ttk.LabelFrame(right, text="Log běhu", style="MM.TLabelframe", padding=8)
        right_wrap.pack(fill="both", expand=True)

        self.stats_text = scrolledtext.ScrolledText(
            left_wrap,
            wrap="word",
            font=("Consolas", 10),
            bg=TEXTBOX_BG,
            fg=FG,
            insertbackground=FG,
            relief="flat",
            padx=10,
            pady=10,
        )
        self.stats_text.pack(fill="both", expand=True)

        self.log_text = scrolledtext.ScrolledText(
            right_wrap,
            wrap="word",
            font=("Consolas", 10),
            bg=TEXTBOX_BG,
            fg=FG,
            insertbackground=FG,
            relief="flat",
            padx=10,
            pady=10,
        )
        self.log_text.pack(fill="both", expand=True)

    # --------------------------------------------------------
    # UI helpers
    # --------------------------------------------------------
    def reload_sports_listbox(self) -> None:
        current_selection = [self.sports_listbox.get(i) for i in self.sports_listbox.curselection()]
        self.sports_listbox.delete(0, tk.END)

        for sport in self.db_sport_options:
            self.sports_listbox.insert(tk.END, sport)

        for idx, sport in enumerate(self.db_sport_options):
            if sport in current_selection:
                self.sports_listbox.selection_set(idx)

    def reload_entities_listbox(self) -> None:
        current_selection = [self.entities_listbox.get(i) for i in self.entities_listbox.curselection()]
        self.entities_listbox.delete(0, tk.END)

        for entity in self.db_entity_options:
            self.entities_listbox.insert(tk.END, entity)

        for idx, entity in enumerate(self.db_entity_options):
            if entity in current_selection:
                self.entities_listbox.selection_set(idx)

    def reload_run_group_combobox(self) -> None:
        current_value = self.run_group_var.get()
        self.run_group_combo["values"] = self.db_run_group_options

        if current_value and current_value in self.db_run_group_options:
            self.run_group_var.set(current_value)
        elif self.db_run_group_options:
            self.run_group_var.set(self.db_run_group_options[0])
        else:
            self.run_group_var.set("")

    def select_all(self, listbox: tk.Listbox) -> None:
        listbox.select_set(0, tk.END)
        self.update_dashboard_cards()

    def clear_selection(self, listbox: tk.Listbox) -> None:
        listbox.selection_clear(0, tk.END)
        self.update_dashboard_cards()

    def clear_logs(self) -> None:
        self.log_text.delete("1.0", "end")
        self.stats_text.delete("1.0", "end")
        self.log_write("Log vyčištěn.")

    def log_write(self, message: str) -> None:
        ts = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{ts}] {message}\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()

    def stats_write(self, message: str) -> None:
        self.stats_text.insert(tk.END, f"{message}\n")
        self.stats_text.see(tk.END)
        self.root.update_idletasks()

    def update_dashboard_cards(self) -> None:
        sports_total = len(self.db_sport_options)
        entities_total = len(self.db_entity_options)
        run_groups_total = len(self.db_run_group_options)

        sports_selected = len(self.get_selected_sports()) if hasattr(self, "sports_listbox") else 0
        entities_selected = len(self.get_selected_entities()) if hasattr(self, "entities_listbox") else 0

        self.card_sports.update_card(sports_total, "sporty dostupné", ACCENT)
        self.card_entities.update_card(entities_total, "entity dostupné", ACCENT_2)
        self.card_run_groups.update_card(run_groups_total, "run groups dostupné", ACCENT)

        if self.is_running:
            self.card_status.update_card("RUNNING", "probíhá proces", WARN)
        else:
            self.card_status.update_card("READY", "čeká na akci", GOOD)

        sports_pct = 100 if sports_total > 0 else 0
        entities_pct = 100 if entities_total > 0 else 0

        self.bar_sports.update_bar(sports_pct, f"načteno {sports_total} sportů")
        self.bar_entities.update_bar(entities_pct, f"načteno {entities_total} entit")

        selection_pct = 0
        if sports_total > 0 and entities_total > 0:
            sport_part = int((sports_selected / max(sports_total, 1)) * 50)
            entity_part = int((entities_selected / max(entities_total, 1)) * 50)
            selection_pct = sport_part + entity_part

        self.bar_selection.update_bar(
            selection_pct,
            f"vybráno sporty {sports_selected}/{sports_total}, entity {entities_selected}/{entities_total}"
        )

    def on_provider_mode_changed(self, event=None) -> None:
        mode = self.provider_mode_var.get()
        if mode == "manual":
            self.manual_provider_entry.config(state="normal")
        else:
            self.manual_provider_entry.config(state="disabled")

    def on_profile_changed(self, event=None) -> None:
        profile = self.profile_var.get()

        if profile == "custom":
            self.log_write("Použit profil entit: custom")
            self.update_dashboard_cards()
            return

        wanted = ENTITY_PROFILE_MAP.get(profile, [])
        self.entities_listbox.selection_clear(0, tk.END)

        for idx, entity in enumerate(self.db_entity_options):
            if entity in wanted:
                self.entities_listbox.selection_set(idx)

        self.log_write(f"Použit profil entit: {profile}")
        self.update_dashboard_cards()

    # --------------------------------------------------------
    # Commands
    # --------------------------------------------------------
    def get_selected_sports(self) -> list[str]:
        if not hasattr(self, "sports_listbox"):
            return []
        return [self.sports_listbox.get(i) for i in self.sports_listbox.curselection()]

    def get_selected_entities(self) -> list[str]:
        if not hasattr(self, "entities_listbox"):
            return []
        return [self.entities_listbox.get(i) for i in self.entities_listbox.curselection()]

    def resolve_provider_for_sport(self, sport: str) -> str:
        if self.provider_mode_var.get() == "manual":
            provider = self.manual_provider_var.get().strip()
            return provider if provider else DEFAULT_PROVIDER_BY_SPORT.get(sport, f"api_{sport}")
        return DEFAULT_PROVIDER_BY_SPORT.get(sport, f"api_{sport}")

    def run_batch_combinations_thread(self) -> None:
        thread = threading.Thread(target=self.run_batch_combinations, daemon=True)
        thread.start()

    def run_scheduler_thread(self) -> None:
        thread = threading.Thread(target=self.run_scheduler, daemon=True)
        thread.start()

    def run_players_pipeline_thread(self) -> None:
        thread = threading.Thread(target=self.run_players_pipeline, daemon=True)
        thread.start()

    def run_scheduler(self) -> None:
        cmd = [PYTHON_EXE, SCHEDULER_RUNNER]
        self.log_write("Spouštím scheduler:")
        self.log_write(" ".join(cmd))
        self.run_command_stream(cmd)

    def run_players_pipeline(self) -> None:
        cmd = [PYTHON_EXE, PLAYERS_PIPELINE_RUNNER]
        self.log_write("Spouštím players pipeline full:")
        self.log_write(" ".join(cmd))
        self.run_command_stream(cmd)

    def run_batch_combinations(self) -> None:
        selected_sports = self.get_selected_sports()
        selected_entities = self.get_selected_entities()

        if not selected_sports:
            self.log_write("Není vybrán žádný sport.")
            return

        if not selected_entities:
            self.log_write("Není vybrána žádná entity.")
            return

        run_group = self.run_group_var.get().strip()
        limit = self.limit_var.get().strip() or "5"
        max_workers = self.max_workers_var.get().strip() or "3"
        timeout_sec = self.timeout_sec_var.get().strip() or "300"

        self.stats_text.delete("1.0", "end")
        self.stats_write("=== MATCHMATRIX BATCH OVERVIEW ===")
        self.stats_write(f"Run group: {run_group or '(bez run_group)'}")
        self.stats_write(f"Limit: {limit}")
        self.stats_write(f"Max workers: {max_workers}")
        self.stats_write(f"Timeout sec: {timeout_sec}")
        self.stats_write(f"Sporty: {', '.join(selected_sports)}")
        self.stats_write(f"Entity: {', '.join(selected_entities)}")
        self.stats_write("")

        for sport in selected_sports:
            provider = self.resolve_provider_for_sport(sport)

            for entity in selected_entities:
                cmd = [
                    PYTHON_EXE,
                    BATCH_RUNNER,
                    "--provider", provider,
                    "--sport", sport,
                    "--entity", entity,
                    "--limit", limit,
                    "--max-workers", max_workers,
                    "--timeout-sec", timeout_sec,
                ]

                if run_group:
                    cmd.extend(["--run-group", run_group])

                self.log_write("=" * 70)
                self.log_write(f"Spouštím batch: sport={sport}, entity={entity}, provider={provider}")
                self.log_write("CMD: " + " ".join(cmd))
                self.run_command_stream(cmd)

    def run_command_stream(self, cmd: list[str]) -> None:
        try:
            self.is_running = True
            self.update_dashboard_cards()

            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                universal_newlines=True,
            )

            assert process.stdout is not None
            for line in process.stdout:
                self.log_write(line.rstrip())

            process.wait()

            if process.returncode == 0:
                self.log_write("Hotovo OK.")
            else:
                self.log_write(f"Proces skončil s chybovým kódem: {process.returncode}")

        except Exception as e:
            self.log_write(f"CHYBA při spuštění procesu: {e}")

        finally:
            self.is_running = False
            self.update_dashboard_cards()


def main():
    root = tk.Tk()
    app = MatchMatrixPanelV5(root)
    root.mainloop()


if __name__ == "__main__":
    main()