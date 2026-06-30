# MATCHMATRIX – MASTER SOUHRN PROJEKTU 2026

**Aktualizace:** 16.06.2026  
**Účel dokumentu:** Hlavní přehled projektu MatchMatrix.  
**Pravidlo:** Tento dokument se nemá přepisovat každý den celý. Doplňují se pouze důležité milníky, změny architektury, nové hotové vrstvy, strategická rozhodnutí a změna směru projektu.

---

## 1. CO JE MATCHMATRIX

MatchMatrix není pouze livescore web, databáze výsledků ani tipérský web.

Cílem je vybudovat **globální sports intelligence platform**, která propojí:

- sportovní data,
- historický archiv,
- profesionální i amatérské soutěže,
- hráče, trenéry, týmy a ligy,
- média a články,
- kurzy a odds,
- ratingy a predikce,
- Match Context Engine,
- Ticket Intelligence,
- AI vrstvu,
- webovou a později mobilní platformu,
- komunitní a amatérskou sportovní vrstvu.

Základní filozofie:

```text
DATA
↓
PEOPLE
↓
MEDIA
↓
ODDS
↓
MATCH CONTEXT
↓
PREDICTIONS
↓
TICKET ENGINE
↓
WEB
```

Projekt je dnes již za fází prototypu. Hlavní infrastruktura, databázová architektura, OPS vrstva, planner, scheduler, governance a většina základních datových vrstev už existují.

---

## 2. HLAVNÍ VIZE DO ROKU 2030

Dlouhodobý cíl:

```text
Největší sportovní databáze
+
největší sportovní archiv
+
amatérská sportovní platforma
+
AI sportovní analytika
+
Ticket Intelligence
+
globální sportovní ekosystém
```

MatchMatrix má pokrývat:

- profesionální sporty,
- amatérské soutěže,
- historická data od roku 1970 a pokud půjde, i starší období,
- live data od aktuálních sezón,
- media layer,
- player profiles,
- team profiles,
- match context,
- ticket learning engine,
- digitální kartičky,
- multijazyčný obsah.

---

## 3. AKTUÁLNÍ STAV PROJEKTU

### Celkové hodnocení

```text
CORE                READY / velmi silná vrstva
PEOPLE              READY / PARTIAL podle sportu
MEDIA               READY FOUNDATION
ODDS                PREPARED / částečně runtime tested
PHOTO               PREPARED / první workflow hotové
GOVERNANCE          READY
OPS                 ADVANCED
AUTONOMOUS OPS      ACTIVE
SOURCE DISCOVERY    STARTED
WEB                 PLANNED / zatím nejslabší vrstva
AI                  PLANNED / naváže na data a context
TICKET ENGINE       DB základ existuje, čeká propojení s contextem
```

Projekt je přibližně ve stavu:

```text
Infrastruktura       95 %
Databáze             95 %
OPS                  95 %
Ingest               90 %
Fotbal               85–90 %
Hokej                70–80 %
Basketbal            70–80 %
People Layer         60–75 %
Media Layer          70–75 %
Web                  20 %
Produkční readiness  65–80 %
```

---

## 4. HLAVNÍ ARCHITEKTURA

Základní datový tok:

```text
PROVIDER
↓
RAW PAYLOAD
↓
STAGING
↓
MERGE
↓
PUBLIC
↓
PEOPLE
↓
MEDIA
↓
ODDS
↓
MATCH CONTEXT
↓
PREDICTIONS
↓
TICKET ENGINE
↓
WEB
↓
OPS
↓
AUTONOMOUS BRAIN
```

### Hlavní vrstvy

#### Provider Layer

Získávání dat z API, oficiálních webů, RSS, sitemap, CSV/open data a dalších zdrojů.

Aktuální nebo plánované zdroje:

- API-Football,
- Football-Data,
- API-Hockey,
- API-Sport / API-Basketball,
- API-Baseball,
- API-Cricket,
- API-American-Football,
- API-Handball,
- API-Volleyball,
- API-Rugby,
- API-Tennis,
- TheOdds,
- SportsDataIO,
- Wikidata,
- Wikimedia,
- official league sites,
- official team sites,
- federation sites.

