# MATCHMATRIX – MASTER NAVÁZÁNÍ

## 1. ÚČEL
Tento dokument je stálý referenční bod pro nové chaty a další práci.
Nejde o denní zápis.
Jde o hlavní pravdu o směru, struktuře a pravidlech projektu.

Použití:
- při přechodu do nového chatu
- při návratu po delší době
- při kontrole, zda jdeme správným směrem
- jako ochrana proti návratu do starších fází projektu

---

## 2. HLAVNÍ SMĚR PROJEKTU
MatchMatrix je:
- multisport datová platforma
- více-provider architektura
- ticket engine
- budoucí people vrstva
- budoucí media/highlights/comments vrstva

Základní princip:
- nesjednocujeme providery
- sjednocujeme technický pattern ingestu a návazných vrstev

---

## 3. HLAVNÍ ARCHITEKTONICKÉ PRAVIDLO
### 3.1 Provider strategie
Každá vrstva může mít jiného providera.

Příklady:
- Tennis + Cricket core = RapidAPI
- další sporty core = API-Sport / API-* provider
- Football core = speciální kombinace providerů
- Odds = zvláštní provider podle sportu
- People = další provider podle coverage
- Highlights / komentáře / články = další provider(y)

### 3.2 Co se sjednocuje
Sjednocujeme:
- strukturu složek
- naming souborů
- pull / parse / merge pattern
- staging/public flow
- OPS audit flow

### 3.3 Co se nesjednocuje
Nesjednocujeme:
- providery
- endpointy
- JSON formáty
- coverage logiku
- football special-case logiku

---

## 4. ROZDĚLENÍ SPORTŮ
### 4.1 Football
Football je speciální větev projektu.
Důvod:
- více providerů pro core
- canonical merge
- aliasy
- složitější match identity
- odds linker
- historický režim
- větší hloubka a šířka dat

Football se nemá míchat do prvního společného multisport frameworku.

### 4.2 Non-FB sporty
Ostatní sporty chceme držet co nejvíce ve společném technickém patternu.

To znamená:
- každý sport má vlastní ingest složku
- každý sport má vlastní pull/parse skripty
- ale všechny se drží stejné architektury

---

## 5. CÍLOVÝ TECHNICKÝ PATTERN
Tok pro sport + entitu:

provider API
→ RAW
→ staging.stg_api_payloads
→ staging.stg_provider_*
→ public.*
→ ops.runtime_entity_audit
→ ops.sport_completion_audit

Poznámka:
- starší sporty mohou mít starší mezikroky nebo starší raw tabulky
- cílový směr je generický staging model

---

## 6. STRUKTURA SLOŽEK
### 6.1 Ingest složky
Každý sport má vlastní složku v:

`C:\MatchMatrix-platform\ingest\API-<Sport>\`

Příklad:
- `API-Tennis`
- `API-Cricket`
- `API-Rugby`
- `API-Hockey`

Do této složky patří:
- `.env`
- `pull_*`
- `parse_*`

### 6.2 Workers
`run_*` skripty patří do:

`C:\MatchMatrix-platform\workers\`

Sem patří:
- orchestrace
- run wrappery
- případně merge runnery

### 6.3 DB kontroly
Kontrolní SQL patří do:

`C:\MatchMatrix-platform\db\checks\`

Auditní a širší kontrolní SQL patří do:

`C:\MatchMatrix-platform\db\audit\`

## 6.4 PRAVIDLO PRO ČÍSLOVÁNÍ SOUBORŮ

### SQL
SQL soubory v `db\checks\` a `db\audit\` se číslují:
`NNN_nazev.sql`

Pravidla:
- každé nové SQL dostane další volné číslo
- čísla se zpětně nemění
- číslo slouží jako pořadí a referenční bod pro navázání

### Python / PS1 – produkční ingest
Hlavní sportovní ingest skripty v `ingest\API-<Sport>\` se nečíslují globálním číslem.
Používá se:
- funkční název
- sport
- entita
- verze

Příklad:
- `pull_api_cricket_fixtures_v1.py`
- `parse_api_cricket_fixtures_v1.py`

### Python / PS1 – pomocné a jednorázové
Pomocné, diagnostické, migrační a přechodové skripty se mohou číslovat:
`NNN_popis.py`
`NNN_popis.ps1`

### Workers
Worker/run skripty ve `workers\` se standardně nečíslují globálním číslem.
Používá se jasný funkční název a verze.

Příklad:
- `run_parse_api_cricket_fixtures_v1.py`
- `run_merge_api_cricket_fixtures_v1.py`
---

## 7. PRAVIDLO PRO SCRIPTY
Nechceme:
- jeden univerzální script pro všechny sporty

Chceme:
- samostatné skripty po sportech a vrstvách

Příklad:
- `pull_api_cricket_fixtures_v1.py`
- `parse_api_cricket_fixtures_v1.py`

a stejně pro další sporty.

Společný má být pattern, ne jeden soubor.

---

## 8. PRAVIDLO PRO VRSTVY
### 8.1 Core vrstva
Typicky:
- leagues
- teams
- fixtures
- odds

### 8.2 People vrstva
Později:
- players
- coaches
- player_stats
- player_season_stats

### 8.3 Media vrstva
Později:
- highlights
- komentáře
- články
- další content/provider vrstvy

Každá vrstva může mít jiného providera.

---

## 9. ZDROJE PRAVDY
### 9.1 Hlavní pravda o stavu
Pravda projektu nemá být jen v ručním textu.
Hlavní pravda je v:
- auditních tabulkách
- OPS tabulkách
- kontrolních SQL
- panelech

### 9.2 Důležité DB objekty
Hlavní orientační objekty:
- `ops.runtime_entity_audit`
- `ops.sport_completion_audit`
- `ops.provider_entity_coverage`
- `ops.ingest_targets`
- `ops.ingest_planner`
- `ops.provider_sport_matrix`
- `ops.ingest_entity_plan`

### 9.3 Panel / UI
Panely slouží jako operační vrstva:
- panel na stahování
- auditní panel
- panel na tvorbu tiketů

Textový zápis nesmí přebít DB realitu.

---

## 10. REFERENČNÍ VZORY
### 10.1 Tennis
Dobrý vzor sportovní složky:
- vlastní `.env`
- oddělené pull/parse skripty
- čistší struktura

### 10.2 Cricket
Nový správný směr:
- RapidAPI
- RAW do `staging.stg_api_payloads`
- navázání do generického staging modelu

### 10.3 Rugby
Přechodová fáze:
- parsery už rozdělené rozumně
- pull ještě přes `.ps1`

### 10.4 Hockey / starší sporty
Starší vlna:
- častěji `.ps1`
- méně sjednocené podle dnešního cílového patternu

---

## 11. PRAVIDLA PRÁCE V TOMTO PROJEKTU
- postupujeme po jedné akci
- SQL skripty dávám pro DBeaver
- ostatní soubory/kód pro VS terminál
- vždy uvádět:
  - kam uložit soubor
  - přesný název
  - jak spustit
- nepřeskakovat mezi vrstvami bez jasného důvodu
- při novém chatu se opírat o tento master dokument + auditní pravdu + poslední konkrétní krok

---

## 12. SEKCE PRO PRŮBĚŽNĚ AKTUALIZOVANÝ STAV
Tato sekce se má ručně aktualizovat jen stručně.

### 12.1 Co je právě hotovo
- CK core staging je funkční v novém generickém modelu:
  - `staging.stg_api_payloads`
  - `staging.stg_provider_fixtures`
  - `staging.stg_provider_leagues`
  - `staging.stg_provider_teams`
- CK fixtures parsed = 2 payloady / 44 staging rows
- CK leagues parsed = 1 payload / 32 staging rows
- CK teams parsed = 1 payload / 37 staging rows
- CK je zapsán do:
  - `ops.runtime_entity_audit`
  - `ops.sport_completion_audit`
- CK core stav:
  - `PARTIAL`
  - `NEAR_READY`
  - `db_layer_ready = true`

#MATCHMATRIX – NAVÁZÁNÍ

TN core hotovo:
api_tennis TN leagues  CONFIRMED
api_tennis TN teams    CONFIRMED
api_tennis TN fixtures CONFIRMED
api_tennis TN odds     CONFIRMED
api_tennis TN players  PLANNED

Důležité:
U TN je teams = tenisový participant/hráč pro match identity.
Skuteční hráči/profily zůstávají people layer = players.

TN teams byly doplněny ze staging.api_tennis_fixtures:
player_1 + player_2 → staging.stg_provider_teams
Výsledek:
staging.stg_provider_teams api_tennis/TN = 138
public.team_provider_map api_tennis = 138
TN fixtures:
staging.api_tennis_fixtures = 69
public.matches ext_source api_tennis = 69
TN leagues:
staging.api_tennis_leagues = 5
public.leagues ext_source api_tennis = 5

Poslední stav auditu:
api_tennis TN players  PLANNED
api_tennis TN teams    CONFIRMED
api_tennis TN fixtures CONFIRMED
api_tennis TN odds     CONFIRMED
api_tennis TN leagues  CONFIRMED

Doplnění – VB (api_volleyball)
VB core pipeline byl rekonstruován do cílového multisport patternu:
fyzická složka API-Volleyball doplněna (pull/parse wrappery)
napojení na generický ingest (run_unified_ingest_v1.py, run_parse_api_sport_*)
staging sjednocen:
sport_code: volleyball → VB (api_volleyball)
opraven critical bug:
run_parse_api_sport_leagues_v1.py → doplněn ON CONFLICT (rerun-safe)
opraven merge blocker:
doplněni chybějící provideri do public.data_providers
ověřen end-to-end běh:
planner → pull → parse → merge → public

Výsledek:

VB byl plně zafixován v auditních tabulkách:
ops.runtime_entity_audit
ops.sport_completion_audit

Stav:

core_pipeline = DONE / READY
leagues = CONFIRMED
teams = CONFIRMED
fixtures = CONFIRMED
odds = PLANNED
players = BLOCKED
coachs = WAIT_PROVIDER

Důležité:

audit sjednocen:
odstraněny staré key_gap a historické next_step
všechny core entity přepnuty na finální stav
pipeline je:
opakovatelná (rerun-safe)
plně napojená na planner + panel
validovaná přes staging → public merge

Výsledek:

VB je nyní:
plně uzavřený core sport
referenční implementace multisport patternu
validní vstup pro ops.sport_completion_audit



DALŠÍ SPORT: HB / api_handball

Fyzický stav složky:
C:\MatchMatrix-platform\ingest\API-Handball\

Obsah:
inspect_api_handball_leagues_db.py
inspect_api_handball_leagues_raw.py
pull_api_handball_fixtures.ps1
pull_api_handball_leagues.ps1
pull_api_handball_teams.ps1

Zjištění:
HB má pull + inspect, ale chybí standardní parse skripty:
parse_api_handball_leagues_v1.py
parse_api_handball_teams_v1.py
parse_api_handball_fixtures_v1.py

Důležité z inspect_api_handball_leagues_db.py:
HB raw payload je ve staging.stg_api_payloads, ale používá sloupce:
provider
sport_code
entity_type
payload_json

Ne entity/payload.

## 12.5 PROVIDER / SPORT / ENTITY STATUS (MASTER OVERVIEW)

### 🏈 AFB – API-AMERICAN-FOOTBALL
```text
api_american_football | AFB | fixtures | CONFIRMED | AFB_CORE
api_american_football | AFB | leagues  | CONFIRMED | AFB_CORE
api_american_football | AFB | teams    | CONFIRMED | AFB_CORE
Stav:

