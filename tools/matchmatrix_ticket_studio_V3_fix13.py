# -*- coding: utf-8 -*-
from __future__ import annotations

import csv
import json
import math
import tkinter as tk
import tkinter.font as tkfont
from tkinter import ttk, messagebox, filedialog
from decimal import Decimal, InvalidOperation
from dataclasses import dataclass
from typing import Optional

import psycopg2
from psycopg2.extras import RealDictCursor


# ============================================================
# MATCHMATRIX TICKET STUDIO V3 FIX7
# ------------------------------------------------------------
# Jednosouborová stabilní verze, která sjednocuje dosavadní směr:
# - 3panelový layout
# - výběr zápasů + FIX + bloky A/B/C
# - práce s templates v DB
# - runtime preview / generate přes mm_* funkce v DB
# - přehled tiketů v samostatném okně
# - export kombinací do CSV
# ============================================================

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

BG = "#0F0A1F"
CARD = "#171228"
CARD_2 = "#21183B"
CARD_3 = "#2B204D"
LINE = "#46336D"
TEXT = "#F4EEFF"
MUTED = "#A99BCF"
ACCENT = "#C77DFF"
YELLOW = "#F1C453"
GREEN = "#39A800"
GREEN_DARK = "#2F8A00"
RED = "#FF6161"
BLUE = "#66C2FF"
PINK = "#D46CFF"
PINK_DARK = "#B14DE8"
DARK_INPUT = "#100D1B"
TICKET_BG = "#151022"
TICKET_CARD = "#241D3C"
TICKET_CARD_ALT = "#2B2345"
ODD_BG = "#31285A"
ODD_SELECTED = "#D46CFF"
ODD_SELECTED_TEXT = "#14071D"
BLOCK_COLORS = {
    1: ("#2FAE66", "#06120B"),
    2: ("#4DA3FF", "#091120"),
    3: ("#F1C453", "#201705"),
}

INFO_BTN_BG = "#211A39"
INFO_BTN_HOVER = "#2A2246"
CHECK_SELECT = "#D46CFF"
CHECK_TEXT = "#FFFFFF"
OVERVIEW_BLOCK_W = 170
OVERVIEW_FIX_W = 360
OVERVIEW_ODD_W = 95
OVERVIEW_WIN_W = 110
OVERVIEW_PRED_W = 85
SPORT_ICONS = {
    "FB": "⚽",
    "HK": "🏒",
    "BK": "🏀",
    "TN": "🎾",
    "VB": "🏐",
    "HB": "🤾",
    "MMA": "🥊",
    "AFB": "🏈",
    "CK": "🏏",
    "BSB": "⚾",
    "ESP": "🎮",
    "RGB": "🏉",
    "FH": "🏑",
    "ALL": "⭐",
}

BASE_FONT_SIZES = {
    "FONT": 10,
    "FONT_SMALL": 9,
    "FONT_XS": 8,
    "FONT_BOLD": 10,
    "FONT_BOLD_XS": 8,
    "FONT_TITLE": 15,
    "FONT_SECTION": 11,
    "FONT_MONO": 9,
}

FONT = ("Segoe UI", 10)
FONT_SMALL = ("Segoe UI", 9)
FONT_XS = ("Segoe UI", 8)
FONT_BOLD = ("Segoe UI", 10, "bold")
FONT_BOLD_XS = ("Segoe UI", 8, "bold")
FONT_TITLE = ("Segoe UI", 15, "bold")
FONT_SECTION = ("Segoe UI", 11, "bold")
FONT_MONO = ("Consolas", 9)

TIME_PRESETS = [
    ("3 hod.", "3 hours"),
    ("6 hod.", "6 hours"),
    ("24 hod.", "24 hours"),
    ("2 dny", "2 days"),
    ("7 dnů", "7 days"),
    ("14 dnů", "14 days"),
]


@dataclass
class PickItem:
    item_type: str
    match_id: int
    market_id: int
    market_code: str
    market_outcome_id: Optional[int]
    outcome_code: Optional[str]
    odd_value: Optional[Decimal]
    sport_code: str
    league_name: str
    home_team: str
    away_team: str
    kickoff: object
    block_index: int = 0

    def key(self) -> tuple:
        return (
            self.item_type,
            self.match_id,
            (self.market_code or "").upper(),
            (self.outcome_code or ""),
            self.block_index,
        )


