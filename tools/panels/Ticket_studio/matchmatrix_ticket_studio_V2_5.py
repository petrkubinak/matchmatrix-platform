from __future__ import annotations

import tkinter as tk
from tkinter import ttk, messagebox
from decimal import Decimal, InvalidOperation
from collections import defaultdict
import psycopg2
from psycopg2.extras import RealDictCursor


# ============================================================
# MATCHMATRIX - TICKET STUDIO V2.4
# ------------------------------------------------------------
# V2.4:
# - dynamic 3-column layout via PanedWindow
# - resizable left / center / right panels
# - responsive center grid
# - scrollable left leagues and right ticket panels
# - FIX: H2H + DC
# - BLOCKS: A/B/C (H2H only)
# - save/load template from DB
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


class TicketStudioV24:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("MatchMatrix Ticket Studio V2.4")
        self.root.geometry("1920x1040")
        self.root.minsize(1500, 860)
        self.root.configure(bg=BG)

        self.market_ids: dict[str, int] = {}
        self.market_outcome_ids: dict[tuple[str, str], int] = {}

        self.all_matches: list[dict] = []
        self.visible_matches: list[dict] = []
        self.league_rows: list[dict] = []

        self.fixed_items: list[dict] = []
        self.block_items: dict[int, list[dict]] = {1: [], 2: [], 3: []}

        self.league_vars: dict[str, tk.BooleanVar] = {}

        self.build_ui()
        self.load_market_maps()
        self.load_sports()
        self.load_leagues_and_matches(initial=True)

        self.root.after(200, self.init_pane_sizes)

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

    def get_market_id(self, market_code: str) -> int | None:
        return self.market_ids.get(str(market_code).upper())

    def get_market_outcome_id(self, market_code: str, outcome_code: str) -> int | None:
        return self.market_outcome_ids.get((str(market_code).upper(), str(outcome_code).upper()))

    def make_pick_key(self, item: dict) -> tuple:
        return (
            str(item.get("item_type", "")),
            int(item.get("match_id", 0)),
            str(item.get("market_code", "")),
            str(item.get("outcome_code", "")),
            int(item.get("block_index", 0)),
        )

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

    # =========================================================
    # UI
    # =========================================================
    def build_ui(self):
        self.build_header()

        outer = tk.Frame(self.root, bg=BG)
        outer.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        self.main_paned = tk.PanedWindow(
            outer,
            orient="horizontal",
            sashrelief="flat",
            sashwidth=8,
            bg=BG,
            bd=0
        )
        self.main_paned.pack(fill="both", expand=True)

        self.left_panel = tk.Frame(self.main_paned, bg=BG)
        self.center_panel = tk.Frame(self.main_paned, bg=BG)
        self.right_panel = tk.Frame(self.main_paned, bg=BG)

        self.main_paned.add(self.left_panel, minsize=240)
        self.main_paned.add(self.center_panel, minsize=700)
        self.main_paned.add(self.right_panel, minsize=340)

        self.build_left_panel(self.left_panel)
        self.build_center_panel(self.center_panel)
        self.build_right_panel(self.right_panel)

    def init_pane_sizes(self):
        try:
            total = self.main_paned.winfo_width()
            if total <= 1:
                return
            left_w = max(260, int(total * 0.18))
            center_w = max(760, int(total * 0.56))
            self.main_paned.sashpos(0, left_w)
            self.main_paned.sashpos(1, left_w + center_w)
        except Exception:
            pass

    def build_header(self):
        header = tk.Frame(self.root, bg=BG)
        header.pack(fill="x", padx=10, pady=10)

        tk.Label(
            header,
            text="MatchMatrix Ticket Studio V2.4",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE
        ).pack(side="left")

        tk.Label(
            header,
            text="dynamický layout • resize panelů • responsivní grid",
            bg=BG,
            fg=MUTED,
            font=FONT
        ).pack(side="left", padx=12)

    # =========================================================
    # Scrollable helpers
    # =========================================================
    def create_scrollable_vertical(self, parent, bg_color):
        outer = tk.Frame(parent, bg=bg_color)
        canvas = tk.Canvas(outer, bg=bg_color, highlightthickness=0)
        scrollbar = tk.Scrollbar(outer, orient="vertical", command=canvas.yview)
        inner = tk.Frame(canvas, bg=bg_color)

        inner.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas_window = canvas.create_window((0, 0), window=inner, anchor="nw")

        def resize_inner(event):
            canvas.itemconfigure(canvas_window, width=event.width)

        canvas.bind("<Configure>", resize_inner)
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        return outer, canvas, inner

    # =========================================================
    # LEFT PANEL
    # =========================================================
    def build_left_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        top = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        top.grid(row=0, column=0, sticky="nsew", pady=(0, 8))

        tk.Label(top, text="Filtry a soutěže", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 8))

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
        tk.Entry(row2, textvariable=self.days_var, width=8, bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat").pack(side="left", padx=(8, 0))

        row3 = tk.Frame(top, bg=CARD)
        row3.pack(fill="x", padx=10, pady=(0, 8))
        tk.Label(row3, text="League filter", bg=CARD, fg=TEXT, font=FONT).pack(anchor="w")
        self.league_filter_var = tk.StringVar(value="")
        tk.Entry(row3, textvariable=self.league_filter_var, bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat").pack(fill="x", pady=(4, 0))

        row4 = tk.Frame(top, bg=CARD)
        row4.pack(fill="x", padx=10, pady=(0, 8))
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
        body.grid(row=1, column=0, sticky="nsew")

        tk.Label(body, text="Soutěže", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 6))

        league_tools = tk.Frame(body, bg=CARD)
        league_tools.pack(fill="x", padx=10, pady=(0, 6))

        tk.Button(league_tools, text="VŠE", bg=CARD_2, fg=TEXT, font=FONT_SMALL, relief="flat", command=self.select_all_leagues).pack(side="left", padx=(0, 6))
        tk.Button(league_tools, text="NIC", bg=CARD_2, fg=TEXT, font=FONT_SMALL, relief="flat", command=self.clear_league_selection).pack(side="left")

        league_outer, _, self.league_list_inner = self.create_scrollable_vertical(body, CARD)
        league_outer.pack(fill="both", expand=True, padx=10, pady=(0, 10))

    # =========================================================
    # CENTER PANEL
    # =========================================================
    def build_center_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        top = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        top.grid(row=0, column=0, sticky="nsew", pady=(0, 8))

        tk.Label(top, text="Nabídka zápasů", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 4))
        tk.Label(
            top,
            text="1 zápas = 1 řádek • připraveno pro Pred / Forma / Tab / H2H",
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL
        ).pack(anchor="w", padx=10, pady=(0, 10))

        grid_box = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        grid_box.grid(row=1, column=0, sticky="nsew")
        grid_box.grid_rowconfigure(1, weight=1)
        grid_box.grid_columnconfigure(0, weight=1)

        self.grid_columns = [
            ("DATUM", 90, "w"),
            ("LIGA", 200, "w"),
            ("DOMÁCÍ", 180, "w"),
            ("HOSTÉ", 180, "w"),
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

    def sync_x_scroll(self, *args):
        self.match_canvas.xview(*args)

    def build_match_header(self, parent):
        for widget in parent.winfo_children():
            widget.destroy()

        x = 0
        for title, width, anchor in self.grid_columns:
            lbl = tk.Label(
                parent,
                text=title,
                bg=CARD_2,
                fg=YELLOW,
                font=FONT_SMALL,
                anchor=anchor
            )
            lbl.place(x=x, y=0, width=width, height=32)
            x += width

        parent.configure(height=32)

    # =========================================================
    # RIGHT PANEL
    # =========================================================
    def build_right_panel(self, parent):
        parent.grid_rowconfigure(2, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        self.build_template_panel(parent)
        self.build_fixed_panel(parent)
        self.build_blocks_panel(parent)
        self.build_summary_panel(parent)

    def build_template_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=0, column=0, sticky="nsew", pady=(0, 8))

        tk.Label(frame, text="Template", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 4))

        row1 = tk.Frame(frame, bg=CARD)
        row1.pack(fill="x", padx=10, pady=(0, 8))

        tk.Label(row1, text="Template ID", bg=CARD, fg=TEXT, font=FONT).pack(side="left")
        self.template_id_var = tk.StringVar(value="1")
        tk.Entry(row1, textvariable=self.template_id_var, width=8, bg=CARD_2, fg=TEXT, insertbackground=TEXT, relief="flat").pack(side="left", padx=(8, 10))

        tk.Button(row1, text="NAČÍST", bg=BLUE, fg=BG, font=FONT_BOLD, relief="flat", command=self.load_template_from_db).pack(side="left", padx=(0, 6))
        tk.Button(row1, text="VYMAZAT LOKÁLNÍ", bg=CARD_2, fg=TEXT, font=FONT_SMALL, relief="flat", command=self.clear_local_state).pack(side="left")

        row2 = tk.Frame(frame, bg=CARD)
        row2.pack(fill="x", padx=10, pady=(0, 10))
        tk.Button(row2, text="ULOŽIT DO DB", bg=ACCENT, fg=BG, font=FONT_BOLD, relief="flat", command=self.save_template_to_db).pack(side="left", padx=(0, 8))
        tk.Button(row2, text="SMAZAT V DB", bg=RED, fg=BG, font=FONT_BOLD, relief="flat", command=self.delete_template_from_db).pack(side="left")

    def build_fixed_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=1, column=0, sticky="nsew", pady=(0, 8))

        tk.Label(frame, text="FIXED Picky", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 6))

        fixed_outer, _, self.fixed_inner = self.create_scrollable_vertical(frame, CARD)
        fixed_outer.pack(fill="both", expand=True, padx=10, pady=(0, 10))
        frame.configure(height=240)
        frame.pack_propagate(False)
        frame.grid_propagate(False)

    def build_blocks_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=2, column=0, sticky="nsew", pady=(0, 8))
        frame.grid_columnconfigure(0, weight=1)

        tk.Label(frame, text="VARIABLE Bloky", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 6))

        blocks_outer, _, self.blocks_inner = self.create_scrollable_vertical(frame, CARD)
        blocks_outer.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        self.block_wraps = {}
        for block_index in (1, 2, 3):
            box = tk.Frame(self.blocks_inner, bg=CARD_2, highlightthickness=1, highlightbackground=LINE)
            box.pack(fill="x", pady=(0, 8))

            top = tk.Frame(box, bg=CARD_2)
            top.pack(fill="x", padx=8, pady=(8, 6))

            tk.Label(top, text=f"Blok {self.block_label(block_index)}", bg=CARD_2, fg=YELLOW, font=FONT_BOLD).pack(side="left")
            tk.Label(top, text="(H2H only)", bg=CARD_2, fg=MUTED, font=FONT_SMALL).pack(side="left", padx=8)

            inner = tk.Frame(box, bg=CARD_2)
            inner.pack(fill="x", padx=8, pady=(0, 8))
            self.block_wraps[block_index] = inner

    def build_summary_panel(self, parent):
        frame = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        frame.grid(row=3, column=0, sticky="nsew")

        tk.Label(frame, text="Souhrn", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 6))

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
    # Market maps / sports
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
    # Data load
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

        old_selected = {name for name, var in self.league_vars.items() if var.get()}
        self.league_vars = {}

        if not self.league_rows:
            tk.Label(self.league_list_inner, text="Žádné soutěže pro filtr.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", pady=6)
            return

        for row in self.league_rows:
            league_name = row["league_name"]
            count = row["match_count"]
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
            self.visible_matches = [row for row in self.all_matches if str(row.get("league_name", "?")) in selected]
        self.render_match_rows()

    # =========================================================
    # Match grid render
    # =========================================================
    def render_match_rows(self):
        for widget in self.match_inner.winfo_children():
            widget.destroy()

        if not self.visible_matches:
            tk.Label(self.match_inner, text="Žádné zápasy pro vybrané soutěže.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", padx=10, pady=10)
            return

        for idx, row in enumerate(self.visible_matches):
            self.render_match_row(row, idx)

    def render_match_row(self, row: dict, row_index: int):
        bg_row = CARD if row_index % 2 == 0 else CARD_3
        wrap = tk.Frame(self.match_inner, bg=bg_row, width=self.grid_total_width, height=34, highlightthickness=1, highlightbackground=LINE)
        wrap.pack(fill="x", padx=2, pady=1)
        wrap.pack_propagate(False)

        dc_odds = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))

        values = [
            self.fmt_kickoff(row.get("kickoff")),
            str(row.get("league_name", "?")),
            str(row.get("home_team", "?")),
            str(row.get("away_team", "?")),
        ]

        x = 0
        for idx, (_, width, anchor) in enumerate(self.grid_columns[:4]):
            txt = values[idx]
            lbl = tk.Label(wrap, text=txt, bg=bg_row, fg=TEXT, font=FONT_GRID, anchor=anchor)
            lbl.place(x=x, y=0, width=width, height=32)
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
            lbl.place(x=x, y=0, width=width, height=32)
            x += width

        self.make_block_button(wrap, row, bg_row, x, 42, 1)
        x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 2)
        x += 42
        self.make_block_button(wrap, row, bg_row, x, 42, 3)

    def make_grid_pick_button(self, parent, row: dict, bg_row: str, x: int, width: int, market_code: str, outcome_code: str, odd_value):
        btn = tk.Button(
            parent,
            text=self.fmt_odds(odd_value),
            bg=CARD_2 if odd_value else bg_row,
            fg=TEXT if odd_value else MUTED,
            font=FONT_SMALL,
            relief="flat",
            state="normal" if odd_value else "disabled",
            command=lambda: self.add_fixed_pick(row, market_code, outcome_code, odd_value)
        )
        btn.place(x=x, y=3, width=width - 4, height=26)

    def make_block_button(self, parent: tk.Frame, row: dict, bg_row: str, x: int, width: int, block_index: int):
        btn = tk.Button(
            parent,
            text=self.block_label(block_index),
            bg=CARD_2,
            fg=TEXT,
            font=FONT_SMALL,
            relief="flat",
            command=lambda: self.add_to_block(row, block_index)
        )
        btn.place(x=x + 2, y=3, width=width - 4, height=26)

    # =========================================================
    # Ticket state
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

        self.fixed_items = [
            x for x in self.fixed_items
            if not (int(x["match_id"]) == int(item["match_id"]) and str(x["market_code"]) == str(item["market_code"]))
        ]

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

        self.fixed_items = [x for x in self.fixed_items if int(x["match_id"]) != int(item["match_id"])]

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
    # Right refresh
    # =========================================================
    def refresh_all_panels(self):
        self.refresh_fixed_panel()
        self.refresh_blocks_panel()
        self.refresh_summary()

    def refresh_fixed_panel(self):
        for widget in self.fixed_inner.winfo_children():
            widget.destroy()

        if not self.fixed_items:
            tk.Label(self.fixed_inner, text="Zatím žádné FIX picky.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", pady=4)
            return

        for idx, item in enumerate(self.fixed_items):
            row = tk.Frame(self.fixed_inner, bg=CARD_2, highlightthickness=1, highlightbackground=LINE)
            row.pack(fill="x", pady=4)

            left = tk.Frame(row, bg=CARD_2)
            left.pack(side="left", fill="both", expand=True, padx=8, pady=8)

            tk.Label(left, text=f"{item['home_team']} vs {item['away_team']}", bg=CARD_2, fg=TEXT, font=FONT_BOLD).pack(anchor="w")
            tk.Label(
                left,
                text=f"{item['league_name']} • {item['market_code']} • {item['outcome_code']} • kurz {self.fmt_odds(item['odd_value'])}",
                bg=CARD_2,
                fg=MUTED,
                font=FONT_SMALL
            ).pack(anchor="w")

            tk.Button(row, text="ODEBRAT", bg=RED, fg=BG, font=FONT_SMALL, relief="flat", command=lambda i=idx: self.remove_fixed_item(i)).pack(side="right", padx=8, pady=8)

    def refresh_blocks_panel(self):
        for block_index in (1, 2, 3):
            wrap = self.block_wraps[block_index]
            for widget in wrap.winfo_children():
                widget.destroy()

            items = self.block_items[block_index]
            if not items:
                tk.Label(wrap, text="prázdný blok", bg=CARD_2, fg=MUTED, font=FONT_SMALL).pack(anchor="w", pady=2)
                continue

            for idx, item in enumerate(items):
                row = tk.Frame(wrap, bg=CARD_3, highlightthickness=1, highlightbackground=LINE)
                row.pack(fill="x", pady=3)

                left = tk.Frame(row, bg=CARD_3)
                left.pack(side="left", fill="both", expand=True, padx=8, pady=6)

                tk.Label(left, text=f"{item['home_team']} vs {item['away_team']}", bg=CARD_3, fg=TEXT, font=FONT).pack(anchor="w")
                tk.Label(left, text=f"{item['league_name']} • blok {self.block_label(block_index)}", bg=CARD_3, fg=MUTED, font=FONT_SMALL).pack(anchor="w")

                tk.Button(row, text="ODEBRAT", bg=RED, fg=BG, font=FONT_SMALL, relief="flat", command=lambda bi=block_index, i=idx: self.remove_block_item(bi, i)).pack(side="right", padx=8, pady=6)

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
        raise Exception(f"Template ID {template_id} neexistuje v public.templates. Nejdřív vytvoř template hlavičku.")

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
                            (template_id, int(item["match_id"]), int(item["market_outcome_id"]), int(item["market_id"]))
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
                                (template_id, block_index, int(item["match_id"]), int(item["market_id"]))
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



