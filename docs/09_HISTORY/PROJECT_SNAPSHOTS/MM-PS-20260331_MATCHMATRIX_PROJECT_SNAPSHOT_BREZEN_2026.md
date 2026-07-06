# MM-PS-20260331

# MATCHMATRIX PROJECT SNAPSHOT – BŘEZEN 2026

## HISTORICKÝ PROJEKTOVÝ CHECKPOINT

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PS-20260331 |
| Název | MatchMatrix Project Snapshot – březen 2026 |
| Typ | Project Snapshot / historický projektový checkpoint |
| Edice | MM-DOC TECH |
| Verze | 1.0 |
| Stav | ACTIVE |
| Datum snapshotu | 2026-03-31 |
| Rekonstruované období | 2026-03-01 až 2026-03-31 |
| Předchozí checkpoint | MM-PS-20260223 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Doporučené umístění | `docs/09_HISTORY/PROJECT_SNAPSHOTS/MM-PS-20260331_MATCHMATRIX_PROJECT_SNAPSHOT_BREZEN_2026.md` |
| Zdroj pravdy | Databázový historický korpus MatchMatrix |
| Hlavní zdrojové dokumenty | MM-HIS-0044, MM-HIS-0045, MM-HIS-0053–0061, MM-HIS-0066, MM-HIS-0069, MM-HIS-0072–0077, MM-HIS-0081, MM-HIS-0085–0098, MM-HIS-0100–0124, MM-HIS-0126, MM-HIS-0143–0203, MM-HIS-0209, MM-HIS-0212–0224 |

---

## Upozornění k použití

Tento dokument je **historický projektový checkpoint**. Popisuje stav, rozhodnutí, implementované části, rozpracované oblasti a produktovou vizi projektu MatchMatrix v průběhu března 2026.

Nejde o popis současného produkčního stavu platformy. Názvy skriptů, tabulek, adresářů, providerů, počty záznamů, limity API, verze panelů a provozní postupy uvedené v dokumentu musí být před dnešním použitím porovnány s aktuální architekturou, databází a dokumentací.

Historické zdroje často používají formulace jako „hotovo“, „plně funkční“ nebo „production ready“ pro dílčí větev, testovací rozsah nebo konkrétní sport. Tento checkpoint proto důsledně rozlišuje:

1. **prokazatelně implementované a ověřené části,**
2. **technicky nebo databázově připravené části,**
3. **produktové návrhy a dlouhodobou vizi,**
4. **tvrzení, která byla později upřesněna nebo opravena.**

Dokument nesmí být použit jako náhrada aktuálního Project Snapshotu. Slouží jako časově ukotvený důkaz vývoje projektu a jako zdroj pro aktualizaci hlavních dokumentů MatchMatrix.

---

# 1. Účel checkpointu

Cílem dokumentu je rekonstruovat vývoj MatchMatrix za březen 2026 a zachytit období, ve kterém se projekt posunul:

- od jednotlivých ingest skriptů k planner-driven orchestrace,
- od sportově specifických staging větví k unified staging modelu,
- od football-first řešení k reálně testované multisport pipeline,
- od základních hráčských importů k první funkční People Layer pro football,
- od analytického backendu k první produktové podobě Ticket Studia,
- od dočasného generování tiketů k ukládání, historii a settlement vrstvě,
- od klikacího panelu k provoznímu dashboardu a připravovanému harvest režimu.

Checkpoint současně vymezuje, co na konci března ještě nebylo dokončeno.

---

# 2. Metodika rekonstrukce

## 2.1 Použité zdroje

Rekonstrukce vychází z:

- denních a pracovních zápisů,
- navazovacích dokumentů,
- SQL checklistů a migrací,
- databázových exportů,
- konzolových logů workerů,
- architektonických souhrnů,
- auditních dokumentů z 31. března,
- produktových návrhů Ticket Studia.

## 2.2 Klasifikace důkazů

Informace byly rozděleny do těchto úrovní:

| Úroveň | Význam |
|---|---|
| IMPLEMENTED / RUNTIME TESTED | Existuje konkrétní skript, tabulka nebo běh a zdroj uvádí reálný výsledek |
| TECH READY | Schéma, job, view, adapter nebo plán existuje, ale není potvrzen plný runtime běh |
| PARTIAL / TRANSITIONAL | Funguje jen část toku, omezený rozsah nebo přechodová větev |
| PROPOSED / PRODUCT VISION | Návrh budoucí funkce, architektury nebo obchodního modelu |
| BLOCKED | Blokace providerem, tarifem, endpointem, mapováním nebo chybějícím workerem |

## 2.3 Pravidla chronologie

- Vnitřní datum dokumentu má přednost před datem poslední změny souboru.
- `source_modified_at` slouží pouze jako vyhledávací pomůcka.
- Dokument změněný později nesmí být automaticky přiřazen k pozdějšímu dni, pokud obsah uvádí jiné datum.
- Datový export bez sémantického data se používá jako podpůrný důkaz, nikoli jako samostatný milník.

