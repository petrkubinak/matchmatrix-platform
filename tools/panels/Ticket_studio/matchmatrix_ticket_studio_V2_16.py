# -*- coding: utf-8 -*-
from __future__ import annotations

import tkinter as tk
from tkinter import ttk
from decimal import Decimal

from matchmatrix_ticket_studio_V2_15_fix import TicketStudioV215
from matchmatrix_ticket_studio_V2_9 import BET_GREEN, BET_GREEN_DARK, BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_SOFT, BET_LINE
from matchmatrix_ticket_studio_V2_12 import BLUE, CARD, CARD_2, PANEL_LINE_SOFT, RED, YELLOW
from matchmatrix_ticket_studio_V2_7 import BG, TEXT, MUTED, ACCENT, FONT, FONT_BOLD, FONT_SMALL, FONT_SECTION


FONT_XS = ("Segoe UI", 8)
FONT_SM = ("Segoe UI", 9)
FONT_SM_BOLD = ("Segoe UI", 9, "bold")
FONT_TITLE = ("Segoe UI", 15, "bold")

SPORT_LABELS = {
    "ALL": "Vše",
    "FB": "Fotbal",
    "HK": "Hokej",
    "TN": "Tenis",
    "BK": "Basketbal",
    "VB": "Volejbal",
    "HB": "Házená",
    "MMA": "MMA",
}

SPORT_ICONS = {
    "FB": "⚽",
    "HK": "🏒",
    "TN": "🎾",
    "BK": "🏀",
    "VB": "🏐",
    "HB": "🤾",
    "MMA": "🥊",
    "ALL": "⭐",
}

TIME_PRESETS = [
    ("3 hod.", "3 hours"),
    ("6 hod.", "6 hours"),
    ("24 hod.", "24 hours"),
    ("2 dny", "2 days"),
    ("Týden", "7 days"),
]


