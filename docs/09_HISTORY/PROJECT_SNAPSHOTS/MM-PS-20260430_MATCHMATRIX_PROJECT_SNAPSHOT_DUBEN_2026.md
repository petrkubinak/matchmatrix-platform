# MM-PS-20260430

# MATCHMATRIX PROJECT SNAPSHOT – DUBEN 2026

## HISTORICKÝ PROJEKTOVÝ CHECKPOINT

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PS-20260430 |
| Název | MatchMatrix Project Snapshot – duben 2026 |
| Typ | Project Snapshot / historický projektový checkpoint |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum snapshotu | 2026-04-30 |
| Rekonstruované období | 2026-04-01 až 2026-04-30 |
| Přímé zdrojové pokrytí | 2026-04-01 až 2026-04-21 |
| Předchozí checkpoint | MM-PS-20260331 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Doporučené umístění | `docs/09_HISTORY/PROJECT_SNAPSHOTS/MM-PS-20260430_MATCHMATRIX_PROJECT_SNAPSHOT_DUBEN_2026.md` |
| Zdroj pravdy | Databázový historický korpus MatchMatrix |
| Hlavní zdrojové dokumenty | MM-HIS-0226 až MM-HIS-0257 |
| Pracovní rekonstrukce | `history_reconstruction_20260401_20260407_working_report_v1.md`, `history_reconstruction_20260408_20260412_working_report_v1.md`, `history_reconstruction_20260415_20260421_working_report_v1.md` |

---

## Upozornění k použití

Tento dokument je **historický projektový checkpoint**. Popisuje stav, rozhodnutí, implementované části, rozpracované oblasti a strategický směr projektu MatchMatrix v dubnu 2026.

Nejde o popis současného produkčního stavu platformy. Názvy skriptů, tabulek, cest, providerů, počty záznamů, limity API, runtime postupy a označení připravenosti musí být před dnešním použitím porovnány s aktuální databází, repozitářem a dokumentací.

Historické zdroje často používají výrazy:

- „hotovo“,
- „plně funkční“,
- „production ready“,
- „core dokončeno“,
- „100 %“,
- „systém je čistý“.

V řadě případů se tyto výrazy vztahovaly pouze na:

- jeden provider,
- jednu ligu nebo sezonu,
- smoke test,
- jednotlivý runtime běh,
- core entity bez odds a People Layer,
- staging vrstvu bez potvrzeného public merge,
- testovací rozsah bez dlouhodobého monitoringu.

Tento checkpoint proto rozlišuje:

1. **prokazatelně implementované a runtime ověřené části,**
2. **end-to-end potvrzený tok v omezeném rozsahu,**
3. **technicky připravené nebo částečné části,**
4. **strategické návrhy a cílovou architekturu,**
5. **tvrzení, která byla později opravena, zúžena nebo zpochybněna.**

### Omezení časového pokrytí

V historickém korpusu bylo pro duben 2026 nalezeno 32 dokumentů s daty od 1. do 21. dubna.

Pro období 22.–30. dubna nebyly v použitém manifestu identifikovány samostatné dubnové zdrojové dokumenty. Tento měsíční checkpoint proto používá datum 30. dubna jako identifikátor měsíčního snapshotu, ale poslední přímo doložený technický stav pochází z 21. dubna 2026.

Dokument nesmí tvrdit, že mezi 22. a 30. dubnem nedošlo k žádné práci. Znamená pouze, že taková práce není doložena použitým historickým korpusem.

---

# 1. Účel checkpointu

Cílem dokumentu je rekonstruovat vývoj MatchMatrix za duben 2026 a zachytit období, ve kterém se projekt posunul:

- od ladění jednotlivých TheOdds aliasů k řízenému canonical matchingu,
- od obecného `NO_MATCH_ID` k reason-code klasifikaci chyb identity a provider coverage,
- od jednotlivých ingest skriptů k systematickému runtime auditu sport × entity,
- od databázové a OPS připravenosti ke skutečně ověřované execution vrstvě,
- od football-first řešení k dalším sportům s reálným core tokem,
- od ručního smoke testu k planner-driven ingest cycle,
- od obecného „jeden provider pro sport“ k architektuře provider-by-entity,
- od ručního výběru soutěží k cílovému discovery-based harvest scope,
- od rozpadlé API-Football identity k řízenému resetu a čistému rebuildu,
- od prvních AUTO SAFE strategií k auditovatelnému Ticket Engine základu.

Checkpoint současně vymezuje oblasti, které k poslednímu doloženému dni zůstávaly neúplné nebo sporné.

---

# 2. Metodika rekonstrukce

## 2.1 Použité zdroje

Rekonstrukce vychází z:

- denních zápisů,
- navazovacích dokumentů,
- pracovních technických reportů,
- runtime auditů,
- checklistu execution vrstvy,
- DB počtů uvedených v zápisech,
- konkrétních run ID,
- popisů změn skriptů a orchestrace,
- pracovních rekonstrukčních zpráv za tři dubnové bloky.

Zdrojový rozsah:

```text
MM-HIS-0226 až MM-HIS-0257
```

Celkem:

```text
32 obsahových dokumentů
```

## 2.2 Klasifikace důkazů

| Úroveň | Význam |
|---|---|
| IMPLEMENTED / RUNTIME TESTED | Existuje konkrétní skript, změna, běh nebo DB výsledek |
| END-TO-END CONFIRMED | Zdroj uvádí tok od pullu nebo RAW až do public vrstvy |
| ORCHESTRATION CONFIRMED | Planner, ingest cycle, parser a merge byly v uvedeném rozsahu spuštěny |
| STAGING CONFIRMED | Data byla ověřena ve staging vrstvě, ale public merge nebyl ještě doložen |
| TECH READY | Schéma, konfigurace nebo worker existuje, ale plný runtime tok není potvrzen |
| PARTIAL / TRANSITIONAL | Funguje jen omezená část toku nebo probíhá rebuild |
| STRATEGIC DESIGN | Cílový model nebo architektonické pravidlo |
| BLOCKED | Blokace providerem, tarifem, pokrytím, identitou nebo orchestrace |
| CONTRADICTED | Dva historické zdroje uvádějí odlišný stav |
| SUPERSEDED | Pozdější dokument opravuje nebo nahrazuje předchozí stav |

