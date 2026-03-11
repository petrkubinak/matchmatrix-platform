
# MatchMatrix 2.0 – cílová architektura platformy

## 1. Vize produktu

MatchMatrix není jen nástroj na sázení.  
Cílově je to **globální sportovní platforma** pro web i mobily, která spojuje:

- sportovní data
- detail zápasů, týmů a hráčů
- analytiku a predikce
- ticket optimizer
- obsah pro fanoušky
- personalizaci
- komunitu

Cíl:

- pokrýt více sportů
- jít do hloubky u týmů a soutěží
- vytvořit důvod, proč se uživatel vrací každý den
- postavit produkt pro široké publikum, ne jen pro sázkaře

---

# 2. Základní produktové pilíře

## 2.1 Sportovní data
Databáze musí obsahovat:

- sporty
- země
- ligy
- sezóny
- týmy
- hráče
- zápasy
- tabulky
- sestavy
- zranění
- statistiky
- události v zápase
- kurzy bookmakerů

## 2.2 MatchMatrix engine
Analytická vrstva:

- rating týmů
- forma
- model predictions
- fair odds
- value bets
- výběr kandidátů
- ticket optimization
- risk scoring

## 2.3 Content vrstva
Obsah pro fanoušky:

- team pages
- player pages
- match preview
- články
- news feed
- AI souhrny
- komentáře
- později komunitní obsah

## 2.4 Personalizace
Každý uživatel vidí:

- své týmy
- své ligy
- svůj sport
- doporučené zápasy
- nové články
- notifikace
- value příležitosti

## 2.5 Monetizace
4 úrovně tarifu:

- FREE
- PRO
- PRO+
- ELITE

---

# 3. Cílová high-level architektura

```text
Providers / feeds / scrapers
        ↓
Ingest jobs
        ↓
Raw storage
        ↓
Parsing + normalization
        ↓
Canonical PostgreSQL
        ↓
Derived views / materialized views
        ↓
API layer
        ↓
Web + Mobile + Notifications
```

Doplňkové vrstvy:

```text
Canonical DB → Redis cache → live API
Canonical DB → Search index → fulltext / news / team pages
Canonical DB → ML engine → predictions / value / ticket optimizer
Canonical DB → Content engine → previews / summaries / tagged news
```

---

# 4. Databázové domény

## 4.1 Core sports domain
Jádro sportovního modelu:

- sports
- countries
- leagues
- seasons
- teams
- players
- venues
- matches
- match_events
- standings
- standings_snapshots
- injuries
- lineups
- player_stats
- team_stats

Úkol této vrstvy:
- být canonical pravdou o sportovním světě
- držet čisté entity
- umožnit multi-sport rozšíření

---

## 4.2 Provider mapping domain
Mapování providerů na canonical model:

- league_provider_map
- team_provider_map
- player_provider_map
- match_provider_map
- bookmaker_provider_map
- article_source_map

Smysl:
- stejné týmy a ligy z více providerů
- auditovatelnost
- fallback mezi zdroji
- možnost přidávat další feedy bez rozbití modelu

---

## 4.3 Betting & analytics domain
Betting a model vrstva:

- bookmakers
- markets
- market_outcomes
- odds
- odds_snapshots
- ml_predictions
- ml_match_dataset
- ml_team_ratings
- fair_odds
- value_edges
- block_candidates
- templates
- generated_tickets
- generated_ticket_blocks
- generated_ticket_risk
- user_selections

Smysl:
- oddělit sportovní realitu od analytiky a sázek
- držet modelové výstupy samostatně
- snadno stavět API pro betting část

---

## 4.4 Content domain
Obsahová vrstva:

- article_sources
- raw_articles
- articles
- article_tags
- team_article_map
- league_article_map
- match_article_map
- ai_summaries
- ai_match_previews
- ai_team_cards
- comments

Smysl:
- přivádět fanoušky
- zvýšit počet návratů
- zlepšit SEO
- nechat data žít i mimo čistě sázkový use-case

---

## 4.5 User & personalization domain
Uživatelská vrstva:

- users
- user_profiles
- user_follows
- user_favorite_teams
- user_favorite_leagues
- user_favorite_sports
- user_bookmaker_preferences
- user_notifications
- subscriptions
- subscription_plans
- paywall_rules

Smysl:
- personal feed
- personalizované notifikace
- prémiové funkce
- mobilní engagement

---

# 5. Ingest vrstva – cílové rozdělení

Nejdůležitější je nemíchat vše do jedné pipeline.

## 5.1 Slow ingest
Běhy 1× denně až 1× týdně:

- ligy
- týmy
- hráči
- historické sezóny
- metadata stadionů
- archivní statistiky

## 5.2 Medium ingest
Běhy několikrát denně:

- fixtures
- standings
- injuries
- lineups
- pre-match team info
- preview data

## 5.3 Fast ingest
Běhy po minutách nebo eventově:

- live match status
- score updates
- live events
- odds refresh
- bookmaker snapshots

## 5.4 Content ingest
Samostatná pipeline:

- RSS feedy
- sportovní news zdroje
- partner feedy
- komentáře / komunitní vstupy
- AI enrichment

---

# 6. Obsahová vrstva – jak ji uchopit

## 6.1 Externí obsah
Na začátku se bude obsah hlavně agregovat:

- RSS zdroje
- sportovní redakce
- klubové weby
- veřejné feedy
- tiskové zprávy
- strukturované news API

## 6.2 Interní obsah
Postupně vznikne i vlastní obsah:

- automatické preview zápasů
- AI souhrny formy týmu
- AI match cards
- AI daily digest
- ručně editované články

## 6.3 Tagování obsahu
Každý článek musí být navázán na entity:

- sport
- liga
- tým
- hráč
- zápas

Bez toho content nebude dobře fungovat v aplikaci.

---

# 7. API vrstva

API nesmí být jen pro web.  
Musí být použitelné stejně pro:

- Next.js web
- mobilní appku
- notifikace
- email digest
- budoucí partnerské API

## 7.1 Objektové endpointy
Základ:

- `/api/sports`
- `/api/leagues`
- `/api/league/[id]`
- `/api/team/[id]`
- `/api/player/[id]`
- `/api/match/[id]`
- `/api/articles/[id]`

## 7.2 Feed endpointy
Např.:

- `/api/matches/today`
- `/api/matches/tomorrow`
- `/api/matches/week`
- `/api/team/[id]/fixtures`
- `/api/team/[id]/news`
- `/api/league/[id]/news`
- `/api/feed/personal`
- `/api/feed/value`
- `/api/feed/fans`

## 7.3 Betting endpointy
Např.:

- `/api/match/[id]/odds`
- `/api/match/[id]/prediction`
- `/api/match/[id]/value`
- `/api/ticket/candidates`
- `/api/ticket/build`
- `/api/ticket/optimize`

---

# 8. Web a mobilní vrstva

## 8.1 Web
Aktuální směr:

- Next.js web
- SEO-friendly stránky
- rychlé feedy
- landing pages pro týmy, ligy a zápasy

## 8.2 Mobile
Cílově:

- React Native / Expo
- sdílené API s webem
- push notifikace
- personal feed
- sledování týmů a zápasů

## 8.3 Objektový navigační model
Aplikace musí být stavěna přes entity:

- sport
- liga
- tým
- hráč
- zápas
- článek
- tiket

To je správný základ pro web i mobil.

---

# 9. Cache, výkon a škálování

Jakmile poroste návštěvnost, nestačí jen PostgreSQL.

## 9.1 PostgreSQL
Použití:

- canonical pravda
- audit
- relační vazby
- historická data

## 9.2 Redis
Použití:

- live score cache
- hot endpoints
- session data
- notifikační fronty
- předpočítané feedy

## 9.3 Search index
Později vhodné přidat:

- fulltext článků
- hledání týmů
- hledání hráčů
- hledání lig
- rychlé search suggestions

---

# 10. Tři nejdůležitější funkce platformy

## 10.1 Match Intelligence
Detail zápasu s hlubokým přehledem:

- forma týmů
- statistiky
- H2H
- lineups
- injuries
- prediction model
- fair odds
- value indikace

To je hlavní analytická feature.

---

