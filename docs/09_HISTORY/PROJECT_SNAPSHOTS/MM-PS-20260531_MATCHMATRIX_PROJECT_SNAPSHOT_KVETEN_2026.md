# MM-PS-20260531

# MATCHMATRIX PROJECT SNAPSHOT – KVĚTEN 2026

## HISTORICKÝ PROJEKTOVÝ CHECKPOINT

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PS-20260531 |
| Název | MatchMatrix Project Snapshot – květen 2026 |
| Typ | Project Snapshot / historický projektový checkpoint |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum snapshotu | 2026-05-31 |
| Rekonstruované období | 2026-05-01 až 2026-05-31 |
| Přímé zdrojové pokrytí | 2026-05-11 až 2026-05-26 |
| Předchozí checkpoint | MM-PS-20260430 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Doporučené umístění | `docs/09_HISTORY/PROJECT_SNAPSHOTS/MM-PS-20260531_MATCHMATRIX_PROJECT_SNAPSHOT_KVETEN_2026.md` |
| Zdroj pravdy | Historický korpus MatchMatrix a redakčně zpracovaná rekonstrukce |
| Hlavní zdrojové dokumenty | MM-HIS-0003 až MM-HIS-0014, MM-HIS-0273, MM-HIS-0275, MM-HIS-0278 až MM-HIS-0284 |
| Pracovní rekonstrukce | `history_reconstruction_20260511_20260526_working_report_v2_reviewed.md` |
| Zdrojový měsíční korpus | `history_complete_month_corpus_2026_05_latest.*` |

---

## Upozornění k použití

Tento dokument je **historický projektový checkpoint**. Popisuje vývoj, rozhodnutí, implementované části, runtime ověřené toky, omezení a strategický směr projektu MatchMatrix v květnu 2026.

Nejde o popis současného produkčního stavu platformy. Názvy skriptů, tabulek, view, providerů, datové počty, runtime stavy a označení připravenosti musí být před dnešním použitím porovnány s aktuální databází, repozitářem a dokumentací.

Historické zdroje používají výrazy:

- „hotovo“,
- „kompletní“,
- „plně funkční“,
- „production-ready“,
- „AI-ready“,
- „scheduler-ready“,
- „safe autonomous“.

V tomto checkpointu jsou tato označení vždy omezena na skutečně doložený rozsah. Mohla se vztahovat pouze na:

- konkrétní worker nebo view,
- jeden sport,
- vybraného providera,
- omezený počet soutěží,
- jednotlivý runtime běh,
- databázovou architekturu bez úplného datového pokrytí,
- testovací orchestraci bez dlouhodobého autonomního provozu.

Checkpoint proto rozlišuje:

1. **IMPLEMENTED / RUNTIME TESTED** – existuje konkrétní implementace a doložený výsledek,
2. **TECH READY** – architektura nebo konfigurace existuje, ale plný provoz není potvrzen,
3. **PARTIAL** – funguje pouze omezený rozsah,
4. **PLANNED / STRATEGIC DESIGN** – budoucí cíl nebo roadmapa,
5. **CLAIM REQUIRING CAUTION** – tvrzení širší než dostupné důkazy,
6. **SUPERSEDED / EXPANDED** – pozdější dokument opravuje nebo rozšiřuje předchozí stav.

### Omezení časového pokrytí

Pro květen 2026 bylo v klasifikovaném historickém korpusu identifikováno:

```text
20 dokumentů
19 přesně datovaných
1 dokument zařazený pouze na úroveň měsíce
```

Přímé datumové pokrytí začíná 11. května a končí 26. května 2026.

Pro období:

```text
2026-05-01 až 2026-05-10
2026-05-27 až 2026-05-31
```

nebyly v použitém korpusu nalezeny samostatné přesně datované zdrojové dokumenty.

Datum 31. května proto slouží jako identifikátor měsíčního snapshotu. Poslední přímo doložený technický stav pochází z 26. května 2026. Chybějící dokument není důkazem, že v nepokrytém období neprobíhala práce.

---

# 1. Účel checkpointu

Cílem dokumentu je rekonstruovat vývoj MatchMatrix za květen 2026 a zachytit období, ve kterém se projekt posunul:

- od prvního MEDIA ingestu k entity matching, feedům a trending vrstvě,
- od pouhého sběru článků k jejich vazbám na kanonické sportovní entity,
- od základního PEOPLE schématu k auditu kvality, backfill queue a provider reality matrix,
- od dílčích player statistik k prvnímu testovanému FB player-match-stats toku,
- od sport-specific parserů k potvrzenému basketball unified flow,
- od readiness view k dependency-aware orchestration a operations center,
- od obecných tvrzení o připravenosti k rozlišení architektury, runtime testu a datového pokrytí,
- od provider-first uvažování k multi-provider strategii podle sportu a entity.

Checkpoint současně vymezuje oblasti, které na konci dostupného květnového období zůstávaly částečné, neověřené nebo plánované.

---

# 2. Metodika rekonstrukce

## 2.1 Použité zdroje

Rekonstrukce vychází z:

- denních a pracovních zápisů,
- navazovacích dokumentů,
- MEDIA milestone reportů,
- PEOPLE master auditů,
- provider priority a reality matrix,
- orchestration milestone dokumentů,
- operations-center zápisů,
- konkrétních DB počtů,
- názvů workerů, view a tabulek,
- runtime výsledků uvedených v historických dokumentech,
- kompletního květnového měsíčního korpusu,
- redakčně zpracované pracovní rekonstrukce v2.