class TicketStudioV25(TicketStudioV24):
    DESKTOP_BREAKPOINT = 1480
    TABLET_BREAKPOINT = 980
    GRID_BREAKPOINT = 1320

    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("MatchMatrix Ticket Studio V2.5")
        self.root.geometry("1600x980")
        self.root.minsize(360, 640)
        self.root.configure(bg=BG)

        self.market_ids: dict[str, int] = {}
        self.market_outcome_ids: dict[tuple[str, str], int] = {}

        self.all_matches: list[dict] = []
        self.visible_matches: list[dict] = []
        self.league_rows: list[dict] = []

        self.fixed_items: list[dict] = []
        self.block_items: dict[int, list[dict]] = {1: [], 2: [], 3: []}

        self.league_vars: dict[str, tk.BooleanVar] = {}
        self.current_layout_mode = "desktop"
        self.current_match_mode = "grid"
        self.resize_after_id = None

        self.build_ui()
        self.load_market_maps()
        self.load_sports()
        self.load_leagues_and_matches(initial=True)

        self.root.bind("<Configure>", self.on_root_resize)
        self.root.after(150, self.apply_initial_layout)

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=10)
        self.header.grid_columnconfigure(0, weight=1)

        title_wrap = tk.Frame(self.header, bg=BG)
        title_wrap.grid(row=0, column=0, sticky="w")

        tk.Label(
            title_wrap,
            text="MatchMatrix Ticket Studio V2.5",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE,
        ).pack(side="left")

        self.header_hint_var = tk.StringVar(value="adaptivní layout • desktop / tablet / mobile • kompaktní karty")
        tk.Label(
            self.header,
            textvariable=self.header_hint_var,
            bg=BG,
            fg=MUTED,
            font=FONT,
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="layout: desktop | zápasy: grid")
        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=YELLOW,
            font=FONT_SMALL,
        ).grid(row=0, column=1, sticky="e")

    def build_ui(self):
        self.build_header()

        self.outer = tk.Frame(self.root, bg=BG)
        self.outer.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        self.outer.grid_rowconfigure(0, weight=1)
        self.outer.grid_columnconfigure(0, weight=1)

        self.content = tk.Frame(self.outer, bg=BG)
        self.content.grid(row=0, column=0, sticky="nsew")

        self.left_section = tk.Frame(self.content, bg=BG)
        self.center_section = tk.Frame(self.content, bg=BG)
        self.right_section = tk.Frame(self.content, bg=BG)

        self.build_left_panel(self.left_section)
        self.build_center_panel(self.center_section)
        self.build_right_panel(self.right_section)

    def build_left_panel(self, parent):
        parent.grid_rowconfigure(0, weight=1)
        parent.grid_columnconfigure(0, weight=1)
        inner = tk.Frame(parent, bg=BG)
        inner.grid(row=0, column=0, sticky="nsew")
        super().build_left_panel(inner)

    def build_center_panel(self, parent):
        parent.grid_rowconfigure(1, weight=1)
        parent.grid_columnconfigure(0, weight=1)

        top = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        top.grid(row=0, column=0, sticky="nsew", pady=(0, 8))

        tk.Label(top, text="Nabídka zápasů", bg=CARD, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 4))
        self.center_hint_var = tk.StringVar(value="široké zobrazení: grid")
        tk.Label(
            top,
            textvariable=self.center_hint_var,
            bg=CARD,
            fg=MUTED,
            font=FONT_SMALL
        ).pack(anchor="w", padx=10, pady=(0, 10))

        self.grid_box = tk.Frame(parent, bg=CARD, highlightthickness=1, highlightbackground=LINE)
        self.grid_box.grid(row=1, column=0, sticky="nsew")
        self.grid_box.grid_rowconfigure(1, weight=1)
        self.grid_box.grid_columnconfigure(0, weight=1)

        self.grid_columns = [
            ("DATUM", 90, "w"),
            ("LIGA", 200, "w"),
            ("DOMÁCÍ", 180, "w"),
            ("HOSTÉ", 180, "w"),
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

        self.match_header = tk.Frame(self.grid_box, bg=CARD_2, width=self.grid_total_width)
        self.match_header.grid(row=0, column=0, sticky="ew")
        self.match_header.grid_propagate(False)
        self.build_match_header(self.match_header)

        body = tk.Frame(self.grid_box, bg=CARD)
        body.grid(row=1, column=0, sticky="nsew")
        body.grid_rowconfigure(0, weight=1)
        body.grid_columnconfigure(0, weight=1)

        self.match_canvas = tk.Canvas(body, bg=CARD, highlightthickness=0)
        self.match_scroll_y = tk.Scrollbar(body, orient="vertical", command=self.match_canvas.yview)
        self.match_scroll_x = tk.Scrollbar(self.grid_box, orient="horizontal", command=self.sync_x_scroll)

        self.match_inner = tk.Frame(self.match_canvas, bg=CARD, width=self.grid_total_width)
        self.match_inner.bind(
            "<Configure>",
            lambda e: self.match_canvas.configure(scrollregion=self.match_canvas.bbox("all"))
        )

        self.match_window = self.match_canvas.create_window((0, 0), window=self.match_inner, anchor="nw")
        self.match_canvas.configure(yscrollcommand=self.match_scroll_y.set, xscrollcommand=self.match_scroll_x.set)

        def on_canvas_resize(event):
            if self.current_match_mode == "grid":
                width = max(event.width, self.grid_total_width)
            else:
                width = max(event.width, 320)
            self.match_canvas.itemconfigure(self.match_window, width=width)
            self.match_header.configure(width=max(width, self.grid_total_width))

        self.match_canvas.bind("<Configure>", on_canvas_resize)

        self.match_canvas.grid(row=0, column=0, sticky="nsew")
        self.match_scroll_y.grid(row=0, column=1, sticky="ns")
        self.match_scroll_x.grid(row=2, column=0, sticky="ew")

    def build_right_panel(self, parent):
        parent.grid_rowconfigure(0, weight=1)
        parent.grid_columnconfigure(0, weight=1)
        inner = tk.Frame(parent, bg=BG)
        inner.grid(row=0, column=0, sticky="nsew")
        super().build_right_panel(inner)

    def apply_initial_layout(self):
        self._apply_responsive_state()

    def on_root_resize(self, event):
        if event.widget is not self.root:
            return
        if self.resize_after_id:
            try:
                self.root.after_cancel(self.resize_after_id)
            except Exception:
                pass
        self.resize_after_id = self.root.after(60, self._apply_responsive_state)

    def _apply_responsive_state(self):
        width = max(self.root.winfo_width(), 1)
        height = max(self.root.winfo_height(), 1)

        if width < self.TABLET_BREAKPOINT:
            target_layout = "mobile"
        elif width < self.DESKTOP_BREAKPOINT:
            target_layout = "tablet"
        else:
            target_layout = "desktop"

        target_match_mode = "cards" if width < self.GRID_BREAKPOINT else "grid"

        layout_changed = target_layout != self.current_layout_mode
        mode_changed = target_match_mode != self.current_match_mode

        if layout_changed:
            self.current_layout_mode = target_layout
            self.rebuild_responsive_layout()

        if mode_changed:
            self.current_match_mode = target_match_mode
            self.center_hint_var.set(
                "kompaktní zobrazení: karty" if target_match_mode == "cards" else "široké zobrazení: grid"
            )
            self.render_match_rows()

        self.header_hint_var.set(
            "adaptivní layout • desktop / tablet / mobile • kompaktní karty"
            if target_layout != "mobile"
            else "mobile režim • sekce pod sebou • bez pevného 3sloupcového rozložení"
        )
        self.viewport_var.set(f"layout: {self.current_layout_mode} | zápasy: {self.current_match_mode} | {width}x{height}")

    def rebuild_responsive_layout(self):
        for widget in (self.left_section, self.center_section, self.right_section):
            widget.grid_forget()

        for idx in range(3):
            self.content.grid_columnconfigure(idx, weight=0)
        for idx in range(3):
            self.content.grid_rowconfigure(idx, weight=0)

        if self.current_layout_mode == "desktop":
            self.content.grid_columnconfigure(0, weight=2, uniform="layout")
            self.content.grid_columnconfigure(1, weight=5, uniform="layout")
            self.content.grid_columnconfigure(2, weight=3, uniform="layout")
            self.content.grid_rowconfigure(0, weight=1)

            self.left_section.grid(row=0, column=0, sticky="nsew", padx=(0, 8))
            self.center_section.grid(row=0, column=1, sticky="nsew", padx=(0, 8))
            self.right_section.grid(row=0, column=2, sticky="nsew")
        elif self.current_layout_mode == "tablet":
            self.content.grid_columnconfigure(0, weight=2)
            self.content.grid_columnconfigure(1, weight=4)
            self.content.grid_rowconfigure(0, weight=3)
            self.content.grid_rowconfigure(1, weight=2)

            self.left_section.grid(row=0, column=0, sticky="nsew", padx=(0, 8), pady=(0, 8))
            self.center_section.grid(row=0, column=1, sticky="nsew", pady=(0, 8))
            self.right_section.grid(row=1, column=0, columnspan=2, sticky="nsew")
        else:
            self.content.grid_columnconfigure(0, weight=1)
            self.content.grid_rowconfigure(0, weight=0)
            self.content.grid_rowconfigure(1, weight=3)
            self.content.grid_rowconfigure(2, weight=2)

            self.left_section.grid(row=0, column=0, sticky="nsew", pady=(0, 8))
            self.center_section.grid(row=1, column=0, sticky="nsew", pady=(0, 8))
            self.right_section.grid(row=2, column=0, sticky="nsew")

    def render_match_rows(self):
        for widget in self.match_inner.winfo_children():
            widget.destroy()

        if self.current_match_mode == "grid":
            try:
                self.match_header.grid()
                self.match_scroll_x.grid()
            except Exception:
                pass
            self.match_inner.configure(width=self.grid_total_width)
        else:
            try:
                self.match_header.grid_remove()
                self.match_scroll_x.grid_remove()
            except Exception:
                pass
            self.match_inner.configure(width=max(self.match_canvas.winfo_width(), 320))

        if not self.visible_matches:
            tk.Label(self.match_inner, text="Žádné zápasy pro vybrané soutěže.", bg=CARD, fg=MUTED, font=FONT).pack(anchor="w", padx=10, pady=10)
            return

        for idx, row in enumerate(self.visible_matches):
            if self.current_match_mode == "grid":
                super().render_match_row(row, idx)
            else:
                self.render_match_card(row, idx)

    def render_match_card(self, row: dict, row_index: int):
        bg_row = CARD if row_index % 2 == 0 else CARD_3
        card = tk.Frame(self.match_inner, bg=bg_row, highlightthickness=1, highlightbackground=LINE)
        card.pack(fill="x", padx=8, pady=6)
        card.grid_columnconfigure(0, weight=1)

        top = tk.Frame(card, bg=bg_row)
        top.grid(row=0, column=0, sticky="ew", padx=10, pady=(10, 4))
        top.grid_columnconfigure(0, weight=1)

        tk.Label(top, text=f"{row.get('home_team', '?')} vs {row.get('away_team', '?')}", bg=bg_row, fg=TEXT, font=FONT_BOLD, anchor="w").grid(row=0, column=0, sticky="w")
        tk.Label(top, text=self.fmt_kickoff(row.get("kickoff")), bg=bg_row, fg=YELLOW, font=FONT_SMALL, anchor="e").grid(row=0, column=1, sticky="e")
        tk.Label(top, text=str(row.get("league_name", "?")), bg=bg_row, fg=MUTED, font=FONT_SMALL, anchor="w").grid(row=1, column=0, columnspan=2, sticky="w", pady=(2, 0))

        odds_wrap = tk.Frame(card, bg=bg_row)
        odds_wrap.grid(row=1, column=0, sticky="ew", padx=10, pady=(4, 4))
        for i in range(3):
            odds_wrap.grid_columnconfigure(i, weight=1)
        for i in range(3, 6):
            odds_wrap.grid_columnconfigure(i, weight=1)

        dc_odds = self.compute_double_chance_odds(row.get("odd_1"), row.get("odd_x"), row.get("odd_2"))
        primary = [("1", row.get("odd_1")), ("X", row.get("odd_x")), ("2", row.get("odd_2"))]
        secondary = [("1X", dc_odds["1X"]), ("12", dc_odds["12"]), ("X2", dc_odds["X2"])]

        for col, (code, odd_value) in enumerate(primary):
            box = tk.Frame(odds_wrap, bg=CARD_2 if odd_value else bg_row)
            box.grid(row=0, column=col, sticky="ew", padx=2, pady=2)
            tk.Label(box, text=code, bg=box["bg"], fg=YELLOW if odd_value else MUTED, font=FONT_SMALL).pack(pady=(4, 0))
            tk.Button(
                box,
                text=self.fmt_odds(odd_value),
                bg=CARD_2 if odd_value else bg_row,
                fg=TEXT if odd_value else MUTED,
                font=FONT_SMALL,
                relief="flat",
                state="normal" if odd_value else "disabled",
                command=lambda m=code, o=odd_value: self.add_fixed_pick(row, "H2H", m, o)
            ).pack(fill="x", padx=4, pady=(2, 4))

        for col, (code, odd_value) in enumerate(secondary):
            box = tk.Frame(odds_wrap, bg=CARD_2 if odd_value else bg_row)
            box.grid(row=1, column=col, sticky="ew", padx=2, pady=2)
            tk.Label(box, text=code, bg=box["bg"], fg=YELLOW if odd_value else MUTED, font=FONT_SMALL).pack(pady=(4, 0))
            tk.Button(
                box,
                text=self.fmt_odds(odd_value),
                bg=CARD_2 if odd_value else bg_row,
                fg=TEXT if odd_value else MUTED,
                font=FONT_SMALL,
                relief="flat",
                state="normal" if odd_value else "disabled",
                command=lambda m=code, o=odd_value: self.add_fixed_pick(row, "DC", m, o)
            ).pack(fill="x", padx=4, pady=(2, 4))

        info = tk.Frame(card, bg=bg_row)
        info.grid(row=2, column=0, sticky="ew", padx=10, pady=(2, 4))
        for col in range(4):
            info.grid_columnconfigure(col, weight=1)
        for col, label in enumerate(("Pred: —", "Forma: —", "Tab: —", "H2H: —")):
            tk.Label(info, text=label, bg=CARD_2, fg=MUTED, font=FONT_SMALL, padx=6, pady=6).grid(row=0, column=col, sticky="ew", padx=2, pady=2)

        actions = tk.Frame(card, bg=bg_row)
        actions.grid(row=3, column=0, sticky="ew", padx=10, pady=(2, 10))
        actions.grid_columnconfigure(0, weight=1)
        actions.grid_columnconfigure(1, weight=1)
        actions.grid_columnconfigure(2, weight=1)

        for col, block_index in enumerate((1, 2, 3)):
            tk.Button(
                actions,
                text=f"Blok {self.block_label(block_index)}",
                bg=CARD_2,
                fg=TEXT,
                font=FONT_SMALL,
                relief="flat",
                command=lambda bi=block_index: self.add_to_block(row, bi)
            ).grid(row=0, column=col, sticky="ew", padx=3)



def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass

    TicketStudioV25(root)
    root.mainloop()


if __name__ == "__main__":
    main()