## 10.2 Ticket Optimizer
Unikátní vrstva platformy:

- výběr zápasů
- generování variant
- výpočet pravděpodobnosti
- výpočet rizika
- bloky a kombinace
- doporučená struktura tiketu

To je velká konkurenční výhoda.

---

## 10.3 Smart Personal Feed
Denní vstupní stránka uživatele:

- zápasy jeho týmů
- news jeho lig
- zajímavé duely dne
- doporučené value kandidáty
- novinky a preview

To je klíč k návratovosti.

---

# 11. Roadmapa ve 3 etapách

## Etapa 1 – Platform skeleton
Cíl:
stabilní základ, na kterém může růst celý produkt

### Udělat:
- doplnit players
- doplnit seasons
- doplnit lineups
- doplnit injuries
- doplnit standings snapshots
- doplnit user/personalization základ
- vytvořit objektové API endpointy
- stabilizovat ingest režimy (slow / medium / fast)

### Výstup:
- čistý sports graph
- API připravené pro web i mobil
- základ platformy mimo samotné sázení

---

## Etapa 2 – Content MVP + fan engagement
Cíl:
udělat z platformy něco, kam chodí i fanoušci

### Udělat:
- content schema
- import článků a feedů
- team news feed
- league news feed
- AI match preview
- AI team summary
- první fan stránky týmů a lig

### Výstup:
- návštěvnost mimo betting use-case
- začátek SEO růstu
- vyšší engagement

---

## Etapa 3 – Scale + mobile + premium
Cíl:
udělat z MatchMatrix skutečný produkt

### Udělat:
- mobilní app
- paywall a subscription plány
- push notifikace
- cache vrstva
- personal feed
- pokročilé betting funkce
- multi-sport rozšíření

### Výstup:
- web + mobil
- monetizace
- dlouhodobě škálovatelný produkt

---

# 12. Co bude největší riziko

## 12.1 Nekonzistentní entity
Např.:
- jeden tým vícekrát
- hráči bez mapování
- ligy bez canonical identity

To se musí držet tvrdě pod kontrolou.

## 12.2 Chaotický content
Články bez správného tagování na tým/ligu/zápas.

## 12.3 Live vrstva bez cache
Jakmile poroste traffic, čisté dotazy do DB nebudou stačit.

## 12.4 Příliš široký záběr příliš brzy
Je potřeba růst po vrstvách:
- nejdřív skeleton
- pak content
- pak mobile + premium
- pak širší sporty

---

# 13. Doporučené strategické pořadí

## Krátkodobě
- stabilizovat fotbal
- dokončit platform skeleton
- připravit content schema
- rozšířit API o objekty

## Střednědobě
- přidat content MVP
- přidat personalizaci
- přidat team pages a player pages
- rozšířit betting intelligence

## Dlouhodobě
- mobilní aplikace
- další sporty
- premium vrstvy
- globální škálování

---

# 14. Upřímné zhodnocení

Ano, **můžeš to zvládnout sám v první fázi**, pokud:

- půjdeš po vrstvách
- nebudeš chtít dělat všechno najednou
- udržíš si pořádek v architektuře
- budeš mít jasné priority

Sám zvládneš velmi dobře:

- databázový model
- ingest pipelines
- canonical architekturu
- backend API
- základ webu
- první content automatizaci
- první verzi analytiky

Sám už hůř zvládneš ve velkém měřítku současně:

- globální content operations
- redakční provoz
- mobilní app + web + backend + live infrastrukturu najednou
- community moderation
- marketing a růst

Proto je správný cíl:

## Fáze 1
postavit silné jádro sám

## Fáze 2
na rostoucí části později přibrat pomoc:
- content
- mobile
- frontend/UI
- redakční a komunitní vrstvu

---

# 15. Praktický závěr

Nejdůležitější teď není „přidat všechno“.

Nejdůležitější je:

1. dokončit **platform skeleton**
2. připravit **content-ready architekturu**
3. rozšířit API z čistě match feedů na **objektový model**
4. udržet systém čistý pro budoucí web + mobil + premium

To je správný základ pro to, aby se z MatchMatrix stal velký globální produkt.