Zdrojový rozsah:

```text
MM-HIS-0003 až MM-HIS-0014
MM-HIS-0273
MM-HIS-0275
MM-HIS-0278 až MM-HIS-0284
```

Celkem:

```text
20 obsahových dokumentů
```

## 2.2 Klasifikace důkazů

| Úroveň | Význam |
|---|---|
| IMPLEMENTED / RUNTIME TESTED | Existuje konkrétní skript, tabulka, view, běh nebo DB výsledek |
| END-TO-END CONFIRMED | Konkrétní tok prošel od queue/pullu nebo RAW až po parser či public vrstvu |
| TECH READY | Architektura, konfigurace nebo view existuje, ale plný runtime není potvrzen |
| PARTIAL | Funguje pouze část sportu, entity, providera nebo datového rozsahu |
| PLANNED / STRATEGIC DESIGN | Cílová architektura, roadmapa nebo další krok |
| BLOCKED / DATA GAP | Omezení providerem, coverage, tarifem, parserem nebo chybějícími daty |
| CLAIM REQUIRING CAUTION | Historické označení je širší než doložený rozsah |
| SUPERSEDED / EXPANDED | Pozdější dokument rozšiřuje nebo nahrazuje předchozí zdroj |
| DATE CONFLICT | Manifest a vnitřní datum dokumentu se neshodují |

## 2.3 Pravidla chronologie

- Přesně datované dokumenty jsou řazeny podle klasifikační mapy.
- Dokument bez přesného dne je používán pouze na úrovni měsíce.
- Plán není důkazem implementace.
- Přítomnost tabulky nebo view není sama o sobě důkazem úplných dat.
- Runtime test jednoho toku není důkazem globální připravenosti platformy.
- Rozšířená varianta dokumentu nesmí způsobit dvojí započítání stejného milníku.
- Rozdílné databázové počty se nesčítají bez znalosti času a filtru auditu.
- Označení `READY`, `DONE` nebo `PRODUCTION-READY` je vždy omezeno na doložený rozsah.

## 2.4 Známé překryvy, varianty a nejistoty

- `MM-HIS-0284` je rozšířená kompozitní varianta `MM-HIS-0283`.
- `MM-HIS-0275` rozšiřuje evidence orchestration milestone `MM-HIS-0014`.
- Datum `MM-HIS-0275` je rekonstruováno na 25. května s jistotou MEDIUM.
- `MM-HIS-0273` je podpůrný PEOPLE checklist bez přesného dne.
- `MM-HIS-0012` je v manifestu veden k 21. květnu, ale uvnitř dokumentu je datum 22. května.
- `MM-HIS-0279` je především roadmapa a vize; není důkazem dokončeného cílového stavu.
- Počty `public.teams` uvedené 23. a 25. května se liší; bez samostatného DB auditu je nelze bezpečně vysvětlit.

---

# 3. AI CONTEXT

MatchMatrix byl v květnu 2026 budován jako rozsáhlá multisportovní datová, analytická, mediální, odds a tiketová platforma.

Projekt měl v tomto období tyto hlavní vrstvy:

1. **Canonical Core**
   - sporty,
   - soutěže,
   - sezony,
   - týmy,
   - zápasy,
   - hráči,
   - provider identity,
   - aliasy a canonical mapping.

2. **Ingest a Harvest Core**
   - targets,
   - planner,
   - queue,
   - pull,
   - RAW payloady,
   - unified staging,
   - parsery,
   - merge do public vrstvy.

3. **People Layer**
   - hráči,
   - provider mapy,
   - season a match statistics,
   - profily,
   - fotografie,
   - týmový kontext,
   - trenéři,
   - quality audit a backfill.

4. **Media Layer**
   - oficiální weby,
   - RSS,
   - články,
   - detail parsing,
   - entity matching,
   - feedy,
   - trending,
   - source discovery a approval.

5. **Odds a Ticket Layer**
   - odds ingest,
   - provider coverage,
   - market data,
   - budoucí Ticket Engine,
   - analytické a doporučovací vrstvy.

6. **Orchestration a Operations**
   - provider routing,
   - readiness,
   - priority queue,
   - dependency graph,
   - scheduler kandidáti,
   - runtime alerty,
   - operations center.

7. **AI a Analytics Foundation**
   - team power,
   - player form,
   - trending,
   - summaries,
   - translations,
   - datové základy budoucích predikcí a asistence.

Květnový strategický posun lze shrnout takto:

> MatchMatrix již neměl být jen soubor oddělených workerů. Měl se stát řízenou, auditovatelnou a multi-provider platformou, ve které je samostatně evidováno, zda architektura existuje, zda tok proběhl a zda jsou data skutečně dostatečně pokrytá.

---

# 4. PROJECT SNAPSHOT

## 4.1 Stav na začátku dostupného květnového období

Do května projekt vstupoval se základy vytvořenými v březnu a dubnu:

- unified staging architekturou,
- canonical core,
- planner-driven ingest,
- runtime audity,
- provider routing,
- prvními multisport toky,
- rozpracovanou PEOPLE vrstvou,
- prvními MEDIA a odds větvemi,
- základní Ticket Engine architekturou,
- rostoucím Control Panelem.

Hlavní květnové otázky byly:

- lze MEDIA vrstvu dostat z ingestu do prakticky použitelných feedů,
- lze systematicky mapovat články na hráče, týmy a ligy,
- lze PEOPLE data oddělit podle kvality, coverage a provider reality,
- lze player match statistics zpracovat přes opakovatelný queue tok,
- lze sjednotit parsery dalších sportů,
- lze orchestraci nejen navrhnout, ale i provozně sledovat.