## 2.4 Známé duplicity a návaznosti zdrojů

- MM-HIS-0054 rozšiřuje nebo nahrazuje MM-HIS-0053.
- MM-HIS-0058 a MM-HIS-0059 jsou obsahově duplicitní.
- MM-HIS-0102 má datum změny 11. března, ale obsahově patří k 10. březnu.
- MM-HIS-0111 má datum změny 15. března, ale obsahově popisuje 14. březen.
- MM-HIS-0188 a MM-HIS-0189 zachycují stejnou Volleyball etapu; druhý dokument obsahuje doplněné potvrzení.
- MM-HIS-0224 je rozšířená a přesnější verze MM-HIS-0223.
- MM-HIS-0210 byl změněn 2. dubna a slouží pouze jako hraniční podpůrný audit, nikoli jako automatický březnový milník.

---

# 3. AI CONTEXT

MatchMatrix byl v březnu 2026 budován jako globální sportovní datová, analytická a tiketová platforma.

Projekt měl tři současně rozvíjené osy:

1. **Data Core** – sporty, soutěže, sezony, týmy, zápasy, hráči, trenéři, kurzy a statistiky.
2. **Analytics Core** – ratingy, features, predikce, standings a value analýza.
3. **Product Core** – Ticket Engine, Ticket Studio, historie tiketů, settlement a budoucí learning loop.

Strategický směr na konci měsíce byl:

> MatchMatrix nemá být bookmaker. Má být globální sportovní databáze, analytický a poradní systém a inteligentní asistent pro tvorbu tiketů.

Březen byl především měsícem infrastruktury a integrace. Projekt dosáhl prvních skutečných end-to-end toků, ale současně odhalil, že označení „multisport ready“ musí být rozděleno na databázovou připravenost, technickou připravenost, runtime ověření a produkční použitelnost.

---

# 4. PROJECT SNAPSHOT

## 4.1 Stav na začátku března

Na začátku měsíce již existovalo:

- canonical jádro lig, týmů a zápasů,
- multi-provider mapování lig a týmů,
- autonomní fixtures ingest pro football,
- audit běhů v `ops.job_runs`,
- základ Ticket Engine s bloky, fixními výběry a variantami,
- analytická vrstva s MMR, features a predikcemi.

Zároveň ještě nebyla dokončena jednotná multisport orchestrace a velká část produktových a webových prvků byla pouze návrhem.

## 4.2 1.–3. března – canonical identity a produktová definice

Hlavní posuny:

- potvrzení multi-provider mapování lig a týmů,
- stabilizace canonical identity,
- autonomní fixtures ingest,
- odstranění duplicit v `ops.ingest_targets`,
- formulace TicketMatrix jako produktu s fixními zápasy, bloky a maximálně 27 variantami,
- definice pravděpodobnosti, EV a rizika tiketů.

Technologie typu Next.js 14, Drizzle, ShadCN, Vercel a Render/Railway byly v této etapě návrhem nebo historickým experimentem, nikoli trvalým potvrzeným cílovým stackem.

## 4.3 4.–6. března – unified staging a první People schema

Bylo potvrzeno:

- backfill API-Football 2024 do `public.matches`,
- oprava merge podle `run_id`,
- dočasné zakládání placeholder týmů při chybějícím mapování,
- formování toku provider → staging → merge → canonical,
- příprava People Layer schématu a workerů.

Player import byl 6. března omezen nebo blokován tarifem. Připravené schéma tedy ještě neznamenalo naplněnou People Layer.

## 4.4 7.–10. března – první hráči, predikce a unified staging bridge

Dne 7. března proběhlo první reálné naplnění hráčské vrstvy:

- ingest API-Football players,
- staging zpracování,
- přibližně 475 hráčů v `public.players`.

Dne 8. března byla prokazatelně provozní prediction pipeline:

- desítky tisíc týmových a match ratingů,
- desítky tisíc feature řádků,
- více než tisíc budoucích predikcí,
- rozhodnutí používat běžný horizont 14 dnů a dlouhý horizont jen testovat.

Dne 10. března nastal kritický architektonický přechod k unified staging tabulkám:

- `staging.stg_api_payloads`,
- `staging.stg_provider_leagues`,
- `staging.stg_provider_teams`,
- `staging.stg_provider_players`,
- `staging.stg_provider_fixtures`,
- další provider-normalized tabulky.

Legacy bridge převedl historická data do jednotného modelu. Tím vznikl základ pro další sporty.

## 4.5 11.–14. března – stabilní core pipeline a planner-driven ingest

K 11. březnu byl ověřen tok:

```text
provider import
→ unified staging
→ public canonical core
→ rating engine
→ prediction engine
→ Control Panel
```

Dobový snapshot uváděl přibližně:

- 2 713 lig,
- 5 136 týmů,
- 475 hráčů,
- 105 146 zápasů,
- 5 103 týmových ratingů,
- 103 422 match ratingů,
- 215 nových predikcí.

