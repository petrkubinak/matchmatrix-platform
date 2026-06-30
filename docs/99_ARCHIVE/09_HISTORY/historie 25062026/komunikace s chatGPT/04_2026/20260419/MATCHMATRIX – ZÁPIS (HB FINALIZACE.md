MATCHMATRIX – ZÁPIS (HB FINALIZACE / AUTOMAT HARVEST PŘÍPRAVA)
📅 Stav k dnešku
✅ HANDball (HB) – CORE HOTOVO

Máme potvrzený kompletní core chain:

✅ leagues → CONFIRMED
✅ teams → CONFIRMED
✅ fixtures → CONFIRMED (včetně public.matches)

Důkaz z runtime auditu:

leagues: 24881, 24882, 24883
fixtures: 132 / 168 / 48 zápasů v public.matches
teams + provider_map plně napojené

➡️ HB je plně funkční na úrovni dat

⚠️ HLAVNÍ PROBLÉM
❗ Orchestrace (planner/scheduler) nefunguje

Log:

Planner queue je prázdná
Processed jobs: 0

➡️ znamená:

planner nevidí žádné joby
ingest_cycle V3 nic nespustí
systém není připravený na automatický harvest
🔎 ROOT CAUSE

HB má:

✔ ingest_entity_plan definovaný
✔ provider coverage OK
✔ runtime audit CONFIRMED

ALE:

👉 planner nemá targety / queue

🎯 CÍL

Dostat HB do stavu:

ingest_cycle_v3
→ planner najde joby
→ spustí ingest
→ merge do public
→ běží automaticky

➡️ tedy:

HB = plně automatický harvestr (stejný jako FB/BK/VB/AFB)

🧱 CO UŽ JE HOTOVÉ (DŮLEŽITÉ)

HB má správně:

entity:
leagues
teams
fixtures
odds (prepared)
run_group: HB_CORE
scope: league + season

➡️ architektura je správná, chybí jen orchestrace

🚀 DALŠÍ KROK (NAVAZUJEME TÍMTO)
🔴 KROK 1 – ZPROVOZNIT PLANNER QUEUE PRO HB

👉 To je jediná věc, která blokuje automat

Co přesně uděláme:
1️⃣ Zkontrolujeme ingest_targets
SELECT *
FROM ops.ingest_targets
WHERE sport_code = 'HB';

👉 očekáváme:

league_id (131, 145, 183)
season = 2024
run_group = HB_CORE
2️⃣ Pokud tam nejsou → vytvoříme je

➡️ připravíme INSERT script

3️⃣ Ověříme planner

spustíš znovu:

python workers/run_ingest_cycle_v3.py --provider api_handball --sport HB --entity fixtures --run-group HB_CORE

👉 očekávaný výsledek:

Processed jobs: > 0
🧠 STRATEGICKÝ KONTEXT

Tímto krokem:

HB se dostane na úroveň:
BK ✅
VB ✅
AFB ✅
vznikne jednotný harvest pattern
📈 DALŠÍ KROKY (po tomto)
HB → stabilní batch běh
sjednocení všech sportů do:
jednoho scheduleru
jednoho harvest runu
příprava na:
PRO API → full data harvest
🔥 SHRNUTÍ PRO DALŠÍ CHAT

👉 Neřešíme už data (ty jsou OK)
👉 Řešíme orchestraci (planner)