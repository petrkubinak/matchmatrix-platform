MATCHMATRIX – ZÁPIS (2026-04-07)
🎯 HLAVNÍ CÍL DNES

Dotáhnout people vrstvu (coaches + players) do stavu:

použitelná pro orchestrátor
jasně auditovaná
oddělené: READY vs BLOCKED vs WAIT_PROVIDER
✅ 1. FB COACHES – DOKONČENO
Stav
FB | coachs | DONE | READY
Co jsme udělali
✔ vytvořen worker: run_api_football_coaches_ingest_v1.py
✔ napojen DB connection (.env fix)
✔ opraveny runtime chyby:
DB_DSN parsing
missing BASE_URL
missing PROVIDER
✔ ingest do staging.stg_provider_coaches
✔ merge do:
public.coaches
coach_provider_map
team_coach_history
Výsledek
data existují
mapping funguje
career historie funguje (multi-team)
Identifikovaný gap (NEkritický)
Chybí:
- start_date / end_date (částečně)
- league_id
- season
- přesnější current flag

👉 To je ENRICHMENT, ne blocker

⚠️ 2. FB PLAYERS – ANALÝZA
Stav
FB | players | PARTIAL | NEAR_READY
Výsledek auditu
Completion audit
Není plné coverage + složitý harvest
→ potřeba definovat liga/sezona model
Staging
prázdné ❌

👉 znamená:

ingest NEBĚŽÍ
pipeline není aktivní
Public
1490 hráčů

👉 historicky existují, ale:

nejsou aktuálně ingestované
nejsou pod kontrolou pipeline
Provider map
api_football → 1490

👉 mapping existuje

Preview
prázdné ❌
🧠 KLÍČOVÝ ZÁVĚR (VELMI DŮLEŽITÉ)
FB PLAYERS stav:
DATA EXISTUJÍ (public)
ALE
PIPELINE NEEXISTUJE (staging + ingest)

👉 přesně stejný problém, jaký byl u coaches ráno

🔥 ARCHITEKTURÁLNÍ STAV
FB sport
fixtures ✅ READY
odds     ✅ READY (s výhradou linkeru)
coaches  ✅ READY
players  ⚠️ NEAR_READY (chybí ingest)
Sport summary
FB → SPORT_READY (po players fixu bude 100%)
HK → SPORT_NEAR_READY
BK → SPORT_NEAR_READY
VB → SPORT_NEAR_READY
🚨 HLAVNÍ PROBLÉM DNES
❗ FB PLAYERS = CHYBÍ INGEST

Stejný pattern jako coaches:

provider → EXISTUJE
endpoint → EXISTUJE
data → EXISTUJÍ

ALE:

worker ❌
staging ❌
planner ❌
🧭 CO BUDEME DĚLAT ZÍTRA (PŘESNĚ)
🔥 KROK 1 (hlavní)

Postavit FB PLAYERS INGEST

→ přesně stejný model jako coaches:

run_api_football_players_ingest_v1.py
🔧 KROK 2

Napojení:

API → staging.stg_provider_players → public.players
🔧 KROK 3

Rozhodnutí harvest strategie:

per:
- league
- season

(protože players jsou heavy)

🔧 KROK 4

Napojení do:

player_provider_map
🧩 STRATEGICKÝ POSUN

Dnešek byl zásadní:

PŘED DNES
people vrstva = nejasná / rozbitá
PO DNES
coaches = hotovo
players = jasně definovaný gap
📌 FINÁLNÍ STAV DNES
FB coaches → DONE ✅
FB players → READY TO BUILD INGEST ⚠️

Platform:
→ připravená na dokončení people layer
→ orchestrátor může přijít až PO players
🔚 TL;DR

👉 Coaches:

vyřešeno end-to-end

👉 Players:

data máme
pipeline nemáme

👉 Další krok:

POSTAVIT PLAYERS INGEST (copy pattern coaches)

Až otevřeš nový chat, stačí napsat:

jedeme FB players ingest

a jdeme přesně dál bez ztráty kontextu 🚀