Dne 12. března vznikl konfiguračně řízený batch ingest nad `ops.ingest_targets`, s paralelizací a auditem do `ops.job_runs`.

Dne 13. března byla reálně ověřena planner pipeline:

```text
ops.ingest_targets
→ build_ingest_planner_jobs.py
→ ops.ingest_planner
→ run_ingest_planner_jobs.py
→ run_unified_ingest_v1.py
→ staging.stg_provider_*
→ run_unified_staging_to_public_merge_v1.py
→ public.*
```

Vznikl orchestration cycle, audit celého cyklu a ochrana pomocí worker locku. Současně byla odhalena potřeba správné propagace chyb z child jobů.

Architektonické dokumenty z 14. března představovaly první souvislou dokumentační sadu, ale některé části zjednodušovaly schéma nebo směšovaly implementaci s cílovou architekturou.

## 4.6 15.–18. března – Teams fallback a People Layer

Teams pipeline byla doplněna fallbackem:

```text
fixtures payload
→ extract teams
→ provider staging
→ canonical teams
```

Tím bylo možné doplnit týmy i tam, kde teams endpoint nebyl úplný.

Players pipeline se rozšířila na:

- player identity,
- player provider map,
- player profiles,
- player season statistics,
- externí identity,
- přípravu multisource enrichmentu.

Vznikl `ops.ingest_entity_plan`, který přesunul definici entit, workerů, priorit a scope z hardcoded logiky do databáze.

Dne 18. března ingest cycle V3 prokazatelně zpracovával players joby přes planner, worker, staging a merge.

## 4.7 19.–20. března – uzamčení DB směru a provider-aware vrstvy

Cílová databázová cesta byla určena jako:

```text
ops.*
→ staging.stg_provider_*
→ public.*
→ analytics / product layers
```

Sportově specifické `staging.api_football_*` tabulky byly označeny jako legacy nebo přechodové.

Player season statistics byly stabilizovány clean rebuild přístupem. Z tisíců staging statistických řádků vznikly stovky canonical business kombinací hráč–tým–liga–sezona.

Football byl rozdělen na provider-aware vrstvy:

- `FB_TOP`,
- `FB_FD_CORE`,
- `FB_API_EXPANSION`.

Football získal:

- target vrstvy,
- test planner views,
- execution order,
- job katalog,
- seed do `ops.provider_jobs`.

Hockey následně převzal stejný model jako první další sport. K 20. březnu byl Hockey OPS-ready, ale první reálný planner běh ještě nebyl dokončen.

## 4.8 22.–23. března – panel, bootstrap a první multisport blokery

Byly rozlišeny role:

- batch runner pro přímé testy targetů,
- planner worker pro odbavení pending queue,
- ingest cycle pro širší tok včetně parserů, fallbacků, merge, locku a auditu,
- budoucí orchestrátor pro koordinaci sportů, run groups, budgetu a retry politiky.

Panel V9 začal dynamicky načítat sporty, providery, entity a run groups z DB.

Byl spuštěn `FB_BOOTSTRAP_V1` pro fixtures a teams. Fronta obsahovala tisíce pending jobů a reálně plnila staging i public vrstvu.

U nových sportů byl potvrzen zásadní rozdíl:

- DB konfigurace a UI byly multisportové,
- provider routing existoval,
- ale některým sportům chyběly konkrétní download skripty nebo adaptery.

„Multisport ready“ tedy v této etapě znamenalo řídicí framework, ne plně funkční harvest všech sportů.

## 4.9 24.–25. března – první skutečně ověřený multisport core

Bylo implementováno sport-aware mapování endpointů:

- football → `fixtures`,
- basketball → `games`,
- hockey → `games`,
- volleyball → `games`.

Orchestrace byla opravena z neúplného toku:

```text
INGEST → MERGE
```

na správný tok:

```text
INGEST → PARSER → MERGE
```

Potvrzené dobové výsledky:

- Volleyball: 12 týmů a 178 zápasů v public vrstvě,
- Hockey: 1 146 zápasů pro konkrétní ligu a sezonu; širší parser běh zpracoval 4 398 fixtures,
- Basketball: technicky funkční tok, ale část targetů vracela nula dat; následně byl potvrzen použitelný fixtures target.

Tím byla reálně ověřena multisport core pipeline pro teams a fixtures alespoň v omezeném testovacím rozsahu.

## 4.10 25.–26. března – football People Layer a canonical team identity

Football players pipeline byla potvrzena jako end-to-end funkční z Panelu V9:

```text
fetch
→ RAW / players_import
→ bridge
→ public.players
→ player_provider_map
→ season stats parse
→ public.player_season_statistics
```

Dobový stav uváděl přibližně:

- 1 482 hráčů,
- 1 484 provider map,
- 36 890 staging season-stat řádků,
- 1 060 canonical player season statistics,
- nulové missing player a league mapy,
- menší zbývající mezeru v team mappingu.

Players endpointy mimo football nebyly v daném tarifu a providerové nabídce vhodné pro bulk ingest. Krátkodobá priorita se proto přesunula na zápasy, kurzy, predikce a Ticket Studio.