## 2.3 Pravidla chronologie

- Datum dokumentu má přednost před datem poslední změny souboru.
- Dokument označený jako plán není důkazem realizace.
- Pozdější konkrétní runtime výsledek má vyšší váhu než dřívější obecný souhrn.
- Označení `READY` nebo `DONE` se vždy omezuje na doložený provider, sport, entity a testovací rozsah.
- Rozdílné databázové počty se nesčítají a neinterpretují bez znalosti filtru.
- Celkový počet `public.matches` se nesmí zaměnit s provider-specific počtem.
- Chybějící zdroj po 21. dubnu není důkazem nulové aktivity.

## 2.4 Známé duplicity, varianty a návaznosti

- MM-HIS-0226 je plán, který byl následně nahrazen skutečnými výsledky.
- MM-HIS-0229 a MM-HIS-0230 se doplňují při auditu `NO_MATCH_ID`.
- MM-HIS-0236 je strategický plán; MM-HIS-0237 již obsahuje konkrétnější FB audit.
- MM-HIS-0242 potvrzuje BK pouze do staging; public merge je potvrzen až MM-HIS-0244.
- MM-HIS-0243 aktualizuje AFB z plánovaného sportu na potvrzený core tok.
- MM-HIS-0245 je rozšířená verze MM-HIS-0246.
- MM-HIS-0247 zásadně koriguje předchozí optimistické hodnocení API-Football identity.
- MM-HIS-0248 je překonán výsledky MM-HIS-0249 a MM-HIS-0250.
- MM-HIS-0251 zachycuje HB smoke test; MM-HIS-0255 uvádí pozdější širší stav.
- MM-HIS-0252 má dvě fyzické varianty, ale jeden obsahový dokument.
- MM-HIS-0256 a MM-HIS-0257 uvádějí rozdílný stav Tennis odds.
- Označení BSB jako hotového v MM-HIS-0254 není v tomto korpusu podloženo samostatným dokončovacím runtime reportem.

---

# 3. AI CONTEXT

MatchMatrix byl v dubnu 2026 budován jako globální multisportovní datová, analytická, odds a tiketová platforma.

Projekt měl v tomto období pět hlavních pracovních os:

1. **Canonical Data Core**
   - sporty,
   - ligy,
   - týmy,
   - zápasy,
   - provider identity,
   - aliasy,
   - canonical match lookup.

2. **Ingest a Harvest Core**
   - targets,
   - planner,
   - pull,
   - RAW,
   - provider-normalized staging,
   - merge,
   - runtime audit,
   - completion audit.

3. **Odds a Matching Core**
   - TheOdds ingest,
   - team resolution,
   - match linking,
   - reason codes,
   - provider coverage.

4. **People a Enrichment Core**
   - players,
   - player provider maps,
   - season statistics,
   - coaches,
   - team-coach history.

5. **Ticket Product Core**
   - AUTO SAFE strategie,
   - generated runs,
   - persistent ticket history,
   - pattern tracking,
   - budoucí learning loop.

Dubnový strategický směr lze shrnout takto:

> MatchMatrix nemá být kolekce sport-specific skriptů. Má být řízená harvest platforma, ve které se runtime připravenost dokazuje po jednotlivých kombinacích sport × provider × entity a ve které se provider vybírá podle konkrétní entity.

Zásadní změna oproti předchozímu období:

> Přítomnost dat v databázi nebo konfigurace v OPS již nebyla považována za dostatečný důkaz runtime připravenosti.

---

# 4. PROJECT SNAPSHOT

## 4.1 Stav na začátku dubna

Na začátku dubna již existovalo:

- canonical football jádro,
- TheOdds ingest a parser,
- team alias systém,
- provider mapy,
- první AUTO SAFE strategie,
- ukládání generated runs a historie tiketů,
- OPS targety, planner a ingest cycle,
- unified staging tabulky,
- částečně funkční People Layer,
- první multisport pokusy z března.

Hlavní otevřené problémy:

- vysoké `NO_MATCH_ID`,
- odlišné coverage mezi TheOdds a fixtures providery,
- chyby týmové normalizace,
- nejasné rozlišení DB-ready a runtime-ready,
- chybějící parser binding u části multisport toků,
- rozpadlá API-Football týmová identita,
- neúplný planner seed,
- chybějící jednotný harvest model.

---

## 4.2 1. dubna – AUTO SAFE a definice problému TheOdds

Byl doložen funkční AUTO SAFE worker:

```text
436_auto_safe_seeder_v3.py
```

Podporované strategie:

```text
AUTO_SAFE_01
AUTO_SAFE_02
AUTO_SAFE_03
```

Konkrétní běh:

```text
run_id = 113
template = 203
tickets_count = 9
total_stake = 900
min_total_odd = 6.8644
max_total_odd = 11.2572
avg_total_odd = 8.3664
max_possible_win = 1125.72
```

Tok zahrnoval:

```text
template
→ preview validation
→ combination generation
→ generated_runs
→ generated_tickets
→ ticket_history_base
→ ticket_generation_runs
```

To potvrzuje funkční základ Ticket Engine.

Dobové označení „self-learning engine“ bylo širší než skutečně doložený stav. Přesnější interpretace:

> Systém vytvářel historická data, patterny a metriky potřebné pro budoucí learning vrstvu. Automatické učení nebo samooptimalizace nebyly v tomto období prokázány.

Současně byl definován zásadní TheOdds insight:

