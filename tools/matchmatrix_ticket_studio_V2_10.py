from __future__ import annotations

import tkinter as tk
from tkinter import ttk
from collections import defaultdict

from matchmatrix_ticket_studio_V2_9 import TicketStudioV29
from matchmatrix_ticket_studio_V2_7 import *


SECTION_BG = "#171326"
SECTION_ACCENT = "#F1C453"
ROW_EVEN = "#151122"
ROW_ODD = "#1A152B"


class TicketStudioV210(TicketStudioV29):
    def __init__(self, root: tk.Tk):
        self._mw_targets = []
        self._active_scroll_canvas = None
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.10")

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=(10, 8))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.10",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="stabilní desktop fullscreen • scroll kolečkem podle kurzoru/kliknutí • zápasy seskupené podle soutěží",
            bg=BG,
            fg=MUTED,
            font=FONT,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="desktop | grouped leagues")
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
            text="zápasy seskupené podle soutěží • kratší řádky • připraveno na Pred / Forma / Tab / H2H",
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL,
        ).pack(anchor="w", padx=10, pady=(0, 10))

        grid_box = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        grid_box.grid(row=1, column=0, sticky="nsew")
        grid_box.grid_rowconfigure(1, weight=1)
        grid_box.grid_columnconfigure(0, weight=1)

        self.grid_columns = [
            ("DATUM", 96, "w"),
            ("DOMÁCÍ", 190, "w"),
            ("HOSTÉ", 190, "w"),
            ("1", 54, "center"),
            ("X", 54, "center"),
            ("2", 54, "center"),
            ("1X", 58, "center"),
            ("12", 58, "center"),
            ("X2", 58, "center"),
            ("PRED", 70, "center"),
            ("FORMA", 70, "center"),
            ("TAB", 70, "center"),
            ("H2H", 70, "center"),
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
        self.match_scroll_x = tk.Scrollbar(grid_box, orient="horizontal", command=self.sync_x_scroll)

        self.match_inner = tk.Frame(self.match_canvas, bg=CARD, width=self.grid_total_width)
        self.match_inner.bind(
            "<Configure>",
            lambda e: self.match_canvas.configure(scrollregion=self.match_canvas.bbox("all"))
        )

        self.match_window = self.match_canvas.create_window((0, 0), window=self.match_inner, anchor="nw")
        self.match_canvas.configure(yscrollcommand=self.match_scroll_y.set, xscrollcommand=self.match_scroll_x.set)

        def on_canvas_resize(event):
            width = max(event.width, self.grid_total_width)
            self.match_canvas.itemconfigure(self.match_window, width=width)
            self.match_header.configure(width=width)

        self.match_canvas.bind("<Configure>", on_canvas_resize)

        self.match_canvas.grid(row=0, column=0, sticky="nsew")
        self.match_scroll_y.grid(row=0, column=1, sticky="ns")
        self.match_scroll_x.grid(row=2, column=0, sticky="ew")

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
            self._render_league_section(league_name, len(rows))
            for row in rows:
                self.render_match_row(row, row_index)
                row_index += 1

    def _render_league_section(self, league_name: str, count: int):
        box = tk.Frame(self.match_inner, bg=SECTION_BG, width=self.grid_total_width, height=34, highlightthickness=0)
        box.pack(fill="x", padx=6, pady=(8, 3))
        box.pack_propagate(False)

        left = tk.Frame(box, bg=SECTION_BG)
        left.pack(side="left", fill="both", expand=True, padx=10)

        tk.Label(left, text=league_name, bg=SECTION_BG, fg=SECTION_ACCENT, font=FONT_BOLD, anchor="w").pack(side="left")
        tk.Label(left, text=f"{count} záp.", bg=SECTION_BG, fg=MUTED, font=FONT_SMALL, anchor="w").pack(side="left", padx=(8, 0))

    def render_match_row(self, row: dict, row_index: int):
        bg_row = ROW_EVEN if row_index % 2 == 0 else ROW_ODD
        wrap = tk.Frame(self.match_inner, bg=bg_row, width=self.grid_total_width, height=30, highlightthickness=0)
        wrap.pack(fill="x", padx=6, pady=1)
        wrap.pack_propagate(False)

        dc_odds = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))

        values = [
            self.fmt_kickoff(row.get("kickoff")),
            str(row.get("home_team", "?")),
            str(row.get("away_team", "?")),
        ]

        x = 0
        for idx, (_, width, anchor) in enumerate(self.grid_columns[:3]):
            txt = values[idx]
            lbl = tk.Label(wrap, text=txt, bg=bg_row, fg=TEXT, font=FONT_GRID, anchor=anchor)
            lbl.place(x=x, y=0, width=width, height=30)
            x += width

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
            lbl.place(x=x, y=0, width=width, height=30)
            x += width

        self.make_block_button(wrap, row, bg_row, x, 42, 1)
        x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 2)
        x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 3)

    def _bind_mousewheel_support(self):
        self._mw_targets = []
        for name in ("match_canvas", "selection_canvas", "combos_canvas"):
            widget = getattr(self, name, None)
            if widget is not None:
                self._mw_targets.append(widget)
                self._bind_canvas_activation(widget)

        self.root.bind_all("<MouseWheel>", self._dispatch_mousewheel_vertical, add="+")
        self.root.bind_all("<Shift-MouseWheel>", self._dispatch_mousewheel_horizontal, add="+")
        self.root.bind_all("<Button-4>", self._dispatch_linux_up, add="+")
        self.root.bind_all("<Button-5>", self._dispatch_linux_down, add="+")

    def _bind_canvas_activation(self, canvas):
        def bind_children(widget):
            widget.bind("<Enter>", lambda e, c=canvas: self._set_active_canvas(c), add="+")
            widget.bind("<Button-1>", lambda e, c=canvas: self._set_active_canvas(c), add="+")
            for child in widget.winfo_children():
                bind_children(child)

        bind_children(canvas)
        inner_name = None
        if canvas is getattr(self, "match_canvas", None):
            inner_name = "match_inner"
        elif canvas is getattr(self, "selection_canvas", None):
            inner_name = "selection_inner"
        elif canvas is getattr(self, "combos_canvas", None):
            inner_name = "combos_inner"
        if inner_name and getattr(self, inner_name, None) is not None:
            bind_children(getattr(self, inner_name))

    def _set_active_canvas(self, canvas):
        self._active_scroll_canvas = canvas

    def _find_canvas_under_pointer(self):
        try:
            widget = self.root.winfo_containing(self.root.winfo_pointerx(), self.root.winfo_pointery())
        except Exception:
            widget = None
        return self._resolve_canvas(widget)

    def _resolve_canvas(self, widget):
        while widget is not None:
            if widget in self._mw_targets:
                return widget
            try:
                widget = widget.master
            except Exception:
                return None
        return None

    def _scroll_target(self):
        return self._find_canvas_under_pointer() or self._active_scroll_canvas

    def _dispatch_mousewheel_vertical(self, event):
        canvas = self._scroll_target()
        if canvas is None:
            return
        delta = getattr(event, "delta", 0)
        if delta == 0:
            return "break"
        canvas.yview_scroll(int(-1 * (delta / 120)), "units")
        return "break"

    def _dispatch_mousewheel_horizontal(self, event):
        canvas = self._scroll_target()
        if canvas is None:
            return
        delta = getattr(event, "delta", 0)
        if delta == 0:
            return "break"
        canvas.xview_scroll(int(-1 * (delta / 120)), "units")
        return "break"

    def _dispatch_linux_up(self, event):
        canvas = self._scroll_target()
        if canvas is not None:
            canvas.yview_scroll(-1, "units")
            return "break"

    def _dispatch_linux_down(self, event):
        canvas = self._scroll_target()
        if canvas is not None:
            canvas.yview_scroll(1, "units")
            return "break"


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV210(root)
    root.mainloop()


if __name__ == "__main__":
    main()
