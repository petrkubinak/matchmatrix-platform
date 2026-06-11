"""
MATCHMATRIX CONTROL PANEL V17.11.11
========================================================

INTERNÍ ORCHESTRATION OPERATIONS CENTER
(ČESKÁ ADMIN VERZE)

CO TO JE:
- Interní admin panel MatchMatrix.
- Runtime governance dashboard.
- Scheduler operations center.

CO ZOBRAZUJE:
- Stav systému
- Frontu ke spuštění
- Plánovač
- Upozornění
- Poslední chyby
- Aktivní běhy



POUZE PRO INTERNÍ POUŽITÍ.

V17.11.11:
- zjemněný fialový vzhled,
- klidnější tabulky,
- méně agresivní kontrasty,
- důležité chyby zůstávají viditelné.
"""

import os
import queue
import threading
import subprocess
from datetime import datetime

import tkinter as tk
from tkinter import ttk, messagebox

import psycopg2
import psycopg2.extras

# =========================================================
# CONFIG
# =========================================================

BASE_DIR = r"C:\MatchMatrix-platform"
PYTHON_EXE = r"C:\Python314\python.exe"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

REFRESH_MS = 8000

WORKER_COMMANDS = {
    "CORE_INGEST_V3": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "run_ingest_cycle_v3.py"),
        "--limit", "10",
    ],
    "PEOPLE_PIPELINE_V22": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "run_people_pipeline_v22_from_planner.py"),
        "--limit", "10",
    ],
    "AUTONOMOUS_RANKED_DISPATCH": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "ops", "110_N_autonomous_dispatch_launcher_v1.py"),
    ],
    # V17.11.07: přeneseno z panelu V11 - rychlé spuštění providerů.
    "THEODDS_REFRESH": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "run_theodds_ingest_v3.py"),
    ],
    "FOOTBALL_DATA_REFRESH": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "run_football_data_ingest_v1.py"),
    ],
}

# V17.11.12: jemnější Mission Control vzhled + grafické KPI karty.
# Cíl: méně křiklavé KPI, důležité stavy zvýraznit graficky místo velké barevné plochy.


# =========================================================
# BARVY
# =========================================================

BG = "#08050d"
PANEL = "#15101d"
PANEL_2 = "#1b1226"
CARD_BG = "#171020"
CARD_BORDER = "#352447"
CARD_BORDER_SOFT = "#251a31"

PURPLE = "#9b6ee8"
PINK = "#d75df2"

GREEN = "#35d07f"
YELLOW = "#e6a93a"
RED = "#e45b72"

MUTED = "#a995bd"
TEXT = "#f4ecff"

# =========================================================
# ČESKÉ POPISKY PRO INTERNÍ OPS PANEL
# =========================================================

TAB_LABELS = {
    "DASHBOARD": "PŘEHLED",
    "SCHEDULER": "PLÁNOVAČ",
    "WORKERS": "WORKERY",
    "ACTIVE RUNS": "AKTIVNÍ BĚHY",
    "PAYLOADS": "PAYLOADY",
    "LOGS": "LOGY",
    "FIX TASKS": "OPRAVY",
    "AI OPS": "AI OPS",
    "ROADMAP": "ROADMAPA",
    "PEOPLE PIPELINE": "PEOPLE",
    "HARVEST": "HARVEST",
    "ODDS": "KURZY",
    "PROVIDERS": "PROVIDEŘI",
}

STATUS_LABELS = {
    "READY": "PŘIPRAVEN",
    "PARTIAL": "ČÁSTEČNĚ",
    "READY_FOR_MERGE": "PŘIPRAVENO K MERGE",
    "RAW_PENDING_PARSE": "RAW ČEKÁ NA PARSER",
    "HAS_ERRORS": "MÁ CHYBY",
    "DATA_GAP": "DATA GAP",
    "WARNING": "VAROVÁNÍ",
    "CRITICAL": "AKTIVNÍ UPOZORNĚNÍ",
    "HEALTHY": "ZDRAVÝ",
    "HIGH": "VYSOKÉ",
    "LOW": "NÍZKÉ",
    "MEDIUM": "STŘEDNÍ",
    "STABLE": "STABILNÍ",
    "ELITE": "ELITNÍ",
    "BUSY": "ZANEPRÁZDNĚNÝ",
    "RUN": "SPUSTIT",
    "RUN_SAFE": "BEZPEČNÉ SPUŠTĚNÍ",
    "RUN_WITH_CAUTION": "SPUSTIT OPATRNĚ",
    "BLOCK": "BLOKOVAT",
    "WAIT": "POČKAT",
    "SMOKE_TEST": "TEST FUNKČNOSTI",
    "PLANNED_ONLY": "POUZE PLÁN",
    "PENDING": "ČEKÁ",
    "DONE": "HOTOVO",
    "FAILED": "CHYBA",
    "ERROR": "CHYBA",
    "OPEN": "OTEVŘENÉ",
    "FIXED": "OPRAVENÉ",
    "IGNORED": "IGNOROVANÉ",
    "ON_HOLD": "POZASTAVENO",
    "NORMAL": "NORMÁLNÍ",
    "NORMAL_EXECUTION": "BĚŽNÉ SPUŠTĚNÍ",
    "LIMITED_EXECUTION": "OMEZENÉ SPUŠTĚNÍ",
    "DISABLE_PROVIDER": "VYPNOUT PROVIDERA",
    "COOLDOWN": "COOLDOWN",
    "RUN_SMOKE_TEST": "SPUSTIT TEST",
    "WAIT_FOR_IMPLEMENTATION": "ČEKÁ NA IMPLEMENTACI",
    "SIMULATED_EXECUTION_OK": "SIMULACE OK",
    "NO_RECENT_RUNTIME": "BEZ ČERSTVÉHO BĚHU",
    "HAS_RUNTIME": "MÁ RUNTIME",
    "REGISTERED_READY_NO_RUNTIME": "PŘIPRAVEN BEZ RUNTIME",
    "REGISTERED_PLANNED": "REGISTROVÁNO / PLÁN",
    "PLANNED": "PLÁNOVÁNO",
    "NOT_IMPLEMENTED_YET": "NENÍ IMPLEMENTOVÁNO",
    "WAIT_FOR_PAID_PLAN": "ČEKÁ NA PRO",
    "IMPLEMENTATION_REQUIRED": "VÝVOJ",
    "PAID_PLAN_REQUIRED": "ČEKÁ NA PRO",
    "COMPLETED": "HOTOVO",
    "READY_FOR_MERGE": "PŘIPRAVENO K MERGE",
    "RAW_PENDING_PARSE": "RAW ČEKÁ NA PARSER",
    "HAS_ERRORS": "OBSAHUJE CHYBY",
    "DATA_GAP": "CHYBÍ DATA",
}

COLUMN_LABELS = {
    "id": "ID",
    "action_id": "ID akce",
    "provider": "Provider",
    "sport_code": "Sport",
    "entity_type": "Entita",
    "entity": "Entita",
    "endpoint_name": "Endpoint",
    "external_id": "Externí ID",
    "season": "Sezóna",
    "parse_status": "Stav parsování",
    "parse_message": "Zpráva parsování",
    "payload_json": "Payload JSON",
    "created_at": "Vytvořeno",
    "updated_at": "Upraveno",
    "fetched_at": "Staženo",
    "last_payload_at": "Poslední payload",
    "generated_at": "Vygenerováno",
    "started_at": "Start",
    "finished_at": "Konec",
    "execution_started_at": "Start akce",
    "execution_finished_at": "Konec akce",
    "event_time": "Čas události",
    "last_alert_time": "Čas posledního upozornění",
    "provider_health_score": "Skóre zdraví",
    "provider_health_status": "Stav providera",
    "provider_presence_status": "Runtime stav",
    "risk_score": "Riziko",
    "execution_decision": "Rozhodnutí",
    "recommended_cooldown_seconds": "Cooldown [s]",
    "coverage_entities": "Pokryté entity",
    "ready_entities": "Připravené entity",
    "blocked_entities": "Blokované entity",
    "planned_entities": "Plánované entity",
    "total_payloads": "Payloady celkem",
    "ai_alert_severity": "Závažnost",
    "ai_alert_message": "AI zpráva",
    "recommended_action": "Doporučený krok",
    "recommendation_reason": "Důvod doporučení",
    "scheduler_priority": "Priorita scheduleru",
    "action_status": "Stav akce",
    "action_type": "Typ akce",
    "execution_result": "Výsledek",
    "orchestration_layer": "Vrstva",
    "scheduler_state": "Stav scheduleru",
    "rows_count": "Počet řádků",
    "runtime_ready_count": "Runtime ready",
    "scheduler_ready_count": "Scheduler ready",
    "panel_ready_count": "Panel ready",
    "ready_pct": "Ready %",
    "run_next_rank": "Pořadí",
    "worker_code": "Worker",
    "retry_policy": "Retry politika",
    "final_priority_score": "Priorita",
    "alert_type": "Typ upozornění",
    "source_object": "Zdroj",
    "alert_severity": "Závažnost",
    "alert_count": "Počet",
    "last_alert_message": "Poslední zpráva",
    "feed_type": "Typ feedu",
    "object_name": "Objekt",
    "severity": "Závažnost",
    "message": "Zpráva",
    "execution_confidence_score": "Důvěra spuštění",
    "scheduler_health_tier": "Zdraví scheduleru",
    "recent_health_tier": "Nedávné zdraví",
    "dashboard_state": "Stav dashboardu",
    "autonomous_safe": "Autonomně bezpečné",
    "league_id": "Liga ID",
    "empty_runs": "Prázdné běhy",
    "empty_pct": "Prázdné %",
    "planner_target_state": "Stav cíle",
    "suggested_retry_after": "Retry po",
    "suggested_action": "Doporučení",
    "lock_name": "Zámek",
    "owner_id": "Vlastník",
    "acquired_at": "Získáno",
    "heartbeat_at": "Heartbeat",
    "running_seconds": "Běží [s]",
    "heartbeat_age_seconds": "Stáří heartbeat [s]",
    "seconds_to_expire": "Expirace [s]",
    "live_state": "Live stav",
    "live_color": "Barva",
    "note": "Poznámka",
    "is_active": "Aktivní",
    "pending_rows": "Čekající řádky",
    "payload_count": "Počet payloadů",
    "job_code": "Job",
    "status": "Stav",
    "rows_affected": "Řádky",
    "duration_sec": "Doba [s]",
    "details": "Detail",
    "params": "Parametry",
    "priority_level": "Priorita",
    "priority_score": "Skóre priority",
    "suggested_fix": "Navržená oprava",
    "task_status": "Stav úkolu",
    "source_payload_id": "Payload ID",
    "short_message": "Krátká zpráva",
    "full_message": "Celá zpráva",
    "created_by": "Vytvořil",
    "fix_hint": "Tip opravy",
    "execution_status": "Stav spuštění",
    "queue_id": "Queue ID",
    "action_code": "Akce",
    "final_rank_score": "Finální skóre",
    "dispatch_state_cz": "Dispatch stav",
    "outcome_code": "Výsledek učení",
    "outcome_note": "Poznámka učení",
    "sport_name": "Název sportu",
    "mode": "Režim",
    "request_day": "Den",
    "requests_used": "Použito",
    "requests_limit": "Limit",
    "requests_remaining": "Zbývá",
    "used_pct": "Využito %",
    "budget_status": "Stav limitu",
    "core_pct": "CORE %",
    "people_pct": "PEOPLE %",
    "media_pct": "MEDIA %",
    "odds_pct": "ODDS %",
    "total_pct": "Celkem %",
    "core_pending": "CORE čeká",
    "sport_readiness": "Připravenost",
    "top_priority_rank": "Priorita",
    "recommended_focus": "Doporučené zaměření",
    "last_updated": "Aktualizováno",
    "raw_payloads": "RAW payloady",
    "raw_pending": "RAW čeká",
    "raw_parsed": "RAW parsed",
    "raw_error": "RAW chyby",
    "staging_players": "Staging hráči",
    "staging_distinct_players": "Unikátní staging",
    "public_players": "Public hráči",
    "provider_maps": "Provider mapy",
    "public_coverage_pct": "Public coverage %",
    "people_status": "PEOPLE stav",
    "sport_people_status": "Stav PEOPLE sportu",
    "providers": "Providerů",
    "coverage_pct": "Coverage %",
    "overall_harvest_readiness": "Harvest ready %",
    "db_ready_percent": "DB ready %",
    "people_ready_percent": "People ready %",
    "media_ready_percent": "Media ready %",
    "panel_ready_percent": "Panel ready %",
    "locks_ready_percent": "Locky ready %",
    "dry_run_score": "Dry-run skóre",
    "dry_run_status": "Dry-run stav",
    "recommendation_cz": "Doporučení",
    "milestone_code": "Milník",
    "milestone_name": "Název milníku",
    "category": "Kategorie",
    "progress_percent": "Hotovo %",
    "risk_level": "Riziko",
    "risk_color": "Barva rizika",
    "total_matches": "Zápasy celkem",
    "matches_with_odds": "Zápasy s kurzy",
    "odds_rows": "Řádky kurzů",
    "bookmakers_count": "Bookmakeři",
    "market_outcomes_count": "Trhy",
    "unmatched_theodds_count": "Nespárované TheOdds",
    "match_odds_coverage_pct": "Pokrytí kurzů %",
    "odds_readiness_score": "Odds skóre",
    "odds_readiness_status": "Odds stav",
    "provider_name": "Název providera",
    "source": "Zdroj",
    "run_count": "Počet běhů",
    "last_status": "Poslední stav",
    "last_started_at": "Poslední start",
    "last_finished_at": "Poslední konec",
    "odds_count": "Počet kurzů",
    "bookmaker_count": "Počet bookmakerů",
    "market_count": "Počet trhů",
    "unmatched_count": "Nespárováno",
    "worker_type": "Typ workeru",
    "worker_supported": "Worker podporován",
    "worker_active": "Worker aktivní",
    "worker_registry_note": "Poznámka registry",
    "coverage_status": "Coverage stav",
    "primary_provider": "Primární provider",
    "fallback_provider": "Záložní provider",
}


class KpiValueHandle:
    """
    Malý wrapper nad hodnotou KPI.
    Panel dál používá .config(text=...), ale karta současně překreslí grafický indikátor.
    """

    def __init__(self, label, canvas, accent_color, title=""):
        self.label = label
        self.canvas = canvas
        self.accent_color = accent_color
        self.title = title
        self.value_text = "0"
        self.canvas.bind("<Configure>", lambda event: self.redraw())

    def config(self, **kwargs):
        if "text" in kwargs:
            self.value_text = str(kwargs.get("text"))
        self.label.config(**kwargs)
        self.redraw()

    configure = config

    def cget(self, key):
        return self.label.cget(key)

    def pack(self, *args, **kwargs):
        return self.label.pack(*args, **kwargs)

    def grid(self, *args, **kwargs):
        return self.label.grid(*args, **kwargs)

    def _numeric_percent(self):
        import re
        txt = str(self.value_text).replace(",", ".")
        match = re.search(r"-?\d+(?:\.\d+)?", txt)
        if not match:
            upper = txt.upper()
            if "READY" in upper or "PŘIPRAV" in upper:
                return 85
            if "VAROV" in upper or "WARNING" in upper:
                return 55
            if "CHYBA" in upper or "CRITICAL" in upper or "ERROR" in upper:
                return 95
            return 18

        value = float(match.group(0))

        # Pro procenta a skóre 0-100 je hodnota přímá.
        if 0 <= value <= 100:
            return int(value)

        # Pro počty použijeme měkké logické omezení, aby 6600 nezničilo graf.
        if value > 1000:
            return 100
        if value > 100:
            return 85
        return max(4, min(100, int(value)))

    def redraw(self):
        try:
            canvas = self.canvas
            canvas.delete("all")
            w = max(30, canvas.winfo_width())
            h = max(10, canvas.winfo_height())
            pct = self._numeric_percent()

            # Pozadí tenkého grafu.
            canvas.create_rectangle(
                0, h - 5, w, h - 3,
                fill="#293044",
                outline="#293044"
            )

            fill_w = int((w - 2) * (pct / 100))
            canvas.create_rectangle(
                1, h - 5, max(2, fill_w), h - 3,
                fill=self.accent_color,
                outline=self.accent_color
            )
        except Exception:
            pass

def cz_status(value):
    if value is None:
        return ""

    text = str(value)
    key = text.upper()

    return STATUS_LABELS.get(key, text)

def cz_column(column_name):
    return COLUMN_LABELS.get(str(column_name), str(column_name))


# =========================================================
# DB
# =========================================================

def db_query(sql):

    conn = None

    try:

        conn = psycopg2.connect(**DB_CONFIG)

        with conn.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor
        ) as cur:

            cur.execute(sql)

            return cur.fetchall()

    except Exception as e:

        return [{"CHYBA": str(e)}]

    finally:

        if conn:
            conn.close()

def db_execute(sql, params=None):

    conn = None

    try:
        conn = psycopg2.connect(**DB_CONFIG)

        with conn.cursor() as cur:
            cur.execute(sql, params)

        conn.commit()
        return True, None

    except Exception as e:
        if conn:
            conn.rollback()
        return False, str(e)

    finally:
        if conn:
            conn.close()

# =========================================================
# APP
# =========================================================

