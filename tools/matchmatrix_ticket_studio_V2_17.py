# -*- coding: utf-8 -*-
from __future__ import annotations

import csv
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from decimal import Decimal

from matchmatrix_ticket_studio_V2_16 import (
    TicketStudioV216,
    SPORT_ICONS,
    FONT_XS,
    FONT_SM,
    FONT_SM_BOLD,
    FONT_TITLE,
)
from matchmatrix_ticket_studio_V2_9 import BET_GREEN, BET_GREEN_DARK, BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_SOFT, BET_LINE
from matchmatrix_ticket_studio_V2_12 import BLUE, CARD, CARD_2, PANEL_LINE_SOFT, RED, YELLOW
from matchmatrix_ticket_studio_V2_7 import BG, TEXT, MUTED, ACCENT, FONT_BOLD, FONT_SMALL, FONT_SECTION


TIME_PRESETS_V217 = [
    ("3 hod.", "3 hours"),
    ("6 hod.", "6 hours"),
    ("24 hod.", "24 hours"),
    ("2 dny", "2 days"),
    ("Týden", "7 days"),
    ("14 dnů", "14 days"),
]


class TicketStudioV217(TicketStudioV216):
    def __init__(self, root: tk.Tk):
        self.ticket_list_inner = None
        self.ticket_count_var = tk.StringVar(value="0 výběrů")
        self.total_odds_var = tk.StringVar(value="1.00")
        self.combo_count_var = tk.StringVar(value="1")
        self.total_stake_var = tk.StringVar(value="100.00 Kč")
        self.total_return_var = tk.StringVar(value="100.00 Kč")
        self.range_return_var = tk.StringVar(value="100.00 Kč")
        self.bookmaker_caption_var = tk.StringVar(value="Bez bookmakera")
        self.ticket_status_var = tk.StringVar(value="Tiket je prázdný")
        self.ticket_hint_var = tk.StringVar(value="Klikni na kurz u zápasu a položka se hned propíše do tiketu.")
        self.overview_btn = None
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.17")
        self.viewport_var.set("desktop | v2.17 | zjednodušený tiket")
        self.refresh_all_panels()

    # -----------------------------------------------------
    # Layout
    # -----------------------------------------------------
    def init_pane_sizes(self):
        try:
            total = self.main_paned.winfo_width()
            if total <= 1:
                return
            left_w = max(205, int(total * 0.14))
            center_w = max(790, int(total * 0.61))
            self.main_paned.sashpos(0, left_w)
            self.main_paned.sashpos(1, left_w + center_w)
        except Exception:
            pass

    def build_header(self):
        if not hasattr(self, "viewport_var"):
            self.viewport_var = tk.StringVar(value="desktop | v2.17 | zjednodušený tiket")

        header = tk.Frame(self.root, bg=BG)
        header.pack(fill="x", padx=10, pady=(8, 6))
        header.grid_columnconfigure(0, weight=1)

        tk.Label(
            header,
            text="MatchMatrix Ticket Studio V2.17",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            header,
            text="užší levý filtr • 14 dnů • jeden přehledný tiket vpravo • přehled tiketů v samostatném okně",
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
        for idx, (label, interval_txt) in enumerate(TIME_PRESETS_V217):
            btn = tk.Button(
                chips,
                text=label,
                bg=CARD_2,
                fg=TEXT,
                relief="flat",
                font=FONT_XS,
                command=lambda v=interval_txt: self.set_time_filter(v),
            )
            btn.grid(row=idx // 2, column=idx % 2, sticky="ew", padx=(0, 4), pady=(0, 4), ipadx=2, ipady=2)
            self.time_buttons[interval_txt] = btn
        for c in range(2):
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

    def build_right_panel(self, parent):
        parent.grid_rowconfigure(0, weight=1)
        parent.grid_columnconfigure(0, weight=1)
        self.build_ticket_panel_v217(parent)

    def build_ticket_panel_v217(self, parent):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        frame.grid(row=0, column=0, sticky="nsew")
        frame.grid_rowconfigure(1, weight=1)
        frame.grid_columnconfigure(0, weight=1)
        self.ticket_frame = frame

        head = tk.Frame(frame, bg=BET_PANEL)
        head.grid(row=0, column=0, sticky="ew", padx=10, pady=(10, 8))
        tk.Label(head, text="Tiket", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(side="left")
        tk.Label(head, textvariable=self.ticket_count_var, bg=BET_PANEL_2, fg=YELLOW, font=FONT_XS, padx=6, pady=2).pack(side="right")

        body = tk.Frame(frame, bg=BET_PANEL)
        body.grid(row=1, column=0, sticky="nsew", padx=10, pady=(0, 8))
        body.grid_rowconfigure(0, weight=1)
        body.grid_columnconfigure(0, weight=1)

        outer, _canvas, self.ticket_list_inner = self.create_scrollable_vertical(body, BET_PANEL)
        outer.grid(row=0, column=0, sticky="nsew")

        footer = tk.Frame(frame, bg=BET_PANEL, highlightthickness=1, highlightbackground=BET_LINE)
        footer.grid(row=2, column=0, sticky="ew", padx=10, pady=(0, 10))
        self.ticket_footer = footer

        self._build_ticket_footer_v217(footer)

    def _build_ticket_footer_v217(self, parent):
        info = tk.Frame(parent, bg=BET_PANEL)
        info.pack(fill="x", padx=8, pady=(8, 6))
        info.grid_columnconfigure(0, weight=1)
        info.grid_columnconfigure(1, weight=1)

        self._metric_line(info, 0, 0, "Celkový kurz", self.total_odds_var)
        self._metric_line(info, 0, 1, "Kombinací", self.combo_count_var)
        self._metric_line(info, 1, 0, "Celkem vsadíš", self.total_stake_var)
        self._metric_line(info, 1, 1, "Možná výhra", self.total_return_var)

        tk.Label(parent, text="Rozsah výher pro všechny varianty", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w", padx=8)
        tk.Label(parent, textvariable=self.range_return_var, bg=BET_PANEL_2, fg=TEXT, font=FONT_SM_BOLD, padx=8, pady=6).pack(fill="x", padx=8, pady=(3, 8))

        util = tk.Frame(parent, bg=BET_PANEL)
        util.pack(fill="x", padx=8, pady=(0, 6))
        util.grid_columnconfigure(0, weight=1)
        util.grid_columnconfigure(1, weight=1)

        tcol = tk.Frame(util, bg=BET_PANEL)
        tcol.grid(row=0, column=0, sticky="ew", padx=(0, 4))
        tk.Label(tcol, text="Template ID", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        self.template_id_var = tk.StringVar(value="1")
        tk.Entry(tcol, textvariable=self.template_id_var, bg=BET_PANEL_3, fg=TEXT, insertbackground=TEXT, relief="flat", font=FONT_XS).pack(fill="x", pady=(3, 0), ipady=4)

        bcol = tk.Frame(util, bg=BET_PANEL)
        bcol.grid(row=0, column=1, sticky="ew", padx=(4, 0))
        tk.Label(bcol, text="Bookmaker", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        self.bookmaker_combo = ttk.Combobox(bcol, textvariable=self.bookmaker_var, state="readonly", height=12)
        self.bookmaker_combo.pack(fill="x", pady=(3, 0))

        params = tk.Frame(parent, bg=BET_PANEL)
        params.pack(fill="x", padx=8, pady=(0, 6))
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

        stake = tk.Frame(parent, bg=BET_PANEL)
        stake.pack(fill="x", padx=8, pady=(0, 6))
        tk.Label(stake, text="Vklad na 1 kombinaci", bg=BET_PANEL, fg=BET_SOFT, font=FONT_XS).pack(anchor="w")
        srow = tk.Frame(stake, bg=BET_PANEL)
        srow.pack(fill="x", pady=(3, 0))
        tk.Label(srow, text="Kč", bg=BET_PANEL_3, fg=TEXT, font=FONT_SM_BOLD, padx=10, pady=7).pack(side="left")
        entry = tk.Entry(srow, textvariable=self.stake_var, bg="#10101A", fg=TEXT, insertbackground=TEXT, relief="flat", justify="right", font=FONT_SM_BOLD)
        entry.pack(side="left", fill="x", expand=True, ipady=6)
        entry.bind("<KeyRelease>", lambda _e: self.refresh_all_panels())

        quick = tk.Frame(parent, bg=BET_PANEL)
        quick.pack(fill="x", padx=8, pady=(6, 6))
        for amount in (10, 50, 100, 200):
            tk.Button(quick, text=str(amount), bg=BET_PANEL_2, fg=TEXT, font=FONT_XS, relief="flat", command=lambda a=amount: self._set_stake_and_refresh(a)).pack(side="left", padx=(0, 4), ipady=3)

        actions = tk.Frame(parent, bg=BET_PANEL)
        actions.pack(fill="x", padx=8, pady=(0, 8))
        actions.grid_columnconfigure(0, weight=1)
        actions.grid_columnconfigure(1, weight=1)

        tk.Button(actions, text="ULOŽIT TIKET", bg=BLUE, fg=BG, font=FONT_SM_BOLD, relief="flat", command=self.save_ticket_action).grid(row=0, column=0, sticky="ew", padx=(0, 4), ipady=6)
        tk.Button(actions, text="VYTVOŘIT TIKETY", bg=BET_GREEN, activebackground=BET_GREEN_DARK, activeforeground=TEXT, fg=TEXT, font=FONT_SM_BOLD, relief="flat", command=self.create_ticket_action).grid(row=0, column=1, sticky="ew", padx=(4, 0), ipady=6)

        self.overview_btn = tk.Button(
            parent,
            text="ZOBRAZIT PŘEHLED TIKETŮ",
            bg=BET_PANEL_2,
            fg=TEXT,
            font=FONT_SM_BOLD,
            relief="flat",
            command=self.open_ticket_overview_window,
            state="disabled",
        )
        self.overview_btn.pack(fill="x", padx=8, pady=(0, 4), ipady=6)

        meta = tk.Frame(parent, bg=BET_PANEL)
        meta.pack(fill="x", padx=8, pady=(0, 8))
        tk.Label(meta, textvariable=self.bookmaker_caption_var, bg=BET_PANEL, fg=MUTED, font=FONT_XS, anchor="w", justify="left").pack(anchor="w")
        tk.Label(meta, textvariable=self.ticket_status_var, bg=BET_PANEL, fg=TEXT, font=FONT_XS, anchor="w", justify="left").pack(anchor="w", pady=(2, 0))

    def _set_stake_and_refresh(self, amount: int):
        self._set_stake(amount)
        self.refresh_all_panels()

    # -----------------------------------------------------
    # Ticket state refresh
    # -----------------------------------------------------
    def refresh_all_panels(self):
        self.refresh_ticket_panel_v217()
        self.refresh_summary_v217()

    def refresh_ticket_panel_v217(self):
        if self.ticket_list_inner is None:
            return
        for widget in self.ticket_list_inner.winfo_children():
            widget.destroy()

        entries = []
        for idx, item in enumerate(self.fixed_items):
            entries.append({
                "kind": "FIXED",
                "index": idx,
                "item": item,
                "label": f"{item.get('market_code', '')} {item.get('outcome_code', '')}".strip(),
                "odd": self.fmt_odds(item.get("odd_value")),
                "remove": lambda i=idx: self.remove_fixed_item(i),
            })
        for block_index in (1, 2, 3):
            for idx, item in enumerate(self.block_items[block_index]):
                entries.append({
                    "kind": self.block_label(block_index),
                    "index": idx,
                    "item": item,
                    "label": f"Blok {self.block_label(block_index)}",
                    "odd": "varianta",
                    "remove": lambda bi=block_index, i=idx: self.remove_block_item(bi, i),
                })

        self.ticket_count_var.set(f"{len(entries)} výběrů")

        if not entries:
            empty = tk.Frame(self.ticket_list_inner, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
            empty.pack(fill="x", pady=(0, 6))
            tk.Label(empty, text="Tiket je prázdný", bg=BET_PANEL_2, fg=TEXT, font=("Segoe UI", 15, "bold")).pack(pady=(16, 4))
            tk.Label(empty, text="Klikni na kurz u zápasu a položka se hned propíše do tiketu.", bg=BET_PANEL_2, fg=MUTED, font=FONT_SMALL, wraplength=300, justify="center").pack(padx=12, pady=(0, 14))
            return

        for entry in entries:
            item = entry["item"]
            card = tk.Frame(self.ticket_list_inner, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
            card.pack(fill="x", pady=(0, 6))

            top = tk.Frame(card, bg=BET_PANEL_2)
            top.pack(fill="x", padx=8, pady=(8, 2))
            icon = SPORT_ICONS.get(str(item.get("sport_code") or "FB").upper(), "⚽")
            tk.Label(top, text=f"{icon}  {self.fmt_kickoff(item.get('kickoff'))}", bg=BET_PANEL_2, fg=MUTED, font=FONT_XS).pack(side="left")
            tk.Button(top, text="✕", bg=BET_PANEL_2, fg=TEXT, relief="flat", font=FONT_XS, command=entry["remove"]).pack(side="right")

            tk.Label(card, text=f"{item.get('home_team', '?')} - {item.get('away_team', '?')}", bg=BET_PANEL_2, fg=TEXT, font=FONT_SM_BOLD, anchor="w", wraplength=320, justify="left").pack(anchor="w", padx=8)
            tk.Label(card, text=item.get("league_name", "?"), bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_XS, anchor="w", wraplength=320, justify="left").pack(anchor="w", padx=8, pady=(1, 4))

            bottom = tk.Frame(card, bg=BET_PANEL_2)
            bottom.pack(fill="x", padx=8, pady=(0, 8))
            tk.Label(
                bottom,
                text=entry["label"],
                bg=BET_PANEL_3,
                fg=ACCENT if entry["kind"] == "FIXED" else YELLOW,
                font=FONT_XS,
                padx=6,
                pady=3,
            ).pack(side="left")
            tk.Label(bottom, text=entry["odd"], bg=BET_PANEL_2, fg=TEXT, font=("Segoe UI", 11, "bold")).pack(side="right")

    def refresh_summary_v217(self):
        combos = self.build_combinations()
        self._combo_rows_cache = combos
        stake = self.parse_stake()

        valid_odds = [c["total_odds"] for c in combos if c.get("total_odds")]
        combo_count = len(combos)
        total_stake = stake * Decimal(combo_count)
        max_return = max((odd * stake for odd in valid_odds), default=Decimal("0"))
        min_return = min((odd * stake for odd in valid_odds), default=Decimal("0")) if valid_odds else Decimal("0")

        if len(valid_odds) == 1:
            odds_text = f"{valid_odds[0]:.2f}"
        elif len(valid_odds) > 1:
            odds_text = f"{min(valid_odds):.2f} až {max(valid_odds):.2f}"
        else:
            odds_text = "-"

        self.total_odds_var.set(odds_text)
        self.combo_count_var.set(str(combo_count))
        self.total_stake_var.set(f"{total_stake:.2f} Kč")
        self.total_return_var.set(f"{max_return:.2f} Kč")
        self.range_return_var.set(f"{min_return:.2f} Kč až {max_return:.2f} Kč" if combo_count > 1 and valid_odds else f"{max_return:.2f} Kč")

        block_count = sum(len(v) for v in self.block_items.values())
        has_blocks = block_count > 0
        if self.overview_btn is not None:
            self.overview_btn.configure(state="normal" if has_blocks else "disabled")

        bookmaker_id = self._selected_bookmaker_id()
        if bookmaker_id:
            self.bookmaker_caption_var.set(f"Bookmaker: {self.bookmaker_var.get()}")
        else:
            self.bookmaker_caption_var.set("Bookmaker zatím není vybraný.")

        fixed_count = len(self.fixed_items)
        self.ticket_status_var.set(f"FIXED: {fixed_count} | blokové položky: {block_count} | kombinací: {combo_count}")

    # -----------------------------------------------------
    # Actions
    # -----------------------------------------------------
    def save_ticket_action(self):
        try:
            self.save_template_to_db()
            self.ticket_status_var.set(f"Tiket uložen do template ID {self.template_id_var.get()}.")
        except Exception as e:
            messagebox.showerror("Uložení tiketu", str(e))

    def create_ticket_action(self):
        if not self.fixed_items and not any(self.block_items.values()):
            messagebox.showwarning("Vytvoření tiketů", "Tiket je prázdný.")
            return
        self.generate_runtime_run()
        raw = str(self.last_run_id_var.get()).strip()
        if raw and raw != "-":
            self.ticket_status_var.set(f"Run {raw} byl vytvořen. Přehled najdeš v okně Přehled tiketů.")

    def open_ticket_overview_window(self):
        combos = self._combo_rows_cache if getattr(self, "_combo_rows_cache", None) else self.build_combinations()
        if not combos:
            messagebox.showinfo("Přehled tiketů", "Nejsou k dispozici žádné kombinace.")
            return

        stake = self.parse_stake()
        win = tk.Toplevel(self.root)
        win.title("Přehled tiketů")
        win.configure(bg=BG)
        win.geometry("1100x760")
        win.minsize(920, 620)

        selected_vars = []

        outer = tk.Frame(win, bg=BG)
        outer.pack(fill="both", expand=True, padx=12, pady=12)
        outer.grid_rowconfigure(1, weight=1)
        outer.grid_columnconfigure(0, weight=1)

        top = tk.Frame(outer, bg=BG)
        top.grid(row=0, column=0, sticky="ew", pady=(0, 10))
        top.grid_columnconfigure(0, weight=1)
        tk.Label(top, text="Přehled jednotlivých tiketů", bg=BG, fg=TEXT, font=FONT_SECTION).grid(row=0, column=0, sticky="w")
        tk.Label(top, text="Výchozí stav: vybrány všechny varianty. Pravděpodobnost je zatím počítána z kurzů.", bg=BG, fg=MUTED, font=FONT_SMALL).grid(row=1, column=0, sticky="w", pady=(2, 0))

        tools = tk.Frame(top, bg=BG)
        tools.grid(row=0, column=1, rowspan=2, sticky="e")
        select_all_var = tk.BooleanVar(value=True)

        list_frame = tk.Frame(outer, bg=BG)
        list_frame.grid(row=1, column=0, sticky="nsew")
        list_frame.grid_rowconfigure(0, weight=1)
        list_frame.grid_columnconfigure(0, weight=1)

        list_outer, _canvas, inner = self.create_scrollable_vertical(list_frame, BG)
        list_outer.grid(row=0, column=0, sticky="nsew")

        summary_var = tk.StringVar(value="")

        def combo_probability(combo: dict) -> Decimal:
            odd = combo.get("total_odds")
            if not odd:
                return Decimal("0")
            try:
                return Decimal("100") / Decimal(str(odd))
            except Exception:
                return Decimal("0")

        def update_summary():
            chosen = []
            for var, combo in selected_vars:
                if var.get():
                    chosen.append(combo)
            count = len(chosen)
            total_stake = stake * Decimal(count)
            max_win = sum((combo.get("total_odds") or Decimal("0")) * stake for combo in chosen)
            avg_prob = (sum(combo_probability(c) for c in chosen) / Decimal(count)) if count else Decimal("0")
            summary_var.set(
                f"Vybrané tikety: {count} | Celkem vsadíš: {total_stake:.2f} Kč | Součet možných výher: {max_win:.2f} Kč | Průměrná pravděpodobnost: {avg_prob:.2f}%"
            )

        def toggle_all():
            val = select_all_var.get()
            for var, _combo in selected_vars:
                var.set(val)
            update_summary()

        tk.Checkbutton(
            tools,
            text="Vybrat vše",
            variable=select_all_var,
            command=toggle_all,
            bg=BG,
            fg=TEXT,
            selectcolor=BET_PANEL_2,
            activebackground=BG,
            activeforeground=TEXT,
            font=FONT_XS,
        ).pack(side="left", padx=(0, 8))

        def export_selected_csv():
            chosen = [combo for var, combo in selected_vars if var.get()]
            if not chosen:
                messagebox.showinfo("Export CSV", "Nejdřív vyber aspoň jeden tiket.")
                return
            path = filedialog.asksaveasfilename(
                title="Uložit přehled tiketů",
                defaultextension=".csv",
                filetypes=[("CSV", "*.csv")],
            )
            if not path:
                return
            with open(path, "w", newline="", encoding="utf-8-sig") as f:
                writer = csv.writer(f, delimiter=";")
                writer.writerow(["ticket_index", "volby", "kurz", "pravdepodobnost_pct", "mozna_vyhra_kc", "polozky"])
                for combo in chosen:
                    prob = combo_probability(combo)
                    payout = (combo.get("total_odds") or Decimal("0")) * stake
                    writer.writerow([
                        combo.get("index"),
                        " | ".join(combo.get("choices") or ["FIXED only"]),
                        f"{combo.get('total_odds'):.2f}" if combo.get("total_odds") else "-",
                        f"{prob:.2f}",
                        f"{payout:.2f}",
                        " • ".join(combo.get("parts") or []),
                    ])
            messagebox.showinfo("Export CSV", f"Soubor uložen:\n{path}")

        tk.Button(tools, text="EXPORT CSV", bg=BLUE, fg=BG, relief="flat", font=FONT_XS, command=export_selected_csv).pack(side="left")

        for combo in combos:
            var = tk.BooleanVar(value=True)
            selected_vars.append((var, combo))

            card = tk.Frame(inner, bg=BET_PANEL_2, highlightthickness=1, highlightbackground=BET_LINE)
            card.pack(fill="x", pady=(0, 8))

            head = tk.Frame(card, bg=BET_PANEL_2)
            head.pack(fill="x", padx=10, pady=(8, 4))
            tk.Checkbutton(
                head,
                variable=var,
                command=update_summary,
                bg=BET_PANEL_2,
                activebackground=BET_PANEL_2,
                selectcolor=BET_PANEL_3,
            ).pack(side="left")
            tk.Label(head, text=f"Tiket #{combo['index']}", bg=BET_PANEL_2, fg=TEXT, font=FONT_SM_BOLD).pack(side="left", padx=(4, 8))
            badge = " | ".join(combo["choices"]) if combo["choices"] else "FIXED only"
            tk.Label(head, text=badge, bg=BET_PANEL_3, fg=YELLOW, font=FONT_XS, padx=6, pady=3).pack(side="right")

            tk.Label(card, text=" • ".join(combo.get("parts") or []), bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_SMALL, wraplength=980, justify="left").pack(fill="x", padx=10)

            foot = tk.Frame(card, bg=BET_PANEL_2)
            foot.pack(fill="x", padx=10, pady=(6, 8))
            odd = combo.get("total_odds")
            odd_text = f"{odd:.2f}" if odd else "-"
            prob = combo_probability(combo)
            payout = (odd or Decimal("0")) * stake
            tk.Label(foot, text=f"Kurz: {odd_text}", bg=BET_PANEL_2, fg=TEXT, font=FONT_XS).pack(side="left")
            tk.Label(foot, text=f"Pravděpodobnost: {prob:.2f}%", bg=BET_PANEL_2, fg=ACCENT, font=FONT_XS).pack(side="left", padx=(16, 0))
            tk.Label(foot, text=f"Možná výhra: {payout:.2f} Kč", bg=BET_PANEL_2, fg=TEXT, font=FONT_XS).pack(side="right")

        bottom = tk.Frame(outer, bg=BET_PANEL)
        bottom.grid(row=2, column=0, sticky="ew", pady=(10, 0))
        tk.Label(bottom, textvariable=summary_var, bg=BET_PANEL, fg=TEXT, font=FONT_SMALL, anchor="w", justify="left").pack(fill="x", padx=10, pady=10)
        update_summary()

    # -----------------------------------------------------
    # Toggle fixes so the ticket refreshes immediately
    # -----------------------------------------------------
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
            self.fixed_items.append({
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
            })
        self._update_button_states()
        self.refresh_all_panels()

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
        self._update_button_states()
        self.refresh_all_panels()

    def remove_fixed_item(self, index: int):
        super().remove_fixed_item(index)
        self._update_button_states()
        self.refresh_all_panels()

    def remove_block_item(self, block_index: int, index: int):
        super().remove_block_item(block_index, index)
        self._update_button_states()
        self.refresh_all_panels()


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV217(root)
    root.mainloop()


if __name__ == "__main__":
    main()
