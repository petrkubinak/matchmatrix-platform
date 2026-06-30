MATCHMATRIX — SOUHRNNÝ ZÁPIS PRO NOVÝ CHAT
PEOPLE LAYER — PLAYER SEASON STATISTICS

Dokončeno:

public.player_season_statistics
Stav:
merge funkční
canonical PEOPLE stats layer funkční
ON CONFLICT opraven
team mapping funkční
sport_id doplněn
frontend feed funguje
Vytvořené view
PLAYER STATISTICS FEED

Soubor:

db/views/create_v_player_statistics_feed.sql

View:

public.v_player_statistics_feed

Obsahuje:

player name
photo
nationality
team
team logo
league
league logo
season stats
advanced percentages:
duel %
shot accuracy %
dribble success %

Použití:

player detail
AI scouting
rankings
predictions
fantasy layer
trending players
PEOPLE QUALITY AUDIT

Soubor:

db/views/create_v_people_stats_quality_audit.sql

View:

public.v_people_stats_quality_audit

Audit sleduje:

appearances coverage
ratings coverage
team mapping coverage
league quality completeness
PEOPLE QUALITY BACKFILL QUEUE

Soubor:

db/people/insert_people_quality_backfill_jobs_v1.sql

Tabulka:

ops.people_quality_backfill_queue

Run group:

FB_PEOPLE_QUALITY_BACKFILL_2024
PRIORITNÍ LIGY PRO QUALITY BACKFILL

Top priority:

Premier League 2024
La Liga 2024
Serie A 2024
Ligue 1 2024
Eredivisie 2024
Championship 2024
2. Bundesliga 2024
Primeira Liga 2024
PEOPLE QUALITY STATUS

Aktuální coverage:

TOTAL ROWS                : 3121
ROWS WITH APPEARANCES     : 1796
ROWS WITH RATING          : 818
ROWS WITH GOALS           : 1612
PANEL / ORCHESTRACE

Mission Control V11:

funguje
planner queue OK
people pipeline OK
provider monitoring OK
snapshot diff OK
live logs OK
ARCHITEKTURA

Potvrzený směr:

ingest/   = stahování
workers/  = orchestrace + merge + parser + quality
db/       = SQL layer
tools/    = panely
ops/      = runtime/queue
reports/  = exporty/audity
docs/     = zápisy
DŮLEŽITÉ ROZHODNUTÍ
ZATÍM NEPŘESOUVAT STARÉ WORKERY

Pouze:

nové ukládat do nové struktury
staré ponechat kvůli panelům/cestám
NOVÁ QUALITY VRSTVA

Připravit:

workers/quality/

První nový worker:

workers/quality/run_people_quality_backfill_v1.py

Účel:

retry incomplete players
retry missing ratings
retry missing photos
retry missing nationality
retry missing stats
automatic quality refill
CO BUDEME DĚLAT DÁL
PRIORITA 1

Vytvořit:

workers/quality/run_people_quality_backfill_v1.py

Funkce:

načte ops.people_quality_backfill_queue
spustí TOP priority ligy
retry incomplete coverage
update planner status
health logging
PRIORITA 2

Přidat QUALITY CONTROL do panelu:

missing ratings
missing photos
missing stats
coverage %
auto requeue
PRIORITA 3

Rozšířit PEOPLE coverage:

NBA
NHL
top football leagues
coaches
profiles
player photos
advanced stats