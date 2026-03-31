from __future__ import annotations

import tkinter as tk
from tkinter import ttk
from decimal import Decimal

from matchmatrix_ticket_studio_V2_12 import TicketStudioV212
from matchmatrix_ticket_studio_V2_7 import *
from matchmatrix_ticket_studio_V2_9 import BET_PANEL, BET_PANEL_2, BET_PANEL_3, BET_LINE, BET_SOFT


GREEN_OK = "#39D353"
YELLOW_WARN = "#F2C94C"
RED_WARN = "#FF6B6B"
BLUE_INFO = "#4DA3FF"
CARD_EDGE = "#3A2C79"


class TicketStudioV213(TicketStudioV212):
    def __init__(self, root: tk.Tk):
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.13")
        self.viewport_var.set("desktop | insights semafor | momentum + volatility text")

    def build_header(self):
        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=10, pady=(10, 8))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.13",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="semafor vítězství • lidský popis momentum/volatility • lepší insight detail",
            bg=BG,
            fg=MUTED,
            font=FONT,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(2, 0))

        self.viewport_var = tk.StringVar(value="desktop | semafor insights")
        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=ACCENT,
            font=FONT_SMALL,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

    def show_match_insights(self, row: dict):
        match_id = int(row.get("match_id"))
        detail = self.fetchone(
            """
            SELECT
                m.id AS match_id,
                m.league_id,
                m.home_team_id,
                m.away_team_id,
                m.kickoff,
                m.status,
                l.name AS league_name,
                ht.name AS home_team,
                at.name AS away_team
            FROM public.matches m
            LEFT JOIN public.leagues l ON l.id = m.league_id
            LEFT JOIN public.teams ht ON ht.id = m.home_team_id
            LEFT JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.id = %s
            """,
            (match_id,),
        )
        if not detail:
            messagebox.showerror("Detail zápasu", f"Nepodařilo se načíst detail pro match_id={match_id}.")
            return

        pred = self.fetchone(
            """
            SELECT model_code, p_home, p_draw, p_away, run_ts
            FROM public.ml_predictions
            WHERE match_id = %s
            ORDER BY run_ts DESC, id DESC
            LIMIT 1
            """,
            (match_id,),
        )

        ratings = self.fetchall(
            """
            SELECT team_id, rating, rating_home, rating_away, momentum, volatility
            FROM public.mm_team_ratings
            WHERE league_id = %s AND team_id IN (%s, %s)
            ORDER BY team_id
            """,
            (detail["league_id"], detail["home_team_id"], detail["away_team_id"]),
        )
        ratings_map = {int(r["team_id"]): r for r in ratings}
        home_rating = ratings_map.get(int(detail["home_team_id"]), {})
        away_rating = ratings_map.get(int(detail["away_team_id"]), {})

        h2h = self.fetchall(
            """
            SELECT
                m.kickoff,
                ht.name AS home_team,
                at.name AS away_team,
                m.home_score,
                m.away_score
            FROM public.matches m
            JOIN public.teams ht ON ht.id = m.home_team_id
            JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.status = 'FINISHED'
              AND ((m.home_team_id = %s AND m.away_team_id = %s)
                OR (m.home_team_id = %s AND m.away_team_id = %s))
            ORDER BY m.kickoff DESC
            LIMIT 5
            """,
            (detail["home_team_id"], detail["away_team_id"], detail["away_team_id"], detail["home_team_id"]),
        )

        recent_home = self.fetchall(
            """
            SELECT m.kickoff, ht.name AS home_team, at.name AS away_team, m.home_score, m.away_score,
                   CASE
                     WHEN m.home_team_id = %s AND m.home_score > m.away_score THEN 'W'
                     WHEN m.away_team_id = %s AND m.away_score > m.home_score THEN 'W'
                     WHEN m.home_score = m.away_score THEN 'D'
                     ELSE 'L'
                   END AS result_code
            FROM public.matches m
            JOIN public.teams ht ON ht.id = m.home_team_id
            JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.status = 'FINISHED'
              AND (%s IN (m.home_team_id, m.away_team_id))
            ORDER BY m.kickoff DESC
            LIMIT 5
            """,
            (detail["home_team_id"], detail["home_team_id"], detail["home_team_id"]),
        )

        recent_away = self.fetchall(
            """
            SELECT m.kickoff, ht.name AS home_team, at.name AS away_team, m.home_score, m.away_score,
                   CASE
                     WHEN m.home_team_id = %s AND m.home_score > m.away_score THEN 'W'
                     WHEN m.away_team_id = %s AND m.away_score > m.home_score THEN 'W'
                     WHEN m.home_score = m.away_score THEN 'D'
                     ELSE 'L'
                   END AS result_code
            FROM public.matches m
            JOIN public.teams ht ON ht.id = m.home_team_id
            JOIN public.teams at ON at.id = m.away_team_id
            WHERE m.status = 'FINISHED'
              AND (%s IN (m.home_team_id, m.away_team_id))
            ORDER BY m.kickoff DESC
            LIMIT 5
            """,
            (detail["away_team_id"], detail["away_team_id"], detail["away_team_id"]),
        )

        signal = self._winner_signal(pred)
        home_momentum = home_rating.get("momentum")
        away_momentum = away_rating.get("momentum")
        home_vol = home_rating.get("volatility")
        away_vol = away_rating.get("volatility")

        win = tk.Toplevel(self.root)
        win.title(f"Detail zápasu | {detail.get('home_team')} vs {detail.get('away_team')}")
        win.configure(bg=BG)
        win.geometry("1120x820")
        win.minsize(880, 640)

        outer = tk.Frame(win, bg=BG)
        outer.pack(fill="both", expand=True, padx=12, pady=12)
        outer.grid_columnconfigure(0, weight=1)
        outer.grid_rowconfigure(2, weight=1)

        head = tk.Frame(outer, bg=BG)
        head.grid(row=0, column=0, sticky="ew", pady=(0, 10))
        head.grid_columnconfigure(0, weight=1)
        tk.Label(head, text=f"{detail.get('home_team')} vs {detail.get('away_team')}", bg=BG, fg=TEXT, font=FONT_SECTION).grid(row=0, column=0, sticky="w")
        tk.Label(head, text=f"{detail.get('league_name')} • {self.fmt_kickoff(detail.get('kickoff'))} • {detail.get('status')}", bg=BG, fg=MUTED, font=FONT_SMALL).grid(row=1, column=0, sticky="w", pady=(2, 0))
        tk.Label(head, text=f"model: {pred.get('model_code') if pred else '-'}", bg=BET_PANEL_2, fg=ACCENT, font=FONT_SMALL, padx=8, pady=4).grid(row=0, column=1, rowspan=2, sticky="e")

        top = tk.Frame(outer, bg=BG)
        top.grid(row=1, column=0, sticky="ew", pady=(0, 10))
        for c in range(3):
            top.grid_columnconfigure(c, weight=1)

        self._metric_card(top, 0, "Semafor vítězství", signal["label"], signal["color"], signal["subtext"])
        self._metric_card(top, 1, f"Momentum: {detail.get('home_team')}", self._momentum_label(home_momentum), self._momentum_color(home_momentum), self._momentum_desc(home_momentum))
        self._metric_card(top, 2, f"Momentum: {detail.get('away_team')}", self._momentum_label(away_momentum), self._momentum_color(away_momentum), self._momentum_desc(away_momentum))

        middle = tk.Frame(outer, bg=BG)
        middle.grid(row=2, column=0, sticky="nsew")
        middle.grid_columnconfigure(0, weight=3)
        middle.grid_columnconfigure(1, weight=2)
        middle.grid_rowconfigure(0, weight=1)

        left = tk.Frame(middle, bg=BG)
        left.grid(row=0, column=0, sticky="nsew", padx=(0, 8))
        left.grid_columnconfigure(0, weight=1)

        probs = tk.Frame(left, bg=BET_PANEL, highlightthickness=1, highlightbackground=CARD_EDGE)
        probs.pack(fill="x", pady=(0, 8))
        tk.Label(probs, text="Predikce a trh", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 8))

        pwrap = tk.Frame(probs, bg=BET_PANEL)
        pwrap.pack(fill="x", padx=10, pady=(0, 10))
        for c in range(3):
            pwrap.grid_columnconfigure(c, weight=1)
        self._prob_box(pwrap, 0, "1", self._pct(pred.get("p_home")) if pred else "-", self.fmt_odds(row.get("odd_1")))
        self._prob_box(pwrap, 1, "X", self._pct(pred.get("p_draw")) if pred else "-", self.fmt_odds(row.get("odd_x")))
        self._prob_box(pwrap, 2, "2", self._pct(pred.get("p_away")) if pred else "-", self.fmt_odds(row.get("odd_2")))

        teamwrap = tk.Frame(left, bg=BET_PANEL, highlightthickness=1, highlightbackground=CARD_EDGE)
        teamwrap.pack(fill="x", pady=(0, 8))
        tk.Label(teamwrap, text="Síla týmů a lidský komentář", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 8))
        self._team_summary(teamwrap, detail.get("home_team"), home_rating, side="home", padx=10)
        self._team_summary(teamwrap, detail.get("away_team"), away_rating, side="away", padx=10)

        formwrap = tk.Frame(left, bg=BET_PANEL, highlightthickness=1, highlightbackground=CARD_EDGE)
        formwrap.pack(fill="both", expand=True)
        tk.Label(formwrap, text="Forma a H2H", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 8))
        self._list_block(formwrap, f"Forma domácí ({self._form_summary(recent_home)})", self._recent_lines(recent_home), padx=10)
        self._list_block(formwrap, f"Forma hosté ({self._form_summary(recent_away)})", self._recent_lines(recent_away), padx=10)
        self._list_block(formwrap, "Vzájemné zápasy H2H", self._h2h_lines(h2h), padx=10, pady=(0, 10))

        right = tk.Frame(middle, bg=BG)
        right.grid(row=0, column=1, sticky="nsew")
        right.grid_columnconfigure(0, weight=1)

        volwrap = tk.Frame(right, bg=BET_PANEL, highlightthickness=1, highlightbackground=CARD_EDGE)
        volwrap.pack(fill="x", pady=(0, 8))
        tk.Label(volwrap, text="Volatilita", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 8))
        self._metric_card_inner(volwrap, f"{detail.get('home_team')}", self._volatility_label(home_vol), self._volatility_color(home_vol), self._volatility_desc(home_vol))
        self._metric_card_inner(volwrap, f"{detail.get('away_team')}", self._volatility_label(away_vol), self._volatility_color(away_vol), self._volatility_desc(away_vol), pady=(0, 10))

        notes = tk.Frame(right, bg=BET_PANEL, highlightthickness=1, highlightbackground=CARD_EDGE)
        notes.pack(fill="both", expand=True)
        tk.Label(notes, text="Rychlé čtení", bg=BET_PANEL, fg=TEXT, font=FONT_SECTION).pack(anchor="w", padx=10, pady=(10, 8))
        summary_lines = self._quick_reading(detail, pred, home_rating, away_rating, recent_home, recent_away)
        text = tk.Text(notes, bg=BET_PANEL_2, fg=TEXT, insertbackground=TEXT, wrap="word", relief="flat", font=("Segoe UI", 10), height=18)
        text.pack(fill="both", expand=True, padx=10, pady=(0, 10))
        text.insert("1.0", "\n\n".join(summary_lines))
        text.configure(state="disabled")

    def _metric_card(self, parent, col, title, value, color, subtext):
        frame = tk.Frame(parent, bg=BET_PANEL, highlightthickness=1, highlightbackground=CARD_EDGE)
        frame.grid(row=0, column=col, sticky="ew", padx=(0 if col == 0 else 4, 0 if col == 2 else 4))
        tk.Label(frame, text=title, bg=BET_PANEL, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(10, 4))
        tk.Label(frame, text=value, bg=BET_PANEL_2, fg=color, font=FONT_BOLD, padx=10, pady=6).pack(anchor="w", padx=10)
        tk.Label(frame, text=subtext, bg=BET_PANEL, fg=TEXT, font=FONT_SMALL, wraplength=280, justify="left").pack(anchor="w", padx=10, pady=(8, 10))

    def _metric_card_inner(self, parent, title, value, color, subtext, pady=(0, 8)):
        box = tk.Frame(parent, bg=BET_PANEL_2)
        box.pack(fill="x", padx=10, pady=pady)
        tk.Label(box, text=title, bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(8, 3))
        tk.Label(box, text=value, bg=BET_PANEL_2, fg=color, font=FONT_BOLD).pack(anchor="w", padx=10)
        tk.Label(box, text=subtext, bg=BET_PANEL_2, fg=TEXT, font=FONT_SMALL, wraplength=320, justify="left").pack(anchor="w", padx=10, pady=(6, 8))

    def _prob_box(self, parent, col, label, prob, odd):
        box = tk.Frame(parent, bg=BET_PANEL_2)
        box.grid(row=0, column=col, sticky="ew", padx=(0 if col == 0 else 4, 0 if col == 2 else 4))
        tk.Label(box, text=label, bg=BET_PANEL_2, fg=ACCENT, font=("Segoe UI", 12, "bold")).pack(anchor="w", padx=10, pady=(8, 2))
        tk.Label(box, text=f"Predikce: {prob}", bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD).pack(anchor="w", padx=10)
        tk.Label(box, text=f"Kurz: {odd}", bg=BET_PANEL_2, fg=BET_SOFT, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(2, 8))

    def _team_summary(self, parent, team_name, rating_row, side="home", padx=10):
        box = tk.Frame(parent, bg=BET_PANEL_2)
        box.pack(fill="x", padx=padx, pady=(0, 8))
        tk.Label(box, text=team_name, bg=BET_PANEL_2, fg=TEXT, font=FONT_BOLD).pack(anchor="w", padx=10, pady=(8, 4))
        if not rating_row:
            tk.Label(box, text="Rating zatím není k dispozici v mm_team_ratings.", bg=BET_PANEL_2, fg=MUTED, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(0, 8))
            return
        side_rating = rating_row.get("rating_home") if side == "home" else rating_row.get("rating_away")
        line1 = f"Total rating: {self._num(rating_row.get('rating'))} | {side} rating: {self._num(side_rating)}"
        line2 = f"Momentum: {self._momentum_label(rating_row.get('momentum'))} | Volatilita: {self._volatility_label(rating_row.get('volatility'))}"
        line3 = f"Komentář: {self._momentum_desc(rating_row.get('momentum'))} {self._volatility_desc(rating_row.get('volatility'))}"
        tk.Label(box, text=line1, bg=BET_PANEL_2, fg=TEXT, font=FONT_SMALL).pack(anchor="w", padx=10)
        tk.Label(box, text=line2, bg=BET_PANEL_2, fg=ACCENT, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(2, 0))
        tk.Label(box, text=line3, bg=BET_PANEL_2, fg=TEXT, font=FONT_SMALL, wraplength=620, justify="left").pack(anchor="w", padx=10, pady=(4, 8))

    def _list_block(self, parent, title, lines, padx=10, pady=(0, 8)):
        tk.Label(parent, text=title, bg=BET_PANEL, fg=ACCENT, font=FONT_BOLD).pack(anchor="w", padx=padx, pady=(0, 4))
        for line in lines:
            tk.Label(parent, text=line, bg=BET_PANEL, fg=TEXT, font=FONT_SMALL, anchor="w", justify="left", wraplength=620).pack(anchor="w", padx=padx, pady=(0, 2))
        if pady != (0, 8):
            tk.Frame(parent, bg=BET_PANEL, height=pady[1]).pack(fill="x")

    def _winner_signal(self, pred: dict | None) -> dict:
        if not pred:
            return {
                "label": "ŠEDÁ ZÓNA",
                "color": BLUE_INFO,
                "subtext": "Predikce zatím není v DB, proto semafor nelze spolehlivě vyhodnotit.",
            }
        vals = {
            "1": self._float(pred.get("p_home")),
            "X": self._float(pred.get("p_draw")),
            "2": self._float(pred.get("p_away")),
        }
        best_key = max(vals, key=vals.get)
        best = vals[best_key]
        if best >= 0.58:
            zone = "ZELENÁ"
            color = GREEN_OK
            strength = "silný favorit"
        elif best >= 0.45:
            zone = "ŽLUTÁ"
            color = YELLOW_WARN
            strength = "mírná výhoda"
        else:
            zone = "ČERVENÁ"
            color = RED_WARN
            strength = "vyrovnané a rizikovější"
        side = {"1": "domácí", "X": "remíza", "2": "hosté"}[best_key]
        return {
            "label": f"{zone} • {side}",
            "color": color,
            "subtext": f"Nejvyšší modelová pravděpodobnost má {side} ({best*100:.1f} %), tedy {strength} scénář.",
        }

    def _momentum_label(self, value) -> str:
        v = self._float(value)
        if v is None:
            return "bez dat"
        if v >= 0.60:
            return "výrazně rostoucí"
        if v >= 0.20:
            return "lehce rostoucí"
        if v <= -0.60:
            return "výrazně klesající"
        if v <= -0.20:
            return "lehce klesající"
        return "stabilní"

    def _momentum_desc(self, value) -> str:
        v = self._float(value)
        if v is None:
            return "Momentum zatím nemá data, takže trend formy nejde spolehlivě přečíst."
        if v >= 0.60:
            return "Tým je ve velmi dobrém trendu a poslední období mu vychází nadprůměrně dobře."
        if v >= 0.20:
            return "Tým má pozitivní trend, ale ještě nejde o úplně dominantní rozjezd."
        if v <= -0.60:
            return "Tým je v negativní vlně a forma je momentálně slabší."
        if v <= -0.20:
            return "Tým lehce ztrácí tempo a výsledkově není úplně stabilní."
        return "Tým působí vyrovnaně bez výrazného růstu nebo propadu formy."

    def _momentum_color(self, value) -> str:
        v = self._float(value)
        if v is None:
            return BLUE_INFO
        if v >= 0.20:
            return GREEN_OK
        if v <= -0.20:
            return RED_WARN
        return YELLOW_WARN

    def _volatility_label(self, value) -> str:
        v = self._float(value)
        if v is None:
            return "bez dat"
        if v >= 1.20:
            return "velmi vysoká"
        if v >= 0.80:
            return "vyšší"
        if v >= 0.40:
            return "střední"
        return "nízká"

    def _volatility_desc(self, value) -> str:
        v = self._float(value)
        if v is None:
            return "Volatilita zatím nemá data, takže kolísání výkonu nelze vyhodnotit."
        if v >= 1.20:
            return "Výkony týmu výrazně kolísají, takže zápas je méně čitelný a rizikovější."
        if v >= 0.80:
            return "Tým umí zahrát velmi dobře i slabě, proto je potřeba počítat s výkyvem."
        if v >= 0.40:
            return "Výkon týmu je běžně proměnlivý, ale pořád relativně čitelný."
        return "Tým působí stabilně a jeho výkony mají menší rozptyl."

    def _volatility_color(self, value) -> str:
        v = self._float(value)
        if v is None:
            return BLUE_INFO
        if v >= 0.80:
            return RED_WARN
        if v >= 0.40:
            return YELLOW_WARN
        return GREEN_OK

    def _form_summary(self, rows: list[dict]) -> str:
        if not rows:
            return "bez historie"
        pts = 0
        for r in rows:
            code = r.get("result_code")
            if code == "W":
                pts += 3
            elif code == "D":
                pts += 1
        return f"{pts} bodů / {len(rows)} záp." if rows else "bez historie"

    def _quick_reading(self, detail, pred, home_rating, away_rating, recent_home, recent_away):
        out = []
        sig = self._winner_signal(pred)
        out.append(f"Semafor: {sig['label']}. {sig['subtext']}")

        home_m = self._momentum_desc(home_rating.get("momentum") if home_rating else None)
        away_m = self._momentum_desc(away_rating.get("momentum") if away_rating else None)
        out.append(f"Momentum domácích: {home_m}\nMomentum hostů: {away_m}")

        home_v = self._volatility_desc(home_rating.get("volatility") if home_rating else None)
        away_v = self._volatility_desc(away_rating.get("volatility") if away_rating else None)
        out.append(f"Volatilita domácích: {home_v}\nVolatilita hostů: {away_v}")

        out.append(
            f"Forma domácí: {self._form_summary(recent_home)}. Forma hosté: {self._form_summary(recent_away)}. "
            f"Tohle je rychlé čtení aktuálního rozpoložení bez nutnosti otevírat další statistiky."
        )
        return out

    def _float(self, value):
        try:
            return float(value)
        except Exception:
            return None


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV213(root)
    root.mainloop()


if __name__ == "__main__":
    main()