---

## 4.2 11. května – první ucelená MEDIA pipeline

Byla popsána první ucelená MEDIA pipeline zahrnující:

```text
pull_official_site_media_articles_v1.py
pull_rss_media_articles_v1.py
parse_article_details_v1.py
merge_media_articles_to_public_v1.py
match_article_entities_v1.py
run_media_pipeline_v1.py
```

Doložený tok:

```text
oficiální weby / RSS
→ staging.stg_media_articles
→ detail parsing
→ public.articles
→ entity matching
```

Zároveň byla formulována širší projektová pravidla:

- databáze je nadřazená textovému souhrnu,
- projekt má být multi-provider,
- orchestrace má být oddělená podle vrstvy,
- dokumentace nemá nahrazovat runtime realitu.

### Hodnocení

| Oblast | Stav |
|---|---|
| MEDIA ingest | IMPLEMENTED / PARTIAL |
| MEDIA merge | RUNTIME TESTED / PARTIAL |
| Entity matching | TECH READY / EARLY |
| Autonomní provoz | NEPROKÁZÁN GLOBÁLNĚ |

Historické označení „kompletní autonomní MEDIA pipeline“ znamenalo první funkční verzi pro podporovaný rozsah, nikoli úplnou multisport MEDIA platformu.

**Zdroje:** `MM-HIS-0003`, `MM-HIS-0278`.

---

## 4.3 13. května – alias-first entity matching a trending

Byl doložen alias-first matcher s konkrétními výsledky:

```text
TEAM ALIASES INSERTED   : 2 770
PLAYER ALIASES INSERTED : 18 315
```

Potvrzeny byly příklady napojení:

- týmů,
- hráčů,
- lig.

Vznikly nebo byly potvrzeny výstupy:

```text
public.media_trending_players
public.media_trending_teams
public.media_trending_leagues
```

Tento krok byl důležitý, protože MEDIA vrstva přestávala být izolovaným úložištěm článků a začala se napojovat na canonical sportovní entity.

### Hodnocení

| Oblast | Stav |
|---|---|
| Alias-first matching | RUNTIME TESTED |
| Team/player alias coverage | VYSOKÁ PRO TEHDEJŠÍ KORPUS |
| Globální entity matching | PARTIAL |
| Trending struktury | IMPLEMENTED |

**Zdroj:** `MM-HIS-0004`.

---

## 4.4 14. května – runtime ověření MEDIA zdrojů

Pro vybrané zdroje byly uvedeny konkrétní výsledky:

| Zdroj | Nalezené URL | Vložené záznamy | Stav |
|---|---:|---:|---|
| NHL | 64 | 0 | bez vložení v uvedeném kroku |
| NBA | 36 | 0 | bez vložení v uvedeném kroku |
| La Liga | 26 | 26 | OK |
| Bundesliga | 14 | 14 | OK |
| Ligue 1 | 0 | 0 | 404 ERROR |

Do `public.articles` bylo sloučeno:

```text
47 článků
```

Během změny `staging.stg_media_articles` vznikl PostgreSQL lock. Historický záznam popisuje:

- identifikaci blokace,
- odstranění locku,
- opětovné spuštění `ALTER TABLE`,
- pokračování merge.

Otevřeným problémem zůstalo ukládání thumbnails do public vrstvy.

### Hodnocení

| Oblast | Stav |
|---|---|
| MEDIA source pull | RUNTIME TESTED / PARTIAL |
| Public merge | RUNTIME TESTED |
| Source coverage | NEROVNOMĚRNÁ |
| Thumbnail flow | OPEN |

**Zdroj:** `MM-HIS-0005`.

---

## 4.5 15. května – article-to-entity vazby a feedy

Byly doloženy workery a view:

```text
match_article_leagues_v1.py
match_article_teams_v1.py
public.v_media_feed_by_team
public.v_media_feed_by_league
public.media_trending_teams
public.media_trending_leagues
public.v_media_trending_teams
public.v_media_trending_leagues
```

Historické počty:

```text
NHL články              : 127
NBA články              : 97
La Liga články          : 23
Bundesliga články       : 14
article-team vazby      : 179
```

Byl odhalen season-format problém API-Sport pro basketball league 12:

```text
season=2024       → 0 výsledků
season=2023-2024  → správný formát
```

### Hodnocení

| Oblast | Stav |
|---|---|
| Article-team matching | RUNTIME TESTED / PARTIAL |
| Article-league matching | IMPLEMENTED / PARTIAL |
| Team/league feed | IMPLEMENTED |
| Trending output | IMPLEMENTED / PARTIAL |
| Produkční coverage | NEÚPLNÁ |

**Zdroj:** `MM-HIS-0006`.

---

## 4.6 17.–18. května – discovery, video feedy a AI podpůrné struktury

Do architektury byly přidány nebo popsány:

```text
v_video_feed_v2
v_video_feed_by_team
v_video_feed_by_player
v_video_feed_by_league
public.media_content_sections
ops.media_source_discovery_candidates
public.v_media_source_discovery_review
public.v_media_sources_ready_for_ingest
ops.media_discovery_requests
public.ai_entity_summaries
public.ai_translations
```

Tyto dokumenty dokazují především technický a architektonický základ. Neobsahují dostatek runtime výsledků pro tvrzení o plně provozní discovery nebo AI vrstvě.

### Hodnocení