#### Raw Layer

Ukládá přesnou odpověď providerů beze změn. Slouží pro audit, reprocessing a kontrolu chyb.

#### Staging Layer

Normalizuje data do jednotné struktury:

- `staging.stg_provider_fixtures`,
- `staging.stg_provider_leagues`,
- `staging.stg_provider_teams`,
- `staging.stg_provider_players`,
- `staging.stg_provider_player_profiles`,
- `staging.stg_provider_player_season_stats`,
- `staging.stg_provider_odds`,
- `staging.stg_media_articles`.

#### Public Layer

Produkční kanonická data:

- sporty,
- země,
- ligy,
- týmy,
- zápasy,
- hráči,
- trenéři,
- články,
- kurzy,
- statistiky,
- provider mapy.

---

## 5. DATABASE GOVERNANCE

Byl proveden rozsáhlý audit DB objektů.

Zmapováno:

```text
OPS views       214+
OPS tables       59+
PUBLIC tables   129+
PUBLIC views    100+
STAGING objects  35+
```

Governance cíl:

```text
vědět, co je MASTER
co je ACTIVE
co je REVIEW
co je LEGACY
co je kandidát na DROP
co používá web
co používá panel
co používá scheduler
co používá autonomní systém
```

Dlouhodobá pravda projektu:

```text
ops.database_object_governance
```

---

## 6. STANDARD MATCHMATRIX PRO NOVÉ SOUBORY A OBJEKTY

Každý nový SQL script, view, tabulka, worker, panel nebo automatizační skript musí obsahovat:

```text
KAM ULOŽIT

NÁZEV SOUBORU

CO TO JE

K ČEMU TO JE

KDE TO UVIDÍME

JAK SE TO VYUŽIJE

NAVAZUJE NA

DALŠÍ KROK

JAK SPUSTIT
```

Toto pravidlo je povinné, protože MatchMatrix už není malý script projekt, ale enterprise-style sportovní platforma s velkým množstvím objektů.

---

## 7. CORE LAYER

Core Layer zahrnuje:

```text
LEAGUES
TEAMS
FIXTURES
MATCHES
```

Silné sporty:

- FB – Football,
- HK – Hockey,
- BK – Basketball,
- BSB – Baseball,
- HB – Handball,
- VB – Volleyball,
- AFB – American Football,
- CK – Cricket,
- RGB – Rugby,
- TN – Tennis.

Core je pro většinu hlavních sportů funkční nebo potvrzený.

---

## 8. TEAM GOVERNANCE

### 17_8 Team Dedup

Byla dokončena velká deduplikační vlna nad `public.teams`.

Výsledek:

```text
496 týmů odstraněno
148 provider map přesunuto
46 hráčů přesunuto
```

Poslední bezpečný HOLD:

```text
Keshla FC
```

důvod:

```text
league_standings dependency
```

### 17_9 Team Duplicate Prevention

Po vyčištění byla vytvořena ochranná vrstva:

- Provider Guard,
- Canonical Guard,
- Alias Guard,
- Insert Guard,
- Duplicate Monitoring.

Finální stav:

```text
TEAM_DUPLICATE_PREVENTION = READY
TEAM_CANONICAL_CLEANUP    = READY
TEAM_INSERT_GUARD         = ACTIVE
```

---

## 9. PLAYER / PEOPLE GOVERNANCE

### Player Identity Governance

Dokončeno:

```text
18_A až 18_F
```

Výsledek:

```text
CRITICAL = 0
HIGH     = 0
MEDIUM   = 106
LOW      = 15
HOLD     = 121
```

Status:

```text
PLAYER_IDENTITY_GOVERNANCE = READY / CONTROLLED_HOLD
PLAYER_INSERT_GUARD        = ACTIVE
```

### Player Provider Map Governance

Kontrola vazeb mezi:

- `public.players`,
- `public.player_provider_map`,
- `public.player_external_identity`.

Finální stav:

```text
CONTROLLED_HOLD
```

Speciální případy zůstávají ruční review, ale neblokují další rozvoj.

---

## 10. MATCH GOVERNANCE

Byla dokončena etapa Match Duplicate Governance.

Nalezeno:

```text
PROVIDER_DUPLICATE        3258 řádků
LEAGUE_MAPPING_ERROR      1128 řádků
REVIEW_REQUIRED            644 řádků
SCORE_CONFLICT_REVIEW      202 řádků
```

Bezpečně odstraněno:

```text
1629 duplicitních zápasů
```

Výsledek:

- očištěn Match Context Engine,
- sníženy duplicity v `public.matches`,
- lepší základ pro Ticket Engine,
- lepší základ pro Match Detail a Web.

Status:

```text
MATCH_DUPLICATE_GOVERNANCE = CONTROLLED_HOLD
```

---

## 11. LEAGUE GOVERNANCE

Byla dokončena League Mapping Governance.

Opraveno:

```text
562 league mapping konfliktů
```

Zůstaly pouze 2 HOLD případy:

- Handball score conflict,
- Football canonical conflict.

Status:

```text
LEAGUE_MAPPING_GOVERNANCE = CONTROLLED_HOLD
LEAGUE_CANONICAL_GOVERNANCE = READY
```

---

## 12. PEOPLE LAYER

People Layer je jedna z největších priorit projektu.

Důvod:

```text
hráči = základ profilů
hráči = základ statistik
hráči = základ ratingů
hráči = základ formy
hráči = základ AI
hráči = základ Ticket Intelligence
```

### READY / silné sporty

```text
FB   Football
HK   Hockey
BK   Basketball
TN   Tennis
MMA  MMA
BSB  Baseball
CK   Cricket
AFB  American Football
```

### Slabé nebo problematické sporty

```text
HB   Handball
VB   Volleyball
RGB  Rugby
FH   Field Hockey
DRT  Darts
ESP  Esports
```

### Důležité zjištění

U více sportů už nejsou problém ligy, týmy a zápasy.

Největší problém je:

```text
players
coaches
profiles
photos
season stats
match stats
```

---

## 13. FOOTBALL PEOPLE

Football People je nejvíce rozpracovaná větev.

Máme:

- tisíce hráčů,
- provider mapy,
- profily,
- sezónní statistiky,
- částečně fotky,
- začínající player rating engine.

Byl spuštěn API-Football profile enrichment.

Stažená data obsahují například:

- full name,
- first name,
- last name,
- birth date,
- nationality,
- height,
- weight,
- position,
- team,
- league,
- season,
- photo URL.

---

## 14. PLAYER SEASON STATS A PLAYER RATING

Byla vytvořena a ověřena vrstva sezónních statistik hráčů.

Statistiky obsahují například:

- appearances,
- lineups,
- minutes played,
- rating,
- goals,
- assists,
- shots,
- passes,
- tackles,
- duels,
- cards,
- penalties.

Následně vznikl první MatchMatrix Player Rating Engine.

Zjištění:

- původní výpočet dával příliš mnoho hráčů na 100,
- pozdější verze lépe rozložila hráče do kategorií,
- zavedeny stavy typu:

```text
INSUFFICIENT_DATA
REGULAR_PLAYER
GOOD_PLAYER
TOP_PLAYER
LOW_RATED_PLAYER
```

Směr:

```text
player_rating
↓
player_form
↓
player cards
↓
player profile
↓
ticket intelligence
```

---

## 15. COACHES LAYER

Byla vytvořena vrstva trenérů:

- `staging.stg_provider_coaches`,
- `public.coaches`,
- `public.team_coaches`,
- `coach_provider_map`.

Ověřeno na fotbale.

Trenéři jako Ruben Amorim, Michael Carrick nebo Erik ten Hag byli propojeni s týmy.

Další směr:

- rozšířit coaches pro více sportů,
- doplnit role,
- doplnit historii kariéry,
- doplnit fotky trenérů,
- napojit na Match Context Engine.

---

## 16. MEDIA LAYER

