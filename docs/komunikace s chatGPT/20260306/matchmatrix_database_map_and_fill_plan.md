
# MatchMatrix – Database Map and Fill Plan

## Soubor
`matchmatrix_database_map_and_fill_plan.md`

## Uložit do
`C:\MatchMatrix-platform\docs`

---

# 1. Cíl dokumentu

Tento dokument shrnuje:

- aktuální cílovou architekturu databáze MatchMatrix
- logické databázové domény
- priority plnění tabulek
- doporučené zdroje dat
- doporučené pořadí ingestu
- praktický plán další práce

Cíl je jednoduchý:

**přestat databázi jen rozšiřovat a začít ji systematicky plnit.**

---

# 2. Přehled databázových domén

## 2.1 Core sport domain

Základní sportovní model:

- sports
- countries
- leagues
- teams
- matches
- seasons
- players
- coaches
- stadiums

Rozšíření:

- team_stadiums
- team_coaches
- player_team_history
- competition_rounds

Smysl:
- canonical pravda o sportovním světě
- ligy, týmy, hráči, zápasy, stadiony, trenéři, sezóny

---

## 2.2 Provider mapping domain

Mapování providerů na canonical entity:

- league_provider_map
- team_provider_map
- team_aliases
- player_provider_map

Smysl:
- více providerů pro stejné entity
- auditovatelnost
- fallback mezi zdroji
- čistý canonical model

---

## 2.3 Match detail domain

Detail zápasu a jeho průběhu:

- lineups
- injuries
- match_events
- match_officials
- match_weather
- player_match_statistics
- team_match_statistics

Smysl:
- timeline zápasu
- sestavy
- střídání
- karty
- góly
- statistiky hráčů a týmů
- rozhodčí
- počasí

---

## 2.4 Betting and analytics domain

Sázkový a analytický model:

- bookmakers
- markets
- market_outcomes
- odds
- ml_predictions
- ml_match_dataset
- ml_match_dataset_v2
- ml_team_ratings
- ml_value_latest_v1
- ml_fair_odds_latest_v1
- ml_block_candidates_latest_v1

Smysl:
- bookmaker odds
- fair odds
- value betting
- predikce
- ticket optimizer

---

## 2.5 Ticket generator domain

Modul generování tiketů:

- templates
- template_blocks
- template_block_matches
- template_feed_picks
- generated_runs
- generated_tickets
- generated_ticket_blocks
- generated_ticket_fixes
- generated_ticket_risk
- user_selections

Smysl:
- skládání tiketů
- bloky
- risk scoring
- generování variant

---

## 2.6 Content domain

Obsah a články:

- content_sources
- articles
- article_team_map
- article_league_map
- article_match_map

Smysl:
- team news
- league news
- match preview
- SEO obsah
- fan engagement

---

## 2.7 Translation domain

Multijazyčnost:

- languages
- article_translations
- league_translations
- team_translations
- player_translations
- translation_jobs
- translation_job_logs

Smysl:
- globální web
- vícejazyčný obsah
- překlady týmů, lig, hráčů a článků
- automatické překladové workflow

---

## 2.8 Fan layer domain

Fanouškovská vrstva:

- team_social_links
- player_social_links
- stadiums
- team_stadiums
- team_transfers

Smysl:
- bohatší týmové a hráčské stránky
- stadion
- sociální sítě
- přestupy

---

## 2.9 User and personalization domain

Uživatelé a personalizace:

- users
- user_favorite_teams
- user_favorite_leagues
- user_favorite_players

Smysl:
- sledování týmů
- sledování lig
- sledování hráčů
- personalizovaný feed

---

## 2.10 Monetization and notifications domain

Monetizace a notifikace:

- subscription_plans
- subscriptions
- user_notifications
- notification_queue

Smysl:
- 4 úrovně předplatného
- premium funkce
- push/email/notifikační workflow

---

# 3. Co už je hotové

Databázově je MatchMatrix už nyní velmi silný.

Hotovo / navrženo:

- sportovní jádro
- multi-provider model
- betting vrstva
- ticket generator
- content vrstva
- multijazyčnost
- users
- subscriptions
- notifications