TheOdds parser začal ukládat kurzy a Ticket Studio je umělo zobrazit. Hlavním blockerem se stala rozdělená canonical identita týmů mezi více providerovými větvemi.

Bylo potvrzeno, že samotný název nestačí. Canonical matching musí používat také:

- zemi,
- ligový kontext,
- provider identity,
- skutečné použití týmu v zápasech.

## 4.11 28.–29. března – standings a produktový detail zápasu

Vznikla produktová databázová vrstva pro standings:

- `standings_rules`,
- `league_standings`,
- refresh logika,
- `product_active_leagues`,
- produktové view pro aktuální tabulky.

`league_standings` byla naplněna tisíci řádky a poskytovala:

- pořadí,
- body,
- skóre,
- formu za 5, 10 a 15 zápasů,
- home/away split,
- body za období.

Audit odhalil duplicitní zápasy v Premier League z historické football_data větve. Po cleanupu a refreshi standings měla produktová tabulka správný počet týmů a zápasů.

Ticket Studio začalo zobrazovat tabulku, formu a H2H v detailu zápasu. Návrhy exportu, bookmaker deeplinku, risk score a statistiky podobných tiketů byly v této etapě převážně produktovou specifikací.

## 4.12 30. března – Ticket Engine save pipeline a historie

Byla opravena tvorba `generated_ticket_blocks` a potvrzen tok:

```text
generated_*
→ mm_save_generated_run_full()
→ tickets
→ ticket_blocks
→ ticket_block_matches
→ ticket_history_base
```

Ticket Studio získalo:

- uložení celého runu,
- ochranu před duplicitním uložením,
- logování stavu,
- historii variant,
- probability a strukturální signatury.

Settlement vrstva byla opravována tak, aby:

- `total_odd` odpovídal UI,
- double chance měla fallback logiku,
- výběr zápasů a kurzů byl konzistentní s konkrétním bookmakerem.

Reálný test potvrdil end-to-end konzistenci pro konkrétní run. Automatický settlement po uložení, finální HIT/MISS a ROI však byly stále dalším krokem.

## 4.13 31. března – OPS dashboard, coverage a harvest směr

Vznikla provozní views pro:

- souhrn KPI,
- stav podle sportů,
- stav podle providerů,
- top queue,
- action queue,
- run-ready klasifikaci,
- panelové řízení RUN / VALIDATE / HOLD / BLOCKED.

Bylo přijato provozní rozhodnutí:

```text
Panel = monitoring, diagnostika a nouzové zásahy
Automat 24/7 = cílový hlavní runtime režim
```

Hockey byl v omezeném core rozsahu ověřen jako funkční přes API call, parsing, teams fallback a merge.

Současně byla vytvořena nebo popsána `ops.provider_entity_coverage`, která měla spojit:

- provider × sport × entity,
- coverage status,
- free/paid dostupnost,
- provider priority,
- fetch a merge priority,
- primary/fallback roli,
- limitations a next action.

Na konci měsíce byl projekt charakterizován jako:

> robustní základ, částečně funkční sporty, silný football, runtime-tested Hockey core a řada tech-ready nebo placeholder větví čekajících na validaci a PRO režim.

---

# 5. DATABASE SNAPSHOT

## 5.1 Cílové vrstvy

K 31. březnu byla preferovaná architektura:

| Vrstva | Role |
|---|---|
| `ops` | konfigurace, targety, planner, joby, coverage, budget, locks a audit |
| `staging` | raw payloady a provider-normalized mezivrstva |
| `work` | dávky, chybějící identity, pomocné transformace a cleanup |
| `public` | canonical sportovní data, analytické výstupy a produktová data |
| produktové / analytické views | Ticket Studio, standings, history, settlement, dashboard |

## 5.2 Unified staging

Hlavní jednotné tabulky zahrnovaly zejména:

- `staging.stg_api_payloads`,
- `staging.stg_provider_leagues`,
- `staging.stg_provider_teams`,
- `staging.stg_provider_fixtures`,
- `staging.stg_provider_players`,
- `staging.stg_provider_player_profiles`,
- `staging.stg_provider_player_season_stats`,
- `staging.stg_provider_odds`.

Starší sportově specifické tabulky a legacy importy stále existovaly a některé zůstávaly reálně používané.

## 5.3 Canonical core

Za klíčové canonical oblasti byly považovány:

- sports,
- countries,
- leagues,
- seasons,
- teams,
- players,
- matches,
- league/team/player provider maps,
- external identity a aliases,
- standings,
- odds,
- ratings a predictions.

## 5.4 Dobové počty

Historické zdroje uvádějí různé počty podle dne a stavu merge. Orientační body:

| Datum / etapa | Leagues | Teams | Players | Matches |
|---|---:|---:|---:|---:|
| 11.–13. března | 2 713 | 5 136 | 475 | 105 146 |
| 25. března | 2 986 | 5 410 | 839 | 108 419 |
| 26. března, football People | – | – | 1 482 | – |