```text
problém není primárně v názvech týmů
problém je v napojení odds na fixtures
```

Plánované nearest-match a FIND_MATCH_ID změny nebyly ještě samy o sobě důkazem implementace.

---

## 4.3 2.–5. dubna – canonical matching, V3 a provider coverage

### 2. dubna

Byly uvedeny objekty:

```text
canonical_league_map
canonical_team_map
v_canonical_team_resolve
v_canonical_match_lookup
v_preferred_team_name_lookup
```

TheOdds parser byl přepojen na canonical lookup.

Běh:

```text
RUN_ID = 165
odds_inserted = 2520
skipped_no_team = 0
skipped_no_match = 72
leagues_ok = 12 / 13
```

Význam:

- team identity byla v testovaném rozsahu stabilizována,
- problém se přesunul k chybějícím zápasům nebo coverage.

### 3. dubna

Audit rozlišil:

```text
MATCHED_OK = 8539
ALIAS_OK_MATCH_MISSING = 2800
MISSING_AWAY_ALIAS = 94
MISSING_HOME_ALIAS = 22
MISSING_BOTH_ALIASES = 32
```

Dobové tvrzení „klubový fotbal 100 % OK“ neodpovídá uvedeným číslům.

Přesnější závěr:

> Mapping hlavních klubových lig se výrazně zlepšil, ale globální odds-to-match coverage nebyla úplná.

### 4. dubna

Byly uvedeny:

```text
run_theodds_ingest_v3.py
theodds_parse_multi_V3.py
theodds_matching_v3.py
```

Kritická oprava normalizace:

```text
Barcelona SC
```

se dříve mohla normalizovat na stejnou hodnotu jako:

```text
FC Barcelona
```

Po odstranění `sc` ze seznamu generických slov byla identita oddělena.

Výsledek běhu:

```text
odds_inserted = 2162
skipped_no_team = 0
skipped_no_match = 24
match_ok_leagues = 11 / 13
```

### 5. dubna

Copa Libertadores dosáhla v jednom testovaném běhu:

```text
no_match = 0
```

Parser byl stabilizován proti hodnotám odds mimo rozsah DB typu:

```python
if odd_value >= 1000:
    continue
```

Běh 185:

```text
odds_inserted = 456
skipped_no_match = 28
unmatched_rows = 28
```

Rozdíl mezi 24 a 28 není automaticky regrese, protože šlo pravděpodobně o odlišný vstupní snapshot nebo rozsah.

---

## 4.4 6. dubna – safe linker, reason codes a harvest audit

Safe linker připojil:

```text
28 zápasů
```

Rozdělení:

```text
Libertadores = 18
World Cup = 5
Brazil = 3
Serie A = 2
```

Backlog byl rozdělen na:

| Bucket | Počet |
|---|---:|
| PAIR_MISSING | 33 |
| COMPETITION_RISK | 3 |
| FALSE_POSITIVE_RISK | 2 |
| MAPPING_EDGE | 2 |
| MAPPING_GAP | 2 |
| SOURCE_GAP | 2 |

Toto byl důležitý governance posun:

> Nespárovaný odds řádek již nebyl automaticky považován za alias nebo parser bug.

Football-Data běh uváděl:

```text
RC = 0
matches = 105603 → 105603
odds_inserted = 382
skipped_no_match = 21
```

Audit 568 měl ukázat, že přibližně 99 % zkoumaných chybějících párů nebylo přítomno ani ve Football-Data RAW.

Tuto hodnotu lze používat pouze jako dobový auditní závěr, protože úplný SQL výstup není součástí snapshotu.

Současně byl přijat strategický postup:

```text
sport po sportu
provider realita
entity realita
execution cesta
datový tok
post-run návaznosti
runtime verdict
```

Vznikl první FB auditní základ v:

```text
ops.fb_entity_audit
```

---

## 4.5 7.–8. dubna – People Layer a harvest governance

### FB coaches

Byl uveden worker:

```text
run_api_football_coaches_ingest_v1.py
```

Tok:

```text
API
→ staging.stg_provider_coaches
→ public.coaches
→ coach_provider_map
→ team_coach_history
```

Chybějící enrichment:

- úplné `start_date` a `end_date`,
- `league_id`,
- `season`,
- přesnější current flag.

Přesný závěr:

> Základní coaches tok byl funkční, ale časová a soutěžní historie nebyla úplná.

### FB players

Dne 7. dubna byl popsán gap:

```text
public.players = 1490
provider map = 1490
staging = empty
preview = empty
```

Dne 8. dubna byl již uveden aktivní tok:

```text
fetch
→ players_import
→ stg_provider_players
→ public.players
→ player_provider_map
→ player_season_statistics
```

Růst:

```text
players = 1490 → přibližně 1958
stats = 1308 → přibližně 1548
```

Free limit:

```text
max 3 pages
přibližně 60 hráčů na ligu a sezonu
```

Přesný závěr:

> FB players pipeline byla runtime ověřena, ale coverage zůstávala omezená tarifem.

### Harvest governance

Byly identifikovány hlavní OPS objekty:

```text
provider_sport_matrix
ingest_entity_plan
provider_entity_coverage
ingest_targets
ingest_planner
job_runs
```

Bylo rozhodnuto:

```text
OPS = řídicí zdroj pravdy
```

ale současně bylo zjištěno:

```text
enabled = true ≠ runtime ready
tech_ready ≠ production ready
```

---

## 4.6 9. dubna – runtime checklist a parse binding

Checklist 614 stanovil, že kombinace sport × entity je runtime ready pouze při existenci:

1. workeru,
2. runneru,
3. pull vrstvy,
4. parseru,
5. merge,
6. OPS bindingu,
7. healthchecku nebo smoke testu.

Definované stavy:

```text
READY
PARTIAL
OPS_ONLY
DESIGN_ONLY
BLOCKED_PROVIDER
```

