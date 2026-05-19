# MATCHMATRIX – MEDIA PIPELINE MILESTONE
# DATE: 2026-05-11

## DOKONČENÝ MILNÍK

Byla dokončena první autonomní MEDIA pipeline MatchMatrix.

Nejde již pouze o scraper.
MEDIA layer nyní obsahuje:
- orchestraci
- staging flow
- parsing
- canonical merge
- audit
- entity matching
- reusable worker architekturu

---

# NOVÁ STRUKTURA

```text
workers/
├─ run_media_pipeline_v1.py
│
└─ media/
   ├─ pull_official_site_media_articles_v1.py
   ├─ pull_rss_media_articles_v1.py
   ├─ parse_article_details_v1.py
   ├─ merge_media_articles_to_public_v1.py
   └─ match_article_entities_v1.py

FINÁLNÍ MEDIA FLOW
official_site/rss
→ staging.stg_media_articles
→ detail parser
→ public.articles
→ entity matching
→ article_team_map
→ future knowledge graph

IMPLEMENTOVANÉ ČÁSTI
1. OFFICIAL SITE INGEST

Funkční:

NHL
NBA
UEFA
FIFA

Status:

NHL/NBA = OK
UEFA = PARTIAL
FIFA = EMPTY
2. RSS INGEST

Připravená RSS vrstva.
Aktuálně bez aktivních validních feedů.

3. DETAIL ARTICLE PARSER

Nový worker:

parse_article_details_v1.py

Extrahuje:

title
summary
raw_text
author_name

Architektura připravena pro:

provider parsers
playwright/browser layer
AI extraction
4. CANONICAL MERGE

Canonical target:

public.articles

Byla identifikována a zastavena duplicita:

public.media_articles

Tabulka byla označena jako:

DEPRECATED / TRANSITIONAL

5. ENTITY MATCHING

Nový worker:

match_article_entities_v1.py

Aktuálně:

team matching
source-aware filtering
omezení false positives

Potvrzené match:

Cavaliers
Warriors

Budoucnost:

alias engine
NLP
embeddings
AI entity extraction

6. AUDIT

Vytvořeno:

ops.media_source_health_audit
ops.media_job_runs

Pipeline nyní ukládá:

job runs
status
duration
worker summary
source health
VÝSLEDEK

MEDIA layer je nyní:

autonomous
scheduler-ready
reusable
multisport
canonical-aware
audit-ready

Toto je první plnohodnotná autonomní MEDIA vrstva MatchMatrix.

DALŠÍ PRIORITY

provider-specific parsers

league matching

player matching

AI summaries

highlight/video ingest

social ingest

search/index layer

recommendation/trending engine

sports knowledge graph

MATCHMATRIX MEDIA LAYER – PROGRESS SUMMARY (2026-05-11)
HOTOVÉ KOMPONENTY
MEDIA PIPELINE V1

Kompletní automatická media pipeline byla úspěšně postavena a ověřena:

pull official site
→ pull rss
→ parse article details
→ merge public.articles
→ entity matching
→ article scoring
→ trending aggregation

Pipeline běží přes:

workers/run_media_pipeline_v1.py

Aktuální workers:

pull_official_site_media_articles_v1.py
pull_rss_media_articles_v1.py
parse_article_details_v1.py
merge_media_articles_to_public_v1.py
match_article_entities_v1.py
score_media_articles_v1.py
OFFICIAL MEDIA SOURCES

Aktivní official-site zdroje:

NHL
NBA
UEFA
FIFA

Potvrzené fungující:

NHL official news
NBA official news

UEFA:

pouze 1 URL
bude potřeba lepší parser

FIFA:

zatím EMPTY
nutné později řešit jiný source pattern
CANONICAL ARTICLES LAYER

Canonical media tabulka:

public.articles

Staging:

staging.stg_media_articles_pending

Původní:

public.media_articles

zůstává legacy / transitional.

ARTICLE DETAIL PARSER

Funguje:

title
summary
raw_text
published_at
author_name
source metadata

Tabulka:

public.articles
SEMANTIC ENTITY GRAPH

Vybudováno:

article
→ league
→ team
→ player

Tabulky:

public.article_league_map
public.article_team_map
public.article_player_map
MEDIA ENTITY ALIASES

Vybudována alias-first architektura:

public.media_entity_aliases

Používá se místo starého canonical fuzzy matching.

Potvrzené aliasy:

LEAGUES
NBA
NBA Playoffs
NHL
Stanley Cup
Stanley Cup Playoffs
UEFA Champions League
Champions League
UCL
TEAMS
Cavaliers
Warriors
PLAYERS
LeBron
Wemby
McDavid
Crosby
FALSE POSITIVE CLEANUP

Canonical team + league matching byly postupně vypínány kvůli false positives:

Původní problémy:

Real
Start
Championship
World Cup
Elite League
hockey League

Systém byl převeden na:

ALIAS-FIRST MATCHING
MEDIA ARTICLE SCORER V1

Worker:

workers/media/score_media_articles_v1.py

Výstupy:

entity_count
quality_score
playoff_related
has_author
has_summary
has_raw_text
ai_relevance_score (připraveno)

Nové sloupce:

public.articles

Aktuální scoring:

+10 has_author
+20 has_summary
+30 has_raw_text
+25 playoff_related
+5  za každou entitu
MEDIA TRENDING ENGINE V1

Worker:

workers/media/build_media_trending_v1.py

Tabulky:

public.media_trending_players
public.media_trending_teams
public.media_trending_leagues

Výpočet:

trending_score =
(article_count * 10)
+ total quality_score
AKTUÁLNÍ TRENDING
LEAGUES
NHL 36
NBA 11
TEAMS
Warriors
Cavaliers
PLAYERS
LeBron
Victor Wembanyama
DŮLEŽITÉ DALŠÍ KROKY
1. DEFINITIVNĚ VYPNOUT STARÝ CANONICAL LEAGUE MATCHING

V match_article_entities_v1.py
ponechat pouze:

ALIAS LEAGUE MATCH
ALIAS TEAM MATCH
ALIAS PLAYER MATCH
DALŠÍ MEDIA ROADMAP
PRIORITA 1 — VIDEO / HIGHLIGHTS LAYER

Plán:

public.media_videos
public.video_match_map
public.video_team_map
public.video_player_map
public.video_league_map

Worker:

workers/media/pull_youtube_highlights_v1.py

Zdroje:

YouTube official channels
NHL video
NBA video
UEFA video
FIFA video

Cíl:

match → highlights
team → videos
player → videos
league → videos
PRIORITA 2 — PLAYER PROFILE ENRICHMENT

Budoucí:

AI player profiles
career summaries
biographies
player pages
related articles
related videos
trend score
PRIORITA 3 — COMMENTS / SOCIAL LAYER

Pozdější fáze:

YouTube comments
Reddit
X/Twitter
Instagram
fan sentiment

Pozor:

spam
toxicita
moderace
právní rizika
CELKOVÝ STAV

MEDIA layer už není doplněk.

Aktuálně existuje:

semantic media graph
quality engine
trending engine
canonical article layer
entity relationship layer

Tohle už je základ:

homepage feedu,
recommendation engine,
AI summaries,
trending systému,
personalized feedů,
knowledge graphu,
budoucího propojení profesionálních i amatérských soutěží.