class TicketStudioV216(TicketStudioV215):
    def __init__(self, root: tk.Tk):
        self.time_filter_var = tk.StringVar(value="24 hours")
        self.sport_tabs_wrap = None
        self.ticket_list_inner = None
        self.ticket_empty_var = tk.StringVar(value="Tiket je prázdný")
        self.ticket_meta_var = tk.StringVar(value="Chceš-li přidat sázku na tiket, klikni na kurz u vybraného zápasu.")
        self.ticket_count_var = tk.StringVar(value="0 výběrů")
        self.total_odds_var = tk.StringVar(value="1.00")
        self.combo_count_var = tk.StringVar(value="1")
        self.total_stake_var = tk.StringVar(value="100.00 Kč")
        self.total_return_var = tk.StringVar(value="100.00 Kč")
        self.sport_name_map = dict(SPORT_LABELS)
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.16")
        self.viewport_var.set("desktop | product rebuild | sport tabs | fortuna ticket")
        self.refresh_all_panels()

    # -----------------------------------------------------
    # Layout
    # -----------------------------------------------------
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

        self.main_paned.add(self.left_panel, minsize=220)
        self.main_paned.add(self.center_panel, minsize=720)
        self.main_paned.add(self.right_panel, minsize=350)

        self.build_left_panel(self.left_panel)
        self.build_center_panel(self.center_panel)
        self.build_right_panel(self.right_panel)

    def init_pane_sizes(self):
        try:
            total = self.main_paned.winfo_width()
            if total <= 1:
                return
            left_w = max(230, int(total * 0.16))
            center_w = max(760, int(total * 0.60))
            self.main_paned.sashpos(0, left_w)
            self.main_paned.sashpos(1, left_w + center_w)
        except Exception:
            pass

    def build_header(self):
        if not hasattr(self, "viewport_var"):
            self.viewport_var = tk.StringVar(value="desktop | product rebuild | sport tabs | fortuna ticket")

        header = tk.Frame(self.root, bg=BG)
        header.pack(fill="x", padx=10, pady=(8, 6))
        header.grid_columnconfigure(0, weight=1)

        tk.Label(
            header,
            text="MatchMatrix Ticket Studio V2.16",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            header,
            text="sporty nahoře • užší levý filtr • tiket ve stylu pravého sloupce • kombinace v samostatném okně",
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

    # -----------------------------------------------------
    # Data load / sports
    # -----------------------------------------------------
    def load_sports(self):
        rows = self.fetchall(
            """
            SELECT code, COALESCE(name, code) AS name
            FROM public.sports
            WHERE is_active = TRUE
            ORDER BY sort_order NULLS LAST, name
            """
        )
        self.sport_name_map = {"ALL": "Vše"}
        values = ["ALL"]
        for row in rows:
            code = str(row.get("code") or "").strip()
            if not code:
                continue
            values.append(code)
            self.sport_name_map[code] = str(row.get("name") or SPORT_LABELS.get(code, code))

        if hasattr(self, "sport_combo"):
            self.sport_combo["values"] = values
        if not hasattr(self, "sport_var"):
            self.sport_var = tk.StringVar(value="ALL")
        self.sport_var.set("ALL")
        self.render_sport_tabs()

    def load_leagues_and_matches(self, initial: bool):
        sport_code = self.sport_var.get().strip() if hasattr(self, "sport_var") else "ALL"
        time_interval = self.time_filter_var.get().strip() if hasattr(self, "time_filter_var") else "24 hours"
        only_odds = self.only_odds_var.get() if hasattr(self, "only_odds_var") else True

        sql = """
            WITH odds_agg AS (
                SELECT
                    o.match_id,
                    MAX(CASE WHEN mo.code = '1' THEN o.odd_value END) AS odd_1,
                    MAX(CASE WHEN mo.code = 'X' THEN o.odd_value END) AS odd_x,
                    MAX(CASE WHEN mo.code = '2' THEN o.odd_value END) AS odd_2
                FROM public.odds o
                JOIN public.market_outcomes mo ON mo.id = o.market_outcome_id
                JOIN public.markets mk ON mk.id = mo.market_id
                WHERE lower(mk.code) IN (lower('h2h'), lower('1X2'))
                GROUP BY o.match_id
            )
            SELECT
                m.id AS match_id,
                m.kickoff,
                COALESCE(sp.code, '?') AS sport_code,
                COALESCE(l.id, 0) AS league_id,
                COALESCE(l.name, '?') AS league_name,
                COALESCE(ht.name, '?') AS home_team,
                COALESCE(at.name, '?') AS away_team,
                oa.odd_1,
                oa.odd_x,
                oa.odd_2
            FROM public.matches m
            LEFT JOIN public.leagues l ON l.id = m.league_id
            LEFT JOIN public.sports sp ON sp.id = l.sport_id
            LEFT JOIN public.teams ht ON ht.id = m.home_team_id
            LEFT JOIN public.teams at ON at.id = m.away_team_id
            LEFT JOIN odds_agg oa ON oa.match_id = m.id
            WHERE m.kickoff >= now()
              AND m.kickoff < now() + (%s)::interval
        """
        params: list = [time_interval]

        if sport_code and sport_code != "ALL":
            sql += " AND sp.code = %s"
            params.append(sport_code)

        if only_odds:
            sql += " AND oa.odd_1 IS NOT NULL AND oa.odd_x IS NOT NULL AND oa.odd_2 IS NOT NULL"

        sql += """
            ORDER BY l.name, m.kickoff ASC NULLS LAST, ht.name, at.name
            LIMIT 1000
        """

        self.all_matches = self.fetchall(sql, tuple(params))
        self.build_league_selector(initial=initial)
        self.apply_league_filter_to_center()

    # -----------------------------------------------------
    # Left panel
    # -----------------------------------------------------
    def build_left_panel(self, parent):
        parent.grid_rowconfigure(2, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_template_panel_left(parent)
        self.build_filter_panel_left(parent)
        self.build_league_panel_left(parent)

    def build_template_panel_left(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        frame.grid(row=0, column=0, sticky="ew", pady=(0, 8))

        top = tk.Frame(frame, bg=CARD)
        top.pack(fill="x", padx=8, pady=(8, 6))
        tk.Label(top, text="Template", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(side="left")

        row = tk.Frame(frame, bg=CARD)
        row.pack(fill="x", padx=8, pady=(0, 6))
        tk.Label(row, text="ID", bg=CARD, fg=TEXT, font=FONT_SMALL).pack(side="left")
        self.template_id_var = tk.StringVar(value="1")
        tk.Entry(row, textvariable=self.template_id_var, width=6, bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat").pack(side="left", padx=(6, 8), ipady=2)
        tk.Button(row, text="NAČÍST", bg=BLUE, fg=BG, font=FONT_SM_BOLD, relief="flat", command=self.load_template_from_db).pack(side="left", padx=(0, 6), ipady=2)
        tk.Button(row, text="ULOŽIT", bg=ACCENT, fg=BG, font=FONT_SM_BOLD, relief="flat", command=self.save_template_to_db).pack(side="left", ipady=2)

        row2 = tk.Frame(frame, bg=CARD)
        row2.pack(fill="x", padx=8, pady=(0, 8))
        tk.Button(row2, text="VYMAZAT LOKÁLNÍ", bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=self.clear_local_state).pack(side="left", padx=(0, 6), ipady=2)
        tk.Button(row2, text="SMAZAT V DB", bg=RED, fg=BG, font=FONT_XS, relief="flat", command=self.delete_template_from_db).pack(side="left", ipady=2)

    def build_filter_panel_left(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        frame.grid(row=1, column=0, sticky="ew", pady=(0, 8))

        tk.Label(frame, text="Sporty a čas", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=8, pady=(8, 6))

        self.sport_var = tk.StringVar(value="ALL")
        self.sport_combo = ttk.Combobox(frame, textvariable=self.sport_var, state="readonly", height=12)
        self.sport_combo.pack(fill="x", padx=8, pady=(0, 6))
        self.sport_combo.bind("<<ComboboxSelected>>", lambda _e: self.on_sport_changed())

        self.sport_tabs_wrap = tk.Frame(frame, bg=CARD)
        self.sport_tabs_wrap.pack(fill="x", padx=8, pady=(0, 6))

        tk.Label(frame, text="Časový filtr", bg=CARD, fg=TEXT, font=FONT_SMALL).pack(anchor="w", padx=8)
        chips = tk.Frame(frame, bg=CARD)
        chips.pack(fill="x", padx=8, pady=(4, 6))
        self.time_buttons = {}
        for idx, (label, interval_txt) in enumerate(TIME_PRESETS):
            btn = tk.Button(
                chips,
                text=label,
                bg=CARD_2,
                fg=TEXT,
                relief="flat",
                font=FONT_XS,
                command=lambda v=interval_txt: self.set_time_filter(v),
            )
            btn.grid(row=idx // 3, column=idx % 3, sticky="ew", padx=(0, 4), pady=(0, 4), ipadx=2, ipady=2)
            self.time_buttons[interval_txt] = btn
        for c in range(3):
            chips.grid_columnconfigure(c, weight=1)

        self.only_odds_var = tk.BooleanVar(value=True)
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
            text="NAČÍST NABÍDKU",
            bg=ACCENT,
            fg=BG,
            font=FONT_SM_BOLD,
            relief="flat",
            command=lambda: self.load_leagues_and_matches(initial=False),
        ).pack(fill="x", padx=8, pady=(0, 8), ipady=4)

        self.render_time_buttons()

    def build_league_panel_left(self, parent):
        body = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        body.grid(row=2, column=0, sticky="nsew")

        tk.Label(body, text="Soutěže", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=8, pady=(8, 4))

        tools = tk.Frame(body, bg=CARD)
        tools.pack(fill="x", padx=8, pady=(0, 6))
        tk.Button(tools, text="VŠE", bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=self.select_all_leagues).pack(side="left", padx=(0, 4), ipady=2)
        tk.Button(tools, text="NIC", bg=CARD_2, fg=TEXT, font=FONT_XS, relief="flat", command=self.clear_league_selection).pack(side="left", ipady=2)

        league_outer, _, self.league_list_inner = self.create_scrollable_vertical(body, CARD)
        league_outer.pack(fill="both", expand=True, padx=8, pady=(0, 8))

    def render_sport_tabs(self):
        if self.sport_tabs_wrap is None:
            return
        for w in self.sport_tabs_wrap.winfo_children():
            w.destroy()

        preferred = ["ALL", "FB", "HK", "TN", "BK", "VB"]
        available = [v for v in ["ALL"] + list(getattr(self.sport_combo, "cget", lambda _x: [])("values") or []) if v]
        values = []
        for code in preferred + list(available):
            if code in available and code not in values:
                values.append(code)

        row = 0
        col = 0
        for code in values[:6]:
            active = self.sport_var.get() == code
            label = f"{SPORT_ICONS.get(code, '•')} {self.sport_name_map.get(code, SPORT_LABELS.get(code, code))}"
            btn = tk.Button(
                self.sport_tabs_wrap,
                text=label,
                bg=ACCENT if active else CARD_2,
                fg=BG if active else TEXT,
                relief="flat",
                font=FONT_XS,
                command=lambda c=code: self.set_sport_filter(c),
            )
            btn.grid(row=row, column=col, sticky="ew", padx=(0, 4), pady=(0, 4), ipady=2)
            self.sport_tabs_wrap.grid_columnconfigure(col, weight=1)
            col += 1
            if col >= 2:
                col = 0
                row += 1

    def render_time_buttons(self):
        for interval_txt, btn in getattr(self, "time_buttons", {}).items():
            active = self.time_filter_var.get() == interval_txt
            btn.configure(bg=ACCENT if active else CARD_2, fg=BG if active else TEXT)

    def set_time_filter(self, interval_txt: str):
        self.time_filter_var.set(interval_txt)
        self.render_time_buttons()

    def set_sport_filter(self, sport_code: str):
        self.sport_var.set(sport_code)
        try:
            self.sport_combo.set(sport_code)
        except Exception:
            pass
        self.render_sport_tabs()

    def on_sport_changed(self):
        self.render_sport_tabs()

    # -----------------------------------------------------
    # Center panel tweaks
    # -----------------------------------------------------
    def build_center_panel(self, parent):
        super().build_center_panel(parent)
        try:
            for title, width, anchor in [
                ("ZÁPAS", 390, "w"),
                ("1", 52, "center"),
                ("X", 52, "center"),
                ("2", 52, "center"),
                ("1X", 52, "center"),
                ("12", 52, "center"),
                ("X2", 52, "center"),
                ("A", 36, "center"),
                ("B", 36, "center"),
                ("C", 36, "center"),
            ]:
                pass
        except Exception:
            pass

    # -----------------------------------------------------
    # Right panel
    # -----------------------------------------------------
    def build_right_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_runtime_panel_v216(parent)
        self.build_ticket_panel_v216(parent)
        self.build_ticket_totals_panel_v216(parent)

    def build_runtime_panel_v216(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=0, column=0, sticky="ew", pady=(0, 8))

        head = tk.Frame(frame, bg=BET_PANEL)
        head.pack(fill="x", padx=10, pady=(8, 6))
        tk.Label(head, text="Runtime engine", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(side="left")
        tk.Label(head, textvariable=self.preview_badge_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        tk.Label(frame, text="Bookmaker", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w", padx=10)
        self.bookmaker_combo = ttk.Combobox(frame, textvariable=self.bookmaker_var, state="readonly", height=12)
        self.bookmaker_combo.pack(fill="x", padx=10, pady=(3, 6))

        params = tk.Frame(frame, bg=BET_PANEL)
        params.pack(fill="x", padx=10, pady=(0, 6))
        params.grid_columnconfigure(0, weight=1)
        params.grid_columnconfigure(1, weight=1)

        p1 = tk.Frame(params, bg=BET_PANEL)
        p1.grid(row=0, column=0, sticky="ew", padx=(0, 4))
        tk.Label(p1, text="Max tiketů", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        tk.Entry(p1, textvariable=self.max_tickets_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_XS).pack(fill="x", pady=(3, 0), ipady=4)

        p2 = tk.Frame(params, bg=BET_PANEL)
        p2.grid(row=0, column=1, sticky="ew", padx=(4, 0))
        tk.Label(p2, text="Min. pravděpod.", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        tk.Entry(p2, textvariable=self.min_probability_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_XS).pack(fill="x", pady=(3, 0), ipady=4)

        acts = tk.Frame(frame, bg=BET_PANEL)
        acts.pack(fill="x", padx=10, pady=(0, 6))
        tk.Button(acts, text="PREVIEW", bg=BLUE, fg=BG, font=FONT_XS, relief="flat", command=self.preview_runtime_run).pack(side="left", padx=(0, 4), ipady=3)
        tk.Button(acts, text="GENERATE", bg=ACCENT, fg=BG, font=FONT_XS, relief="flat", command=self.generate_runtime_run).pack(side="left", padx=(0, 4), ipady=3)
        tk.Button(acts, text="POSLEDNÍ", bg=BET_PANEL_3, fg=TEXT, font=FONT_XS, relief="flat", command=self.show_last_run_details).pack(side="left", ipady=3)

        info = tk.Frame(frame, bg=BET_PANEL)
        info.pack(fill="x", padx=10, pady=(0, 8))
        tk.Label(info, text="Poslední run", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(side="left")
        tk.Label(info, textvariable=self.last_run_id_var, bg=BET_PANEL_2, fg=TEXT, font=FONT_XS, padx=6, pady=2).pack(side="left", padx=(6, 0))

    def build_ticket_panel_v216(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=1, column=0, sticky="nsew", pady=(0, 8))
        frame.grid_rowconfigure(1, weight=1)
        frame.grid_columnconfigure(0, weight=1)
        self.ticket_frame = frame

        head = tk.Frame(frame, bg=BET_PANEL)
        head.grid(row=0, column=0, sticky="ew", padx=10, pady=(8, 6))
        tk.Label(head, text="Tiket", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(side="left")
        tk.Label(head, textvariable=self.ticket_count_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        outer, _canvas, self.ticket_list_inner = self.create_scrollable_vertical(frame, BET_PANEL)
        outer.grid(row=1, column=0, sticky="nsew", padx=10, pady=(0, 10))

    def build_ticket_totals_panel_v216(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=2, column=0, sticky="ew")
        self.ticket_totals_frame = frame

        metrics = tk.Frame(frame, bg=BET_PANEL)
        metrics.pack(fill="x", padx=10, pady=(8, 6))
        metrics.grid_columnconfigure(0, weight=1)
        metrics.grid_columnconfigure(1, weight=1)

        self._metric_line(metrics, 0, 0, "Celkový kurz", self.total_odds_var)
        self._metric_line(metrics, 0, 1, "Kombinací", self.combo_count_var)
        self._metric_line(metrics, 1, 0, "Celkem vsadíš", self.total_stake_var)
        self._metric_line(metrics, 1, 1, "Možná výhra", self.total_return_var)

        stake_area = tk.Frame(frame, bg=BET_PANEL)
        stake_area.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(stake_area, text="Sázka", bg=BET_PANEL, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w")
        row = tk.Frame(stake_area, bg=BET_PANEL)
        row.pack(fill="x", pady=(3, 0))
        tk.Label(row, text="Kč", bg=BET_PANEL_3, fg=TEXT, font=FONT_SM_BOLD, padx=10, pady=7).pack(side="left")
        tk.Entry(row, textvariable=self.stake_var, bg="#10101A", fg=TEXT, insertbackground=TEXT, relief="flat", justify="right", font=FONT_SM_BOLD).pack(side="left", fill="x", expand=True, ipady=6)

        quick = tk.Frame(frame, bg=BET_PANEL)
        quick.pack(fill="x", padx=10, pady=(6, 6))
        for amount in (10, 50, 100, 200):
            tk.Button(quick, text=str(amount), bg=BET_PANEL_2, fg=TEXT, font=FONT_XS, relief="flat", command=lambda a=amount: self._set_stake(a)).pack(side="left", padx=(0, 4), ipady=3)

        tk.Button(
            frame,
            text="ZOBRAZIT PŘEHLED KOMBINACÍ",
            bg=BET_PANEL_2,
            fg=TEXT,
            font=FONT_SM_BOLD,
            relief="flat",
            command=self.open_combo_overview_window,
        ).pack(fill="x", padx=10, pady=(0, 6), ipady=6)

        tk.Button(
            frame,
            text="GENERATE TIKET",
            bg=BET_GREEN,
            activebackground=BET_GREEN_DARK,
            activeforeground=TEXT,
            fg=TEXT,
            font=FONT_SM_BOLD,
            relief="flat",
            command=self.generate_runtime_run,
        ).pack(fill="x", padx=10, pady=(0, 10), ipady=8)

    def _metric_line(self, parent, row, column, title, var_obj):
        box = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        box.grid(row=row, column=column, sticky="ew", padx=(0 if column == 0 else 4, 0 if column == 1 else 0), pady=(0, 4))
        tk.Label(box, text=title, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_XS).pack(anchor="w", padx=8, pady=(6, 1))
        tk.Label(box, textvariable=var_obj, bg=BET_PANEL_2, fg=TEXT, font=FONT_SM_BOLD).pack(anchor="w", padx=8, pady=(0, 6))

    # -----------------------------------------------------
    # Refresh
    # -----------------------------------------------------
    def refresh_all_panels(self):
        self.refresh_ticket_panel_v216()
        self.refresh_summary_v216()

    def refresh_ticket_panel_v216(self):
        if self.ticket_list_inner is None:
            return
        for widget in self.ticket_list_inner.winfo_children():
            widget.destroy()

        entries = []
        for idx, item in enumerate(self.fixed_items):
            entries.append(("FIXED", idx, item, f"{item.get('market_code', '')} {item.get('outcome_code', '')}", self.fmt_odds(item.get("odd_value"))))
        for block_index in (1, 2, 3):
            for idx, item in enumerate(self.block_items[block_index]):
                entries.append((self.block_label(block_index), idx, item, f"Blok {self.block_label(block_index)}", "varianta"))

        self.ticket_count_var.set(f"{len(entries)} výběrů")

        if not entries:
            empty = tk.Frame(self.ticket_list_inner, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
            empty.pack(fill="x", pady=(0, 6))
            tk.Label(empty, text="Tiket je prázdný", bg=BET_PANEL_2, fg=TEXT, font=("Segoe UI", 16, "bold")).pack(pady=(16, 4))
            tk.Label(empty, text="Chceš-li přidat sázku na tiket, klikni na kurz u vybraného zápasu.", bg=BET_PANEL_2, fg=MUTED, font=FONT_SMALL, wraplength=280, justify="center").pack(padx=12, pady=(0, 16))
            return

        for kind, idx, item, tip_text, odd_text in entries:
            card = tk.Frame(self.ticket_list_inner, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
            card.pack(fill="x", pady=(0, 6))

            top = tk.Frame(card, bg=BET_PANEL_2)
            top.pack(fill="x", padx=8, pady=(8, 2))
            icon = SPORT_ICONS.get(str(item.get("sport_code") or "FB").upper(), "⚽")
            tk.Label(top, text=f"{self.fmt_kickoff(item.get('kickoff'))}  {icon}", bg=BET_PANEL_2, fg=MUTED, font=FONT_XS).pack(side="left")
            tk.Button(
                top,
                text="✕",
                bg=BET_PANEL_2,
                fg=TEXT,
                relief="flat",
                font=FONT_XS,
                command=(lambda i=idx: self.remove_fixed_item(i)) if kind == "FIXED" else (lambda b=kind, i=idx: self.remove_block_item({"A":1,"B":2,"C":3}[b], i)),
            ).pack(side="right")

            tk.Label(card, text=f"{item.get('home_team', '?')} - {item.get('away_team', '?')}", bg=BET_PANEL_2, fg=TEXT, font=FONT_SM_BOLD, anchor="w", wraplength=300, justify="left").pack(anchor="w", padx=8)
            tk.Label(card, text=item.get("league_name", "?"), bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_XS, anchor="w", wraplength=300, justify="left").pack(anchor="w", padx=8, pady=(1, 4))

            bottom = tk.Frame(card, bg=BET_PANEL_2)
            bottom.pack(fill="x", padx=8, pady=(0, 8))
            tk.Label(bottom, text=tip_text, bg=BET_PANEL_3, fg=YELLOW if kind != "FIXED" else ACCENT, font=FONT_XS, padx=6, pady=3).pack(side="left")
            tk.Label(bottom, text=odd_text, bg=BET_PANEL_2, fg=TEXT, font=("Segoe UI", 11, "bold")).pack(side="right")

    def refresh_summary_v216(self):
        combos = self.build_combinations()
        self._combo_rows_cache = combos
        stake = self.parse_stake()

        valid_odds = [c["total_odds"] for c in combos if c.get("total_odds")]
        if len(valid_odds) == 1:
            odds_text = f"{valid_odds[0]:.2f}"
        elif len(valid_odds) > 1:
            odds_text = f"{min(valid_odds):.2f} až {max(valid_odds):.2f}"
        else:
            odds_text = "-"

        combo_count = len(combos)
        total_stake = stake * Decimal(combo_count)
        max_return = max((odd * stake for odd in valid_odds), default=Decimal("0"))

        self.total_odds_var.set(odds_text)
        self.combo_count_var.set(str(combo_count))
        self.total_stake_var.set(f"{total_stake:.2f} Kč")
        self.total_return_var.set(f"{max_return:.2f} Kč")

    # -----------------------------------------------------
    # Combo window
    # -----------------------------------------------------
    def open_combo_overview_window(self):
        combos = self._combo_rows_cache if getattr(self, "_combo_rows_cache", None) else self.build_combinations()
        stake = self.parse_stake()

        win = tk.Toplevel(self.root)
        win.title("Přehled kombinací")
        win.configure(bg=BG)
        win.geometry("980x720")
        win.minsize(840, 600)

        outer = tk.Frame(win, bg=BG)
        outer.pack(fill="both", expand=True, padx=12, pady=12)

        tk.Label(outer, text="Přehled všech kombinací", bg=BG, fg=TEXT, font=FONT_SECTION).pack(anchor="w")
        tk.Label(outer, text="Tady budeme příště dál řešit bloky a finální scénáře tiketu.", bg=BG, fg=MUTED, font=FONT_SMALL).pack(anchor="w", pady=(2, 10))

        list_outer, _canvas, inner = self.create_scrollable_vertical(outer, BG)
        list_outer.pack(fill="both", expand=True)

        if not combos:
            tk.Label(inner, text="Žádné kombinace.", bg=BG, fg=MUTED, font=FONT).pack(anchor="w", pady=6)
            return

        for combo in combos:
            card = tk.Frame(inner, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
            card.pack(fill="x", pady=(0, 8))

            top = tk.Frame(card, bg=BET_PANEL_2)
            top.pack(fill="x", padx=10, pady=(8, 4))
            tk.Label(top, text=f"Kombinace #{combo['index']}", bg=BET_PANEL_2, fg=TEXT, font=FONT_SM_BOLD).pack(side="left")
            badge = " | ".join(combo["choices"]) if combo["choices"] else "FIXED only"
            tk.Label(top, text=badge, bg=BET_PANEL_3, fg=YELLOW, font=FONT_XS, padx=6, pady=3).pack(side="right")

            picks_text = " • ".join(combo["parts"])
            tk.Label(card, text=picks_text, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_SMALL, wraplength=900, justify="left").pack(fill="x", padx=10)

            odds_text = f"{combo['total_odds']:.2f}" if combo.get("total_odds") else "-"
            payout = combo["total_odds"] * stake if combo.get("total_odds") else None
            payout_text = f"{payout:.2f} Kč" if payout is not None else "-"
            tk.Label(card, text=f"Kurz: {odds_text}    Možná výhra: {payout_text}", bg=BET_PANEL_2, fg=TEXT, font=FONT_XS).pack(anchor="w", padx=10, pady=(6, 8))


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV216(root)
    root.mainloop()


if __name__ == "__main__":
    main()
