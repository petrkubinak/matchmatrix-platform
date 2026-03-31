MATCHMATRIX – NAVAZOVACÍ ZÁPIS (PLAYERS PIPELINE HOTOVÁ)

Projekt: MatchMatrix (planner-native ingest architektura)
Stav: Players pipeline (API-Football) plně funkční end-to-end (staging vrstva)

🔷 Kontext projektu
Orchestrátor: ops.ingest_planner
Runner: workers/run_ingest_planner_jobs.py
Architektura: planner-native (per entity execution)
DB vrstvy:
staging.stg_api_payloads (raw payloady)
staging.players_import (flatten import)
staging.stg_provider_player_profiles (parse výstup)
✅ CO JE HOTOVO
1) Planner → Players dispatch
planner správně claimuje joby:
provider = api_football
entity = players

dispatch:

run_players_fetch_only_v1.py
→ run_players_parse_only_v1.py
2) Fetch (V5 – Python)

Soubor:

ingest/API-Football/pull_api_football_players_v5.py
Funkce:
běží v single mode
bere parametry:
--league-id
--season
--run-id
--job-id
Ukládá:
raw payloady → staging.stg_api_payloads
import data → staging.players_import
Fixy:
odstraněn PowerShell
správný run_id
free plan page limit (max page=3) není chyba
doplněn photo_url
SQL odpovídá reálné DB
3) Parse wrapper

Soubor:

workers/run_players_parse_only_v1.py
volá parser
předává:
provider
sport
league_id
season
job_id
4) Parser (finální verze)

Soubor:

ingest/parse_api_football_player_profiles_v1.py
Klíčové opravy:

správný .env:

ingest/API-Football/.env

správný filtr:

entity_type = 'players'
AND (parse_status IS NULL OR parse_status = 'pending')
filtr podle:
league_id
season
Transformace:
height: "179 cm" → 179
weight: "72 kg" → 72
position: ze statistics.games.position ✔
Stabilita:
Unicode safe print
error handling per payload
commit/rollback OK
🔥 FINÁLNÍ PIPELINE
ops.ingest_planner
→ run_ingest_planner_jobs.py

→ run_players_fetch_only_v1.py
  → pull_api_football_players_v5.py
    → stg_api_payloads
    → players_import

→ run_players_parse_only_v1.py
  → parse_api_football_player_profiles_v1.py
    → stg_provider_player_profiles
📊 OVĚŘENÝ VÝSLEDEK

Test:

league: 88 (Eredivisie)
season: 2022

Výsledek:

Payloads to process: 4
DONE

DB:

COUNT(*) = 60

Sample:

S. Bonte         Cambuur            Goalkeeper
J. Helmer        AZ Alkmaar         Attacker
W. M. Janssen    Utrecht            Defender
...

✔ data jsou konzistentní
✔ pipeline stabilní
✔ žádné runtime chyby

🧠 KDE JSME

Players pipeline je:

✔ planner-native
✔ fetch OK
✔ parse OK
✔ staging provider profiles OK

👉 PRVNÍ PLNĚ FUNKČNÍ ENTITY V NOVÉ ARCHITEKTUŘE

🎯 DALŠÍ MOŽNÉ KROKY (vybereš 1)
Varianta A – MERGE VRSTVA

→ stg_provider_player_profiles → public.players

Varianta B – STABILIZACE
deduplikace players
unique keys
indexy
výkon
Varianta C – ROZŠÍŘENÍ
player stats
squads
player history
Varianta D – REPLIKACE NA DALŠÍ ENTITY
teams
leagues
fixtures
👉 INSTRUKCE PRO DALŠÍ CHAT

Stačí napsat:

Pokračujeme – players máme hotové, jdeme na další krok: [A/B/C/D]