AFB core pipeline je uzavřena
Pull → RAW → STAGING → PROVIDER_MAP → PUBLIC plně funkční
staging vrstvy existují (stg_api_american_football_*)
public.matches naplněno (335)
team_provider_map naplněno (34)
runtime_entity_audit potvrzeno
sport_completion_audit = DONE / READY

Architektura:

stg_provider_teams
stg_provider_fixtures
→ worker_template_multisport_v1
→ merge_runner_multisport_v1
→ public.*

Zařazení do systému:

AFB je plně sjednocený multisport pipeline
sdílí worker template
kompatibilní s ingest orchestrátorem
připraveno na batch processing
📊 REAL STATUS (CORE SPORTS)
HK  | CONFIRMED
CK  | CONFIRMED
TN  | CONFIRMED
HB  | CONFIRMED
AFB | CONFIRMED

NEXT STEPS (AFB)
ODDS LAYER
AFB → odds ingest (TheOdds / jiný provider)
PEOPLE LAYER
AFB → players / coaches (nutný další provider)

🧠 SHRNUTÍ
AFB = plně dokončený CORE sport
pipeline sjednocena
real merge implementován (idempotentní)
připraveno na škálování
připraveno na rozšíření (odds / people)

Potom poslat výstup:
Root keys
Response count
FIRST ITEM KEYS
FIRST ITEM JSON
Doplnění – ODDS LAYER (multisport)

Byla provedena systematická validace odds endpointů napříč sporty
pomocí smoke testů (pull → staging.stg_api_payloads → payload kontrola).

Použitý pattern:
- pull_*_odds.ps1
- RAW ukládání do staging.stg_api_payloads
- validace response.results + response.response

Výsledky:

HK (api_hockey)
odds endpoint:
- funkční (game parametr)
- payload se ukládá
- free plán vrací results=0

Stav:
odds = BLOCKED (limited_free bez dat)

VB (api_volleyball)
odds endpoint:
- opraven parametr fixture → game
- endpoint funkční
- payload ukládán do staging.stg_api_payloads
- response:
  results = 0
  response = []

Stav:
odds = BLOCKED (limited_free / historická data bez odds)

Závěr pro limited_free sporty:
- endpointy jsou technicky použitelné
- RAW ingest funguje
- parser není implementován (není potřeba při results=0)
- hlavní limit = free plán / historická sezóna

Rozdělení odds vrstvy:

CONFIRMED:
- TN (api_tennis) → odds funkční

RUNTIME_TESTED:
- FB (theodds) → hlavní odds provider

BLOCKED (limited_free bez dat):
- HK
- VB

PLANNED (neřešeno zatím):
- AFB
- BK
- BSB
- CK
- HB
- RGB
- FH

PAID_ONLY:
- MMA
- DRT
- ESP
- další FB providers (pinnacle, betfair, sportdataapi)

Důležité:

odds nejsou blokované technicky
→ jsou blokované business modelem (API plan / data availability)

Strategie:

- odds layer nebude blokovat postup projektu
- odds se budou řešit:
  - po přechodu na placený API plán
  - nebo přes specializované odds providery

- další krok případně:
  - odds
  - people
  - downstream entity
---

================================================================================
MATCHMATRIX PROGRESS LOG
================================================================================
DATE: 2026-04-28
AREA: PEOPLE LAYER – BASKETBALL (API-SPORT)
================================================================================

