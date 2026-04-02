from __future__ import annotations

import os
import subprocess
import threading
import tkinter as tk
from datetime import datetime
from pathlib import Path
from tkinter import messagebox, ttk

import psycopg2


# ============================================================
# MATCHMATRIX CONTROL PANEL V9
# - compact / responsive layout
# - global scroll for whole window
# - adaptive bottom split
# - snapshot before/after/diff
# - live run status
# ============================================================

PROJECT_ROOT = Path(r"C:\MatchMatrix-platform")
PYTHON_EXE = r"C:\Python314\python.exe"

BATCH_RUNNER = str(PROJECT_ROOT / "ingest" / "run_unified_ingest_batch_v1.py")
SCHEDULER_RUNNER = str(PROJECT_ROOT / "workers" / "run_ingest_cycle_v3.py")
PLAYERS_PIPELINE_RUNNER = str(PROJECT_ROOT / "workers" / "run_players_pipeline_transitional_v1.py")
THEODDS_RUNNER = str(PROJECT_ROOT / "workers" / "run_theodds_ingest_v2.py")
FOOTBALL_DATA_RUNNER = str(PROJECT_ROOT / "workers" / "run_football_data_ingest_v1.py")

PROVIDER_UPDATE_COMMANDS = {
    "THEODDS": [
        PYTHON_EXE,
        THEODDS_RUNNER,
    ],
    "FOOTBALL_DATA": [
        PYTHON_EXE,
        FOOTBALL_DATA_RUNNER,
    ],
}

NAV_PATHS = {
    "Projekt root": PROJECT_ROOT,
    "Workers": PROJECT_ROOT / "workers",
    "Ingest": PROJECT_ROOT / "ingest",
    "DB": PROJECT_ROOT / "db",
    "API-Football": PROJECT_ROOT / "ingest" / "API-Football",
    "Reports": PROJECT_ROOT / "reports",
    "Docs": PROJECT_ROOT / "docs",
    "Dump": PROJECT_ROOT / "Dump",
}

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

FALLBACK_RUN_GROUP_OPTIONS = [
    "FB_BOOTSTRAP_V1",
    "FB_TOP",
    "FB_API_EXPANSION",
    "FB_FD_CORE",
    "HK_TOP",
    "HK_CORE",
    "BK_TOP",
    "BK_CORE",
    "TN_CORE",
    "MMA_CORE",
    "VB_CORE",
    "HB_CORE",
    "BSB_CORE",
    "RGB_CORE",
    "CK_CORE",
    "FH_CORE",
    "AFB_CORE",
    "ESP_CORE",
    "DRT_CORE",
]

DEFAULT_PROVIDER_BY_SPORT = {
    "FB": "api_football",
    "HK": "api_hockey",
    "BK": "api_sport",
    "football": "api_football",
    "hockey": "api_hockey",
    "basketball": "api_sport",
    "TN": "api_tennis",
    "tennis": "api_tennis",
    "MMA": "api_mma",
    "mma": "api_mma",
    "VB": "api_volleyball",
    "volleyball": "api_volleyball",
    "HB": "api_handball",
    "handball": "api_handball",
    "BSB": "api_baseball",
    "baseball": "api_baseball",
    "RGB": "api_rugby",
    "rugby": "api_rugby",
    "CK": "api_cricket",
    "cricket": "api_cricket",
    "FH": "api_field_hockey",
    "field_hockey": "api_field_hockey",
    "AFB": "api_american_football",
    "american_football": "api_american_football",
    "ESP": "api_esports",
    "esports": "api_esports",
    "DRT": "api_darts",
    "darts": "api_darts",
}

PROVIDER_LABELS = {
    "THEODDS": "THEODDS - odds refresh",
    "FOOTBALL_DATA": "FOOTBALL_DATA - matches/results refresh",
}

