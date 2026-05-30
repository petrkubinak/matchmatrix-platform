# MATCHMATRIX — STAV PO DNEŠKU (CORE + PEOPLE + MEDIA + ODDS)

Dnes jsme dokončili zásadní milestone:

MATCHMATRIX SPORTS OPERATIONS PLATFORM

Poprvé máme funkční:

CORE
PEOPLE
MEDIA
ODDS

v jednom orchestration panelu.

---

# 1. BK CORE PIPELINE — DOKONČENO

Dokončili jsme kompletní BK unified flow.

## Opraveno

### BK fixtures normalization

Původní problém:

sport_code = basketball
score = celý JSON

merge očekával:

sport_code = BK
home_score
away_score

Opravy:

703_bk_fixtures_merge.sql
sport_id = 3
status mapping
score parsing

Výsledek:

public.matches:
FINISHED = 330
SCHEDULED = 784

---

# 2. BK PARSERS — PŘEVEDENO DO PYTHONU

## Fixtures parser

Soubor:

C:\MatchMatrix-platform\workers\parsers\105_V_parse_api_sport_bk_fixtures_to_staging_v1.py

Výsledek:

TOTAL AFFECTED ROWS: 1572

---

## Leagues parser

Soubor:

C:\MatchMatrix-platform\workers\parsers\105_W_parse_api_sport_bk_leagues_to_staging_v1.py

Výsledek:

427 affected rows

---

## Teams parser

Soubor:

C:\MatchMatrix-platform\workers\parsers\105_X_parse_api_sport_bk_teams_to_staging_v1.py

Výsledek:

72 affected rows

---

## Players parser

Soubor:

C:\MatchMatrix-platform\workers\parsers\105_Y_parse_api_sport_bk_players_to_staging_v1.py

Výsledek:

payload 745
affected rows = 22

---

# 3. BK CORE PARSER RUNNER — DOKONČEN

Spuštěno:

MATCHMATRIX BK CORE PARSERS RUNNER V1

Výsledek:

ALL BK PARSERS FINISHED

Tím jsme sjednotili:

RAW
→ Python parser
→ staging

pro BK.

---

# 4. BK UNIFIED MERGE — POTVRZEN

Spuštěno:

run_unified_staging_to_public_merge_v3.py

Výsledek:

public.matches: 123534
public.players: 18995
public.teams: 7620
public.leagues: 3471

Potvrzeno:

BK merge orchestrace funguje.

---

# 5. MATCHMATRIX CONTROL PANEL — V15

Dnes vznikl nový orchestration panel:

matchmatrix_control_panel_V15.py

Umístění:

C:\MatchMatrix-platform\tools\

---

## Nová architektura panelu

### Layer-aware orchestrace

Panel už rozlišuje:

CORE
PEOPLE
MEDIA
ODDS

a používá různé orchestration flow.

---

## SPORT_LAYER_CONFIG

Přidána centrální konfigurace:

sport
→ layer
→ provider
→ run_group

Například:

BK PEOPLE
→ sportsdataio
→ PEOPLE_AUTO_SPORTSDATAIO_2024

---

## PEOPLE LOCK

Důležitá oprava:

PEOPLE layer už ignoruje globální run_group dropdown
a používá SPORT_LAYER_CONFIG.

Tím se odstranily chyby typu:

BK → AFB_PEOPLE_V2

---

## Dynamické UI

Přidáno:

větší fonty tlačítek
dynamické scaling UI
responsive resize

---

# 6. BK PEOPLE PIPELINE — POTVRZENA

Test:

sportsdataio
BK
players
PEOPLE_AUTO_SPORTSDATAIO_2024

Výsledek:

response_count = 534
RAW id = 1445
parsed = 534

Potvrzeno:

RAW
→ staging.stg_provider_players

ověřeno SQL:

534 rows
provider = sportsdataio
sport_code = BK

---

# 7. MEDIA LAYER — POTVRZEN

Spuštěna MEDIA orchestrace.

## Funkční workers

pull_official_site_media_articles_v1.py
pull_rss_media_articles_v1.py
parse_article_details_v1.py
merge_media_articles_to_public_v1.py
match_article_entities_v1.py
score_media_articles_v1.py

Výsledek:

MEDIA PIPELINE SUMMARY
SUCCESS: 6
FAILED : 0
RESULT : OK

Potvrzeno:

official_site
RSS
parse
merge
match
score

v orchestration panelu.

---

# 8. ODDS LAYER — PLNĚ POTVRZEN

Dnes největší milestone.

## THEODDS orchestrace

Spuštěno:

run_theodds_ingest_v3.py

a zároveň:

run_football_data_ingest_v1.py

---

# 9. DAILY FULL REFRESH — HOTOVO

Potvrzena produkční architektura:

FOOTBALL_DATA
→ canonical fixtures
→ THEODDS
→ odds attach

---

# 10. ODDS MATCHING ENGINE — SILNĚ FUNKČNÍ

Potvrzeno:

ATTACH DEBUG
reason: EXACT_PAIR_EXACT_KICKOFF

To znamená:

TheOdds event
→ canonical teams
→ canonical fixtures
→ exact kickoff
→ public.matches attach
→ odds insert

---

# 11. ODDS INSERTY — POTVRZENY

## První běh

odds:
71290 → 76369
+5079

## Další refresh

76369 → 76414
+45

---

# 12. ENTERPRISE DIAGNOSTICS — HOTOVO

Potvrzeno:

LOW COVERAGE
NO MATCH ID
FALSE_PAIRING_BLACKLIST
provider alias maps
preferred lookup
team maps

Tohle je už:

enterprise sportsbook-grade normalization

---

# 13. DŮLEŽITÝ POZNATEK

Zjistili jsme:

staging tabulky nejsou standardizované.

Například:

stg_provider_players
stg_provider_teams
stg_provider_leagues

mají různé struktury.

Dlouhodobý cíl:

STANDARDIZED STAGING SCHEMA

---

# 14. AKTUÁLNÍ ARCHITEKTURA

Dnes už MatchMatrix umí:

provider
→ RAW
→ parser
→ staging
→ merge
→ public
→ media
→ odds
→ diagnostics

v jednom systému.

---

# 15. CO BUDEME DĚLAT DÁL

## PRIORITA 1 — PANEL V16

Připravíme:

SIMPLE MODE
ADVANCED MODE
status cards
diagnostics
provider health
active workers
queue monitor
scheduler prep
live progress

---

## PRIORITA 2 — STANDARDIZACE

Napříč sporty sjednotit:

parser naming
merge flow
planner flow
staging schema
worker orchestration

---

## PRIORITA 3 — DALŠÍ SPORTY

Audit:

HK
HB
CK
BSB
VB
AFB

na:

CORE
PEOPLE
MEDIA
ODDS

---

# DLOUHODOBÝ CÍL

Mít:

ALL SPORTS = SAME ARCHITECTURE

tedy:

provider
→ RAW
→ parser
→ staging
→ merge
→ public
→ analytics
→ media
→ AI
→ odds

pro všechny sporty v MatchMatrix.

# 16. DŮLEŽITÝ ARCHITEKTONICKÝ POZNATEK — ODDS MULTI-PROVIDER STRATEGIE

Dnes jsme definitivně potvrdili, že:

THEODDS není vhodný jako jediný globální odds provider pro celý MatchMatrix.

---

## Aktuální realita THEODDS

THEODDS aktuálně pokrývá hlavně:

- TOP football ligy
- evropské poháry
- FIFA World Cup
- několik dalších major competitions

Typicky:

- Premier League
- LaLiga
- Serie A
- Bundesliga
- Ligue 1
- Champions League
- Copa Libertadores
- World Cup

Ale:

nepokrývá celý rozsah soutěží,
které máme nebo budeme mít z API-Sport.

---

# DŮSLEDEK PRO MATCHMATRIX

ODDS layer musí být:

MULTI-PROVIDER ARCHITECTURE

nikoliv pouze:

THEODDS ONLY

---

# CÍLOVÁ ARCHITEKTURA ODDS

## 1. THEODDS

Použití:

TOP football odds provider

Vhodné pro:

- major football leagues
- evropské poháry
- high-quality bookmaker coverage
- line movement
- value odds
- AI prediction inputs

---

## 2. API-SPORT ODDS

Budoucí hlavní coverage provider.

Použití:

- široké pokrytí lig
- více sportů
- menší soutěže
- lower divisions
- long-tail coverage

Budoucí workers:

API_SPORT_ODDS_BACKFILL
API_SPORT_ODDS_LIVE_REFRESH

---

