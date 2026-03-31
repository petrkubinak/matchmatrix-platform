from __future__ import annotations

import itertools
import os
import tkinter as tk
from tkinter import ttk
from decimal import Decimal

from matchmatrix_ticket_studio_V2_7 import *

BET_GREEN = "#39A800"
BET_GREEN_DARK = "#2F8A00"
BET_PANEL = "#161125"
BET_PANEL_2 = "#1E1733"
BET_PANEL_3 = "#241C3D"
BET_INPUT = "#10101A"
BET_INPUT_BORDER = "#4D456A"
BET_SOFT = "#B9AEE0"
BET_LINE = "#342A52"


class TicketStudioV29(TicketStudioV27):
    def __init__(self, root: tk.Tk):
        self.stake_var = tk.StringVar(value="100")
        self.combos_visible = tk.BooleanVar(value=False)
        self._combo_rows_cache: list[dict] = []
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.9 BETSLIP")
        self.refresh_all_panels()
        self._bind_mousewheel_support()

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=(10, 8))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.9 BETSLIP",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="desktop full-screen • stabilní rychlá verze • nový ticket slip vpravo • připraveno na Pred / Forma / Tab / H2H",
            bg=BG,
            fg=MUTED,
            font=FONT,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="desktop | stable grid | betslip")
        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=YELLOW,
            font=FONT_SMALL,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

        self.root.bind("<Map>", self._update_viewport, add="+")
        self.root.bind("<Configure>", self._on_root_configure_v29, add="+")

    def _update_viewport(self, _event=None):
        self.viewport_var.set(f"desktop | stable grid | betslip | {self.root.winfo_width()}x{self.root.winfo_height()}")

    def _on_root_configure_v29(self, event):
        if event.widget is self.root:
            self._update_viewport()

    def build_right_panel(self, parent):
        parent.grid_rowconfigure(2, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_template_panel_v29(parent)
        self.build_betslip_summary_panel(parent)
        self.build_selection_panel_v29(parent)
        self.build_combos_panel_v29(parent)

    def build_template_panel_v29(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        frame.grid(row=0, column=0, sticky="ew", pady=(0, 8))

        tk.Label(frame, text="Template", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 4))

        row1 = tk.Frame(frame, bg=CARD)
        row1.pack(fill="x", padx=10, pady=(0, 8))

        tk.Label(row1, text="Template ID", bg=CARD, fg=TEXT, font=FONT_SMALL).pack(side="left")
        self.template_id_var = tk.StringVar(value="1")
        tk.Entry(
            row1,
            textvariable=self.template_id_var,
            width=7,
            bg=CARD_2,
            fg=TEXT,
            insertbackground=TEXT,
            relief="flat"
        ).pack(side="left", padx=(8, 8))

        tk.Button(row1, text="NAČÍST", bg=BLUE, fg=BG, font=FONT_BOLD, relief="flat", command=self.load_template_from_db).pack(side="left", padx=(0, 6))
        tk.Button(row1, text="VYMAZAT LOKÁLNÍ", bg=CARD_2, fg=TEXT, font=FONT_SMALL, relief="flat", command=self.clear_local_state).pack(side="left")

        row2 = tk.Frame(frame, bg=CARD)
        row2.pack(fill="x", padx=10, pady=(0, 10))
        tk.Button(row2, text="ULOŽIT DO DB", bg=ACCENT, fg=BG, font=FONT_BOLD, relief="flat", command=self.save_template_to_db).pack(side="left", padx=(0, 8))
        tk.Button(row2, text="SMAZAT V DB", bg=RED, fg=BG, font=FONT_BOLD, relief="flat", command=self.delete_template_from_db).pack(side="left")

    def build_betslip_summary_panel(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=1, column=0, sticky="ew", pady=(0, 8))
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

        self.stake_entry = tk.Entry(
            stake_wrap,
            textvariable=self.stake_var,
            bg=BET_INPUT,
            fg=TEXT,
            insertbackground=TEXT,
            relief="flat",
            font=FONT_BOLD,
            justify="right"
        )
        self.stake_entry.pack(side="left", fill="x", expand=True, ipady=7)
        self.stake_entry.bind("<KeyRelease>", lambda _e: self.refresh_summary())

        tk.Label(stake_wrap, text="Kč", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD, padx=12, pady=8).pack(side="left", padx=(8, 0))

        quick = tk.Frame(frame, bg=BET_PANEL)
        quick.pack(fill="x", padx=12, pady=(0, 10))
        for amount in (10, 50, 100, 200):
            tk.Button(
                quick,
                text=f"{amount}",
                bg=BET_PANEL_3,
                fg=TEXT,
                relief="flat",
                font=FONT_SMALL,
                command=lambda a=amount: self._set_stake(a),
            ).pack(side="left", padx=(0, 6))

        self.combo_toggle_btn = tk.Button(
            frame,
            text="ZOBRAZIT VŠECHNY KOMBINACE",
            bg=BET_PANEL_3,
            fg=TEXT,
            relief="flat",
            font=FONT_BOLD,
            command=self.toggle_combos_panel,
        )
        self.combo_toggle_btn.pack(fill="x", padx=12, pady=(0, 10), ipady=6)

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

    def _metric_box(self, parent, row, column, label_text):
        box = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        box.grid(row=row, column=column, sticky="ew", padx=(0 if column == 0 else 6, 0 if column == 1 else 6), pady=(0, 6))
        tk.Label(box, text=label_text, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w", padx=8, pady=(7, 2))
        value = tk.Label(box, text="-", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD)
        value.pack(anchor="w", padx=8, pady=(0, 7))
        return value

    def build_selection_panel_v29(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        frame.grid(row=2, column=0, sticky="nsew", pady=(0, 8))
        frame.grid_rowconfigure(1, weight=1)
        frame.grid_columnconfigure(0, weight=1)

        head = tk.Frame(frame, bg=CARD)
        head.pack(fill="x", padx=10, pady=(10, 6))
        tk.Label(head, text="Vybrané zápasy", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(side="left")
        self.selected_count_var = tk.StringVar(value="0")
        tk.Label(head, textvariable=self.selected_count_var, bg=CARD_2, fg=YELLOW, font=FONT_SMALL, padx=8, pady=3).pack(side="right")

        self.selection_outer, self.selection_canvas, self.selection_inner = self.create_scrollable_vertical(frame, CARD)
        self.selection_outer.pack(fill="both", expand=True, padx=10, pady=(0, 10))

    def build_combos_panel_v29(self, parent):
        self.combos_frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=PANEL_LINE_SOFT)
        self.combos_frame.grid(row=3, column=0, sticky="nsew")
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

    def _bind_mousewheel_support(self):
        targets = []
        for name in ("match_canvas", "selection_canvas", "combos_canvas"):
            widget = getattr(self, name, None)
            if widget is not None:
                targets.append(widget)

        for widget in targets:
            widget.bind("<MouseWheel>", self._on_mousewheel_vertical, add="+")
            widget.bind("<Shift-MouseWheel>", self._on_mousewheel_horizontal, add="+")
            widget.bind("<Button-4>", lambda e, w=widget: self._linux_scroll(w, -1), add="+")
            widget.bind("<Button-5>", lambda e, w=widget: self._linux_scroll(w, 1), add="+")

    def _linux_scroll(self, widget, step):
        try:
            widget.yview_scroll(step, "units")
        except Exception:
            pass

    def _on_mousewheel_vertical(self, event):
        widget = event.widget
        canvas = self._resolve_canvas(widget)
        if canvas is not None:
            canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
        return "break"

    def _on_mousewheel_horizontal(self, event):
        widget = event.widget
        canvas = self._resolve_canvas(widget)
        if canvas is not None:
            canvas.xview_scroll(int(-1 * (event.delta / 120)), "units")
            if canvas is self.match_canvas:
                try:
                    first, _last = self.match_canvas.xview()
                    self.header_canvas.xview_moveto(first)
                except Exception:
                    pass
        return "break"

    def _resolve_canvas(self, widget):
        while widget is not None:
            if isinstance(widget, tk.Canvas):
                return widget
            widget = getattr(widget, "master", None)
        return None

    def _set_stake(self, amount: int):
        self.stake_var.set(str(amount))
        self.refresh_summary()

    def parse_stake(self) -> Decimal:
        raw = str(self.stake_var.get()).replace(" ", "").replace(",", ".").strip()
        if not raw:
            return Decimal("0")
        try:
            value = Decimal(raw)
            return value if value >= 0 else Decimal("0")
        except Exception:
            return Decimal("0")

    def get_match_lookup(self) -> dict[int, dict]:
        return {int(r["match_id"]): r for r in self.all_matches if r.get("match_id") is not None}

    def get_h2h_odd(self, match_row: dict | None, outcome_code: str) -> Decimal | None:
        if not match_row:
            return None
        mapping = {
            "1": match_row.get("odd_1"),
            "X": match_row.get("odd_x"),
            "2": match_row.get("odd_2"),
        }
        return self.safe_decimal(mapping.get(outcome_code))

    def build_combinations(self) -> list[dict]:
        active_blocks = [bi for bi in (1, 2, 3) if self.block_items[bi]]
        match_lookup = self.get_match_lookup()
        fixed_total = Decimal("1")
        fixed_ok = True

        fixed_details = []
        for item in self.fixed_items:
            odd = self.safe_decimal(item.get("odd_value"))
            if not odd or odd <= 0:
                fixed_ok = False
                odd = None
            else:
                fixed_total *= odd
            fixed_details.append(f"{item['home_team']} {item['outcome_code']}")

        assignments = list(itertools.product(("1", "X", "2"), repeat=len(active_blocks))) if active_blocks else [tuple()]
        combos = []

        for combo_idx, assignment in enumerate(assignments, start=1):
            total_odds = fixed_total
            is_valid = fixed_ok
            parts = list(fixed_details)
            block_summary = []

            for block_pos, block_index in enumerate(active_blocks):
                choice = assignment[block_pos]
                block_summary.append(f"{self.block_label(block_index)}={choice}")
                for item in self.block_items[block_index]:
                    match_row = match_lookup.get(int(item["match_id"]))
                    odd = self.get_h2h_odd(match_row, choice)
                    if not odd or odd <= 0:
                        is_valid = False
                    else:
                        total_odds *= odd
                    parts.append(f"{item['home_team']} {choice}")

            combos.append({
                "index": combo_idx,
                "choices": block_summary,
                "parts": parts,
                "valid": is_valid,
                "total_odds": total_odds if is_valid else None,
                "pred": "—",
                "combo_pred": "—",
            })

        return combos

    def toggle_combos_panel(self):
        self.combos_visible.set(not self.combos_visible.get())
        if self.combos_visible.get():
            self.combos_outer.grid()
        else:
            self.combos_outer.grid_remove()
        self.refresh_summary()
        self.refresh_combos_panel()

    def refresh_all_panels(self):
        self.refresh_selection_panel()
        self.refresh_summary()
        self.refresh_combos_panel()

    def refresh_selection_panel(self):
        for widget in self.selection_inner.winfo_children():
            widget.destroy()

        total_entries = len(self.fixed_items) + sum(len(v) for v in self.block_items.values())
        self.selected_count_var.set(f"{total_entries} výběrů")

        if not total_entries:
            tk.Label(
                self.selection_inner,
                text="Zatím žádné vybrané zápasy.",
                bg=CARD,
                fg=MUTED,
                font=FONT,
            ).pack(anchor="w", pady=6)
            return

        if self.fixed_items:
            self._section_title(self.selection_inner, "FIXED picky")
            for idx, item in enumerate(self.fixed_items):
                self._render_pick_card(self.selection_inner, item, f"{item['market_code']} • {item['outcome_code']} • kurz {self.fmt_odds(item['odd_value'])}", lambda i=idx: self.remove_fixed_item(i), accent=ACCENT)

        for block_index in (1, 2, 3):
            items = self.block_items[block_index]
            if not items:
                continue
            self._section_title(self.selection_inner, f"Blok {self.block_label(block_index)}")
            for idx, item in enumerate(items):
                self._render_pick_card(self.selection_inner, item, f"blok {self.block_label(block_index)} • outcome dle kombinace", lambda bi=block_index, i=idx: self.remove_block_item(bi, i), accent=YELLOW)

    def _section_title(self, parent, text: str):
        tk.Label(parent, text=text, bg=CARD, fg=BET_SOFT, font=FONT_BOLD).pack(anchor="w", pady=(2, 6))

    def _render_pick_card(self, parent, item: dict, meta: str, remove_cmd, accent=ACCENT):
        card = tk.Frame(parent, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
        card.pack(fill="x", pady=(0, 6))

        left = tk.Frame(card, bg=BET_PANEL_2)
        left.pack(side="left", fill="both", expand=True, padx=8, pady=8)

        tk.Label(left, text=f"{item['home_team']} vs {item['away_team']}", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD, anchor="w").pack(anchor="w")
        tk.Label(left, text=item.get("league_name", "?"), bg=BET_PANEL_2, fg=MUTED, font=FONT_SMALL, anchor="w").pack(anchor="w", pady=(1, 0))
        tk.Label(left, text=meta, bg=BET_PANEL_2, fg=accent, font=FONT_SMALL, anchor="w").pack(anchor="w", pady=(2, 0))

        tk.Button(card, text="ODEBRAT", bg=RED, fg=BG, font=FONT_SMALL, relief="flat", command=remove_cmd).pack(side="right", padx=8, pady=10)

    def refresh_summary(self):
        combos = self.build_combinations()
        self._combo_rows_cache = combos

        fixed_count = len(self.fixed_items)
        block_match_count = sum(len(v) for v in self.block_items.values())
        total_entries = fixed_count + block_match_count
        combo_count = len(combos)
        stake = self.parse_stake()

        valid_odds = [c["total_odds"] for c in combos if c.get("total_odds")]
        if len(valid_odds) == 1:
            odds_text = f"{valid_odds[0]:.2f}"
        elif len(valid_odds) > 1:
            odds_text = f"{min(valid_odds):.2f} až {max(valid_odds):.2f}"
        else:
            odds_text = "-"

        total_stake = stake * Decimal(combo_count)
        max_return = max((odd * stake for odd in valid_odds), default=Decimal("0"))

        self.metric_total_odds.config(text=odds_text)
        self.metric_combo_count.config(text=str(combo_count))
        self.metric_total_stake.config(text=f"{total_stake:.2f} Kč")
        self.metric_total_return.config(text=f"{max_return:.2f} Kč")
        self.summary_badge_var.set(f"{total_entries} výběrů")
        self.combo_toggle_btn.config(text=f"{'SKRÝT' if self.combos_visible.get() else 'ZOBRAZIT'} VŠECHNY KOMBINACE ({combo_count})")
        self.combos_caption_var.set(f"{combo_count} řádků" if self.combos_visible.get() else "skryto")

    def refresh_combos_panel(self):
        for widget in self.combos_inner.winfo_children():
            widget.destroy()

        combos = self._combo_rows_cache if self._combo_rows_cache else self.build_combinations()
        stake = self.parse_stake()

        if not self.combos_visible.get():
            return

        if not combos:
            tk.Label(self.combos_inner, text="Žádné kombinace.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", pady=6)
            return

        for combo in combos:
            card = tk.Frame(self.combos_inner, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
            card.pack(fill="x", pady=(0, 6))

            header = tk.Frame(card, bg=BET_PANEL_2)
            header.pack(fill="x", padx=8, pady=(8, 4))
            tk.Label(header, text=f"Kombinace #{combo['index']}", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD).pack(side="left")
            tk.Label(header, text=" | ".join(combo["choices"]) if combo["choices"] else "FIXED only", bg=BET_PANEL_3, fg=YELLOW, font=FONT_SMALL, padx=8, pady=3).pack(side="right")

            picks_text = " • ".join(combo["parts"][:6])
            if len(combo["parts"]) > 6:
                picks_text += f" • +{len(combo['parts']) - 6} další"
            tk.Label(card, text=picks_text, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_SMALL, anchor="w", justify="left", wraplength=520).pack(fill="x", padx=8)

            metrics = tk.Frame(card, bg=BET_PANEL_2)
            metrics.pack(fill="x", padx=8, pady=(6, 8))
            odds_text = f"{combo['total_odds']:.2f}" if combo.get("total_odds") else "-"
            payout = (combo["total_odds"] * stake) if combo.get("total_odds") else None
            payout_text = f"{payout:.2f} Kč" if payout is not None else "-"

            for text in (
                f"Kurz: {odds_text}",
                f"Výhra: {payout_text}",
                f"Predikce tiket: {combo['pred']}",
                f"Predikce kombinace: {combo['combo_pred']}",
            ):
                tk.Label(metrics, text=text, bg=BET_PANEL_3, fg=TEXT, font=FONT_SMALL, padx=8, pady=4).pack(side="left", padx=(0, 6))


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV29(root)
    root.mainloop()


if __name__ == "__main__":
    main()