SPORT_LABELS = {
    "FB": "FB - Football",
    "HK": "HK - Hockey",
    "BK": "BK - Basketball",
    "TN": "TN - Tennis",
    "MMA": "MMA - MMA",
    "VB": "VB - Volleyball",
    "HB": "HB - Handball",
    "BSB": "BSB - Baseball",
    "RGB": "RGB - Rugby",
    "CK": "CK - Cricket",
    "FH": "FH - Field Hockey",
    "AFB": "AFB - American Football",
    "ESP": "ESP - Esports",
    "DRT": "DRT - Darts",
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

# ------------------------------------------------------------
# Styl / compact V9
# ------------------------------------------------------------
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

FONT_FAMILY = "Segoe UI"
FONT_TITLE = (FONT_FAMILY, 15, "bold")
FONT_SUBTITLE = (FONT_FAMILY, 10)
FONT_LABEL = (FONT_FAMILY, 10, "bold")
FONT_TEXT = (FONT_FAMILY, 10)
FONT_VALUE = (FONT_FAMILY, 13, "bold")
FONT_SMALL = (FONT_FAMILY, 10)
FONT_MONO = ("Consolas", 10)

PAD_OUTER = 3
PAD_CARD_X = 2
PAD_CARD_Y = 2
CARD_INNER_PAD_X = 5
CARD_INNER_PAD_Y = 3

TOP_STACK_BREAKPOINT = 920
BOTTOM_STACK_BREAKPOINT = 1000


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
        self.configure(padx=CARD_INNER_PAD_X, pady=CARD_INNER_PAD_Y)

        self.title_lbl = tk.Label(self, text=title, bg=CARD, fg=MUTED, font=FONT_LABEL)
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(self, text=value, bg=CARD, fg=FG, font=FONT_VALUE)
        self.value_lbl.pack(anchor="w", pady=(1, 0))

        self.sub_lbl = tk.Label(self, text=subtitle, bg=CARD, fg=color, font=FONT_SMALL)
        self.sub_lbl.pack(anchor="w", pady=(4, 0))

    def update_card(self, value, subtitle: str = "", color: str = ACCENT) -> None:
        self.value_lbl.config(text=str(value))
        self.sub_lbl.config(text=subtitle, fg=color)


class ProgressBarCard(tk.Frame):
    def __init__(self, parent, title: str, color: str = ACCENT):
        super().__init__(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.color = color
        self.configure(padx=CARD_INNER_PAD_X, pady=CARD_INNER_PAD_Y)

        self.title_lbl = tk.Label(self, text=title, bg=CARD, fg=MUTED, font=FONT_LABEL)
        self.title_lbl.pack(anchor="w")

        self.value_lbl = tk.Label(self, text="0 %", bg=CARD, fg=FG, font=(FONT_FAMILY, 14, "bold"))
        self.value_lbl.pack(anchor="w", pady=(1, 0))

        self.canvas = tk.Canvas(self, height=10, bg=CARD, highlightthickness=0, bd=0)
        self.canvas.pack(fill="x", pady=(2, 1))

        self.sub_lbl = tk.Label(self, text="", bg=CARD, fg=MUTED, font=FONT_SMALL)
        self.sub_lbl.pack(anchor="w", pady=(2, 0))

        self._value = 0
        self.bind("<Configure>", lambda e: self.redraw(self._value))

    def redraw(self, value: int) -> None:
        self._value = max(0, min(100, int(value)))
        self.canvas.delete("all")
        w = max(40, self.canvas.winfo_width())
        self.canvas.create_rectangle(0, 1, w, 9, fill="#24173C", outline=LINE)
        fill_w = int((w - 2) * (self._value / 100))
        self.canvas.create_rectangle(1, 2, max(2, fill_w), 8, fill=self.color, outline=self.color)

    def update_bar(self, value: int, subtitle: str = "") -> None:
        self.value_lbl.config(text=f"{int(value)} %")
        self.sub_lbl.config(text=subtitle)
        self.redraw(value)


class MatchMatrixPanelV11:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("TicketMatrixPlatform Mission Control V11")
        self.root.geometry("1366x768")
        self.root.minsize(760, 480)
        self.root.tk.call("tk", "scaling", 0.9)
        self.root.configure(bg=BG)

        self.is_running = False
        self.db_sport_options: list[str] = []
        self.db_run_group_options: list[str] = []
        self.db_entity_options: list[str] = []

        self.before_snapshot: dict[str, int] = {}
        self.after_snapshot: dict[str, int] = {}
        self.last_run_info: dict[str, str] = {}
        self.current_runner_name = ""
        self.current_step = 0
        self.total_steps = 0

        self.current_top_layout = None
        self.current_bottom_layout = None

        self._setup_style()
        self._build_ui()
        self.refresh_dynamic_options(initial=True)
        self.refresh_ops_dashboard()
        self.refresh_provider_status_cards()
        self.render_snapshot_before({})
        self.render_snapshot_after({})
        self.render_snapshot_diff({}, {})

        self.log_write("Panel připraven.")
        self.log_write("V9 načten: compact + responsive + global scroll + adaptive layout.")

    # --------------------------------------------------------
    # Styling
    # --------------------------------------------------------
    def _setup_style(self) -> None:
        style = ttk.Style()
        try:
            style.theme_use("clam")
        except Exception:
            pass

        style.configure("MM.TLabelframe", background=BG, foreground=FG, bordercolor=LINE)
        style.configure("MM.TLabelframe.Label", background=BG, foreground=ACCENT_2, font=FONT_LABEL)

        style.configure(
            "Accent.TButton",
            background=ACCENT_3,
            foreground=FG,
            borderwidth=0,
            padding=2,
            font=(FONT_FAMILY, 8, "bold"),
        )
        style.map(
            "Accent.TButton",
            background=[("active", ACCENT), ("pressed", ACCENT_2)],
            foreground=[("active", BG), ("pressed", BG)],
        )

        style.configure(
            "Ghost.TButton",
            background=CARD_2,
            foreground=FG,
            borderwidth=0,
            padding=2,
            font=(FONT_FAMILY, 8),
        )
        style.map(
            "Ghost.TButton",
            background=[("active", ACCENT_3), ("pressed", ACCENT)],
            foreground=[("active", FG), ("pressed", BG)],
        )

        style.configure(
            "Treeview",
            background=TEXTBOX_BG,
            fieldbackground=TEXTBOX_BG,
            foreground=FG,
            rowheight=16,
            borderwidth=0,
            font=FONT_SMALL,
        )
        style.configure(
            "Treeview.Heading",
            background=CARD_2,
            foreground=FG,
            relief="flat",
            font=FONT_LABEL,
        )
        style.map(
            "Treeview.Heading",
            background=[("active", ACCENT_3)],
            foreground=[("active", FG)],
        )

        style.configure(
            "TCombobox",
            fieldbackground="#F1EEF7",
            background="#F1EEF7",
            foreground="#111111",
            arrowsize=12,
            padding=2,
        )

    # --------------------------------------------------------
    # DB helpers
    # --------------------------------------------------------
    def get_connection(self):
        return psycopg2.connect(**DB_CONFIG)

    def safe_fetch_one(self, sql: str, default=None):
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                row = cur.fetchone()
                return row[0] if row and row[0] is not None else default
        finally:
            conn.close()

    def safe_fetch_row(self, sql: str):
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return cur.fetchone()
        finally:
            conn.close()

    def safe_fetch_one_dict(self, sql: str) -> dict | None:
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                row = cur.fetchone()
                if row is None:
                    return None
                cols = [desc[0] for desc in cur.description]
                return dict(zip(cols, row))
        finally:
            conn.close()

    def safe_fetch_all_dicts(self, sql: str) -> list[dict]:
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                rows = cur.fetchall()
                cols = [desc[0] for desc in cur.description]
                return [dict(zip(cols, row)) for row in rows]
        finally:
            conn.close()

    def load_last_provider_runs(self) -> dict[str, dict]:
        result: dict[str, dict] = {}

        rows = self.safe_fetch_all_dicts("""
            SELECT source, status, started_at, finished_at
            FROM (
                SELECT
                    source,
                    status,
                    started_at,
                    finished_at,
                    ROW_NUMBER() OVER (
                        PARTITION BY source
                        ORDER BY started_at DESC NULLS LAST, id DESC
                    ) AS rn
                FROM public.api_import_runs
                WHERE source IN ('theodds', 'football_data')
            ) x
            WHERE rn = 1
        """)

        for row in rows:
            source = str(row.get("source") or "").lower()
            result[source] = row

        return result

    def load_dashboard_kpi_data(self) -> dict:
        summary = self.safe_fetch_one_dict("""
            SELECT *
            FROM ops.v_ops_dashboard_summary
        """) or {}

        by_sport = self.safe_fetch_all_dicts("""
            SELECT *
            FROM ops.v_ops_dashboard_by_sport
            ORDER BY pending_total DESC, sport_code
        """)

        by_provider = self.safe_fetch_all_dicts("""
            SELECT *
            FROM ops.v_ops_dashboard_by_provider
            ORDER BY pending_total DESC, provider
        """)

        top_queue = self.safe_fetch_all_dicts("""
            SELECT *
            FROM ops.v_ops_panel_top_queue
            LIMIT 30
        """)

        return {
            "summary": summary,
            "by_sport": by_sport,
            "by_provider": by_provider,
            "top_queue": top_queue,
        }

    def load_enabled_target_sports_from_db(self) -> set[str]:
        sql = """
            SELECT DISTINCT sport_code
            FROM ops.ingest_targets
            WHERE enabled = TRUE
            AND COALESCE(BTRIM(sport_code), '') <> ''
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return {row[0] for row in cur.fetchall()}
        finally:
            conn.close()

    def load_sports_from_db(self) -> list[str]:
        sql = """
            SELECT code
            FROM public.sports
            WHERE is_active = TRUE
            AND COALESCE(BTRIM(code), '') <> ''
            ORDER BY sort_order, code
        """
        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def load_run_groups_from_db(self, provider: str | None = None, sport: str | None = None) -> list[str]:
        sql = """
            SELECT DISTINCT run_group
            FROM ops.ingest_targets
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(run_group), '') <> ''
        """
        params = []
        if provider:
            sql += "\n  AND provider = %s"
            params.append(provider)
        if sport:
            sql += "\n  AND sport_code = %s"
            params.append(sport)
        sql += "\n ORDER BY run_group"

        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql, tuple(params))
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def load_run_groups_for_selected_sports(self, sports: list[str]) -> list[str]:
        if not sports:
            return []

        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT DISTINCT run_group
                    FROM ops.ingest_targets
                    WHERE enabled = TRUE
                      AND COALESCE(BTRIM(run_group), '') <> ''
                      AND sport_code = ANY(%s)
                    ORDER BY run_group
                    """,
                    (sports,),
                )
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def load_entities_from_db(self, provider: str | None = None, sport: str | None = None) -> list[str]:
        sql = """
            SELECT DISTINCT entity
            FROM ops.ingest_entity_plan
            WHERE enabled = TRUE
              AND COALESCE(BTRIM(entity), '') <> ''
        """
        params = []
        if provider:
            sql += "\n  AND provider = %s"
            params.append(provider)
        if sport:
            sql += "\n  AND sport_code = %s"
            params.append(sport)
        sql += "\n ORDER BY entity"

        conn = self.get_connection()
        try:
            with conn.cursor() as cur:
                cur.execute(sql, tuple(params))
                return [row[0] for row in cur.fetchall()]
        finally:
            conn.close()

    def collect_db_snapshot(self) -> dict[str, int]:
        snapshot = {}
        queries = {
            "matches": "SELECT COUNT(*) FROM public.matches",
            "leagues": "SELECT COUNT(*) FROM public.leagues",
            "teams": "SELECT COUNT(*) FROM public.teams",
            "players": "SELECT COUNT(*) FROM public.players",
            "player_season_statistics": "SELECT COUNT(*) FROM public.player_season_statistics",
            "stg_player_season_stats": "SELECT COUNT(*) FROM staging.stg_provider_player_season_stats",
            "stg_provider_fixtures": "SELECT COUNT(*) FROM staging.stg_provider_fixtures",
            "stg_provider_teams": "SELECT COUNT(*) FROM staging.stg_provider_teams",
            "planner_pending_ready": """
                SELECT COUNT(*) FROM ops.ingest_planner
                WHERE status IN ('pending', 'ready')
            """,
            "planner_running": """
                SELECT COUNT(*) FROM ops.ingest_planner
                WHERE status = 'running'
            """,
            "job_runs": "SELECT COUNT(*) FROM ops.job_runs",
            "api_import_runs": "SELECT COUNT(*) FROM public.api_import_runs",
            "api_raw_payloads": "SELECT COUNT(*) FROM public.api_raw_payloads",
            "odds": "SELECT COUNT(*) FROM public.odds",
            "bookmakers": "SELECT COUNT(*) FROM public.bookmakers",
            "theodds_runs": """
                SELECT COUNT(*)
                FROM public.api_import_runs
                WHERE source = 'theodds'
            """,
            "football_data_runs": """
                SELECT COUNT(*)
                FROM public.api_import_runs
                WHERE source = 'football_data'
            """,
        }

        for key, sql in queries.items():
            try:
                snapshot[key] = int(self.safe_fetch_one(sql, 0) or 0)
            except Exception:
                snapshot[key] = 0

        return snapshot

    def refresh_dynamic_options(self, initial: bool = False) -> None:
        try:
            sports = self.load_sports_from_db()
            enabled_target_sports = self.load_enabled_target_sports_from_db()
            self.enabled_target_sports = enabled_target_sports

            if not sports:
                sports = ["FB", "HK", "BK"]

            self.db_sport_options = sports
            self.reload_sports_listbox()

            selected_sports = self.get_selected_sports() if hasattr(self, "sports_listbox") else []

            sport = selected_sports[0] if selected_sports else (sports[0] if sports else None)
            provider = self.resolve_provider_for_sport(sport) if sport else None

            if len(selected_sports) > 1:
                run_groups = self.load_run_groups_for_selected_sports(selected_sports)
            else:
                run_groups = self.load_run_groups_from_db(provider, sport) if sport else []

            entities = self.load_entities_from_db(provider, sport) if sport else []

            if not run_groups:
                run_groups = FALLBACK_RUN_GROUP_OPTIONS[:]

            if not entities:
                entities = [
                    "leagues",
                    "teams",
                    "fixtures",
                    "odds",
                    "players",
                    "coaches",
                ]

            self.db_run_group_options = run_groups
            self.db_entity_options = entities

            self.reload_run_group_combobox()
            self.reload_entities_listbox()
            self.update_selection_dashboard()

            if not initial:
                self.log_write(f"Dynamické volby načteny z DB pro sport: {sport or '-'}")

        except Exception as e:
            self.db_sport_options = ["FB", "HK", "BK"]
            self.db_run_group_options = FALLBACK_RUN_GROUP_OPTIONS[:]
            self.db_entity_options = [
                "leagues",
                "teams",
                "fixtures",
                "odds",
                "players",
                "coaches",
            ]

            self.reload_sports_listbox()
            self.reload_run_group_combobox()
            self.reload_entities_listbox()
            self.update_selection_dashboard()

            if not initial:
                self.log_write(f"DB load warning: {e}")
                self.log_write("Použit fallback seznam sportů, entit a run_group.")

    def refresh_ops_dashboard(self) -> None:
        try:
            dashboard = self.load_dashboard_kpi_data()
            summary = dashboard.get("summary", {})
            by_sport = dashboard.get("by_sport", [])
            by_provider = dashboard.get("by_provider", [])
            top_queue = dashboard.get("top_queue", [])

            run_now_rows = int(summary.get("run_now_rows", 0) or 0)
            validate_rows = int(summary.get("validate_rows", 0) or 0)
            blocked_rows = int(summary.get("blocked_rows", 0) or 0)
            pending_total = int(summary.get("pending_total", 0) or 0)
            can_run_rows = int(summary.get("can_run_rows", 0) or 0)
            total_rows = int(summary.get("total_rows", 0) or 0)
            requests_used = int(summary.get("requests_used", 0) or 0)
            requests_limit = int(summary.get("requests_limit", 0) or 0)
            active_worker_locks = int(summary.get("active_worker_locks", 0) or 0)
            pct_can_run = int(float(summary.get("pct_can_run", 0) or 0))
            pct_enabled_targets = int(float(summary.get("pct_enabled_targets", 0) or 0))

            top_sport = by_sport[0] if by_sport else {}
            top_provider = by_provider[0] if by_provider else {}
            next_item = top_queue[0] if top_queue else {}

            self.card_matches.update_card(run_now_rows, "RUN NOW", GOOD if run_now_rows else MUTED)
            self.card_leagues.update_card(validate_rows, "RUN_VALIDATE", WARN if validate_rows else MUTED)
            self.card_teams.update_card(blocked_rows, "BLOCKED", BAD if blocked_rows else GOOD)
            self.card_players.update_card(pending_total, "PENDING TOTAL", ACCENT_2)

            self.card_planner_pending.update_card(
                f"{can_run_rows}/{total_rows}",
                "CAN RUN / TOTAL",
                GOOD if can_run_rows else WARN,
            )
            self.card_planner_running.update_card(
                f"{requests_used}/{requests_limit}",
                "API BUDGET used/limit",
                GOOD if requests_used < requests_limit else BAD,
            )

            if top_sport:
                self.card_last_job.update_card(
                    top_sport.get("sport_code", "-"),
                    f"TOP SPORT backlog {top_sport.get('pending_total', 0)}",
                    ACCENT,
                )
            else:
                self.card_last_job.update_card("-", "bez sport KPI", MUTED)

            next_label = "bez akční fronty"
            next_color = MUTED
            if next_item:
                next_label = f"{next_item.get('provider', '-')}/{next_item.get('sport_code', '-')}/{next_item.get('entity', '-')}"
                next_color = GOOD if str(next_item.get("queue_action", "")).upper() == "RUN_NOW" else WARN

            self.card_live_status.update_card(
                active_worker_locks,
                f"LOCKS | next: {next_label}",
                next_color,
            )

            self.bar_db_health.update_bar(
                pct_enabled_targets,
                f"enabled targets {summary.get('enabled_targets_sum', 0)}/{summary.get('total_targets_sum', 0)}",
            )
            self.bar_ops_health.update_bar(
                pct_can_run,
                f"can run {can_run_rows}/{total_rows} | top provider {top_provider.get('provider', '-')}: {top_provider.get('pending_total', 0)}",
            )

        except Exception as e:
            self.card_matches.update_card("-", "dashboard view error", BAD)
            self.card_leagues.update_card("-", "dashboard view error", BAD)
            self.card_teams.update_card("-", "dashboard view error", BAD)
            self.card_players.update_card("-", "dashboard view error", BAD)
            self.card_planner_pending.update_card("-", "dashboard view error", BAD)
            self.card_planner_running.update_card("-", "dashboard view error", BAD)
            self.card_last_job.update_card("-", "dashboard view error", BAD)
            self.card_live_status.update_card("ERR", "dashboard view error", BAD)
            self.bar_db_health.update_bar(0, "dashboard view error")
            self.bar_ops_health.update_bar(0, "dashboard view error")
            self.log_write(f"OPS/DB dashboard warning: {e}")

    # --------------------------------------------------------
    # UI build
    # --------------------------------------------------------
    def _build_ui(self) -> None:
        self.root.grid_rowconfigure(0, weight=1)
        self.root.grid_columnconfigure(0, weight=1)

        # hlavní canvas pro scroll celé aplikace
        self.outer_canvas = tk.Canvas(
            self.root,
            bg=BG,
            highlightthickness=0,
            bd=0,
        )
        self.outer_canvas.grid(row=0, column=0, sticky="nsew")

        self.outer_vscroll = ttk.Scrollbar(self.root, orient="vertical", command=self.outer_canvas.yview)
        self.outer_vscroll.grid(row=0, column=1, sticky="ns")

        self.outer_hscroll = ttk.Scrollbar(self.root, orient="horizontal", command=self.outer_canvas.xview)
        self.outer_hscroll.grid(row=1, column=0, sticky="ew")

        self.outer_canvas.configure(
            yscrollcommand=self.outer_vscroll.set,
            xscrollcommand=self.outer_hscroll.set,
        )

        self.scroll_frame = tk.Frame(self.outer_canvas, bg=BG)
        self.canvas_window = self.outer_canvas.create_window((0, 0), window=self.scroll_frame, anchor="nw")

        self.scroll_frame.bind("<Configure>", self._update_scroll_region)
        self.outer_canvas.bind("<Configure>", self._on_canvas_configure)

        self._bind_mousewheel_recursive(self.root)

        self.main = tk.Frame(self.scroll_frame, bg=BG)
        self.main.grid(row=0, column=0, sticky="nsew", padx=PAD_OUTER, pady=PAD_OUTER)
        self.main.grid_columnconfigure(0, weight=1)

        self.build_header(self.main)
        self.build_top_controls(self.main)
        self.build_selection_dashboard(self.main)
        self.build_ops_dashboard(self.main)
        self.build_bottom_area(self.main)

        self.root.bind("<Configure>", self.on_root_resize)

    def _update_scroll_region(self, event=None) -> None:
        try:
            self.outer_canvas.configure(scrollregion=self.outer_canvas.bbox("all"))
        except Exception:
            pass

    def _on_canvas_configure(self, event) -> None:
        # drží minimálně šířku okna, ale dovolí i horizontální scroll při extrémně úzkém zobrazení
        try:
            canvas_width = event.width
            desired_width = max(canvas_width, 1080)
            self.outer_canvas.itemconfigure(self.canvas_window, width=event.width)
        except Exception:
            pass

    def _bind_mousewheel_recursive(self, widget) -> None:
        widget.bind_all("<MouseWheel>", self._on_mousewheel_windows)
        widget.bind_all("<Button-4>", self._on_mousewheel_linux_up)
        widget.bind_all("<Button-5>", self._on_mousewheel_linux_down)
        widget.bind_all("<Shift-MouseWheel>", self._on_shift_mousewheel)

    def _on_mousewheel_windows(self, event) -> None:
        try:
            self.outer_canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
        except Exception:
            pass

    def _on_shift_mousewheel(self, event) -> None:
        try:
            self.outer_canvas.xview_scroll(int(-1 * (event.delta / 120)), "units")
        except Exception:
            pass

    def _on_mousewheel_linux_up(self, event) -> None:
        try:
            self.outer_canvas.yview_scroll(-1, "units")
        except Exception:
            pass

    def _on_mousewheel_linux_down(self, event) -> None:
        try:
            self.outer_canvas.yview_scroll(1, "units")
        except Exception:
            pass

    def build_header(self, parent) -> None:
        self.header_frame = tk.Frame(parent, bg=BG)
        self.header_frame.grid(row=0, column=0, sticky="ew", pady=(0, 8))
        self.header_frame.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header_frame,
            text="TICKETMATRIXPLATFORM MISSION CONTROL V11",
            bg=BG,
            fg=FG,
            font=FONT_TITLE,
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header_frame,
            text="Multi-provider + multi-sport control panel | batch + provider refresh | global scroll | OPS / DB mini dashboard",
            bg=BG,
            fg=MUTED,
            font=FONT_SUBTITLE,
        ).grid(row=1, column=0, sticky="w", pady=(2, 3))

        tk.Label(
            self.header_frame,
            text=f"Project root: {PROJECT_ROOT}",
            bg=BG,
            fg=MUTED,
            font=FONT_SUBTITLE,
        ).grid(row=2, column=0, sticky="w")

        tk.Label(
            self.header_frame,
            text=f"Python exe: {PYTHON_EXE}",
            bg=BG,
            fg=MUTED,
            font=FONT_SUBTITLE,
        ).grid(row=3, column=0, sticky="w")

    def build_top_controls(self, parent) -> None:
        self.top = tk.Frame(parent, bg=BG)
        self.top.grid(row=1, column=0, sticky="nsew", pady=(0, 8))

        self.settings_frame_outer = ttk.LabelFrame(self.top, text="Batch Control", style="MM.TLabelframe", padding=4)
        self.navigator_frame_outer = ttk.LabelFrame(self.top, text="Project Navigator", style="MM.TLabelframe", padding=4)

        self.settings_frame_outer.grid(row=0, column=0, sticky="nsew", padx=(0, 6))
        self.navigator_frame_outer.grid(row=0, column=1, sticky="nsew")

        self.build_selection_area(self.settings_frame_outer)
        self.build_action_area(self.settings_frame_outer)
        self.build_provider_quick_run(self.settings_frame_outer)
        self.build_navigator(self.navigator_frame_outer)

        self.apply_top_layout(self.root.winfo_width())

    def apply_top_layout(self, width: int) -> None:
        target = "stack" if width < TOP_STACK_BREAKPOINT else "side"
        if self.current_top_layout == target:
            return

        self.current_top_layout = target

        for i in range(3):
            self.top.grid_columnconfigure(i, weight=0)

        if target == "side":
            self.settings_frame_outer.grid_forget()
            self.navigator_frame_outer.grid_forget()

            self.top.grid_columnconfigure(0, weight=4)
            self.top.grid_columnconfigure(1, weight=1)

            self.settings_frame_outer.grid(row=0, column=0, sticky="nsew", padx=(0, 6), pady=0)
            self.navigator_frame_outer.grid(row=0, column=1, sticky="nsew", padx=0, pady=0)
        else:
            self.settings_frame_outer.grid_forget()
            self.navigator_frame_outer.grid_forget()

            self.top.grid_columnconfigure(0, weight=1)

            self.settings_frame_outer.grid(row=0, column=0, sticky="nsew", padx=0, pady=(0, 6))
            self.navigator_frame_outer.grid(row=1, column=0, sticky="nsew", padx=0, pady=0)

    def build_selection_area(self, parent) -> None:
        self.selection_wrapper = tk.Frame(parent, bg=BG)
        self.selection_wrapper.pack(fill="x", pady=(0, 6))

        self.sports_frame = tk.Frame(self.selection_wrapper, bg=BG)
        self.entities_frame = tk.Frame(self.selection_wrapper, bg=BG)
        self.settings_frame = tk.Frame(self.selection_wrapper, bg=BG)

        self.build_sports_frame(self.sports_frame)
        self.build_entities_frame(self.entities_frame)
        self.build_settings_frame(self.settings_frame)

        self.apply_selection_layout(self.root.winfo_width())

    def apply_selection_layout(self, width: int) -> None:
        compact_stack = width < TOP_STACK_BREAKPOINT

        for child in (self.sports_frame, self.entities_frame, self.settings_frame):
            child.grid_forget()

        for i in range(3):
            self.selection_wrapper.grid_columnconfigure(i, weight=0)

        if compact_stack:
            self.selection_wrapper.grid_columnconfigure(0, weight=1)
            self.sports_frame.grid(row=0, column=0, padx=4, pady=3, sticky="nsew")
            self.entities_frame.grid(row=1, column=0, padx=4, pady=3, sticky="nsew")
            self.settings_frame.grid(row=2, column=0, padx=4, pady=3, sticky="nsew")
        else:
            self.selection_wrapper.grid_columnconfigure(0, weight=1)
            self.selection_wrapper.grid_columnconfigure(1, weight=1)
            self.selection_wrapper.grid_columnconfigure(2, weight=2)
            self.sports_frame.grid(row=0, column=0, padx=4, pady=3, sticky="nsew")
            self.entities_frame.grid(row=0, column=1, padx=4, pady=3, sticky="nsew")
            self.settings_frame.grid(row=0, column=2, padx=4, pady=3, sticky="nsew")

    def build_sports_frame(self, sports_frame) -> None:
        sports_frame.grid_rowconfigure(1, weight=1)
        sports_frame.grid_columnconfigure(0, weight=1)

        tk.Label(sports_frame, text="Sporty", bg=BG, fg=FG, font=FONT_LABEL).grid(row=0, column=0, sticky="w")

        list_wrap = tk.Frame(sports_frame, bg=BG)
        list_wrap.grid(row=1, column=0, sticky="nsew")
        list_wrap.grid_rowconfigure(0, weight=1)
        list_wrap.grid_columnconfigure(0, weight=1)

        self.sports_listbox = tk.Listbox(
            list_wrap,
            selectmode=tk.MULTIPLE,
            exportselection=False,
            height=10,
            bg=TEXTBOX_BG,
            fg=FG,
            selectbackground=ACCENT_3,
            selectforeground=FG,
            relief="flat",
            font=FONT_SMALL,
            activestyle="none",
        )
        self.sports_listbox.grid(row=0, column=0, sticky="nsew")
        self.sports_listbox.bind("<<ListboxSelect>>", self.on_sport_selection_changed)

        sports_scroll = ttk.Scrollbar(list_wrap, orient="vertical", command=self.sports_listbox.yview)
        sports_scroll.grid(row=0, column=1, sticky="ns")
        self.sports_listbox.configure(yscrollcommand=sports_scroll.set)

        sports_btns = tk.Frame(sports_frame, bg=BG)
        sports_btns.grid(row=2, column=0, sticky="ew", pady=5)
        sports_btns.grid_columnconfigure((0, 1, 2), weight=1)

        ttk.Button(
            sports_btns,
            text="Vybrat vše",
            style="Ghost.TButton",
            command=lambda: self.select_all(self.sports_listbox),
        ).grid(row=0, column=0, sticky="ew", padx=(0, 3))

        ttk.Button(
            sports_btns,
            text="Vymazat",
            style="Ghost.TButton",
            command=lambda: self.clear_selection(self.sports_listbox),
        ).grid(row=0, column=1, sticky="ew", padx=3)

        ttk.Button(
            sports_btns,
            text="Refresh DB",
            style="Ghost.TButton",
            command=self.refresh_all,
        ).grid(row=0, column=2, sticky="ew", padx=(3, 0))

    def build_entities_frame(self, entities_frame) -> None:
        entities_frame.grid_rowconfigure(1, weight=1)
        entities_frame.grid_columnconfigure(0, weight=1)

        tk.Label(entities_frame, text="Entity", bg=BG, fg=FG, font=FONT_LABEL).grid(row=0, column=0, sticky="w")

        list_wrap = tk.Frame(entities_frame, bg=BG)
        list_wrap.grid(row=1, column=0, sticky="nsew")
        list_wrap.grid_rowconfigure(0, weight=1)
        list_wrap.grid_columnconfigure(0, weight=1)

        self.entities_listbox = tk.Listbox(
            list_wrap,
            selectmode=tk.MULTIPLE,
            exportselection=False,
            height=10,
            bg=TEXTBOX_BG,
            fg=FG,
            selectbackground=ACCENT_3,
            selectforeground=FG,
            relief="flat",
            font=FONT_SMALL,
            activestyle="none",
        )
        self.entities_listbox.grid(row=0, column=0, sticky="nsew")
        self.entities_listbox.bind("<<ListboxSelect>>", lambda e: self.update_selection_dashboard())

        entities_scroll = ttk.Scrollbar(list_wrap, orient="vertical", command=self.entities_listbox.yview)
        entities_scroll.grid(row=0, column=1, sticky="ns")
        self.entities_listbox.configure(yscrollcommand=entities_scroll.set)

        entities_btns = tk.Frame(entities_frame, bg=BG)
        entities_btns.grid(row=2, column=0, sticky="ew", pady=5)
        entities_btns.grid_columnconfigure((0, 1), weight=1)

        ttk.Button(
            entities_btns,
            text="Vybrat vše",
            style="Ghost.TButton",
            command=lambda: self.select_all(self.entities_listbox),
        ).grid(row=0, column=0, sticky="ew", padx=(0, 3))

        ttk.Button(
            entities_btns,
            text="Vymazat",
            style="Ghost.TButton",
            command=lambda: self.clear_selection(self.entities_listbox),
        ).grid(row=0, column=1, sticky="ew", padx=(3, 0))

    def build_settings_frame(self, settings_frame) -> None:
        settings_frame.grid_columnconfigure(1, weight=1)

        tk.Label(settings_frame, text="Nastavení batch běhu", bg=BG, fg=FG, font=FONT_LABEL).grid(
            row=0, column=0, columnspan=2, sticky="w", pady=(0, 5)
        )

        tk.Label(settings_frame, text="Run group", bg=BG, fg=FG, font=FONT_TEXT).grid(row=1, column=0, sticky="w", pady=2)
        self.run_group_var = tk.StringVar()
        self.run_group_combo = ttk.Combobox(settings_frame, textvariable=self.run_group_var, state="readonly")
        self.run_group_combo.grid(row=1, column=1, sticky="ew", pady=2)

        tk.Label(settings_frame, text="Entity profil", bg=BG, fg=FG, font=FONT_TEXT).grid(row=2, column=0, sticky="w", pady=2)
        self.profile_var = tk.StringVar(value="custom")
        self.profile_combo = ttk.Combobox(
            settings_frame,
            textvariable=self.profile_var,
            state="readonly",
            values=list(ENTITY_PROFILE_MAP.keys()),
        )
        self.profile_combo.grid(row=2, column=1, sticky="ew", pady=2)
        self.profile_combo.bind("<<ComboboxSelected>>", self.on_profile_changed)

        tk.Label(settings_frame, text="Provider mode", bg=BG, fg=FG, font=FONT_TEXT).grid(row=3, column=0, sticky="w", pady=2)
        self.provider_mode_var = tk.StringVar(value="auto")
        provider_mode_combo = ttk.Combobox(
            settings_frame,
            textvariable=self.provider_mode_var,
            state="readonly",
            values=["auto", "manual"],
        )
        provider_mode_combo.grid(row=3, column=1, sticky="ew", pady=2)
        provider_mode_combo.bind("<<ComboboxSelected>>", self.on_provider_mode_changed)

        tk.Label(settings_frame, text="Manual provider", bg=BG, fg=FG, font=FONT_TEXT).grid(row=4, column=0, sticky="w", pady=2)
        self.manual_provider_var = tk.StringVar()
        self.manual_provider_entry = ttk.Entry(settings_frame, textvariable=self.manual_provider_var)
        self.manual_provider_entry.grid(row=4, column=1, sticky="ew", pady=2)

        tk.Label(settings_frame, text="Limit", bg=BG, fg=FG, font=FONT_TEXT).grid(row=5, column=0, sticky="w", pady=2)
        self.limit_var = tk.StringVar(value="5")
        ttk.Entry(settings_frame, textvariable=self.limit_var).grid(row=5, column=1, sticky="ew", pady=2)

        tk.Label(settings_frame, text="Max workers", bg=BG, fg=FG, font=FONT_TEXT).grid(row=6, column=0, sticky="w", pady=2)
        self.max_workers_var = tk.StringVar(value="3")
        ttk.Entry(settings_frame, textvariable=self.max_workers_var).grid(row=6, column=1, sticky="ew", pady=2)

        tk.Label(settings_frame, text="Timeout sec", bg=BG, fg=FG, font=FONT_TEXT).grid(row=7, column=0, sticky="w", pady=2)
        self.timeout_sec_var = tk.StringVar(value="300")
        ttk.Entry(settings_frame, textvariable=self.timeout_sec_var).grid(row=7, column=1, sticky="ew", pady=2)

        self.on_provider_mode_changed()

    def build_action_area(self, parent) -> None:
        action_frame = tk.Frame(parent, bg=BG)
        action_frame.pack(fill="x", pady=(2, 0))

        ttk.Button(
            action_frame,
            text="Spustit batch kombinace",
            style="Accent.TButton",
            command=self.run_batch_combinations_thread,
        ).pack(side="left", padx=4, pady=4)

        ttk.Button(
            action_frame,
            text="Spustit ingest cycle (planner)",
            style="Ghost.TButton",
            command=self.run_scheduler_thread,
        ).pack(side="left", padx=4, pady=4)

        ttk.Button(
            action_frame,
            text="Spustit players pipeline",
            style="Ghost.TButton",
            command=self.run_players_pipeline_thread,
        ).pack(side="left", padx=4, pady=4)

        ttk.Button(
            action_frame,
            text="Refresh sporty + entity + OPS",
            style="Ghost.TButton",
            command=self.refresh_all,
        ).pack(side="left", padx=4, pady=4)

        ttk.Button(
            action_frame,
            text="Vyčistit log",
            style="Ghost.TButton",
            command=self.clear_logs,
        ).pack(side="left", padx=4, pady=4)

    def build_navigator(self, parent) -> None:
        for i in range(2):
            parent.grid_columnconfigure(i, weight=1)

        nav_row = 0
        nav_col = 0
        for name, path in NAV_PATHS.items():
            ttk.Button(
                parent,
                text=name,
                style="Ghost.TButton",
                command=lambda p=path: open_path(p),
            ).grid(row=nav_row, column=nav_col, padx=3, pady=3, sticky="ew")

            nav_col += 1
            if nav_col >= 2:
                nav_col = 0
                nav_row += 1

    def build_provider_quick_run(self, parent) -> None:
        quick_wrap = ttk.LabelFrame(
            parent,
            text="Provider Quick Run",
            style="MM.TLabelframe",
            padding=4
        )
        quick_wrap.pack(fill="x", pady=(4, 0))

        row = tk.Frame(quick_wrap, bg=BG)
        row.pack(fill="x")

        ttk.Button(
            row,
            text="THEODDS",
            style="Ghost.TButton",
            command=lambda: self.run_provider_update_thread("THEODDS"),
        ).pack(side="left", padx=4, pady=4)

        ttk.Button(
            row,
            text="FOOTBALL_DATA",
            style="Ghost.TButton",
            command=lambda: self.run_provider_update_thread("FOOTBALL_DATA"),
        ).pack(side="left", padx=4, pady=4)

        ttk.Button(
            row,
            text="DAILY FULL REFRESH",
            style="Accent.TButton",
            command=self.run_daily_refresh_thread,
        ).pack(side="left", padx=6, pady=4)

    def build_selection_dashboard(self, parent) -> None:
        dashboard = tk.Frame(parent, bg=BG)
        dashboard.grid(row=2, column=0, sticky="ew", pady=(0, 6))
        for i in range(6):
            dashboard.grid_columnconfigure(i, weight=1)

        self.card_sports = MetricCard(dashboard, "Sporty", "0", "načteno z DB", ACCENT)
        self.card_sports.grid(row=0, column=0, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_entities = MetricCard(dashboard, "Entity", "0", "načteno z DB", ACCENT_2)
        self.card_entities.grid(row=0, column=1, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_run_groups = MetricCard(dashboard, "Run groups", "0", "načteno z DB", ACCENT)
        self.card_run_groups.grid(row=0, column=2, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_status = MetricCard(dashboard, "Stav panelu", "READY", "čeká na akci", GOOD)
        self.card_status.grid(row=0, column=3, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_theodds = MetricCard(dashboard, "THEODDS", "-", "čeká na refresh", ACCENT)
        self.card_theodds.grid(row=0, column=4, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_football_data = MetricCard(dashboard, "FOOTBALL_DATA", "-", "čeká na refresh", ACCENT_2)
        self.card_football_data.grid(row=0, column=5, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        progress_row = tk.Frame(parent, bg=BG)
        progress_row.grid(row=3, column=0, sticky="ew", pady=(0, 6))
        for i in range(3):
            progress_row.grid_columnconfigure(i, weight=1)

        self.bar_sports = ProgressBarCard(progress_row, "SPORT COVERAGE", ACCENT)
        self.bar_sports.grid(row=0, column=0, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.bar_entities = ProgressBarCard(progress_row, "ENTITY COVERAGE", ACCENT_3)
        self.bar_entities.grid(row=0, column=1, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.bar_selection = ProgressBarCard(progress_row, "CURRENT SELECTION", ACCENT_2)
        self.bar_selection.grid(row=0, column=2, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

    def build_ops_dashboard(self, parent) -> None:
        ops_wrap = tk.Frame(parent, bg=BG)
        ops_wrap.grid(row=4, column=0, sticky="ew", pady=(0, 6))

        for i in range(4):
            ops_wrap.grid_columnconfigure(i, weight=1)

        self.card_matches = MetricCard(ops_wrap, "Zápasy", "-", "public.matches", ACCENT)
        self.card_matches.grid(row=0, column=0, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_leagues = MetricCard(ops_wrap, "Ligy", "-", "public.leagues", ACCENT_2)
        self.card_leagues.grid(row=0, column=1, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_teams = MetricCard(ops_wrap, "Týmy", "-", "public.teams", ACCENT)
        self.card_teams.grid(row=0, column=2, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_players = MetricCard(ops_wrap, "Hráči", "-", "public.players", ACCENT_2)
        self.card_players.grid(row=0, column=3, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_planner_pending = MetricCard(ops_wrap, "Planner pending", "-", "ops.ingest_planner", WARN)
        self.card_planner_pending.grid(row=1, column=0, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_planner_running = MetricCard(ops_wrap, "Planner running", "-", "ops.ingest_planner", WARN)
        self.card_planner_running.grid(row=1, column=1, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_last_job = MetricCard(ops_wrap, "Poslední job", "-", "ops.job_runs", GOOD)
        self.card_last_job.grid(row=1, column=2, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.card_live_status = MetricCard(ops_wrap, "Live stav", "IDLE", "čeká na spuštění", GOOD)
        self.card_live_status.grid(row=1, column=3, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.bar_db_health = ProgressBarCard(ops_wrap, "DB HEALTH", GOOD)
        self.bar_db_health.grid(row=2, column=0, columnspan=2, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

        self.bar_ops_health = ProgressBarCard(ops_wrap, "OPS HEALTH", WARN)
        self.bar_ops_health.grid(row=2, column=2, columnspan=2, sticky="nsew", padx=PAD_CARD_X, pady=PAD_CARD_Y)

    def build_bottom_area(self, parent) -> None:
        self.bottom_container = tk.Frame(parent, bg=BG)
        self.bottom_container.grid(row=5, column=0, sticky="nsew", pady=(0, 4))
        parent.grid_rowconfigure(5, weight=1)

        self.bottom_left = tk.Frame(self.bottom_container, bg=BG)
        self.bottom_center = tk.Frame(self.bottom_container, bg=BG)
        self.bottom_right = tk.Frame(self.bottom_container, bg=BG)

        self.build_snapshot_area(self.bottom_left)
        self.build_provider_diagnostics_area(self.bottom_center)
        self.build_log_area(self.bottom_right)

        self.apply_bottom_layout(self.root.winfo_width())

    def apply_bottom_layout(self, width: int) -> None:
        target = "stack" if width < BOTTOM_STACK_BREAKPOINT else "side"
        if self.current_bottom_layout == target:
            return

        self.current_bottom_layout = target

        self.bottom_left.grid_forget()
        self.bottom_center.grid_forget()
        self.bottom_right.grid_forget()

        for i in range(3):
            self.bottom_container.grid_columnconfigure(i, weight=0)

        if target == "side":
            self.bottom_container.grid_columnconfigure(0, weight=1)
            self.bottom_container.grid_columnconfigure(1, weight=1)
            self.bottom_container.grid_columnconfigure(2, weight=2)

            self.bottom_left.grid(row=0, column=0, sticky="nsew", padx=(0, 4), pady=0)
            self.bottom_center.grid(row=0, column=1, sticky="nsew", padx=4, pady=0)
            self.bottom_right.grid(row=0, column=2, sticky="nsew", padx=(4, 0), pady=0)
        else:
            self.bottom_container.grid_columnconfigure(0, weight=1)
            self.bottom_left.grid(row=0, column=0, sticky="nsew", padx=0, pady=(0, 6))
            self.bottom_center.grid(row=1, column=0, sticky="nsew", padx=0, pady=(0, 6))
            self.bottom_right.grid(row=2, column=0, sticky="nsew", padx=0, pady=0)

    def on_root_resize(self, event=None) -> None:
        width = self.root.winfo_width()
        self.apply_top_layout(width)
        self.apply_selection_layout(width)
        self.apply_bottom_layout(width)
        self._update_scroll_region()

    def _snapshot_order(self) -> list[tuple[str, str]]:
        return [
            ("matches", "public.matches"),
            ("leagues", "public.leagues"),
            ("teams", "public.teams"),
            ("players", "public.players"),
            ("player_season_statistics", "public.player_season_statistics"),
            ("stg_player_season_stats", "staging.stg_provider_player_season_stats"),
            ("stg_provider_fixtures", "staging.stg_provider_fixtures"),
            ("stg_provider_teams", "staging.stg_provider_teams"),
            ("planner_pending_ready", "ops.ingest_planner pending/ready"),
            ("planner_running", "ops.ingest_planner running"),
            ("job_runs", "ops.job_runs"),
            ("api_import_runs", "public.api_import_runs"),
            ("api_raw_payloads", "public.api_raw_payloads"),
            ("odds", "public.odds"),
            ("bookmakers", "public.bookmakers"),
            ("theodds_runs", "api_import_runs source=theodds"),
            ("football_data_runs", "api_import_runs source=football_data"),
        ]

    def build_snapshot_area(self, parent) -> None:
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        title = tk.Frame(parent, bg=BG)
        title.grid(row=0, column=0, sticky="ew", pady=(0, 6))
        title.grid_columnconfigure(0, weight=1)

        tk.Label(
            title,
            text="Porovnání běhu",
            bg=BG,
            fg=ACCENT_2,
            font=FONT_LABEL,
        ).grid(row=0, column=0, sticky="w")

        table_wrap = ttk.LabelFrame(parent, text="Snapshot před / po / rozdíl", style="MM.TLabelframe", padding=4)
        table_wrap.grid(row=1, column=0, sticky="nsew")
        table_wrap.grid_rowconfigure(0, weight=1)
        table_wrap.grid_columnconfigure(0, weight=1)

        columns = ("metric", "before", "after", "diff")
        self.snapshot_table = ttk.Treeview(table_wrap, columns=columns, show="headings", height=10)
        self.snapshot_table.grid(row=0, column=0, sticky="nsew")

        self.snapshot_table.heading("metric", text="Metrika")
        self.snapshot_table.heading("before", text="Před během")
        self.snapshot_table.heading("after", text="Po běhu")
        self.snapshot_table.heading("diff", text="Rozdíl")

        self.snapshot_table.column("metric", width=240, anchor="w")
        self.snapshot_table.column("before", width=90, anchor="center")
        self.snapshot_table.column("after", width=90, anchor="center")
        self.snapshot_table.column("diff", width=90, anchor="center")

        vsb = ttk.Scrollbar(table_wrap, orient="vertical", command=self.snapshot_table.yview)
        vsb.grid(row=0, column=1, sticky="ns")
        self.snapshot_table.configure(yscrollcommand=vsb.set)

        self.snapshot_table.tag_configure("changed", background="#3C245B", foreground=FG)
        self.snapshot_table.tag_configure("same", background=TEXTBOX_BG, foreground=FG)
        self.snapshot_table.tag_configure("negative", background="#4B1F2F", foreground=FG)

    def build_provider_diagnostics_area(self, parent) -> None:
        parent.grid_rowconfigure(0, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        wrap = ttk.LabelFrame(parent, text="Provider Diagnostics", style="MM.TLabelframe", padding=4)
        wrap.grid(row=0, column=0, sticky="nsew")
        wrap.grid_rowconfigure(1, weight=1)
        wrap.grid_columnconfigure(0, weight=1)

        tk.Label(
            wrap,
            text="NO TEAM MATCH / NO MATCH ID / provider diagnostika",
            bg=BG,
            fg=MUTED,
            font=FONT_SMALL,
        ).grid(row=0, column=0, sticky="w", pady=(0, 4))

        self.provider_diag_text = tk.Text(
            wrap,
            wrap="word",
            height=12,
            font=FONT_MONO,
            bg=TEXTBOX_BG,
            fg=FG,
            insertbackground=FG,
            relief="flat",
            padx=6,
            pady=6,
        )
        self.provider_diag_text.grid(row=1, column=0, sticky="nsew")

        self.provider_diag_text.insert("1.0", "Zatím bez diagnostiky provider matching.\n")

    def reset_provider_diagnostics(self) -> None:
        self.provider_diag_stats = {
            "provider": "-",
            "no_team_match": 0,
            "no_match_id": 0,
            "inserted_odds": 0,
            "last_lines": [],
        }

        if hasattr(self, "provider_diag_text"):
            self.provider_diag_text.delete("1.0", "end")
            self.provider_diag_text.insert("1.0", "Diagnostika resetována.\n")

    def render_provider_diagnostics(self, title: str = "Provider Diagnostics") -> None:
        if not hasattr(self, "provider_diag_text"):
            return

        stats = getattr(self, "provider_diag_stats", {
            "provider": "-",
            "no_team_match": 0,
            "no_match_id": 0,
            "inserted_odds": 0,
            "last_lines": [],
        })

        self.provider_diag_text.delete("1.0", "end")
        self.provider_diag_text.insert("end", f"{title}\n")
        self.provider_diag_text.insert("end", f"Provider: {stats.get('provider', '-')}\n")
        self.provider_diag_text.insert("end", "=" * 60 + "\n")
        self.provider_diag_text.insert("end", f"NO TEAM MATCH : {stats['no_team_match']}\n")
        self.provider_diag_text.insert("end", f"NO MATCH ID   : {stats['no_match_id']}\n")
        self.provider_diag_text.insert("end", f"INSERTED ODDS : {stats['inserted_odds']}\n")
        self.provider_diag_text.insert("end", "-" * 60 + "\n")

        last_lines = stats.get("last_lines", [])
        if last_lines:
            self.provider_diag_text.insert("end", "Poslední zachycené řádky:\n")
            for line in last_lines[-12:]:
                self.provider_diag_text.insert("end", f"{line}\n")
        else:
            self.provider_diag_text.insert("end", "Zatím bez zachycených diagnostických řádků.\n")

    def parse_provider_diagnostic_line(self, line: str) -> None:
        if not hasattr(self, "provider_diag_stats"):
            self.reset_provider_diagnostics()

        text = (line or "").strip()
        if not text:
            return

        provider = str(self.provider_diag_stats.get("provider", "") or "").upper()

        # Detailní matching diagnostiku teď držíme hlavně pro THEODDS
        if provider != "THEODDS":
            if len(self.provider_diag_stats["last_lines"]) < 20:
                if "run_id=" in text or "RUN_ID:" in text or "RATE LIMIT" in text or "OK run_id=" in text:
                    self.provider_diag_stats["last_lines"].append(text)
            return    

        if "NO TEAM MATCH:" in text:
            self.provider_diag_stats["no_team_match"] += 1
            self.provider_diag_stats["last_lines"].append(text)

        elif "NO MATCH ID:" in text:
            self.provider_diag_stats["no_match_id"] += 1
            self.provider_diag_stats["last_lines"].append(text)

        elif "Inserted odds:" in text:
            self.provider_diag_stats["last_lines"].append(text)
            try:
                # očekává např. "Inserted odds: 25 (league: ...)"
                part = text.split("Inserted odds:", 1)[1].strip()
                value = part.split(" ", 1)[0].strip()
                self.provider_diag_stats["inserted_odds"] += int(value)
            except Exception:
                pass

        # držíme jen posledních 50 řádků
        if len(self.provider_diag_stats["last_lines"]) > 50:
            self.provider_diag_stats["last_lines"] = self.provider_diag_stats["last_lines"][-50:]

    def build_log_area(self, parent) -> None:
        parent.grid_rowconfigure(0, weight=0)
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        live_wrap = ttk.LabelFrame(parent, text="Live stav běhu", style="MM.TLabelframe", padding=3)
        live_wrap.grid(row=0, column=0, sticky="ew", pady=(0, 5))
        live_wrap.grid_columnconfigure(0, weight=1)

        self.run_info_text = tk.Text(
            live_wrap,
            height=5,
            wrap="word",
            font=FONT_MONO,
            bg=TEXTBOX_BG,
            fg=FG,
            insertbackground=FG,
            relief="flat",
            padx=6,
            pady=6,
        )
        self.run_info_text.grid(row=0, column=0, sticky="ew")

        log_wrap = ttk.LabelFrame(parent, text="Log běhu / průběh stahování", style="MM.TLabelframe", padding=5)
        log_wrap.grid(row=1, column=0, sticky="nsew")
        log_wrap.grid_rowconfigure(0, weight=1)
        log_wrap.grid_columnconfigure(0, weight=1)

        self.log_text = tk.Text(
            log_wrap,
            wrap="none",
            font=FONT_MONO,
            bg=TEXTBOX_BG,
            fg=FG,
            insertbackground=FG,
            relief="flat",
            padx=6,
            pady=6,
        )
        self.log_text.grid(row=0, column=0, sticky="nsew")

        yscroll = ttk.Scrollbar(log_wrap, orient="vertical", command=self.log_text.yview)
        yscroll.grid(row=0, column=1, sticky="ns")

        xscroll = ttk.Scrollbar(log_wrap, orient="horizontal", command=self.log_text.xview)
        xscroll.grid(row=1, column=0, sticky="ew")

        self.log_text.configure(yscrollcommand=yscroll.set, xscrollcommand=xscroll.set)

    # --------------------------------------------------------
    # Render helpers
    # --------------------------------------------------------
    def render_snapshot_table(self, before: dict[str, int], after: dict[str, int]) -> None:
        if not hasattr(self, "snapshot_table"):
            return

        self.snapshot_table.delete(*self.snapshot_table.get_children())
        for key, label in self._snapshot_order():
            b = int(before.get(key, 0) or 0)
            a = int(after.get(key, 0) or 0)
            d = a - b
            diff_text = f"{d:+d}"

            tag = "same"
            if d > 0:
                tag = "changed"
            elif d < 0:
                tag = "negative"

            self.snapshot_table.insert("", "end", values=(label, b, a, diff_text), tags=(tag,))

    def render_snapshot_before(self, snapshot: dict[str, int]) -> None:
        self.render_snapshot_table(snapshot, self.after_snapshot if self.after_snapshot else {})

    def render_snapshot_after(self, snapshot: dict[str, int]) -> None:
        self.render_snapshot_table(self.before_snapshot if self.before_snapshot else {}, snapshot)

    def render_snapshot_diff(self, before: dict[str, int], after: dict[str, int]) -> None:
        self.render_snapshot_table(before, after)

    def log_provider_snapshot_summary(self, before: dict[str, int], after: dict[str, int], label: str) -> None:
        tracked_keys = [
            ("matches", "matches"),
            ("odds", "odds"),
            ("api_raw_payloads", "api_raw_payloads"),
            ("api_import_runs", "api_import_runs"),
            ("theodds_runs", "theodds_runs"),
            ("football_data_runs", "football_data_runs"),
        ]

        self.log_write("-" * 70)
        self.log_write(f"DB SNAPSHOT SUMMARY: {label}")

        for key, title in tracked_keys:
            b = int(before.get(key, 0) or 0)
            a = int(after.get(key, 0) or 0)
            d = a - b
            self.log_write(f"{title}: {b} -> {a} ({d:+d})")

        self.log_write("-" * 70)

    def render_run_info(self) -> None:
        self.run_info_text.delete("1.0", "end")

        if not self.last_run_info:
            self.run_info_text.insert("1.0", "Zatím nebyl spuštěn žádný běh.")
            return

        lines = [
            f"Runner         : {self.last_run_info.get('runner', '-')}",
            f"Start          : {self.last_run_info.get('start', '-')}",
            f"Konec          : {self.last_run_info.get('end', '-')}",
            f"Trvání         : {self.last_run_info.get('duration', '-')}",
            f"Return code    : {self.last_run_info.get('return_code', '-')}",
            f"Sporty         : {self.last_run_info.get('sports', '-')}",
            f"Entity         : {self.last_run_info.get('entities', '-')}",
            f"Run group      : {self.last_run_info.get('run_group', '-')}",
            f"Stav           : {self.last_run_info.get('status', '-')}",
            f"Krok           : {self.last_run_info.get('step_info', '-')}",
        ]
        self.run_info_text.insert("1.0", "\n".join(lines))

    # --------------------------------------------------------
    # UI helpers
    # --------------------------------------------------------
    def reload_sports_listbox(self) -> None:
        current_selection = self.get_selected_sports() if hasattr(self, "sports_listbox") else []
        self.sports_listbox.delete(0, tk.END)

        enabled_target_sports = getattr(self, "enabled_target_sports", set())

        display_values = []
        for sport in self.db_sport_options:
            base_label = SPORT_LABELS.get(sport, sport)
            if sport not in enabled_target_sports:
                base_label = f"{base_label} [NO TARGETS]"
            display_values.append(base_label)

        for value in display_values:
            self.sports_listbox.insert(tk.END, value)

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
        self.update_selection_dashboard()

    def clear_selection(self, listbox: tk.Listbox) -> None:
        listbox.selection_clear(0, tk.END)
        self.update_selection_dashboard()

    def clear_logs(self) -> None:
        self.log_text.delete("1.0", "end")
        self.log_write("Log vyčištěn.")

    def log_write(self, message: str) -> None:
        ts = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{ts}] {message}\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()

    def update_selection_dashboard(self) -> None:
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
            f"vybráno sporty {sports_selected}/{sports_total}, entity {entities_selected}/{entities_total}",
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
            self.update_selection_dashboard()
            return

        wanted = ENTITY_PROFILE_MAP.get(profile, [])
        self.entities_listbox.selection_clear(0, tk.END)

        for idx, entity in enumerate(self.db_entity_options):
            if entity in wanted:
                self.entities_listbox.selection_set(idx)

        self.log_write(f"Použit profil entit: {profile}")
        self.update_selection_dashboard()

    def refresh_provider_status_cards(self) -> None:
        try:
            rows = self.load_last_provider_runs()

            theodds = rows.get("theodds")
            football_data = rows.get("football_data")

            if theodds:
                status = str(theodds.get("status") or "-").upper()
                color = GOOD if status == "OK" else (WARN if status == "RUNNING" else BAD)
                started = theodds.get("started_at")
                subtitle = f"last: {started}" if started else "poslední běh"
                self.card_theodds.update_card(status, subtitle, color)
            else:
                self.card_theodds.update_card("-", "bez runu", MUTED)

            if football_data:
                status = str(football_data.get("status") or "-").upper()
                color = GOOD if status == "OK" else (WARN if status == "RUNNING" else BAD)
                started = football_data.get("started_at")
                subtitle = f"last: {started}" if started else "poslední běh"
                self.card_football_data.update_card(status, subtitle, color)
            else:
                self.card_football_data.update_card("-", "bez runu", MUTED)

        except Exception as e:
            self.card_theodds.update_card("ERR", "provider status error", BAD)
            self.card_football_data.update_card("ERR", "provider status error", BAD)
            self.log_write(f"Provider status warning: {e}")

    def refresh_all(self) -> None:
        self.refresh_dynamic_options()
        self.refresh_ops_dashboard()
        self.refresh_provider_status_cards()
        self.update_selection_dashboard()
        self.log_write("Refresh sportů, entit, run_group a OPS/DB dashboardu dokončen.")

    # --------------------------------------------------------
    # Run state helpers
    # --------------------------------------------------------
    def set_live_status(self, value: str, subtitle: str, color: str) -> None:
        self.card_live_status.update_card(value, subtitle, color)

    def mark_run_started(self, runner_name: str, sports: str, entities: str, run_group: str) -> None:
        self.current_runner_name = runner_name
        self.last_run_info = {
            "runner": runner_name,
            "start": datetime.now().strftime("%d.%m.%Y %H:%M:%S"),
            "end": "-",
            "duration": "-",
            "return_code": "-",
            "sports": sports or "-",
            "entities": entities or "-",
            "run_group": run_group or "-",
            "status": "RUNNING",
            "step_info": "-",
        }
        self.set_live_status("RUNNING", runner_name, WARN)
        self.render_run_info()

    def mark_run_finished(self, return_code: int, started_at: datetime) -> None:
        ended_at = datetime.now()
        duration = ended_at - started_at

        self.last_run_info["end"] = ended_at.strftime("%d.%m.%Y %H:%M:%S")
        self.last_run_info["duration"] = str(duration).split(".")[0]
        self.last_run_info["return_code"] = str(return_code)
        self.last_run_info["status"] = "OK" if return_code == 0 else "ERROR"

        if return_code == 0:
            self.set_live_status("OK", self.current_runner_name or "dokončeno", GOOD)
        else:
            self.set_live_status("ERROR", self.current_runner_name or "chyba", BAD)

        self.render_run_info()

    def set_run_progress(self, current_step: int, total_steps: int, label: str) -> None:
        self.current_step = current_step
        self.total_steps = total_steps
        step_info = f"{current_step}/{total_steps} | {label}" if total_steps > 0 else label

        if self.last_run_info:
            self.last_run_info["step_info"] = step_info
            self.render_run_info()

    # --------------------------------------------------------
    # Commands
    # --------------------------------------------------------
    def get_selected_sports(self) -> list[str]:
        selected = [self.sports_listbox.get(i) for i in self.sports_listbox.curselection()]
        cleaned = [item.replace(" [NO TARGETS]", "") for item in selected]
        reverse_labels = {v: k for k, v in SPORT_LABELS.items()}
        return [reverse_labels.get(item, item) for item in cleaned]

    def on_sport_selection_changed(self, event=None) -> None:
        self.refresh_dynamic_options(initial=True)

    def get_selected_entities(self) -> list[str]:
        return [self.entities_listbox.get(i) for i in self.entities_listbox.curselection()]

    def run_provider_update_thread(self, provider_key: str) -> None:
        thread = threading.Thread(
            target=self.run_provider_update,
            args=(provider_key,),
            daemon=True
        )
        thread.start()

    def run_provider_update(self, provider_key: str) -> None:
        cmd = PROVIDER_UPDATE_COMMANDS.get(provider_key)

        if not cmd:
            self.log_write(f"Neznámý provider: {provider_key}")
            return

        provider_label = PROVIDER_LABELS.get(provider_key, provider_key)

        self.log_write("=" * 70)
        self.log_write(f"PROVIDER UPDATE START: {provider_label}")
        self.log_write(f"Provider key: {provider_key}")
        self.log_write("CMD: " + " ".join(cmd))
        self.log_write("=" * 70)

        self.run_command_stream(
            cmd=cmd,
            runner_name=f"{provider_key} update",
            total_steps=1,
            step_label=provider_key,
            sports="-",
            entities=provider_key,
            run_group="-",
            provider_label=provider_key,
        )

        self.refresh_provider_status_cards()

        if self.before_snapshot and self.after_snapshot:
            self.log_provider_snapshot_summary(
            self.before_snapshot,
            self.after_snapshot,
            f"{provider_key} update"
        )

    def run_daily_refresh_thread(self) -> None:
        thread = threading.Thread(
            target=self.run_daily_refresh,
            daemon=True
        )
        thread.start()


    def run_daily_refresh(self) -> None:
        steps = [
            ("FOOTBALL_DATA", PROVIDER_UPDATE_COMMANDS["FOOTBALL_DATA"]),
            ("THEODDS", PROVIDER_UPDATE_COMMANDS["THEODDS"]),
        ]

        self.log_write("=" * 70)
        self.log_write("DAILY FULL REFRESH START")
        self.log_write("Pořadí kroků: FOOTBALL_DATA -> THEODDS")
        self.log_write("=" * 70)

        for idx, (name, cmd) in enumerate(steps, start=1):
            self.set_run_progress(idx, len(steps), name)

            self.log_write(f"[{idx}/{len(steps)}] STEP START: {name}")
            self.log_write("CMD: " + " ".join(cmd))
            rc = self.run_single_process(cmd, provider_label=name)
            self.refresh_provider_status_cards()

            after_snapshot = self.collect_db_snapshot()
            self.log_provider_snapshot_summary(
                self.before_snapshot if self.before_snapshot else {},
                after_snapshot,
                f"daily refresh step {name}"
            )
            self.before_snapshot = after_snapshot

            if rc != 0:
                self.log_write(f"CHYBA v kroku {name}")
                return

        self.log_write("=" * 70)
        self.log_write("DAILY FULL REFRESH DONE")
        self.log_write("=" * 70)

    def resolve_provider_for_sport(self, sport: str) -> str:
        if self.provider_mode_var.get() == "manual":
            provider = self.manual_provider_var.get().strip()
            return provider if provider else DEFAULT_PROVIDER_BY_SPORT.get(sport, f"api_{sport.lower()}")
        return DEFAULT_PROVIDER_BY_SPORT.get(sport, f"api_{sport.lower()}")

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
        selected_sports = self.get_selected_sports()
        selected_entities = self.get_selected_entities()
        run_group = self.run_group_var.get().strip()
        limit = self.limit_var.get().strip() or "10"
        timeout_sec = self.timeout_sec_var.get().strip() or "300"

        cmd = [
            PYTHON_EXE,
            SCHEDULER_RUNNER,
            "--limit", limit,
            "--timeout-sec", timeout_sec,
        ]

        # vždy nastav provider podle sportu
        if selected_sports:
            provider = self.resolve_provider_for_sport(selected_sports[0])
            cmd += ["--provider", provider]

        # sport
        if selected_sports:
            cmd += ["--sport", selected_sports[0]]

        # entity – POVINNĚ
        if selected_entities:
            cmd += ["--entity", selected_entities[0]]
        else:
            self.log_write("CHYBA: není vybraná entity")
            return

        # Run group
        if run_group:
            cmd += ["--run-group", run_group]

        self.log_write("Spouštím scheduler:")
        self.log_write(" ".join(cmd))

        self.run_command_stream(
            cmd=cmd,
            runner_name="ingest cycle V3",
            total_steps=1,
            step_label="scheduler run",
            sports=", ".join(selected_sports) or "-",
            entities=", ".join(selected_entities) or "-",
            run_group=run_group or "-",
        )

    def run_players_pipeline(self) -> None:
        cmd = [PYTHON_EXE, PLAYERS_PIPELINE_RUNNER]
        self.log_write("Spouštím players pipeline full:")
        self.log_write(" ".join(cmd))
        self.run_command_stream(
            cmd=cmd,
            runner_name="players pipeline full",
            total_steps=1,
            step_label="players pipeline run",
            sports="-",
            entities="players",
            run_group="-",
        )

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

        combos = []
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
                combos.append((sport, entity, provider, cmd))

        self.log_write(f"Počet kombinací ke spuštění: {len(combos)}")

        self.before_snapshot = self.collect_db_snapshot()
        self.render_snapshot_before(self.before_snapshot)
        self.after_snapshot = {}
        self.render_snapshot_after({})
        self.render_snapshot_diff({}, {})

        start_ts = datetime.now()
        self.mark_run_started(
            runner_name="batch kombinace",
            sports=", ".join(selected_sports),
            entities=", ".join(selected_entities),
            run_group=run_group or "-",
        )

        self.is_running = True
        self.update_selection_dashboard()

        return_code = 0
        try:
            total = len(combos)

            for idx, (sport, entity, provider, cmd) in enumerate(combos, start=1):
                label = f"{sport} / {entity} / {provider}"
                self.set_run_progress(idx, total, label)
                self.set_live_status("RUNNING", label, WARN)

                self.log_write("=" * 70)
                self.log_write(f"Spouštím batch: sport={sport}, entity={entity}, provider={provider}")
                self.log_write("CMD: " + " ".join(cmd))

                rc = self.run_single_process(cmd)
                if rc != 0:
                    return_code = rc
                    break

            self.after_snapshot = self.collect_db_snapshot()
            self.render_snapshot_after(self.after_snapshot)
            self.render_snapshot_diff(self.before_snapshot, self.after_snapshot)

        except Exception as e:
            return_code = 1
            self.log_write(f"CHYBA při batch kombinacích: {e}")

        finally:
            self.is_running = False
            self.update_selection_dashboard()
            self.refresh_ops_dashboard()
            self.mark_run_finished(return_code, start_ts)

    def run_single_process(self, cmd: list[str], provider_label: str = "-") -> int:
        self.reset_provider_diagnostics()
        self.provider_diag_stats["provider"] = provider_label
        self.render_provider_diagnostics("Provider Diagnostics - RUN START")

        try:
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                universal_newlines=True,
                cwd=str(PROJECT_ROOT),
            )

            assert process.stdout is not None
            for line in process.stdout:
                clean_line = line.rstrip()
                self.log_write(clean_line)
                self.parse_provider_diagnostic_line(clean_line)
                self.render_provider_diagnostics("Provider Diagnostics - LIVE")

            process.wait()
            if process.returncode == 0:
                self.log_write("Hotovo OK.")
            else:
                self.log_write(f"Proces skončil s chybovým kódem: {process.returncode}")

            self.render_provider_diagnostics("Provider Diagnostics - FINISHED")
            return process.returncode

        except Exception as e:
            self.log_write(f"CHYBA při spuštění procesu: {e}")
            return 1

    def run_command_stream(
        self,
        cmd: list[str],
        runner_name: str,
        total_steps: int,
        step_label: str,
        sports: str,
        entities: str,
        run_group: str,
        provider_label: str = "-",
    ) -> None:
        start_ts = datetime.now()
        return_code = 1

        self.before_snapshot = self.collect_db_snapshot()
        self.render_snapshot_before(self.before_snapshot)
        self.after_snapshot = {}
        self.render_snapshot_after({})
        self.render_snapshot_diff({}, {})

        self.mark_run_started(runner_name, sports, entities, run_group)
        self.set_run_progress(1, total_steps, step_label)

        try:
            self.is_running = True
            self.update_selection_dashboard()

            return_code = self.run_single_process(cmd, provider_label=provider_label)

            self.after_snapshot = self.collect_db_snapshot()
            self.render_snapshot_after(self.after_snapshot)
            self.render_snapshot_diff(self.before_snapshot, self.after_snapshot)

        finally:
            self.is_running = False
            self.update_selection_dashboard()
            self.refresh_ops_dashboard()
            self.mark_run_finished(return_code, start_ts)

    # --------------------------------------------------------
    # Main
    # --------------------------------------------------------
    def run(self) -> None:
        self.root.mainloop()


def main() -> None:
    root = tk.Tk()
    app = MatchMatrixPanelV11(root)
    app.run()


if __name__ == "__main__":
    main()