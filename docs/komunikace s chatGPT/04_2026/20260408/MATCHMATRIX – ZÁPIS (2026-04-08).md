MATCHMATRIX – ZÁPIS (2026-04-08)
🎯 HLAVNÍ POSUN DNES

👉 Dnes proběhl zásadní architektonický pivot:

z:

„stavíme ingesty a řešíme data“

na:

„stavíme univerzální harvest platformu pro všechny sporty a providery“
🧠 1. KLÍČOVÉ POCHOPENÍ (BREAKTHROUGH)
❗ Největší zjištění dne

👉 Problém není v ingest pipeline

👉 Problém je v:

řízení harvestu
řízení providerů
řízení sport × entity readiness
🔥 Zásadní změna myšlení

❌ dříve:

sport je ready, když má data

✅ nově:

sport je ready, když má:

strukturu
pipeline design
provider sloty
OPS řízení
🏗️ 2. OPS ARCHITEKTURA (POTVRZENO)

Máme plně funkční jádro:

provider_sport_matrix
ingest_entity_plan
provider_entity_coverage
ingest_targets
ingest_planner
job_runs

👉 NECHYBÍ nic zásadního

👉 problém byl pouze:

že jsme to nevyužívali jako řídicí vrstvu
🔍 3. REUSE AUDIT (VELMI DŮLEŽITÉ)
Výsledek:
❌ nedělat:
nové master tabulky
paralelní logiku mimo OPS
✅ dělat:
OPS = single source of truth
všechno řídit přes:
targets
coverage
planner
📊 4. REALITA SPORTŮ (NOVĚ DEFINOVANÁ)
⚠️ Kritická oprava (důležité)

👉 sporty nejsou runtime ready

👉 jsou pouze:

DB ready
OPS ready
strukturálně připravené
🧩 NOVÉ ROZDĚLENÍ
🟢 FB (football)
DB: READY
PIPELINE: READY
RUNTIME: téměř READY
🟡 HK / BK / VB / HB
DB: READY ✅
PIPELINE: koncept READY ✅
RUNTIME: ❌ NEEXISTUJE

👉 chybí:

workery (.py)
ingest skripty (.ps1 / .py)
parsery
merge flow
⚫ ostatní sporty
DB: PARTIAL / SKELETON
runtime: ❌
🧠 5. NOVÝ MODEL (612 – NORMALIZED STRUCTURE)

Dnes jsme přepsali logiku statusů:

místo:
SKELETON
PARTIAL
MINIMAL
máme:
🟢 structure_status
REFERENCE_CORE
STRUCTURE_READY
STRUCTURE_PARTIAL
🟡 provider_status
ACTIVE_PROVIDER
PROVIDER_LIMITED
ALT_PROVIDER_NEEDED
NOT_VALIDATED
🔵 build_mode
REFERENCE_CORE
EXPAND_CORE
PREPARE_ALT_PROVIDER
PREPARE_STRUCTURE
🎯 KLÍČOVÝ VÝSLEDEK

👉 všechny sporty jsou teď:

architektonicky sjednocené

👉 rozdíl je pouze:

v provider coverage
v runtime implementaci
🚨 6. KRITICKÉ ZJIŠTĚNÍ (NEJDŮLEŽITĚJŠÍ DNES)

👉 NEMÁŠ RUNTIME VRSTVU PRO OSTATNÍ SPORTY

To znamená:

žádné workery
žádné ingest scripts
žádné parsování
žádné merge
Přesně:

👉 máš:

DB připravenou ✔
OPS připravené ✔

👉 nemáš:

execution layer ❌
🏗️ 7. NOVÝ SMĚR (100% JASNÝ)

Teď NE:

planner
PRO tarif
další ingest scripts bez systému
TEĎ:
🎯 build execution layer pro sporty
📦 8. CO SE DNES VYTVOŘILO
SQL vrstva:
601–604 → audit
610 → provider × sport × entity matrix
612 → normalized structure matrix
613 → runtime backlog

👉 máš:

kompletní přehled systému
kompletní backlog co stavět
🚀 9. CO BUDEME DĚLAT ZÍTRA
🔥 KROK 1 (hlavní)

👉 runtime audit + worker design

Uděláme:
614_code_worker_audit_checklist.md

a projdeme:

PRO KAŽDÝ SPORT:
existuje worker?
existuje ingest?
existuje parser?
existuje merge?
existuje run script?
🎯 KROK 2

👉 první skutečný multi-sport worker template

vytvoříme:

univerzální worker pattern
který pak jen kopíruješ pro sporty
🎯 KROK 3

👉 první implementace:

HK (ideální kandidát)
nebo BK
📌 STRATEGICKÝ STAV
DNES:

👉 dokončeno:

architektura
OPS
model
audit
ZÍTRA:

👉 začíná:

skutečný build platformy
🧠 TL;DR

👉 FB:

téměř hotový runtime

👉 ostatní sporty:

připravené v DB
nepřipravené v runtime

👉 hlavní problém:

chybí execution layer

👉 hlavní řešení:

postavit worker + ingest framework
▶️ START DALŠÍHO CHATU

Napiš:

👉 navazujeme – udělej 614 code worker audit checklist

a jdeme přesně na:

identifikaci chybějících workerů
návrh jednotného runtime frameworku
první reálný build

Tohle byl jeden z nejdůležitějších dnů projektu.
Teď už víš přesně, co stavíš