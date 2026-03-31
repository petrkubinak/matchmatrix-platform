from __future__ import annotations

import tkinter as tk
from tkinter import ttk, messagebox
from decimal import Decimal, InvalidOperation
from collections import defaultdict
import psycopg2
from psycopg2.extras import RealDictCursor


# ============================================================
# MATCHMATRIX - TICKET STUDIO V2.3
# ------------------------------------------------------------
# Layout V2.3:
# - LEFT   : leagues / competitions
# - CENTER : matches in one-row grid
# - RIGHT  : current ticket (FIX + BLOCKS)
#
# DB:
# - template_fixed_picks
# - template_blocks
# - template_block_matches
#
# Markets:
# - H2H: 1/X/2
# - DC : 1X / 12 / X2
#
# BLOCKS:
# - H2H only for now
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
FONT_GRID = ("Segoe UI", 9)


class TicketStudioV23:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("MatchMatrix Ticket Studio V2.3")
        self.root.geometry("1920x1040")
        self.root.minsize(1500, 860)
        self.root.configure(bg=BG)

        # maps
        self.market_ids: dict[str, int] = {}
        self.market_outcome_ids: dict[tuple[str, str], int] = {}

        # data state
        self.all_matches: list[dict] = []
        self.visible_matches: list[dict] = []
        self.league_rows: list[dict] = []

        # ticket state
        self.fixed_items: list[dict] = []
        self.block_items: dict[int, list[dict]] = {1: [], 2: [], 3: []}

        self.build_ui()
        self.load_market_maps()
        self.load_sports()
        self.load_leagues_and_matches(initial=True)

    # =========================================================
    # DB helpers
    # =========================================================
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

    # =========================================================
    # General helpers
    # =========================================================
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

    def fmt_kickoff(self, value) -> str:
        if value is None:
            return "-"
        try:
            return value.strftime("%d.%m %H:%M")
        except Exception:
            return str(value)

    def block_label(self, block_index: int) -> str:
        return {1: "A", 2: "B", 3: "C"}.get(block_index, str(block_index))

    def compute_double_chance_odds(self, odd_1, odd_x, odd_2) -> dict[str, Decimal | None]:
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

    def get_market_id(self, market_code: str) -> int | None:
        return self.market_ids.get(str(market_code).upper())

    def get_market_outcome_id(self, market_code: str, outcome_code: str) -> int | None:
        return self.market_outcome_ids.get((str(market_code).upper(), str(outcome_code).upper()))

    # =========================================================
    # UI build
    # =========================================================
    def build_ui(self):
        self.build_header()
        self.build_main_layout()

    def build_header(self):
        header = tk.Frame(self.root, bg=BG)
        header.pack(fill="x", padx=10, pady=10)

        tk.Label(
            header,
            text="MatchMatrix Ticket Studio V2.3",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE
        ).pack(side="left")

        tk.Label(
            header,
            text="LEFT: soutěže • CENTER: zápasy • RIGHT: tiket",
            bg=BG,
            fg=MUTED,
            font=FONT
        ).pack(side="left", padx=12)

    def build_main_layout(self):
        main = tk.Frame(self.root, bg=BG)
        main.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        # LEFT
        left = tk.Frame(main, bg=BG, width=300)
        left.pack(side="left", fill="y", padx=(0, 8))
        left.pack_propagate(False)
        self.build_left_panel(left)

        # CENTER
        center = tk.Frame(main, bg=BG)
        center.pack(side="left", fill="both", expand=True, padx=(0, 8))
        self.build_center_panel(center)

        # RIGHT
        right = tk.Frame(main, bg=BG, width=430)
        right.pack(side="right", fill="y")
        right.pack_propagate(False)
        self.build_right_panel(right)

    # ---------------------------------------------------------
    # LEFT PANEL
    # ---------------------------------------------------------
    def build_left_panel(self, parent):
        top = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        top.pack(fill="x", pady=(0, 8))

        tk.Label(
            top,
            text="Filtry a soutěže",
            bg=CARD,
            fg=TEXT,
            font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 8))

        row1 = tk.Frame(top, bg=CARD)
        row1.pack(fill="x", padx=10, pady=(0, 8))

        tk.Label(row1, text="Sport", bg=CARD, fg=TEXT, font=FONT).pack(side="left")
        self.sport_var = tk.StringVar(value="ALL")
        self.sport_combo = ttk.Combobox(row1, textvariable=self.sport_var, state="readonly", width=12)
        self.sport_combo.pack(side="left", padx=(8, 0))

        row2 = tk.Frame(top, bg=CARD)
        row2.pack(fill="x", padx=10, pady=(0, 8))

        tk.Label(row2, text="Days", bg=CARD, fg=TEXT, font=FONT).pack(side="left")
        self.days_var = tk.StringVar(value="14")
        tk.Entry(
            row2, textvariable=self.days_var, width=8,
            bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat"
        ).pack(side="left", padx=(8, 0))

        row3 = tk.Frame(top, bg=CARD)
        row3.pack(fill="x", padx=10, pady=(0, 8))

        tk.Label(row3, text="League filter", bg=CARD, fg=TEXT, font=FONT).pack(anchor="w")
        self.league_filter_var = tk.StringVar(value="")
        tk.Entry(
            row3, textvariable=self.league_filter_var,
            bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat"
        ).pack(fill="x", pady=(4, 0))

        row4 = tk.Frame(top, bg=CARD)
        row4.pack(fill="x", padx=10, pady=(0, 10))

        self.only_odds_var = tk.BooleanVar(value=True)
        tk.Checkbutton(
            row4,
            text="Jen zápasy s kurzy",
            variable=self.only_odds_var,
            bg=CARD,
            fg=TEXT,
            selectcolor=CARD_2,
            activebackground=CARD,
            activeforeground=TEXT,
            font=FONT_SMALL
        ).pack(anchor="w")

        tk.Button(
            top,
            text="NAČÍST NABÍDKU",
            bg=ACCENT,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=lambda: self.load_leagues_and_matches(initial=False)
        ).pack(fill="x", padx=10, pady=(0, 10))

        body = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        body.pack(fill="both", expand=True)

        tk.Label(
            body,
            text="Soutěže",
            bg=CARD,
            fg=TEXT,
            font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 6))

        league_tools = tk.Frame(body, bg=CARD)
        league_tools.pack(fill="x", padx=10, pady=(0, 6))

        tk.Button(
            league_tools,
            text="VŠE",
            bg=CARD_2,
            fg=TEXT,
            font=FONT_SMALL,
            relief="flat",
            command=self.select_all_leagues
        ).pack(side="left", padx=(0, 6))

        tk.Button(
            league_tools,
            text="NIC",
            bg=CARD_2,
            fg=TEXT,
            font=FONT_SMALL,
            relief="flat",
            command=self.clear_league_selection
        ).pack(side="left")

        self.league_list_canvas = tk.Canvas(body, bg=CARD, highlightthickness=0)
        self.league_list_scroll = tk.Scrollbar(body, orient="vertical", command=self.league_list_canvas.yview)
        self.league_list_inner = tk.Frame(self.league_list_canvas, bg=CARD)

        self.league_list_inner.bind(
            "<Configure>",
            lambda e: self.league_list_canvas.configure(scrollregion=self.league_list_canvas.bbox("all"))
        )

        self.league_list_canvas.create_window((0, 0), window=self.league_list_inner, anchor="nw")
        self.league_list_canvas.configure(yscrollcommand=self.league_list_scroll.set)

        self.league_list_canvas.pack(side="left", fill="both", expand=True, padx=(10, 0), pady=(0, 10))
        self.league_list_scroll.pack(side="right", fill="y", padx=(0, 10), pady=(0, 10))

        self.league_vars: dict[str, tk.BooleanVar] = {}

    # ---------------------------------------------------------
    # CENTER PANEL
    # ---------------------------------------------------------
    def build_center_panel(self, parent):
        top = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        top.pack(fill="x", pady=(0, 8))

        tk.Label(
            top,
            text="Nabídka zápasů",
            bg=CARD,
            fg=TEXT,
            font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 4))

        tk.Label(
            top,
            text="1 zápas = 1 řádek • připraveno pro Pred / Forma / Tab / H2H",
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL
        ).pack(anchor="w", padx=10, pady=(0, 10))

        grid_box = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        grid_box.pack(fill="both", expand=True)

        self.build_match_header(grid_box)

        body = tk.Frame(grid_box, bg=CARD)
        body.pack(fill="both", expand=True)

        self.match_canvas = tk.Canvas(body, bg=CARD, highlightthickness=0)
        self.match_scroll_y = tk.Scrollbar(body, orient="vertical", command=self.match_canvas.yview)
        self.match_scroll_x = tk.Scrollbar(grid_box, orient="horizontal", command=self.match_canvas.xview)

        self.match_inner = tk.Frame(self.match_canvas, bg=CARD)

        self.match_inner.bind(
            "<Configure>",
            lambda e: self.match_canvas.configure(scrollregion=self.match_canvas.bbox("all"))
        )

        self.match_canvas.create_window((0, 0), window=self.match_inner, anchor="nw")
        self.match_canvas.configure(
            yscrollcommand=self.match_scroll_y.set,
            xscrollcommand=self.match_scroll_x.set
        )

        self.match_canvas.pack(side="left", fill="both", expand=True)
        self.match_scroll_y.pack(side="right", fill="y")
        self.match_scroll_x.pack(fill="x")

    def build_match_header(self, parent):
        hdr = tk.Frame(parent, bg=CARD_2)
        hdr.pack(fill="x")

        columns = [
            ("DATUM", 10),
            ("LIGA", 20),
            ("DOMÁCÍ", 18),
            ("HOSTÉ", 18),
            ("1", 6),
            ("X", 6),
            ("2", 6),
            ("1X", 6),
            ("12", 6),
            ("X2", 6),
            ("PRED", 8),
            ("FORMA", 8),
            ("TAB", 8),
            ("H2H", 8),
            ("FIX", 10),
            ("A", 5),
            ("B", 5),
            ("C", 5),
        ]

        for col, width in columns:
            tk.Label(
                hdr,
                text=col,
                width=width,
                bg=CARD_2,
                fg=YELLOW,
                font=FONT_SMALL,
                anchor="w" if col in ("LIGA", "DOMÁCÍ", "HOSTÉ") else "center"
            ).pack(side="left", padx=1, pady=6)

    # ---------------------------------------------------------
    # RIGHT PANEL
    # ---------------------------------------------------------
    def build_right_panel(self, parent):
        self.build_template_panel(parent)
        self.build_fixed_panel(parent)
        self.build_blocks_panel(parent)
        self.build_summary_panel(parent)

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
            text="NAČÍST",
            bg=BLUE,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=self.load_template_from_db
        ).pack(side="left", padx=(0, 6))

        tk.Button(
            row1,
            text="LOKÁLNÍ SLIP = 0",
            bg=CARD_2,
            fg=TEXT,
            font=FONT_SMALL,
            relief="flat",
            command=self.clear_local_state
        ).pack(side="left")

        row2 = tk.Frame(frame, bg=CARD)
        row2.pack(fill="x", padx=10, pady=(0, 10))

        tk.Button(
            row2,
            text="ULOŽIT DO DB",
            bg=ACCENT,
            fg=BG,
            font=FONT_BOLD,
            relief="flat",
            command=self.save_template_to_db
        ).pack(side="left", padx=(0, 8))

        tk.Button(
            row2,
            text="SMAZAT V DB",
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
            frame,
            text="FIXED Picky",
            bg=CARD,
            fg=TEXT,
            font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 6))

        self.fixed_canvas = tk.Canvas(frame, bg=CARD, highlightthickness=0, height=210)
        self.fixed_scroll = tk.Scrollbar(frame, orient="vertical", command=self.fixed_canvas.yview)
        self.fixed_inner = tk.Frame(self.fixed_canvas, bg=CARD)

        self.fixed_inner.bind(
            "<Configure>",
            lambda e: self.fixed_canvas.configure(scrollregion=self.fixed_canvas.bbox("all"))
        )

        self.fixed_canvas.create_window((0, 0), window=self.fixed_inner, anchor="nw")
        self.fixed_canvas.configure(yscrollcommand=self.fixed_scroll.set)

        self.fixed_canvas.pack(side="left", fill="both", expand=True, padx=(10, 0), pady=(0, 10))
        self.fixed_scroll.pack(side="right", fill="y", padx=(0, 10), pady=(0, 10))

    def build_blocks_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.pack(fill="both", expand=True, pady=(0, 8))

        tk.Label(
            frame,
            text="VARIABLE Bloky",
            bg=CARD,
            fg=TEXT,
            font=FONT_SECTION
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
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.pack(fill="x")

        tk.Label(
            frame,
            text="Souhrn",
            bg=CARD,
            fg=TEXT,
            font=FONT_SECTION
        ).pack(anchor="w", padx=10, pady=(10, 6))

        self.fixed_count_lbl = tk.Label(frame, text="Fixed picks: 0", bg=CARD, fg=TEXT, font=FONT)
        self.fixed_count_lbl.pack(anchor="w", padx=10, pady=(0, 2))

        self.block_count_lbl = tk.Label(frame, text="Block matches: 0", bg=CARD, fg=TEXT, font=FONT)
        self.block_count_lbl.pack(anchor="w", padx=10, pady=(0, 2))

        self.combo_count_lbl = tk.Label(frame, text="Variable combinations: 1", bg=CARD, fg=MUTED, font=FONT)
        self.combo_count_lbl.pack(anchor="w", padx=10, pady=(0, 2))

        self.total_odds_lbl = tk.Label(frame, text="Fixed total odds: -", bg=CARD, fg=TEXT, font=FONT)
        self.total_odds_lbl.pack(anchor="w", padx=10, pady=(0, 8))

        tk.Label(
            frame,
            text="Další krok: predikce, forma, tabulka, H2H, settlement, auto-ticket generation",
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL
        ).pack(anchor="w", padx=10, pady=(0, 10))

    # =========================================================
    # Markets load
    # =========================================================
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

    # =========================================================
    # Load leagues + matches
    # =========================================================
    def load_leagues_and_matches(self, initial: bool):
        sport_code = self.sport_var.get().strip()
        league_filter = self.league_filter_var.get().strip()
        days = self.safe_int(self.days_var.get(), 14)
        only_odds = self.only_odds_var.get()

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
                COALESCE(l.id, 0) AS league_id,
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

        if league_filter:
            sql += " AND l.name ILIKE %s"
            params.append(f"%{league_filter}%")

        if only_odds:
            sql += " AND oa.odd_1 IS NOT NULL AND oa.odd_x IS NOT NULL AND oa.odd_2 IS NOT NULL"

        sql += """
            ORDER BY l.name, m.kickoff ASC NULLS LAST, ht.name, at.name
            LIMIT 1000
        """

        self.all_matches = self.fetchall(sql, tuple(params))
        self.build_league_selector(initial=initial)
        self.apply_league_filter_to_center()

    def build_league_selector(self, initial: bool):
        for w in self.league_list_inner.winfo_children():
            w.destroy()

        grouped = defaultdict(int)
        for row in self.all_matches:
            league_name = str(row.get("league_name", "?"))
            grouped[league_name] += 1

        self.league_rows = [
            {"league_name": league_name, "match_count": count}
            for league_name, count in sorted(grouped.items(), key=lambda x: (x[0] or ""))
        ]

        # preserve current selection if possible
        old_selected = {name for name, var in self.league_vars.items() if var.get()}
        self.league_vars = {}

        if not self.league_rows:
            tk.Label(
                self.league_list_inner,
                text="Žádné soutěže pro filtr.",
                bg=CARD,
                fg=MUTED,
                font=FONT
            ).pack(anchor="w", pady=6)
            return

        for row in self.league_rows:
            league_name = row["league_name"]
            count = row["match_count"]

            # initial = select all
            selected = True if initial else (league_name in old_selected if old_selected else True)

            var = tk.BooleanVar(value=selected)
            self.league_vars[league_name] = var

            item = tk.Frame(self.league_list_inner, bg=CARD)
            item.pack(fill="x", pady=1)

            cb = tk.Checkbutton(
                item,
                text=f"{league_name} ({count})",
                variable=var,
                bg=CARD,
                fg=TEXT,
                selectcolor=CARD_2,
                activebackground=CARD,
                activeforeground=TEXT,
                font=FONT_SMALL,
                anchor="w",
                justify="left",
                command=self.apply_league_filter_to_center
            )
            cb.pack(fill="x", anchor="w")

    def select_all_leagues(self):
        for var in self.league_vars.values():
            var.set(True)
        self.apply_league_filter_to_center()

    def clear_league_selection(self):
        for var in self.league_vars.values():
            var.set(False)
        self.apply_league_filter_to_center()

    def apply_league_filter_to_center(self):
        selected = {name for name, var in self.league_vars.items() if var.get()}
        if not selected:
            self.visible_matches = []
        else:
            self.visible_matches = [
                row for row in self.all_matches
                if str(row.get("league_name", "?")) in selected
            ]
        self.render_match_rows()

    # =========================================================
    # Render match rows
    # =========================================================
    def render_match_rows(self):
        for widget in self.match_inner.winfo_children():
            widget.destroy()

        if not self.visible_matches:
            tk.Label(
                self.match_inner,
                text="Žádné zápasy pro vybrané soutěže.",
                bg=CARD,
                fg=MUTED,
                font=FONT
            ).pack(anchor="w", padx=10, pady=10)
            return

        for row in self.visible_matches:
            self.render_match_row(row)

    def render_match_row(self, row: dict):
        wrap = tk.Frame(self.match_inner, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        wrap.pack(fill="x", padx=4, pady=2)

        dc_odds = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))

        fields = [
            (self.fmt_kickoff(row.get("kickoff")), 10, "w"),
            (str(row.get("league_name", "?")), 20, "w"),
            (str(row.get("home_team", "?")), 18, "w"),
            (str(row.get("away_team", "?")), 18, "w"),
        ]

        for txt, width, anchor in fields:
            tk.Label(
                wrap,
                text=txt,
                width=width,
                bg=CARD,
                fg=TEXT,
                font=FONT_GRID,
                anchor=anchor
            ).pack(side="left", padx=1, pady=5)

        self.make_grid_pick_button(wrap, row, "H2H", "1", row.get("odd_1"), "1")
        self.make_grid_pick_button(wrap, row, "H2H", "X", row.get("odd_x"), "X")
        self.make_grid_pick_button(wrap, row, "H2H", "2", row.get("odd_2"), "2")

        self.make_grid_pick_button(wrap, row, "DC", "1X", dc_odds["1X"], "1X")
        self.make_grid_pick_button(wrap, row, "DC", "12", dc_odds["12"], "12")
        self.make_grid_pick_button(wrap, row, "DC", "X2", dc_odds["X2"], "X2")

        # placeholders
        self.make_placeholder_cell(wrap, "—", 8)
        self.make_placeholder_cell(wrap, "—", 8)
        self.make_placeholder_cell(wrap, "—", 8)
        self.make_placeholder_cell(wrap, "—", 8)

        # actions
        tk.Button(
            wrap,
            text="FIX",
            width=10,
            bg=ACCENT,
            fg=BG,
            font=FONT_SMALL,
            relief="flat",
            state="disabled"
        ).pack(side="left", padx=1, pady=3)

        tk.Button(
            wrap,
            text="A",
            width=5,
            bg=CARD_2,
            fg=TEXT,
            font=FONT_SMALL,
            relief="flat",
            command=lambda r=row: self.add_to_block(r, 1)
        ).pack(side="left", padx=1, pady=3)

        tk.Button(
            wrap,
            text="B",
            width=5,
            bg=CARD_2,
            fg=TEXT,
            font=FONT_SMALL,
            relief="flat",
            command=lambda r=row: self.add_to_block(r, 2)
        ).pack(side="left", padx=1, pady=3)

        tk.Button(
            wrap,
            text="C",
            width=5,
            bg=CARD_2,
            fg=TEXT,
            font=FONT_SMALL,
            relief="flat",
            command=lambda r=row: self.add_to_block(r, 3)
        ).pack(side="left", padx=1, pady=3)

    def make_placeholder_cell(self, parent, text: str, width: int):
        tk.Label(
            parent,
            text=text,
            width=width,
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL,
            anchor="center"
        ).pack(side="left", padx=1, pady=5)

    def make_grid_pick_button(self, parent, row: dict, market_code: str, outcome_code: str, odd_value, label: str):
        btn = tk.Button(
            parent,
            text=self.fmt_odds(odd_value),
            width=6,
            bg=CARD_2 if odd_value else CARD_3,
            fg=TEXT if odd_value else MUTED,
            font=FONT_SMALL,
            relief="flat",
            state="normal" if odd_value else "disabled",
            command=lambda: self.add_fixed_pick(row, market_code, outcome_code, odd_value)
        )
        btn.pack(side="left", padx=1, pady=3)

    # =========================================================
    # Ticket local state
    # =========================================================
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
            "league_name": str(row.get("league_name", "?")),
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

        # only one fixed pick per match+market
        self.fixed_items = [
            x for x in self.fixed_items
            if not (
                int(x["match_id"]) == int(item["match_id"])
                and str(x["market_code"]) == str(item["market_code"])
            )
        ]

        # if same match was in blocks, remove from blocks
        for bi in (1, 2, 3):
            self.block_items[bi] = [x for x in self.block_items[bi] if int(x["match_id"]) != int(item["match_id"])]

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
            "league_name": str(row.get("league_name", "?")),
            "market_code": "H2H",
            "market_id": int(market_id),
            "outcome_code": "",
            "market_outcome_id": None,
            "odd_value": None,
            "block_index": int(block_index),
        }

        # remove same match from fixed
        self.fixed_items = [x for x in self.fixed_items if int(x["match_id"]) != int(item["match_id"])]

        # remove same match from all blocks
        for bi in (1, 2, 3):
            self.block_items[bi] = [x for x in self.block_items[bi] if int(x["match_id"]) != int(item["match_id"])]

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

    # =========================================================
    # Refresh right panel
    # =========================================================
    def refresh_all_panels(self):
        self.refresh_fixed_panel()
        self.refresh_blocks_panel()
        self.refresh_summary()

    def refresh_fixed_panel(self):
        for widget in self.fixed_inner.winfo_children():
            widget.destroy()

        if not self.fixed_items:
            tk.Label(
                self.fixed_inner,
                text="Zatím žádné FIX picky.",
                bg=CARD,
                fg=MUTED,
                font=FONT
            ).pack(anchor="w", pady=4)
            return

        for idx, item in enumerate(self.fixed_items):
            row = tk.Frame(self.fixed_inner, bg=CARD_2, highlightthickness=1, highlightbackground=LINE)
            row.pack(fill="x", pady=4)

            left = tk.Frame(row, bg=CARD_2)
            left.pack(side="left", fill="both", expand=True, padx=8, pady=8)

            tk.Label(
                left,
                text=f"{item['home_team']} vs {item['away_team']}",
                bg=CARD_2,
                fg=TEXT,
                font=FONT_BOLD
            ).pack(anchor="w")

            tk.Label(
                left,
                text=f"{item['league_name']} • {item['market_code']} • {item['outcome_code']} • kurz {self.fmt_odds(item['odd_value'])}",
                bg=CARD_2,
                fg=MUTED,
                font=FONT_SMALL
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

                left = tk.Frame(row, bg=CARD_3)
                left.pack(side="left", fill="both", expand=True, padx=8, pady=6)

                tk.Label(
                    left,
                    text=f"{item['home_team']} vs {item['away_team']}",
                    bg=CARD_3,
                    fg=TEXT,
                    font=FONT
                ).pack(anchor="w")

                tk.Label(
                    left,
                    text=f"{item['league_name']} • blok {self.block_label(block_index)}",
                    bg=CARD_3,
                    fg=MUTED,
                    font=FONT_SMALL
                ).pack(anchor="w")

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
        self.total_odds_lbl.config(text=f"Fixed total odds: {total_odds:.2f}" if has_odds else "Fixed total odds: -")

    # =========================================================
    # Template save/load
    # =========================================================
    def ensure_template_exists(self, template_id: int):
        row = self.fetchone("SELECT id FROM public.templates WHERE id = %s", (template_id,))
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
                            (
                                template_id,
                                int(item["match_id"]),
                                int(item["market_outcome_id"]),
                                int(item["market_id"]),
                            )
                        )

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
                    m.kickoff,
                    l.name AS league_name
                FROM public.template_fixed_picks tfp
                JOIN public.matches m ON m.id = tfp.match_id
                LEFT JOIN public.leagues l ON l.id = m.league_id
                LEFT JOIN public.teams ht ON ht.id = m.home_team_id
                LEFT JOIN public.teams at ON at.id = m.away_team_id
                LEFT JOIN public.market_outcomes mo ON mo.id = tfp.market_outcome_id
                LEFT JOIN public.markets mk ON mk.id = COALESCE(tfp.market_id, mo.market_id)
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
                    m.kickoff,
                    l.name AS league_name
                FROM public.template_block_matches tbm
                JOIN public.matches m ON m.id = tbm.match_id
                LEFT JOIN public.leagues l ON l.id = m.league_id
                LEFT JOIN public.teams ht ON ht.id = m.home_team_id
                LEFT JOIN public.teams at ON at.id = m.away_team_id
                LEFT JOIN public.markets mk ON mk.id = tbm.market_id
                WHERE tbm.template_id = %s
                ORDER BY tbm.block_index, m.kickoff, tbm.match_id
                """,
                (template_id,)
            )

            match_map = {int(r["match_id"]): r for r in self.all_matches}

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
                    "league_name": str(r.get("league_name", "?")),
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
                    "league_name": str(r.get("league_name", "?")),
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

    app = TicketStudioV23(root)
    root.mainloop()


if __name__ == "__main__":
    main()