class TicketStudioV3:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("MatchMatrix Ticket Studio V3 fix11")
        self.root.geometry("1860x1040")
        self.root.minsize(1500, 860)
        self.root.configure(bg=BG)

        self.time_filter_var = tk.StringVar(value="24 hours")
        self.sport_var = tk.StringVar(value="ALL")
        self.only_odds_var = tk.BooleanVar(value=True)
        self.stake_var = tk.StringVar(value="100")
        self.template_id_var = tk.StringVar(value="1")
        self.bookmaker_var = tk.StringVar(value="")
        self.max_tickets_var = tk.StringVar(value="5000")
        self.min_probability_var = tk.StringVar(value="")
        self.ticket_count_var = tk.StringVar(value="0 výběrů")
        self.metric_odds_var = tk.StringVar(value="1.00")
        self.metric_combos_var = tk.StringVar(value="1")
        self.metric_stake_var = tk.StringVar(value="100.00 Kč")
        self.metric_return_var = tk.StringVar(value="100.00 Kč")
        self.runtime_status_var = tk.StringVar(value="Runtime engine připraven.")
        self.preview_badge_var = tk.StringVar(value="bez preview")
        self.last_run_id_var = tk.StringVar(value="-")
        self.viewport_var = tk.StringVar(value="desktop | unified V3 | fix11 | standings detail + form 5/10/15")

        self.market_ids: dict[str, int] = {}
        self.market_outcome_ids: dict[tuple[str, str], int] = {}
        self.bookmakers_by_name: dict[str, int] = {}
        self.bookmaker_rows: list[dict] = []
        self.sport_name_map: dict[str, str] = {"ALL": "Vše"}
        self.league_vars: dict[int, tk.BooleanVar] = {}
        self.league_rows: list[dict] = []
        self.all_matches: list[dict] = []
        self.visible_matches: list[dict] = []
        self.fixed_items: list[PickItem] = []
        self.block_items: dict[int, list[PickItem]] = {1: [], 2: [], 3: []}
        self.generated_rows: list[dict] = []
        self.generated_checks: list[tk.BooleanVar] = []
        self.generated_probabilities: dict[int, float] = {}
        self.match_detail_cache: dict[int, dict] = {}
        self.match_row_widgets: dict[int, dict] = {}
        self._scroll_target_map: dict[int, object] = {}
        self._last_load_signature = None
        self.zoom_percent = 100

        self.build_ui()
        self.load_market_maps()
        self.load_sports()
        self.load_bookmakers()
        self.load_leagues_and_matches(initial=True)
        self.root.after(200, self.init_pane_sizes)
        self.root.bind("<Configure>", self._on_root_resize, add="+")
        self._bind_mousewheel_support()


    def _bind_mousewheel_support(self):
        self.root.bind_all("<Control-MouseWheel>", self._on_ctrl_mousewheel, add="+")
        self.root.bind_all("<MouseWheel>", self._on_mousewheel, add="+")
        self.root.bind_all("<Button-4>", self._on_mousewheel_linux_up, add="+")
        self.root.bind_all("<Button-5>", self._on_mousewheel_linux_down, add="+")

    def _map_scroll_target(self, widget, canvas):
        if widget is None or canvas is None:
            return
        self._scroll_target_map[id(widget)] = canvas

    def _resolve_scroll_target(self, widget):
        current = widget
        visited = set()
        while current is not None and id(current) not in visited:
            visited.add(id(current))
            canvas = self._scroll_target_map.get(id(current))
            if canvas is not None:
                return canvas
            try:
                current = current.master
            except Exception:
                current = None
        return None

    def _register_wheel_target(self, widget, canvas):
        self._map_scroll_target(widget, canvas)

    def _scroll_canvas_units(self, canvas, units: int):
        if canvas is None:
            return
        try:
            first, last = canvas.yview()
            if first == 0.0 and units < 0:
                return
            if last == 1.0 and units > 0:
                return
            canvas.yview_scroll(units, "units")
        except Exception:
            pass

    def _on_mousewheel(self, event):
        canvas = self._resolve_scroll_target(event.widget)
        if canvas is None:
            return
        delta = event.delta
        if delta == 0:
            return
        units = -1 * int(delta / 120) if abs(delta) >= 120 else (-1 if delta > 0 else 1)
        self._scroll_canvas_units(canvas, units)

    def _on_mousewheel_linux_up(self, event):
        self._scroll_canvas_units(self._resolve_scroll_target(event.widget), -1)

    def _on_mousewheel_linux_down(self, event):
        self._scroll_canvas_units(self._resolve_scroll_target(event.widget), 1)

    def _on_ctrl_mousewheel(self, event):
        if event.delta > 0:
            self.apply_zoom(10)
        elif event.delta < 0:
            self.apply_zoom(-10)
        return "break"

    def apply_zoom(self, delta_percent: int):
        new_zoom = max(80, min(150, self.zoom_percent + delta_percent))
        if new_zoom == self.zoom_percent:
            return
        self.zoom_percent = new_zoom
        self._apply_font_scale()
        self.rebuild_ui_after_zoom()

    def _apply_font_scale(self):
        scale = self.zoom_percent / 100.0
        globals()["FONT"] = ("Segoe UI", max(8, round(BASE_FONT_SIZES["FONT"] * scale)))
        globals()["FONT_SMALL"] = ("Segoe UI", max(7, round(BASE_FONT_SIZES["FONT_SMALL"] * scale)))
        globals()["FONT_XS"] = ("Segoe UI", max(7, round(BASE_FONT_SIZES["FONT_XS"] * scale)))
        globals()["FONT_BOLD"] = ("Segoe UI", max(8, round(BASE_FONT_SIZES["FONT_BOLD"] * scale)), "bold")
        globals()["FONT_BOLD_XS"] = ("Segoe UI", max(7, round(BASE_FONT_SIZES["FONT_BOLD_XS"] * scale)), "bold")
        globals()["FONT_TITLE"] = ("Segoe UI", max(11, round(BASE_FONT_SIZES["FONT_TITLE"] * scale)), "bold")
        globals()["FONT_SECTION"] = ("Segoe UI", max(9, round(BASE_FONT_SIZES["FONT_SECTION"] * scale)), "bold")
        globals()["FONT_MONO"] = ("Consolas", max(7, round(BASE_FONT_SIZES["FONT_MONO"] * scale)))

    def rebuild_ui_after_zoom(self):
        for child in self.root.winfo_children():
            child.destroy()
        self.build_ui()
        self.root.after(50, self.init_pane_sizes)
        self.root.after(70, self.refresh_all_panels)
        self._bind_mousewheel_support()

    # ========================================================
    # DB helpers
    # ========================================================
    def get_connection(self):
        return psycopg2.connect(**DB_CONFIG)

    def fetchall(self, sql: str, params: tuple = ()) -> list[dict]:
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                return list(cur.fetchall())

    def fetchone(self, sql: str, params: tuple = ()) -> Optional[dict]:
        rows = self.fetchall(sql, params)
        return rows[0] if rows else None

    def execute(self, sql: str, params: tuple = ()) -> None:
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, params)
            conn.commit()

    # ========================================================
    # Utility
    # ========================================================
    def safe_int(self, value, default: int = 0) -> int:
        try:
            return int(str(value).strip())
        except Exception:
            return default

    def safe_decimal(self, value) -> Optional[Decimal]:
        if value in (None, "", "None"):
            return None
        try:
            return Decimal(str(value))
        except (InvalidOperation, ValueError):
            return None

    def float_or_none(self, value) -> Optional[float]:
        try:
            if value is None or value == "":
                return None
            return float(value)
        except Exception:
            return None

    def fmt_odds(self, value) -> str:
        dec = self.safe_decimal(value)
        return "-" if dec is None else f"{dec:.2f}"

    def fmt_money(self, value) -> str:
        dec = self.safe_decimal(value)
        return "-" if dec is None else f"{dec:.2f} Kč"

    def fmt_percent(self, value) -> str:
        num = self.float_or_none(value)
        return "-" if num is None else f"{num * 100:.2f} %"

    def fmt_kickoff(self, value) -> str:
        if value is None:
            return "-"
        try:
            return value.strftime("%d.%m %H:%M")
        except Exception:
            return str(value)

    def block_label(self, block_index: int) -> str:
        return {1: "A", 2: "B", 3: "C"}.get(block_index, str(block_index))

    def sport_icon(self, sport_code: str) -> str:
        return SPORT_ICONS.get((sport_code or "").upper(), "⭐")

    def compute_double_chance_odds(self, odd_1, odd_x, odd_2) -> dict[str, Optional[Decimal]]:
        d1 = self.safe_decimal(odd_1)
        dx = self.safe_decimal(odd_x)
        d2 = self.safe_decimal(odd_2)
        if not d1 or not dx or not d2:
            return {"1X": None, "12": None, "X2": None}
        try:
            inv1 = Decimal("1") / d1
            invx = Decimal("1") / dx
            inv2 = Decimal("1") / d2
            total = inv1 + invx + inv2
            if total <= 0:
                return {"1X": None, "12": None, "X2": None}
            p1 = inv1 / total
            px = invx / total
            p2 = inv2 / total
            return {
                "1X": Decimal("1") / (p1 + px),
                "12": Decimal("1") / (p1 + p2),
                "X2": Decimal("1") / (px + p2),
            }
        except Exception:
            return {"1X": None, "12": None, "X2": None}

    def get_bookmaker_id(self) -> Optional[int]:
        name = self.bookmaker_var.get().strip()
        return self.bookmakers_by_name.get(name)

    def get_h2h_market_id(self) -> Optional[int]:
        return self.market_ids.get("H2H") or self.market_ids.get("1X2")

    def get_market_outcome_id(self, market_code: str, outcome_code: str) -> Optional[int]:
        return self.market_outcome_ids.get((market_code.upper(), outcome_code.upper()))

    def make_fixed_from_row(self, row: dict, outcome_code: str, odd_value) -> Optional[PickItem]:
        market_code, market_id, market_outcome_id = self.resolve_pick_market(outcome_code)
        if market_id is None or market_outcome_id is None:
            return None
        return PickItem(
            item_type="FIXED",
            match_id=int(row["match_id"]),
            market_id=int(market_id),
            market_code=market_code,
            market_outcome_id=int(market_outcome_id),
            outcome_code=outcome_code,
            odd_value=self.safe_decimal(odd_value),
            sport_code=str(row.get("sport_code") or ""),
            league_name=str(row.get("league_name") or ""),
            home_team=str(row.get("home_team") or "?"),
            away_team=str(row.get("away_team") or "?"),
            kickoff=row.get("kickoff"),
        )

    def resolve_pick_market(self, outcome_code: str) -> tuple[str, Optional[int], Optional[int]]:
        code = (outcome_code or "").upper()
        if code in ("1", "X", "2"):
            market_candidates = ["H2H", "1X2"]
        else:
            market_candidates = ["DOUBLE_CHANCE", "DOUBLE CHANCE", "DC"]
        for market_code in market_candidates:
            market_id = self.market_ids.get(market_code.upper())
            if market_id is None:
                continue
            market_outcome_id = self.get_market_outcome_id(market_code, code)
            if market_outcome_id is not None:
                return market_code, int(market_id), int(market_outcome_id)
        return ("H2H" if code in ("1", "X", "2") else "DOUBLE_CHANCE", None, None)

    def outcome_is_supported(self, outcome_code: str) -> bool:
        _market_code, market_id, market_outcome_id = self.resolve_pick_market(outcome_code)
        return market_id is not None and market_outcome_id is not None

    def make_block_from_row(self, row: dict, block_index: int) -> Optional[PickItem]:
        market_id = self.get_h2h_market_id()
        if market_id is None:
            return None
        return PickItem(
            item_type="BLOCK",
            match_id=int(row["match_id"]),
            market_id=int(market_id),
            market_code="H2H",
            market_outcome_id=None,
            outcome_code=None,
            odd_value=None,
            sport_code=str(row.get("sport_code") or ""),
            league_name=str(row.get("league_name") or ""),
            home_team=str(row.get("home_team") or "?"),
            away_team=str(row.get("away_team") or "?"),
            kickoff=row.get("kickoff"),
            block_index=block_index,
        )

    # ========================================================
    # UI
    # ========================================================
    def build_ui(self):
        self.build_header()

        outer = tk.Frame(self.root, bg=BG)
        outer.pack(fill="both", expand=True, padx=8, pady=(0, 8))

        self.main_paned = tk.PanedWindow(
            outer,
            orient="horizontal",
            sashrelief="flat",
            sashwidth=8,
            bg=BG,
            bd=0,
        )
        self.main_paned.pack(fill="both", expand=True)

        self.left_panel = tk.Frame(self.main_paned, bg=BG)
        self.center_panel = tk.Frame(self.main_paned, bg=BG)
        self.right_panel = tk.Frame(self.main_paned, bg=BG)

        self.main_paned.add(self.left_panel, minsize=170)
        self.main_paned.add(self.center_panel, minsize=700)
        self.main_paned.add(self.right_panel, minsize=560)

        self.build_left_panel(self.left_panel)
        self.build_center_panel(self.center_panel)
        self.build_right_panel(self.right_panel)

    def init_pane_sizes(self):
        try:
            total = self.main_paned.winfo_width()
            if total <= 1:
                return
            left_w = 180
            right_w = max(560, int(total * 0.36))
            center_w = max(700, total - left_w - right_w)
            self.main_paned.sashpos(0, left_w)
            self.main_paned.sashpos(1, left_w + center_w)
        except Exception:
            pass

    def _on_root_resize(self, event):
        if event.widget is self.root:
            self.viewport_var.set(f"desktop | unified V3 | {self.root.winfo_width()}x{self.root.winfo_height()}")

    def build_header(self):
        header = tk.Frame(self.root, bg=BG)
        header.pack(fill="x", padx=10, pady=(8, 6))
        header.grid_columnconfigure(0, weight=1)

        tk.Label(
            header,
            text="MatchMatrix Ticket Studio V3",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            header,
            text="kompaktní tiket • 2 řádky na výběr • CTRL + kolečko = zoom • širší pravý panel",
            bg=BG,
            fg=MUTED,
            font=FONT_SMALL,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        tk.Label(
            header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=ACCENT,
            font=FONT_SMALL,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

    def create_scrollable_vertical(self, parent, bg_color):
        outer = tk.Frame(parent, bg=bg_color)
        canvas = tk.Canvas(outer, bg=bg_color, highlightthickness=0)
        scrollbar = tk.Scrollbar(outer, orient="vertical", command=canvas.yview)
        inner = tk.Frame(canvas, bg=bg_color)

        inner.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        win = canvas.create_window((0, 0), window=inner, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)

        def on_canvas_resize(event):
            canvas.itemconfigure(win, width=event.width)

        canvas.bind("<Configure>", on_canvas_resize)
        self._register_wheel_target(outer, canvas)
        self._register_wheel_target(canvas, canvas)
        self._register_wheel_target(inner, canvas)
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        return outer, canvas, inner

    def build_left_panel(self, parent):
        parent.grid_rowconfigure(2, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_template_panel_left(parent)
        self.build_filter_panel_left(parent)
        self.build_league_panel_left(parent)

    def build_template_panel_left(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=0, column=0, sticky="ew", pady=(0, 8))

        tk.Label(frame, text="Template", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=8, pady=(8, 6))

        row = tk.Frame(frame, bg=CARD)
        row.pack(fill="x", padx=8, pady=(0, 6))
        tk.Label(row, text="ID", bg=CARD, fg=MUTED, font=FONT_XS).pack(side="left")
        tk.Entry(row, textvariable=self.template_id_var, bg=DARK_INPUT, fg=TEXT, insertbackground=TEXT, relief="flat", width=8).pack(side="left", padx=(6, 0), ipady=4)

        btns = tk.Frame(frame, bg=CARD)
        btns.pack(fill="x", padx=8, pady=(0, 8))
        tk.Button(btns, text="Načíst", bg=BLUE, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.load_template_from_db).pack(side="left", padx=(0, 5), ipady=3)
        tk.Button(btns, text="Uložit", bg=ACCENT, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.save_template_to_db).pack(side="left", padx=(0, 5), ipady=3)
        tk.Button(btns, text="Smazat", bg=RED, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.delete_template_from_db).pack(side="left", ipady=3)

    def build_filter_panel_left(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=1, column=0, sticky="ew", pady=(0, 8))

        tk.Label(frame, text="Sporty a čas", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=8, pady=(8, 6))

        self.sport_combo = ttk.Combobox(frame, textvariable=self.sport_var, state="readonly", height=12)
        self.sport_combo.pack(fill="x", padx=8, pady=(0, 6))
        self.sport_combo.bind("<<ComboboxSelected>>", lambda _e: self.load_leagues_and_matches(initial=False))

        chips = tk.Frame(frame, bg=CARD)
        chips.pack(fill="x", padx=8, pady=(0, 6))
        self.time_buttons: dict[str, tk.Button] = {}
        for idx, (label, value) in enumerate(TIME_PRESETS):
            btn = tk.Button(
                chips,
                text=label,
                bg=CARD_2,
                fg=TEXT,
                relief="flat",
                font=FONT_XS,
                command=lambda v=value: self.set_time_filter(v),
            )
            btn.grid(row=idx // 2, column=idx % 2, sticky="ew", padx=(0, 4), pady=(0, 4), ipady=2)
            self.time_buttons[value] = btn
        chips.grid_columnconfigure(0, weight=1)
        chips.grid_columnconfigure(1, weight=1)

        tk.Checkbutton(
            frame,
            text="Jen zápasy s kurzy",
            variable=self.only_odds_var,
            bg=CARD,
            fg=TEXT,
            selectcolor=CARD_2,
            activebackground=CARD,
            activeforeground=TEXT,
            font=FONT_SMALL,
        ).pack(anchor="w", padx=8, pady=(0, 6))

        tk.Button(
            frame,
            text="Načíst nabídku",
            bg=ACCENT,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=lambda: self.load_leagues_and_matches(initial=False),
        ).pack(fill="x", padx=8, pady=(0, 8), ipady=4)

        self.render_time_buttons()

    def build_league_panel_left(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=2, column=0, sticky="nsew")
        frame.grid_rowconfigure(2, weight=1)
        frame.grid_columnconfigure(0, weight=1)

        tk.Label(frame, text="Soutěže", bg=CARD, fg=TEXT, font=FONT_SECTION).grid(row=0, column=0, sticky="w", padx=8, pady=(8, 6))

        tools = tk.Frame(frame, bg=CARD)
        tools.grid(row=1, column=0, sticky="ew", padx=8, pady=(0, 6))
        tk.Button(tools, text="Vše", bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=self.select_all_leagues).pack(side="left", padx=(0, 4), ipady=2)
        tk.Button(tools, text="Nic", bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=self.clear_league_selection).pack(side="left", ipady=2)

        outer, _canvas, self.league_inner = self.create_scrollable_vertical(frame, CARD)
        outer.grid(row=2, column=0, sticky="nsew", padx=8, pady=(0, 8))

    def build_center_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        top = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        top.grid(row=0, column=0, sticky="ew", pady=(0, 8))
        tk.Label(top, text="Nabídka zápasů", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(8, 4))
        tk.Label(top, text="klik na kurz = FIX • klik na A/B/C = přidání zápasu do bloku • i = detail zápasu", bg=CARD, fg=MUTED, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(0, 8))

        box = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        box.grid(row=1, column=0, sticky="nsew")
        box.grid_rowconfigure(1, weight=1)
        box.grid_columnconfigure(0, weight=1)

        self.grid_columns = [
            ("ZÁPAS", 396, "w"),
            ("i", 34, "center"),
            ("1", 58, "center"),
            ("X", 58, "center"),
            ("2", 58, "center"),
            ("1X", 60, "center"),
            ("12", 60, "center"),
            ("X2", 60, "center"),
            ("A", 44, "center"),
            ("B", 44, "center"),
            ("C", 44, "center"),
        ]
        self.grid_total_width = sum(col[1] for col in self.grid_columns) + 20

        self.header_row = tk.Frame(box, bg=CARD_2, height=34, width=self.grid_total_width)
        self.header_row.grid(row=0, column=0, sticky="ew")
        self.header_row.grid_propagate(False)
        self.build_match_header()

        body = tk.Frame(box, bg=CARD)
        body.grid(row=1, column=0, sticky="nsew")
        body.grid_rowconfigure(0, weight=1)
        body.grid_columnconfigure(0, weight=1)

        self.match_canvas = tk.Canvas(body, bg=CARD, highlightthickness=0)
        self.match_scroll = tk.Scrollbar(body, orient="vertical", command=self.match_canvas.yview)
        self.match_canvas.configure(yscrollcommand=self.match_scroll.set)
        self.match_inner = tk.Frame(self.match_canvas, bg=CARD, width=self.grid_total_width)
        self.match_inner.bind("<Configure>", lambda e: self.match_canvas.configure(scrollregion=self.match_canvas.bbox("all")))
        self.match_window = self.match_canvas.create_window((0, 0), window=self.match_inner, anchor="nw")

        def on_resize(event):
            width = max(event.width, self.grid_total_width)
            self.match_canvas.itemconfigure(self.match_window, width=width)
            self.header_row.configure(width=width)

        self.match_canvas.bind("<Configure>", on_resize)
        self._register_wheel_target(body, self.match_canvas)
        self._register_wheel_target(self.match_canvas, self.match_canvas)
        self._register_wheel_target(self.match_inner, self.match_canvas)
        self.match_canvas.grid(row=0, column=0, sticky="nsew")
        self.match_scroll.grid(row=0, column=1, sticky="ns")

    def build_match_header(self):
        for child in self.header_row.winfo_children():
            child.destroy()
        x = 0
        for title, width, anchor in self.grid_columns:
            tk.Label(self.header_row, text=title, bg=CARD_2, fg=YELLOW, font=FONT_XS, anchor=anchor).place(x=x, y=0, width=width, height=34)
            x += width

    def build_right_panel(self, parent):
        parent.grid_rowconfigure(0, weight=1)
        parent.grid_rowconfigure(1, weight=0)
        parent.grid_columnconfigure(0, weight=1)
        self.build_ticket_panel(parent)
        self.build_controls_panel(parent)

    def build_ticket_panel(self, parent):
        frame = tk.Frame(parent, bg=TICKET_BG, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=0, column=0, sticky="nsew", pady=(0, 8))
        frame.grid_rowconfigure(1, weight=1)
        frame.grid_columnconfigure(0, weight=1)
        self.ticket_frame = frame

        top_fields = tk.Frame(frame, bg=TICKET_BG)
        top_fields.grid(row=0, column=0, sticky="ew", padx=8, pady=(8, 6))
        for c in range(4):
            top_fields.grid_columnconfigure(c, weight=1)
        self._top_entry_box(top_fields, 0, "Template ID", "template")
        self._top_entry_box(top_fields, 1, "Bookmaker", "bookmaker")
        self._top_entry_box(top_fields, 2, "Max tiketů", "max")
        self._top_entry_box(top_fields, 3, "Min. pravděpod.", "min")

        ticket_wrap = tk.Frame(frame, bg=TICKET_BG)
        ticket_wrap.grid(row=1, column=0, sticky="nsew", padx=8, pady=(0, 8))
        ticket_wrap.grid_rowconfigure(1, weight=1)
        ticket_wrap.grid_columnconfigure(0, weight=1)

        head = tk.Frame(ticket_wrap, bg=TICKET_BG)
        head.grid(row=0, column=0, sticky="ew", pady=(0, 6))
        tk.Label(head, text="Tiket", bg=TICKET_BG, fg=TEXT, font=FONT_SECTION).pack(side="left")
        tk.Label(head, textvariable=self.ticket_count_var, bg=CARD_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        self.ticket_outer, self.ticket_canvas, self.ticket_inner = self.create_scrollable_vertical(ticket_wrap, TICKET_BG)
        self.ticket_outer.grid(row=1, column=0, sticky="nsew")

    def build_controls_panel(self, parent):
        frame = tk.Frame(parent, bg=TICKET_BG, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=1, column=0, sticky="ew", pady=(0, 0))

        metrics = tk.Frame(frame, bg=TICKET_BG)
        metrics.pack(fill="x", padx=8, pady=(8, 6))
        for c in range(4):
            metrics.grid_columnconfigure(c, weight=1)
        self._metric_box_top(metrics, 0, "Kurz", self.metric_odds_var)
        self._metric_box_top(metrics, 1, "Kombinací", self.metric_combos_var)
        self._metric_box_top(metrics, 2, "Vsadíš", self.metric_stake_var)
        self._metric_box_top(metrics, 3, "Výhra", self.metric_return_var)

        stake = tk.Frame(frame, bg=TICKET_BG)
        stake.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(stake, text="Vklad na 1 kombinaci", bg=TICKET_BG, fg=MUTED, font=FONT_XS).pack(anchor="w")
        stake_row = tk.Frame(stake, bg=TICKET_BG)
        stake_row.pack(fill="x", pady=(3, 0))
        tk.Label(stake_row, text="Kč", bg=CARD_2, fg=TEXT, font=FONT_BOLD_XS, padx=10, pady=5).pack(side="left")
        self.stake_entry = tk.Entry(stake_row, textvariable=self.stake_var, bg=DARK_INPUT, fg=TEXT, insertbackground=TEXT, relief="flat", justify="right", font=FONT_BOLD)
        self.stake_entry.pack(side="left", fill="x", expand=True, ipady=5)
        self.stake_entry.bind("<KeyRelease>", lambda _e: self.refresh_summary())
        self.stake_entry.bind("<FocusOut>", lambda _e: self.refresh_summary())

        quick = tk.Frame(frame, bg=TICKET_BG)
        quick.pack(fill="x", padx=10, pady=(0, 6))
        for amount in (10, 50, 100, 200):
            tk.Button(quick, text=str(amount), bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=lambda a=amount: self.set_stake(a)).pack(side="left", padx=(0, 4), ipady=2)

        runtime = tk.Frame(frame, bg=TICKET_BG)
        runtime.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(runtime, text="Runtime engine", bg=TICKET_BG, fg=TEXT, font=FONT_SECTION).pack(anchor="w")
        rt_btns = tk.Frame(runtime, bg=TICKET_BG)
        rt_btns.pack(fill="x", pady=(4, 4))
        tk.Button(rt_btns, text="PREVIEW", bg=BLUE, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.preview_runtime_run).pack(side="left", padx=(0, 6), ipady=3)
        tk.Button(rt_btns, text="GENERATE", bg=ACCENT, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.generate_runtime_run).pack(side="left", padx=(0, 6), ipady=3)
        tk.Button(rt_btns, text="ULOŽIT RUN", bg=GREEN_DARK, fg=TEXT, font=FONT_BOLD_XS, relief="flat", command=self.save_current_run_full).pack(side="left", padx=(0, 6), ipady=3)
        tk.Button(rt_btns, text="PŘEHLED TIKETŮ", bg=GREEN, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.show_generated_overview).pack(side="left", ipady=3)

        status = tk.Frame(frame, bg=TICKET_BG)
        status.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(status, text="Preview", bg=TICKET_BG, fg=MUTED, font=FONT_XS).pack(side="left")
        tk.Label(status, textvariable=self.preview_badge_var, bg=CARD_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="left", padx=(6, 10))
        tk.Label(status, text="Run ID", bg=TICKET_BG, fg=MUTED, font=FONT_XS).pack(side="left")
        tk.Label(status, textvariable=self.last_run_id_var, bg=CARD_2, fg=TEXT, font=FONT_XS, padx=6, pady=2).pack(side="left", padx=(6, 0))

        tk.Label(frame, textvariable=self.runtime_status_var, bg=TICKET_BG, fg=TEXT, font=FONT_XS, anchor="w", justify="left", wraplength=520).pack(fill="x", padx=10, pady=(0, 4))

        log_wrap = tk.Frame(frame, bg=TICKET_BG)
        log_wrap.pack(fill="both", expand=False, padx=10, pady=(0, 8))
        self.runtime_text = tk.Text(log_wrap, height=4, bg=CARD_2, fg=TEXT, insertbackground=TEXT, wrap="word", relief="flat", font=FONT_MONO)
        self.runtime_text.pack(side="left", fill="both", expand=True)
        self._register_wheel_target(self.runtime_text, self.ticket_canvas if hasattr(self, "ticket_canvas") else None)
        tk.Scrollbar(log_wrap, orient="vertical", command=self.runtime_text.yview).pack(side="right", fill="y")
        self.runtime_text.configure(yscrollcommand=lambda a, b: None)

    def _top_entry_box(self, parent, col: int, label: str, mode: str):
        box = tk.Frame(parent, bg=CARD_2, highlightthickness=1, highlightbackground=LINE)
        box.grid(row=0, column=col, sticky="ew", padx=(0 if col == 0 else 4, 0))
        tk.Label(box, text=label, bg=CARD_2, fg=MUTED, font=FONT_XS).pack(anchor="w", padx=8, pady=(5, 1))

        if mode == "template":
            entry = tk.Entry(box, textvariable=self.template_id_var, bg=DARK_INPUT, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL)
            entry.pack(fill="x", padx=8, pady=(0, 6), ipady=4)
        elif mode == "bookmaker":
            self.bookmaker_combo = ttk.Combobox(box, textvariable=self.bookmaker_var, state="readonly", height=12)
            self.bookmaker_combo.pack(fill="x", padx=8, pady=(0, 6), ipady=2)
        elif mode == "max":
            entry = tk.Entry(box, textvariable=self.max_tickets_var, bg=DARK_INPUT, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL)
            entry.pack(fill="x", padx=8, pady=(0, 6), ipady=4)
        else:
            entry = tk.Entry(box, textvariable=self.min_probability_var, bg=DARK_INPUT, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL)
            entry.pack(fill="x", padx=8, pady=(0, 6), ipady=4)

    def _metric_box_top(self, parent, col: int, label: str, variable: tk.StringVar):
        box = tk.Frame(parent, bg=CARD_2, highlightthickness=1, highlightbackground=LINE)
        box.grid(row=0, column=col, sticky="ew", padx=(0 if col == 0 else 4, 0))
        tk.Label(box, text=label, bg=CARD_2, fg=MUTED, font=FONT_XS).pack(anchor="w", padx=8, pady=(5, 1))
        tk.Label(box, textvariable=variable, bg=CARD_2, fg=TEXT, font=FONT_BOLD).pack(anchor="w", padx=8, pady=(0, 6))

    # ========================================================
    # Loaders
    # ========================================================
    def load_market_maps(self):
        try:
            rows = self.fetchall("SELECT id, code FROM public.markets ORDER BY id")
            self.market_ids = {str(r["code"]).upper(): int(r["id"]) for r in rows if r.get("code")}
            rows = self.fetchall(
                """
                SELECT mo.id, mo.code AS outcome_code, mk.code AS market_code
                FROM public.market_outcomes mo
                JOIN public.markets mk ON mk.id = mo.market_id
                """
            )
            self.market_outcome_ids = {
                (str(r["market_code"]).upper(), str(r["outcome_code"]).upper()): int(r["id"])
                for r in rows
                if r.get("market_code") and r.get("outcome_code")
            }
        except Exception as e:
            messagebox.showerror("DB chyba", f"Nepodařilo se načíst markets / outcomes.\n\n{e}")

    def load_sports(self):
        try:
            rows = self.fetchall(
                """
                SELECT code, COALESCE(name, code) AS name
                FROM public.sports
                WHERE COALESCE(is_active, TRUE) = TRUE
                ORDER BY sort_order NULLS LAST, name
                """
            )
            values = ["ALL"]
            self.sport_name_map = {"ALL": "Vše"}
            for row in rows:
                code = str(row.get("code") or "").strip()
                if not code:
                    continue
                values.append(code)
                self.sport_name_map[code] = str(row.get("name") or code)
            self.sport_combo["values"] = values
            self.sport_var.set("ALL")
        except Exception as e:
            messagebox.showerror("DB chyba", f"Nepodařilo se načíst sporty.\n\n{e}")

    def load_bookmakers(self):
        try:
            rows = self.fetchall(
                """
                SELECT id, name
                FROM public.bookmakers
                ORDER BY name
                """
            )
            self.bookmaker_rows = rows
            self.bookmakers_by_name = {str(r["name"]): int(r["id"]) for r in rows if r.get("name")}
            values = list(self.bookmakers_by_name.keys())
            self.bookmaker_combo["values"] = values
            if values and not self.bookmaker_var.get().strip():
                self.bookmaker_var.set(values[0])
        except Exception as e:
            messagebox.showerror("DB chyba", f"Nepodařilo se načíst bookmakery.\n\n{e}")

    def set_time_filter(self, value: str):
        self.time_filter_var.set(value)
        self.render_time_buttons()
        self.load_leagues_and_matches(initial=False)

    def render_time_buttons(self):
        for value, btn in getattr(self, "time_buttons", {}).items():
            active = value == self.time_filter_var.get()
            btn.configure(bg=ACCENT if active else CARD_2, fg=BG if active else TEXT)

    def load_leagues_and_matches(self, initial: bool):
        sport_code = self.sport_var.get().strip() or "ALL"
        time_interval = self.time_filter_var.get().strip() or "24 hours"
        only_odds = self.only_odds_var.get()
        bookmaker_id = self.get_bookmaker_id()

        signature = (sport_code, time_interval, bool(only_odds), bookmaker_id)
        if signature == self._last_load_signature and self.all_matches:
            self.build_league_selector(initial=initial)
            self.apply_league_filter_to_center()
            return

        limit_rows = 220
        match_sql = """
            SELECT
                m.id AS match_id,
                m.kickoff,
                COALESCE(sp.code, '?') AS sport_code,
                COALESCE(l.id, 0) AS league_id,
                COALESCE(l.name, '?') AS league_name,
                COALESCE(ht.name, '?') AS home_team,
                COALESCE(at.name, '?') AS away_team
            FROM public.matches m
            LEFT JOIN public.leagues l ON l.id = m.league_id
            LEFT JOIN public.sports sp ON sp.id = COALESCE(m.sport_id, l.sport_id)
            LEFT JOIN public.teams ht ON ht.id = m.home_team_id
            LEFT JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.kickoff >= now()
            AND m.kickoff < now() + (%s)::interval
            AND (%s = 'ALL' OR sp.code = %s)
        """
        match_params = [time_interval, sport_code, sport_code]

        if only_odds:
            if bookmaker_id is not None:
                match_sql += """
                AND EXISTS (
                        SELECT 1
                        FROM public.odds o
                        JOIN public.market_outcomes mo ON mo.id = o.market_outcome_id
                        JOIN public.markets mk ON mk.id = mo.market_id
                        WHERE o.match_id = m.id
                        AND o.bookmaker_id = %s
                        AND lower(mk.code) IN (lower('h2h'), lower('1x2'))
                        AND mo.code IN ('1','X','2')
                        AND o.odd_value IS NOT NULL
                        AND o.odd_value > 0
                )
                """
                match_params.append(bookmaker_id)
            else:
                match_sql += """
                AND EXISTS (
                        SELECT 1
                        FROM public.odds o
                        JOIN public.market_outcomes mo ON mo.id = o.market_outcome_id
                        JOIN public.markets mk ON mk.id = mo.market_id
                        WHERE o.match_id = m.id
                        AND lower(mk.code) IN (lower('h2h'), lower('1x2'))
                        AND mo.code IN ('1','X','2')
                        AND o.odd_value IS NOT NULL
                        AND o.odd_value > 0
                )
                """

        match_sql += """
            ORDER BY l.name, m.kickoff ASC NULLS LAST, ht.name, at.name
            LIMIT %s
        """
        match_params.append(limit_rows)

        try:
            matches = self.fetchall(match_sql, tuple(match_params))
            if not matches:
                self.all_matches = []
                self.match_detail_cache = {}
                self._last_load_signature = signature
                self.build_league_selector(initial=initial)
                self.apply_league_filter_to_center()
                return

            ids = [int(r["match_id"]) for r in matches if r.get("match_id") is not None]

            if bookmaker_id is not None:
                odds_sql = """
                    SELECT
                        o.match_id,
                        MAX(CASE WHEN mo.code = '1' THEN o.odd_value END) AS odd_1,
                        MAX(CASE WHEN mo.code = 'X' THEN o.odd_value END) AS odd_x,
                        MAX(CASE WHEN mo.code = '2' THEN o.odd_value END) AS odd_2
                    FROM public.odds o
                    JOIN public.market_outcomes mo ON mo.id = o.market_outcome_id
                    JOIN public.markets mk ON mk.id = mo.market_id
                    WHERE o.match_id = ANY(%s)
                    AND o.bookmaker_id = %s
                    AND lower(mk.code) IN (lower('h2h'), lower('1x2'))
                    AND mo.code IN ('1','X','2')
                    AND o.odd_value IS NOT NULL
                    AND o.odd_value > 0
                    GROUP BY o.match_id
                """
                odds_params = (ids, bookmaker_id)
            else:
                odds_sql = """
                    SELECT
                        o.match_id,
                        MAX(CASE WHEN mo.code = '1' THEN o.odd_value END) AS odd_1,
                        MAX(CASE WHEN mo.code = 'X' THEN o.odd_value END) AS odd_x,
                        MAX(CASE WHEN mo.code = '2' THEN o.odd_value END) AS odd_2
                    FROM public.odds o
                    JOIN public.market_outcomes mo ON mo.id = o.market_outcome_id
                    JOIN public.markets mk ON mk.id = mo.market_id
                    WHERE o.match_id = ANY(%s)
                    AND lower(mk.code) IN (lower('h2h'), lower('1x2'))
                    AND mo.code IN ('1','X','2')
                    AND o.odd_value IS NOT NULL
                    AND o.odd_value > 0
                    GROUP BY o.match_id
                """
                odds_params = (ids,)

            odds_rows = self.fetchall(odds_sql, odds_params)
            odds_map = {int(r["match_id"]): r for r in odds_rows if r.get("match_id") is not None}

            enriched = []
            for row in matches:
                odds = odds_map.get(int(row["match_id"]), {})
                new_row = dict(row)
                new_row["odd_1"] = odds.get("odd_1")
                new_row["odd_x"] = odds.get("odd_x")
                new_row["odd_2"] = odds.get("odd_2")
                if only_odds and not (
                    new_row["odd_1"] is not None
                    and new_row["odd_x"] is not None
                    and new_row["odd_2"] is not None
                ):
                    continue
                enriched.append(new_row)

            self.all_matches = enriched
            self.match_detail_cache = {}
            self._last_load_signature = signature
            self.build_league_selector(initial=initial)
            self.apply_league_filter_to_center()
        except Exception as e:
            messagebox.showerror("DB chyba", f"Nepodařilo se načíst zápasy.\n\n{e}")

    def build_league_selector(self, initial: bool):
        counts: dict[int, dict] = {}
        for row in self.all_matches:
            lid = int(row.get("league_id") or 0)
            if lid not in counts:
                counts[lid] = {
                    "league_id": lid,
                    "league_name": str(row.get("league_name") or "?"),
                    "match_count": 0,
                }
            counts[lid]["match_count"] += 1

        self.league_rows = sorted(counts.values(), key=lambda x: (x["league_name"].lower(), x["league_id"]))

        existing = {lid: var.get() for lid, var in self.league_vars.items()}
        self.league_vars = {}

        for child in self.league_inner.winfo_children():
            child.destroy()

        for row in self.league_rows:
            lid = int(row["league_id"])
            default_val = True if initial else existing.get(lid, True)
            var = tk.BooleanVar(value=default_val)
            self.league_vars[lid] = var
            txt = f"{row['league_name']} ({row['match_count']})"
            cb = tk.Checkbutton(
                self.league_inner,
                text=txt,
                variable=var,
                bg=CARD,
                fg=TEXT,
                selectcolor=CARD_2,
                activebackground=CARD,
                activeforeground=TEXT,
                font=FONT_SMALL,
                anchor="w",
                justify="left",
                command=self.apply_league_filter_to_center,
            )
            cb.pack(fill="x", anchor="w", pady=1)

    def select_all_leagues(self):
        for var in self.league_vars.values():
            var.set(True)
        self.apply_league_filter_to_center()

    def clear_league_selection(self):
        for var in self.league_vars.values():
            var.set(False)
        self.apply_league_filter_to_center()

    def apply_league_filter_to_center(self):
        enabled = {lid for lid, var in self.league_vars.items() if var.get()}
        self.visible_matches = [row for row in self.all_matches if int(row.get("league_id") or 0) in enabled]
        self.render_match_rows()

    # ========================================================
    # Match rendering
    # ========================================================
    def render_match_rows(self):
        self.match_row_widgets = {}
        for child in self.match_inner.winfo_children():
            child.destroy()

        if not self.visible_matches:
            tk.Label(self.match_inner, text="Žádné zápasy pro vybrané soutěže.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", padx=10, pady=10)
            return

        fixed_key_set = {item.key() for item in self.fixed_items}
        block_map = {item.match_id: item.block_index for bi in (1, 2, 3) for item in self.block_items[bi]}

        grouped: dict[str, list[dict]] = {}
        for row in self.visible_matches:
            grouped.setdefault(str(row.get("league_name") or "?"), []).append(row)

        row_index = 0
        for league_name in sorted(grouped.keys()):
            self._render_league_section(league_name, grouped[league_name])
            for row in grouped[league_name]:
                self.render_match_row(row, row_index, fixed_key_set, block_map)
                row_index += 1

    def update_match_selection_styles(self):
        fixed_key_set = {item.key() for item in self.fixed_items}
        block_map = {item.match_id: item.block_index for bi in (1, 2, 3) for item in self.block_items[bi]}
        for match_id, refs in self.match_row_widgets.items():
            for code, btn in refs.get("odds_buttons", {}).items():
                key = ("FIXED", match_id, refs.get("market_codes", {}).get(code, "H2H"), code, 0)
                is_selected = key in fixed_key_set
                is_supported = refs.get("supported", {}).get(code, False)
                if is_supported:
                    btn.configure(
                        bg=ODD_SELECTED if is_selected else ODD_BG,
                        fg=ODD_SELECTED_TEXT if is_selected else TEXT,
                        state="normal",
                    )
                else:
                    btn.configure(bg=CARD_2, fg=MUTED, state="disabled")
            current_block = block_map.get(match_id)
            for bi, btn in refs.get("block_buttons", {}).items():
                if current_block == bi:
                    bg_btn, fg_btn = BLOCK_COLORS[bi]
                elif current_block is None:
                    bg_btn, fg_btn = CARD_2, TEXT
                else:
                    bg_btn, fg_btn = CARD_3, MUTED
                btn.configure(bg=bg_btn, fg=fg_btn)

    def _render_league_section(self, league_name: str, rows: list[dict]):
        box = tk.Frame(self.match_inner, bg=CARD_2, height=30)
        box.pack(fill="x", padx=6, pady=(8, 2))
        box.pack_propagate(False)
        sample = rows[0] if rows else {}
        sport_code = str(sample.get("sport_code") or "")
        text = f"{self.sport_icon(sport_code)}  {league_name}  •  {len(rows)} zápasů"
        tk.Label(box, text=text, bg=CARD_2, fg=YELLOW, font=FONT_BOLD, anchor="w").pack(fill="both", padx=10)

    def render_match_row(self, row: dict, row_index: int, fixed_key_set: set, block_map: dict[int, int]):
        bg = CARD if row_index % 2 == 0 else CARD_3
        frame = tk.Frame(self.match_inner, bg=bg, height=46)
        frame.pack(fill="x", padx=6, pady=1)
        frame.pack_propagate(False)
        self._register_wheel_target(frame, self.match_canvas)

        match_id = int(row["match_id"])
        x = 0
        dc = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))
        match_text = f"{self.fmt_kickoff(row.get('kickoff'))}   {row.get('home_team')}  -  {row.get('away_team')}"
        tk.Label(frame, text=match_text, bg=bg, fg=TEXT, font=FONT_SMALL, anchor="w").place(x=x + 8, y=0, width=self.grid_columns[0][1] - 12, height=46)
        x += self.grid_columns[0][1]

        info_width = next(w for t, w, _ in self.grid_columns if t == 'i')
        info_btn = tk.Label(frame, text='i', bg=INFO_BTN_BG, fg=YELLOW, font=FONT_BOLD_XS, relief='flat', cursor='hand2')
        info_btn.place(x=x + 4, y=7, width=info_width - 8, height=30)
        info_btn.bind('<Button-1>', lambda _e, r=row: self.show_match_info(r))
        info_btn.bind('<Enter>', lambda _e: info_btn.configure(bg=INFO_BTN_HOVER))
        info_btn.bind('<Leave>', lambda _e: info_btn.configure(bg=INFO_BTN_BG))
        self._register_wheel_target(info_btn, self.match_canvas)
        x += info_width

        odds_map = {
            "1": row.get("odd_1"),
            "X": row.get("odd_x"),
            "2": row.get("odd_2"),
            "1X": dc["1X"],
            "12": dc["12"],
            "X2": dc["X2"],
        }

        refs = {"odds_buttons": {}, "block_buttons": {}, "supported": {}, "market_codes": {}}
        for code in ("1", "X", "2", "1X", "12", "X2"):
            width = next(w for t, w, _ in self.grid_columns if t == code)
            odd_value = odds_map[code]
            market_code, market_id, market_outcome_id = self.resolve_pick_market(code)
            is_supported = market_id is not None and market_outcome_id is not None and odd_value is not None
            refs["supported"][code] = is_supported
            refs["market_codes"][code] = market_code
            is_selected = ("FIXED", match_id, market_code, code, 0) in fixed_key_set if is_supported else False
            bg_btn = ODD_SELECTED if is_selected else (ODD_BG if is_supported else CARD_2)
            fg_btn = ODD_SELECTED_TEXT if is_selected else (TEXT if is_supported else MUTED)
            cmd = (lambda r=row, c=code, o=odd_value: self.toggle_fixed_pick(r, c, o)) if is_supported else None
            btn = tk.Button(frame, text=self.fmt_odds(odd_value), bg=bg_btn, fg=fg_btn, relief="flat", font=FONT_XS, command=cmd, state=("normal" if cmd else "disabled"))
            btn.place(x=x + 4, y=7, width=width - 8, height=30)
            self._register_wheel_target(btn, self.match_canvas)
            refs["odds_buttons"][code] = btn
            x += width

        current_block = block_map.get(match_id)
        for bi in (1, 2, 3):
            width = next(w for t, w, _ in self.grid_columns if t == self.block_label(bi))
            if current_block == bi:
                bg_btn, fg_btn = BLOCK_COLORS[bi]
            elif current_block is None:
                bg_btn, fg_btn = CARD_2, TEXT
            else:
                bg_btn, fg_btn = CARD_3, MUTED
            btn = tk.Button(
                frame,
                text=self.block_label(bi),
                bg=bg_btn,
                fg=fg_btn,
                relief="flat",
                font=FONT_BOLD_XS,
                command=lambda r=row, b=bi: self.toggle_block_pick(r, b),
            )
            btn.place(x=x + 4, y=7, width=width - 8, height=30)
            self._register_wheel_target(btn, self.match_canvas)
            refs["block_buttons"][bi] = btn
            x += width

        self.match_row_widgets[match_id] = refs

    def _safe_upper_text(self, value) -> str:
        return str(value or "").upper()

    def _form_sequence(self, value: Optional[str], limit: int) -> list[str]:
        raw = str(value or "").strip().upper()
        tokens = [ch for ch in raw if ch in ("W", "D", "L", "V", "R", "P")]
        normalized = []
        for ch in tokens[:limit]:
            if ch == "V":
                normalized.append("W")
            elif ch == "R":
                normalized.append("D")
            elif ch == "P":
                normalized.append("L")
            else:
                normalized.append(ch)
        return normalized

    def _render_form_boxes(self, parent, form_value: Optional[str], limit: int):
        wrap = tk.Frame(parent, bg=parent.cget("bg"))
        wrap.pack(anchor="w")

        mapping = {
            "W": ("V", "#22c55e", "#06120B"),  # výhra
            "D": ("R", "#eab308", "#201705"),  # remíza
            "L": ("P", "#ef4444", "#14071D"),  # prohra
        }

        tokens = self._form_sequence(form_value, limit)
        if not tokens:
            tk.Label(wrap, text="-", bg=parent.cget("bg"), fg=MUTED, font=FONT_SMALL).pack(side="left")
            return wrap

        for token in tokens:
            label, bg_box, fg_box = mapping.get(token, (token, CARD_2, TEXT))
            tk.Label(
                wrap,
                text=label,
                bg=bg_box,
                fg=fg_box,
                font=FONT_BOLD_XS,
                width=2,
                pady=2,
                relief="flat",
                bd=0,
                highlightthickness=0,
            ).pack(side="left", padx=(0, 3))

        return wrap

    def _load_match_detail_data(self, row: dict, match_id: int) -> dict:
        detail = {
            "league_name": row.get("league_name"),
            "sport_code": row.get("sport_code"),
            "kickoff": row.get("kickoff"),
            "home_team": row.get("home_team"),
            "away_team": row.get("away_team"),
            "odd_1": row.get("odd_1"),
            "odd_x": row.get("odd_x"),
            "odd_2": row.get("odd_2"),
            "home_rank": None,
            "away_rank": None,
            "home_form": None,
            "away_form": None,
            "home_played": None,
            "away_played": None,
            "home_points": None,
            "away_points": None,
            "home_goals_for": None,
            "home_goals_against": None,
            "away_goals_for": None,
            "away_goals_against": None,
            "home_form_10": None,
            "away_form_10": None,
            "home_form_15": None,
            "away_form_15": None,
            "home_points_last_5": None,
            "away_points_last_5": None,
            "home_points_last_10": None,
            "away_points_last_10": None,
            "home_points_last_15": None,
            "away_points_last_15": None,
            "home_wins": None,
            "draws": None,
            "away_wins": None,
            "league_id": None,
            "season": None,
            "home_team_id": None,
            "away_team_id": None,
            "table_rows": [],
            "h2h_home_rows": [],
        }
        try:
            db_row = self.fetchone(
                """
                WITH base_match AS (
                    SELECT
                        m.id,
                        m.league_id,
                        m.season,
                        m.home_team_id,
                        m.away_team_id
                    FROM public.matches m
                    WHERE m.id = %s
                ),
                home_ls AS (
                    SELECT ls.*
                    FROM public.league_standings ls
                    JOIN base_match bm
                      ON bm.league_id = ls.league_id
                     AND bm.season = ls.season
                     AND bm.home_team_id = ls.team_id
                ),
                away_ls AS (
                    SELECT ls.*
                    FROM public.league_standings ls
                    JOIN base_match bm
                      ON bm.league_id = ls.league_id
                     AND bm.season = ls.season
                     AND bm.away_team_id = ls.team_id
                ),
                h2h AS (
                    SELECT
                        COUNT(*) FILTER (
                            WHERE (
                                (m.home_team_id = bm.home_team_id AND m.away_team_id = bm.away_team_id AND m.home_score > m.away_score)
                                OR
                                (m.home_team_id = bm.away_team_id AND m.away_team_id = bm.home_team_id AND m.away_score > m.home_score)
                            )
                        ) AS home_wins,
                        COUNT(*) FILTER (WHERE m.home_score = m.away_score) AS draws,
                        COUNT(*) FILTER (
                            WHERE (
                                (m.home_team_id = bm.away_team_id AND m.away_team_id = bm.home_team_id AND m.home_score > m.away_score)
                                OR
                                (m.home_team_id = bm.home_team_id AND m.away_team_id = bm.away_team_id AND m.away_score > m.home_score)
                            )
                        ) AS away_wins
                    FROM base_match bm
                    JOIN public.matches m
                      ON (
                            (m.home_team_id = bm.home_team_id AND m.away_team_id = bm.away_team_id)
                         OR (m.home_team_id = bm.away_team_id AND m.away_team_id = bm.home_team_id)
                         )
                     AND m.status = 'FINISHED'
                )
                SELECT
                    bm.league_id,
                    bm.season,
                    bm.home_team_id,
                    bm.away_team_id,
                    hl.position AS home_rank,
                    al.position AS away_rank,
                    hl.form_last_5 AS home_form,
                    al.form_last_5 AS away_form,
                    hl.played AS home_played,
                    al.played AS away_played,
                    hl.points AS home_points,
                    al.points AS away_points,
                    hl.goals_for AS home_goals_for,
                    hl.goals_against AS home_goals_against,
                    al.goals_for AS away_goals_for,
                    al.goals_against AS away_goals_against,
                    hl.form_last_10 AS home_form_10,
                    al.form_last_10 AS away_form_10,
                    hl.form_last_15 AS home_form_15,
                    al.form_last_15 AS away_form_15,
                    hl.points_last_5 AS home_points_last_5,
                    al.points_last_5 AS away_points_last_5,
                    hl.points_last_10 AS home_points_last_10,
                    al.points_last_10 AS away_points_last_10,
                    hl.points_last_15 AS home_points_last_15,
                    al.points_last_15 AS away_points_last_15,
                    h2h.home_wins,
                    h2h.draws,
                    h2h.away_wins
                FROM base_match bm
                LEFT JOIN home_ls hl ON TRUE
                LEFT JOIN away_ls al ON TRUE
                LEFT JOIN h2h ON TRUE
                """,
                (match_id,),
            )
            if db_row:
                detail.update(db_row)
                league_id = db_row.get("league_id")
                season = db_row.get("season")
                home_team_id = db_row.get("home_team_id")
                away_team_id = db_row.get("away_team_id")
                if league_id is not None and season is not None:
                    detail["table_rows"] = self.fetchall(
                        """
                        SELECT
                            ls.team_id,
                            t.name AS team_name,
                            ls.position,
                            ls.played,
                            ls.wins,
                            ls.draws,
                            ls.losses,
                            ls.goals_for,
                            ls.goals_against,
                            ls.goal_diff,
                            ls.points,
                            ls.home_played,
                            ls.home_wins,
                            ls.home_draws,
                            ls.home_losses,
                            ls.home_goals_for,
                            ls.home_goals_against,
                            ls.home_goal_diff,
                            ls.home_points,
                            ls.away_played,
                            ls.away_wins,
                            ls.away_draws,
                            ls.away_losses,
                            ls.away_goals_for,
                            ls.away_goals_against,
                            ls.away_goal_diff,
                            ls.away_points,
                            ls.form_last_5,
                            ls.form_last_10,
                            ls.form_last_15,
                            ls.points_last_5,
                            ls.points_last_10,
                            ls.points_last_15
                        FROM public.league_standings ls
                        JOIN public.teams t ON t.id = ls.team_id
                        WHERE ls.league_id = %s
                          AND ls.season = %s
                        ORDER BY ls.position NULLS LAST, t.name
                        """,
                        (league_id, season),
                    )
                if home_team_id is not None and away_team_id is not None:
                    detail["h2h_home_rows"] = self.fetchall(
                        """
                        SELECT
                            m.kickoff,
                            m.home_score,
                            m.away_score,
                            ht.name AS home_team,
                            at.name AS away_team
                        FROM public.matches m
                        JOIN public.teams ht ON ht.id = m.home_team_id
                        JOIN public.teams at ON at.id = m.away_team_id
                        WHERE m.status = 'FINISHED'
                          AND m.home_team_id = %s
                          AND m.away_team_id = %s
                        ORDER BY m.kickoff DESC
                        LIMIT 5
                        """,
                        (home_team_id, away_team_id),
                    )
        except Exception:
            pass
        return detail


    def _build_match_info_overview(self, parent, detail: dict):
        info = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        info.pack(fill="x", padx=0, pady=(0, 6))
        tk.Label(info, text="Rychlý panel", bg=CARD, fg=YELLOW, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(8, 6))

        grid = tk.Frame(info, bg=CARD)
        grid.pack(fill="x", padx=10, pady=(0, 8))
        for col in range(3):
            grid.grid_columnconfigure(col, weight=1)

        headers = ["", "Domácí", "Hosté"]
        for col, txt in enumerate(headers):
            tk.Label(
                grid,
                text=txt,
                bg=CARD,
                fg=YELLOW if col else MUTED,
                font=FONT_BOLD_XS if col else FONT_XS
            ).grid(row=0, column=col, sticky="w", padx=4, pady=(0, 4))

        summary_rows = [
            ("Postavení", f"#{detail.get('home_rank') or '-'}", f"#{detail.get('away_rank') or '-'}"),
            ("Body / zápasy", f"{detail.get('home_points') if detail.get('home_points') is not None else '-'} b / {detail.get('home_played') if detail.get('home_played') is not None else '-'} z.", f"{detail.get('away_points') if detail.get('away_points') is not None else '-'} b / {detail.get('away_played') if detail.get('away_played') is not None else '-'} z."),
            ("Skóre", f"{detail.get('home_goals_for') if detail.get('home_goals_for') is not None else '-'}:{detail.get('home_goals_against') if detail.get('home_goals_against') is not None else '-'}", f"{detail.get('away_goals_for') if detail.get('away_goals_for') is not None else '-'}:{detail.get('away_goals_against') if detail.get('away_goals_against') is not None else '-'}"),
        ]
        for ridx, (label, home_val, away_val) in enumerate(summary_rows, start=1):
            tk.Label(grid, text=label, bg=CARD, fg=MUTED, font=FONT_SMALL).grid(row=ridx, column=0, sticky="w", padx=4, pady=3)
            tk.Label(grid, text=home_val, bg=CARD_2, fg=TEXT, font=FONT_SMALL, padx=6, pady=3).grid(row=ridx, column=1, sticky="ew", padx=4, pady=3)
            tk.Label(grid, text=away_val, bg=CARD_2, fg=TEXT, font=FONT_SMALL, padx=6, pady=3).grid(row=ridx, column=2, sticky="ew", padx=4, pady=3)

        h2h = tk.Frame(info, bg=CARD)
        h2h.pack(fill="x", padx=10, pady=(0, 8))
        tk.Label(h2h, text="H2H", bg=CARD, fg=MUTED, font=FONT_SMALL, width=10, anchor="w").pack(side="left")
        tk.Label(
            h2h,
            text=f"Domácí výhry: {detail.get('home_wins') if detail.get('home_wins') is not None else '-'} | Remízy: {detail.get('draws') if detail.get('draws') is not None else '-'} | Hosté výhry: {detail.get('away_wins') if detail.get('away_wins') is not None else '-'}",
            bg=CARD,
            fg=TEXT,
            font=FONT_SMALL,
            anchor="w"
        ).pack(side="left", fill="x", expand=True)

    def _build_match_info_form(self, parent, detail: dict):
        controls = tk.Frame(parent, bg=BG)
        controls.pack(fill="x", padx=0, pady=(0, 6))
        tk.Label(controls, text="Forma", bg=BG, fg=YELLOW, font=FONT_SECTION).pack(side="left")
        form_var = tk.StringVar(value="5")

        content = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        content.pack(fill="x", padx=0, pady=(0, 6))

        def render():
            for child in content.winfo_children():
                child.destroy()
            selected = int(form_var.get())
            tk.Label(content, text=f"Posledních {selected} zápasů", bg=CARD, fg=YELLOW, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(8, 6))
            rows = [
                ("Domácí", detail.get("home_form") if selected == 5 else detail.get("home_form_10") if selected == 10 else detail.get("home_form_15"), detail.get("home_points_last_5") if selected == 5 else detail.get("home_points_last_10") if selected == 10 else detail.get("home_points_last_15")),
                ("Hosté", detail.get("away_form") if selected == 5 else detail.get("away_form_10") if selected == 10 else detail.get("away_form_15"), detail.get("away_points_last_5") if selected == 5 else detail.get("away_points_last_10") if selected == 10 else detail.get("away_points_last_15")),
            ]
            for label, form_value, pts in rows:
                line = tk.Frame(content, bg=CARD)
                line.pack(fill="x", padx=10, pady=(0, 6))
                tk.Label(line, text=label, bg=CARD, fg=MUTED, font=FONT_SMALL, width=8, anchor="w").pack(side="left")
                form_wrap = tk.Frame(line, bg=CARD)
                form_wrap.pack(side="left", padx=(0, 6))
                self._render_form_boxes(form_wrap, form_value, selected)
                tk.Label(line, text=f"{pts if pts is not None else '-'} b", bg=CARD_2, fg=TEXT, font=FONT_XS, padx=6, pady=2).pack(side="left")

        form_buttons = []
        for count in (5, 10, 15):
            btn = tk.Button(
                controls,
                text=str(count),
                bg=ACCENT if form_var.get() == str(count) else CARD_2,
                fg=BG if form_var.get() == str(count) else TEXT,
                relief="flat",
                font=FONT_BOLD_XS,
                command=lambda c=count: [form_var.set(str(c)), refresh_buttons(), render()],
            )
            btn.pack(side="left", padx=(8 if count == 5 else 4, 0), ipady=2)
            form_buttons.append(btn)

        def refresh_buttons():
            for btn in form_buttons:
                active = btn.cget("text") == form_var.get()
                btn.configure(bg=ACCENT if active else CARD_2, fg=BG if active else TEXT)

        render()

    def _build_match_info_table(self, parent, detail: dict):
        controls = tk.Frame(parent, bg=BG)
        controls.pack(fill="x", padx=6, pady=(0, 6))
        tk.Label(controls, text="Tabulka soutěže", bg=BG, fg=YELLOW, font=FONT_SECTION).pack(side="left")
        scope_var = tk.StringVar(value="CELKEM")
        form_var = tk.StringVar(value="5")

        table_box = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        table_box.pack(fill="both", expand=True, padx=6, pady=(0, 6))

        table_font = ("Segoe UI", 7)
        table_bold = ("Segoe UI", 7, "bold")
        row_h = 28

        def metric_values(r: dict):
            scope = scope_var.get()
            if scope == "DOMA":
                played = r.get("home_played")
                wins = r.get("home_wins")
                draws = r.get("home_draws")
                losses = r.get("home_losses")
                gf = r.get("home_goals_for")
                ga = r.get("home_goals_against")
                gd = r.get("home_goal_diff")
                pts = r.get("home_points")
            elif scope == "VENKU":
                played = r.get("away_played")
                wins = r.get("away_wins")
                draws = r.get("away_draws")
                losses = r.get("away_losses")
                gf = r.get("away_goals_for")
                ga = r.get("away_goals_against")
                gd = r.get("away_goal_diff")
                pts = r.get("away_points")
            else:
                played = r.get("played")
                wins = r.get("wins")
                draws = r.get("draws")
                losses = r.get("losses")
                gf = r.get("goals_for")
                ga = r.get("goals_against")
                gd = r.get("goal_diff")
                pts = r.get("points")
            return played, wins, draws, losses, gf, ga, gd, pts

        def form_for_row(r: dict):
            count = int(form_var.get())
            if count == 5:
                return r.get("form_last_5")
            if count == 10:
                return r.get("form_last_10")
            return r.get("form_last_15")

        def render_table():
            for child in table_box.winfo_children():
                child.destroy()

            head = tk.Frame(table_box, bg=CARD_2, height=row_h)
            head.pack(fill="x", padx=8, pady=(8, 0))
            head.pack_propagate(False)
            cols = [("#", 38), ("Tým", 230), ("Z", 36), ("V", 36), ("R", 36), ("P", 36), ("G", 68), ("RS", 48), ("B", 48), ("Forma", 220)]
            x = 0
            for title, width in cols:
                tk.Label(head, text=title, bg=CARD_2, fg=YELLOW, font=table_font).place(x=x, y=0, width=width, height=row_h)
                x += width

            body = tk.Frame(table_box, bg=CARD)
            body.pack(fill="both", expand=True, padx=8, pady=(0, 8))

            rows = detail.get("table_rows") or []
            if not rows:
                tk.Label(body, text="Tabulka pro tuto soutěž zatím není k dispozici.", bg=CARD, fg=MUTED, font=FONT_SMALL).pack(anchor="w", padx=10, pady=10)
                return

            for idx, r in enumerate(rows):
                team_id = r.get("team_id")
                position = r.get("position") or 0
                fg_team = TEXT

                # základní zebra
                bg_row = CARD if idx % 2 == 0 else CARD_3

                # TOP zóny
                if position <= 4:
                    bg_row = "#1e3a5f"

                # sestupové zóny - poslední 3 týmy
                if position >= (len(rows) - 2):
                    bg_row = "#5a1e1e"

                # zvýraznění vybraných týmů má prioritu
                if team_id == detail.get("home_team_id"):
                    bg_row = "#123A67"

                if team_id == detail.get("away_team_id"):
                    bg_row = "#6A3D00"

                rowf = tk.Frame(body, bg=bg_row, height=row_h)
                rowf.pack(fill="x", pady=1)
                rowf.pack_propagate(False)

                played, wins, draws, losses, gf, ga, gd, pts = metric_values(r)
                values = [
                    str(position if position else "-"),
                    str(r.get("team_name") or "?"),
                    str(played if played is not None else "-"),
                    str(wins if wins is not None else "-"),
                    str(draws if draws is not None else "-"),
                    str(losses if losses is not None else "-"),
                    f"{gf if gf is not None else '-'}:{ga if ga is not None else '-'}",
                    str(gd if gd is not None else "-"),
                    str(pts if pts is not None else "-"),
                ]
                widths = [38, 230, 36, 36, 36, 36, 68, 48, 48]
                x = 0
                for col_idx, (val, width) in enumerate(zip(values, widths)):
                    anchor = "w" if col_idx == 1 else "center"
                    padx = 8 if col_idx == 1 else 0
                    tk.Label(
                        rowf,
                        text=val,
                        bg=bg_row,
                        fg=fg_team,
                        font=table_font if col_idx != 1 else table_bold,
                        anchor=anchor
                    ).place(x=x + padx, y=0, width=width - padx, height=row_h)
                    x += width

                form_wrap = tk.Frame(rowf, bg=bg_row)
                form_wrap.place(x=x + 6, y=4, width=208, height=20)
                self._render_form_boxes(form_wrap, form_for_row(r), int(form_var.get()))

        scope_buttons = []
        for scope in ("CELKEM", "DOMA", "VENKU"):
            btn = tk.Button(
                controls,
                text=scope,
                bg=ACCENT if scope == "CELKEM" else CARD_2,
                fg=BG if scope == "CELKEM" else TEXT,
                relief="flat",
                font=FONT_BOLD_XS,
                command=lambda s=scope: [scope_var.set(s), refresh_scope_buttons(), render_table()],
            )
            btn.pack(side="left", padx=(8 if scope == "CELKEM" else 4, 0), ipady=2)
            scope_buttons.append(btn)

        form_buttons = []
        for count in (5, 10, 15):
            btn = tk.Button(
                controls,
                text=str(count),
                bg=ACCENT if count == 5 else CARD_2,
                fg=BG if count == 5 else TEXT,
                relief="flat",
                font=FONT_BOLD_XS,
                command=lambda c=count: [form_var.set(str(c)), refresh_form_buttons(), render_table()],
            )
            btn.pack(side="left", padx=(10 if count == 5 else 4, 0), ipady=2)
            form_buttons.append(btn)

        def refresh_scope_buttons():
            for btn in scope_buttons:
                active = btn.cget("text") == scope_var.get()
                btn.configure(bg=ACCENT if active else CARD_2, fg=BG if active else TEXT)

        def refresh_form_buttons():
            for btn in form_buttons:
                active = btn.cget("text") == form_var.get()
                btn.configure(bg=ACCENT if active else CARD_2, fg=BG if active else TEXT)

        render_table()

    def _build_match_info_h2h(self, parent, detail: dict):
        card = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        card.pack(fill="both", expand=True, padx=0, pady=(0, 6))
        tk.Label(card, text="Posledních 5 vzájemných zápasů na tomto hřišti", bg=CARD, fg=YELLOW, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(8, 6))
        summary = tk.Frame(card, bg=CARD)
        summary.pack(fill="x", padx=10, pady=(0, 8))
        tk.Label(summary, text=f"Bilance: {detail.get('home_wins') if detail.get('home_wins') is not None else '-'} / {detail.get('draws') if detail.get('draws') is not None else '-'} / {detail.get('away_wins') if detail.get('away_wins') is not None else '-'}", bg=CARD_2, fg=TEXT, font=FONT_SMALL, padx=8, pady=4).pack(anchor="w")
        rows = detail.get("h2h_home_rows") or []
        if not rows:
            tk.Label(card, text="Zatím bez dat o vzájemných zápasech na tomto hřišti.", bg=CARD, fg=MUTED, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(0, 10))
            return
        for idx, r in enumerate(rows):
            bg_row = CARD if idx % 2 == 0 else CARD_3
            line = tk.Frame(card, bg=bg_row, height=30)
            line.pack(fill="x", padx=10, pady=1)
            line.pack_propagate(False)
            left = f"{self.fmt_kickoff(r.get('kickoff'))}   {r.get('home_team')}"
            score = f"{r.get('home_score') if r.get('home_score') is not None else '-'}:{r.get('away_score') if r.get('away_score') is not None else '-'}"
            right = str(r.get('away_team') or '?')
            tk.Label(line, text=left, bg=bg_row, fg=TEXT, font=FONT_SMALL, anchor="w").pack(side="left", fill="x", expand=True, padx=8)
            tk.Label(line, text=score, bg=CARD_2, fg=YELLOW, font=FONT_BOLD_XS, padx=8, pady=2).pack(side="left", padx=8)
            tk.Label(line, text=right, bg=bg_row, fg=TEXT, font=FONT_SMALL, anchor="e").pack(side="right", padx=8)

    def show_match_info(self, row: dict):
        match_id = int(row.get("match_id") or 0)
        if match_id <= 0:
            return

        if match_id not in self.match_detail_cache:
            self.match_detail_cache[match_id] = self._load_match_detail_data(row, match_id)

        detail = self.match_detail_cache[match_id]

        win = tk.Toplevel(self.root)
        win.title(f"Detail zápasu #{match_id}")
        win.geometry("1220x900")
        win.minsize(1020, 780)
        win.configure(bg=BG)

        # =====================================================
        # HEADER
        # =====================================================
        top = tk.Frame(win, bg=BG)
        top.pack(fill="x", padx=10, pady=8)

        tk.Label(
            top,
            text=f"{detail.get('home_team')}  vs  {detail.get('away_team')}",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE,
            anchor="w"
        ).pack(anchor="w")

        tk.Label(
            top,
            text=f"{detail.get('league_name')} • {self.fmt_kickoff(detail.get('kickoff'))} • {detail.get('sport_code')}",
            bg=BG,
            fg=MUTED,
            font=FONT_SMALL,
            anchor="w"
        ).pack(anchor="w", pady=(4, 0))

        # =====================================================
        # MAIN LAYOUT
        # =====================================================
        main_frame = tk.Frame(win, bg=BG)
        main_frame.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        left_wrap = tk.Frame(main_frame, bg=BG, width=360)
        left_wrap.pack(side="left", fill="y", expand=False, padx=(0, 8), anchor="n")
        left_wrap.pack_propagate(False)

        right_wrap = tk.Frame(main_frame, bg=BG)
        right_wrap.pack(side="left", fill="both", expand=True)

        # =====================================================
        # LEFT - ODDS
        # =====================================================
        odds = tk.Frame(left_wrap, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        odds.pack(fill="x", pady=(0, 6))

        tk.Label(
            odds,
            text="Kurzy zápasu",
            bg=CARD,
            fg=YELLOW,
            font=FONT_SECTION
        ).grid(row=0, column=0, columnspan=3, sticky="w", padx=10, pady=(8, 6))

        dc = self.compute_double_chance_odds(detail.get("odd_1"), detail.get("odd_x"), detail.get("odd_2"))
        odds_items = (
            ("1", detail.get("odd_1")),
            ("X", detail.get("odd_x")),
            ("2", detail.get("odd_2")),
            ("1X", dc.get("1X")),
            ("12", dc.get("12")),
            ("X2", dc.get("X2")),
        )

        for i, (lbl, val) in enumerate(odds_items):
            box = tk.Frame(odds, bg=CARD_2, bd=0, highlightthickness=0)
            r = 1 if i < 3 else 2
            c = i % 3
            box.grid(row=r, column=c, sticky="ew", padx=6, pady=(0, 6))
            odds.grid_columnconfigure(c, weight=1)

            tk.Label(
                box,
                text=lbl,
                bg=CARD_2,
                fg=MUTED,
                font=FONT_XS
            ).pack(pady=(4, 1))

            tk.Label(
                box,
                text=self.fmt_odds(val),
                bg=CARD_2,
                fg=TEXT,
                font=FONT_BOLD
            ).pack(pady=(0, 5))

        # =====================================================
        # LEFT - ACTION BUTTONS 2x3
        # =====================================================
        action = tk.Frame(left_wrap, bg=BG)
        action.pack(fill="x", pady=(0, 6))

        action_grid = tk.Frame(action, bg=BG)
        action_grid.pack(anchor="w")

        btn_specs = [
            ("Přidat FIX 1", ODD_SELECTED, ODD_SELECTED_TEXT, lambda: self.toggle_fixed_pick(row, "1", detail.get("odd_1"))),
            ("Přidat FIX X", CARD_2, TEXT, lambda: self.toggle_fixed_pick(row, "X", detail.get("odd_x"))),
            ("Přidat FIX 2", ODD_SELECTED, ODD_SELECTED_TEXT, lambda: self.toggle_fixed_pick(row, "2", detail.get("odd_2"))),
            ("Do bloku A", BLOCK_COLORS[1][0], BLOCK_COLORS[1][1], lambda: self.toggle_block_pick(row, 1)),
            ("Do bloku B", BLOCK_COLORS[2][0], BLOCK_COLORS[2][1], lambda: self.toggle_block_pick(row, 2)),
            ("Do bloku C", BLOCK_COLORS[3][0], BLOCK_COLORS[3][1], lambda: self.toggle_block_pick(row, 3)),
        ]

        for idx, (txt, bg_btn, fg_btn, cmd) in enumerate(btn_specs):
            rr = idx // 3
            cc = idx % 3
            tk.Button(
                action_grid,
                text=txt,
                bg=bg_btn,
                fg=fg_btn,
                relief="flat",
                bd=0,
                highlightthickness=0,
                font=("Segoe UI", 8),
                padx=8,
                pady=3,
                width=13,
                command=cmd
            ).grid(row=rr, column=cc, padx=(0, 4), pady=(0, 4), sticky="w")

        # =====================================================
        # LEFT - NAV
        # =====================================================
        nav = tk.Frame(left_wrap, bg=BG)
        nav.pack(fill="x", pady=(0, 6))

        left_content = tk.Frame(left_wrap, bg=BG)
        left_content.pack(fill="x", expand=False)

        right_content = tk.Frame(right_wrap, bg=BG)
        right_content.pack(fill="both", expand=True)

        view_var = tk.StringVar(value="FORMA")
        nav_buttons = []

        def render_view():
            for child in left_content.winfo_children():
                child.destroy()
            for child in right_content.winfo_children():
                child.destroy()

            self._build_match_info_overview(left_content, detail)

            if view_var.get() == "FORMA":
                self._build_match_info_form(left_content, detail)
            elif view_var.get() == "H2H":
                self._build_match_info_h2h(left_content, detail)
            elif view_var.get() == "TABULKA":
                placeholder = tk.Frame(left_content, bg=CARD, highlightthickness=1, highlightbackground=LINE)
                placeholder.pack(fill="x", padx=6, pady=(0, 6))
                tk.Label(
                    placeholder,
                    text="Tabulka soutěže je zobrazena vpravo.",
                    bg=CARD,
                    fg=MUTED,
                    font=FONT_SMALL,
                    anchor="w",
                    justify="left"
                ).pack(fill="x", padx=10, pady=8)

            self._build_match_info_table(right_content, detail)

            for btn in nav_buttons:
                active = btn.cget("text") == view_var.get()
                btn.configure(bg=ACCENT if active else CARD_2, fg=BG if active else TEXT)

        for name in ("FORMA", "TABULKA", "H2H"):
            btn = tk.Button(
                nav,
                text=name,
                bg="#2a1f5a",
                fg=TEXT,
                relief="flat",
                bd=0,
                highlightthickness=0,
                font=("Segoe UI", 8, "bold"),
                padx=8,
                pady=3,
                command=lambda n=name: [view_var.set(n), render_view()]
            )
            btn.pack(side="left", padx=(0, 4))
            nav_buttons.append(btn)

        # =====================================================
        # LEFT - SUMMARY
        # =====================================================
        summary = tk.Frame(left_wrap, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        summary.pack(fill="x", pady=(6, 0))

        signal = []
        if self.safe_decimal(detail.get("odd_1")) and self.safe_decimal(detail.get("odd_2")):
            o1 = self.safe_decimal(detail.get("odd_1"))
            o2 = self.safe_decimal(detail.get("odd_2"))
            if o1 and o2:
                if abs(o1 - o2) <= Decimal("0.25"):
                    signal.append("Vyrovnaný zápas bez jasného favorita.")
                elif o1 < o2:
                    signal.append("Trh mírně preferuje domácí.")
                else:
                    signal.append("Trh mírně preferuje hosty.")

        if detail.get("home_form") or detail.get("away_form"):
            signal.append("Forma je orientační a slouží jako rychlý doplněk pro výběr.")

        tk.Label(
            summary,
            text="Shrnutí",
            bg=CARD,
            fg=YELLOW,
            font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(8, 6))

        tk.Label(
            summary,
            text=" ".join(signal) if signal else "Detail panel je připravený, další grafické doladění doplníme v další verzi.",
            bg=CARD,
            fg=TEXT,
            font=("Segoe UI", 9),
            justify="left",
            wraplength=320
        ).pack(anchor="w", padx=10, pady=(0, 10))

        render_view()

    # ========================================================
    # Local selection logic
    # ========================================================
    def toggle_fixed_pick(self, row: dict, outcome_code: str, odd_value):
        item = self.make_fixed_from_row(row, outcome_code, odd_value)
        if item is None:
            messagebox.showerror("Chyba", "Nepodařilo se dohledat market / outcome pro FIX pick.")
            return

        key = item.key()
        before = len(self.fixed_items)
        self.fixed_items = [x for x in self.fixed_items if x.key() != key]
        if len(self.fixed_items) == before:
            self.fixed_items.append(item)

        self.update_match_selection_styles()
        self.refresh_ticket_panel()
        self.refresh_summary()

    def toggle_block_pick(self, row: dict, block_index: int):
        match_id = int(row["match_id"])
        was_in_target = any(x.match_id == match_id for x in self.block_items[block_index])

        for bi in (1, 2, 3):
            self.block_items[bi] = [x for x in self.block_items[bi] if x.match_id != match_id]

        if was_in_target:
            self.update_match_selection_styles()
            self.refresh_ticket_panel()
            self.refresh_summary()
            return

        if len(self.block_items[block_index]) >= 3:
            messagebox.showwarning("Limit bloku", f"Blok {self.block_label(block_index)} už má 3 zápasy.")
            self.update_match_selection_styles()
            return

        item = self.make_block_from_row(row, block_index)
        if item is None:
            messagebox.showerror("Chyba", "Nepodařilo se vytvořit block pick.")
            return
        self.block_items[block_index].append(item)
        self.update_match_selection_styles()
        self.refresh_ticket_panel()
        self.refresh_summary()

    def remove_fixed_item(self, idx: int):
        if 0 <= idx < len(self.fixed_items):
            self.fixed_items.pop(idx)
            self.refresh_all_panels()

    def remove_block_item(self, block_index: int, idx: int):
        items = self.block_items.get(block_index, [])
        if 0 <= idx < len(items):
            items.pop(idx)
            self.refresh_all_panels()

    def clear_local_state(self):
        self.fixed_items = []
        self.block_items = {1: [], 2: [], 3: []}
        self.generated_rows = []
        self.generated_checks = []
        self.generated_probabilities = {}
        self.preview_badge_var.set("bez preview")
        self.last_run_id_var.set("-")
        self.runtime_status_var.set("Lokální stav vyčištěn.")
        self.runtime_text.delete("1.0", "end")
        self.update_match_selection_styles()
        self.refresh_ticket_panel()
        self.refresh_summary()

    def refresh_all_panels(self):
        self.render_match_rows()
        self.refresh_ticket_panel()
        self.refresh_summary()

    def refresh_ticket_panel(self):
        for child in self.ticket_inner.winfo_children():
            child.destroy()

        total_entries = len(self.fixed_items) + sum(len(v) for v in self.block_items.values())
        self.ticket_count_var.set(f"{total_entries} výběrů")

        if total_entries == 0:
            empty = tk.Frame(self.ticket_inner, bg=TICKET_CARD, highlightthickness=1, highlightbackground=LINE)
            empty.pack(fill="x", pady=(0, 8))
            tk.Label(empty, text="Tiket je prázdný", bg=TICKET_CARD, fg=TEXT, font=FONT_BOLD).pack(anchor="w", padx=10, pady=(10, 2))
            tk.Label(empty, text="Klikni na kurz 1/X/2 pro FIX nebo na A/B/C pro zařazení zápasu do bloku.", bg=TICKET_CARD, fg=MUTED, font=FONT_SMALL, wraplength=360, justify="left").pack(anchor="w", padx=10, pady=(0, 10))
            return

        if self.fixed_items:
            self._render_ticket_section_header("FIX")
            for idx, item in enumerate(self.fixed_items):
                self._render_fixed_item_card(item, lambda i=idx: self.remove_fixed_item(i))

        for bi in (1, 2, 3):
            if self.block_items[bi]:
                self._render_ticket_section_header(f"Blok {self.block_label(bi)}")
                for idx, item in enumerate(self.block_items[bi]):
                    self._render_block_item_card(item, bi, lambda b=bi, i=idx: self.remove_block_item(b, i))

    def _render_ticket_section_header(self, text: str):
        row = tk.Frame(self.ticket_inner, bg=TICKET_BG)
        row.pack(fill="x", pady=(2, 6))
        tk.Label(row, text=text, bg=CARD_2, fg=YELLOW, font=FONT_XS, padx=7, pady=2).pack(anchor="w")

    def _render_fixed_item_card(self, item: PickItem, remove_cmd):
        card = tk.Frame(self.ticket_inner, bg=TICKET_CARD, highlightthickness=1, highlightbackground=LINE)
        card.pack(fill="x", pady=(0, 4))

        row1 = tk.Frame(card, bg=TICKET_CARD)
        row1.pack(fill="x", padx=8, pady=(6, 2))
        tk.Label(
            row1,
            text=f"{self.sport_icon(item.sport_code)} {item.home_team} - {item.away_team}",
            bg=TICKET_CARD,
            fg=TEXT,
            font=FONT_SMALL if self.zoom_percent <= 100 else FONT_BOLD,
            anchor="w",
        ).pack(side="left", fill="x", expand=True)
        tk.Button(row1, text="✕", bg=TICKET_CARD, fg=RED, relief="flat", font=FONT_BOLD_XS, command=remove_cmd, padx=2, pady=0).pack(side="right")

        row2 = tk.Frame(card, bg=TICKET_CARD)
        row2.pack(fill="x", padx=8, pady=(0, 6))
        left_text = f"{item.league_name} • {self.fmt_kickoff(item.kickoff)} • Výsledek zápasu: {item.outcome_code}"
        tk.Label(row2, text=left_text, bg=TICKET_CARD, fg=MUTED, font=FONT_XS, anchor="w").pack(side="left", fill="x", expand=True)
        tk.Label(row2, text=f"@ {self.fmt_odds(item.odd_value)}", bg=CARD_2, fg=TEXT, font=FONT_XS, padx=8, pady=2).pack(side="right")

    def _render_block_item_card(self, item: PickItem, block_index: int, remove_cmd):
        bg_card = TICKET_CARD if block_index % 2 == 1 else TICKET_CARD_ALT
        badge_bg, badge_fg = BLOCK_COLORS[block_index]
        card = tk.Frame(self.ticket_inner, bg=bg_card, highlightthickness=1, highlightbackground=LINE)
        card.pack(fill="x", pady=(0, 4))

        row1 = tk.Frame(card, bg=bg_card)
        row1.pack(fill="x", padx=8, pady=(6, 2))
        tk.Label(
            row1,
            text=f"{self.sport_icon(item.sport_code)} {item.home_team} - {item.away_team}",
            bg=bg_card,
            fg=TEXT,
            font=FONT_SMALL if self.zoom_percent <= 100 else FONT_BOLD,
            anchor="w",
        ).pack(side="left", fill="x", expand=True)
        tk.Button(row1, text="✕", bg=bg_card, fg=RED, relief="flat", font=FONT_BOLD_XS, command=remove_cmd, padx=2, pady=0).pack(side="right")

        row2 = tk.Frame(card, bg=bg_card)
        row2.pack(fill="x", padx=8, pady=(0, 6))
        left_text = f"{item.league_name} • {self.fmt_kickoff(item.kickoff)} • Výsledek zápasu: Blok {self.block_label(block_index)}"
        tk.Label(row2, text=left_text, bg=bg_card, fg=MUTED, font=FONT_XS, anchor="w").pack(side="left", fill="x", expand=True)
        tk.Label(row2, text=f"Blok {self.block_label(block_index)}", bg=badge_bg, fg=badge_fg, font=FONT_XS, padx=8, pady=2).pack(side="right")

    def refresh_summary(self):
        fixed_odds = [item.odd_value for item in self.fixed_items if item.odd_value is not None and item.odd_value > 0]
        total_fixed = Decimal("1")
        for odd in fixed_odds:
            total_fixed *= odd

        block_sizes = [len(self.block_items[bi]) for bi in (1, 2, 3) if self.block_items[bi]]
        combo_count = 1
        for _size in block_sizes:
            combo_count *= 3
        combo_count = max(combo_count, 1)

        total_odd = total_fixed
        stake = self.safe_decimal(self.stake_var.get()) or Decimal("100")
        total_stake = stake * Decimal(combo_count)
        total_return = total_odd * stake

        self.metric_odds_var.set(f"{total_odd:.2f}")
        self.metric_combos_var.set(str(combo_count))
        self.metric_stake_var.set(f"{total_stake:.2f} Kč")
        self.metric_return_var.set(f"{total_return:.2f} Kč")

    def set_stake(self, amount: int):
        self.stake_var.set(str(amount))
        self.refresh_summary()

    # ========================================================
    # Template DB
    # ========================================================
    def _local_variable_block_count(self) -> int:
        return sum(1 for bi in (1, 2, 3) if self.block_items[bi])

    def _local_expected_combo_count(self) -> int:
        count = 1
        for bi in (1, 2, 3):
            if self.block_items[bi]:
                count *= 3
        return count

    def _ensure_template_row(self, cur, template_id: int):
        cur.execute(
            """
            INSERT INTO public.templates (id, name, max_variable_blocks)
            VALUES (%s, %s, 3)
            ON CONFLICT (id) DO UPDATE
            SET name = EXCLUDED.name,
                max_variable_blocks = 3
            """,
            (template_id, f"Ticket Studio Template {template_id}"),
        )

    def _persist_template_state(self, template_id: int):
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                self._ensure_template_row(cur, template_id)
                cur.execute("SET LOCAL session_replication_role = replica")
                cur.execute("DELETE FROM public.template_fixed_picks WHERE template_id = %s", (template_id,))
                cur.execute("DELETE FROM public.template_block_matches WHERE template_id = %s", (template_id,))
                cur.execute("DELETE FROM public.template_blocks WHERE template_id = %s", (template_id,))

                used_blocks = [bi for bi in (1, 2, 3) if self.block_items[bi]]
                for bi in used_blocks:
                    cur.execute(
                        """
                        INSERT INTO public.template_blocks (template_id, block_index, block_type)
                        VALUES (%s, %s, 'VARIABLE')
                        """,
                        (template_id, bi),
                    )
                    for item in self.block_items[bi]:
                        cur.execute(
                            """
                            INSERT INTO public.template_block_matches (template_id, block_index, match_id, market_id)
                            VALUES (%s, %s, %s, %s)
                            """,
                            (template_id, bi, item.match_id, item.market_id),
                        )

                for item in self.fixed_items:
                    if item.market_outcome_id is None:
                        continue
                    cur.execute(
                        """
                        INSERT INTO public.template_fixed_picks (
                            template_id, match_id, market_id, market_outcome_id
                        )
                        VALUES (%s, %s, %s, %s)
                        """,
                        (template_id, item.match_id, item.market_id, item.market_outcome_id),
                    )
            conn.commit()

    def save_template_to_db(self, show_message: bool = True) -> bool:
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            if show_message:
                messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return False

        try:
            self._persist_template_state(template_id)
            if show_message:
                messagebox.showinfo("OK", f"Template {template_id} uložen do DB.")
            return True
        except Exception as e:
            if show_message:
                messagebox.showerror("Chyba při uložení", str(e))
            return False

    def ensure_runtime_template_synced(self) -> bool:
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return False
        ok = self.save_template_to_db(show_message=False)
        if not ok:
            messagebox.showerror("Chyba", "Nepodařilo se synchronizovat aktuální lokální template do DB před runtime během.")
            return False
        return True
    def delete_template_from_db(self):
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return
        if not messagebox.askyesno("Potvrzení", f"Opravdu smazat template {template_id}?"):
            return
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SET LOCAL session_replication_role = replica")
                    cur.execute("DELETE FROM public.template_fixed_picks WHERE template_id = %s", (template_id,))
                    cur.execute("DELETE FROM public.template_block_matches WHERE template_id = %s", (template_id,))
                    cur.execute("DELETE FROM public.template_blocks WHERE template_id = %s", (template_id,))
                conn.commit()
            self.clear_local_state()
            messagebox.showinfo("OK", f"Template {template_id} vyčištěn.")
        except Exception as e:
            messagebox.showerror("Chyba při mazání", str(e))

    def load_template_from_db(self):
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return
        try:
            fixed_rows = self.fetchall(
                """
                SELECT
                    tfp.match_id,
                    COALESCE(tfp.market_id, mo.market_id) AS market_id,
                    tfp.market_outcome_id,
                    mk.code AS market_code,
                    mo.code AS outcome_code,
                    COALESCE(sp.code, '?') AS sport_code,
                    COALESCE(l.name, '?') AS league_name,
                    COALESCE(ht.name, '?') AS home_team,
                    COALESCE(at.name, '?') AS away_team,
                    m.kickoff
                FROM public.template_fixed_picks tfp
                JOIN public.matches m ON m.id = tfp.match_id
                LEFT JOIN public.leagues l ON l.id = m.league_id
                LEFT JOIN public.sports sp ON sp.id = COALESCE(m.sport_id, l.sport_id)
                LEFT JOIN public.teams ht ON ht.id = m.home_team_id
                LEFT JOIN public.teams at ON at.id = m.away_team_id
                LEFT JOIN public.market_outcomes mo ON mo.id = tfp.market_outcome_id
                LEFT JOIN public.markets mk ON mk.id = COALESCE(tfp.market_id, mo.market_id)
                WHERE tfp.template_id = %s
                ORDER BY m.kickoff, tfp.match_id
                """,
                (template_id,),
            )
            block_rows = self.fetchall(
                """
                SELECT
                    tbm.block_index,
                    tbm.match_id,
                    tbm.market_id,
                    mk.code AS market_code,
                    COALESCE(sp.code, '?') AS sport_code,
                    COALESCE(l.name, '?') AS league_name,
                    COALESCE(ht.name, '?') AS home_team,
                    COALESCE(at.name, '?') AS away_team,
                    m.kickoff
                FROM public.template_block_matches tbm
                JOIN public.matches m ON m.id = tbm.match_id
                LEFT JOIN public.leagues l ON l.id = m.league_id
                LEFT JOIN public.sports sp ON sp.id = COALESCE(m.sport_id, l.sport_id)
                LEFT JOIN public.teams ht ON ht.id = m.home_team_id
                LEFT JOIN public.teams at ON at.id = m.away_team_id
                LEFT JOIN public.markets mk ON mk.id = tbm.market_id
                WHERE tbm.template_id = %s
                ORDER BY tbm.block_index, m.kickoff, tbm.match_id
                """,
                (template_id,),
            )

            self.fixed_items = []
            self.block_items = {1: [], 2: [], 3: []}

            for row in fixed_rows:
                self.fixed_items.append(
                    PickItem(
                        item_type="FIXED",
                        match_id=self.safe_int(row.get("match_id"), 0),
                        market_id=self.safe_int(row.get("market_id"), self.get_h2h_market_id() or 0),
                        market_code=str(row.get("market_code") or "H2H"),
                        market_outcome_id=self.safe_int(row.get("market_outcome_id"), 0) if row.get("market_outcome_id") is not None else None,
                        outcome_code=str(row.get("outcome_code") or ""),
                        odd_value=None,
                        sport_code=str(row.get("sport_code") or ""),
                        league_name=str(row.get("league_name") or ""),
                        home_team=str(row.get("home_team") or "?"),
                        away_team=str(row.get("away_team") or "?"),
                        kickoff=row.get("kickoff"),
                    )
                )

            for row in block_rows:
                bi = self.safe_int(row.get("block_index"), 0)
                if bi not in self.block_items:
                    continue
                self.block_items[bi].append(
                    PickItem(
                        item_type="BLOCK",
                        match_id=self.safe_int(row.get("match_id"), 0),
                        market_id=self.safe_int(row.get("market_id"), self.get_h2h_market_id() or 0),
                        market_code=str(row.get("market_code") or "H2H"),
                        market_outcome_id=None,
                        outcome_code=None,
                        odd_value=None,
                        sport_code=str(row.get("sport_code") or ""),
                        league_name=str(row.get("league_name") or ""),
                        home_team=str(row.get("home_team") or "?"),
                        away_team=str(row.get("away_team") or "?"),
                        kickoff=row.get("kickoff"),
                        block_index=bi,
                    )
                )

            self.runtime_status_var.set(f"Template {template_id} načten z DB.")
            self.refresh_all_panels()
            messagebox.showinfo("OK", f"Template {template_id} načten.")
        except Exception as e:
            messagebox.showerror("Chyba při načtení", str(e))

    # ========================================================
    # Runtime engine
    # ========================================================
    def log_runtime(self, text: str, clear: bool = False):
        if clear:
            self.runtime_text.delete("1.0", "end")
        self.runtime_text.insert("end", text + "\n")
        self.runtime_text.see("end")

    def preview_runtime_run(self):
        if not self.ensure_runtime_template_synced():
            return
        template_id = self.safe_int(self.template_id_var.get(), 0)
        bookmaker_id = self.get_bookmaker_id()
        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return
        if bookmaker_id is None:
            messagebox.showerror("Chyba", "Vyber bookmaker.")
            return

        try:
            row = self.fetchone(
                "SELECT * FROM public.mm_preview_run(%s, %s)",
                (template_id, bookmaker_id),
            )
            if not row:
                self.preview_badge_var.set("bez dat")
                self.runtime_status_var.set("Preview nevrátil žádná data.")
                self.log_runtime("Preview nevrátil žádná data.", clear=True)
                return

            est = row.get("estimated_tickets")
            warnings = row.get("preview_warnings") or []
            details = row.get("preview_blocks_detail")
            self.preview_badge_var.set(f"{est} tiketů")
            self.runtime_status_var.set("Preview hotový." if not warnings else "Preview hotový, ale obsahuje varování.")
            self.log_runtime("=== PREVIEW RUN ===", clear=True)
            self.log_runtime(f"template_id      : {template_id}")
            self.log_runtime(f"bookmaker_id     : {bookmaker_id}")
            self.log_runtime(f"local_blocks     : {self._local_variable_block_count()}")
            self.log_runtime(f"local_combo_est  : {self._local_expected_combo_count()}")
            self.log_runtime(f"variable_blocks  : {row.get('variable_blocks')}")
            self.log_runtime(f"fixed_picks      : {row.get('fixed_picks')}")
            self.log_runtime(f"estimated_tickets: {est}")
            self.log_runtime("warnings         : " + (" | ".join(warnings) if warnings else "bez varování"))
            self.log_runtime("blocks_detail    :")
            self.log_runtime(json.dumps(details, ensure_ascii=False, indent=2, default=str))
        except Exception as e:
            self.preview_badge_var.set("chyba")
            self.runtime_status_var.set("Preview spadl na chybě.")
            self.log_runtime(f"PREVIEW ERROR: {e}", clear=True)
            messagebox.showerror("Preview chyba", str(e))

    def generate_runtime_run(self):
        if not self.ensure_runtime_template_synced():
            return
        template_id = self.safe_int(self.template_id_var.get(), 0)
        bookmaker_id = self.get_bookmaker_id()
        max_tickets = self.safe_int(self.max_tickets_var.get(), 5000)
        min_probability = self.safe_decimal(self.min_probability_var.get()) if self.min_probability_var.get().strip() else None
        stake = self.safe_decimal(self.stake_var.get()) or Decimal("100")

        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return
        if bookmaker_id is None:
            messagebox.showerror("Chyba", "Vyber bookmaker.")
            return

        try:
            row = self.fetchone(
                "SELECT public.mm_generate_run_engine(%s, %s, %s, %s) AS run_id",
                (template_id, bookmaker_id, max_tickets, min_probability),
            )
            if not row or row.get("run_id") is None:
                raise RuntimeError("Generate run nevrátil run_id.")

            run_id = int(row["run_id"])
            self.last_run_id_var.set(str(run_id))
            self.runtime_status_var.set(f"Run {run_id} vygenerován.")

            summary = self.fetchone(
                "SELECT * FROM public.mm_ui_run_summary(%s, %s)",
                (run_id, stake),
            )
            tickets = self.fetchall(
                "SELECT * FROM public.mm_ui_run_tickets_with_stake(%s, %s)",
                (run_id, stake),
            )
            self.generated_rows = tickets
            self.generated_checks = [tk.BooleanVar(value=True) for _ in tickets]
            prob_rows = self.fetchall(
                "SELECT ticket_index, probability FROM public.generated_tickets WHERE run_id = %s",
                (run_id,),
            )
            self.generated_probabilities = {int(r['ticket_index']): float(r['probability']) for r in prob_rows if r.get('ticket_index') is not None and r.get('probability') is not None}

            self.log_runtime("=== GENERATE RUN ===", clear=True)
            self.log_runtime(f"run_id           : {run_id}")
            self.log_runtime(f"local_blocks     : {self._local_variable_block_count()}")
            self.log_runtime(f"local_combo_est  : {self._local_expected_combo_count()}")
            self.log_runtime(f"tickets_count    : {len(tickets)}")
            if summary:
                self.log_runtime(f"total_stake      : {summary.get('total_stake')}")
                self.log_runtime(f"max_total_odd    : {summary.get('max_total_odd')}")
                self.log_runtime(f"min_total_odd    : {summary.get('min_total_odd')}")
                self.log_runtime(f"avg_total_odd    : {summary.get('avg_total_odd')}")
                self.log_runtime(f"max_possible_win : {summary.get('max_possible_win')}")

            if summary:
                self.metric_combos_var.set(str(summary.get("tickets_count") or 0))
                self.metric_stake_var.set(self.fmt_money(summary.get("total_stake")))
                self.metric_return_var.set(self.fmt_money(summary.get("max_possible_win")))
                avg_odd = summary.get("avg_total_odd") or summary.get("max_total_odd") or Decimal("1")
                self.metric_odds_var.set(self.fmt_odds(avg_odd))

            self.preview_badge_var.set(f"{len(tickets)} generated")
            if tickets:
                self.show_generated_overview()
            else:
                messagebox.showwarning("Bez výsledku", "Run proběhl, ale nevrátil žádné tikety.")
        except Exception as e:
            self.runtime_status_var.set("Generate run spadl na chybě.")
            self.log_runtime(f"GENERATE ERROR: {e}", clear=True)
            messagebox.showerror("Generate chyba", str(e))

    # ========================================================
    # Save tickets overview
    # ========================================================
    def save_current_run_full(self):
        run_id = self.safe_int(self.last_run_id_var.get(), 0)
        if hasattr(self, "_last_saved_run_id") and self._last_saved_run_id == run_id:
            messagebox.showwarning("Uložení runu", f"Run {run_id} už byl uložen.")
            return
        if run_id <= 0:
            messagebox.showerror("Uložení runu", "Nejdřív vygeneruj run přes GENERATE.")
            return

        try:
            row = self.fetchone(
                "SELECT * FROM public.mm_save_generated_run_full(%s)",
                (run_id,),
            )
            if not row:
                raise RuntimeError("DB funkce nevrátila žádný výsledek.")

            self.runtime_status_var.set(
                f"Run {run_id} uložen. Ticket ID: {row.get('out_ticket_ref_id')}"
            )

            self.log_runtime("=== SAVE RUN FULL ===", clear=False)
            self.log_runtime(f"run_id                 : {row.get('out_run_id')}")
            self.log_runtime(f"ticket_id              : {row.get('out_ticket_ref_id')}")
            self.log_runtime(f"tickets_rows           : {row.get('out_tickets_rows')}")
            self.log_runtime(f"ticket_blocks_rows     : {row.get('out_ticket_blocks_rows')}")
            self.log_runtime(f"ticket_block_matches   : {row.get('out_ticket_block_matches_rows')}")
            self.log_runtime(f"history_inserted_rows  : {row.get('out_history_inserted_rows')}")
            self.log_runtime(f"history_updated_rows   : {row.get('out_history_updated_rows')}")
            self.log_runtime(f"status                 : {row.get('out_status_text')}")

            messagebox.showinfo(
                "Uložení runu",
                f"Run {run_id} byl uložen.\n\n"
                f"Ticket ID: {row.get('out_ticket_ref_id')}\n"
                f"Status: {row.get('out_status_text')}"
            )

            self._last_saved_run_id = run_id
            
        except Exception as e:
            self.runtime_status_var.set("Uložení runu spadlo na chybě.")
            self.log_runtime(f"SAVE RUN ERROR: {e}", clear=False)
            messagebox.showerror("Uložení runu", str(e))

    # ========================================================
    # Generated tickets overview
    # ========================================================
    def show_generated_overview(self):
        if not self.generated_rows:
            messagebox.showinfo("Přehled tiketů", "Zatím nejsou vygenerované žádné tikety.")
            return

        win = tk.Toplevel(self.root)
        win.title("MatchMatrix Ticket Studio V3 - Přehled tiketů")
        win.geometry("1500x900")
        win.configure(bg=BG)

        top = tk.Frame(win, bg=BG)
        top.pack(fill="x", padx=10, pady=10)
        title_wrap = tk.Frame(top, bg=BG)
        title_wrap.pack(side="left")
        tk.Label(title_wrap, text="Přehled vygenerovaných tiketů", bg=BG, fg=TEXT, font=FONT_TITLE).pack(anchor="w")
        tk.Label(title_wrap, text="FIX detailnější • bloky kratší • plný detail všech zápasů bude v samostatném výstupu", bg=BG, fg=MUTED, font=FONT_XS).pack(anchor="w")
        tk.Button(top, text="Export CSV", bg=ACCENT, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.export_generated_csv).pack(side="right", ipady=3)

        header = tk.Frame(win, bg=CARD_2, height=34)
        header.pack(fill="x", padx=10)
        header.pack_propagate(False)
        columns = [
            ("✓", 40),
            ("Komb.", 70),
            ("FIX", OVERVIEW_FIX_W),
            ("Blok A", OVERVIEW_BLOCK_W),
            ("Blok B", OVERVIEW_BLOCK_W),
            ("Blok C", OVERVIEW_BLOCK_W),
            ("Kurz", OVERVIEW_ODD_W),
            ("Výhra", OVERVIEW_WIN_W),
            ("%", OVERVIEW_PRED_W),
            ("Predikce", 150),
        ]
        x = 0
        for title, width in columns:
            tk.Label(header, text=title, bg=CARD_2, fg=YELLOW, font=FONT_XS).place(x=x, y=0, width=width, height=34)
            x += width

        body = tk.Frame(win, bg=BG)
        body.pack(fill="both", expand=True, padx=10, pady=(0, 8))
        outer, _canvas, inner = self.create_scrollable_vertical(body, BG)
        outer.pack(fill="both", expand=True)

        for idx, row in enumerate(self.generated_rows):
            bg = CARD if idx % 2 == 0 else CARD_3
            line = tk.Frame(inner, bg=bg, height=34)
            line.pack(fill="x", pady=1)
            line.pack_propagate(False)
            parsed = self.describe_generated_row(row)
            values = [
                self.generated_checks[idx],
                str(row.get("ticket_index") or idx + 1),
                parsed["fixed"],
                parsed["A"],
                parsed["B"],
                parsed["C"],
                parsed["total_odd"],
                parsed["possible_win"],
                self.fmt_percent(parsed["probability"]),
                self.describe_ticket_prediction(row),
            ]
            x = 0
            widths = [40, 70, OVERVIEW_FIX_W, OVERVIEW_BLOCK_W, OVERVIEW_BLOCK_W, OVERVIEW_BLOCK_W, OVERVIEW_ODD_W, OVERVIEW_WIN_W, OVERVIEW_PRED_W, 150]
            for col_idx, width in enumerate(widths):
                if col_idx == 0:
                    tk.Checkbutton(line, variable=values[0], bg=bg, fg=CHECK_TEXT, activebackground=bg, activeforeground=CHECK_TEXT, selectcolor=CHECK_SELECT, relief='flat').place(x=x + 8, y=7, width=24, height=20)
                else:
                    tk.Label(line, text=str(values[col_idx]), bg=bg, fg=TEXT, font=FONT_XS, anchor="w").place(x=x + 4, y=0, width=width - 8, height=34)
                x += width

        summary = tk.Frame(win, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        summary.pack(fill="x", padx=10, pady=(0, 10))
        self.generated_summary_var = tk.StringVar(value="")
        tk.Label(summary, textvariable=self.generated_summary_var, bg=CARD, fg=TEXT, font=FONT_SMALL, anchor="w", justify="left").pack(fill="x", padx=10, pady=8)
        self.refresh_generated_summary()

        toolbar = tk.Frame(win, bg=BG)
        toolbar.pack(fill="x", padx=10, pady=(0, 10))
        tk.Button(toolbar, text="Vybrat vše", bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=lambda: self.set_generated_checks(True)).pack(side="left", padx=(0, 4), ipady=2)
        tk.Button(toolbar, text="Zrušit vše", bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=lambda: self.set_generated_checks(False)).pack(side="left", padx=(0, 4), ipady=2)
        tk.Button(toolbar, text="Přepočítat souhrn", bg=BLUE, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.refresh_generated_summary).pack(side="left", ipady=2)

    def describe_ticket_prediction(self, row: dict) -> str:
        prob = self.generated_probabilities.get(int(row.get("ticket_index") or 0))
        total_odd = self.safe_decimal(row.get("total_odd"))
        items = row.get("items") or []

        outcome_codes = []
        for entry in items:
            outcome_code = self.lookup_outcome_code(self.safe_int(entry.get("market_outcome_id"), 0))
            if outcome_code:
                outcome_codes.append(str(outcome_code).upper())

        home_count = sum(1 for x in outcome_codes if x == "1")
        draw_count = sum(1 for x in outcome_codes if x == "X")
        away_count = sum(1 for x in outcome_codes if x == "2")

        bias_text = None
        if home_count > away_count and home_count >= draw_count:
            bias_text = "Převaha domácích"
        elif away_count > home_count and away_count >= draw_count:
            bias_text = "Převaha hostů"
        elif draw_count > home_count and draw_count > away_count:
            bias_text = "Remízová varianta"

        risk_text = None
        if prob is not None:
            if prob >= 0.60:
                risk_text = "silnější kombinace"
            elif prob >= 0.40:
                risk_text = "vyrovnaná kombinace"
            else:
                risk_text = "rizikovější tiket"
        elif total_odd is not None:
            if total_odd <= Decimal("3.00"):
                risk_text = "konzervativní tiket"
            elif total_odd <= Decimal("6.00"):
                risk_text = "střední riziko"
            else:
                risk_text = "vyšší riziko"

        if bias_text and risk_text:
            return f"{bias_text}, {risk_text}"
        if bias_text:
            return bias_text
        if risk_text:
            return risk_text
        return "Bez predikce"

    def describe_generated_row(self, row: dict) -> dict:
        items = row.get("items") or []
        probability = self.generated_probabilities.get(int(row.get("ticket_index") or 0))
        stake = self.safe_decimal(self.stake_var.get()) or Decimal("100")

        fixed_product = Decimal("1")
        fixed_values = []
        for item in self.fixed_items:
            odd_val = self.safe_decimal(getattr(item, "odd_value", None))
            if odd_val is None or odd_val <= 0:
                continue
            fixed_product *= odd_val
            fixed_values.append(self.fmt_odds(odd_val))

        block_products = {"A": Decimal("1"), "B": Decimal("1"), "C": Decimal("1")}
        block_values = {"A": [], "B": [], "C": []}
        block_outcome = {"A": None, "B": None, "C": None}

        for entry in items:
            bi = int(entry.get("block_index") or 0)
            label = self.block_label(bi)
            if label not in block_products:
                continue
            odd_val = self.safe_decimal(entry.get("odd"))
            if odd_val is None or odd_val <= 0:
                continue
            block_products[label] *= odd_val
            block_values[label].append(self.fmt_odds(odd_val))
            if block_outcome[label] is None:
                block_outcome[label] = self.lookup_outcome_code(self.safe_int(entry.get("market_outcome_id"), 0))

        total_product = Decimal("1")
        used_parts = 0
        if fixed_values:
            total_product *= fixed_product
            used_parts += 1
        for label in ("A", "B", "C"):
            if block_values[label]:
                total_product *= block_products[label]
                used_parts += 1
        if used_parts == 0:
            total_product = Decimal("0")
        possible_win = total_product * stake if total_product > 0 else Decimal("0")

        def block_text(label: str) -> str:
            vals = block_values[label]
            if not vals:
                return "-"
            prefix = block_outcome[label] or "?"
            return f"{prefix}: {' × '.join(vals)} = {self.fmt_odds(block_products[label])}"

        fixed_text = "-"
        if fixed_values:
            if len(fixed_values) <= 3:
                fixed_text = f"{' × '.join(fixed_values)} = {self.fmt_odds(fixed_product)}"
            else:
                fixed_text = f"{' × '.join(fixed_values[:3])} ... ({len(fixed_values)} záp.) = {self.fmt_odds(fixed_product)}"

        return {
            "fixed": fixed_text,
            "A": block_text("A"),
            "B": block_text("B"),
            "C": block_text("C"),
            "total_odd": self.fmt_odds(total_product) if total_product > 0 else "-",
            "possible_win": self.fmt_money(possible_win),
            "probability": probability,
        }

    def lookup_outcome_code(self, market_outcome_id: int) -> Optional[str]:
        if market_outcome_id <= 0:
            return None
        for (market_code, outcome_code), mo_id in self.market_outcome_ids.items():
            if mo_id == market_outcome_id:
                return outcome_code
        try:
            row = self.fetchone("SELECT code FROM public.market_outcomes WHERE id = %s", (market_outcome_id,))
            return str(row.get("code")) if row else None
        except Exception:
            return None

    def set_generated_checks(self, value: bool):
        for var in self.generated_checks:
            var.set(value)
        self.refresh_generated_summary()

    def refresh_generated_summary(self):
        if not hasattr(self, "generated_summary_var"):
            return
        selected = [row for row, var in zip(self.generated_rows, self.generated_checks) if var.get()]
        stake = self.safe_decimal(self.stake_var.get()) or Decimal("100")
        total_stake = stake * Decimal(len(selected))
        max_win = sum((self.safe_decimal(self.describe_generated_row(r).get("possible_win")) or Decimal("0")) for r in selected)
        probs = [self.generated_probabilities.get(int(row.get("ticket_index") or 0), 0.0) for row in selected]
        agg_prob = sum(probs)
        self.generated_summary_var.set(
            f"Vybráno: {len(selected)} tiketů    |    Celkem vsazeno: {total_stake:.2f} Kč    |    Možná výhra: {max_win:.2f} Kč    |    Agregovaná pravděpodobnost: {agg_prob * 100:.2f} %"
        )

    def export_generated_csv(self):
        if not self.generated_rows:
            messagebox.showinfo("Export CSV", "Není co exportovat.")
            return
        path = filedialog.asksaveasfilename(
            title="Uložit CSV",
            defaultextension=".csv",
            filetypes=[("CSV", "*.csv")],
            initialfile="matchmatrix_ticket_overview_v3_fix11.csv",
        )
        if not path:
            return
        try:
            with open(path, "w", newline="", encoding="utf-8-sig") as f:
                writer = csv.writer(f, delimiter=";")
                writer.writerow(["selected", "ticket_index", "fixed", "block_a", "block_b", "block_c", "total_odd", "possible_win", "probability"])
                run_id = self.safe_int(self.last_run_id_var.get(), 0)
                for row, var in zip(self.generated_rows, self.generated_checks):
                    parsed = self.describe_generated_row(row)
                    writer.writerow([
                        1 if var.get() else 0,
                        row.get("ticket_index"),
                        parsed["fixed"],
                        parsed["A"],
                        parsed["B"],
                        parsed["C"],
                        self.fmt_odds(row.get("total_odd")),
                        self.fmt_money(row.get("possible_win")),
                        self.fmt_percent(parsed["probability"]),
                    ])
            messagebox.showinfo("Export CSV", f"Export hotový.\n\n{path}")
        except Exception as e:
            messagebox.showerror("Export CSV", str(e))


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    app = TicketStudioV3(root)
    root.mainloop()


if __name__ == "__main__":
    main()
