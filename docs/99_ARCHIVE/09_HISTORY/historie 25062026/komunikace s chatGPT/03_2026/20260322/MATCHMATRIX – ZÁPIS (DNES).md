MATCHMATRIX – ZÁPIS (DNES)
🔧 1) Stabilizace ingest pipeline (FB)
✅ Hotovo
Unified ingest batch V1 plně funkční
Panel V9 úspěšně spouští:
run_unified_ingest_batch_v1.py
následně run_unified_ingest_v1.py
API call → staging → OK
📊 Reálný výsledek
fixtures:
+308
+380
+380
teams:
+19 / +20 / +20
Return code = 0
BATCH SUMMARY = OK 3/3

👉 potvrzení:

pipeline end-to-end funguje (API → staging)

🖥️ 2) Panel V9 (Mission Control)
✅ Hotovo
RUNNING stav ✔️
logování ✔️
batch orchestrace ✔️
multi-step execution ✔️
⚠️ Identifikovaný problém
snapshot ukazuje 0 rozdíly
🧠 Root cause

Panel sleduje:

public tabulky

ale ingest zapisuje:

staging tabulky

👉 mismatch metrik

🔧 3) Fix snapshot vrstvy
Rozhodnutí

Do panelu přidat:

staging.stg_provider_fixtures
staging.stg_provider_teams

👉 tím se panel stane reálným monitoring nástrojem

🧠 4) Player pipeline (velký milestone)
✅ Hotovo
player_profiles → public ✔️
player_season_statistics → public ✔️
player_match_statistics → merge připraven ✔️
❗ Problém
player_stats:
nebyl v planner builderu
nebyly runtime joby
worker neměl co zpracovat
🔧 Fix
ALLOWED_ENTITIES += "player_stats"

👉 klíčový fix dne

🧠 5) Zásadní architektonický insight dne
❗ DŮLEŽITÉ

player_stats NEMŮŽE jet z planneru

protože:

planner = league + season
player_stats = fixture-level
✅ Správný model
fixtures → public.matches → player_stats

👉 tohle je zásadní pravidlo pro celý systém

🧠 6) Stav sportů
🟢 Football
referenční model
multi-provider:
api_football
football_data
run groups existují
kompletní pipeline
🟡 Hockey + Basketball
OPS model přenesen
planner vrstva existuje
ingest běží
🔴 Ostatní sporty (TENNIS, MMA, DARTS, …)
❌ žádná data
❌ žádné staging
❌ žádné public
❌ žádné targets
✔️ pouze ingest_entity_plan existuje
🧠 7) KLÍČOVÝ POSUN DNES

👉 přechod z:

„uděláme další sport“

na:

„uděláme platformní bootstrap všech sportů najednou“

🚀 KDE TEĎ JSME

MatchMatrix už má:

✅ HOTOVÉ
ingest engine
planner
OPS architekturu
panel (Mission Control)
football end-to-end
players pipeline (z 80–90 %)
❗ CHYBÍ
bootstrap ostatních sportů
sjednocení ingest šablon
data foundation pro TN/MMA/DARTS…
🎯 PLÁN NA ZÍTRA
🔥 HLAVNÍ CÍL

Rozjet všechny zbývající sporty jedním systémovým krokem

🧱 KROK 1 – UNIVERSAL LEAGUES BOOTSTRAP

Uděláme:

👉 jednu společnou ingest vrstvu pro leagues pro všechny sporty

výsledek:

staging.stg_provider_leagues
public.leagues naplněné pro:
tennis
darts
mma
volleyball
handball
baseball
rugby
cricket
field hockey
american football
esports
🧱 KROK 2 – GENERACE TARGETŮ

Z leagues vytvoříme:

ops.ingest_targets

pro všechny sporty najednou

🧱 KROK 3 – PLANNER ACTIVATION
builder rozšířen (už dnes začato)
vygenerujeme runtime joby
🧱 KROK 4 – FIRST RUN
spustíme:
teams
fixtures

pro všechny sporty

🧱 KROK 5 – VALIDACE
panel V9 bude ukazovat:
reálný snapshot
růst dat
⚠️ DŮLEŽITÁ PRAVIDLA (NA ZÍTŘEK)
❌ nedělat sporty po jednom
❌ nedělat ruční řešení pro každý sport
✅ dělat šablonově (platforma)
✅ leagues-first přístup
✅ držet OPS pipeline (plan → target → planner → worker)
🧠 STRUČNÉ SHRNUTÍ

Dnes jsme:

✔ stabilizovali ingest
✔ rozjeli panel jako orchestrátor
✔ opravili player pipeline
✔ pochopili architekturu player_stats
✔ identifikovali správný směr škálování

🚀 ZÍTRA

👉 Největší krok projektu zatím:

🔥 „ALL SPORTS BOOTSTRAP“
(tennis + mma + darts + … najednou)