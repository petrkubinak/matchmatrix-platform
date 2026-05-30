from __future__ import annotations

import tkinter as tk
from collections import defaultdict

from matchmatrix_ticket_studio_V2_10_4 import TicketStudioV2104, FLAG_MAP
from matchmatrix_ticket_studio_V2_10 import ROW_EVEN, ROW_ODD, SECTION_BG, SECTION_ACCENT
from matchmatrix_ticket_studio_V2_7 import *


PINK = "#D46CFF"
PINK_DARK = "#B14DE8"
PINK_TEXT = "#12081D"
DATE_SOFT = "#A99BCF"


class TicketStudioV2105(TicketStudioV2104):
    def __init__(self, root: tk.Tk):
        self._fixed_btn_refs = {}
        self._block_btn_refs = {}
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.10.5")
        self.viewport_var.set("desktop | compact center | no extra columns")
        self.refresh_all_panels()

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=(10, 8))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.10.5",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="rychlejší patch nad V2.10 • růžové zvýraznění • užší střed • Pred/Forma/Tab/H2H přes detail týmu",
            bg=BG,
            fg=MUTED,
            font=FONT,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="desktop | compact center | no extra columns")
        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=ACCENT,
            font=FONT_SMALL,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

    def build_center_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        top = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        top.grid(row=0, column=0, sticky="nsew", pady=(0, 8))

        tk.Label(top, text="Nabídka zápasů", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 4))
        tk.Label(
            top,
            text="kompaktní přehled • domácí / hosté odděleně • bez pomocných sloupců • zvýraznění vybraného kurzu",
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL,
        ).pack(anchor="w", padx=10, pady=(0, 10))

        grid_box = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        grid_box.grid(row=1, column=0, sticky="nsew")
        grid_box.grid_rowconfigure(1, weight=1)
        grid_box.grid_columnconfigure(0, weight=1)

        self.grid_columns = [
            ("ZÁPAS", 430, "w"),
            ("1", 54, "center"),
            ("X", 54, "center"),
            ("2", 54, "center"),
            ("1X", 58, "center"),
            ("12", 58, "center"),
            ("X2", 58, "center"),
            ("A", 42, "center"),
            ("B", 42, "center"),
            ("C", 42, "center"),
        ]
        self.grid_total_width = sum(col[1] for col in self.grid_columns) + 20

        self.match_header = tk.Frame(grid_box, bg=CARD_2, width=self.grid_total_width)
        self.match_header.grid(row=0, column=0, sticky="ew")
        self.match_header.grid_propagate(False)
        self.build_match_header(self.match_header)

        body = tk.Frame(grid_box, bg=CARD)
        body.grid(row=1, column=0, sticky="nsew")
        body.grid_rowconfigure(0, weight=1)
        body.grid_columnconfigure(0, weight=1)

        self.match_canvas = tk.Canvas(body, bg=CARD, highlightthickness=0)
        self.match_scroll_y = tk.Scrollbar(body, orient="vertical", command=self.match_canvas.yview)

        self.match_inner = tk.Frame(self.match_canvas, bg=CARD, width=self.grid_total_width)
        self.match_inner.bind(
            "<Configure>",
            lambda e: self.match_canvas.configure(scrollregion=self.match_canvas.bbox("all"))
        )

        self.match_window = self.match_canvas.create_window((0, 0), window=self.match_inner, anchor="nw")
        self.match_canvas.configure(yscrollcommand=self.match_scroll_y.set)

        def on_canvas_resize(event):
            width = max(event.width, self.grid_total_width)
            self.match_canvas.itemconfigure(self.match_window, width=width)
            self.match_header.configure(width=width)

        self.match_canvas.bind("<Configure>", on_canvas_resize)

        self.match_canvas.grid(row=0, column=0, sticky="nsew")
        self.match_scroll_y.grid(row=0, column=1, sticky="ns")

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
        return ""

    def render_match_rows(self):
        self._fixed_btn_refs = {}
        self._block_btn_refs = {}
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
        box = tk.Frame(self.match_inner, bg=SECTION_BG, width=self.grid_total_width, height=32, highlightthickness=0)
        box.pack(fill="x", padx=6, pady=(8, 2))
        box.pack_propagate(False)

        left = tk.Frame(box, bg=SECTION_BG)
        left.pack(side="left", fill="both", expand=True, padx=10)

        flag = self._league_flag(rows[0])
        title = f"{flag}  {league_name}" if flag else league_name
        tk.Label(left, text=title, bg=SECTION_BG, fg=SECTION_ACCENT, font=FONT_BOLD, anchor="w").pack(side="left")
        tk.Label(left, text=f"{len(rows)} záp.", bg=SECTION_BG, fg=MUTED, font=FONT_SMALL, anchor="w").pack(side="left", padx=(8, 0))

    def render_match_row(self, row: dict, row_index: int):
        bg_row = ROW_EVEN if row_index % 2 == 0 else ROW_ODD
        wrap = tk.Frame(self.match_inner, bg=bg_row, width=self.grid_total_width, height=40, highlightthickness=0)
        wrap.pack(fill="x", padx=6, pady=1)
        wrap.pack_propagate(False)

        match_x = 0
        match_w = self.grid_columns[0][1]
        info = tk.Frame(wrap, bg=bg_row)
        info.place(x=match_x + 8, y=1, width=match_w - 16, height=38)

        teams = tk.Frame(info, bg=bg_row)
        teams.pack(anchor="w", fill="x")
        home = tk.Label(teams, text=str(row.get("home_team", "?")), bg=bg_row, fg=TEXT, font=("Segoe UI", 9, "bold"), anchor="w")
        home.pack(side="left")
        tk.Label(teams, text="  vs  ", bg=bg_row, fg=MUTED, font=("Segoe UI", 8), anchor="w").pack(side="left")
        away = tk.Label(teams, text=str(row.get("away_team", "?")), bg=bg_row, fg=TEXT, font=("Segoe UI", 9, "bold"), anchor="w")
        away.pack(side="left")

        tk.Label(
            info,
            text=self.fmt_kickoff(row.get("kickoff")),
            bg=bg_row,
            fg=DATE_SOFT,
            font=("Segoe UI", 8, "italic"),
            anchor="w",
        ).pack(anchor="w", pady=(1, 0))

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

    def make_grid_pick_button(self, parent, row: dict, bg_row: str, x: int, width: int, market_code: str, outcome_code: str, odd_value):
        key = self._fixed_key(row.get("match_id"), market_code, outcome_code)
        is_selected = key in self._selected_fixed_keys()
        btn = tk.Button(
            parent,
            text=self.fmt_odds(odd_value),
            bg=PINK if is_selected else (CARD_2 if odd_value else bg_row),
            fg=PINK_TEXT if is_selected else (TEXT if odd_value else MUTED),
            activebackground=PINK_DARK if is_selected else CARD_3,
            activeforeground=PINK_TEXT if is_selected else TEXT,
            font=FONT_SMALL,
            relief="flat",
            borderwidth=0,
            state="normal" if odd_value else "disabled",
            command=lambda: self._toggle_fixed_pick_fast(row, market_code, outcome_code, odd_value),
        )
        btn.place(x=x + 2, y=7, width=width - 4, height=24)
        self._fixed_btn_refs[key] = btn

    def make_block_button(self, parent: tk.Frame, row: dict, bg_row: str, x: int, width: int, block_index: int):
        current_block = self._selected_block_map().get(int(row.get("match_id")), 0)
        is_selected = current_block == block_index
        btn = tk.Button(
            parent,
            text=self.block_label(block_index),
            bg=PINK if is_selected else CARD_2,
            fg=PINK_TEXT if is_selected else TEXT,
            activebackground=PINK_DARK if is_selected else CARD_3,
            activeforeground=PINK_TEXT if is_selected else TEXT,
            font=FONT_SMALL,
            relief="flat",
            borderwidth=0,
            command=lambda: self._toggle_block_pick_fast(row, block_index),
        )
        btn.place(x=x + 2, y=7, width=width - 4, height=24)
        self._block_btn_refs[(int(row.get("match_id")), block_index)] = btn

    def _update_button_states(self):
        selected_fixed = self._selected_fixed_keys()
        for key, btn in list(self._fixed_btn_refs.items()):
            if not btn.winfo_exists():
                continue
            is_selected = key in selected_fixed
            btn.configure(
                bg=PINK if is_selected else CARD_2,
                fg=PINK_TEXT if is_selected else TEXT,
                activebackground=PINK_DARK if is_selected else CARD_3,
                activeforeground=PINK_TEXT if is_selected else TEXT,
            )

        selected_block_map = self._selected_block_map()
        for (match_id, block_index), btn in list(self._block_btn_refs.items()):
            if not btn.winfo_exists():
                continue
            is_selected = selected_block_map.get(match_id, 0) == block_index
            btn.configure(
                bg=PINK if is_selected else CARD_2,
                fg=PINK_TEXT if is_selected else TEXT,
                activebackground=PINK_DARK if is_selected else CARD_3,
                activeforeground=PINK_TEXT if is_selected else TEXT,
            )

    def _toggle_fixed_pick_fast(self, row: dict, market_code: str, outcome_code: str, odd_value):
        key = self._fixed_key(row.get("match_id"), market_code, outcome_code)
        before = len(self.fixed_items)
        self.fixed_items = [
            x for x in self.fixed_items
            if self._fixed_key(x.get("match_id"), x.get("market_code"), x.get("outcome_code")) != key
        ]
        if len(self.fixed_items) == before:
            item = {
                "match_id": int(row.get("match_id")),
                "league_name": str(row.get("league_name", "?")),
                "home_team": str(row.get("home_team", "?")),
                "away_team": str(row.get("away_team", "?")),
                "market_code": str(market_code).upper(),
                "outcome_code": str(outcome_code).upper(),
                "odd_value": odd_value,
            }
            self.fixed_items.append(item)
        self._update_button_states()
        self.refresh_selection_panel()
        self.refresh_summary()
        self.refresh_combos_panel()

    def _toggle_block_pick_fast(self, row: dict, block_index: int):
        match_id = int(row.get("match_id"))
        # remove same match from all blocks first
        for bi in (1, 2, 3):
            self.block_items[bi] = [x for x in self.block_items[bi] if int(x.get("match_id")) != match_id]

        current = self._selected_block_map().get(match_id, 0)
        if current != block_index:
            self.block_items[block_index].append({
                "match_id": match_id,
                "league_name": str(row.get("league_name", "?")),
                "home_team": str(row.get("home_team", "?")),
                "away_team": str(row.get("away_team", "?")),
                "block_index": block_index,
            })

        self._update_button_states()
        self.refresh_selection_panel()
        self.refresh_summary()
        self.refresh_combos_panel()

    def _render_pick_card(self, parent, item: dict, meta: str, remove_cmd, accent=ACCENT):
        card = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        card.pack(fill="x", pady=(0, 6))

        top = tk.Frame(card, bg=BET_PANEL_2)
        top.pack(fill="x", padx=8, pady=(7, 2))

        left = tk.Frame(top, bg=BET_PANEL_2)
        left.pack(side="left", fill="both", expand=True)
        right = tk.Frame(top, bg=BET_PANEL_2)
        right.pack(side="right", anchor="ne")

        tk.Label(left, text=f"{item['home_team']} vs {item['away_team']}", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD, anchor="w").pack(anchor="w")
        tk.Label(left, text=item.get("league_name", "?"), bg=BET_PANEL_2, fg=MUTED, font=("Segoe UI", 8, "italic"), anchor="w").pack(anchor="w", pady=(1, 0))

        display_meta = meta.replace("kurz ", "").replace(" • ", "   ")
        tk.Label(right, text=display_meta, bg=BET_PANEL_2, fg=PINK if accent == ACCENT else YELLOW, font=FONT_SMALL, anchor="e", justify="right").pack(anchor="e")

        tk.Button(card, text="ODEBRAT", bg=RED, fg=BG, font=FONT_SMALL, relief="flat", command=lambda: (remove_cmd(), self._update_button_states())).pack(side="right", padx=8, pady=(0, 8))

    def remove_fixed_item(self, index: int):
        super().remove_fixed_item(index)
        self._update_button_states()

    def remove_block_item(self, block_index: int, index: int):
        super().remove_block_item(block_index, index)
        self._update_button_states()


if __name__ == "__main__":
    root = tk.Tk()
    app = TicketStudioV2105(root)
    root.mainloop()
