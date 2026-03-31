from __future__ import annotations

import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime
from decimal import Decimal, InvalidOperation
import psycopg2
from psycopg2.extras import RealDictCursor


# ============================================================
# MATCHMATRIX - TICKET STUDIO V2.2
# ------------------------------------------------------------
# V2.2:
# - real matches from DB
# - real odds 1 / X / 2 from DB
# - computed odds 1X / 12 / X2 from 1X2
# - FIX picks:
#     -> save to public.template_fixed_picks
# - VARIABLE blocks A/B/C:
#     -> save to public.template_blocks
#     -> save to public.template_block_matches
# - load existing template back to UI
#
# IMPORTANT:
# - FIX supports H2H and DC
# - BLOCKS are kept as H2H only for now
#   because your existing scenario generation in DB is 1/X/2 based
# ============================================================

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

BG = "#0F0A1F"
CARD = "#1A1235"
CARD_2 = "#24164A"
CARD_3 = "#120D26"
ACCENT = "#C77DFF"
GREEN = "#00E676"
RED = "#FF5252"
YELLOW = "#FFD166"
TEXT = "#F5F0FF"
MUTED = "#9C8CC9"
LINE = "#4D347A"
BLUE = "#66C2FF"

FONT = ("Segoe UI", 10)
FONT_BOLD = ("Segoe UI", 10, "bold")
FONT_SMALL = ("Segoe UI", 9)
FONT_TITLE = ("Segoe UI", 16, "bold")
FONT_SECTION = ("Segoe UI", 12, "bold")