class MatchMatrixAdminPanel(tk.Tk):

    def __init__(self):

        super().__init__()

        self.title(
            "MATCHMATRIX OPS PANEL V17.11.14 CZ"
        )

        self.geometry("1920x1040")

        self.configure(bg=BG)

        self.scale = 1.0

        self.log_queue = queue.Queue()

        self.worker_running = False

        # V17.11.01: režim řízení panelu + doporučená akce.
        # MANUÁL = uživatel vybírá akce.
        # AUTOMAT = panel po doběhu workeru vybere další bezpečnou akci z fronty.
        self.auto_mode_enabled = False
        self.auto_cycle_running = False
        self.auto_ok_count = 0
        self.auto_warning_count = 0
        self.auto_error_count = 0
        self.last_worker_return_code = None
        self.last_worker_name = None

        self.blink_state = False

        self.system_pulse_state = False

        self.fix_task_filter = "open"

        self.setup_style()
        self.build_ui()

        self.refresh_all()

        self.after(300, self.process_logs)

    # =====================================================
    # STYLE
    # =====================================================

    def setup_style(self):

        style = ttk.Style()

        style.theme_use("clam")

        style.configure(
            "Treeview",
            background="#0e0915",
            foreground=TEXT,
            fieldbackground="#0e0915",
            rowheight=24,
            font=("Segoe UI", 10),
        )

        style.configure(
            "Treeview.Heading",
            background="#121724",
            foreground="#d8b4fe",
            font=("Segoe UI", 9, "bold"),
        )

        style.configure(
            "Vertical.TScrollbar",
            background="#20142d",
            troughcolor="#0b0613",
            arrowcolor="#d8b4fe",
            bordercolor="#20142d",
            relief="flat",
        )

        style.configure(
            "Horizontal.TScrollbar",
            background="#20142d",
            troughcolor="#0b0613",
            arrowcolor="#d8b4fe",
            bordercolor="#20142d",
            relief="flat",
        )

        style.map(
            "Treeview",
            background=[("selected", "#403054")],
            foreground=[("selected", "white")],
        )

    # =====================================================
    # UI
    # =====================================================

    def build_ui(self):

        # HEADER
        header = tk.Frame(self, bg="#07040d", height=70)
        header.pack(fill="x")

        tk.Label(
            header,
            text="▰ MATCHMATRIX OPERAČNÍ CENTRUM",
            bg="#07040d",
            fg=PINK,
            font=("Segoe UI", 24, "bold")
        ).pack(side="left", padx=15, pady=10)

        self.clock_label = tk.Label(
            header,
            text="",
            bg="#07040d",
            fg="white",
            font=("Segoe UI", 18, "bold")
        )
        self.clock_label.pack(side="right", padx=15)

        self.system_state = tk.Label(
            header,
            text="PŘIPRAVEN",
            bg="#07040d",
            fg=GREEN,
            font=("Segoe UI", 13, "bold")
        )
        self.system_state.pack(side="right", padx=15)

        # =========================================================
        # STAV PROJEKTU - V17.10.06
        # =========================================================
        # CO TO JE:
        # - Horní projektový přehled dokončenosti hlavních vrstev.
        # - Vlevo jsou aktuální progress bary, vpravo kratší graf vývoje v čase.
        #
        # K ČEMU TO JE:
        # - Aktuální stav je čitelný okamžitě.
        # - Graf není roztažený přes celou obrazovku, takže křivky lépe vyniknou.
        #
        # KDE TO UVIDÍME:
        # - Přímo pod hlavní horní lištou panelu.
        #
        # JAK SE TO VYUŽIJE:
        # - Hodnoty CORE / PEOPLE / MEDIA / ODDS / CELKEM se při refreshi čtou z DB.
        # - Graf vývoje zatím drží poslední body v paměti panelu.

        self.project_progress_values = {
            "CORE": 82,
            "PEOPLE": 34,
            "MEDIA": 41,
            "ODDS": 8,
            "CELKEM": 56,
        }

        # V17.11.14: reference na horní grafické indikátory.
        # Hodnoty se po startu a při refreshi přepíšou z DB view
        # ops.v_sport_completion_dashboard_v2.
        self.project_progress_widgets = {}

        self.project_progress_history = [
            ("05-27", 76, 28, 32, 5, 48),
            ("05-28", 78, 30, 35, 6, 50),
            ("05-29", 80, 31, 38, 7, 52),
            ("05-30", 81, 33, 40, 8, 54),
            ("05-31", 82, 34, 41, 8, 56),
        ]

        project_frame = tk.Frame(
            self,
            bg="#0d0716",
            highlightbackground=PURPLE,
            highlightthickness=1
        )

        project_frame.pack(
            fill="x",
            padx=6,
            pady=(2, 3)
        )

        project_frame.columnconfigure(0, weight=3)
        project_frame.columnconfigure(1, weight=2)
        project_frame.rowconfigure(0, weight=1)

        # Levá část: aktuální procenta vrstev.
        project_progress_panel = tk.Frame(
            project_frame,
            bg="#0d0716"
        )

        project_progress_panel.grid(
            row=0,
            column=0,
            sticky="nsew",
            padx=(8, 5),
            pady=4
        )

        tk.Label(
            project_progress_panel,
            text="📊 AKTUÁLNÍ STAV VRSTEV",
            bg="#0d0716",
            fg=PINK,
            font=("Segoe UI", 9, "bold")
        ).pack(
            anchor="w",
            pady=(0, 2)
        )

        project_grid = tk.Frame(
            project_progress_panel,
            bg="#0d0716"
        )

        project_grid.pack(
            fill="both",
            expand=True
        )

        for c in range(5):
            project_grid.columnconfigure(c, weight=1, uniform="project_progress")

        self.create_project_progress_cell(
            project_grid,
            0,
            "CORE",
            self.project_progress_values["CORE"],
            GREEN
        )

        self.create_project_progress_cell(
            project_grid,
            1,
            "PEOPLE",
            self.project_progress_values["PEOPLE"],
            YELLOW
        )

        self.create_project_progress_cell(
            project_grid,
            2,
            "MEDIA",
            self.project_progress_values["MEDIA"],
            PURPLE
        )

        self.create_project_progress_cell(
            project_grid,
            3,
            "ODDS",
            self.project_progress_values["ODDS"],
            RED
        )

        self.create_project_progress_cell(
            project_grid,
            4,
            "CELKEM",
            self.project_progress_values["CELKEM"],
            PINK
        )

        # Pravá část: kratší graf vývoje v čase.
        project_chart_panel = tk.Frame(
            project_frame,
            bg="#0d0716"
        )

        project_chart_panel.grid(
            row=0,
            column=1,
            sticky="nsew",
            padx=(5, 8),
            pady=4
        )

        tk.Label(
            project_chart_panel,
            text="📈 VÝVOJ V ČASE",
            bg="#0d0716",
            fg=PINK,
            font=("Segoe UI", 9, "bold")
        ).pack(
            anchor="w",
            pady=(0, 0)
        )

        self.project_chart = tk.Canvas(
            project_chart_panel,
            bg="#0d0716",
            height=86,
            highlightthickness=0
        )

        self.project_chart.pack(
            fill="both",
            expand=True,
            padx=0,
            pady=(0, 0)
        )

        self.project_chart.bind(
            "<Configure>",
            lambda event: self.draw_project_timeline_chart()
        )

        # KPI
        # V17.11.13: KPI jsou bez velkých rámečků.
        # Na širokém okně se vejdou do jednoho řádku.
        # Při zmenšení okna se automaticky zalomí do více řádků.
        self.kpi_bar = tk.Frame(self, bg=BG)
        self.kpi_bar.pack(fill="x", pady=(5, 3))

        self.kpi_items = []
        self.kpi_count = 0
        self.kpis_per_row = 18
        self.kpi_bar.bind(
            "<Configure>",
            lambda event: self.reflow_kpis()
        )

        self.kpi_stav = self.create_kpi("🛡 STAV", "PŘIPRAVEN", GREEN, "Systém")
        self.kpi_pending = self.create_kpi("⏳ ČEKAJÍCÍ", "0", YELLOW, "Planner")
        self.kpi_alerty = self.create_kpi("🔔 ALERTY", "0", RED, "Kritické/var.")
        self.kpi_safe = self.create_kpi("✅ BEZPEČNÉ", "0", PURPLE, "Workery")
        self.kpi_conf = self.create_kpi("📈 DŮVĚRA AI", "0", PINK, "Rozhodování")

        self.ai_critical = self.create_kpi("🚨 AI KRIT.", "0", RED, "Okamžitě")
        self.ai_safe_retry = self.create_kpi("♻ RETRY", "0", GREEN, "Bezpečné")
        self.ai_auto_fix = self.create_kpi("🛠 OPRAVY", "0", PURPLE, "Auto fix")
        self.ai_blocking = self.create_kpi("⛔ BLOK", "0", RED, "Zdroje")

        self.ai_score = self.create_kpi("🤖 AI SKÓRE", "0", PINK, "Kvalita")
        self.coverage_ready = self.create_kpi("📦 READY", "0", GREEN, "Připraveno")
        self.coverage_missing = self.create_kpi("🚧 CHYBÍ", "0", YELLOW, "Data gap")
        self.coverage_paid = self.create_kpi("💰 PRO", "0", PURPLE, "Čeká")
        self.dev_backlog = self.create_kpi("📋 BACKLOG", "0", PINK, "Úkoly")

        self.autonomous_ready = self.create_kpi("🚀 AUTO RDY", "0", GREEN, "Ke spuštění")
        self.autonomous_running = self.create_kpi("▶ AUTO BĚŽÍ", "0", YELLOW, "Aktivní")
        self.autonomous_success = self.create_kpi("✅ AUTO OK", "0", GREEN, "Úspěch")
        self.autonomous_failed = self.create_kpi("❌ AUTO ERR", "0", RED, "Chyba")

        # BUTTONS
        btn_bar = tk.Frame(self, bg=BG)
        btn_bar.pack(fill="x")

        self.make_button(btn_bar, "↻ OBNOVIT", "#452060", self.refresh_all)
        self.auto_mode_button = self.make_button(btn_bar, "🟢 REŽIM: MANUÁL", "#452060", self.toggle_auto_mode)
        self.make_button(btn_bar, "⭐ DOPORUČENÁ AKCE", "#8b5cf6", self.run_recommended_worker)
        self.make_button(btn_bar, "▶ SPUSTIT DALŠÍ", "#006b3c", self.run_next_safe)
        self.make_button(btn_bar, "▶ SPUSTIT VYBRANÝ", "#0f766e", self.run_selected_worker)
        self.make_button(btn_bar, "ℹ PROČ DOPORUČENO", "#5b21b6", self.explain_recommended_worker)
        self.make_button(btn_bar, "🤖 AUTONOMNÍ AKCE", "#0f766e", self.run_autonomous_dispatch)
        self.make_button(btn_bar, "🗑 VYMAZAT LOG", "#90115d", self.clear_log)

        # V17.10.06: viditelný stav spuštěného workeru.
        # CO TO JE:
        # - Malý runtime indikátor, který ukazuje, že po kliknutí opravdu běží akce.
        # K ČEMU TO JE:
        # - Uživatel hned vidí, že panel nezamrzl a worker pracuje.
        self.worker_activity_label = tk.Label(
            btn_bar,
            text="● ŽÁDNÁ AKCE NEBĚŽÍ",
            bg=BG,
            fg="#c4a1dd",
            font=("Segoe UI", 10, "bold")
        )
        self.worker_activity_label.pack(side="right", padx=12)

        self.auto_status_label = tk.Label(
            btn_bar,
            text="MANUÁL | CÍL: ZVÝŠIT NEJSLABŠÍ VRSTVU",
            bg=BG,
            fg="#c4a1dd",
            font=("Segoe UI", 10, "bold")
        )
        self.auto_status_label.pack(side="right", padx=8)

        self.worker_progress = ttk.Progressbar(
            btn_bar,
            mode="indeterminate",
            length=220
        )
        self.worker_progress.pack(side="right", padx=8, pady=8)

        # NOTEBOOK
        # HLAVNÍ OBSAH + SPODNÍ LIŠTA ZÁLOŽEK
        self.content_area = tk.Frame(self, bg=BG)
        self.content_area.pack(fill="both", expand=True, padx=8, pady=(6, 4))

        self.bottom_tabs = tk.Frame(self, bg="#0d0716", height=78)
        self.bottom_tabs.pack(fill="x", side="bottom", padx=8, pady=(2, 8))

        self.tabs = {}
        self.current_tab = None

        tab_dashboard = tk.Frame(self.content_area, bg=BG)
        tab_scheduler = tk.Frame(self.content_area, bg=BG)
        tab_workers = tk.Frame(self.content_area, bg=BG)
        tab_runtime = tk.Frame(self.content_area, bg=BG)
        tab_payloads = tk.Frame(self.content_area, bg=BG)
        tab_logs = tk.Frame(self.content_area, bg=BG)
        tab_fix_tasks = tk.Frame(self.content_area, bg=BG)
        tab_ai_ops = tk.Frame(self.content_area, bg=BG)
        tab_roadmap = tk.Frame(self.content_area, bg=BG)
        tab_people_pipeline = tk.Frame(self.content_area, bg=BG)
        tab_harvest = tk.Frame(self.content_area, bg=BG)
        tab_odds = tk.Frame(self.content_area, bg=BG)
        tab_providers = tk.Frame(self.content_area, bg=BG)

        self.tabs = {
            "DASHBOARD": tab_dashboard,
            "SCHEDULER": tab_scheduler,
            "WORKERS": tab_workers,
            "ACTIVE RUNS": tab_runtime,
            "PAYLOADS": tab_payloads,
            "LOGS": tab_logs,
            "FIX TASKS": tab_fix_tasks,
            "AI OPS": tab_ai_ops,
            "ROADMAP": tab_roadmap,
            "PEOPLE PIPELINE": tab_people_pipeline,
            "HARVEST": tab_harvest,
            "ODDS": tab_odds,
            "PROVIDERS": tab_providers,
        }

        for frame in self.tabs.values():
            frame.place(relx=0, rely=0, relwidth=1, relheight=1)

        self.create_bottom_tab("▦", "DASHBOARD")
        self.create_bottom_tab("◷", "SCHEDULER")
        self.create_bottom_tab("👥", "WORKERS")
        self.create_bottom_tab("▶", "ACTIVE RUNS")
        self.create_bottom_tab("▣", "PAYLOADS")
        self.create_bottom_tab("▤", "LOGS")
        self.create_bottom_tab("🛠", "FIX TASKS")
        self.create_bottom_tab("🤖", "AI OPS")
        self.create_bottom_tab("🧭", "ROADMAP")
        self.create_bottom_tab("🌾", "HARVEST")
        self.create_bottom_tab("🎯", "ODDS")
        self.create_bottom_tab("🔌", "PROVIDERS")
        self.create_bottom_tab("👥", "PEOPLE PIPELINE")

        self.show_tab("DASHBOARD")
        
        # DASHBOARD DYNAMIC PANED LAYOUT
        tab_dashboard.columnconfigure(0, weight=1)
        tab_dashboard.rowconfigure(0, weight=1)

        dashboard_paned = tk.PanedWindow(
            tab_dashboard,
            orient=tk.VERTICAL,
            bg=BG,
            sashwidth=8,
            sashrelief="raised"
        )

        dashboard_paned.grid(
            row=0,
            column=0,
            sticky="nsew"
        )

        dashboard_row_1 = tk.Frame(dashboard_paned, bg=BG)
        dashboard_row_2 = tk.Frame(dashboard_paned, bg=BG)
        dashboard_row_3 = tk.Frame(dashboard_paned, bg=BG)

        for row_frame in [
            dashboard_row_1,
            dashboard_row_2,
            dashboard_row_3
        ]:
            for i in range(3):
                row_frame.columnconfigure(i, weight=1)

            row_frame.rowconfigure(0, weight=1)

            dashboard_paned.add(
                row_frame,
                minsize=160
            )

        self.orchestration_summary_tree = self.create_section(
            dashboard_row_1, "⚙ SOUHRN ORCHESTRACE", 0, 0
        )

        self.run_next_tree = self.create_section(
            dashboard_row_1, "▶ FRONTA KE SPUŠTĚNÍ", 0, 1
        )

        self.dashboard_tree = self.create_section(
            dashboard_row_1, "📊 STAV PLÁNOVAČE", 0, 2
        )

        self.alerts_tree = self.create_section(
            dashboard_row_2, "🔔 UPOZORNĚNÍ", 0, 0
        )

        self.feed_tree = self.create_section(
            dashboard_row_2, "🧭 UDÁLOSTI ORCHESTRACE", 0, 1
        )

        self.worker_health_tree = self.create_section(
            dashboard_row_2, "🧩 ZDRAVÍ WORKERŮ", 0, 2
        )

        self.pending_payloads_tree = self.create_section(
            dashboard_row_3, "▣ ČEKAJÍCÍ PAYLOADY", 0, 0
        )

        self.cooldown_tree = self.create_section(
            dashboard_row_3, "❄ COOLDOWN PLÁNOVAČE", 0, 1
        )

        self.active_runs_tree = self.create_section(
            dashboard_row_3, "▶ AKTIVNÍ BĚHY", 0, 2
        )

        # V17.11.02: Denní API limity podle sportů.
        # CO TO JE:
        # - Přehled využití denního API budgetu pro historický harvest.
        # K ČEMU TO JE:
        # - Uvidíš, jestli nejede jen fotbal a kolik limitu zbývá ostatním sportům.
        dashboard_row_3.columnconfigure(3, weight=1)

        self.sport_daily_budget_tree = self.create_section(
            dashboard_row_3, "💳 DENNÍ LIMIT SPORTŮ", 0, 3
        )

        # DETAIL TABS
        tab_scheduler.columnconfigure(0, weight=1)
        tab_scheduler.rowconfigure(0, weight=1)
        self.audit_tree = self.create_section(
            tab_scheduler, "🧭 AUDIT ORCHESTRACE", 0, 0
        )

        tab_workers.columnconfigure(0, weight=1)
        tab_workers.rowconfigure(0, weight=1)
        self.workers_detail_tree = self.create_section(
            tab_workers, "🧩 DETAIL WORKERŮ", 0, 0
        )
        self.workers_detail_tree.bind(
            "<Double-1>", self.open_worker_detail
        )

        tab_runtime.columnconfigure(0, weight=1)
        tab_runtime.rowconfigure(0, weight=1)
        self.active_runs_detail_tree = self.create_section(
            tab_runtime, "▶ DETAIL AKTIVNÍCH BĚHŮ", 0, 0
        )

        tab_payloads.columnconfigure(0, weight=1)
        tab_payloads.rowconfigure(0, weight=1)
        self.payloads_detail_tree = self.create_section(
            tab_payloads, "📦 DETAIL PAYLOADŮ", 0, 0
        )

        self.payloads_detail_tree.bind(
            "<Double-1>",
            self.open_payload_group_detail
        )

        tab_logs.rowconfigure(0, weight=2)
        tab_logs.rowconfigure(1, weight=1)
        self.logs_detail_tree = self.create_section(
            tab_logs, "▤ POSLEDNÍ LOGY JOBŮ", 0, 0
        )

        tab_fix_tasks.columnconfigure(0, weight=1)
        tab_fix_tasks.rowconfigure(1, weight=1)

        fix_filter_bar = tk.Frame(tab_fix_tasks, bg=BG)
        fix_filter_bar.grid(row=0, column=0, sticky="ew", padx=4, pady=4)

        self.fix_btn_open = self.make_button(
            fix_filter_bar,
            "OTEVŘENÉ",
            "#006b3c",
            lambda: self.set_fix_task_filter("open")
        )

        self.fix_btn_fixed = self.make_button(
            fix_filter_bar,
            "OPRAVENÉ",
            "#452060",
            lambda: self.set_fix_task_filter("fixed")
        )

        self.fix_btn_ignored = self.make_button(
            fix_filter_bar,
            "IGNOROVANÉ",
            "#90115d",
            lambda: self.set_fix_task_filter("ignored")
        )

        self.fix_btn_all = self.make_button(
            fix_filter_bar,
            "VŠE",
            "#333333",
            lambda: self.set_fix_task_filter("all")
        )

        tab_ai_ops.columnconfigure(0, weight=1)
        tab_ai_ops.columnconfigure(1, weight=1)
        tab_ai_ops.rowconfigure(0, weight=1)
        tab_ai_ops.rowconfigure(1, weight=1)
        tab_ai_ops.rowconfigure(2, weight=1)
        tab_ai_ops.rowconfigure(3, weight=1)
        tab_ai_ops.rowconfigure(4, weight=1)

        self.ai_ops_health_tree = self.create_section(
            tab_ai_ops, "🤖 ZDRAVÍ PROVIDERŮ", 0, 0
        )

        self.ai_ops_alert_tree = self.create_section(
            tab_ai_ops, "🚨 AI UPOZORNĚNÍ", 0, 1
        )

        self.scheduler_autopilot_tree = self.create_section(
            tab_ai_ops, "🤖 DOPORUČENÍ SCHEDULERU", 1, 0
        )

        self.ai_action_queue_tree = self.create_section(
            tab_ai_ops, "⚙ FRONTA AI AKCÍ", 1, 1
        )

        self.ai_action_history_tree = self.create_section(
            tab_ai_ops, "📜 HISTORIE AI AKCÍ", 2, 0, 2
        )

        self.autonomous_queue_summary_tree = self.create_section(
            tab_ai_ops, "🤖 AUTONOMNÍ FRONTA", 3, 0
        )

        self.autonomous_learning_tree = self.create_section(
            tab_ai_ops, "🧠 POSLEDNÍ AUTONOMNÍ UČENÍ", 3, 1
        )

        # V17.11.04: Autonomous OPS Brain napojený do panelu.
        # CO TO JE:
        # - Finální rozhodovací pohled 111_S.
        # K ČEMU TO JE:
        # - Panel ukáže, co má Brain doporučeno RUN / WAIT / HOLD.
        self.autonomous_ops_brain_tree = self.create_section(
            tab_ai_ops, "🧠 AUTONOMOUS OPS BRAIN", 4, 0, 2
        )

        # ROADMAP / COVERAGE / DEVELOPMENT BACKLOG
        tab_roadmap.columnconfigure(0, weight=1)
        tab_roadmap.columnconfigure(1, weight=1)
        tab_roadmap.rowconfigure(0, weight=1)
        tab_roadmap.rowconfigure(1, weight=1)
        tab_roadmap.rowconfigure(2, weight=1)

        self.coverage_progress_tree = self.create_section(
            tab_roadmap, "🏆 DOKONČENOST SPORTŮ", 0, 0
        )

        self.top_development_tasks_tree = self.create_section(
            tab_roadmap, "🏁 TOP ÚKOLY VÝVOJE", 0, 1
        )

        self.data_gap_tree = self.create_section(
            tab_roadmap, "🧩 DATA GAP / CO CHYBÍ", 1, 0
        )

        self.development_queue_summary_tree = self.create_section(
            tab_roadmap, "📋 SOUHRN BACKLOGU", 1, 1
        )

        self.development_queue_tree = self.create_section(
            tab_roadmap, "🗂 DETAIL BACKLOGU", 2, 0, 2
        )

        # V17.11.07: HARVEST READINESS - hotové view ze série 117.
        # CO TO JE:
        # - Přehled připravenosti projektu na velký harvest / druhé PC / PRO období.
        # K ČEMU TO JE:
        # - Ukazuje readiness, dry-run, locky a doporučení, bez nutnosti otevírat DBeaver.
        tab_harvest.columnconfigure(0, weight=1)
        tab_harvest.columnconfigure(1, weight=1)
        tab_harvest.rowconfigure(0, weight=1)
        tab_harvest.rowconfigure(1, weight=1)
        tab_harvest.rowconfigure(2, weight=1)

        self.harvest_readiness_tree = self.create_section(
            tab_harvest, "🌾 HARVEST READINESS", 0, 0
        )

        self.harvest_dry_run_tree = self.create_section(
            tab_harvest, "🧪 DRY-RUN PŘIPRAVENOST", 0, 1
        )

        self.harvest_recommendations_tree = self.create_section(
            tab_harvest, "💡 HARVEST DOPORUČENÍ", 1, 0
        )

        self.harvest_locks_tree = self.create_section(
            tab_harvest, "🔒 LOCKY / DRUHÉ PC", 1, 1
        )

        self.harvest_layers_tree = self.create_section(
            tab_harvest, "📊 PEOPLE / MEDIA / ODDS READY", 2, 0, 2
        )

        # V17.11.07: ODDS + THEODDS + FOOTBALL-DATA převzaté z V11.
        tab_odds.columnconfigure(0, weight=1)
        tab_odds.columnconfigure(1, weight=1)
        tab_odds.rowconfigure(1, weight=1)
        tab_odds.rowconfigure(2, weight=1)

        odds_button_bar = tk.Frame(tab_odds, bg=BG)
        odds_button_bar.grid(row=0, column=0, columnspan=2, sticky="ew", padx=4, pady=4)

        self.make_button(
            odds_button_bar,
            "🎯 SPUSTIT THEODDS",
            "#7c3aed",
            lambda: self.start_worker_by_code("THEODDS_REFRESH", "THEODDS REFRESH")
        )

        self.make_button(
            odds_button_bar,
            "⚽ SPUSTIT FOOTBALL DATA",
            "#6d28d9",
            lambda: self.start_worker_by_code("FOOTBALL_DATA_REFRESH", "FOOTBALL DATA REFRESH")
        )

        self.make_button(
            odds_button_bar,
            "↻ OBNOVIT KURZY",
            "#581c87",
            self.load_odds_dashboard
        )

        self.odds_readiness_tree = self.create_section(
            tab_odds, "🎯 ODDS READINESS PODLE SPORTŮ", 1, 0
        )

        self.odds_provider_roadmap_tree = self.create_section(
            tab_odds, "🗺 ODDS PROVIDER ROADMAP", 1, 1
        )

        self.odds_provider_runs_tree = self.create_section(
            tab_odds, "🕒 THEODDS / FOOTBALL-DATA POSLEDNÍ BĚHY", 2, 0
        )

        self.odds_counts_tree = self.create_section(
            tab_odds, "📦 KURZY / BOOKMAKEŘI / NESPÁROVANÉ", 2, 1
        )

        # V17.11.07: PROVIDEŘI - provider strategie, alternativy, registry workerů.
        tab_providers.columnconfigure(0, weight=1)
        tab_providers.columnconfigure(1, weight=1)
        tab_providers.rowconfigure(0, weight=1)
        tab_providers.rowconfigure(1, weight=1)
        tab_providers.rowconfigure(2, weight=1)

        self.provider_switch_tree = self.create_section(
            tab_providers, "🔌 PROVIDER SWITCH PANEL", 0, 0
        )

        self.provider_alternative_tree = self.create_section(
            tab_providers, "🔁 ALTERNATIVNÍ PROVIDEŘI", 0, 1
        )

        self.provider_strategy_tree = self.create_section(
            tab_providers, "🧠 PROVIDER STRATEGIE", 1, 0
        )

        self.provider_worker_registry_tree = self.create_section(
            tab_providers, "🧩 REGISTRY WORKERŮ PROVIDERŮ", 1, 1
        )

        self.database_governance_tree = self.create_section(
            tab_providers, "🏛 DB GOVERNANCE - AKTIVNÍ PANEL OBJEKTY", 2, 0, 2
        )

        # V17.11.06: PEOPLE PIPELINE summary + detail.
        # CO TO JE:
        # - Horní tabulka ukazuje PEOPLE stav po sportech.
        # - Dolní tabulka ukazuje detail podle providerů.
        # K ČEMU TO JE:
        # - Panel už nemíchá FB/football nebo BK/basketball a ukazuje sport jako celek.
        tab_people_pipeline.columnconfigure(0, weight=1)
        tab_people_pipeline.rowconfigure(0, weight=1)
        tab_people_pipeline.rowconfigure(1, weight=2)

        self.people_pipeline_summary_tree = self.create_section(
            tab_people_pipeline, "👥 PEOPLE SUMMARY PODLE SPORTŮ", 0, 0
        )

        self.people_pipeline_detail_tree = self.create_section(
            tab_people_pipeline, "🔎 PEOPLE DETAIL PODLE PROVIDERŮ", 1, 0
        )

        self.fix_tasks_tree = self.create_section(
            tab_fix_tasks, "🛠 ÚKOLY K OPRAVĚ", 1, 0
        )
        self.fix_tasks_tree.bind(
            "<Double-1>", self.open_fix_task_detail
        )

        self.logs_detail_tree.bind(
            "<Double-1>", self.open_job_log_detail
        )

        self.log_text = self.create_log_section(
            tab_logs, "LOG SPOUŠTĚNÍ", 1, 0
        )

        self.bind("<Control-MouseWheel>", self.zoom)

        self.blink_critical_rows()
        self.update_clock()
        self.pulse_system_state()

    # =====================================================
    # PROJECT TIMELINE CHART
    # =====================================================

    def draw_project_timeline_chart(self):
        """
        CO TO JE:
        - Jeden společný graf vývoje dokončenosti vrstev v čase.

        K ČEMU TO JE:
        - Rychle ukáže, jestli se CORE / PEOPLE / MEDIA / ODDS posouvají dopředu.

        KDE TO UVIDÍME:
        - Horní pruh pod titulkem panelu.

        JAK SE TO VYUŽIJE:
        - Teď kreslí statickou historii.
        - Později bude číst data z OPS snapshot tabulky.
        """

        if not hasattr(self, "project_chart"):
            return

        canvas = self.project_chart
        canvas.delete("all")

        width = canvas.winfo_width()
        height = canvas.winfo_height()

        if width < 300 or height < 50:
            return

        left = 55
        right = 125
        top = 10
        bottom = 18

        chart_w = max(200, width - left - right)
        chart_h = max(35, height - top - bottom)

        # Jemná mřížka 0 / 50 / 100 %.
        for pct in (0, 50, 100):
            y = top + chart_h - (pct / 100) * chart_h
            canvas.create_line(
                left, y, left + chart_w, y,
                fill="#261a33"
            )
            canvas.create_text(
                left - 8, y,
                text=f"{pct}%",
                fill="#b999cc",
                font=("Segoe UI", 7, "bold"),
                anchor="e"
            )

        history = getattr(self, "project_progress_history", [])

        if len(history) < 2:
            return

        series = [
            ("CORE", 1, GREEN),
            ("PEOPLE", 2, YELLOW),
            ("MEDIA", 3, PURPLE),
            ("ODDS", 4, RED),
            ("CELKEM", 5, PINK),
        ]

        def point(index, percent):
            x = left + (index / (len(history) - 1)) * chart_w
            y = top + chart_h - (max(0, min(100, percent)) / 100) * chart_h
            return x, y

        # Osa X s daty.
        for i, row in enumerate(history):
            x, _ = point(i, 0)
            canvas.create_line(x, top, x, top + chart_h, fill="#21172d")
            canvas.create_text(
                x, height - 8,
                text=row[0],
                fill="#cdb0df",
                font=("Segoe UI", 7, "bold")
            )

        for name, value_index, color in series:
            coords = []

            for i, row in enumerate(history):
                x, y = point(i, row[value_index])
                coords.extend([x, y])

            if len(coords) >= 4:
                canvas.create_line(
                    *coords,
                    fill=color,
                    width=2,
                    smooth=False
                )

            last_x, last_y = point(len(history) - 1, history[-1][value_index])
            canvas.create_oval(
                last_x - 3, last_y - 3,
                last_x + 3, last_y + 3,
                fill=color,
                outline=color
            )

        # Legenda vpravo.
        legend_x = left + chart_w + 18
        legend_y = top + 2

        for row_index, (name, value_index, color) in enumerate(series):
            y = legend_y + row_index * 12
            value = history[-1][value_index]

            canvas.create_rectangle(
                legend_x, y - 4,
                legend_x + 9, y + 5,
                fill=color,
                outline=color
            )
            canvas.create_text(
                legend_x + 16, y,
                text=f"{name} {value}%",
                fill="white",
                font=("Segoe UI", 8, "bold"),
                anchor="w"
            )

    # =====================================================
    # PROJECT PROGRESS BAR
    # =====================================================

    def create_project_progress_cell(
        self,
        parent,
        column,
        title,
        percent,
        color
    ):
        """
        CO TO JE:
        - Malý grafický indikátor dokončenosti vrstvy projektu.

        K ČEMU TO JE:
        - Rychlý vizuální přehled, jak daleko je CORE / PEOPLE / MEDIA / ODDS.

        KDE TO UVIDÍME:
        - Horní pruh STAV PROJEKTU pod titulkem panelu.

        JAK SE TO VYUŽIJE:
        - Hodnoty se po startu a při refreshi aktualizují z DB view ops.v_sport_completion_dashboard_v2.
        """

        percent = max(0, min(100, int(percent)))

        cell = tk.Frame(
            parent,
            bg="#140b1e",
            highlightbackground=color,
            highlightthickness=1
        )

        cell.grid(
            row=0,
            column=column,
            sticky="nsew",
            padx=4,
            pady=1
        )

        header = tk.Frame(
            cell,
            bg="#140b1e"
        )

        header.pack(
            fill="x",
            padx=6,
            pady=(3, 1)
        )

        tk.Label(
            header,
            text=title,
            bg="#140b1e",
            fg=color,
            font=("Segoe UI", 9, "bold"),
            anchor="w"
        ).pack(
            side="left"
        )

        percent_label = tk.Label(
            header,
            text=f"{percent} %",
            bg="#140b1e",
            fg="white",
            font=("Segoe UI", 9, "bold"),
            anchor="e"
        )

        percent_label.pack(
            side="right"
        )

        bar_wrap = tk.Frame(
            cell,
            bg="#09050f",
            height=10
        )

        bar_wrap.pack(
            fill="x",
            padx=6,
            pady=(0, 5)
        )

        bar_fill = tk.Frame(
            bar_wrap,
            bg=color,
            height=10
        )

        bar_fill.place(
            relx=0,
            rely=0,
            relwidth=percent / 100,
            relheight=1
        )

        self.project_progress_widgets[title] = {
            "percent_label": percent_label,
            "bar_fill": bar_fill,
        }

        # Kliknutí na vrstvu otevře vysvětlení, co zvýší dané procento.
        for widget in (cell, header, bar_wrap, bar_fill):
            widget.bind(
                "<Button-1>",
                lambda event, layer=title: self.open_project_layer_help(layer)
            )
            widget.configure(cursor="hand2")

    # =====================================================
    # KPI
    # =====================================================

    def format_kpi_value(self, value):

        text = str(value)

        if text == "AKTIVNÍ UPOZORNĚNÍ":
            return "AKTIVNÍ\nUPOZORNĚNÍ"

        if len(text) > 14 and " " in text:
            parts = text.split()
            middle = max(1, len(parts) // 2)
            return " ".join(parts[:middle]) + "\n" + " ".join(parts[middle:])

        return text

    def reflow_kpis(self):
        """
        V17.11.13 - responzivní KPI řádek.

        CO TO JE:
        - Na širokém okně jsou KPI v jednom řádku.
        - Při zmenšení okna se automaticky zalomí do více řádků.
        """

        if not hasattr(self, "kpi_bar") or not hasattr(self, "kpi_items"):
            return

        try:
            width = self.kpi_bar.winfo_width()

            if width >= 1680:
                per_row = 18
            elif width >= 1450:
                per_row = 14
            elif width >= 1180:
                per_row = 11
            elif width >= 950:
                per_row = 8
            elif width >= 720:
                per_row = 6
            else:
                per_row = 4

            per_row = max(1, per_row)
            self.kpis_per_row = per_row

            for col in range(24):
                self.kpi_bar.columnconfigure(col, weight=0)

            for col in range(per_row):
                self.kpi_bar.columnconfigure(col, weight=1, uniform="kpi")

            for index, frame in enumerate(self.kpi_items):
                frame.grid_forget()
                frame.grid(
                    row=index // per_row,
                    column=index % per_row,
                    sticky="nsew",
                    padx=0,
                    pady=(1, 1)
                )
        except Exception:
            pass

    def create_kpi(
        self,
        title,
        value,
        color,
        subtitle=""
    ):
        """
        V17.11.13 - jemné KPI bez rámečků.

        CO TO JE:
        - KPI je oddělené jen tenkou svislou linkou.
        - Barva je pouze tečka, ikona/text a spodní mini indikátor.
        - Běžné KPI jsou ztlumené, důležité zůstávají čitelné.
        """

        index = self.kpi_count
        self.kpi_count += 1

        important_words = [
            "ALERT", "KRIT", "BLOK", "ERR", "CHYB", "STAV"
        ]

        is_important = any(word in str(title).upper() for word in important_words)
        title_color = color if is_important else "#c7b6d8"
        value_color = "#ffffff" if is_important else "#efe8f8"
        subtitle_color = "#8f7ca3"

        frame = tk.Frame(
            self.kpi_bar,
            bg=BG,
            highlightthickness=0,
            bd=0
        )

        frame.columnconfigure(0, weight=1)
        frame.rowconfigure(0, weight=1)

        inner = tk.Frame(
            frame,
            bg=BG,
            highlightthickness=0,
            bd=0
        )
        inner.grid(
            row=0,
            column=0,
            sticky="nsew",
            padx=(10, 12),
            pady=(3, 4)
        )

        # Svislá linka oddělí KPI bez velkého rámečku.
        separator = tk.Frame(
            frame,
            bg="#273145" if not is_important else color,
            width=1,
            highlightthickness=0,
            bd=0
        )
        separator.grid(
            row=0,
            column=1,
            sticky="ns",
            pady=(7, 7)
        )

        header = tk.Frame(inner, bg=BG)
        header.pack(fill="x")

        dot = tk.Canvas(
            header,
            width=10,
            height=10,
            bg=BG,
            highlightthickness=0,
            bd=0
        )
        dot.pack(side="left", padx=(0, 5), pady=(2, 0))
        dot.create_oval(1, 1, 9, 9, fill=color, outline=color)

        title_lbl = tk.Label(
            header,
            text=title,
            bg=BG,
            fg=title_color,
            font=("Segoe UI", 7, "bold"),
            anchor="w"
        )
        title_lbl.pack(
            side="left",
            fill="x",
            expand=True
        )

        lbl = tk.Label(
            inner,
            text=value,
            bg=BG,
            fg=value_color,
            font=("Segoe UI", 12, "bold"),
            anchor="w",
            justify="left",
            wraplength=140
        )

        lbl.pack(
            fill="x",
            pady=(1, 0)
        )

        subtitle_lbl = tk.Label(
            inner,
            text=subtitle,
            bg=BG,
            fg=subtitle_color,
            font=("Segoe UI", 6, "bold"),
            anchor="w"
        )
        subtitle_lbl.pack(
            fill="x",
            pady=(0, 1)
        )

        graph = tk.Canvas(
            inner,
            height=8,
            bg=BG,
            highlightthickness=0,
            bd=0
        )
        graph.pack(
            fill="x",
            pady=(1, 0)
        )

        for widget in (frame, inner, header, dot, title_lbl, lbl, subtitle_lbl, graph, separator):
            widget.bind(
                "<Button-1>",
                lambda event, t=title, s=subtitle: self.open_kpi_help(t, s)
            )
            widget.configure(cursor="hand2")

        self.kpi_items.append(frame)
        self.reflow_kpis()

        handle = KpiValueHandle(lbl, graph, color, title)
        handle.config(text=value)
        return handle

    # =====================================================
    # INTERAKTIVNÍ NÁPOVĚDA KPI / VRSTVY
    # =====================================================

    def show_help_window(self, title, body):
        """
        CO TO JE:
        - Univerzální detailní okno pro vysvětlení KPI / vrstvy.

        K ČEMU TO JE:
        - Uživatel po kliknutí vidí, co karta znamená, kde hledat detail
          a jakým krokem stav zlepšit.
        """

        win = tk.Toplevel(self)
        win.title(title)
        win.geometry("1050x720")
        win.configure(bg=BG)

        tk.Label(
            win,
            text=title,
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 20, "bold")
        ).pack(anchor="w", padx=15, pady=12)

        text = tk.Text(
            win,
            bg="#09050f",
            fg="#eeeeee",
            insertbackground="white",
            font=("Consolas", 11),
            wrap="word"
        )
        text.pack(fill="both", expand=True, padx=12, pady=(0, 12))
        text.insert("1.0", body.strip())
        text.config(state="disabled")

    def open_kpi_help(self, title, subtitle):
        key = f"{title} {subtitle}".upper()

        help_map = [
            (
                "STAV",
                """
CO TO JE:
Celkový stav OPS panelu a orchestrace.

CO TEĎ VIDÍŠ:
Pokud je zde AKTIVNÍ UPOZORNĚNÍ, systém neběží špatně, ale existují položky, které vyžadují kontrolu.

KDE KLIKNOUT:
1) PŘEHLED -> UPOZORNĚNÍ
2) AI OPS -> AI UPOZORNĚNÍ
3) OPRAVY -> ÚKOLY K OPRAVĚ

JAK STAV ZLEPŠIT:
- otevři nejvyšší CRITICAL / WARNING řádky,
- vyřeš fix tasky,
- spusť bezpečné retry nebo autonomní akci,
- po úspěšném běhu klikni OBNOVIT.
"""
            ),
            (
                "ČEKAJÍCÍ",
                """
CO TO JE:
Počet čekajících jobů / planner položek.

KDE KLIKNOUT:
1) PŘEHLED -> FRONTA KE SPUŠTĚNÍ
2) PLÁNOVAČ -> AUDIT ORCHESTRACE
3) tlačítko SPUSTIT DALŠÍ

JAK STAV ZLEPŠIT:
- spouštěj jen položky, které jsou RUN / bezpečné,
- větší dávky nech na druhé PC nebo noční harvest,
- pokud počet dlouho neklesá, zkontroluj cooldown a blokace.
"""
            ),
            (
                "ALERT",
                """
CO TO JE:
Souhrn varování a kritických upozornění.

KDE KLIKNOUT:
1) PŘEHLED -> UPOZORNĚNÍ
2) AI OPS -> AI UPOZORNĚNÍ
3) LOGY -> POSLEDNÍ LOGY JOBŮ

JAK STAV ZLEPŠIT:
- nejdřív řeš CRITICAL,
- potom WARNING,
- pokud jde o duplicitu, upravit parser na UPSERT / ON CONFLICT,
- pokud jde o timeout, menší batch nebo retry.
"""
            ),
            (
                "BEZPEČNÉ",
                """
CO TO JE:
Počet workerů, které panel vyhodnocuje jako bezpečné ke spuštění.

KDE KLIKNOUT:
1) WORKERY -> DETAIL WORKERŮ
2) PŘEHLED -> ZDRAVÍ WORKERŮ
3) PŘEHLED -> FRONTA KE SPUŠTĚNÍ

JAK STAV ZLEPŠIT:
- opravit workery s WARNING / ERROR,
- doplnit chybějící runtime evidence,
- snižovat počet blokovaných payloadů.
"""
            ),
            (
                "DŮVĚRA AI",
                """
CO TO JE:
Skóre jistoty, že doporučené spuštění je bezpečné a smysluplné.

KDE KLIKNOUT:
1) AI OPS -> DOPORUČENÍ SCHEDULERU
2) AI OPS -> FRONTA AI AKCÍ

JAK STAV ZLEPŠIT:
- zvýšit runtime stabilitu workerů,
- odstranit chyby v posledních bězích,
- doplnit audit evidence v OPS tabulkách.
"""
            ),
            (
                "AI KRIT",
                """
CO TO JE:
Počet kritických AI/OPS položek.

KDE KLIKNOUT:
1) AI OPS -> AI UPOZORNĚNÍ
2) OPRAVY -> OTEVŘENÉ

JAK STAV ZLEPŠIT:
- otevři detail upozornění,
- zjisti provider / sport / entitu,
- vytvoř nebo vyřeš fix task,
- po opravě spusť bezpečné ověření.
"""
            ),
            (
                "RETRY",
                """
CO TO JE:
Položky, které vypadají bezpečně pro opakované spuštění.

KDE KLIKNOUT:
1) PŘEHLED -> FRONTA KE SPUŠTĚNÍ
2) AI OPS -> DOPORUČENÍ SCHEDULERU
3) tlačítko SPUSTIT DALŠÍ

JAK STAV ZLEPŠIT:
- spouštěj retry po menších dávkách,
- sleduj LOGY,
- po doběhu ověř payloady a veřejné tabulky.
"""
            ),
            (
                "OPRAVY",
                """
CO TO JE:
Počet položek, které systém vyhodnotil jako opravitelné.

KDE KLIKNOUT:
1) OPRAVY -> ÚKOLY K OPRAVĚ
2) dvojklik na řádek úkolu

JAK STAV ZLEPŠIT:
- vyřeš otevřené fix tasky,
- označ je jako HOTOVO nebo IGNOROVAT,
- následně spusť kontrolní run.
"""
            ),
            (
                "BLOK",
                """
CO TO JE:
Blokované položky / zdroje, které panel nechce spouštět automaticky.

KDE KLIKNOUT:
1) AI OPS -> ZDRAVÍ PROVIDERŮ
2) ROADMAPA -> DATA GAP / CO CHYBÍ

JAK STAV ZLEPŠIT:
- ověř, jestli je problém provider, PRO plán, endpoint nebo parser,
- pro PRO položky neřešit hned, jen držet v plánu,
- pro parser chyby založit fix task.
"""
            ),
            (
                "AI SKÓRE",
                """
CO TO JE:
Souhrnné skóre kvality AI OPS vrstvy.

KDE KLIKNOUT:
1) AI OPS
2) ROADMAPA

JAK STAV ZLEPŠIT:
- doplnit auditní evidence,
- opravovat chyby workerů,
- ukládat výsledky autonomních akcí do learning tabulek.
"""
            ),
            (
                "READY",
                """
CO TO JE:
Počet entit / částí, které jsou připravené.

KDE KLIKNOUT:
1) ROADMAPA -> DOKONČENOST DATOVÉ VRSTVY
2) ROADMAPA -> DATA GAP / CO CHYBÍ

JAK STAV ZLEPŠIT:
- dokončovat NOT_IMPLEMENTED_YET,
- spouštět bezpečné ingest/merge workery,
- doplňovat people/media/odds vrstvy po sportech.
"""
            ),
            (
                "CHYBÍ",
                """
CO TO JE:
Počet chybějících nebo nedokončených částí.

KDE KLIKNOUT:
1) ROADMAPA -> DATA GAP / CO CHYBÍ
2) ROADMAPA -> TOP ÚKOLY VÝVOJE

JAK STAV ZLEPŠIT:
- vyber první položky s nejvyšší prioritou,
- vytvoř nebo spusť chybějící worker,
- doplň staging -> parser -> public merge.
"""
            ),
            (
                "PRO",
                """
CO TO JE:
Položky čekající na placený / PRO API plán.

KDE KLIKNOUT:
1) ROADMAPA -> DATA GAP / CO CHYBÍ
2) AI OPS -> ZDRAVÍ PROVIDERŮ

JAK STAV ZLEPŠIT:
- teď je nebrat jako chybu,
- připravit smoke testy a workery,
- po aktivaci PRO spustit kontrolované dávky.
"""
            ),
            (
                "BACKLOG",
                """
CO TO JE:
Počet vývojových úkolů.

KDE KLIKNOUT:
1) ROADMAPA -> TOP ÚKOLY VÝVOJE
2) ROADMAPA -> DETAIL BACKLOGU

JAK STAV ZLEPŠIT:
- řešit TOP priority,
- postupně převádět plánované entity do READY,
- dokončovat po jedné vrstvě / sportu.
"""
            ),
            (
                "AUTO RDY",
                """
CO TO JE:
Autonomní akce připravené ke spuštění.

KDE KLIKNOUT:
1) AI OPS -> AUTONOMNÍ FRONTA
2) tlačítko AUTONOMNÍ AKCE

JAK STAV ZLEPŠIT:
- spouštěj jen ověřené safe akce,
- sleduj runtime indikátor nahoře,
- po doběhu zkontroluj HISTORII AI AKCÍ.
"""
            ),
            (
                "AUTO BĚŽÍ",
                """
CO TO JE:
Aktuálně běžící autonomní akce.

KDE KLIKNOUT:
1) LOGY
2) AKTIVNÍ BĚHY
3) AI OPS -> HISTORIE AI AKCÍ

JAK STAV ZLEPŠIT:
- počkat na dokončení,
- neklikat opakovaně na spuštění,
- po doběhu kliknout OBNOVIT.
"""
            ),
            (
                "AUTO OK",
                """
CO TO JE:
Úspěšně dokončené autonomní akce.

KDE KLIKNOUT:
1) AI OPS -> HISTORIE AI AKCÍ
2) AI OPS -> POSLEDNÍ AUTONOMNÍ UČENÍ

JAK STAV ZLEPŠIT:
- kontrolovat, jestli úspěchy skutečně zvedají coverage,
- ukládat dobré výsledky do learning vrstvy.
"""
            ),
            (
                "AUTO ERR",
                """
CO TO JE:
Neúspěšné autonomní akce.

KDE KLIKNOUT:
1) AI OPS -> HISTORIE AI AKCÍ
2) LOGY -> detail posledního jobu
3) OPRAVY

JAK STAV ZLEPŠIT:
- zjistit důvod chyby,
- vytvořit fix task,
- opravit worker / endpoint / mapping,
- teprve potom spustit znovu.
"""
            ),
        ]

        for needle, body in help_map:
            if needle in key:
                self.show_help_window(f"ℹ DETAIL KPI :: {title}", body)
                return

        self.show_help_window(
            f"ℹ DETAIL KPI :: {title}",
            f"""
CO TO JE:
KPI karta panelu MatchMatrix.

NÁZEV:
{title}

SKUPINA:
{subtitle}

KDE KLIKNOUT:
Podívej se do odpovídající záložky dole podle názvu KPI.

JAK STAV ZLEPŠIT:
Začni v ROADMAPA / AI OPS / LOGY podle toho, jestli jde o data, autonomii nebo chybu běhu.
"""
        )

    def open_project_layer_help(self, layer):
        """
        V17.11.09 - DB NÁPOVĚDA PANELU

        CO TO JE:
        - Klikací nápověda pro horní vrstvy CORE / PEOPLE / MEDIA / ODDS / CELKEM.
        - Nejprve čte texty z ops.panel_help.
        - Pokud tabulka nebo řádek neexistuje, použije bezpečný fallback přímo z panelu.

        K ČEMU TO JE:
        - Texty nápovědy už nejsou natvrdo v Pythonu.
        - Můžeš je upravovat v DBeaveru bez úpravy panelu.
        """

        layer = str(layer).upper().strip()

        # CELKEM zatím nemá samostatný řádek v DB, proto jej mapujeme na celkový přehled.
        db_help_code = layer
        if layer in ("CELKEM", "TOTAL"):
            db_help_code = "CELKEM"

        rows = db_query(f"""
            SELECT
                help_code,
                title,
                co_to_je,
                k_cemu_to_je,
                kde_to_uvidime,
                jak_se_vyuzije,
                co_zvysi_procento,
                doporuceny_krok
            FROM ops.panel_help
            WHERE is_active = true
              AND help_code = '{db_help_code}'
            LIMIT 1;
        """)

        if rows and "CHYBA" not in rows[0]:
            row = rows[0]

            current_pct = ""
            try:
                if hasattr(self, "project_progress_values") and layer in self.project_progress_values:
                    current_pct = f"\nAKTUÁLNÍ PROCENTO V PANELU:\n{layer}: {self.project_progress_values.get(layer)} %\n"
            except Exception:
                current_pct = ""

            body = f"""
CO TO JE:
{row.get('co_to_je') or '-'}

K ČEMU TO JE:
{row.get('k_cemu_to_je') or '-'}

KDE TO UVIDÍME:
{row.get('kde_to_uvidime') or '-'}

JAK SE TO VYUŽIJE:
{row.get('jak_se_vyuzije') or '-'}

CO ZVÝŠÍ PROCENTO:
{row.get('co_zvysi_procento') or '-'}
{current_pct}
DOPORUČENÝ KROK:
{row.get('doporuceny_krok') or '-'}
"""

            self.show_help_window(
                row.get("title") or f"📊 DETAIL VRSTVY :: {layer}",
                body
            )
            return

        # Fallback, kdyby tabulka ops.panel_help ještě nebyla vytvořená
        # nebo pro vrstvu zatím neexistoval řádek.
        layer_help = {
            "CORE": """
CO TO JE:
CORE vrstva = sporty, ligy, týmy, zápasy, základní canonical data.

CO ZVÝŠÍ PROCENTO:
- další potvrzené fixtures/leagues/teams,
- úspěšný staging -> public merge,
- méně chyb v mappings.

KDE KLIKNOUT:
1) PŘEHLED -> SOUHRN ORCHESTRACE
2) PLÁNOVAČ
3) WORKERY
4) SPUSTIT DALŠÍ, pokud je ve frontě CORE_INGEST_V3

DOPORUČENÝ KROK:
Nejdřív dokončit bezpečné CORE runy u sportů, které už mají providera a parser.
""",
            "PEOPLE": """
CO TO JE:
PEOPLE vrstva = hráči, trenéři, profily, player stats, provider mapy.

CO ZVÝŠÍ PROCENTO:
- spuštění PEOPLE_PIPELINE,
- doplnění player_provider_map,
- doplnění player statistics,
- smoke testy providerů pro další sporty.

KDE KLIKNOUT:
1) PEOPLE záložka
2) WORKERY -> PEOPLE_PIPELINE
3) ROADMAPA -> DATA GAP / CO CHYBÍ

DOPORUČENÝ KROK:
Pokračovat po sportech: FB -> BK -> HK -> HB -> VB -> AFB.
""",
            "MEDIA": """
CO TO JE:
MEDIA vrstva = články, videa, highlights, matching na týmy/hráče/ligy.

CO ZVÝŠÍ PROCENTO:
- nové zdroje,
- parser článků,
- entity matching,
- thumbnail/video enrichment,
- merge do public.articles.

KDE KLIKNOUT:
1) HARVEST -> PEOPLE / MEDIA / ODDS READY
2) ROADMAPA -> TOP ÚKOLY VÝVOJE
3) LOGY -> media joby

DOPORUČENÝ KROK:
Rozšířit football media a připravit media workery pro další sporty.
""",
            "ODDS": """
CO TO JE:
ODDS vrstva = kurzy, bookmakeři, trhy, value detection, ticket intelligence.

CO ZVÝŠÍ PROCENTO:
- smoke test odds endpointů,
- odds staging,
- odds merge do public.odds,
- propojení odds na canonical matches.

KDE KLIKNOUT:
1) KURZY
2) PROVIDEŘI
3) ROADMAPA -> DATA GAP / CO CHYBÍ

DOPORUČENÝ KROK:
Zatím připravit workery a SQL. Velký růst přijde po aktivaci PRO účtu.
""",
            "CELKEM": """
CO TO JE:
Celkové procento projektu přes CORE / PEOPLE / MEDIA / ODDS.

CO ZVÝŠÍ PROCENTO:
- dokončené vrstvy po sportech,
- méně data gap položek,
- více READY entit,
- méně blokací a chyb.

KDE KLIKNOUT:
1) HARVEST
2) ROADMAPA
3) AI OPS
4) PŘEHLED

DOPORUČENÝ KROK:
Denní postup: nejdřív odstranit kritické chyby, potom spouštět bezpečné runy, potom doplnit vývojové gaps.
""",
        }

        self.show_help_window(
            f"📊 DETAIL VRSTVY :: {layer}",
            layer_help.get(layer, "Pro tuto vrstvu zatím není připraven detail v ops.panel_help.")
        )


    def normalize_help_code(self, text_value, prefix="SECTION"):
        """
        V17.11.10 - NORMALIZACE KÓDU NÁPOVĚDY

        CO TO JE:
        - Z názvu tabulky / sekce vytvoří stabilní help_code pro ops.panel_help.

        K ČEMU TO JE:
        - Každá tabulka v panelu může mít vlastní vysvětlení upravitelné v DB.
        """

        raw = str(text_value or "").upper()

        replacements = {
            "Á": "A", "Č": "C", "Ď": "D", "É": "E", "Ě": "E",
            "Í": "I", "Ň": "N", "Ó": "O", "Ř": "R", "Š": "S",
            "Ť": "T", "Ú": "U", "Ů": "U", "Ý": "Y", "Ž": "Z",
        }

        for src_char, dst_char in replacements.items():
            raw = raw.replace(src_char, dst_char)

        cleaned = []
        last_underscore = False

        for ch in raw:
            if ch.isalnum():
                cleaned.append(ch)
                last_underscore = False
            else:
                if not last_underscore:
                    cleaned.append("_")
                    last_underscore = True

        code = "".join(cleaned).strip("_")

        if not code:
            code = "OBECNE"

        return f"{prefix}_{code}"

    def open_section_help(self, title):
        """
        V17.11.10 - NÁPOVĚDA KE KAŽDÉ TABULCE

        CO TO JE:
        - Klikací nápověda pro všechny tabulkové sekce panelu.

        K ČEMU TO JE:
        - Panel je velký a ne každá sekce se používá denně.
        - Po kliknutí na nadpis tabulky se ukáže, co tabulka znamená,
          kde je v DB zdroj a jak se používá.

        JAK SE TO VYUŽIJE:
        - Primárně čte ops.panel_help.
        - Když text v DB zatím neexistuje, použije bezpečný fallback podle názvu sekce.
        """

        title = str(title or "").strip()
        help_code = self.normalize_help_code(title, "SECTION")

        rows = db_query(f"""
            SELECT
                help_code,
                title,
                co_to_je,
                k_cemu_to_je,
                kde_to_uvidime,
                jak_se_vyuzije,
                co_zvysi_procento,
                doporuceny_krok
            FROM ops.panel_help
            WHERE is_active = true
              AND help_code = '{help_code}'
            LIMIT 1;
        """)

        if rows and "CHYBA" not in rows[0]:
            row = rows[0]
            body = f"""
CO TO JE:
{row.get('co_to_je') or '-'}

K ČEMU TO JE:
{row.get('k_cemu_to_je') or '-'}

KDE TO UVIDÍME:
{row.get('kde_to_uvidime') or '-'}

JAK SE TO VYUŽIJE:
{row.get('jak_se_vyuzije') or '-'}

CO ZVÝŠÍ PROCENTO / KVALITU:
{row.get('co_zvysi_procento') or '-'}

DOPORUČENÝ KROK:
{row.get('doporuceny_krok') or '-'}
"""
            self.show_help_window(
                row.get("title") or f"ℹ DETAIL TABULKY :: {title}",
                body
            )
            return

        fallback = self.get_section_help_fallback(title)
        self.show_help_window(
            f"ℹ DETAIL TABULKY :: {title}",
            fallback
        )

    def get_section_help_fallback(self, title):
        """
        Bezpečná nápověda pro sekce, které ještě nemají řádek v ops.panel_help.
        """

        title_upper = str(title or "").upper()

        known = [
            (
                "FRONTA KE SPUŠTĚNÍ",
                """
CO TO JE:
Seznam položek, které systém vyhodnotil jako nejvhodnější pro další spuštění.

K ČEMU TO JE:
Pomáhá spustit další bezpečný worker bez ručního hledání v planneru.

KDE JE ZDROJ:
ops.v_run_next_queue_v1

JAK SE TO VYUŽIJE:
Klikni na řádek a použij SPUSTIT VYBRANÝ, nebo použij SPUSTIT DALŠÍ.

DOPORUČENÝ KROK:
Spouštěj pouze položky s rozhodnutím RUN a sleduj LOGY / AKTIVNÍ BĚHY.
"""
            ),
            (
                "STAV PLÁNOVAČE",
                """
CO TO JE:
Aktuální stav scheduleru a jeho rozhodování nad workery.

K ČEMU TO JE:
Ukazuje, zda worker může běžet, jakou má důvěru a zdraví.

KDE JE ZDROJ:
ops.v_scheduler_runtime_dashboard_v1

JAK SE TO VYUŽIJE:
Kontrola, jestli problém není v plánovači, cooldownu nebo nízké důvěře spuštění.
"""
            ),
            (
                "UPOZORNĚNÍ",
                """
CO TO JE:
Skupinový přehled warning/critical stavů v OPS vrstvě.

K ČEMU TO JE:
Rychle ukáže, co je potřeba řešit jako první.

KDE JE ZDROJ:
ops.v_runtime_alerts_grouped_v1

DOPORUČENÝ KROK:
Nejdřív řeš CRITICAL, potom WARNING. Detail hledej v LOGY nebo OPRAVY.
"""
            ),
            (
                "ZDRAVÍ WORKERŮ",
                """
CO TO JE:
Přehled stability workerů podle scheduler/runtime metrik.

K ČEMU TO JE:
Pomáhá poznat, které workery lze bezpečně spouštět autonomně.

KDE JE ZDROJ:
ops.v_scheduler_runtime_dashboard_v1

DOPORUČENÝ KROK:
Workery s WARNING/ERROR ověřit přes LOGY a případně vytvořit fix task.
"""
            ),
            (
                "HARVEST READINESS",
                """
CO TO JE:
Celková připravenost platformy na větší harvest dat.

K ČEMU TO JE:
Říká, jestli je bezpečné spouštět větší dávky a dry-run.

KDE JE ZDROJ:
ops.v_harvest_readiness_dashboard_v1

DOPORUČENÝ KROK:
Dostat slabé vrstvy nad bezpečnou hranici a potom pustit dry-run.
"""
            ),
            (
                "DRY-RUN",
                """
CO TO JE:
Kontrola připravenosti na první bezpečný test harvestu.

K ČEMU TO JE:
Ověří DB readiness, locky a celkový harvest stav.

KDE JE ZDROJ:
ops.v_harvest_dry_run_readiness_v1

DOPORUČENÝ KROK:
Pokud je stav NEAR_READY, dokončit poslední mezery. READY_FOR_DRY_RUN znamená připravit test.
"""
            ),
            (
                "LOCKY",
                """
CO TO JE:
Ochrana proti duplicitnímu spuštění workerů a běhům na více PC.

K ČEMU TO JE:
Před druhým PC a PRO harvestem musí být lock systém bezpečný.

KDE JE ZDROJ:
ops.v_harvest_locks_readiness_v1 / ops.v_active_runs_live_v1

DOPORUČENÝ KROK:
Aktivní nebo expirované locky kontroluj před větším během.
"""
            ),
            (
                "ODDS READINESS",
                """
CO TO JE:
Připravenost kurzové vrstvy podle sportů.

K ČEMU TO JE:
Ukazuje, kde máme zápasy s kurzy a kde je odds mezera.

KDE JE ZDROJ:
ops.v_harvest_odds_readiness_v1

DOPORUČENÝ KROK:
Připravit odds providery a po PRO aktivaci spustit kontrolovaný backfill.
"""
            ),
            (
                "ODDS PROVIDER ROADMAP",
                """
CO TO JE:
Plán providerů pro kurzovou vrstvu.

K ČEMU TO JE:
Ukazuje, které odds providery už máme, které čekají a jaká je priorita.

KDE JE ZDROJ:
ops.odds_provider_roadmap

DOPORUČENÝ KROK:
Nejdřív řešit providery s free_available nebo vysokou implementation_priority.
"""
            ),
            (
                "THEODDS",
                """
CO TO JE:
Historický provider kurzů, který už byl používán v panelu V11.

K ČEMU TO JE:
Slouží pro football odds refresh, matching na zápasy a audit nespárovaných kurzů.

KDE JE ZDROJ:
public.api_import_runs, public.odds, public.unmatched_theodds

DOPORUČENÝ KROK:
Použít SPUSTIT THEODDS a po doběhu zkontrolovat inserted odds / unmatched.
"""
            ),
            (
                "FOOTBALL-DATA",
                """
CO TO JE:
CSV provider pro historické fotbalové zápasy a výsledky.

K ČEMU TO JE:
Doplňuje dlouhou historii football core dat a odds z CSV zdrojů.

KDE JE ZDROJ:
public.api_import_runs, public.matches, public.odds

DOPORUČENÝ KROK:
Použít SPUSTIT FOOTBALL DATA a zkontrolovat změny ve snapshotu.
"""
            ),
            (
                "ALTERNATIVNÍ PROVIDEŘI",
                """
CO TO JE:
Přehled fallback a alternativních providerů pro sport/entity.

K ČEMU TO JE:
Když hlavní provider nestačí, panel ukáže náhradní zdroje.

KDE JE ZDROJ:
ops.v_provider_alternative_panel_v1 / provider routing view

DOPORUČENÝ KROK:
Před PRO harvestem ověřit free/paid dostupnost a hloubku dat.
"""
            ),
            (
                "REGISTRY WORKERŮ PROVIDERŮ",
                """
CO TO JE:
Evidence, které kombinace provider/sport/entity mají podporovaný worker.

K ČEMU TO JE:
Autonomous Brain podle toho pozná, co může opravdu spustit.

KDE JE ZDROJ:
ops.provider_worker_registry

DOPORUČENÝ KROK:
Doplnit registry pro kombinace, které jsou WAIT_NO_REGISTRY nebo CUSTOM_WORKER.
"""
            ),
            (
                "DB GOVERNANCE",
                """
CO TO JE:
Katalog pravdy nad DB objekty MatchMatrix.

K ČEMU TO JE:
Určuje, co je MASTER, ACTIVE, LEGACY, PANEL nebo OPS objekt.

KDE JE ZDROJ:
ops.database_object_governance

DOPORUČENÝ KROK:
Panel má používat hlavně objekty označené KEEP / ACTIVE / MASTER.
"""
            ),
            (
                "PEOPLE SUMMARY",
                """
CO TO JE:
Souhrn PEOPLE vrstvy podle sportů.

K ČEMU TO JE:
Ukazuje hráče, provider mapy, raw payloady a readiness sportu.

KDE JE ZDROJ:
ops.v_people_pipeline_summary_v1

DOPORUČENÝ KROK:
Sporty s RAW_PENDING_PARSE nebo DATA_GAP poslat do People pipeline/parseru.
"""
            ),
            (
                "PEOPLE DETAIL",
                """
CO TO JE:
Detail PEOPLE vrstvy podle providerů.

K ČEMU TO JE:
Ukazuje, který provider dodal hráče a kde chybí parser nebo merge.

KDE JE ZDROJ:
ops.v_people_pipeline_audit_v1

DOPORUČENÝ KROK:
Opravit providery s HAS_ERRORS nebo RAW_PENDING_PARSE.
"""
            ),
            (
                "AUTONOMOUS OPS BRAIN",
                """
CO TO JE:
Rozhodovací mozek MatchMatrix pro autonomní akce.

K ČEMU TO JE:
Vyhodnocuje doporučení, focus sportu, worker registry a bezpečnost spuštění.

KDE JE ZDROJ:
ops.v_autonomous_ops_brain_v5

DOPORUČENÝ KROK:
RUN položky lze použít jako kandidáty pro autonomní dispatcher.
"""
            ),
        ]

        for needle, body in known:
            if needle in title_upper:
                return body.strip()

        return f"""
CO TO JE:
Tabulka panelu MatchMatrix: {title}

K ČEMU TO JE:
Slouží jako operativní přehled v aktuální záložce panelu.

KDE TO UVIDÍME:
Aktuální záložka panelu.

JAK SE TO VYUŽIJE:
Použij ji pro rychlou kontrolu stavu, hledání problému nebo rozhodnutí o dalším kroku.

DOPORUČENÝ KROK:
Pokud chceš přesnější text, doplň do ops.panel_help řádek s help_code:
{self.normalize_help_code(title, 'SECTION')}
""".strip()

    # =====================================================
    # BUTTON
    # =====================================================

    def make_button(
        self,
        parent,
        text,
        color,
        cmd
    ):

        btn = tk.Button(
            parent,
            text=text,
            command=cmd,
            bg=color,
            fg="white",
            activebackground="#273145",
            activeforeground="white",
            font=("Segoe UI", 9, "bold"),
            width=17,
            bd=0
        )

        btn.pack(
            side="left",
            padx=5,
            pady=5
        )

        return btn

    # =====================================================
    # SECTION
    # =====================================================

    def create_section(
        self,
        parent,
        title,
        row,
        column,
        colspan=1
    ):

        frame = tk.Frame(
            parent,
            bg=PANEL_2
        )

        frame.grid(
            row=row,
            column=column,
            columnspan=colspan,
            sticky="nsew",
            padx=4,
            pady=4
        )

        title_label = tk.Label(
            frame,
            text=title,
            bg=PANEL_2,
            fg="#e879f9",
            font=("Segoe UI", 11, "bold")
        )
        title_label.pack(
            anchor="w",
            padx=8,
            pady=4
        )

        # V17.11.10: každá tabulka má klikací nápovědu.
        # Klik / dvojklik / pravé tlačítko na nadpis tabulky otevře vysvětlení.
        title_label.bind(
            "<Button-1>",
            lambda event, section_title=title: self.open_section_help(section_title)
        )
        title_label.bind(
            "<Double-1>",
            lambda event, section_title=title: self.open_section_help(section_title)
        )
        title_label.bind(
            "<Button-3>",
            lambda event, section_title=title: self.open_section_help(section_title)
        )
        title_label.configure(cursor="hand2")

        wrap = tk.Frame(
            frame,
            bg=PANEL_2
        )

        wrap.pack(
            fill="both",
            expand=True
        )

        tree = ttk.Treeview(
            wrap,
            show="headings"
        )

        vsb = ttk.Scrollbar(
            wrap,
            orient="vertical",
            command=tree.yview
        )

        hsb = ttk.Scrollbar(
            wrap,
            orient="horizontal",
            command=tree.xview
        )

        tree.configure(
            yscrollcommand=vsb.set,
            xscrollcommand=hsb.set
        )

        tree.bind(
            "<Configure>",
            lambda event, t=tree: self.auto_resize_tree_columns(t)
        )

        tree.grid(
            row=0,
            column=0,
            sticky="nsew"
        )

        vsb.grid(
            row=0,
            column=1,
            sticky="ns"
        )

        hsb.grid(
            row=1,
            column=0,
            sticky="ew"
        )

        wrap.rowconfigure(0, weight=1)
        wrap.columnconfigure(0, weight=1)

        tree.tag_configure(
            "green",
            background="#0d2a20"
        )

        tree.tag_configure(
            "yellow",
            background="#2a2213"
        )

        tree.tag_configure(
            "red",
            background="#2a0d15"
        )

        tree.tag_configure(
            "purple",
            background="#171020"
        )

        tree.tag_configure(
            "priority_high",
            background="#3a1222",
            foreground="#ffd2e3"
        )

        tree.tag_configure(
            "priority_medium",
            background="#2a2213",
            foreground="#ffe6a3"
        )

        tree.tag_configure(
            "priority_low",
            background="#0d2a20",
            foreground="#d8fff0"
        )

        tree.tag_configure(
            "critical_blink_on",
            background="#be123c",
            foreground="white"
        )

        tree.tag_configure(
            "critical_blink_off",
            background="#2a0d15",
            foreground="white"
        )

        return tree

    # =====================================================
    # LOG
    # =====================================================

    def create_log_section(
        self,
        parent,
        title,
        row,
        col
    ):

        frame = tk.Frame(
            parent,
            bg=PANEL_2
        )

        frame.grid(
            row=row,
            column=col,
            sticky="nsew",
            padx=4,
            pady=4
        )

        tk.Label(
            frame,
            text=title,
            bg=PANEL_2,
            fg="#e879f9",
            font=("Segoe UI", 11, "bold")
        ).pack(
            anchor="w",
            padx=8,
            pady=4
        )

        log = tk.Text(
            frame,
            bg="#09050f",
            fg=TEXT,
            insertbackground="white",
            font=("Consolas", 10),
            wrap="word"
        )

        log.pack(
            fill="both",
            expand=True,
            padx=5,
            pady=5
        )

        return log

    # =====================================================
    # REFRESH
    # =====================================================

    def refresh_all(self):

        self.load_project_progress_from_db()
        self.load_summary()
        self.load_ai_ops_summary()
        self.load_autonomous_queue_kpis()

        if self.current_tab == "DASHBOARD":
            self.load_orchestration_summary()
            self.load_feed()
            self.load_run_next()
            self.load_alerts()
            self.load_dashboard()
            self.load_worker_health()
            self.load_cooldown()
            self.load_active_runs()
            self.load_pending_payloads()
            self.load_sport_daily_budget()

        if self.current_tab == "AI OPS":
            self.load_ai_ops_health()
            self.load_ai_ops_alert_center()
            self.load_scheduler_autopilot()
            self.load_ai_action_queue()
            self.load_ai_action_history()
            self.load_autonomous_queue_summary()
            self.load_autonomous_learning_recent()
            self.load_autonomous_ops_brain()

        if self.current_tab == "ROADMAP":
            self.load_roadmap()

        if self.current_tab == "PEOPLE PIPELINE":
            self.load_people_pipeline()

        if self.current_tab == "HARVEST":
            self.load_harvest_dashboard()

        if self.current_tab == "ODDS":
            self.load_odds_dashboard()

        if self.current_tab == "PROVIDERS":
            self.load_providers_dashboard()

        if self.current_tab == "SCHEDULER":
            self.load_audit()

        if self.current_tab == "WORKERS":
            self.load_workers_detail()

        if self.current_tab == "ACTIVE RUNS":
            self.load_active_runs_detail()

        if self.current_tab == "PAYLOADS":
            self.load_payloads_detail()

        if self.current_tab == "LOGS":
            self.load_logs_detail()

        if self.current_tab == "FIX TASKS":
            self.load_fix_tasks()

        self.after(
            REFRESH_MS,
            self.refresh_all
        )

    # =====================================================
    # LOADERS
    # =====================================================

    def load_project_progress_from_db(self):
        """
        V17.11.14 - AKTUÁLNÍ STAV VRSTEV Z DB

        CO TO JE:
        - Horní hodnoty CORE / PEOPLE / MEDIA / ODDS / CELKEM už nejsou statické.

        K ČEMU TO JE:
        - Panel ukazuje skutečný průměr dokončenosti sportů z DB.

        KDE TO UVIDÍME:
        - Horní pruh AKTUÁLNÍ STAV VRSTEV.

        JAK SE TO VYUŽIJE:
        - Při každém refreshi se načte ops.v_sport_completion_dashboard_v2.
        - Pokud v2 ještě neexistuje, zkusí se fallback na v1.
        """

        sql_template = """
        SELECT
            ROUND(AVG(COALESCE(core_pct, 0)), 2) AS core_pct,
            ROUND(AVG(COALESCE(people_pct, 0)), 2) AS people_pct,
            ROUND(AVG(COALESCE(media_pct, 0)), 2) AS media_pct,
            ROUND(AVG(COALESCE(odds_pct, 0)), 2) AS odds_pct,
            ROUND(AVG(COALESCE(total_pct, 0)), 2) AS total_pct
        FROM {view_name};
        """

        rows = db_query(
            sql_template.format(
                view_name="ops.v_sport_completion_dashboard_v2"
            )
        )

        if rows and "CHYBA" in rows[0]:
            rows = db_query(
                sql_template.format(
                    view_name="ops.v_sport_completion_dashboard_v1"
                )
            )

        if not rows or "CHYBA" in rows[0]:
            return

        row = rows[0]

        mapping = {
            "CORE": row.get("core_pct"),
            "PEOPLE": row.get("people_pct"),
            "MEDIA": row.get("media_pct"),
            "ODDS": row.get("odds_pct"),
            "CELKEM": row.get("total_pct"),
        }

        for key, raw_value in mapping.items():
            try:
                value = int(round(float(raw_value or 0)))
            except Exception:
                value = 0

            value = max(0, min(100, value))
            self.project_progress_values[key] = value

            widget_info = getattr(self, "project_progress_widgets", {}).get(key)

            if widget_info:
                label = widget_info.get("percent_label")
                bar = widget_info.get("bar_fill")

                if label:
                    label.config(text=f"{value} %")

                if bar:
                    bar.place_configure(relwidth=value / 100)

        # Aktualizace posledního bodu grafu, aby legenda odpovídala DB.
        try:
            today = datetime.now().strftime("%m-%d")
            current_row = (
                today,
                self.project_progress_values.get("CORE", 0),
                self.project_progress_values.get("PEOPLE", 0),
                self.project_progress_values.get("MEDIA", 0),
                self.project_progress_values.get("ODDS", 0),
                self.project_progress_values.get("CELKEM", 0),
            )

            history = list(getattr(self, "project_progress_history", []))

            if history and history[-1][0] == today:
                history[-1] = current_row
            else:
                history.append(current_row)
                history = history[-5:]

            self.project_progress_history = history
            self.draw_project_timeline_chart()

        except Exception:
            pass


    def load_sport_daily_budget(self):
        """
        V17.11.02 - DENNÍ LIMIT SPORTŮ

        CO TO JE:
        - Načte OPS pohled ops.v_sport_daily_budget_monitor_v1.

        K ČEMU TO JE:
        - Při historickém harvestu vidíme využití limitu po sportech.
        - FREE režim ukáže typicky 100 / sport / den.
        - PRO režim později ukáže např. 7500 / sport / den podle provider_accounts.

        KDE TO UVIDÍME:
        - PŘEHLED -> DENNÍ LIMIT SPORTŮ.
        """

        sql = """
        SELECT
            sport_code,
            sport_name,
            mode,
            requests_used,
            requests_limit,
            requests_remaining,
            used_pct,
            budget_status,
            last_updated
        FROM ops.v_sport_daily_budget_monitor_v1
        ORDER BY
            used_pct DESC,
            sport_code;
        """

        self.populate_tree(
            self.sport_daily_budget_tree,
            db_query(sql)
        )

    def load_orchestration_summary(self):

        sql = """
        SELECT
            orchestration_layer,
            scheduler_state,
            rows_count,
            runtime_ready_count,
            scheduler_ready_count,
            panel_ready_count,
            ready_pct
        FROM ops.v_panel_orchestration_summary_v1
        ORDER BY
            orchestration_layer,
            scheduler_state;
        """

        self.populate_tree(
            self.orchestration_summary_tree,
            db_query(sql)
        )
        
    def load_summary(self):

        rows = db_query("""
            SELECT *
            FROM ops.v_operations_center_summary_v1;
        """)

        if not rows:
            return

        row = rows[0]

        self.kpi_stav.config(
            text=self.format_kpi_value(cz_status(row["operations_state"]))
        )

        self.kpi_pending.config(
            text=str(row["pending_jobs"])
        )

        self.kpi_alerty.config(
            text=str(row["alert_groups"])
        )

        self.kpi_safe.config(
            text=str(
                row["safe_autonomous_workers"]
            )
        )

        self.kpi_conf.config(
            text=str(
                row["avg_confidence_score"]
            )
        )

        color = row["operations_color"]

        if color == "GREEN":
            fg = GREEN
        elif color == "YELLOW":
            fg = YELLOW
        elif color == "RED":
            fg = RED
        else:
            fg = PURPLE

        if not self.worker_running:
            self.system_state.config(
                text=cz_status(row["operations_state"]),
                fg=fg
            )

    def load_ai_ops_summary(self):

        rows = db_query("""
            SELECT
                critical_count,
                safe_retry_count,
                auto_fixable_count,
                blocking_count,
                manual_review_count,
                avg_ai_ops_score
            FROM ops.v_ai_ops_summary_v1;
        """)

        if not rows:
            return

        row = rows[0]

        self.ai_critical.config(text=str(row.get("critical_count", 0)))
        self.ai_safe_retry.config(text=str(row.get("safe_retry_count", 0)))
        self.ai_auto_fix.config(text=str(row.get("auto_fixable_count", 0)))
        self.ai_blocking.config(text=str(row.get("blocking_count", 0)))
        ai_score = row.get("avg_ai_ops_score")

        if ai_score is None:
            ai_score = 0

        self.ai_score.config(text=str(ai_score))
        self.load_coverage_kpis()

    def load_ai_ops_health(self):

        sql = """
        SELECT
            provider,
            provider_health_score,
            provider_health_status,
            provider_presence_status,
            risk_score,
            execution_decision,
            recommended_cooldown_seconds,
            coverage_entities,
            ready_entities,
            blocked_entities,
            planned_entities,
            total_payloads,
            last_payload_at
        FROM ops.v_execution_risk_full
        ORDER BY
            risk_score DESC,
            provider;
        """

        self.populate_tree(
            self.ai_ops_health_tree,
            db_query(sql)
        ) 

    def load_ai_ops_alert_center(self):

        sql = """
        SELECT
            provider,
            ai_alert_severity,
            execution_decision,
            risk_score,
            ai_alert_message,
            recommended_cooldown_seconds,
            provider_presence_status,
            total_payloads,
            last_payload_at
        FROM ops.v_ai_ops_alert_center_v1
        ORDER BY
            risk_score DESC,
            provider;
        """

        self.populate_tree(
            self.ai_ops_alert_tree,
            db_query(sql)
        )

    def load_scheduler_autopilot(self):

        sql = """
        SELECT
            provider,
            execution_decision,
            recommended_action,
            recommendation_reason,
            risk_score,
            scheduler_priority,
            recommended_cooldown_seconds,
            provider_health_status,
            provider_presence_status,
            total_payloads,
            last_payload_at
        FROM ops.v_scheduler_autopilot_v1
        ORDER BY
            scheduler_priority DESC,
            provider;
        """

        self.populate_tree(
            self.scheduler_autopilot_tree,
            db_query(sql)
        )

    def load_ai_action_queue(self):

        sql = """
        SELECT
            action_id,
            provider,
            recommended_action,
            action_status,
            recommendation_reason,
            scheduler_priority,
            recommended_cooldown_seconds,
            execution_decision,
            provider_health_status,
            provider_presence_status,
            total_payloads,
            last_payload_at
        FROM ops.v_ai_ops_actions_queue_v1
        ORDER BY
            scheduler_priority DESC,
            provider;
        """

        self.populate_tree(
            self.ai_action_queue_tree,
            db_query(sql)
        )

    def load_ai_action_history(self):

        sql = """
        SELECT
            id,
            action_id,
            provider,
            action_type,
            action_status,
            execution_decision,
            execution_result,
            created_at
        FROM ops.v_ai_action_history_v1
        ORDER BY created_at DESC, id DESC
        LIMIT 100;
        """

        self.populate_tree(
            self.ai_action_history_tree,
            db_query(sql)
        )

    def load_autonomous_ops_brain(self):
        """
        V17.11.04 - AUTONOMOUS OPS BRAIN

        CO TO JE:
        - Načte rozhodovací view ops.v_autonomous_ops_brain_v5.

        K ČEMU TO JE:
        - Panel ukáže, co Brain doporučuje spustit, počkat nebo podržet.
        - Zatím pouze zobrazuje. Nic automaticky nespouští.

        KDE TO UVIDÍME:
        - AI OPS -> AUTONOMOUS OPS BRAIN.

        JAK SE TO VYUŽIJE:
        - Další krok bude launcher, který bude brát pouze bezpečné RUN akce.
        """

        sql = """
        SELECT
            brain_rank,
            sport_code,
            sport_name,
            entity,
            recommended_focus,
            focus_alignment_score,
            brain_score,
            brain_decision,
            brain_decision_reason,
            ai_decision,
            ai_risk_level,
            autonomous_safe,
            empty_runs,
            empty_pct,
            grouped_count,
            provider,
            league_id,
            season,
            run_group,
            generated_at
        FROM ops.v_autonomous_ops_brain_v5
        ORDER BY
            brain_rank ASC
        LIMIT 100;
        """

        self.populate_tree(
            self.autonomous_ops_brain_tree,
            db_query(sql)
        )

    def load_coverage_kpis(self):

        rows = db_query("""
            SELECT
                gap_status_code,
                item_count
            FROM ops.v_coverage_progress_dashboard_v1;
        """)

        ready = 0
        missing = 0
        paid = 0

        for row in rows:
            status = str(row.get("gap_status_code", ""))
            count = row.get("item_count", 0)

            if status == "READY":
                ready = count
            elif status == "NOT_IMPLEMENTED_YET":
                missing = count
            elif status == "WAIT_FOR_PAID_PLAN":
                paid = count

        self.coverage_ready.config(text=str(ready))
        self.coverage_missing.config(text=str(missing))
        self.coverage_paid.config(text=str(paid))

        backlog_rows = db_query("""
            SELECT COUNT(*) AS backlog_count
            FROM ops.development_task_queue
            WHERE task_status = 'PENDING';
        """)

        if backlog_rows:
            self.dev_backlog.config(
                text=str(backlog_rows[0].get("backlog_count", 0))
            )

    def load_autonomous_queue_kpis(self):

        rows = db_query("""
            SELECT
                execution_status,
                COUNT(*) AS status_count
            FROM ops.autonomous_execution_queue
            GROUP BY execution_status;
        """)

        counts = {
            "PENDING": 0,
            "RUNNING": 0,
            "SUCCESS": 0,
            "FAILED": 0,
        }

        for row in rows:
            status = str(row.get("execution_status", "")).upper()
            counts[status] = row.get("status_count", 0)

        self.autonomous_ready.config(text=str(counts.get("PENDING", 0)))
        self.autonomous_running.config(text=str(counts.get("RUNNING", 0)))
        self.autonomous_success.config(text=str(counts.get("SUCCESS", 0)))
        self.autonomous_failed.config(text=str(counts.get("FAILED", 0)))

    def load_autonomous_queue_summary(self):

        sql = """
        SELECT
            execution_status,
            COUNT(*) AS status_count,
            MAX(created_at) AS last_created_at,
            MAX(started_at) AS last_started_at,
            MAX(finished_at) AS last_finished_at
        FROM ops.autonomous_execution_queue
        GROUP BY execution_status
        ORDER BY
            CASE execution_status
                WHEN 'PENDING' THEN 1
                WHEN 'RUNNING' THEN 2
                WHEN 'SUCCESS' THEN 3
                WHEN 'FAILED' THEN 4
                ELSE 99
            END;
        """

        self.populate_tree(
            self.autonomous_queue_summary_tree,
            db_query(sql)
        )

    def load_autonomous_learning_recent(self):

        sql = """
        SELECT
            id,
            provider,
            sport_code,
            entity,
            repair_action,
            outcome_code,
            outcome_note,
            created_at
        FROM ops.repair_outcome_learning
        ORDER BY created_at DESC, id DESC
        LIMIT 20;
        """

        self.populate_tree(
            self.autonomous_learning_tree,
            db_query(sql)
        )

    def load_harvest_dashboard(self):
        """
        V17.11.07 - HARVEST READINESS

        CO TO JE:
        - Načítá hotová view ze série 117.

        K ČEMU TO JE:
        - Jeden přehled pro rozhodnutí, jestli je platforma připravená na velký harvest,
          dry-run a provoz na druhém PC.
        """

        readiness_sql = """
        SELECT *
        FROM ops.v_harvest_readiness_dashboard_v1;
        """

        dry_run_sql = """
        SELECT
            overall_harvest_readiness,
            db_ready_percent,
            people_ready_percent,
            media_ready_percent,
            panel_ready_percent,
            locks_ready_percent,
            dry_run_score,
            dry_run_status,
            recommendation_cz
        FROM ops.v_harvest_dry_run_readiness_v1;
        """

        recommendations_sql = """
        SELECT
            milestone_code,
            milestone_name,
            category,
            status,
            progress_percent,
            risk_level,
            risk_color,
            recommendation_cz
        FROM ops.v_harvest_recommendations_v1
        ORDER BY
            CASE risk_level
                WHEN 'CRITICAL' THEN 1
                WHEN 'HIGH' THEN 2
                WHEN 'MEDIUM' THEN 3
                WHEN 'LOW' THEN 4
                ELSE 9
            END,
            progress_percent ASC;
        """

        locks_sql = """
        SELECT *
        FROM ops.v_harvest_locks_readiness_v1;
        """

        layers_sql = """
        SELECT
            'PEOPLE'::text AS layer_name,
            sport_code,
            sport_name,
            people_readiness_score::numeric AS readiness_score,
            people_readiness_status AS readiness_status,
            recommendation_cz
        FROM ops.v_harvest_people_readiness_v1

        UNION ALL

        SELECT
            'MEDIA'::text AS layer_name,
            'ALL'::text AS sport_code,
            'Media celkem'::text AS sport_name,
            media_readiness_score::numeric AS readiness_score,
            media_readiness_status AS readiness_status,
            recommendation_cz
        FROM ops.v_harvest_media_readiness_v1

        UNION ALL

        SELECT
            'ODDS'::text AS layer_name,
            sport_code,
            sport_name,
            odds_readiness_score::numeric AS readiness_score,
            odds_readiness_status AS readiness_status,
            recommendation_cz
        FROM ops.v_harvest_odds_readiness_v1
        ORDER BY
            sport_code,
            layer_name;
        """

        self.populate_tree(self.harvest_readiness_tree, db_query(readiness_sql))
        self.populate_tree(self.harvest_dry_run_tree, db_query(dry_run_sql))
        self.populate_tree(self.harvest_recommendations_tree, db_query(recommendations_sql))
        self.populate_tree(self.harvest_locks_tree, db_query(locks_sql))
        self.populate_tree(self.harvest_layers_tree, db_query(layers_sql))

    def load_odds_dashboard(self):
        """
        V17.11.07 - ODDS / THEODDS / FOOTBALL DATA

        CO TO JE:
        - Přehled kurzů, TheOdds a Football-Data převzatý funkčně z V11.

        K ČEMU TO JE:
        - Vidíme, jestli odds vrstva roste, co je nespárované a kdy běželi provideri.
        """

        readiness_sql = """
        SELECT
            sport_code,
            sport_name,
            total_matches,
            matches_with_odds,
            odds_rows,
            bookmakers_count,
            market_outcomes_count,
            unmatched_theodds_count,
            match_odds_coverage_pct,
            odds_readiness_score,
            odds_readiness_status,
            recommendation_cz
        FROM ops.v_harvest_odds_readiness_v1
        ORDER BY
            odds_readiness_score ASC,
            sport_code;
        """

        roadmap_sql = """
        SELECT
            provider_code,
            provider_name,
            sport_code,
            free_available,
            paid_available,
            historical_odds,
            live_odds,
            pre_match_odds,
            implementation_priority,
            provider_status,
            next_action,
            notes,
            updated_at
        FROM ops.odds_provider_roadmap
        ORDER BY
            implementation_priority ASC NULLS LAST,
            provider_name;
        """

        provider_runs_sql = """
        SELECT
            source,
            COUNT(*) AS run_count,
            (ARRAY_AGG(status ORDER BY started_at DESC NULLS LAST, id DESC))[1] AS last_status,
            MAX(started_at) AS last_started_at,
            MAX(finished_at) AS last_finished_at
        FROM public.api_import_runs
        WHERE source IN ('theodds', 'football_data')
        GROUP BY source
        ORDER BY source;
        """

        counts_sql = """
        SELECT
            (SELECT COUNT(*) FROM public.odds) AS odds_count,
            (SELECT COUNT(*) FROM public.bookmakers) AS bookmaker_count,
            (SELECT COUNT(*) FROM public.market_outcomes) AS market_count,
            (SELECT COUNT(*) FROM public.unmatched_theodds) AS unmatched_count,
            (SELECT COUNT(*) FROM public.api_import_runs WHERE source = 'theodds') AS theodds_runs,
            (SELECT COUNT(*) FROM public.api_import_runs WHERE source = 'football_data') AS football_data_runs;
        """

        self.populate_tree(self.odds_readiness_tree, db_query(readiness_sql))
        self.populate_tree(self.odds_provider_roadmap_tree, db_query(roadmap_sql))
        self.populate_tree(self.odds_provider_runs_tree, db_query(provider_runs_sql))
        self.populate_tree(self.odds_counts_tree, db_query(counts_sql))

    def load_providers_dashboard(self):
        """
        V17.11.07 - PROVIDEŘI

        CO TO JE:
        - Přehled provider switch, alternativ, strategie a worker registry.

        K ČEMU TO JE:
        - Ukáže, kterého providera použít, kde je fallback a co je/není spustitelné.
        """

        switch_sql = """
        SELECT *
        FROM ops.v_provider_switch_panel_v1
        LIMIT 200;
        """

        alternatives_sql = """
        SELECT *
        FROM ops.v_provider_alternative_panel_v1
        LIMIT 200;
        """

        strategy_sql = """
        SELECT *
        FROM ops.v_provider_strategy_engine_v1
        LIMIT 200;
        """

        registry_sql = """
        SELECT
            provider,
            sport_code,
            entity,
            worker_type,
            is_supported AS worker_supported,
            is_active AS worker_active,
            notes AS worker_registry_note
        FROM ops.provider_worker_registry
        ORDER BY
            provider,
            sport_code,
            entity
        LIMIT 300;
        """

        governance_sql = """
        SELECT
            schema_name,
            object_name,
            domain_area,
            owner_layer,
            app_usage,
            migration_action,
            updated_at
        FROM ops.database_object_governance
        WHERE COALESCE(app_usage, '') ILIKE '%Panel%'
           OR COALESCE(domain_area, '') IN ('PANEL', 'PROVIDER', 'OPS', 'AI')
        ORDER BY
            domain_area,
            owner_layer,
            object_name
        LIMIT 300;
        """

        self.populate_tree(self.provider_switch_tree, db_query(switch_sql))
        self.populate_tree(self.provider_alternative_tree, db_query(alternatives_sql))
        self.populate_tree(self.provider_strategy_tree, db_query(strategy_sql))
        self.populate_tree(self.provider_worker_registry_tree, db_query(registry_sql))
        self.populate_tree(self.database_governance_tree, db_query(governance_sql))

    def load_people_pipeline(self):
        """
        V17.11.06 - PEOPLE PIPELINE SUMMARY + DETAIL

        CO TO JE:
        - Načte ops.v_people_pipeline_summary_v1 a ops.v_people_pipeline_audit_v1.

        K ČEMU TO JE:
        - Horní tabulka ukazuje PEOPLE stav za celý sport.
        - Dolní tabulka ukazuje detail podle providerů.

        KDE TO UVIDÍME:
        - PEOPLE -> PEOPLE SUMMARY + PEOPLE DETAIL.
        """

        summary_sql = """
        SELECT
            sport_code,
            providers,
            raw_payloads,
            raw_pending,
            raw_parsed,
            raw_error,
            staging_players,
            staging_distinct_players,
            public_players,
            provider_maps,
            ROUND(coverage_pct, 2) AS coverage_pct,
            sport_people_status
        FROM ops.v_people_pipeline_summary_v1
        ORDER BY
            CASE sport_people_status
                WHEN 'READY' THEN 1
                WHEN 'PARTIAL' THEN 2
                WHEN 'READY_FOR_MERGE' THEN 3
                WHEN 'RAW_PENDING_PARSE' THEN 4
                WHEN 'HAS_ERRORS' THEN 5
                ELSE 9
            END,
            coverage_pct DESC,
            sport_code;
        """

        detail_sql = """
        SELECT
            provider,
            sport_code,
            raw_payloads,
            raw_pending,
            raw_parsed,
            raw_error,
            staging_players,
            staging_distinct_players,
            public_players,
            provider_maps,
            ROUND(public_coverage_pct, 2) AS public_coverage_pct,
            people_status
        FROM ops.v_people_pipeline_audit_v1
        ORDER BY
            sport_code,
            CASE people_status
                WHEN 'READY' THEN 1
                WHEN 'PARTIAL' THEN 2
                WHEN 'READY_FOR_MERGE' THEN 3
                WHEN 'RAW_PENDING_PARSE' THEN 4
                WHEN 'HAS_ERRORS' THEN 5
                ELSE 9
            END,
            provider;
        """

        self.populate_tree(
            self.people_pipeline_summary_tree,
            db_query(summary_sql)
        )

        self.populate_tree(
            self.people_pipeline_detail_tree,
            db_query(detail_sql)
        )

    def load_roadmap(self):

        self.load_coverage_progress()
        self.load_top_development_tasks()
        self.load_data_gap()
        self.load_development_queue_summary()
        self.load_development_queue()

    def load_coverage_progress(self):
        """
        V17.11.03 - SPORT COMPLETION DASHBOARD

        CO TO JE:
        - Načte přehled dokončenosti sportů z ops.v_sport_completion_dashboard_v2.

        K ČEMU TO JE:
        - Ukáže, který sport je nejdál a kde chybí CORE / PEOPLE / MEDIA / ODDS.
        - Pomůže určit další prioritu před autonomním řízením 111_S.

        KDE TO UVIDÍME:
        - ROADMAPA -> DOKONČENOST SPORTŮ.

        JAK SE TO VYUŽIJE:
        - Panel rychle ukáže nejslabší sport a doporučené zaměření.
        - Autonomous OPS Brain později použije stejné view pro výběr další akce.
        """

        sql = """
        SELECT
            sport_code,
            sport_name,
            mode,
            ROUND(core_pct, 2) AS core_pct,
            ROUND(people_pct, 2) AS people_pct,
            ROUND(media_pct, 2) AS media_pct,
            ROUND(odds_pct, 2) AS odds_pct,
            ROUND(total_pct, 2) AS total_pct,
            core_pending,
            requests_used,
            requests_limit,
            requests_remaining,
            ROUND(budget_used_pct, 2) AS budget_used_pct,
            budget_status,
            sport_readiness,
            top_priority_rank,
            recommended_focus
        FROM ops.v_sport_completion_dashboard_v2
        ORDER BY
            top_priority_rank ASC NULLS LAST,
            total_pct ASC NULLS LAST,
            sport_code;
        """

        self.populate_tree(
            self.coverage_progress_tree,
            db_query(sql)
        )

    def load_top_development_tasks(self):

        sql = """
        SELECT *
        FROM ops.v_top_development_tasks_panel_v1
        LIMIT 30;
        """

        self.populate_tree(
            self.top_development_tasks_tree,
            db_query(sql)
        )

    def load_data_gap(self):

        sql = """
        SELECT *
        FROM ops.v_data_gap_panel_v2
        ORDER BY
            "Status",
            "Sport",
            "Entita",
            "Provider"
        LIMIT 120;
        """

        self.populate_tree(
            self.data_gap_tree,
            db_query(sql)
        )

    def load_development_queue_summary(self):

        sql = """
        SELECT *
        FROM ops.v_development_task_queue_panel_summary_v1
        ORDER BY
            "Stav",
            "Nejvyšší priorita" DESC;
        """

        self.populate_tree(
            self.development_queue_summary_tree,
            db_query(sql)
        )

    def load_development_queue(self):

        sql = """
        SELECT
            id AS "ID",
            sport_code AS "Sport",
            entity AS "Entita",
            priority_score AS "Priorita",
            task_title AS "Úkol",
            task_description AS "Popis",
            action_code AS "Typ",
            task_status AS "Stav",
            created_at AS "Vytvořeno"
        FROM ops.v_development_task_queue_v1
        LIMIT 120;
        """

        self.populate_tree(
            self.development_queue_tree,
            db_query(sql)
        )

    def load_feed(self):

        sql = """
        SELECT
            feed_type,
            object_name,
            severity,
            message,
            event_time
        FROM ops.v_runtime_operations_center_feed_v1
        ORDER BY event_time DESC
        LIMIT 80;
        """

        self.populate_tree(
            self.feed_tree,
            db_query(sql)
        )

    def load_run_next(self):

        sql = """
        SELECT
            run_next_rank,
            worker_code,
            execution_decision,
            retry_policy,
            final_priority_score
        FROM ops.v_run_next_queue_v1
        ORDER BY run_next_rank;
        """

        self.populate_tree(
            self.run_next_tree,
            db_query(sql)
        )

    def load_alerts(self):

        sql = """
        SELECT
            alert_type,
            source_object,
            alert_severity,
            alert_count,
            last_alert_message,
            last_alert_time
        FROM ops.v_runtime_alerts_grouped_v1
        ORDER BY last_alert_time DESC;
        """

        self.populate_tree(
            self.alerts_tree,
            db_query(sql)
        )

    def load_dashboard(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            dashboard_state
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY execution_confidence_score DESC;
        """

        self.populate_tree(
            self.dashboard_tree,
            db_query(sql)
        )

    def load_worker_health(self):

        sql = """
        SELECT
            worker_code,
            scheduler_health_tier,
            recent_health_tier,
            execution_confidence_score,
            dashboard_state,
            autonomous_safe
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY execution_confidence_score DESC;
        """

        self.populate_tree(
            self.worker_health_tree,
            db_query(sql)
        )

    def load_workers_detail(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            autonomous_safe,
            included_in_run_next,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            dashboard_state
        FROM ops.v_scheduler_runtime_dashboard_v1
        ORDER BY
            execution_confidence_score DESC,
            worker_code;
        """

        self.populate_tree(
            self.workers_detail_tree,
            db_query(sql)
        )

    def open_worker_detail(self, event):

        selected = self.workers_detail_tree.selection()

        if not selected:
            return

        item = self.workers_detail_tree.item(selected[0])
        values = item.get("values", [])

        if not values:
            return

        worker_code = str(values[0]).strip()

        detail_window = tk.Toplevel(self)
        detail_window.title(f"DETAIL WORKERU :: {worker_code}")
        detail_window.geometry("1500x850")
        detail_window.configure(bg=BG)

        tk.Label(
            detail_window,
            text=f"🧩 DETAIL WORKERU :: {worker_code}",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 20, "bold")
        ).pack(anchor="w", padx=15, pady=10)

        body = tk.Frame(detail_window, bg=BG)
        body.pack(fill="both", expand=True, padx=10, pady=10)

        body.columnconfigure(0, weight=1)
        body.columnconfigure(1, weight=1)
        body.rowconfigure(0, weight=1)
        body.rowconfigure(1, weight=1)

        # 1) Aktuální runtime dashboard
        current_tree = self.create_section(
            body,
            "📊 AKTUÁLNÍ STAV WORKERU",
            0,
            0
        )

        sql_current = f"""
        SELECT
            worker_code,
            execution_decision,
            execution_confidence_score,
            scheduler_health_tier,
            recent_health_tier,
            dashboard_state,
            autonomous_safe
        FROM ops.v_scheduler_runtime_dashboard_v1
        WHERE worker_code = '{worker_code}';
        """

        self.populate_tree(
            current_tree,
            db_query(sql_current)
        )

        # 2) RUN NEXT audit
        audit_tree = self.create_section(
            body,
            "🧭 AUDIT RUN NEXT",
            0,
            1
        )

        sql_audit = f"""
        SELECT
            worker_code,
            execution_decision,
            autonomous_safe,
            included_in_run_next,
            audit_reason
        FROM ops.v_run_next_audit_v1
        WHERE worker_code = '{worker_code}';
        """

        self.populate_tree(
            audit_tree,
            db_query(sql_audit)
        )

        # 3) Poslední orchestration události
        events_tree = self.create_section(
            body,
            "🕒 POSLEDNÍ UDÁLOSTI",
            1,
            0
        )

        sql_events = f"""
        SELECT
            feed_type,
            object_name,
            severity,
            message,
            event_time
        FROM ops.v_runtime_operations_center_feed_v1
        WHERE
            UPPER(COALESCE(object_name, '')) LIKE UPPER('%{worker_code}%')
            OR UPPER(COALESCE(message, '')) LIKE UPPER('%{worker_code}%')
        ORDER BY event_time DESC
        LIMIT 30;
        """

        self.populate_tree(
            events_tree,
            db_query(sql_events)
        )

        # 4) Alerty k workeru
        alerts_tree = self.create_section(
            body,
            "🔔 UPOZORNĚNÍ WORKERU",
            1,
            1
        )

        sql_alerts = f"""
        SELECT
            alert_type,
            source_object,
            alert_severity,
            alert_count,
            last_alert_message,
            last_alert_time
        FROM ops.v_runtime_alerts_grouped_v1
        WHERE
            UPPER(COALESCE(source_object, '')) LIKE UPPER('%{worker_code}%')
            OR UPPER(COALESCE(last_alert_message, '')) LIKE UPPER('%{worker_code}%')
        ORDER BY last_alert_time DESC
        LIMIT 30;
        """

        self.populate_tree(
            alerts_tree,
            db_query(sql_alerts)
        )

    def load_audit(self):

        sql = """
        SELECT
            worker_code,
            execution_decision,
            autonomous_safe,
            included_in_run_next,
            audit_reason
        FROM ops.v_run_next_audit_v1
        ORDER BY included_in_run_next DESC;
        """

        self.populate_tree(
            self.audit_tree,
            db_query(sql)
        )

    def load_cooldown(self):

        sql = """
        SELECT
            league_id,
            season,
            empty_runs,
            empty_pct,
            planner_target_state,
            suggested_retry_after,
            suggested_action
        FROM ops.v_planner_cooldown_candidates_v1
        ORDER BY target_rank, empty_runs DESC;
        """

        self.populate_tree(
            self.cooldown_tree,
            db_query(sql)
        )

    def load_active_runs(self):

        sql = """
        SELECT
            lock_name,
            owner_id,
            acquired_at,
            heartbeat_at,
            running_seconds,
            heartbeat_age_seconds,
            seconds_to_expire,
            live_state,
            live_color,
            note,
            is_active
        FROM ops.v_active_runs_live_v1
        ORDER BY acquired_at DESC;
        """

        self.populate_tree(
            self.active_runs_tree,
            db_query(sql)
        )

    def load_active_runs_detail(self):

        sql = """
        SELECT
            lock_name,
            owner_id,
            acquired_at,
            heartbeat_at,
            expires_at,
            running_seconds,
            heartbeat_age_seconds,
            seconds_to_expire,
            live_state,
            live_color,
            note,
            created_at,
            updated_at,
            is_active
        FROM ops.v_active_runs_live_v1
        ORDER BY acquired_at DESC;
        """

        self.populate_tree(
            self.active_runs_detail_tree,
            db_query(sql)
        )

    def load_pending_payloads(self):

        sql = """
        SELECT
            provider,
            sport_code,
            entity_type,
            parse_status,
            COUNT(*) AS pending_rows
        FROM staging.stg_api_payloads
        WHERE LOWER(parse_status) IN (
            'pending',
            'failed',
            'empty'
        )
        GROUP BY
            provider,
            sport_code,
            entity_type,
            parse_status
        ORDER BY pending_rows DESC;
        """

        self.populate_tree(
            self.pending_payloads_tree,
            db_query(sql)
        )

    def load_payloads_detail(self):

        sql = """
        SELECT
            provider,
            sport_code,
            entity_type,
            parse_status,
            COUNT(*) AS payload_count
        FROM staging.stg_api_payloads
        GROUP BY
            provider,
            sport_code,
            entity_type,
            parse_status
        ORDER BY
            payload_count DESC,
            provider;
        """

        self.populate_tree(
            self.payloads_detail_tree,
            db_query(sql)
        )

    def open_payload_group_detail(self, event):

        selected = self.payloads_detail_tree.selection()

        if not selected:
            return

        item = self.payloads_detail_tree.item(selected[0])
        values = item.get("values", [])

        if len(values) < 4:
            return

        provider = str(values[0]).strip()
        sport_code = str(values[1]).strip()
        entity_type = str(values[2]).strip()
        parse_status = str(values[3]).strip()

        detail_window = tk.Toplevel(self)
        detail_window.title(
            f"DETAIL PAYLOADU :: {provider} / {sport_code} / {entity_type} / {parse_status}"
        )
        detail_window.geometry("1500x850")
        detail_window.configure(bg=BG)

        tk.Label(
            detail_window,
            text=f"📦 DETAIL PAYLOADU :: {provider} / {sport_code} / {entity_type} / {parse_status}",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 20, "bold")
        ).pack(anchor="w", padx=15, pady=10)

        body = tk.Frame(detail_window, bg=BG)
        body.pack(fill="both", expand=True, padx=10, pady=10)

        body.columnconfigure(0, weight=1)
        body.rowconfigure(0, weight=1)

        tree = self.create_section(
            body,
            "POSLEDNÍ PAYLOADY",
            0,
            0
        )

        def on_double_click(event):

            selected = tree.selection()

            if not selected:
                return

            item = tree.item(selected[0])

            vals = item.get("values", [])

            if len(vals) < 9:
                return

            parse_message = vals[8]

            self.open_parse_message_detail(parse_message)

        sql = f"""
        SELECT
            id,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            parse_status,
            parse_message,
            CASE
                WHEN LOWER(COALESCE(parse_message, '')) LIKE '%duplicate key%'
                OR LOWER(COALESCE(parse_message, '')) LIKE '%uniqueviolation%'
                    THEN 'UPSERT / ON CONFLICT'
                WHEN LOWER(COALESCE(parse_message, '')) LIKE '%timeout%'
                    THEN 'RETRY / MENŠÍ BATCH'
                WHEN LOWER(COALESCE(parse_message, '')) LIKE '%json%'
                    THEN 'KONTROLA JSON MAPPINGU'
                WHEN LOWER(COALESCE(parse_message, '')) LIKE '%empty%'
                    THEN 'OVĚŘIT SCOPE / COVERAGE'
                ELSE 'RUČNÍ KONTROLA'
            END AS fix_hint,
            fetched_at,
            created_at
        FROM staging.stg_api_payloads
        WHERE provider = '{provider}'
        AND sport_code = '{sport_code}'
        AND entity_type = '{entity_type}'
        AND parse_status = '{parse_status}'
        ORDER BY fetched_at DESC
        LIMIT 100;
        """

        self.populate_tree(
            tree,
            db_query(sql)
        )

        def on_payload_double_click(event):

            selected = tree.selection()

            if not selected:
                return

            column_id = tree.identify_column(event.x)

            try:
                col_index = int(column_id.replace("#", "")) - 1
            except Exception:
                col_index = -1

            cols = list(tree["columns"])

            if col_index >= 0 and col_index < len(cols):
                col_name = cols[col_index]

                if col_name == "parse_message":
                    item = tree.item(selected[0])
                    vals = item.get("values", [])

                    if col_index < len(vals):
                        self.open_parse_message_detail(vals[col_index])

                    return

            self.open_payload_detail(event, tree)


        tree.bind("<Double-1>", on_payload_double_click)


    def open_payload_detail(self, event, source_tree):

        selected = source_tree.selection()

        if not selected:
            return

        item = source_tree.item(selected[0])
        values = item.get("values", [])

        if not values:
            return

        payload_id = values[0]

        sql = f"""
        SELECT
            id,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            external_id,
            season,
            parse_status,
            parse_message,
            fetched_at,
            payload_json
        FROM staging.stg_api_payloads
        WHERE id = {payload_id};
        """

        rows = db_query(sql)

        if not rows:
            return

        row = rows[0]

        diagnostic = ""
        msg = str(row.get("parse_message", "")).lower()

        if "uniqueviolation" in msg or "duplicate key" in msg:
            diagnostic = """
    DIAGNOSTIKA:
    - Duplicitní záznam ve staging/public tabulce.
    - Provider pravděpodobně není problém.
    - Parser se snaží vložit už existující kombinaci klíčů.
    - Doporučení: upravit parser na UPSERT / ON CONFLICT DO UPDATE nebo DO NOTHING.
    """

        elif "timeout" in msg:
            diagnostic = """
    DIAGNOSTIKA:
    - Timeout při zpracování nebo stahování.
    - Doporučení: retry, delší timeout nebo menší batch.
    """

        elif "json" in msg:
            diagnostic = """
    DIAGNOSTIKA:
    - Problém se strukturou JSON payloadu.
    - Doporučení: ověřit parser mapping a raw payload.
    """

        elif "empty" in msg:
            diagnostic = """
    DIAGNOSTIKA:
    - Provider vrátil prázdnou odpověď.
    - Doporučení: ověřit league/season scope nebo provider coverage.
    """

        win = tk.Toplevel(self)
        win.title(f"DETAIL JSON PAYLOADU :: {payload_id}")
        win.geometry("1500x850")
        win.configure(bg=BG)

        tk.Label(
            win,
            text=f"📦 DETAIL JSON PAYLOADU :: {payload_id}",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 20, "bold")
        ).pack(anchor="w", padx=15, pady=10)

        text = tk.Text(
            win,
            bg="#09050f",
            fg="#dddddd",
            insertbackground="white",
            font=("Consolas", 10),
            wrap="word"
        )

        text.pack(fill="both", expand=True, padx=10, pady=10)

        output = f"""
    ID: {row.get("id")}
    PROVIDER: {row.get("provider")}
    SPORT: {row.get("sport_code")}
    ENTITY: {row.get("entity_type")}
    ENDPOINT: {row.get("endpoint_name")}
    EXTERNAL_ID: {row.get("external_id")}
    SEASON: {row.get("season")}
    STATUS: {row.get("parse_status")}
    MESSAGE: {row.get("parse_message")}
    FETCHED_AT: {row.get("fetched_at")}

    ----------------------------------------
    {diagnostic}
    ----------------------------------------
    PAYLOAD JSON PREVIEW:
    {str(row.get("payload_json"))[:6000]}

    ----------------------------------------
    INFO:
    Zobrazen je pouze náhled prvních 6000 znaků kvůli rychlosti panelu.
    Celý JSON je dostupný přes tlačítko KOPÍROVAT CELÝ JSON.
    """
        full_payload_json = str(row.get("payload_json"))

        def copy_full_json():
            win.clipboard_clear()
            win.clipboard_append(full_payload_json)
            win.update()

        def create_fix_task():

            provider = row.get("provider")
            sport = row.get("sport_code")
            entity = row.get("entity_type")
            endpoint = row.get("endpoint_name")
            status = row.get("parse_status")
            message = row.get("parse_message")

            suggested_fix = "UNKNOWN"

            if "duplicate key" in str(message).lower():
                suggested_fix = "UPSERT / ON CONFLICT"

            elif "timeout" in str(message).lower():
                suggested_fix = "INCREASE TIMEOUT"

            elif "403" in str(message):
                suggested_fix = "CHECK API ACCESS"

            elif "404" in str(message):
                suggested_fix = "CHECK ENDPOINT"

            sql = """
            INSERT INTO ops.fix_tasks (
                provider,
                sport_code,
                entity_type,
                endpoint_name,
                parse_status,
                short_message,
                full_message,
                suggested_fix,
                source_payload_id
            )
            VALUES (
                %s,%s,%s,%s,%s,%s,%s,%s,%s
            )
            """

            short_message = str(message)[:300]

            ok, error = db_execute(
                sql,
                (
                    provider,
                    sport,
                    entity,
                    endpoint,
                    status,
                    short_message,
                    str(message),
                    suggested_fix,
                    row.get("id")
                )
            )

            if not ok:
                if "ux_fix_tasks_source_payload_open" in str(error):
                    messagebox.showwarning(
                        "ÚKOL OPRAVY",
                        "Fix task pro tento payload už existuje."
                    )
                else:
                    messagebox.showerror(
                        "CHYBA ÚKOLU OPRAVY",
                        str(error)
                    )
                return

            self.log(
                f"ÚKOL OPRAVY ULOŽEN | {provider} | {sport} | {entity} | {suggested_fix}"
            )

            messagebox.showinfo(
                "ÚKOL OPRAVY ULOŽEN",
                "Úkol opravy byl uložen do ops.fix_tasks"
            )

        def show_full_json():

            json_win = tk.Toplevel(self)
            json_win.title(f"CELÝ PAYLOAD JSON :: {payload_id}")
            json_win.geometry("1500x850")
            json_win.configure(bg=BG)

            tk.Label(
                json_win,
                text=f"👁 CELÝ PAYLOAD JSON :: {payload_id}",
                bg=BG,
                fg=PINK,
                font=("Segoe UI", 20, "bold")
            ).pack(anchor="w", padx=15, pady=10)

            text = tk.Text(
                json_win,
                bg="#09050f",
                fg="#dddddd",
                insertbackground="white",
                font=("Consolas", 10),
                wrap="word"
            )

            text.pack(fill="both", expand=True, padx=10, pady=10)

            text.insert("1.0", full_payload_json)
            text.config(state="disabled")

        button_frame = tk.Frame(
            win,
            bg=BG
        )

        button_frame.pack(
            anchor="e",
            padx=10,
            pady=(0, 10)
        )

        tk.Button(
            button_frame,
            text="👁 ZOBRAZIT CELÝ JSON",
            command=show_full_json,
            bg="#3b2555",
            fg="white",
            activebackground="#273145",
            activeforeground="white",
            font=("Segoe UI", 11, "bold"),
            bd=0
        ).pack(
            side="left",
            padx=5
        )

        tk.Button(
            button_frame,
            text="📋 KOPÍROVAT CELÝ JSON",
            command=copy_full_json,
            bg="#166534",
            fg="white",
            activebackground="#273145",
            activeforeground="white",
            font=("Segoe UI", 11, "bold"),
            bd=0
        ).pack(
            side="left",
            padx=5
        )

        tk.Button(
            button_frame,
            text="🛠 VYTVOŘIT FIX ÚKOL",
            command=create_fix_task,
            bg="#831843",
            fg="white",
            activebackground="#273145",
            activeforeground="white",
            font=("Segoe UI", 11, "bold"),
            bd=0
        ).pack(
            side="left",
            padx=5
        )

        text.insert("1.0", output.strip())
        text.config(state="disabled")

    def open_parse_message_detail(self, message_text):

        win = tk.Toplevel(self)

        win.title("DETAIL ZPRÁVY PARSOVÁNÍ")

        win.geometry("1100x700")

        win.configure(bg=BG)

        tk.Label(
            win,
            text="⚠ DETAIL ZPRÁVY PARSOVÁNÍ",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 20, "bold")
        ).pack(anchor="w", padx=15, pady=10)

        text = tk.Text(
            win,
            bg="#09050f",
            fg="#dddddd",
            insertbackground="white",
            font=("Consolas", 11),
            wrap="word"
        )

        text.pack(
            fill="both",
            expand=True,
            padx=10,
            pady=10
        )

        scrollbar = ttk.Scrollbar(
            text,
            orient="vertical",
            command=text.yview
        )

        text.configure(yscrollcommand=scrollbar.set)

        scrollbar.pack(side="right", fill="y")

        text.insert(
            "1.0",
            str(message_text)
        )

        text.config(state="disabled")

    def load_logs_detail(self):

        sql = """
        SELECT
            id,
            job_code,
            started_at,
            finished_at,
            status,
            rows_affected,
            duration_sec,
            message
        FROM ops.v_job_runs_recent
        ORDER BY started_at DESC
        LIMIT 50;
        """

        self.populate_tree(
            self.logs_detail_tree,
            db_query(sql)
        )

    def load_fix_tasks(self):

        counts_sql = """
        SELECT
            task_status,
            COUNT(*)
        FROM ops.fix_tasks
        GROUP BY task_status;
        """

        counts_rows = db_query(counts_sql)

        counts = {
            "open": 0,
            "fixed": 0,
            "ignored": 0
        }

        for row in counts_rows:
            counts[row["task_status"]] = row["count"]

        all_count = (
            counts["open"] +
            counts["fixed"] +
            counts["ignored"]
        )

        where_sql = ""

        if self.fix_task_filter != "all":
            where_sql = f"WHERE task_status = '{self.fix_task_filter}'"

        self.fix_btn_open.config(
            text=f"OTEVŘENÉ ({counts['open']})"
        )

        self.fix_btn_fixed.config(
            text=f"OPRAVENÉ ({counts['fixed']})"
        )

        self.fix_btn_ignored.config(
            text=f"IGNOROVANÉ ({counts['ignored']})"
        )

        self.fix_btn_all.config(
            text=f"VŠE ({all_count})"
        )

        sql = f"""
        SELECT
            id,
            created_at,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            parse_status,
            severity,
            priority_level,
            priority_score,
            suggested_fix,
            recommended_action,
            task_status,
            source_payload_id,
            short_message
        FROM ops.fix_tasks
        {where_sql}
        ORDER BY
            priority_score DESC NULLS LAST,
            created_at DESC
        LIMIT 100;
        """

        self.populate_tree(
            self.fix_tasks_tree,
            db_query(sql)
        )

    def set_fix_task_filter(self, status):

        self.fix_task_filter = status
        self.load_fix_tasks()

    def open_fix_task_detail(self, event):

        selected = self.fix_tasks_tree.selection()

        if not selected:
            return

        item = self.fix_tasks_tree.item(selected[0])
        values = item.get("values", [])

        if not values:
            return

        fix_task_id = values[0]

        sql = f"""
        SELECT
            id,
            created_at,
            provider,
            sport_code,
            entity_type,
            endpoint_name,
            parse_status,
            severity,
            short_message,
            full_message,
            suggested_fix,
            task_status,
            source_payload_id,
            created_by
        FROM ops.fix_tasks
        WHERE id = {fix_task_id};
        """

        rows = db_query(sql)

        if not rows:
            return

        row = rows[0]

        win = tk.Toplevel(self)
        win.title(f"DETAIL ÚKOLU OPRAVY :: {fix_task_id}")
        win.geometry("1400x850")
        win.configure(bg=BG)

        tk.Label(
            win,
            text=f"🛠 DETAIL ÚKOLU OPRAVY :: {fix_task_id}",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 22, "bold")
        ).pack(anchor="w", padx=15, pady=10)

        text = tk.Text(
            win,
            bg="#09050f",
            fg="#dddddd",
            insertbackground="white",
            font=("Consolas", 11),
            wrap="word"
        )

        text.pack(fill="both", expand=True, padx=10, pady=10)

        output = f"""
    ID: {row.get("id")}
    CREATED_AT: {row.get("created_at")}
    PROVIDER: {row.get("provider")}
    SPORT: {row.get("sport_code")}
    ENTITY: {row.get("entity_type")}
    ENDPOINT: {row.get("endpoint_name")}
    STATUS: {row.get("parse_status")}
    SEVERITY: {row.get("severity")}
    TASK_STATUS: {row.get("task_status")}
    SOURCE_PAYLOAD_ID: {row.get("source_payload_id")}

    SUGGESTED FIX:
    {row.get("suggested_fix")}

    SHORT MESSAGE:
    {row.get("short_message")}

    FULL MESSAGE:
    {row.get("full_message")}
    """

        text.insert("1.0", output.strip())
        text.config(state="disabled")

        def mark_fixed():

            ok, error = db_execute(
                """
                UPDATE ops.fix_tasks
                SET task_status = 'fixed'
                WHERE id = %s
                """,
                (fix_task_id,)
            )

            if not ok:
                messagebox.showerror("CHYBA", error)
                return

            self.log(f"ÚKOL OPRAVY HOTOVO | id={fix_task_id}")
            messagebox.showinfo("ÚKOL OPRAVY", "Úkol označen jako HOTOVO.")
            self.load_fix_tasks()
            win.destroy()


        def mark_ignored():

            ok, error = db_execute(
                """
                UPDATE ops.fix_tasks
                SET task_status = 'ignored'
                WHERE id = %s
                """,
                (fix_task_id,)
            )

            if not ok:
                messagebox.showerror("CHYBA", error)
                return

            self.log(f"ÚKOL OPRAVY IGNOROVÁN | id={fix_task_id}")
            messagebox.showinfo("ÚKOL OPRAVY", "Úkol označen jako IGNORED.")
            self.load_fix_tasks()
            win.destroy()


        def copy_error():

            win.clipboard_clear()
            win.clipboard_append(str(row.get("full_message")))
            win.update()

            messagebox.showinfo("KOPÍROVÁNO", "Chyba byla zkopírována do schránky.")

        button_frame = tk.Frame(win, bg=BG)
        button_frame.pack(anchor="e", padx=10, pady=(0, 10))

        tk.Button(
            button_frame,
            text="✅ OZNAČIT HOTOVO",
            command=mark_fixed,
            bg="#166534",
            fg="white",
            font=("Segoe UI", 11, "bold"),
            bd=0
        ).pack(side="left", padx=5)

        tk.Button(
            button_frame,
            text="🚫 IGNOROVAT",
            command=mark_ignored,
            bg="#3b2555",
            fg="white",
            font=("Segoe UI", 11, "bold"),
            bd=0
        ).pack(side="left", padx=5)

        tk.Button(
            button_frame,
            text="📋 KOPÍROVAT CHYBU",
            command=copy_error,
            bg="#831843",
            fg="white",
            font=("Segoe UI", 11, "bold"),
            bd=0
        ).pack(side="left", padx=5)

    def open_job_log_detail(self, event):

        selected = self.logs_detail_tree.selection()

        if not selected:
            return

        item = self.logs_detail_tree.item(selected[0])

        values = item.get("values", [])

        if not values:
            return

        job_id = values[0]

        sql = f"""
        SELECT
            id,
            job_code,
            started_at,
            finished_at,
            status,
            rows_affected,
            duration_sec,
            message,
            params,
            details
        FROM ops.v_job_runs_recent
        WHERE id = {job_id};
        """

        rows = db_query(sql)

        if not rows:
            return

        row = rows[0]

        detail_window = tk.Toplevel(self)

        detail_window.title(
            f"DETAIL LOGU JOBU :: {job_id}"
        )

        detail_window.geometry("1400x850")

        detail_window.configure(bg=BG)

        # HEADER

        header = tk.Frame(
            detail_window,
            bg="#100818",
            height=80
        )

        header.pack(
            fill="x"
        )

        tk.Label(
            header,
            text=f"▤ DETAIL LOGU JOBU :: {job_id}",
            bg="#100818",
            fg=PINK,
            font=("Segoe UI", 24, "bold")
        ).pack(
            side="left",
            padx=20,
            pady=20
        )

        status = str(row.get("status", "")).lower()

        status_color = "#00ff99"

        if status == "warning":
            status_color = "#ffcc00"

        elif status in ["failed", "error", "critical"]:
            status_color = "#ff3355"

        tk.Label(
            header,
            text=status.upper(),
            bg="#100818",
            fg=status_color,
            font=("Segoe UI", 18, "bold")
        ).pack(
            side="right",
            padx=20
        )

        # BODY

        body = tk.Frame(
            detail_window,
            bg=BG
        )

        body.pack(
            fill="both",
            expand=True,
            padx=15,
            pady=15
        )

        # INFO GRID

        info_frame = tk.Frame(
            body,
            bg="#171022",
            bd=1,
            relief="solid"
        )

        info_frame.pack(
            fill="x",
            pady=(0, 15)
        )

        fields = [
            ("JOB CODE", row.get("job_code")),
            ("STARTED", row.get("started_at")),
            ("FINISHED", row.get("finished_at")),
            ("ROWS", row.get("rows_affected")),
            ("DURATION", f"{row.get('duration_sec')} sec"),
        ]

        for i, (label, value) in enumerate(fields):

            cell = tk.Frame(
                info_frame,
                bg="#171022",
                padx=15,
                pady=10
            )

            cell.grid(
                row=0,
                column=i,
                sticky="nsew"
            )

            tk.Label(
                cell,
                text=label,
                bg="#171022",
                fg="#ff66cc",
                font=("Segoe UI", 10, "bold")
            ).pack(anchor="w")

            tk.Label(
                cell,
                text=str(value),
                bg="#171022",
                fg="white",
                font=("Consolas", 11)
            ).pack(anchor="w")

        # MESSAGE VIEWER

        tk.Label(
            body,
            text="📄 ZPRÁVA / VÝSTUP",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 15, "bold")
        ).pack(anchor="w")

        text_frame = tk.Frame(
            body,
            bg=BG
        )

        text_frame.pack(
            fill="both",
            expand=True
        )

        scrollbar = tk.Scrollbar(text_frame)

        scrollbar.pack(
            side="right",
            fill="y"
        )

        text = tk.Text(
            text_frame,
            bg="#09050f",
            fg="#dddddd",
            insertbackground="white",
            font=("Consolas", 11),
            wrap="word",
            yscrollcommand=scrollbar.set
        )

        text.pack(
            fill="both",
            expand=True
        )

        scrollbar.config(
            command=text.yview
        )

        message = row.get("message", "")
        params = row.get("params", "")
        details = row.get("details", "")

        output = f"""
        MESSAGE:
        {message}

        ----------------------------------------
        PARAMS:
        {params}

        ----------------------------------------
        DETAILS:
        {details}
        """

        text.insert(
            "1.0",
            output.strip()
        )

        text.config(
            state="disabled"
        )  

    # =====================================================
    # TREE
    # =====================================================

    def populate_tree(self, tree, rows):

        tree.delete(*tree.get_children())

        if not rows:
            tree.configure(displaycolumns=())

            tree["columns"] = ["info"]
            tree["displaycolumns"] = ["info"]

            tree.heading("info", text="INFO")
            tree.column("info", width=300, anchor="center", stretch=True)

            tree.insert("", "end", values=("Žádná aktivní data",))
            return

        cols = [str(c) for c in rows[0].keys()]

        tree.configure(displaycolumns=())

        tree["columns"] = cols
        tree["displaycolumns"] = cols

        for col in cols:
            tree.heading(col, text=cz_column(col))

            max_len = len(col)

            for row in rows:
                val = row.get(col, "")
                max_len = max(max_len, len(str(val)))

            width = max(80, min(max_len * 7, 450))

            if col.lower() in ("id", "season", "status", "parse_status"):
                width = 80

            if col.lower() in ("provider", "sport_code", "entity_type", "endpoint_name"):
                width = 130

            if "message" in col.lower() or "reason" in col.lower() or "note" in col.lower():
                width = max(220, min(max_len * 6, 520))

            tree.column(
                col,
                width=width,
                minwidth=60,
                anchor="center",
                stretch=True
            )

        for row in rows:

            vals = []
            txt = ""

            for c in cols:
                v = row.get(c, "")

                if isinstance(v, datetime):
                    v = v.strftime("%Y-%m-%d %H:%M:%S")

                vals.append(v)
                txt += str(v).upper()

            tag = "purple"

            priority_level = str(row.get("priority_level", "")).upper()

            if priority_level == "HIGH":
                tag = "priority_high"

            elif priority_level == "MEDIUM":
                tag = "priority_medium"

            elif priority_level == "LOW":
                tag = "priority_low"

            elif (
                "READY_FOR_MERGE" in txt
                or "RAW_PENDING_PARSE" in txt
            ):
                tag = "yellow"

            elif (
                "GREEN" in txt
                or "OK" in txt
                or "READY" in txt
                or "HEALTHY" in txt
            ):
                tag = "green"

            elif (
                "YELLOW" in txt
                or "WARNING" in txt
                or "COOLDOWN" in txt
            ):
                tag = "yellow"

            elif (
                "UPSERT / ON CONFLICT" in txt
                or "DUPLICATE KEY" in txt
                or "UNIQUEVIOLATION" in txt
            ):
                tag = "yellow"

            elif (
                "RETRY / MENŠÍ BATCH" in txt
                or "TIMEOUT" in txt
            ):
                tag = "yellow"

            elif (
                "KONTROLA JSON MAPPINGU" in txt
                or "JSON" in txt
            ):
                tag = "red"

            elif (
                "OVĚŘIT SCOPE / COVERAGE" in txt
                or "EMPTY" in txt
            ):
                tag = "purple"

            elif (
                "RED" in txt
                or "CRITICAL" in txt
                or "FAILED" in txt
                or "ERROR" in txt
            ):
                tag = "red"

            display_values = list(vals)

            for i, val in enumerate(display_values):

                if isinstance(val, str) and len(val) > 120:
                    display_values[i] = val[:120] + " ..."

            tree.insert("", "end", values=display_values, tags=(tag,))

        self.auto_resize_tree_columns(tree)

    def auto_resize_tree_columns(self, tree):

        try:
            columns = list(tree["columns"])

            if not columns:
                return

            total_width = tree.winfo_width()

            if total_width <= 100:
                return

            visible_width = max(300, total_width - 25)

            fixed_small_columns = {
                "id",
                "action_id",
                "season",
                "status",
                "parse_status",
                "risk_score",
                "scheduler_priority",
                "provider_health_score",
                "total_payloads",
                "pending_rows",
                "rows_count",
            }

            small_width = 80
            remaining_columns = []

            used_width = 0

            for col in columns:

                col_lower = str(col).lower()

                if col_lower in fixed_small_columns:
                    tree.column(col, width=small_width, minwidth=55, stretch=False)
                    used_width += small_width
                else:
                    remaining_columns.append(col)

            if not remaining_columns:
                return

            remaining_width = max(80, visible_width - used_width)

            dynamic_width = int(remaining_width / len(remaining_columns))

            for col in remaining_columns:

                col_lower = str(col).lower()

                min_width = 90

                if "message" in col_lower or "reason" in col_lower or "note" in col_lower:
                    min_width = 180

                if "provider" in col_lower or "worker" in col_lower:
                    min_width = 120

                tree.column(
                    col,
                    width=max(min_width, dynamic_width),
                    minwidth=min_width,
                    stretch=True
                )

        except Exception:
            pass   

    # =====================================================
    # MANUÁL / AUTOMAT REŽIM
    # =====================================================

    def toggle_auto_mode(self):
        """
        CO TO JE:
        - Přepínač mezi ručním a automatickým řízením panelu.

        K ČEMU TO JE:
        - MANUÁL: uživatel vybírá, co se spustí.
        - AUTOMAT: po doběhu akce panel vezme další bezpečnou položku z RUN NEXT fronty.

        BEZPEČNOST:
        - Automat nikdy nespustí dvě akce najednou.
        - Automat bere pouze workery, které jsou definované ve WORKER_COMMANDS.
        - Při chybě se nezacyklí okamžitě, ale počká a zapíše stav do logu.
        """

        self.auto_mode_enabled = not self.auto_mode_enabled

        if self.auto_mode_enabled:
            self.auto_mode_button.config(
                text="🤖 REŽIM: AUTOMAT",
                bg="#0f5f5a"
            )
            self.auto_status_label.config(
                text="AUTOMAT ZAPNUT",
                fg=GREEN
            )
            self.log("AUTOMAT: zapnutý režim. Panel bude po doběhu akce vybírat další bezpečný worker z fronty.")
            self.schedule_auto_cycle(delay_ms=1200)
        else:
            self.auto_mode_button.config(
                text="🟢 REŽIM: MANUÁL",
                bg="#3b2555"
            )
            self.auto_status_label.config(
                text="MANUÁL",
                fg="#c4a1dd"
            )
            self.log("AUTOMAT: vypnutý režim. Další akce spouštíš ručně.")

    def schedule_auto_cycle(self, delay_ms=5000):
        if not self.auto_mode_enabled:
            return

        self.after(delay_ms, self.auto_cycle_step)

    def auto_cycle_step(self):
        """
        Jeden bezpečný krok automatu.
        """

        if not self.auto_mode_enabled:
            return

        if self.worker_running:
            self.auto_status_label.config(
                text="AUTOMAT ČEKÁ NA DOBĚH",
                fg=YELLOW
            )
            self.schedule_auto_cycle(delay_ms=5000)
            return

        rec = self.get_recommended_worker_row()
        worker = rec.get("worker_code") if rec else None

        if not worker:
            self.auto_status_label.config(
                text="AUTOMAT: NIC KE SPUŠTĚNÍ",
                fg="#c4a1dd"
            )
            self.log("AUTOMAT: fronta je prázdná nebo neobsahuje spustitelný doporučený worker, čekám na další data.")
            self.schedule_auto_cycle(delay_ms=15000)
            return

        if worker not in WORKER_COMMANDS:
            self.auto_status_label.config(
                text=f"AUTOMAT: CHYBÍ PŘÍKAZ {worker}",
                fg=RED
            )
            self.log(f"AUTOMAT: worker {worker} není ve WORKER_COMMANDS, přeskakuji a čekám.")
            self.schedule_auto_cycle(delay_ms=15000)
            return

        reason = rec.get("reason", "doporučená akce podle aktuálního stavu") if rec else "doporučená akce podle aktuálního stavu"
        self.auto_status_label.config(
            text=f"AUTOMAT SPOUŠTÍ: {worker}",
            fg=GREEN
        )
        self.log(f"AUTOMAT DOPORUČIL: {worker} | {reason}")
        self.start_worker_by_code(worker, "AUTOMAT DOPORUČENÁ AKCE")

    def update_auto_result_counters(self, return_code):
        if return_code == 0:
            self.auto_ok_count += 1
        elif return_code is None:
            self.auto_error_count += 1
        else:
            self.auto_error_count += 1

        if hasattr(self, "auto_status_label"):
            self.auto_status_label.config(
                text=f"AUTO OK:{self.auto_ok_count} WARN:{self.auto_warning_count} ERR:{self.auto_error_count}",
                fg=GREEN if return_code == 0 else RED
            )

    # =====================================================
    # RUN NEXT / RUČNÍ ŘÍZENÍ FRONTY
    # =====================================================

    def get_selected_run_next_worker(self):
        """
        CO TO JE:
        - Vrátí worker_code vybraný kliknutím v tabulce FRONTA KE SPUŠTĚNÍ.

        K ČEMU TO JE:
        - Uživatel může spustit konkrétní doporučený worker, ne jen první řádek.
        """

        selected = self.run_next_tree.selection()

        if not selected:
            return None

        item = self.run_next_tree.item(selected[0])
        values = item.get("values", [])

        if len(values) < 2:
            return None

        return str(values[1]).strip()

    def get_first_run_next_worker(self):
        rows = db_query("""
            SELECT
                worker_code
            FROM ops.v_run_next_queue_v1
            ORDER BY run_next_rank
            LIMIT 1;
        """)

        if not rows:
            return None

        return rows[0].get("worker_code")

    def start_worker_by_code(self, worker, source_label="RUČNÍ SPUŠTĚNÍ"):
        """
        CO TO JE:
        - Společná funkce pro spuštění workeru podle worker_code.

        K ČEMU TO JE:
        - Stejný bezpečnostní postup pro SPUSTIT DALŠÍ i SPUSTIT VYBRANÝ.
        """

        if self.worker_running:
            messagebox.showwarning(
                "SPUŠTĚNO",
                "Worker už běží. Počkej na dokončení aktuální akce."
            )
            return

        if not worker:
            messagebox.showinfo(
                "SPUŠTĚNÍ WORKERU",
                "Není vybraný žádný worker."
            )
            return

        if worker not in WORKER_COMMANDS:
            messagebox.showerror(
                "CHYBÍ PŘÍKAZ",
                (
                    f"Pro worker '{worker}' zatím není v panelu definovaný příkaz.\n\n"
                    "Doporučení:\n"
                    "1) otevři záložku WORKERY nebo PLÁNOVAČ,\n"
                    "2) ověř cestu worker_script,\n"
                    "3) doplň worker do WORKER_COMMANDS v panelu."
                )
            )
            return

        cmd = WORKER_COMMANDS[worker]
        self.last_worker_name = worker

        self.log(f"{source_label}: {worker}")
        self.log("INFO: průběh sleduj vpravo nahoře, v progress baru a v LOG SPOUŠTĚNÍ.")

        self.start_worker_activity(worker)

        thread = threading.Thread(
            target=self.run_worker_thread,
            args=(cmd,),
            daemon=True
        )

        thread.start()

    def run_selected_worker(self):
        worker = self.get_selected_run_next_worker()

        if not worker:
            messagebox.showinfo(
                "SPUSTIT VYBRANÝ",
                (
                    "Nejdřív klikni na řádek v tabulce FRONTA KE SPUŠTĚNÍ.\n\n"
                    "Pak klikni na SPUSTIT VYBRANÝ."
                )
            )
            return

        self.start_worker_by_code(worker, "SPUSTIT VYBRANÝ")

    def get_run_next_rows(self):
        """
        CO TO JE:
        - Načte aktuální RUN NEXT frontu z OPS.

        K ČEMU TO JE:
        - Doporučovací logika může vybrat největší přínos, ne pouze první řádek.
        """

        return db_query("""
            SELECT
                run_next_rank,
                worker_code,
                execution_decision,
                retry_policy,
                final_priority_score
            FROM ops.v_run_next_queue_v1
            ORDER BY run_next_rank;
        """)

    def get_recommended_worker_row(self):
        """
        V17.11.01 - doporučení podle kritických oblastí.

        Princip:
        - PEOPLE má teď nízké procento a reálně přidává hráče/mapy.
        - CORE už často jen opakuje ligy bez fixtures, proto dostává nižší přínos.
        - MEDIA/ODDS zatím čekají na další workery v panelu.

        Později se scoring napojí přímo na OPS snapshoty:
        ops.sport_completion_audit / v_sport_completion_summary / data gap.
        """

        rows = self.get_run_next_rows()

        if not rows:
            return None

        best = None
        best_score = -999999

        for row in rows:
            worker = str(row.get("worker_code", ""))
            decision = str(row.get("execution_decision", "")).upper()
            base_score = int(row.get("final_priority_score") or 0)
            score = base_score
            reason_parts = []

            if decision != "RUN":
                score -= 1000
                reason_parts.append("worker není ve stavu RUN")

            if worker not in WORKER_COMMANDS:
                score -= 500
                reason_parts.append("worker zatím nemá příkaz v panelu")

            upper_worker = worker.upper()

            if "PEOPLE" in upper_worker or "PLAYER" in upper_worker:
                score += 600
                reason_parts.append("PEOPLE vrstva je nízko a tento worker ji přímo zvyšuje")

            elif "MEDIA" in upper_worker:
                score += 420
                reason_parts.append("MEDIA vrstva je rozpracovaná a worker může zvýšit media coverage")

            elif "ODDS" in upper_worker:
                score += 350
                reason_parts.append("ODDS vrstva je nejslabší, ale často závisí na PRO/provider dostupnosti")

            elif "CORE" in upper_worker or "INGEST" in upper_worker:
                score += 120
                reason_parts.append("CORE je důležitý, ale aktuálně už často jen doplňuje/čistí frontu")

            if "NORMAL" in str(row.get("retry_policy", "")).upper():
                score += 20
                reason_parts.append("retry politika je normální")

            row = dict(row)
            row["recommendation_score"] = score
            row["reason"] = "; ".join(reason_parts) if reason_parts else "doporučeno podle OPS pořadí"

            if score > best_score:
                best_score = score
                best = row

        return best

    def run_recommended_worker(self):
        rec = self.get_recommended_worker_row()

        if not rec:
            messagebox.showinfo(
                "DOPORUČENÁ AKCE",
                "Teď není k dispozici žádná doporučená akce."
            )
            return

        worker = rec.get("worker_code")
        self.log(
            f"DOPORUČENÁ AKCE: {worker} | score={rec.get('recommendation_score')} | {rec.get('reason')}"
        )
        self.start_worker_by_code(worker, "DOPORUČENÁ AKCE")

    def explain_recommended_worker(self):
        rec = self.get_recommended_worker_row()

        if not rec:
            messagebox.showinfo(
                "PROČ DOPORUČENO",
                "Fronta je prázdná nebo neobsahuje spustitelný worker."
            )
            return

        worker = rec.get("worker_code")
        detail = f"""
DOPORUČENÁ AKCE MATCHMATRIX

Doporučený worker:
{worker}

Doporučovací skóre:
{rec.get('recommendation_score')}

Pořadí v původní RUN NEXT frontě:
{rec.get('run_next_rank')}

OPS rozhodnutí:
{rec.get('execution_decision')}

Retry politika:
{rec.get('retry_policy')}

Důvod:
{rec.get('reason')}

CO TÍM ZLEPŠÍME:
- panel už nebere jen první řádek z fronty,
- vybírá akci s největším přínosem pro slabé oblasti projektu,
- aktuálně má vyšší váhu PEOPLE, protože z posledních běhů reálně přidává hráče a mapování,
- CORE má nižší váhu, protože často vrací prázdné fixtures ligy.

CO UDĚLAT:
1) Klikni na DOPORUČENÁ AKCE.
2) Sleduj vpravo nahoře, progress bar a LOG SPOUŠTĚNÍ.
3) Pokud chceš ruční kontrolu, klikni na řádek ve frontě a použij SPUSTIT VYBRANÝ.
4) Pokud zapneš AUTOMAT, bude používat stejnou doporučovací logiku.

DALŠÍ KROK:
Napojíme scoring na skutečné OPS tabulky a přidáme filtr pro ligy, které opakovaně vrací No fixtures returned.
""".strip()

        messagebox.showinfo("PROČ JE TOTO DOPORUČENO", detail)

    def explain_selected_or_first_worker(self):
        selected_worker = self.get_selected_run_next_worker()
        worker_filter_sql = ""

        if selected_worker:
            worker_filter_sql = f"WHERE worker_code = '{selected_worker}'"

        rows = db_query(f"""
            SELECT
                run_next_rank,
                worker_code,
                execution_decision,
                retry_policy,
                final_priority_score
            FROM ops.v_run_next_queue_v1
            {worker_filter_sql}
            ORDER BY run_next_rank
            LIMIT 1;
        """)

        if not rows:
            messagebox.showinfo(
                "PROČ PRVNÍ?",
                "Ve frontě teď není žádný worker k vysvětlení."
            )
            return

        row = rows[0]
        worker = row.get("worker_code")
        rank = row.get("run_next_rank")
        decision = row.get("execution_decision")
        retry = row.get("retry_policy")
        score = row.get("final_priority_score")

        detail = f"""
FRONTA KE SPUŠTĚNÍ - VYSVĚTLENÍ

Worker:
{worker}

Pořadí ve frontě:
{rank}

Rozhodnutí:
{decision}

Retry politika:
{retry}

Prioritní skóre:
{score}

CO TO ZNAMENÁ:
Panel bere pořadí z OPS pohledu ops.v_run_next_queue_v1.
Tento pohled má být později řízený podle kritických oblastí:
- vysoké alerty,
- data gap,
- chybějící vrstvy,
- blokované nebo nehotové entity,
- stav workerů,
- riziko a cooldown.

CO MŮŽEŠ UDĚLAT TEĎ:
1) Chceš-li pustit akci s největším přínosem, klikni na DOPORUČENÁ AKCE.
2) Chceš-li pustit první řádek z původní fronty, klikni na SPUSTIT DALŠÍ.
3) Chceš-li pustit konkrétní řádek, klikni na řádek ve FRONTĚ KE SPUŠTĚNÍ a potom SPUSTIT VYBRANÝ.
4) Když worker není v panelu spustitelný, doplníme ho do WORKER_COMMANDS.

DALŠÍ VÝVOJ:
Od V17.11.01 už panel umí vybrat DOPORUČENOU AKCI podle přínosu.
Další SQL vrstva bude frontu čistit také podle opakovaných empty/no-data výsledků.
""".strip()

        messagebox.showinfo("PROČ JE WORKER VE FRONTĚ", detail)

    # =====================================================
    # RUN NEXT
    # =====================================================

    def run_next_safe(self):

        worker = self.get_first_run_next_worker()

        if not worker:
            messagebox.showinfo(
                "SPUSTIT DALŠÍ",
                "Není nic ke spuštění."
            )
            return

        self.start_worker_by_code(worker, "SPUSTIT DALŠÍ")

    def run_autonomous_dispatch(self):

        if self.worker_running:

            messagebox.showwarning(
                "SPUŠTĚNO",
                "Worker už běží."
            )

            return

        rows = db_query("""
            SELECT
                queue_id,
                action_code,
                worker_code,
                final_rank_score,
                dispatch_state_cz
            FROM ops.v_ranked_launcher_dispatch_next_v1;
        """)

        if not rows:

            status_rows = db_query("""
                SELECT
                    execution_status,
                    COUNT(*) AS status_count
                FROM ops.autonomous_execution_queue
                GROUP BY execution_status
                ORDER BY execution_status;
            """)

            info_lines = ["Není žádná READY_TO_LAUNCH autonomní akce.", "", "Aktuální autonomní fronta:"]

            if status_rows:
                for status_row in status_rows:
                    info_lines.append(
                        f"{status_row.get('execution_status')}: {status_row.get('status_count')}"
                    )
            else:
                info_lines.append("Žádná historie autonomní fronty.")

            messagebox.showinfo(
                "AUTONOMNÍ AKCE",
                "\n".join(info_lines)
            )

            return

        row = rows[0]

        cmd = WORKER_COMMANDS["AUTONOMOUS_RANKED_DISPATCH"]

        self.log(
            "AUTONOMNÍ AKCE: "
            f"queue_id={row.get('queue_id')} | "
            f"worker={row.get('worker_code')} | "
            f"score={row.get('final_rank_score')}"
        )

        self.start_worker_activity(str(row.get('worker_code')))

        thread = threading.Thread(
            target=self.run_worker_thread,
            args=(cmd,),
            daemon=True
        )

        thread.start()

    # =====================================================
    # RUNTIME INDIKÁTOR AKCE
    # =====================================================

    def set_worker_activity(self, text, color, running=False):
        """
        CO TO JE:
        - Aktualizuje viditelný stav běžící akce v horní liště tlačítek.

        K ČEMU TO JE:
        - Po kliknutí na spuštění je jasně vidět, že se něco děje.
        """

        if hasattr(self, "worker_activity_label"):
            self.worker_activity_label.config(text=text, fg=color)

        if hasattr(self, "worker_progress"):
            if running:
                self.worker_progress.start(12)
            else:
                self.worker_progress.stop()

    def start_worker_activity(self, worker_name):
        self.set_worker_activity(
            f"▶ BĚŽÍ: {worker_name}",
            YELLOW,
            running=True
        )
        self.system_state.config(text="BĚŽÍ AKCE", fg=YELLOW)

    def finish_worker_activity(self, return_code=None):
        if return_code == 0:
            self.set_worker_activity(
                "✅ AKCE DOKONČENA",
                GREEN,
                running=False
            )
        else:
            self.set_worker_activity(
                "⚠ AKCE SKONČILA / ZKONTROLUJ LOG",
                RED,
                running=False
            )

        self.after(
            4000,
            lambda: self.set_worker_activity(
                "● ŽÁDNÁ AKCE NEBĚŽÍ",
                "#b98bd8",
                running=False
            )
        )

    # =====================================================
    # THREAD
    # =====================================================

    def decode_process_line(self, raw_line):

        if raw_line is None:
            return ""

        for encoding in ("utf-8", "cp1250", "cp852", "latin-1"):
            try:
                return raw_line.decode(encoding)
            except Exception:
                pass

        return raw_line.decode("utf-8", errors="replace")

    def run_worker_thread(
        self,
        cmd
    ):

        self.worker_running = True
        return_code = None

        try:

            self.log_queue.put("START: worker spuštěn, čekám na výstup...")
            self.log_queue.put("PŘÍKAZ: " + " ".join(str(x) for x in cmd))

            proc = subprocess.Popen(
                cmd,
                cwd=BASE_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=False
            )

            for raw_line in proc.stdout:

                line = self.decode_process_line(raw_line)

                self.log_queue.put(
                    line.rstrip()
                )

            proc.wait()
            return_code = proc.returncode

            self.log_queue.put(
                f"KONEC: worker doběhl | return_code={return_code}"
            )

        except Exception as e:

            self.log_queue.put(
                f"CHYBA: {e}"
            )

        self.worker_running = False
        self.last_worker_return_code = return_code
        self.after(0, lambda rc=return_code: self.finish_worker_activity(rc))
        self.after(0, lambda rc=return_code: self.update_auto_result_counters(rc))

        if self.auto_mode_enabled:
            self.log_queue.put("AUTOMAT: akce doběhla, za chvíli vyberu další položku z fronty.")
            self.after(7000, self.auto_cycle_step)

    # =====================================================
    # LOG
    # =====================================================

    def process_logs(self):

        try:

            while True:

                msg = self.log_queue.get_nowait()

                self.log(msg)

        except queue.Empty:
            pass

        self.after(
            300,
            self.process_logs
        )

    def log(
        self,
        msg
    ):

        ts = datetime.now().strftime(
            "%H:%M:%S"
        )

        self.log_text.insert(
            "end",
            f"[{ts}] {msg}\n"
        )

        self.log_text.see("end")

    def clear_log(self):

        self.log_text.delete(
            "1.0",
            "end"
        )

    def update_clock(self):

        now = datetime.now().strftime("%H:%M:%S")

        self.clock_label.config(
            text=f"{now}  ● LIVE",
            fg=GREEN
        )

        self.after(
            1000,
            self.update_clock
        )

    def blink_critical_rows(self):

        self.blink_state = not self.blink_state

        for tree in [
            self.alerts_tree,
            self.feed_tree,
            self.worker_health_tree
        ]:
            for item in tree.get_children():
                values = tree.item(item, "values")
                row_text = " ".join(str(v).upper() for v in values)

                if "CRITICAL" in row_text or "FAILED_WORKER" in row_text:
                    tree.item(
                        item,
                        tags=("critical_blink_on" if self.blink_state else "critical_blink_off",)
                    )

        self.after(800, self.blink_critical_rows)

    def pulse_system_state(self):

        self.system_pulse_state = not self.system_pulse_state

        state_text = self.system_state.cget("text").upper()

        if "CRITICAL" in state_text or "ERROR" in state_text:
            color_on = RED
            color_off = "#4a0018"

        elif "WARNING" in state_text or "COOLDOWN" in state_text:
            color_on = YELLOW
            color_off = "#4a3b00"

        else:
            color_on = GREEN
            color_off = "#083b2b"

        self.system_state.config(
            fg=color_on if self.system_pulse_state else color_off
        )

        self.after(900, self.pulse_system_state)

    def create_bottom_tab(self, icon, name):

        display_name = TAB_LABELS.get(name, name)

        btn = tk.Button(
            self.bottom_tabs,
            text=f"{icon}\n{display_name}",
            bg="#14081d",
            fg="#e9d5ff",
            activebackground="#9333ea",
            activeforeground="white",
            relief="solid",
            bd=1,
            font=("Segoe UI", 10, "bold"),
            command=lambda n=name: self.show_tab(n)
        )

        btn.pack(
            side="left",
            fill="both",
            expand=True,
            padx=4,
            pady=5
        )

        self.tabs[f"{name}_button"] = btn


    def show_tab(self, name):

        for key, frame in self.tabs.items():
            if isinstance(frame, tk.Frame):
                frame.lower()

        self.tabs[name].lift()
        self.current_tab = name

        if name == "SCHEDULER":
            self.load_audit()

        if name == "WORKERS":
            self.load_workers_detail()

        if name == "ACTIVE RUNS":
            self.load_active_runs_detail()

        if name == "PAYLOADS":
            self.load_payloads_detail()

        if name == "LOGS":
            self.load_logs_detail()

        if name == "FIX TASKS":
            self.load_fix_tasks()

        if name == "AI OPS":
            self.load_autonomous_queue_summary()
            self.load_autonomous_learning_recent()

        if name == "ROADMAP":
            self.load_roadmap()

        if name == "PEOPLE PIPELINE":
            self.load_people_pipeline()

        if name == "HARVEST":
            self.load_harvest_dashboard()

        if name == "ODDS":
            self.load_odds_dashboard()

        if name == "PROVIDERS":
            self.load_providers_dashboard()

        for key, item in self.tabs.items():
            if key.endswith("_button"):
                item.config(bg="#14081d", fg="#e9d5ff")

        btn_key = f"{name}_button"
        if btn_key in self.tabs:
            self.tabs[btn_key].config(
                bg="#a21caf",
                fg="white"
            )

    # =====================================================
    # ZOOM
    # =====================================================

    def zoom(
        self,
        event
    ):

        if event.delta > 0:
            self.scale += 0.05
        else:
            self.scale -= 0.05

        self.scale = max(
            0.7,
            min(self.scale, 2.0)
        )

        style = ttk.Style()

        size = int(10 * self.scale)

        style.configure(
            "Treeview",
            rowheight=int(
                24 * self.scale
            ),
            font=("Segoe UI", size)
        )

        style.configure(
            "Treeview.Heading",
            font=(
                "Segoe UI",
                size,
                "bold"
            )
        )

# =========================================================
# MAIN
# =========================================================

if __name__ == "__main__":

    app = MatchMatrixAdminPanel()

    app.mainloop()