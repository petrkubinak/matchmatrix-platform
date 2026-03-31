from __future__ import annotations

import tkinter as tk
from tkinter import ttk

from matchmatrix_ticket_studio_V2_13 import TicketStudioV213
from matchmatrix_ticket_studio_V2_7 import *
from matchmatrix_ticket_studio_V2_9 import BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_LINE, BET_SOFT
from matchmatrix_ticket_studio_V2_12 import BLUE, BET_GREEN, BET_GREEN_DARK, YELLOW, CARD, CARD_2, PANEL_LINE_SOFT, RED


FONT_XS = ("Segoe UI", 8)
FONT_BOLD_XS = ("Segoe UI", 8, "bold")
FONT_SECTION_SMALL = ("Segoe UI", 11, "bold")


class TicketStudioV214(TicketStudioV213):
    def __init__(self, root: tk.Tk):
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.14")
        self.viewport_var.set("desktop | compact right rail")

    def build_header(self):
        if not hasattr(self, "viewport_var"):
            self.viewport_var = tk.StringVar(value="desktop | compact right rail")

        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=8, pady=(8, 6))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.14",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="kompaktnĂ­ pravĂ˝ panel â€˘ menĹˇĂ­ metriky â€˘ vĂ­ce mĂ­sta pro celĂ˝ tiket",
            bg=BG,
            fg=MUTED,
            font=FONT_XS,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(1, 0))

        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=ACCENT,
            font=FONT_XS,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

    def build_runtime_panel_v212(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=1, column=0, sticky="ew", pady=(0, 6))
        frame.grid_columnconfigure(0, weight=1)

        top = tk.Frame(frame, bg=BET_PANEL)
        top.pack(fill="x", padx=10, pady=(8, 6))
        tk.Label(top, text="Runtime engine", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION_SMALL).pack(side="left")
        tk.Label(top, textvariable=self.preview_badge_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        row1 = tk.Frame(frame, bg=BET_PANEL)
        row1.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(row1, text="Bookmaker", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        self.bookmaker_combo = ttk.Combobox(row1, textvariable=self.bookmaker_var, state="readonly", height=10)
        self.bookmaker_combo.pack(fill="x", pady=(3, 0), ipady=1)

        row2 = tk.Frame(frame, bg=BET_PANEL)
        row2.pack(fill="x", padx=10, pady=(0, 6))
        row2.grid_columnconfigure(0, weight=1)
        row2.grid_columnconfigure(1, weight=1)

        left = tk.Frame(row2, bg=BET_PANEL)
        left.grid(row=0, column=0, sticky="ew", padx=(0, 5))
        tk.Label(left, text="Max tickets", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        tk.Entry(left, textvariable=self.max_tickets_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_XS).pack(fill="x", pady=(3, 0), ipady=4)

        right = tk.Frame(row2, bg=BET_PANEL)
        right.grid(row=0, column=1, sticky="ew", padx=(5, 0))
        tk.Label(right, text="Min probability", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        tk.Entry(right, textvariable=self.min_probability_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_XS).pack(fill="x", pady=(3, 0), ipady=4)

        row3 = tk.Frame(frame, bg=BET_PANEL)
        row3.pack(fill="x", padx=10, pady=(0, 6))
        tk.Button(row3, text="PREVIEW", bg=BLUE, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.preview_runtime_run).pack(side="left", padx=(0, 6), ipady=4)
        tk.Button(row3, text="GENERATE", bg=ACCENT, fg=BG, font=FONT_BOLD_XS, relief="flat", command=self.generate_runtime_run).pack(side="left", padx=(0, 6), ipady=4)
        tk.Button(row3, text="POSLEDNĂŤ", bg=BET_PANEL_3, fg=TEXT, font=FONT_XS, relief="flat", command=self.show_last_run_details).pack(side="left", ipady=4)

        row4 = tk.Frame(frame, bg=BET_PANEL)
        row4.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(row4, text="PoslednĂ­ run", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(side="left")
        tk.Label(row4, textvariable=self.last_run_id_var, bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD_XS, padx=6, pady=2).pack(side="left", padx=(6, 0))

        tk.Label(frame, textvariable=self.runtime_status_var, bg=BET_PANEL, fg=TEXT, font=FONT_XS, anchor="w", justify="left").pack(fill="x", padx=10, pady=(0, 6))

    def _metric_box(self, parent, row, column, label_text):
        box = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        box.grid(row=row, column=column, sticky="ew", padx=(0 if column == 0 else 4, 0 if column == 1 else 4), pady=(0, 4))
        tk.Label(box, text=label_text, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_XS).pack(anchor="w", padx=7, pady=(5, 1))
        value = tk.Label(box, text="-", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD_XS)
        value.pack(anchor="w", padx=7, pady=(0, 5))
        return value

    def build_betslip_summary_panel(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=2, column=0, sticky="ew", pady=(0, 6))
        frame.grid_columnconfigure(0, weight=1)

        top = tk.Frame(frame, bg=BET_PANEL)
        top.pack(fill="x", padx=10, pady=(8, 6))
        tk.Label(top, text="Ticket slip", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION_SMALL).pack(side="left")
        self.summary_badge_var = tk.StringVar(value="0 vĂ˝bÄ›rĹŻ")
        tk.Label(top, textvariable=self.summary_badge_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        metrics = tk.Frame(frame, bg=BET_PANEL)
        metrics.pack(fill="x", padx=10, pady=(0, 6))
        metrics.grid_columnconfigure(0, weight=1)
        metrics.grid_columnconfigure(1, weight=1)

        self.metric_total_odds = self._metric_box(metrics, 0, 0, "Kurz tiketu")
        self.metric_combo_count = self._metric_box(metrics, 0, 1, "KombinacĂ­")
        self.metric_total_stake = self._metric_box(metrics, 1, 0, "Celkem vsadĂ­Ĺˇ")
        self.metric_total_return = self._metric_box(metrics, 1, 1, "MoĹľnĂˇ vĂ˝hra")

        stake_row = tk.Frame(frame, bg=BET_PANEL)
        stake_row.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(stake_row, text="Vklad na 1 kombinaci", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")

        stake_wrap = tk.Frame(stake_row, bg=BET_PANEL)
        stake_wrap.pack(fill="x", pady=(3, 0))
        entry = tk.Entry(stake_wrap, textvariable=self.stake_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", justify="right", font=FONT_XS)
        entry.pack(side="left", fill="x", expand=True, ipady=4)
        tk.Label(stake_wrap, text="KÄŤ", bg=BET_PANEL_3, fg=TEXT, font=FONT_BOLD_XS, padx=7).pack(side="left")

        quick = tk.Frame(frame, bg=BET_PANEL)
        quick.pack(fill="x", padx=10, pady=(0, 6))
        for amount in (10, 50, 100, 200):
            tk.Button(quick, text=str(amount), bg=BET_PANEL_2, fg=TEXT, font=FONT_XS, relief="flat", command=lambda a=amount: self._set_stake(a)).pack(side="left", padx=(0, 5), ipady=2)

        self.combo_toggle_btn = tk.Button(
            frame,
            text="ZOBRAZIT VĹ ECHNY KOMBINACE (0)",
            bg=BET_PANEL_2,
            activebackground=BET_PANEL_3,
            activeforeground=TEXT,
            fg=TEXT,
            relief="flat",
            font=FONT_BOLD_XS,
            command=self.toggle_combos_panel,
        )
        self.combo_toggle_btn.pack(fill="x", padx=10, pady=(0, 6), ipady=6)

        self.submit_btn = tk.Button(
            frame,
            text="PĹEHLED TIKETU",
            bg=BET_GREEN,
            activebackground=BET_GREEN_DARK,
            activeforeground=TEXT,
            fg=TEXT,
            relief="flat",
            font=FONT_BOLD_XS,
            command=self.toggle_combos_panel,
        )
        self.submit_btn.pack(fill="x", padx=10, pady=(0, 10), ipady=7)

    def build_selection_panel_v212(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        frame.grid(row=3, column=0, sticky="nsew", pady=(0, 6))
        frame.grid_rowconfigure(1, weight=1)
        frame.grid_columnconfigure(0, weight=1)

        head = tk.Frame(frame, bg=CARD)
        head.pack(fill="x", padx=8, pady=(8, 4))
        tk.Label(head, text="VybranĂ© zĂˇpasy", bg=CARD, fg=TEXT, font=FONT_SECTION_SMALL).pack(side="left")
        self.selected_count_var = tk.StringVar(value="0")
        tk.Label(head, textvariable=self.selected_count_var, bg=CARD_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        self.selection_outer, self.selection_canvas, self.selection_inner = self.create_scrollable_vertical(frame, CARD)
        self.selection_outer.pack(fill="both", expand=True, padx=8, pady=(0, 8))

    def build_combos_panel_v212(self, parent):
        self.combos_frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        self.combos_frame.grid(row=4, column=0, sticky="nsew")
        self.combos_frame.grid_columnconfigure(0, weight=1)
        self.combos_frame.grid_rowconfigure(1, weight=1)

        head = tk.Frame(self.combos_frame, bg=CARD)
        head.grid(row=0, column=0, sticky="ew", padx=8, pady=(8, 4))
        tk.Label(head, text="PĹ™ehled vĹˇech tiketĹŻ / kombinacĂ­", bg=CARD, fg=TEXT, font=FONT_SECTION_SMALL).pack(side="left")
        self.combos_caption_var = tk.StringVar(value="skryto")
        tk.Label(head, textvariable=self.combos_caption_var, bg=CARD_2, fg=BET_SOFT, font=FONT_XS, padx=6, pady=2).pack(side="right")

        self.combos_outer, self.combos_canvas, self.combos_inner = self.create_scrollable_vertical(self.combos_frame, CARD)
        self.combos_outer.grid(row=1, column=0, sticky="nsew", padx=8, pady=(0, 8))
        if not self.combos_visible.get():
            self.combos_outer.grid_remove()

    def _render_selected_card(self, parent, item, accent, meta, remove_cmd):
        card = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        card.pack(fill="x", pady=(0, 4))
        row = tk.Frame(card, bg=BET_PANEL_2)
        row.pack(fill="x", padx=7, pady=(5, 5))
        left = tk.Frame(row, bg=BET_PANEL_2)
        left.pack(side="left", fill="x", expand=True)
        right = tk.Frame(row, bg=BET_PANEL_2)
        right.pack(side="right", anchor="ne")

        tk.Label(left, text=f"{item.get('home_team', '?')} vs {item.get('away_team', '?')}", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD_XS, anchor="w").pack(anchor="w")
        tk.Label(left, text=f"{item.get('league_name', '')} â€˘ {self.fmt_kickoff(item.get('kickoff'))}", bg=BET_PANEL_2, fg=MUTED, font=FONT_XS, anchor="w").pack(anchor="w", pady=(1, 0))

        tk.Label(right, text=meta.replace("kurz ", "").replace(" â€˘ ", "   "), bg=BET_PANEL_2, fg=accent, font=FONT_XS, anchor="e", justify="right").pack(anchor="e")
        tk.Button(card, text="ODEBRAT", bg=RED, fg=BG, font=FONT_XS, relief="flat", command=lambda: (remove_cmd(), self._update_button_states())).pack(anchor="e", padx=7, pady=(0, 5), ipadx=3)


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV214(root)
    root.mainloop()


if __name__ == "__main__":
    main()