class TicketStudioV22:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("MatchMatrix Ticket Studio V2.2")
        self.root.geometry("1820x980")
        self.root.minsize(1380, 820)
        self.root.configure(bg=BG)

        # market + outcome maps
        self.market_ids: dict[str, int] = {}
        self.market_outcome_ids: dict[tuple[str, str], int] = {}

        # UI state
        self.match_rows: list[dict] = []
        self.fixed_items: list[dict] = []
        self.block_items: dict[int, list[dict]] = {1: [], 2: [], 3: []}

        self.build_ui()
        self.load_market_maps()
        self.load_sports()
        self.load_matches()

    # --------------------------------------------------------
    # DB helpers
    # --------------------------------------------------------
    def get_connection(self):
        return psycopg2.connect(**DB_CONFIG)

    def fetchall(self, sql: str, params: tuple = ()) -> list[dict]:
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                return list(cur.fetchall())

    def fetchone(self, sql: str, params: tuple = ()) -> dict | None:
        rows = self.fetchall(sql, params)
        return rows[0] if rows else None

    def execute(self, sql: str, params: tuple = ()) -> None:
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(sql, params)
            conn.commit()

    def execute_many(self, sql_params_list: list[tuple[str, tuple]]) -> None:
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                for sql, params in sql_params_list:
                    cur.execute(sql, params)
            conn.commit()

    # --------------------------------------------------------
    # General helpers
    # --------------------------------------------------------
    def safe_int(self, value: str, default: int) -> int:
        try:
            return int(str(value).strip())
        except Exception:
            return default

    def safe_decimal(self, value) -> Decimal | None:
        if value is None:
            return None
        try:
            return Decimal(str(value))
        except (InvalidOperation, ValueError):
            return None

    def fmt_odds(self, value) -> str:
        dec = self.safe_decimal(value)
        if dec is None:
            return "-"
        return f"{dec:.2f}"

    def compute_double_chance_odds(self, odd_1, odd_x, odd_2) -> dict[str, Decimal | None]:
        """
        Fair DC odds from normalized implied probabilities of 1/X/2.
        """
        d1 = self.safe_decimal(odd_1)
        dx = self.safe_decimal(odd_x)
        d2 = self.safe_decimal(odd_2)

        if not d1 or not dx or not d2:
            return {"1X": None, "12": None, "X2": None}

        try:
            inv1 = Decimal("1") / d1
            invx = Decimal("1") / dx
            inv2 = Decimal("1") / d2
            total = inv1 + invx + inv2
            if total <= 0:
                return {"1X": None, "12": None, "X2": None}

            p1 = inv1 / total
            px = invx / total
            p2 = inv2 / total

            p_1x = p1 + px
            p_12 = p1 + p2
            p_x2 = px + p2

            o_1x = Decimal("1") / p_1x if p_1x > 0 else None
            o_12 = Decimal("1") / p_12 if p_12 > 0 else None
            o_x2 = Decimal("1") / p_x2 if p_x2 > 0 else None

            return {"1X": o_1x, "12": o_12, "X2": o_x2}
        except Exception:
            return {"1X": None, "12": None, "X2": None}

    def make_pick_key(self, item: dict) -> tuple:
        return (
            str(item.get("item_type", "")),
            int(item.get("match_id", 0)),
            str(item.get("market_code", "")),
            str(item.get("outcome_code", "")),
            int(item.get("block_index", 0)),
        )

    # --------------------------------------------------------
    # UI build
    # --------------------------------------------------------
    def build_ui(self):
        header = tk.Frame(self.root, bg=BG)
        header.pack(fill="x", padx=10, pady=10)

        tk.Label(
            header,
            text="MatchMatrix Ticket Studio V2.2",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE
        ).pack(side="left")

        tk.Label(
            header,
            text="FIX + BLOKY A/B/C + 1/X/2 + 1X/12/X2",
            bg=BG,
            fg=MUTED,
            font=FONT
        ).pack(side="left", padx=12)

        content = tk.Frame(self.root, bg=BG)
        content.pack(fill="both", expand=True)

        # left side: filters + matches
        left = tk.Frame(content, bg=BG)
        left.pack(side="left", fill="both", expand=True, padx=(10, 6), pady=(0, 10))

        self.build_filters(left)
        self.build_match_list(left)

        # right side: fixed + blocks + summary
        right = tk.Frame(content, bg=BG, width=460)
        right.pack(side="right", fill="y", padx=(6, 10), pady=(0, 10))
        right.pack_propagate(False)

        self.build_template_panel(right)
        self.build_fixed_panel(right)
        self.build_blocks_panel(right)
        self.build_summary_panel(right)

    def build_filters(self, parent):
        filters = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        filters.pack(fill="x", pady=(0, 8))

        row1 = tk.Frame(filters, bg=CARD)
        row1.pack(fill="x", padx=10, pady=(10, 6))

        tk.Label(row1, text="Sport", bg=CARD, fg=TEXT, font=FONT).pack(side="left")
        self.sport_var = tk.StringVar(value="ALL")
        self.sport_combo = ttk.Combobox(row1, textvariable=self.sport_var, state="readonly", width=12)
        self.sport_combo.pack(side="left", padx=(6, 14))

        tk.Label(row1, text="League", bg=CARD, fg=TEXT, font=FONT).pack(side="left")
        self.league_var = tk.StringVar(value="")
        tk.Entry(
            row1, textvariable=self.league_var, width=24,
            bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat"
        ).pack(side="left", padx=(6, 14))

        tk.Label(row1, text="Days", bg=CARD, fg=TEXT, font=FONT).pack(side="left")
        self.days_var = tk.StringVar(value="14")
        tk.Entry(
            row1, textvariable=self.days_var, width=6,
            bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat"
        ).pack(side="left", padx=(6, 14))

        tk.Button(
            row1,
            text="NAČÍST ZÁPASY",
            bg=ACCENT,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=self.load_matches
        ).pack(side="left", padx=(0, 8))

        row2 = tk.Frame(filters, bg=CARD)
        row2.pack(fill="x", padx=10, pady=(0, 10))

        tk.Label(
            row2,
            text="FIX podporuje H2H i DC • BLOKY jsou zatím H2H only",
            bg=CARD,
            fg=YELLOW,
            font=FONT_SMALL
        ).pack(side="left")

    def build_match_list(self, parent):
        wrap = tk.Frame(parent, bg=BG)
        wrap.pack(fill="both", expand=True)

        self.canvas = tk.Canvas(wrap, bg=BG, highlightthickness=0)
        self.scrollbar = tk.Scrollbar(wrap, orient="vertical", command=self.canvas.yview)
        self.cards_frame = tk.Frame(self.canvas, bg=BG)

        self.cards_frame.bind(
            "<Configure>",
            lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        )

        self.canvas.create_window((0, 0), window=self.cards_frame, anchor="nw")
        self.canvas.configure(yscrollcommand=self.scrollbar.set)

        self.canvas.pack(side="left", fill="both", expand=True)
        self.scrollbar.pack(side="right", fill="y")

    def build_template_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.pack(fill="x", pady=(0, 8))

        tk.Label(
            frame, text="Template",
            bg=CARD, fg=TEXT, font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 4))

        row1 = tk.Frame(frame, bg=CARD)
        row1.pack(fill="x", padx=10, pady=(0, 8))

        tk.Label(row1, text="Template ID", bg=CARD, fg=TEXT, font=FONT).pack(side="left")
        self.template_id_var = tk.StringVar(value="1")
        tk.Entry(
            row1, textvariable=self.template_id_var, width=8,
            bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat"
        ).pack(side="left", padx=(8, 10))

        tk.Button(
            row1,
            text="NAČÍST TEMPLATE",
            bg=BLUE,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=self.load_template_from_db
        ).pack(side="left", padx=(0, 8))

        tk.Button(
            row1,
            text="VYMAZAT LOKÁLNÍ SLIP",
            bg=CARD_2,
            fg=TEXT,
            font=FONT,
            relief="flat",
            command=self.clear_local_state
        ).pack(side="left")

        row2 = tk.Frame(frame, bg=CARD)
        row2.pack(fill="x", padx=10, pady=(0, 10))

        tk.Button(
            row2,
            text="ULOŽIT TEMPLATE DO DB",
            bg=ACCENT,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=self.save_template_to_db
        ).pack(side="left", padx=(0, 8))

        tk.Button(
            row2,
            text="SMAZAT TEMPLATE V DB",
            bg=RED,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=self.delete_template_from_db
        ).pack(side="left")

    def build_fixed_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.pack(fill="both", expand=True, pady=(0, 8))

        tk.Label(
            frame, text="FIXED Picky",
            bg=CARD, fg=TEXT, font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 6))

        self.fixed_wrap = tk.Frame(frame, bg=CARD)
        self.fixed_wrap.pack(fill="both", expand=True, padx=10, pady=(0, 10))

    def build_blocks_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.pack(fill="both", expand=True, pady=(0, 8))

        tk.Label(
            frame, text="VARIABLE Bloky",
            bg=CARD, fg=TEXT, font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 6))

        self.block_wraps: dict[int, tk.Frame] = {}

        for block_index in (1, 2, 3):
            box = tk.Frame(frame, bg=CARD_2, highlightthickness=1, highlightbackground=LINE)
            box.pack(fill="x", padx=10, pady=(0, 8))

            top = tk.Frame(box, bg=CARD_2)
            top.pack(fill="x", padx=8, pady=(8, 6))

            tk.Label(
                top,
                text=f"Blok {self.block_label(block_index)}",
                bg=CARD_2,
                fg=YELLOW,
                font=FONT_BOLD
            ).pack(side="left")

            tk.Label(
                top,
                text="(H2H only)",
                bg=CARD_2,
                fg=MUTED,
                font=FONT_SMALL
            ).pack(side="left", padx=8)

            inner = tk.Frame(box, bg=CARD_2)
            inner.pack(fill="x", padx=8, pady=(0, 8))
            self.block_wraps[block_index] = inner

    def build_summary_panel(self, parent):
        summary = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        summary.pack(fill="x")

        tk.Label(
            summary, text="Souhrn",
            bg=CARD, fg=TEXT, font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 6))

        self.fixed_count_lbl = tk.Label(summary, text="Fixed picks: 0", bg=CARD, fg=TEXT, font=FONT)
        self.fixed_count_lbl.pack(anchor="w", padx=10, pady=(0, 2))

        self.block_count_lbl = tk.Label(summary, text="Block matches: 0", bg=CARD, fg=TEXT, font=FONT)
        self.block_count_lbl.pack(anchor="w", padx=10, pady=(0, 2))

        self.combo_count_lbl = tk.Label(summary, text="Variable combinations: 1", bg=CARD, fg=MUTED, font=FONT)
        self.combo_count_lbl.pack(anchor="w", padx=10, pady=(0, 2))

        self.total_odds_lbl = tk.Label(summary, text="Fixed total odds: -", bg=CARD, fg=TEXT, font=FONT)
        self.total_odds_lbl.pack(anchor="w", padx=10, pady=(0, 8))

        tk.Label(
            summary,
            text="Další krok: navázat na generování tiketů a settlement pipeline",
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL
        ).pack(anchor="w", padx=10, pady=(0, 10))

    # --------------------------------------------------------
    # Labels
    # --------------------------------------------------------
    def block_label(self, block_index: int) -> str:
        return {1: "A", 2: "B", 3: "C"}.get(block_index, str(block_index))

    # --------------------------------------------------------
    # Load market / outcome maps
    # --------------------------------------------------------
    def load_market_maps(self):
        markets = self.fetchall("""
            SELECT id, code
            FROM public.markets
            ORDER BY id
        """)
        self.market_ids = {str(r["code"]).upper(): int(r["id"]) for r in markets}

        outcomes = self.fetchall("""
            SELECT mk.code AS market_code, mo.code AS outcome_code, mo.id
            FROM public.market_outcomes mo
            JOIN public.markets mk ON mk.id = mo.market_id
            ORDER BY mk.id, mo.id
        """)
        self.market_outcome_ids = {
            (str(r["market_code"]).upper(), str(r["outcome_code"]).upper()): int(r["id"])
            for r in outcomes
        }

    def get_market_id(self, market_code: str) -> int | None:
        return self.market_ids.get(str(market_code).upper())

    def get_market_outcome_id(self, market_code: str, outcome_code: str) -> int | None:
        return self.market_outcome_ids.get((str(market_code).upper(), str(outcome_code).upper()))

    # --------------------------------------------------------
    # Data load
    # --------------------------------------------------------
    def load_sports(self):
        sql = """
            SELECT code
            FROM public.sports
            WHERE is_active = TRUE
            ORDER BY sort_order NULLS LAST, code
        """
        rows = self.fetchall(sql)
        values = ["ALL"] + [str(r["code"]) for r in rows]
        self.sport_combo["values"] = values
        self.sport_var.set("ALL")

    def load_matches(self):
        for widget in self.cards_frame.winfo_children():
            widget.destroy()

        sport_code = self.sport_var.get().strip()
        league_name = self.league_var.get().strip()
        days = self.safe_int(self.days_var.get(), 14)

        sql = """
            WITH odds_agg AS (
                SELECT
                    o.match_id,
                    MAX(CASE WHEN mo.code = '1' THEN o.odd_value END) AS odd_1,
                    MAX(CASE WHEN mo.code = 'X' THEN o.odd_value END) AS odd_x,
                    MAX(CASE WHEN mo.code = '2' THEN o.odd_value END) AS odd_2
                FROM public.odds o
                JOIN public.market_outcomes mo ON mo.id = o.market_outcome_id
                JOIN public.markets mk ON mk.id = mo.market_id
                WHERE lower(mk.code) IN (lower('h2h'), lower('1X2'))
                GROUP BY o.match_id
            )
            SELECT
                m.id AS match_id,
                m.kickoff,
                COALESCE(sp.code, '?') AS sport_code,
                COALESCE(l.name, '?') AS league_name,
                COALESCE(ht.name, '?') AS home_team,
                COALESCE(at.name, '?') AS away_team,
                oa.odd_1,
                oa.odd_x,
                oa.odd_2
            FROM public.matches m
            LEFT JOIN public.leagues l ON l.id = m.league_id
            LEFT JOIN public.sports sp ON sp.id = l.sport_id
            LEFT JOIN public.teams ht ON ht.id = m.home_team_id
            LEFT JOIN public.teams at ON at.id = m.away_team_id
            LEFT JOIN odds_agg oa ON oa.match_id = m.id
            WHERE m.kickoff >= now()
              AND m.kickoff < now() + (%s || ' days')::interval
        """
        params: list = [str(days)]

        if sport_code and sport_code != "ALL":
            sql += " AND sp.code = %s"
            params.append(sport_code)

        if league_name:
            sql += " AND l.name ILIKE %s"
            params.append(f"%{league_name}%")

        sql += """
            ORDER BY m.kickoff ASC NULLS LAST, l.name, ht.name, at.name
            LIMIT 500
        """

        rows = self.fetchall(sql, tuple(params))
        self.match_rows = rows

        if not rows:
            tk.Label(
                self.cards_frame,
                text="Žádné zápasy pro zadaný filtr.",
                bg=BG,
                fg=MUTED,
                font=FONT
            ).pack(anchor="w", padx=8, pady=8)
            return

        for row in rows:
            self.render_match_card(row)

    # --------------------------------------------------------
    # Match cards
    # --------------------------------------------------------
    def render_match_card(self, row: dict):
        card = tk.Frame(self.cards_frame, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        card.pack(fill="x", padx=4, pady=5)

        head = tk.Frame(card, bg=CARD)
        head.pack(fill="x", padx=10, pady=(10, 6))

        kickoff_txt = "-"
        if row.get("kickoff"):
            try:
                kickoff_txt = row["kickoff"].strftime("%d.%m.%Y %H:%M")
            except Exception:
                kickoff_txt = str(row["kickoff"])

        tk.Label(
            head,
            text=f"{row.get('sport_code', '?')} • {row.get('league_name', '?')} • {kickoff_txt}",
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL
        ).pack(anchor="w")

        teams = tk.Frame(card, bg=CARD)
        teams.pack(fill="x", padx=10, pady=(0, 8))

        tk.Label(
            teams,
            text=f"{row.get('home_team', '?')}  vs  {row.get('away_team', '?')}",
            bg=CARD,
            fg=TEXT,
            font=("Segoe UI", 12, "bold")
        ).pack(anchor="w")

        odds_box = tk.Frame(card, bg=CARD)
        odds_box.pack(fill="x", padx=10, pady=(0, 8))

        # H2H row
        h2h = tk.Frame(odds_box, bg=CARD)
        h2h.pack(fill="x", pady=(0, 4))
        tk.Label(h2h, text="FIX H2H", bg=CARD, fg=YELLOW, font=FONT_SMALL, width=10, anchor="w").pack(side="left")

        self.make_pick_button(h2h, row, market_code="H2H", outcome_code="1", odd_value=row.get("odd_1"), label="1")
        self.make_pick_button(h2h, row, market_code="H2H", outcome_code="X", odd_value=row.get("odd_x"), label="X")
        self.make_pick_button(h2h, row, market_code="H2H", outcome_code="2", odd_value=row.get("odd_2"), label="2")

        # DC row
        dc_odds = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))
        dc = tk.Frame(odds_box, bg=CARD)
        dc.pack(fill="x", pady=(0, 4))
        tk.Label(dc, text="FIX DC", bg=CARD, fg=BLUE, font=FONT_SMALL, width=10, anchor="w").pack(side="left")

        self.make_pick_button(dc, row, market_code="DC", outcome_code="1X", odd_value=dc_odds["1X"], label="1X")
        self.make_pick_button(dc, row, market_code="DC", outcome_code="12", odd_value=dc_odds["12"], label="12")
        self.make_pick_button(dc, row, market_code="DC", outcome_code="X2", odd_value=dc_odds["X2"], label="X2")

        # Blocks row - H2H only
        blocks = tk.Frame(card, bg=CARD)
        blocks.pack(fill="x", padx=10, pady=(0, 10))

        tk.Label(blocks, text="BLOKY", bg=CARD, fg=TEXT, font=FONT_SMALL).pack(side="left", padx=(0, 8))

        for block_index in (1, 2, 3):
            tk.Button(
                blocks,
                text=f"+ blok {self.block_label(block_index)}",
                bg=CARD_2,
                fg=TEXT,
                font=FONT_SMALL,
                relief="flat",
                command=lambda r=row, bi=block_index: self.add_to_block(r, bi)
            ).pack(side="left", padx=(0, 6))

    def make_pick_button(self, parent, row: dict, market_code: str, outcome_code: str, odd_value, label: str):
        btn = tk.Button(
            parent,
            text=f"{label}\n{self.fmt_odds(odd_value)}",
            width=8,
            height=2,
            bg=CARD_2 if odd_value else CARD_3,
            fg=TEXT if odd_value else MUTED,
            font=FONT_BOLD if odd_value else FONT,
            relief="flat",
            state="normal" if odd_value else "disabled",
            command=lambda: self.add_fixed_pick(row, market_code, outcome_code, odd_value)
        )
        btn.pack(side="left", padx=(0, 6))

    # --------------------------------------------------------
    # Local state manipulation
    # --------------------------------------------------------
    def add_fixed_pick(self, row: dict, market_code: str, outcome_code: str, odd_value):
        market_id = self.get_market_id(market_code)
        outcome_id = self.get_market_outcome_id(market_code, outcome_code)

        if not market_id or not outcome_id:
            messagebox.showerror("DB chyba", f"Chybí market/outcome map pro {market_code}/{outcome_code}.")
            return

        item = {
            "item_type": "FIXED",
            "match_id": int(row["match_id"]),
            "kickoff": row.get("kickoff"),
            "home_team": str(row.get("home_team", "?")),
            "away_team": str(row.get("away_team", "?")),
            "market_code": market_code.upper(),
            "market_id": int(market_id),
            "outcome_code": outcome_code.upper(),
            "market_outcome_id": int(outcome_id),
            "odd_value": self.safe_decimal(odd_value),
            "block_index": 0,
        }

        key = self.make_pick_key(item)
        existing_keys = {self.make_pick_key(x) for x in self.fixed_items}
        if key in existing_keys:
            return

        # one fixed pick per match+market
        self.fixed_items = [
            x for x in self.fixed_items
            if not (
                int(x["match_id"]) == int(item["match_id"])
                and str(x["market_code"]) == str(item["market_code"])
            )
        ]
        self.fixed_items.append(item)
        self.refresh_all_panels()

    def add_to_block(self, row: dict, block_index: int):
        market_id = self.get_market_id("H2H")
        if not market_id:
            messagebox.showerror("DB chyba", "Chybí market_id pro H2H.")
            return

        item = {
            "item_type": "BLOCK",
            "match_id": int(row["match_id"]),
            "kickoff": row.get("kickoff"),
            "home_team": str(row.get("home_team", "?")),
            "away_team": str(row.get("away_team", "?")),
            "market_code": "H2H",
            "market_id": int(market_id),
            "outcome_code": "",
            "market_outcome_id": None,
            "odd_value": None,
            "block_index": int(block_index),
        }

        # avoid same match in another block
        for bi in (1, 2, 3):
            self.block_items[bi] = [
                x for x in self.block_items[bi]
                if int(x["match_id"]) != int(item["match_id"])
            ]

        # avoid same match in fixed if user wants it as variable block
        self.fixed_items = [
            x for x in self.fixed_items
            if int(x["match_id"]) != int(item["match_id"])
        ]

        self.block_items[block_index].append(item)
        self.refresh_all_panels()

    def remove_fixed_item(self, idx: int):
        if 0 <= idx < len(self.fixed_items):
            del self.fixed_items[idx]
            self.refresh_all_panels()

    def remove_block_item(self, block_index: int, idx: int):
        if 0 <= idx < len(self.block_items[block_index]):
            del self.block_items[block_index][idx]
            self.refresh_all_panels()

    def clear_local_state(self):
        self.fixed_items = []
        self.block_items = {1: [], 2: [], 3: []}
        self.refresh_all_panels()

    # --------------------------------------------------------
    # Refresh panels
    # --------------------------------------------------------
    def refresh_all_panels(self):
        self.refresh_fixed_panel()
        self.refresh_blocks_panel()
        self.refresh_summary()

    def refresh_fixed_panel(self):
        for widget in self.fixed_wrap.winfo_children():
            widget.destroy()

        if not self.fixed_items:
            tk.Label(
                self.fixed_wrap,
                text="Zatím žádné FIX picky.",
                bg=CARD,
                fg=MUTED,
                font=FONT
            ).pack(anchor="w", pady=4)
            return

        for idx, item in enumerate(self.fixed_items):
            row = tk.Frame(self.fixed_wrap, bg=CARD_2, highlightthickness=1, highlightbackground=LINE)
            row.pack(fill="x", pady=4)

            left = tk.Frame(row, bg=CARD_2)
            left.pack(side="left", fill="both", expand=True, padx=8, pady=8)

            tk.Label(
                left,
                text=f"{item['home_team']} vs {item['away_team']}",
                bg=CARD_2, fg=TEXT, font=FONT_BOLD
            ).pack(anchor="w")

            tk.Label(
                left,
                text=f"{item['market_code']} • {item['outcome_code']} • kurz {self.fmt_odds(item['odd_value'])}",
                bg=CARD_2, fg=MUTED, font=FONT_SMALL
            ).pack(anchor="w")

            tk.Button(
                row,
                text="ODEBRAT",
                bg=RED,
                fg=BG,
                font=FONT_SMALL,
                relief="flat",
                command=lambda i=idx: self.remove_fixed_item(i)
            ).pack(side="right", padx=8, pady=8)

    def refresh_blocks_panel(self):
        for block_index in (1, 2, 3):
            wrap = self.block_wraps[block_index]
            for widget in wrap.winfo_children():
                widget.destroy()

            items = self.block_items[block_index]
            if not items:
                tk.Label(
                    wrap,
                    text="prázdný blok",
                    bg=CARD_2,
                    fg=MUTED,
                    font=FONT_SMALL
                ).pack(anchor="w", pady=2)
                continue

            for idx, item in enumerate(items):
                row = tk.Frame(wrap, bg=CARD_3, highlightthickness=1, highlightbackground=LINE)
                row.pack(fill="x", pady=3)

                tk.Label(
                    row,
                    text=f"{item['home_team']} vs {item['away_team']}",
                    bg=CARD_3,
                    fg=TEXT,
                    font=FONT
                ).pack(side="left", padx=8, pady=6)

                tk.Button(
                    row,
                    text="ODEBRAT",
                    bg=RED,
                    fg=BG,
                    font=FONT_SMALL,
                    relief="flat",
                    command=lambda bi=block_index, i=idx: self.remove_block_item(bi, i)
                ).pack(side="right", padx=8, pady=6)

    def refresh_summary(self):
        fixed_count = len(self.fixed_items)
        block_count = sum(len(v) for v in self.block_items.values())
        variable_blocks = sum(1 for bi in (1, 2, 3) if len(self.block_items[bi]) > 0)
        combination_count = 3 ** variable_blocks if variable_blocks > 0 else 1

        total_odds = Decimal("1")
        has_odds = False
        for item in self.fixed_items:
            odd = self.safe_decimal(item.get("odd_value"))
            if odd and odd > 0:
                total_odds *= odd
                has_odds = True

        self.fixed_count_lbl.config(text=f"Fixed picks: {fixed_count}")
        self.block_count_lbl.config(text=f"Block matches: {block_count} in {variable_blocks} active block(s)")
        self.combo_count_lbl.config(text=f"Variable combinations: {combination_count}")
        self.total_odds_lbl.config(
            text=f"Fixed total odds: {total_odds:.2f}" if has_odds else "Fixed total odds: -"
        )

    # --------------------------------------------------------
    # Save / load template
    # --------------------------------------------------------
    def ensure_template_exists(self, template_id: int):
        row = self.fetchone(
            "SELECT id FROM public.templates WHERE id = %s",
            (template_id,)
        )
        if row:
            return

        raise Exception(
            f"Template ID {template_id} neexistuje v public.templates. "
            f"Nejdřív vytvoř template hlavičku."
        )

    def save_template_to_db(self):
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return

        try:
            self.ensure_template_exists(template_id)

            with self.get_connection() as conn:
                with conn.cursor() as cur:
                    # 1) clear old rows
                    cur.execute("DELETE FROM public.template_fixed_picks WHERE template_id = %s", (template_id,))
                    cur.execute("DELETE FROM public.template_block_matches WHERE template_id = %s", (template_id,))
                    cur.execute("DELETE FROM public.template_blocks WHERE template_id = %s", (template_id,))

                    # 2) save fixed picks
                    for item in self.fixed_items:
                        cur.execute(
                            """
                            INSERT INTO public.template_fixed_picks (
                                template_id, match_id, market_outcome_id, market_id
                            )
                            VALUES (%s, %s, %s, %s)
                            """,
                            (
                                template_id,
                                int(item["match_id"]),
                                int(item["market_outcome_id"]),
                                int(item["market_id"]),
                            )
                        )

                    # 3) save variable blocks
                    for block_index in (1, 2, 3):
                        items = self.block_items[block_index]
                        if not items:
                            continue

                        cur.execute(
                            """
                            INSERT INTO public.template_blocks (
                                template_id, block_index, block_type
                            )
                            VALUES (%s, %s, 'VARIABLE')
                            """,
                            (template_id, block_index)
                        )

                        for item in items:
                            cur.execute(
                                """
                                INSERT INTO public.template_block_matches (
                                    template_id, block_index, match_id, market_id
                                )
                                VALUES (%s, %s, %s, %s)
                                """,
                                (
                                    template_id,
                                    block_index,
                                    int(item["match_id"]),
                                    int(item["market_id"]),
                                )
                            )

                conn.commit()

            messagebox.showinfo("OK", f"Template {template_id} uložen do DB.")
        except Exception as e:
            messagebox.showerror("Chyba při uložení", str(e))

    def delete_template_from_db(self):
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return

        if not messagebox.askyesno("Potvrzení", f"Opravdu smazat picks/blocks pro template {template_id}?"):
            return

        try:
            with self.get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("DELETE FROM public.template_fixed_picks WHERE template_id = %s", (template_id,))
                    cur.execute("DELETE FROM public.template_block_matches WHERE template_id = %s", (template_id,))
                    cur.execute("DELETE FROM public.template_blocks WHERE template_id = %s", (template_id,))
                conn.commit()

            self.clear_local_state()
            messagebox.showinfo("OK", f"Template {template_id} vyčištěn.")
        except Exception as e:
            messagebox.showerror("Chyba při mazání", str(e))

    def load_template_from_db(self):
        template_id = self.safe_int(self.template_id_var.get(), 0)
        if template_id <= 0:
            messagebox.showerror("Chyba", "Zadej platné Template ID.")
            return

        try:
            fixed_rows = self.fetchall(
                """
                SELECT
                    tfp.match_id,
                    tfp.market_id,
                    tfp.market_outcome_id,
                    mk.code AS market_code,
                    mo.code AS outcome_code,
                    ht.name AS home_team,
                    at.name AS away_team,
                    m.kickoff
                FROM public.template_fixed_picks tfp
                JOIN public.matches m ON m.id = tfp.match_id
                LEFT JOIN public.teams ht ON ht.id = m.home_team_id
                LEFT JOIN public.teams at ON at.id = m.away_team_id
                LEFT JOIN public.markets mk ON mk.id = COALESCE(tfp.market_id, mo.market_id)
                LEFT JOIN public.market_outcomes mo ON mo.id = tfp.market_outcome_id
                WHERE tfp.template_id = %s
                ORDER BY m.kickoff, tfp.match_id
                """,
                (template_id,)
            )

            block_rows = self.fetchall(
                """
                SELECT
                    tbm.block_index,
                    tbm.match_id,
                    tbm.market_id,
                    mk.code AS market_code,
                    ht.name AS home_team,
                    at.name AS away_team,
                    m.kickoff
                FROM public.template_block_matches tbm
                JOIN public.matches m ON m.id = tbm.match_id
                LEFT JOIN public.teams ht ON ht.id = m.home_team_id
                LEFT JOIN public.teams at ON at.id = m.away_team_id
                LEFT JOIN public.markets mk ON mk.id = tbm.market_id
                WHERE tbm.template_id = %s
                ORDER BY tbm.block_index, m.kickoff, tbm.match_id
                """,
                (template_id,)
            )

            # prepare odds lookup from loaded match rows currently on screen
            match_map = {int(r["match_id"]): r for r in self.match_rows}

            self.fixed_items = []
            self.block_items = {1: [], 2: [], 3: []}

            for r in fixed_rows:
                odd_value = None
                match_id = int(r["match_id"])
                market_code = str(r["market_code"]).upper()
                outcome_code = str(r["outcome_code"]).upper()

                if match_id in match_map:
                    src = match_map[match_id]
                    if market_code == "H2H":
                        if outcome_code == "1":
                            odd_value = src.get("odd_1")
                        elif outcome_code == "X":
                            odd_value = src.get("odd_x")
                        elif outcome_code == "2":
                            odd_value = src.get("odd_2")
                    elif market_code == "DC":
                        dc_odds = self.compute_double_chance_odds(src.get("odd_1"), src.get("odd_x"), src.get("odd_2"))
                        odd_value = dc_odds.get(outcome_code)

                self.fixed_items.append({
                    "item_type": "FIXED",
                    "match_id": match_id,
                    "kickoff": r.get("kickoff"),
                    "home_team": str(r.get("home_team", "?")),
                    "away_team": str(r.get("away_team", "?")),
                    "market_code": market_code,
                    "market_id": int(r["market_id"]) if r.get("market_id") is not None else self.get_market_id(market_code),
                    "outcome_code": outcome_code,
                    "market_outcome_id": int(r["market_outcome_id"]),
                    "odd_value": self.safe_decimal(odd_value),
                    "block_index": 0,
                })

            for r in block_rows:
                block_index = int(r["block_index"])
                if block_index not in (1, 2, 3):
                    continue

                self.block_items[block_index].append({
                    "item_type": "BLOCK",
                    "match_id": int(r["match_id"]),
                    "kickoff": r.get("kickoff"),
                    "home_team": str(r.get("home_team", "?")),
                    "away_team": str(r.get("away_team", "?")),
                    "market_code": str(r.get("market_code", "H2H")).upper(),
                    "market_id": int(r["market_id"]),
                    "outcome_code": "",
                    "market_outcome_id": None,
                    "odd_value": None,
                    "block_index": block_index,
                })

            self.refresh_all_panels()
            messagebox.showinfo("OK", f"Template {template_id} načten z DB.")
        except Exception as e:
            messagebox.showerror("Chyba při načtení", str(e))


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass

    app = TicketStudioV22(root)
    root.mainloop()


if __name__ == "__main__":
    main()