[1] CONTEXT
--------------------------------------------------------------------------------
Cíl: připravit automatizovaný PEOPLE pipeline pro Basketball (BK) přes provider api_sport.
Důraz: team-based ingest (players per team + season).

--------------------------------------------------------------------------------

[2] SMOKE TEST – API-SPORT BK
--------------------------------------------------------------------------------
Endpoint: /players
Parametry: team + season
Výsledek: CONFIRMED

✔ endpoint funguje
✔ vrací data (např. 16 hráčů pro Barcelona)
✔ league-based volání NEFUNGUJE (nutné team-based)

Endpoint: /coaches
Výsledek: NOT AVAILABLE

✖ endpoint neexistuje
→ BK coaches BLOCKED

--------------------------------------------------------------------------------

[3] ARCHITEKTURA – PEOPLE PIPELINE
--------------------------------------------------------------------------------
Zaveden nový model:

teams → players (team-based) → staging → public.players

Použitá tabulka:
ops.player_enrichment_plan

Parametry:
provider = api_sport
sport_code = basketball
entity = players
run_group = BK_PEOPLE

--------------------------------------------------------------------------------

[4] IMPLEMENTACE
--------------------------------------------------------------------------------
✔ vytvořen planner (18 týmů – liga 117, sezóna 2023-2024)

✔ vytvořen worker:
ingest/API-Sport/pull_api_sport_bk_players_v1.py
→ queue mode (ops.player_enrichment_plan)

✔ vytvořen parser:
run_parse_api_sport_bk_players_v1.py
→ upraven na UPSERT (ON CONFLICT provider + external_player_id)

✔ napojeno na:
staging.stg_api_payloads
staging.stg_provider_players
public.players
public.player_provider_map

--------------------------------------------------------------------------------

[5] EXECUTION
--------------------------------------------------------------------------------
Pull:
- 18 týmů
- 18 payloadů

Parse:
- payloads processed: 18
- players inserted: 274
- errors: 0

Merge:
- players inserted: 267
- player_provider_map inserted: 267

--------------------------------------------------------------------------------

[6] FINAL STATE
--------------------------------------------------------------------------------
public.players: 2740
public.player_provider_map: 2740

BK players:
✔ END-TO-END CONFIRMED
✔ AUTOMAT READY
✔ MULTISPORT PEOPLE PIPELINE POPRVÉ FUNKČNÍ

--------------------------------------------------------------------------------

[7] STATUS UPDATE
--------------------------------------------------------------------------------
api_sport    BK    players   CONFIRMED   READY
api_sport    BK    coaches   BLOCKED     NO_ENDPOINT

--------------------------------------------------------------------------------

[8] KLÍČOVÝ ZÁVĚR
--------------------------------------------------------------------------------
People layer:
✖ není league-based
✔ je TEAM-based

→ nový standard pro celý MatchMatrix

================================================================================
END OF LOG
================================================================================
================================================================================
DATE: 2026-04-29
AREA: PEOPLE LAYER – BASEBALL (BSB)
================================================================================

[1] CONTEXT
--------------------------------------------------------------------------------
Cíl: ověřit PEOPLE pipeline pro Baseball (BSB) přes provider api_baseball.

Použit:
- multisport players runner (run_players_multisport_v1.py)
- planner-driven pipeline
- RAW → staging → players_import → merge flow

--------------------------------------------------------------------------------

[2] IMPLEMENTACE
--------------------------------------------------------------------------------
✔ vytvořen multisport runner:
C:\MatchMatrix-platform\workers\run_players_multisport_v1.py

✔ využit existující:
- pull_api_football_players_v4.py (generalized)
- staging.stg_api_payloads
- staging.players_import

✔ vytvořen planner seed:
- ops.ingest_planner
- run_group = BSB_PEOPLE
- team-based jobs

--------------------------------------------------------------------------------

[3] EXECUTION TEST
--------------------------------------------------------------------------------
Spuštění:

python workers\run_players_multisport_v1.py BSB

Výsledek:

✔ job nalezen (planner OK)
✔ API call proběhl
✔ HTTP 200 OK
✔ RAW payload uložen

Testované endpointy:

1) /players?league=10&season=2024
→ response empty

2) /players?team=10&season=2024
→ response empty

--------------------------------------------------------------------------------

[4] DATA FLOW VÝSLEDEK
--------------------------------------------------------------------------------

stg_api_payloads:
✔ raw_payload_id = 741, 742

staging.players_import:
✖ inserted = 0

public.players:
✖ žádná změna

--------------------------------------------------------------------------------

[5] AUDIT ZÁPIS
--------------------------------------------------------------------------------

ops.runtime_entity_audit:

api_baseball | BSB | players | BLOCKED

Důvod:
- endpoint vrací 200 OK
- ale bez dat (league i team scope)

--------------------------------------------------------------------------------

[6] STATUS
--------------------------------------------------------------------------------

api_baseball    BSB    leagues    CONFIRMED
api_baseball    BSB    teams      CONFIRMED
api_baseball    BSB    fixtures   CONFIRMED
api_baseball    BSB    players    BLOCKED

--------------------------------------------------------------------------------

[7] KLÍČOVÝ ZÁVĚR
--------------------------------------------------------------------------------

✔ pipeline FUNGUJE (runtime OK)
✔ architektura správná (planner + RAW + staging)

✖ provider nedodává data pro players

→ problém není v systému
→ problém je v provideru

--------------------------------------------------------------------------------

[8] NEXT STEP
--------------------------------------------------------------------------------

1) Otestovat RGB players (api_rugby)
2) Otestovat HB players (api_handball)
3) případně:
   - jiný endpoint
   - jiný provider
   - paid plan

--------------------------------------------------------------------------------

[9] ARCHITEKTONICKÝ POSUN
--------------------------------------------------------------------------------

People layer sjednocen na:

planner → RAW → players_import → public

→ připraveno pro multisport template

================================================================================
END OF LOG
================================================================================
PEOPLE PIPELINE – UNIFIED V1 (2026-04-29)
Stav implementace

PEOPLE layer byl poprvé sjednocen do jednoho pipeline workeru:

workers/run_people_pipeline_v1.py

Pipeline pokrývá:

RAW pull → staging.stg_api_payloads
parse → staging.stg_provider_players / coaches
data fix (team_id fallback, sport_code normalization)
merge → public.players + player_provider_map
audit → ops.provider_people_audit
Výsledky (CONFIRMED)
✅ API-FOOTBALL (FB)

players

RAW: OK (response_count=20)
staging: OK
public.players: OK (již existující)
player_provider_map: OK
audit: PUBLIC_CONFIRMED

coaches

RAW: OK (response_count=3)
staging: OK
public: zatím neřešeno (není model)
audit: STAGING_CONFIRMED
✅ API-AMERICAN-FOOTBALL (AFB)

players

RAW: OK (response_count=86)
staging: OK
public.players: OK (86 insert)
player_provider_map: OK (86 insert)
audit: PUBLIC_CONFIRMED
⚠️ API-SPORT (BK)

players

RAW: OK (response_count=22)
staging: OK
problém: chybí team_provider_map (team=139)
audit: STAGING_CONFIRMED
další krok: doplnit team mapping nebo změnit scope
Klíčové technické poznatky
API-Football players:
team/league data jsou pouze ve statistics[]
parser musí vždy číst z statistics[0]
konflikty ve staging:
existující data měla sport_code='football'
nutná normalizace na FB
fallback logika:
pokud chybí team_id → použít external_id (team=...)
nutné pro non-FB providery
Architektura – potvrzený pattern
RAW → stg_api_payloads
    → stg_provider_players / coaches
        → (fix layer)
            → public.players
            → player_provider_map
                → audit (ops.provider_people_audit)