U API-Sport teams byl nalezen root cause:

```text
pull
→ raw
→ staging payload
→ STOP
```

Parser existoval, ale nebyl automaticky volán.

Opravený soubor:

```text
ingest/API-Sport/pull_api_sport_teams.ps1
```

Doplněné volání:

```text
run_parse_api_sport_teams_v1.py
```

Výsledek pro Basketball:

```text
stg_provider_teams +18 řádků
```

V tento den byl potvrzen staging tok, nikoli ještě celý public merge.

---

## 4.7 10. dubna – Basketball, Volleyball a American Football

### Basketball

Pozdější dokument uváděl potvrzený tok:

```text
pull
→ raw
→ staging
→ provider_map
→ public.matches
```

### Volleyball

DB důkazy:

```text
public.matches = 178
team_provider_map = 12
league = SuperLega
statusy = FINISHED
```

### American Football

Uvedený stav:

```text
teams = 34
fixtures staging = 335
public.matches = 335
FINISHED = 318
SCHEDULED = 17
```

Opravena byla sport-specific struktura:

```text
game.date = objekt
```

Technická pravidla:

```text
PowerShell JSON BOM → utf-8-sig
dict pro psycopg2 → Json() nebo serializovaný string
```

Přesný závěr:

> BK, VB a AFB měly v uvedeném testovacím rozsahu potvrzený core tok do public vrstvy. To neprokazovalo kompletní historické coverage, odds, People Layer ani dlouhodobý produkční provoz.

---

## 4.8 12. dubna – Baseball staging a API-Football controlled reset

### Baseball

Byly opraveny:

- neplatný DSN s `set DB_DSN=`,
- nedostatečná práva uživatele `mm_ingest`,
- nesprávný sloupec `entity`,
- neaktivní main entrypoint a chybějící debug.

Potvrzený teams tok:

```text
API-Sport baseball
→ stg_api_payloads
→ parse_api_baseball_teams_to_staging.py
→ stg_provider_teams
```

Výsledek:

```text
RAW results = 32
odfiltrovány American League a National League
vložené týmy = 30
distinct teams = 30
duplicity = 0
```

Fixtures:

```text
raw pull = CONFIRMED
run_id = 20260412002129042
fixtures staging = NOT YET CONFIRMED
public.matches = NOT YET CONFIRMED
```

Historické zdroje jsou nejednoznačné ohledně `team_provider_map`. Proto nelze k tomuto dni označit BSB jako dokončený core sport.

### API-Football controlled reset

Identifikovaný problém:

- stovky `SAME_SPORT_DUPLICATE`,
- desítky `CROSS_SPORT_COLLISION`,
- vazby na teams přes 23 tabulek,
- chyby team provider map,
- chyby merge,
- dopad na TheOdds attach.

Auditovaný rozsah:

```text
matches = 74583
fixtures staging = 74583
teams staging = 2285
provider_map = 2197
match_features = 56091
```

Byl proveden reset:

```text
public.matches pro api_football
match_features
team_provider_map pro api_football
api_football staging vrstvy
```

Následná kontrola:

```text
matches = 0
match_features = 0
team_provider_map = 0
staging = 0
```

Rozhodnutý rebuild:

```text
leagues
→ teams
→ fixtures
→ team_provider_map
→ public.matches
```

Tento krok zásadně korigoval dřívější optimistické hodnocení FB readiness.

---

## 4.9 15.–17. dubna – API-Football clean rebuild a planner opravy

### 15. dubna

Leagues byly uvedeny jako čisté.

Teams:

```text
staging.api_football_teams = 2254
stg_provider_teams = 0
team_provider_map = 0
```

Byla identifikována chybějící bridge:

```text
api_football_teams
→ stg_provider_teams
```

### 16. dubna

Pro kombinaci:

```text
provider = api_football
sport = FB
entity = fixtures
run_group = EU_top,EU_exact_v1
```

nebyla správně připravena planner queue.

Byla přijata pravidla:

```text
ops.ingest_targets = master konfigurace
ops.ingest_planner = pracovní queue
sport_code = FB
```

Potvrzený běh:

```text
Processed planner jobs = 5
Teams extractor = YES
Teams parser = YES
Fixtures parser = YES
Merge executed = YES
Final status = OK
```

Metriky:

```text
matches updated = 1650
matches inserted = 79610
public.matches = 111285
```

### 17. dubna

Do `run_ingest_cycle_v3.py` byla doplněna větev:

```text
STEP 2B – API FOOTBALL RAW TO PUBLIC MERGE
```

Spouštěný krok:

```text
run_api_football_fixtures_raw_to_public.ps1
```

Ověřené běhy:

```text
20260417213521047 → 240 / 240 / 0
20260417213618896 → 306 / 306 / 0
20260417213733016 → 192 / 192 / 0
```

DB údaj:

```text
public.matches pro api_football = 77435
```

Hodnota 111285 byla pravděpodobně celkový stav, zatímco 77435 provider-specific slice. Bez přesného SQL filtru se nesmějí zaměnit.

Přesný závěr:

> API-Football core pipeline byla po controlled resetu znovu runtime průchozí a několik uvedených běhů mělo nulový rozdíl mezi RAW a public.

---

## 4.10 18.–20. dubna – Handball od smoke testu k orchestrace

### 18. dubna

HB leagues parser byl upraven podle skutečného payloadu.

Potvrzené ligy zahrnovaly:

```text
183 African Championship
131 Champions League
145 EHF European League
```

Teams smoke test:

```text
league = 131
season = 2024
```

Fixtures specifikum:

```text
endpoint = games
ne fixtures
```

a:

```text
bez from/to
```

Výsledek:

```text
results = 132
stg_provider_fixtures = 132
```

Tento stav potvrzoval staging smoke test jedné soutěže.

### 19. dubna

Byly uvedeny:

