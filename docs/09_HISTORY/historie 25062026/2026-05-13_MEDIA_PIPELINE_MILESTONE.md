# MATCHMATRIX MEDIA LAYER V1 — TRENDING + DECAY COMPLETED

## Datum

2026-05-13

---

# MEDIA PIPELINE V1 STABILIZED

Dokončena a stabilizována první plně funkční MEDIA vrstva:

```text
official/rss ingest
→ public.articles
→ alias-first entity matching
→ article scoring
→ trending engine
→ freshness decay
```

---

# ENTITY MATCHER V1

Dokončen alias-first matcher:

## Potvrzené matchování

### Teams

* Warriors → team_id=26087
* Cavaliers → team_id=27476

### Players

* LeBron → player_id=14480 (opraveno)
* Crosby → opraveno na Sidney Crosby

### Leagues

* NHL → league_id=22390
* NBA → league_id=23344
* Stanley Cup → NHL
* Stanley Cup Playoffs → NHL
* NBA Playoffs → NBA
* Champions League → UEFA

---

# SAFE ALIAS SYSTEM

Byl testován automatický alias builder:

```text
TEAM ALIASES INSERTED: 2770
PLAYER ALIASES INSERTED: 18315
```

Následně identifikovány massive false positives.

## Zjištění

Plošný auto alias builder:

* není bezpečný
* vytváří falešné entity matche
* rozbíjí scoring/trending

## Přijaté rozhodnutí

MEDIA bude používat:

```text
SAFE PLAYER ALIASES V2
```

Pouze:

* whitelist hvězd
* ručně ověřené player_id
* kontrolované aliasy

---

# FIXES

## Opravené chyby

### LeBron alias

Původně:

* Cristofer Lebron

Opraveno:

* LeBron James → player_id=14480

### Crosby alias

Původně:

* Maxx Crosby

Opraveno:

* Sidney Crosby

---

# ARTICLE SCORER V1

Scoring stabilizován.

Původní problém:

```text
entities=134
score=925
```

Po cleanup:

```text
score=60-90
entities=1-3
```

Scoring je nyní realistický.

---

# TRENDING ENGINE V1

Dokončen:

```text
public.media_trending_players
public.media_trending_teams
public.media_trending_leagues
```

---

# FRESHNESS DECAY IMPLEMENTED

Přidán decay model:

```text
0-7 dní:
    postupný pokles trending score

minimum:
    25 % původní síly
```

Použit:

```text
created_at
```

protože:

```text
published_at = NULL
```

---

# FINAL VERIFIED RESULTS

## Players

```text
LeBron James
articles: 2
total_score: 175
trending_score: 143.72
```

## Teams

```text
Warriors
articles: 2
total_score: 150
trending_score: 119.75
```

## Leagues

```text
NHL
articles: 16
total_score: 1105
trending_score: 885.43

NBA
articles: 5
total_score: 370
trending_score: 295.85
```

---

# DUPLICATE DETECTOR V1

Vytvořen duplicate detector.

Výsledek:

```text
DUPLICATE GROUPS: 0
```

---

# CURRENT MEDIA STATUS

MEDIA layer je nyní:

* stabilní
* čistá
* bez false positives
* s decay trendingem
* připravená pro homepage/feed API

---

# NEXT STEPS

## Doporučené pokračování

1. Homepage media feed API
2. Video/highlights layer
3. Published_at extraction parser
4. Multi-language article translations
5. Media recommendation engine
6. Social/comments layer
7. Player biography/star profiles
8. Trending snapshots/history