Stav projektu

PEOPLE layer:

první sport (AFB) → end-to-end hotovo
druhý sport (FB) → reuse + confirmed
pipeline → unified (V1)

👉 systém je připraven na škálování

Další krok
🔜 PEOPLE PIPELINE V2
napojení na ops.ingest_targets
napojení na ops.ingest_planner
parametrizace:
league_id
team_id
season
batch processing (multi-league / multi-team)
Shrnutí
PEOPLE pipeline poprvé funguje jako univerzální vrstva
máme funkční:
ingestion
parsing
mapping
merge
audit

👉 MatchMatrix má nyní plnohodnotný PEOPLE layer základ

## PEOPLE PIPELINE – STAV K 2026-04-29

Hotovo:
- PEOPLE V2.1 planner-driven pipeline potvrzena.
- FB players: CONFIRMED.
- FB coaches: PARTIAL, staging OK, public coaches model zatím není.
- AFB players: CONFIRMED.
- FB_PEOPLE_SCALE_01: 10 lig, RAW=10, players=200, mapped=181.
- FB_PEOPLE_SCALE_02: 10 lig, RAW=10, players=200, mapped=200.
- FB_PEOPLE_TEAM_SCALE_01: 20 týmů, RAW=20, players=400, mapped=395.
- Runtime audit aktualizován.

Další krok:
PEOPLE PIPELINE V2.2 – PAGINATION.

Úkol:
- upravit worker:
  C:\MatchMatrix-platform\workers\run_people_pipeline_v21_from_planner.py

na novou verzi:
  C:\MatchMatrix-platform\workers\run_people_pipeline_v22_from_planner.py

Požadovaná logika:
- pro players endpoint používat stránkování page=1..N
- ukládat každý page RAW do staging.stg_api_payloads
- každý page parsovat do staging.stg_provider_players
- mergeovat players do public.players + public.player_provider_map
- ukončit loop pokud response_count = 0
- bezpečnostní limit MAX_PAGES např. 5
- planner job označit done až po doběhnutí všech stran
- evidence_note / runtime audit doplnit o počet pages, parsed rows, mapped rows

Priorita:
1. FB team-based players pagination
2. potom FB league-based players pagination
3. až následně další team batch

### AFB – PEOPLE PIPELINE V2 (players)

STATUS: CONFIRMED  
LAYER: PEOPLE  
RUN_GROUP: AFB_PEOPLE_V2  

POPIS:
AFB players pipeline byl úspěšně napojen na planner-driven PEOPLE pipeline (V2.1).

PROVEDENO:
- oprava worker_script v ops.ingest_entity_plan
- napojení na existující worker:
  workers/run_people_pipeline_v21_from_planner.py
- reset planner jobu (id=5845)
- úspěšný běh přes planner

VALIDACE:
- HTTP OK; response_count=86
- RAW uložen (id=799)
- Parsed rows=86
- Public merge OK (0 insert = data již existovala)
- job_runs: status=done, attempts=1

ZÁVĚR:
AFB players je plně funkční v režimu:
planner → worker → RAW → staging → public

POZNÁMKY:
- PEOPLE pipeline funguje jako reusable template
- insert=0 potvrzuje deduplikaci a správný provider_map
- připraveno na rozšíření scope (více týmů / sezon)

NEXT STEP:
- rozšířit ingest_planner o další AFB leagues/seasons
- následně aplikovat stejný pattern na:
  HK / BK / VB PEOPLE layer

### FB – PEOPLE PIPELINE V2.2 (players pagination)

STATUS: CONFIRMED  
LAYER: PEOPLE  
RUN_GROUP: FB_PEOPLE_TEAM_SCALE_01  

POPIS:
Implementována a ověřena nová verze PEOPLE pipeline V2.2 s podporou stránkování (pagination) pro players endpoint.

PROVEDENO:
- vytvořen nový worker:
  workers/run_people_pipeline_v22_from_planner.py
- implementována logika:
  - page=1..N loop
  - ukládání každé stránky do staging.stg_api_payloads
  - parsing do staging.stg_provider_players
  - merge do public.players + public.player_provider_map
  - stop podmínka: response_count=0
  - bezpečnostní limit: MAX_PAGES=5
- doplněna evidence do ops.job_runs (pages, parsed_rows, maps_inserted)

VALIDACE:
- test job: id=5887 (api_football / FB / players)
- PAGE 1 → 20 hráčů
- PAGE 2 → 20 hráčů
- PAGE 3 → 20 hráčů
- PAGE 4 → 0 → STOP
- RAW: id=800, 801, 802
- parsed_rows=60
- maps_inserted=60
- job status=done, attempts=1

ZÁVĚR:
FB players pagination funguje plně v režimu:
planner → worker V2.2 → RAW (multi-page) → staging → public merge

POZNÁMKY:
- deduplikace players + provider_map funguje správně
- pipeline je připravena na scale (více team batchů)
- AFB test potvrdil funkčnost pipeline, FB test potvrdil pagination

NEXT STEP:
- rozšířit FB batch (více provider_league_id)
- implementovat league-based pagination fallback
- následně aplikovat template na:
  HK / BK / VB PEOPLE layer


### FB – PEOPLE PIPELINE V2.2 SCALE CONFIRMED

STATUS: CONFIRMED
LAYER: PEOPLE
RUN_GROUP: FB_PEOPLE_TEAM_SCALE_01

Dne 2026-04-30 byla potvrzena PEOPLE pipeline V2.2 pro FB players pagination.

Ověřeno:
- 20/20 planner jobů dokončeno jako done
- page=1..N pagination funguje
- každá stránka ukládána do staging.stg_api_payloads
- parsing do staging.stg_provider_players funkční
- merge do public.players + public.player_provider_map funkční
- staging upsert opraven proti duplicitám
- HTTP 429 retry/backoff ověřen
- stop při response_count=0 funkční

Výsledky scale testů:
- batch 1: pages=18, parsed_rows=352, maps_inserted=331
- batch 2: pages=20, parsed_rows=400, maps_inserted=239
- finální stav: FB_PEOPLE_TEAM_SCALE_01 = 20/20 done

Závěr:
FB team-based players pagination je CONFIRMED a připravena pro další scale dávky.

NEXT STEP:
Připravit FB league-based players pagination fallback nebo založit další FB team batch.

PEOPLE_SMOKE_TEST_FB_2024 ověřen.
Spuštěn 1 job: api_football / FB / players / league 374 / season 2024.
Fetch OK, bridge OK, public players merge OK, player season stats parse OK, public stats merge OK.
Free plán potvrdil limit max page=3, prakticky 60 hráčů na ligu.
Stav po testu: done 1, pending 1.
AUTO fronta FB_PEOPLE_AUTO_2024 byla odsunuta na future next_run, aby ji worker omylem nebral.

PEOPLE SMOKE TEST STANDARD zaveden.

Run_group pattern:
- PEOPLE_SMOKE_TEST_<SPORT>_2024

Aktuálně připraveno:
- AFB: 1 job
- BSB: 1 job
- CK: 1 job
- FB: 3 joby
- HB: 1 job
- HK: 1 job
- RGB: 1 job
- VB: 1 job

Účel:
- malé řízené ověření runtime people pipeline
- ne harvest
- ne hromadné stahování
- testovací běhy pouze po jednom sportu a po vědomém spuštění

