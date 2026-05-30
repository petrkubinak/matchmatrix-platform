# -*- coding: utf-8 -*-
from __future__ import annotations

import tkinter as tk
from tkinter import ttk, messagebox
from decimal import Decimal
import tkinter.font as tkfont

from matchmatrix_ticket_studio_V2_19_fix import TicketStudioV219
from matchmatrix_ticket_studio_V2_18 import CARD_ITEM, CARD_ITEM_ALT, ROW_LINE, ODD_BG, ODD_LABEL
from matchmatrix_ticket_studio_V2_9 import BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_LINE, BET_SOFT
from matchmatrix_ticket_studio_V2_12 import BLUE, BET_GREEN, BET_GREEN_DARK
from matchmatrix_ticket_studio_V2_14 import FONT_XS, FONT_BOLD_XS, FONT_SECTION_SMALL
from matchmatrix_ticket_studio_V2_7 import BG, TEXT, MUTED, ACCENT, RED, YELLOW, FONT_SMALL, FONT_BOLD


class TicketStudioV220(TicketStudioV219):
    def __init__(self, root: tk.Tk):
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.20")
        if hasattr(self, "viewport_var"):
            self.viewport_var.set("desktop | narrow left | top runtime row | live ticket refresh")
        self.root.after(150, self.adjust_left_panel_width)

    def build_header(self):
        if not hasattr(self, "viewport_var"):
            self.viewport_var = tk.StringVar(value="desktop | narrow left | top runtime row | live ticket refresh")

        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=8, pady=(8, 6))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.20",
            bg=BG,
            fg=TEXT,
            font=("Segoe UI", 15, "bold"),
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="užší levý panel • horní řádek Template/Bookmaker/Max/Min • živé propsání do tiketu",
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
            left_w = 190
            center_w = max(760, int(total * 0.60))
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

            control_floor = 168
            target_left = max(control_floor, min(245, max_px + 34))
            center_w = max(760, int(total * 0.60))
            right_min = 470
            if target_left + center_w + right_min > total:
                center_w = max(700, total - target_left - right_min)

            self.main_paned.sashpos(0, target_left)
            self.main_paned.sashpos(1, target_left + center_w)
        except Exception:
            pass

    def build_right_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_ticket_panel_v220(parent)
        self.build_controls_panel_v219(parent)

    def build_ticket_panel_v220(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=0, column=0, sticky="nsew", pady=(0, 8))
        frame.grid_rowconfigure(3, weight=1)
        frame.grid_columnconfigure(0, weight=1)
        self.ticket_frame = frame

        top_fields = tk.Frame(frame, bg=BET_PANEL)
        top_fields.grid(row=0, column=0, sticky="ew", padx=8, pady=(8, 6))
        for c in range(4):
            top_fields.grid_columnconfigure(c, weight=1)

        self._top_entry_box(top_fields, 0, "Template ID", "template")
        self._top_entry_box(top_fields, 1, "Bookmaker", "bookmaker")
        self._top_entry_box(top_fields, 2, "Max tiketů", "max")
        self._top_entry_box(top_fields, 3, "Min. pravděpod.", "min")

        metrics = tk.Frame(frame, bg=BET_PANEL)
        metrics.grid(row=1, column=0, sticky="ew", padx=8, pady=(0, 6))
        for c in range(4):
            metrics.grid_columnconfigure(c, weight=1)
        self._metric_box_top(metrics, 0, "Kurz", self.metric_odds_var)
        self._metric_box_top(metrics, 1, "Kombinací", self.metric_combos_var)
        self._metric_box_top(metrics, 2, "Vsadíš", self.metric_stake_var)
        self._metric_box_top(metrics, 3, "Výhra", self.metric_return_var)

        head = tk.Frame(frame, bg=BET_PANEL)
        head.grid(row=2, column=0, sticky="ew", padx=10, pady=(0, 6))
        tk.Label(head, text="Tiket", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION_SMALL).pack(side="left")
        self.summary_badge_var = tk.StringVar(value="0 výběrů")
        tk.Label(head, textvariable=self.summary_badge_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        self.ticket_outer, self.ticket_canvas, self.ticket_inner = self.create_scrollable_vertical(frame, BET_PANEL)
        self.ticket_outer.grid(row=3, column=0, sticky="nsew", padx=10, pady=(0, 8))

    def _top_entry_box(self, parent, col: int, label: str, mode: str):
        box = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        box.grid(row=0, column=col, sticky="ew", padx=(0 if col == 0 else 4, 0), pady=0)
        tk.Label(box, text=label, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_XS).pack(anchor="w", padx=8, pady=(5, 1))

        if mode == "template":
            if not hasattr(self, "template_id_var"):
                self.template_id_var = tk.StringVar(value="1")
            entry = tk.Entry(box, textvariable=self.template_id_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL)
            entry.pack(fill="x", padx=8, pady=(0, 6), ipady=3)
        elif mode == "bookmaker":
            self.bookmaker_combo = ttk.Combobox(box, textvariable=self.bookmaker_var, state="readonly")
            self.bookmaker_combo.pack(fill="x", padx=8, pady=(0, 6), ipady=1)
        elif mode == "max":
            entry = tk.Entry(box, textvariable=self.max_tickets_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL)
            entry.pack(fill="x", padx=8, pady=(0, 6), ipady=3)
        else:
            entry = tk.Entry(box, textvariable=self.min_probability_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_SMALL)
            entry.pack(fill="x", padx=8, pady=(0, 6), ipady=3)

    def build_controls_panel_v219(self, parent):
        super().build_controls_panel_v219(parent)
        # Remove duplicated top controls from bottom panel, keep stake/actions/status only
        # Children layout: row1, row2, stake, quick, actions, combo_toggle_btn, label
        children = self.right_panel.grid_slaves(row=1, column=0)
        # not needed; operate directly on last-created frame
        frame = parent.grid_slaves(row=1, column=0)[0]
        packed = frame.pack_slaves()
        # First two packed frames are duplicated Template/Bookmaker and Max/Min blocks.
        # Hide them because they are now at the top.
        hidden_count = 0
        for widget in packed:
            if isinstance(widget, tk.Frame) and hidden_count < 2:
                widget.pack_forget()
                hidden_count += 1
            if hidden_count >= 2:
                break

    def _refresh_live_ticket(self):
        self.refresh_ticket_panel()
        self.refresh_summary()
        if hasattr(self, "_update_button_states"):
            self._update_button_states()

    def _toggle_fixed_pick_fast(self, row: dict, market_code: str, outcome_code: str, odd_value):
        key = self._fixed_key(row.get("match_id"), market_code, outcome_code)
        before = len(self.fixed_items)
        self.fixed_items = [
            x for x in self.fixed_items
            if self._fixed_key(x.get("match_id"), x.get("market_code"), x.get("outcome_code")) != key
        ]
        if len(self.fixed_items) == before:
            market_id = self.get_market_id(market_code)
            outcome_id = self.get_market_outcome_id(market_code, outcome_code)
            if not market_id or not outcome_id:
                messagebox.showerror("DB chyba", f"Chybí market/outcome map pro {market_code}/{outcome_code}.")
                return
            self.fixed_items = [
                x for x in self.fixed_items
                if not (int(x.get("match_id")) == int(row.get("match_id")) and str(x.get("market_code")) == str(market_code).upper())
            ]
            for bi in (1, 2, 3):
                self.block_items[bi] = [x for x in self.block_items[bi] if int(x.get("match_id")) != int(row.get("match_id"))]
            item = {
                "item_type": "FIXED",
                "match_id": int(row.get("match_id")),
                "kickoff": row.get("kickoff"),
                "home_team": str(row.get("home_team", "?")),
                "away_team": str(row.get("away_team", "?")),
                "league_name": str(row.get("league_name", "?")),
                "sport_code": str(row.get("sport_code", "FB")),
                "market_code": str(market_code).upper(),
                "market_id": int(market_id),
                "outcome_code": str(outcome_code).upper(),
                "market_outcome_id": int(outcome_id),
                "odd_value": self.safe_decimal(odd_value),
                "block_index": 0,
            }
            self.fixed_items.append(item)
        self._refresh_live_ticket()

    def _toggle_block_pick_fast(self, row: dict, block_index: int):
        match_id = int(row.get("match_id"))
        current = self._selected_block_map().get(match_id, 0)
        for bi in (1, 2, 3):
            self.block_items[bi] = [x for x in self.block_items[bi] if int(x.get("match_id")) != match_id]
        if current != block_index:
            market_id = self.get_market_id("H2H")
            if not market_id:
                messagebox.showerror("DB chyba", "Chybí market_id pro H2H.")
                return
            self.fixed_items = [x for x in self.fixed_items if int(x.get("match_id")) != match_id]
            self.block_items[block_index].append({
                "item_type": "BLOCK",
                "match_id": match_id,
                "kickoff": row.get("kickoff"),
                "home_team": str(row.get("home_team", "?")),
                "away_team": str(row.get("away_team", "?")),
                "league_name": str(row.get("league_name", "?")),
                "sport_code": str(row.get("sport_code", "FB")),
                "market_code": "H2H",
                "market_id": int(market_id),
                "outcome_code": "",
                "market_outcome_id": None,
                "odd_value": None,
                "block_index": int(block_index),
            })
        self._refresh_live_ticket()

    def refresh_all_panels(self):
        self.refresh_ticket_panel()
        self.refresh_summary()
        if hasattr(self, "_update_button_states"):
            self._update_button_states()

    def _render_ticket_section_header(self, title: str):
        tag = tk.Frame(self.ticket_inner, bg=BET_PANEL)
        tag.pack(fill="x", pady=(4, 6))
        tk.Label(tag, text=title, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=7, pady=2).pack(anchor="w")

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
            wraplength=250,
            justify="left",
        ).pack(side="left", fill="x", expand=True)
        tk.Button(top, text="✕", bg=CARD_ITEM, fg=TEXT, relief="flat", font=FONT_XS, command=lambda: (remove_cmd(), self._update_button_states())).pack(side="right")

        row2 = tk.Frame(card, bg=CARD_ITEM)
        row2.pack(fill="x", padx=8, pady=(0, 6))
        tk.Label(row2, text=self.fmt_kickoff(item.get('kickoff')), bg=CARD_ITEM, fg=MUTED, font=FONT_XS).pack(side="left")
        tk.Label(row2, text=f"Výsledek zápasu: {item.get('outcome_code', '')}", bg=CARD_ITEM, fg=ACCENT, font=FONT_XS).pack(side="left", padx=(10, 0))
        tk.Label(row2, text=self.fmt_odds(item.get('odd_value')), bg=CARD_ITEM, fg=TEXT, font=FONT_BOLD).pack(side="right")

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
            wraplength=225,
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
            source_key = "odd_1" if code == "1" else "odd_x" if code == "X" else "odd_2"
            odd = self.fmt_odds(match_row.get(source_key) if match_row else None)
            box = tk.Frame(odds_wrap, bg=ODD_BG)
            box.pack(side="left", padx=(4, 0))
            tk.Label(box, text=code, bg=ODD_BG, fg=ODD_LABEL, font=("Segoe UI", 7)).pack(side="left", padx=(4, 2), pady=2)
            tk.Label(box, text=odd, bg=ODD_BG, fg=TEXT, font=("Segoe UI", 7, "bold")).pack(side="left", padx=(0, 4), pady=2)

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
        self.combo_toggle_btn.config(state="normal" if block_count > 0 else "disabled")
        if hasattr(self, "_combo_window") and self._combo_window is not None and self._combo_window.winfo_exists():
            self.render_combo_window()


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV220(root)
    root.mainloop()


if __name__ == "__main__":
    main()
