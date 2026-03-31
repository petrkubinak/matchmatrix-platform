from __future__ import annotations

import tkinter as tk
from tkinter import ttk
from collections import defaultdict

from matchmatrix_ticket_studio_V2_10 import TicketStudioV210
from matchmatrix_ticket_studio_V2_7 import *
from matchmatrix_ticket_studio_V2_9 import BET_PANEL_2, BET_LINE, BET_SOFT


SECTION_BG = "#171326"
SECTION_ACCENT = "#F1C453"
ROW_EVEN = "#151122"
ROW_ODD = "#1A152B"
SELECT_GREEN = "#2FAE66"
SELECT_GREEN_DARK = "#238651"
SELECT_TEXT_DARK = "#06120B"
TEAM_META = "#9F96BE"

FLAG_MAP = {
    "england": "🇬🇧", "premier league": "🇬🇧", "championship": "🇬🇧",
    "spain": "🇪🇸", "la liga": "🇪🇸", "primera division": "🇪🇸",
    "italy": "🇮🇹", "serie a": "🇮🇹",
    "germany": "🇩🇪", "bundesliga": "🇩🇪",
    "france": "🇫🇷", "ligue 1": "🇫🇷",
    "netherlands": "🇳🇱", "ered": "🇳🇱",
    "portugal": "🇵🇹", "primeira": "🇵🇹",
    "brazil": "🇧🇷", "brasileiro": "🇧🇷",
    "argentina": "🇦🇷",
    "czech": "🇨🇿", "chance liga": "🇨🇿", "fortuna liga": "🇨🇿",
    "slovakia": "🇸🇰", "poland": "🇵🇱", "ekstraklasa": "🇵🇱",
    "austria": "🇦🇹", "belgium": "🇧🇪", "switzerland": "🇨🇭",
    "denmark": "🇩🇰", "sweden": "🇸🇪", "norway": "🇳🇴", "scotland": "🏴",
}