```text
leagues = CONFIRMED
teams = CONFIRMED
fixtures = CONFIRMED včetně public.matches
```

ale planner queue byla prázdná:

```text
Processed jobs = 0
```

Tedy:

```text
data pipeline = funkční
automatická orchestrace = ještě ne
```

### 20. dubna

Pozdější dokument uvádí kompletní core pattern:

```text
run_ingest_cycle_v3.py
run_ingest_planner_jobs.py
run_unified_ingest_v1.py
run_unified_staging_to_public_merge_v3.py
```

DB důkazy:

```text
public.matches api_handball = 2517
FINISHED = 2468
SCHEDULED = 38
CANCELLED = 11

team_provider_map api_handball = 752
missing_team_map = 0

public.leagues api_handball = 31
```

Teams fallback:

```text
fixtures
→ extract teams
→ stg_provider_teams
→ team_provider_map
```

Přesný závěr:

> Handball core tok byl v uvedeném rozsahu end-to-end potvrzen a orchestrace byla dobovým auditem označena za funkční. Odds a People Layer do tohoto potvrzeného core stavu nepatřily.

---

## 4.11 19. dubna – cílový harvest model

Byla formulována cílová posloupnost vrstev:

```text
1. Core
   leagues
   teams
   fixtures
   odds

2. People
   players
   coaches

3. Content
   articles
   commentary
   posts

4. Visual
   video
   highlights
```

Klíčový harvest princip:

```text
year / season
→ provider league discovery
→ active scope
→ teams
→ fixtures
→ odds
```

Klíčové providerové pravidlo:

```text
provider-by-entity
```

nikoli pouze:

```text
provider-by-sport
```

Tento model byl strategický návrh. Dubnové zdroje neprokazují jeho úplnou automatickou implementaci.

---

## 4.12 20. dubna – Rugby core tok

Rugby stav:

```text
leagues = 142
teams = 6
team_provider_map = 6
fixtures/public.matches = 15
```

Sport-specific opravy:

```text
Finished → FINISHED
score text → integer
```

Důležitý architektonický poznatek:

> API-Sports nepoužívá jednotný payload pro všechny sporty. Shared orchestrace je možná, ale parser a mapování musí respektovat sport-specific datový kontrakt.

Dobové označení „FULLY READY CORE SPORT“ bylo příliš široké.

Přesnější závěr:

> Rugby core chain byl potvrzen na omezeném testovacím datasetu se 6 týmy a 15 zápasy.

Stejný dokument uvádí BSB mezi dokončenými sporty, ale v dostupném dubnovém korpusu není samostatný dokončovací runtime důkaz.

---

## 4.13 21. dubna – Tennis canonical model a Cricket plán

Tennis byl adaptován na team-based model:

```text
hráč = team
dvojice = team
```

Potvrzené vrstvy:

```text
RAW
→ staging
→ public.teams
→ team_provider_map
→ public.matches
```

Jeden dokument uvádí:

```text
1 RAW → 69 fixtures
přibližně 50+ live matches
sport_id = 4
status = LIVE
```

Leagues byly pouze search-based seed:

```text
PARTIAL
```

### Rozpor Tennis odds

MM-HIS-0256 uvádí:

```text
odds = CONFIRMED
pull_api_tennis_odds_v1.py
fractional → decimal conversion
```

MM-HIS-0257 uvádí:

```text
odds = NOT READY
```

Bez přesného času vzniku nelze bezpečně určit pořadí.

Finální dubnový verdict:

```text
TN participant identity = CONFIRMED
TN fixtures staging = CONFIRMED
TN public matches = CONFIRMED in live test scope
TN leagues = PARTIAL
TN odds = CONTRADICTED / REQUIRES CONFIRMATION
TN player detail = NOT READY
TN enrichment = NOT READY
```

Cricket byl pouze plánován:

```text
API-Cricket folder
RapidAPI configuration
fixtures worker
parser
public merge
odds later
```

Runtime implementace Cricket v tomto dubnovém korpusu není potvrzena.

---

# 5. DATABASE SNAPSHOT

## 5.1 Cílové databázové vrstvy

V dubnu se upevnil model:

| Vrstva | Role |
|---|---|
| `ops` | targets, planner, coverage, runtime status, audit a řízení harvestu |
| provider RAW | původní payload nebo provider-specific historická mezivrstva |
| `staging.stg_api_payloads` | společné úložiště provider payloadů |
| `staging.stg_provider_*` | provider-normalized staging |
| `public.*` | canonical sportovní a produktová data |
| audit views/tables | runtime entity audit, completion audit, coverage a reason codes |

## 5.2 Důležité DB objekty

### OPS a orchestrace

- `ops.provider_sport_matrix`
- `ops.ingest_entity_plan`
- `ops.provider_entity_coverage`
- `ops.ingest_targets`
- `ops.ingest_planner`
- `ops.provider_jobs`
- `ops.job_runs`
- `ops.fb_entity_audit`
- `runtime_entity_audit`
- `sport_completion_audit`

### Canonical a matching

- `canonical_league_map`
- `canonical_team_map`
- `v_canonical_team_resolve`
- `v_canonical_match_lookup`
- `v_preferred_team_name_lookup`
- `team_provider_map`
- `team_aliases`
- `public.matches`
- `public.odds`
- `public.unmatched_theodds`

### People

- `staging.stg_provider_players`
- `public.players`
- `player_provider_map`
- `player_season_statistics`
- `staging.stg_provider_coaches`
- `public.coaches`
- `coach_provider_map`
- `team_coach_history`

### Ticket Engine

- `generated_runs`
- `generated_tickets`
- `ticket_history_base`
- `ticket_generation_runs`
- `ticket_patterns`
- `pattern_candidates`
- `pattern_map`

## 5.3 Dobové počty a runtime body

Tyto hodnoty představují různé dny, providery a filtry. Nejde o jeden konzistentní DB snapshot.