Poznámka:
Po zjištění bylo potvrzeno, že `next_run IS NULL` může být v planner view vyhodnoceno jako ready now, proto se před smoke spuštěním musí vždy ověřit konkrétní ready queue.

PEOPLE SAFE HOLD nastaven.
Všechny pending people-like joby mimo PEOPLE_SMOKE_TEST_% byly odsunuty na next_run = 2099-01-01.
Ready queue nyní obsahuje pouze řízené smoke testy:
AFB 1, BSB 1, CK 1, FB 2, HB 1, HK 1, RGB 1, VB 1.

PEOPLE COVERAGE REALITY CHECK:
Ne každý API-Sport má reálně ověřené players/coaches endpointy.
Aktuálně bezpečně ověřitelné:
- AFB players = runtime_tested
- FB players/player_stats = funkčně ověřeno smoke testem
- HK coaches = tech_ready

Nespouštět automaticky:
- HK players = blocked
- ostatní sporty players/coaches = planned, nejdřív provider validation

PEOPLE SMOKE TEST – aktuální stav:
- FB: done 2, pending 1, pipeline ověřena end-to-end
- AFB: pending 1, vhodné pro další test, protože AFB players = runtime_tested
- HK: pending 1, ale players v coverage = blocked, nespouštět bez validace
- BSB/CK/HB/RGB/VB: pending 1, coverage zatím planned, nespouštět bez provider validation
PEOPLE LAYER – STRATEGIE

Rozhodnutí:
Neřešit nyní players/coaches pro další sporty.

Důvod:
- coverage většiny sportů = planned
- HK players = blocked
- pouze FB a AFB mají reálně ověřenou hodnotu

Stav:
- PEOPLE pipeline technicky READY
- SMOKE testy připravené pro všechny sporty
- AUTO fronty připravené pro budoucí harvest

Strategie:
- people layer bude aktivně řešen až po PRO plánu
- nyní se soustředit na core data (leagues, teams, fixtures, odds)

ODDS STRATEGIE:
API-SPORTS paid plán má podle pricingu přístup ke všem endpointům.
Odds vrstva tedy dává smysl řešit až po PRO/paid aktivaci.
Pro core sporty držet odds jako PLANNED / READY_FOR_PAID_VALIDATION.
Před full harvestem vždy udělat smoke test endpointu pro konkrétní sport.

ODDS RUNTIME AUDIT SEED dokončen.
Odds vrstva je připravena auditně pro paid/API-Sport režim.
Aktuálně confirmed pouze TN odds.
Ostatní sporty jsou PLANNED a budou validovány až po PRO/paid aktivaci přes smoke test endpointu.

ODDS COVERAGE REALITY CHECK:
Odds vrstva je vhodná hlavně po paid/PRO režimu.
FB primární odds provider zůstává TheOdds.
API-SPORTS odds použít jako sportovní paid smoke/harvest vrstvu pro AFB/BK/BSB/CK/HB/RGB a případně HK/VB po ověření aktuálních SCHEDULED zápasů.
HK/VB odds endpoint technicky funguje, ale free/historická data vrací 0.

ODDS LAYER – REALITA
Odds pro API-Sport sporty nebudeme teď spouštět nad historickými sezónami 2022–2024.
Nejprve je nutné mít aktuální SCHEDULED fixtures.
Odds smoke test bude až po aktuálním pullu fixtures nebo po PRO/paid aktivaci.

THEODDS COVERAGE CHECK:
TheOdds/odds data jsou reálně napojená na football_data ligy.
Aktuální pokrytí:
- 12 lig se zápasy s odds
- celkem 649 zápasů s odds
- nejlepší coverage: Championship, Brasileirão Série A, Primera Division, Bundesliga, Premier League
Poznámka: není uložené přes leagues.ext_source='theodds', ale přes vazbu public.odds -> public.matches -> public.leagues.ok

CK AUDIT DUPLICITY:
CK má duplicitní runtime_entity_audit řádky:
- api_cricket = CONFIRMED pro leagues/teams/fixtures
- api_sport = PLANNED pro leagues/teams/fixtures

Pravda pro core harvester:
- primary provider: api_cricket
- api_sport CK ponechat jen jako fallback placeholder
- pro readiness summary počítat CK core podle api_cricket, ne podle api_sport

---

## 12.6 MASTER ORCHESTRATOR / PIPELINE STRATEGIE

Bylo potvrzeno, že soubor:

`C:\MatchMatrix-platform\workers\run_ingest_cycle_v3.py`

je hlavní runtime orchestrátor pro ingest cyklus.

Jeho aktuální role:
- získá worker lock
- vytvoří záznam do `ops.job_runs`
- spustí planner worker
- po úspěšném planner běhu spouští návazné kroky:
  - extract teams from fixtures raw
  - parse teams
  - parse fixtures
  - merge staging → public
- pro API-Football fixtures obsahuje speciální RAW → PUBLIC větev
- zapisuje výsledek cyklu do `ops.job_runs`
- uvolňuje worker lock

Architektonický závěr:

`run_ingest_cycle_v3.py` je základ pro CORE runtime pipeline, ale nemá do sebe přímo obsahovat celou logiku PEOPLE a MEDIA/HIGHLIGHTS vrstvy.

Správný cílový model:

```text
MASTER ORCHESTRATOR
 ├─ CORE cycle
 ├─ ODDS cycle
 ├─ PEOPLE cycle
 └─ MEDIA / HIGHLIGHTS cycle

# MATCHMATRIX – PEOPLE LAYER REALITY (API-Sports)  
Datum: 2026-05-04

================================================================================
CÍL
================================================================================
Ověření PEOPLE layer (players) napříč sporty po dokončení CORE pipeline.

================================================================================
VÝSLEDEK – API-SPORTS PROVIDERS
================================================================================

FB (api_football)
----------------------------------------------------------------
STATUS: CONFIRMED_DATA
POZNÁMKA:
- endpoint /players funkční
- data vrací (ověřeno batch + SMART run)
- primary PEOPLE provider

AFB (api_american_football)
----------------------------------------------------------------
STATUS: RUNTIME_OK_EMPTY
POZNÁMKA:
- endpoint existuje
- HTTP OK
- response_count = 0 pro league scope
- pravděpodobně nutný jiný scope (team/squad)

HB (api_handball)
----------------------------------------------------------------
STATUS: RUNTIME_OK_EMPTY
POZNÁMKA:
- endpoint existuje
- HTTP OK
- žádná data pro league+season
- API limitation

HK (api_hockey)
----------------------------------------------------------------
STATUS: RUNTIME_OK_EMPTY
POZNÁMKA:
- endpoint existuje
- HTTP OK
- žádná data
- API limitation

BSB (api_baseball)
----------------------------------------------------------------
STATUS: RUNTIME_OK_EMPTY
POZNÁMKA:
- endpoint existuje
- HTTP OK
- žádná data
- API limitation

RGB (api_rugby)
----------------------------------------------------------------
STATUS: RUNTIME_OK_EMPTY
POZNÁMKA:
- endpoint existuje
- HTTP OK
- žádná data
- API limitation

VB (api_volleyball)
----------------------------------------------------------------
STATUS: BLOCKED_PROVIDER
POZNÁMKA:
- endpoint /players neexistuje
- provider nepodporuje PEOPLE layer

CK (api_cricket)
----------------------------------------------------------------
STATUS: WORKER_NOT_SUPPORTED_YET
POZNÁMKA:
- jiný provider (RapidAPI)
- není kompatibilní s V2.2 workerem

================================================================================
ZÁVĚR
================================================================================

API-Sports:
- plně použitelný pro PEOPLE pouze pro FB
- ostatní sporty:
  - buď nemají data
  - nebo endpoint vůbec neexistuje

================================================================================
DOPAD NA ARCHITEKTURU
================================================================================

1) SINGLE PROVIDER nestačí
→ nutný MULTI-PROVIDER PEOPLE layer

2) fallback strategie:
----------------------------------------------------------------
A) team squads (kde existuje)
B) jiný provider (RapidAPI / special API)
C) vlastní data (future layer)

3) priorita:
----------------------------------------------------------------
1. FB (hotovo)
2. AFB (scope fix / team-based)
3. ostatní sporty → řešit jiným providerem

================================================================================
BUSINESS POHLED
================================================================================

- PEOPLE layer = klíč pro uživatele (hráči, statistiky)
- API-Sports nestačí → nutná kombinace zdrojů
- nejrychlejší monetizace:
  → FB PEOPLE + odds + stats

================================================================================
STAV MATCHMATRIX
================================================================================

CORE layer: DONE (multi-sport)
PEOPLE layer: PARTIAL (FB only usable)
ARCHITECTURE: READY for multi-provider expansion

================================================================================
NEXT STEP
================================================================================

- navrhnout PEOPLE multi-provider mapu
- definovat provider per sport
- připravit V3 PEOPLE pipeline (provider abstraction)

---

## PEOPLE MULTI-PROVIDER ARCHITEKTURA – ROZHODNUTÍ

Rozhodnutí:
PEOPLE layer nebude řešen jako jedna provider větev pro všechny sporty.

Důvod:
- některé sporty mají jiného core providera
- některé sporty mají jiný vhodný people provider
- některé API-Sports endpointy pro players vrací prázdná data
- u některých sportů people endpoint vůbec neexistuje

Důležité:
Auditní pravda o aktuálním stavu zůstává v existujících OPS tabulkách.

Nepřidáváme novou hlavní auditní tabulku jen pro stav.

Používané autority:
- `ops.runtime_entity_audit`
- `ops.provider_entity_coverage`
- `ops.ingest_entity_plan`
- `ops.ingest_targets`
- `ops.ingest_planner`
- `ops.job_runs`

Cílový princip:

```text
CORE provider
≠
PEOPLE provider

