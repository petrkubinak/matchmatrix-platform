# -*- coding: utf-8 -*-
from __future__ import annotations

import tkinter as tk
from tkinter import ttk
import tkinter.font as tkfont

from matchmatrix_ticket_studio_V2_17 import TicketStudioV217
from matchmatrix_ticket_studio_V2_7 import BG, CARD, CARD_2, TEXT, MUTED, ACCENT, YELLOW, FONT_SMALL, FONT_BOLD
from matchmatrix_ticket_studio_V2_14 import FONT_XS, FONT_BOLD_XS, FONT_SECTION_SMALL
from matchmatrix_ticket_studio_V2_9 import BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_LINE, BET_SOFT

CARD_ITEM = "#241D3C"
CARD_ITEM_ALT = "#2C2447"
ROW_LINE = "#3B315D"
ODD_BG = "#31285A"
ODD_LABEL = "#BEB0E6"


class TicketStudioV218(TicketStudioV217):
    def __init__(self, root: tk.Tk):
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.18")
        if hasattr(self, "viewport_var"):
            self.viewport_var.set("desktop | compact left by leagues | compact ticket rows")
        self.root.after(150, self.adjust_left_panel_width)

    def build_header(self):
        if not hasattr(self, "viewport_var"):
            self.viewport_var = tk.StringVar(value="desktop | compact left by leagues | compact ticket rows")

        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=8, pady=(8, 6))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.18",
            bg=BG,
            fg=TEXT,
            font=("Segoe UI", 15, "bold"),
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="užší levý panel podle soutěží • kompaktní tiket • bloky s 1/X/2 kurzy vpravo",
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
            left_w = 250
            center_w = max(760, int(total * 0.58))
            self.main_paned.sashpos(0, left_w)
            self.main_paned.sashpos(1, left_w + center_w)
        except Exception:
            pass

    def build_league_selector(self, initial: bool):
        super().build_league_selector(initial)
        self.root.after(50, self.adjust_left_panel_width)

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

            control_floor = 210
            target_left = max(control_floor, min(330, max_px + 55))
            center_w = max(760, int(total * 0.58))
            right_min = 420
            if target_left + center_w + right_min > total:
                center_w = max(680, total - target_left - right_min)

            self.main_paned.sashpos(0, target_left)
            self.main_paned.sashpos(1, target_left + center_w)
        except Exception:
            pass

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
            tk.Label(
                empty,
                text="Klikni na kurz u zápasu a položka se hned propíše do tiketu.",
                bg=CARD_ITEM,
                fg=MUTED,
                font=FONT_SMALL,
                wraplength=300,
                justify="left",
            ).pack(anchor="w", padx=10, pady=(0, 10))
            return

        if self.fixed_items:
            self._render_ticket_section_header("FIXED")
            for idx, item in enumerate(self.fixed_items):
                self._render_fixed_ticket_item(self.ticket_inner, item, lambda i=idx: self.remove_fixed_item(i))

        for block_index in (1, 2, 3):
            items = self.block_items[block_index]
            if not items:
                continue
            self._render_ticket_section_header(f"Blok {self.block_label(block_index)}")
            for idx, item in enumerate(items):
                self._render_block_ticket_item(self.ticket_inner, item, block_index, lambda bi=block_index, i=idx: self.remove_block_item(bi, i))

    def _render_ticket_section_header(self, text: str):
        row = tk.Frame(self.ticket_inner, bg=BET_PANEL)
        row.pack(fill="x", pady=(2, 6))
        tk.Label(row, text=text, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=7, pady=2).pack(anchor="w")

    def _render_fixed_ticket_item(self, parent, item: dict, remove_cmd):
        card = tk.Frame(parent, bg=CARD_ITEM, highlightthickness=1, highlightbackground=ROW_LINE)
        card.pack(fill="x", pady=(0, 6))

        top = tk.Frame(card, bg=CARD_ITEM)
        top.pack(fill="x", padx=8, pady=(7, 2))
        icon = self._sport_icon_for_item(item)
        tk.Label(
            top,
            text=f"{icon}  {item.get('home_team', '?')} - {item.get('away_team', '?')}",
            bg=CARD_ITEM,
            fg=TEXT,
            font=FONT_BOLD_XS,
            anchor="w",
            wraplength=280,
            justify="left",
        ).pack(side="left", fill="x", expand=True)
        tk.Button(top, text="✕", bg=CARD_ITEM, fg=TEXT, relief="flat", font=FONT_XS, command=lambda: (remove_cmd(), self._update_button_states())).pack(side="right")

        middle = tk.Frame(card, bg=CARD_ITEM)
        middle.pack(fill="x", padx=8, pady=(0, 7))
        tk.Label(middle, text=self.fmt_kickoff(item.get('kickoff')), bg=CARD_ITEM, fg=MUTED, font=FONT_XS).pack(side="left")
        tk.Label(middle, text=f"Výsledek zápasu: {item.get('outcome_code', '')}", bg=CARD_ITEM, fg=ACCENT, font=FONT_XS).pack(side="left", padx=(10, 0))
        tk.Label(middle, text=self.fmt_odds(item.get('odd_value')), bg=CARD_ITEM, fg=TEXT, font=FONT_BOLD).pack(side="right")

        note = self._ticket_extra_note(item)
        if note:
            tk.Label(card, text=note, bg=CARD_ITEM, fg=MUTED, font=FONT_XS, wraplength=310, justify="left").pack(anchor="w", padx=8, pady=(0, 7))

    def _render_block_ticket_item(self, parent, item: dict, block_index: int, remove_cmd):
        card = tk.Frame(parent, bg=CARD_ITEM_ALT, highlightthickness=1, highlightbackground=ROW_LINE)
        card.pack(fill="x", pady=(0, 6))

        top = tk.Frame(card, bg=CARD_ITEM_ALT)
        top.pack(fill="x", padx=8, pady=(7, 2))
        icon = self._sport_icon_for_item(item)
        tk.Label(
            top,
            text=f"{icon}  {item.get('home_team', '?')} - {item.get('away_team', '?')}",
            bg=CARD_ITEM_ALT,
            fg=TEXT,
            font=FONT_BOLD_XS,
            anchor="w",
            wraplength=250,
            justify="left",
        ).pack(side="left", fill="x", expand=True)
        tk.Button(top, text="✕", bg=CARD_ITEM_ALT, fg=TEXT, relief="flat", font=FONT_XS, command=lambda: (remove_cmd(), self._update_button_states())).pack(side="right")

        row2 = tk.Frame(card, bg=CARD_ITEM_ALT)
        row2.pack(fill="x", padx=8, pady=(0, 2))
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
            tk.Label(card, text=note, bg=CARD_ITEM_ALT, fg=MUTED, font=FONT_XS, wraplength=310, justify="left").pack(anchor="w", padx=8, pady=(0, 7))
        else:
            tk.Frame(card, bg=CARD_ITEM_ALT, height=5).pack(fill="x")

    def _match_row_lookup(self) -> dict[int, dict]:
        return {
            int(r.get("match_id")): r
            for r in getattr(self, "all_matches", [])
            if r.get("match_id") is not None
        }

    def _ticket_extra_note(self, item: dict) -> str:
        neutral = item.get("neutral_venue")
        if neutral in (True, "t", "true", 1, "1"):
            return "Neutrální hřiště"
        venue = str(item.get("venue_note") or "").strip()
        return venue


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV218(root)
    root.mainloop()


if __name__ == "__main__":
    main()
