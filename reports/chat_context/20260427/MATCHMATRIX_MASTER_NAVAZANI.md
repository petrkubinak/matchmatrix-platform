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


- další krok případně:
  - odds
  - people
  - downstream entity
---

## 13. TEXT PRO NOVÝ CHAT
Použij tento text:

Navazujeme v MatchMatrix na aktuální multisport ingest pattern: každý sport má vlastní ingest složku, runy jsou ve workers, football je speciální větev, non-FB sporty jedou přes společný technický pattern; aktuální pravda je v auditních tabulkách a OPS, tento master dokument je hlavní referenční kontext. Teď konkrétně pokračujeme bodem: 
Další sport