## 12.7.) PEOPLE LAYER – MULTI-PROVIDER SCALE (HK / BSB / BK / MMA)

### Stav:
PEOPLE layer byl rozšířen z původního FB-only modelu na multi-sport architekturu s fallback providery.

### Implementace:
- Zaveden fallback provider pattern:
  primary provider (API-Sports) → fallback (SportsDataIO)
- Upraven worker:
  workers/run_people_pipeline_v22_from_planner.py
- Doplněna logika:
  - provider candidates (primary + fallback)
  - SportsDataIO non-paginated handling
  - parser pro:
    - NHL/NBA/MLB players
    - MMA fighters (custom struktura)

### Výsledky:

#### HK (hokej)
- api_hockey → EMPTY
- sportsdataio → OK
- parsed ≈ 1950
- public.players naplněno

#### BSB (baseball)
- api_baseball → EMPTY
- sportsdataio → OK
- parsed ≈ 7100
- public.players naplněno

#### BK (basketball)
- api_basketball → EMPTY
- sportsdataio → OK
- parsed ≈ 535
- public.players naplněno

#### MMA
- core layer: ❌ NEEXISTUJE
- PEOPLE layer: ✅ FUNKČNÍ (fallback SportsDataIO)
- parsed ≈ 3668 fighters
- public.players naplněno

### Architektura:
PEOPLE layer nyní funguje nezávisle na core vrstvě (fixtures/leagues/teams).

To umožňuje:
- zobrazovat hráče i bez match dat
- rychle rozšiřovat obsah platformy
- generovat traffic (player-centric UX)

### Stav systému:

| Sport | Core | People | Provider |
|------|------|--------|----------|
| FB   | ✅   | ✅     | api_football |
| AFB  | ✅   | ✅     | api_american_football |
| HK   | ✅   | ✅     | sportsdataio |
| BSB  | ✅   | ✅     | sportsdataio |
| BK   | ✅   | ✅     | sportsdataio |
| MMA  | ❌   | ✅     | sportsdataio |

### Klíčový milník:
MATCHMATRIX má nyní plně funkční MULTI-PROVIDER PEOPLE PIPELINE.

### Další krok:
- AUTO harvest pro FB (scale 1000+ jobs)
- napojení PEOPLE → UI (player detail)
- případně doplnění core vrstvy pro MMA (nižší priorita)

MATCHMATRIX – NAVAZUJÍCÍ ZÁPIS (FB PEOPLE SCALE + SPORTSDATAIO STABILIZACE)
================================================================================

DATUM:
2026-05-05

HLAVNÍ VÝSLEDEK:
People pipeline V2.2 byla stabilizována pro:
- SportsDataIO
- API-Football players scale harvesting

Byly odstraněny problémy:
- parsed=None
- parsed=0
- TypeError při runtime audit sum()
- nefunkční API-Football parser branch
- chybné fallbacky providerů
- PostgreSQL UPDATE LIMIT syntax
- debug chaos v logu

================================================================================
1) SPORTSDATAIO – MMA PEOPLE PIPELINE
================================================================================

PROVEDENO:
- doplněna special branch pro MMA fighters
- SportsDataIO MMA používá:
    FighterID
  místo:
    PlayerID

IMPLEMENTACE:
if job.sport_code == "MMA":
    external_player_id = FighterID/FighterId

VÝSLEDEK:
sportsdataio MMA ingest plně funkční.

TEST:
JOB 7287
sportsdataio | MMA | players

RESULT:
parsed_rows=3668
players_inserted=3668
maps_inserted=3668

STATUS:
sportsdataio MMA people pipeline = CONFIRMED

POZNÁMKA:
MMA zatím nemá CORE vrstvu.
Pouze PEOPLE vrstva přes SportsDataIO.

================================================================================
2) API-FOOTBALL PLAYERS PARSER – OPRAVA
================================================================================

PŮVODNÍ PROBLÉM:
API vracelo response_count=20
ale:
parsed=0
players_inserted=0

ROOT CAUSE:
insert_staging_players() vracel parsed pouze
pro sportsdataio branch.

API-Football branch:
for item in items:
    row = parse_player_item(...)

neobsahovala:
- INSERT INTO staging
- parsed += 1
- UPDATE staging.stg_api_payloads
- return parsed

=> parser nic nezapisoval.

OPRAVA:
Byla doplněna generic/API-Football branch:
- INSERT INTO staging.stg_provider_players
- ON CONFLICT UPDATE
- parsed += 1
- payload parse_status update
- return int(parsed or 0)

VÝSLEDEK:
API-Football parser nyní zapisuje korektně.

================================================================================
3) API-FOOTBALL SCALE TEST – SUCCESS
================================================================================

RUN GROUP:
FB_PEOPLE_SCALE_BATCH_01

VÝSLEDEK:
done=50
pending=0

PIPELINE STAV:
- parser funkční
- staging funkční
- provider_map funkční
- retry 429 funkční
- empty leagues správně skipnuty

UKÁZKY:
parsed_rows=262
maps_inserted=256

parsed_rows=238
maps_inserted=230

STATUS:
FB PEOPLE SCALE = STABLE

================================================================================
4) POSTGRESQL UPDATE LIMIT PROBLÉM
================================================================================