Tyto hodnoty se nesmí sčítat ani považovat za dnešní stav.

## 5.5 People data

Na konci sledovaného období byla nejsilnější People Layer ve footballu:

- canonical hráči,
- provider mapy,
- player profiles,
- season statistics,
- příprava player-team history,
- připravený základ `team_coach_history`.

Coaches data zůstávala slabá a některé endpointy neexistovaly.

## 5.6 Ticket data

Rozlišovaly se vrstvy:

### Runtime

- generated runs,
- generated tickets,
- generated blocks,
- generated fixed picks.

### Persistent product

- tickets,
- ticket blocks,
- block matches,
- variants,
- constants.

### History / settlement / learning

- ticket history base,
- ticket settlements,
- pattern statistics,
- variant features,
- recommendation feedback.

Na konci měsíce již existoval reálný tok z runtime generování do uložené historie.

---

# 6. INGEST A OPS SNAPSHOT

## 6.1 Core autority

Jako klíčové řídicí entity byly identifikovány:

- `provider_sport_matrix`,
- `sport_dimension_rules`,
- `sport_entity_rules`,
- `ingest_entity_plan`,
- `provider_entity_coverage`,
- `ingest_targets`,
- `ingest_planner`,
- `provider_jobs`,
- `job_runs`,
- `worker_locks`.

## 6.2 Role komponent

| Komponenta | Role |
|---|---|
| `ingest_targets` | Co konkrétně chceme stahovat |
| planner builder | Převod targetů na konkrétní joby |
| `ingest_planner` | Runtime queue |
| planner worker | Claim a vykonání jobu |
| unified ingest runner | Provider dispatch |
| parser | Převod RAW na provider-normalized staging |
| merge worker | Převod staging do canonical public |
| ingest cycle | Lock, audit, parser/fallback/merge orchestrace |
| Control Panel | Manuální řízení, monitoring a diagnostika |
| budoucí harvest orchestrátor | Koordinace sportů, entit, priority, budgetu a denního plánu |

## 6.3 Free režim

Březen probíhal převážně v omezeném free režimu:

- seasons především 2022–2024 u některých providerů,
- omezené request budgety,
- odds z API-Football vypnuté,
- malé testovací batchy,
- příprava na budoucí krátké, ale intenzivní PRO období.

## 6.4 Runtime stavy

Na konci března se začaly používat nebo navrhovat přesnější stavy:

- planned,
- tech_ready,
- runtime_tested,
- production_ready,
- blocked,
- run_now,
- run_validate,
- monitor,
- review,
- wait_plan.

To bylo důležité, protože `enabled = true` samo o sobě neprokazovalo funkční endpoint ani worker.

---

# 7. PROVIDER A SPORT SNAPSHOT

## 7.1 Football

### Potvrzené

- API-Football: leagues, teams, fixtures a players v omezeném free rozsahu.
- football_data: historická a aktuální fixtures větev, ale stále přes legacy execution cestu.
- TheOdds: odds ingest runtime-tested a částečně napojený do Ticket Studia.
- Football players a season statistics: nejsilnější People Layer.

### Omezení

- unified runner neuměl na konci měsíce plně vykonat football_data adapter,
- část canonical týmů byla duplicitní,
- odds coverage trpěla rozdílnými team IDs,
- velký planner backlog zůstával pending.

## 7.2 Hockey

### Potvrzené

- leagues, teams a fixtures runtime-tested v omezeném rozsahu,
- fixtures parser a merge fungovaly,
- teams fallback z fixtures byl užitečný a někdy spolehlivější než teams endpoint.

### Omezení

- players endpoint byl problematický nebo blokovaný,
- coaches endpoint nebyl spolehlivě dostupný,
- část planneru obsahovala pending/error targety.

## 7.3 Basketball

### Potvrzené

- provider routing,
- endpoint `games`,
- raw ingest, parser a merge tok,
- použitelný fixtures target.

### Omezení

- část lig vracela nula dat,
- odds a hlubší People Layer nebyly připravené pro produkční provoz.

## 7.4 Volleyball

### Potvrzené

- endpoint mapping na `games`,
- 12 týmů a 178 zápasů v testovaném rozsahu,
- core teams + fixtures tok.

### Omezení

- hlubší entity a odds nebyly potvrzené.

## 7.5 Ostatní sporty

AFB, BSB, CK, FH, HB a RGB měly základní skeleton nebo databázovou konfiguraci, ale ne plně doložený produkční runtime.

TN, MMA, DRT a ESP byly převážně placeholder nebo budoucí větve.

---

# 8. PEOPLE LAYER SNAPSHOT

## 8.1 Football players

Konec března potvrzuje funkční základ:

- fetch hráčů,
- raw payloady,
- flatten import,
- bridge do unified staging,
- canonical players,
- provider mapy,
- season statistics.

## 8.2 Player identity

Bylo potvrzeno, že multi-provider hráčská vrstva vyžaduje:

- jednoznačný canonical player,
- provider mapy,
- externí identity,
- týmový a sezonní kontext,
- budoucí player-team history.

