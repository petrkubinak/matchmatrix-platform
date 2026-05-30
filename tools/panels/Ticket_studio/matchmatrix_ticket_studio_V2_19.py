# -*- coding: utf-8 -*-
from __future__ import annotations

import tkinter as tk
from tkinter import ttk
from decimal import Decimal
import tkinter.font as tkfont

from matchmatrix_ticket_studio_V2_18 import TicketStudioV218, CARD_ITEM, CARD_ITEM_ALT, ROW_LINE, ODD_BG, ODD_LABEL
from matchmatrix_ticket_studio_V2_9 import BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_LINE, BET_SOFT
from matchmatrix_ticket_studio_V2_12 import BLUE, BET_GREEN, BET_GREEN_DARK
from matchmatrix_ticket_studio_V2_14 import FONT_XS, FONT_BOLD_XS, FONT_SECTION_SMALL
from matchmatrix_ticket_studio_V2_7 import BG, CARD, CARD_2, TEXT, MUTED, ACCENT, RED, YELLOW, FONT_SMALL, FONT_BOLD


class TicketStudioV219(TicketStudioV218):
    def __init__(self, root: tk.Tk):
        self.metric_odds_var = tk.StringVar(value="1.00")
        self.metric_combos_var = tk.StringVar(value="1")
        self.metric_stake_var = tk.StringVar(value="100.00 Kč")
        self.metric_return_var = tk.StringVar(value="100.00 Kč")
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.19")
        if hasattr(self, "viewport_var"):
            self.viewport_var.set("desktop | compact left | compact ticket cards | top metrics")
        self.root.after(150, self.adjust_left_panel_width)

    def build_header(self):
        if not hasattr(self, "viewport_var"):
            self.viewport_var = tk.StringVar(value="desktop | compact left | compact ticket cards | top metrics")

        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=8, pady=(8, 6))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.19",
            bg=BG,
            fg=TEXT,
            font=("Segoe UI", 15, "bold"),
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="užší levý panel • kompaktní položky tiketu • metriky nahoře v jednom řádku",
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

    def init_pane_sizes(self):
        try:
            total = self.main_paned.winfo_width()
            if total <= 1:
                return
            left_w = 215
            center_w = max(760, int(total * 0.585))
            self.main_paned.sashpos(0, left_w)
            self.main_paned.sashpos(1, left_w + center_w)
        except Exception:
            pass

    def adjust_left_panel_width(self):
        try:
            total = self.main_paned.winfo_width()
            if total <= 1:
                return
            text_font = tkfont.Font(font=FONT_SMALL)
            max_px = 0
            for row in getattr(self, "league_rows", []):
                txt = f"{row['league_name']} ({row['match_count']})"
                max_px = max(max_px, text_font.measure(txt))

            control_floor = 185
            target_left = max(control_floor, min(285, max_px + 38))
            center_w = max(760, int(total * 0.585))
            right_min = 430
            if target_left + center_w + right_min > total:
                center_w = max(700, total - target_left - right_min)

            self.main_paned.sashpos(0, target_left)
            self.main_paned.sashpos(1, target_left + center_w)
        except Exception:
            pass

    def build_right_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_ticket_panel_v219(parent)
        self.build_controls_panel_v219(parent)

    def build_ticket_panel_v219(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=0, column=0, sticky="nsew", pady=(0, 8))
        frame.grid_rowconfigure(2, weight=1)
        frame.grid_columnconfigure(0, weight=1)
        self.ticket_frame = frame

        metrics = tk.Frame(frame, bg=BET_PANEL)
        metrics.grid(row=0, column=0, sticky="ew", padx=8, pady=(8, 6))
        for c in range(4):
            metrics.grid_columnconfigure(c, weight=1)

        self._metric_box_top(metrics, 0, "Kurz", self.metric_odds_var)
        self._metric_box_top(metrics, 1, "Kombinací", self.metric_combos_var)
        self._metric_box_top(metrics, 2, "Vsadíš", self.metric_stake_var)
        self._metric_box_top(metrics, 3, "Výhra", self.metric_return_var)

        head = tk.Frame(frame, bg=BET_PANEL)
        head.grid(row=1, column=0, sticky="ew", padx=10, pady=(0, 6))
        tk.Label(head, text="Tiket", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION_SMALL).pack(side="left")
        self.summary_badge_var = tk.StringVar(value="0 výběrů")
        tk.Label(head, textvariable=self.summary_badge_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        self.ticket_outer, self.ticket_canvas, self.ticket_inner = self.create_scrollable_vertical(frame, BET_PANEL)
        self.ticket_outer.grid(row=2, column=0, sticky="nsew", padx=10, pady=(0, 8))

    def build_controls_panel_v219(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=1, column=0, sticky="ew")

        row1 = tk.Frame(frame, bg=BET_PANEL)
        row1.pack(fill="x", padx=10, pady=(8, 6))
        row1.grid_columnconfigure(0, weight=1)
        row1.grid_columnconfigure(1, weight=1)

        left = tk.Frame(row1, bg=BET_PANEL)
        left.grid(row=0, column=0, sticky="ew", padx=(0, 4))
        tk.Label(left, text="Template ID", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        self.template_id_var = tk.StringVar(value="1")
        tk.Entry(left, textvariable=self.template_id_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL).pack(fill="x", pady=(3, 0), ipady=4)

        right = tk.Frame(row1, bg=BET_PANEL)
        right.grid(row=0, column=1, sticky="ew", padx=(4, 0))
        tk.Label(right, text="Bookmaker", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        self.bookmaker_combo = ttk.Combobox(right, textvariable=self.bookmaker_var, state="readonly")
        self.bookmaker_combo.pack(fill="x", pady=(3, 0))

        row2 = tk.Frame(frame, bg=BET_PANEL)
        row2.pack(fill="x", padx=10, pady=(0, 6))
        row2.grid_columnconfigure(0, weight=1)
        row2.grid_columnconfigure(1, weight=1)

        p1 = tk.Frame(row2, bg=BET_PANEL)
        p1.grid(row=0, column=0, sticky="ew", padx=(0, 4))
        tk.Label(p1, text="Max tiketů", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        tk.Entry(p1, textvariable=self.max_tickets_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL).pack(fill="x", pady=(3, 0), ipady=4)

        p2 = tk.Frame(row2, bg=BET_PANEL)
        p2.grid(row=0, column=1, sticky="ew", padx=(4, 0))
        tk.Label(p2, text="Min. pravděpod.", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        tk.Entry(p2, textvariable=self.min_probability_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL).pack(fill="x", pady=(3, 0), ipady=4)

        stake = tk.Frame(frame, bg=BET_PANEL)
        stake.pack(fill="x", padx=10, pady=(0, 6))
        tk.Label(stake, text="Vklad na 1 kombinaci", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        stake_row = tk.Frame(stake, bg=BET_PANEL)
        stake_row.pack(fill="x", pady=(3, 0))
        tk.Label(stake_row, text="Kč", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD_XS, padx=10, pady=5).pack(side="left")
        self.stake_entry = tk.Entry(
            stake_row,
            textvariable=self.stake_var,
            bg="#0F0D1A",
            fg=TEXT,
            insertbackground=TEXT,
            relief="flat",
            justify="right",
            font=FONT_BOLD,
        )
        self.stake_entry.pack(side="left", fill="x", expand=True, ipady=5)
        self.stake_entry.bind("<KeyRelease>", lambda _e: self.refresh_summary())
        self.stake_entry.bind("<FocusOut>", lambda _e: self.refresh_summary())

        quick = tk.Frame(frame, bg=BET_PANEL)
        quick.pack(fill="x", padx=10, pady=(0, 6))
        for amount in (10, 50, 100, 200):
            tk.Button(
                quick,
                text=str(amount),
                bg=BET_PANEL_2,
                fg=TEXT,
                font=FONT_XS,
                relief="flat",
                command=lambda a=amount: self._set_stake(a),
            ).pack(side="left", padx=(0, 4), ipady=2)

        actions = tk.Frame(frame, bg=BET_PANEL)
        actions.pack(fill="x", padx=10, pady=(2, 6))
        actions.grid_columnconfigure(0, weight=1)
        actions.grid_columnconfigure(1, weight=1)

        tk.Button(
            actions,
            text="ULOŽIT TIKET",
            bg=BLUE,
            fg=BG,
            font=FONT_BOLD_XS,
            relief="flat",
            command=self.save_ticket_direct,
        ).grid(row=0, column=0, sticky="ew", padx=(0, 4), ipady=7)

        tk.Button(
            actions,
            text="VYTVOŘIT TIKETY",
            bg=BET_GREEN,
            activebackground=BET_GREEN_DARK,
            activeforeground=TEXT,
            fg=TEXT,
            font=FONT_BOLD_XS,
            relief="flat",
            command=self.generate_runtime_run,
        ).grid(row=0, column=1, sticky="ew", padx=(4, 0), ipady=7)

        self.combo_toggle_btn = tk.Button(
            frame,
            text="ZOBRAZIT PŘEHLED TIKETŮ",
            bg=BET_PANEL_2,
            fg=TEXT,
            font=FONT_BOLD_XS,
            relief="flat",
            command=self.show_combos_window,
        )
        self.combo_toggle_btn.pack(fill="x", padx=10, pady=(0, 6), ipady=6)

        self.runtime_status_var = tk.StringVar(value="")
        tk.Label(frame, textvariable=self.runtime_status_var, bg=BET_PANEL, fg=MUTED, font=FONT_XS, justify="left", anchor="w").pack(fill="x", padx=10, pady=(0, 8))

    def _metric_box_top(self, parent, col: int, label: str, var: tk.StringVar):
        box = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        box.grid(row=0, column=col, sticky="ew", padx=(0 if col == 0 else 4, 0), pady=0)
        tk.Label(box, text=label, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_XS).pack(anchor="w", padx=8, pady=(5, 1))
        tk.Label(box, textvariable=var, bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD_XS).pack(anchor="w", padx=8, pady=(0, 5))

    def _set_stake(self, amount: int):
        self.stake_var.set(str(amount))
        self.refresh_summary()

    def save_ticket_direct(self):
        try:
            self.save_template_to_db()
            self.runtime_status_var.set(f"Tiket uložen do template ID {self.template_id_var.get()}.")
        except Exception as e:
            self.runtime_status_var.set(f"Uložení selhalo: {e}")

    def refresh_all_panels(self):
        self.refresh_ticket_panel()
        self.refresh_summary()
        if hasattr(self, "_update_button_states"):
            self._update_button_states()

    def refresh_ticket_panel(self):
        for widget in self.ticket_inner.winfo_children():
            widget.destroy()

        fixed_count = len(self.fixed_items)
        block_count = sum(len(v) for v in self.block_items.values())
        total_entries = fixed_count + block_count
        self.summary_badge_var.set(f"{total_entries} výběrů")

        if not total_entries:
            empty = tk.Frame(self.ticket_inner, bg=CARD_ITEM, highlightthickness=1, highlightbackground=BET_LINE)
            empty.pack(fill="x", pady=(0, 8))
            tk.Label(empty, text="Tiket je prázdný", bg=CARD_ITEM, fg=TEXT, font=FONT_BOLD).pack(anchor="w", padx=10, pady=(10, 2))
            tk.Label(empty, text="Klikni na kurz u zápasu a položka se hned propíše do tiketu.", bg=CARD_ITEM, fg=MUTED, font=FONT_SMALL, wraplength=300, justify="left").pack(anchor="w", padx=10, pady=(0, 10))
            return

        for idx, item in enumerate(self.fixed_items):
            self._render_fixed_ticket_item(self.ticket_inner, item, lambda i=idx: self.remove_fixed_item(i))

        for block_index in (1, 2, 3):
            items = self.block_items[block_index]
            if not items:
                continue
            self._render_ticket_section_header(f"Blok {self.block_label(block_index)}")
            for idx, item in enumerate(items):
                self._render_block_ticket_item(self.ticket_inner, item, block_index, lambda bi=block_index, i=idx: self.remove_block_item(bi, i))

    def _render_fixed_ticket_item(self, parent, item: dict, remove_cmd):
        card = tk.Frame(parent, bg=CARD_ITEM, highlightthickness=1, highlightbackground=ROW_LINE)
        card.pack(fill="x", pady=(0, 6))

        top = tk.Frame(card, bg=CARD_ITEM)
        top.pack(fill="x", padx=8, pady=(6, 2))
        icon = self._sport_icon_for_item(item)
        tk.Label(
            top,
            text=f"{icon}  {item.get('home_team', '?')} - {item.get('away_team', '?')}",
            bg=CARD_ITEM,
            fg=TEXT,
            font=FONT_BOLD_XS,
            anchor="w",
            wraplength=270,
            justify="left",
        ).pack(side="left", fill="x", expand=True)
        tk.Button(top, text="✕", bg=CARD_ITEM, fg=TEXT, relief="flat", font=FONT_XS, command=lambda: (remove_cmd(), self._update_button_states())).pack(side="right")

        row2 = tk.Frame(card, bg=CARD_ITEM)
        row2.pack(fill="x", padx=8, pady=(0, 6))
        tk.Label(row2, text=self.fmt_kickoff(item.get('kickoff')), bg=CARD_ITEM, fg=MUTED, font=FONT_XS).pack(side="left")
        tk.Label(row2, text=f"Výsledek zápasu: {item.get('outcome_code', '')}", bg=CARD_ITEM, fg=ACCENT, font=FONT_XS).pack(side="left", padx=(10, 0))
        tk.Label(row2, text=self.fmt_odds(item.get('odd_value')), bg=CARD_ITEM, fg=TEXT, font=FONT_BOLD).pack(side="right")

        note = self._ticket_extra_note(item)
        if note:
            tk.Label(card, text=note, bg=CARD_ITEM, fg=MUTED, font=FONT_XS, wraplength=300, justify="left").pack(anchor="w", padx=8, pady=(0, 6))

    def _render_block_ticket_item(self, parent, item: dict, block_index: int, remove_cmd):
        card = tk.Frame(parent, bg=CARD_ITEM_ALT, highlightthickness=1, highlightbackground=ROW_LINE)
        card.pack(fill="x", pady=(0, 6))

        top = tk.Frame(card, bg=CARD_ITEM_ALT)
        top.pack(fill="x", padx=8, pady=(6, 2))
        icon = self._sport_icon_for_item(item)
        tk.Label(
            top,
            text=f"{icon}  {item.get('home_team', '?')} - {item.get('away_team', '?')}",
            bg=CARD_ITEM_ALT,
            fg=TEXT,
            font=FONT_BOLD_XS,
            anchor="w",
            wraplength=245,
            justify="left",
        ).pack(side="left", fill="x", expand=True)
        tk.Button(top, text="✕", bg=CARD_ITEM_ALT, fg=TEXT, relief="flat", font=FONT_XS, command=lambda: (remove_cmd(), self._update_button_states())).pack(side="right")

        row2 = tk.Frame(card, bg=CARD_ITEM_ALT)
        row2.pack(fill="x", padx=8, pady=(0, 6))
        tk.Label(row2, text=self.fmt_kickoff(item.get('kickoff')), bg=CARD_ITEM_ALT, fg=MUTED, font=FONT_XS).pack(side="left")
        tk.Label(row2, text="Výsledek zápasu:", bg=CARD_ITEM_ALT, fg=YELLOW, font=FONT_XS).pack(side="left", padx=(10, 6))

        odds_wrap = tk.Frame(row2, bg=CARD_ITEM_ALT)
        odds_wrap.pack(side="right")
        match_row = self._match_row_lookup().get(int(item.get("match_id")))
        for code in ("1", "X", "2"):
            odd = self.fmt_odds(match_row.get(f"odd_{'1' if code=='1' else 'x' if code=='X' else '2'}") if match_row else None)
            box = tk.Frame(odds_wrap, bg=ODD_BG)
            box.pack(side="left", padx=(4, 0))
            tk.Label(box, text=code, bg=ODD_BG, fg=ODD_LABEL, font=("Segoe UI", 7)).pack(side="left", padx=(4, 2), pady=2)
            tk.Label(box, text=odd, bg=ODD_BG, fg=TEXT, font=("Segoe UI", 7, "bold")).pack(side="left", padx=(0, 4), pady=2)

        note = self._ticket_extra_note(item)
        if note:
            tk.Label(card, text=note, bg=CARD_ITEM_ALT, fg=MUTED, font=FONT_XS, wraplength=300, justify="left").pack(anchor="w", padx=8, pady=(0, 6))

    def refresh_summary(self):
        combos = self.build_combinations()
        self._combo_rows_cache = combos

        combo_count = len(combos)
        valid_odds = [c["total_odds"] for c in combos if c.get("total_odds")]
        stake = self.parse_stake()
        total_stake = stake * Decimal(combo_count)
        max_return = max((odd * stake for odd in valid_odds), default=Decimal("0"))

        if len(valid_odds) == 1:
            odds_text = f"{valid_odds[0]:.2f}"
        elif len(valid_odds) > 1:
            odds_text = f"{min(valid_odds):.2f} až {max(valid_odds):.2f}"
        else:
            odds_text = "-"

        self.metric_odds_var.set(odds_text)
        self.metric_combos_var.set(str(combo_count))
        self.metric_stake_var.set(f"{total_stake:.2f} Kč")
        self.metric_return_var.set(f"{max_return:.2f} Kč")

        block_count = sum(len(v) for v in self.block_items.values())
        state = "normal" if block_count > 0 else "disabled"
        self.combo_toggle_btn.config(state=state)

        if hasattr(self, "_combo_window") and self._combo_window is not None and self._combo_window.winfo_exists():
            self.render_combo_window()


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV219(root)
    root.mainloop()


if __name__ == "__main__":
    main()