| Oblast | Stav |
|---|---|
| Video feed struktury | TECH READY |
| Source discovery | TECH READY / PARTIAL |
| Approval workflow | TECH READY |
| AI summaries/translations | IMPLEMENTED FOUNDATION |
| Webová integrace | PLANNED / NEOVĚŘENÁ |

**Zdroje:** `MM-HIS-0007`, `MM-HIS-0008`.

---

## 4.7 19. května – live feed a komunitní architektura

Byly uvedeny objekty:

```text
public.v_live_match_feed
public.v_live_match_feed_v2
public.community_competitions
public.community_teams
public.community_matches
public.community_match_results
ops.community_approval_queue
```

Dokument dále popisuje:

- sport display engine,
- player/team image resolver,
- LIVE NOW feed,
- komunitní soutěže,
- budoucí prediction strategii.

Označení „frontend-ready“ a „CDN-ready“ je nutné chápat jako technickou připravenost datové vrstvy, nikoli jako potvrzené dokončené nasazení do produkčního webu.

### Hodnocení

| Oblast | Stav |
|---|---|
| Live feed view | IMPLEMENTED / TECH READY |
| Community schema | IMPLEMENTED FOUNDATION |
| Frontend | NEPROKÁZÁN |
| CDN provoz | NEPROKÁZÁN |

**Zdroj:** `MM-HIS-0009`.

---

## 4.8 20. května – PEOPLE audit, quality workflow a provider reality

PEOPLE vrstva získala nebo potvrdila:

```text
public.player_season_statistics
public.v_player_statistics_feed
public.v_people_stats_quality_audit
ops.people_quality_backfill_queue
run_people_quality_backfill_v1.py
```

Historický PEOPLE master audit uváděl:

```text
canonical players        : 18 959
staging rows             : 105 834
mapped rows              : 105 834
unmapped rows            : 0
```

Zásadní omezení:

> 105 834 mapovaných staging rows nebyly hotové sezonní statistiky.

Šlo o úspěšné mapování zdrojových řádků, nikoli o dokončený validovaný season-statistics dataset.

Provider strategie byla zpracována ve dvou souvisejících dokumentech:

- `MM-HIS-0283` – primární priority reference,
- `MM-HIS-0284` – rozšířená reality matrix.

Tyto dokumenty se částečně překrývají a tvoří jeden strategický milník.

Podpůrný checklist `MM-HIS-0273` potvrzuje existenci části schématu, ale současně uvádí nehotové oblasti:

- player profiles,
- player media links,
- translations,
- další multisport provider toky.

### Hodnocení

| Oblast | Stav |
|---|---|
| PEOPLE schema | IMPLEMENTED |
| Quality audit | IMPLEMENTED |
| Backfill queue | IMPLEMENTED / PARTIAL |
| Provider mapping | STRONG FOUNDATION |
| Season statistics | PARTIAL |
| Profiles a media | PARTIAL / DATA GAP |
| Multisport PEOPLE coverage | PARTIAL |

**Zdroje:** `MM-HIS-0010`, `MM-HIS-0282`, `MM-HIS-0283`, `MM-HIS-0284`, `MM-HIS-0273`.

---

## 4.9 21.–22. května – FB player match statistics a team power

Pro fotbal vznikl konkrétní queue/pull/parse tok:

```text
104_S_build_fb_player_match_stats_queue_v1.py
104_W_pull_fb_player_match_stats_from_queue_v2.py
104_U_parse_fb_player_match_stats_queue_payloads_v1.py
```

Tok využíval:

```text
ops.fixture_player_stats_queue
staging.stg_api_payloads
public.matches
public.team_provider_map
public.player_match_statistics
```

Bylo řešeno:

- schema mismatch ve staging payloadu,
- HTTP 429 rate limiting,
- retry a čekání,
- fixture a team identity,
- parse status.

Historický záznam potvrzuje, že testovaný tok po opravách nepadal trvale do 429 a dokázal zpracovat queue položky.

Fotbalový audit dále uváděl:

```text
FB matches v public.matches : 107 129
FB finished matches         : 105 971
FB canonical players        : 2 725
FB player provider maps     : 2 726
```

Byla vytvořena view pro:

```text
team player form
team results form
FB team power
```

Dokument sám správně rozlišuje:

```text
ARCHITECTURE READY
DATA COVERAGE NOT READY
```

### Datový konflikt

`MM-HIS-0012` je v manifestu přiřazen k 21. květnu, ale vnitřní datum dokumentu uvádí 22. května. V tomto snapshotu je milník uváděn jako období 21.–22. května.

### Hodnocení

| Oblast | Stav |
|---|---|
| FB player-match-stats queue | RUNTIME TESTED |
| Pull a 429 handling | RUNTIME TESTED / PARTIAL |
| Parser a mapping | RUNTIME TESTED / PARTIAL |
| Team power views | TECH READY |
| AI-ready základ | FOUNDATION READY |
| Datové pokrytí | PARTIAL |

**Zdroje:** `MM-HIS-0011`, `MM-HIS-0012`.

---

## 4.10 23. května – basketball unified flow

Basketbalové parsery byly převedeny do Pythonu:

```text
105_V_parse_api_sport_bk_fixtures_to_staging_v1.py
105_W_parse_api_sport_bk_leagues_to_staging_v1.py
105_X_parse_api_sport_bk_teams_to_staging_v1.py
105_Y_parse_api_sport_bk_players_to_staging_v1.py
```

Doložené runtime výsledky:

```text
BK FINISHED matches           : 330
BK SCHEDULED matches          : 784
fixtures affected rows        : 1 572
leagues affected rows         : 427
teams affected rows           : 72
players affected rows         : 22
```