## 8.3 Match-level statistics

Player match statistics nebyly na konci měsíce stejně silně doložené jako season statistics.

Bylo rozpoznáno, že fixture-level entity nemají být plánovány čistě league-season plannerem. Musí vznikat z již dostupných zápasů.

## 8.4 Coaches

- staging model existoval,
- `team_coach_history` bylo připraveno,
- reálná data byla slabá nebo nulová,
- některé provider endpointy neexistovaly.

Coaches proto zůstali důležitou, ale nedokončenou People Layer.

---

# 9. ANALYTICS, ML A STANDINGS SNAPSHOT

## 9.1 Ratingy a predikce

Na začátku a uprostřed měsíce byly prokazatelně provozní:

- MMR team ratings,
- match ratings,
- feature dataset,
- prediction pipeline,
- budoucí predikce.

## 9.2 Odds a value

TheOdds parser:

- reálně ukládal část kurzů,
- snižoval počet unmatched týmů pomocí aliases,
- zůstával omezen duplicitní canonical identitou týmů a časovým párováním zápasů.

## 9.3 Standings

Na konci měsíce byla vytvořena robustní standings vrstva:

- centrální pravidla bodování pro více týmových sportů,
- aktuální i historická tabulka,
- forma 5/10/15,
- produktový whitelist lig,
- refresh z `public.matches`.

Byla také potvrzena potřeba oddělit klasické ligové soutěže od turnajových modelů.

## 9.4 Downstream refresh

Březen odhalil zásadní provozní princip:

> Ingest aktuálních zápasů musí spustit navazující refresh downstream vrstev.

Minimální lavina:

```text
fixtures ingest
→ status/score repair
→ standings refresh
→ form
→ ratings
→ features
→ Ticket Studio input
```

Na konci měsíce byl plněji ověřen především ingest + standings refresh.

---

# 10. TICKET ENGINE A PRODUCT SNAPSHOT

## 10.1 Runtime engine

Potvrzený princip:

- fixní zápasy,
- bloky A/B/C,
- maximálně tři bloky,
- maximálně tři volby na blok,
- až 27 variant,
- snapshot kurzů a pravděpodobností.

## 10.2 Persistent save pipeline

Dne 30. března byl potvrzen end-to-end tok z runtime generování do persistent produktové vrstvy a historie.

## 10.3 Settlement

Funkční části:

- výpočet total odd,
- bookmaker-consistent filtering,
- pending settlement stav,
- ukládání do historie.

Nedokončené části:

- automatické spuštění settlement refresh po save,
- úplné HIT/MISS vyhodnocení,
- profit a ROI pro všechny dokončené tikety,
- dlouhodobé pattern learning.

## 10.4 Ticket Studio

Konec března potvrzuje první funkční produktovou aplikaci s:

- výběrem zápasů,
- kurzy,
- fixy a bloky,
- generováním variant,
- ticket slipem,
- ukládáním do DB,
- detailem zápasu,
- standings, formou a H2H,
- historií runů.

Produktové návrhy, které ještě nebyly plně implementované:

- export PDF/XLSX/CSV v konečné podobě,
- bookmaker deeplink,
- risk score,
- statistika podobných tiketů,
- inteligentní doporučení,
- auto-builder,
- uživatelské účty a placené úrovně.

---

# 11. IMPLEMENTOVANÉ, PŘIPRAVENÉ A NAVRŽENÉ ČÁSTI

## 11.1 Prokazatelně implementované nebo runtime-tested

- unified staging pro hlavní entity,
- football core ingest a merge,
- planner builder a planner worker,
- ingest cycle s lockem a auditem,
- teams fallback z fixtures,
- football players a season statistics,
- prediction pipeline,
- core teams/fixtures testy pro HK, BK a VB,
- TheOdds ingest v omezené coverage,
- standings rules a league standings,
- Ticket Studio základ,
- Ticket Engine generování variant,
- save pipeline do persistent ticket vrstvy,
- ticket history,
- runtime settlement základ,
- OPS dashboard views a readiness klasifikace.

## 11.2 Technicky nebo databázově připravené

- širší multisport entity plans,
- provider jobs pro řadu sportů,
- coverage a priority logika,
- některé players/coaches/odds větve mimo football,
- worker orchestrace pro budoucí harvest,
- dlouhodobé People vztahy,
- learning tabulky a pattern statistics.

## 11.3 Rozpracované nebo přechodové

- football_data adapter v unified runneru,
- odstranění legacy ingest větví,
- canonical merge duplicitních týmů,
- úplné odds coverage,
- fixture-level player statistics,
- coaches data,
- automatický downstream refresh všech analytických vrstev,
- 24/7 harvest orchestrátor.

## 11.4 Návrhy a dlouhodobá vize

- globální web,
- mobilní aplikace,
- uživatelské účty,
- čtyři monetizační úrovně,
- uživatelské amatérské soutěže,
- bookmaker deeplink,
- pokročilý recommendation engine,
- automatická nabídka kandidátů do bloků,
- learning nad tisíci historicky vyhodnocenými variantami.