## 3. SPORT-SPECIFIC ODDS PROVIDERS

Později:

- basketball-specific odds
- hockey-specific odds
- tennis-specific odds
- esports odds
- betting exchange integrations

podle kvality coverage.

---

# ODDS COVERAGE MATRIX

Budeme potřebovat:

ops/provider_odds_coverage

nebo podobnou tabulku.

Každá soutěž bude mít:

ODDS_AVAILABLE
ODDS_LIMITED
ODDS_NOT_AVAILABLE
ODDS_PAID_REQUIRED
ODDS_TOP_PROVIDER
ODDS_LAST_UPDATE

---

# CÍLOVÝ ODDS FLOW

League
→ zjistit dostupné providery
→ vybrat nejlepší provider
→ stáhnout odds
→ uložit RAW
→ normalizovat bookmaker
→ normalizovat market/outcome
→ attach na public.matches
→ ukládat odds history
→ AI analytics
→ line movement
→ value detection

---

# STRATEGICKÝ CÍL

THEODDS zůstane:

FB_TOP_ODDS_PROVIDER

ale MatchMatrix musí mít:

GLOBAL MULTI-PROVIDER ODDS SYSTEM

pro:

FB
BK
HK
HB
VB
BSB
AFB
CK
TN
MMA
ESP
a další sporty.

---

# DLOUHODOBĚ

Cíl:

ALL MATCHMATRIX LEAGUES
→ pokud existují odds provider data
→ musí být schopné získat odds coverage
→ nezávisle na konkrétním providerovi.

# 17. DŮLEŽITÁ ARCHITEKTONICKÁ ZÁSADA — PROVIDER GAP ≠ BLOCKED SPORT LAYER

Dnes jsme upřesnili důležitou strategii MatchMatrix architektury.

---

# ŠPATNÝ PŘÍSTUP

Například:

VB + players = blocked

Tohle není správně.

Protože:

jeden konkrétní provider může mít omezený endpoint,
ale samotná sportovní vrstva není zablokovaná.

---

# SPRÁVNÝ PŘÍSTUP

Například:

api_volleyball + VB + players
= BLOCKED_ENDPOINT

ale:

VB + players
= PROVIDER_GAP
= hledáme vhodného providera
= fallback provider
= jiný source
= official source
= paid provider
= alternative API

---

# KLÍČOVÉ PRAVIDLO MATCHMATRIX

BLOCKED PROVIDER
≠
BLOCKED SPORT LAYER

---

# CÍLOVÁ FILOZOFIE MATCHMATRIX

Každý tradiční sport musí cílově obsahovat:

CORE
PEOPLE
MEDIA
ODDS
STATS
ANALYTICS

pro známé profesionální soutěže.

Nezáleží na tom,
jestli to pokryje:

- jeden provider
- více providerů
- official source
- placené API
- fallback ingest
- kombinace zdrojů

---

# SPRÁVNÁ MULTI-PROVIDER LOGIKA

Sport + entity
→ zkus provider A
→ pokud neumí:
   provider B
→ pokud neumí:
   provider C
→ official source
→ manual/fallback ingest
→ budoucí integrace

---

# BUDOUCÍ OPS ENGINE

Budoucí routing engine bude rozlišovat:

PRIMARY_PROVIDER
FALLBACK_PROVIDER
BLOCKED_ENDPOINT
PROVIDER_GAP
PLANNED_PROVIDER
OFFICIAL_SOURCE
MANUAL_SOURCE

---

# PŘÍKLADY

## Volleyball

api_volleyball + players
= blocked endpoint

VB + players
= provider gap
= hledá se alternativní provider

---

## Hockey

api_hockey + odds
= limited/blocked coverage

HK + odds
= fallback/premium provider candidate

---

## Basketball

api_sport + BK odds
= limited_free

sportsdataio + BK players
= runtime_tested

THEODDS + BK
= nepoužívá se jako primary source

---

# DŮLEŽITÝ STRATEGICKÝ CÍL

MatchMatrix nesmí být závislý na jednom providerovi.

Cílová architektura:

GLOBAL MULTI-PROVIDER SPORTS PLATFORM

---

# DLOUHODOBĚ

Každý sport bude mít:

provider governance
provider priority
fallback routing
coverage matrix
runtime health
automatic provider selection

nezávisle na tom,
jestli konkrétní provider selže nebo nemá coverage.