PŮVODNÍ CHYBA:
ERROR: syntax error at or near "LIMIT"

ROOT CAUSE:
PostgreSQL nepodporuje:
UPDATE ... LIMIT

ŘEŠENÍ:
Použit CTE pattern:

WITH cte AS (
    SELECT id
    FROM ops.ingest_planner
    ...
    LIMIT 50
)
UPDATE ops.ingest_planner p
SET run_group = 'FB_PEOPLE_SCALE_BATCH_02'
FROM cte
WHERE p.id = cte.id;

================================================================================
5) FB_PEOPLE_SCALE_BATCH_02
================================================================================

VYTVOŘENO:
50 pending jobs

RUN:
run_harvest_master_v1.py
--run-group FB_PEOPLE_SCALE_BATCH_02

VÝSLEDKY:
parsed_rows=78
maps_inserted=58

POZNÁMKA:
část lig vrací:
response_count=0

To je provider coverage reality,
ne chyba pipeline.

================================================================================
6) DEBUG LOG CLEANUP
================================================================================

DOČASNÉ DEBUGY:
print(f"DEBUG insert_staging_players...")
print(f"DEBUG first_item_keys...")
print(f"DEBUG first_parse_result...")

rozbíjely log dlouhým JSON payloadem.

DALŠÍ KROK:
debug printy odstranit / zakomentovat.

================================================================================
7) AKTUÁLNÍ STAV
================================================================================

FB PEOPLE:
- parser OK
- staging OK
- provider_map OK
- runtime audit OK
- retry handling OK

SPORTSDATAIO:
- BK OK
- BSB OK
- HK OK
- MMA OK

MMA:
- PEOPLE vrstva hotová
- CORE vrstva zatím neexistuje

================================================================================
8) DALŠÍ KROK
================================================================================

1.
Odstranit DEBUG printy
v insert_staging_players()

2.
Dokončit:
FB_PEOPLE_SCALE_BATCH_02

3.
Pokračovat:
FB_PEOPLE_AUTO_2024
(přes další SCALE batch)

4.
Poté:
- SMART optimalizace
nebo
- FULL SCALE FB PEOPLE harvest

===========================================================================
MATCHMATRIX – CORE HARVEST STABILIZATION (HK + BK)
===========================================================================

DATUM:
2026-05-08

HLAVNÍ VÝSLEDEK:
Byla potvrzena stabilizace multisport CORE ingest pipeline pro:
- HK (api_hockey)
- BK (api_sport basketball)

Proběhlo:
- planner-driven harvest
- unified ingest
- RAW payload ingest
- parser flow
- unified merge
- public canonical merge

===========================================================================
1) HK – HOCKEY CORE VALIDACE
===========================================================================
RUN GROUP:
HK_TOP

ENTITY TESTY:
- teams

VÝSLEDEK:
Processed planner jobs: 15

Potvrzeno:
✔ planner worker OK
✔ unified ingest OK
✔ RAW payload ukládání OK
✔ parser flow OK
✔ merge flow OK

Poznámky:
- část league_id vrací results=0
- nejde o pipeline chybu
- jde o provider coverage reality / empty season scope

Příklady:
league=142 → results=20
league=59  → results=29
league=37  → results=38

Naopak:
league=110 / 265 / 63 / 242 / 141 / 257 / 207 / 14 / 149
→ results=0

Merge výsledky:
teams updated: 2
league_teams inserted: 68

FINAL COUNTS:
public.teams = 7502
public.team_provider_map = 7091
public.matches = 122803

STATUS:
HK core pipeline = STABLE

===========================================================================
2) BK – BASKETBALL CORE VALIDACE
===========================================================================

RUN GROUP:
BK_TOP

ENTITY TESTY:
- teams
- fixtures

--------------------------------------------------------------------------------
BK TEAMS
--------------------------------------------------------------------------------

Processed jobs:
9

Výsledek:
✔ planner OK
✔ ingest OK
✔ merge OK

Merge:
teams updated: 16
teams inserted: 58
team_provider_map inserted: 58
league_teams inserted: 74

matches inserted: 731

FINAL COUNTS:
public.teams = 7560
public.team_provider_map = 7149
public.matches = 123534

STATUS:
BK teams pipeline = CONFIRMED

--------------------------------------------------------------------------------
BK FIXTURES
--------------------------------------------------------------------------------

Processed jobs:
7

Výsledek:
✔ ingest OK
✔ RAW payload flow OK
✔ merge runner OK

Poznámka:
- parse fixtures payloads = 0
- ale merge běh proběhl korektně
- queue následně prázdná

Merge:
matches updated: 92944
matches inserted: 0

STATUS:
BK fixtures pipeline = STABLE

===========================================================================
3) READY_AUTOMAT FRONTY
===========================================================================

Potvrzeno:
READY_AUTOMAT backlog byl vyčištěn.

Aktuální stav:
- pending = 0
- error = 0

Pipeline nyní:
✔ planner-safe
✔ rerun-safe
✔ merge-safe

===========================================================================
4) MULTISPORT CORE STAV
===========================================================================

Aktuálně potvrzené CORE sporty:

✔ FB
✔ HK
✔ BK
✔ HB
✔ VB
✔ AFB
✔ CK
✔ RGB
✔ TN (partial/core)

Potvrzené entity:
- leagues
- teams
- fixtures

===========================================================================
5) ARCHITEKTONICKÝ ZÁVĚR
===========================================================================

MATCHMATRIX nyní funguje jako:
- sjednocená multisport CORE harvesting platforma
- planner-driven orchestrator
- unified RAW/staging/public flow
- provider-isolated ingest architecture

Potvrzený pattern:

planner
→ unified ingest
→ RAW payloads
→ parser
→ staging
→ unified merge
→ public canonical layer

===========================================================================
6) DALŠÍ KROK
===========================================================================

Priorita:
1.
dokončit audit reality check:
- BK
- HK
- HB
- RGB

2.
poté:
ODDS layer validation (paid/API activation)

3.
následně:
PEOPLE multi-provider expansion

==========================================================================

# BK CORE VALIDACE – CONTROLLED FLOW CHECK

## BK fixtures validace (api_sport / BK_TOP)

Planner queue:

* api_sport | BK | fixtures | BK_TOP | done = 9
* Controlled harvest flow doběhl bez pending jobů.

Validace public.matches:

* public.matches (sport_id=3, ext_source=api_sport)
* matches_cnt = 1114
* distinct_matches = 1114
* kickoff range = 2023-09-23 → 2025-06-12

Kontrola integrity:

* home_team_id / away_team_id jsou správně navázané na public.teams
* missing_public_team = 0

Důležitá architektonická poznámka:

* Původní kontrola proti public.team_provider_map vracela missing_team_map = 1114
* Nešlo o reálný problém dat.
* public.matches.home_team_id / away_team_id již obsahují canonical public team_id.
* public.teams používá starší canonical model:

  * ext_source
  * ext_team_id
* public.teams aktuálně neobsahuje sloupec sport_id.

Stav provider mapping vrstvy:

* public.team_provider_map:

  * api_sport = 2236 mappingů
* Mapping vrstva existuje a je validní.

Závěr:

* BK fixtures controlled flow je plně validovaný.
* Neexistují duplicitní matches.
* Neexistují orphan team reference.
* Public canonical vrstva je konzistentní.
* BK core může zůstat ve stavu CONFIRMED v runtime audit.

## MEDIA LAYER – ARTICLES / SOURCES – 2026-05-09

Byla zahájena a stabilizována základní MEDIA vrstva.