Po unified merge byl uveden stav:

```text
public.matches : 123 534
public.players : 18 995
public.teams   : 7 620
```

### Hodnocení

| Oblast | Stav |
|---|---|
| BK fixtures parser | RUNTIME TESTED |
| BK leagues parser | RUNTIME TESTED |
| BK teams parser | RUNTIME TESTED |
| BK players parser | RUNTIME TESTED / VERY LIMITED COVERAGE |
| Unified merge | RUNTIME TESTED |
| Kompletní BK coverage | NEPROKÁZÁNA |

Historické tvrzení „kompletní BK unified flow“ znamená dokončený ingest/parse/merge vzor pro tehdy dostupná data, nikoli kompletní basketbalovou databázi.

**Zdroj:** `MM-HIS-0013`.

---

## 4.11 25. května – orchestrace, dependency logika a planner jobs

Byly vytvořeny nebo potvrzeny orchestration objekty:

```text
ops.v_provider_routing_master_v2
ops.v_automation_execution_queue_v2
ops.v_automation_ready_queue_v4
ops.v_execution_priority_queue_v1
ops.v_scheduler_candidates_v1
ops.v_implementation_readiness_v2
ops.worker_dependency_graph
ops.v_dependency_resolver_v1
ops.v_dependency_aware_execution_queue_v1
ops.v_orchestration_priority_queue_v1
ops.v_orchestration_priority_queue_v2
ops.v_orchestration_priority_queue_v3
ops.v_planner_pending_guard_v1
ops.v_planner_pending_guard_v2
```

Doložen byl běh:

```text
run_ingest_cycle_v3.py
```

a testovaný end-to-end průchod orchestrace v omezeném rozsahu.

Rozšířený související dokument uváděl:

```text
planner jobs   : 10
public.matches : 123 540
public.teams   : 8 514
public.players : 18 995
```

Rozdíl v počtu týmů oproti 23. květnu není bez samostatného DB auditu vysvětlen.

### Hodnocení

| Oblast | Stav |
|---|---|
| Provider routing | IMPLEMENTED |
| Ready a priority queue | IMPLEMENTED |
| Dependency graph | IMPLEMENTED |
| Planner pending guard | IMPLEMENTED |
| Testovaný orchestration běh | RUNTIME TESTED / PARTIAL |
| Globální autonomie | NEPROKÁZÁNA |

**Zdroje:** `MM-HIS-0014`, `MM-HIS-0275`.

---

## 4.12 26. května – operations center a roadmapa

Operations-center vrstva zahrnovala:

```text
ops.v_active_runs_live_v1
ops.v_active_runs_summary_v1
ops.v_planner_queue_summary_v1
ops.v_scheduler_queue_summary_v1
ops.v_recent_failures_v1
ops.v_runtime_alerts_v1
ops.v_runtime_operations_center_feed_v1
ops.v_runtime_alerts_grouped_v1
ops.v_operations_center_summary_v1
```

Uvedený historický stav:

```text
pending_jobs     : 5 152
avg_confidence   : 90.73
scheduler_state  : READY
```

Ve zdroji se objevuje označení:

```text
READY + SAFE_AUTONOMOUS
```

Bezpečná interpretace:

> Operations scoring označil konkrétní scheduler stav jako připravený, ale historický korpus neprokazuje dlouhodobě bezpečný autonomní provoz celé platformy.

Důvody:

- stále existovala velká pending fronta,
- byly evidovány failed a warning workery,
- coverage nebyla úplná,
- některé entity a sporty zůstávaly blokované nebo částečné.

Souběžná roadmapa definovala dlouhodobý směr:

- multi-provider platforma,
- PC2 harvest server,
- rozsáhlý panel,
- AI a analytické vrstvy,
- web a produktová integrace,
- pevnější standard práce a dokumentace.

Roadmapa není důkazem realizace všech uvedených cílů.

**Zdroje:** `MM-HIS-0280`, `MM-HIS-0279`.

---

# 5. DATABASE SNAPSHOT

## 5.1 Doložené historické počty

Níže uvedené hodnoty pocházejí z různých historických dní a různých auditních kontextů. Nejde o jeden konzistentní databázový export k 31. květnu.

| Datum / zdroj | Objekt | Hodnota | Poznámka |
|---|---|---:|---|
| 2026-05-13 | team aliases | 2 770 | MEDIA alias-first matcher |
| 2026-05-13 | player aliases | 18 315 | MEDIA alias-first matcher |
| 2026-05-14 | merged articles | 47 | uvedený FB/media merge |
| 2026-05-15 | NHL articles | 127 | MEDIA audit |
| 2026-05-15 | NBA articles | 97 | MEDIA audit |
| 2026-05-15 | article-team relations | 179 | MEDIA entity layer |
| 2026-05-20 | canonical players | 18 959 | PEOPLE master audit |
| 2026-05-20 | staging PEOPLE rows | 105 834 | nejsou hotové season statistics |
| 2026-05-20 | mapped PEOPLE rows | 105 834 | 0 unmapped v uvedeném auditu |
| 2026-05-21/22 | FB matches | 107 129 | fotbalový audit |
| 2026-05-21/22 | FB finished matches | 105 971 | fotbalový audit |
| 2026-05-21/22 | FB canonical players | 2 725 | fotbalový audit |
| 2026-05-23 | BK finished matches | 330 | basketball status |
| 2026-05-23 | BK scheduled matches | 784 | basketball status |
| 2026-05-23 | public.matches | 123 534 | po unified merge |
| 2026-05-23 | public.players | 18 995 | po unified merge |
| 2026-05-23 | public.teams | 7 620 | po unified merge |
| 2026-05-25 | planner jobs | 10 | orchestration milestone |
| 2026-05-25 | public.matches | 123 540 | orchestration zápis |
| 2026-05-25 | public.players | 18 995 | orchestration zápis |
| 2026-05-25 | public.teams | 8 514 | odlišné od 23. 5. |
| 2026-05-26 | pending jobs | 5 152 | operations center |
| 2026-05-26 | average confidence | 90.73 | operations scoring |

