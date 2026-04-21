MATCHMATRIX – ZÁPIS (HB DOKONČENO)
🎯 Stav: HAND BALL (HB) – CORE PIPELINE HOTOVO
✅ FINAL STATUS
HB | leagues → CONFIRMED
HB | teams → CONFIRMED
HB | fixtures → CONFIRMED
sport_completion_audit:
HB | core | core_pipeline | DONE | READY
🧱 Pipeline (HB)
✔️ Orchestrace
run_ingest_cycle_v3.py
run_ingest_planner_jobs.py
run_unified_ingest_v1.py
run_unified_staging_to_public_merge_v3.py
✔️ Entities
leagues → plně funkční
fixtures → plně funkční

teams → řešeno přes fallback:

fixtures → extract_teams → stg_provider_teams → public.team_provider_map
📊 DB Evidence
🔹 Matches
public.matches api_handball = 2517
FINISHED = 2468
SCHEDULED = 38
CANCELLED = 11
🔹 Teams
public.team_provider_map api_handball = 752
missing_team_map = 0 ✅
🔹 Leagues
public.leagues api_handball = 31
⚙️ Klíčové řešení (IMPORTANT)
❗ HB specifikum
API /teams endpoint má nulovou / nedostatečnou coverage
finální řešení:
teams = extract z fixtures (fallback)

👉 To je:

potvrzené
stabilní
zapsané v auditu
🧠 Architektura (sjednocený pattern)

HB nyní běží stejně jako:

✅ BK (basketball)
✅ VB (volleyball)
✅ AFB (american football)

Pattern:

planner → ingest → raw → staging → merge → public → audit
📌 Co je HOTOVO
ingest cycle orchestrace
planner queue
fixtures ingest
teams fallback + mapping
merge do public
audit zápisy (runtime + completion)
🚀 Další krok (NAVAZUJEME ZDE)

Teď už nejdeme zpět na HB core — to je uzavřené.

➤ DALŠÍ LOGICKÝ STEP:

Vybereme JEDEN z těchto směrů:

1️⃣ ODDS (doporučeno)
napojení HB na theodds / jiný provider
linker na public.matches
stejný pattern jako FB
2️⃣ PEOPLE (players / coaches)
připravit staging + merge
řešit provider (API-SPORT nemá)
3️⃣ DALŠÍ SPORT (např. BSB baseball)
aplikovat ověřený pattern z HB
⚠️ DŮLEŽITÉ PRO DALŠÍ CHAT
HB NEŘEŠIT znovu
pipeline je:
funkční
auditovaná
potvrzená

👉 navazujeme DALŠÍ vrstvou systému