Media Layer je již funkční základ.

Aktivní nebo částečně aktivní zdroje:

```text
NHL
NBA
Premier League
LaLiga
Bundesliga
UEFA
FIFA částečně / problém
Serie A částečně / problém
Ligue 1 problém / 404
```

Systém umí:

- stáhnout články,
- parsovat články,
- ukládat raw text,
- detekovat thumbnail,
- rozpoznávat video,
- linkovat na týmy,
- linkovat na hráče,
- připravovat match linking.

Další směr:

- kvalitnější football source parsery,
- UEFA custom extractor,
- FIFA extractor,
- thumbnail propagation,
- article-team-player-match mapping,
- media feed pro web.

---

## 17. PHOTO LAYER

Byl vytvořen první workflow:

```text
Wikidata / Wikimedia
↓
photo discovery worker
↓
staging.stg_player_photo_candidates
↓
panel PHOTO REVIEW
↓
approve / reject
↓
merge do public.players.photo_url
```

Ověřeno:

- André Ramalho – schválený kandidát,
- N. Ferguson – zamítnutý kandidát kvůli špatné identitě.

Klíčové zjištění:

```text
fotky nelze bezpečně přiřazovat jen podle zkráceného jména
```

Potřebujeme před tím:

- celé jméno,
- datum narození,
- národnost,
- tým,
- liga,
- sezóna,
- provider identity,
- profilová data.

Další směr:

```text
Player Detail Coverage Audit
↓
Profile Enrichment
↓
Photo Discovery
↓
Photo Review
↓
Photo Merge
```

---

## 18. ODDS LAYER

Odds Layer je připravená architektonicky.

Existuje:

- TheOdds ingest,
- odds tables,
- odds attach,
- best match odds,
- market odds,
- fair odds,
- unmatched_theodds,
- odds roadmap.

Stav:

- FB odds částečně runtime tested,
- další sporty čekají na paid/pro API režim,
- nutný smoke test před masivním harvestem.

Další směr:

- TheOdds Command Center zpět do nového panelu,
- FB odds linker quality,
- historical odds,
- live odds,
- odds coverage dashboard,
- paid provider readiness.

---

## 19. TICKET ENGINE

Ticket Engine již není jen myšlenka.

V databázi existují hlavní části:

- tickets,
- ticket_blocks,
- ticket_variants,
- ticket_settlements,
- ticket_pattern_stats,
- ticket_strategy_catalog,
- ticket_recommendation_feedback,
- generated_tickets,
- ml_predictions,
- player_form,
- team power views,
- strategy ranking/recommendation views.

Co chybí:

```text
ne tabulky
ale propojení
```

Nutné propojit:

```text
Ticket Engine
+
People Layer
+
Media Layer
+
Match Context Engine
+
Injuries
+
Absences
+
Form
+
Odds
```

Cíl:

```text
Ticket Learning Engine
```

který bude vyhodnocovat:

- úspěšnost,
- ROI,
- historické patterny,
- podobné zápasy,
- confidence,
- value,
- riziko.

MatchMatrix nebude sázkovka. Bude to analytický a poradní systém. Konečné rozhodnutí vždy zůstává na uživateli.

---

## 20. UNIVERSAL CONTEXT RESOLVER

Byla dokončena první funkční verze univerzálního vyhledávacího a kontextového systému.

Systém umí:

```text
uživatelský dotaz
↓
rozpoznání entit
↓
rozpoznání aliasů
↓
nalezení týmů
↓
nalezení lig
↓
nalezení hráčů
↓
nalezení zápasů
↓
nalezení článků
↓
vytvoření kontextu
```

Ověřený test:

```text
Barcelona vs Real Madrid
```

Výstup:

- FC Barcelona,
- Real Madrid CF,
- La Liga,
- Copa del Rey,
- vzájemné zápasy,
- články,
- historie zápasů.

Hotové části:

```text
ENTITY REGISTRY
ALIAS REGISTRY
CONTEXT RESOLVER
SEARCH FUNCTION V1/V2/V3
MATCH PAIR RESOLVER
MATCH CONTEXT ENGINE V1/V2/V3
```