| Datum / větev | Metrika | Hodnota |
|---|---|---:|
| 1. dubna | AUTO SAFE run tickets | 9 |
| 2. dubna | TheOdds odds inserted | 2 520 |
| 2. dubna | TheOdds skipped no team | 0 |
| 2. dubna | TheOdds skipped no match | 72 |
| 4. dubna | TheOdds odds inserted | 2 162 |
| 4. dubna | TheOdds skipped no match | 24 |
| 5. dubna | Run 185 odds inserted | 456 |
| 5. dubna | Run 185 unmatched | 28 |
| 6. dubna | Football-Data public matches | 105 603 |
| 8. dubna | FB players | přibližně 1 958 |
| 8. dubna | FB player stats | přibližně 1 548 |
| 10. dubna | VB public matches | 178 |
| 10. dubna | AFB public matches | 335 |
| 12. dubna | BSB playable teams staging | 30 |
| 12. dubna před resetem | API-Football matches | 74 583 |
| 12. dubna před resetem | API-Football teams staging | 2 285 |
| 12. dubna před resetem | API-Football provider map | 2 197 |
| 12. dubna před resetem | Match features | 56 091 |
| 16. dubna | Matches inserted | 79 610 |
| 16. dubna | Matches updated | 1 650 |
| 16. dubna | Public matches, pravděpodobně celkem | 111 285 |
| 17. dubna | API-Football public matches | 77 435 |
| 20. dubna | HB public matches | 2 517 |
| 20. dubna | HB team provider maps | 752 |
| 20. dubna | HB public leagues | 31 |
| 20. dubna | RGB public matches | 15 |
| 21. dubna | TN fixtures z jednoho RAW | 69 |
| 21. dubna | TN live matches | přibližně 50+ |

## 5.4 Identitní reset jako databázové rozhodnutí

API-Football reset byl založen na auditu závislostí a rozsahu duplicit.

Před resetem:

```text
matches = 74583
fixtures staging = 74583
teams staging = 2285
provider_map = 2197
match_features = 56091
```

Po resetu byly dotčené větve ověřeny na nule.

Tento krok byl technicky významný, ale rizikový. Do finální architektury z něj plyne pravidlo:

> Controlled reset je přípustný pouze po auditu závislostí, pokud je oprava identity bezpečně dražší a rizikovější než čistý rebuild.

---

# 6. INGEST A OPS SNAPSHOT

## 6.1 Runtime readiness model

Duben vytvořil důslednější definici runtime připravenosti.

Kombinace sport × provider × entity je `READY` pouze tehdy, pokud je potvrzeno:

```text
worker
runner
pull
RAW storage
parser
provider staging
canonical merge
OPS binding
runtime test
audit / healthcheck
```

Používané nebo navržené výsledky:

```text
READY
PARTIAL
OPS_ONLY
DESIGN_ONLY
BLOCKED_PROVIDER
```

## 6.2 Targets a planner

Rozdělení rolí:

```text
ops.ingest_targets
= master konfigurace požadovaného rozsahu

ops.ingest_planner
= pracovní fronta konkrétních jobů
```

Kritická dubnová lekce:

> Platný target bez odpovídající planner queue nevede k vykonání jobu.

## 6.3 Kanonické sport codes

V orchestrace vrstvě bylo nutné používat konzistentní zkratky:

```text
FB
HK
BK
VB
AFB
HB
BSB
RGB
TN
```

Nemíchat:

```text
FB
football
```

## 6.4 Execution pattern

Cílový core tok:

```text
planner
→ provider pull
→ RAW payload
→ provider-normalized staging
→ participant/team extraction
→ provider map
→ canonical merge
→ public
→ runtime audit
```

## 6.5 Shared versus sport-specific části

### Sdílené

- planner,
- run logging,
- RAW storage,
- základní provider dispatch,
- auditní statusy,
- merge orchestrace,
- error exit code.

### Sport-specific

- endpoint name,
- JSON struktura,
- participant identity,
- date parsing,
- score mapping,
- status mapping,
- team extraction,
- season a league parametry,
- odds formát.

## 6.6 Planner seed

Na konci doloženého období zůstával důležitý follow-up:

```text
automaticky seedovat ops.ingest_planner z ops.ingest_targets
```

Historické zdroje potvrzují ruční nebo opravovaný seed, ale neprokazují dokončenou obecnou automatizaci pro všechny sporty.

---

# 7. SPORTS READINESS SNAPSHOT

Stav vyjadřuje poslední přímo doložený dubnový stav, nikoli současnost.

| Sport | Core data | Orchestrace | Omezení / poznámka | Dubnový verdict |
|---|---|---|---|---|
| FB | Obnoven po resetu | Planner a merge runtime tested | Odds attach a identitní stabilita vyžadovaly další ověření | CORE RESTORED |
| HK | Teams potvrzeny, fixtures dříve partial | Neuzavřeno v dubnovém korpusu | Chybí finální dubnový completion report | PARTIAL |
| BK | Teams, fixtures, leagues potvrzeny | End-to-end uváděn | Omezený testovací rozsah | CORE CONFIRMED |
| VB | Teams, fixtures, leagues potvrzeny | End-to-end uváděn | 178 matches, 12 provider maps | CORE CONFIRMED |
| AFB | 34 teams, 335 matches | End-to-end uváděn | Non-playable AFC/NFC entity | CORE CONFIRMED |
| HB | 31 leagues, 752 maps, 2 517 matches | Planner/ingest cycle uváděn jako funkční | Teams fallback z fixtures, odds a people nehotové | CORE + ORCHESTRATION CONFIRMED |
| BSB | Teams staging a fixtures raw potvrzeny | Nejasné | Completion později tvrzen, ale nedoložen samostatným reportem | UNVERIFIED COMPLETION |
| RGB | 142 leagues, 6 teams, 15 matches | Core chain uváděn | Velmi omezený dataset | LIMITED CORE CONFIRMED |
| TN | Participant identity a live matches potvrzeny | Částečně | Leagues partial, odds rozpor, enrichment chybí | PARTIAL CORE CONFIRMED |
| CK/CRK | Plán | Ne | Worker a merge nejsou v korpusu potvrzeny | PLANNED |
| MMA | Další kandidát | Ne | Bez dubnového runtime důkazu | NOT VERIFIED |