Cíl vrstvy:
- články
- news
- highlights
- videa
- budoucí komentáře / social / partner content

Potvrzený cílový pattern:
source/provider
→ staging
→ public media tables
→ mapování na matches / teams / leagues
→ translations / AI summary

Aktuální DB základ:

public:
- content_sources
- articles
- article_match_map
- article_team_map
- article_league_map
- article_translations

staging:
- staging.stg_media_articles

Doplněno:
- deduplikační unikátní indexy:
  - content_sources(name, source_type)
  - articles(content_source_id, url)
  - article_match_map(article_id, match_id)
  - article_team_map(article_id, team_id)
  - article_league_map(article_id, league_id)
  - article_translations(article_id, language_code)

Doplněna validace source_type:
- rss
- news_api
- official_site
- youtube
- video_api
- social
- manual
- scraper
- partner_api
- sitemap

Vytvořen první RSS worker:
- C:\MatchMatrix-platform\workers\pull_rss_media_articles_v1.py

Worker technicky ověřen:
- připojení do DB funkční
- načítání content_sources funkční
- timeout + User-Agent doplněn
- staging insert připraven přes ON CONFLICT(provider, url) DO NOTHING

Bootstrap content sources:
- UEFA / rss
- FIFA / rss
- NHL / rss
- NBA / rss

Výsledek RSS validace:
- UEFA: endpoint dostupný, ale vrací 0 entries
- FIFA: RSS endpoint vrací 404
- NHL: RSS endpoint vrací 403, vhodnější bude sitemap/news scraper
- NBA: RSS endpoint vrací 404, vhodnější official_site/news scraper

Rozhodnutí:
- první RSS zdroje ponechány v content_sources jako evidence
- všechny 4 RSS zdroje přepnuty na is_active=false
- další směr MEDIA vrstvy:
  1. sitemap source pro NHL
  2. official_site scraper pro NBA/FIFA/UEFA
  3. později youtube/video_api pro highlights

Stav:
MEDIA layer základ = READY
RSS bootstrap = TECH_OK / SOURCE_URL_INVALID
Další krok = sitemap / official_site worker

# MATCHMATRIX MEDIA LAYER – STATUS ZÁPIS PRO DALŠÍ CHAT

## DATUM

2026-05-10

---

# MEDIA LAYER – ARCHITEKTURA

Potvrzena první funkční reusable multisport MEDIA pipeline:

official_site
→ staging.stg_media_articles
→ public.articles
→ media_team_alias_rules
→ article_media_team_alias_map
→ media_team_alias_bridge
→ runtime_entity_audit

---

# NOVÉ / POTVRZENÉ TABULKY

## PUBLIC

* content_sources
* articles
* article_translations
* article_team_map
* article_match_map
* article_league_map
* media_team_alias_rules
* article_media_team_alias_map
* media_team_alias_bridge

## STAGING

* staging.stg_media_articles

---

# NHL / HK MEDIA

## SOURCE

* NHL official_site
* https://www.nhl.com/news

## STATUS

* HTTP 200 OK
* static scraper funguje
* FOUND URLS ≈ 65+
* public.articles funguje
* alias mapping funguje

## RUNTIME AUDIT

api_hockey / HK / highlights

STATUS:
PARTIAL

EVIDENCE:
official_site scraper OK | NHL HTTP 200 | staging=65+ | public.articles merged | article_media_team_alias_map OK

---

# NHL MEDIA ALIAS RULES

Vytvořeny aliasy:

* Anaheim Ducks
* Buffalo Sabres
* Carolina Hurricanes
* Colorado Avalanche
* Florida Panthers
* Minnesota Wild
* Montreal Canadiens
* Philadelphia Flyers
* Tampa Bay Lightning
* Vegas Golden Knights

Provider:
nhl_official_site

---

# NHL ARTICLE MAPPING

Potvrzeno:

* article_media_team_alias_map funguje
* URL slug match funguje
* více týmů v jednom článku funguje

---

# NBA / BK MEDIA

## SOURCE

* NBA official_site
* https://www.nba.com/news

## STATUS

* HTTP 200 OK
* static scraper funguje
* public.articles merge funguje

## DŮLEŽITÝ FIX

Bug:
NBA URL byly ukládány pod nhl.com

Opraven worker:
pull_official_site_media_articles_v1.py

Fix:
dynamic site_root přes urlparse/urljoin

---

# NBA MEDIA ALIAS RULES

Vytvořeny full + short aliasy:

* lakers
* thunder
* knicks
* cavaliers
* timberwolves
* spurs
* 76ers
* nuggets
* warriors

Provider:
nba_official_site

---

# NBA ARTICLE MAPPING

Potvrzeno:

* BK article_media_alias_maps = 27
* cross-source pollution = 0

Byl opraven problém:
thunder → thunderbirds (NHL false positive)

Fix:
strict source filter přes content_sources.name = 'NBA'

---

# CLEANUPY

## NBA cleanup

Smazány špatné NBA články uložené pod nhl.com

## UEFA cleanup

Smazán falešný landing page article:
https://www.uefa.com/news-media/news/

---

# UEFA / FB MEDIA

## SOURCE

https://www.uefa.com/news-media/stories/

## STATUS

HTTP 200 OK
ale:

* generic static scraper nevidí article URLs
* stránka vrací hlavně navigation links

## RUNTIME AUDIT

api_football / FB / articles

STATUS:
PARTIAL

EVIDENCE:
UEFA official_site HTTP 200, but inspected page returns navigation links only; no article URLs found by static scraper.

NEXT ACTION:
Create UEFA-specific scraper or alternate source/API.

---

# FIFA / FB MEDIA

## SOURCE

https://www.fifa.com/en/news

## STATUS

HTTP 200 OK
FOUND URLS = 0

Pravděpodobně:

* JS rendered
* anti scraping
* dynamic content

Zatím bez ingestu.

---

# AKTUÁLNÍ COUNTS

public.articles:

* NHL official_site = 74
* NBA official_site = 36

Celkem:
110+

---

# DŮLEŽITÉ SOUBORY

## WORKERS

C:\MatchMatrix-platform\workers\pull_official_site_media_articles_v1.py

C:\MatchMatrix-platform\workers\inspect_official_site_links_v1.py

---

# DALŠÍ DOPORUČENÉ KROKY

1.

Vytvořit:
media_source_health_audit

sledovat:

* HTTP status
* found URLs
* inserted rows
* JS rendered
* blocked source
* RSS dead
* sitemap dead
* worker type

2.

Rozšířit NHL alias coverage:
všech 32 týmů

3.

Rozšířit NBA alias coverage:
všech 30 týmů

4.

Začít:
player aliases
coach aliases
league aliases

5.

Vytvořit:
provider-specific UEFA scraper

6.

Prověřit:
headless/browser scraping layer
(playwright/selenium)

---

# KLÍČOVÝ VÝSLEDEK DNE 10.5.2026

Potvrzena první skutečně funkční reusable multisport MEDIA architecture pro MatchMatrix.


## 13. TEXT PRO NOVÝ CHAT
Použij tento text:

Navazujeme v MatchMatrix na aktuální multisport ingest pattern: každý sport má vlastní ingest složku, runy jsou ve workers, football je speciální větev, non-FB sporty jedou přes společný technický pattern; aktuální pravda je v auditních tabulkách a OPS, tento master dokument je hlavní referenční kontext. Teď konkrétně pokračujeme bodem: 

Rozšířit stejný pattern:

- RGB (rugby)
- HB (handball)

→ jednotný PEOPLE engine