---

# 12. KLÍČOVÁ ROZHODNUTÍ BŘEZNA 2026

## 12.1 Unified staging je cílový směr

Sportově specifické staging tabulky jsou legacy nebo přechodová vrstva.

## 12.2 Football je referenční sport, ne jediný sport

Football slouží jako první hluboká implementace. Architektura musí zůstat multisportová.

## 12.3 Ingest se řídí targety, coverage a run groups

Planner není zdroj strategie. Planner vykonává práci vytvořenou z targetů a pravidel.

## 12.4 Provider se vybírá podle entity

Neexistuje jeden ideální provider pro všechno. MatchMatrix má kombinovat primary a fallback zdroje podle sportu a entity.

## 12.5 RAW → PARSER → STAGING → MERGE je povinný tok

Přímý merge bez parseru vedl k prázdným nebo nekonzistentním výsledkům.

## 12.6 Teams lze odvozovat z fixtures

Teams endpoint není vždy spolehlivý. Fixtures mohou být primárním nebo fallback zdrojem týmů.

## 12.7 Canonical identita nesmí stát pouze na názvu

Týmová identita musí používat provider mapu, zemi, soutěžní kontext a vazby v zápasech.

## 12.8 Panel není cílový 24/7 runtime

Panel je servisní a operátorský nástroj. Cílový harvest má běžet automatizovaně.

## 12.9 Ticket varianta je learning jednotka

Musí zůstat zachován `ticket_index`, struktura varianty, kontext, kurz, pravděpodobnost a následný výsledek.

## 12.10 MatchMatrix je advisory system

Projekt nemá být bookmaker. Má poskytovat data, analýzy, predikce a asistenci při tvorbě tiketů.

---

# 13. HLAVNÍ RIZIKA A NEKONZISTENCE

## 13.1 „Hotovo“ mělo různý význam

Některé dokumenty označovaly jako hotovou pouze staging větev, jiné celý public tok. Každé tvrzení musí být čteno v konkrétním kontextu.

## 13.2 Legacy větve zůstávaly aktivní

Přestože cílem byl unified model, football_data stále běželo přes legacy cestu.

## 13.3 Enabled neznamenalo funkční

Řada entit byla v plánu povolena, i když chyběl endpoint, worker, parser nebo runtime test.

## 13.4 Fronty obsahovaly placeholder a chybové targety

Bez coverage klasifikace a validace bylo možné spouštět nesmyslné nebo prázdné joby.

## 13.5 Canonical duplicity ovlivňovaly více vrstev

Duplicitní týmy poškozovaly:

- odds matching,
- match matching,
- predictions,
- Ticket Studio,
- budoucí multi-provider merge.

## 13.6 Downstream vrstvy mohly zastarat

Aktualizované matches automaticky neznamenaly aktualizované standings, form, ratings nebo features.

## 13.7 Free režim zkresloval coverage

Nedostupnost dat mohla být způsobena tarifem, ne nefunkční architekturou. Naopak technicky připravená větev nemusela být po aktivaci PRO automaticky produkční.

---

# 14. CURRENT STATUS K 2026-03-31

## 14.1 Silné a reálně funkční oblasti

- football datové a analytické jádro,
- unified staging a canonical merge princip,
- OPS planner a audit běhů,
- football players a season statistics,
- ratings a predictions,
- omezený multisport core pro HK, BK a VB,
- standings pro hlavní ligové soutěže,
- Ticket Studio jako první produktové UI,
- Ticket Engine runtime + save + history,
- readiness a dashboard views.

## 14.2 Částečně funkční nebo validační oblasti

- Hockey full queue,
- Basketball a Volleyball širší coverage,
- TheOdds match coverage,
- football_data unified adapter,
- automatic settlement,
- downstream refresh beyond standings,
- canonical cleanup napříč providery.

## 14.3 Připravené, ale neprokázané oblasti

- většina dalších sportů,
- coaches mimo omezené pokusy,
- players mimo football,
- odds mimo football,
- 24/7 harvest orchestrace,
- pokročilý learning a recommendations.

## 14.4 Celkový stav

MatchMatrix byl k 31. březnu 2026:

- architektonicky výrazně pokročilý,
- reálně funkční ve footballu,
- runtime-tested v omezeném core rozsahu u Hockey, Basketball a Volleyball,
- připravený pro další providerovou a sportovní expanzi,
- stále zatížený legacy větvemi, canonical duplicitami a nejednotnou runtime klasifikací,
- poprvé propojený od ingestu přes analytiku až k produktovému Ticket Studiu a historii tiketů.

---

# 15. OPEN QUESTIONS K 2026-03-31

