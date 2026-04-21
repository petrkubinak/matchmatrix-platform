MATCHMATRIX – ZÁPIS (dnešek)
🎯 Hlavní cíl dne

Dokončení dalšího sportu do FULL CORE PIPELINE a nastavení směru pro další sporty.

🏁 RGB (RUGBY) – DOKONČENO
✅ Leagues
pull ✔
RAW ✔
staging ✔ (142)
public.leagues ✔ (142)
✅ Teams
pull ✔
RAW ✔
staging ✔ (6)
public.teams ✔ (6)
team_provider_map ✔ (6)
✅ Fixtures
pull ✔
RAW ✔
staging ✔ (15)
public.matches ✔ (15)
status mapping ✔ (Finished → FINISHED)
score casting ✔ (text → int)
🔥 RGB CORE PIPELINE
RGB | leagues   | CONFIRMED
RGB | teams     | CONFIRMED
RGB | fixtures  | CONFIRMED
RGB | core_pipeline | CONFIRMED

👉 RGB je nyní:

FULLY READY CORE SPORT
⚠️ Klíčové technické poznatky
1️⃣ API-Sports není jednotné

Každý sport má:

jiný endpoint naming (games vs fixtures)
jinou JSON strukturu

👉 Rugby:

id, date, teams, scores

👉 Football:

fixture, teams, goals
2️⃣ Parser musí být sport-specific

Nelze reuse 1:1 → nutná adaptace

3️⃣ Status mapping je kritický
Finished → FINISHED

jinak padá:

matches_score_status_chk
4️⃣ DB schéma není jednotné
teams nemá sport_id
fixtures staging má jiné názvy sloupců

👉 vždy kontrola přes information_schema

📊 Stav projektu po dnešku
✅ Core sporty hotové
BK
VB
AFB
HB
BSB
RGB 🔥 (dnes)
⚠️ Hold
CK (není provider)
🚀 Ready next
TN (Tennis)
MMA
🎾 TENNIS – ZAČÁTEK
✔ založeno
TN | leagues   | PLANNED
TN | fixtures  | PLANNED
TN | players   | PLANNED
✔ ingest targety existují
ATP
WTA
📘 NAVÁZÁNÍ (NOVÝ CHAT)
🎯 Start point

👉 Tennis pipeline

🔥 PRVNÍ KROK

Spustit:

cd C:\MatchMatrix-platform\ingest\API-Tennis

.\pull_api_tennis_leagues.ps1
🎯 Co budeme dělat
leagues pull
parser → staging
public.leagues
players (místo teams)
fixtures
matches merge
⚠️ POZOR u Tennis
není teams
místo toho:
players = core entita
🧠 Strategie dál
NE dělat:

❌ další sporty naslepo

ANO dělat:

✔ dokončit TN
✔ potom MMA
✔ potom ODDS layer

🏁 Shrnutí dne

👉 Dnes jsi:

dokončil kompletně nový sport (RGB)
vyřešil:
API rozdíly
parser adaptace
DB mapping
constrainty
dostal systém do stavu:
MULTI-SPORT CORE PLATFORM READY
🔚 Konec dne

👉 Zítra:

START: TENNIS PIPELINE

Když otevřeš nový chat, jen napiš:

navazujeme Tennis leagues pull

a jedeme rovnou bez vysvětlování 🚀