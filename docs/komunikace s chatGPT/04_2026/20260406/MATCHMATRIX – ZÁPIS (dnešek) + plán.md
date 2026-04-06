MATCHMATRIX – ZÁPIS (dnešek) + plán na zítřek
🔥 1. Co jsme dnes dokončili (zásadní milník)
✅ TheOdds CLEANUP – FINÁLNÍ FÁZE DOKONČENA
✔️ 1.1 Alias + Team Identity
vyčištěny aliasy (diakritika, varianty, duplicity)
sjednoceny canonical týmy
potvrzeno:
Czech Republic → Czechia (117)
Sporting Cristal → CS Cristal (10991)
odstraněn vliv:
U18 / U20 týmů
špatných aliasů (např. Barcelona SC → Barcelona ❌)

👉 Výsledek: identity vrstva stabilní

✔️ 1.2 Safe Linker (ATTACH_NOW)

Implementováno:

přesné párování (home + away)
kontrola ligy (theodds_key)
jednoznačný match (COUNT = 1)
ochrany:
Atlético / Barcelona (competition guard)
Universidad Católica (edge)
Australia vs Jordan (source gap)

📊 Výsledek:

28 zápasů attachnuto
Libertadores: 18
World Cup: 5
Brazil: 3
Serie A: 2

👉 Toto je klíčový průlom – linker funguje správně

✔️ 1.3 Finální klasifikace backlogu
Bucket	Počet	Význam
PAIR_MISSING	33	chybí fixture v DB
COMPETITION_RISK	3	La Liga vs UCL
FALSE_POSITIVE_RISK	2	Barcelona SC
MAPPING_EDGE	2	Universidad Católica
MAPPING_GAP	2	(vyřešeno → linker edge)
SOURCE_GAP	2	Australia vs Jordan
🧠 KLÍČOVÝ ZÁVĚR DNES
❗ TheOdds problém už NENÍ:
alias ❌
team mapping ❌
merge ❌
✅ TheOdds problém JE:

👉 fixture coverage (PAIR_MISSING)

🧱 2. Stav systému po dnešku
Stabilní vrstvy:
✅ teams
✅ aliases
✅ provider mapping
✅ safe linker
Otevřené:
⚠️ missing matches (33)
⚠️ competition guard (3)
⚠️ edge cases (5–7)
🚀 3. STRATEGICKÝ POSUN
🔄 Dnes jsme uzavřeli:

👉 TheOdds CLEANUP větev

➡️ Zítra přecházíme na:

👉 DATA INGEST & COVERAGE (API)

To je přesně to, co jsi chtěl:

„hlavní směr bude API sport placený účet“

✔️ správně
✔️ timing ideální
✔️ systém připravený

🧭 4. PLÁN NA ZÍTŘEK (1 krok po kroku)
🎯 Cíl:

Vytvořit základ Mission_Control V11

🧱 4.1 Co má Mission_Control V11 dělat
Jednotný panel pro:
všechny sporty
všechny entity
řízení ingestu
📊 SPORTY (TVŮJ SET)
Code	Sport	API ready
FB	Football	✅
HK	Hockey	✅
BK	Basketball	⚠️
TN	Tennis	❌
MMA	MMA	❌
DRT	Darts	❌
VB	Volleyball	⚠️
HB	Handball	⚠️
BSB	Baseball	⚠️
RGB	Rugby	⚠️
CK	Cricket	⚠️
FH	Field Hockey	⚠️
AFB	American Football	⚠️
ESP	Esports	❌
🧩 4.2 Architektura panelu
Panel bude řídit:
1️⃣ ENTITY
leagues
teams
fixtures
(players – jen FB)
2️⃣ PROVIDER
api_football
api_sport
football_data
(future: odds, players)
3️⃣ RUN CONTROL
RUN NOW
VALIDATE
SKIP
PRIORITY
4️⃣ STATUS
pending
running
done
error
⚙️ 4.3 Co zítra konkrétně uděláme
KROK 1 (jen jeden!)

👉 vytvoříme datový zdroj pro panel

📁 Soubor:
C:\MatchMatrix-platform\config\mission_control_v11_sources.sql
🎯 Obsah:
seznam sportů
seznam entity
mapping na provider
run_group logika
Co bude výstup:

Tabulka (view nebo config):

sport | entity | provider | run_group | enabled | priority
🧠 4.4 Jak to navazuje na dnešek

Dnes:

❌ řešili jsme následky (TheOdds mismatch)

Zítra:

✅ řešíme příčinu (chybějící fixtures)
🔥 5. Co bude výsledek po V11

Po implementaci:

nebude vznikat PAIR_MISSING
TheOdds bude attachovat automaticky
coverage půjde nahoru
Ticket Engine dostane více dat
🧩 6. Další roadmap (jen pro kontext)

Po V11:

ingest orchestrace
auto scheduler
coverage dashboard
API PRO backfill (10 sezon)
Ticket Engine v plném režimu
🟢 FINÁLNÍ SHRNUTÍ

Dnes:

dokončen TheOdds cleanup
linker validovaný
backlog rozdělen
identifikován root cause → missing fixtures

Zítra:

start Mission_Control V11
první krok → config / source table
👉 Další krok (hned zítra)

Napiš:

„jedeme V11 krok 1“

a já ti dám:

přesný SQL
kam uložit
jak spustit
jak to napojit do panelu

🔥 Dnešek byl jeden z nejdůležitějších milníků celého projektu.