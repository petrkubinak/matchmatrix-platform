from __future__ import annotations

import json
import tkinter as tk
from tkinter import ttk, messagebox
from decimal import Decimal

from matchmatrix_ticket_studio_V2_10_5 import TicketStudioV2105, PINK, PINK_DARK, PINK_TEXT
from matchmatrix_ticket_studio_V2_9 import BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_LINE, BET_SOFT
from matchmatrix_ticket_studio_V2_7 import *


class TicketStudioV211(TicketStudioV2105):
    def __init__(self, root: tk.Tk):
        self.bookmaker_var = tk.StringVar(value="")
        self.max_tickets_var = tk.StringVar(value="5000")
        self.min_probability_var = tk.StringVar(value="")
        self.last_run_id_var = tk.StringVar(value="-")
        self.runtime_status_var = tk.StringVar(value="Runtime engine nepřipraven")
        self.preview_badge_var = tk.StringVar(value="bez preview")
        self.bookmaker_rows: list[dict] = []
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.11")
        self.viewport_var.set("desktop | compact center | runtime engine")
        self.load_bookmakers()
        self.refresh_all_panels()

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=(10, 8))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.11",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="opravené ukládání picks/bloků • správný toggle bloků • runtime preview + generování tiketů",
            bg=BG,
            fg=MUTED,
            font=FONT,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="desktop | compact center | runtime engine")
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

        self.build_template_panel_v29(parent)
        self.build_runtime_panel_v211(parent)
        self.build_betslip_summary_panel(parent)
        self.build_selection_panel_v29(parent)
        self.build_combos_panel_v29(parent)

    def build_runtime_panel_v211(self, parent):
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

        log_wrap = tk.Frame(frame, bg=BET_PANEL)
        log_wrap.pack(fill="both", expand=True, padx=12, pady=(0, 12))
        self.runtime_text = tk.Text(
            log_wrap,
            height=12,
            bg=BET_PANEL_2,
            fg=TEXT,
            insertbackground=TEXT,
            wrap="word",
            relief="flat",
            font=("Consolas", 9),
        )
        self.runtime_text.pack(side="left", fill="both", expand=True)
        scroll = tk.Scrollbar(log_wrap, orient="vertical", command=self.runtime_text.yview)
        scroll.pack(side="right", fill="y")
        self.runtime_text.configure(yscrollcommand=scroll.set)
        self._set_runtime_text("Runtime engine připraven. Nejprve vyber bookmaker a template ID.")

    def _set_runtime_text(self, text: str):
        self.runtime_text.configure(state="normal")
        self.runtime_text.delete("1.0", "end")
        self.runtime_text.insert("1.0", text)
        self.runtime_text.configure(state="disabled")

    def load_bookmakers(self):
        try:
            rows = self.fetchall(
                """
                SELECT b.id, b.name, COUNT(o.*) AS odds_count
                FROM public.bookmakers b
                LEFT JOIN public.odds o ON o.bookmaker_id = b.id
                GROUP BY b.id, b.name
                ORDER BY COUNT(o.*) DESC, b.name
                """
            )
            self.bookmaker_rows = rows
            values = [f"{int(r['id'])} | {r['name']} ({int(r.get('odds_count') or 0)})" for r in rows]
            self.bookmaker_combo["values"] = values
            if values and not self.bookmaker_var.get():
                self.bookmaker_var.set(values[0])
            self.runtime_status_var.set(f"Načteno bookmakerů: {len(rows)}")
        except Exception as e:
            self.runtime_status_var.set(f"Bookmaker load error: {e}")

    def _selected_bookmaker_id(self) -> int | None:
        raw = str(self.bookmaker_var.get()).strip()
        if not raw:
            return None
        try:
            return int(raw.split("|", 1)[0].strip())
        except Exception:
            return None

    def _parse_min_probability(self):
        raw = str(self.min_probability_var.get()).replace(",", ".").strip()
        if not raw:
            return None
        try:
            return Decimal(raw)
        except Exception:
            return None

    def _save_template_to_db_silent(self) -> int:
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            raise Exception("Zadej platné Template ID.")

        self.ensure_template_exists(template_id)

        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM public.template_fixed_picks WHERE template_id = %s", (template_id,))
                cur.execute("DELETE FROM public.template_block_matches WHERE template_id = %s", (template_id,))
                cur.execute("DELETE FROM public.template_blocks WHERE template_id = %s", (template_id,))

                for item in self.fixed_items:
                    cur.execute(
                        """
                        INSERT INTO public.template_fixed_picks (
                            template_id, match_id, market_outcome_id, market_id
                        )
                        VALUES (%s, %s, %s, %s)
                        """,
                        (template_id, int(item["match_id"]), int(item["market_outcome_id"]), int(item["market_id"])),
                    )

                for block_index in (1, 2, 3):
                    items = self.block_items[block_index]
                    if not items:
                        continue
                    cur.execute(
                        """
                        INSERT INTO public.template_blocks (template_id, block_index, block_type)
                        VALUES (%s, %s, 'VARIABLE')
                        """,
                        (template_id, block_index),
                    )
                    for item in items:
                        cur.execute(
                            """
                            INSERT INTO public.template_block_matches (
                                template_id, block_index, match_id, market_id
                            )
                            VALUES (%s, %s, %s, %s)
                            """,
                            (template_id, block_index, int(item["match_id"]), int(item["market_id"])),
                        )
            conn.commit()
        return template_id

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
                "market_code": str(market_code).upper(),
                "market_id": int(market_id),
                "outcome_code": str(outcome_code).upper(),
                "market_outcome_id": int(outcome_id),
                "odd_value": self.safe_decimal(odd_value),
                "block_index": 0,
            }
            self.fixed_items.append(item)
        self._update_button_states()
        self.refresh_selection_panel()
        self.refresh_summary()
        self.refresh_combos_panel()

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
                "market_code": "H2H",
                "market_id": int(market_id),
                "outcome_code": "",
                "market_outcome_id": None,
                "odd_value": None,
                "block_index": int(block_index),
            })
        self._update_button_states()
        self.refresh_selection_panel()
        self.refresh_summary()
        self.refresh_combos_panel()

    def preview_runtime_run(self):
        try:
            bookmaker_id = self._selected_bookmaker_id()
            if not bookmaker_id:
                raise Exception("Vyber bookmaker.")
            template_id = self._save_template_to_db_silent()
            row = self.fetchone("SELECT * FROM public.mm_preview_run(%s, %s)", (template_id, bookmaker_id))
            if not row:
                raise Exception("Preview nevrátil žádná data.")

            warnings = row.get("preview_warnings") or []
            blocks_detail = row.get("preview_blocks_detail")
            detail_text = json.dumps(blocks_detail, ensure_ascii=False, indent=2, default=str) if blocks_detail is not None else "[]"

            badge = f"{int(row.get('estimated_tickets') or 0)} tiketů"
            if warnings:
                badge += f" | {len(warnings)} warning"
            self.preview_badge_var.set(badge)
            self.runtime_status_var.set(f"Preview hotov pro template {template_id}, bookmaker {bookmaker_id}")

            text = (
                f"TEMPLATE ID: {template_id}\n"
                f"BOOKMAKER ID: {bookmaker_id}\n"
                f"VARIABLE BLOCKS: {row.get('variable_blocks')}\n"
                f"FIXED PICKS: {row.get('fixed_picks')}\n"
                f"ESTIMATED TICKETS: {row.get('estimated_tickets')}\n\n"
                f"WARNINGS:\n" + ("\n".join(f"- {w}" for w in warnings) if warnings else "- bez warningů") +
                f"\n\nDETAIL BLOCKŮ:\n{detail_text}"
            )
            self._set_runtime_text(text)
        except Exception as e:
            self.runtime_status_var.set(f"Preview error: {e}")
            self._set_runtime_text(f"PREVIEW ERROR\n\n{e}")

    def generate_runtime_run(self):
        try:
            bookmaker_id = self._selected_bookmaker_id()
            if not bookmaker_id:
                raise Exception("Vyber bookmaker.")
            template_id = self._save_template_to_db_silent()
            max_tickets = self.safe_int(self.max_tickets_var.get(), 5000)
            min_probability = self._parse_min_probability()
            stake = self.parse_stake()

            row = self.fetchone(
                "SELECT public.mm_generate_run_engine(%s, %s, %s, %s) AS run_id",
                (template_id, bookmaker_id, max_tickets, min_probability),
            )
            run_id = int(row["run_id"])
            self.last_run_id_var.set(str(run_id))
            self.preview_badge_var.set(f"run {run_id}")
            self.runtime_status_var.set(f"Run {run_id} vygenerován")
            self._render_run_details(run_id, stake)
        except Exception as e:
            self.runtime_status_var.set(f"Generate error: {e}")
            self._set_runtime_text(f"GENERATE ERROR\n\n{e}")

    def show_last_run_details(self):
        raw = str(self.last_run_id_var.get()).strip()
        if not raw or raw == "-":
            self._set_runtime_text("Zatím nebyl vytvořen žádný run v tomto panelu.")
            return
        try:
            self._render_run_details(int(raw), self.parse_stake())
        except Exception as e:
            self.runtime_status_var.set(f"Detail error: {e}")
            self._set_runtime_text(f"DETAIL ERROR\n\n{e}")

    def _render_run_details(self, run_id: int, stake: Decimal):
        summary = self.fetchone("SELECT * FROM public.mm_ui_run_summary(%s, %s)", (run_id, stake))
        tickets = self.fetchall(
            "SELECT * FROM public.mm_ui_run_tickets(%s) ORDER BY ticket_index LIMIT 20",
            (run_id,),
        )
        if not summary:
            raise Exception(f"Pro run {run_id} nebylo vráceno summary.")

        lines = [
            f"RUN ID: {run_id}",
            f"BOOKMAKER ID: {summary.get('bookmaker_id')}",
            f"TICKETS COUNT: {summary.get('tickets_count')}",
            f"STAKE / TICKET: {summary.get('stake_per_ticket')}",
            f"TOTAL STAKE: {summary.get('total_stake')}",
            f"MAX TOTAL ODD: {summary.get('max_total_odd')}",
            f"MIN TOTAL ODD: {summary.get('min_total_odd')}",
            f"AVG TOTAL ODD: {summary.get('avg_total_odd')}",
            f"MAX POSSIBLE WIN: {summary.get('max_possible_win')}",
            "",
            "PRVNÍ TIKETY:",
        ]

        for row in tickets:
            items = row.get("items")
            if isinstance(items, str):
                try:
                    items = json.loads(items)
                except Exception:
                    items = []
            parts = []
            for item in items or []:
                match_label = item.get("match") or f"match {item.get('match_id')}"
                outcome = item.get("outcome_code") or item.get("code") or "?"
                odd = item.get("odd_value")
                parts.append(f"{match_label} [{outcome} @ {odd}]")
            lines.append(f"#{row.get('ticket_index')} | kurz={row.get('total_odd')} | " + (" ; ".join(parts) if parts else "bez detailu"))

        self._set_runtime_text("\n".join(lines))


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV211(root)
    root.mainloop()


if __name__ == "__main__":
    main()
