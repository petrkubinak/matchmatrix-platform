MATCHMATRIX – ORCHESTRACE INGESTU (REALITA SYSTÉMU)
🎯 1. CO TEN SYSTÉM VE SKUTEČNOSTI DĚLÁ

Cílem není „stáhnout data“.

Cílem je:

TARGET → QUEUE → RUN → PULL → RAW → STAGING → PROVIDER → MERGE → PUBLIC → AUDIT

Tohle je end-to-end pipeline, která odpovídá architektuře projektu: ingest vrstva → DB → další vrstvy systému.

🧩 2. HLAVNÍ KOMPONENTY (DB + CODE)
🟦 A) DEFINICE PRÁCE
ops.ingest_targets

👉 říká:

CO se má stahovat

Obsahuje:

sport (FB, BK, VB, …)
provider (api_football, api_volleyball, …)
league + season
enabled
run_group

📌 To je zdroj pravdy pro plánování

🟨 B) FRONTA
ops.scheduler_queue

👉 říká:

CO se má TEĎ spustit

Stavy:

pending ← čeká
selected ← vzato workerem
running
done
error

📌 To je reálný orchestrátor

🟩 C) LOG BĚHŮ
ops.job_runs

👉 říká:

CO se skutečně spustilo

Obsahuje:

job_code
status
started_at, finished_at
message

📌 To je execution log

🟥 D) REALITA SYSTÉMU
ops.runtime_entity_audit

👉 říká:

JAK NA TOM DOOPRAVDY JSME

Obsahuje:

pull_confirmed
raw_confirmed
staging_confirmed
public_merge_confirmed
current_state

📌 To je source of truth pro kvalitu ingestu

⚙️ 3. ORCHESTRACE – KROK ZA KROKEM
🔹 KROK 1 – TARGET EXISTUJE

ops.ingest_targets

Např:

VB | fixtures | league 97 | season 2024

👉 říká:
➡️ tohle chceme stahovat

🔹 KROK 2 – VZNIKNE QUEUE

scheduler_queue

status = pending

👉 připraveno ke spuštění

🔹 KROK 3 – BATCH RUNNER
run_unified_ingest_batch_v1.py

👉 udělá:

vybere pending
označí jako selected
pustí run_unified_ingest_v1.py
🔹 KROK 4 – UNIFIED INGEST
run_unified_ingest_v1.py

👉 klíčový dispatcher:

provider + sport + entity → konkrétní script

Např:

api_volleyball + fixtures
→ pull_api_sport_fixtures.ps1
🔹 KROK 5 – PULL LAYER

👉 .ps1 script

API → uloží RAW payload

výstup:

data/raw + staging.stg_api_payloads
🔹 KROK 6 – PARSE LAYER ❗

👉 převod:

RAW → staging.stg_provider_*

např:

stg_provider_teams
stg_provider_fixtures

⚠️ TADY JE TVŮJ HLAVNÍ PROBLÉM

🔹 KROK 7 – PROVIDER MAP

👉 mapování:

external_id → canonical_id
🔹 KROK 8 – MERGE
staging → public

např:

public.teams
public.matches
🔹 KROK 9 – AUDIT

runtime_entity_audit

vyhodnotí:

PAYLOAD_ONLY
STAGING_CONFIRMED
MERGE_CONFIRMED
🚨 4. CO JSI DNES ODHALIL (KRITICKÉ)
❌ 1. FALSE OK RUN

VB fixtures:

STATUS: OK

ALE:

proběhl jen pull
žádný parse
žádný merge

👉 fake success

❌ 2. BROKEN DISPATCH

VB players:

pull_api_sport_players.ps1 → NEEXISTUJE

👉 systém spadne

❌ 3. PARTIAL PIPELINE

BK teams:

RAW OK
stg_provider_teams = 0

👉 parser neběží

🧠 5. HLAVNÍ ARCHITEKTONICKÁ PRAVDA
❗ SYSTÉM NENÍ ROZBITÝ

✔ queue funguje
✔ targets fungují
✔ runner funguje
✔ DB funguje

❗ CHYBÍ EXECUTION LAYER

Konkrétně:

DISPATCH → PARSE → MERGE
🏗️ 6. SPRÁVNÝ DESIGN (TVŮJ DNEŠNÍ BREAKTHROUGH)
❌ ŠPATNĚ:
jeden univerzální parser
nebo každý sport úplně separátně
✅ SPRÁVNĚ:
HYBRID MODEL
🟦 SHARED
pull (API-Sport)
🟩 PER SPORT × ENTITY
parse
merge
🚀 7. REÁLNÝ FLOW (SPRÁVNÝ)
scheduler_queue (pending)
    ↓
batch runner
    ↓
unified ingest
    ↓
PULL (shared)
    ↓
PARSE (per sport/entity)
    ↓
STAGING
    ↓
MERGE
    ↓
PUBLIC
    ↓
AUDIT
🎯 8. CO JE TEĎ NEJDŮLEŽITĚJŠÍ
🔥 PRIORITA 1

👉 opravit dispatch

odstranit neexistující scripts
správně mapovat players
🔥 PRIORITA 2

👉 rozběhnout PARSE

BK teams
VB fixtures
VB players
🔥 PRIORITA 3

👉 validovat přes audit

stg_provider_* > 0
🧠 TL;DR

👉 pending = scheduler_queue
👉 systém běží správně
👉 targety jsou OK

❗ PROBLÉM:

execution layer (dispatch + parse)

👉 řešení:

per entity parser + správný dispatch
▶️ DALŠÍ KROK

Teď už jsme ready na fix.

Napiš:

👉 „pojďme opravit dispatch v run_unified_ingest_v1.py“

a jdeme rovnou:

konkrétní úprava kódu
přesný diff
kam uložit
jak otestovat (BK teams + VB players)