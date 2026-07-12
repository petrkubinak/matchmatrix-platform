"""
MATCHMATRIX CONTROL PANEL V20.1.Q3 DOCUMENTATION WORKFLOW
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

V19:
- spodní záložky přesunuty do levé navigace,
- výchozí pracovní obrazovka je DENNÍ PRÁCE,
- horní velký dashboard se zobrazuje pouze v PŘEHLED,
- běžná práce má méně rušivých KPI a více místa na akce.

V19.10:
- pravá akční lišta v Denní práci zúžena, aby měl střed víc prostoru,
- v Přehledu jsou rychlé akce přesunuté doprava a horní KPI/doporučení jsou rovnoměrněji rozložené.

V19.7:
- globální rychlé akce jsou vrácené pod KPI/doporučení,
- pravá lišta slouží jen pro akce nad vybraným řádkem,
- Přehled má pořadí: KPI -> stav oblastí -> Dnešní priorita + AI doporučení -> Rychlé akce.

V18.16:
- přidána nová záložka PC2 COMMAND CENTER,
- panel načítá PC2 harvest roadmapu, KPI, frontu příkazů a RUN button view,
- připraveno ruční spuštění další PC2 akce z DB fronty ops.pc2_run_command_queue,
- po spuštění zapisuje RUNNING / DONE / FAILED zpět do DB.
- PC2 execution engine používá bezpečné shell=False spuštění přes C:\\Python314\\python.exe.

V20.A:
- PŘEHLED je zeštíhlený.
- UPOZORNĚNÍ + UDÁLOSTI ORCHESTRACE + ZDRAVÍ WORKERŮ jsou sloučeny do jedné sekce SYSTÉMOVÉ UDÁLOSTI.
- Cíl: méně tabulek najednou, jasnější čtení a více prostoru pro denní práci.

V20.C.2:
- DENNÍ PRÁCE je převedena do akčního operátorského režimu.
- Hlavní informace jsou grafické karty a progress bary.
- Tabulky zůstávají jako detail pod grafickým přehledem.
- Cíl: spustit → sledovat → vyhodnotit → opravit → pokračovat.

V20.1.P4:
- Doporučená akce „api_volleyball → HLEDAT PEOPLE PROVIDERA“ už není jen text.
- Tlačítko zakládá discovery úkol přes ops.fn_operator_create_provider_discovery_action_v1.
- Cíl: CHYBA → PROČ → HLEDAT PROVIDERA → auditovaný úkol v DB.

V20.1.P:
- DENNÍ PRÁCE napojena na ops.v_operator_action_buttons_v1.
- Vybraný řádek ukazuje doporučené tlačítko: POKRAČOVAT / OTEVŘÍT PROVIDER MATRIX / OTEVŘÍT LOG.
- Cíl: CHYBA → PROČ → CO UDĚLAT → TLAČÍTKO AKCE.

V20.1.Q:
- Přidána samostatná záložka DOKUMENTACE.
- Zobrazuje stav dokumentační databáze, aktuální dokumenty, vazby, historii stavů a importní běhy.
- Obsahuje rychlé otevření hlavní dokumentace, denních zápisů, navázání, slovníku a reportů.
- První verze je bezpečně read-only vůči dokumentační databázi.

V20.1.Q2:
- PC1 klient čte databázi a dokumentaci z PC2.
- MM-REF-001 slouží pouze jako překladový slovník.
- MM-REF-002 poskytuje klikací výklad, zdrojový dokument a cílovou kapitolu.
- Kliknutí na cizí výraz zobrazí český překlad a vysvětlení přímo v panelu.
- Tlačítka otevřou výklad, zdrojovou kapitolu nebo celý dokument.

V20.1.Q3:
- Rozšiřuje záložku DOKUMENTACE o řízený dokumentační workflow.
- Workflow využívá existující nástroje A17 až A24, A6 a A7.
- Jednotlivé dokumenty budou zpracovávány v oddělených pracovních složkách.
- STEP 10 přidává bezpečné tlačítko NÁVRH OPRAVY napojené na A18.
- A18 pracuje pouze ve workspace a nikdy nepřepisuje zdrojový dokument.

V20.1.Q3 STEP 11:
- přidává tlačítko KONTROLA MAPOVÁNÍ napojené na A19,
- A19 GUI se spouští lokálně na PC1, aby bylo uživateli viditelné,
- panel připraví bezpečnou pracovní kopii A18 kontraktu s UNC cestou,
- A19 ukládá revizi pouze do podsložky a19 aktuálního workspace,
- zdrojový dokument ani databáze se nemění.

- Cíl: připravit, zkontrolovat, potvrdit terminologii, publikovat a ověřit dokument.

V20.1.Q3 STEP 12–17:
- A20 vytvoří standardizovaný dokument z potvrzeného mapování A19,
- kandidát lze přímo otevřít a ručně doplnit,
- finální A17 ověří doplněný kandidát,
- schválení vytvoří kanonický dokument se stavem APPROVED,
- kanonický A17 ověří skutečně uložený soubor,
- Git commit přidá a commitne pouze konkrétní kanonický dokument; nikdy nepoužije git add .

V20.1.Q3 STEP 18:
- fáze 4 PUBLIKOVAT pokračuje po Git commitu bezpečným A24 VALIDATE_ONLY na PC2,
- APPLY je povolen pouze po úspěšné validaci stejného SHA-256 dokumentu,
- A24 APPLY na PC2 spustí A6 a následné inkrementální ověření A7,
- panel rozlišuje VALIDATED, APPLIED_AND_VERIFIED,
  APPLIED_VERIFICATION_FAILED a BLOCKED,
- automatický stash ani automatický push se nepoužívá.

V20.1.Q3 STEP 19:
- fáze 1 umí vytvořit nový DAILY_LOG nebo CHAT_CONTINUATION z oficiální šablony,
- používá MM-TPL-001 a MM-TPL-002 z docs/13_TEMPLATES na PC2,
- šablona se rozbalí přímo do izolovaného workspace a nikdy se nepřepisuje,
- základní metadata, datum, Document ID a kanonický název se vyplní automaticky,
- před A17 panel zablokuje audit, dokud v dokumentu zůstávají nevyplněná pole {{...}},
- stále lze vybrat a zpracovat libovolný existující Markdown dokument.

V20.1.Q3 STEP 20A:
- nové dokumenty automaticky přebírají ověřitelná technická data z Git a dokumentační DB,
- panel doplní Git větev, commit, stav pracovního stromu a synchronizaci s originem,
- panel doplní aktuální počty dokumentů, verzí, sekcí, vazeb a importních běhů,
- panel předvyplní technickou dohledatelnost, aktivní panel, pracovní blok a stav workflow,
- obsahové kapitoly a projektová rozhodnutí zůstávají k ručnímu nebo řízenému doplnění,
- vysvětlující pole {{NAZEV_PROMENNE}} se nepočítá jako skutečně nevyplněný údaj.
"""

import os
import queue
import threading
import subprocess
import shlex
import shutil
import json
import sys
import base64
import hashlib
import re
import unicodedata
from pathlib import Path
from datetime import datetime
import time

import tkinter as tk
from tkinter import ttk, messagebox, filedialog, simpledialog

import psycopg2
import psycopg2.extras

# =========================================================
# CONFIG
# =========================================================

BASE_DIR = r"C:\MatchMatrix-platform"
DOCUMENTATION_ROOT = r"\\192.168.3.119\matchmatrix"
REFERENCE_DIR = os.path.join(DOCUMENTATION_ROOT, "docs", "10_REFERENCE")
GLOSSARY_TRANSLATION_PATH = os.path.join(REFERENCE_DIR, "MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md")
GLOSSARY_EXPLANATION_PATH = os.path.join(REFERENCE_DIR, "MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md")

# V20.1.Q3 - DOCUMENTATION WORKFLOW CONFIG
# CO:
# - Centrální registry existujících dokumentačních nástrojů.
# K ČEMU:
# - Panel jejich logiku neduplikuje, pouze je bezpečně spouští.
# KDE:
# - tools/documentation
# JAK:
# - Každý dokument dostane vlastní pracovní složku pod panel_workspaces.
DOCUMENTATION_EXECUTION_MODE = "REMOTE_PC2"
DOCUMENTATION_REMOTE_HOST = "192.168.3.119"
DOCUMENTATION_REMOTE_PROJECT_ROOT = r"C:\MatchMatrix-Platform"
DOCUMENTATION_PYTHON_EXE = r"C:\Users\Admin\AppData\Local\Python\pythoncore-3.14-64\python.exe"
DOCUMENTATION_TOOL_DIR = os.path.join(
    DOCUMENTATION_ROOT,
    "tools",
    "documentation"
)
DOCUMENTATION_WORKSPACE_ROOT = os.path.join(
    DOCUMENTATION_ROOT,
    "reports",
    "documentation",
    "standardization",
    "panel_workspaces"
)

# V20.1.Q3 STEP 19 - OFICIÁLNÍ ŠABLONY NOVÝCH DOKUMENTŮ
# CO:
# - Centrální cesty k řízeným šablonám DAILY_LOG a CHAT_CONTINUATION.
# K ČEMU:
# - Nový dokument vzniká rovnou ve struktuře očekávané A17.
# KDE:
# - docs/13_TEMPLATES na sdíleném repozitáři PC2.
# JAK:
# - Panel čte pouze obsah mezi MM-TEMPLATE-START a MM-TEMPLATE-END.
DOCUMENTATION_TEMPLATE_DIR = os.path.join(
    DOCUMENTATION_ROOT,
    "docs",
    "13_TEMPLATES"
)
DOCUMENTATION_TEMPLATES = {
    "CHAT_CONTINUATION": os.path.join(
        DOCUMENTATION_TEMPLATE_DIR,
        "MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md"
    ),
    "DAILY_LOG": os.path.join(
        DOCUMENTATION_TEMPLATE_DIR,
        "MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md"
    ),
}

DOCUMENTATION_SCRIPTS = {
    "A17": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py"
    ),
    "A18": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_18_BUILD_DOCUMENT_STANDARDIZATION_PROPOSAL_V1.py"
    ),
    "A19": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_19_REVIEW_DOCUMENT_STANDARDIZATION_MAPPING_V1.py"
    ),
    "A20": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_20_BUILD_STANDARDIZED_DOCUMENT_FROM_REVIEW_V1.py"
    ),
    "A21": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_21_POLISH_STANDARDIZED_DOCUMENT_CANDIDATE_V1.py"
    ),
    "A22": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_22_PREPARE_DAILY_LOG_CANONICAL_APPROVAL_V1.py"
    ),
    "A23": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py"
    ),
    "A24": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py"
    ),
    "A6": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_6_IMPORT_CANONICAL_DOCUMENTS_TO_DB_V1.py"
    ),
    "A7": os.path.join(
        DOCUMENTATION_TOOL_DIR,
        "25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py"
    ),
}
PYTHON_EXE = "python"

DB_CONFIG = {
    "host": "192.168.3.119",
    "port": 5432,
    "dbname": "matchmatrix",
    "user": "matchmatrix",
    "password": "matchmatrix_pass",
}

REFRESH_MS = 20000
DB_CACHE_SECONDS = 12
DB_CACHE = {}

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
    # V19.11: PHOTO LAYER - Wikimedia/Wikidata discovery worker.
    "PHOTO_ASSET_DISCOVERY_FB": [
        PYTHON_EXE,
        os.path.join(BASE_DIR, "workers", "media", "photo_asset_discovery_worker_v1.py"),
        "--sport", "FB",
        "--limit", "25",
        "--sleep", "2",
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
    "PC2 COMMAND": "DENNÍ PRÁCE",
    "FIX TASKS": "PROBLÉMY",
    "SCHEDULER": "PLÁNOVAČ",
    "WORKERS": "WORKERY",
    "ACTIVE RUNS": "AKTIVNÍ BĚHY",
    "PAYLOADS": "PAYLOADY",
    "LOGS": "LOGY",
    "AI OPS": "AI OPS",
    "ROADMAP": "ROADMAPA",
    "PEOPLE PIPELINE": "PEOPLE",
    "HARVEST": "HARVEST",
    "SPORT COMPLETION": "SPORT COMPLETION",
    "ODDS": "KURZY",
    "PROVIDERS": "PROVIDEŘI",
    "PROVIDER MATRIX": "PROVIDER MATRIX",
    "MEDIA": "MEDIA",
    "ARCHITECTURE": "ARCHITEKTURA",
    "GOVERNANCE": "GOVERNANCE",
    "DOCUMENTATION": "DOKUMENTACE",
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
    "READY_TO_RUN": "PŘIPRAVENO KE SPUŠTĚNÍ",
    "RUNNING": "BĚŽÍ",
    "DISABLED": "VYPNUTO",
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
    "CONFIRMED": "POTVRZENO",
    "CONTROLLED_HOLD": "ŘÍZENÝ HOLD",
    "SAFE_WITH_HOLD": "BEZPEČNÉ S HOLDEM",
    "BLOCK_PEOPLE_PROVIDER_INGEST": "BLOKOVAT PEOPLE PROVIDERY",
    "BLOCK_PEOPLE_INGEST": "BLOKOVAT PEOPLE INGEST",
    "NOT_IMPLEMENTED_YET": "NENÍ IMPLEMENTOVÁNO",
    "WAIT_FOR_PAID_PLAN": "ČEKÁ NA PRO",
    "IMPLEMENTATION_REQUIRED": "VÝVOJ",
    "PAID_PLAN_REQUIRED": "ČEKÁ NA PRO",
    "COMPLETED": "HOTOVO",
    "NEAR_READY": "TÉMĚŘ PŘIPRAVENO",
    "NOT_READY": "NEPŘIPRAVENO",
    "READY_FOR_MERGE": "PŘIPRAVENO K MERGE",
    "RAW_PENDING_PARSE": "RAW ČEKÁ NA PARSER",
    "HAS_ERRORS": "OBSAHUJE CHYBY",
    "DATA_GAP": "CHYBÍ DATA",
    "CONTROLLED": "ŘÍZENÉ",
    "REVIEW": "KE KONTROLE",
    "CANONICAL_MASTER": "CANONICAL MASTER",
    "SAFE_PROVIDER_MAP_CANDIDATE": "BEZPEČNÁ PROVIDER MAPA",
    "HOLD_DEPENDENCY_REVIEW": "HOLD - ZÁVISLOSTI",
    "MERGE_CANDIDATE_HAS_DEPENDENCIES": "MERGE KANDIDÁT MÁ ZÁVISLOSTI",
    "NO_DEPENDENCIES": "BEZ ZÁVISLOSTÍ",
    "KEEP_MASTER": "PONECHAT MASTER",
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




# =========================================================
# V18.2 - DOPLNĚNÉ ČESKÉ POPISKY PRO NOVÉ GOVERNANCE / V18 VIEW
# =========================================================
COLUMN_LABELS.update({
    "layer_order": "Pořadí vrstvy",
    "layer_code": "Kód vrstvy",
    "layer_name": "Název vrstvy",
    "what_is_it": "Co to je",
    "purpose": "K čemu to je",
    "input_source": "Vstup",
    "output_target": "Výstup",
    "master_objects": "Master objekty",
    "panel_usage": "Použití v panelu",
    "governance_status": "Governance stav",
    "readiness_percent": "Připravenost %",
    "readiness_status": "Stav připravenosti",
    "readiness_color": "Barva stavu",
    "readiness_note": "Poznámka připravenosti",
    "blocking_issue": "Blokace",
    "next_action": "Další krok",
    "current_state": "Aktuální stav",
    "state_reason": "Důvod stavu",
    "provider_map_confirmed": "Provider mapa OK",
    "public_merge_confirmed": "Public merge OK",
    "downstream_confirmed": "Downstream OK",
    "last_run_group": "Run group",
    "db_evidence_summary": "DB důkaz",
    "audit_note": "Audit poznámka",
    "source_type": "Typ zdroje",
    "harvest_readiness_percent": "Harvest ready %",
    "weakest_layers": "Nejslabší vrstvy",
    "biggest_blocker": "Největší blokace",
    "recommended_next_step": "Doporučený další krok",
    "next_target_date": "Další termín",
    "tab_order": "Pořadí záložky",
    "tab_code": "Kód záložky",
    "tab_name_cz": "Název záložky",
    "source_schema": "DB schema",
    "source_object": "Zdroj",
    "governance_required_status": "Požadovaný governance stav",
    "refresh_mode": "Režim obnovy",
    "priority_level": "Priorita",
    "milestone_order": "Pořadí milníku",
    "milestone_area": "Oblast",
    "target_date": "Cílové datum",
    "milestone_status": "Stav milníku",
    "milestone_color": "Barva milníku",
    "total_count": "Počet celkem",
    "with_thumbnail": "S obrázkem",
    "with_video": "S videem",
    "newest_created_at": "Nejnovější vytvořeno",
    "newest_updated_at": "Nejnovější upraveno",
    "content_source_id": "Název zdroje",
    "source_type": "Typ zdroje",
    "http_status": "HTTP stav",
    "found_urls": "Nalezené URL",
    "inserted_rows": "Vložené řádky",
    "updated_rows": "Upravené řádky",
    "skipped_rows": "Přeskočené řádky",
    "health_status": "Zdraví zdroje",
    "health_note": "Poznámka zdraví",
    "last_run_at": "Poslední běh",
    "worker_script": "Worker skript",
    "request_type": "Typ požadavku",
    "entity_id": "ID entity",
    "attempts": "Pokusy",
    "max_attempts": "Max pokusů",
    "next_allowed_refresh_at": "Další povolený refresh",
    "result_message": "Výsledek / zpráva",
    "title": "Název",
    "url": "URL",
    "is_video": "Video",
    "published_at": "Publikováno",
    "map_name": "Mapa/link tabulka",
    "linked_rows": "Napojené řádky",
    "supports_leagues": "Podporuje ligy",
    "supports_teams": "Podporuje týmy",
    "supports_fixtures": "Podporuje zápasy",
    "supports_players": "Podporuje hráče",
    "supports_player_stats": "Podporuje statistiky hráčů",
    "supports_odds": "Podporuje kurzy",
    "supports_coaches": "Podporuje trenéry",
    "supports_standings": "Podporuje tabulky",
    "players_supported": "Hráči podporováni",
    "coaches_supported": "Trenéři podporováni",
    "profiles_supported": "Profily podporovány",
    "season_stats_supported": "Sezónní statistiky",
    "match_stats_supported": "Zápasové statistiky",
    "rankings_supported": "Rankingy",
    "photos_supported": "Fotky",
    "people_provider": "People provider",
    "provider_status": "Stav providera",
    "provider_priority": "Priorita providera",
    "merge_priority": "Priorita merge",
    "fetch_priority": "Priorita fetch",
    "quality_rating": "Kvalita",
    "availability_scope": "Dostupnost",
    "free_plan_supported": "Free plán",
    "paid_plan_supported": "Paid plán",
    "expected_depth": "Hloubka dat",
    "is_primary_source": "Primární zdroj",
    "is_fallback_source": "Záložní zdroj",
    "source_endpoint": "Endpoint",
    "target_table": "Cílová tabulka",
    "endpoint_code": "Endpoint kód",
    "ingest_mode": "Režim ingestu",
    "enabled": "Povoleno",
    "batch_size": "Velikost dávky",
    "max_requests_per_run": "Max requestů / běh",
    "retry_limit": "Retry limit",
    "cooldown_seconds": "Cooldown [s]",
    "days_back": "Dny zpět",
    "days_forward": "Dny dopředu",
    "schema_name": "Schema",
    "object_type": "Typ objektu",
    "is_master": "Je master",
    "master_replacement": "Master náhrada",
    "used_by": "Používá",
    "domain_area": "Doména",
    "owner_layer": "Vrstva/owner",
    "web_usage": "Použití na webu",
    "app_usage": "Použití v aplikaci",
    "depends_on": "Závisí na",
    "used_by_objects": "Používáno objekty",
    "risk_if_wrong": "Riziko při chybě",
    "migration_action": "Migrační akce",
    "cleanup_note": "Cleanup poznámka",
    "purpose_note": "Účel",
    "object_count": "Počet objektů",
    "master_count": "Počet master objektů",
    "governance_items": "Governance oblasti",
    "governance_score_avg": "Governance skóre %",
    "confirmed_items": "Potvrzeno",
    "controlled_hold_items": "Řízený HOLD",
    "partial_items": "Částečně",
    "review_items": "Ke kontrole",
    "governance_status": "Governance stav",
    "refreshed_at": "Obnoveno",
    "oblast": "Oblast",
    "technicky_kod": "Technický kód",
    "stav_cz": "Stav",
    "skore": "Skóre",
    "vysvetleni": "Vysvětlení",
    "dukaz_v_db": "Důkaz v DB",
    "dalsi_krok": "Další krok",
    "posledni_kontrola": "Poslední kontrola",
    "panel_status": "Panel status",
    "governance_score": "Governance skóre",
})


# V18.6 - SPORT COMPLETION COMMAND CENTER
COLUMN_LABELS.update({
    "missing_layer": "Chybějící vrstva",
    "layer_percent": "Vrstva %",
    "priority_reason": "Důvod priority",
    "priority_order": "Pořadí priority",
    "recommended_sport_action": "Doporučená akce sportu",
    "focus_count": "Počet doporučení",
    "avg_total_pct": "Průměr celkem %",
    "weakest_layer": "Nejslabší vrstva",
    "weakest_layer_pct": "Nejslabší vrstva %",
})


# V18.15 - PC2 COMMAND CENTER POPISKY
COLUMN_LABELS.update({
    "effective_status": "Skutečný stav",
    "classification_reason": "Důvod klasifikace",
    "operator_recommendation": "Doporučení operátora",
    "recommendation_priority": "Priorita doporučení",
    "button_code": "Kód tlačítka",
    "button_label_cz": "Tlačítko akce",
    "button_color": "Barva tlačítka",
    "button_help_cz": "Nápověda tlačítka",
})

COLUMN_LABELS.update({
    "command_id": "ID příkazu",
    "button_label_cs": "Tlačítko",
    "provider_recommendation_short_cz": "Provider / doporučení",
    "detected_provider": "Detekovaný provider",
    "detected_entity": "Detekovaná entita",
    "provider_problem_cz": "Provider problém",
    "provider_next_step_cz": "Další krok provider",
    "provider_context_status": "Provider kontext",
    "command_title": "Název příkazu",
    "command_text": "Příkaz",
    "target_layer": "Cílová vrstva",
    "execution_bucket": "Exekuční bucket",
    "run_status": "Stav běhu",
    "safety_mode": "Bezpečnostní režim",
    "button_enabled": "Tlačítko aktivní",
    "safety_note_cs": "Bezpečnostní poznámka",
    "pc2_ready_score": "PC2 připravenost",
    "kpi_code": "KPI kód",
    "kpi_name_cs": "KPI název",
    "kpi_value": "Hodnota",
    "kpi_unit": "Jednotka",
    "kpi_status": "KPI stav",
    "kpi_note_cs": "KPI poznámka",
    "next_harvest_layer": "Další vrstva",
    "roadmap_bucket": "Roadmap bucket",
    "pc2_execution_order": "PC2 pořadí",
    "provider_gap_total": "Provider gapy",
    "provider_missing_count": "Chybějící providery",
    "provider_research_required_count": "Research providerů",
    "photo_license_review_count": "Photo licence",
    "photo_wait_for_paid_count": "Photo paid",
    "pc2_next_action_cs": "PC2 další akce",
    "priority_label_cs": "Priorita",
    "action_description": "CO TO JE",
    "purpose_description": "K ČEMU TO JE",
    "target_tables": "Kam se ukládá",
    "panel_usage": "Kde to uvidíme",
    "expected_result": "Očekávaný výsledek",
    "execution_readiness_status": "Execution readiness",
    "planner_jobs": "Planner joby",
    "pending_jobs": "Pending joby",
    "done_jobs": "Done joby",
    "failed_jobs": "Failed joby",
    "can_run": "RUN",
    "can_continue": "CONTINUE",
    "can_retry": "RETRY",
    "can_set_ready": "READY",
    "can_set_done": "DONE",
    "can_set_blocked": "BLOCKED",
    "can_set_failed": "FAILED",
    "can_test": "TEST",
    "action_code": "Akce",
    "action_label_cs": "Tlačítko",
    "action_enabled": "Povoleno",
    "action_note_cs": "Poznámka akce",
})


# V19.3 - krátké české názvy pro operační tabulky
COLUMN_LABELS.update({
    "last_result": "Poslední výsledek",
    "command_title": "Akce",
    "run_status": "Stav",
    "target_layer": "Vrstva",
    "priority_score": "Priorita",
    "execution_readiness_status": "Readiness",
    "planner_jobs": "Planner",
    "pending_jobs": "Pending",
    "done_jobs": "Done",
    "failed_jobs": "Fail",
})

# V19.11 - PHOTO REVIEW / PLAYER PHOTO LAYER
COLUMN_LABELS.update({
    "candidate_id": "ID kandidáta",
    "player_id": "ID hráče",
    "public_player_name": "Hráč v public",
    "candidate_player_name": "Hráč kandidát",
    "photo_url": "URL fotky",
    "wikidata_id": "Wikidata ID",
    "commons_file": "Commons soubor",
    "confidence_score": "Důvěra",
    "review_status": "Review stav",
    "can_approve": "Lze schválit",
    "can_reject": "Lze zamítnout",
    "public_photo_state": "Stav public fotky",
    "current_public_photo_url": "Aktuální public fotka",
    "confidence_level": "Úroveň důvěry",
    "approved_by": "Schválil",
    "approved_at": "Schváleno",
    "total_players": "Hráči celkem",
    "players_with_photo": "Hráči s fotkou",
    "pending_reviews": "Čeká review",
    "approved_reviews": "Schváleno",
    "rejected_reviews": "Zamítnuto",
    "photo_status": "Stav fotek",
})


# V20.A - OPS OVERVIEW DECLUTTER / SYSTÉMOVÉ UDÁLOSTI
COLUMN_LABELS.update({
    "event_group": "Skupina",
    "source_name": "Zdroj",
    "severity_label": "Závažnost",
    "item_count": "Počet",
    "event_message": "Zpráva",
    "recommended_action_cz": "Doporučený krok",
    "event_time": "Čas události",
})

TAB_HELP_TEXTS = {
    "DASHBOARD": ("PŘEHLED", "Hlavní operační obrazovka. Ukazuje aktuální stav OPS, frontu ke spuštění, upozornění, runtime feed, aktivní běhy a denní API limity. Použiješ ji jako první místo po spuštění panelu."),
    "SCHEDULER": ("PLÁNOVAČ", "Kontrola rozhodnutí scheduleru a Run Next auditu. Slouží k ověření, proč je worker zařazený nebo nezařazený do bezpečného spuštění."),
    "WORKERS": ("WORKERY", "Detail workerů a jejich runtime připravenosti. Používá se pro kontrolu, co lze bezpečně spustit."),
    "ACTIVE RUNS": ("AKTIVNÍ BĚHY", "Živé běhy a locky. Důležité před druhým PC a před větším harvestem, aby neběžely duplicity."),
    "PAYLOADS": ("PAYLOADY", "Stav raw/staging payloadů. Dvojklik na řádku otevře detail skupiny payloadů."),
    "LOGS": ("LOGY", "Poslední job logy a výpis běhu. Slouží k dohledání chyb workerů."),
    "FIX TASKS": ("OPRAVY", "Úkoly k opravě. Zde se řeší parser chyby, mapping chyby, safe retry a blokace."),
    "AI OPS": ("AI OPS", "AI/OPS rozhodovací vrstva. Ukazuje zdraví providerů, AI upozornění, frontu akcí, historii a Autonomous Brain."),
    "ROADMAP": ("ROADMAPA", "Projektová roadmapa, dokončenost sportů, backlog a Data Gap. Používá se pro rozhodnutí, co stavět dál."),
    "PEOPLE PIPELINE": ("PEOPLE", "People vrstva: hráči, provider mapy, staging/public coverage a stav po sportech/providerech."),
    "HARVEST": ("HARVEST", "Připravenost na masivní harvest, dry-run, locky, doporučení a readiness lidí/media/odds."),
    "SPORT COMPLETION": ("SPORT COMPLETION", "Centrum dokončenosti sportů. Ukazuje CORE, PEOPLE, MEDIA, ODDS a celkové procento po sportech, nejslabší vrstvy a doporučené další kroky."),
    "ODDS": ("KURZY", "Odds Command Center: TheOdds, Football-Data, coverage kurzů, bookmakeři, markety a nespárované kurzy."),
    "PROVIDERS": ("PROVIDEŘI", "Provider routing, alternativy, strategie, worker registry a governance panelových objektů."),
    "PROVIDER MATRIX": ("PROVIDER MATRIX", "Master matice providerů: sport/entity/provider, coverage, jobs a people provider matrix. Ukazuje, čím krmíme každou vrstvu."),
    "MEDIA": ("MEDIA", "Media Command Center: články, zdroje, health, refresh fronta a linkování na týmy/ligy/hráče."),
    "ARCHITECTURE": ("ARCHITEKTURA", "V18 architektura z kroků 118_A–118_E: vrstvy, readiness, harvest engine a zdroje panelu."),
    "GOVERNANCE": ("GOVERNANCE", "Živý přehled governance projektu: týmy, hráči, ligy, provider mapy, runtime audit a oficiální DB objekty pro panel."),
    "PC2 COMMAND": ("PC2 COMMAND", "Řídicí centrum pro druhé PC. Ukazuje PC2 KPI, další akci ke spuštění, frontu příkazů a výsledek posledních běhů."),
    "DOCUMENTATION": ("DOKUMENTACE", "Dokumentační centrum MatchMatrix. Obsahuje překladový slovník MM-REF-001, klikací výklady MM-REF-002, přímé otevření zdrojových kapitol a přehled dokumentační databáze."),
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



class KpiHiddenHandle:
    """
    Skrytý KPI handle pro metriky, které dál načítáme do panelu,
    ale už je nezobrazujeme v horní KPI liště.
    Díky tomu nemusíme rozbíjet loader funkce, které volají .config(text=...).
    """

    def __init__(self, value="0"):
        self.value_text = str(value)

    def config(self, **kwargs):
        if "text" in kwargs:
            self.value_text = str(kwargs.get("text"))

    configure = config

    def cget(self, key):
        return self.value_text if key == "text" else ""


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
    """
    V18.4 ACTIVE ONLY:
    - krátká cache pro SELECT/WITH dotazy, aby panel neotevíral DB opakovaně
      při přepínání záložek a automatickém refreshi.
    - zápisové operace se necachují.
    """

    query_text = str(sql or "").strip()
    cache_key = " ".join(query_text.split())
    use_cache = cache_key.upper().startswith(("SELECT", "WITH"))

    if use_cache:
        cached = DB_CACHE.get(cache_key)
        now_ts = time.time()
        if cached and (now_ts - cached[0]) <= DB_CACHE_SECONDS:
            return cached[1]

    conn = None

    try:
        conn = psycopg2.connect(**DB_CONFIG)

        with conn.cursor(
            cursor_factory=psycopg2.extras.RealDictCursor
        ) as cur:

            cur.execute(sql)
            rows = cur.fetchall()

            if use_cache:
                DB_CACHE[cache_key] = (time.time(), rows)

            return rows

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
        try:
            DB_CACHE.clear()
        except Exception:
            pass
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
            "MATCHMATRIX OPS PANEL V20.1.Q3 - DOCUMENTATION WORKFLOW CZ"
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
        self.pc2_select_syncing = False

        self.system_pulse_state = False

        self.fix_task_filter = "open"

        # V20.1.Q3 - DOCUMENTATION WORKFLOW RUNTIME STATE
        # CO:
        # - Stav jednoho rozpracovaného dokumentačního procesu.
        # K ČEMU:
        # - Jednotlivé kroky A17 až A24 nesmí míchat vstupy různých dokumentů.
        # KDE:
        # - Záložka DOKUMENTACE.
        # JAK:
        # - Po výběru dokumentu vznikne samostatný workspace a panel sleduje
        #   aktivní krok, proces, výsledek a výstupní soubory.
        self.documentation_workflow_document = None
        self.documentation_workflow_source_original = None
        self.documentation_workflow_manifest = None
        self.documentation_workflow_workspace = None
        self.documentation_workflow_step = None
        self.documentation_workflow_last_status = "NEVYBRÁN DOKUMENT"
        self.documentation_workflow_last_output = None

        # V20.1.Q3 STEP 09 - A17 FINDINGS UI
        self.documentation_workflow_findings = []
        self.documentation_workflow_report_json = None
        self.documentation_workflow_report_markdown = None

        # V20.1.Q3 STEP 10 - A18 STANDARDIZATION PROPOSAL
        # CO:
        # - Výstupy bezpečného návrhu opravy vytvořeného pouze ve workspace.
        # K ČEMU:
        # - Zdrojový dokument zůstává beze změny; panel uchovává návrh, diff
        #   a mapování pro navazující kontrolu A19.
        self.documentation_workflow_a18_proposal = None
        self.documentation_workflow_a18_diff = None
        self.documentation_workflow_a18_mapping_json = None
        self.documentation_workflow_a18_mapping_markdown = None
        self.documentation_workflow_a18_panel_mapping_json = None
        self.documentation_workflow_a18_panel_mapping_markdown = None

        # V20.1.Q3 STEP 12–17 - cesta od A20 až po Git commit.
        self.documentation_workflow_a20_candidate = None
        self.documentation_workflow_a20_build_json = None
        self.documentation_workflow_final_a17_json = None
        self.documentation_workflow_final_a17_markdown = None
        self.documentation_workflow_approved_candidate = None
        self.documentation_workflow_canonical_document = None
        self.documentation_workflow_canonical_a17_json = None
        self.documentation_workflow_canonical_a17_markdown = None
        self.documentation_workflow_git_commit = None

        # V20.1.Q3 STEP 18 - databázová publikační část A24 -> A6 -> A7.
        self.documentation_workflow_a24_validation_status = None
        self.documentation_workflow_a24_validation_report = None
        self.documentation_workflow_a24_validation_hash = None
        self.documentation_workflow_a24_apply_status = None
        self.documentation_workflow_a24_apply_report = None
        self.documentation_workflow_a7_status = None
        self.documentation_workflow_import_summary = {}

        self.documentation_workflow_process = None
        self.documentation_workflow_running = False
        self.documentation_workflow_started_at = None
        self.documentation_workflow_finished_at = None

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

        # V18.5 UX: tabulky bez ostrého bílého orámování.
        # Tk/ttk ve Windows umí kreslit bílé 3D hrany přes theme "clam".
        # Proto nastavujeme tmavé border/light/dark barvy a flat relief.
        style.configure(
            "Treeview",
            background="#0e0915",
            foreground=TEXT,
            fieldbackground="#0e0915",
            rowheight=24,
            font=("Segoe UI", 10),
            borderwidth=0,
            relief="flat",
            bordercolor="#2b1740",
            lightcolor="#2b1740",
            darkcolor="#0b0613",
        )

        style.configure(
            "Treeview.Heading",
            background="#15101d",
            foreground="#f0c7ff",
            font=("Segoe UI", 9, "bold"),
            borderwidth=1,
            relief="flat",
            bordercolor="#6d28d9",
            lightcolor="#6d28d9",
            darkcolor="#211332",
        )

        try:
            style.layout("Treeview", [("Treeview.treearea", {"sticky": "nswe"})])
        except Exception:
            pass

        style.configure(
            "Vertical.TScrollbar",
            background="#17111f",
            troughcolor="#09050f",
            arrowcolor="#665274",
            bordercolor="#09050f",
            lightcolor="#17111f",
            darkcolor="#09050f",
            relief="flat",
            arrowsize=6,
            width=7,
        )

        style.configure(
            "Horizontal.TScrollbar",
            background="#17111f",
            troughcolor="#09050f",
            arrowcolor="#665274",
            bordercolor="#09050f",
            lightcolor="#17111f",
            darkcolor="#09050f",
            relief="flat",
            arrowsize=6,
            width=7,
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
        header = tk.Frame(self, bg="#07040d", height=50)
        header.pack(fill="x")

        tk.Label(
            header,
            text="▰ MATCHMATRIX ŘÍDICÍ CENTRUM V20.1.Q3",
            bg="#07040d",
            fg=PINK,
            font=("Segoe UI", 18, "bold")
        ).pack(side="left", padx=(14, 10), pady=8)

        # V18.13: hlavní procento je v titulku, ne jako vysoká samostatná karta.
        self.header_project_value = tk.Label(
            header,
            text="47 %",
            bg="#07040d",
            fg="white",
            font=("Segoe UI", 18, "bold")
        )
        self.header_project_value.pack(side="left", padx=(4, 6), pady=8)

        self.header_project_note = tk.Label(
            header,
            text="CELKOVÁ PŘIPRAVENOST • PRIORITA PEOPLE / MEDIA / ODDS",
            bg="#07040d",
            fg="#c4a1dd",
            font=("Segoe UI", 8, "bold")
        )
        self.header_project_note.pack(side="left", padx=(0, 10), pady=10)

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
        # V19.3: klik na blikající stav otevře přesný seznam upozornění a doporučenou opravu.
        self.system_state.bind("<Button-1>", lambda event: self.open_active_alerts_center())
        self.system_state.configure(cursor="hand2")

        # =========================================================
        # V18.13 - RESPONSIVE MATCHMATRIX COMMAND CENTER
        # =========================================================
        # CO TO JE:
        # - Horní část je nižší a responzivní.
        # - MATCHMATRIX % je přesunuté do titulku vedle nadpisu.
        # - Stav hlavních oblastí je jako řádkový přehled.
        # - OPS KPI je roztažené do přehlednějšího pruhu s grafickými indikátory.
        # - Akce jsou seskupené a tlačítka vyplňují dostupný prostor.
        # - Při zmenšení okna se doporučení přesune pod horní řádek, aby se nic neořezávalo.

        self.command_center_values = {
            "PROJEKT": 47,
            "SPORTY": 0,
            "PROVIDEŘI": 0,
            "PEOPLE": 0,
            "MEDIA": 0,
            "ODDS": 0,
            "WEB": 20,
        }

        self.command_center_widgets = {}
        self.project_progress_values = dict(self.command_center_values)

        self.project_progress_history = [
            ("06-04", 31, 82, 75, 60, 52, 35, 10),
            ("06-05", 33, 84, 80, 65, 55, 38, 10),
            ("06-06", 34, 86, 85, 69, 58, 41, 11),
            ("06-07", 35, 88, 90, 72, 60, 43, 12),
            ("06-08", 47, 90, 95, 72, 61, 45, 20),
        ]

        command_frame = tk.Frame(
            self,
            bg="#0a0610",
            highlightbackground="#332142",
            highlightthickness=1
        )
        command_frame.pack(fill="x", padx=8, pady=(2, 4))  # V19: viditelné pouze na stránce PŘEHLED
        self.command_frame = command_frame
        self.command_layout_mode = None

        # Levý blok: stav hlavních oblastí.
        command_metrics_panel = tk.Frame(command_frame, bg="#0a0610")
        self.command_metrics_panel = command_metrics_panel
        command_metrics_panel.columnconfigure(0, weight=1)

        tk.Label(
            command_metrics_panel,
            text="▣ STAV HLAVNÍCH OBLASTÍ",
            bg="#0a0610",
            fg="#d8b4fe",
            font=("Segoe UI", 8, "bold")
        ).grid(row=0, column=0, sticky="w", pady=(0, 2))

        self.create_command_center_metric_card(command_metrics_panel, 1, "SPORTY", "Sport readiness", 90, GREEN)
        self.create_command_center_metric_card(command_metrics_panel, 2, "PROVIDEŘI", "Coverage / health", 95, GREEN)
        self.create_command_center_metric_card(command_metrics_panel, 3, "PEOPLE", "Hráči / identity", 72, YELLOW)
        self.create_command_center_metric_card(command_metrics_panel, 4, "MEDIA", "Články / video", 61, PURPLE)
        self.create_command_center_metric_card(command_metrics_panel, 5, "ODDS", "Kurzy / trhy", 45, RED)
        self.create_command_center_metric_card(command_metrics_panel, 6, "WEB", "Aplikace", 20, RED)

        # Střed: OPS KPI nahoře + akce pod tím.
        command_middle_panel = tk.Frame(command_frame, bg="#0a0610")
        self.command_middle_panel = command_middle_panel
        command_middle_panel.columnconfigure(0, weight=1)
        command_middle_panel.rowconfigure(1, weight=1)

        command_kpi_panel = tk.Frame(command_middle_panel, bg="#0a0610")
        command_kpi_panel.grid(row=0, column=0, sticky="ew", pady=(0, 4))
        command_kpi_panel.columnconfigure(0, weight=1)

        tk.Label(
            command_kpi_panel,
            text="◈ OPS KPI",
            bg="#0a0610",
            fg="#d8b4fe",
            font=("Segoe UI", 8, "bold")
        ).grid(row=0, column=0, sticky="w", pady=(0, 2))

        kpi_grid = tk.Frame(command_kpi_panel, bg="#0a0610")
        kpi_grid.grid(row=1, column=0, sticky="ew")
        for kpi_col in range(5):
            kpi_grid.columnconfigure(kpi_col, weight=1, uniform="ops_kpi")

        self.kpi_stav = self.create_command_kpi_tile(kpi_grid, 0, "🛡 STAV", "PŘIPRAVEN", GREEN, "Systém")
        self.kpi_pending = self.create_command_kpi_tile(kpi_grid, 1, "⏳ FRONTY", "0", YELLOW, "Ke spuštění")
        self.kpi_alerty = self.create_command_kpi_tile(kpi_grid, 2, "🔔 ALERTY", "0", RED, "Kritické/var.")
        self.kpi_safe = self.create_command_kpi_tile(kpi_grid, 3, "✅ SAFE RUN", "0", PURPLE, "Bezpečné")
        self.kpi_conf = self.create_command_kpi_tile(kpi_grid, 4, "📈 AI SKÓRE", "0", PINK, "Důvěra")

        # Detailní technické KPI zůstávají načítané, ale nejsou v horní části.
        self.coverage_ready = KpiHiddenHandle("0")
        self.coverage_missing = KpiHiddenHandle("0")
        self.dev_backlog = KpiHiddenHandle("0")
        self.ai_critical = KpiHiddenHandle("0")
        self.ai_safe_retry = KpiHiddenHandle("0")
        self.ai_auto_fix = KpiHiddenHandle("0")
        self.ai_blocking = KpiHiddenHandle("0")
        self.ai_score = KpiHiddenHandle("0")
        self.coverage_paid = KpiHiddenHandle("0")
        self.autonomous_ready = KpiHiddenHandle("0")
        self.autonomous_running = KpiHiddenHandle("0")
        self.autonomous_success = KpiHiddenHandle("0")
        self.autonomous_failed = KpiHiddenHandle("0")

        action_panel = tk.Frame(command_frame, bg="#0a0610")
        self.command_actions_panel = action_panel
        action_panel.columnconfigure(0, weight=1)

        tk.Label(
            action_panel,
            text="🚀 RYCHLÉ AKCE",
            bg="#0a0610",
            fg="#d8b4fe",
            font=("Segoe UI", 8, "bold")
        ).grid(row=0, column=0, sticky="w", pady=(0, 2))

        def command_button(parent, row, col, text, color, command, colspan=1):
            btn = tk.Button(
                parent,
                text=text,
                command=command,
                bg=color,
                fg="white",
                activebackground="#273145",
                activeforeground="white",
                font=("Segoe UI", 8, "bold"),
                bd=0,
                relief="flat",
                padx=4,
                pady=3
            )
            btn.grid(row=row, column=col, columnspan=colspan, sticky="ew", padx=3, pady=3)
            return btn

        action_grid = tk.Frame(action_panel, bg="#0a0610")
        action_grid.grid(row=1, column=0, sticky="ew")
        for action_col in range(6):
            action_grid.columnconfigure(action_col, weight=1, uniform="action")

        tk.Label(action_grid, text="SYSTÉM", bg="#0a0610", fg="#8f7ca3", font=("Segoe UI", 7, "bold"), anchor="w").grid(row=0, column=0, sticky="ew", padx=3)
        command_button(action_grid, 1, 0, "↻ OBNOVIT", "#3b2555", self.refresh_all, 2)
        self.auto_mode_button = command_button(action_grid, 1, 2, "● REŽIM: MANUÁL", "#3b2555", self.toggle_auto_mode, 2)
        command_button(action_grid, 1, 4, "⭐ DOPORUČENÁ", "#6d45b8", self.run_recommended_worker, 2)

        tk.Label(action_grid, text="SPUŠTĚNÍ", bg="#0a0610", fg="#8f7ca3", font=("Segoe UI", 7, "bold"), anchor="w").grid(row=2, column=0, sticky="ew", padx=3)
        command_button(action_grid, 3, 0, "▶ DALŠÍ", "#0f6a42", self.run_next_safe, 2)
        command_button(action_grid, 3, 2, "▶ VYBRANÝ", "#0f5f63", self.run_selected_worker, 2)
        command_button(action_grid, 3, 4, "▶ WORKER", "#0f6a42", lambda: self.start_worker_by_code("CORE_INGEST_V3", "CORE INGEST"), 2)

        tk.Label(action_grid, text="AI / LOG", bg="#0a0610", fg="#8f7ca3", font=("Segoe UI", 7, "bold"), anchor="w").grid(row=4, column=0, sticky="ew", padx=3)
        command_button(action_grid, 5, 0, "ℹ PROČ", "#4c2c83", self.explain_recommended_worker, 2)
        command_button(action_grid, 5, 2, "🤖 AUTO", "#0f5f63", self.run_autonomous_dispatch, 2)
        command_button(action_grid, 5, 4, "🗑 LOG", "#6f1d4d", self.clear_log, 2)

        runtime_row = tk.Frame(action_panel, bg="#0a0610")
        runtime_row.grid(row=2, column=0, sticky="ew", pady=(2, 0))
        runtime_row.columnconfigure(0, weight=1)

        self.worker_activity_label = tk.Label(
            runtime_row,
            text="● ŽÁDNÁ AKCE NEBĚŽÍ",
            bg="#0a0610",
            fg="#bca0d4",
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.worker_activity_label.grid(row=0, column=0, sticky="ew")

        self.auto_status_label = tk.Label(
            runtime_row,
            text="MANUÁL | CÍL: ZVÝŠIT NEJSLABŠÍ VRSTVU",
            bg="#0a0610",
            fg="#bca0d4",
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.auto_status_label.grid(row=1, column=0, sticky="ew", pady=(1, 0))

        self.worker_progress = ttk.Progressbar(runtime_row, mode="indeterminate", length=180)
        self.worker_progress.grid(row=2, column=0, sticky="ew", pady=(3, 0))

        # Pravý blok: doporučení. V úzkém okně se přelomí pod horní řádek.
        self.priority_bar = tk.Frame(command_frame, bg="#0a0610")
        self.priority_bar.columnconfigure(0, weight=1)
        self.priority_bar.rowconfigure(1, weight=1)
        self.priority_bar.rowconfigure(2, weight=1)

        tk.Label(
            self.priority_bar,
            text="☰ DOPORUČENÍ",
            bg="#0a0610",
            fg="#d8b4fe",
            font=("Segoe UI", 8, "bold")
        ).grid(row=0, column=0, sticky="w", pady=(0, 2))

        self.today_priority_text = self.create_info_card(self.priority_bar, "🎯 DNEŠNÍ PRIORITA", 1, 0)
        self.ai_recommendation_text = self.create_info_card(self.priority_bar, "🤖 AI DOPORUČENÍ", 2, 0)

        command_frame.bind("<Configure>", lambda event: self.reflow_command_center())
        self.after(150, self.reflow_command_center)

        # NOTEBOOK
        # HLAVNÍ OBSAH + SPODNÍ LIŠTA ZÁLOŽEK
        # V18.13: spodní záložky zůstávají vidět, posouvá se pouze střední tabulková část.
        self.content_outer = tk.Frame(self, bg=BG)
        self.content_outer.pack(fill="both", expand=True, side="right", padx=(4, 8), pady=(4, 2))
        self.content_outer.columnconfigure(0, weight=1)
        self.content_outer.rowconfigure(0, weight=1)

        self.content_canvas = tk.Canvas(
            self.content_outer,
            bg=BG,
            highlightthickness=0,
            bd=0
        )
        self.content_canvas.grid(row=0, column=0, sticky="nsew")

        self.content_vsb = ttk.Scrollbar(
            self.content_outer,
            orient="vertical",
            command=self.content_canvas.yview
        )
        self.content_vsb.grid(row=0, column=1, sticky="ns")
        self.content_canvas.configure(yscrollcommand=self.content_vsb.set)

        self.content_area = tk.Frame(self.content_canvas, bg=BG)
        self.content_window_id = self.content_canvas.create_window(
            (0, 0),
            window=self.content_area,
            anchor="nw"
        )

        self.content_canvas.bind("<Configure>", self.sync_content_canvas)
        self.content_area.bind("<Configure>", self.update_content_scrollregion)
        self.content_canvas.bind_all("<Shift-MouseWheel>", self.scroll_content_mousewheel)

        # V19: hlavní navigace je vlevo, ne dole.
        self.bottom_tabs = tk.Frame(self, bg="#0d0716", width=230)
        self.bottom_tabs.pack(fill="y", side="left", padx=(8, 4), pady=(4, 6))
        self.bottom_tab_buttons = []
        self.bottom_tabs.bind("<Configure>", lambda event: self.reflow_bottom_tabs())

        # =========================================================
        # V19.7 - GLOBÁLNÍ PRAVÁ AKČNÍ LIŠTA
        # =========================================================
        # CO TO JE:
        # - Pravý ovládací sloupec naproti levé navigaci.
        # - Je dostupný po celé výšce denní práce, ne jen uvnitř jedné tabulky.
        # - Slouží pouze pro akce nad vybraným řádkem.
        # - Globální rychlé akce jsou v horní části přehledu.
        try:
            self.content_outer.pack_forget()
        except Exception:
            pass

        self.global_pc2_action_side = tk.Frame(
            self,
            bg="#100918",
            width=190,
            highlightbackground="#3b2555",
            highlightthickness=1
        )
        self.global_pc2_action_side.pack(fill="y", side="right", padx=(4, 8), pady=(4, 6))
        self.global_pc2_action_side.pack_propagate(False)
        self.global_pc2_action_side.columnconfigure(0, weight=1)

        tk.Label(
            self.global_pc2_action_side,
            text="🎮 AKCE NAD ŘÁDKEM",
            bg="#100918",
            fg="#f0c7ff",
            font=("Segoe UI", 10, "bold"),
            anchor="w"
        ).grid(row=0, column=0, sticky="ew", padx=8, pady=(8, 3))

        self.global_pc2_selected_action_label = tk.Label(
            self.global_pc2_action_side,
            text="Vyber řádek vlevo. Tady jsou akce jen pro vybraný řádek.",
            bg="#100918",
            fg="#cdb7df",
            font=("Segoe UI", 7, "bold"),
            anchor="w",
            justify="left",
            wraplength=160
        )
        self.global_pc2_selected_action_label.grid(row=1, column=0, sticky="ew", padx=8, pady=(0, 6))
        self.pc2_selected_action_label = self.global_pc2_selected_action_label

        def global_pc2_group(row, title):
            lbl = tk.Label(
                self.global_pc2_action_side,
                text=title,
                bg="#100918",
                fg="#8f7ca3",
                font=("Segoe UI", 7, "bold"),
                anchor="w"
            )
            lbl.grid(row=row, column=0, sticky="ew", padx=8, pady=(8, 1))
            return lbl

        def global_pc2_button(row, text, color, command):
            btn = tk.Button(
                self.global_pc2_action_side,
                text=text,
                command=command,
                bg=color,
                fg="white",
                activebackground="#273145",
                activeforeground="white",
                font=("Segoe UI", 7, "bold"),
                bd=1,
                relief="raised",
                padx=4,
                pady=4,
                anchor="w",
                cursor="hand2",
                wraplength=158,
                justify="left"
            )
            btn.grid(row=row, column=0, sticky="ew", padx=8, pady=2)
            return btn

        global_pc2_group(2, "1) SPUŠTĚNÍ")
        self.global_pc2_run_button = global_pc2_button(3, "▶ SPUSTIT DALŠÍ READY", "#0f6a42", self.run_pc2_next_command)
        global_pc2_button(4, "▶ SPUSTIT VYBRANOU", "#0f5f63", self.run_pc2_selected_command)
        global_pc2_button(5, "▶ POKRAČOVAT", "#0f6a42", self.pc2_continue_selected_command)

        global_pc2_group(6, "2) STAV")
        global_pc2_button(7, "✓ READY", "#3b2555", lambda: self.pc2_set_selected_status("READY_TO_RUN"))
        global_pc2_button(8, "✔ HOTOVO", "#355e3b", lambda: self.pc2_set_selected_status("DONE"))
        global_pc2_button(9, "⛔ BLOKOVAT", "#7f1d1d", lambda: self.pc2_set_selected_status("BLOCKED"))
        global_pc2_button(10, "⚠ CHYBA", "#92400e", lambda: self.pc2_set_selected_status("FAILED"))

        global_pc2_group(11, "3) OPRAVA")
        global_pc2_button(12, "↻ RETRY / READY", "#6d45b8", self.pc2_retry_selected_command)
        global_pc2_button(13, "⏳ PLANNER PENDING", "#4c2c83", self.pc2_reset_selected_planner_pending)

        global_pc2_group(14, "4) KONTROLA")
        global_pc2_button(15, "🔍 TEST", "#0f5f63", self.pc2_test_selected_command)
        global_pc2_button(16, "↻ OBNOVIT PC2", "#3b2555", self.load_pc2_command_center)

        # V20.1.P - DOPORUČENÁ AKCE Z OPERATOR ENGINE
        # CO TO JE:
        # - Dynamické tlačítko podle ops.v_operator_action_buttons_v1.
        # K ČEMU TO JE:
        # - Operátor u vybraného řádku okamžitě vidí, co má udělat dál.
        global_pc2_group(17, "5) DOPORUČENÁ AKCE")
        self.global_operator_action_help = tk.Label(
            self.global_pc2_action_side,
            text="Vyber řádek. Panel načte doporučenou akci.",
            bg="#100918",
            fg="#cdb7df",
            font=("Segoe UI", 7, "bold"),
            anchor="w",
            justify="left",
            wraplength=158
        )
        self.global_operator_action_help.grid(row=18, column=0, sticky="ew", padx=8, pady=(2, 2))
        self.global_operator_action_button = global_pc2_button(
            19,
            "🔎 DETAIL",
            "#4c2c83",
            self.run_operator_recommended_action
        )

        # V19.8: uložíme widgety řádkových akcí, aby se daly skrýt v PŘEHLEDU.
        self.global_pc2_row_action_widgets = list(self.global_pc2_action_side.grid_slaves())

        # V19.8: pravá lišta pro PŘEHLED = globální rychlé akce panelu.
        # V PŘEHLEDU nechceme akce nad řádkem, ale ovládání panelu.
        self.global_quick_actions_side = tk.Frame(self.global_pc2_action_side, bg="#100918")
        self.global_quick_actions_side.grid(row=0, column=0, sticky="nsew")
        self.global_quick_actions_side.columnconfigure(0, weight=1)
        self.global_quick_actions_side.grid_remove()

        tk.Label(
            self.global_quick_actions_side,
            text="🚀 RYCHLÉ AKCE",
            bg="#100918",
            fg="#f0c7ff",
            font=("Segoe UI", 10, "bold"),
            anchor="w"
        ).grid(row=0, column=0, sticky="ew", padx=8, pady=(8, 3))

        tk.Label(
            self.global_quick_actions_side,
            text="Globální akce panelu. Nejsou vázané na vybraný řádek.",
            bg="#100918",
            fg="#cdb7df",
            font=("Segoe UI", 7, "bold"),
            anchor="w",
            justify="left",
            wraplength=176
        ).grid(row=1, column=0, sticky="ew", padx=8, pady=(0, 6))

        def quick_side_group(row, title):
            tk.Label(
                self.global_quick_actions_side,
                text=title,
                bg="#100918",
                fg="#8f7ca3",
                font=("Segoe UI", 7, "bold"),
                anchor="w"
            ).grid(row=row, column=0, sticky="ew", padx=8, pady=(8, 1))

        def quick_side_button(row, text, color, command):
            btn = tk.Button(
                self.global_quick_actions_side,
                text=text,
                command=command,
                bg=color,
                fg="white",
                activebackground="#273145",
                activeforeground="white",
                font=("Segoe UI", 7, "bold"),
                bd=1,
                relief="raised",
                padx=5,
                pady=5,
                anchor="w",
                cursor="hand2",
                wraplength=172,
                justify="left"
            )
            btn.grid(row=row, column=0, sticky="ew", padx=8, pady=2)
            return btn

        quick_side_group(2, "1) SYSTÉM")
        quick_side_button(3, "↻ OBNOVIT", "#3b2555", self.refresh_all)
        self.quick_auto_mode_button = quick_side_button(4, "● REŽIM: MANUÁL", "#3b2555", self.toggle_auto_mode)
        quick_side_button(5, "⭐ DOPORUČENÁ", "#6d45b8", self.run_recommended_worker)

        quick_side_group(6, "2) SPUŠTĚNÍ")
        quick_side_button(7, "▶ DALŠÍ", "#0f6a42", self.run_next_safe)
        quick_side_button(8, "▶ VYBRANÝ", "#0f5f63", self.run_selected_worker)
        quick_side_button(9, "▶ WORKER", "#0f6a42", lambda: self.start_worker_by_code("CORE_INGEST_V3", "CORE INGEST"))

        quick_side_group(10, "3) AI / LOG")
        quick_side_button(11, "ℹ PROČ", "#4c2c83", self.explain_recommended_worker)
        quick_side_button(12, "🤖 AUTO", "#0f5f63", self.run_autonomous_dispatch)
        quick_side_button(13, "🗑 LOG", "#6f1d4d", self.clear_log)

        # Středový obsah je mezi levou navigací a pravou akční lištou.
        self.content_outer.pack(fill="both", expand=True, side="right", padx=(4, 4), pady=(4, 2))

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
        tab_sport_completion = tk.Frame(self.content_area, bg=BG)
        tab_odds = tk.Frame(self.content_area, bg=BG)
        tab_providers = tk.Frame(self.content_area, bg=BG)
        tab_provider_matrix = tk.Frame(self.content_area, bg=BG)
        tab_media = tk.Frame(self.content_area, bg=BG)
        tab_architecture = tk.Frame(self.content_area, bg=BG)
        tab_governance = tk.Frame(self.content_area, bg=BG)
        tab_documentation = tk.Frame(self.content_area, bg=BG)
        tab_pc2_command = tk.Frame(self.content_area, bg=BG)

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
            "SPORT COMPLETION": tab_sport_completion,
            "ODDS": tab_odds,
            "PROVIDERS": tab_providers,
            "PROVIDER MATRIX": tab_provider_matrix,
            "MEDIA": tab_media,
            "ARCHITECTURE": tab_architecture,
            "GOVERNANCE": tab_governance,
            "DOCUMENTATION": tab_documentation,
            "PC2 COMMAND": tab_pc2_command,
        }

        for frame in self.tabs.values():
            frame.place(relx=0, rely=0, relwidth=1, relheight=1)

        self.create_bottom_tab("🏠", "PC2 COMMAND")
        self.create_bottom_tab("⚠", "FIX TASKS")
        self.create_bottom_tab("▦", "DASHBOARD")
        self.create_bottom_tab("◷", "SCHEDULER")
        self.create_bottom_tab("👥", "WORKERS")
        self.create_bottom_tab("▶", "ACTIVE RUNS")
        self.create_bottom_tab("▣", "PAYLOADS")
        self.create_bottom_tab("▤", "LOGS")
        self.create_bottom_tab("🤖", "AI OPS")
        self.create_bottom_tab("🌾", "HARVEST")
        self.create_bottom_tab("👥", "PEOPLE PIPELINE")
        self.create_bottom_tab("📰", "MEDIA")
        self.create_bottom_tab("🎯", "ODDS")
        self.create_bottom_tab("🏆", "SPORT COMPLETION")
        self.create_bottom_tab("🔌", "PROVIDERS")
        self.create_bottom_tab("🧬", "PROVIDER MATRIX")
        self.create_bottom_tab("🏛", "GOVERNANCE")
        self.create_bottom_tab("📚", "DOCUMENTATION")
        self.create_bottom_tab("🧱", "ARCHITECTURE")
        self.create_bottom_tab("🧭", "ROADMAP")

        # V19 FIX: výchozí záložku DENNÍ PRÁCE zapneme až po vytvoření všech widgetů.
        # Původní volání tady spouštělo load_pc2_command_center() dřív, než existoval self.pc2_button_tree.
        
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

        # V20.A OPS OVERVIEW DECLUTTER
        # CO TO JE:
        # - Jedna společná tabulka pro alerty, runtime feed a zdraví workerů.
        # K ČEMU TO JE:
        # - Přehled není přeplněný třemi podobnými tabulkami vedle sebe.
        # KDE TO UVIDÍME:
        # - PŘEHLED -> SYSTÉMOVÉ UDÁLOSTI.
        # JAK SE TO VYUŽIJE:
        # - Operátor řeší nejdřív CRITICAL / FAILED / WARNING řádky a detail otevírá dvojklikem.
        self.system_events_tree = self.create_section(
            dashboard_row_2, "🔔 SYSTÉMOVÉ UDÁLOSTI", 0, 0, 3
        )

        # Zpětná kompatibilita: staré loader funkce už v PŘEHLEDU nevoláme,
        # ale některé pomocné funkce mohou kontrolovat existenci těchto atributů.
        self.alerts_tree = self.system_events_tree
        self.feed_tree = self.system_events_tree
        self.worker_health_tree = self.system_events_tree

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

        # =========================================================
        # V18.6: SPORT COMPLETION COMMAND CENTER
        # =========================================================
        tab_sport_completion.columnconfigure(0, weight=2)
        tab_sport_completion.columnconfigure(1, weight=1)
        tab_sport_completion.rowconfigure(0, weight=2)
        tab_sport_completion.rowconfigure(1, weight=1)
        tab_sport_completion.rowconfigure(2, weight=2)

        self.sport_completion_main_tree = self.create_section(
            tab_sport_completion, "🏆 SPORT COMPLETION - HLAVNÍ PŘEHLED", 0, 0
        )
        self.sport_completion_main_tree.bind(
            "<Double-1>", self.open_sport_completion_detail
        )

        self.sport_completion_focus_tree = self.create_section(
            tab_sport_completion, "🎯 NEJSLABŠÍ VRSTVY", 0, 1
        )

        self.sport_completion_missing_tree = self.create_section(
            tab_sport_completion, "🧩 CHYBĚJÍCÍ VRSTVY / PRIORITY", 1, 0, 2
        )

        self.sport_completion_ai_tree = self.create_section(
            tab_sport_completion, "🤖 AI DOPORUČENÍ PRO SPORTY", 2, 0
        )

        self.sport_completion_gap_tree = self.create_section(
            tab_sport_completion, "📋 DATA GAP DETAIL", 2, 1
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

        # =========================================================
        # V18.1: PROVIDER MATRIX COMMAND CENTER
        # =========================================================
        tab_provider_matrix.columnconfigure(0, weight=1)
        tab_provider_matrix.columnconfigure(1, weight=1)
        tab_provider_matrix.rowconfigure(0, weight=1)
        tab_provider_matrix.rowconfigure(1, weight=1)
        tab_provider_matrix.rowconfigure(2, weight=1)

        self.provider_matrix_core_tree = self.create_section(
            tab_provider_matrix, "🧬 PROVIDER MATRIX - SPORT / ENTITA", 0, 0, 2
        )

        self.provider_matrix_people_tree = self.create_section(
            tab_provider_matrix, "👥 PEOPLE MASTER MATRIX", 1, 0
        )

        self.provider_matrix_coverage_tree = self.create_section(
            tab_provider_matrix, "📦 PROVIDER ENTITY COVERAGE", 1, 1
        )

        self.provider_matrix_jobs_tree = self.create_section(
            tab_provider_matrix, "⚙ PROVIDER JOBS", 2, 0, 2
        )

        # =========================================================
        # V18.1 / V19.11: MEDIA COMMAND CENTER + PHOTO REVIEW
        # =========================================================
        tab_media.columnconfigure(0, weight=1)
        tab_media.columnconfigure(1, weight=1)
        tab_media.rowconfigure(0, weight=0)
        tab_media.rowconfigure(1, weight=1)
        tab_media.rowconfigure(2, weight=1)
        tab_media.rowconfigure(3, weight=1)
        tab_media.rowconfigure(4, weight=1)

        photo_button_bar = tk.Frame(tab_media, bg=BG)
        photo_button_bar.grid(row=0, column=0, columnspan=2, sticky="ew", padx=4, pady=4)

        self.make_button(
            photo_button_bar,
            "🖼 SPUSTIT FB PHOTO WORKER",
            "#7c3aed",
            lambda: self.start_worker_by_code("PHOTO_ASSET_DISCOVERY_FB", "FB PHOTO DISCOVERY")
        )

        self.make_button(
            photo_button_bar,
            "✅ SCHVÁLIT FOTO",
            "#0f6a42",
            self.photo_approve_selected_candidate
        )

        self.make_button(
            photo_button_bar,
            "🖼 ZOBRAZIT FOTO",
            "#4c2c83",
            self.photo_preview_selected_candidate
        )

        self.make_button(
            photo_button_bar,
            "⛔ ZAMÍTNOUT FOTO",
            "#7f1d1d",
            self.photo_reject_selected_candidate
        )

        self.make_button(
            photo_button_bar,
            "🔀 MERGE FOTO",
            "#0f5f63",
            self.photo_merge_approved_candidates
        )

        self.make_button(
            photo_button_bar,
            "↻ OBNOVIT MEDIA",
            "#3b2555",
            self.load_media_dashboard
        )

        self.media_overview_tree = self.create_section(
            tab_media, "📰 MEDIA OVERVIEW", 1, 0
        )

        self.media_sources_tree = self.create_section(
            tab_media, "🔎 MEDIA SOURCE HEALTH", 1, 1
        )

        self.media_refresh_queue_tree = self.create_section(
            tab_media, "♻ MEDIA REFRESH QUEUE", 2, 0
        )

        self.media_articles_recent_tree = self.create_section(
            tab_media, "🗞 POSLEDNÍ ČLÁNKY", 2, 1
        )

        self.media_linking_tree = self.create_section(
            tab_media, "🔗 MEDIA LINKING", 3, 0
        )

        self.photo_review_dashboard_tree = self.create_section(
            tab_media, "🖼 PHOTO DASHBOARD", 3, 1
        )

        self.photo_review_panel_tree = self.create_section(
            tab_media, "✅ PHOTO REVIEW - KANDIDÁTI", 4, 0, 2
        )
# =========================================================
        # V18.1: ARCHITECTURE / READINESS COMMAND CENTER
        # =========================================================
        tab_architecture.columnconfigure(0, weight=1)
        tab_architecture.columnconfigure(1, weight=1)
        tab_architecture.rowconfigure(0, weight=1)
        tab_architecture.rowconfigure(1, weight=1)
        tab_architecture.rowconfigure(2, weight=1)

        self.architecture_map_tree = self.create_section(
            tab_architecture, "🧱 MASTER ARCHITECTURE MAP", 0, 0, 2
        )

        self.layer_readiness_tree = self.create_section(
            tab_architecture, "📊 LAYER READINESS", 1, 0
        )

        self.harvest_engine_tree = self.create_section(
            tab_architecture, "🌾 HARVEST READINESS ENGINE", 1, 1
        )

        self.panel_sources_tree = self.create_section(
            tab_architecture, "🧭 V18 PANEL SOURCES", 2, 0, 2
        )

        # =========================================================
        # V18.14: GOVERNANCE COMMAND CENTER
        # =========================================================
        tab_governance.columnconfigure(0, weight=1)
        tab_governance.columnconfigure(1, weight=1)
        tab_governance.rowconfigure(0, weight=1)
        tab_governance.rowconfigure(1, weight=1)
        tab_governance.rowconfigure(2, weight=1)

        self.governance_summary_tree = self.create_section(
            tab_governance, "🏛 GOVERNANCE KPI", 0, 0
        )

        self.governance_master_tree = self.create_section(
            tab_governance, "✅ GOVERNANCE DETAIL", 0, 1
        )

        self.governance_review_tree = self.create_section(
            tab_governance, "🧾 RUNTIME GOVERNANCE AUDIT", 1, 0
        )

        self.governance_legacy_tree = self.create_section(
            tab_governance, "📦 DB OBJECT GOVERNANCE", 1, 1
        )

        self.governance_detail_tree = self.create_section(
            tab_governance, "📚 ACTIVE MASTER ZDROJE PANELU", 2, 0, 2
        )

        # =========================================================
        # V20.1.Q: DOCUMENTATION CENTER
        # =========================================================
        # CO TO JE:
        # - Read-only přehled dokumentační databáze a rychlé odkazy na soubory.
        # K ČEMU TO JE:
        # - Operátor vidí stav dokumentů, verzí, sekcí, vazeb a importů bez DBeaveru.
        # - Základ pro budoucí několikaklikový dokumentační workflow.
        tab_documentation.columnconfigure(0, weight=1)
        tab_documentation.columnconfigure(1, weight=1)
        tab_documentation.rowconfigure(1, weight=0)
        tab_documentation.rowconfigure(2, weight=2)
        tab_documentation.rowconfigure(3, weight=1)
        tab_documentation.rowconfigure(4, weight=1)
        tab_documentation.rowconfigure(5, weight=1)

        documentation_button_bar = tk.Frame(tab_documentation, bg=BG)
        documentation_button_bar.grid(
            row=0,
            column=0,
            columnspan=2,
            sticky="ew",
            padx=4,
            pady=4
        )

        self.make_button(
            documentation_button_bar,
            "↻ OBNOVIT",
            "#3b2555",
            self.load_documentation_dashboard
        )
        self.make_button(
            documentation_button_bar,
            "📂 HLAVNÍ DOKUMENTACE",
            "#4c2c83",
            lambda: self.open_matchmatrix_path("docs")
        )
        self.make_button(
            documentation_button_bar,
            "📅 DENNÍ ZÁPISY",
            "#6d45b8",
            lambda: self.open_matchmatrix_path(
                os.path.join("docs", "09_HISTORY", "DENNÍ_ZÁPISY")
            )
        )
        self.make_button(
            documentation_button_bar,
            "🔗 NAVÁZÁNÍ",
            "#0f5f63",
            lambda: self.open_matchmatrix_path(
                os.path.join("docs", "09_HISTORY", "NAVÁZÁNÍ_NA_CHAT")
            )
        )
        self.make_button(
            documentation_button_bar,
            "📖 PŘEKLADY",
            "#0f6a42",
            lambda: self.open_matchmatrix_path(
                os.path.join(
                    "docs",
                    "10_REFERENCE",
                    "MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md"
                )
            )
        )
        self.make_button(
            documentation_button_bar,
            "📘 VÝKLAD POJMŮ",
            "#0f5f63",
            lambda: self.open_matchmatrix_path(
                os.path.join(
                    "docs",
                    "10_REFERENCE",
                    "MM-REF-002_VYKLADOVY_REJSTRIK_POJMU_MATCHMATRIX.md"
                )
            )
        )
        self.make_button(
            documentation_button_bar,
            "📊 REPORTY",
            "#581c87",
            lambda: self.open_matchmatrix_path(
                os.path.join("reports", "documentation")
            )
        )

        # V20.1.Q3 - ŘÍZENÝ DOKUMENTAČNÍ WORKFLOW
        # CO:
        # - Výběr jednoho zdrojového Markdown dokumentu.
        # K ČEMU:
        # - Založí izolovaný workspace pro navazující A17 až A24.
        # KDE:
        # - Horní část záložky DOKUMENTACE.
        # JAK:
        # - Tlačítko VYBRAT DOKUMENT vytvoří pracovní kopii a manifest.
        documentation_workflow_frame = tk.Frame(
            tab_documentation,
            bg="#100918",
            highlightbackground=CARD_BORDER,
            highlightthickness=1
        )
        documentation_workflow_frame.grid(
            row=1,
            column=0,
            columnspan=2,
            sticky="ew",
            padx=4,
            pady=4
        )
        documentation_workflow_frame.columnconfigure(1, weight=1)
        documentation_workflow_frame.columnconfigure(3, weight=1)

        tk.Label(
            documentation_workflow_frame,
            text="🧭 ŘÍZENÝ DOKUMENTAČNÍ WORKFLOW",
            bg="#100918",
            fg="#d8b4fe",
            font=("Segoe UI", 10, "bold")
        ).grid(
            row=0,
            column=0,
            columnspan=4,
            sticky="w",
            padx=8,
            pady=(6, 4)
        )

        workflow_action_bar = tk.Frame(
            documentation_workflow_frame,
            bg="#100918"
        )
        workflow_action_bar.grid(
            row=1,
            column=0,
            columnspan=4,
            sticky="ew",
            padx=6,
            pady=(0, 5)
        )

        # V20.1.Q3 STEP 14:
        # Čtyři hlavní fáze místo dvanácti samostatných tlačítek.
        # Každé tlačítko provede právě následující chybějící krok své fáze.
        # Pravé tlačítko myši otevře nabídku všech dílčích akcí fáze.
        phase_buttons = []

        def add_phase_button(label, color, command, menu_builder):
            button = tk.Button(
                workflow_action_bar,
                text=label,
                bg=color,
                fg="white",
                activebackground=color,
                activeforeground="white",
                relief="flat",
                bd=0,
                font=("Segoe UI", 9, "bold"),
                cursor="hand2",
                command=command,
                padx=10,
                pady=5
            )
            button.pack(side="left", fill="x", expand=True, padx=5)
            button.bind(
                "<Button-3>",
                lambda event, builder=menu_builder: self._documentation_show_phase_menu(
                    event,
                    builder()
                )
            )
            phase_buttons.append(button)
            return button

        add_phase_button(
            "1  VYBRAT A ANALYZOVAT",
            "#6d45b8",
            self.documentation_phase_1_analyze,
            self._documentation_phase_1_menu
        )
        add_phase_button(
            "2  OPRAVIT A ZKONTROLOVAT",
            "#9a5b13",
            self.documentation_phase_2_review,
            self._documentation_phase_2_menu
        )
        add_phase_button(
            "3  VYTVOŘIT A SCHVÁLIT",
            "#0f6a42",
            self.documentation_phase_3_build,
            self._documentation_phase_3_menu
        )
        add_phase_button(
            "4  PUBLIKOVAT",
            "#0f5f63",
            self.documentation_phase_4_publish,
            self._documentation_phase_4_menu
        )

        tk.Label(
            documentation_workflow_frame,
            text="DOKUMENT:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=2,
            column=0,
            sticky="w",
            padx=(8, 4),
            pady=2
        )

        self.documentation_workflow_document_value = tk.Label(
            documentation_workflow_frame,
            text="NEVYBRÁN",
            bg="#100918",
            fg=TEXT,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.documentation_workflow_document_value.grid(
            row=2,
            column=1,
            sticky="ew",
            padx=(0, 8),
            pady=2
        )

        tk.Label(
            documentation_workflow_frame,
            text="STAV:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=2,
            column=2,
            sticky="w",
            padx=(8, 4),
            pady=2
        )

        self.documentation_workflow_status_value = tk.Label(
            documentation_workflow_frame,
            text="NEVYBRÁN DOKUMENT",
            bg="#100918",
            fg=YELLOW,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.documentation_workflow_status_value.grid(
            row=2,
            column=3,
            sticky="ew",
            padx=(0, 8),
            pady=2
        )

        tk.Label(
            documentation_workflow_frame,
            text="KROK:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=3,
            column=0,
            sticky="w",
            padx=(8, 4),
            pady=(2, 6)
        )

        self.documentation_workflow_step_value = tk.Label(
            documentation_workflow_frame,
            text="-",
            bg="#100918",
            fg=TEXT,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        )
        self.documentation_workflow_step_value.grid(
            row=3,
            column=1,
            sticky="ew",
            padx=(0, 8),
            pady=(2, 6)
        )

        tk.Label(
            documentation_workflow_frame,
            text="WORKSPACE:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=3,
            column=2,
            sticky="w",
            padx=(8, 4),
            pady=(2, 6)
        )

        self.documentation_workflow_workspace_value = tk.Label(
            documentation_workflow_frame,
            text="-",
            bg="#100918",
            fg="#cdb7df",
            font=("Segoe UI", 7),
            anchor="w",
            justify="left",
            wraplength=650
        )
        self.documentation_workflow_workspace_value.grid(
            row=3,
            column=3,
            sticky="ew",
            padx=(0, 8),
            pady=(2, 6)
        )

        tk.Label(
            documentation_workflow_frame,
            text="A17 NÁLEZY:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=4,
            column=0,
            sticky="w",
            padx=(8, 4),
            pady=(2, 7)
        )

        self.documentation_workflow_findings_value = tk.Label(
            documentation_workflow_frame,
            text="-",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w",
            justify="left",
            wraplength=1050
        )
        self.documentation_workflow_findings_value.grid(
            row=4,
            column=1,
            columnspan=3,
            sticky="ew",
            padx=(0, 8),
            pady=(2, 7)
        )

        tk.Label(
            documentation_workflow_frame,
            text="PUBLIKACE:",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).grid(
            row=5,
            column=0,
            sticky="w",
            padx=(8, 4),
            pady=(2, 7)
        )

        self.documentation_workflow_publish_value = tk.Label(
            documentation_workflow_frame,
            text="PC2 | DB localhost/matchmatrix | A24 VALIDATE: ČEKÁ | APPLY: ČEKÁ | A7: ČEKÁ",
            bg="#100918",
            fg=MUTED,
            font=("Segoe UI", 8, "bold"),
            anchor="w",
            justify="left",
            wraplength=1050
        )
        self.documentation_workflow_publish_value.grid(
            row=5,
            column=1,
            columnspan=3,
            sticky="ew",
            padx=(0, 8),
            pady=(2, 7)
        )

        self._documentation_update_workflow_ui()

        # V20.1.Q2 - KLIKACÍ SLOVNÍK A VÝKLADOVÝ REJSTŘÍK
        glossary_frame = tk.Frame(
            tab_documentation,
            bg=PANEL_2,
            highlightbackground=CARD_BORDER,
            highlightthickness=1
        )
        glossary_frame.grid(
            row=2,
            column=0,
            columnspan=2,
            sticky="nsew",
            padx=4,
            pady=4
        )
        glossary_frame.columnconfigure(0, weight=1)
        glossary_frame.columnconfigure(1, weight=1)
        glossary_frame.rowconfigure(1, weight=1)

        tk.Label(
            glossary_frame,
            text="📚 CIZÍ VÝRAZY – PŘEKLAD A KLIKACÍ VÝKLAD",
            bg=PANEL_2,
            fg="#d8b4fe",
            font=("Segoe UI", 10, "bold")
        ).grid(row=0, column=0, columnspan=2, sticky="w", padx=8, pady=(6, 4))

        glossary_left = tk.Frame(glossary_frame, bg=PANEL_2)
        glossary_left.grid(row=1, column=0, sticky="nsew", padx=(6, 3), pady=(0, 6))
        glossary_left.columnconfigure(0, weight=1)
        glossary_left.rowconfigure(1, weight=1)

        search_bar = tk.Frame(glossary_left, bg=PANEL_2)
        search_bar.grid(row=0, column=0, sticky="ew", pady=(0, 4))
        search_bar.columnconfigure(1, weight=1)

        tk.Label(
            search_bar,
            text="HLEDAT:",
            bg=PANEL_2,
            fg=MUTED,
            font=("Segoe UI", 8, "bold")
        ).grid(row=0, column=0, sticky="w", padx=(0, 6))

        self.glossary_search_var = tk.StringVar()
        self.glossary_search_entry = tk.Entry(
            search_bar,
            textvariable=self.glossary_search_var,
            bg="#0e0915",
            fg=TEXT,
            insertbackground="white",
            relief="flat",
            font=("Segoe UI", 9)
        )
        self.glossary_search_entry.grid(row=0, column=1, sticky="ew")
        self.glossary_search_entry.bind("<KeyRelease>", lambda event: self.filter_glossary_terms())

        self.glossary_status_label = tk.Label(
            search_bar,
            text="Načítám...",
            bg=PANEL_2,
            fg="#cdb7df",
            font=("Segoe UI", 7, "bold")
        )
        self.glossary_status_label.grid(row=0, column=2, sticky="e", padx=(8, 0))

        glossary_tree_wrap = tk.Frame(glossary_left, bg=PANEL_2)
        glossary_tree_wrap.grid(row=1, column=0, sticky="nsew")
        glossary_tree_wrap.columnconfigure(0, weight=1)
        glossary_tree_wrap.rowconfigure(0, weight=1)

        self.glossary_tree = ttk.Treeview(
            glossary_tree_wrap,
            columns=("foreign", "czech", "source_document", "target_chapter"),
            show="headings",
            selectmode="browse"
        )
        self.glossary_tree.heading("foreign", text="CIZÍ VÝRAZ")
        self.glossary_tree.heading("czech", text="ČESKÝ PŘEKLAD")
        self.glossary_tree.heading("source_document", text="ZDROJ")
        self.glossary_tree.heading("target_chapter", text="KAPITOLA")
        self.glossary_tree.column("foreign", width=170, minwidth=120, anchor="w")
        self.glossary_tree.column("czech", width=220, minwidth=140, anchor="w")
        self.glossary_tree.column("source_document", width=105, minwidth=90, anchor="w")
        self.glossary_tree.column("target_chapter", width=210, minwidth=130, anchor="w")
        self.glossary_tree.grid(row=0, column=0, sticky="nsew")

        glossary_vsb = ttk.Scrollbar(
            glossary_tree_wrap,
            orient="vertical",
            command=self.glossary_tree.yview
        )
        glossary_vsb.grid(row=0, column=1, sticky="ns")
        glossary_hsb = ttk.Scrollbar(
            glossary_tree_wrap,
            orient="horizontal",
            command=self.glossary_tree.xview
        )
        glossary_hsb.grid(row=1, column=0, sticky="ew")
        self.glossary_tree.configure(
            yscrollcommand=glossary_vsb.set,
            xscrollcommand=glossary_hsb.set
        )
        self.glossary_tree.bind("<<TreeviewSelect>>", self.on_glossary_select)
        self.glossary_tree.bind("<Double-1>", lambda event: self.open_selected_glossary_explanation())

        glossary_right = tk.Frame(glossary_frame, bg=PANEL_2)
        glossary_right.grid(row=1, column=1, sticky="nsew", padx=(3, 6), pady=(0, 6))
        glossary_right.columnconfigure(0, weight=1)
        glossary_right.rowconfigure(0, weight=1)

        self.glossary_detail_text = tk.Text(
            glossary_right,
            bg="#09050f",
            fg=TEXT,
            insertbackground="white",
            font=("Segoe UI", 10),
            wrap="word",
            relief="flat"
        )
        self.glossary_detail_text.grid(row=0, column=0, sticky="nsew")
        self.glossary_detail_text.insert(
            "1.0",
            "Vyber cizí výraz vlevo. Zobrazí se český překlad, vysvětlení, zdrojový dokument a cílová kapitola."
        )
        self.glossary_detail_text.config(state="disabled")

        glossary_detail_vsb = ttk.Scrollbar(
            glossary_right,
            orient="vertical",
            command=self.glossary_detail_text.yview
        )
        glossary_detail_vsb.grid(row=0, column=1, sticky="ns")
        self.glossary_detail_text.configure(yscrollcommand=glossary_detail_vsb.set)

        glossary_actions = tk.Frame(glossary_right, bg=PANEL_2)
        glossary_actions.grid(row=1, column=0, columnspan=2, sticky="ew", pady=(5, 0))
        self.make_button(
            glossary_actions,
            "📘 OTEVŘÍT VÝKLAD",
            "#4c2c83",
            self.open_selected_glossary_explanation
        )
        self.make_button(
            glossary_actions,
            "📑 OTEVŘÍT KAPITOLU",
            "#0f5f63",
            self.open_selected_glossary_chapter
        )
        self.make_button(
            glossary_actions,
            "📄 CELÝ DOKUMENT",
            "#3b2555",
            self.open_selected_glossary_document
        )

        self.glossary_entries = []
        self.glossary_entry_by_iid = {}
        self.glossary_selected_entry = None

        self.documentation_kpi_tree = self.create_section(
            tab_documentation,
            "📚 STAV DOKUMENTAČNÍ DATABÁZE",
            3,
            0,
            2
        )

        self.documentation_documents_tree = self.create_section(
            tab_documentation,
            "📄 AKTUÁLNÍ DOKUMENTY",
            4,
            0
        )

        self.documentation_import_runs_tree = self.create_section(
            tab_documentation,
            "⏱ POSLEDNÍ IMPORTNÍ BĚHY",
            4,
            1
        )

        self.documentation_relations_tree = self.create_section(
            tab_documentation,
            "🔗 VAZBY DOKUMENTŮ",
            5,
            0
        )

        self.documentation_history_tree = self.create_section(
            tab_documentation,
            "🧾 HISTORIE STAVŮ",
            5,
            1
        )

        # =========================================================
        # V19.4: DENNÍ PRÁCE / PC2 COMMAND CENTER
        # =========================================================
        # CO TO JE:
        # - Hlavní pracovní obrazovka pro denní provoz.
        # - Akce nejsou v úzké horní liště, ale vpravo jako skutečná ovládací konzole.
        # - Tlačítka jsou seskupená podle smyslu: spuštění, stav, oprava, kontrola.
        #
        # K ČEMU TO JE:
        # - Operátor nejdřív vybere řádek vlevo a vpravo vidí jasná velká tlačítka.
        # - Názvy tlačítek jsou celé a nepůsobí jako obyčejná tabulka.
        tab_pc2_command.columnconfigure(0, weight=1)
        tab_pc2_command.columnconfigure(1, weight=1)
        tab_pc2_command.columnconfigure(2, weight=0, minsize=0)
        tab_pc2_command.rowconfigure(0, weight=0)
        tab_pc2_command.rowconfigure(1, weight=2)
        tab_pc2_command.rowconfigure(2, weight=2)
        tab_pc2_command.rowconfigure(3, weight=0)

        # Pravý akční panel – stále viditelný v DENNÍ PRÁCI.
        pc2_action_side = tk.Frame(
            tab_pc2_command,
            bg="#100918",
            highlightbackground="#3b2555",
            highlightthickness=1
        )
        pc2_action_side.grid(row=0, column=2, rowspan=3, sticky="nsew", padx=(8, 4), pady=4)
        pc2_action_side.columnconfigure(0, weight=1)

        tk.Label(
            pc2_action_side,
            text="🎮 AKCE NAD ŘÁDKEM",
            bg="#100918",
            fg="#f0c7ff",
            font=("Segoe UI", 10, "bold"),
            anchor="w"
        ).grid(row=0, column=0, sticky="ew", padx=10, pady=(10, 4))

        self.pc2_selected_action_label = tk.Label(
            pc2_action_side,
            text="Vyber řádek vlevo a potom použij akci.",
            bg="#100918",
            fg="#cdb7df",
            font=("Segoe UI", 8, "bold"),
            anchor="w",
            justify="left",
            wraplength=235
        )
        self.pc2_selected_action_label.grid(row=1, column=0, sticky="ew", padx=10, pady=(0, 8))

        def pc2_group(parent, row, title):
            lbl = tk.Label(
                parent,
                text=title,
                bg="#100918",
                fg="#8f7ca3",
                font=("Segoe UI", 8, "bold"),
                anchor="w"
            )
            lbl.grid(row=row, column=0, sticky="ew", padx=10, pady=(10, 2))
            return lbl

        def pc2_side_button(parent, row, text, color, command):
            btn = tk.Button(
                parent,
                text=text,
                command=command,
                bg=color,
                fg="white",
                activebackground="#273145",
                activeforeground="white",
                font=("Segoe UI", 8, "bold"),
                bd=1,
                relief="raised",
                padx=7,
                pady=7,
                anchor="w",
                cursor="hand2",
                wraplength=220,
                justify="left"
            )
            btn.grid(row=row, column=0, sticky="ew", padx=10, pady=3)
            return btn

        pc2_group(pc2_action_side, 2, "1) SPUŠTĚNÍ")
        self.pc2_run_button = pc2_side_button(
            pc2_action_side,
            3,
            "▶ SPUSTIT DALŠÍ READY AKCI",
            "#0f6a42",
            self.run_pc2_next_command
        )
        pc2_side_button(
            pc2_action_side,
            4,
            "▶ SPUSTIT VYBRANOU AKCI",
            "#0f5f63",
            self.run_pc2_selected_command
        )
        pc2_side_button(
            pc2_action_side,
            5,
            "▶ POKRAČOVAT VE FRONTĚ",
            "#0f6a42",
            self.pc2_continue_selected_command
        )

        pc2_group(pc2_action_side, 6, "2) STAV ŘÁDKU")
        pc2_side_button(
            pc2_action_side,
            7,
            "✓ NASTAVIT READY",
            "#3b2555",
            lambda: self.pc2_set_selected_status("READY_TO_RUN")
        )
        pc2_side_button(
            pc2_action_side,
            8,
            "✔ OZNAČIT HOTOVO",
            "#355e3b",
            lambda: self.pc2_set_selected_status("DONE")
        )
        pc2_side_button(
            pc2_action_side,
            9,
            "⛔ ZABLOKOVAT",
            "#7f1d1d",
            lambda: self.pc2_set_selected_status("BLOCKED")
        )
        pc2_side_button(
            pc2_action_side,
            10,
            "⚠ OZNAČIT CHYBU",
            "#92400e",
            lambda: self.pc2_set_selected_status("FAILED")
        )

        pc2_group(pc2_action_side, 11, "3) OPRAVA / OPAKOVÁNÍ")
        pc2_side_button(
            pc2_action_side,
            12,
            "↻ RETRY – VRÁTIT NA READY",
            "#6d45b8",
            self.pc2_retry_selected_command
        )
        pc2_side_button(
            pc2_action_side,
            13,
            "⏳ VRÁTIT PLANNER NA PENDING",
            "#4c2c83",
            self.pc2_reset_selected_planner_pending
        )

        pc2_group(pc2_action_side, 14, "4) KONTROLA")
        pc2_side_button(
            pc2_action_side,
            15,
            "🔍 TEST VYBRANÉ AKCE",
            "#0f5f63",
            self.pc2_test_selected_command
        )
        pc2_side_button(
            pc2_action_side,
            16,
            "↻ OBNOVIT PC2 DATA",
            "#3b2555",
            self.load_pc2_command_center
        )

        # V19.10: stará interní pravá lišta v DENNÍ PRÁCI je skrytá.
        # Akce jsou nyní globálně vpravo naproti levé navigaci.
        try:
            pc2_action_side.grid_remove()
            tab_pc2_command.columnconfigure(2, weight=0, minsize=0)
            self.pc2_selected_action_label = self.global_pc2_selected_action_label
        except Exception:
            pass

        # V20.C.4 - OPERATOR MONITOR BINDING
        # CO TO JE:
        # - Horní část DENNÍ PRÁCE je akční operátorský panel s grafickými kartami.
        # - Tabulky zůstávají níže jako informační detail.
        # K ČEMU TO JE:
        # - Při historických backfillech vidíš zeleně/červeně stav, procenta, chyby a další krok.
        self.pc2_visual_frame = tk.Frame(tab_pc2_command, bg=BG)
        self.pc2_visual_frame.grid(row=0, column=0, columnspan=2, sticky="ew", padx=4, pady=4)
        self.pc2_visual_frame.columnconfigure(0, weight=1)
        self.pc2_visual_frame.columnconfigure(1, weight=1)
        self.pc2_visual_frame.columnconfigure(2, weight=1)
        self.pc2_visual_frame.columnconfigure(3, weight=1)
        self.create_pc2_visual_operator_cards(self.pc2_visual_frame)

        self.pc2_button_tree = self.create_section(
            tab_pc2_command, "🏠 DENNÍ PRÁCE – CO SPUSTIT TEĎ", 1, 0, 2
        )

        self.pc2_queue_tree = self.create_section(
            tab_pc2_command, "▼ DETAIL FRONTY / STAVY", 2, 0, 2
        )

        # Skryté kompatibilní TreeView handly pro starší loader logiku.
        self.pc2_kpi_tree = ttk.Treeview(tab_pc2_command, show="headings")
        self.pc2_roadmap_tree = ttk.Treeview(tab_pc2_command, show="headings")
        self.pc2_actions_tree = ttk.Treeview(tab_pc2_command, show="headings")

        self.pc2_queue_tree.bind("<Double-1>", self.open_pc2_command_detail)
        self.pc2_button_tree.bind("<Double-1>", self.open_pc2_command_detail)
        self.pc2_button_tree.bind("<<TreeviewSelect>>", self.on_pc2_action_card_select)
        self.pc2_queue_tree.bind("<<TreeviewSelect>>", self.on_pc2_action_card_select)

        # V19 FIX: teprve teď existují všechny PC2 widgety, takže můžeme otevřít výchozí obrazovku.
        self.show_tab("PC2 COMMAND")

        # V17.11.06: PEOPLE PIPELINE summary + detail.
        # CO TO JE:
        # - Horní tabulka ukazuje PEOPLE stav po sportech.
        # - Dolní tabulka ukazuje detail podle providerů.
        # K ČEMU TO JE:
        # - Panel už nemíchá FB/football nebo BK/basketball a ukazuje sport jako celek.
        tab_people_pipeline.columnconfigure(0, weight=1)
        tab_people_pipeline.rowconfigure(0, weight=1)
        tab_people_pipeline.rowconfigure(1, weight=1)
        tab_people_pipeline.rowconfigure(2, weight=2)

        self.people_governance_status_tree = self.create_section(
            tab_people_pipeline, "🛡 PEOPLE GOVERNANCE STATUS", 0, 0
        )

        self.people_pipeline_summary_tree = self.create_section(
            tab_people_pipeline, "👥 PEOPLE SUMMARY PODLE SPORTŮ", 1, 0
        )

        self.people_pipeline_detail_tree = self.create_section(
            tab_people_pipeline, "🔎 PEOPLE DETAIL PODLE PROVIDERŮ", 2, 0
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

    def draw_command_total_bar(self):
        """
        V18.10 - dominantní ukazatel MATCHMATRIX CELKEM.
        """
        if not hasattr(self, "command_total_bar"):
            return

        canvas = self.command_total_bar
        canvas.delete("all")

        width = max(20, canvas.winfo_width())
        height = max(8, canvas.winfo_height())

        try:
            pct = float(getattr(self, "command_center_values", {}).get("PROJEKT", 0))
        except Exception:
            pct = 0

        pct = max(0, min(100, pct))
        fill_w = int(width * pct / 100)

        canvas.create_rectangle(0, 2, width, height - 2, fill="#261832", outline="#261832")
        canvas.create_rectangle(0, 2, max(2, fill_w), height - 2, fill=PINK, outline=PINK)
        canvas.create_text(
            width - 4,
            height / 2,
            text=f"{int(round(pct))}%",
            fill="#f4ecff",
            font=("Segoe UI", 7, "bold"),
            anchor="e"
        )

    def create_command_center_metric_card(self, parent, row, title, subtitle, percent, color):
        """
        V18.11 - řádkový ukazatel hlavní oblasti.

        CO TO JE:
        - Hlavní oblasti projektu jsou pod sebou jako přehledné řádky.
        - Každý řádek má název, popis, grafický pruh a procento úplně vpravo.
        """
        percent = max(0, min(100, int(percent)))

        card = tk.Frame(
            parent,
            bg="#100918",
            highlightbackground="#24182f",
            highlightthickness=1
        )
        parent.columnconfigure(max(0, row - 1), weight=1, uniform="hlavni_oblasti")
        card.grid(row=1, column=max(0, row - 1), sticky="nsew", padx=2, pady=2)
        card.columnconfigure(0, weight=0, minsize=92)
        card.columnconfigure(1, weight=1)
        card.columnconfigure(2, weight=0, minsize=54)

        name_frame = tk.Frame(card, bg="#100918")
        name_frame.grid(row=0, column=0, sticky="nsew", padx=(8, 4), pady=4)

        tk.Label(
            name_frame,
            text=title,
            bg="#100918",
            fg=color,
            font=("Segoe UI", 8, "bold"),
            anchor="w"
        ).pack(anchor="w")

        tk.Label(
            name_frame,
            text=subtitle,
            bg="#100918",
            fg="#8f7ca3",
            font=("Segoe UI", 6, "bold"),
            anchor="w"
        ).pack(anchor="w")

        bar = tk.Canvas(card, height=16, bg="#100918", highlightthickness=0)
        bar.grid(row=0, column=1, sticky="ew", padx=(4, 8), pady=6)

        value_label = tk.Label(
            card,
            text=f"{percent}%",
            bg="#100918",
            fg="white",
            font=("Segoe UI", 11, "bold"),
            anchor="e"
        )
        value_label.grid(row=0, column=2, sticky="e", padx=(0, 8), pady=4)

        def redraw_bar(event=None):
            try:
                bar.delete("all")
                w = max(30, bar.winfo_width())
                h = max(8, bar.winfo_height())
                current_value = self.command_center_values.get(title, percent)
                current_value = max(0, min(100, int(round(float(current_value or 0)))))
                fill_w = int(w * current_value / 100)
                y = h // 2
                bar.create_rectangle(0, y - 3, w, y + 3, fill="#24182f", outline="#24182f")
                bar.create_rectangle(0, y - 3, max(2, fill_w), y + 3, fill=color, outline=color)
            except Exception:
                pass

        bar.bind("<Configure>", redraw_bar)

        self.command_center_widgets[title] = {
            "value_label": value_label,
            "bar": bar,
            "redraw": redraw_bar,
        }

        for widget in (card, name_frame, value_label, bar):
            widget.bind("<Button-1>", lambda event, layer=title: self.open_project_layer_help(layer))
            widget.configure(cursor="hand2")

        redraw_bar()
        return card

    def create_command_kpi_row(self, parent, row, title, value, color, subtitle=""):
        """
        V18.11 - řádkové KPI pro OPS sloupec.

        CO TO JE:
        - KPI je menší a čitelné pod sebou.
        - Loader dál může používat .config(text=...).
        """
        frame = tk.Frame(parent, bg="#100918", highlightbackground="#24182f", highlightthickness=1)
        frame.grid(row=row, column=0, sticky="ew", padx=0, pady=1)
        frame.columnconfigure(1, weight=1)

        dot = tk.Canvas(frame, width=10, height=10, bg="#100918", highlightthickness=0, bd=0)
        dot.grid(row=0, column=0, rowspan=2, sticky="n", padx=(7, 5), pady=(7, 0))
        dot.create_oval(1, 1, 9, 9, fill=color, outline=color)

        tk.Label(
            frame,
            text=title,
            bg="#100918",
            fg="#d8b4fe",
            font=("Segoe UI", 6, "bold"),
            anchor="w"
        ).grid(row=0, column=1, sticky="ew", pady=(2, 0))

        lbl = tk.Label(
            frame,
            text=value,
            bg="#100918",
            fg="white",
            font=("Segoe UI", 9, "bold"),
            anchor="w"
        )
        lbl.grid(row=1, column=1, sticky="ew", pady=(0, 1))

        tk.Label(
            frame,
            text=subtitle,
            bg="#100918",
            fg="#8f7ca3",
            font=("Segoe UI", 5, "bold"),
            anchor="e"
        ).grid(row=0, column=2, rowspan=2, sticky="e", padx=(3, 5))

        graph = tk.Canvas(frame, height=3, bg="#100918", highlightthickness=0, bd=0)
        graph.grid(row=2, column=0, columnspan=3, sticky="ew", padx=7, pady=(0, 4))

        for widget in (frame, dot, lbl, graph):
            widget.bind("<Button-1>", lambda event, t=title, s=subtitle: self.open_kpi_help(t, s))
            widget.configure(cursor="hand2")

        handle = KpiValueHandle(lbl, graph, color, title)
        handle.config(text=value)
        return handle

    def draw_project_timeline_chart(self):
        """
        V18.10 - projektová cesta místo starého čárového grafu.

        CO TO JE:
        - Nejde o technický graf, ale o rychlé čtení stavu projektu.
        - Ukazuje, které oblasti táhnou projekt nahoru a které ho brzdí.
        """

        if not hasattr(self, "project_chart"):
            return

        canvas = self.project_chart
        canvas.delete("all")

        width = canvas.winfo_width()
        height = canvas.winfo_height()

        if width < 260 or height < 70:
            return

        values = getattr(self, "command_center_values", {}) or {}

        rows = [
            ("Governance", 100, GREEN),
            ("Providers", values.get("PROVIDEŘI", 0), GREEN),
            ("Sporty", values.get("SPORTY", 0), GREEN),
            ("People", values.get("PEOPLE", 0), YELLOW),
            ("Media", values.get("MEDIA", 0), PURPLE),
            ("Odds", values.get("ODDS", 0), RED),
            ("Web", values.get("WEB", 0), RED),
        ]

        left = 82
        right = 38
        top = 8
        row_h = 14
        bar_w = max(80, width - left - right)

        def clamp(value):
            try:
                return max(0, min(100, float(value or 0)))
            except Exception:
                return 0

        # Horní celková cesta.
        project_pct = clamp(values.get("PROJEKT", 0))
        canvas.create_text(
            0,
            top,
            text="CELKEM",
            fill="#f4ecff",
            font=("Segoe UI", 8, "bold"),
            anchor="nw"
        )
        canvas.create_rectangle(left, top + 3, left + bar_w, top + 8, fill="#2c2038", outline="#2c2038")
        canvas.create_rectangle(left, top + 3, left + int(bar_w * project_pct / 100), top + 8, fill=PINK, outline=PINK)
        canvas.create_text(left + bar_w + 6, top + 5, text=f"{int(round(project_pct))}%", fill=PINK, font=("Segoe UI", 8, "bold"), anchor="w")

        y = top + 18
        for name, value, color in rows:
            pct = clamp(value)
            canvas.create_text(0, y, text=name, fill="#cdb7df", font=("Segoe UI", 7, "bold"), anchor="nw")
            canvas.create_rectangle(left, y + 3, left + bar_w, y + 6, fill="#2c2038", outline="#2c2038")
            canvas.create_rectangle(left, y + 3, left + int(bar_w * pct / 100), y + 6, fill=color, outline=color)
            canvas.create_text(left + bar_w + 6, y + 4, text=f"{int(round(pct))}%", fill=color, font=("Segoe UI", 7, "bold"), anchor="w")
            y += row_h

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

            # V18.8: maximálně 8 KPI v jednom řádku – žádná dlouhá přeplněná lišta.
            if width >= 1180:
                per_row = 8
            elif width >= 950:
                per_row = 6
            elif width >= 720:
                per_row = 4
            else:
                per_row = 2

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
            pady=(2, 3)
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
            font=("Segoe UI", 11, "bold"),
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
            height=6,
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


    # =====================================================
    # V18.2 - DETAILY ZÁLOŽEK, SLOUPCŮ A ŘÁDKŮ
    # =====================================================

    def open_tab_help(self, tab_code):
        """
        CO TO JE:
        - Detailní nápověda k dolní záložce panelu.

        K ČEMU TO JE:
        - Každá záložka vysvětlí, co zobrazuje, odkud čte data a jak se používá.
        """
        title, desc = TAB_HELP_TEXTS.get(
            tab_code,
            (TAB_LABELS.get(tab_code, tab_code), "Tato záložka slouží jako operační část panelu MatchMatrix.")
        )

        rows = db_query(f"""
            SELECT
                tab_code,
                tab_name_cz,
                source_schema,
                source_object,
                source_type,
                governance_required_status,
                what_is_it,
                purpose,
                panel_usage,
                refresh_mode,
                priority_level
            FROM ops.v18_master_panel_sources_v1
            WHERE UPPER(tab_code) = UPPER('{tab_code}')
               OR UPPER(tab_name_cz) = UPPER('{title}')
            LIMIT 1;
        """)

        db_part = ""
        if rows and "CHYBA" not in rows[0]:
            row = rows[0]
            db_part = f"""

DB ZDROJ / V18 REGISTR:
Kód: {row.get('tab_code')}
Název: {row.get('tab_name_cz')}
Zdroj: {row.get('source_schema')}.{row.get('source_object')}
Typ: {row.get('source_type')}
Governance: {row.get('governance_required_status')}
Refresh: {row.get('refresh_mode')}
Priorita: {row.get('priority_level')}

CO TO JE PODLE DB:
{row.get('what_is_it') or '-'}

K ČEMU TO JE PODLE DB:
{row.get('purpose') or '-'}

KDE TO UVIDÍME:
{row.get('panel_usage') or '-'}
"""

        body = f"""
CO TO JE:
{desc}

K ČEMU TO JE:
Pomáhá rychle pochopit konkrétní oblast panelu bez hledání v dokumentaci nebo DBeaveru.

KDE TO UVIDÍME:
Dolní záložka: {title}

JAK SE TO VYUŽIJE:
- kliknutím na záložku otevřeš oblast,
- pravým klikem nebo dvojklikem na záložku otevřeš tento detail,
- dvojklikem na řádek v tabulkách otevřeš detail celého řádku,
- kliknutím na nadpis tabulky otevřeš detail sekce,
- kliknutím na hlavičku sloupce otevřeš detail sloupce.
{db_part}
"""
        self.show_help_window(f"ℹ DETAIL ZÁLOŽKY :: {title}", body)

    def get_column_help_text(self, column_name, section_title=""):
        col = str(column_name or "")
        cz = cz_column(col)
        key = col.lower()

        specific = {
            "layer_order": "Pořadí vrstvy v hlavním datovém toku MatchMatrix.",
            "layer_code": "Stabilní technický kód vrstvy. Používá se pro napojení readiness, roadmapy a panelu.",
            "layer_name": "Čitelný název vrstvy pro panel a dokumentaci.",
            "what_is_it": "Popis, co daný objekt, vrstva nebo záznam znamená.",
            "purpose": "Vysvětlení, k čemu se objekt používá a proč existuje.",
            "input_source": "Odkud do vrstvy přichází data.",
            "output_target": "Kam data z vrstvy pokračují dál.",
            "master_objects": "Hlavní DB objekty nebo workery, které danou část reprezentují.",
            "panel_usage": "Kde a jak se objekt zobrazí v panelu V18.",
            "governance_status": "Governance status: ACTIVE_MASTER, ACTIVE_PANEL, ACTIVE, ACTIVE_REVIEW, LEGACY_KEEP nebo DROP_CANDIDATE.",
            "readiness_percent": "Procento připravenosti vrstvy nebo oblasti.",
            "readiness_status": "Slovní stav připravenosti: READY, PARTIAL, NOT_READY nebo PLANNED.",
            "blocking_issue": "Problém, který brání zvýšení připravenosti nebo dokončení vrstvy.",
            "next_action": "Doporučený další krok pro zlepšení stavu.",
            "harvest_readiness_percent": "Celkové procento připravenosti na masivní harvest.",
            "weakest_layers": "Nejslabší vrstvy, které nejvíce brzdí projekt.",
            "biggest_blocker": "Největší aktuální blokace projektu.",
            "recommended_next_step": "Doporučený další krok podle harvest readiness enginu.",
            "tab_code": "Technický kód záložky ve V18 panel source registru.",
            "source_object": "View nebo tabulka, ze které panel danou oblast čte.",
            "refresh_mode": "Zda se zdroj obnovuje automaticky nebo ručně.",
            "sport_code": "Kód sportu, například FB, BK, HK, TN.",
            "provider": "Datový provider, ze kterého data pochází nebo který je doporučený.",
            "entity": "Datová entita, například fixtures, teams, players, odds, articles.",
            "coverage_status": "Stav pokrytí dat u providera/entity.",
            "health_status": "Zdravotní stav zdroje nebo providera.",
            "recommendation_cz": "České doporučení dalšího postupu.",
            "migration_action": "Co s objektem dělat v governance: KEEP, REVIEW, DROP později apod.",
            "risk_if_wrong": "Co se může stát, pokud je objekt špatně napojený nebo neaktuální.",
        }

        description = specific.get(key)
        if not description:
            if "percent" in key or "pct" in key:
                description = "Číselná procentuální hodnota. Slouží k rychlému porovnání stavu nebo pokrytí."
            elif "status" in key or "state" in key:
                description = "Stavový sloupec. Podle něj panel barví řádky a určuje prioritu kontroly."
            elif "count" in key or "rows" in key:
                description = "Počet řádků nebo položek v dané oblasti."
            elif "created" in key or "updated" in key or "at" in key:
                description = "Časová informace pro audit aktuálnosti dat."
            elif "note" in key or "message" in key or "reason" in key:
                description = "Textové vysvětlení, zpráva, důvod nebo poznámka. Dvojklik na řádek ji zobrazí celou."
            else:
                description = "Sloupec z databázového view/tabulky. Používá se jako součást operačního přehledu v panelu."

        return f"""
CO TO JE:
Sloupec: {cz}
Technický název: {col}
Sekce: {section_title or '-'}

K ČEMU TO JE:
{description}

KDE TO UVIDÍME:
V aktuální tabulce panelu V18.

JAK SE TO VYUŽIJE:
- podle sloupce lze řadit nebo vizuálně číst stav,
- dlouhé hodnoty se v tabulce zkracují,
- dvojklik na celý řádek otevře plný detail všech hodnot.
""".strip()

    def open_column_help(self, column_name, tree=None):
        section_title = getattr(tree, "_section_title", "") if tree is not None else ""
        self.show_help_window(
            f"ℹ DETAIL SLOUPCE :: {cz_column(column_name)}",
            self.get_column_help_text(column_name, section_title)
        )

    def open_tree_row_detail(self, event, tree=None):
        """
        CO TO JE:
        - Univerzální detail řádku pro všechny tabulky.

        K ČEMU TO JE:
        - V tabulkách jsou dlouhé texty, které nejsou vidět. Dvojklik otevře celý řádek.
        """
        if tree is None:
            tree = event.widget

        selected = tree.selection()
        if not selected:
            item_id = tree.identify_row(event.y)
            if item_id:
                tree.selection_set(item_id)
                selected = (item_id,)

        if not selected:
            return

        item = tree.item(selected[0])
        values = list(item.get("values", []))
        columns = list(tree["columns"])
        section_title = getattr(tree, "_section_title", "TABULKA")

        lines = []
        lines.append("CO TO JE:")
        lines.append(f"Detail jednoho řádku tabulky: {section_title}")
        lines.append("")
        lines.append("K ČEMU TO JE:")
        lines.append("Slouží k přečtení dlouhých textů, poznámek, doporučení, URL, chyb a auditních údajů bez omezení šířkou sloupce.")
        lines.append("")
        lines.append("KDE TO UVIDÍME:")
        lines.append("Dvojklik na libovolný řádek v tabulce panelu.")
        lines.append("")
        lines.append("JAK SE TO VYUŽIJE:")
        lines.append("Zkopíruj hodnotu, najdi chybový text, ověř zdrojový objekt nebo podle doporučení proveď další krok.")
        lines.append("")
        lines.append("=" * 90)
        lines.append("HODNOTY ŘÁDKU")
        lines.append("=" * 90)

        for idx, col in enumerate(columns):
            value = values[idx] if idx < len(values) else ""
            lines.append(f"\n{cz_column(col)} [{col}]:")
            lines.append(str(value))

        self.show_help_window(
            f"🔎 DETAIL ŘÁDKU :: {section_title}",
            "\n".join(lines)
        )

    def translate_cell_value(self, value):
        """Převod běžných hodnot do češtiny pro zobrazení v tabulkách."""
        if value is None:
            return ""
        if isinstance(value, bool):
            return "Ano" if value else "Ne"
        if isinstance(value, datetime):
            return value.strftime("%Y-%m-%d %H:%M:%S")
        if isinstance(value, str):
            upper = value.upper()
            translated = STATUS_LABELS.get(upper)
            if translated:
                return translated
            common = {
                "TRUE": "Ano",
                "FALSE": "Ne",
                "AUTO_REFRESH": "Automaticky",
                "MANUAL_REFRESH": "Ručně",
                "VIEW": "View",
                "TABLE": "Tabulka",
                "NONE": "",
            }
            return common.get(upper, value)
        return value

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
            "PROJEKT": """
CO TO JE:
Hlavní ukazatel MATCHMATRIX CELKEM.

K ČEMU TO JE:
Ukazuje celkovou připravenost platformy přes governance, sporty, providery, people, media, odds a web.

CO ZVÝŠÍ PROCENTO:
- dokončené sportovní vrstvy,
- vyšší provider readiness,
- doplněná People vrstva,
- lepší Media a Odds coverage,
- první webová/admin aplikační vrstva.

KDE KLIKNOUT:
1) HARVEST
2) ROADMAPA
3) SPORT COMPLETION
4) PROVIDER MATRIX

DOPORUČENÝ KROK:
Pokračovat po jedné oblasti: nejdřív dokončit slabé vrstvy PEOPLE / MEDIA / ODDS a držet governance bez CRITICAL/HIGH.
""",
            "SPORTY": """
CO TO JE:
Připravenost sportů přes core sportovní data: ligy, týmy, zápasy, sezóny a základní public merge.

CO ZVÝŠÍ PROCENTO:
- další potvrzené fixtures/leagues/teams,
- méně data gap položek,
- dokončený sport completion pro jednotlivé sporty.

KDE KLIKNOUT:
1) SPORT COMPLETION
2) ROADMAPA -> DOKONČENOST SPORTŮ
3) HARVEST
""",
            "PROVIDEŘI": """
CO TO JE:
Připravenost providerů, jejich pokrytí, health, fallbacky a worker registry.

CO ZVÝŠÍ PROCENTO:
- potvrzené provider/entity coverage,
- stabilní provider health,
- doplněné worker registry,
- připravený fallback provider.

KDE KLIKNOUT:
1) PROVIDEŘI
2) PROVIDER MATRIX
3) AI OPS -> ZDRAVÍ PROVIDERŮ
""",
            "WEB": """
CO TO JE:
Budoucí uživatelská a administrační webová vrstva MatchMatrix.

CO ZVÝŠÍ PROCENTO:
- registrace/přihlášení,
- uživatelský dashboard,
- předplatné,
- webové zobrazení sportů, týmů, hráčů, tiketů a amatérských soutěží.

KDE KLIKNOUT:
1) ROADMAPA
2) ARCHITEKTURA
3) budoucí WEB / LAUNCH tab
""",
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
                "SYSTÉMOVÉ UDÁLOSTI",
                """
CO TO JE:
Sloučený operační přehled alertů, událostí orchestrace a zdraví workerů.

K ČEMU TO JE:
Nahrazuje tři samostatné tabulky v PŘEHLEDU a ukazuje jeden prioritní seznam toho, co vyžaduje pozornost.

KDE JE ZDROJ:
ops.v_runtime_alerts_grouped_v1
ops.v_runtime_operations_center_feed_v1
ops.v_scheduler_runtime_dashboard_v1

JAK SE TO VYUŽIJE:
Nejdřív řeš CRITICAL / FAILED / AKTIVNÍ UPOZORNĚNÍ, potom WARNING, zbytek jen monitoruj.

DOPORUČENÝ KROK:
Dvojklikem otevři detail řádku. Pro worker chyby pokračuj do LOGY / WORKERY / OPRAVY.
"""
            ),
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
                "GOVERNANCE KPI",
                """
CO TO JE:
Souhrnné živé KPI celé governance vrstvy MatchMatrix.

K ČEMU TO JE:
Ukazuje počet governance oblastí, celkové skóre, potvrzené části a částečné/HOLD oblasti.

KDE JE ZDROJ:
ops.v_governance_summary_kpi_v1

DOPORUČENÝ KROK:
Pokud je stav CONTROLLED, pokračovat bezpečně. Pokud je PARTIAL, řešit oblast s nejnižším skóre.
"""
            ),
            (
                "GOVERNANCE DETAIL",
                """
CO TO JE:
Český detail governance oblastí: týmy, hráči, ligy a provider mapy.

K ČEMU TO JE:
Rychle ukáže, co je hotovo, co je částečné a jaký je další krok.

KDE JE ZDROJ:
ops.v_governance_panel_detail_v1

DOPORUČENÝ KROK:
Dvojklikem otevři řádek a podle pole Další krok pokračuj v další governance opravě.
"""
            ),
            (
                "RUNTIME GOVERNANCE AUDIT",
                """
CO TO JE:
Runtime auditní záznamy governance milníků.

K ČEMU TO JE:
Slouží jako živý zdroj pravdy pro panel a AI/OPS rozhodování.

KDE JE ZDROJ:
ops.runtime_entity_audit

DOPORUČENÝ KROK:
Po dokončení nové governance oblasti zapsat řádek do runtime audit tabulky.
"""
            ),
            (
                "DB OBJECT GOVERNANCE",
                """
CO TO JE:
Registry oficiálních DB objektů, které panel a OPS používá.

K ČEMU TO JE:
Určuje ACTIVE_MASTER zdroje a snižuje riziko, že panel čte staré nebo legacy view.

KDE JE ZDROJ:
ops.database_object_governance

DOPORUČENÝ KROK:
Používat hlavně objekty označené ACTIVE_MASTER / KEEP_ACTIVE_MASTER.
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


    def create_info_card(self, parent, title, row, column):
        """
        V18.5 UX

        CO TO JE:
        - Horní textová karta pro DNEŠNÍ PRIORITU a AI DOPORUČENÍ.

        K ČEMU TO JE:
        - Po spuštění panelu hned vidíš, co je nejdůležitější řešit.
        """

        frame = tk.Frame(
            parent,
            bg="#100918",
            highlightbackground="#24182f",
            highlightthickness=1
        )
        frame.grid(row=row, column=column, sticky="nsew", padx=4, pady=3)

        tk.Label(
            frame,
            text=title,
            bg="#100918",
            fg="#d8b4fe",
            font=("Segoe UI", 10, "bold")
        ).pack(anchor="w", padx=8, pady=(5, 1))

        lbl = tk.Label(
            frame,
            text="Načítám...",
            bg="#100918",
            fg="#f4ecff",
            justify="left",
            anchor="nw",
            font=("Segoe UI", 9),
            wraplength=850
        )
        lbl.pack(fill="both", expand=True, padx=8, pady=(0, 6))
        return lbl

    def load_today_priority_cards(self):
        """
        V18.5 UX

        CO TO JE:
        - Naplní horní box DNEŠNÍ PRIORITA a AI DOPORUČENÍ.

        ZDROJE:
        - ops.v_harvest_readiness_summary_v1
        - ops.v_autonomous_ops_brain_v5
        - ops.v_run_next_queue_v1
        """

        harvest_rows = db_query("""
            SELECT
                harvest_readiness_percent,
                readiness_status,
                weakest_layers,
                biggest_blocker,
                recommended_next_step,
                next_target_date
            FROM ops.v_harvest_readiness_summary_v1;
        """)

        if harvest_rows and "CHYBA" not in harvest_rows[0]:
            h = harvest_rows[0]
            priority = f"""{h.get('recommended_next_step') or 'Kontrola systému'}
Harvest ready: {h.get('harvest_readiness_percent')} % | Stav: {cz_status(h.get('readiness_status'))}
Nejslabší vrstvy: {h.get('weakest_layers') or '-'}
Největší blokace: {h.get('biggest_blocker') or '-'}
Další termín: {h.get('next_target_date') or '-'}"""
        else:
            priority = "Nelze načíst harvest readiness summary. Zkontroluj ops.v_harvest_readiness_summary_v1."

        self.today_priority_text.config(text=priority.strip())

        brain_rows = db_query("""
            SELECT
                brain_rank,
                sport_code,
                entity,
                provider,
                brain_decision,
                recommended_focus,
                brain_decision_reason
            FROM ops.v_autonomous_ops_brain_v5
            ORDER BY brain_rank ASC
            LIMIT 3;
        """)

        if brain_rows and "CHYBA" not in brain_rows[0]:
            lines = []
            for r in brain_rows:
                lines.append(
                    f"{r.get('brain_rank')}. {r.get('brain_decision')} | {r.get('sport_code')}/{r.get('entity')} | {r.get('provider') or '-'} | {r.get('recommended_focus') or '-'}"
                )
            ai_text = "\n".join(lines)
        else:
            run_rows = db_query("""
                SELECT
                    run_next_rank,
                    worker_code,
                    execution_decision,
                    final_priority_score
                FROM ops.v_run_next_queue_v1
                ORDER BY run_next_rank
                LIMIT 3;
            """)
            if run_rows and "CHYBA" not in run_rows[0]:
                ai_text = "\n".join([
                    f"{r.get('run_next_rank')}. {r.get('worker_code')} | {cz_status(r.get('execution_decision'))} | priorita {r.get('final_priority_score')}"
                    for r in run_rows
                ])
            else:
                ai_text = "Zatím není dostupné AI doporučení."

        self.ai_recommendation_text.config(text=ai_text.strip())

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
            width=18,
            bd=0
        )

        btn.pack(
            side="left",
            padx=5,
            pady=6,
            fill="x",
            expand=True
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
            fg="#d8b4fe",
            font=("Segoe UI", 10, "bold")
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
        tree._section_title = title
        tree.bind(
            "<Double-1>",
            lambda event, t=tree: self.open_tree_row_detail(event, t)
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
            "empty_ok",
            background="#0b1f18",
            foreground="#7dffb3"
        )

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
            fg="#d8b4fe",
            font=("Segoe UI", 10, "bold")
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
        self.load_today_priority_cards()

        if self.current_tab == "DASHBOARD":
            self.load_orchestration_summary()
            self.load_feed()
            self.load_run_next()
            self.load_system_events_dashboard()
            self.load_dashboard()
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

        if self.current_tab == "SPORT COMPLETION":
            self.load_sport_completion_dashboard()

        if self.current_tab == "ODDS":
            self.load_odds_dashboard()

        if self.current_tab == "PROVIDERS":
            self.load_providers_dashboard()

        if self.current_tab == "PROVIDER MATRIX":
            self.load_provider_matrix_dashboard()

        if self.current_tab == "MEDIA":
            self.load_media_dashboard()

        if self.current_tab == "ARCHITECTURE":
            self.load_architecture_dashboard()

        if self.current_tab == "GOVERNANCE":
            self.load_governance_dashboard()

        if self.current_tab == "DOCUMENTATION":
            self.load_documentation_dashboard()

        if self.current_tab == "PC2 COMMAND":
            self.load_pc2_command_center()

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

    def _documentation_workspace_slug(self, file_path):
        """
        V20.1.Q3 - vytvoří bezpečnou část názvu workspace.
        """
        stem = os.path.splitext(
            os.path.basename(
                str(file_path or "")
            )
        )[0]

        normalized = unicodedata.normalize(
            "NFKD",
            stem
        )

        ascii_text = "".join(
            character
            for character in normalized
            if not unicodedata.combining(character)
        )

        slug = re.sub(
            r"[^A-Za-z0-9]+",
            "_",
            ascii_text
        ).strip("_").upper()

        return slug[:80] or "DOCUMENT"


    def _documentation_update_workflow_ui(self):
        """
        V20.1.Q3 - obnoví popisky pracovního dokumentačního workflow.
        """
        document_text = (
            os.path.basename(
                self.documentation_workflow_document
            )
            if self.documentation_workflow_document
            else "NEVYBRÁN"
        )

        workspace_text = (
            self.documentation_workflow_workspace
            if self.documentation_workflow_workspace
            else "-"
        )

        step_text = self.documentation_workflow_step or "-"
        status_text = self.documentation_workflow_last_status or "-"

        if hasattr(self, "documentation_workflow_document_value"):
            self.documentation_workflow_document_value.config(
                text=document_text
            )

        if hasattr(self, "documentation_workflow_workspace_value"):
            self.documentation_workflow_workspace_value.config(
                text=workspace_text
            )

        if hasattr(self, "documentation_workflow_step_value"):
            self.documentation_workflow_step_value.config(
                text=step_text
            )

        if hasattr(self, "documentation_workflow_status_value"):
            status_upper = status_text.upper()

            if "CHYBA" in status_upper or "FAILED" in status_upper:
                status_color = RED
            elif self.documentation_workflow_document:
                status_color = GREEN
            else:
                status_color = YELLOW

            self.documentation_workflow_status_value.config(
                text=status_text,
                fg=status_color
            )

        if hasattr(self, "documentation_workflow_findings_value"):
            all_findings = list(
                getattr(self, "documentation_workflow_findings", []) or []
            )
            problem_findings = [
                item
                for item in all_findings
                if isinstance(item, dict)
                and str(item.get("result", "")).strip().upper() != "PASS"
            ]

            report_ready = bool(
                getattr(self, "documentation_workflow_report_json", None)
                or getattr(
                    self,
                    "documentation_workflow_report_markdown",
                    None
                )
            )

            if not report_ready:
                findings_text = "-"
                findings_color = MUTED
            elif not problem_findings:
                findings_text = (
                    f"BEZ PROBLÉMOVÝCH NÁLEZŮ | "
                    f"KONTROLY CELKEM: {len(all_findings)}"
                )
                findings_color = GREEN
            else:
                result_parts = []
                for result_name in ("FAIL", "PARTIAL", "MANUAL_REVIEW"):
                    result_count = sum(
                        1
                        for item in problem_findings
                        if str(
                            item.get("result", "")
                        ).strip().upper() == result_name
                    )
                    if result_count:
                        result_parts.append(
                            f"{result_name}: {result_count}"
                        )

                findings_text = f"K ŘEŠENÍ: {len(problem_findings)}"
                if result_parts:
                    findings_text += " | " + " | ".join(result_parts)

                serious = any(
                    str(item.get("result", "")).strip().upper() == "FAIL"
                    or str(
                        item.get("severity", "")
                    ).strip().upper() in ("CRITICAL", "HIGH")
                    for item in problem_findings
                )
                findings_color = RED if serious else YELLOW

            self.documentation_workflow_findings_value.config(
                text=findings_text,
                fg=findings_color
            )

        if hasattr(self, "documentation_workflow_publish_value"):
            validate_status = (
                self.documentation_workflow_a24_validation_status
                or "ČEKÁ"
            )
            apply_status = (
                self.documentation_workflow_a24_apply_status
                or "ČEKÁ"
            )
            a7_status = self.documentation_workflow_a7_status or "ČEKÁ"

            publication_text = (
                "EXECUTION HOST: PC2 "
                f"({DOCUMENTATION_REMOTE_HOST}) | "
                "DB HOST: localhost na PC2 | "
                f"DB TARGET: {DB_CONFIG.get('dbname', 'matchmatrix')} | "
                f"A24 VALIDATE: {validate_status} | "
                f"APPLY: {apply_status} | "
                f"A7: {a7_status}"
            )

            publication_upper = publication_text.upper()
            if (
                "FAILED" in publication_upper
                or "BLOCKED" in publication_upper
                or "CHYBA" in publication_upper
            ):
                publication_color = RED
            elif (
                self.documentation_workflow_a24_apply_status
                == "HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED"
            ):
                publication_color = GREEN
            elif self.documentation_workflow_a24_validation_status:
                publication_color = YELLOW
            else:
                publication_color = MUTED

            self.documentation_workflow_publish_value.config(
                text=publication_text,
                fg=publication_color
            )



    def documentation_choose_source_action(self):
        """
        V20.1.Q3 STEP 19 - hlavní vstup do fáze 1.

        Nabídne nový denní zápis, nové navázání nebo existující Markdown.
        Oficiální šablony se nikdy nepřepisují; nový dokument vzniká pouze
        v podsložce source samostatného workspace.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Dokumentační workflow",
                "Nelze změnit dokument, dokud běží aktuální krok."
            )
            return

        chooser = tk.Toplevel(self)
        chooser.title("Nový nebo existující dokument")
        chooser.geometry("620x335")
        chooser.resizable(False, False)
        chooser.configure(bg="#100918")
        chooser.transient(self)
        chooser.grab_set()

        tk.Label(
            chooser,
            text="VYBER ZPŮSOB ZAHÁJENÍ WORKFLOW",
            bg="#100918",
            fg="#f0c7ff",
            font=("Segoe UI", 14, "bold")
        ).pack(anchor="w", padx=18, pady=(16, 5))

        tk.Label(
            chooser,
            text=(
                "Nové dokumenty vzniknou z oficiálních šablon "
                "docs/13_TEMPLATES. Existující dokument zůstane beze změny "
                "a panel vytvoří jeho pracovní kopii."
            ),
            bg="#100918",
            fg="#cdb7df",
            justify="left",
            wraplength=580,
            font=("Segoe UI", 9)
        ).pack(anchor="w", padx=18, pady=(0, 12))

        button_frame = tk.Frame(chooser, bg="#100918")
        button_frame.pack(fill="both", expand=True, padx=18, pady=(0, 10))
        button_frame.columnconfigure(0, weight=1)
        button_frame.columnconfigure(1, weight=1)

        def run_action(action):
            try:
                chooser.grab_release()
            except Exception:
                pass
            chooser.destroy()
            self.after(80, action)

        tk.Button(
            button_frame,
            text="📅  NOVÝ DENNÍ ZÁPIS\nz MM-TPL-002",
            command=lambda: run_action(
                self.documentation_create_daily_log_from_template
            ),
            bg="#6d45b8",
            fg="white",
            activebackground="#7c3aed",
            activeforeground="white",
            font=("Segoe UI", 10, "bold"),
            relief="flat",
            cursor="hand2",
            padx=10,
            pady=14
        ).grid(row=0, column=0, sticky="nsew", padx=(0, 6), pady=5)

        tk.Button(
            button_frame,
            text="🔗  NOVÉ NAVÁZÁNÍ\nz MM-TPL-001",
            command=lambda: run_action(
                self.documentation_create_chat_continuation_from_template
            ),
            bg="#0f5f63",
            fg="white",
            activebackground="#14747a",
            activeforeground="white",
            font=("Segoe UI", 10, "bold"),
            relief="flat",
            cursor="hand2",
            padx=10,
            pady=14
        ).grid(row=0, column=1, sticky="nsew", padx=(6, 0), pady=5)

        tk.Button(
            button_frame,
            text="📄  VYBRAT EXISTUJÍCÍ MARKDOWN DOKUMENT",
            command=lambda: run_action(
                self.documentation_select_source_document
            ),
            bg="#3b2555",
            fg="white",
            activebackground="#4c2c83",
            activeforeground="white",
            font=("Segoe UI", 10, "bold"),
            relief="flat",
            cursor="hand2",
            padx=10,
            pady=10
        ).grid(
            row=1,
            column=0,
            columnspan=2,
            sticky="ew",
            pady=(8, 5)
        )

        tk.Button(
            chooser,
            text="ZRUŠIT",
            command=chooser.destroy,
            bg="#2a2034",
            fg="#d8c9e8",
            activebackground="#3a2d47",
            activeforeground="white",
            font=("Segoe UI", 9, "bold"),
            relief="flat",
            cursor="hand2",
            padx=15,
            pady=6
        ).pack(side="bottom", pady=(0, 14))

        chooser.protocol("WM_DELETE_WINDOW", chooser.destroy)


    def documentation_create_daily_log_from_template(self):
        """Vytvoří nový DAILY_LOG z oficiální šablony MM-TPL-002."""
        self._documentation_create_from_template("DAILY_LOG")


    def documentation_create_chat_continuation_from_template(self):
        """Vytvoří nový CHAT_CONTINUATION z oficiální šablony MM-TPL-001."""
        self._documentation_create_from_template("CHAT_CONTINUATION")


    def _documentation_find_latest_canonical_name(self, directory, pattern):
        """Vrátí název nejnovějšího kanonického souboru podle názvu."""
        try:
            candidates = sorted(
                Path(directory).glob(pattern),
                key=lambda item: item.name.upper()
            )
        except Exception:
            candidates = []
        return candidates[-1].name if candidates else "NENÍ"


    def _documentation_next_nav_sequence(self, date_compact):
        """
        Určí další pořadové číslo MM-NAV pro daný den.
        Zohlední kanonické dokumenty i rozpracované source soubory.
        """
        pattern = re.compile(
            rf"^MM-NAV-{re.escape(date_compact)}-(\d{{2}})(?:_|\.|$)",
            re.IGNORECASE
        )
        numbers = []

        canonical_root = os.path.join(
            DOCUMENTATION_ROOT,
            "docs",
            "09_HISTORY",
            "NAVÁZÁNÍ_NA_CHAT"
        )

        searches = [
            (Path(canonical_root), False),
            (Path(DOCUMENTATION_WORKSPACE_ROOT), True),
        ]

        for root_path, recursive in searches:
            try:
                if not root_path.exists():
                    continue
                iterator = (
                    root_path.rglob(f"MM-NAV-{date_compact}-*.md")
                    if recursive
                    else root_path.glob(f"MM-NAV-{date_compact}-*.md")
                )
                for item in iterator:
                    match = pattern.match(item.name)
                    if match:
                        numbers.append(int(match.group(1)))
            except Exception:
                continue

        next_number = (max(numbers) + 1) if numbers else 1
        if next_number > 99:
            raise RuntimeError(
                f"Pro datum {date_compact} již nelze vytvořit další MM-NAV-XX."
            )
        return next_number


    def _documentation_extract_template_body(self, template_path):
        """Načte pouze výstupní část oficiální šablony."""
        text_value = Path(template_path).read_text(encoding="utf-8-sig")
        start_marker = "<!-- MM-TEMPLATE-START -->"
        end_marker = "<!-- MM-TEMPLATE-END -->"

        start_index = text_value.find(start_marker)
        end_index = text_value.find(end_marker)

        if start_index < 0 or end_index < 0 or end_index <= start_index:
            raise RuntimeError(
                "Šablona neobsahuje platné značky "
                "MM-TEMPLATE-START / MM-TEMPLATE-END."
            )

        body = text_value[
            start_index + len(start_marker):end_index
        ].strip()

        if not body:
            raise RuntimeError("Výstupní část šablony je prázdná.")

        return body + "\n"


    def _documentation_allocate_workspace(self, document_filename):
        """Vytvoří jedinečný workspace a jeho source podsložku."""
        os.makedirs(DOCUMENTATION_WORKSPACE_ROOT, exist_ok=True)

        workspace_stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        workspace_slug = self._documentation_workspace_slug(document_filename)
        base_name = f"{workspace_stamp}_{workspace_slug}"
        workspace_path = os.path.join(
            DOCUMENTATION_WORKSPACE_ROOT,
            base_name
        )

        suffix = 1
        while os.path.exists(workspace_path):
            suffix += 1
            workspace_path = os.path.join(
                DOCUMENTATION_WORKSPACE_ROOT,
                f"{base_name}_{suffix:02d}"
            )

        source_dir = os.path.join(workspace_path, "source")
        os.makedirs(source_dir, exist_ok=False)
        return workspace_path, source_dir


    def _documentation_activate_new_workspace(
        self,
        *,
        workspace_path,
        source_snapshot,
        manifest_path,
        source_original,
        status_text
    ):
        """Aktivuje nově vytvořený workspace a vyčistí stav starého běhu."""
        self._documentation_reset_workflow_state()

        self.documentation_workflow_source_original = source_original
        self.documentation_workflow_document = source_snapshot
        self.documentation_workflow_manifest = manifest_path
        self.documentation_workflow_workspace = workspace_path
        self.documentation_workflow_step = "NOVÝ DOKUMENT ZE ŠABLONY"
        self.documentation_workflow_last_status = status_text
        self.documentation_workflow_last_output = source_snapshot
        self.documentation_workflow_process = None
        self.documentation_workflow_running = False
        self.documentation_workflow_started_at = None
        self.documentation_workflow_finished_at = None

        self._documentation_update_workflow_ui()


    def _documentation_run_git(self, arguments):
        """Bezpečně spustí read-only Git příkaz nad lokálním repozitářem."""
        try:
            completed = subprocess.run(
                ["git", "-C", BASE_DIR, *list(arguments)],
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=15,
                shell=False
            )
        except Exception as exc:
            return False, f"{type(exc).__name__}: {exc}"

        output = (completed.stdout or completed.stderr or "").strip()
        if completed.returncode != 0:
            return False, output or f"Git return code {completed.returncode}"
        return True, output


    def _documentation_collect_git_snapshot(self):
        """Vrátí pouze ověřené technické údaje z lokálního Git repozitáře."""
        result = {
            "branch": "NEOVĚŘENO",
            "commit": "NEOVĚŘENO",
            "subject": "NEOVĚŘENO",
            "worktree": "NEOVĚŘENO",
            "push_status": "NEOVĚŘENO",
            "summary": "Git stav se nepodařilo ověřit.",
        }

        ok_branch, branch = self._documentation_run_git(
            ["rev-parse", "--abbrev-ref", "HEAD"]
        )
        ok_commit, commit_hash = self._documentation_run_git(
            ["rev-parse", "--short=12", "HEAD"]
        )
        ok_subject, subject = self._documentation_run_git(
            ["log", "-1", "--pretty=%s"]
        )
        ok_status, status_text = self._documentation_run_git(
            ["status", "--short", "--branch"]
        )

        if ok_branch and branch:
            result["branch"] = branch.splitlines()[0].strip()
        if ok_commit and commit_hash:
            result["commit"] = commit_hash.splitlines()[0].strip()
        if ok_subject and subject:
            result["subject"] = subject.splitlines()[0].strip()

        if ok_status:
            status_lines = [line.rstrip() for line in status_text.splitlines()]
            branch_line = status_lines[0] if status_lines else ""
            changes = [line for line in status_lines[1:] if line.strip()]
            result["worktree"] = (
                "ČISTÝ"
                if not changes
                else f"ZMĚNY – {len(changes)} položek"
            )

            if "..." in branch_line:
                relation = branch_line.removeprefix("## ").strip()
                if "[ahead " in relation or "[behind " in relation:
                    result["push_status"] = relation
                else:
                    result["push_status"] = f"Synchronizováno: {relation}"
            elif branch_line:
                result["push_status"] = branch_line.removeprefix("## ").strip()

        result["summary"] = (
            f"{result['branch']} @ {result['commit']} | "
            f"{result['worktree']} | {result['push_status']}"
        )
        return result


    def _documentation_collect_database_snapshot(self, timestamp_iso):
        """Načte aktuální ověřitelné počty z dokumentační databáze."""
        snapshot = {
            "DB_DOCUMENTS": "NEOVĚŘENO",
            "DB_VERSIONS_TOTAL": "NEOVĚŘENO",
            "DB_CURRENT_VERSIONS": "NEOVĚŘENO",
            "DB_SECTIONS": "NEOVĚŘENO",
            "DB_RELATIONS": "NEOVĚŘENO",
            "DB_STATUS_HISTORY": "NEOVĚŘENO",
            "DB_IMPORT_RUNS": "NEOVĚŘENO",
            "DB_SNAPSHOT_CREATED_AT": timestamp_iso,
            "DB_EXECUTION_HOST": (
                f"PC2 ({DOCUMENTATION_REMOTE_HOST})"
            ),
            "DB_HOST": f"{DB_CONFIG.get('host')}:{DB_CONFIG.get('port')}",
            "DB_TARGET": str(DB_CONFIG.get("dbname") or "NEOVĚŘENO"),
            "DB_VERIFICATION_SOURCE": (
                "documentation.documents, documentation.document_versions, "
                "documentation.document_sections, documentation.document_relations, "
                "documentation.document_status_history, documentation.import_runs"
            ),
        }

        rows = db_query("""
            SELECT
                (SELECT COUNT(*) FROM documentation.documents) AS documents,
                (SELECT COUNT(*) FROM documentation.document_versions) AS versions_total,
                (
                    SELECT COUNT(*)
                    FROM documentation.document_versions
                    WHERE is_current = true
                ) AS current_versions,
                (SELECT COUNT(*) FROM documentation.document_sections) AS sections,
                (SELECT COUNT(*) FROM documentation.document_relations) AS relations,
                (
                    SELECT COUNT(*)
                    FROM documentation.document_status_history
                ) AS status_history,
                (SELECT COUNT(*) FROM documentation.import_runs) AS import_runs;
        """)

        if rows and "CHYBA" not in rows[0]:
            row = rows[0]
            snapshot.update({
                "DB_DOCUMENTS": str(row.get("documents", 0)),
                "DB_VERSIONS_TOTAL": str(row.get("versions_total", 0)),
                "DB_CURRENT_VERSIONS": str(row.get("current_versions", 0)),
                "DB_SECTIONS": str(row.get("sections", 0)),
                "DB_RELATIONS": str(row.get("relations", 0)),
                "DB_STATUS_HISTORY": str(row.get("status_history", 0)),
                "DB_IMPORT_RUNS": str(row.get("import_runs", 0)),
            })
        elif rows and "CHYBA" in rows[0]:
            snapshot["DB_VERIFICATION_SOURCE"] = (
                "NEOVĚŘENO – " + str(rows[0].get("CHYBA"))[:300]
            )

        snapshot["database_summary"] = (
            f"dokumenty {snapshot['DB_DOCUMENTS']} | "
            f"verze {snapshot['DB_VERSIONS_TOTAL']} | "
            f"aktuální {snapshot['DB_CURRENT_VERSIONS']} | "
            f"sekce {snapshot['DB_SECTIONS']} | "
            f"vazby {snapshot['DB_RELATIONS']} | "
            f"importní běhy {snapshot['DB_IMPORT_RUNS']}"
        )
        return snapshot


    def _documentation_build_technical_replacements(
        self,
        *,
        work_area,
        filename,
        workspace_path,
        timestamp_iso
    ):
        """Sestaví technická pole, která lze doplnit bez obsahového odhadu."""
        git_snapshot = self._documentation_collect_git_snapshot()
        db_snapshot = self._documentation_collect_database_snapshot(
            timestamp_iso
        )

        replacements = dict(db_snapshot)
        replacements.pop("database_summary", None)
        replacements.update({
            "GIT_BRANCH": git_snapshot["branch"],
            "GIT_COMMIT": git_snapshot["commit"],
            "GIT_WORKTREE_STATUS": git_snapshot["worktree"],
            "GIT_PUSH_STATUS": git_snapshot["push_status"],
            "WORKSPACE_PATH": workspace_path,
            "A17_STATUS": "ČEKÁ – DOSUD NESPUŠTĚNO PRO TENTO DOKUMENT",
            "A24_STATUS": "ČEKÁ – DOSUD NESPUŠTĚNO PRO TENTO DOKUMENT",
            "A7_STATUS": "ČEKÁ – DOSUD NESPUŠTĚNO PRO TENTO DOKUMENT",
            "SNAPSHOT_AKTIVNI_PRACOVNI_BLOK": work_area,
            "SNAPSHOT_AKTIVNI_PANEL": (
                "tools/matchmatrix_control_panel_V20_1_Q3_"
                "DOCUMENTATION_WORKFLOW.py"
            ),
            "SNAPSHOT_POSLEDNI_VYSLEDEK": (
                f"Poslední Git commit {git_snapshot['commit']}: "
                f"{git_snapshot['subject']}"
            ),
            "SNAPSHOT_GIT_STAV": git_snapshot["summary"],
            "SNAPSHOT_DOKUMENTACNI_WORKFLOW": (
                "Q3 STEP 20A – nový dokument z oficiální šablony; "
                "čeká na doplnění obsahu a A17"
            ),
            "SNAPSHOT_DATABAZOVY_STAV": db_snapshot["database_summary"],
            "SNAPSHOT_NEJVETSI_OTEVRENY_UKOL": (
                "Doplnit zbývající obsahová pole dokumentu a spustit A17."
            ),
            "SNAPSHOT_NASLEDUJICI_BLOK": (
                "Doplnění obsahu → A17 → řízené schválení a publikace."
            ),
        })
        return replacements, git_snapshot, db_snapshot


    def _documentation_create_from_template(self, document_type):
        """
        Vytvoří nový pracovní dokument z oficiální šablony.

        Automaticky doplní identitu, datum, verzi, stav, kanonický název,
        základní vazby, pracovní oblast, Git údaje, technickou dohledatelnost
        a aktuální snapshot dokumentační databáze. Obsahová pole zůstávají
        k doplnění uživatelem a před A17 jsou technicky kontrolována.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Nový dokument ze šablony",
                "Nelze vytvořit nový dokument, dokud běží aktuální krok."
            )
            return

        document_type = str(document_type or "").strip().upper()
        template_path = DOCUMENTATION_TEMPLATES.get(document_type)

        if not template_path:
            messagebox.showerror(
                "Nový dokument ze šablony",
                f"Typ dokumentu {document_type!r} nemá registrovanou šablonu."
            )
            return

        if not os.path.isfile(template_path):
            messagebox.showerror(
                "Nový dokument ze šablony",
                (
                    "Oficiální šablona nebyla nalezena:\n\n"
                    f"{template_path}\n\n"
                    "Ověř synchronizaci docs/13_TEMPLATES na PC2."
                )
            )
            return

        work_area = simpledialog.askstring(
            "Pracovní oblast",
            (
                "Zadej stručnou pracovní oblast nového dokumentu.\n\n"
                "Příklad: Dokumentační workflow Q3 a šablony dokumentů"
            ),
            parent=self,
            initialvalue="Dokumentační workflow Q3"
        )
        if work_area is None:
            return

        work_area = " ".join(work_area.strip().split())
        if not work_area:
            messagebox.showwarning(
                "Pracovní oblast",
                "Pracovní oblast nesmí být prázdná."
            )
            return

        now_value = datetime.now().astimezone()
        default_date = now_value.strftime("%Y-%m-%d")

        date_input = simpledialog.askstring(
            "Datum dokumentu",
            (
                "Zadej datum dokumentu ve formátu YYYY-MM-DD.\n\n"
                "Identifikátor MM-DL nebo MM-NAV bude vytvořen z tohoto data."
            ),
            parent=self,
            initialvalue=default_date
        )
        if date_input is None:
            return

        date_input = date_input.strip()
        try:
            document_date = datetime.strptime(
                date_input,
                "%Y-%m-%d"
            )
        except ValueError:
            messagebox.showwarning(
                "Datum dokumentu",
                "Datum musí být ve formátu YYYY-MM-DD."
            )
            return

        date_iso = document_date.strftime("%Y-%m-%d")
        date_compact = document_date.strftime("%Y%m%d")
        timestamp_iso = now_value.isoformat(timespec="seconds")

        daily_dir = os.path.join(
            DOCUMENTATION_ROOT,
            "docs",
            "09_HISTORY",
            "DENNÍ_ZÁPISY"
        )
        nav_dir = os.path.join(
            DOCUMENTATION_ROOT,
            "docs",
            "09_HISTORY",
            "NAVÁZÁNÍ_NA_CHAT"
        )

        try:
            # Workspace musí existovat před sestavením dokumentu, protože jeho
            # cesta se zapisuje přímo do technické dohledatelnosti šablony.
            if document_type == "DAILY_LOG":
                document_id = f"MM-DL-{date_compact}"
                filename = f"{document_id}_MATCHMATRIX_DENNI_ZAPIS.md"
                title_value = f"MatchMatrix – denní zápis – {date_iso}"
                canonical_path = os.path.join(daily_dir, filename)

                if os.path.isfile(canonical_path):
                    messagebox.showwarning(
                        "Denní zápis již existuje",
                        (
                            "Pro dnešní datum již existuje kanonický denní zápis:\n\n"
                            f"{canonical_path}\n\n"
                            "Použij „Vybrat existující Markdown dokument“, "
                            "pokud jej potřebuješ aktualizovat."
                        )
                    )
                    return

                next_nav_number = self._documentation_next_nav_sequence(
                    date_compact
                )
                expected_nav = (
                    f"MM-NAV-{date_compact}-{next_nav_number:02d}"
                    "_MATCHMATRIX_NAVAZANI_DO_CHATU.md"
                )
                previous_daily = self._documentation_find_latest_canonical_name(
                    daily_dir,
                    "MM-DL-*_MATCHMATRIX_DENNI_ZAPIS.md"
                )

                replacements = {
                    "NAZEV_DOKUMENTU": title_value,
                    "DOCUMENT_ID": document_id,
                    "VERZE": "1.0",
                    "STAV": "DRAFT – NEEDS_USER_APPROVAL",
                    "DATUM_YYYY_MM_DD": date_iso,
                    "DATUM_CAS_ISO_8601": timestamp_iso,
                    "PRACOVNI_OBLAST": work_area,
                    "NAZEV_SOUBORU": filename,
                    "PREDCHOZI_DENNI_ZAPIS_NEBO_NENI": previous_daily,
                    "NAVAZUJICI_DOKUMENT_NEBO_BUDE_VYTVOREN": (
                        f"BUDE VYTVOŘEN: {expected_nav}"
                    ),
                }

            elif document_type == "CHAT_CONTINUATION":
                nav_number = self._documentation_next_nav_sequence(
                    date_compact
                )
                document_id = f"MM-NAV-{date_compact}-{nav_number:02d}"
                filename = (
                    f"{document_id}_MATCHMATRIX_NAVAZANI_DO_CHATU.md"
                )
                title_value = (
                    "MatchMatrix – navázání do nového chatu – "
                    f"{date_iso}"
                )
                source_daily = (
                    f"MM-DL-{date_compact}_MATCHMATRIX_DENNI_ZAPIS.md"
                )
                previous_nav = self._documentation_find_latest_canonical_name(
                    nav_dir,
                    "MM-NAV-*_MATCHMATRIX_NAVAZANI_DO_CHATU.md"
                )

                replacements = {
                    "NAZEV_DOKUMENTU": title_value,
                    "DOCUMENT_ID": document_id,
                    "VERZE": "1.0",
                    "STAV": "DRAFT – NEEDS_USER_APPROVAL",
                    "DATUM_YYYY_MM_DD": date_iso,
                    "DATUM_CAS_ISO_8601": timestamp_iso,
                    "PRACOVNI_OBLAST": work_area,
                    "NAZEV_SOUBORU": filename,
                    "ZDROJOVY_DENNI_ZAPIS": source_daily,
                    "PREDCHOZI_NAVAZANI_NEBO_NENI": previous_nav,
                }

            else:
                raise RuntimeError(
                    f"Nepodporovaný typ dokumentu: {document_type}"
                )

            workspace_path, source_dir = (
                self._documentation_allocate_workspace(filename)
            )

            technical_replacements, git_snapshot, db_snapshot = (
                self._documentation_build_technical_replacements(
                    work_area=work_area,
                    filename=filename,
                    workspace_path=workspace_path,
                    timestamp_iso=timestamp_iso
                )
            )
            replacements.update(technical_replacements)

            template_body = self._documentation_extract_template_body(
                template_path
            )

            generated_text = template_body
            for field_name, field_value in replacements.items():
                generated_text = generated_text.replace(
                    "{{" + field_name + "}}",
                    str(field_value)
                )

            source_snapshot = os.path.join(source_dir, filename)
            Path(source_snapshot).write_text(
                generated_text,
                encoding="utf-8",
                newline="\n"
            )

            manifest_path = os.path.join(
                workspace_path,
                "documentation_workflow_manifest.json"
            )
            manifest_payload = {
                "contract_version": "1.2",
                "panel_version": "V20.1.Q3_STEP_20A",
                "selected_at": now_value.isoformat(),
                "creation_mode": "OFFICIAL_TEMPLATE",
                "template_source": template_path,
                "template_document_type": document_type,
                "generated_document_id": document_id,
                "generated_filename": filename,
                "source_original": template_path,
                "source_snapshot": source_snapshot,
                "workspace": workspace_path,
                "workflow_status": "TEMPLATE_DRAFT_CREATED_WITH_TECHNICAL_PREFILL",
                "technical_prefill": {
                    "git": git_snapshot,
                    "database": db_snapshot,
                    "filled_fields": sorted(technical_replacements.keys()),
                },
            }

            with open(
                manifest_path,
                "w",
                encoding="utf-8"
            ) as manifest_handle:
                json.dump(
                    manifest_payload,
                    manifest_handle,
                    ensure_ascii=False,
                    indent=2
                )

            self._documentation_activate_new_workspace(
                workspace_path=workspace_path,
                source_snapshot=source_snapshot,
                manifest_path=manifest_path,
                source_original=template_path,
                status_text="ŠABLONA PŘEDVYPLNĚNA – DOPLŇ OBSAH"
            )

            unresolved = self._documentation_unresolved_template_fields(
                source_snapshot
            )

            try:
                os.startfile(source_snapshot)
                open_note = "Pracovní dokument byl otevřen v editoru."
            except Exception:
                open_note = (
                    "Dokument se nepodařilo automaticky otevřít. "
                    "Otevři jej ručně."
                )

            messagebox.showinfo(
                "Nový dokument ze šablony",
                (
                    f"Byl vytvořen nový dokument typu {document_type}.\n\n"
                    f"Document ID: {document_id}\n"
                    f"Šablona: {template_path}\n"
                    f"Pracovní dokument: {source_snapshot}\n"
                    f"Technicky předvyplněná pole: {len(technical_replacements)}\n"
                    f"Nevyplněná obsahová pole: {len(unresolved)}\n"
                    f"Git: {git_snapshot['summary']}\n"
                    f"DB: {db_snapshot['database_summary']}\n\n"
                    f"{open_note}\n\n"
                    "Doplň zbývající pole {{NAZEV_POLE}}. Potom znovu klikni "
                    "na 1 VYBRAT A ANALYZOVAT a panel spustí A17."
                )
            )

        except Exception as exc:
            self.documentation_workflow_last_status = (
                "CHYBA PŘI VYTVOŘENÍ DOKUMENTU ZE ŠABLONY"
            )
            self._documentation_update_workflow_ui()
            messagebox.showerror(
                "Nový dokument ze šablony",
                f"Dokument se nepodařilo vytvořit:\n\n{exc}"
            )


    def _documentation_unresolved_template_fields(self, path_value):
        """Vrátí unikátní seznam nevyplněných polí {{POLE}}."""
        if not path_value or not os.path.isfile(path_value):
            return []

        try:
            text_value = Path(path_value).read_text(
                encoding="utf-8-sig"
            )
        except Exception:
            return []

        fields = set(
            re.findall(
                r"\{\{([A-Z0-9_]+)\}\}",
                text_value
            )
        )
        fields.discard("NAZEV_PROMENNE")
        return sorted(fields)


    def documentation_open_working_document(self):
        """Otevře aktivní pracovní dokument ve výchozím editoru Windows."""
        document = self.documentation_workflow_document
        if not document or not os.path.isfile(document):
            messagebox.showwarning(
                "Pracovní dokument",
                "Aktivní pracovní dokument nebyl nalezen."
            )
            return

        try:
            os.startfile(document)
        except Exception as exc:
            messagebox.showerror(
                "Pracovní dokument",
                f"Dokument se nepodařilo otevřít:\n\n{exc}"
            )


    def _documentation_show_phase_menu(self, event, items):
        """Zobrazí kontextovou nabídku dílčích akcí jedné fáze."""
        menu = tk.Menu(self, tearoff=0)
        for label, command in items:
            if label == "---":
                menu.add_separator()
            else:
                menu.add_command(label=label, command=command)
        try:
            menu.tk_popup(event.x_root, event.y_root)
        finally:
            menu.grab_release()


    def _documentation_phase_1_menu(self):
        return [
            (
                "Nový denní zápis z MM-TPL-002",
                self.documentation_create_daily_log_from_template
            ),
            (
                "Nové navázání z MM-TPL-001",
                self.documentation_create_chat_continuation_from_template
            ),
            ("---", None),
            (
                "Vybrat existující dokument",
                self.documentation_select_source_document
            ),
            (
                "Otevřít pracovní dokument",
                self.documentation_open_working_document
            ),
            ("---", None),
            ("Spustit A17 audit", self.documentation_run_a17),
            ("Zobrazit A17 nálezy", self.documentation_show_a17_findings),
            ("Otevřít A17 report", self.documentation_open_a17_report),
        ]


    def _documentation_phase_2_menu(self):
        return [
            ("Vytvořit návrh opravy A18", self.documentation_run_a18),
            ("Otevřít kontrolu mapování A19", self.documentation_run_a19),
        ]


    def _documentation_phase_3_menu(self):
        return [
            ("Pokračovat podle stavu dokumentu", self.documentation_phase_3_build),
            ("---", None),
            ("Vytvořit dokument A20", self.documentation_run_a20),
            ("Otevřít kandidát", self.documentation_open_a20_candidate),
            ("Spustit finální A17", self.documentation_run_final_a17),
            ("Schválit a uložit", self.documentation_approve_and_save_canonical),
        ]


    def _documentation_phase_4_menu(self):
        return [
            ("Spustit kanonický A17", self.documentation_run_canonical_a17),
            ("Vytvořit Git commit", self.documentation_git_commit),
            ("---", None),
            ("A24 – pouze validovat na PC2", self.documentation_run_a24_validate),
            ("A24 – APPLY + A7 na PC2", self.documentation_run_a24_apply),
            ("Otevřít poslední A24 report", self.documentation_open_a24_report),
            ("---", None),
            ("Otevřít poslední A17 report", self.documentation_open_a17_report),
        ]


    def _documentation_reset_workflow_state(self):
        """
        Vyčistí stav předchozího dokumentačního workflow před výběrem
        nového dokumentu. Soubory ve workspace ani kanonické dokumenty nemaže.
        """
        self.documentation_workflow_document = None
        self.documentation_workflow_source_original = None
        self.documentation_workflow_source_document = None
        self.documentation_workflow_workspace = None
        self.documentation_workflow_manifest = None

        self.documentation_workflow_report_json = None
        self.documentation_workflow_report_markdown = None
        self.documentation_workflow_findings = []

        self.documentation_workflow_a18_proposal = None
        self.documentation_workflow_a18_mapping_json = None
        self.documentation_workflow_a18_panel_mapping_json = None

        self.documentation_workflow_a20_candidate = None
        self.documentation_workflow_a20_diff = None
        self.documentation_workflow_a20_build_json = None

        self.documentation_workflow_final_a17_json = None
        self.documentation_workflow_final_a17_markdown = None

        self.documentation_workflow_canonical_document = None
        self.documentation_workflow_canonical_a17_json = None
        self.documentation_workflow_canonical_a17_markdown = None

        self.documentation_workflow_git_commit = None

        self.documentation_workflow_a24_validation_status = None
        self.documentation_workflow_a24_validation_report = None
        self.documentation_workflow_a24_validation_hash = None
        self.documentation_workflow_a24_apply_status = None
        self.documentation_workflow_a24_apply_report = None
        self.documentation_workflow_a7_status = None
        self.documentation_workflow_import_summary = {}

        self.documentation_workflow_step = "ZDROJ"
        self.documentation_workflow_last_status = "NEVYBRÁN DOKUMENT"

        self._documentation_update_workflow_ui()


    def _documentation_initial_a17_is_clean(self):
        """
        Vrátí True, pokud aktuální vstupní A17 neobsahuje FAIL ani PARTIAL.
        MANUAL_REVIEW není technická chyba a nevyžaduje A18/A19/A20.
        """
        report_path = self.documentation_workflow_report_json

        if not report_path or not os.path.isfile(report_path):
            return False

        try:
            with open(report_path, "r", encoding="utf-8-sig") as handle:
                report = json.load(handle)
        except Exception:
            return False

        findings = report.get("findings") or []
        return not any(
            str(item.get("result", "")).strip().upper() in {"FAIL", "PARTIAL"}
            for item in findings
        )


    def documentation_phase_1_analyze(self):
        """
        FÁZE 1:
        výběr dokumentu -> A17 -> nálezy.

        Po dokončeném Git commitu začne nové kliknutí vždy nový workflow
        a otevře výběr dalšího dokumentu.
        """
        workflow_finished = (
            self.documentation_workflow_a24_apply_status
            == "HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED"
        )

        if workflow_finished:
            start_new = messagebox.askyesno(
                "Nový dokument",
                (
                    "Předchozí dokument je dokončen a commitnut.\n\n"
                    "Chceš vybrat nový dokument a zahájit nový workflow?"
                )
            )
            if not start_new:
                return

            self._documentation_reset_workflow_state()
            self.documentation_choose_source_action()
            return

        if not self.documentation_workflow_workspace:
            self.documentation_choose_source_action()
            return

        report_ready = bool(
            self.documentation_workflow_report_json
            or self.documentation_workflow_report_markdown
        )
        if not report_ready:
            self.documentation_run_a17()
            return

        self.documentation_show_a17_findings()


    def documentation_phase_2_review(self):
        """
        FÁZE 2:
        A18 návrh -> A19 ruční kontrola a uzavření mapování.
        Pokud vstupní A17 nemá FAIL ani PARTIAL, oprava není nutná
        a fáze 2 se bezpečně přeskočí.
        """
        if not self.documentation_workflow_workspace:
            messagebox.showwarning(
                "Fáze 2 – opravit a zkontrolovat",
                "Nejprve dokonči fázi 1."
            )
            return

        if self._documentation_initial_a17_is_clean():
            messagebox.showinfo(
                "Fáze 2 – není potřeba",
                (
                    "Vstupní audit A17 neobsahuje žádný FAIL ani PARTIAL.\n\n"
                    "Dokument není třeba opravovat. Pokračuj přímo na "
                    "3  VYTVOŘIT A SCHVÁLIT."
                )
            )
            return

        if not self.documentation_workflow_a18_panel_mapping_json:
            self.documentation_run_a18()
            return

        review_path = os.path.join(
            self.documentation_workflow_workspace,
            "a19",
            "document_standardization_panel_review_latest.json"
        )
        review_confirmed = False
        if os.path.isfile(review_path):
            try:
                with open(review_path, "r", encoding="utf-8-sig") as handle:
                    payload = json.load(handle)
                review_confirmed = (
                    payload.get("review_status") == "MAPPING_CONFIRMED"
                    and payload.get("final_status")
                    == "DOCUMENT_STANDARDIZATION_PANEL_REVIEW_CONFIRMED"
                )
            except Exception:
                review_confirmed = False

        if not review_confirmed:
            self.documentation_run_a19()
            return

        messagebox.showinfo(
            "Fáze 2 – hotovo",
            "Návrh A18 byl vytvořen a mapování A19 je finálně uzavřeno."
        )


    def documentation_phase_3_build(self):
        """
        FÁZE 3:
        - čistý dokument: použije vstupní pracovní kopii a vstupní A17,
          bez A18/A19/A20,
        - dokument vyžadující opravu: A20 -> finální A17 -> schválení.
        """
        if not self.documentation_workflow_workspace:
            messagebox.showwarning(
                "Fáze 3 – vytvořit a schválit",
                "Nejprve dokonči fázi 1."
            )
            return

        # Rychlá větev pro dokument, který již splňuje standard:
        # žádný FAIL ani PARTIAL, pouze případný MANUAL_REVIEW terminologie.
        if (
            not self.documentation_workflow_a20_candidate
            and self._documentation_initial_a17_is_clean()
        ):
            source_candidate = self.documentation_workflow_document
            source_report = self.documentation_workflow_report_json

            if not source_candidate or not os.path.isfile(source_candidate):
                messagebox.showwarning(
                    "Fáze 3 – vytvořit a schválit",
                    "Pracovní kopie zdrojového dokumentu nebyla nalezena."
                )
                return

            if not source_report or not os.path.isfile(source_report):
                messagebox.showwarning(
                    "Fáze 3 – vytvořit a schválit",
                    "Nejprve spusť vstupní A17 audit."
                )
                return

            self.documentation_workflow_a20_candidate = source_candidate
            self.documentation_workflow_final_a17_json = source_report
            self.documentation_workflow_final_a17_markdown = (
                self.documentation_workflow_report_markdown
            )
            self.documentation_workflow_step = "PŘÍMÉ SCHVÁLENÍ"
            self.documentation_workflow_last_status = (
                "DOKUMENT BEZ OPRAVY – PŘIPRAVEN KE SCHVÁLENÍ"
            )
            self._documentation_update_workflow_ui()
            self.documentation_approve_and_save_canonical()
            return

        if not self.documentation_workflow_a20_candidate:
            self.documentation_run_a20()
            return

        if not self.documentation_workflow_final_a17_json:
            open_first = messagebox.askyesnocancel(
                "Fáze 3 – kandidát",
                (
                    "Kandidát je vytvořen.\n\n"
                    "ANO = otevřít kandidát pro ruční kontrolu\n"
                    "NE = spustit finální A17\n"
                    "ZRUŠIT = bez akce"
                )
            )
            if open_first is None:
                return
            if open_first:
                self.documentation_open_a20_candidate()
            else:
                self.documentation_run_final_a17()
            return

        if not self.documentation_workflow_canonical_document:
            self.documentation_approve_and_save_canonical()
            return

        messagebox.showinfo(
            "Fáze 3 – hotovo",
            (
                "Dokument byl vytvořen, finálně auditován, schválen "
                "a uložen do kanonické složky."
            )
        )


    def documentation_phase_4_publish(self):
        """
        FÁZE 4:
        kanonický A17 -> Git commit -> A24 VALIDATE_ONLY ->
        potvrzený A24 APPLY -> A6 -> inkrementální A7.

        Každé kliknutí provede právě jeden další chybějící krok.
        """
        if not self.documentation_workflow_canonical_document:
            messagebox.showwarning(
                "Fáze 4 – publikovat",
                "Nejprve dokonči fázi 3 a ulož kanonický dokument."
            )
            return

        if not self.documentation_workflow_canonical_a17_json:
            self.documentation_run_canonical_a17()
            return

        if not self.documentation_workflow_git_commit:
            self.documentation_git_commit()
            return

        if (
            self.documentation_workflow_a24_validation_status
            != "HISTORY_DOCUMENT_IMPORT_VALIDATED"
        ):
            self.documentation_run_a24_validate()
            return

        if (
            self.documentation_workflow_a24_apply_status
            != "HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED"
        ):
            self.documentation_run_a24_apply()
            return

        messagebox.showinfo(
            "Fáze 4 – hotovo",
            (
                "Dokument byl kanonicky auditován, uložen v Git historii "
                "a importován do dokumentační databáze na PC2.\n\n"
                f"Commit: {self.documentation_workflow_git_commit}\n"
                f"A24: {self.documentation_workflow_a24_apply_status}\n"
                f"A7: {self.documentation_workflow_a7_status}\n\n"
                "Push nebyl spuštěn."
            )
        )


    def _documentation_sha256_file(self, path_value):
        """Vrátí SHA-256 souboru bez načítání celého dokumentu do paměti."""
        digest = hashlib.sha256()
        with open(path_value, "rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
        return digest.hexdigest()


    def _documentation_extract_a24_status(self, output_text):
        """Vybere nejpřesnější finální stav A24 z konzolového výstupu."""
        output_upper = str(output_text or "").upper()
        statuses = (
            "HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED",
            "HISTORY_DOCUMENT_IMPORT_APPLIED_VERIFICATION_FAILED",
            "HISTORY_DOCUMENT_IMPORT_VALIDATED",
            "HISTORY_DOCUMENT_IMPORT_BLOCKED",
        )
        for status in statuses:
            if status in output_upper:
                return status
        return None


    def _documentation_find_latest_a24_report(self, expected_status=None):
        """
        Najde poslední A24 JSON report vztahující se k aktuálnímu
        kanonickému dokumentu. Reporty vznikají na PC2, ale PC1 je čte
        přes sdílený kořen projektu.
        """
        report_dir = os.path.join(
            DOCUMENTATION_ROOT,
            "reports",
            "documentation"
        )
        if not os.path.isdir(report_dir):
            return None

        document = self.documentation_workflow_canonical_document
        document_name = os.path.basename(document or "")
        document_id = ""
        try:
            _, metadata = self._documentation_read_metadata(document)
            document_id = str(metadata.get("document_id") or "").strip()
        except Exception:
            document_id = ""

        candidates = sorted(
            Path(report_dir).glob(
                "history_document_database_pipeline_*.json"
            ),
            key=lambda item: item.stat().st_mtime,
            reverse=True
        )

        for candidate in candidates[:50]:
            try:
                payload = json.loads(
                    candidate.read_text(encoding="utf-8-sig")
                )
            except Exception:
                continue

            final_status = str(
                payload.get("final_status") or ""
            ).strip().upper()

            if (
                expected_status
                and final_status
                and final_status != str(expected_status).strip().upper()
            ):
                continue

            serialized = json.dumps(
                payload,
                ensure_ascii=False
            ).lower()

            if (
                document_name
                and document_name.lower() in serialized
            ):
                return str(candidate)

            if (
                document_id
                and document_id.lower() in serialized
            ):
                return str(candidate)

        return None


    def _documentation_parse_a24_summary(self, output_text, report_path=None):
        """
        Připraví stručný souhrn bez závislosti na jediné verzi A24/A6/A7.
        Pokud je dostupný JSON report, zachová i jeho klíčové příznaky.
        """
        summary = {
            "execution_host": "PC2",
            "remote_host": DOCUMENTATION_REMOTE_HOST,
            "db_host": "localhost na PC2",
            "db_target": DB_CONFIG.get("dbname", "matchmatrix"),
            "warnings": None,
            "blockers": None,
            "a6_apply_succeeded": None,
            "a7_verified": None,
        }

        payload = {}
        if report_path and os.path.isfile(report_path):
            try:
                with open(report_path, "r", encoding="utf-8-sig") as handle:
                    payload = json.load(handle)
            except Exception:
                payload = {}

        if isinstance(payload, dict):
            summary["a6_apply_succeeded"] = payload.get(
                "a6_apply_succeeded"
            )
            summary["a7_verified"] = payload.get("a7_verified")
            summary["manifest_path"] = payload.get("manifest_path")
            summary["final_status"] = payload.get("final_status")

        output = str(output_text or "")
        patterns = {
            "warnings": (
                r"(?im)^\s*WARNINGS?\s*[:=]\s*(\d+)\s*$",
                r"(?im)^\s*VAROVÁNÍ\s*[:=]\s*(\d+)\s*$",
            ),
            "blockers": (
                r"(?im)^\s*BLOCKERS?\s*[:=]\s*(\d+)\s*$",
                r"(?im)^\s*BLOKÁTORY\s*[:=]\s*(\d+)\s*$",
            ),
        }
        for key, key_patterns in patterns.items():
            for pattern in key_patterns:
                match = re.search(pattern, output)
                if match:
                    summary[key] = int(match.group(1))
                    break

        return summary


    def documentation_run_a24_validate(self):
        """
        STEP 18A - nedestruktivní validace jednoho kanonického dokumentu.
        Databáze se nemění.
        """
        document = self.documentation_workflow_canonical_document

        if (
            not document
            or not os.path.isfile(document)
            or not self.documentation_workflow_git_commit
        ):
            messagebox.showwarning(
                "A24 – validace",
                (
                    "Nejprve dokonči kanonický A17 a Git commit "
                    "konkrétního dokumentu."
                )
            )
            return

        current_hash = self._documentation_sha256_file(document)

        self.documentation_workflow_a24_validation_status = None
        self.documentation_workflow_a24_validation_report = None
        self.documentation_workflow_a24_validation_hash = current_hash
        self.documentation_workflow_a24_apply_status = None
        self.documentation_workflow_a24_apply_report = None
        self.documentation_workflow_a7_status = None
        self.documentation_workflow_import_summary = {}
        self._documentation_update_workflow_ui()

        output_dir = os.path.join(
            self.documentation_workflow_workspace,
            "a24_validate"
        )

        self._documentation_start_remote_tool(
            tool_key="A24",
            arguments=[
                "--document",
                ("PATH", document),
                "--validate-only",
            ],
            step="A24 VALIDATE_ONLY",
            running_status="A24 VALIDATE_ONLY BĚŽÍ NA PC2",
            finish_callback=(
                lambda success, out, local, remote:
                self._documentation_finish_a24_validate(
                    success,
                    out,
                    local,
                    remote,
                    output_dir
                )
            )
        )


    def _documentation_finish_a24_validate(
        self,
        success,
        output_text,
        local_exit_code,
        remote_exit_code,
        output_dir
    ):
        self._documentation_finish_generic(
            success=success,
            step="A24 VALIDATE_ONLY",
            success_status="A24 VALIDACE DOKONČENA",
            failure_status="CHYBA A24 VALIDACE",
            output_text=output_text,
            output_dir=output_dir
        )

        status = self._documentation_extract_a24_status(output_text)
        validated = (
            success
            and status == "HISTORY_DOCUMENT_IMPORT_VALIDATED"
        )

        self.documentation_workflow_a24_validation_status = (
            status or "HISTORY_DOCUMENT_IMPORT_BLOCKED"
        )
        self.documentation_workflow_a24_validation_report = (
            self._documentation_find_latest_a24_report(
                expected_status=status
            )
        )
        self.documentation_workflow_import_summary = (
            self._documentation_parse_a24_summary(
                output_text,
                self.documentation_workflow_a24_validation_report
            )
        )

        if validated:
            self.documentation_workflow_last_status = (
                "A24 VALIDATED – APPLY JE PŘIPRAVEN"
            )
            self._documentation_manifest_update(
                workflow_status="A24_VALIDATED",
                a24_validation_status=status,
                a24_validation_report=(
                    self.documentation_workflow_a24_validation_report
                ),
                a24_validation_hash=(
                    self.documentation_workflow_a24_validation_hash
                )
            )
            self._documentation_update_workflow_ui()
            messagebox.showinfo(
                "A24 – VALIDATE_ONLY",
                (
                    "Validace na PC2 proběhla úspěšně. Databáze nebyla změněna.\n\n"
                    f"Execution host: PC2 ({DOCUMENTATION_REMOTE_HOST})\n"
                    "DB host: localhost na PC2\n"
                    f"DB target: {DB_CONFIG.get('dbname')}\n"
                    f"Dokument: {self.documentation_workflow_canonical_document}\n"
                    f"Stav: {status}\n\n"
                    "Další kliknutí na 4 PUBLIKOVAT nabídne potvrzený APPLY."
                )
            )
        else:
            self.documentation_workflow_last_status = (
                f"A24 VALIDACE BLOKOVÁNA: {status or 'NEZNÁMÝ STAV'}"
            )
            self._documentation_manifest_update(
                workflow_status="A24_VALIDATION_BLOCKED",
                a24_validation_status=(
                    status or "HISTORY_DOCUMENT_IMPORT_BLOCKED"
                )
            )
            self._documentation_update_workflow_ui()
            messagebox.showerror(
                "A24 – VALIDATE_ONLY",
                (
                    "Validace nebyla úspěšná. APPLY zůstává zablokován.\n\n"
                    f"Lokální kód: {local_exit_code}\n"
                    f"Vzdálený kód: {remote_exit_code}\n"
                    f"Stav: {status or 'NEZNÁMÝ'}\n\n"
                    f"{str(output_text or '')[-3500:]}"
                )
            )


    def documentation_run_a24_apply(self):
        """
        STEP 18B - skutečný import přes A24. A24 uvnitř spustí A6 a A7.
        APPLY se nespustí bez platné validace stejného obsahu dokumentu.
        """
        document = self.documentation_workflow_canonical_document

        if (
            self.documentation_workflow_a24_validation_status
            != "HISTORY_DOCUMENT_IMPORT_VALIDATED"
        ):
            messagebox.showwarning(
                "A24 – APPLY",
                "Nejprve musí úspěšně proběhnout A24 VALIDATE_ONLY."
            )
            return

        if not document or not os.path.isfile(document):
            messagebox.showerror(
                "A24 – APPLY",
                "Kanonický dokument nebyl nalezen."
            )
            return

        current_hash = self._documentation_sha256_file(document)
        if (
            not self.documentation_workflow_a24_validation_hash
            or current_hash
            != self.documentation_workflow_a24_validation_hash
        ):
            self.documentation_workflow_a24_validation_status = None
            self.documentation_workflow_a24_apply_status = None
            self.documentation_workflow_a7_status = None
            self._documentation_update_workflow_ui()
            messagebox.showerror(
                "A24 – APPLY",
                (
                    "Dokument se od validace změnil. APPLY byl zablokován.\n\n"
                    "Spusť znovu A24 VALIDATE_ONLY."
                )
            )
            return

        try:
            _, metadata = self._documentation_read_metadata(document)
            document_id = metadata.get("document_id") or Path(document).stem
        except Exception:
            document_id = Path(document).stem

        confirmed = messagebox.askyesno(
            "A24 – potvrdit APPLY",
            (
                "Bude proveden skutečný databázový import.\n\n"
                f"Execution host: PC2 ({DOCUMENTATION_REMOTE_HOST})\n"
                "DB host: localhost na PC2\n"
                f"DB target: {DB_CONFIG.get('dbname')}\n"
                f"Document ID: {document_id}\n"
                f"Soubor: {document}\n\n"
                "A24 spustí A6 a následně inkrementální A7.\n"
                "Automatický stash ani push se neprovede.\n\n"
                "Pokračovat?"
            )
        )
        if not confirmed:
            return

        output_dir = os.path.join(
            self.documentation_workflow_workspace,
            "a24_apply"
        )

        self._documentation_start_remote_tool(
            tool_key="A24",
            arguments=[
                "--document",
                ("PATH", document),
                "--apply",
            ],
            step="A24 APPLY + A6 + A7",
            running_status="A24 APPLY BĚŽÍ NA PC2",
            finish_callback=(
                lambda success, out, local, remote:
                self._documentation_finish_a24_apply(
                    success,
                    out,
                    local,
                    remote,
                    output_dir
                )
            )
        )


    def _documentation_finish_a24_apply(
        self,
        success,
        output_text,
        local_exit_code,
        remote_exit_code,
        output_dir
    ):
        self._documentation_finish_generic(
            success=success,
            step="A24 APPLY + A6 + A7",
            success_status="A24 APPLY DOKONČEN",
            failure_status="CHYBA A24 APPLY",
            output_text=output_text,
            output_dir=output_dir
        )

        status = self._documentation_extract_a24_status(output_text)
        self.documentation_workflow_a24_apply_status = (
            status or "HISTORY_DOCUMENT_IMPORT_BLOCKED"
        )
        self.documentation_workflow_a24_apply_report = (
            self._documentation_find_latest_a24_report(
                expected_status=status
            )
        )
        self.documentation_workflow_import_summary = (
            self._documentation_parse_a24_summary(
                output_text,
                self.documentation_workflow_a24_apply_report
            )
        )

        if status == "HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED":
            self.documentation_workflow_a7_status = "VERIFIED"
            self.documentation_workflow_last_status = (
                "DATABÁZOVÝ IMPORT A A7 OVĚŘENÍ HOTOVO"
            )
            workflow_status = "DATABASE_IMPORTED_AND_VERIFIED"
            dialog = "info"
        elif status == "HISTORY_DOCUMENT_IMPORT_APPLIED_VERIFICATION_FAILED":
            self.documentation_workflow_a7_status = "BLOCKED"
            self.documentation_workflow_last_status = (
                "A6 APPLY PROBĚHL, A7 OVĚŘENÍ SELHALO"
            )
            workflow_status = "DATABASE_APPLIED_VERIFICATION_FAILED"
            dialog = "error"
        else:
            self.documentation_workflow_a7_status = "BLOCKED"
            self.documentation_workflow_last_status = (
                f"DATABÁZOVÝ IMPORT BLOKOVÁN: {status or 'NEZNÁMÝ STAV'}"
            )
            workflow_status = "DATABASE_IMPORT_BLOCKED"
            dialog = "error"

        self._documentation_manifest_update(
            workflow_status=workflow_status,
            a24_apply_status=self.documentation_workflow_a24_apply_status,
            a24_apply_report=self.documentation_workflow_a24_apply_report,
            a7_status=self.documentation_workflow_a7_status,
            import_summary=self.documentation_workflow_import_summary
        )

        try:
            DB_CACHE.clear()
            self.load_documentation_dashboard()
        except Exception:
            pass

        self._documentation_update_workflow_ui()

        summary = self.documentation_workflow_import_summary or {}
        detail = (
            f"Execution host: PC2 ({DOCUMENTATION_REMOTE_HOST})\n"
            "DB host: localhost na PC2\n"
            f"DB target: {DB_CONFIG.get('dbname')}\n"
            f"A24 stav: {self.documentation_workflow_a24_apply_status}\n"
            f"A7 stav: {self.documentation_workflow_a7_status}\n"
            f"Varování: {summary.get('warnings')}\n"
            f"Blokátory: {summary.get('blockers')}\n"
            f"Report: {self.documentation_workflow_a24_apply_report or '-'}"
        )

        if dialog == "info":
            messagebox.showinfo(
                "A24 – APPLY + A7",
                (
                    "Dokument byl importován a integrita byla ověřena.\n\n"
                    + detail
                )
            )
        else:
            messagebox.showerror(
                "A24 – APPLY + A7",
                (
                    "Publikační databázová část není plně dokončena.\n\n"
                    + detail
                    + "\n\nPOSLEDNÍ VÝSTUP:\n"
                    + str(output_text or "")[-3000:]
                )
            )


    def documentation_open_a24_report(self):
        """Otevře poslední validační nebo APPLY report A24."""
        report_path = (
            self.documentation_workflow_a24_apply_report
            or self.documentation_workflow_a24_validation_report
        )

        if not report_path:
            messagebox.showwarning(
                "A24 – report",
                "Zatím není dostupný žádný report A24."
            )
            return

        if not os.path.isfile(report_path):
            messagebox.showerror(
                "A24 – report",
                f"Report nebyl nalezen:\n\n{report_path}"
            )
            return

        try:
            os.startfile(report_path)
        except Exception as exc:
            messagebox.showerror(
                "A24 – report",
                f"Report se nepodařilo otevřít:\n\n{exc}"
            )


    def documentation_select_source_document(self):
        """
        V20.1.Q3 - vybere zdrojový Markdown
        a vytvoří izolovaný workspace.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Dokumentační workflow",
                "Nelze změnit dokument, dokud běží aktuální krok."
            )
            return

        initial_dir = (
            DOCUMENTATION_ROOT
            if os.path.isdir(DOCUMENTATION_ROOT)
            else BASE_DIR
        )

        selected_path = filedialog.askopenfilename(
            title="Vyber zdrojový Markdown dokument",
            initialdir=initial_dir,
            filetypes=[
                ("Markdown dokumenty", "*.md"),
                ("Všechny soubory", "*.*"),
            ]
        )

        if not selected_path:
            return

        selected_path = os.path.abspath(
            os.path.normpath(selected_path)
        )

        if not os.path.isfile(selected_path):
            messagebox.showwarning(
                "Dokumentační workflow",
                f"Vybraný soubor neexistuje:\n{selected_path}"
            )
            return

        if os.path.splitext(selected_path)[1].lower() != ".md":
            messagebox.showwarning(
                "Dokumentační workflow",
                "Vyber Markdown soubor s příponou .md."
            )
            return

        try:
            os.makedirs(
                DOCUMENTATION_WORKSPACE_ROOT,
                exist_ok=True
            )

            workspace_stamp = datetime.now().strftime(
                "%Y%m%d_%H%M%S"
            )

            workspace_slug = (
                self._documentation_workspace_slug(
                    selected_path
                )
            )

            workspace_path = os.path.join(
                DOCUMENTATION_WORKSPACE_ROOT,
                f"{workspace_stamp}_{workspace_slug}"
            )

            source_dir = os.path.join(
                workspace_path,
                "source"
            )

            os.makedirs(
                source_dir,
                exist_ok=False
            )

            source_snapshot = os.path.join(
                source_dir,
                os.path.basename(selected_path)
            )

            shutil.copy2(
                selected_path,
                source_snapshot
            )

            manifest_path = os.path.join(
                workspace_path,
                "documentation_workflow_manifest.json"
            )

            manifest_payload = {
                "contract_version": "1.0",
                "panel_version": "V20.1.Q3",
                "selected_at": datetime.now().astimezone().isoformat(),
                "source_original": selected_path,
                "source_snapshot": source_snapshot,
                "workspace": workspace_path,
                "workflow_status": "SOURCE_SELECTED",
            }

            with open(
                manifest_path,
                "w",
                encoding="utf-8"
            ) as manifest_handle:
                json.dump(
                    manifest_payload,
                    manifest_handle,
                    ensure_ascii=False,
                    indent=2
                )

        except Exception as exc:
            self.documentation_workflow_last_status = (
                "CHYBA PŘI VYTVOŘENÍ WORKSPACE"
            )

            self._documentation_update_workflow_ui()

            messagebox.showerror(
                "Dokumentační workflow",
                f"Workspace se nepodařilo vytvořit:\n\n{exc}"
            )
            return

        self.documentation_workflow_source_original = selected_path
        self.documentation_workflow_document = source_snapshot
        self.documentation_workflow_manifest = manifest_path
        self.documentation_workflow_workspace = workspace_path
        self.documentation_workflow_step = "ZDROJ"
        self.documentation_workflow_last_status = "DOKUMENT VYBRÁN"
        self.documentation_workflow_last_output = source_snapshot
        self.documentation_workflow_findings = []
        self.documentation_workflow_report_json = None
        self.documentation_workflow_report_markdown = None
        self.documentation_workflow_a18_proposal = None
        self.documentation_workflow_a18_diff = None
        self.documentation_workflow_a18_mapping_json = None
        self.documentation_workflow_a18_mapping_markdown = None
        self.documentation_workflow_a18_panel_mapping_json = None
        self.documentation_workflow_a18_panel_mapping_markdown = None
        self.documentation_workflow_a20_candidate = None
        self.documentation_workflow_a20_build_json = None
        self.documentation_workflow_final_a17_json = None
        self.documentation_workflow_final_a17_markdown = None
        self.documentation_workflow_approved_candidate = None
        self.documentation_workflow_canonical_document = None
        self.documentation_workflow_canonical_a17_json = None
        self.documentation_workflow_canonical_a17_markdown = None
        self.documentation_workflow_git_commit = None
        self.documentation_workflow_process = None
        self.documentation_workflow_running = False
        self.documentation_workflow_started_at = None
        self.documentation_workflow_finished_at = None

        self._documentation_update_workflow_ui()

        messagebox.showinfo(
            "Dokumentační workflow",
            (
                "Dokument byl bezpečně načten do samostatného workspace.\n\n"
                f"Zdroj:\n{selected_path}\n\n"
                f"Pracovní kopie:\n{source_snapshot}"
            )
        )


    def _documentation_to_remote_pc2_path(self, path_value):
        """
        V20.1.Q3 - převede cestu dostupnou z PC1 na lokální cestu PC2.
        """
        if not path_value:
            return None

        candidate = os.path.normpath(str(path_value))
        candidate_case = os.path.normcase(candidate)

        remote_root = os.path.normpath(
            DOCUMENTATION_REMOTE_PROJECT_ROOT
        )
        remote_root_case = os.path.normcase(remote_root)

        if (
            candidate_case == remote_root_case
            or candidate_case.startswith(remote_root_case + os.sep)
        ):
            return candidate

        for source_root in (DOCUMENTATION_ROOT, BASE_DIR):
            root_norm = os.path.normpath(source_root)
            root_case = os.path.normcase(root_norm)

            if candidate_case == root_case:
                return remote_root

            if candidate_case.startswith(root_case + os.sep):
                relative_path = candidate[
                    len(root_norm):
                ].lstrip("\\/")

                return os.path.normpath(
                    os.path.join(
                        remote_root,
                        relative_path
                    )
                )

        raise ValueError(
            "Cestu nelze převést na lokální cestu PC2: "
            + candidate
        )


    def _documentation_powershell_literal(self, value):
        """
        V20.1.Q3 - bezpečný PowerShell textový literál.
        """
        return "'" + str(value).replace("'", "''") + "'"


    def _documentation_decode_process_output(self, raw_output):
        """
        V20.1.Q3 - dekóduje výstup Windows PowerShellu.
        """
        if raw_output is None:
            return ""

        if isinstance(raw_output, str):
            return raw_output

        for encoding_name in (
            "utf-8-sig",
            "utf-8",
            "cp1250",
            "cp852",
            "mbcs",
        ):
            try:
                return raw_output.decode(encoding_name)
            except (UnicodeDecodeError, LookupError):
                continue

        return raw_output.decode(
            "utf-8",
            errors="replace"
        )


    def documentation_run_a17(self):
        """
        V20.1.Q3 - spustí audit A17 vzdáleně na PC2.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Dokumentační workflow",
                "Jiný krok dokumentačního workflow právě běží."
            )
            return

        if (
            not self.documentation_workflow_document
            or not self.documentation_workflow_workspace
        ):
            messagebox.showwarning(
                "A17 – audit dokumentu",
                "Nejprve vyber zdrojový Markdown dokument."
            )
            return

        if not os.path.isfile(
            self.documentation_workflow_document
        ):
            messagebox.showerror(
                "A17 – audit dokumentu",
                (
                    "Pracovní kopie dokumentu nebyla nalezena:\n\n"
                    f"{self.documentation_workflow_document}"
                )
            )
            return

        unresolved_fields = self._documentation_unresolved_template_fields(
            self.documentation_workflow_document
        )
        if unresolved_fields:
            preview = ", ".join(unresolved_fields[:12])
            if len(unresolved_fields) > 12:
                preview += f" … a dalších {len(unresolved_fields) - 12}"

            open_document = messagebox.askyesno(
                "A17 – nevyplněná šablona",
                (
                    "Dokument stále obsahuje nevyplněná pole šablony.\n\n"
                    f"Počet polí: {len(unresolved_fields)}\n"
                    f"První pole: {preview}\n\n"
                    "A17 se nyní nespustí. Otevřít pracovní dokument "
                    "pro doplnění?"
                )
            )
            if open_document:
                self.documentation_open_working_document()
            return

        self.documentation_workflow_running = True
        self.documentation_workflow_step = "A17 AUDIT"
        self.documentation_workflow_last_status = (
            "A17 BĚŽÍ NA PC2"
        )
        self.documentation_workflow_last_output = None
        self.documentation_workflow_findings = []
        self.documentation_workflow_report_json = None
        self.documentation_workflow_report_markdown = None
        self.documentation_workflow_a18_proposal = None
        self.documentation_workflow_a18_diff = None
        self.documentation_workflow_a18_mapping_json = None
        self.documentation_workflow_a18_mapping_markdown = None
        self.documentation_workflow_a18_panel_mapping_json = None
        self.documentation_workflow_a18_panel_mapping_markdown = None
        self.documentation_workflow_process = None
        self.documentation_workflow_started_at = (
            datetime.now().astimezone().isoformat()
        )
        self.documentation_workflow_finished_at = None

        self._documentation_update_workflow_ui()

        worker_thread = threading.Thread(
            target=self._documentation_run_a17_worker,
            daemon=True
        )
        worker_thread.start()


    def _documentation_run_a17_worker(self):
        """
        V20.1.Q3 - pracovní vlákno vzdáleného auditu A17.
        """
        try:
            remote_document = (
                self._documentation_to_remote_pc2_path(
                    self.documentation_workflow_document
                )
            )

            remote_workspace = (
                self._documentation_to_remote_pc2_path(
                    self.documentation_workflow_workspace
                )
            )

            remote_a17_script = (
                self._documentation_to_remote_pc2_path(
                    DOCUMENTATION_SCRIPTS["A17"]
                )
            )

            remote_output_dir = os.path.join(
                remote_workspace,
                "a17"
            )

            ps_host = self._documentation_powershell_literal(
                DOCUMENTATION_REMOTE_HOST
            )
            ps_python = self._documentation_powershell_literal(
                DOCUMENTATION_PYTHON_EXE
            )
            ps_script = self._documentation_powershell_literal(
                remote_a17_script
            )
            ps_document = self._documentation_powershell_literal(
                remote_document
            )
            ps_output = self._documentation_powershell_literal(
                remote_output_dir
            )
            ps_project = self._documentation_powershell_literal(
                DOCUMENTATION_REMOTE_PROJECT_ROOT
            )

            powershell_script = f"""
$ErrorActionPreference = "Stop"

try {{
    Invoke-Command -ComputerName {ps_host} -ScriptBlock {{
        param(
            $PythonExe,
            $AuditScript,
            $DocumentPath,
            $OutputDir,
            $ProjectRoot
        )

        $ErrorActionPreference = "Stop"

        Set-Location -LiteralPath $ProjectRoot

        New-Item -ItemType Directory -Path $OutputDir -Force |
            Out-Null

        & $PythonExe $AuditScript `
            --document $DocumentPath `
            --document-type AUTO `
            --output-dir $OutputDir `
            --stdout-findings 20

        $AuditExitCode = $LASTEXITCODE

        Write-Output "__MM_A17_EXIT_CODE__=$AuditExitCode"

        if ($AuditExitCode -ne 0) {{
            throw "A17 skoncil navratovym kodem $AuditExitCode"
        }}
    }} -ArgumentList {ps_python}, {ps_script}, {ps_document}, {ps_output}, {ps_project}

    exit 0
}}
catch {{
    Write-Error $_.Exception.Message
    exit 1
}}
"""
            encoded_command = base64.b64encode(
                powershell_script.encode("utf-16le")
            ).decode("ascii")

            command = [
                "powershell.exe",
                "-NoProfile",
                "-NonInteractive",
                "-ExecutionPolicy",
                "Bypass",
                "-EncodedCommand",
                encoded_command,
            ]

            creation_flags = getattr(
                subprocess,
                "CREATE_NO_WINDOW",
                0
            )

            process = subprocess.Popen(
                command,
                cwd=BASE_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=False,
                creationflags=creation_flags
            )

            self.documentation_workflow_process = process

            raw_output, _ = process.communicate()

            output_text = (
                self._documentation_decode_process_output(
                    raw_output
                )
            )

            local_exit_code = process.returncode

            marker_match = re.search(
                r"__MM_A17_EXIT_CODE__=(-?\d+)",
                output_text
            )

            remote_exit_code = (
                int(marker_match.group(1))
                if marker_match
                else None
            )

            success = (
                local_exit_code == 0
                and remote_exit_code == 0
            )

            self.after(
                0,
                lambda: self._documentation_finish_a17(
                    success=success,
                    output_text=output_text,
                    local_exit_code=local_exit_code,
                    remote_exit_code=remote_exit_code
                )
            )

        except Exception as exc:
            self.after(
                0,
                lambda error=exc: self._documentation_finish_a17(
                    success=False,
                    output_text=str(error),
                    local_exit_code=-1,
                    remote_exit_code=None
                )
            )


    def _documentation_finish_a17(
        self,
        success,
        output_text,
        local_exit_code,
        remote_exit_code
    ):
        """
        V20.1.Q3 - dokončí A17 v hlavním vlákně panelu.
        """
        self.documentation_workflow_running = False
        self.documentation_workflow_process = None
        self.documentation_workflow_finished_at = (
            datetime.now().astimezone().isoformat()
        )

        a17_dir = os.path.join(
            self.documentation_workflow_workspace,
            "a17"
        )

        stdout_path = os.path.join(
            a17_dir,
            "a17_panel_stdout.txt"
        )

        try:
            os.makedirs(
                a17_dir,
                exist_ok=True
            )

            with open(
                stdout_path,
                "w",
                encoding="utf-8"
            ) as output_handle:
                output_handle.write(output_text or "")

        except Exception:
            stdout_path = None

        report_json_path = os.path.join(
            a17_dir,
            "document_compliance_audit_latest.json"
        )

        report_md_path = os.path.join(
            a17_dir,
            "document_compliance_audit_latest.md"
        )

        report_payload = {}
        report_error = None

        if success:
            try:
                with open(
                    report_json_path,
                    "r",
                    encoding="utf-8-sig"
                ) as report_handle:
                    report_payload = json.load(report_handle)
            except Exception as exc:
                success = False
                report_error = str(exc)

        score = report_payload.get(
            "compliance_score_percent"
        )
        compliance_status = report_payload.get(
            "compliance_status"
        )
        final_status = report_payload.get(
            "final_status"
        )

        manifest_payload = {}

        try:
            if (
                self.documentation_workflow_manifest
                and os.path.isfile(
                    self.documentation_workflow_manifest
                )
            ):
                with open(
                    self.documentation_workflow_manifest,
                    "r",
                    encoding="utf-8-sig"
                ) as manifest_handle:
                    manifest_payload = json.load(
                        manifest_handle
                    )

            manifest_payload["workflow_status"] = (
                "A17_COMPLETED"
                if success
                else "A17_FAILED"
            )

            manifest_payload["a17"] = {
                "finished_at": (
                    self.documentation_workflow_finished_at
                ),
                "success": bool(success),
                "local_exit_code": local_exit_code,
                "remote_exit_code": remote_exit_code,
                "compliance_score_percent": score,
                "compliance_status": compliance_status,
                "final_status": final_status,
                "report_json": (
                    report_json_path
                    if os.path.isfile(report_json_path)
                    else None
                ),
                "report_markdown": (
                    report_md_path
                    if os.path.isfile(report_md_path)
                    else None
                ),
                "stdout_log": stdout_path,
            }

            if self.documentation_workflow_manifest:
                with open(
                    self.documentation_workflow_manifest,
                    "w",
                    encoding="utf-8"
                ) as manifest_handle:
                    json.dump(
                        manifest_payload,
                        manifest_handle,
                        ensure_ascii=False,
                        indent=2
                    )

        except Exception:
            pass

        if success:
            score_text = (
                f"{float(score):.2f} %"
                if score is not None
                else "-"
            )

            status_text = (
                str(compliance_status or "AUDIT READY")
            )

            self.documentation_workflow_step = "A17"
            self.documentation_workflow_last_status = (
                f"A17 HOTOVO | {score_text} | {status_text}"
            )
            self.documentation_workflow_last_output = (
                report_md_path
            )
            self.documentation_workflow_findings = list(
                report_payload.get("findings") or []
            )
            self.documentation_workflow_report_json = (
                report_json_path
                if os.path.isfile(report_json_path)
                else None
            )
            self.documentation_workflow_report_markdown = (
                report_md_path
                if os.path.isfile(report_md_path)
                else None
            )

            self._documentation_update_workflow_ui()

            messagebox.showinfo(
                "A17 – audit dokončen",
                (
                    "Audit dokumentu proběhl na PC2.\n\n"
                    f"Skóre souladu: {score_text}\n"
                    f"Stav: {status_text}\n\n"
                    f"Report:\n{report_md_path}"
                )
            )
            return

        self.documentation_workflow_step = "A17"
        self.documentation_workflow_last_status = (
            "CHYBA A17"
        )
        self.documentation_workflow_last_output = (
            stdout_path or output_text
        )
        self.documentation_workflow_findings = []
        self.documentation_workflow_report_json = None
        self.documentation_workflow_report_markdown = None

        self._documentation_update_workflow_ui()

        detail_parts = [
            f"Lokální návratový kód: {local_exit_code}",
            f"Vzdálený návratový kód: {remote_exit_code}",
        ]

        if report_error:
            detail_parts.append(
                f"Načtení reportu: {report_error}"
            )

        output_tail = (output_text or "")[-2500:]

        messagebox.showerror(
            "A17 – audit selhal",
            (
                "\n".join(detail_parts)
                + "\n\nPoslední výstup:\n"
                + output_tail
            )
        )

    def documentation_run_a18(self):
        """
        V20.1.Q3 STEP 10 - vytvoří bezpečný návrh opravy přes A18 na PC2.

        Zdrojový dokument se nemění. A18 čte poslední JSON audit A17,
        ověří SHA-256 pracovní kopie a uloží návrh, diff a mapování pouze
        do podsložky a18 aktuálního workspace.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Dokumentační workflow",
                "Jiný krok dokumentačního workflow právě běží."
            )
            return

        audit_path = getattr(
            self,
            "documentation_workflow_report_json",
            None
        )

        if not audit_path:
            messagebox.showwarning(
                "A18 – návrh opravy",
                "Nejprve spusť audit A17."
            )
            return

        if not os.path.isfile(audit_path):
            messagebox.showerror(
                "A18 – návrh opravy",
                f"JSON report A17 nebyl nalezen:\n\n{audit_path}"
            )
            return

        try:
            with open(
                audit_path,
                "r",
                encoding="utf-8-sig"
            ) as audit_handle:
                audit_payload = json.load(audit_handle)
        except Exception as exc:
            messagebox.showerror(
                "A18 – návrh opravy",
                f"JSON report A17 nelze načíst:\n\n{exc}"
            )
            return

        document_type = str(
            audit_payload.get("document_type") or ""
        ).strip().upper()

        supported_types = {
            "DAILY_LOG",
            "CHAT_CONTINUATION",
        }

        if document_type not in supported_types:
            messagebox.showinfo(
                "A18 – návrh opravy",
                (
                    "A18 nyní podporuje pouze denní zápisy a dokumenty "
                    "NAVÁZÁNÍ.\n\n"
                    f"Detekovaný typ: {document_type or '-'}\n\n"
                    "Zdrojový dokument nebyl změněn."
                )
            )
            return

        findings = list(audit_payload.get("findings") or [])
        actionable_findings = [
            item
            for item in findings
            if isinstance(item, dict)
            and str(item.get("result", "")).strip().upper()
            in {"FAIL", "PARTIAL"}
        ]

        if not actionable_findings:
            messagebox.showinfo(
                "A18 – návrh opravy",
                (
                    "Audit A17 neobsahuje žádný nález FAIL nebo PARTIAL.\n\n"
                    "Automatický strukturální návrh opravy není potřeba. "
                    "Případné MANUAL_REVIEW zůstává k ručnímu posouzení."
                )
            )
            return

        if not self.documentation_workflow_workspace:
            messagebox.showwarning(
                "A18 – návrh opravy",
                "Aktuální dokument nemá vytvořený workspace."
            )
            return

        self.documentation_workflow_running = True
        self.documentation_workflow_step = "A18 NÁVRH"
        self.documentation_workflow_last_status = (
            "A18 VYTVÁŘÍ NÁVRH NA PC2"
        )
        self.documentation_workflow_last_output = None
        self.documentation_workflow_process = None
        self.documentation_workflow_started_at = (
            datetime.now().astimezone().isoformat()
        )
        self.documentation_workflow_finished_at = None

        self.documentation_workflow_a18_proposal = None
        self.documentation_workflow_a18_diff = None
        self.documentation_workflow_a18_mapping_json = None
        self.documentation_workflow_a18_mapping_markdown = None
        self.documentation_workflow_a18_panel_mapping_json = None
        self.documentation_workflow_a18_panel_mapping_markdown = None

        self._documentation_update_workflow_ui()

        worker_thread = threading.Thread(
            target=self._documentation_run_a18_worker,
            daemon=True
        )
        worker_thread.start()


    def _documentation_run_a18_worker(self):
        """
        V20.1.Q3 STEP 10 - pracovní vlákno vzdáleného A18.
        """
        try:
            remote_audit = self._documentation_to_remote_pc2_path(
                self.documentation_workflow_report_json
            )
            remote_workspace = self._documentation_to_remote_pc2_path(
                self.documentation_workflow_workspace
            )
            remote_a18_script = self._documentation_to_remote_pc2_path(
                DOCUMENTATION_SCRIPTS["A18"]
            )
            remote_output_dir = os.path.join(
                remote_workspace,
                "a18"
            )

            ps_host = self._documentation_powershell_literal(
                DOCUMENTATION_REMOTE_HOST
            )
            ps_python = self._documentation_powershell_literal(
                DOCUMENTATION_PYTHON_EXE
            )
            ps_script = self._documentation_powershell_literal(
                remote_a18_script
            )
            ps_audit = self._documentation_powershell_literal(
                remote_audit
            )
            ps_output = self._documentation_powershell_literal(
                remote_output_dir
            )
            ps_project = self._documentation_powershell_literal(
                DOCUMENTATION_REMOTE_PROJECT_ROOT
            )

            powershell_script = f"""
$ErrorActionPreference = "Stop"

try {{
    Invoke-Command -ComputerName {ps_host} -ScriptBlock {{
        param(
            $PythonExe,
            $ProposalScript,
            $AuditPath,
            $OutputDir,
            $ProjectRoot
        )

        $ErrorActionPreference = "Stop"

        Set-Location -LiteralPath $ProjectRoot

        New-Item -ItemType Directory -Path $OutputDir -Force |
            Out-Null

        & $PythonExe $ProposalScript `
            --audit $AuditPath `
            --output-dir $OutputDir

        $ProposalExitCode = $LASTEXITCODE

        Write-Output "__MM_A18_EXIT_CODE__=$ProposalExitCode"

        if ($ProposalExitCode -ne 0) {{
            throw "A18 skoncil navratovym kodem $ProposalExitCode"
        }}
    }} -ArgumentList {ps_python}, {ps_script}, {ps_audit}, {ps_output}, {ps_project}

    exit 0
}}
catch {{
    Write-Error $_.Exception.Message
    exit 1
}}
"""

            encoded_command = base64.b64encode(
                powershell_script.encode("utf-16le")
            ).decode("ascii")

            command = [
                "powershell.exe",
                "-NoProfile",
                "-NonInteractive",
                "-ExecutionPolicy",
                "Bypass",
                "-EncodedCommand",
                encoded_command,
            ]

            creation_flags = getattr(
                subprocess,
                "CREATE_NO_WINDOW",
                0
            )

            process = subprocess.Popen(
                command,
                cwd=BASE_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=False,
                creationflags=creation_flags
            )

            self.documentation_workflow_process = process

            raw_output, _ = process.communicate()
            output_text = self._documentation_decode_process_output(
                raw_output
            )
            local_exit_code = process.returncode

            marker_match = re.search(
                r"__MM_A18_EXIT_CODE__=(-?\d+)",
                output_text
            )
            remote_exit_code = (
                int(marker_match.group(1))
                if marker_match
                else None
            )

            success = (
                local_exit_code == 0
                and remote_exit_code == 0
            )

            self.after(
                0,
                lambda: self._documentation_finish_a18(
                    success=success,
                    output_text=output_text,
                    local_exit_code=local_exit_code,
                    remote_exit_code=remote_exit_code
                )
            )

        except Exception as exc:
            self.after(
                0,
                lambda error=exc: self._documentation_finish_a18(
                    success=False,
                    output_text=str(error),
                    local_exit_code=-1,
                    remote_exit_code=None
                )
            )


    def _documentation_finish_a18(
        self,
        success,
        output_text,
        local_exit_code,
        remote_exit_code
    ):
        """
        V20.1.Q3 STEP 10 - dokončí A18 v hlavním vlákně panelu.
        """
        self.documentation_workflow_running = False
        self.documentation_workflow_process = None
        self.documentation_workflow_finished_at = (
            datetime.now().astimezone().isoformat()
        )

        a18_dir = os.path.join(
            self.documentation_workflow_workspace,
            "a18"
        )
        stdout_path = os.path.join(
            a18_dir,
            "a18_panel_stdout.txt"
        )

        try:
            os.makedirs(a18_dir, exist_ok=True)
            with open(
                stdout_path,
                "w",
                encoding="utf-8"
            ) as output_handle:
                output_handle.write(output_text or "")
        except Exception:
            stdout_path = None

        proposal_path = os.path.join(
            a18_dir,
            "document_standardization_proposal_latest.md"
        )
        diff_path = os.path.join(
            a18_dir,
            "document_standardization_diff_latest.diff"
        )
        mapping_json_path = os.path.join(
            a18_dir,
            "document_standardization_mapping_latest.json"
        )
        mapping_md_path = os.path.join(
            a18_dir,
            "document_standardization_mapping_latest.md"
        )
        panel_json_path = os.path.join(
            a18_dir,
            "document_standardization_panel_mapping_latest.json"
        )
        panel_md_path = os.path.join(
            a18_dir,
            "document_standardization_panel_mapping_latest.md"
        )

        mapping_payload = {}
        panel_payload = {}
        report_error = None

        if success:
            required_paths = (
                proposal_path,
                diff_path,
                mapping_json_path,
                panel_json_path,
            )
            missing_paths = [
                path
                for path in required_paths
                if not os.path.isfile(path)
            ]
            if missing_paths:
                success = False
                report_error = (
                    "A18 nevrátil všechny povinné výstupy:\n"
                    + "\n".join(missing_paths)
                )

        if success:
            try:
                with open(
                    mapping_json_path,
                    "r",
                    encoding="utf-8-sig"
                ) as mapping_handle:
                    mapping_payload = json.load(mapping_handle)

                with open(
                    panel_json_path,
                    "r",
                    encoding="utf-8-sig"
                ) as panel_handle:
                    panel_payload = json.load(panel_handle)
            except Exception as exc:
                success = False
                report_error = str(exc)

        final_status = (
            mapping_payload.get("final_status")
            or panel_payload.get("final_status")
        )
        document_type = (
            mapping_payload.get("document_type")
            or panel_payload.get("document_type")
        )
        coverage = mapping_payload.get(
            "character_mapping_coverage_percent"
        )

        try:
            manifest_payload = {}
            if (
                self.documentation_workflow_manifest
                and os.path.isfile(
                    self.documentation_workflow_manifest
                )
            ):
                with open(
                    self.documentation_workflow_manifest,
                    "r",
                    encoding="utf-8-sig"
                ) as manifest_handle:
                    manifest_payload = json.load(manifest_handle)

            manifest_payload["workflow_status"] = (
                "A18_COMPLETED"
                if success
                else "A18_FAILED"
            )
            manifest_payload["a18"] = {
                "finished_at": (
                    self.documentation_workflow_finished_at
                ),
                "success": bool(success),
                "local_exit_code": local_exit_code,
                "remote_exit_code": remote_exit_code,
                "document_type": document_type,
                "final_status": final_status,
                "character_mapping_coverage_percent": coverage,
                "proposal": (
                    proposal_path
                    if os.path.isfile(proposal_path)
                    else None
                ),
                "diff": (
                    diff_path
                    if os.path.isfile(diff_path)
                    else None
                ),
                "mapping_json": (
                    mapping_json_path
                    if os.path.isfile(mapping_json_path)
                    else None
                ),
                "mapping_markdown": (
                    mapping_md_path
                    if os.path.isfile(mapping_md_path)
                    else None
                ),
                "panel_mapping_json": (
                    panel_json_path
                    if os.path.isfile(panel_json_path)
                    else None
                ),
                "panel_mapping_markdown": (
                    panel_md_path
                    if os.path.isfile(panel_md_path)
                    else None
                ),
                "stdout_log": stdout_path,
                "source_modified": False,
            }

            if self.documentation_workflow_manifest:
                with open(
                    self.documentation_workflow_manifest,
                    "w",
                    encoding="utf-8"
                ) as manifest_handle:
                    json.dump(
                        manifest_payload,
                        manifest_handle,
                        ensure_ascii=False,
                        indent=2
                    )
        except Exception:
            pass

        if success:
            self.documentation_workflow_step = "A18"
            coverage_text = (
                f"{float(coverage):.2f} %"
                if coverage is not None
                else "-"
            )
            self.documentation_workflow_last_status = (
                f"A18 NÁVRH HOTOV | POKRYTÍ {coverage_text}"
            )
            self.documentation_workflow_last_output = proposal_path
            self.documentation_workflow_a18_proposal = proposal_path
            self.documentation_workflow_a18_diff = diff_path
            self.documentation_workflow_a18_mapping_json = (
                mapping_json_path
            )
            self.documentation_workflow_a18_mapping_markdown = (
                mapping_md_path
                if os.path.isfile(mapping_md_path)
                else None
            )
            self.documentation_workflow_a18_panel_mapping_json = (
                panel_json_path
            )
            self.documentation_workflow_a18_panel_mapping_markdown = (
                panel_md_path
                if os.path.isfile(panel_md_path)
                else None
            )

            self._documentation_update_workflow_ui()

            open_now = messagebox.askyesno(
                "A18 – návrh opravy vytvořen",
                (
                    "Bezpečný návrh opravy byl vytvořen ve workspace.\n\n"
                    f"Typ: {document_type or '-'}\n"
                    f"Pokrytí obsahu: {coverage_text}\n"
                    f"Stav: {final_status or 'READY'}\n\n"
                    "Zdrojový dokument nebyl změněn.\n\n"
                    f"Návrh:\n{proposal_path}\n\n"
                    "Otevřít návrh nyní?"
                )
            )

            if open_now:
                try:
                    os.startfile(proposal_path)
                except Exception as exc:
                    messagebox.showerror(
                        "A18 – otevření návrhu",
                        f"Návrh se nepodařilo otevřít:\n\n{exc}"
                    )
            return

        self.documentation_workflow_step = "A18"
        self.documentation_workflow_last_status = "CHYBA A18"
        self.documentation_workflow_last_output = (
            stdout_path or output_text
        )
        self.documentation_workflow_a18_proposal = None
        self.documentation_workflow_a18_diff = None
        self.documentation_workflow_a18_mapping_json = None
        self.documentation_workflow_a18_mapping_markdown = None
        self.documentation_workflow_a18_panel_mapping_json = None
        self.documentation_workflow_a18_panel_mapping_markdown = None

        self._documentation_update_workflow_ui()

        detail_parts = [
            f"Lokální návratový kód: {local_exit_code}",
            f"Vzdálený návratový kód: {remote_exit_code}",
        ]
        if report_error:
            detail_parts.append(f"Výstupy A18: {report_error}")

        output_tail = (output_text or "")[-3000:]

        messagebox.showerror(
            "A18 – návrh opravy selhal",
            (
                "\n".join(detail_parts)
                + "\n\nPoslední výstup:\n"
                + output_tail
            )
        )



    def documentation_run_a19(self):
        """
        V20.1.Q3 STEP 11 - otevře samostatné GUI A19 nad výstupem A18.

        A19 běží lokálně na PC1. A18 kontrakt obsahuje lokální cestu PC2,
        proto panel vytvoří v podsložce a19 bezpečnou pracovní kopii
        kontraktu s UNC cestou ke stejnému zdrojovému souboru.
        """
        if self.documentation_workflow_running:
            messagebox.showwarning(
                "Dokumentační workflow",
                "Jiný krok dokumentačního workflow právě běží."
            )
            return

        mapping_path = getattr(
            self,
            "documentation_workflow_a18_panel_mapping_json",
            None
        )
        if not mapping_path:
            messagebox.showwarning(
                "A19 – kontrola mapování",
                "Nejprve vytvoř návrh opravy A18."
            )
            return

        if not os.path.isfile(mapping_path):
            messagebox.showerror(
                "A19 – kontrola mapování",
                f"Panelový kontrakt A18 nebyl nalezen:\\n\\n{mapping_path}"
            )
            return

        a19_script = DOCUMENTATION_SCRIPTS.get("A19")
        if not a19_script or not os.path.isfile(a19_script):
            messagebox.showerror(
                "A19 – kontrola mapování",
                f"Skript A19 nebyl nalezen:\\n\\n{a19_script}"
            )
            return

        try:
            with open(mapping_path, "r", encoding="utf-8-sig") as handle:
                payload = json.load(handle)

            source_pc2 = str(
                payload.get("source_document_path") or ""
            ).strip()
            remote_root = os.path.normpath(
                DOCUMENTATION_REMOTE_PROJECT_ROOT
            )
            source_norm = os.path.normpath(source_pc2)

            if os.path.normcase(source_norm).startswith(
                os.path.normcase(remote_root + os.sep)
            ):
                relative_path = source_norm[
                    len(remote_root):
                ].lstrip("\\/")
                source_unc = os.path.normpath(
                    os.path.join(
                        DOCUMENTATION_ROOT,
                        relative_path
                    )
                )
            elif os.path.normcase(source_norm).startswith(
                os.path.normcase(
                    os.path.normpath(DOCUMENTATION_ROOT) + os.sep
                )
            ):
                source_unc = source_norm
            else:
                raise ValueError(
                    "Zdrojovou cestu A18 nelze převést na UNC cestu: "
                    + source_pc2
                )

            if not os.path.isfile(source_unc):
                raise FileNotFoundError(
                    "Zdrojový dokument nebyl nalezen přes UNC cestu: "
                    + source_unc
                )

            a19_dir = os.path.join(
                self.documentation_workflow_workspace,
                "a19"
            )
            os.makedirs(a19_dir, exist_ok=True)

            bridge_mapping = os.path.join(
                a19_dir,
                "document_standardization_panel_mapping_for_a19.json"
            )

            payload["source_document_path"] = source_unc
            payload["panel_bridge"] = {
                "created_by": "MATCHMATRIX_CONTROL_PANEL_V20_1_Q3_STEP_11",
                "original_source_document_path": source_pc2,
                "pc1_unc_source_document_path": source_unc,
                "original_mapping_path": mapping_path,
                "source_modified": False,
                "database_modified": False,
            }

            with open(
                bridge_mapping,
                "w",
                encoding="utf-8"
            ) as handle:
                json.dump(
                    payload,
                    handle,
                    ensure_ascii=False,
                    indent=2
                )

            command = [
                sys.executable,
                a19_script,
                "--mapping",
                bridge_mapping,
                "--output-dir",
                a19_dir,
                "--reviewer",
                "Petr",
            ]

            subprocess.Popen(
                command,
                cwd=BASE_DIR,
                creationflags=0
            )

            self.documentation_workflow_step = "A19 KONTROLA MAPOVÁNÍ"
            self.documentation_workflow_last_status = (
                "A19 OTEVŘENO NA PC1"
            )
            self.documentation_workflow_last_output = bridge_mapping
            self._documentation_update_workflow_ui()

        except Exception as exc:
            self.documentation_workflow_step = "A19"
            self.documentation_workflow_last_status = "CHYBA A19"
            self.documentation_workflow_last_output = str(exc)
            self._documentation_update_workflow_ui()
            messagebox.showerror(
                "A19 – kontrola mapování",
                str(exc)
            )


    def _documentation_manifest_update(self, **values):
        """Bezpečně doplní stav workflow do manifestu aktuálního workspace."""
        if not self.documentation_workflow_manifest:
            return
        payload = {}
        try:
            if os.path.isfile(self.documentation_workflow_manifest):
                with open(self.documentation_workflow_manifest, "r", encoding="utf-8-sig") as handle:
                    payload = json.load(handle)
        except Exception:
            payload = {}
        payload.update(values)
        with open(self.documentation_workflow_manifest, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2)

    def _documentation_start_remote_tool(self, *, tool_key, arguments, step, running_status, finish_callback):
        """Spustí dokumentační Python nástroj na PC2 bez blokování GUI."""
        if self.documentation_workflow_running:
            messagebox.showwarning("Dokumentační workflow", "Jiný krok dokumentačního workflow právě běží.")
            return False
        tool_path = DOCUMENTATION_SCRIPTS.get(tool_key)
        if not tool_path or not os.path.isfile(tool_path):
            messagebox.showerror("Dokumentační workflow", f"Skript {tool_key} nebyl nalezen:\n\n{tool_path}")
            return False
        self.documentation_workflow_running = True
        self.documentation_workflow_step = step
        self.documentation_workflow_last_status = running_status
        self.documentation_workflow_started_at = datetime.now().astimezone().isoformat()
        self.documentation_workflow_finished_at = None
        self._documentation_update_workflow_ui()

        def worker():
            try:
                remote_tool = self._documentation_to_remote_pc2_path(tool_path)
                remote_args = []
                for value in arguments:
                    if isinstance(value, tuple) and len(value) == 2 and value[0] == "PATH":
                        remote_args.append(self._documentation_to_remote_pc2_path(value[1]))
                    else:
                        remote_args.append(str(value))
                ps_host = self._documentation_powershell_literal(DOCUMENTATION_REMOTE_HOST)
                ps_python = self._documentation_powershell_literal(DOCUMENTATION_PYTHON_EXE)
                ps_tool = self._documentation_powershell_literal(remote_tool)
                ps_project = self._documentation_powershell_literal(DOCUMENTATION_REMOTE_PROJECT_ROOT)
                ps_args = "@(" + ",".join(self._documentation_powershell_literal(x) for x in remote_args) + ")"
                powershell_script = (
                    '$ErrorActionPreference = "Stop"\n'
                    'try {\n'
                    f'    Invoke-Command -ComputerName {ps_host} -ScriptBlock {{\n'
                    '        param($PythonExe, $ToolScript, $ProjectRoot, $ToolArgs)\n'
                    '        $ErrorActionPreference = "Stop"\n'
                    '        Set-Location -LiteralPath $ProjectRoot\n'
                    '        & $PythonExe $ToolScript @ToolArgs\n'
                    '        $ToolExitCode = $LASTEXITCODE\n'
                    '        Write-Output "__MM_TOOL_EXIT_CODE__=$ToolExitCode"\n'
                    '        if ($ToolExitCode -ne 0) { throw "Dokumentacni nastroj skoncil kodem $ToolExitCode" }\n'
                    f'    }} -ArgumentList {ps_python}, {ps_tool}, {ps_project}, {ps_args}\n'
                    '    exit 0\n'
                    '}\n'
                    'catch {\n'
                    '    Write-Error $_.Exception.Message\n'
                    '    exit 1\n'
                    '}\n'
                )
                encoded = base64.b64encode(powershell_script.encode("utf-16le")).decode("ascii")
                command = ["powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-EncodedCommand", encoded]
                creation_flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
                process = subprocess.Popen(command, cwd=BASE_DIR, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=False, creationflags=creation_flags)
                self.documentation_workflow_process = process
                raw_output, _ = process.communicate()
                output_text = self._documentation_decode_process_output(raw_output)
                marker = re.search(r"__MM_TOOL_EXIT_CODE__=(-?\d+)", output_text)
                remote_code = int(marker.group(1)) if marker else None
                success = process.returncode == 0 and remote_code == 0
                self.after(0, lambda: finish_callback(success, output_text, process.returncode, remote_code))
            except Exception as exc:
                self.after(0, lambda error=exc: finish_callback(False, str(error), -1, None))

        threading.Thread(target=worker, daemon=True).start()
        return True

    def _documentation_finish_generic(self, *, success, step, success_status, failure_status, output_text, output_dir):
        self.documentation_workflow_running = False
        self.documentation_workflow_process = None
        self.documentation_workflow_finished_at = datetime.now().astimezone().isoformat()
        try:
            os.makedirs(output_dir, exist_ok=True)
            stdout_path = os.path.join(output_dir, "panel_stdout.txt")
            with open(stdout_path, "w", encoding="utf-8") as handle:
                handle.write(output_text or "")
        except Exception:
            stdout_path = None
        self.documentation_workflow_step = step
        self.documentation_workflow_last_status = success_status if success else failure_status
        self.documentation_workflow_last_output = stdout_path or output_text
        self._documentation_update_workflow_ui()
        return stdout_path

    def documentation_run_a20(self):
        """STEP 12 - vytvoří standardizovaný dokument z uzavřeného A19."""
        if not self.documentation_workflow_workspace:
            messagebox.showwarning("A20 – vytvořit dokument", "Nejprve vyber dokument a dokonči A19.")
            return
        review_path = os.path.join(self.documentation_workflow_workspace, "a19", "document_standardization_panel_review_latest.json")
        if not os.path.isfile(review_path):
            messagebox.showwarning("A20 – vytvořit dokument", "Uzavřený kontrakt A19 nebyl nalezen.")
            return
        try:
            with open(review_path, "r", encoding="utf-8-sig") as handle:
                review = json.load(handle)
            if review.get("review_status") != "MAPPING_CONFIRMED" or review.get("final_status") != "DOCUMENT_STANDARDIZATION_PANEL_REVIEW_CONFIRMED":
                raise RuntimeError("Mapování A19 ještě není finálně uzavřeno.")
        except Exception as exc:
            messagebox.showerror("A20 – vytvořit dokument", str(exc))
            return
        output_dir = os.path.join(self.documentation_workflow_workspace, "a20")
        self._documentation_start_remote_tool(
            tool_key="A20",
            arguments=["--review", ("PATH", review_path), "--output-dir", ("PATH", output_dir)],
            step="A20 VYTVOŘENÍ DOKUMENTU",
            running_status="A20 BĚŽÍ NA PC2",
            finish_callback=lambda success, out, local, remote: self._documentation_finish_a20(success, out, output_dir),
        )

    def _documentation_finish_a20(self, success, output_text, output_dir):
        self._documentation_finish_generic(success=success, step="A20", success_status="A20 DOKUMENT VYTVOŘEN", failure_status="CHYBA A20", output_text=output_text, output_dir=output_dir)
        candidate = os.path.join(output_dir, "document_standardized_candidate_latest.md")
        build_json = os.path.join(output_dir, "document_standardized_candidate_build_latest.json")
        if success and os.path.isfile(candidate) and os.path.isfile(build_json):
            self.documentation_workflow_a20_candidate = candidate
            self.documentation_workflow_a20_build_json = build_json
            self.documentation_workflow_document = candidate
            self.documentation_workflow_last_output = candidate
            self._documentation_manifest_update(workflow_status="A20_COMPLETED", a20_candidate=candidate, a20_build_json=build_json)
            self._documentation_update_workflow_ui()
            messagebox.showinfo("A20 – dokument vytvořen", f"Standardizovaný kandidát byl vytvořen.\n\n{candidate}\n\nDoplň případné placeholdery a potom spusť FINÁLNÍ A17.")
        else:
            messagebox.showerror("A20 – chyba", (output_text or "")[-3500:])

    def documentation_open_a20_candidate(self):
        candidate = self.documentation_workflow_a20_candidate
        if not candidate or not os.path.isfile(candidate):
            messagebox.showwarning("A20 – kandidát", "Nejprve vytvoř dokument tlačítkem VYTVOŘIT DOKUMENT.")
            return
        try:
            os.startfile(candidate)
            self.documentation_workflow_step = "RUČNÍ DOPLNĚNÍ KANDIDÁTA"
            self.documentation_workflow_last_status = "KANDIDÁT OTEVŘEN"
            self._documentation_update_workflow_ui()
        except Exception as exc:
            messagebox.showerror("A20 – kandidát", str(exc))

    def _documentation_run_named_a17(self, document_path, output_dir, step, running_status, finish_callback):
        if not document_path or not os.path.isfile(document_path):
            messagebox.showwarning("A17", "Dokument pro audit nebyl nalezen.")
            return
        self._documentation_start_remote_tool(
            tool_key="A17",
            arguments=["--document", ("PATH", document_path), "--document-type", "AUTO", "--output-dir", ("PATH", output_dir), "--stdout-findings", "20"],
            step=step,
            running_status=running_status,
            finish_callback=finish_callback,
        )

    def documentation_run_final_a17(self):
        candidate = self.documentation_workflow_a20_candidate
        output_dir = os.path.join(self.documentation_workflow_workspace or "", "a17_final_candidate")
        self._documentation_run_named_a17(candidate, output_dir, "FINÁLNÍ A17 KANDIDÁTA", "FINÁLNÍ A17 BĚŽÍ", lambda success, out, local, remote: self._documentation_finish_named_a17(success, out, output_dir, canonical=False))

    def _documentation_finish_named_a17(self, success, output_text, output_dir, canonical=False):
        self._documentation_finish_generic(success=success, step="KANONICKÝ A17" if canonical else "FINÁLNÍ A17", success_status="KANONICKÝ A17 HOTOV" if canonical else "FINÁLNÍ A17 HOTOV", failure_status="CHYBA KANONICKÉHO A17" if canonical else "CHYBA FINÁLNÍHO A17", output_text=output_text, output_dir=output_dir)
        report_json = os.path.join(output_dir, "document_compliance_audit_latest.json")
        report_md = os.path.join(output_dir, "document_compliance_audit_latest.md")
        if success and os.path.isfile(report_json):
            try:
                with open(report_json, "r", encoding="utf-8-sig") as handle:
                    report = json.load(handle)
                findings = report.get("findings") or []
                fails = sum(1 for item in findings if str(item.get("result", "")).upper() == "FAIL")
                partial = sum(1 for item in findings if str(item.get("result", "")).upper() == "PARTIAL")
                if canonical:
                    self.documentation_workflow_canonical_a17_json = report_json
                    self.documentation_workflow_canonical_a17_markdown = report_md if os.path.isfile(report_md) else None
                else:
                    self.documentation_workflow_final_a17_json = report_json
                    self.documentation_workflow_final_a17_markdown = report_md if os.path.isfile(report_md) else None
                self.documentation_workflow_report_json = report_json
                self.documentation_workflow_report_markdown = report_md if os.path.isfile(report_md) else None
                self.documentation_workflow_findings = findings
                self._documentation_update_workflow_ui()
                messagebox.showinfo("A17 – výsledek", f"Skóre: {report.get('compliance_score_percent')} %\nFAIL: {fails}\nPARTIAL: {partial}\nStav: {report.get('compliance_status')}")
                return
            except Exception as exc:
                messagebox.showerror("A17 – report", str(exc))
                return
        messagebox.showerror("A17 – audit selhal", (output_text or "")[-3500:])

    def _documentation_read_metadata(self, path_value):
        text_value = Path(path_value).read_text(encoding="utf-8-sig")
        fields = {}
        aliases = {"document id": "document_id", "dokument": "document_id", "typ dokumentu": "document_type", "typ": "document_type", "název dokumentu": "title", "název": "title", "stav": "status"}
        for line in text_value.splitlines():
            match = re.match(r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|$", line)
            if not match:
                continue
            key = match.group(1).strip().casefold()
            value = match.group(2).strip().strip("`")
            if key in aliases and aliases[key] not in fields:
                fields[aliases[key]] = value
        return text_value, fields

    def documentation_approve_and_save_canonical(self):
        candidate = self.documentation_workflow_a20_candidate
        report_path = self.documentation_workflow_final_a17_json
        if not candidate or not os.path.isfile(candidate) or not report_path or not os.path.isfile(report_path):
            messagebox.showwarning("Schválení dokumentu", "Nejprve vytvoř kandidát, doplň jej a spusť FINÁLNÍ A17.")
            return

        unresolved_fields = self._documentation_unresolved_template_fields(
            candidate
        )
        if unresolved_fields:
            messagebox.showwarning(
                "Schválení dokumentu",
                (
                    "Dokument stále obsahuje nevyplněná pole šablony.\n\n"
                    f"Počet polí: {len(unresolved_fields)}\n"
                    f"Pole: {', '.join(unresolved_fields[:15])}\n\n"
                    "Dokument nelze schválit."
                )
            )
            return

        try:
            with open(report_path, "r", encoding="utf-8-sig") as handle:
                report = json.load(handle)
            findings = report.get("findings") or []

            # Pracovní kandidát A20 má záměrně technický název
            # document_standardized_candidate_latest.md. Proto smí finální
            # audit kandidáta obsahovat pouze očekávaný FAIL COMMON-FILENAME.
            # Všechny ostatní FAIL/PARTIAL nálezy schválení stále blokují.
            candidate_basename = os.path.basename(candidate).lower()
            allowed_working_filename = (
                candidate_basename
                == "document_standardized_candidate_latest.md"
            )

            blocking_findings = []
            for item in findings:
                result = str(item.get("result", "")).strip().upper()
                rule_id = str(item.get("rule_id", "")).strip().upper()

                if result not in {"FAIL", "PARTIAL"}:
                    continue

                if (
                    allowed_working_filename
                    and result == "FAIL"
                    and rule_id == "COMMON-FILENAME"
                ):
                    continue

                blocking_findings.append(item)

            if blocking_findings:
                blocking_rules = ", ".join(
                    str(item.get("rule_id") or "?")
                    for item in blocking_findings
                )
                raise RuntimeError(
                    "Finální A17 obsahuje blokující FAIL nebo PARTIAL: "
                    f"{blocking_rules}"
                )

            text_value, metadata = self._documentation_read_metadata(candidate)
            if re.search(r"^>\s*\*\*DOPLNIT UŽIVATELEM", text_value, re.MULTILINE):
                raise RuntimeError("Kandidát stále obsahuje skutečný placeholder DOPLNIT UŽIVATELEM.")
            document_id = metadata.get("document_id")
            document_type = metadata.get("document_type")
            if isinstance(document_type, str):
                document_type = " ".join(document_type.strip().upper().split())
            if not document_id or not document_type:
                raise RuntimeError("Nelze načíst Document ID nebo Typ dokumentu z metadat.")
            if not messagebox.askyesno("Schválení dokumentu", f"Potvrzuješ finální obsah a terminologii dokumentu {document_id}?\n\nDokument bude uložen jako APPROVED do kanonické složky."):
                return
            approved_text = re.sub(
                r"(?m)^\| Stav \| DRAFT[^|]*\|$",
                "| Stav | APPROVED |",
                text_value
            )
            approved_text = re.sub(r"(?m)^\| Stav \| REVIEW \|$", "| Původní stav zdrojového dokumentu | REVIEW |", approved_text)
            if document_type == "CHAT_CONTINUATION":
                target_dir = os.path.join(
                    DOCUMENTATION_ROOT,
                    "docs",
                    "09_HISTORY",
                    "NAVÁZÁNÍ_NA_CHAT"
                )
                filename = f"{document_id}_MATCHMATRIX_NAVAZANI_DO_CHATU.md"

            elif document_type == "DAILY_LOG":
                target_dir = os.path.join(
                    DOCUMENTATION_ROOT,
                    "docs",
                    "09_HISTORY",
                    "DENNÍ_ZÁPISY"
                )
                filename = f"{document_id}_MATCHMATRIX_DENNI_ZAPIS.md"

            elif document_type in {
                "PROJECT_SNAPSHOT",
                "PROJECT SNAPSHOT",
                "PROJECT SNAPSHOT / HISTORICKÝ PROJEKTOVÝ CHECKPOINT",
                "PROJECT_SNAPSHOT / HISTORICKÝ PROJEKTOVÝ CHECKPOINT",
            }:
                target_dir = os.path.join(
                    DOCUMENTATION_ROOT,
                    "docs",
                    "09_HISTORY",
                    "PROJECT_SNAPSHOTS"
                )

                # U Project Snapshotu zachovej již standardizovaný název
                # pracovního zdroje, protože obsahuje období/checkpoint.
                source_filename = os.path.basename(candidate)
                source_stem, source_ext = os.path.splitext(source_filename)

                if (
                    source_ext.lower() == ".md"
                    and source_stem.upper().startswith(
                        f"{document_id}_".upper()
                    )
                ):
                    filename = source_filename
                else:
                    filename = (
                        f"{document_id}_MATCHMATRIX_PROJECT_SNAPSHOT.md"
                    )

            else:
                raise RuntimeError(
                    f"Kanonické uložení typu {document_type!r} "
                    "zatím panel nepodporuje."
                )
            approved_dir = os.path.join(self.documentation_workflow_workspace, "approved")
            os.makedirs(approved_dir, exist_ok=True)
            approved_path = os.path.join(approved_dir, filename)
            os.makedirs(target_dir, exist_ok=True)
            canonical_path = os.path.join(target_dir, filename)
            encoded = approved_text.encode("utf-8")

            # Pokud již existuje aktivní kanonický dokument stejné identity,
            # nesmí být přepsán bez výslovného potvrzení. Předchozí obsah se
            # bezpečně uloží do auditní kopie uvnitř aktuálního workspace.
            if os.path.exists(canonical_path):
                existing_bytes = Path(canonical_path).read_bytes()

                if existing_bytes != encoded:
                    replace_confirmed = messagebox.askyesno(
                        "Aktualizace kanonického dokumentu",
                        (
                            "Kanonický dokument stejného Document ID již existuje "
                            "s jiným obsahem.\n\n"
                            f"{canonical_path}\n\n"
                            "Předchozí obsah bude uložen jako auditní kopie do "
                            "aktuálního workspace a aktivní kanonický soubor bude "
                            "nahrazen schválenou verzí.\n\n"
                            "Pokračovat?"
                        )
                    )

                    if not replace_confirmed:
                        raise RuntimeError(
                            "Aktualizace kanonického dokumentu byla zrušena uživatelem."
                        )

                    previous_dir = os.path.join(
                        self.documentation_workflow_workspace,
                        "previous_canonical"
                    )
                    os.makedirs(previous_dir, exist_ok=True)

                    backup_stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                    previous_path = os.path.join(
                        previous_dir,
                        f"{Path(filename).stem}_BEFORE_{backup_stamp}.md"
                    )
                    Path(previous_path).write_bytes(existing_bytes)

                    self._documentation_manifest_update(
                        previous_canonical=previous_path,
                        canonical_replaced=True
                    )

            Path(canonical_path).write_bytes(encoded)
            Path(approved_path).write_bytes(encoded)
            self.documentation_workflow_approved_candidate = approved_path
            self.documentation_workflow_canonical_document = canonical_path
            self.documentation_workflow_document = canonical_path
            self.documentation_workflow_step = "KANONICKÉ ULOŽENÍ"
            self.documentation_workflow_last_status = "DOKUMENT APPROVED A ULOŽEN"
            self.documentation_workflow_last_output = canonical_path
            self._documentation_manifest_update(workflow_status="CANONICAL_SAVED", approved_candidate=approved_path, canonical_document=canonical_path)
            self._documentation_update_workflow_ui()
            messagebox.showinfo("Schválení dokumentu", f"Kanonický dokument byl uložen:\n\n{canonical_path}\n\nNyní spusť KANONICKÝ A17.")
        except Exception as exc:
            messagebox.showerror("Schválení dokumentu", str(exc))

    def documentation_run_canonical_a17(self):
        document = self.documentation_workflow_canonical_document
        output_dir = os.path.join(self.documentation_workflow_workspace or "", "a17_canonical")
        self._documentation_run_named_a17(document, output_dir, "KANONICKÝ A17", "KANONICKÝ A17 BĚŽÍ", lambda success, out, local, remote: self._documentation_finish_named_a17(success, out, output_dir, canonical=True))

    def documentation_git_commit(self):
        """STEP 17 - commitne pouze konkrétní kanonický dokument, nikdy celý strom."""
        document = self.documentation_workflow_canonical_document
        report_path = self.documentation_workflow_canonical_a17_json
        if not document or not os.path.isfile(document) or not report_path or not os.path.isfile(report_path):
            messagebox.showwarning("Git commit", "Nejprve ulož kanonický dokument a spusť KANONICKÝ A17.")
            return
        try:
            with open(report_path, "r", encoding="utf-8-sig") as handle:
                report = json.load(handle)
            findings = report.get("findings") or []
            if any(str(item.get("result", "")).upper() in {"FAIL", "PARTIAL"} for item in findings):
                raise RuntimeError("Kanonický A17 obsahuje FAIL nebo PARTIAL. Commit je zablokován.")
            _, metadata = self._documentation_read_metadata(document)
            document_id = metadata.get("document_id") or Path(document).stem
            if not messagebox.askyesno("Git commit", f"Commitnout pouze tento dokument?\n\n{document}\n\nCommit message:\ndocs: add {document_id}"):
                return
            remote_document = self._documentation_to_remote_pc2_path(document)
            remote_root = os.path.normpath(DOCUMENTATION_REMOTE_PROJECT_ROOT)
            relative = os.path.relpath(remote_document, remote_root).replace("\\", "/")
            ps_host = self._documentation_powershell_literal(DOCUMENTATION_REMOTE_HOST)
            ps_project = self._documentation_powershell_literal(DOCUMENTATION_REMOTE_PROJECT_ROOT)
            ps_relative = self._documentation_powershell_literal(relative)
            ps_message = self._documentation_powershell_literal(f"docs: add {document_id}")
            powershell_script = (
                '$ErrorActionPreference = "Stop"\n'
                'try {\n'
                f'    Invoke-Command -ComputerName {ps_host} -ScriptBlock {{\n'
                '        param($ProjectRoot, $RelativePath, $CommitMessage)\n'
                '        $ErrorActionPreference = "Stop"\n'
                '        Set-Location -LiteralPath $ProjectRoot\n'
                '        git add -- $RelativePath\n'
                '        if ($LASTEXITCODE -ne 0) { throw "git add selhal" }\n'
                '        git diff --cached --quiet -- $RelativePath\n'
                '        if ($LASTEXITCODE -eq 0) {\n'
                '            $ExistingCommit = git log -1 --format=%H -- $RelativePath\n'
                '            $ExistingSubject = git log -1 --format=%s -- $RelativePath\n'
                '            Write-Output "__MM_GIT_NO_CHANGES__=1"\n'
                '            Write-Output "__MM_GIT_COMMIT__=$ExistingCommit"\n'
                '            Write-Output "__MM_GIT_SUBJECT__=$ExistingSubject"\n'
                '            return\n'
                '        }\n'
                '        git commit -m $CommitMessage -- $RelativePath\n'
                '        if ($LASTEXITCODE -ne 0) { throw "git commit selhal" }\n'
                '        $CommitHash = git rev-parse HEAD\n'
                '        $CommitSubject = git log -1 --pretty=%s\n'
                '        Write-Output "__MM_GIT_COMMIT__=$CommitHash"\n'
                '        Write-Output "__MM_GIT_SUBJECT__=$CommitSubject"\n'
                f'    }} -ArgumentList {ps_project}, {ps_relative}, {ps_message}\n'
                '    exit 0\n'
                '}\n'
                'catch { Write-Error $_.Exception.Message; exit 1 }\n'
            )
            encoded = base64.b64encode(powershell_script.encode("utf-16le")).decode("ascii")
            self.documentation_workflow_running = True
            self.documentation_workflow_step = "GIT COMMIT"
            self.documentation_workflow_last_status = "GIT COMMIT BĚŽÍ NA PC2"
            self._documentation_update_workflow_ui()
            def worker():
                try:
                    creation_flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
                    result = subprocess.run(["powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-EncodedCommand", encoded], cwd=BASE_DIR, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=False, creationflags=creation_flags)
                    output = self._documentation_decode_process_output(result.stdout)
                    self.after(0, lambda: self._documentation_finish_git_commit(result.returncode == 0, output))
                except Exception as exc:
                    self.after(0, lambda error=exc: self._documentation_finish_git_commit(False, str(error)))
            threading.Thread(target=worker, daemon=True).start()
        except Exception as exc:
            messagebox.showerror("Git commit", str(exc))

    def _documentation_finish_git_commit(self, success, output_text):
        self.documentation_workflow_running = False
        self.documentation_workflow_process = None

        commit_match = re.search(
            r"__MM_GIT_COMMIT__=([0-9a-fA-F]+)",
            output_text or ""
        )
        no_changes = "__MM_GIT_NO_CHANGES__=1" in (output_text or "")

        if success and commit_match:
            commit_hash = commit_match.group(1)
            self.documentation_workflow_git_commit = commit_hash
            self.documentation_workflow_step = "GIT COMMIT"
            self.documentation_workflow_last_output = output_text

            if no_changes:
                self.documentation_workflow_last_status = (
                    f"BEZ ZMĚN – JIŽ COMMITNUTO: {commit_hash[:8]}"
                )
                self._documentation_manifest_update(
                    workflow_status="GIT_ALREADY_COMMITTED",
                    git_commit=commit_hash,
                    canonical_document=self.documentation_workflow_canonical_document
                )
                self._documentation_update_workflow_ui()
                messagebox.showinfo(
                    "Git commit",
                    (
                        "Vybraný dokument nemá žádné nové změny.\n\n"
                        "Dokument už je v Git historii.\n\n"
                        f"Poslední commit: {commit_hash}\n\n"
                        "Nový commit nebyl potřeba."
                    )
                )
            else:
                self.documentation_workflow_last_status = (
                    f"COMMIT HOTOV: {commit_hash[:8]}"
                )
                self._documentation_manifest_update(
                    workflow_status="GIT_COMMITTED",
                    git_commit=commit_hash,
                    canonical_document=self.documentation_workflow_canonical_document
                )
                self._documentation_update_workflow_ui()
                messagebox.showinfo(
                    "Git commit",
                    (
                        "Dokument byl commitnut.\n\n"
                        f"Commit: {commit_hash}\n\n"
                        "Push nebyl spuštěn."
                    )
                )
        else:
            self.documentation_workflow_step = "GIT COMMIT"
            self.documentation_workflow_last_status = "CHYBA GIT COMMIT"
            self.documentation_workflow_last_output = output_text
            self._documentation_update_workflow_ui()
            messagebox.showerror("Git commit", (output_text or "")[-3500:])


    def _documentation_a17_problem_findings(self):
        # V20.1.Q3 STEP 09 - pouze kontroly vyžadující pozornost.
        findings = list(
            getattr(self, "documentation_workflow_findings", []) or []
        )
        return [
            item
            for item in findings
            if isinstance(item, dict)
            and str(item.get("result", "")).strip().upper() != "PASS"
        ]


    def documentation_open_a17_report(self):
        # V20.1.Q3 STEP 09 - otevře Markdown nebo JSON report.
        report_path = (
            getattr(
                self,
                "documentation_workflow_report_markdown",
                None
            )
            or getattr(
                self,
                "documentation_workflow_report_json",
                None
            )
        )

        if not report_path:
            messagebox.showwarning(
                "A17 – report",
                "Nejprve spusť audit A17."
            )
            return

        if not os.path.isfile(report_path):
            messagebox.showerror(
                "A17 – report",
                f"Report nebyl nalezen:\n\n{report_path}"
            )
            return

        try:
            os.startfile(report_path)
        except Exception as exc:
            messagebox.showerror(
                "A17 – report",
                f"Report se nepodařilo otevřít:\n\n{exc}"
            )


    def documentation_show_a17_findings(self):
        # V20.1.Q3 STEP 09 - samostatné okno detailu nálezů.
        all_findings = list(
            getattr(self, "documentation_workflow_findings", []) or []
        )

        report_ready = bool(
            getattr(self, "documentation_workflow_report_json", None)
            or getattr(
                self,
                "documentation_workflow_report_markdown",
                None
            )
        )

        if not report_ready:
            messagebox.showwarning(
                "A17 – nálezy",
                "Nejprve spusť audit A17."
            )
            return

        problem_findings = self._documentation_a17_problem_findings()

        detail_window = tk.Toplevel(self)
        detail_window.title("MatchMatrix – A17 – detail nálezů")
        detail_window.geometry("1120x680")
        detail_window.minsize(900, 560)
        detail_window.configure(bg=PANEL_2)
        detail_window.transient(self)
        detail_window.columnconfigure(0, weight=1)
        detail_window.rowconfigure(1, weight=3)
        detail_window.rowconfigure(2, weight=2)

        summary_text = (
            f"Kontroly celkem: {len(all_findings)} | "
            f"K řešení: {len(problem_findings)}"
        )

        tk.Label(
            detail_window,
            text=summary_text,
            bg=PANEL_2,
            fg=GREEN if not problem_findings else YELLOW,
            font=("Segoe UI", 11, "bold"),
            anchor="w"
        ).grid(
            row=0,
            column=0,
            sticky="ew",
            padx=12,
            pady=(12, 8)
        )

        table_frame = tk.Frame(detail_window, bg=PANEL_2)
        table_frame.grid(
            row=1,
            column=0,
            sticky="nsew",
            padx=12,
            pady=(0, 8)
        )
        table_frame.columnconfigure(0, weight=1)
        table_frame.rowconfigure(0, weight=1)

        columns = (
            "rule_id",
            "result",
            "severity",
            "category",
            "title"
        )
        findings_tree = ttk.Treeview(
            table_frame,
            columns=columns,
            show="headings",
            selectmode="browse"
        )

        headings = {
            "rule_id": "PRAVIDLO",
            "result": "VÝSLEDEK",
            "severity": "ZÁVAŽNOST",
            "category": "KATEGORIE",
            "title": "NÁZEV",
        }
        widths = {
            "rule_id": 190,
            "result": 145,
            "severity": 100,
            "category": 125,
            "title": 420,
        }

        for column_name in columns:
            findings_tree.heading(
                column_name,
                text=headings[column_name]
            )
            findings_tree.column(
                column_name,
                width=widths[column_name],
                anchor=(
                    "w"
                    if column_name in ("rule_id", "title")
                    else "center"
                ),
                stretch=(column_name == "title")
            )

        scrollbar_y = ttk.Scrollbar(
            table_frame,
            orient="vertical",
            command=findings_tree.yview
        )
        scrollbar_x = ttk.Scrollbar(
            table_frame,
            orient="horizontal",
            command=findings_tree.xview
        )
        findings_tree.configure(
            yscrollcommand=scrollbar_y.set,
            xscrollcommand=scrollbar_x.set
        )

        findings_tree.grid(row=0, column=0, sticky="nsew")
        scrollbar_y.grid(row=0, column=1, sticky="ns")
        scrollbar_x.grid(row=1, column=0, sticky="ew")

        detail_text = tk.Text(
            detail_window,
            bg="#0e0915",
            fg=TEXT,
            insertbackground=TEXT,
            relief="flat",
            wrap="word",
            font=("Consolas", 10),
            padx=10,
            pady=10
        )
        detail_text.grid(
            row=2,
            column=0,
            sticky="nsew",
            padx=12,
            pady=(0, 8)
        )
        detail_text.config(state="disabled")

        for finding_index, finding in enumerate(problem_findings):
            findings_tree.insert(
                "",
                "end",
                iid=str(finding_index),
                values=(
                    finding.get("rule_id", "-"),
                    finding.get("result", "-"),
                    finding.get("severity", "-"),
                    finding.get("category", "-"),
                    finding.get("title", "-")
                )
            )

        def render_finding_detail(event=None):
            selected = findings_tree.selection()
            if not selected:
                return

            try:
                finding = problem_findings[int(selected[0])]
            except Exception:
                return

            evidence = finding.get("evidence") or []
            if isinstance(evidence, (list, tuple)):
                evidence_text = "\n".join(
                    f"- {item}"
                    for item in evidence
                )
            else:
                evidence_text = str(evidence)

            detail_lines = [
                f"PRAVIDLO: {finding.get('rule_id', '-')}",
                f"NÁZEV: {finding.get('title', '-')}",
                f"VÝSLEDEK: {finding.get('result', '-')}",
                f"ZÁVAŽNOST: {finding.get('severity', '-')}",
                f"KATEGORIE: {finding.get('category', '-')}",
                f"STANDARD: {finding.get('standard', '-')}",
                "",
                "POPIS:",
                str(finding.get("description", "-")),
                "",
                "DŮKAZY:",
                evidence_text or "-",
                "",
                "DOPORUČENÍ:",
                str(finding.get("recommendation", "-")),
            ]

            detail_text.config(state="normal")
            detail_text.delete("1.0", "end")
            detail_text.insert("1.0", "\n".join(detail_lines))
            detail_text.config(state="disabled")

        findings_tree.bind(
            "<<TreeviewSelect>>",
            render_finding_detail
        )

        if problem_findings:
            findings_tree.selection_set("0")
            findings_tree.focus("0")
            findings_tree.see("0")
            render_finding_detail()
        else:
            detail_text.config(state="normal")
            detail_text.insert(
                "1.0",
                (
                    "Audit neobsahuje žádný nález typu FAIL, "
                    "PARTIAL nebo MANUAL_REVIEW.\n\n"
                    "Úplný výsledek je dostupný v reportu A17."
                )
            )
            detail_text.config(state="disabled")

        button_frame = tk.Frame(detail_window, bg=PANEL_2)
        button_frame.grid(
            row=3,
            column=0,
            sticky="ew",
            padx=12,
            pady=(0, 12)
        )

        tk.Button(
            button_frame,
            text="OTEVŘÍT REPORT",
            command=self.documentation_open_a17_report,
            bg="#355c8a",
            fg="white",
            activebackground="#4270a6",
            activeforeground="white",
            relief="flat",
            font=("Segoe UI", 9, "bold"),
            padx=12,
            pady=6,
            cursor="hand2"
        ).pack(side="left")

        tk.Button(
            button_frame,
            text="ZAVŘÍT",
            command=detail_window.destroy,
            bg="#4c4257",
            fg="white",
            activebackground="#62566f",
            activeforeground="white",
            relief="flat",
            font=("Segoe UI", 9, "bold"),
            padx=12,
            pady=6,
            cursor="hand2"
        ).pack(side="right")


    def open_matchmatrix_path(self, relative_path):
        """
        V20.1.Q - Otevře soubor nebo složku uvnitř projektu MatchMatrix.

        Bezpečnost:
        - cesta je vždy odvozena od BASE_DIR,
        - nic nemaže ani neupravuje,
        - při chybě zobrazí srozumitelné upozornění.
        """
        target = os.path.normpath(os.path.join(DOCUMENTATION_ROOT, relative_path))

        if not os.path.exists(target):
            messagebox.showwarning(
                "Dokumentace",
                f"Cesta neexistuje:\n{target}"
            )
            return

        try:
            os.startfile(target)
        except Exception as exc:
            messagebox.showerror(
                "Dokumentace",
                f"Cestu se nepodařilo otevřít:\n{target}\n\n{exc}"
            )

    def _read_utf8_text(self, path):
        """Bezpečně načte UTF-8 Markdown soubor."""
        last_error = None
        for encoding in ("utf-8-sig", "utf-8"):
            try:
                with open(path, "r", encoding=encoding) as handle:
                    return handle.read()
            except Exception as exc:
                last_error = exc
        raise last_error

    def _parse_translation_glossary(self, text):
        """Načte pouze tabulku Cizí výraz | Český překlad z MM-REF-001."""
        marker = "# 2. Překladový slovník"
        start = text.find(marker)
        if start < 0:
            return []

        entries = []
        table_started = False
        for raw_line in text[start:].splitlines()[1:]:
            line = raw_line.strip()
            if line == "---" and table_started:
                break
            if not line.startswith("|"):
                continue
            parts = [part.strip() for part in line.strip("|").split("|")]
            if len(parts) != 2:
                continue
            if parts[0] in {"Cizí výraz", "---"} or set(parts[0]) <= {"-", ":"}:
                table_started = True
                continue
            if not table_started:
                continue
            if parts[0] and parts[1]:
                entries.append({"foreign": parts[0], "czech": parts[1]})
        return entries

    def _parse_explanation_registry(self, text):
        """Načte výkladové sekce MM-REF-002 do slovníku podle cizího výrazu."""
        result = {}
        pattern = re.compile(r"^##\s+3\.\d+\s+(.+?)\s*$", re.MULTILINE)
        matches = list(pattern.finditer(text))

        for index, match in enumerate(matches):
            term = match.group(1).strip()
            section_start = match.end()
            section_end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
            section = text[section_start:section_end]

            def field(label):
                found = re.search(
                    rf"^\*\*{re.escape(label)}:\*\*\s*(.+?)\s*$",
                    section,
                    re.MULTILINE
                )
                return found.group(1).strip().strip("`") if found else ""

            result[term.casefold()] = {
                "foreign": term,
                "czech": field("Český překlad"),
                "explanation": field("Vysvětlení"),
                "source_document": field("Zdrojový dokument"),
                "target_chapter": field("Cílová kapitola nebo sekce"),
            }
        return result

    def load_glossary_reference(self):
        """
        V20.1.Q2 - spojí překladový slovník MM-REF-001 s výklady MM-REF-002.
        """
        try:
            translation_text = self._read_utf8_text(GLOSSARY_TRANSLATION_PATH)
            translations = self._parse_translation_glossary(translation_text)
        except Exception as exc:
            translations = []
            if hasattr(self, "glossary_status_label"):
                self.glossary_status_label.config(text="CHYBA MM-REF-001", fg=RED)
            messagebox.showwarning(
                "Překladový slovník",
                f"Nelze načíst MM-REF-001:\n{GLOSSARY_TRANSLATION_PATH}\n\n{exc}"
            )

        try:
            explanation_text = self._read_utf8_text(GLOSSARY_EXPLANATION_PATH)
            explanations = self._parse_explanation_registry(explanation_text)
        except Exception:
            explanations = {}

        combined = []
        for translation in translations:
            detail = explanations.get(translation["foreign"].casefold(), {})
            combined.append({
                "foreign": translation["foreign"],
                "czech": translation["czech"],
                "explanation": detail.get("explanation", "Výklad zatím není doplněn v MM-REF-002."),
                "source_document": detail.get("source_document", ""),
                "target_chapter": detail.get("target_chapter", ""),
            })

        self.glossary_entries = sorted(
            combined,
            key=lambda item: item.get("foreign", "").casefold()
        )
        self.filter_glossary_terms()

    def filter_glossary_terms(self):
        if not hasattr(self, "glossary_tree"):
            return

        query = ""
        if hasattr(self, "glossary_search_var"):
            query = self.glossary_search_var.get().strip().casefold()

        for item_id in self.glossary_tree.get_children():
            self.glossary_tree.delete(item_id)
        self.glossary_entry_by_iid = {}

        visible = []
        for entry in getattr(self, "glossary_entries", []):
            haystack = " ".join([
                entry.get("foreign", ""),
                entry.get("czech", ""),
                entry.get("explanation", ""),
                entry.get("source_document", ""),
                entry.get("target_chapter", ""),
            ]).casefold()
            if query and query not in haystack:
                continue
            visible.append(entry)

        for index, entry in enumerate(visible):
            iid = f"glossary_{index}"
            self.glossary_entry_by_iid[iid] = entry
            self.glossary_tree.insert(
                "",
                "end",
                iid=iid,
                values=(
                    entry.get("foreign", ""),
                    entry.get("czech", ""),
                    entry.get("source_document", ""),
                    entry.get("target_chapter", ""),
                )
            )

        if hasattr(self, "glossary_status_label"):
            self.glossary_status_label.config(
                text=f"{len(visible)} / {len(getattr(self, 'glossary_entries', []))}",
                fg=GREEN if visible else YELLOW
            )

        if visible:
            first_iid = "glossary_0"
            self.glossary_tree.selection_set(first_iid)
            self.glossary_tree.focus(first_iid)
            self.on_glossary_select()
        else:
            self.glossary_selected_entry = None
            self._set_glossary_detail("Nebyl nalezen žádný odpovídající cizí výraz.")

    def _set_glossary_detail(self, content):
        if not hasattr(self, "glossary_detail_text"):
            return
        self.glossary_detail_text.config(state="normal")
        self.glossary_detail_text.delete("1.0", "end")
        self.glossary_detail_text.insert("1.0", content)
        self.glossary_detail_text.config(state="disabled")

    def on_glossary_select(self, event=None):
        selected = self.glossary_tree.selection() if hasattr(self, "glossary_tree") else ()
        if not selected:
            return
        entry = self.glossary_entry_by_iid.get(selected[0])
        if not entry:
            return
        self.glossary_selected_entry = entry
        body = f"""CIZÍ VÝRAZ
{entry.get('foreign') or '-'}

ČESKÝ PŘEKLAD
{entry.get('czech') or '-'}

VYSVĚTLENÍ
{entry.get('explanation') or '-'}

ZDROJOVÝ DOKUMENT
{entry.get('source_document') or '-'}

CÍLOVÁ KAPITOLA / SEKCE
{entry.get('target_chapter') or '-'}

Použij tlačítka dole pro otevření výkladu, kapitoly nebo celého dokumentu."""
        self._set_glossary_detail(body)

    def open_selected_glossary_explanation(self):
        entry = getattr(self, "glossary_selected_entry", None)
        if not entry:
            messagebox.showinfo("Výklad pojmu", "Nejdřív vyber cizí výraz.")
            return
        body = f"""CIZÍ VÝRAZ:
{entry.get('foreign') or '-'}

ČESKÝ PŘEKLAD:
{entry.get('czech') or '-'}

VYSVĚTLENÍ:
{entry.get('explanation') or '-'}

ZDROJOVÝ DOKUMENT:
{entry.get('source_document') or '-'}

CÍLOVÁ KAPITOLA / SEKCE:
{entry.get('target_chapter') or '-'}"""
        self.show_help_window(
            f"📘 VÝKLAD POJMU :: {entry.get('foreign') or ''}",
            body
        )

    def _normalize_match_text(self, value):
        normalized = unicodedata.normalize("NFKD", str(value or ""))
        ascii_text = "".join(char for char in normalized if not unicodedata.combining(char))
        return re.sub(r"[^a-z0-9]+", " ", ascii_text.casefold()).strip()

    def _find_document_file(self, document_id):
        """
        V20.1.Q2 FIX:
        Dokument se vybírá podle skutečného Document ID uvnitř Markdownu,
        ne pouze podle začátku názvu souboru.
        """
        document_id = str(document_id or "").strip()
        if not document_id:
            return None

        docs_root = os.path.join(DOCUMENTATION_ROOT, "docs")
        wanted_id = document_id.upper()
        candidates = []

        for root, _dirs, files in os.walk(docs_root):
            for filename in files:
                if not filename.lower().endswith(".md"):
                    continue

                if not filename.upper().startswith(wanted_id):
                    continue

                full_path = os.path.join(root, filename)

                try:
                    with open(
                        full_path,
                        "r",
                        encoding="utf-8-sig",
                        errors="replace"
                    ) as source:
                        header_text = "".join(
                            source.readline() for _ in range(80)
                        )
                except OSError:
                    continue

                exact_heading = re.search(
                    rf"(?mi)^#\s*{re.escape(document_id)}\s*$",
                    header_text
                )

                exact_metadata = re.search(
                    rf"(?mi)^\|\s*(?:Označení|Dokument)\s*\|[^|]*\b{re.escape(document_id)}\b",
                    header_text
                )

                if not (exact_heading or exact_metadata):
                    continue

                upper_path = full_path.upper()
                history_penalty = (
                    1
                    if "09_HISTORY" in upper_path or "99_ARCHIVE" in upper_path
                    else 0
                )
                review_penalty = 1 if "_REVIEW" in filename.upper() else 0

                candidates.append(
                    (
                        history_penalty,
                        review_penalty,
                        len(full_path),
                        full_path
                    )
                )

        if not candidates:
            return None

        candidates.sort()
        return candidates[0][3]

    def open_selected_glossary_document(self):
        entry = getattr(self, "glossary_selected_entry", None)
        if not entry:
            messagebox.showinfo("Zdrojový dokument", "Nejdřív vyber cizí výraz.")
            return
        path = self._find_document_file(entry.get("source_document"))
        if not path:
            messagebox.showwarning(
                "Zdrojový dokument",
                f"Dokument {entry.get('source_document') or '-'} nebyl nalezen v hlavní dokumentaci na PC2."
            )
            return
        try:
            os.startfile(path)
        except Exception as exc:
            messagebox.showerror("Zdrojový dokument", f"Dokument nelze otevřít:\n{path}\n\n{exc}")

    def _extract_relevant_markdown_section(self, text, target_chapter, term):
        headings = list(re.finditer(r"^(#{1,6})\s+(.+?)\s*$", text, re.MULTILINE))
        if not headings:
            return None, None

        target_norm = self._normalize_match_text(target_chapter)
        term_norm = self._normalize_match_text(term)
        selected_index = None

        for index, heading in enumerate(headings):
            heading_norm = self._normalize_match_text(heading.group(2))
            if target_norm and (target_norm in heading_norm or heading_norm in target_norm):
                selected_index = index
                break

        if selected_index is None and term_norm:
            for index, heading in enumerate(headings):
                heading_norm = self._normalize_match_text(heading.group(2))
                if term_norm in heading_norm or heading_norm in term_norm:
                    selected_index = index
                    break

        if selected_index is None:
            search_positions = []
            for needle in (target_chapter, term):
                if needle:
                    position = text.casefold().find(str(needle).casefold())
                    if position >= 0:
                        search_positions.append(position)
            if search_positions:
                position = min(search_positions)
                for index, heading in enumerate(headings):
                    if heading.start() <= position:
                        selected_index = index
                    else:
                        break

        if selected_index is None:
            return None, None

        selected = headings[selected_index]
        selected_level = len(selected.group(1))
        section_end = len(text)
        for following in headings[selected_index + 1:]:
            if len(following.group(1)) <= selected_level:
                section_end = following.start()
                break

        return selected.group(2).strip(), text[selected.start():section_end].strip()

    def open_selected_glossary_chapter(self):
        entry = getattr(self, "glossary_selected_entry", None)
        if not entry:
            messagebox.showinfo("Zdrojová kapitola", "Nejdřív vyber cizí výraz.")
            return
        path = self._find_document_file(entry.get("source_document"))
        if not path:
            messagebox.showwarning(
                "Zdrojová kapitola",
                f"Dokument {entry.get('source_document') or '-'} nebyl nalezen v hlavní dokumentaci na PC2."
            )
            return
        try:
            source_text = self._read_utf8_text(path)
            heading, section = self._extract_relevant_markdown_section(
                source_text,
                entry.get("target_chapter"),
                entry.get("foreign")
            )
        except Exception as exc:
            messagebox.showerror("Zdrojová kapitola", f"Dokument nelze načíst:\n{path}\n\n{exc}")
            return

        if not section:
            messagebox.showinfo(
                "Zdrojová kapitola",
                "Přesná kapitola nebyla nalezena. Otevírám celý zdrojový dokument."
            )
            try:
                os.startfile(path)
            except Exception as exc:
                messagebox.showerror("Zdrojový dokument", str(exc))
            return

        self.show_help_window(
            f"📑 {entry.get('source_document')} :: {heading}",
            section
        )

    def load_documentation_dashboard(self):
        """
        V20.1.Q - DOCUMENTATION CENTER

        CO TO JE:
        - Read-only načtení dokumentační databáze.

        K ČEMU TO JE:
        - Rychlá kontrola, zda jsou dokumenty, aktuální verze, sekce,
          vazby a importní běhy konzistentně uložené.

        ZDROJE:
        - documentation.documents
        - documentation.document_versions
        - documentation.document_sections
        - documentation.document_relations
        - documentation.document_status_history
        - documentation.import_runs
        """

        summary_sql = """
        SELECT
            (SELECT COUNT(*) FROM documentation.documents) AS documents,
            (
                SELECT COUNT(*)
                FROM documentation.document_versions
                WHERE is_current = true
            ) AS current_versions,
            (
                SELECT COUNT(*)
                FROM documentation.document_versions
            ) AS versions_total,
            (
                SELECT COUNT(*)
                FROM documentation.document_sections
            ) AS sections,
            (
                SELECT COUNT(*)
                FROM documentation.document_relations
            ) AS relations,
            (
                SELECT COUNT(*)
                FROM documentation.document_status_history
            ) AS status_history,
            (
                SELECT COUNT(*)
                FROM documentation.import_runs
            ) AS import_runs,
            (
                SELECT COUNT(*)
                FROM documentation.documents
                WHERE COALESCE(is_active, false) = true
            ) AS active_documents;
        """

        documents_sql = """
        SELECT
            document_id,
            title,
            document_type,
            edition,
            current_version_label,
            current_status,
            source_of_truth,
            is_active,
            updated_at
        FROM documentation.documents
        ORDER BY
            updated_at DESC NULLS LAST,
            document_id
        LIMIT 100;
        """

        import_runs_sql = """
        SELECT
            import_run_pk,
            started_at,
            finished_at,
            import_status,
            source_root,
            details
        FROM documentation.import_runs
        ORDER BY import_run_pk DESC
        LIMIT 50;
        """

        relations_sql = """
        SELECT
            source.document_id AS source_document_id,
            target.document_id AS target_document_id,
            r.relation_type,
            r.created_at
        FROM documentation.document_relations AS r
        LEFT JOIN documentation.documents AS source
          ON source.document_pk = r.source_document_pk
        LEFT JOIN documentation.documents AS target
          ON target.document_pk = r.target_document_pk
        ORDER BY r.created_at DESC NULLS LAST
        LIMIT 100;
        """

        history_sql = """
        SELECT
            d.document_id,
            h.previous_status,
            h.new_status,
            h.change_reason,
            h.changed_at
        FROM documentation.document_status_history AS h
        LEFT JOIN documentation.documents AS d
          ON d.document_pk = h.document_pk
        ORDER BY h.changed_at DESC NULLS LAST
        LIMIT 100;
        """

        self.populate_tree(
            self.documentation_kpi_tree,
            db_query(summary_sql)
        )
        self.populate_tree(
            self.documentation_documents_tree,
            db_query(documents_sql)
        )
        self.populate_tree(
            self.documentation_import_runs_tree,
            db_query(import_runs_sql)
        )
        self.populate_tree(
            self.documentation_relations_tree,
            db_query(relations_sql)
        )
        self.populate_tree(
            self.documentation_history_tree,
            db_query(history_sql)
        )
        self.load_glossary_reference()

    def load_project_progress_from_db(self):
        """
        V18.10 - COMMAND CENTER HODNOTY Z DB

        CO TO JE:
        - Načte hlavní hodnoty pro horní MatchMatrix Command Center.

        K ČEMU TO JE:
        - Panel nahoře ukazuje projektové oblasti, ne jen technické vrstvy.

        ZDROJE:
        - ops.v_sport_completion_dashboard_v2
        - ops.v_layer_readiness_dashboard_v1
        - ops.v_harvest_readiness_summary_v1
        - ops.v_harvest_odds_readiness_v1
        """

        def safe_number(value, default=0):
            try:
                if value is None:
                    return default
                return int(round(float(value)))
            except Exception:
                return default

        def clamp(value):
            return max(0, min(100, safe_number(value, 0)))

        values = dict(getattr(self, "command_center_values", {}) or {})

        # 1) Sport completion: SPORTY / PEOPLE / MEDIA / ODDS.
        sport_rows = db_query("""
            SELECT
                ROUND(AVG(COALESCE(core_pct, 0)), 2) AS sport_core_pct,
                ROUND(AVG(COALESCE(people_pct, 0)), 2) AS people_pct,
                ROUND(AVG(COALESCE(media_pct, 0)), 2) AS media_pct,
                ROUND(AVG(COALESCE(odds_pct, 0)), 2) AS odds_pct,
                ROUND(AVG(COALESCE(total_pct, 0)), 2) AS sport_total_pct
            FROM ops.v_sport_completion_dashboard_v2;
        """)

        if sport_rows and "CHYBA" not in sport_rows[0]:
            row = sport_rows[0]
            values["SPORTY"] = clamp(row.get("sport_core_pct") or row.get("sport_total_pct"))
            values["PEOPLE"] = clamp(row.get("people_pct"))
            values["MEDIA"] = clamp(row.get("media_pct"))
            values["ODDS"] = clamp(row.get("odds_pct"))

        # 2) Provider readiness z layer readiness, pokud existuje.
        provider_rows = db_query("""
            SELECT
                ROUND(AVG(COALESCE(readiness_percent, 0)), 2) AS provider_pct
            FROM ops.v_layer_readiness_dashboard_v1
            WHERE UPPER(COALESCE(layer_code, '')) LIKE '%PROVIDER%'
               OR UPPER(COALESCE(layer_name, '')) LIKE '%PROVIDER%';
        """)

        if provider_rows and "CHYBA" not in provider_rows[0]:
            provider_pct = provider_rows[0].get("provider_pct")
            if provider_pct is not None:
                values["PROVIDEŘI"] = clamp(provider_pct)

        # Fallback: provider matrix coverage podle enabled/provider rows.
        if not values.get("PROVIDEŘI"):
            provider_fallback_rows = db_query("""
                SELECT
                    CASE
                        WHEN COUNT(*) = 0 THEN 0
                        ELSE ROUND(100.0 * COUNT(*) FILTER (WHERE COALESCE(is_enabled, false) = true) / COUNT(*), 2)
                    END AS provider_pct
                FROM ops.provider_entity_coverage;
            """)
            if provider_fallback_rows and "CHYBA" not in provider_fallback_rows[0]:
                values["PROVIDEŘI"] = clamp(provider_fallback_rows[0].get("provider_pct"))

        # 3) WEB readiness – z layer readiness, jinak nízký fallback.
        web_rows = db_query("""
            SELECT
                ROUND(AVG(COALESCE(readiness_percent, 0)), 2) AS web_pct
            FROM ops.v_layer_readiness_dashboard_v1
            WHERE UPPER(COALESCE(layer_code, '')) LIKE '%WEB%'
               OR UPPER(COALESCE(layer_name, '')) LIKE '%WEB%';
        """)

        if web_rows and "CHYBA" not in web_rows[0]:
            web_pct = web_rows[0].get("web_pct")
            if web_pct is not None:
                values["WEB"] = clamp(web_pct)

        if values.get("WEB") is None:
            values["WEB"] = 12

        # 4) Celkem = vážený projektový stav.
        # WEB má menší váhu, protože vývojová filozofie projektu je nejdřív data, potom web.
        weights = {
            "SPORTY": 0.18,
            "PROVIDEŘI": 0.17,
            "PEOPLE": 0.18,
            "MEDIA": 0.14,
            "ODDS": 0.13,
            "WEB": 0.08,
        }
        governance_pct = 100
        governance_weight = 0.12
        weighted_sum = governance_pct * governance_weight
        total_weight = governance_weight

        for key, weight in weights.items():
            weighted_sum += clamp(values.get(key, 0)) * weight
            total_weight += weight

        values["PROJEKT"] = clamp(weighted_sum / total_weight if total_weight else 0)

        self.command_center_values = values
        self.project_progress_values = values

        # Aktualizace dominantního bloku.
        try:
            project_pct = clamp(values.get("PROJEKT", 0))
            if hasattr(self, "header_project_value"):
                self.header_project_value.config(text=f"{project_pct} %")
            if hasattr(self, "command_total_value"):
                self.command_total_value.config(text=f"{project_pct} %")
            if hasattr(self, "command_total_status"):
                if project_pct >= 80:
                    status = "READY PRO VELKÝ HARVEST"
                elif project_pct >= 60:
                    status = "TÉMĚŘ PŘIPRAVENO – DOPLNIT SLABÉ VRSTVY"
                elif project_pct >= 40:
                    status = "ROZPRACOVÁNO – PRIORITA PEOPLE / MEDIA / ODDS"
                else:
                    status = "BUDUJEME DATOVÉ JÁDRO A GOVERNANCE"
                self.command_total_status.config(text=status)
            self.draw_command_total_bar()
        except Exception:
            pass

        # Aktualizace karet.
        try:
            for key, widget_info in getattr(self, "command_center_widgets", {}).items():
                value = clamp(values.get(key, 0))
                label = widget_info.get("value_label")
                if label:
                    label.config(text=f"{value}%")
                redraw = widget_info.get("redraw")
                if redraw:
                    redraw()
        except Exception:
            pass

        # Aktualizace historie pro projektovou cestu.
        try:
            today = datetime.now().strftime("%m-%d")
            current_row = (
                today,
                clamp(values.get("PROJEKT", 0)),
                clamp(values.get("SPORTY", 0)),
                clamp(values.get("PROVIDEŘI", 0)),
                clamp(values.get("PEOPLE", 0)),
                clamp(values.get("MEDIA", 0)),
                clamp(values.get("ODDS", 0)),
                clamp(values.get("WEB", 0)),
            )
            history = list(getattr(self, "project_progress_history", []))
            if history and history[-1][0] == today:
                history[-1] = current_row
            else:
                history.append(current_row)
                history = history[-7:]
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
        SELECT
            harvest_readiness_percent,
            readiness_status,
            weakest_layers,
            biggest_blocker,
            recommended_next_step,
            next_target_date
        FROM ops.v_harvest_readiness_summary_v1;
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
            layer_order,
            layer_code,
            layer_name,
            readiness_percent,
            readiness_status,
            readiness_color,
            blocking_issue,
            next_action,
            panel_usage,
            updated_at
        FROM ops.v_layer_readiness_dashboard_v1
        ORDER BY layer_order;
        """

        self.populate_tree(self.harvest_readiness_tree, db_query(readiness_sql))
        self.populate_tree(self.harvest_dry_run_tree, db_query(dry_run_sql))
        self.populate_tree(self.harvest_recommendations_tree, db_query(recommendations_sql))
        self.populate_tree(self.harvest_locks_tree, db_query(locks_sql))
        self.populate_tree(self.harvest_layers_tree, db_query(layers_sql))

    def load_sport_completion_dashboard(self):
        """
        V18.6 - SPORT COMPLETION COMMAND CENTER

        CO TO JE:
        - Řídicí centrum dokončenosti sportů po vrstvách CORE / PEOPLE / MEDIA / ODDS.

        K ČEMU TO JE:
        - Ukáže nejslabší sporty, nejslabší vrstvy a další doporučený krok.
        """

        main_sql = """
        SELECT
            sport_code,
            sport_name,
            mode,
            ROUND(core_pct, 2) AS core_pct,
            ROUND(people_pct, 2) AS people_pct,
            ROUND(media_pct, 2) AS media_pct,
            ROUND(odds_pct, 2) AS odds_pct,
            ROUND(total_pct, 2) AS total_pct,
            sport_readiness,
            top_priority_rank,
            recommended_focus,
            budget_status
        FROM ops.v_sport_completion_dashboard_v2
        ORDER BY
            top_priority_rank ASC NULLS LAST,
            total_pct ASC NULLS LAST,
            sport_code;
        """

        weakest_sql = """
        WITH base AS (
            SELECT
                sport_code,
                sport_name,
                ROUND(core_pct, 2) AS core_pct,
                ROUND(people_pct, 2) AS people_pct,
                ROUND(media_pct, 2) AS media_pct,
                ROUND(odds_pct, 2) AS odds_pct,
                ROUND(total_pct, 2) AS total_pct,
                recommended_focus
            FROM ops.v_sport_completion_dashboard_v2
        ), layer_values AS (
            SELECT
                sport_code,
                sport_name,
                total_pct,
                recommended_focus,
                v.layer_name AS weakest_layer,
                v.layer_percent AS weakest_layer_pct
            FROM base
            CROSS JOIN LATERAL (VALUES
                ('CORE', core_pct),
                ('PEOPLE', people_pct),
                ('MEDIA', media_pct),
                ('ODDS', odds_pct)
            ) AS v(layer_name, layer_percent)
        ), ranked AS (
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY sport_code
                    ORDER BY weakest_layer_pct ASC, weakest_layer ASC
                ) AS rn
            FROM layer_values
        )
        SELECT
            sport_code,
            sport_name,
            weakest_layer,
            weakest_layer_pct,
            total_pct,
            recommended_focus,
            CASE
                WHEN weakest_layer_pct < 25 THEN 'KRITICKÉ'
                WHEN weakest_layer_pct < 50 THEN 'VYSOKÉ'
                WHEN weakest_layer_pct < 75 THEN 'STŘEDNÍ'
                ELSE 'NÍZKÉ'
            END AS priority_level
        FROM ranked
        WHERE rn = 1
        ORDER BY
            weakest_layer_pct ASC,
            total_pct ASC,
            sport_code;
        """

        missing_sql = """
        WITH base AS (
            SELECT
                sport_code,
                sport_name,
                ROUND(core_pct, 2) AS core_pct,
                ROUND(people_pct, 2) AS people_pct,
                ROUND(media_pct, 2) AS media_pct,
                ROUND(odds_pct, 2) AS odds_pct,
                ROUND(total_pct, 2) AS total_pct,
                recommended_focus,
                top_priority_rank
            FROM ops.v_sport_completion_dashboard_v2
        )
        SELECT
            sport_code,
            sport_name,
            v.missing_layer,
            v.layer_percent,
            total_pct,
            top_priority_rank AS priority_order,
            CASE
                WHEN v.layer_percent < 25 THEN 'KRITICKÉ'
                WHEN v.layer_percent < 50 THEN 'VYSOKÉ'
                WHEN v.layer_percent < 75 THEN 'STŘEDNÍ'
                WHEN v.layer_percent < 90 THEN 'NÍZKÉ'
                ELSE 'OK'
            END AS priority_level,
            CASE
                WHEN v.missing_layer = 'ODDS' THEN 'Doplnit odds provider / TheOdds / matching kurzů.'
                WHEN v.missing_layer = 'MEDIA' THEN 'Doplnit články, highlights a entity linking.'
                WHEN v.missing_layer = 'PEOPLE' THEN 'Doplnit hráče, trenéry, profily, fotky a statistiky.'
                WHEN v.missing_layer = 'CORE' THEN 'Doplnit fixtures, teams, leagues a merge.'
                ELSE 'Ověřit datovou mezeru.'
            END AS recommended_sport_action
        FROM base
        CROSS JOIN LATERAL (VALUES
            ('CORE', core_pct),
            ('PEOPLE', people_pct),
            ('MEDIA', media_pct),
            ('ODDS', odds_pct)
        ) AS v(missing_layer, layer_percent)
        WHERE v.layer_percent < 90
        ORDER BY
            v.layer_percent ASC,
            total_pct ASC,
            top_priority_rank ASC NULLS LAST,
            sport_code;
        """

        ai_sql = """
        SELECT
            brain_rank,
            sport_code,
            sport_name,
            entity,
            provider,
            recommended_focus,
            brain_decision,
            brain_score,
            brain_decision_reason,
            autonomous_safe,
            generated_at
        FROM ops.v_autonomous_ops_brain_v5
        ORDER BY
            brain_rank ASC
        LIMIT 50;
        """

        gap_sql = """
        SELECT *
        FROM ops.v_data_gap_engine_v2
        LIMIT 120;
        """

        self.populate_tree(self.sport_completion_main_tree, db_query(main_sql))
        self.populate_tree(self.sport_completion_focus_tree, db_query(weakest_sql))
        self.populate_tree(self.sport_completion_missing_tree, db_query(missing_sql))
        self.populate_tree(self.sport_completion_ai_tree, db_query(ai_sql))
        self.populate_tree(self.sport_completion_gap_tree, db_query(gap_sql))

    def open_sport_completion_detail(self, event):
        """
        Dvojklik na sport v SPORT COMPLETION otevře detail sportu.
        """
        selected = self.sport_completion_main_tree.selection()
        if not selected:
            return

        item = self.sport_completion_main_tree.item(selected[0])
        values = item.get("values", [])
        if not values:
            return

        sport_code = str(values[0]).strip()
        sport_name = str(values[1]).strip() if len(values) > 1 else sport_code

        win = tk.Toplevel(self)
        win.title(f"DETAIL SPORTU :: {sport_code}")
        win.geometry("1550x900")
        win.configure(bg=BG)

        tk.Label(
            win,
            text=f"🏆 DETAIL SPORTU :: {sport_code} / {sport_name}",
            bg=BG,
            fg=PINK,
            font=("Segoe UI", 22, "bold")
        ).pack(anchor="w", padx=15, pady=10)

        body = tk.Frame(win, bg=BG)
        body.pack(fill="both", expand=True, padx=10, pady=10)
        body.columnconfigure(0, weight=1)
        body.columnconfigure(1, weight=1)
        body.rowconfigure(0, weight=1)
        body.rowconfigure(1, weight=1)

        overview_tree = self.create_section(body, "📊 SPORT COMPLETION DETAIL", 0, 0)
        missing_tree = self.create_section(body, "🧩 CHYBĚJÍCÍ VRSTVY SPORTU", 0, 1)
        people_tree = self.create_section(body, "👥 PEOPLE DETAIL SPORTU", 1, 0)
        brain_tree = self.create_section(body, "🤖 AI / BRAIN DETAIL SPORTU", 1, 1)

        overview_sql = f"""
        SELECT
            sport_code,
            sport_name,
            mode,
            ROUND(core_pct, 2) AS core_pct,
            ROUND(people_pct, 2) AS people_pct,
            ROUND(media_pct, 2) AS media_pct,
            ROUND(odds_pct, 2) AS odds_pct,
            ROUND(total_pct, 2) AS total_pct,
            sport_readiness,
            top_priority_rank,
            recommended_focus,
            budget_status
        FROM ops.v_sport_completion_dashboard_v2
        WHERE sport_code = '{sport_code}';
        """

        missing_sql = f"""
        WITH base AS (
            SELECT
                sport_code,
                sport_name,
                ROUND(core_pct, 2) AS core_pct,
                ROUND(people_pct, 2) AS people_pct,
                ROUND(media_pct, 2) AS media_pct,
                ROUND(odds_pct, 2) AS odds_pct,
                ROUND(total_pct, 2) AS total_pct
            FROM ops.v_sport_completion_dashboard_v2
            WHERE sport_code = '{sport_code}'
        )
        SELECT
            sport_code,
            sport_name,
            v.missing_layer,
            v.layer_percent,
            total_pct,
            CASE
                WHEN v.missing_layer = 'ODDS' THEN 'Kurzy / bookmakeři / markety / matching na zápasy.'
                WHEN v.missing_layer = 'MEDIA' THEN 'Články / video / highlights / linking.'
                WHEN v.missing_layer = 'PEOPLE' THEN 'Hráči / trenéři / profily / fotky / statistiky.'
                WHEN v.missing_layer = 'CORE' THEN 'Ligy / týmy / zápasy / public merge.'
                ELSE 'Datová vrstva.'
            END AS what_is_it,
            CASE
                WHEN v.layer_percent >= 90 THEN 'Vrstva je téměř připravená.'
                ELSE 'Vrstva potřebuje doplnění nebo audit.'
            END AS next_action
        FROM base
        CROSS JOIN LATERAL (VALUES
            ('CORE', core_pct),
            ('PEOPLE', people_pct),
            ('MEDIA', media_pct),
            ('ODDS', odds_pct)
        ) AS v(missing_layer, layer_percent)
        ORDER BY v.layer_percent ASC;
        """

        people_sql = f"""
        SELECT *
        FROM ops.v_people_pipeline_audit_v1
        WHERE sport_code = '{sport_code}'
        ORDER BY provider
        LIMIT 100;
        """

        brain_sql = f"""
        SELECT
            brain_rank,
            sport_code,
            sport_name,
            entity,
            provider,
            recommended_focus,
            brain_decision,
            brain_score,
            brain_decision_reason,
            autonomous_safe,
            generated_at
        FROM ops.v_autonomous_ops_brain_v5
        WHERE sport_code = '{sport_code}'
        ORDER BY brain_rank ASC
        LIMIT 50;
        """

        self.populate_tree(overview_tree, db_query(overview_sql))
        self.populate_tree(missing_tree, db_query(missing_sql))
        self.populate_tree(people_tree, db_query(people_sql))
        self.populate_tree(brain_tree, db_query(brain_sql))

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

    def load_provider_matrix_dashboard(self):
        """
        V18.1 - PROVIDER MATRIX COMMAND CENTER

        CO TO JE:
        - Přehled providerů podle sportu, entity a připravenosti.

        K ČEMU TO JE:
        - Před PRO harvestem musí být jasné, který provider pokrývá CORE / PEOPLE / MEDIA / ODDS.
        """

        core_sql = """
        SELECT
            sport_code,
            sport_name,
            provider,
            supports_leagues,
            supports_teams,
            supports_fixtures,
            supports_players,
            supports_player_stats,
            supports_odds,
            supports_coaches,
            supports_standings,
            is_enabled,
            updated_at
        FROM ops.provider_sport_matrix
        ORDER BY
            sport_code,
            provider;
        """

        people_sql = """
        SELECT
            sport_code,
            sport_name,
            people_provider,
            players_supported,
            coaches_supported,
            profiles_supported,
            season_stats_supported,
            match_stats_supported,
            rankings_supported,
            photos_supported,
            provider_status,
            priority_order,
            notes,
            updated_at
        FROM ops.people_master_provider_matrix
        ORDER BY
            priority_order ASC NULLS LAST,
            sport_code,
            people_provider;
        """

        coverage_sql = """
        SELECT
            provider,
            sport_code,
            entity,
            coverage_status,
            is_enabled,
            provider_priority,
            merge_priority,
            fetch_priority,
            quality_rating,
            availability_scope,
            free_plan_supported,
            paid_plan_supported,
            expected_depth,
            is_primary_source,
            is_fallback_source,
            next_action,
            updated_at
        FROM ops.provider_entity_coverage
        ORDER BY
            sport_code,
            entity,
            provider_priority ASC NULLS LAST,
            provider;
        """

        jobs_sql = """
        SELECT
            provider,
            sport_code,
            job_code,
            endpoint_code,
            ingest_mode,
            enabled,
            priority,
            batch_size,
            max_requests_per_run,
            retry_limit,
            cooldown_seconds,
            days_back,
            days_forward,
            notes,
            updated_at
        FROM ops.provider_jobs
        ORDER BY
            enabled DESC,
            priority ASC NULLS LAST,
            sport_code,
            provider,
            job_code;
        """

        self.populate_tree(self.provider_matrix_core_tree, db_query(core_sql))
        self.populate_tree(self.provider_matrix_people_tree, db_query(people_sql))
        self.populate_tree(self.provider_matrix_coverage_tree, db_query(coverage_sql))
        self.populate_tree(self.provider_matrix_jobs_tree, db_query(jobs_sql))

    def get_selected_photo_candidate_id(self):
        """
        V19.11 - PHOTO REVIEW selected row helper.

        CO TO JE:
        - Vrátí candidate_id z vybraného řádku v PHOTO REVIEW tabulce.

        K ČEMU TO JE:
        - Tlačítka SCHVÁLIT / ZAMÍTNOUT / MERGE pracují s vybraným kandidátem.
        """
        try:
            tree = getattr(self, "photo_review_panel_tree", None)
            if tree is None:
                return None
            selected = tree.selection()
            if not selected:
                return None
            item = tree.item(selected[0])
            values = item.get("values", [])
            if not values:
                return None
            return int(values[0])
        except Exception:
            return None

    def photo_approve_selected_candidate(self):
        """
        V19.11 - PHOTO REVIEW approve.

        CO TO JE:
        - Schválí vybraného kandidáta fotografie.

        K ČEMU TO JE:
        - Po schválení může merge funkce propsat photo_url do public.players.
        """
        candidate_id = self.get_selected_photo_candidate_id()
        if not candidate_id:
            messagebox.showinfo("PHOTO REVIEW", "Nejdřív vyber řádek v tabulce PHOTO REVIEW - KANDIDÁTI.")
            return

        confirm = messagebox.askyesno(
            "SCHVÁLIT FOTO",
            f"Schválit kandidáta fotografie candidate_id={candidate_id}?"
        )
        if not confirm:
            return

        ok, err = db_execute("""
            UPDATE staging.stg_player_photo_candidates
            SET
                review_status = 'APPROVED',
                approved_by = 'panel_manual_review',
                approved_at = now(),
                updated_at = now()
            WHERE candidate_id = %s;
        """, (candidate_id,))

        if not ok:
            messagebox.showerror("PHOTO REVIEW", f"Schválení se nepodařilo:\n{err}")
            return

        self.log(f"PHOTO REVIEW: candidate_id={candidate_id} -> APPROVED")
        self.load_media_dashboard()

    def photo_preview_selected_candidate(self):
        """
        V19.11 - PHOTO REVIEW preview + player context + image preview.
        """
        candidate_id = self.get_selected_photo_candidate_id()
        if not candidate_id:
            messagebox.showinfo(
                "PHOTO REVIEW",
                "Nejdřív vyber řádek v tabulce PHOTO REVIEW - KANDIDÁTI."
            )
            return

        rows = db_query(f"""
            SELECT *
            FROM ops.v_photo_review_player_context_v1
            WHERE candidate_id = {candidate_id}
            LIMIT 1;
        """)

        if not rows or "CHYBA" in rows[0]:
            messagebox.showerror("PHOTO PREVIEW", f"Kandidát nebyl nalezen:\n{rows}")
            return

        row = rows[0]
        photo_url = row.get("candidate_photo_url")

        if not photo_url:
            messagebox.showwarning("PHOTO PREVIEW", "Vybraný kandidát nemá candidate_photo_url.")
            return

        popup = tk.Toplevel(self)
        popup.title("PHOTO PREVIEW + HRÁČSKÝ KONTEXT")
        popup.geometry("1200x720")
        popup.configure(bg=BG)

        left = tk.Frame(popup, bg="#100918", width=420)
        left.pack(side="left", fill="y", padx=8, pady=8)
        left.pack_propagate(False)

        right = tk.Frame(popup, bg="#050308")
        right.pack(side="right", fill="both", expand=True, padx=8, pady=8)

        info = (
            "KONTEXT HRÁČE\n"
            "============================\n"
            f"Hráč: {row.get('public_player_name') or '-'}\n"
            f"Player ID: {row.get('player_id') or '-'}\n"
            f"Narození: {row.get('birth_date') or '-'}\n"
            f"Věk: {row.get('age_years') or '-'}\n"
            f"Národnost: {row.get('nationality') or '-'}\n"
            f"Pozice: {row.get('position') or '-'}\n"
            f"Team ID: {row.get('team_id') or '-'}\n"
            f"Ext source: {row.get('ext_source') or '-'}\n"
            f"Ext player ID: {row.get('ext_player_id') or '-'}\n\n"
            "KANDIDÁT FOTKY\n"
            "============================\n"
            f"Candidate ID: {row.get('candidate_id') or '-'}\n"
            f"Review stav: {row.get('review_status') or '-'}\n"
            f"Důvěra: {row.get('confidence_score') or '-'}\n"
            f"Wikidata: {row.get('wikidata_id') or '-'}\n"
            f"Commons: {row.get('commons_file') or '-'}\n"
            f"Licence: {row.get('license_name') or '-'}\n\n"
            "ROZHODNUTÍ\n"
            "============================\n"
            f"Hint: {row.get('review_decision_hint') or '-'}\n"
            f"Schválil: {row.get('approved_by') or '-'}\n"
            f"Schváleno: {row.get('approved_at') or '-'}\n\n"
            f"URL:\n{photo_url}"
        )

        txt = tk.Text(left, bg="#09050f", fg=TEXT, wrap="word", font=("Consolas", 10))
        txt.pack(fill="both", expand=True, padx=6, pady=6)
        txt.insert("1.0", info)
        txt.config(state="disabled")

        try:
            import urllib.request
            import io
            from PIL import Image, ImageTk

            with urllib.request.urlopen(str(photo_url), timeout=15) as response:
                image_data = response.read()

            img = Image.open(io.BytesIO(image_data))
            img.thumbnail((720, 660))

            tk_img = ImageTk.PhotoImage(img)
            popup.preview_image = tk_img

            img_label = tk.Label(right, image=tk_img, bg="#050308")
            img_label.pack(expand=True)

        except Exception as e:
            tk.Label(
                right,
                text=f"Náhled se nepodařilo načíst.\n\n{e}",
                bg="#050308",
                fg=RED,
                font=("Segoe UI", 12, "bold"),
                justify="center"
            ).pack(expand=True)

        btn_bar = tk.Frame(left, bg="#100918")
        btn_bar.pack(fill="x", padx=6, pady=6)

        tk.Button(
            btn_bar,
            text="🌐 Otevřít v prohlížeči",
            command=lambda: __import__("webbrowser").open(str(photo_url)),
            bg="#4c2c83",
            fg="white",
            font=("Segoe UI", 9, "bold")
        ).pack(fill="x")

    def photo_reject_selected_candidate(self):
        """
        V19.11 - PHOTO REVIEW reject.

        CO TO JE:
        - Zamítne vybraného kandidáta fotografie.

        K ČEMU TO JE:
        - Nekvalitní nebo nejistý kandidát se nebude mergeovat do public.players.
        """
        candidate_id = self.get_selected_photo_candidate_id()
        if not candidate_id:
            messagebox.showinfo("PHOTO REVIEW", "Nejdřív vyber řádek v tabulce PHOTO REVIEW - KANDIDÁTI.")
            return

        confirm = messagebox.askyesno(
            "ZAMÍTNOUT FOTO",
            f"Zamítnout kandidáta fotografie candidate_id={candidate_id}?"
        )
        if not confirm:
            return

        ok, err = db_execute("""
            UPDATE staging.stg_player_photo_candidates
            SET
                review_status = 'REJECTED',
                approved_by = 'panel_manual_review',
                approved_at = now(),
                updated_at = now()
            WHERE candidate_id = %s;
        """, (candidate_id,))

        if not ok:
            messagebox.showerror("PHOTO REVIEW", f"Zamítnutí se nepodařilo:\n{err}")
            return

        self.log(f"PHOTO REVIEW: candidate_id={candidate_id} -> REJECTED")
        self.load_media_dashboard()

    def photo_merge_approved_candidates(self):
        """
        V19.11 - PHOTO MERGE.

        CO TO JE:
        - Spustí DB funkci ops.fn_merge_approved_player_photos_v1().

        K ČEMU TO JE:
        - Propíše schválené kandidáty do public.players.photo_url,
          ale pouze tam, kde je public photo_url prázdné.
        """
        confirm = messagebox.askyesno(
            "MERGE FOTO",
            "Spustit merge všech APPROVED photo kandidátů do public.players.photo_url?"
        )
        if not confirm:
            return

        rows = db_query("""
            SELECT *
            FROM ops.fn_merge_approved_player_photos_v1();
        """)

        if not rows:
            messagebox.showinfo("MERGE FOTO", "Merge doběhl bez vrácených řádků.")
            self.load_media_dashboard()
            return

        if "CHYBA" in rows[0]:
            messagebox.showerror("MERGE FOTO", str(rows[0].get("CHYBA")))
            return

        merged = rows[0].get("merged_count", 0)
        self.log(f"PHOTO MERGE: merged_count={merged}")
        messagebox.showinfo("MERGE FOTO", f"Hotovo.\nmerged_count={merged}")
        self.load_media_dashboard()

    def load_media_dashboard(self):
        """
        V18.1 / V19.11 - MEDIA COMMAND CENTER + PHOTO REVIEW

        CO TO JE:
        - Přehled článků, zdrojů, refresh fronty, linkování a PHOTO vrstvy.

        K ČEMU TO JE:
        - MEDIA záložka je zároveň první ruční review centrum pro fotky hráčů.
        """

        overview_sql = """
        SELECT
            'articles'::text AS metric,
            COUNT(*)::bigint AS total_count,
            COUNT(*) FILTER (WHERE COALESCE(thumbnail_url, '') <> '')::bigint AS with_thumbnail,
            COUNT(*) FILTER (WHERE COALESCE(video_url, '') <> '' OR COALESCE(is_video, false) = true)::bigint AS with_video,
            MAX(created_at) AS newest_created_at,
            MAX(updated_at) AS newest_updated_at
        FROM public.articles;
        """

        sources_sql = """
        SELECT
            provider,
            sport_code,
            entity,
            source_name,
            source_type,
            http_status,
            found_urls,
            inserted_rows,
            updated_rows,
            skipped_rows,
            health_status,
            health_note,
            last_run_at,
            worker_script
        FROM ops.media_source_health_audit
        ORDER BY
            last_run_at DESC NULLS LAST,
            health_status,
            provider,
            sport_code
        LIMIT 200;
        """

        refresh_sql = """
        SELECT
            request_type,
            sport_code,
            content_source_id,
            entity_type,
            entity_id,
            priority,
            status,
            attempts,
            max_attempts,
            next_allowed_refresh_at,
            result_message,
            created_at,
            updated_at
        FROM ops.media_refresh_queue
        ORDER BY
            priority DESC NULLS LAST,
            created_at DESC
        LIMIT 200;
        """

        articles_sql = """
        SELECT
            id,
            content_source_id,
            title,
            url,
            is_video,
            published_at,
            created_at,
            updated_at,
            thumbnail_url
        FROM public.articles
        ORDER BY
            COALESCE(published_at, created_at, updated_at) DESC NULLS LAST
        LIMIT 150;
        """

        linking_sql = """
        SELECT
            'article_team_map'::text AS map_name,
            COUNT(*)::bigint AS linked_rows
        FROM public.article_team_map
        UNION ALL
        SELECT
            'article_league_map'::text AS map_name,
            COUNT(*)::bigint AS linked_rows
        FROM public.article_league_map
        UNION ALL
        SELECT
            'article_player_map'::text AS map_name,
            COUNT(*)::bigint AS linked_rows
        FROM public.article_player_map;
        """

        photo_dashboard_sql = """
        SELECT
            sport_code,
            total_players,
            players_with_photo,
            coverage_pct,
            pending_reviews,
            approved_reviews,
            rejected_reviews,
            photo_status
        FROM ops.v_photo_review_dashboard_v1
        ORDER BY
            coverage_pct ASC,
            sport_code;
        """

        photo_review_sql = """
        SELECT
            candidate_id,
            player_id,
            public_player_name,
            candidate_player_name,
            sport_code,
            provider,
            source_system,
            wikidata_id,
            commons_file,
            photo_url,
            confidence_score,
            review_status,
            can_approve,
            can_reject,
            public_photo_state,
            current_public_photo_url,
            confidence_level,
            approved_by,
            approved_at,
            created_at,
            updated_at
        FROM ops.v_photo_review_panel_v1
        ORDER BY
            CASE review_status
                WHEN 'PENDING' THEN 1
                WHEN 'APPROVED' THEN 2
                WHEN 'REJECTED' THEN 3
                ELSE 9
            END,
            created_at DESC
        LIMIT 300;
        """

        self.populate_tree(self.media_overview_tree, db_query(overview_sql))
        self.populate_tree(self.media_sources_tree, db_query(sources_sql))
        self.populate_tree(self.media_refresh_queue_tree, db_query(refresh_sql))
        self.populate_tree(self.media_articles_recent_tree, db_query(articles_sql))
        self.populate_tree(self.media_linking_tree, db_query(linking_sql))

        if hasattr(self, "photo_review_dashboard_tree"):
            self.populate_tree(self.photo_review_dashboard_tree, db_query(photo_dashboard_sql))

        if hasattr(self, "photo_review_panel_tree"):
            self.populate_tree(self.photo_review_panel_tree, db_query(photo_review_sql))


    def load_architecture_dashboard(self):
        """
        V18.1 - ARCHITECTURE COMMAND CENTER

        CO TO JE:
        - Přímé zobrazení 118_A až 118_E.
        """

        architecture_sql = """
        SELECT
            layer_order,
            layer_code,
            layer_name,
            what_is_it,
            purpose,
            input_source,
            output_target,
            master_objects,
            panel_usage,
            governance_status,
            updated_at
        FROM ops.v_master_architecture_map_v1
        ORDER BY layer_order;
        """

        layer_sql = """
        SELECT
            layer_order,
            layer_code,
            layer_name,
            readiness_percent,
            readiness_status,
            readiness_color,
            readiness_note,
            blocking_issue,
            next_action,
            panel_usage,
            source_type,
            updated_at
        FROM ops.v_layer_readiness_dashboard_v1
        ORDER BY layer_order;
        """

        harvest_sql = """
        SELECT *
        FROM ops.v_harvest_readiness_summary_v1;
        """

        sources_sql = """
        SELECT
            tab_order,
            tab_code,
            tab_name_cz,
            source_schema,
            source_object,
            source_type,
            governance_required_status,
            panel_usage,
            refresh_mode,
            priority_level,
            updated_at
        FROM ops.v18_master_panel_sources_v1
        ORDER BY tab_order;
        """

        self.populate_tree(self.architecture_map_tree, db_query(architecture_sql))
        self.populate_tree(self.layer_readiness_tree, db_query(layer_sql))
        self.populate_tree(self.harvest_engine_tree, db_query(harvest_sql))
        self.populate_tree(self.panel_sources_tree, db_query(sources_sql))

    def load_governance_dashboard(self):
        """
        V18.14 - GOVERNANCE COMMAND CENTER

        CO TO JE:
        - Živý governance přehled nad novými view 18_5_A až 18_5_C.
        - Zobrazuje celkové KPI, český detail oblastí, runtime audit a oficiální DB objekty.

        K ČEMU TO JE:
        - Panel ukáže, že Team / Player / League governance je pod kontrolou.
        - Player Provider Map zůstává viditelně PARTIAL, dokud nedořešíme HOLD případy.

        KDE TO UVIDÍME:
        - GOVERNANCE záložka.

        JAK SE TO VYUŽIJE:
        - Rychlá kontrola, jestli lze bezpečně pokračovat v harvestu a dalších providerech.
        - Podklad pro další OPS / AI doporučení.
        """

        summary_sql = """
        SELECT
            governance_items,
            governance_score_avg,
            confirmed_items,
            controlled_hold_items,
            partial_items,
            review_items,
            governance_status,
            refreshed_at
        FROM ops.v_governance_summary_kpi_v1;
        """

        detail_sql = """
        SELECT
            oblast,
            technicky_kod,
            stav_cz,
            skore,
            panel_status,
            vysvetleni,
            dukaz_v_db,
            dalsi_krok,
            posledni_kontrola
        FROM ops.v_governance_panel_detail_v1
        ORDER BY
            CASE panel_status
                WHEN 'READY' THEN 1
                WHEN 'CONTROLLED' THEN 2
                WHEN 'PARTIAL' THEN 3
                WHEN 'REVIEW' THEN 4
                ELSE 9
            END,
            oblast;
        """

        runtime_sql = """
        SELECT
            entity,
            current_state,
            state_reason,
            provider_map_confirmed,
            public_merge_confirmed,
            downstream_confirmed,
            last_run_group,
            db_evidence_summary,
            next_action,
            updated_at
        FROM ops.runtime_entity_audit
        WHERE provider = 'matchmatrix_governance'
        ORDER BY
            CASE current_state
                WHEN 'CONFIRMED' THEN 1
                WHEN 'READY' THEN 2
                WHEN 'CONTROLLED_HOLD' THEN 3
                WHEN 'PARTIAL' THEN 4
                ELSE 9
            END,
            entity;
        """

        object_registry_sql = """
        SELECT
            schema_name,
            object_name,
            object_type,
            governance_status,
            is_master,
            domain_area,
            owner_layer,
            migration_action,
            updated_at
        FROM ops.database_object_governance
        WHERE COALESCE(domain_area, '') = 'governance'
           OR object_name IN (
                'v_governance_dashboard_v1',
                'v_governance_summary_kpi_v1',
                'v_governance_panel_detail_v1'
           )
        ORDER BY
            CASE governance_status
                WHEN 'ACTIVE_MASTER' THEN 1
                WHEN 'ACTIVE_PANEL' THEN 2
                WHEN 'ACTIVE' THEN 3
                WHEN 'ACTIVE_REVIEW' THEN 4
                ELSE 9
            END,
            schema_name,
            object_name;
        """

        active_master_sql = """
        SELECT
            schema_name,
            object_name,
            object_type,
            governance_status,
            is_master,
            used_by,
            purpose,
            app_usage,
            depends_on,
            risk_if_wrong,
            migration_action,
            updated_at
        FROM ops.database_object_governance
        WHERE governance_status IN ('ACTIVE_MASTER', 'ACTIVE_PANEL')
          AND (
                COALESCE(domain_area, '') = 'governance'
                OR COALESCE(app_usage, '') ILIKE '%Panel%'
                OR object_name LIKE '%governance%'
          )
        ORDER BY
            governance_status,
            schema_name,
            object_name
        LIMIT 300;
        """

        self.populate_tree(self.governance_summary_tree, db_query(summary_sql))
        self.populate_tree(self.governance_master_tree, db_query(detail_sql))
        self.populate_tree(self.governance_review_tree, db_query(runtime_sql))
        self.populate_tree(self.governance_legacy_tree, db_query(object_registry_sql))
        self.populate_tree(self.governance_detail_tree, db_query(active_master_sql))

    def create_pc2_visual_operator_cards(self, parent):
        """
        V20.C.4 - VISUAL OPERATOR CARDS + RUN MONITOR

        CO TO JE:
        - Grafické karty v DENNÍ PRÁCI.

        K ČEMU TO JE:
        - Operátor má okamžitě vidět: hotovo / běží / čeká / chyba,
          aktuální běh, poslední výsledek a doporučený další krok.
        """
        self.pc2_visual_cards = {}

        def make_card(key, title, col, accent):
            card = tk.Frame(
                parent,
                bg="#100918",
                highlightbackground=accent,
                highlightthickness=1
            )
            card.grid(row=0, column=col, sticky="nsew", padx=4, pady=4)
            card.columnconfigure(0, weight=1)

            title_lbl = tk.Label(
                card,
                text=title,
                bg="#100918",
                fg=accent,
                font=("Segoe UI", 10, "bold"),
                anchor="w"
            )
            title_lbl.grid(row=0, column=0, sticky="ew", padx=10, pady=(8, 2))

            value_lbl = tk.Label(
                card,
                text="Načítám...",
                bg="#100918",
                fg="#ffffff",
                font=("Segoe UI", 18, "bold"),
                anchor="w"
            )
            value_lbl.grid(row=1, column=0, sticky="ew", padx=10, pady=(0, 0))

            sub_lbl = tk.Label(
                card,
                text="",
                bg="#100918",
                fg="#cdb7df",
                font=("Segoe UI", 8, "bold"),
                anchor="nw",
                justify="left",
                wraplength=360
            )
            sub_lbl.grid(row=2, column=0, sticky="ew", padx=10, pady=(0, 6))

            bar = tk.Canvas(card, height=16, bg="#100918", highlightthickness=0, bd=0)
            bar.grid(row=3, column=0, sticky="ew", padx=10, pady=(0, 9))

            self.pc2_visual_cards[key] = {
                "frame": card,
                "title": title_lbl,
                "value": value_lbl,
                "sub": sub_lbl,
                "bar": bar,
                "accent": accent,
                "pct": 0,
            }
            bar.bind("<Configure>", lambda event, k=key: self.redraw_pc2_visual_bar(k))

        make_card("day", "🟢 DNEŠNÍ POSTUP", 0, GREEN)
        make_card("current", "▶ AKTUÁLNÍ / DALŠÍ BĚH", 1, PURPLE)
        make_card("result", "✅ POSLEDNÍ VÝSLEDEK", 2, GREEN)
        make_card("error", "🔴 CHYBY / STOP", 3, RED)

    def redraw_pc2_visual_bar(self, key):
        try:
            info = self.pc2_visual_cards.get(key)
            if not info:
                return
            canvas = info.get("bar")
            pct = max(0, min(100, int(float(info.get("pct") or 0))))
            accent = info.get("accent", PURPLE)
            canvas.delete("all")
            w = max(20, canvas.winfo_width())
            h = max(10, canvas.winfo_height())
            canvas.create_rectangle(0, 3, w, h - 3, fill="#2b2038", outline="#2b2038")
            canvas.create_rectangle(0, 3, int(w * pct / 100), h - 3, fill=accent, outline=accent)
            canvas.create_text(w - 4, h / 2, text=f"{pct}%", fill="#ffffff", font=("Segoe UI", 8, "bold"), anchor="e")
        except Exception:
            pass

    def update_pc2_visual_operator_cards(self, rows):
        """
        V20.C.4 - OPERATOR MONITOR BINDING

        CO TO JE:
        - Grafické karty v DENNÍ PRÁCI se primárně plní z ops.harvest_run_monitor view.
        - PC2 fronta zůstává jako fallback a detailní tabulka.

        K ČEMU TO JE:
        - Operátor vidí skutečný průběh běhu, výsledek a STOP chyby.
        - Tabulky jsou podpůrný detail, grafické karty jsou hlavní akční informace.

        ZDROJE:
        - ops.v_operator_today_progress_v1
        - ops.v_operator_current_run_v1
        - ops.v_operator_last_result_v1
        - ops.v_operator_stop_errors_v1
        """

        def first_ok(sql):
            try:
                result = db_query(sql)
                if result and isinstance(result, list) and "CHYBA" not in result[0]:
                    return result[0]
            except Exception:
                pass
            return None

        def as_int(value, default=0):
            try:
                if value is None:
                    return default
                return int(float(value))
            except Exception:
                return default

        def as_pct(value, default=0):
            try:
                if value is None:
                    return default
                return max(0, min(100, int(round(float(value)))))
            except Exception:
                return default

        def color_from_light(light, fallback=PURPLE):
            text = str(light or "").upper()
            if text == "GREEN":
                return GREEN
            if text == "YELLOW":
                return YELLOW
            if text == "RED":
                return RED
            if text == "BLACK":
                return "#555555"
            return fallback

        try:
            today = first_ok("""
                SELECT *
                FROM ops.v_operator_today_progress_v1;
            """)

            current = first_ok("""
                SELECT *
                FROM ops.v_operator_current_run_v1;
            """)

            last_result = first_ok("""
                SELECT *
                FROM ops.v_operator_last_result_v1;
            """)

            stop_error = first_ok("""
                SELECT *
                FROM ops.v_operator_stop_errors_v1;
            """)

            # 1) DNEŠNÍ POSTUP
            if today:
                day_pct = as_pct(today.get("day_progress_pct"))
                done = as_int(today.get("done_runs"))
                running = as_int(today.get("running_runs"))
                waiting = as_int(today.get("waiting_runs"))
                errors = as_int(today.get("error_runs"))
                blocked = as_int(today.get("blocked_runs"))
                total = as_int(today.get("total_runs"))

                self.set_pc2_visual_card(
                    "day",
                    f"{day_pct} %",
                    (
                        f"Celkem: {total}   Hotovo: {done}   Běží: {running}\n"
                        f"Čeká: {waiting}   Chyba: {errors}   Blokováno: {blocked}\n"
                        f"{today.get('operator_message') or ''}"
                    ),
                    day_pct,
                    color_from_light(today.get("traffic_light"), GREEN)
                )
            else:
                self.set_pc2_visual_card(
                    "day",
                    "0 %",
                    "Monitor dnes nemá žádný běh. Spusť akci nebo vytvoř první monitor záznam.",
                    0,
                    YELLOW
                )

            # 2) AKTUÁLNÍ / DALŠÍ BĚH
            if current:
                pct = as_pct(current.get("progress_pct"))
                sport = current.get("sport_code") or "-"
                entity = current.get("entity_type") or "-"
                layer = current.get("target_layer") or "-"
                status = current.get("run_status_cz") or cz_status(current.get("run_status"))
                processed = as_int(current.get("processed_count"))
                total_count = as_int(current.get("total_count"))
                inserted = as_int(current.get("inserted_count"))
                updated = as_int(current.get("updated_count"))
                errors = as_int(current.get("error_count"))
                eta = current.get("eta_seconds")
                eta_text = "-" if eta is None else f"{as_int(eta)} s"

                self.set_pc2_visual_card(
                    "current",
                    f"{sport} / {layer}",
                    (
                        f"{status} | {entity} | {pct} %\n"
                        f"Zpracováno: {processed} / {total_count}   ETA: {eta_text}\n"
                        f"Nové: {inserted}   Aktualizováno: {updated}   Chyby: {errors}\n"
                        f"{current.get('operator_message') or ''}"
                    ),
                    pct,
                    color_from_light(current.get("traffic_light"), PURPLE)
                )
            else:
                # Fallback z PC2 fronty, když aktuálně nic neběží ani nečeká v monitoru.
                queue_rows = [r for r in (rows or []) if "CHYBA" not in r]
                next_ready = None
                for wanted in ("READY_TO_RUN", "READY", "PENDING"):
                    found = [r for r in queue_rows if str(r.get("run_status") or "").upper() == wanted]
                    if found:
                        next_ready = found[0]
                        break

                if next_ready:
                    self.set_pc2_visual_card(
                        "current",
                        f"{next_ready.get('sport_code') or '-'} / {next_ready.get('target_layer') or '-'}",
                        (
                            f"Další připravená akce\n"
                            f"Priorita: {next_ready.get('priority_score') or '-'}\n"
                            f"{str(next_ready.get('command_title') or '')[:120]}"
                        ),
                        0,
                        PURPLE
                    )
                else:
                    self.set_pc2_visual_card(
                        "current",
                        "Žádná akce",
                        "Aktuálně nic neběží a monitor nemá připravený běh.",
                        0,
                        YELLOW
                    )

            # 3) POSLEDNÍ VÝSLEDEK
            if last_result:
                pct = as_pct(last_result.get("result_pct"))
                sport = last_result.get("sport_code") or "-"
                entity = last_result.get("entity_type") or "-"
                status = last_result.get("run_status_cz") or cz_status(last_result.get("run_status"))
                inserted = as_int(last_result.get("inserted_count"))
                updated = as_int(last_result.get("updated_count"))
                errors = as_int(last_result.get("error_count"))

                self.set_pc2_visual_card(
                    "result",
                    f"{pct} % OK",
                    (
                        f"{sport} / {entity} | {status}\n"
                        f"Nové: {inserted}   Aktualizováno: {updated}   Chyby: {errors}\n"
                        f"{last_result.get('operator_message') or ''}\n"
                        f"{last_result.get('operator_recommendation') or ''}"
                    ),
                    pct,
                    color_from_light(last_result.get("traffic_light"), GREEN)
                )
            else:
                self.set_pc2_visual_card(
                    "result",
                    "Zatím nic",
                    "Monitor zatím nemá dokončený běh.",
                    0,
                    YELLOW
                )

            # 4) CHYBY / STOP
            if stop_error:
                sport = stop_error.get("sport_code") or "-"
                entity = stop_error.get("entity_type") or "-"
                code = stop_error.get("last_error_code") or "ERROR"
                msg = stop_error.get("last_error_message") or "Bez detailu chyby."
                fix = stop_error.get("recommended_fix_cz") or "Otevři log a rozhodni další krok."

                self.set_pc2_visual_card(
                    "error",
                    "1 STOP",
                    (
                        f"{sport} / {entity}\n"
                        f"{code}: {str(msg)[:95]}\n"
                        f"Doporučení: {fix}"
                    ),
                    100,
                    RED
                )
            else:
                self.set_pc2_visual_card(
                    "error",
                    "0 STOP",
                    "Bez aktivních STOP chyb v monitoru. Můžeš pokračovat další akcí.",
                    100,
                    GREEN
                )

        except Exception as exc:
            try:
                self.set_pc2_visual_card("error", "Chyba panelu", str(exc)[:160], 100, RED)
            except Exception:
                pass

    def set_pc2_visual_card(self, key, value, sub, pct, accent):
        try:
            info = self.pc2_visual_cards.get(key)
            if not info:
                return
            info["value"].config(text=str(value))
            info["sub"].config(text=str(sub))
            info["pct"] = max(0, min(100, int(float(pct or 0))))
            info["accent"] = accent
            info["frame"].config(highlightbackground=accent)
            info["title"].config(fg=accent)
            self.redraw_pc2_visual_bar(key)
        except Exception:
            pass

    def load_pc2_command_center(self):
        """
        V18.15 - PC2 COMMAND CENTER

        CO TO JE:
        - Načte PC2 KPI, další spustitelný příkaz, celou frontu a roadmapu.

        K ČEMU TO JE:
        - Panel už neukazuje jen plán, ale konkrétní příkaz ke spuštění z DB.
        """

        button_sql = """
        SELECT
            q.id AS command_id,
            q.command_title,
            q.sport_code,
            q.sport_name,
            q.target_layer,
            q.execution_bucket,
            q.priority_score,
            COALESCE(pc.effective_status, q.run_status) AS run_status,
            q.safety_mode,
            q.panel_action_enabled AS button_enabled,
            q.safety_mode AS safety_note_cs,
            q.action_description,
            q.purpose_description,
            q.target_tables,
            q.panel_usage,
            q.expected_result,
            q.command_text,
            q.last_result,
            pc.classification_reason,
            pc.operator_recommendation,
            pc.recommendation_priority,
            pc.button_code,
            pc.button_label_cz,
            pc.button_color,
            pc.button_help_cz,
            pc.detected_provider,
            pc.detected_entity,
            pc.provider_problem_cz,
            pc.provider_next_step_cz,
            pc.suggested_provider,
            pc.provider_context_status,
            pc.provider_recommendation_short_cz,
            q.updated_at
        FROM ops.v_pc2_run_command_queue_v2 q
        LEFT JOIN ops.v_operator_provider_context_v1 pc
            ON pc.id = q.id
        ORDER BY
            CASE
                WHEN COALESCE(pc.effective_status, q.run_status) IN ('FAILED','ERROR') THEN 1
                WHEN COALESCE(pc.effective_status, q.run_status) = 'READY_TO_RUN' THEN 2
                WHEN COALESCE(pc.effective_status, q.run_status) = 'RUNNING' THEN 3
                WHEN COALESCE(pc.effective_status, q.run_status) = 'DONE' THEN 4
                WHEN COALESCE(pc.effective_status, q.run_status) = 'BLOCKED' THEN 5
                ELSE 9
            END,
            q.priority_score,
            q.sport_code,
            q.target_layer;
        """

        kpi_sql = """
        SELECT
            kpi_code,
            kpi_name_cs,
            kpi_value,
            kpi_unit,
            kpi_status,
            kpi_note_cs
        FROM ops.v_pc2_command_center_kpi_cards_v1;
        """

        queue_sql = """
        SELECT
            q.id,
            q.sport_code,
            q.sport_name,
            q.target_layer,
            q.execution_bucket,
            q.priority_score,
            q.command_title,
            q.run_status AS db_run_status,
            COALESCE(pc.effective_status, q.run_status) AS effective_status,
            pc.classification_reason,
            pc.operator_recommendation,
            pc.button_label_cz,
            pc.button_color,
            pc.detected_provider,
            pc.detected_entity,
            pc.provider_problem_cz,
            pc.provider_next_step_cz,
            pc.suggested_provider,
            pc.provider_context_status,
            pc.provider_recommendation_short_cz,
            q.safety_mode,
            q.panel_action_enabled,
            q.action_description,
            q.purpose_description,
            q.target_tables,
            q.panel_usage,
            q.expected_result,
            q.command_text,
            q.last_started_at,
            q.last_finished_at,
            q.last_result,
            q.updated_at
        FROM ops.v_pc2_run_command_queue_v2 q
        LEFT JOIN ops.v_operator_provider_context_v1 pc
            ON pc.id = q.id
        ORDER BY
            CASE
                WHEN COALESCE(pc.effective_status, q.run_status) IN ('FAILED','ERROR') THEN 1
                WHEN COALESCE(pc.effective_status, q.run_status) = 'READY_TO_RUN' THEN 2
                WHEN COALESCE(pc.effective_status, q.run_status) = 'RUNNING' THEN 3
                WHEN COALESCE(pc.effective_status, q.run_status) = 'DONE' THEN 4
                ELSE 9
            END,
            q.priority_score,
            q.sport_code,
            q.target_layer;
        """

        roadmap_sql = """
        SELECT
            sport_code,
            sport_name,
            next_harvest_layer,
            roadmap_bucket,
            core_pct,
            people_pct,
            media_pct,
            odds_pct,
            provider_gap_total,
            photo_license_review_count,
            photo_wait_for_paid_count,
            pc2_next_action_cs
        FROM ops.v_pc2_command_center_dashboard_v1
        ORDER BY
            pc2_execution_order,
            harvest_priority,
            sport_code;
        """

        actions_sql = """
        SELECT
            command_id,
            sport_code,
            target_layer,
            run_status,
            execution_readiness_status,
            planner_jobs,
            pending_jobs,
            done_jobs,
            failed_jobs,
            can_run,
            can_continue,
            can_retry,
            can_set_ready,
            can_set_done,
            can_set_blocked,
            can_set_failed,
            can_test
        FROM ops.v_pc2_panel_action_matrix_v1
        ORDER BY command_id;
        """

        # V19.10: PC2 načítání bez zamrzání.
        # - button_sql se nevolá dvakrát,
        # - náročnější spodní tabulky se načtou až po vykreslení hlavní části,
        # - tím zůstane DENNÍ PRÁCE použitelná hned po kliknutí.
        button_rows = db_query(button_sql)
        self.populate_pc2_action_cards(self.pc2_button_tree, button_rows)
        self.update_pc2_visual_operator_cards(button_rows)
        self.populate_tree(self.pc2_queue_tree, db_query(queue_sql))

        # V20.1.P4.FIX - po refreshi automaticky aktualizuj pravou doporučenou akci.
        # CO TO JE:
        # - Treeview někdy po OBNOVIT PC2 zůstane vizuálně vybraný, ale neproběhne
        #   událost <<TreeviewSelect>>.
        # K ČEMU TO JE:
        # - Pravý panel už nezůstane na starém tlačítku „DETAIL“.
        # - U VB / RESEARCH_REQUIRED se hned zobrazí „🔎 HLEDAT PROVIDERA“.
        try:
            selected_command_id = self.get_selected_pc2_command_id()
            if not selected_command_id and hasattr(self, "pc2_button_tree"):
                first_items = self.pc2_button_tree.get_children()
                if first_items:
                    self.pc2_button_tree.selection_set(first_items[0])
                    self.pc2_button_tree.focus(first_items[0])
                    selected_command_id = self.get_selected_pc2_command_id_from_tree(self.pc2_button_tree)
            if selected_command_id:
                self.update_operator_recommendation_for_selection(selected_command_id)
        except Exception:
            pass

        # V20.C.2: roadmapa, KPI a action matrix už nejsou hlavní obsah DENNÍ PRÁCE.
        # Zůstávají dostupné v DB a detailních záložkách, ale zde neruší operátorský režim.

        # Aktualizace textu hlavního PC2 tlačítka podle DB.
        try:
            rows = button_rows
            ready_rows = [r for r in rows if "CHYBA" not in r and str(r.get("run_status") or "").upper() == "READY_TO_RUN"] if rows else []
            if ready_rows:
                row = ready_rows[0]
                title = row.get("command_title") or "SPUSTIT DALŠÍ PC2 AKCI"
                enabled = bool(row.get("button_enabled", True))
                self.pc2_run_button.config(
                    text=f"▶ {title}",
                    state=("normal" if enabled else "disabled")
                )
                if hasattr(self, "global_pc2_run_button"):
                    self.global_pc2_run_button.config(
                        text=f"▶ {title}",
                        state=("normal" if enabled else "disabled")
                    )
            else:
                self.pc2_run_button.config(text="▶ ŽÁDNÁ PC2 AKCE", state="disabled")
                if hasattr(self, "global_pc2_run_button"):
                    self.global_pc2_run_button.config(text="▶ ŽÁDNÁ PC2 AKCE", state="disabled")
        except Exception:
            pass


    def populate_pc2_action_cards(self, tree, rows):
        """
        V20.1.P2.B - PC2 ACTION CARDS + PROVIDER CONTEXT

        CO TO JE:
        - Hlavní tabulka DENNÍ PRÁCE ukazuje akci, skutečný stav a doporučené tlačítko.

        K ČEMU TO JE:
        - Operátor nemusí číst dlouhý log. Uvidí například:
          VB / FAILED / 🔌 OTEVŘÍT PROVIDER MATRIX.

        KDE TO UVIDÍME:
        - DENNÍ PRÁCE -> CO SPUSTIT TEĎ.

        JAK SE TO VYUŽIJE:
        - Klik na řádek nastaví pravé dynamické tlačítko podle ops.v_operator_action_buttons_v1.
        """
        try:
            tree.delete(*tree.get_children())
            tree["columns"] = (
                "command_id",
                "action_card",
                "status",
                "provider_recommendation",
                "priority",
                "sport",
                "layer",
            )

            tree.heading("command_id", text="")
            tree.heading("action_card", text="AKCE")
            tree.heading("status", text="STAV")
            tree.heading("provider_recommendation", text="PROVIDER / DOPORUČENÍ")
            tree.heading("priority", text="PRIORITA")
            tree.heading("sport", text="SPORT")
            tree.heading("layer", text="VRSTVA")

            tree.column("command_id", width=1, minwidth=1, stretch=False, anchor="w")
            tree.column("action_card", width=610, minwidth=420, stretch=True, anchor="w")
            tree.column("status", width=115, minwidth=95, stretch=False, anchor="center")
            tree.column("provider_recommendation", width=300, minwidth=230, stretch=False, anchor="w")
            tree.column("priority", width=80, minwidth=65, stretch=False, anchor="center")
            tree.column("sport", width=120, minwidth=95, stretch=False, anchor="w")
            tree.column("layer", width=95, minwidth=80, stretch=False, anchor="center")

            if not rows:
                tree.insert("", "end", values=("", "ŽÁDNÁ PC2 AKCE", "", "", "", "", ""), tags=("purple",))
                return

            for row in rows:
                if "CHYBA" in row:
                    tree.insert("", "end", values=("", str(row.get("CHYBA")), "CHYBA", "", "", "", ""), tags=("red",))
                    continue

                command_id = row.get("command_id") or row.get("id")
                title = str(row.get("command_title") or "PC2 akce").strip()
                sport_code = str(row.get("sport_code") or "").strip()
                sport_name = str(row.get("sport_name") or sport_code).strip()
                layer = str(row.get("target_layer") or "").strip()
                status = str(row.get("effective_status") or row.get("run_status") or "").strip()
                priority = row.get("priority_score") or ""
                button_label = str(
                    row.get("provider_recommendation_short_cz")
                    or row.get("button_label_cz")
                    or row.get("operator_recommendation")
                    or "🔎 DETAIL"
                ).strip()
                button_color = str(row.get("button_color") or "").upper()

                icon = "▶"
                status_up = status.upper()
                if status_up == "DONE":
                    icon = "✔"
                elif status_up in ("FAILED", "ERROR"):
                    icon = "⚠"
                elif status_up == "BLOCKED":
                    icon = "⛔"
                elif status_up == "RUNNING":
                    icon = "●"

                action_card = f"{icon} {title.upper()}"

                tag = "purple"
                if button_color == "PURPLE":
                    tag = "purple"
                elif status_up == "READY_TO_RUN":
                    tag = "green"
                elif status_up == "DONE":
                    tag = "empty_ok"
                elif status_up in ("FAILED", "ERROR"):
                    tag = "red"
                elif status_up in ("BLOCKED", "DISABLED"):
                    tag = "yellow"

                item_id = tree.insert(
                    "",
                    "end",
                    values=(
                        command_id,
                        action_card,
                        cz_status(status),
                        button_label,
                        priority,
                        sport_name,
                        layer,
                    ),
                    tags=(tag,),
                )
                tree.set(item_id, "command_id", command_id)
        except Exception as exc:
            try:
                tree.delete(*tree.get_children())
                tree["columns"] = ("error",)
                tree.heading("error", text="CHYBA")
                tree.column("error", width=900, stretch=True)
                tree.insert("", "end", values=(str(exc),), tags=("red",))
            except Exception:
                pass

    def on_pc2_action_card_select(self, event=None):
        """
        V19.11 - bezpečná synchronizace výběru PC2 řádků.

        CO TO JE:
        - Klik na kartu / řádek aktualizuje pravý akční panel.
        - Ochrana proti rekurzivnímu TreeviewSelect loopu, který na Windows mohl způsobit "Neodpovídá".
        """
        if getattr(self, "pc2_select_syncing", False):
            return

        self.pc2_select_syncing = True
        try:
            source_tree = event.widget if event is not None and hasattr(event, "widget") else None

            command_id = None
            if source_tree is getattr(self, "pc2_button_tree", None):
                command_id = self.get_selected_pc2_command_id_from_tree(self.pc2_button_tree)
            elif source_tree is getattr(self, "pc2_queue_tree", None):
                command_id = self.get_selected_pc2_command_id_from_tree(self.pc2_queue_tree)
            else:
                command_id = self.get_selected_pc2_command_id_from_tree(getattr(self, "pc2_button_tree", None))
                if not command_id:
                    command_id = self.get_selected_pc2_command_id_from_tree(getattr(self, "pc2_queue_tree", None))

            if not command_id:
                return

            # Synchronizuj druhou tabulku pouze pokud přišel klik z akčních karet.
            # Když událost přišla z detailní fronty, znovu nenastavujeme selection_set na stejném Treeview.
            if source_tree is getattr(self, "pc2_button_tree", None):
                for item_id in self.pc2_queue_tree.get_children():
                    values = self.pc2_queue_tree.item(item_id).get("values", [])
                    if values and str(values[0]) == str(command_id):
                        current = self.pc2_queue_tree.selection()
                        if not current or current[0] != item_id:
                            self.pc2_queue_tree.selection_set(item_id)
                            self.pc2_queue_tree.focus(item_id)
                            self.pc2_queue_tree.see(item_id)
                        break

            row = self.get_pc2_command_row(command_id)
            if row and hasattr(self, "pc2_selected_action_label"):
                title = str(row.get("command_title") or "-")
                if len(title) > 90:
                    title = title[:87] + "…"
                self.pc2_selected_action_label.config(
                    text=(
                        f"Vybráno: {row.get('sport_code') or '-'} / {row.get('target_layer') or '-'}\n"
                        f"Stav: {cz_status(row.get('run_status'))}\n"
                        f"Akce: {title}"
                    )
                )
                self.update_operator_recommendation_for_selection(command_id)
        except Exception:
            pass
        finally:
            self.pc2_select_syncing = False

    def get_selected_pc2_command_id_from_tree(self, tree):
        try:
            if not tree:
                return None

            selected = tree.selection()
            if not selected:
                return None

            item = tree.item(selected[0])
            values = list(item.get("values", []))
            columns = list(tree["columns"])

            if not values:
                return None

            for idx, col in enumerate(columns):
                if str(col).strip().lower() == "id" and idx < len(values):
                    return int(values[idx])

            return int(values[0])

        except Exception:
            return None

    def get_selected_pc2_command_id(self):
        # V18.20: nejdřív zkus výběr v akčních kartách, potom hlavní spouštěcí frontu.
        command_id = self.get_selected_pc2_command_id_from_tree(getattr(self, "pc2_button_tree", None))
        if command_id:
            return command_id

        return self.get_selected_pc2_command_id_from_tree(self.pc2_queue_tree)

    def get_pc2_command_row(self, command_id=None):
        if command_id:
            rows = db_query(f"""
                SELECT
                    q.id,
                    q.command_title,
                    q.command_text,
                    q.sport_code,
                    q.target_layer,
                    COALESCE(pc.effective_status, q.run_status) AS run_status,
                    q.safety_mode,
                    q.action_description,
                    q.purpose_description,
                    q.target_tables,
                    q.panel_usage,
                    q.expected_result,
                    q.last_started_at,
                    q.last_finished_at,
                    q.last_result,
                    ab.classification_reason,
                    ab.operator_recommendation,
                    ab.recommendation_priority,
                    ab.button_code,
                    ab.button_label_cz,
                    ab.button_color,
                    ab.button_help_cz
                FROM ops.pc2_run_command_queue q
                LEFT JOIN ops.v_operator_action_buttons_v1 ab
                    ON ab.id = q.id
                LEFT JOIN ops.v_operator_provider_context_v1 pc
                    ON pc.id = q.id    
                WHERE q.id = {int(command_id)}
                LIMIT 1;
            """)
        else:
            rows = db_query("""
                SELECT
                    q.id,
                    q.command_title,
                    q.command_text,
                    q.sport_code,
                    q.target_layer,
                    q.run_status,
                    q.safety_mode,
                    q.action_description,
                    q.purpose_description,
                    q.target_tables,
                    q.panel_usage,
                    q.expected_result,
                    q.last_started_at,
                    q.last_finished_at,
                    q.last_result
                FROM ops.v_pc2_run_command_queue_v2 q
                WHERE q.run_status = 'READY_TO_RUN'
                  AND q.panel_action_enabled = true
                ORDER BY
                    q.priority_score,
                    q.sport_code,
                    q.target_layer
                LIMIT 1;
            """)

        if rows and "CHYBA" not in rows[0]:
            return rows[0]
        return None

    def get_operator_action_button_row(self, command_id):
        """
        V20.1.P - OPERATOR ACTION BUTTON LOADER

        CO TO JE:
        - Načte doporučené tlačítko pro vybraný PC2 command.

        K ČEMU TO JE:
        - Pravý panel ví, zda má nabídnout POKRAČOVAT, OTEVŘÍT LOG nebo OTEVŘÍT PROVIDER MATRIX.
        """
        try:
            rows = db_query(f"""
                SELECT
                    id,
                    sport_code,
                    sport_name,
                    target_layer,
                    effective_status,
                    classification_reason,
                    operator_recommendation,
                    recommendation_priority,
                    button_code,
                    button_label_cz,
                    button_enabled,
                    button_color,
                    button_help_cz,
                    detected_provider,
                    detected_entity,
                    provider_problem_cz,
                    provider_next_step_cz,
                    suggested_provider,
                    provider_context_status,
                    provider_recommendation_short_cz
                FROM ops.v_operator_provider_context_v1
                WHERE id = {int(command_id)}
                LIMIT 1;
            """)
            if rows and "CHYBA" not in rows[0]:
                return rows[0]
        except Exception:
            pass
        return None

    def operator_button_color_to_hex(self, color_name):
        text = str(color_name or "").upper()
        if text == "GREEN":
            return "#0f6a42"
        if text == "YELLOW":
            return "#92400e"
        if text == "RED":
            return "#7f1d1d"
        if text == "PURPLE":
            return "#6d45b8"
        return "#4c2c83"

    def update_operator_recommendation_for_selection(self, command_id=None):
        """
        V20.1.P - UPDATE RIGHT RECOMMENDED BUTTON

        CO TO JE:
        - Aktualizuje dynamické tlačítko v pravé liště podle vybraného řádku.

        K ČEMU TO JE:
        - U VB/FAILED nabídne 🔌 OTEVŘÍT PROVIDER MATRIX.
        - U DONE nabídne ▶ POKRAČOVAT.
        """
        try:
            if command_id is None:
                command_id = self.get_selected_pc2_command_id()
            row = self.get_operator_action_button_row(command_id)
            if not row:
                if hasattr(self, "global_operator_action_button"):
                    self.global_operator_action_button.config(text="🔎 DETAIL", bg="#4c2c83", state="disabled")
                if hasattr(self, "global_operator_action_help"):
                    self.global_operator_action_help.config(text="Doporučení není dostupné. Otevři detail řádku.")
                return

            color = self.operator_button_color_to_hex(row.get("button_color"))
            enabled = bool(row.get("button_enabled", True))
            provider_line = row.get("provider_recommendation_short_cz") or row.get("button_label_cz") or row.get("operator_recommendation") or "🔎 DETAIL"
            help_text = row.get("provider_next_step_cz") or row.get("button_help_cz") or row.get("operator_recommendation") or "Otevři detail řádku."
            reason = row.get("provider_problem_cz") or row.get("classification_reason") or "-"

            # V20.1.P4.FIX - research provider má vlastní jasné tlačítko.
            # CO TO JE:
            # - V tabulce zůstává kontext „api_volleyball → HLEDAT PEOPLE PROVIDERA“.
            # - Vpravo je samotné akční tlačítko „🔎 HLEDAT PROVIDERA“.
            # K ČEMU TO JE:
            # - Operátor hned pozná, že klik zakládá discovery úkol.
            if str(row.get("provider_context_status") or "").upper() == "RESEARCH_REQUIRED":
                action_button_text = "🔎 HLEDAT PROVIDERA"
                color = "#6d45b8"
                enabled = True
                help_block = (
                    f"{row.get('sport_code') or '-'} / {row.get('target_layer') or '-'}\n"
                    f"{provider_line}\n"
                    f"{reason}\n"
                    f"{help_text}"
                )
            else:
                action_button_text = str(row.get("button_label_cz") or provider_line or "🔎 DETAIL")
                help_block = f"{row.get('sport_code') or '-'} / {row.get('target_layer') or '-'}\n{reason}\n{help_text}"

            if hasattr(self, "global_operator_action_button"):
                self.global_operator_action_button.config(
                    text=action_button_text,
                    bg=color,
                    state=("normal" if enabled else "disabled")
                )
            if hasattr(self, "global_operator_action_help"):
                self.global_operator_action_help.config(text=help_block)
        except Exception as exc:
            try:
                self.global_operator_action_help.config(text=f"Chyba doporučení: {exc}")
            except Exception:
                pass

    def run_operator_recommended_action(self):
        """
        V20.1.P - EXECUTE RECOMMENDED PANEL ACTION

        CO TO JE:
        - Provede panelovou akci podle button_code z ops.v_operator_action_buttons_v1.

        K ČEMU TO JE:
        - Z doporučení se stává skutečné tlačítko v DENNÍ PRÁCI.
        """
        command_id = self.get_selected_pc2_command_id()
        if not command_id:
            messagebox.showinfo("DOPORUČENÁ AKCE", "Nejdřív vyber řádek v DENNÍ PRÁCI.")
            return

        rec = self.get_operator_action_button_row(command_id)
        if not rec:
            self.open_pc2_command_detail(None)
            return

        code = str(rec.get("button_code") or "OPEN_DETAIL").upper()
        sport = rec.get("sport_code") or "-"
        layer = rec.get("target_layer") or "-"

        if code == "CONTINUE_NEXT":
            self.pc2_continue_selected_command()
            return

        # V20.1.P4 - PROVIDER DISCOVERY ACTION
        # CO TO JE:
        # - Pokud operátor vybere řádek typu VB / PEOPLE / MISSING_PROVIDER,
        #   tlačítko nezůstane jen u otevření Provider Matrix.
        # - Zavolá DB funkci, která založí auditovaný discovery úkol.
        # K ČEMU TO JE:
        # - Panel začne aktivně vytvářet úkol „najít nového providera“,
        #   ne jen zobrazovat textové doporučení.
        if (
            code == "OPEN_PROVIDER_MATRIX"
            and str(rec.get("provider_context_status") or "").upper() == "RESEARCH_REQUIRED"
        ):
            self.create_provider_discovery_action_from_selected(command_id, rec)
            return

        if code == "OPEN_PROVIDER_MATRIX":
            self.show_tab("PROVIDER MATRIX")
            messagebox.showinfo(
                "PROVIDER MATRIX",
                f"Otevřena Provider Matrix.\n\nŘeš: {sport} / {layer}\nDůvod: {rec.get('classification_reason') or '-'}"
            )
            return

        if code == "OPEN_ROUTING_AUDIT":
            self.show_tab("PROVIDERS")
            messagebox.showinfo(
                "ROUTING AUDIT",
                f"Otevřena záložka PROVIDEŘI.\n\nŘeš routing pro: {sport} / {layer}"
            )
            return

        if code in ("OPEN_LOG", "OPEN_DETAIL_ANALYSIS", "OPEN_DETAIL"):
            self.open_pc2_command_detail(None)
            return

        self.open_pc2_command_detail(None)

    def create_provider_discovery_action_from_selected(self, command_id, rec=None):
        """
        V20.1.P4 - CREATE PROVIDER DISCOVERY ACTION

        CO TO JE:
        - Panelová akce pro tlačítko „HLEDAT PEOPLE PROVIDERA“.

        K ČEMU TO JE:
        - Zavolá SQL funkci ops.fn_operator_create_provider_discovery_action_v1.
        - Vytvoří nebo znovu najde otevřený discovery úkol pro sport/entity.

        KDE TO UVIDÍME:
        - DENNÍ PRÁCE -> pravý panel -> dynamické tlačítko.
        - DB view: ops.v_operator_provider_discovery_actions_v1.

        JAK SE TO VYUŽIJE:
        - VB / PEOPLE / players -> api_volleyball nepodporuje players.
        - Kliknutí vytvoří úkol „Najít specializovaného PEOPLE providera“.
        """
        try:
            rows = db_query(f"""
                SELECT *
                FROM ops.fn_operator_create_provider_discovery_action_v1(
                    {int(command_id)},
                    'PANEL_OPERATOR'
                );
            """)

            if not rows or "CHYBA" in rows[0]:
                err = rows[0].get("CHYBA") if rows else "DB nevrátila výsledek."
                messagebox.showerror(
                    "HLEDAT PROVIDERA",
                    f"Discovery úkol se nepodařilo vytvořit.\n\n{err}"
                )
                return

            row = rows[0]
            msg = row.get("message") or "Discovery akce dokončena."
            status = row.get("action_status") or "-"
            sport = row.get("sport_code") or (rec.get("sport_code") if rec else "-")
            entity = row.get("entity_type") or (rec.get("detected_entity") if rec else "-")
            provider = row.get("current_provider") or (rec.get("detected_provider") if rec else "-")

            self.log(f"PROVIDER DISCOVERY: command_id={command_id} | {sport}/{entity} | provider={provider} | status={status} | {msg}")

            # Po úspěchu otevřeme Provider Matrix, aby operátor hned viděl kontext providerů.
            self.show_tab("PROVIDER MATRIX")
            try:
                self.load_provider_matrix_dashboard()
            except Exception:
                pass

            messagebox.showinfo(
                "HLEDAT PROVIDERA",
                f"{msg}\n\nSport: {sport}\nEntita: {entity}\nAktuální provider: {provider}\nStav: {status}\n\nOtevřena Provider Matrix."
            )

        except Exception as exc:
            messagebox.showerror(
                "HLEDAT PROVIDERA",
                f"Chyba při vytváření discovery úkolu:\n\n{exc}"
            )

    def run_pc2_next_command(self):
        row = self.get_pc2_command_row()
        if not row:
            messagebox.showinfo("PC2 AKCE", "Není dostupná žádná READY_TO_RUN PC2 akce.")
            return
        self.start_pc2_command(row)

    def run_pc2_selected_command(self):
        command_id = self.get_selected_pc2_command_id()
        if not command_id:
            messagebox.showinfo(
                "PC2 VYBRANÁ AKCE",
                "Nejdřív klikni na akční kartu nahoře nebo na řádek v PC2 SPOUŠTĚCÍ FRONTA."
            )
            return

        row = self.get_pc2_command_row(command_id)
        if not row:
            messagebox.showerror("PC2 VYBRANÁ AKCE", "Vybraný příkaz se nepodařilo načíst z DB.")
            return
        self.start_pc2_command(row)

    def get_pc2_selected_row_or_warn(self, title="PC2 AKCE"):
        command_id = self.get_selected_pc2_command_id()
        if not command_id:
            messagebox.showinfo(
                title,
                "Nejdřív klikni na akční kartu nahoře nebo na řádek v PC2 SPOUŠTĚCÍ FRONTA."
            )
            return None

        row = self.get_pc2_command_row(command_id)
        if not row:
            messagebox.showerror(title, "Vybraný příkaz se nepodařilo načíst z DB.")
            return None

        return row

    def pc2_set_selected_status(self, new_status):
        """
        V18.20 - ruční přepnutí stavu PC2 příkazu přímo z panelu.

        CO TO JE:
        - Nahrazuje ruční UPDATE v DBeaveru.

        K ČEMU TO JE:
        - Přímo v panelu lze nastavit READY / DONE / BLOCKED / FAILED.
        """
        row = self.get_pc2_selected_row_or_warn("PC2 STAV")
        if not row:
            return

        command_id = int(row.get("id"))
        title = row.get("command_title") or f"PC2 command {command_id}"
        old_status = row.get("run_status")

        if str(old_status).upper() == "RUNNING":
            messagebox.showwarning("PC2 STAV", "Nelze měnit stav příkazu, který právě běží.")
            return

        confirm = messagebox.askyesno(
            "PC2 STAV",
            f"Přepnout stav vybrané PC2 akce?\n\n{title}\n\n{old_status} → {new_status}"
        )
        if not confirm:
            return

        ok, err = db_execute("""
            UPDATE ops.pc2_run_command_queue
            SET
                run_status = %s,
                last_result = %s,
                updated_at = now()
            WHERE id = %s;
        """, (
            new_status,
            f"Manual status change from OPS Panel V18.20: {old_status} -> {new_status}",
            command_id,
        ))

        if not ok:
            messagebox.showerror("PC2 STAV", f"Nepodařilo se přepnout stav:\n{err}")
            return

        self.log(f"PC2 STATUS: command_id={command_id} | {old_status} -> {new_status}")
        self.load_pc2_command_center()

    def pc2_continue_selected_command(self):
        """
        V18.20 - CONTINUE.

        CO TO JE:
        - Pokud je PC2 command DONE, ale planner má ještě pending joby,
          vrátí command zpět na READY_TO_RUN.
        """
        row = self.get_pc2_selected_row_or_warn("PC2 POKRAČOVAT")
        if not row:
            return

        command_id = int(row.get("id"))
        status_rows = db_query(f"""
            SELECT
                command_id,
                sport_code,
                target_layer,
                run_status,
                pending_jobs,
                done_jobs,
                failed_jobs,
                can_continue
            FROM ops.v_pc2_panel_action_matrix_v1
            WHERE command_id = {command_id}
            LIMIT 1;
        """)

        if not status_rows or "CHYBA" in status_rows[0]:
            messagebox.showerror("PC2 POKRAČOVAT", "Nelze načíst action matrix.")
            return

        info = status_rows[0]
        if int(info.get("can_continue") or 0) != 1:
            messagebox.showinfo(
                "PC2 POKRAČOVAT",
                f"Pokračovat nelze.\n\nStav: {info.get('run_status')}\nPending joby: {info.get('pending_jobs')}"
            )
            return

        ok, err = db_execute("""
            UPDATE ops.pc2_run_command_queue
            SET
                run_status = 'READY_TO_RUN',
                last_result = 'Continue pending planner jobs from OPS Panel V18.20.',
                updated_at = now()
            WHERE id = %s;
        """, (command_id,))

        if not ok:
            messagebox.showerror("PC2 POKRAČOVAT", f"Nepodařilo se nastavit READY_TO_RUN:\n{err}")
            return

        self.log(f"PC2 CONTINUE: command_id={command_id} | pending={info.get('pending_jobs')} -> READY_TO_RUN")
        self.load_pc2_command_center()

    def pc2_retry_selected_command(self):
        """
        V18.20 - RETRY.

        CO TO JE:
        - Resetuje vybraný PC2 command na READY_TO_RUN.
        """
        row = self.get_pc2_selected_row_or_warn("PC2 RETRY")
        if not row:
            return

        command_id = int(row.get("id"))
        old_status = row.get("run_status")

        if str(old_status).upper() == "RUNNING":
            messagebox.showwarning("PC2 RETRY", "Nelze dát retry příkazu, který právě běží.")
            return

        ok, err = db_execute("""
            UPDATE ops.pc2_run_command_queue
            SET
                run_status = 'READY_TO_RUN',
                last_started_at = NULL,
                last_finished_at = NULL,
                last_result = 'Retry requested from OPS Panel V18.20.',
                updated_at = now()
            WHERE id = %s;
        """, (command_id,))

        if not ok:
            messagebox.showerror("PC2 RETRY", f"Nepodařilo se nastavit retry:\n{err}")
            return

        self.log(f"PC2 RETRY: command_id={command_id} | {old_status} -> READY_TO_RUN")
        self.load_pc2_command_center()

    def extract_run_group_from_command_text(self, command_text):
        """
        V18.20 - vytáhne --run-group z command_text.
        """
        try:
            parts = shlex.split(str(command_text or ""), posix=False)
            for idx, part in enumerate(parts):
                if part == "--run-group" and idx + 1 < len(parts):
                    return str(parts[idx + 1]).strip('"')
                if str(part).startswith("--run-group="):
                    return str(part).split("=", 1)[1].strip('"')
        except Exception:
            return None
        return None

    def pc2_reset_selected_planner_pending(self):
        """
        V18.20 - vrátí planner joby vybraného PC2 commandu na pending.

        CO TO JE:
        - Nahrazuje ruční UPDATE ops.ingest_planner v DBeaveru.

        JAK SE TO VYUŽIJE:
        - Po opravě routingu / workeru dáš routing_error/error/failed zpět na pending.
        """
        row = self.get_pc2_selected_row_or_warn("PC2 PLANNER PENDING")
        if not row:
            return

        command_id = int(row.get("id"))
        command_text = row.get("command_text") or ""
        run_group = self.extract_run_group_from_command_text(command_text)

        if not run_group:
            messagebox.showerror("PC2 PLANNER PENDING", "Z command_text se nepodařilo zjistit --run-group.")
            return

        confirm = messagebox.askyesno(
            "PC2 PLANNER PENDING",
            f"Vrátit planner joby na pending?\n\ncommand_id={command_id}\nrun_group={run_group}\n\nZmění se statusy: routing_error, error, failed, cancelled, running → pending."
        )
        if not confirm:
            return

        ok, err = db_execute("""
            UPDATE ops.ingest_planner
            SET
                status = 'pending',
                attempts = 0,
                next_run = now(),
                updated_at = now()
            WHERE run_group = %s
              AND status IN ('routing_error','error','failed','cancelled','running');
        """, (run_group,))

        if not ok:
            messagebox.showerror("PC2 PLANNER PENDING", f"Nepodařilo se vrátit joby na pending:\n{err}")
            return

        ok2, err2 = db_execute("""
            UPDATE ops.pc2_run_command_queue
            SET
                run_status = 'READY_TO_RUN',
                last_result = %s,
                updated_at = now()
            WHERE id = %s;
        """, (
            f"Planner jobs reset to pending from OPS Panel V18.20 | run_group={run_group}",
            command_id,
        ))

        if not ok2:
            messagebox.showerror("PC2 COMMAND READY", f"Planner reset OK, ale command nejde přepnout:\n{err2}")
            return

        self.log(f"PC2 PLANNER PENDING: run_group={run_group} -> pending | command_id={command_id} -> READY_TO_RUN")
        self.load_pc2_command_center()

    def pc2_test_selected_command(self):
        """
        V18.20 - TEST.

        CO TO JE:
        - Spustí vybraný command i mimo READY_TO_RUN stav.
        - Používá se pro ověření nového workeru/routingu.
        """
        row = self.get_pc2_selected_row_or_warn("PC2 TEST")
        if not row:
            return

        self.start_pc2_command(row, allow_non_ready=True, test_mode=True)

    def start_pc2_command(self, row, allow_non_ready=False, test_mode=False):
        """
        V18.16 - PC2 EXECUTION ENGINE

        CO TO JE:
        - Spustí command_text z ops.pc2_run_command_queue.
        - Hned zapíše RUNNING do DB.
        - Po doběhu zapíše DONE nebo FAILED.

        K ČEMU TO JE:
        - PC2 Command Center už není jen přehled, ale reálné spouštění.
        """

        if self.worker_running:
            messagebox.showwarning("SPUŠTĚNO", "Worker už běží. Počkej na dokončení aktuální akce.")
            return

        command_id = row.get("id")
        title = row.get("command_title") or "PC2 akce"
        command_text = row.get("command_text") or ""
        run_status = str(row.get("run_status") or "").upper()

        if not command_id:
            messagebox.showerror("PC2 AKCE", "Chybí command_id. Nelze spustit PC2 akci.")
            return

        if run_status != "READY_TO_RUN" and not allow_non_ready:
            messagebox.showwarning(
                "PC2 AKCE NENÍ READY",
                f"Vybraná akce není ve stavu READY_TO_RUN.\n\nAktuální stav: {run_status}\n\nPoužij READY / RETRY / POKRAČOVAT, nebo tlačítko TEST."
            )
            return

        run_args, normalized_preview = self.build_pc2_subprocess_command(command_text)
        if not run_args:
            messagebox.showerror(
                "PC2 PŘÍKAZ",
                "Příkaz se nepodařilo převést na bezpečné spuštění.\n\n" + str(command_text)
            )
            return

        dialog_title = "TEST PC2 AKCE" if test_mode else "SPUSTIT PC2 AKCI"
        confirm = messagebox.askyesno(
            dialog_title,
            f"Chceš spustit tuto PC2 akci?\n\n{title}\n\nRežim: {'TEST' if test_mode else 'RUN'}\n\nPříkaz z DB:\n{command_text}\n\nSpustí se jako:\n{normalized_preview}"
        )
        if not confirm:
            return

        # Worker_running nastavíme už před UPDATE, aby nešlo kliknout dvakrát.
        self.worker_running = True

        # V18.20:
        # - běžný RUN smí jen ze stavu READY_TO_RUN,
        # - TEST smí i z DONE/BLOCKED/FAILED, aby šlo ověřit nový worker bez DBeaveru.
        if allow_non_ready:
            ok, err = db_execute("""
                UPDATE ops.pc2_run_command_queue
                SET
                    run_status = 'RUNNING',
                    last_started_at = now(),
                    last_finished_at = NULL,
                    last_result = %s,
                    updated_at = now()
                WHERE id = %s;
            """, (
                "TEST started from OPS Panel V18.20" if test_mode else "Started from OPS Panel V18.20",
                command_id,
            ))
        else:
            ok, err = db_execute("""
                UPDATE ops.pc2_run_command_queue
                SET
                    run_status = 'RUNNING',
                    last_started_at = now(),
                    last_finished_at = NULL,
                    last_result = %s,
                    updated_at = now()
                WHERE id = %s
                  AND run_status = 'READY_TO_RUN';
            """, (
                "Started from OPS Panel V18.20",
                command_id,
            ))

        if not ok:
            self.worker_running = False
            messagebox.showerror("PC2 DB UPDATE", f"Nepodařilo se zapsat RUNNING:\n{err}")
            return

        self.last_worker_name = f"PC2_COMMAND_{command_id}"
        self.log(f"PC2 RUN: {title}")
        self.log(f"PC2 COMMAND_ID: {command_id}")
        self.log(f"PC2 PŘÍKAZ Z DB: {command_text}")
        self.log(f"PC2 NORMALIZOVANÝ PŘÍKAZ: {normalized_preview}")
        self.start_worker_activity(f"PC2 {row.get('sport_code')}/{row.get('target_layer')}")
        self.load_pc2_command_center()

        thread = threading.Thread(
            target=self.run_pc2_command_thread,
            args=(int(command_id), run_args, normalized_preview, test_mode),
            daemon=True
        )
        thread.start()

    def build_pc2_subprocess_command(self, command_text):
        """
        V18.16 - bezpečný převod DB příkazu na subprocess args.

        Proč:
        - V DB držíme čitelný příkaz typu:
          python workers/run_ingest_planner_jobs.py --sport HB --layer core ...
        - Panel ho na Windows spustí přes konkrétní C:\\Python314\\python.exe.
        - Nepoužíváme shell=True, aby byl běh stabilnější a čitelnější.
        """
        try:
            text_cmd = str(command_text or "").strip()
            if not text_cmd:
                return None, ""

            parts = shlex.split(text_cmd, posix=False)
            if not parts:
                return None, text_cmd

            first = str(parts[0]).strip().lower().strip('"')

            if first in ("python", "python.exe", "py", "py.exe"):
                parts[0] = PYTHON_EXE

            # Pokud je druhý argument relativní cesta k .py, převedeme ji na absolutní.
            if len(parts) >= 2 and str(parts[1]).lower().endswith(".py"):
                script_path = str(parts[1]).strip('"')
                if not os.path.isabs(script_path):
                    parts[1] = os.path.join(BASE_DIR, script_path)

            preview = " ".join([f'"{p}"' if " " in str(p) else str(p) for p in parts])
            return parts, preview

        except Exception as e:
            self.log_queue.put(f"CHYBA PC2 NORMALIZACE PŘÍKAZU: {e}")
            return None, str(command_text or "")

    def run_pc2_command_thread(self, command_id, run_args, normalized_preview, test_mode=False):
        return_code = None
        result_message = ""

        try:
            self.log_queue.put("START PC2: command spuštěn, čekám na výstup...")
            self.log_queue.put("PŘÍKAZ: " + str(normalized_preview))

            proc = subprocess.Popen(
                run_args,
                cwd=BASE_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=False,
                shell=False
            )

            output_tail = []
            for raw_line in proc.stdout:
                line = self.decode_process_line(raw_line).rstrip()
                output_tail.append(line)
                output_tail = output_tail[-20:]
                self.log_queue.put(line)

            proc.wait()
            return_code = proc.returncode
            result_message = "\n".join(output_tail)[-2500:]
            self.log_queue.put(f"KONEC PC2: command doběhl | return_code={return_code}")

        except Exception as e:
            result_message = str(e)
            self.log_queue.put(f"CHYBA PC2: {e}")

        new_status = "DONE" if return_code == 0 else "FAILED"
        db_execute("""
            UPDATE ops.pc2_run_command_queue
            SET
                run_status = %s,
                last_finished_at = now(),
                last_result = %s,
                updated_at = now()
            WHERE id = %s;
        """, (
            new_status,
            f"return_code={return_code}\n{result_message}",
            command_id
        ))

        self.worker_running = False
        self.last_worker_return_code = return_code
        self.after(0, lambda rc=return_code: self.finish_worker_activity(rc))
        self.after(0, self.load_pc2_command_center)
        self.after(0, self.refresh_all)

    def open_pc2_command_detail(self, event):
        command_id = self.get_selected_pc2_command_id()
        if not command_id:
            return

        row = self.get_pc2_command_row(command_id)
        if not row:
            return

        detail = f"""
PC2 COMMAND DETAIL

ID:
{row.get('id')}

Název:
{row.get('command_title')}

Sport / vrstva:
{row.get('sport_code')} / {row.get('target_layer')}

Stav:
{row.get('run_status')}

Bezpečnost:
{row.get('safety_mode')}

CO TO JE:
{row.get('action_description') or '-'}

K ČEMU TO JE:
{row.get('purpose_description') or '-'}

KAM SE UKLÁDÁ:
{row.get('target_tables') or '-'}

KDE TO UVIDÍME:
{row.get('panel_usage') or '-'}

OČEKÁVANÝ VÝSLEDEK:
{row.get('expected_result') or '-'}

PŘÍKAZ:
{row.get('command_text')}

POSLEDNÍ START:
{row.get('last_started_at') or '-'}

POSLEDNÍ KONEC:
{row.get('last_finished_at') or '-'}

POSLEDNÍ VÝSLEDEK:
{row.get('last_result') or '-'}

KLASIFIKACE / DOPORUČENÍ:
Důvod: {row.get('classification_reason') or '-'}
Doporučení: {row.get('operator_recommendation') or '-'}
Priorita: {row.get('recommendation_priority') or '-'}
Tlačítko: {row.get('button_label_cz') or '-'}
Nápověda: {row.get('button_help_cz') or '-'}

CO UDĚLAT:
- Použij dynamické tlačítko DOPORUČENÁ AKCE vpravo.
- Pokud je stav READY_TO_RUN, můžeš použít SPUSTIT VYBRANOU PC2 AKCI.
- Po spuštění se řádek přepne na RUNNING.
- Po doběhu se zapíše DONE nebo FAILED.
""".strip()
        self.show_help_window("🚀 DETAIL PC2 PŘÍKAZU", detail)

    def load_people_pipeline(self):
        """
        V18.7 - PEOPLE PIPELINE + PEOPLE GOVERNANCE STATUS

        CO TO JE:
        - Načte People runtime governance z ops.runtime_entity_audit.
        - Načte ops.v_people_pipeline_summary_v1 a ops.v_people_pipeline_audit_v1.

        K ČEMU TO JE:
        - Horní tabulka ukazuje Team/Player governance stav.
        - Prostřední tabulka ukazuje PEOPLE stav za celý sport.
        - Dolní tabulka ukazuje detail podle providerů.

        KDE TO UVIDÍME:
        - PEOPLE -> PEOPLE GOVERNANCE STATUS.
        - PEOPLE -> PEOPLE SUMMARY + PEOPLE DETAIL.

        JAK SE TO VYUŽIJE:
        - Před people/provider ingestem uvidíme, jestli identity guardy běží.
        - CONTROLLED_HOLD znamená: ingest je možný, ale automatické merge opravy jsou zastavené.
        """

        governance_sql = """
        SELECT
            entity,
            current_state,
            state_reason,
            provider_map_confirmed,
            public_merge_confirmed,
            downstream_confirmed,
            last_run_group,
            db_evidence_summary,
            next_action,
            updated_at
        FROM ops.runtime_entity_audit
        WHERE provider = 'matchmatrix_governance'
          AND entity IN (
              'team_duplicate_prevention',
              'player_identity_governance',
              'player_provider_map_governance'
          )
        ORDER BY
            CASE entity
                WHEN 'team_duplicate_prevention' THEN 1
                WHEN 'player_identity_governance' THEN 2
                WHEN 'player_provider_map_governance' THEN 3
                ELSE 9
            END;
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
            self.people_governance_status_tree,
            db_query(governance_sql)
        )

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

    def load_system_events_dashboard(self):
        """
        V20.A - SYSTÉMOVÉ UDÁLOSTI

        CO TO JE:
        - Sloučený přehled alertů, runtime feedu a worker health.

        K ČEMU TO JE:
        - PŘEHLED už nemá tři podobné tabulky vedle sebe.
        - Operátor vidí jeden prioritní seznam událostí.

        KDE TO UVIDÍME:
        - PŘEHLED -> SYSTÉMOVÉ UDÁLOSTI.

        JAK SE TO VYUŽIJE:
        - Nejdřív řešit CRITICAL / FAILED_WORKER / WARNING.
        - Detail otevřít dvojklikem na řádek.
        """

        sql = """
        WITH alerts AS (
            SELECT
                'ALERT'::text AS event_group,
                source_object::text AS source_name,
                alert_severity::text AS severity_label,
                alert_count::bigint AS item_count,
                last_alert_message::text AS event_message,
                CASE
                    WHEN UPPER(COALESCE(alert_severity, '')) IN ('CRITICAL', 'AKTIVNÍ UPOZORNĚNÍ') THEN 'Řešit jako první. Otevři detail a navazující LOGY / OPRAVY.'
                    WHEN UPPER(COALESCE(alert_severity, '')) IN ('WARNING', 'VAROVÁNÍ') THEN 'Zkontrolovat po kritických položkách.'
                    ELSE 'Monitorovat.'
                END AS recommended_action_cz,
                last_alert_time AS event_time,
                CASE
                    WHEN UPPER(COALESCE(alert_severity, '')) IN ('CRITICAL', 'AKTIVNÍ UPOZORNĚNÍ') THEN 1
                    WHEN UPPER(COALESCE(alert_severity, '')) IN ('WARNING', 'VAROVÁNÍ') THEN 2
                    ELSE 5
                END AS sort_order
            FROM ops.v_runtime_alerts_grouped_v1
        ), feed AS (
            SELECT
                feed_type::text AS event_group,
                object_name::text AS source_name,
                severity::text AS severity_label,
                NULL::bigint AS item_count,
                message::text AS event_message,
                CASE
                    WHEN UPPER(COALESCE(severity, '')) IN ('CRITICAL', 'FAILED', 'ERROR', 'AKTIVNÍ UPOZORNĚNÍ') THEN 'Zkontrolovat LOGY a případně vytvořit fix task.'
                    WHEN UPPER(COALESCE(severity, '')) IN ('WARNING', 'VAROVÁNÍ') THEN 'Ověřit po doběhu workeru.'
                    ELSE 'Informační událost.'
                END AS recommended_action_cz,
                event_time AS event_time,
                CASE
                    WHEN UPPER(COALESCE(severity, '')) IN ('CRITICAL', 'FAILED', 'ERROR', 'AKTIVNÍ UPOZORNĚNÍ') THEN 1
                    WHEN UPPER(COALESCE(severity, '')) IN ('WARNING', 'VAROVÁNÍ') THEN 2
                    ELSE 6
                END AS sort_order
            FROM ops.v_runtime_operations_center_feed_v1
        ), worker_health AS (
            SELECT
                'WORKER'::text AS event_group,
                worker_code::text AS source_name,
                dashboard_state::text AS severity_label,
                NULL::bigint AS item_count,
                (
                    'Scheduler: ' || COALESCE(scheduler_health_tier::text, '-') ||
                    ' | Recent: ' || COALESCE(recent_health_tier::text, '-') ||
                    ' | Důvěra: ' || COALESCE(execution_confidence_score::text, '-')
                ) AS event_message,
                CASE
                    WHEN UPPER(COALESCE(dashboard_state, '')) IN ('CRITICAL', 'ERROR', 'FAILED', 'VAROVÁNÍ', 'WARNING') THEN 'Ověřit worker v záložce WORKERY a LOGY.'
                    WHEN COALESCE(autonomous_safe, false) = true THEN 'Worker je kandidát pro bezpečné spuštění.'
                    ELSE 'Monitorovat worker.'
                END AS recommended_action_cz,
                now() AS event_time,
                CASE
                    WHEN UPPER(COALESCE(dashboard_state, '')) IN ('CRITICAL', 'ERROR', 'FAILED', 'VAROVÁNÍ', 'WARNING') THEN 2
                    WHEN COALESCE(autonomous_safe, false) = true THEN 4
                    ELSE 7
                END AS sort_order
            FROM ops.v_scheduler_runtime_dashboard_v1
        )
        SELECT
            event_group,
            source_name,
            severity_label,
            item_count,
            event_message,
            recommended_action_cz,
            event_time
        FROM (
            SELECT * FROM alerts
            UNION ALL
            SELECT * FROM feed
            UNION ALL
            SELECT * FROM worker_health
        ) x
        ORDER BY
            sort_order ASC,
            event_time DESC NULLS LAST
        LIMIT 120;
        """

        self.populate_tree(
            self.system_events_tree,
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
            final_priority_score,
            CASE
                WHEN UPPER(worker_code) LIKE '%PEOPLE%' OR UPPER(worker_code) LIKE '%PLAYER%' THEN 'PEOPLE'
                WHEN UPPER(worker_code) LIKE '%ODDS%' OR UPPER(worker_code) LIKE '%THEODDS%' THEN 'ODDS'
                WHEN UPPER(worker_code) LIKE '%MEDIA%' THEN 'MEDIA'
                WHEN UPPER(worker_code) LIKE '%CORE%' OR UPPER(worker_code) LIKE '%INGEST%' THEN 'CORE'
                ELSE 'OPS'
            END AS layer_code,
            CASE
                WHEN execution_decision = 'RUN' THEN 'Bezpečný kandidát ke spuštění podle Run Next fronty.'
                ELSE 'Nespouštět bez kontroly detailu.'
            END AS recommendation_reason
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
        FROM ops.v_active_runs_live_v2
        WHERE is_active = true
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
        FROM ops.v_active_runs_live_v2
        WHERE is_active = true
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


    def format_table_cell_value_v19(self, col, value):
        """
        V19.3 - krátké hodnoty v tabulkách.

        CO TO JE:
        - V hlavní tabulce se ukazuje krátký čitelný stav.
        - Plný technický detail zůstává dostupný přes dvojklik na řádek.
        """
        translated = self.translate_cell_value(value)
        col_low = str(col or "").lower()

        if translated is None:
            return ""

        text = str(translated)
        upper_original = str(value or "").upper()
        upper_text = text.upper()

        if col_low in (
            "run_status", "status", "current_state", "execution_readiness_status",
            "result_status", "kpi_status", "panel_status", "readiness_status",
            "task_status", "parse_status"
        ):
            short_map = {
                "READY_TO_RUN": "PŘIPRAVENO",
                "PŘIPRAVENO KE SPUŠTĚNÍ": "PŘIPRAVENO",
                "DONE": "HOTOVO",
                "HOTOVO": "HOTOVO",
                "RUNNING": "BĚŽÍ",
                "BĚŽÍ": "BĚŽÍ",
                "FAILED": "CHYBA",
                "ERROR": "CHYBA",
                "BLOCKED": "BLOK",
                "DISABLED": "VYPNUTO",
                "PENDING": "ČEKÁ",
                "WAIT": "ČEKÁ",
                "CONFIRMED": "POTVRZENO",
                "CONTROLLED_HOLD": "ŘÍZENÝ HOLD",
                "VERIFY_PEOPLE_WORKER": "OVĚŘIT WORKER",
                "ROUTING_ERROR_PLAYERS_NOT_GENERIC": "ROUTING ERROR",
                "ROUTING_ERROR": "ROUTING ERROR",
                "PLANNER_JOB_MISSING": "CHYBÍ JOB",
                "LEAGUE_ID_MISSING": "CHYBÍ LIGA",
                "READY": "READY",
                "REVIEW": "KONTROLA",
                "WARNING": "VAROVÁNÍ",
                "VAROVÁNÍ": "VAROVÁNÍ",
                "CRITICAL": "KRITICKÉ",
                "AKTIVNÍ UPOZORNĚNÍ": "UPOZORNĚNÍ",
                "INFO": "INFO",
                "EMPTY_RUN": "PRÁZDNÝ BĚH",
            }
            return short_map.get(upper_original, short_map.get(upper_text, text))

        if col_low in ("command_title", "action_card"):
            return text.replace("Spustit ", "Spustit ").strip()

        return translated

    def open_active_alerts_center(self):
        """
        V19.3 - klikací aktivní upozornění.

        CO TO JE:
        - Otevře okno s tím, proč panel bliká.

        K ČEMU TO JE:
        - Operátor hned vidí problém a doporučenou opravu bez hledání v záložkách.
        """
        lines = []
        lines.append("CO TO JE:")
        lines.append("Aktivní upozornění znamená, že OPS vrstva našla stav, který stojí za kontrolu.")
        lines.append("")
        lines.append("CO UDĚLAT TEĎ:")
        lines.append("1) Zkontroluj TOP upozornění níže.")
        lines.append("2) Pokud jde o routing/provider/planner problém, otevři DENNÍ PRÁCE nebo PROBLÉMY.")
        lines.append("3) Po opravě spusť akci znovu a klikni OBNOVIT.")
        lines.append("")
        lines.append("=" * 90)
        lines.append("TOP ALERTY / UPOZORNĚNÍ")
        lines.append("=" * 90)

        alert_queries = [
            (
                "RUNTIME ALERTY",
                """
                SELECT *
                FROM ops.v_runtime_alerts_grouped_v1
                ORDER BY
                    CASE
                        WHEN UPPER(COALESCE(alert_severity, severity, '')) = 'CRITICAL' THEN 1
                        WHEN UPPER(COALESCE(alert_severity, severity, '')) = 'HIGH' THEN 2
                        WHEN UPPER(COALESCE(alert_severity, severity, '')) = 'WARNING' THEN 3
                        ELSE 9
                    END,
                    COALESCE(alert_count, 0) DESC
                LIMIT 8;
                """
            ),
            (
                "AI OPS ALERTY",
                """
                SELECT
                    provider,
                    ai_alert_severity,
                    execution_decision,
                    risk_score,
                    ai_alert_message,
                    recommended_cooldown_seconds,
                    provider_presence_status
                FROM ops.v_ai_ops_alert_center_v1
                ORDER BY risk_score DESC NULLS LAST, provider
                LIMIT 8;
                """
            ),
            (
                "OTEVŘENÉ OPRAVY",
                """
                SELECT
                    id,
                    provider,
                    sport_code,
                    entity_type,
                    severity,
                    task_status,
                    short_message,
                    suggested_fix,
                    created_at
                FROM ops.fix_tasks
                WHERE COALESCE(task_status, 'OPEN') NOT IN ('FIXED', 'IGNORED', 'DONE')
                ORDER BY
                    CASE severity
                        WHEN 'CRITICAL' THEN 1
                        WHEN 'HIGH' THEN 2
                        WHEN 'MEDIUM' THEN 3
                        WHEN 'LOW' THEN 4
                        ELSE 9
                    END,
                    created_at DESC
                LIMIT 8;
                """
            ),
            (
                "PC2 PROBLÉMOVÉ AKCE",
                """
                SELECT
                    command_id,
                    sport_code,
                    target_layer,
                    run_status,
                    execution_readiness_status,
                    planner_jobs,
                    pending_jobs,
                    failed_jobs
                FROM ops.v_pc2_panel_action_matrix_v1
                WHERE UPPER(COALESCE(execution_readiness_status, '')) NOT IN ('READY_TO_RUN', 'PŘIPRAVENO KE SPUŠTĚNÍ')
                   OR COALESCE(failed_jobs, 0) > 0
                ORDER BY command_id
                LIMIT 12;
                """
            ),
        ]

        any_data = False
        for title, sql in alert_queries:
            rows = db_query(sql)
            lines.append("")
            lines.append(f"[{title}]")
            if not rows:
                lines.append("✓ Bez aktivních položek.")
                continue
            if rows and "CHYBA" in rows[0]:
                lines.append(f"Nelze načíst: {rows[0].get('CHYBA')}")
                continue
            any_data = True
            for idx, row in enumerate(rows, start=1):
                compact = []
                for key, value in row.items():
                    if value in (None, ""):
                        continue
                    text = str(value)
                    if len(text) > 120:
                        text = text[:120] + " ..."
                    compact.append(f"{cz_column(key)}={text}")
                lines.append(f"{idx}. " + " | ".join(compact))

        lines.append("")
        lines.append("=" * 90)
        lines.append("DOPORUČENÁ OPRAVA")
        lines.append("=" * 90)
        if any_data:
            lines.append("- Otevři záložku PROBLÉMY pro opravy/fix tasky.")
            lines.append("- Otevři DENNÍ PRÁCE pro PC2 akce a routing/planner stav.")
            lines.append("- Po opravě spusť konkrétní akci znovu a zkontroluj historii/log v detailu řádku.")
            lines.append("- Pokud upozornění zůstává, dvojklikni na řádek v příslušné tabulce a pošli detail chyby.")
        else:
            lines.append("Nejsou nalezené konkrétní aktivní položky. Pokud text pořád bliká, jde pravděpodobně o souhrnný WARNING bez detailu v alert views.")

        self.show_help_window("🚨 AKTIVNÍ UPOZORNĚNÍ – DETAIL A OPRAVA", "\n".join(lines))

    def get_visible_columns_for_tree(self, tree, cols):
        """
        V19.2 - přehledné tabulky.

        CO TO JE:
        - Každá tabulka má v první obrazovce jen důležité sloupce.
        - Všechny původní hodnoty zůstávají v řádku a jsou vidět přes dvojklik.

        K ČEMU TO JE:
        - Operátor hned pozná: co je to za řádek, jaký má stav, co je další výsledek/problém.
        - Dlouhé technické popisy, SQL/command texty a auditní poznámky nezahlcují hlavní pohled.
        """
        cols = [str(c) for c in cols]
        cols_set = set(cols)
        section = str(getattr(tree, "_section_title", "") or "").upper()

        def pick(preferred, max_count=8):
            result = []
            for c in preferred:
                if c in cols_set and c not in result:
                    result.append(c)
            for c in cols:
                if c in result:
                    continue
                c_low = c.lower()
                if c_low in (
                    "command_text", "payload_json", "raw_json", "details", "params",
                    "full_message", "audit_note", "db_evidence_summary", "purpose_description",
                    "action_description", "target_tables", "panel_usage", "expected_result",
                    "notes", "note", "description", "log_tail", "url"
                ):
                    continue
                if len(result) >= max_count:
                    break
                result.append(c)
            return result or cols[:max_count]

        # V19.11 - PHOTO REVIEW kandidáti
        if "PHOTO REVIEW" in section:
            return pick([
                "sport_code",
                "provider",
                "review_status",
                "confidence_score",
                "candidate_id",
                "player_id",
                "public_player_name",
                "candidate_player_name",
                "source_system",
                "wikidata_id",
                "public_photo_state",
                "approved_by",
                "approved_at",
                "created_at",
            ], max_count=14)

        # Denní práce / PC2 fronta – hlavní operační tabulka.
        if "DETAIL FRONTY" in section or "SPOUŠTĚCÍ FRONTA" in section or "PC2 SPOU" in section:
            return pick([
                "id", "sport_code", "sport_name", "target_layer",
                "run_status", "priority_score", "command_title", "last_result"
            ], max_count=8)

        # PC2 akce / audit matice.
        if "MOŽNÉ AKCE" in section or "PC2 DALŠÍ AKCE" in section:
            return pick([
                "command_id", "sport_code", "target_layer", "run_status",
                "execution_readiness_status", "planner_jobs", "pending_jobs", "done_jobs", "failed_jobs"
            ], max_count=9)

        # Historie běhů.
        if "HISTOR" in section:
            return pick([
                "id", "command_id", "sport_code", "target_layer", "result_status",
                "processed_jobs", "return_code", "started_at", "result_message"
            ], max_count=9)

        # Problémy / opravy.
        if "OPRAV" in section or "PROBL" in section or "FIX" in section:
            return pick([
                "id", "sport_code", "provider", "entity", "severity", "task_status",
                "short_message", "suggested_fix", "created_at"
            ], max_count=9)

        # Harvest / completion.
        if "SPORT COMPLETION" in section or "HARVEST" in section or "ROADMAP" in section:
            return pick([
                "sport_code", "sport_name", "target_layer", "next_harvest_layer",
                "run_status", "readiness_status", "total_pct", "priority_level", "recommended_focus", "next_action"
            ], max_count=9)

        # Obecná priorita sloupců pro všechny ostatní tabulky.
        generic_priority = [
            "id", "sport_code", "sport_name", "provider", "entity", "entity_type",
            "target_layer", "status", "run_status", "current_state", "readiness_status",
            "priority_score", "priority_level", "command_title", "action_code",
            "result_status", "last_result", "recommended_action", "next_action", "updated_at"
        ]
        return pick(generic_priority, max_count=8)

    def get_column_width_v19(self, col, rows, visible=True):
        """
        V19.2 - stabilní šířky důležitých sloupců.
        Hlavní sloupce jsou čitelné, dlouhé technické hodnoty patří do detailu řádku.
        """
        col_low = str(col).lower()

        width_map = {
            "id": 52,
            "command_id": 70,
            "sport_code": 70,
            "sport_name": 115,
            "provider": 130,
            "entity": 95,
            "entity_type": 95,
            "target_layer": 95,
            "season": 70,
            "run_status": 120,
            "status": 110,
            "current_state": 135,
            "readiness_status": 135,
            "execution_readiness_status": 190,
            "priority_score": 85,
            "priority_level": 105,
            "planner_jobs": 88,
            "pending_jobs": 88,
            "done_jobs": 82,
            "failed_jobs": 82,
            "processed_jobs": 95,
            "return_code": 80,
            "result_status": 125,
            "command_title": 310,
            "short_message": 300,
            "suggested_fix": 330,
            "recommended_action": 280,
            "next_action": 300,
            "last_result": 330,
            "result_message": 330,
            "updated_at": 150,
            "started_at": 150,
            "finished_at": 150,
            "last_started_at": 150,
            "last_finished_at": 150,
        }

        if col_low in width_map:
            return width_map[col_low]

        if not visible:
            return 80

        max_len = len(str(col))
        for row in rows[:50]:
            try:
                max_len = max(max_len, len(str(row.get(col, ""))))
            except Exception:
                pass

        if any(key in col_low for key in ("message", "reason", "note", "description")):
            return max(180, min(max_len * 6, 320))
        return max(80, min(max_len * 7, 220))

    def safe_tree_display_value_v19_9(self, col, value, max_len=220):
        """
        V19.10 - bezpečné hodnoty pro Treeview.

        CO TO JE:
        - Treeview dostane jen krátký text, aby se Tkinter nezasekl na dlouhém logu.

        K ČEMU TO JE:
        - DENNÍ PRÁCE nesmí zamrznout, když je v DB uložený dlouhý last_result/log.
        """
        try:
            if value is None:
                return ""
            text = str(value)
            text = text.replace("\r", " ").replace("\n", " | ").replace("\t", " ")
            while "  " in text:
                text = text.replace("  ", " ")
            col_low = str(col or "").lower()
            if col_low in ("last_result", "result_message", "log_tail", "full_message", "payload_json", "details", "params"):
                max_len = 180
            elif col_low in ("command_text", "action_description", "purpose_description", "expected_result", "target_tables", "panel_usage"):
                max_len = 160
            if len(text) > max_len:
                text = text[:max_len].rstrip() + " …"
            return text
        except Exception:
            return ""

    def populate_tree(self, tree, rows):

        tree.delete(*tree.get_children())

        if not rows:
            tree.configure(displaycolumns=())

            tree["columns"] = ["info"]
            tree["displaycolumns"] = ["info"]

            tree.heading("info", text="INFO")
            tree.column("info", width=300, anchor="center", stretch=True)

            section_title = str(getattr(tree, "_section_title", "")).upper()
            empty_text = "✓ Žádná aktivní data"
            if "AKTIVNÍ BĚHY" in section_title:
                empty_text = "✓ Žádné aktivní běhy"
            elif "COOLDOWN" in section_title:
                empty_text = "✓ Scheduler bez cooldownů"
            elif "LIMIT" in section_title:
                empty_text = "✓ Denní limity bez aktivního čerpání"

            tree.insert("", "end", values=(empty_text,), tags=("empty_ok",))
            return

        cols = [str(c) for c in rows[0].keys()]
        visible_cols = self.get_visible_columns_for_tree(tree, cols)

        tree.configure(displaycolumns=())

        tree["columns"] = cols
        tree["displaycolumns"] = visible_cols

        for col in cols:
            tree.heading(
                col,
                text=cz_column(col),
                command=lambda c=col, t=tree: self.open_column_help(c, t)
            )

            is_visible = col in visible_cols
            width = self.get_column_width_v19(col, rows, is_visible)

            # Hlavní textové sloupce vlevo, krátké stavové/číselné sloupce doprostřed.
            anchor = "w" if col.lower() in (
                "command_title", "last_result", "result_message", "short_message",
                "suggested_fix", "recommended_action", "next_action", "sport_name", "provider"
            ) else "center"

            tree.column(
                col,
                width=width,
                minwidth=50,
                anchor=anchor,
                stretch=(col.lower() in ("command_title", "last_result", "result_message", "short_message", "suggested_fix", "next_action"))
            )

        for row in rows:

            vals = []
            txt = ""

            for c in cols:
                v = row.get(c, "")

                v = self.format_table_cell_value_v19(c, v)
                safe_v = self.safe_tree_display_value_v19_9(c, v)

                vals.append(v)
                txt += str(safe_v).upper()

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

            # V19.10: do Treeview nedáváme plné dlouhé logy.
            # Dlouhé texty v DB (hlavně last_result/log_tail) umí na Windows zaseknout Tkinter.
            # Proto se v tabulce zobrazí krátká verze; technický detail zůstává v DB/PC2 historii.
            display_values = [
                self.safe_tree_display_value_v19_9(c, v)
                for c, v in zip(cols, vals)
            ]

            tree.insert("", "end", values=display_values, tags=(tag,))

        # V18.4 ACTIVE ONLY: auto-resize po každém refreshi je vypnutý.
        # Sloupce se nastaví při naplnění tabulky podle aktuálních dat.

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

        trees_to_check = []
        if hasattr(self, "system_events_tree"):
            trees_to_check.append(self.system_events_tree)
        else:
            for attr_name in ["alerts_tree", "feed_tree", "worker_health_tree"]:
                if hasattr(self, attr_name):
                    trees_to_check.append(getattr(self, attr_name))

        for tree in list(dict.fromkeys(trees_to_check)):
            for item in tree.get_children():
                values = tree.item(item, "values")
                row_text = " ".join(str(v).upper() for v in values)

                if "CRITICAL" in row_text or "FAILED_WORKER" in row_text or "AKTIVNÍ UPOZORNĚNÍ" in row_text:
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

    # =====================================================
    # V18.13 - RESPONZIVNÍ ROZVRŽENÍ
    # =====================================================

    def reflow_command_center(self):
        """
        V19.7 - STABLE UI / RYCHLÉ AKCE

        CO TO JE:
        - Horní přehled je ztenčený, ale rychlé globální akce jsou zpět.
        - Pravá lišta je pouze pro akce nad vybraným řádkem.
        - Rozložení: KPI -> hlavní oblasti -> priorita + AI -> rychlé akce.

        K ČEMU TO JE:
        - Uživatel má nahoře globální ovládání panelu.
        - Ve střední části vidí obsah.
        - Vpravo má akce jen pro vybraný řádek.
        """
        if not hasattr(self, "command_frame"):
            return

        mode = "v19_8_stable_ui_quick_actions_right"
        if getattr(self, "command_layout_mode", None) == mode:
            return

        self.command_layout_mode = mode

        for child in (
            getattr(self, "command_metrics_panel", None),
            getattr(self, "command_middle_panel", None),
            getattr(self, "priority_bar", None),
            getattr(self, "command_actions_panel", None),
        ):
            if child is not None:
                try:
                    child.grid_forget()
                except Exception:
                    pass

        for r in range(6):
            self.command_frame.rowconfigure(r, weight=0, minsize=0)
        for c in range(6):
            self.command_frame.columnconfigure(c, weight=0, minsize=0)

        self.command_frame.columnconfigure(0, weight=1)
        self.command_frame.columnconfigure(1, weight=1)
        self.command_frame.rowconfigure(0, weight=0)
        self.command_frame.rowconfigure(1, weight=0)
        self.command_frame.rowconfigure(2, weight=0)
        self.command_frame.rowconfigure(3, weight=0)

        # 1) KPI nahoře přes celou šířku.
        self.command_middle_panel.grid(
            row=0,
            column=0,
            columnspan=2,
            sticky="ew",
            padx=8,
            pady=(4, 1)
        )

        # 2) Stav hlavních oblastí jako jeden kompaktní řádek.
        self.command_metrics_panel.grid(
            row=1,
            column=0,
            columnspan=2,
            sticky="ew",
            padx=8,
            pady=(1, 1)
        )

        # 3) Dnešní priorita a AI doporučení vedle sebe.
        self.priority_bar.grid(
            row=2,
            column=0,
            columnspan=2,
            sticky="ew",
            padx=8,
            pady=(1, 2)
        )

        try:
            self.priority_bar.columnconfigure(0, weight=1, uniform="priority")
            self.priority_bar.columnconfigure(1, weight=1, uniform="priority")

            # Nadpis DOPORUČENÍ necháme nahoře, obě karty vedle sebe v jednom řádku.
            self.today_priority_text.master.grid_forget()
            self.ai_recommendation_text.master.grid_forget()

            self.today_priority_text.master.grid(
                row=1,
                column=0,
                sticky="nsew",
                padx=(0, 4),
                pady=2
            )
            self.ai_recommendation_text.master.grid(
                row=1,
                column=1,
                sticky="nsew",
                padx=(4, 0),
                pady=2
            )
        except Exception:
            pass

        # 4) V19.8: rychlé akce už nejsou pod KPI.
        # Jsou vpravo v PŘEHLEDU, aby tabulky měly více výšky.
        try:
            self.command_actions_panel.grid_forget()
        except Exception:
            pass

    def sync_content_canvas(self, event=None):
        """Udrží tabulkovou část stejně širokou jako viditelné okno a povolí svislý posun."""
        if not hasattr(self, "content_canvas"):
            return
        try:
            canvas_width = self.content_canvas.winfo_width()
            canvas_height = self.content_canvas.winfo_height()
            content_height = max(canvas_height, 760)
            self.content_canvas.itemconfigure(self.content_window_id, width=canvas_width, height=content_height)
            self.content_area.configure(width=canvas_width, height=content_height)
            self.update_content_scrollregion()
        except Exception:
            pass

    def update_content_scrollregion(self, event=None):
        if not hasattr(self, "content_canvas"):
            return
        try:
            self.content_canvas.configure(scrollregion=self.content_canvas.bbox("all"))
        except Exception:
            pass

    def scroll_content_mousewheel(self, event):
        if not hasattr(self, "content_canvas"):
            return
        try:
            self.content_canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
        except Exception:
            pass

    def reflow_bottom_tabs(self):
        """V19: levá navigace. Jedna položka na řádek, žádné spodní zalamování."""
        if not hasattr(self, "bottom_tab_buttons"):
            return

        try:
            for btn in self.bottom_tab_buttons:
                btn.grid_forget()

            for c in range(4):
                self.bottom_tabs.columnconfigure(c, weight=0)
            self.bottom_tabs.columnconfigure(0, weight=1)

            # sekční mezery v levé navigaci
            section_breaks = {
                "PC2 COMMAND": "DENNÍ PROVOZ",
                "DASHBOARD": "KONTROLA",
                "HARVEST": "DATOVÉ VRSTVY",
                "PROVIDERS": "ZDROJE / ŘÍZENÍ",
                "DOCUMENTATION": "DOKUMENTACE",
                "ARCHITECTURE": "PROJEKT",
            }

            row = 0
            for btn in self.bottom_tab_buttons:
                tab_name = getattr(btn, "_tab_name", "")
                if tab_name in section_breaks:
                    lbl = getattr(btn, "_section_label", None)
                    if lbl is None:
                        lbl = tk.Label(
                            self.bottom_tabs,
                            text=section_breaks[tab_name],
                            bg="#0d0716",
                            fg="#8f7ca3",
                            font=("Segoe UI", 7, "bold"),
                            anchor="w"
                        )
                        btn._section_label = lbl
                    lbl.grid(row=row, column=0, sticky="ew", padx=8, pady=(10, 2))
                    row += 1

                btn.grid(row=row, column=0, sticky="ew", padx=6, pady=2)
                row += 1

            self.bottom_tabs.configure(width=230)

        except Exception:
            pass

    def create_command_kpi_tile(self, parent, column, title, value, color, subtitle=""):
        """
        V18.13 - OPS KPI dlaždice.
        Menší než původní bloky, ale širší a s grafickým pruhem.
        """
        frame = tk.Frame(parent, bg="#100918", highlightbackground="#24182f", highlightthickness=1)
        frame.grid(row=0, column=column, sticky="nsew", padx=2, pady=1)
        frame.columnconfigure(1, weight=1)

        dot = tk.Canvas(frame, width=9, height=9, bg="#100918", highlightthickness=0, bd=0)
        dot.grid(row=0, column=0, sticky="n", padx=(6, 4), pady=(7, 0))
        dot.create_oval(1, 1, 8, 8, fill=color, outline=color)

        tk.Label(
            frame,
            text=title,
            bg="#100918",
            fg="#d8b4fe",
            font=("Segoe UI", 6, "bold"),
            anchor="w"
        ).grid(row=0, column=1, sticky="ew", padx=(0, 4), pady=(3, 0))

        lbl = tk.Label(
            frame,
            text=value,
            bg="#100918",
            fg="white",
            font=("Segoe UI", 10, "bold"),
            anchor="w"
        )
        lbl.grid(row=1, column=1, sticky="ew", padx=(0, 4), pady=(0, 1))

        tk.Label(
            frame,
            text=subtitle,
            bg="#100918",
            fg="#8f7ca3",
            font=("Segoe UI", 5, "bold"),
            anchor="e"
        ).grid(row=0, column=2, rowspan=2, sticky="e", padx=(2, 5))

        graph = tk.Canvas(frame, height=4, bg="#100918", highlightthickness=0, bd=0)
        graph.grid(row=2, column=0, columnspan=3, sticky="ew", padx=6, pady=(0, 4))

        for widget in (frame, dot, lbl, graph):
            widget.bind("<Button-1>", lambda event, t=title, s=subtitle: self.open_kpi_help(t, s))
            widget.configure(cursor="hand2")

        handle = KpiValueHandle(lbl, graph, color, title)
        handle.config(text=value)
        return handle

    def create_bottom_tab(self, icon, name):

        display_name = TAB_LABELS.get(name, name)

        btn = tk.Button(
            self.bottom_tabs,
            text=f"{icon}  {display_name}",
            bg="#14081d",
            fg="#e9d5ff",
            activebackground="#9333ea",
            activeforeground="white",
            relief="flat",
            bd=0,
            font=("Segoe UI", 9, "bold"),
            anchor="w",
            padx=10,
            pady=8,
            command=lambda n=name: self.show_tab(n)
        )
        btn._tab_name = name
        btn.bind("<Button-3>", lambda event, n=name: self.open_tab_help(n))
        btn.bind("<Double-1>", lambda event, n=name: self.open_tab_help(n))

        if not hasattr(self, "bottom_tab_buttons"):
            self.bottom_tab_buttons = []

        self.bottom_tab_buttons.append(btn)
        self.tabs[f"{name}_button"] = btn
        self.reflow_bottom_tabs()


    def update_right_action_sidebar_mode(self, tab_name):
        """
        V19.8 - přepínání pravé lišty podle obrazovky.

        PŘEHLED:
        - vpravo jsou globální rychlé akce panelu.

        DENNÍ PRÁCE:
        - vpravo jsou akce nad vybraným řádkem.

        Ostatní obrazovky:
        - pravá lišta se skryje, aby tabulky dostaly více místa.
        """
        try:
            side = getattr(self, "global_pc2_action_side", None)
            if side is None:
                return

            quick_frame = getattr(self, "global_quick_actions_side", None)
            row_widgets = getattr(self, "global_pc2_row_action_widgets", [])

            if tab_name == "DASHBOARD":
                try:
                    side.pack(fill="y", side="right", padx=(4, 8), pady=(4, 6), before=self.content_outer)
                except Exception:
                    try:
                        side.pack(fill="y", side="right", padx=(4, 8), pady=(4, 6))
                    except Exception:
                        pass

                for widget in row_widgets:
                    try:
                        widget.grid_remove()
                    except Exception:
                        pass
                if quick_frame is not None:
                    quick_frame.grid(row=0, column=0, sticky="nsew")

            elif tab_name == "PC2 COMMAND":
                try:
                    side.pack(fill="y", side="right", padx=(4, 8), pady=(4, 6), before=self.content_outer)
                except Exception:
                    try:
                        side.pack(fill="y", side="right", padx=(4, 8), pady=(4, 6))
                    except Exception:
                        pass

                if quick_frame is not None:
                    quick_frame.grid_remove()
                for widget in row_widgets:
                    try:
                        widget.grid()
                    except Exception:
                        pass

            else:
                if quick_frame is not None:
                    quick_frame.grid_remove()
                for widget in row_widgets:
                    try:
                        widget.grid_remove()
                    except Exception:
                        pass
                try:
                    side.pack_forget()
                except Exception:
                    pass

        except Exception:
            pass

    def show_tab(self, name):

        # V19: velký horní dashboard se zobrazuje pouze v PŘEHLED.
        # Na denní práci, problémech a detailech necháváme co nejvíce místa pro operaci.
        try:
            if hasattr(self, "command_frame"):
                self.command_frame.pack_forget()
                if name == "DASHBOARD":
                    self.command_frame.pack(fill="x", padx=8, pady=(2, 4), before=self.content_outer)
        except Exception:
            pass

        for key, frame in self.tabs.items():
            if isinstance(frame, tk.Frame):
                frame.lower()

        self.tabs[name].lift()
        self.current_tab = name
        self.update_right_action_sidebar_mode(name)

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

        if name == "SPORT COMPLETION":
            self.load_sport_completion_dashboard()

        if name == "ODDS":
            self.load_odds_dashboard()

        if name == "PROVIDERS":
            self.load_providers_dashboard()

        if name == "PROVIDER MATRIX":
            self.load_provider_matrix_dashboard()

        if name == "MEDIA":
            self.load_media_dashboard()

        if name == "ARCHITECTURE":
            self.load_architecture_dashboard()

        if name == "GOVERNANCE":
            self.load_governance_dashboard()

        if name == "DOCUMENTATION":
            self.load_documentation_dashboard()

        if name == "PC2 COMMAND":
            # V19.11: načti denní práci až po překreslení UI, aby Windows neoznačil panel jako Neodpovídá.
            self.after_idle(self.load_pc2_command_center)

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
