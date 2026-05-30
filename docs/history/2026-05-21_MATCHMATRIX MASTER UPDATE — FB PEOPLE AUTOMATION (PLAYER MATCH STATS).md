MATCHMATRIX MASTER UPDATE — FB PEOPLE AUTOMATION (PLAYER MATCH STATS)
Datum

2026-05-21

FB PEOPLE LAYER — PLAYER MATCH STATISTICS AUTOMATION

Byla dokončena první plně automatizovaná verze:

FB PLAYER MATCH STATISTICS HARVEST PIPELINE

pro:

API-Football → /fixtures/players

Pipeline nyní funguje end-to-end.

DOKONČENÁ ARCHITEKTURA
1. QUEUE BUILDER

Soubor:

workers/people/104_S_build_fb_player_match_stats_queue_v1.py

Funkce:

hledá FINISHED matches
kontroluje existenci player stats
enqueue nových jobs
zapisuje do:
ops.fixture_player_stats_queue

Výsledek:

automatické plánování PEOPLE harvestingu
oddělení queue vrstvy od API vrstvy
2. API PULLER V1

Soubor:

workers/people/104_T_pull_fb_player_match_stats_from_queue_v1.py

Funkce:

bere pending jobs z queue
volá:
/fixtures/players
ukládá RAW payloady do:
staging.stg_api_payloads

Zjištěné problémy:

API key naming mismatch
DB_DSN issue
schema mismatch ve stg_api_payloads
HTTP 429 rate limiting

Vše opraveno.

3. API PULLER V2 (PRODUCTION SAFE)

Soubor:

workers/people/104_W_pull_fb_player_match_stats_from_queue_v2.py

Nové vlastnosti:

sleep between requests
rate limit protection
HTTP 429 handling
retry scheduling
graceful queue retry
production-safe throttling

Parametry:

--sleep-sec
--retry-minutes
--rate-limit-retry-minutes

Výsledek:

API již nepadá do permanentního 429
stabilní harvesting
4. RAW PAYLOAD PARSER

Soubor:

workers/parsers/104_U_parse_fb_player_match_stats_queue_payloads_v1.py

Funkce:

bere RAW payloady:
provider='api_football'
entity_type='fixture_player_stats'
parse_status='pending'
mapuje:
fixture → public.matches
team → public.team_provider_map
player → public.player_provider_map
ukládá do:
public.player_match_statistics
OPRAVENÉ PROBLÉMY PARSERU
NULL VALUES

API-Football vrací:

goals=null
assists=null
shots=null
fouls=null

u mnoha hráčů.

Oprava:

safe_int() nyní převádí NULL → 0

Výsledek:

parser již nepadá na NOT NULL constraint.
UNIQUE CONFLICT

Tabulka:

public.player_match_statistics

má:

UNIQUE(match_id, player_id)

Parser původně kontroloval:

match_id + team_id + player_id

Oprava:

duplicate check změněn na:
match_id + player_id
přidáno:
ON CONFLICT (match_id, player_id)
DO NOTHING

Výsledek:

parser již nepadá na unique conflicts.
5. ORCHESTRATOR CYCLE

Soubor:

workers/people/104_V_run_fb_player_match_stats_cycle_v1.py

Funkce:

spustí celý chain:
QUEUE BUILDER
→ PULLER
→ PARSER

Automatizace:

první skutečný PEOPLE harvesting cycle subsystem
COVERAGE AUDIT

Audit ukázal:

LIGY S REÁLNOU COVERAGE

Např.:

21062 Segunda División
21063 Serie B

vrací:

DONE rows
player statistics data
LIGY S EMPTY RESPONSE

Mnoho lower leagues vrací:

HTTP 200
response_count = 0

To není chyba pipeline.

Je to:

API-Sports FREE coverage limitation
SMART QUEUE PRIORITY

Byla zavedena:

queue priority intelligence

Ligy:

s DONE coverage
→ priority=10

Ligy:

s velkým množstvím EMPTY
→ priority=90

Výsledek:

méně zbytečných API requestů
efektivnější harvesting
nižší spotřeba request budgetu
AKTUÁLNÍ OMEZENÍ

Projekt aktuálně běží na:

API-Sports FREE PLAN

Praktické limity:

historická data hlavně 2022–2024
nižší request limit
ne všechny endpointy mají full coverage
lower leagues často bez player stats
STRATEGICKÝ VÝZNAM

Tento krok je velmi důležitý.

Nyní existuje:

REÁLNÝ AUTOMATIZOVANÝ PEOPLE HARVEST SUBSYSTEM

s:

queue architekturou
retry logikou
RAW storage
parser layer
throttlingem
provider intelligence
coverage intelligence
orchestrace cycles
VYUŽITÍ NA WEBU / APP

Data budou využita pro:

PLAYER DETAIL
match statistics
player history
heat / momentum
PLAYER FORM ENGINE
recent form
rolling averages
consistency
FANTASY SCORING
player fantasy points
value metrics
AI PREDICTION LAYER
player performance prediction
player impact
AI recommendations
MOMENTUM ENGINE
hot streaks
cold streaks
trending players
ODDS + PLAYER ANALYTICS
player props
AI betting models
MEDIA LINKING
articles ↔ players
highlights ↔ players
trends ↔ players
ARCHITEKTURA MATCHMATRIX

Velmi důležitý posun:

Nové workers už jsou správně oddělovány:

workers/people/
workers/parsers/

Nové komponenty:

již nevznikají v root workers
připravuje se budoucí plný refactor cest

To je důležitý krok k:

enterprise architektuře
maintainability
scalingu
multi-sport expansion
DALŠÍ DOPORUČENÉ KROKY
PEOPLE
player form engine
player momentum
player aggregates
xG/xA layer
player trends
CORE
další coverage audits
canonical match quality
MEDIA
player ↔ article linking expansion
highlights linking
ODDS
multi-provider architecture
lower leagues expansion
AI
player performance models
AI prediction layer
recommendation engine