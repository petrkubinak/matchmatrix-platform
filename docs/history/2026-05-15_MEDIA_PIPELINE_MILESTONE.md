MATCHMATRIX MEDIA LAYER PROGRESS — 2026-05-15

## MEDIA ENTITY MAPPING + TRENDING ENGINE V1

### Dokončeno

Byla dokončena první produkční verze MEDIA ENTITY LAYER pro MatchMatrix platformu.

### ARTICLE ↔ LEAGUE MATCHING

Dokončen worker:

workers/media/match_article_leagues_v1.py

Výsledek:

* article_league_map naplněn
* správně mapovány:

  * NHL
  * NBA
  * La Liga
  * Bundesliga
  * Premier League
  * UEFA Champions League

Vyřešeny problémy:

* neexistující column source_name
* ambiguity league names
* LaLiga alias resolution
* UEFA Champions League canonical mapping

Finální league feed:

* NHL: 127 článků
* NBA: 97 článků
* La Liga: 23
* Bundesliga: 14
* Premier League: 2
* UEFA Champions League: 1

---

## ARTICLE ↔ TEAM MATCHING

Dokončen worker:

workers/media/match_article_teams_v1.py

Vyřešeno:

* DB_DSN parsing
* alias seed systém
* NBA/NHL canonical team ingest
* automatic alias matching

Byly vytvořeny:

* public.team_aliases
* media_short aliases
* media_seed aliases
* media_seed_bk_hk_name aliases

### NBA ingest fix

Zjistěno:

* API-Sport basketball league 12 vrací pro season=2024 results=0
* správná season musí být:
  2023-2024

Úspěšně mergnuty NBA canonical teams:

* Lakers
* Knicks
* Thunder
* Spurs
* Timberwolves
* 76ers
* další NBA teams

Úspěšně mergnuty NHL canonical teams:

* Avalanche
* Ducks
* Golden Knights
* Canadiens
* Sabres
* Wild
* další NHL teams

Finální team mapping:

* 179 article-team vazeb
* idempotentní matcher
* duplicate-safe matching

Top team article feeds:

* Colorado Avalanche: 22
* Anaheim Ducks: 20
* Montreal Canadiens: 20
* Minnesota Wild: 19
* Vegas Golden Knights: 18
* New York Knicks: 16
* Spurs: 13
* Cavaliers: 12
* 76ers: 11

---

## MEDIA FEED VIEWS

Vytvořeno:

public.v_media_feed_by_team
public.v_media_feed_by_league

Použití:

* /team/{id}/news
* /league/{id}/news
* homepage feeds
* frontend widgets
* sport landing pages

Feedy používají:

* article_quality_score >= 70
* official source filtering
* thumbnails
* videos
* source metadata

---

## TRENDING ENGINE V1

Vytvořeno:

* public.media_trending_teams
* public.media_trending_leagues

Doplněny columns:

* weighted_score
* total_score
* calculated_at

Vytvořeny views:

* public.v_media_trending_teams
* public.v_media_trending_leagues

Scoring:

* article_quality_score
* video boost
* weighted aggregation

Top trending teams:

1. Colorado Avalanche
2. New York Knicks
3. Anaheim Ducks
4. Montreal Canadiens
5. Minnesota Wild

Top trending leagues:

1. NHL
2. NBA
3. La Liga
4. Bundesliga

---

## ARCHITEKTURA MEDIA LAYER — STAV

Hotovo:

* official_site ingest
* article parsing
* article merge
* article quality scoring
* article ↔ league mapping
* article ↔ team mapping
* team aliases
* league feeds
* team feeds
* trending engine
* trending views

Media layer je nyní první reálně použitelná produkční vrstva pro:

* homepage feeds
* team pages
* league pages
* trending widgets
* recommendation engine
* future API endpoints

---

## DALŠÍ PRIORITY

1. article_match_map
2. player media matching
3. trending decay / recency scoring
4. recommendation feed
5. personalized feeds
6. automatic alias builder
7. video highlight enrichment
8. live sports news widgets
9. frontend API layer
10. media scheduler automation