Architektura už odpovídá platformě, ne jen malé aplikaci.

---

# 4. Teď už nejde hlavně o nové tabulky

Nejdůležitější další krok není přidávat další tabulky.

Nejdůležitější je:

1. ověřit nově vytvořené tabulky
2. rozhodnout pořadí plnění
3. připravit ingest skripty
4. začít tabulky reálně plnit

---

# 5. Strategický princip plnění

Tabulky budeme plnit po vrstvách.

Ne „všechno naráz bez pořadí“, ale:

```text
1. reference
2. core sport
3. match detail
4. content
5. translations
6. users / monetization
```

Z pohledu provozu to může být jedna pipeline, ale interně musí běžet po blocích.

---

# 6. Priorita plnění tabulek

## PRIORITA A – naplnit jako první

Toto je první vlna.  
Bez ní nepůjde dobře dělat detail týmu, hráče ani zápasu.

### 6.1 languages
Typ:
- seed

Zdroj:
- ručně definovaný seznam jazyků

Důvod:
- jednoduché
- uzavře translation základ

---

### 6.2 seasons
Typ:
- seed / ingest

Zdroj:
- API-Football
- football-data
- případně odvození z league coverage

Důvod:
- navazuje na ligy
- potřeba pro další entity

---

### 6.3 players
Typ:
- ingest

Zdroj:
- API-Football
- další provider feeds

Důvod:
- základ pro lineups, injuries, stats, player pages

---

### 6.4 player_provider_map
Typ:
- ingest / merge

Zdroj:
- stejné jako players

Důvod:
- canonical hráči
- multi-provider architektura

---

### 6.5 stadiums
Typ:
- ingest / semi-manual seed

Zdroj:
- provider metadata
- oficiální zdroje
- doplnění ručně

Důvod:
- potřeba pro team pages a match detail

---

### 6.6 team_stadiums
Typ:
- merge

Zdroj:
- team metadata + stadium mapping

Důvod:
- navázání stadionů na kluby

---

### 6.7 content_sources
Typ:
- seed

Zdroj:
- ručně založený seznam zdrojů

Důvod:
- základ content pipeline

---

# 7. PRIORITA B – druhá vlna

Jakmile bude fungovat hráčská vrstva, jdeme na detail zápasu.

### 7.1 lineups
Zdroj:
- API-Football lineups
- případně premium provider později

Důvod:
- detail zápasu
- fanouškovská hodnota

### 7.2 injuries
Zdroj:
- provider injury feed
- oficiální weby klubů
- content parsing

Důvod:
- team page
- preview
- fan zájem

### 7.3 match_events
Zdroj:
- API match events
- live/event provider

Důvod:
- timeline zápasu
- recap
- live match view

### 7.4 player_match_statistics
Zdroj:
- provider statistics feed

Důvod:
- player pages
- match detail
- rating / xG / advanced stats

### 7.5 team_match_statistics
Zdroj:
- provider team stats

Důvod:
- team summary
- match detail
- analytics

### 7.6 coaches
Zdroj:
- provider team metadata
- oficiální weby klubů

### 7.7 team_coaches
Zdroj:
- merge z coaches + teams

### 7.8 match_officials
Zdroj:
- provider match detail

### 7.9 match_weather
Zdroj:
- weather API podle času a stadionu
- později enrichment

---

# 8. PRIORITA C – třetí vlna

Content, news a SEO.

### 8.1 articles
Zdroj:
- RSS
- official club sites
- league sites
- sports media sources

### 8.2 article_team_map
Zdroj:
- entity tagging
- parser / rules / AI tagging

### 8.3 article_league_map
Zdroj:
- entity tagging

### 8.4 article_match_map
Zdroj:
- entity tagging + schedule match

### 8.5 article_translations
Zdroj:
- DeepL / Google / OpenAI / manual review

### 8.6 translation_jobs
Zdroj:
- vytvořené automaticky po ingestu článků nebo nových entit

### 8.7 translation_job_logs
Zdroj:
- translation worker

---

# 9. PRIORITA D – čtvrtá vlna

Fanouškovský detail a bohaté profily.

### 9.1 player_team_history
Zdroj:
- squads by season
- transfer data
- provider roster snapshots

