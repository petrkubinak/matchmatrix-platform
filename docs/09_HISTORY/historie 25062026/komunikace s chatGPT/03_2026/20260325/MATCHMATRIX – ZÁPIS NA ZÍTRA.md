MATCHMATRIX – ZÁPIS NA ZÍTRA
🔥 Stav projektu (po dnešku)
✅ HOTOVO
Players pipeline (football) plně funkční v panelu V9
Opraveno:
fetch (batch mode bez RunId)
parse (season stats správný parser)
bridge (players_import → staging)
merge players → public
merge season stats → public
Pipeline běží end-to-end bez chyby
📊 Aktuální data
public.players: ~1480
public.player_provider_map: ~1480
public.player_season_statistics: ~1060
staging stats: ~36k+
🧠 Klíčový posun

👉 Máme hotovou první kompletní entitu:

PLAYERS (včetně statistik)

👉 Teď přecházíme na:

RELACE MEZI ENTITAMI (vyšší logika systému)
🎯 CÍL NA ZÍTRA
🔥 HLAVNÍ PRIORITA:
👉 COACHES + TEAM_COACH_HISTORY
🧩 Proč

Chybí ti klíčová vazba:

hráč → tým → trenér → čas

Bez toho:

❌ není coach rating
❌ není vývoj hráče pod trenérem
❌ není advanced analytika
🧩 Co budeme dělat
1️⃣ Analýza zdroje dat

Zjistíme:

odkud bereme trenéry
jestli máme:
/coaches endpoint
nebo trenéry v match/lineups
2️⃣ Návrh DB struktury

Vytvoříme:

public.team_coach_history
případně:
public.coach_career
3️⃣ Staging vrstva
staging.stg_provider_coaches   (už máš ✔)

doplníme logiku pro:

team ↔ coach ↔ období
4️⃣ Pipeline

Postavíme:

pull_coaches
→ parse
→ staging
→ public merge
→ team_coach_history
5️⃣ Napojení na existující data

Propojíme:

players
+ player_team_history
+ team_coach_history
🚀 Výsledek zítřka

Po zítřku budeš mít:

✔ trenéry v systému
✔ historii trenérů u týmů
✔ základ pro coach rating
✔ základ pro player development tracking
⚠️ Důležité pravidlo (držet se)

👉 NE:

nepřidávat nové sporty
neřešit UI
neřešit ML

👉 ANO:

budovat CORE vrstvu (50 let historie)
🧭 Plán dne (rychlý start ráno)
napíšeš „jedeme“
já ti:
navrhnu SQL tabulku team_coach_history
ty:
vytvoříš v DB (DBeaver)
pokračujeme pipeline
🔥 Shrnutí jednou větou

👉 Dnes jsme postavili hráče
👉 Zítra postavíme trenéry a vazby
👉 Tím začíná skutečný MatchMatrix