from __future__ import annotations

import tkinter as tk
from tkinter import ttk
from decimal import Decimal

from matchmatrix_ticket_studio_V2_11 import TicketStudioV211
from matchmatrix_ticket_studio_V2_9 import BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_LINE, BET_SOFT, BET_GREEN, BET_GREEN_DARK, PANEL_LINE_SOFT
from matchmatrix_ticket_studio_V2_10_4 import SECTION_BG, SECTION_ACCENT, ROW_EVEN, ROW_ODD, SELECT_GREEN, TEAM_META, FLAG_MAP
from matchmatrix_ticket_studio_V2_10_5 import PINK, PINK_DARK, PINK_TEXT, DATE_SOFT
from matchmatrix_ticket_studio_V2_7 import *


INFO_BG = "#2D2160"
INFO_BG_ACTIVE = "#3A2C79"


class TicketStudioV212(TicketStudioV211):
    def __init__(self, root: tk.Tk):
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.12")
        self.viewport_var.set("desktop | ticket slip fixed | info icon + insights")
        self.refresh_all_panels()

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=(10, 8))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.12",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="oprava pravého panelu • ticket slip se propisuje • info ikonka u zápasu • predikce/forma/H2H/detail",
            bg=BG,
            fg=MUTED,
            font=FONT,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="desktop | ticket slip fixed | insights")
        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=ACCENT,
            font=FONT_SMALL,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

    def build_right_panel(self, parent):
        parent.grid_rowconfigure(3, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_template_panel_v29(parent)      # row 0
        self.build_runtime_panel_v212(parent)      # row 1
        self.build_betslip_summary_panel(parent)   # row 2
        self.build_selection_panel_v212(parent)    # row 3
        self.build_combos_panel_v212(parent)       # row 4

    def build_runtime_panel_v212(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=1, column=0, sticky="ew", pady=(0, 8))
        frame.grid_columnconfigure(0, weight=1)

        top = tk.Frame(frame, bg=BET_PANEL)
        top.pack(fill="x", padx=12, pady=(10, 8))
        tk.Label(top, text="Runtime engine", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(side="left")
        tk.Label(top, textvariable=self.preview_badge_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_SMALL, padx=8, pady=3).pack(side="right")

        row1 = tk.Frame(frame, bg=BET_PANEL)
        row1.pack(fill="x", padx=12, pady=(0, 8))
        tk.Label(row1, text="Bookmaker", bg=BET_PANEL, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w")
        self.bookmaker_combo = ttk.Combobox(row1, textvariable=self.bookmaker_var, state="readonly")
        self.bookmaker_combo.pack(fill="x", pady=(4, 0))

        row2 = tk.Frame(frame, bg=BET_PANEL)
        row2.pack(fill="x", padx=12, pady=(0, 8))
        row2.grid_columnconfigure(0, weight=1)
        row2.grid_columnconfigure(1, weight=1)

        left = tk.Frame(row2, bg=BET_PANEL)
        left.grid(row=0, column=0, sticky="ew", padx=(0, 6))
        tk.Label(left, text="Max tickets", bg=BET_PANEL, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w")
        tk.Entry(left, textvariable=self.max_tickets_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat").pack(fill="x", pady=(4, 0), ipady=6)

        right = tk.Frame(row2, bg=BET_PANEL)
        right.grid(row=0, column=1, sticky="ew", padx=(6, 0))
        tk.Label(right, text="Min probability", bg=BET_PANEL, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w")
        tk.Entry(right, textvariable=self.min_probability_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat").pack(fill="x", pady=(4, 0), ipady=6)

        row3 = tk.Frame(frame, bg=BET_PANEL)
        row3.pack(fill="x", padx=12, pady=(0, 10))
        tk.Button(row3, text="PREVIEW RUN", bg=BLUE, fg=BG, font=FONT_BOLD, relief="flat", command=self.preview_runtime_run).pack(side="left", padx=(0, 8))
        tk.Button(row3, text="GENERATE RUN", bg=ACCENT, fg=BG, font=FONT_BOLD, relief="flat", command=self.generate_runtime_run).pack(side="left", padx=(0, 8))
        tk.Button(row3, text="ZOBRAZIT POSLEDNÍ", bg=BET_PANEL_3, fg=TEXT, font=FONT_SMALL, relief="flat", command=self.show_last_run_details).pack(side="left")

        row4 = tk.Frame(frame, bg=BET_PANEL)
        row4.pack(fill="x", padx=12, pady=(0, 8))
        tk.Label(row4, text="Poslední run", bg=BET_PANEL, fg=BET_SOFT, font=FONT_SMALL).pack(side="left")
        tk.Label(row4, textvariable=self.last_run_id_var, bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD, padx=8, pady=3).pack(side="left", padx=(8, 0))

        tk.Label(frame, textvariable=self.runtime_status_var, bg=BET_PANEL, fg=TEXT, font=FONT_SMALL, anchor="w", justify="left").pack(fill="x", padx=12, pady=(0, 8))

    def build_betslip_summary_panel(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=2, column=0, sticky="ew", pady=(0, 8))
        frame.grid_columnconfigure(0, weight=1)

        top = tk.Frame(frame, bg=BET_PANEL)
        top.pack(fill="x", padx=12, pady=(10, 8))
        tk.Label(top, text="Ticket slip", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(side="left")
        self.summary_badge_var = tk.StringVar(value="0 výběrů")
        tk.Label(top, textvariable=self.summary_badge_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_SMALL, padx=8, pady=3).pack(side="right")

        metrics = tk.Frame(frame, bg=BET_PANEL)
        metrics.pack(fill="x", padx=12, pady=(0, 10))
        metrics.grid_columnconfigure(0, weight=1)
        metrics.grid_columnconfigure(1, weight=1)

        self.metric_total_odds = self._metric_box(metrics, 0, 0, "Kurz tiketu")
        self.metric_combo_count = self._metric_box(metrics, 0, 1, "Kombinací")
        self.metric_total_stake = self._metric_box(metrics, 1, 0, "Celkem vsadíš")
        self.metric_total_return = self._metric_box(metrics, 1, 1, "Možná výhra")

        stake_row = tk.Frame(frame, bg=BET_PANEL)
        stake_row.pack(fill="x", padx=12, pady=(0, 10))
        tk.Label(stake_row, text="Vklad na 1 kombinaci", bg=BET_PANEL, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w")

        stake_wrap = tk.Frame(stake_row, bg=BET_PANEL)
        stake_wrap.pack(fill="x", pady=(4, 0))
        entry = tk.Entry(stake_wrap, textvariable=self.stake_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", justify="right")
        entry.pack(side="left", fill="x", expand=True, ipady=6)
        tk.Label(stake_wrap, text="Kč", bg=BET_PANEL_3, fg=TEXT, font=FONT_BOLD, padx=8).pack(side="left")

        quick = tk.Frame(frame, bg=BET_PANEL)
        quick.pack(fill="x", padx=12, pady=(0, 10))
        for amount in (10, 50, 100, 200):
            tk.Button(quick, text=str(amount), bg=BET_PANEL_2, fg=TEXT, font=FONT_SMALL, relief="flat", command=lambda a=amount: self._set_stake(a)).pack(side="left", padx=(0, 6))

        self.combo_toggle_btn = tk.Button(
            frame,
            text="ZOBRAZIT VŠECHNY KOMBINACE (0)",
            bg=BET_PANEL_2,
            activebackground=BET_PANEL_3,
            activeforeground=TEXT,
            fg=TEXT,
            relief="flat",
            font=FONT_BOLD,
            command=self.toggle_combos_panel,
        )
        self.combo_toggle_btn.pack(fill="x", padx=12, pady=(0, 8), ipady=8)

        self.submit_btn = tk.Button(
            frame,
            text="PŘEHLED TIKETU",
            bg=BET_GREEN,
            activebackground=BET_GREEN_DARK,
            activeforeground=TEXT,
            fg=TEXT,
            relief="flat",
            font=FONT_BOLD,
            command=self.toggle_combos_panel,
        )
        self.submit_btn.pack(fill="x", padx=12, pady=(0, 12), ipady=8)

    def build_selection_panel_v212(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        frame.grid(row=3, column=0, sticky="nsew", pady=(0, 8))
        frame.grid_rowconfigure(1, weight=1)
        frame.grid_columnconfigure(0, weight=1)

        head = tk.Frame(frame, bg=CARD)
        head.pack(fill="x", padx=10, pady=(10, 6))
        tk.Label(head, text="Vybrané zápasy", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(side="left")
        self.selected_count_var = tk.StringVar(value="0")
        tk.Label(head, textvariable=self.selected_count_var, bg=CARD_2, fg=YELLOW, font=FONT_SMALL, padx=8, pady=3).pack(side="right")

        self.selection_outer, self.selection_canvas, self.selection_inner = self.create_scrollable_vertical(frame, CARD)
        self.selection_outer.pack(fill="both", expand=True, padx=10, pady=(0, 10))

    def build_combos_panel_v212(self, parent):
        self.combos_frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        self.combos_frame.grid(row=4, column=0, sticky="nsew")
        self.combos_frame.grid_columnconfigure(0, weight=1)
        self.combos_frame.grid_rowconfigure(1, weight=1)

        head = tk.Frame(self.combos_frame, bg=CARD)
        head.grid(row=0, column=0, sticky="ew", padx=10, pady=(10, 6))
        tk.Label(head, text="Přehled všech tiketů / kombinací", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(side="left")
        self.combos_caption_var = tk.StringVar(value="skryto")
        tk.Label(head, textvariable=self.combos_caption_var, bg=CARD_2, fg=BET_SOFT, font=FONT_SMALL, padx=8, pady=3).pack(side="right")

        self.combos_outer, self.combos_canvas, self.combos_inner = self.create_scrollable_vertical(self.combos_frame, CARD)
        self.combos_outer.grid(row=1, column=0, sticky="nsew", padx=10, pady=(0, 10))
        if not self.combos_visible.get():
            self.combos_outer.grid_remove()

    def refresh_selection_panel(self):
        for widget in self.selection_inner.winfo_children():
            widget.destroy()

        total_entries = len(self.fixed_items) + sum(len(v) for v in self.block_items.values())
        self.selected_count_var.set(f"{total_entries} výběrů")

        if not total_entries:
            tk.Label(self.selection_inner, text="Zatím žádné vybrané zápasy.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", pady=6)
            return

        if self.fixed_items:
            self._section_title(self.selection_inner, "FIXED picky")
            for idx, item in enumerate(self.fixed_items):
                meta = f"{item.get('market_code', '')} • {item.get('outcome_code', '')} • kurz {self.fmt_odds(item.get('odd_value'))}"
                self._render_pick_card_safe(self.selection_inner, item, meta, lambda i=idx: self.remove_fixed_item(i), accent=SELECT_GREEN)

        for block_index in (1, 2, 3):
            items = self.block_items[block_index]
            if not items:
                continue
            self._section_title(self.selection_inner, f"Blok {self.block_label(block_index)}")
            for idx, item in enumerate(items):
                meta = f"blok {self.block_label(block_index)} • outcome dle kombinace"
                self._render_pick_card_safe(self.selection_inner, item, meta, lambda bi=block_index, i=idx: self.remove_block_item(bi, i), accent=YELLOW)

    def _render_pick_card_safe(self, parent, item: dict, meta: str, remove_cmd, accent=ACCENT):
        card = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        card.pack(fill="x", pady=(0, 6))

        top = tk.Frame(card, bg=BET_PANEL_2)
        top.pack(fill="x", padx=8, pady=(7, 4))
        top.grid_columnconfigure(0, weight=1)

        left = tk.Frame(top, bg=BET_PANEL_2)
        left.grid(row=0, column=0, sticky="ew")
        tk.Label(left, text=f"{item.get('home_team', '?')} vs {item.get('away_team', '?')}", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD, anchor="w").pack(anchor="w")
        tk.Label(left, text=item.get("league_name", "?"), bg=BET_PANEL_2, fg=MUTED, font=("Segoe UI", 8, "italic"), anchor="w").pack(anchor="w", pady=(1, 0))

        right = tk.Frame(top, bg=BET_PANEL_2)
        right.grid(row=0, column=1, sticky="ne", padx=(10, 0))
        tk.Label(right, text=meta.replace("kurz ", "").replace(" • ", "   "), bg=BET_PANEL_2, fg=accent, font=FONT_SMALL, anchor="e", justify="right").pack(anchor="e")

        tk.Button(card, text="ODEBRAT", bg=RED, fg=BG, font=FONT_SMALL, relief="flat", command=lambda: (remove_cmd(), self._update_button_states())).pack(anchor="e", padx=8, pady=(0, 8))

    def render_match_row(self, row: dict, row_index: int):
        bg_row = ROW_EVEN if row_index % 2 == 0 else ROW_ODD
        wrap = tk.Frame(self.match_inner, bg=bg_row, width=self.grid_total_width, height=40, highlightthickness=0)
        wrap.pack(fill="x", padx=6, pady=1)
        wrap.pack_propagate(False)

        match_x = 0
        match_w = self.grid_columns[0][1]
        info = tk.Frame(wrap, bg=bg_row)
        info.place(x=match_x + 8, y=1, width=match_w - 16, height=38)
        info.grid_columnconfigure(0, weight=1)

        text_col = tk.Frame(info, bg=bg_row)
        text_col.grid(row=0, column=0, sticky="nsew")

        teams = tk.Frame(text_col, bg=bg_row)
        teams.pack(anchor="w", fill="x")
        tk.Label(teams, text=str(row.get("home_team", "?")), bg=bg_row, fg=TEXT, font=("Segoe UI", 9, "bold"), anchor="w").pack(side="left")
        tk.Label(teams, text="  vs  ", bg=bg_row, fg=MUTED, font=("Segoe UI", 8), anchor="w").pack(side="left")
        tk.Label(teams, text=str(row.get("away_team", "?")), bg=bg_row, fg=TEXT, font=("Segoe UI", 9, "bold"), anchor="w").pack(side="left")

        meta = tk.Frame(text_col, bg=bg_row)
        meta.pack(anchor="w", fill="x", pady=(1, 0))
        tk.Label(meta, text=self.fmt_kickoff(row.get("kickoff")), bg=bg_row, fg=DATE_SOFT, font=("Segoe UI", 8, "italic"), anchor="w").pack(side="left")
        tk.Label(meta, text="  •  detail", bg=bg_row, fg=TEAM_META, font=("Segoe UI", 8), anchor="w").pack(side="left")

        tk.Button(
            info,
            text="i",
            bg=INFO_BG,
            fg=TEXT,
            activebackground=INFO_BG_ACTIVE,
            activeforeground=TEXT,
            font=("Segoe UI", 8, "bold"),
            relief="flat",
            borderwidth=0,
            command=lambda r=row: self.show_match_insights(r),
        ).grid(row=0, column=1, sticky="e", padx=(8, 0), ipadx=6, ipady=3)

        x = match_w
        dc_odds = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))
        self.make_grid_pick_button(wrap, row, bg_row, x, 54, "H2H", "1", row.get("odd_1")); x += 54
        self.make_grid_pick_button(wrap, row, bg_row, x, 54, "H2H", "X", row.get("odd_x")); x += 54
        self.make_grid_pick_button(wrap, row, bg_row, x, 54, "H2H", "2", row.get("odd_2")); x += 54
        self.make_grid_pick_button(wrap, row, bg_row, x, 58, "DC", "1X", dc_odds["1X"]); x += 58
        self.make_grid_pick_button(wrap, row, bg_row, x, 58, "DC", "12", dc_odds["12"]); x += 58
        self.make_grid_pick_button(wrap, row, bg_row, x, 58, "DC", "X2", dc_odds["X2"]); x += 58
        self.make_block_button(wrap, row, bg_row, x, 42, 1); x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 2); x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 3)

    def show_match_insights(self, row: dict):
        match_id = int(row.get("match_id"))
        detail = self.fetchone(
            """
            SELECT
                m.id AS match_id,
                m.league_id,
                m.home_team_id,
                m.away_team_id,
                m.kickoff,
                m.status,
                l.name AS league_name,
                ht.name AS home_team,
                at.name AS away_team
            FROM public.matches m
            LEFT JOIN public.leagues l ON l.id = m.league_id
            LEFT JOIN public.teams ht ON ht.id = m.home_team_id
            LEFT JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.id = %s
            """,
            (match_id,),
        )
        if not detail:
            messagebox.showerror("Detail zápasu", f"Nepodařilo se načíst detail pro match_id={match_id}.")
            return

        pred = self.fetchone(
            """
            SELECT model_code, p_home, p_draw, p_away, run_ts
            FROM public.ml_predictions
            WHERE match_id = %s
            ORDER BY run_ts DESC, id DESC
            LIMIT 1
            """,
            (match_id,),
        )

        ratings = self.fetchall(
            """
            SELECT team_id, rating, rating_home, rating_away, momentum, volatility
            FROM public.mm_team_ratings
            WHERE league_id = %s AND team_id IN (%s, %s)
            ORDER BY team_id
            """,
            (detail["league_id"], detail["home_team_id"], detail["away_team_id"]),
        )
        ratings_map = {int(r["team_id"]): r for r in ratings}

        h2h = self.fetchall(
            """
            SELECT
                m.kickoff,
                ht.name AS home_team,
                at.name AS away_team,
                m.home_score,
                m.away_score
            FROM public.matches m
            JOIN public.teams ht ON ht.id = m.home_team_id
            JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.status = 'FINISHED'
              AND ((m.home_team_id = %s AND m.away_team_id = %s)
                OR (m.home_team_id = %s AND m.away_team_id = %s))
            ORDER BY m.kickoff DESC
            LIMIT 5
            """,
            (detail["home_team_id"], detail["away_team_id"], detail["away_team_id"], detail["home_team_id"]),
        )

        recent_home = self.fetchall(
            """
            SELECT m.kickoff, ht.name AS home_team, at.name AS away_team, m.home_score, m.away_score,
                   CASE
                     WHEN m.home_team_id = %s AND m.home_score > m.away_score THEN 'W'
                     WHEN m.away_team_id = %s AND m.away_score > m.home_score THEN 'W'
                     WHEN m.home_score = m.away_score THEN 'D'
                     ELSE 'L'
                   END AS result_code
            FROM public.matches m
            JOIN public.teams ht ON ht.id = m.home_team_id
            JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.status = 'FINISHED'
              AND (%s IN (m.home_team_id, m.away_team_id))
            ORDER BY m.kickoff DESC
            LIMIT 5
            """,
            (detail["home_team_id"], detail["home_team_id"], detail["home_team_id"]),
        )

        recent_away = self.fetchall(
            """
            SELECT m.kickoff, ht.name AS home_team, at.name AS away_team, m.home_score, m.away_score,
                   CASE
                     WHEN m.home_team_id = %s AND m.home_score > m.away_score THEN 'W'
                     WHEN m.away_team_id = %s AND m.away_score > m.home_score THEN 'W'
                     WHEN m.home_score = m.away_score THEN 'D'
                     ELSE 'L'
                   END AS result_code
            FROM public.matches m
            JOIN public.teams ht ON ht.id = m.home_team_id
            JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.status = 'FINISHED'
              AND (%s IN (m.home_team_id, m.away_team_id))
            ORDER BY m.kickoff DESC
            LIMIT 5
            """,
            (detail["away_team_id"], detail["away_team_id"], detail["away_team_id"]),
        )

        winp = self._probability_text(pred)
        home_rating = ratings_map.get(int(detail["home_team_id"]), {})
        away_rating = ratings_map.get(int(detail["away_team_id"]), {})

        lines = [
            f"ZÁPAS: {detail.get('home_team')} vs {detail.get('away_team')}",
            f"SOUTĚŽ: {detail.get('league_name')} | kickoff: {self.fmt_kickoff(detail.get('kickoff'))} | status: {detail.get('status')}",
            "",
            "PREDIKCE:",
            winp,
            "",
            "ODDS V NABÍDCE:",
            f"1={self.fmt_odds(row.get('odd_1'))}   X={self.fmt_odds(row.get('odd_x'))}   2={self.fmt_odds(row.get('odd_2'))}",
            f"1X={self.fmt_odds(self.compute_double_chance_odds(row.get('odd_1'), row.get('odd_x'), row.get('odd_2'))['1X'])}   12={self.fmt_odds(self.compute_double_chance_odds(row.get('odd_1'), row.get('odd_x'), row.get('odd_2'))['12'])}   X2={self.fmt_odds(self.compute_double_chance_odds(row.get('odd_1'), row.get('odd_x'), row.get('odd_2'))['X2'])}",
            "",
            "SÍLA TÝMŮ / MMR:",
            self._rating_line(detail.get('home_team'), home_rating, side='home'),
            self._rating_line(detail.get('away_team'), away_rating, side='away'),
            "",
            "FORMA DOMÁCÍ:",
        ]
        lines.extend(self._recent_lines(recent_home))
        lines.extend(["", "FORMA HOSTÉ:"])
        lines.extend(self._recent_lines(recent_away))
        lines.extend(["", "VZÁJEMNÉ ZÁPASY H2H:"])
        lines.extend(self._h2h_lines(h2h))
        lines.extend(["", "TABULKA / UMÍSTĚNÍ:", "zatím není napojená samostatná standings vrstva v tomto panelu"])

        win = tk.Toplevel(self.root)
        win.title(f"Detail zápasu | {detail.get('home_team')} vs {detail.get('away_team')}")
        win.configure(bg=BG)
        win.geometry("960x760")
        win.minsize(760, 560)

        head = tk.Frame(win, bg=BG)
        head.pack(fill="x", padx=12, pady=(12, 8))
        tk.Label(head, text=f"{detail.get('home_team')} vs {detail.get('away_team')}", bg=BG, fg=TEXT, font=FONT_SECTION).pack(anchor="w")
        tk.Label(head, text="Predikce • forma • H2H • síla týmů • odds snapshot", bg=BG, fg=MUTED, font=FONT_SMALL).pack(anchor="w", pady=(2, 0))

        body = tk.Frame(win, bg=BG)
        body.pack(fill="both", expand=True, padx=12, pady=(0, 12))
        text = tk.Text(body, bg=BET_PANEL_2, fg=TEXT, insertbackground=TEXT, wrap="word", relief="flat", font=("Consolas", 10))
        text.pack(side="left", fill="both", expand=True)
        scroll = tk.Scrollbar(body, orient="vertical", command=text.yview)
        scroll.pack(side="right", fill="y")
        text.configure(yscrollcommand=scroll.set)
        text.insert("1.0", "\n".join(lines))
        text.configure(state="disabled")

    def _probability_text(self, pred: dict | None) -> str:
        if not pred:
            return "predikce zatím v DB není k dispozici"
        return (
            f"model={pred.get('model_code')} | home={self._pct(pred.get('p_home'))} | "
            f"draw={self._pct(pred.get('p_draw'))} | away={self._pct(pred.get('p_away'))} | "
            f"run={pred.get('run_ts')}"
        )

    def _pct(self, value) -> str:
        try:
            return f"{Decimal(str(value)) * Decimal('100'):.1f}%"
        except Exception:
            return "-"

    def _rating_line(self, team_name: str, row: dict | None, side: str) -> str:
        if not row:
            return f"{team_name}: rating zatím není v mm_team_ratings"
        side_rating = row.get('rating_home') if side == 'home' else row.get('rating_away')
        return (
            f"{team_name}: total={self._num(row.get('rating'))} | {side}={self._num(side_rating)} | "
            f"momentum={self._num(row.get('momentum'))} | volatility={self._num(row.get('volatility'))}"
        )

    def _num(self, value) -> str:
        try:
            return f"{Decimal(str(value)):.3f}"
        except Exception:
            return "-"

    def _recent_lines(self, rows: list[dict]) -> list[str]:
        if not rows:
            return ["bez historie"]
        out = []
        for r in rows:
            out.append(
                f"{self.fmt_kickoff(r.get('kickoff'))} | {r.get('home_team')} {r.get('home_score')}:{r.get('away_score')} {r.get('away_team')} | {r.get('result_code')}"
            )
        return out

    def _h2h_lines(self, rows: list[dict]) -> list[str]:
        if not rows:
            return ["bez H2H historie"]
        out = []
        for r in rows:
            out.append(f"{self.fmt_kickoff(r.get('kickoff'))} | {r.get('home_team')} {r.get('home_score')}:{r.get('away_score')} {r.get('away_team')}")
        return out


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV212(root)
    root.mainloop()


if __name__ == "__main__":
    main()