## 5.2 Pravidla interpretace počtů

- Hodnoty se nesmějí mechanicky sčítat.
- Počet může být provider-specific, sport-specific nebo globální.
- Počty z různých dnů se mohou lišit kvůli novému importu, merge, filtru nebo opravě.
- `mapped rows` není totéž co validovaný finální dataset.
- `pending_jobs` není počet chyb; je to velikost čekající fronty v daném pohledu.
- `avg_confidence` je historický výstup konkrétního scoringu a není univerzální metrikou kvality platformy.

---

# 6. CURRENT STATUS K POSLEDNÍMU DOLOŽENÉMU DNI

## 6.1 Stav hlavních oblastí

| Oblast | Rekonstruovaný stav | Doložené části | Omezení |
|---|---|---|---|
| CORE | PARTIAL / STRONG FOUNDATION | FB rozsáhlá match základna, BK unified flow | Neúplné multisport a historické pokrytí |
| PEOPLE | PARTIAL / ARCHITECTURE READY | Schema, mapy, quality audit, backfill, FB match stats | Profily, season stats, fotky a multisport coverage |
| MEDIA | PARTIAL / RUNTIME TESTED | Pull, parse, merge, entity vazby, feedy, trending | Source chyby, thumbnails, coverage a parser kvalita |
| ODDS | PARTIAL / LIMITED | Architektonická návaznost a dílčí merge reference | Bez důkazu úplného market a provider coverage |
| HARVEST | PARTIAL / RUNTIME TESTED | Queue, planner, parsery, unified merge | Ne všechny sporty a entity měly funkční worker |
| ORCHESTRATION | PARTIAL / RUNTIME TESTED | Routing, priority, dependency, scheduler view | Globální autonomie nebyla prokázána |
| GOVERNANCE | PARTIAL / IMPLEMENTED | DB jako zdroj pravdy, multi-provider pravidla, readiness view | Některá pravidla byla ještě rozpracovaná |
| PANEL / UI | PARTIAL / TECH READY | Control Panel a operations-center feed | Dokončený uživatelský frontend nebyl doložen |
| AI / ANALYTICS | PARTIAL / FOUNDATION READY | Team power, trending, summaries a translations struktury | Nešlo o hotový AI produkt |
| TICKET ENGINE | PLANNED / EARLY FOUNDATION | Strategická návaznost na data a budoucí produkt | Bez květnového důkazu kompletního runtime engine |
| INFRASTRUCTURE | PLANNED / PARTIAL | PC2 a deployment roadmapa | Realizace nebyla v květnovém korpusu potvrzena |

## 6.2 Co bylo skutečně připravené

K poslednímu doloženému květnovému stavu bylo možné bezpečně tvrdit:

- MEDIA ingest/merge fungoval pro vybrané zdroje,
- alias-first entity matching byl provozně použit,
- vybrané article-team a article-league vazby existovaly,
- PEOPLE schema a quality workflow byly vytvořeny,
- FB player-match-stats tok prošel konkrétním testem,
- BK ingest/parse/merge tok prošel konkrétním testem,
- orchestration a dependency vrstvy existovaly,
- operations-center view poskytovaly přehled o bězích, frontě a problémech,
- multi-provider architektura byla potvrzena jako cílové pravidlo.

## 6.3 Co nebylo bezpečné tvrdit

Nebylo bezpečné tvrdit, že:

- platforma byla kompletně autonomní,
- všechny sporty měly stejné coverage,
- PEOPLE statistiky byly kompletní,
- MEDIA pokrývala všechny ligy a entity,
- AI vrstva byla hotový produkt,
- Ticket Engine byl v květnu dokončen,
- web a frontend byly produkčně nasazeny,
- `READY` v operations view znamenalo nulové riziko,
- databázové počty představovaly jednotný snapshot k 31. květnu.

---

# 7. ARCHITEKTONICKÁ A GOVERNANCE ROZHODNUTÍ

## 7.1 Databáze je nadřazený zdroj pravdy

Textový zápis nesmí přebít aktuální databázovou realitu. Dokumentace zachycuje historický kontext, rozhodnutí a důkazy, ale provozní stav musí být auditován v DB a runtime prostředí.

**Zdroj:** `MM-HIS-0278`.

## 7.2 Multi-provider podle entity

Projekt nesmí být závislý na jednom providerovi. Provider se má vybírat podle:

- sportu,
- entity,
- coverage,
- kvality,
- ceny,
- tarifu,
- runtime zdraví.

**Zdroje:** `MM-HIS-0278`, `MM-HIS-0283`, `MM-HIS-0284`, `MM-HIS-0013`, `MM-HIS-0279`.

## 7.3 Architektura, runtime a coverage jsou rozdílné stavy

Bylo potvrzeno zásadní pravidlo:

```text
ARCHITECTURE READY
≠
RUNTIME TESTED
≠
DATA COVERAGE READY
```