Další směr:

```text
MATCH_CONTEXT_ENGINE_V4_DEDUP
AI_SEARCH_RESPONSE_V1
```

---

## 21. MATCH CONTEXT ENGINE

Budoucí klíčová vrstva.

Princip:

```text
Zápas
↓
najít zdroje
↓
stáhnout články
↓
AI analýza
↓
vytáhnout fakta
↓
uložit do DB
↓
použít v predikci a Ticket Engine
```

Typy faktů:

- INJURY,
- KEY_PLAYER_MISSING,
- COACH_CHANGE,
- LINEUP_NEWS,
- GOOD_FORM,
- BAD_FORM,
- MOTIVATION,
- FATIGUE,
- TRAVEL,
- TRANSFER.

---

## 22. OPS / RUNTIME OPERATIONS CENTER

Vznikl skutečný základ:

```text
Sports Data Operating System
```

Hotové prvky:

- Active Runs Live,
- Active Runs Summary,
- Planner Queue Summary,
- Scheduler Queue Summary,
- Recent Failures Engine,
- Runtime Alerts Engine,
- Runtime Operations Center Feed,
- Grouped Runtime Alerts,
- Operations Center Summary.

OPS umí sledovat:

- běžící workery,
- stale heartbeat,
- expired lock,
- planner backlog,
- failed workers,
- retry pressure,
- provider failures,
- scheduler confidence.

Panel už není jen GUI, ale začíná připomínat NOC/SOC pro sportovní data.

---

## 23. AUTONOMOUS OPS BRAIN

Vznikla autonomní rozhodovací vrstva.

Obsahuje:

- Sport Completion Dashboard,
- Autonomous OPS Brain,
- Dispatch Queue,
- Dispatch Readiness,
- Dispatch Summary,
- Automation Ready Queue,
- Run Next,
- Provider Routing,
- Data Gap Engine.

Autonomní smyčka:

```text
Brain
↓
Dispatch Queue
↓
Candidate Selection
↓
Command Builder
↓
Readiness Check
↓
Worker
↓
Audit
```

Dnes už systém umí vyhodnotit, co je:

```text
RUN
WAIT
HOLD
RUN_WITH_CAUTION
SKIPPED_NO_PENDING
```

---

## 24. PC2 HARVEST SERVER

Druhé PC je plánováno jako výkonný harvest server.

Role PC1:

- PostgreSQL,
- Redis,
- Scheduler,
- Planner,
- OPS Panel,
- DBeaver,
- VS Code,
- web vývoj.

Role PC2:

- API harvest,
- historical backfill,
- People harvest,
- media enrichment,
- batch workery,
- později AI experimenty.

Pravidlo:

```text
ŽÁDNÝ PŘÍMÝ HARVEST
VŠE PŘES:
ops.ingest_planner
ops.scheduler_queue
ops.worker_locks
ops.runtime audit
```

PC2 Command Center už bylo ověřeno na reálných bězích.

---

## 25. PC2 COMMAND CENTER

Byla vytvořena logika:

```text
CORE
↓
PEOPLE
↓
MEDIA
↓
ODDS
↓
CONTEXT
```

A vznikla fronta:

```text
ops.pc2_run_command_queue
```

PC2 Command Center umí:

- připravit command,
- spustit worker,
- zapsat stav,
- odlišit routing error,
- worker error,
- provider error,
- empty data.

Ověřeno:

- HB CORE,
- TN CORE,
- FB MEDIA,
- BK PEOPLE TECH_READY_EMPTY,
- AFB PEOPLE TECH_READY_EMPTY.

---

## 26. V18 / V19 PANEL

Panel se postupně vyvíjí z jednoduchého kontrolního nástroje na hlavní Command Center.

Požadované moduly:

- Harvest Command Center,
- AI Doporučení,
- People Command Center,
- Media Command Center,
- Odds Command Center,
- Provider Command Center,
- Autonomous Harvest,
- Incident Center,
- Project Roadmap,
- Source Discovery,
- Photo Review.