---

# 8. ODDS A MATCHING SNAPSHOT

## 8.1 TheOdds V3

Duben přinesl:

- canonical team lookup,
- canonical match lookup,
- V3 matching helper,
- opravu Barcelona SC,
- nulový `NO_TEAM_MATCH` v několika uvedených bězích,
- snížení `NO_MATCH_ID`,
- safe linker,
- reason-code klasifikaci.

## 8.2 Hlavní typy problémů

```text
identity mismatch
missing fixture
provider source gap
competition risk
false positive risk
time mismatch
mapping edge
```

## 8.3 Provider coverage versus matching

Nejdůležitější dubnový odds závěr:

> Pokud referenční fixture provider zápas vůbec neposkytuje, matching logika nemůže bezpečně vytvořit canonical match pouhým fuzzy párováním názvů.

## 8.4 Otevřený stav na konci období

API-Football rebuild obnovil množství zápasů.

Další logický krok byl:

```text
TheOdds
→ reattach na nové public.matches
→ audit NO_MATCH_ID
→ false pairing kontrola
```

Dubnové zdroje neobsahují finální potvrzení, že odds attach byl po rebuildu plně stabilní.

---

# 9. PEOPLE LAYER SNAPSHOT

## 9.1 Football players

Potvrzeno:

- fetch,
- import,
- bridge,
- provider staging,
- canonical merge,
- provider map,
- season statistics.

Coverage byla omezená free tarifem.

## 9.2 Football coaches

Potvrzen základní tok:

```text
provider
→ staging
→ public.coaches
→ coach_provider_map
→ team_coach_history
```

Chybělo úplné časové a soutěžní obohacení.

## 9.3 Ostatní sporty

People Layer nebyla v dubnovém korpusu pro další sporty systematicky dokončena.

Strategické pořadí:

```text
core
→ people
→ content
→ visual
```

---

# 10. TICKET ENGINE SNAPSHOT

## 10.1 Potvrzené části

- AUTO_SAFE_01,
- AUTO_SAFE_02,
- AUTO_SAFE_03,
- run validation,
- ticket generation,
- generated runs,
- generated tickets,
- persistent history,
- generation audit,
- pattern tables a views.

## 10.2 Potvrzený běh

```text
run_id = 113
template = 203
tickets = 9
```

## 10.3 Produktový závěr

Ticket Engine měl funkční technický základ.

Nebyl však ještě prokázán:

- autonomní learning loop,
- automatická optimalizace strategií,
- stabilní ROI model,
- kompletní settlement a bankroll management,
- produkční napojení na všechny sporty a odds vrstvy.

---

# 11. ARCHITEKTONICKÁ ROZHODNUTÍ

## 11.1 Data presence není runtime readiness

Existence dat, tabulky nebo enabled targetu neznamená:

```text
runtime ready
```

## 11.2 Provider-by-entity

Provider se vybírá podle:

```text
sport × entity × coverage × quality × cost
```

nikoli jen podle sportu.

## 11.3 League discovery definuje scope

Cílový model:

```text
season
→ leagues discovery
→ active competitions
→ teams
→ fixtures
→ odds
```

## 11.4 Fixtures mohou být zdrojem participant identity

Při neúplném teams endpointu:

```text
fixtures
→ extract participants
→ canonical identity
```

## 11.5 Shared orchestrace, sport-specific parser

Unifikovat lze řízení procesu, nikoli automaticky celý datový kontrakt.

## 11.6 Canonical identity má přednost před objemem dat

Pokud je identity layer systematicky chybná, více dat pouze zvětšuje následky.

## 11.7 Reason codes místo obecné chyby

Chyby musí být klasifikovány podle skutečné příčiny, ne vedeny jako obecný `NO_MATCH_ID`.

## 11.8 Panel a automat

Směr projektu:

```text
Panel = operátorské, diagnostické a nouzové řízení
Automat = cílový hlavní harvest režim
```

---

# 12. CURRENT STATUS K POSLEDNÍMU DOLOŽENÉMU DNI

## 12.1 Potvrzené

- TheOdds V3 matching fungoval v testovaném football rozsahu.
- `NO_TEAM_MATCH` byl v konkrétních bězích nulový.
- AUTO SAFE Ticket Engine měl funkční generování a historii.
- FB players a coaches měly aktivní nebo základní end-to-end tok.
- Runtime auditní metodika byla vytvořena.
- BK, VB a AFB měly potvrzený core tok.
- API-Football větev byla po resetu znovu naplněna.
- HB měl širší potvrzený core tok a teams fallback.
- RGB měl omezený core test.
- TN participant identity a matches byly napojeny na canonical model.

## 12.2 Částečné nebo přechodové

- HK.
- BSB completion.
- TN leagues.
- TN odds.
- orchestrace seed pro všechny sporty.
- discovery-based harvest scope.
- automatický scheduler.
- odds attach po API-Football rebuildu.
- dlouhodobá provozní stabilita sportovních toků.

## 12.3 Nedoložené nebo plánované

- Cricket runtime.
- MMA runtime.
- plný multisport odds layer.
- plný People Layer mimo football.
- Content Layer.
- Visual Layer.
- skutečný autonomous learning loop.
- produkční 24/7 harvest napříč všemi sporty.

---

# 13. KLÍČOVÉ KOREKCE HISTORICKÝCH TVRZENÍ