Toto rozlišení je klíčové pro People Layer, MEDIA, AI i orchestration.

**Zdroje:** `MM-HIS-0282`, `MM-HIS-0012`, `MM-HIS-0273`.

## 7.4 Automatizace musí být auditovatelná

Queue, planner, dependency graph, priority, pending guard, failures a operations center mají umožnit:

- zjistit, co běží,
- zjistit, co čeká,
- zjistit, proč tok selhal,
- určit další bezpečný krok,
- oddělit připravenost od skutečného výsledku.

**Zdroje:** `MM-HIS-0014`, `MM-HIS-0275`, `MM-HIS-0280`.

## 7.5 Uživatel zůstává konečným rozhodovatelem

AI a automatizace mají poskytovat:

- analýzu,
- doporučení,
- prioritu,
- návrh dalšího kroku,
- provozní podporu.

Konečné rozhodnutí má zůstat pod uživatelskou kontrolou.

**Zdroj:** `MM-HIS-0279`.

---

# 8. NORMALIZACE ŠIROKÝCH TVRZENÍ

| Historické tvrzení | Bezpečná interpretace |
|---|---|
| Kompletní autonomní MEDIA pipeline | První funkční MEDIA pipeline pro vybrané zdroje a entity |
| Plně funkční MEDIA vrstva | Implementovaný a částečně testovaný matching, feed a trending |
| Production-ready MEDIA layer | Použitelná v omezeném testovaném rozsahu |
| FB pipeline funguje end-to-end | Konkrétní queue/pull/parse tok prošel end-to-end testem |
| AI-ready platform | Existovaly datové a analytické základy pro budoucí AI |
| Kompletní BK unified flow | BK ingest/parse/merge vzor fungoval pro dostupná data |
| Production-ready core | Silný core základ pro vybrané sporty, nikoli kompletní platforma |
| READY + SAFE_AUTONOMOUS | Konkrétní scoring označil scheduler stav jako připravený; globální autonomie nebyla doložena |

---

# 9. OPEN QUESTIONS

## 9.1 MEDIA

- Proč část NHL a NBA zdrojů našla URL, ale nevložila záznamy?
- Jak vyřešit thumbnails v public vrstvě?
- Jak sjednotit source-specific parsery?
- Jak ověřovat licence, robots.txt a povolený způsob použití zdrojů?
- Jak zvýšit article-player a article-match coverage?
- Jak převést discovery kandidáty do řízeného approval a ingest workflow?

## 9.2 PEOPLE

- Který provider bude primární pro každý sport a typ statistik?
- Které staging rows představují skutečné season stats a které pouze raw mapping?
- Jak doplnit profily, fotografie, pozice, týmový kontext a historii?
- Jak rozšířit player-match-stats tok mimo football?
- Jak přidat trenéry a historické vazby?
- Jak bezpečně řídit paid provider aktivaci?

## 9.3 CORE

- Jak rozšířit unified flow na další sporty?
- Jak doplnit historical coverage?
- Jak řešit rozdílné season formáty?
- Jak vysvětlit rozdílné historické DB počty?
- Jak oddělit provider-specific a canonical počty v každém auditu?

## 9.4 Orchestrace a provoz

- Jak snížit pending frontu 5 152 položek?
- Které workery byly failed nebo warning?
- Jak zavést safe retry, backoff, rate-limit a lock handling?
- Jak potvrdit autonomní provoz na více sportech a entitách?
- Jak propojit operations-center feed s praktickým akčním panelem?

## 9.5 ODDS, AI a Ticket Engine

- Jak rozšířit odds coverage podle sportu a marketu?
- Které analytické vrstvy jsou skutečně runtime validované?
- Kdy bude dostatečná kvalita dat pro Ticket Engine?
- Jak oddělit modelovou predikci, doporučení a uživatelské rozhodnutí?
- Jak evidovat kvalitu, confidence a zpětnou vazbu bez nadsazeného označení „self-learning“?

---

# 10. NEXT STEP

Následující období mělo navázat těmito prioritami:

1. **People Layer**
   - audit providerů,
   - doplnění player match a season stats,
   - profiles, photos, teams a positions,
   - trenéři a historie.

2. **Multisport CORE**
   - rozšíření unified flow,
   - skutečné runtime ověření dalších sportů,
   - řešení provider a season rozdílů.

3. **Harvest a orchestrace**
   - stabilizace planner queue,
   - dependency-aware execution,
   - retry a error recovery,
   - operations-center akční workflow.

4. **MEDIA**
   - zlepšení parserů,
   - rozšíření zdrojů,
   - entity coverage,
   - discovery a approval.

5. **Governance**
   - oddělení READY / PARTIAL / BLOCKED / DATA GAP,
   - provider-by-entity strategie,
   - auditovatelný zdroj pravdy,
   - přesnější historická dokumentace.

6. **Infrastruktura**
   - příprava PC2 jako hlavního harvest a databázového serveru,
   - PC1 jako řídicího pracoviště,
   - budoucí autonomní dlouhodobé sklizně.

---

# 11. HLAVNÍ MILNÍKY PRO NAVAZUJÍCÍ DOKUMENTACI

