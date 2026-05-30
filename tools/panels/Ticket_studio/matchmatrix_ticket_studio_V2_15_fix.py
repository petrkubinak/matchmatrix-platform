from __future__ import annotations

import tkinter as tk
from tkinter import ttk

from matchmatrix_ticket_studio_V2_14 import TicketStudioV214
from matchmatrix_ticket_studio_V2_13 import GREEN_OK, YELLOW_WARN, RED_WARN, BLUE_INFO
from matchmatrix_ticket_studio_V2_7 import BG, TEXT, MUTED, ACCENT, FONT_TITLE_S, FONT_SMALL, FONT_BOLD, FONT_SECTION


class TicketStudioV215(TicketStudioV214):
    def __init__(self, root: tk.Tk):
        super().__init__(root)
        self.root.title("MatchMatrix Ticket Studio V2.15")
        self.viewport_var.set("desktop | compact right rail | smoother insights")

    def build_header(self):
        if not hasattr(self, "viewport_var"):
            self.viewport_var = tk.StringVar(value="desktop | compact right rail | smoother insights")

        self.header = tk.Frame(self.root, bg=BG)
        self.header.pack(fill="x", padx=8, pady=(8, 6))
        self.header.grid_columnconfigure(0, weight=1)

        tk.Label(
            self.header,
            text="MatchMatrix Ticket Studio V2.15",
            bg=BG,
            fg=TEXT,
            font=FONT_TITLE_S,
            anchor="w",
        ).grid(row=0, column=0, sticky="w")

        tk.Label(
            self.header,
            text="uhlazenější insight texty • lepší logika semaforu • grafické W/D/L značky",
            bg=BG,
            fg=MUTED,
            font=FONT_SMALL,
            anchor="w",
        ).grid(row=1, column=0, sticky="w", pady=(1, 0))

        tk.Label(
            self.header,
            textvariable=self.viewport_var,
            bg=BG,
            fg=ACCENT,
            font=FONT_SMALL,
            anchor="e",
        ).grid(row=0, column=1, rowspan=2, sticky="e")

    def _winner_signal(self, pred: dict | None) -> dict:
        if not pred:
            return {
                "label": "ŠEDÁ • bez predikce",
                "color": BLUE_INFO,
                "subtext": "Model zatím pro tento zápas nemá uloženou predikci, takže semafor ber jen orientačně podle trhu.",
            }

        vals = {
            "1": self._float(pred.get("p_home")),
            "X": self._float(pred.get("p_draw")),
            "2": self._float(pred.get("p_away")),
        }
        best_key = max(vals, key=vals.get)
        best = vals[best_key] or 0.0

        if best_key == "1":
            side_text = "domácí"
        elif best_key == "2":
            side_text = "hosté"
        else:
            side_text = "remíza"

        if best >= 0.58:
            return {
                "label": f"ZELENÁ • favorit: {side_text}",
                "color": GREEN_OK,
                "subtext": f"Model dává nejvyšší šanci variantě „{side_text}“ ({best*100:.1f} %). Zápas má čitelnějšího favorita.",
            }
        if best >= 0.45:
            return {
                "label": f"ŽLUTÁ • mírná výhoda: {side_text}",
                "color": YELLOW_WARN,
                "subtext": f"Nejvýš vychází varianta „{side_text}“ ({best*100:.1f} %), ale náskok ještě není úplně silný.",
            }
        return {
            "label": "ČERVENÁ • bez jasného favorita",
            "color": RED_WARN,
            "subtext": f"Nejvyšší pravděpodobnost je jen {best*100:.1f} %, takže zápas působí vyrovnaněji a je rizikovější.",
        }

    def _momentum_desc(self, value) -> str:
        v = self._float(value)
        if v is None:
            return "Momentum zatím nemá dost dat, takže trend formy nejde spolehlivě pojmenovat."
        if v >= 0.60:
            return "Tým je v silném rozjezdu a poslední období mu vychází opravdu dobře."
        if v >= 0.20:
            return "Forma jde nahoru a tým působí zdravěji než v předchozím období."
        if v <= -0.60:
            return "Tým je ve slabším období a výsledkově ztrácí jistotu i rytmus."
        if v <= -0.20:
            return "Forma lehce padá a tým nepůsobí úplně komfortně."
        return "Forma je spíš vyrovnaná, bez výrazného růstu nebo propadu."

    def _volatility_desc(self, value) -> str:
        v = self._float(value)
        if v is None:
            return "Volatilita zatím nemá dost dat, takže kolísání výkonu nejde dobře odhadnout."
        if v >= 1.20:
            return "Výkony hodně kolísají, takže zápas je hůř čitelný a nese vyšší riziko překvapení."
        if v >= 0.80:
            return "Tým umí zahrát velmi dobře i slabě, takže je potřeba počítat s výkyvem."
        if v >= 0.40:
            return "Výkonnost se mění běžně, ale pořád se dá relativně rozumně číst."
        return "Tým působí stabilně a jeho výkony mají menší rozptyl."

    def _result_badge(self, code: str | None) -> str:
        code = (code or "").upper()
        if code == "W":
            return "🟢 výhra"
        if code == "D":
            return "🟡 remíza"
        if code == "L":
            return "🔴 prohra"
        return "⚪ bez výsledku"

    def _h2h_badge(self, row: dict) -> str:
        try:
            hs = int(row.get("home_score"))
            aw = int(row.get("away_score"))
        except Exception:
            return "⚪"
        if hs > aw:
            return "🟢 domácí"
        if aw > hs:
            return "🔴 hosté"
        return "🟡 remíza"

    def _recent_lines(self, rows: list[dict]) -> list[str]:
        if not rows:
            return ["bez historie"]
        out = []
        for r in rows:
            badge = self._result_badge(r.get("result_code"))
            out.append(
                f"{badge} | {self.fmt_kickoff(r.get('kickoff'))} | {r.get('home_team')} {r.get('home_score')}:{r.get('away_score')} {r.get('away_team')}"
            )
        return out

    def _h2h_lines(self, rows: list[dict]) -> list[str]:
        if not rows:
            return ["bez H2H historie"]
        out = []
        for r in rows:
            badge = self._h2h_badge(r)
            out.append(
                f"{badge} | {self.fmt_kickoff(r.get('kickoff'))} | {r.get('home_team')} {r.get('home_score')}:{r.get('away_score')} {r.get('away_team')}"
            )
        return out

    def _team_summary(self, parent, team_name, rating_row, side="home", padx=10):
        box = tk.Frame(parent, bg="#1E1446")
        box.pack(fill="x", padx=padx, pady=(0, 8))
        tk.Label(box, text=team_name, bg="#1E1446", fg=TEXT, font=FONT_BOLD).pack(anchor="w", padx=10, pady=(8, 4))
        if not rating_row:
            tk.Label(
                box,
                text="Pro tento tým zatím nemám rating v mm_team_ratings.",
                bg="#1E1446",
                fg=MUTED,
                font=FONT_SMALL,
            ).pack(anchor="w", padx=10, pady=(0, 8))
            return

        side_rating = rating_row.get("rating_home") if side == "home" else rating_row.get("rating_away")
        line1 = f"Total rating: {self._num(rating_row.get('rating'))} | {side} rating: {self._num(side_rating)}"
        line2 = f"Momentum: {self._momentum_label(rating_row.get('momentum'))} | Volatilita: {self._volatility_label(rating_row.get('volatility'))}"
        line3 = self._team_plain_comment(rating_row)

        tk.Label(box, text=line1, bg="#1E1446", fg=TEXT, font=FONT_SMALL).pack(anchor="w", padx=10)
        tk.Label(box, text=line2, bg="#1E1446", fg=ACCENT, font=FONT_SMALL).pack(anchor="w", padx=10, pady=(2, 0))
        tk.Label(box, text=line3, bg="#1E1446", fg=TEXT, font=FONT_SMALL, wraplength=620, justify="left").pack(anchor="w", padx=10, pady=(4, 8))

    def _team_plain_comment(self, rating_row: dict) -> str:
        mom = self._momentum_desc(rating_row.get("momentum"))
        vol = self._volatility_desc(rating_row.get("volatility"))
        return f"Komentář: {mom} {vol}"

    def _quick_reading(self, detail, pred, home_rating, away_rating, recent_home, recent_away):
        sig = self._winner_signal(pred)
        home_form = self._form_summary(recent_home)
        away_form = self._form_summary(recent_away)

        home_line = self._team_quick_line(detail.get("home_team"), home_rating)
        away_line = self._team_quick_line(detail.get("away_team"), away_rating)

        return [
            f"Semafor zápasu: {sig['label']}. {sig['subtext']}",
            home_line,
            away_line,
            f"Aktuální forma: domácí {home_form}, hosté {away_form}. Tohle je rychlé čtení situace před sázkou bez nutnosti otevírat další vrstvy statistik.",
        ]

    def _team_quick_line(self, team_name: str, rating_row: dict | None) -> str:
        if not rating_row:
            return f"{team_name}: zatím bez detailních ratingových dat."
        mom_label = self._momentum_label(rating_row.get("momentum"))
        vol_label = self._volatility_label(rating_row.get("volatility"))
        mom_desc = self._momentum_desc(rating_row.get("momentum"))
        vol_desc = self._volatility_desc(rating_row.get("volatility"))
        return f"{team_name}: momentum {mom_label}, volatilita {vol_label}. {mom_desc} {vol_desc}"


def main():
    root = tk.Tk()
    style = ttk.Style()
    try:
        style.theme_use("clam")
    except Exception:
        pass
    TicketStudioV215(root)
    root.mainloop()


if __name__ == "__main__":
    main()