| Dobové tvrzení | Rekonstruovaný význam |
|---|---|
| „self-learning engine“ | vznikl datový a auditní základ pro budoucí learning |
| „canonical core hotovo“ | canonical lookup fungoval v konkrétní football větvi |
| „klubový fotbal 100 % OK“ | mapping hlavních lig byl výrazně zlepšen |
| „problém už není technický“ | hlavní zbývající problém byl coverage, ale edge cases trvaly |
| „sport production ready“ | core tok byl potvrzen v omezeném testovacím rozsahu |
| „Baseball hotovo“ | dostupný korpus neobsahuje úplný dokončovací důkaz |
| „Rugby fully ready“ | fungoval omezený core dataset |
| „Tennis odds hotovo“ | jiný dokument stejného dne odds označuje za nehotové |
| „systém je čistý“ | resetovaná API-Football větev byla prázdná a připravená k rebuildu |
| „multisport platform ready“ | více sportovních toků bylo ověřeno, ale globální automat nebyl dokončen |

---

# 14. RIZIKA A TECHNICKÝ DLUH

## 14.1 Identity risk

- duplicitní canonical teams,
- cross-sport collisions,
- špatné aliasy,
- provider map inconsistency.

## 14.2 Coverage risk

- rozdílné fixtures mezi providery,
- free plan omezení,
- chybějící reprezentace a knockout fixtures,
- search-based seed místo řízeného league feedu.

## 14.3 Orchestration risk

- prázdná planner queue,
- run-group mismatch,
- `FB` versus `football`,
- chybějící parser binding,
- ruční seed planneru.

## 14.4 Data contract risk

- odlišné endpointy,
- odlišná JSON struktura,
- objektová versus textová data,
- sport-specific statusy,
- různé formáty odds.

## 14.5 Overclaiming risk

Historické označení `DONE` nebo `READY` mohlo zakrýt:

- omezený dataset,
- chybějící odds,
- chybějící People Layer,
- neověřenou opakovatelnost,
- neexistující monitoring.

---

# 15. OPEN QUESTIONS

1. Byl planner seed z `ops.ingest_targets` později plně automatizován?
2. Jak stabilní zůstal API-Football rebuild po dalších bězích?
3. Obnovil se TheOdds attach bez návratu identity konfliktů?
4. Byl BSB core skutečně dokončen?
5. Jaký byl finální dubnový stav HK?
6. Byl RGB rozšířen mimo 6 týmů a 15 zápasů?
7. Který Tennis dokument zachycuje pozdější stav odds?
8. Byly Tennis odds skutečně vloženy a auditovány v `public.odds`?
9. Byl Cricket worker implementován?
10. Byl zahájen MMA runtime build?
11. Byl discovery-based scope převeden z návrhu do kódu?
12. Vznikl společný scheduler napříč sporty?
13. Byly core sporty opakovaně ověřeny po čistém restartu?
14. Jak se později změnily počty matches, teams, players a provider maps?
15. Kdy se oddělila historická data od skutečně aktivního runtime coverage?

---

# 16. NEXT STEP

## 16.1 Dokumentační workflow

Před aktivací tohoto snapshotu:

1. spustit A17 Document Standard Compliance Audit,
2. vyřešit případné findings,
3. provést uživatelskou obsahovou kontrolu,
4. změnit verzi na 1.0 a stav na ACTIVE,
5. uložit do:
   `docs/09_HISTORY/PROJECT_SNAPSHOTS/`,
6. commitnout do Git,
7. spustit A24 APPLY do dokumentační databáze,
8. spustit A7 a ověřit manifest a databázový stav.

## 16.2 Historická rekonstrukce

Po schválení dubnového snapshotu pokračovat:

```text
květen 2026
→ červen 2026
→ sjednocení historických status dokumentů
```

## 16.3 Technický follow-up z dubna

Při návratu k technickému vývoji ověřit proti současné DB:

- API-Football identity po rebuildu,
- TheOdds attach,
- HK a BSB actual readiness,
- TN odds,
- Cricket a MMA,
- planner seed,
- discovery-based harvest,
- scheduler a 24/7 režim.

---

# 17. ZÁVĚR CHECKPOINTU

Duben 2026 byl měsícem, ve kterém MatchMatrix přešel od intenzivního lokálního ladění k systematičtějšímu řízení sportovních pipeline.

Projekt prokázal:

- funkční canonical matching v části football odds toku,
- auditovatelný Ticket Engine základ,
- runtime People Layer pro football,
- použitelnost unified ingest patternu pro několik sportů,
- schopnost provést controlled reset a clean rebuild,
- možnost využít fixtures jako fallback zdroj týmové identity,
- význam planneru, targetů a runtime auditu,
- nutnost sport-specific parserů pod společnou orchestrace vrstvou.

Současně se ukázalo:

- že provider coverage nelze nahradit fuzzy matchingem,
- že více stažených dat nezachrání chybnou canonical identitu,
- že `READY` musí být dokazováno execution chainem,
- že „univerzální pipeline“ neznamená jednotný payload,
- že dobové označení dokončenosti je nutné vždy vztáhnout ke konkrétnímu rozsahu.

Nejpřesnější souhrn dubna:

> MatchMatrix v dubnu 2026 stabilizoval významnou část football matching a ingest toku, rozšířil runtime ověření na další sporty, obnovil API-Football po řízeném identitním resetu a formuloval cílový harvest model založený na league discovery a provider-by-entity strategii. Platforma však stále nebyla globálně production ready: několik sportů bylo pouze částečně ověřeno, automatická planner orchestrace nebyla plně zobecněna a některé dobové completion stavy zůstaly neúplně doložené nebo rozporné.

---

## Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 0.9 | 2026-07-08 | Pracovní měsíční rekonstrukce dubna 2026 z MM-HIS-0226 až MM-HIS-0257. Dokument připraven k A17 a uživatelskému review. |