| Milník | Stav | Hlavní zdroje |
|---|---|---|
| První ucelená MEDIA pipeline | RUNTIME TESTED / PARTIAL | `MM-HIS-0003`, `MM-HIS-0005` |
| Alias-first entity matching | RUNTIME TESTED | `MM-HIS-0004` |
| Article-team a article-league vazby | RUNTIME TESTED / PARTIAL | `MM-HIS-0006` |
| Source discovery a approval základ | TECH READY | `MM-HIS-0007`, `MM-HIS-0008` |
| Live feed a community schema | TECH READY | `MM-HIS-0009` |
| PEOPLE quality workflow | IMPLEMENTED / PARTIAL | `MM-HIS-0010`, `MM-HIS-0282` |
| Provider reality matrix | STRATEGIC / REVIEWED | `MM-HIS-0283`, `MM-HIS-0284` |
| FB player match stats tok | RUNTIME TESTED / PARTIAL | `MM-HIS-0011`, `MM-HIS-0012` |
| Basketball unified flow | RUNTIME TESTED / PARTIAL | `MM-HIS-0013` |
| Dependency-aware orchestration | RUNTIME TESTED / PARTIAL | `MM-HIS-0014`, `MM-HIS-0275` |
| Operations center | IMPLEMENTED / PARTIAL | `MM-HIS-0280` |
| Multi-provider roadmapa | STRATEGIC DESIGN | `MM-HIS-0278`, `MM-HIS-0279` |

---

# 12. ZÁVĚR CHECKPOINTU

Květen 2026 byl měsícem, ve kterém se MatchMatrix začal měnit z kolekce samostatných datových větví na propojenou platformu s:

- canonical identitou,
- MEDIA entity matching,
- PEOPLE quality governance,
- sjednocenými sportovními parsery,
- queue a dependency orchestration,
- runtime monitoringem,
- multi-provider strategií.

Největší dosaženou hodnotou nebyla úplnost dat, ale vznik opakovatelných technických vzorů:

```text
provider
→ pull
→ raw / staging
→ parse
→ canonical mapping
→ public merge
→ audit
→ readiness
→ operations
```

Pro vybrané toky existovaly konkrétní runtime důkazy:

- MEDIA pull a merge,
- alias-first matching,
- article-team vazby,
- FB player-match-stats queue/pull/parse,
- BK unified merge,
- testovaná orchestrace.

Současně zůstával projekt celkově ve stavu **PARTIAL**:

- sportovní coverage nebyla rovnoměrná,
- PEOPLE statistiky nebyly úplné,
- MEDIA zdroje měly chyby a mezery,
- odds coverage nebyla doložena jako kompletní,
- AI byla především datovým základem,
- globální safe autonomous provoz nebyl prokázán.

Nejdůležitější governance závěr května:

> V MatchMatrix musí být vždy odděleno, zda architektura existuje, zda tok skutečně proběhl a zda jsou data dostatečně úplná pro produktové použití.

Toto rozlišení vytvářelo základ pro červnové audity, rozšiřování People Layer, Source Intelligence, PC2 harvest infrastrukturu a přesnější dokumentační governance.

---

# 13. ZDROJOVÝ REGISTR

| Document ID | Datum / klasifikace | Role |
|---|---|---|
| MM-HIS-0003 | 2026-05-11 | MEDIA pipeline milestone |
| MM-HIS-0278 | 2026-05-11 | Master návazání a governance |
| MM-HIS-0004 | 2026-05-13 | Alias matching a trending |
| MM-HIS-0005 | 2026-05-14 | MEDIA source runtime a merge |
| MM-HIS-0006 | 2026-05-15 | Article entity matching a feedy |
| MM-HIS-0007 | 2026-05-17 | Video a source discovery |
| MM-HIS-0008 | 2026-05-18 | AI/content foundation a vize |
| MM-HIS-0009 | 2026-05-19 | Live feed a community schema |
| MM-HIS-0010 | 2026-05-20 | PEOPLE quality audit a backfill |
| MM-HIS-0282 | 2026-05-20 | PEOPLE master audit |
| MM-HIS-0283 | 2026-05-20 | Provider priority primary reference |
| MM-HIS-0284 | 2026-05-20 | Provider reality expanded variant |
| MM-HIS-0011 | 2026-05-21 | FB player match stats runtime tok |
| MM-HIS-0012 | manifest 2026-05-21 / obsah 2026-05-22 | FB team power a AI readiness |
| MM-HIS-0013 | 2026-05-23 | BK unified flow |
| MM-HIS-0014 | 2026-05-25 | V17 orchestration milestone |
| MM-HIS-0275 | inferred 2026-05-25 | Rozšíření orchestration evidence |
| MM-HIS-0279 | 2026-05-26 | Hlavní vize a roadmapa |
| MM-HIS-0280 | 2026-05-26 | Operations center |
| MM-HIS-0273 | květen 2026, bez dne | PEOPLE podpůrný checklist |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-08 | REVIEW | První rekonstruovaná verze květnového Project Snapshotu z kompletního klasifikovaného korpusu a working reportu v2 reviewed |

---

## Kontrolní stav před schválením

- [x] Kompletní květnový klasifikovaný korpus: 20 dokumentů
- [x] SHA kontrola zdrojů bez varování
- [x] Přesně datované a MONTH_ONLY dokumenty odděleny
- [x] Překryvy a expanded varianty identifikovány
- [x] Široká tvrzení normalizována
- [x] AI CONTEXT doplněn
- [x] PROJECT SNAPSHOT doplněn
- [x] DATABASE SNAPSHOT doplněn
- [x] CURRENT STATUS doplněn
- [x] OPEN QUESTIONS doplněny
- [x] NEXT STEP doplněn
- [ ] Automatický dokumentový audit A17
- [ ] Uživatelské schválení
- [ ] Změna stavu na ACTIVE
- [ ] Git commit
- [ ] Import do dokumentační databáze