class TicketStudioV2104(TicketStudioV210):
    def __init__(self, root: tk.Tk):
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.10.4")
        self.viewport_var.set("desktop | grouped leagues | safe patch")
        self.refresh_all_panels()

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=(10, 8))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.10.4",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="bezpečný patch nad V2.10 • domácí/hosté odděleně • vlaječky lig • zvýraznění vybraného kurzu",
            bg=BG,
            fg=MUTED,
            font=FONT,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="desktop | grouped leagues | safe patch")
        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=ACCENT,
            font=FONT_SMALL,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

    def refresh_all_panels(self):
        super().refresh_all_panels()
        if hasattr(self, "match_inner"):
            self.render_match_rows()

    def _league_flag(self, sample_row: dict) -> str:
        for key in (
            str(sample_row.get("country_name", "")),
            str(sample_row.get("country", "")),
            str(sample_row.get("league_name", "")),
        ):
            norm = key.strip().lower()
            if not norm:
                continue
            for token, flag in FLAG_MAP.items():
                if token in norm:
                    return flag
        return "🏳️"

    def _fixed_key(self, match_id: int, market_code: str, outcome_code: str):
        return (int(match_id), str(market_code).upper(), str(outcome_code).upper())

    def _selected_fixed_keys(self):
        return {
            self._fixed_key(item.get("match_id"), item.get("market_code"), item.get("outcome_code"))
            for item in self.fixed_items
        }

    def _selected_block_map(self):
        return {
            int(item.get("match_id")): int(item.get("block_index", 0))
            for bi in (1, 2, 3)
            for item in self.block_items[bi]
        }

    def _toggle_fixed_pick(self, row: dict, market_code: str, outcome_code: str, odd_value):
        key = self._fixed_key(row.get("match_id"), market_code, outcome_code)
        before = len(self.fixed_items)
        self.fixed_items = [
            x for x in self.fixed_items
            if self._fixed_key(x.get("match_id"), x.get("market_code"), x.get("outcome_code")) != key
        ]
        if len(self.fixed_items) != before:
            self.refresh_all_panels()
            return
        self.add_fixed_pick(row, market_code, outcome_code, odd_value)

    def _toggle_block_pick(self, row: dict, block_index: int):
        match_id = int(row.get("match_id"))
        if any(int(x.get("match_id")) == match_id for x in self.block_items[block_index]):
            self.block_items[block_index] = [x for x in self.block_items[block_index] if int(x.get("match_id")) != match_id]
            self.refresh_all_panels()
            return
        self.add_to_block(row, block_index)

    def render_match_rows(self):
        for widget in self.match_inner.winfo_children():
            widget.destroy()

        if not self.visible_matches:
            tk.Label(self.match_inner, text="Žádné zápasy pro vybrané soutěže.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", padx=10, pady=10)
            return

        grouped = defaultdict(list)
        for row in self.visible_matches:
            grouped[str(row.get("league_name", "?"))].append(row)

        row_index = 0
        for league_name in sorted(grouped.keys()):
            rows = grouped[league_name]
            self._render_league_section(league_name, rows)
            for row in rows:
                self.render_match_row(row, row_index)
                row_index += 1

    def _render_league_section(self, league_name: str, rows: list[dict]):
        box = tk.Frame(self.match_inner, bg=SECTION_BG, width=self.grid_total_width, height=34, highlightthickness=0)
        box.pack(fill="x", padx=6, pady=(8, 3))
        box.pack_propagate(False)

        left = tk.Frame(box, bg=SECTION_BG)
        left.pack(side="left", fill="both", expand=True, padx=10)

        flag = self._league_flag(rows[0])
        tk.Label(left, text=f"{flag}  {league_name}", bg=SECTION_BG, fg=SECTION_ACCENT, font=FONT_BOLD, anchor="w").pack(side="left")
        tk.Label(left, text=f"{len(rows)} záp.", bg=SECTION_BG, fg=MUTED, font=FONT_SMALL, anchor="w").pack(side="left", padx=(8, 0))

    def render_match_row(self, row: dict, row_index: int):
        bg_row = ROW_EVEN if row_index % 2 == 0 else ROW_ODD
        wrap = tk.Frame(self.match_inner, bg=bg_row, width=self.grid_total_width, height=34, highlightthickness=0)
        wrap.pack(fill="x", padx=6, pady=1)
        wrap.pack_propagate(False)

        dc_odds = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))

        values = [
            self.fmt_kickoff(row.get("kickoff")),
            str(row.get("home_team", "?")),
            str(row.get("away_team", "?")),
        ]

        x = 0
        # datum menší kurzívou
        lbl = tk.Label(wrap, text=values[0], bg=bg_row, fg=TEAM_META, font=("Segoe UI", 8, "italic"), anchor="w")
        lbl.place(x=x + 8, y=0, width=self.grid_columns[0][1] - 8, height=34)
        x += self.grid_columns[0][1]

        # domácí / hosté odděleně
        lbl = tk.Label(wrap, text=values[1], bg=bg_row, fg=TEXT, font=FONT_GRID, anchor="w")
        lbl.place(x=x + 8, y=0, width=self.grid_columns[1][1] - 8, height=34)
        x += self.grid_columns[1][1]

        lbl = tk.Label(wrap, text=values[2], bg=bg_row, fg=TEXT, font=FONT_GRID, anchor="w")
        lbl.place(x=x + 8, y=0, width=self.grid_columns[2][1] - 8, height=34)
        x += self.grid_columns[2][1]

        self.make_grid_pick_button(wrap, row, bg_row, x, 54, "H2H", "1", row.get("odd_1"))
        x += 54
        self.make_grid_pick_button(wrap, row, bg_row, x, 54, "H2H", "X", row.get("odd_x"))
        x += 54
        self.make_grid_pick_button(wrap, row, bg_row, x, 54, "H2H", "2", row.get("odd_2"))
        x += 54

        self.make_grid_pick_button(wrap, row, bg_row, x, 58, "DC", "1X", dc_odds["1X"])
        x += 58
        self.make_grid_pick_button(wrap, row, bg_row, x, 58, "DC", "12", dc_odds["12"])
        x += 58
        self.make_grid_pick_button(wrap, row, bg_row, x, 58, "DC", "X2", dc_odds["X2"])
        x += 58

        for width in (70, 70, 70, 70):
            lbl = tk.Label(wrap, text="—", bg=bg_row, fg=MUTED, font=FONT_SMALL, anchor="center")
            lbl.place(x=x, y=0, width=width, height=34)
            x += width

        self.make_block_button(wrap, row, bg_row, x, 42, 1)
        x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 2)
        x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 3)

    def make_grid_pick_button(self, parent, row: dict, bg_row: str, x: int, width: int, market_code: str, outcome_code: str, odd_value):
        is_selected = self._fixed_key(row.get("match_id"), market_code, outcome_code) in self._selected_fixed_keys()
        btn = tk.Button(
            parent,
            text=self.fmt_odds(odd_value),
            bg=SELECT_GREEN if is_selected else (CARD_2 if odd_value else bg_row),
            fg=SELECT_TEXT_DARK if is_selected else (TEXT if odd_value else MUTED),
            activebackground=SELECT_GREEN_DARK if is_selected else CARD_3,
            activeforeground=SELECT_TEXT_DARK if is_selected else TEXT,
            font=FONT_SMALL,
            relief="flat",
            borderwidth=0,
            state="normal" if odd_value else "disabled",
            command=lambda: self._toggle_fixed_pick(row, market_code, outcome_code, odd_value)
        )
        btn.place(x=x + 2, y=4, width=width - 4, height=26)

    def make_block_button(self, parent: tk.Frame, row: dict, bg_row: str, x: int, width: int, block_index: int):
        current_block = self._selected_block_map().get(int(row.get("match_id")), 0)
        is_selected = current_block == block_index
        btn = tk.Button(
            parent,
            text=self.block_label(block_index),
            bg=SELECT_GREEN if is_selected else CARD_2,
            fg=SELECT_TEXT_DARK if is_selected else TEXT,
            activebackground=SELECT_GREEN_DARK if is_selected else CARD_3,
            activeforeground=SELECT_TEXT_DARK if is_selected else TEXT,
            font=FONT_SMALL,
            relief="flat",
            borderwidth=0,
            command=lambda: self._toggle_block_pick(row, block_index)
        )
        btn.place(x=x + 2, y=4, width=width - 4, height=26)

    def _render_pick_card(self, parent, item: dict, meta: str, remove_cmd, accent=ACCENT):
        card = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        card.pack(fill="x", pady=(0, 6))

        top = tk.Frame(card, bg=BET_PANEL_2)
        top.pack(fill="x", padx=8, pady=(7, 2))
        tk.Label(
            top,
            text=str(item.get("league_name", "?")),
            bg=BET_PANEL_2,
            fg=BET_SOFT,
            font=("Segoe UI", 8, "italic"),
            anchor="w"
        ).pack(side="left")

        body = tk.Frame(card, bg=BET_PANEL_2)
        body.pack(fill="x", padx=8, pady=(0, 7))

        tk.Label(
            body,
            text=f"{item.get('home_team', '?')} vs {item.get('away_team', '?')}",
            bg=BET_PANEL_2,
            fg=TEXT,
            font=FONT_BOLD,
            anchor="w"
        ).pack(side="left", fill="x", expand=True)

        tk.Label(
            body,
            text=meta,
            bg=BET_PANEL_2,
            fg=accent,
            font=FONT_SMALL,
            anchor="e",
            justify="right"
        ).pack(side="right")

        tk.Button(card, text="ODEBRAT", bg=RED, fg=BG, font=FONT_SMALL, relief="flat", command=remove_cmd).pack(anchor="e", padx=8, pady=(0, 7))

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
                meta = f"{item.get('outcome_code', '')} @ {self.fmt_odds(item.get('odd_value'))}"
                self._render_pick_card(self.selection_inner, item, meta, lambda i=idx: self.remove_fixed_item(i), accent=SELECT_GREEN)

        for block_index in (1, 2, 3):
            items = self.block_items[block_index]
            if not items:
                continue
            self._section_title(self.selection_inner, f"Blok {self.block_label(block_index)}")
            for idx, item in enumerate(items):
                meta = f"blok {self.block_label(block_index)}"
                self._render_pick_card(self.selection_inner, item, meta, lambda bi=block_index, i=idx: self.remove_block_item(bi, i), accent=YELLOW)


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV2104(root)
    root.mainloop()


if __name__ == "__main__":
    main()