1. Jak definitivně oddělit core, test, legacy a placeholder prvky v OPS a staging?
2. Jak převést football_data do unified provider registry bez ztráty funkční legacy cesty?
3. Jak provést bezpečný canonical merge duplicitních týmů napříč providery?
4. Jak napojit coverage a priority přímo na planner a denní harvest plán?
5. Jak měřit skutečný progress proti cílovému datasetu?
6. Jak spouštět downstream refresh po ingestu bez ručních kroků?
7. Které sporty a entity jsou skutečně production-ready a které pouze runtime-tested?
8. Jak získat použitelné players a coaches zdroje mimo football?
9. Jak dokončit automatic settlement, ROI a learning loop?
10. Jak připravit krátké PRO období tak, aby využilo maximum request budgetu?

---

# 16. NEXT STEP DEFINOVANÝ NA KONCI BŘEZNA 2026

Bezprostřední technický směr měl dvě navazující větve.

## 16.1 Harvest a OPS

- sjednotit coverage statusy,
- napojit coverage a priority na planner,
- doplnit harvest dashboard,
- rozlišit RUN NOW / VALIDATE / HOLD / BLOCKED,
- připravit denní plán a request budget,
- automatizovat post-ingest refresh.

## 16.2 Data a produkt

- pokračovat v canonical cleanup týmů,
- stabilizovat odds matching,
- dokončit automatic settlement,
- ukládat HIT/MISS, profit a ROI,
- začít budovat spolehlivý learning dataset variant.

Dlouhodobý cíl zůstal:

```text
DATA
→ CANONICAL IDENTITY
→ ANALYTICS
→ TICKET ENGINE
→ HISTORY / SETTLEMENT
→ LEARNING
→ RECOMMENDATIONS
→ WEB PRODUCT
```

---

# 17. VZTAH K SOUČASNÉMU PROJEKTU

## 17.1 Dlouhodobě platné principy

- unified staging,
- canonical provider maps,
- provider-aware ingest,
- OPS řízení přes targety a planner,
- oddělení raw, staging, canonical a product vrstev,
- multisport architektura,
- Ticket Engine jako samostatná produktová vrstva,
- varianta tiketu jako learning jednotka,
- panel jako operátorský nástroj,
- advisory model projektu.

## 17.2 Historické technické prvky k revizi

- konkrétní názvy workerů a verzí panelů,
- PowerShell a `.bat` orchestrace,
- legacy football_data cesta,
- tehdejší provider registry,
- historické DB počty,
- testovací run groups,
- free tarifní limity,
- dočasné fallbacky a clean rebuild skripty.

## 17.3 Oblasti pro aktualizaci hlavních Review dokumentů

- skutečný současný stav unified staging,
- canonical identity governance,
- People Layer,
- provider coverage a Source Intelligence,
- Operator / Denní práce,
- Ticket Engine a Ticket Intelligence,
- documentation-driven snapshot a audit workflow.

---

# 18. MAPOVÁNÍ DO DOKUMENTAČNÍCH OBLASTÍ

| Oblast | Hlavní březnový obsah |
|---|---|
| MASTER | globální sportovní datová a poradní platforma |
| GOVERNANCE | canonical identity, provider maps, coverage statusy |
| ARCHITECTURE | OPS → staging → public → analytics → product |
| DATABASE | unified staging, People Layer, standings, ticket history |
| PROVIDERS | API-Football, football_data, TheOdds, API-Hockey, API-Sport |
| LAYERS | core, people, analytics, ticket, settlement, learning |
| OPERATOR | planner, cycle, panel, readiness, harvest dashboard |
| DEVELOPMENT | workery, parsery, merge, fallbacky, downstream refresh |
| HISTORY | tento Project Snapshot a zdrojové denní zápisy |
| REFERENCE | terminologie coverage, runtime-tested, production-ready |

---

# 19. ZÁVĚR CHECKPOINTU

Březen 2026 byl pro MatchMatrix přelomovým měsícem.

Projekt se posunul od souboru samostatných football skriptů k vrstvenému systému, který již obsahoval:

- unified staging,
- planner-driven ingest,
- audit a locky,
- první ověřené multisport core běhy,
- funkční football People Layer,
- ratingy a predikce,
- standings a detail zápasu,
- Ticket Studio,
- ukládání tiketů,
- historii a základ settlementu,
- coverage a readiness logiku pro budoucí harvest.

Současně se ukázalo, že největší překážkou dalšího rozvoje není nedostatek tabulek nebo návrhů, ale potřeba:

- vyčistit canonical identity,
- odstranit paralelní legacy větve,
- přesně klasifikovat runtime stav každé sportovní entity,
- propojit ingest s downstream refreshem,
- řídit harvest podle coverage, priority a budgetu,
- dokončit learning loop nad reálně vyhodnocenými tikety.

Nejpřesnější charakteristika stavu k 31. březnu 2026 je:

> MatchMatrix měl robustní architektonický základ, silný football, první runtime-tested multisport core, funkční Ticket Studio a vznikající harvest a learning systém. Nebyl ještě plně produkční multisport platformou, ale poprvé byl propojen od providerových dat až k uloženým tiketovým variantám a jejich budoucímu vyhodnocení.

---

## Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 1.0 | 2026-07-06 | První rekonstruované vydání Project Snapshotu za březen 2026. |