Uživatelská preference:

- panel kompletně česky,
- méně KPI,
- profesionální vzhled,
- fialová barva,
- jasné akční karty,
- minimum chaosu,
- méně technického DBeaver stylu,
- více Command Center styl.

---

## 27. SOURCE DISCOVERY LAYER – DNEŠNÍ MILNÍK 16.06.2026

Dnes vznikla nová vrstva:

```text
AUTONOMOUS SOURCE DISCOVERY LAYER
```

Cíl:

```text
když provider nestačí
systém sám zjistí, kde hledat data dál
```

Nové / potvrzené objekty:

```text
ops.entity_requirement_matrix
ops.source_discovery_matrix
ops.source_registry
ops.source_discovery_tasks

ops.v_source_discovery_engine_v1
ops.v_missing_data_source_recommendations_v1
ops.v_source_discovery_summary_v1
ops.v_source_discovery_queue_v1
ops.v_source_discovery_dashboard_v1
```

Systém dnes umí říct:

```text
sport
entity
provider
coverage status
source type
recommended mode
task status
suggested action
```

Například:

```text
HB players api_handball blocked
→ HIGH_PRIORITY
→ hledat další zdroje

HK players api_hockey blocked
→ HIGH_PRIORITY

VB players api_volleyball blocked
→ HIGH_PRIORITY

RGB players api_rugby blocked
→ HIGH_PRIORITY
```

Source types:

- API_PROVIDER,
- OFFICIAL_TEAM_SITE,
- OFFICIAL_LEAGUE_SITE,
- FEDERATION_SITE,
- RSS,
- SITEMAP,
- WIKIDATA,
- WIKIMEDIA,
- CSV_OPEN_DATA,
- PAID_FEED,
- BOOKMAKER_SITE.

Entity requirements:

- PLAYERS,
- COACHES,
- FIXTURES,
- ODDS,
- MEDIA,
- PHOTOS.

Toto je zásadní posun od:

```text
provider-driven harvest
```

k:

```text
source-discovery-driven harvest
```

---

## 28. CO BUDEME DĚLAT TEĎ

Nejbližší epic:

```text
19_5_AM_SOURCE_DISCOVERY_EXECUTOR_V1
```

Cíl:

```text
Discovery Queue
↓
ověřit kandidátní zdroj
↓
ověřit URL / API / RSS / sitemap / official site
↓
ověřit license / robots / terms
↓
zapsat do source_registry
↓
vytvořit discovery task
↓
připravit harvest route
↓
vrátit do automation queue
```

Tím se uzavře smyčka:

```text
DATA GAP
↓
SOURCE DISCOVERY
↓
SOURCE VALIDATION
↓
SOURCE REGISTRY
↓
HARVEST QUEUE
↓
WORKER
↓
STAGING
↓
PUBLIC
```

---

## 29. ROADMAPA DO KONCE ROKU 2026

### Červen 2026

- dokončit Source Discovery Layer,
- dokončit People Enrichment,
- pokračovat Photo Layer,
- zlepšit PC2 Command Center,
- připravit PRO harvest,
- připravit webové datové views.

### Červenec 2026

- PC2 plný provoz,
- massive harvest,
- Football full backfill,
- People expansion,
- Media expansion,
- odds smoke tests.

### Srpen 2026

- historical backfill ve větším objemu,
- rozšířit storage,
- rozšířit RAM,
- začít AI sumarizace / překlady,
- hlubší Match Context Engine.

### Září 2026

- Web Beta,
- první veřejné stránky týmů, hráčů a zápasů,
- první media feed,
- základ uživatelských profilů.

### Říjen 2026

- Closed Beta,
- Ticket Intelligence V1,
- personalizace,
- oblíbené týmy/hráči.

### Listopad 2026

- Public Beta,
- širší testování,
- první premium vrstvy.

### Prosinec 2026

- první platící uživatelé,
- stabilizace,
- produkční provoz.

---

## 30. WEB PLATFORM