### 9.2 team_transfers
Zdroj:
- provider transfer feed
- official news
- specializované transfer zdroje

### 9.3 team_social_links
Zdroj:
- ruční seed
- oficiální klubové weby

### 9.4 player_social_links
Zdroj:
- ruční seed / veřejné oficiální profily

### 9.5 league_translations / team_translations / player_translations
Zdroj:
- translation worker
- manual review

---

# 10. PRIORITA E – pátá vlna

User vrstva, premium a notifikace.

### 10.1 users
Plnění:
- registrace

### 10.2 user_favorite_teams
Plnění:
- user actions

### 10.3 user_favorite_leagues
Plnění:
- user actions

### 10.4 user_favorite_players
Plnění:
- user actions

### 10.5 subscription_plans
Plnění:
- seed

### 10.6 subscriptions
Plnění:
- payment workflow

### 10.7 user_notifications
Plnění:
- aplikace / notifikační engine

### 10.8 notification_queue
Plnění:
- background workers

---

# 11. Doporučené zdroje dat podle oblasti

## 11.1 Sportovní data
Hlavní:
- API-Football
- football-data.org

Později:
- Sportradar nebo podobný silnější provider pro detailnější coverage

Použití:
- seasons
- players
- lineups
- match_events
- statistics
- coaches
- officials

---

## 11.2 Odds
Hlavní:
- The Odds API

Použití:
- bookmaker odds
- market coverage
- snapshots

---

## 11.3 Obsah
Hlavní:
- oficiální weby klubů
- oficiální weby lig
- RSS feedy
- velká sportovní média

Použití:
- articles
- content_sources
- injury news
- previews

---

## 11.4 Překlady
Hlavní:
- DeepL
- Google Translate API
- OpenAI translation workflow

Použití:
- article_translations
- team_translations
- player_translations
- league_translations

---

## 11.5 Počasí
Hlavní:
- weather API podle stadionu a kickoff času

Použití:
- match_weather

---

# 12. Doporučené pořadí ingest pipeline

Takto by měl běžet první větší plnicí workflow:

```text
1. seed_languages
2. seed_content_sources
3. ingest_seasons
4. ingest_players
5. merge_player_provider_map
6. ingest_stadiums
7. merge_team_stadiums
8. ingest_lineups
9. ingest_injuries
10. ingest_match_events
11. ingest_player_match_statistics
12. ingest_team_match_statistics
13. ingest_articles
14. map_articles_to_entities
15. create_translation_jobs
16. translation_worker
17. checks + report
```

---

# 13. Doporučený praktický plán práce

## Fáze 1 – okamžitě
Uděláme první plnění:

- languages
- content_sources
- seasons
- players
- player_provider_map

To je první reálný krok.

## Fáze 2
Uděláme sportovní detail:

- stadiums
- team_stadiums
- lineups
- injuries
- match_events
- player_match_statistics
- team_match_statistics

## Fáze 3
Uděláme content a translations:

- articles
- article maps
- translation jobs
- article_translations

## Fáze 4
Později přijdou:

- social links
- transfers
- coaches
- user vrstva
- subscriptions
- notifications

---

# 14. Co doporučuji jako další konkrétní krok

Další krok už nemá být nová tabulka.

Další krok má být:

## vytvořit první plnicí sadu

Konkrétně:

1. seed pro `languages`
2. seed pro `content_sources`
3. ingest / merge pro `seasons`
4. ingest / merge pro `players`
5. ingest / merge pro `player_provider_map`

To je první skutečné naplnění nových tabulek.

---

# 15. Pracovní pravidlo

Při každém dalším kroku musí být vždy uvedeno:

1. **název souboru**
2. **přesná složka kam uložit**
3. **SQL nebo skript hotový k použití**
4. **jak přesně spustit**

To je pevné pravidlo pro další práci na MatchMatrix.

---

# 16. Závěr

Databázový model MatchMatrix je nyní dostatečně silný.

Teď je potřeba přejít z fáze:

**„navrhujeme tabulky“**

do fáze:

**„systematicky je plníme a napojujeme na ingest pipeline“**

To je další hlavní krok projektu.