Web je zatím nejslabší vrstva, ale má jasný směr.

Bude obsahovat:

- homepage,
- sport detail,
- league detail,
- team detail,
- player detail,
- match detail,
- media feed,
- odds view,
- ticket builder,
- user profile,
- premium features,
- admin panel,
- amateur competitions.

Zatím platí filozofie:

```text
nejdříve data
potom inteligence
potom web
```

---

## 31. AMATÉRSKÉ SOUTĚŽE

Jedna z největších budoucích výhod MatchMatrix.

Uživatel bude moci:

- založit soutěž,
- přidat týmy,
- zadávat výsledky,
- spravovat hráče,
- spravovat statistiky.

Po schválení MatchMatrix:

- vznikne tabulka,
- forma,
- rating,
- statistiky,
- historie,
- týmové a hráčské karty.

Hlavní myšlenka:

```text
Stejný engine pro Premier League i okresní přebor.
```

---

## 32. DIGITÁLNÍ KARTIČKY

Budoucí prémiová funkce.

Typy:

- hráčské karty,
- týmové karty,
- zápasové karty,
- amatérské karty,
- speciální edice,
- digitální alba,
- PDF alba,
- tištěné kolekce.

Naváže na:

- Photo Layer,
- Player Ratings,
- Team Ratings,
- Match Context,
- AI grafiku,
- webovou platformu.

---

## 33. MONETIZACE

Pracovní model:

```text
FREE TRIAL
SPORT PASS
CLUB PASS
MATCHMATRIX PLUS
MATCHMATRIX ELITE
```

Možné ceny z vize:

- Sport Pass cca 3 EUR / měsíc,
- Club Pass cca 6 EUR / měsíc,
- Plus cca 9 EUR / měsíc,
- Elite cca 12 EUR / měsíc.

Budoucí affiliate vrstva se sázkovými kancelářemi pouze podle legislativních možností v dané zemi.

---

## 34. HLAVNÍ KONKURENČNÍ VÝHODA

Ne počet zápasů sám o sobě.

Ale propojení:

```text
DATA
+
PEOPLE
+
MEDIA
+
ODDS
+
MATCH CONTEXT
+
AI
+
TICKET ENGINE
+
AMATEUR COMPETITIONS
+
DIGITAL CARDS
+
AUTONOMOUS OPS
```

do jednoho systému.

---

## 35. NEJBLIŽŠÍ PRIORITY

1. **Source Discovery Executor**  
   Aby systém nejen doporučoval zdroje, ale začal je ověřovat a zapisovat.

2. **People Enrichment**  
   Doplnit profily, pozice, celé jméno, týmový kontext, statistiky.

3. **Photo Layer bezpečně přes identity**  
   Nepřiřazovat fotky bez dostatečného hráčského kontextu.

4. **PC2 Harvest Flow**  
   Stabilizovat CORE → PEOPLE → MEDIA → ODDS.

5. **Odds Command Center**  
   Vrátit / napojit TheOdds a odds coverage do nového panelu.

6. **Match Context Engine V4**  
   Deduplikace a AI-ready response.

7. **Web Data Views**  
   Začít připravovat data pro veřejné stránky.

---

## 36. ZÁVĚR

MatchMatrix dnes není jen databázový projekt.

Je to postupně vznikající:

```text
AUTONOMOUS SPORTS INTELLIGENCE PLATFORM
```

Projekt už má:

- rozsáhlé datové jádro,
- governance,
- monitoring,
- planner,
- scheduler,
- OPS panel,
- People Layer,
- Media Layer,
- Odds základ,
- Ticket Engine základ,
- Context Engine,
- Source Discovery Layer.

Největší další krok není stavět další tabulky naslepo.

Největší další krok je uzavírat autonomní smyčky:

```text
problém
↓
detekce
↓
doporučení
↓
ověření
↓
oprava
↓
návrat do harvestu
↓
výsledek
```

Tím se MatchMatrix dostane do stavu, kdy bude schopný dlouhodobě růst přes mnoho sportů a providerů bez ručního hlídání každého jednotlivého problému.

