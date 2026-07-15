# ARCHITEKTURA DATABÁZE MATCHMATRIX

**Document ID:** `MM-DB-001`  
**Edice:** MM-DOC TECH

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DB-001 |
| Document ID | MM-DB-001 |
| Název dokumentu | Architektura databáze MatchMatrix |
| Typ dokumentu | DATABASE_ARCHITECTURE |
| Dokumentační oblast | 04_DATABASE |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum | 2026-07-14 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Primární formát | Markdown (.md) |
| Cílové umístění | `docs/04_DATABASE/MM-DB-001_ARCHITEKTURA_DATABAZE_MATCHMATRIX.md` |
| Nadřazený index | MM-DB-1000 |
| Nadřazená dokumentační mapa | MM-DOC-001 |
| Nadřazený dokumentační rámec | MM-DOC-000 |
| Hlavní architektonický zdroj | MM-DOC-300 |
| Hlavní governance zdroj | MM-DOC-200 |
| Hlavní vývojový zdroj | MM-DOC-800 |
| Auditní nástroj | 25_1_A_33 v1.0 |
| Auditní snapshot | 2026-07-14T09:19:17.812347+00:00 |
| Auditovaná databáze | `matchmatrix` |
| Auditovaný databázový server | PostgreSQL 16.14 |
| Auditní režim | READ ONLY / REPEATABLE READ / ROLLBACK |
| Auditní Git commit | `62433559998916901299959ce1d8566cfa03b7be` |
| Související standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-009 |
| Zdroj pravdy | Aktuální PostgreSQL + Git + řízená dokumentační databáze |

---

## Úvod

### Účel dokumentu

Tento dokument popisuje skutečnou databázovou architekturu platformy MatchMatrix na základě read-only auditu produkční databáze.

Jeho účelem je:

- vymezit fyzická PostgreSQL schémata a jejich odpovědnosti,
- popsat logické datové vrstvy a jejich vazby,
- odlišit canonical data od staging, provozních, dokumentačních a pracovních dat,
- stanovit povolený směr datového toku,
- určit zdroje pravdy pro jednotlivé části platformy,
- zaznamenat architektonické výjimky a přechodové objekty,
- vytvořit ověřený základ pro navazující katalog `MM-DB-002`,
- vytvořit stabilní referenční bod pro budoucí migrace, workery, panel a web.

Dokument není úplným katalogem všech 1115 databázových objektů. Úplný katalog má vzniknout v `MM-DB-002`.

### Rozsah

Dokument pokrývá tato fyzická schémata:

- `staging`,
- `public`,
- `ops`,
- `documentation`,
- `work`.

Dokument zahrnuje tabulky, views, sekvence, sloupce, constraints, indexy, rutiny, triggery, relační závislosti, oprávnění a governance metadata v rozsahu zachyceném nástrojem A33.

### Důležité omezení

Audit představuje stav databáze v jednom konkrétním okamžiku.

Počty řádků jsou odhady PostgreSQL statistik. Nejde o úplné `COUNT(*)` nad všemi tabulkami.

Závislosti v tomto dokumentu představují databázové relační závislosti. Nezahrnují automaticky všechny vazby z Pythonu, SQL souborů, panelu, workerů, cronu, externích aplikací nebo Git historie.

### Závěr kapitoly

Úvod vymezil účel, rozsah a omezení dokumentu. Přínosem je jasné oddělení architektonického popisu od úplného objektového katalogu. Návaznost pokračuje v kapitole, která stanovuje důkazní základ a pravidla interpretace auditu.

---

## 1. Důkazní základ a klasifikace tvrzení

### 1.1 Primární důkazy

| Zdroj | Úloha |
|---|---|
| `database_structure_audit_latest.json` | Strojový zdroj pravdy pro snapshot databáze |
| `database_structure_audit_latest.md` | Čitelný auditní report |
| `25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py` | Reprodukovatelný read-only audit |
| MM-DB-1000 | Index a plán databázové dokumentace |
| MM-DOC-300 | Architektonické principy celé platformy |
| MM-DOC-200 | Governance a ochrana databázových rozhodnutí |
| Git repozitář | Zdroj pravdy pro schválené definice a skripty |
| PostgreSQL `matchmatrix` | Zdroj pravdy pro skutečně existující objekty |

### 1.2 Klasifikace

| Klasifikace | Význam |
|---|---|
| DB VERIFIED | Tvrzení bylo ověřeno přímo v databázi auditem A33 |
| GIT VERIFIED | Tvrzení bylo ověřeno v aktuálním Git repozitáři |
| DOCUMENTED | Tvrzení je převzato ze schválené nebo řízené dokumentace |
| IMPLEMENTED | Existuje konkrétní objekt nebo funkční implementace |
| PARTIAL | Implementace existuje jen v části systému |
| TRANSITIONAL | Objekt nebo princip je přechodový a nesmí být považován za cílový stav |
| REQUIRES AUDIT | Před změnou je nutný další audit |
| PLANNED | Jde o budoucí architektonický záměr |

### 1.3 Pořadí důvěryhodnosti

Při rozporu zdrojů platí:

```text
aktuální databáze
→ aktuální Git definice
→ schválená řízená dokumentace
→ historický dokument
→ pracovní report nebo chat
```

### 1.4 Git stav auditního běhu

Audit A33 byl vytvořen nad databází v read-only transakci.

Git byl při auditu označen jako dirty pouze proto, že nový skript A33 ještě nebyl v okamžiku běhu commitnutý. Tato skutečnost neovlivňuje databázový snapshot, ale musí zůstat dohledatelná.

### Závěr kapitoly

Kapitola stanovila zdroje, klasifikaci a pořadí důvěryhodnosti. Přínosem je ochrana dokumentu před smícháním ověřeného stavu s historickými nebo plánovanými informacemi. Návaznost pokračuje fyzickým snapshotem databáze.

---

## 2. Ověřený fyzický snapshot databáze

### 2.1 Souhrn instance

| Metrika | Ověřená hodnota |
|---|---:|
| Schémata | 5 |
| Objekty | 1115 |
| Tabulky | 283 |
| Views | 596 |
| Materialized views | 0 |
| Sekvence | 236 |
| Foreign tables | 0 |
| Sloupce | 12257 |
| Constraints | 603 |
| Indexy | 856 |
| Rutiny | 95 |
| Triggery | 23 |
| Relační závislosti | 747 |
| Grant záznamy | 7679 |
| Vlastní enumy a domény | 0 |
| Celková velikost | 656.52 MB |

### 2.2 Schémata

| Schéma | Tabulky | Views | Sekvence | Funkce | Velikost | Podíl velikosti |
|---|---:|---:|---:|---:|---:|---:|
| `staging` | 31 | 5 | 21 | 0 | 415 MB | 63.2 % |
| `public` | 131 | 100 | 108 | 68 | 215 MB | 32.7 % |
| `ops` | 111 | 488 | 100 | 26 | 18 MB | 2.7 % |
| `documentation` | 7 | 3 | 7 | 1 | 8648 kB | 1.3 % |
| `work` | 3 | 0 | 0 | 0 | 848 kB | 0.1 % |

### 2.3 Fyzický model

```text
PostgreSQL databáze matchmatrix
│
├── staging       vstupní, providerová a normalizační vrstva
├── public        canonical, produktová a analytická vrstva
├── ops           řídicí, provozní, auditní a dashboardová vrstva
├── documentation řízená databázová vrstva dokumentace
└── work          dočasné pracovní množiny a pomocné seznamy
```

### 2.4 Co v databázi fyzicky není

Audit nepotvrdil samostatná schémata:

- `raw`,
- `runtime`,
- `analytics`,
- `media`,
- `people`,
- `odds`,
- `ai`.

Tyto názvy představují logické funkční vrstvy nebo domény. Jejich fyzické objekty jsou aktuálně rozloženy zejména mezi `staging`, `public` a `ops`.

Raw/payload odpovědnost je realizována objekty, jako jsou `staging.stg_api_payloads` a `public.api_raw_payloads`.

Runtime odpovědnost je realizována zejména v `ops` a částečně v `work`; nejde o samostatné fyzické schéma.

### 2.5 Databázová verze

Auditovaná databázová instance hlásí PostgreSQL 16.14.

Tento údaj popisuje konkrétní běžící databázovou službu. Neurčuje automaticky verzi všech PostgreSQL instalací nebo binárních balíčků dostupných na PC2.

### Závěr kapitoly

Kapitola vytvořila ověřený fyzický obraz databáze. Přínosem je korekce starších obecných popisů: současná databáze má pět fyzických schémat a logické raw či runtime funkce nejsou samostatnými schématy. Návaznost pokračuje architektonickými principy.

---

## 3. Základní architektonické principy

### 3.1 Canonical zdroj pravdy

Oficiální sportovní a produktové entity musí být čteny z canonical vrstvy v `public`.

Providerová nebo pracovní data nesmějí bez řízeného mapování přímo určovat identitu:

- sportu,
- soutěže,
- sezóny,
- týmu,
- osoby,
- zápasu,
- článku,
- kurzu,
- tiketu.

### 3.2 Oddělení odpovědností

Každé schéma má jednoznačnou hlavní odpovědnost:

| Schéma | Hlavní odpovědnost |
|---|---|
| `staging` | Přijetí, zachování, normalizace a příprava zdrojových dat |
| `public` | Canonical entity, produktové výstupy a stabilní datové kontrakty |
| `ops` | Řízení provozu, plánování, governance, audity a dashboardy |
| `documentation` | Verze, sekce, vztahy a historie řízené dokumentace |
| `work` | Dočasné pracovní množiny, které nejsou zdrojem pravdy |

### 3.3 Jednosměrnost datového toku

Základní tok musí směřovat od zdroje k canonical vrstvě:

```text
provider nebo oficiální zdroj
→ harvest / worker
→ raw payload
→ staging
→ parser a normalizace
→ identity mapping
→ merge a governance
→ public canonical
→ analytika / AI / Ticket Engine / web / API
```

`ops` tento tok řídí a audituje. `documentation` eviduje dokumentační znalost. `work` slouží pouze jako dočasná pomocná vrstva.

### 3.4 Plně kvalifikované názvy

SQL, dokumentace a kód musí u databázových objektů používat plně kvalifikované názvy:

```sql
public.league_provider_map
ops.league_provider_map
```

Audit potvrdil minimálně jeden stejný název objektu ve více schématech. Nekvalifikovaný název by mohl vést k použití nesprávného objektu podle `search_path`.

### 3.5 Bezpečnost před rychlostí

Při konfliktu mezi rychlým importem a ochranou dat má přednost:

- integrita,
- dohledatelnost,
- opakovatelnost,
- idempotence,
- možnost rollbacku,
- řízené řešení konfliktů,
- zachování zdrojového payloadu.

### Závěr kapitoly

Kapitola stanovila hlavní principy: canonical zdroj pravdy, oddělení odpovědností, jednosměrný tok a kvalifikované názvy. Přínosem je společný rámec pro všechny další databázové dokumenty. Návaznost pokračuje vstupní vrstvou `staging`.

---

## 4. Schéma staging

### 4.1 Úloha

`staging` je vstupní a normalizační vrstva.

Obsahuje:

- providerové payloady,
- provider-specific tabulky,
- sjednocené `stg_*` tabulky,
- data připravená pro mapování a merge,
- přechodové a historické struktury, které dosud nelze odstranit.

### 4.2 Ověřený rozsah

| Metrika | Hodnota |
|---|---:|
| Tabulky | 31 |
| Views | 5 |
| Sekvence | 21 |
| Velikost | 415 MB |
| Podíl databáze | 63.2 % |

`staging` je objemově největší schéma databáze.

### 4.3 Cílový sjednocený vzor

Ověřené aktivní objekty sjednoceného vzoru zahrnují například:

- `staging.stg_api_payloads`,
- `staging.stg_provider_fixtures`,
- `staging.stg_provider_leagues`,
- `staging.stg_provider_teams`,
- `staging.stg_provider_players`,
- `staging.stg_provider_player_profiles`,
- `staging.stg_provider_player_season_stats`,
- `staging.stg_media_articles`.

Tyto objekty představují cílový směr univerzálního providerového stagingu.

### 4.4 Provider-specific a legacy objekty

Audit současně potvrdil starší `api_*` objekty, například:

- `staging.api_football_fixtures`,
- `staging.api_football_leagues`,
- `staging.api_football_teams`,
- `staging.api_hockey_leagues`,
- `staging.api_hockey_teams`,
- `staging.api_tennis_fixtures`.

Objekty označené `LEGACY_KEEP` se nesmějí automaticky odstranit.

`LEGACY_KEEP` znamená:

- objekt není cílový master vzor,
- může být stále čten parserem, workerem nebo migračním procesem,
- jeho odstranění vyžaduje audit databázových i aplikačních závislostí,
- případná náhrada musí být ověřena proti sjednocenému `stg_*` toku.

### 4.5 Největší staging objekt

`staging.api_football_fixtures` má přibližně 254 MB a tvoří 38.7 % celé auditované databáze.

Governance stav je `LEGACY_KEEP`.

Jde o nejvýznamnější kapacitní a migrační bod staging vrstvy. Objekt nesmí být mazán pouze na základě názvu nebo velikosti.

### 4.6 Povolené a zakázané použití

Povoleno:

- harvest a parser,
- kontrola zdrojového payloadu,
- mapování providerových identit,
- řízený merge,
- audit a oprava dat,
- bezpečný replay.

Zakázáno jako výchozí architektonický vzor:

- přímé čtení z webu,
- přímé čtení veřejným API,
- považování providerového ID za canonical ID,
- ruční mazání bez auditní stopy,
- vytváření nového provider-specific schématu bez architektonického schválení.

### Závěr kapitoly

Kapitola popsala `staging` jako největší vstupní vrstvu a oddělila cílový `stg_*` vzor od přechodových `api_*` struktur. Přínosem je bezpečný migrační rámec bez unáhleného mazání legacy dat. Návaznost pokračuje canonical vrstvou `public`.

---

## 5. Schéma public

### 5.1 Úloha

`public` je canonical a produktová vrstva MatchMatrix.

Obsahuje:

- základní sportovní entity,
- providerové mapy,
- People data,
- Media data,
- Odds data,
- ratingy a predikce,
- Ticket Engine,
- produktové a analytické views,
- datové kontrakty pro web, API a další konzumenty.

### 5.2 Ověřený rozsah

| Metrika | Hodnota |
|---|---:|
| Tabulky | 131 |
| Views | 100 |
| Sekvence | 108 |
| Funkce | 68 |
| Velikost | 215 MB |
| Podíl databáze | 32.7 % |

### 5.3 Core a canonical entity

Reprezentativní canonical objekty:

- `public.sports`,
- `public.leagues`,
- `public.seasons`,
- `public.teams`,
- `public.matches`,
- `public.stadiums`,
- `public.league_teams`,
- `public.league_standings`.

`public.matches` je governance objektem `ACTIVE_MASTER`, má přibližně 121 911 odhadovaných řádků a velikost přibližně 63 MB.

### 5.4 Providerové identity

Canonical vrstva odděluje interní identitu od providerových identifikátorů.

Reprezentativní objekty:

- `public.league_provider_map`,
- `public.team_provider_map`,
- `public.player_provider_map`,
- `public.coach_provider_map`,
- `public.player_external_identity`,
- `public.canonical_league_map`.

Provider mapy jsou součástí identity boundary. Jejich změny mají vysoký dopad a musí podléhat constraints, auditu a řízenému merge.

### 5.5 People doména

Reprezentativní objekty:

- `public.players`,
- `public.coaches`,
- `public.team_coaches`,
- `public.team_coach_history`,
- `public.player_match_statistics`,
- `public.player_season_statistics`,
- `public.player_form`,
- `public.player_trending`.

`public.players` je `ACTIVE_MASTER` a audit odhaduje přibližně 19 493 řádků.

### 5.6 Media doména

Reprezentativní objekty:

- `public.articles`,
- `public.media_articles`,
- `public.content_sources`,
- `public.article_player_map`,
- `public.article_team_map`,
- `public.article_match_map`,
- `public.article_league_map`.

Media vazby musí používat canonical entity a nesmějí vytvářet druhou identitu týmů, hráčů nebo zápasů.

### 5.7 Odds doména

Reprezentativní objekty:

- `public.odds`,
- `public.bookmakers`,
- `public.markets`,
- `public.market_outcomes`,
- `public.closing_odds`.

`public.odds` je `ACTIVE_MASTER`, má přibližně 82 386 odhadovaných řádků a velikost přibližně 15 MB.

`public.closing_odds` je současně bez primárního klíče a je označeno jako legacy/deprecated kandidát k posouzení. Nejde o automatický pokyn k odstranění.

### 5.8 Ratingy, ML a Ticket Engine

Reprezentativní objekty:

- `public.mm_match_ratings`,
- `public.mm_team_ratings`,
- `public.match_features`,
- `public.ml_predictions`,
- `public.mm_value_bets`,
- `public.generated_tickets`,
- `public.generated_ticket_blocks`,
- `public.ticket_blocks`,
- `public.tickets`.

Tyto objekty jsou odvozenou nebo produktovou vrstvou nad canonical sportovními daty. Nesmějí obcházet canonical identitu a musí zachovat vazbu na vstupní entity a výpočetní běh.

### 5.9 Architektonické výjimky

Objekt `public.api_raw_payloads` plní payloadovou odpovědnost, která by logicky patřila do raw/staging oblasti.

Jeho přítomnost v `public` musí být považována za současný implementovaný stav, nikoli automaticky za cílový standard.

Před případným přesunem je nutné ověřit:

- workery,
- parsery,
- retenci,
- constraints,
- indexy,
- objem TOAST dat,
- aplikační závislosti.

### Závěr kapitoly

Kapitola popsala `public` jako canonical, produktovou a analytickou vrstvu. Přínosem je jasné rozdělení Core, People, Media, Odds, ML a Ticket Engine při zachování jediné identity. Návaznost pokračuje řídicí vrstvou `ops`.

---

## 6. Schéma ops

### 6.1 Úloha

`ops` je řídicí, provozní, governance a auditní vrstva.

Nejde pouze o technické logy. Schéma obsahuje:

- plánování ingestu,
- fronty a runtime řízení,
- registry workerů,
- providerové pokrytí,
- governance objektů,
- source intelligence,
- bezpečnostní a kontrolní audity,
- dashboardy a read models pro panel.

### 6.2 Ověřený rozsah

| Metrika | Hodnota |
|---|---:|
| Tabulky | 111 |
| Views | 488 |
| Sekvence | 100 |
| Funkce | 26 |
| Velikost | 18 MB |
| Podíl databáze | 2.7 % |

`ops` obsahuje 488 views, což z něj dělá nejrozsáhlejší read-model a dashboardovou vrstvu databáze.

### 6.3 Plánování a běhy

Reprezentativní master objekty:

- `ops.ingest_planner`,
- `ops.ingest_targets`,
- `ops.job_runs`,
- `ops.scheduler_queue`,
- `ops.worker_registry`,
- `ops.worker_locks`,
- `ops.worker_execution_rules`.

### 6.4 Provider a runtime řízení

Reprezentativní objekty:

- `ops.provider_entity_coverage`,
- `ops.provider_jobs`,
- `ops.provider_sport_matrix`,
- `ops.provider_accounts`,
- `ops.runtime_entity_audit`,
- `ops.runtime_execution_history`.

Runtime odpovědnost je tedy fyzicky začleněna do `ops`, nikoli do samostatného `runtime` schématu.

### 6.5 Governance objektů

Centrální registr:

```text
ops.database_object_governance
```

Audit našel 540 governance záznamů a 540 jednoznačných shod s databázovými objekty.

Rozdělení spárovaných objektů:

| Governance stav | Počet |
|---|---:|
| ACTIVE_MASTER | 206 |
| ACTIVE | 202 |
| ACTIVE_REVIEW | 63 |
| LEGACY_KEEP | 53 |
| ACTIVE_PANEL | 14 |
| DROP_CANDIDATE | 2 |

### 6.6 Views a verzované názvy

V `ops` existuje velké množství views s verzovanými suffixy, například `_v1`, `_v2`, `_v3`.

Verzovaný název view může být přechodovým mechanismem, ale nesmí nahrazovat:

- governance status,
- explicitní náhradu,
- audit závislostí,
- řízené odstranění staré verze,
- stabilní kontrakt pro panel a workery.

Audit potvrdil dva objekty `DROP_CANDIDATE`:

- `ops.v_provider_routing_master`,
- `ops.v_sport_completion_dashboard_v1`.

Oba mají uvedený náhradní objekt a před odstraněním vyžadují kontrolu kódu, panelu a workerů.

### 6.7 Source Intelligence

Source Intelligence je funkční doména uvnitř `ops`.

Zahrnuje registry, právní a obchodní audity, coverage, plánování a ověřování zdrojů.

Její objekty nesmějí být zaměňovány s providerovými sportovními daty v `staging` nebo `public`.

### Závěr kapitoly

Kapitola popsala `ops` jako control plane celé platformy a vysvětlila, proč vysoký počet views neznamená vysoký datový objem. Přínosem je jasné oddělení provozního řízení od canonical dat. Návaznost pokračuje dokumentační databázovou vrstvou.

---

## 7. Schéma documentation

### 7.1 Úloha

`documentation` je řízená databázová vrstva dokumentace a znalostí projektu MatchMatrix.

Není určena pro sportovní data.

### 7.2 Ověřený rozsah

| Metrika | Hodnota |
|---|---:|
| Tabulky | 7 |
| Views | 3 |
| Sekvence | 7 |
| Funkce | 1 |
| Velikost | 8648 kB |
| Podíl databáze | 1.3 % |

### 7.3 Hlavní tabulky

- `documentation.documents`,
- `documentation.document_versions`,
- `documentation.document_sections`,
- `documentation.document_relations`,
- `documentation.document_status_history`,
- `documentation.import_runs`,
- `documentation.status_snapshots`.

### 7.4 Architektonický model

```text
Document ID
→ dokument
→ jedna nebo více verzí
→ strukturované sekce
→ vazby na jiné dokumenty
→ historie stavů
→ audit importního běhu
```

### 7.5 Zdroj pravdy

Dokumentační vrstva používá hybridní model:

- Git je zdrojem schváleného souborového obsahu,
- PostgreSQL je strukturovaným registrem a znalostní vrstvou,
- A24 zajišťuje řízený import,
- A6/A7 ověřují integritu.

Databáze nesmí být používána k neřízenému přepisování schválených Markdown souborů.

### Závěr kapitoly

Kapitola vymezila `documentation` jako samostatnou řízenou znalostní vrstvu. Přínosem je oddělení dokumentačních entit od sportovních a provozních dat. Návaznost pokračuje dočasnou pracovní vrstvou `work`.

---

## 8. Schéma work a dočasná data

### 8.1 Úloha

`work` obsahuje pomocné pracovní množiny.

Audit potvrdil tři tabulky:

- `work.missing_player_profile_batches`,
- `work.missing_player_profile_ids`,
- `work.leagues_to_add`.

### 8.2 Architektonická pravidla

Objekty ve `work`:

- nesmějí být canonical zdrojem pravdy,
- nesmějí být přímo čteny veřejným API,
- musí mít jasný účel a vlastníka,
- musí mít definovanou dobu života nebo podmínku uzavření,
- musí být možné znovu vytvořit z ověřených zdrojů,
- nesmějí potichu přerůst v trvalou produkční tabulku.

### 8.3 Primární klíče

Dvě potvrzené pracovní tabulky nemají primární klíč:

- `work.missing_player_profile_batches`,
- `work.missing_player_profile_ids`.

U dočasné pracovní množiny může být absence PK záměrná. Musí však být zdokumentována a nesmí způsobovat duplicitní nebo nejednoznačné zpracování.

### 8.4 Vztah k runtime

`work` není plnou runtime vrstvou.

Runtime řízení je implementováno především v `ops`; `work` slouží pouze pro konkrétní dočasné datové množiny.

### Závěr kapitoly

Kapitola stanovila přísné hranice pracovní vrstvy. Přínosem je ochrana před tím, aby dočasné tabulky začaly suplovat canonical nebo runtime architekturu. Návaznost pokračuje kompletním datovým tokem.

---

## 9. Datový tok a architektonické hranice

### 9.1 Hlavní tok

```text
Externí provider / oficiální zdroj
        │
        ▼
Harvest worker a řízení v ops
        │
        ▼
Payloadové uložení
        │
        ▼
staging: providerová a sjednocená data
        │
        ▼
Parser, normalizace a validace
        │
        ▼
Provider identity mapping
        │
        ▼
Merge, konflikty, HOLD a governance
        │
        ▼
public: canonical a produktová data
        │
        ├──► People
        ├──► Media
        ├──► Odds
        ├──► Ratings / ML
        ├──► Ticket Engine
        └──► Web / API / panelové výstupy
```

### 9.2 Řídicí tok

```text
ops planner
→ target
→ worker
→ job run
→ audit
→ coverage
→ readiness
→ dashboard / panel
```

### 9.3 Dokumentační tok

```text
Markdown dokument
→ A17 audit
→ A18/A19/A20 standardizace
→ schválení
→ Git commit a push
→ A24 import
→ A6/A7 integrita
→ documentation schema
```

### 9.4 Zakázané obcházení

Architektura nesmí běžně připustit:

- provider → `public` bez validace,
- `work` → veřejné API,
- legacy tabulka → nový produktový kontrakt bez schválení,
- view s vyšší verzí → automatické odstranění předchozí verze,
- ruční změnu canonical identity bez auditu,
- aplikační použití nekvalifikovaného názvu při kolizi schémat,
- dokumentační databázi jako náhradu Git zdroje pravdy.

### 9.5 Idempotence a replay

Ingest a merge musí být navrženy tak, aby:

- opakovaný běh nevytvořil druhou canonical entitu,
- bylo možné znovu zpracovat zachovaný payload,
- importní běh měl jednoznačný identifikátor,
- změna byla dohledatelná podle provideru a externího ID,
- konflikt byl oddělen od úspěšného importu.

### Závěr kapitoly

Kapitola spojila fyzická schémata do jednoho řízeného toku. Přínosem je přesná definice povolených hranic a zakázaných zkratek. Návaznost pokračuje integritou, klíči a závislostmi.

---

## 10. Integrita, klíče a závislosti

### 10.1 Ověřený stav

Audit eviduje:

- 603 constraints,
- 856 indexů,
- 747 relačních závislostí,
- 23 triggerů,
- 95 rutin.

Rozdělení rutin:

- `public`: 68,
- `ops`: 26,
- `documentation`: 1.

Procedury nebyly v auditu nalezeny; auditované rutiny jsou funkcemi nebo funkčními objekty PostgreSQL.

### 10.2 Primární klíče

Audit našel 14 tabulek bez primárního klíče.

| Schéma | Tabulka | Odhad řádků | Governance |
|---|---|---:|---|
| `staging` | `players_import` | 2745 | LEGACY_KEEP |
| `work` | `missing_player_profile_batches` | 4379 |  |
| `staging` | `api_hockey_leagues` | 524 | LEGACY_KEEP |
| `staging` | `api_hockey_teams_raw` | 1333 | ACTIVE_REVIEW |
| `staging` | `api_hockey_teams` | 399 | LEGACY_KEEP |
| `staging` | `api_hockey_leagues_raw` | 7 | ACTIVE_REVIEW |
| `public` | `unmatched_theodds` | 72 | LEGACY_KEEP |
| `work` | `missing_player_profile_ids` | 220 |  |
| `ops` | `eu_batch_1` | 1 | LEGACY_KEEP |
| `ops` | `eu_batch_100` | 100 | LEGACY_KEEP |
| `ops` | `people_quality_backfill_queue` | -1 | ACTIVE |
| `public` | `work_pl_aliases` | -1 | LEGACY_KEEP |
| `staging` | `player_provider_map_import` | -1 | LEGACY_KEEP |
| `public` | `closing_odds` | -1 | LEGACY_KEEP |

Absence primárního klíče není automaticky chyba.

Je však nutné rozlišit:

- záměrnou heap/work tabulku,
- importní dočasnou tabulku,
- historický legacy objekt,
- skutečnou integritní mezeru.

### 10.3 Cizí klíče a aplikační integrita

Cizí klíče jsou důležité zejména pro:

- canonical entity,
- provider mapy,
- vazby článků,
- statistiky osob,
- Ticket Engine,
- dokumentační vazby.

Ne každé pravidlo musí být vynuceno cizím klíčem. Pokud je integrita záměrně ponechána aplikační vrstvě, musí to být zdokumentováno v `MM-DB-006`.

### 10.4 Databázové a aplikační závislosti

A33 zachycuje relační závislosti z PostgreSQL katalogů.

Před změnou nebo odstraněním objektu musí být ověřeno také:

- vyhledání názvu v Git repozitáři,
- panelové SQL dotazy,
- workery a parsery,
- cron a plánovače,
- views a funkce,
- externí exporty,
- dokumentace,
- případné ruční provozní postupy.

### 10.5 Triggery

Triggery jsou koncentrovány zejména v `public` a `ops`.

Každý trigger musí mít:

- dokumentovaný účel,
- známou funkci,
- známý dopad na insert/update/delete,
- test opakovaného běhu,
- vazbu na migraci,
- známý rollback.

### Závěr kapitoly

Kapitola shrnula integritní mechanismy a oddělila databázové závislosti od aplikačních. Přínosem je bezpečný postup před změnou objektu nebo klíče. Návaznost pokračuje kapacitou a výkonem.

---

## 11. Kapacita, výkon a údržba

### 11.1 Největší objekty

| Pořadí | Objekt | Typ | Odhad řádků | Velikost | Governance |
|---:|---|---|---:|---:|---|
| 1 | `staging.api_football_fixtures` | TABLE | 184158 | 254 MB | LEGACY_KEEP |
| 2 | `public.matches` | TABLE | 121911 | 63 MB | ACTIVE_MASTER |
| 3 | `staging.api_football_leagues` | TABLE | 40345 | 41 MB | LEGACY_KEEP |
| 4 | `public.context_entity_registry` | TABLE | 156283 | 36 MB |  |
| 5 | `public.api_raw_payloads` | TABLE | 1740 | 35 MB | ACTIVE_REVIEW |
| 6 | `staging.stg_provider_player_season_stats` | TABLE | 110319 | 29 MB | ACTIVE_MASTER |
| 7 | `staging.stg_media_articles` | TABLE | 486 | 26 MB | ACTIVE_MASTER |
| 8 | `public.mm_match_ratings` | TABLE | 106401 | 25 MB | ACTIVE_MASTER |
| 9 | `staging.stg_provider_fixtures` | TABLE | 98090 | 24 MB | ACTIVE_MASTER |
| 10 | `staging.stg_api_payloads` | TABLE | 1750 | 19 MB | ACTIVE_MASTER |
| 11 | `public.odds` | TABLE | 82386 | 15 MB | ACTIVE_MASTER |
| 12 | `staging.stg_provider_players` | TABLE | 19432 | 6864 kB | ACTIVE_MASTER |
| 13 | `public.players` | TABLE | 19493 | 5568 kB | ACTIVE_MASTER |
| 14 | `staging.players_import` | TABLE | 2745 | 4832 kB | LEGACY_KEEP |
| 15 | `public.league_standings` | TABLE | 8806 | 4408 kB | ACTIVE |

### 11.2 Koncentrace dat

Přibližně 63.2 % velikosti je ve `staging`.

Největší jediný objekt, `staging.api_football_fixtures`, tvoří přibližně 38.7 % celé databáze.

Tato koncentrace znamená, že plán retence, záloh a migrace staging vrstvy má větší dopad než optimalizace mnoha malých `ops` tabulek.

### 11.3 Indexy

Audit vytvořil 108 informačních nálezů, kde indexy přesahují dvojnásobek velikosti dat tabulky.

U malých tabulek je tento poměr často přirozený kvůli minimální velikosti indexových stránek.

Proto se nesmí index automaticky odstranit pouze podle poměru velikostí.

Výkonový audit musí kombinovat:

- `pg_stat_user_indexes`,
- skutečné čtení a zápisy,
- query plans,
- selektivitu,
- velikost tabulky,
- frekvenci údržby,
- dopad na ingest a merge.

### 11.4 ANALYZE a statistiky

A33 vytvořil 44 nálezů `ANALYZE_NOT_RECORDED`.

Jde o screening podle auditovaných statistik, nikoli důkaz, že autovacuum nebo analyze nefunguje v celé instanci.

Následný audit musí ověřit:

- autovacuum nastavení,
- `pg_stat_all_tables`,
- čas posledního analyze,
- statistické targety,
- dlouhé transakce,
- bloat,
- dead tuples,
- plán údržby.

### 11.5 Materialized views a partitioning

Audit nepotvrdil žádné materialized views ani partitioned tables v exportovaném souhrnu.

To neznamená, že musí být okamžitě zavedeny.

Partitioning je vhodné zvažovat až podle:

- dlouhodobého růstu,
- retenční politiky,
- časových filtrů,
- nákladů na vacuum,
- rychlosti mazání a archivace,
- konkrétních query plans.

### Závěr kapitoly

Kapitola identifikovala hlavní kapacitní koncentraci ve staging vrstvě a vysvětlila, proč informační nálezy o indexech nejsou automatickou chybou. Přínosem je datově podložený základ pro `MM-DB-008`. Návaznost pokračuje governance a životním cyklem objektů.

---

## 12. Governance a životní cyklus objektů

### 12.1 Pokrytí

| Metrika | Hodnota |
|---|---:|
| Auditované objekty | 1115 |
| Governance záznamy | 540 |
| Jednoznačné shody | 540 |
| Nejednoznačné shody | 0 |
| Bez přesné shody | 575 |
| Přímé pokrytí | 48.4 % |

### 12.2 Interpretace nepokrytých objektů

575 objektů bez přesné governance shody neznamená automaticky 575 chyb.

Mezi nepokrytými objekty mohou být:

- sekvence,
- views,
- novější objekty,
- dokumentační objekty,
- pracovní objekty,
- objekty s odlišnou klasifikační politikou.

Přesto jde o významnou dokumentační mezeru, kterou musí rozlišit `MM-DB-002`.

### 12.3 Povolené governance stavy

Základní význam aktuálně používaných stavů:

| Governance stav | Význam |
|-----------------|---|
| ACTIVE_MASTER   | Hlavní aktivní objekt a zdroj pravdy ve své oblasti |
| ACTIVE          | Aktivní podpůrný objekt |
| ACTIVE_REVIEW   | Aktivní objekt čekající na další ověření |
| ACTIVE_PANEL    | Objekt aktivně používaný panelem |
| LEGACY_KEEP     | Historický nebo přechodový objekt, který se zatím musí zachovat |
| DROP_CANDIDATE  | Kandidát k odstranění po úplném dependency auditu |

### 12.4 Screening versus rozhodnutí

A33 vytvořil 57 nálezů `LEGACY_OR_DEPRECATED_OBJECT`.

Tento kód je screening založený na názvu, komentáři nebo governance textu.

Některé nálezy mohou být falešně pozitivní. Například samotný governance registr může obsahovat slovo „legacy“ ve svém popisu, aniž by byl legacy objektem.

Proto platí:

```text
A33 nález
→ ruční klasifikace
→ dependency audit
→ návrh změny
→ schválení
→ migrační skript
→ validace
→ teprve potom odstranění nebo přejmenování
```

### 12.5 Zákaz neřízeného mazání

Žádný objekt nesmí být odstraněn pouze proto, že:

- obsahuje suffix `_v1`,
- má nízký počet řádků,
- je bez PK,
- je označen `LEGACY_KEEP`,
- má velké indexy,
- je uveden v HIGH nálezu A33.

### Závěr kapitoly

Kapitola vysvětlila governance pokrytí i omezení automatického screeningu. Přínosem je ochrana před chybnou interpretací 226 auditních nálezů jako 226 potvrzených vad. Návaznost pokračuje bezpečností a oprávněními.

---

## 13. Bezpečnost, vlastníci a oprávnění

### 13.1 Vlastnictví

Všech pět auditovaných schémat vlastní databázový uživatel `matchmatrix`.

Jednotný vlastník zjednodušuje provoz, ale může zvyšovat dopad kompromitace nebo chybného skriptu.

### 13.2 Oprávnění

Audit exportoval 7679 grant záznamů.

Tento počet není počtem uživatelů ani rolí. Je to počet jednotlivých oprávnění nad objekty.

Detailní bezpečnostní dokumentace musí určit:

- používané role,
- vlastníky,
- aplikace a workery,
- read-only účty,
- migrační účet,
- dokumentační účet,
- minimální potřebná oprávnění,
- rotaci hesel,
- audit přístupů.

### 13.3 Zásada nejmenších oprávnění

Aplikace, worker nebo reportovací nástroj smí mít pouze oprávnění nutná pro svou úlohu.

Doporučené rozdělení:

- read-only konzument,
- ingest writer do staging,
- merge writer do public,
- ops runtime writer,
- dokumentační importer,
- migrace/DDL správce.

### 13.4 Secrets

Hesla a connection strings nesmějí být ukládány:

- v Markdown dokumentech,
- v Git commitech,
- v panelových screenshotech,
- v nešifrovaných exportech,
- v hard-coded produkčních skriptech.

A33 heslo v reportu maskuje a audit běží read-only.

### 13.5 Veřejná rozhraní

Budoucí web nebo veřejné API nesmí používat vlastnický účet `matchmatrix`.

Musí používat omezenou roli nad schválenými views nebo explicitní API vrstvou.

### Závěr kapitoly

Kapitola vymezila vlastnictví, granty a zásadu nejmenších oprávnění. Přínosem je základ pro samostatný bezpečnostní dokument `MM-DB-010`. Návaznost pokračuje provozem, zálohami a obnovou.

---

## 14. Provoz, zálohy a obnova

### 14.1 Provozní role PC2

Produkční databáze je provozována na PC2 a auditována přes `localhost:5432`.

PC2 plní zejména:

- databázový provoz,
- harvest,
- ingest,
- dlouhé workery,
- dokumentační import,
- auditní a kontrolní úlohy.

### 14.2 Zálohovací požadavky

Databázová architektura musí mít zdokumentováno:

- typ zálohy,
- frekvenci,
- retenci,
- cílové umístění,
- šifrování,
- kontrolu dokončení,
- ověření konzistence,
- obnovovací test,
- odpovědnou osobu,
- ochranu mimo PC2.

### 14.3 Obnova

Záloha není považována za ověřenou bez úspěšného restore testu.

Musí existovat postup pro:

- obnovu celé databáze,
- obnovu vybraného schématu,
- obnovu vybrané tabulky,
- návrat chybné migrace,
- obnovu na náhradní zařízení,
- ověření aplikace po obnově.

### 14.4 Read-only audity

A33 je příkladem bezpečného provozního auditu:

- transakce `READ ONLY`,
- izolace `REPEATABLE READ`,
- statement timeout,
- lock timeout,
- rollback po dokončení,
- žádná databázová změna.

Tento vzor má být používán i pro další inventarizační a diagnostické nástroje.

### Závěr kapitoly

Kapitola stanovila provozní a obnovovací rámec. Přínosem je oddělení inventarizačního auditu od změnových nástrojů a požadavek na ověřenou obnovu. Návaznost pokračuje riziky a otevřenými otázkami.

---

## 15. Rizika, výjimky a otevřené otázky

### 15.1 Hlavní architektonická rizika

| Riziko | Závažnost | Stav | Opatření |
|---|---|---|---|
| Největší tabulka je provider-specific `LEGACY_KEEP` | HIGH | DB VERIFIED | Dependency audit a migrační plán |
| 575 objektů bez přesné governance shody | HIGH | DB VERIFIED | Katalog a klasifikace v MM-DB-002 |
| 14 tabulek bez primárního klíče | MEDIUM/HIGH | DB VERIFIED | Individuální posouzení v MM-DB-006 |
| Raw/payload odpovědnost je částečně v `public` | HIGH | DB VERIFIED | Vyjasnit cílový model a závislosti |
| Runtime není samostatné fyzické schéma | MEDIUM | DB VERIFIED | Sjednotit terminologii dokumentace |
| Velký počet verzovaných ops views | MEDIUM | DB VERIFIED | Governance, náhrady a dependency audit |
| Stejný název objektu ve více schématech | HIGH | DB VERIFIED | Povinné kvalifikované názvy |
| 44 screening nálezů analyze | MEDIUM | REQUIRES AUDIT | Samostatný maintenance audit |
| Chybějící formální restore test | CRITICAL | DOCUMENTED GAP | Vytvořit MM-DB-009 a provést test |
| Jediný vlastník všech schémat | HIGH | DB VERIFIED | Role model a least privilege |

### 15.2 Auditní nálezy

| Závažnost | Počet |
|---|---:|
| HIGH | 60 |
| MEDIUM | 56 |
| INFO | 110 |
| Celkem | 226 |

Nálezy nejsou automaticky potvrzené vady.

Musí být přezkoumány podle kódu, governance, datového toku a aplikačních závislostí.

### 15.3 Otevřené otázky

- Které z 575 nepokrytých objektů musí být součástí governance registru?
- Které legacy `api_*` tabulky jsou stále čteny workery?
- Jaký je cílový osud `public.api_raw_payloads`?
- Které views mají stabilní veřejný kontrakt?
- Které `_v1`, `_v2`, `_v3` views lze bezpečně archivovat?
- Které tabulky bez PK jsou záměrné?
- Jaký je aktuální role model?
- Kdy proběhl poslední restore test?
- Které největší tabulky potřebují retenci nebo partitioning?
- Jak se verzují databázové migrace?
- Které DB objekty jsou přímo používány panelem a webem?
- Které databázové objekty jsou reprezentovány v MM-DB-002?

### Závěr kapitoly

Kapitola převedla auditní nálezy do řízeného seznamu rizik a otázek. Přínosem je priorizace bez automatických zásahů do databáze. Návaznost pokračuje plánem navazující dokumentace a rozvoje.

---

## 16. Cílový rozvoj databázové dokumentace

### 16.1 Navazující dokumenty

| Document ID | Název | Úloha |
|---|---|---|
| MM-DB-002 | Katalog schémat a databázových objektů | Úplná inventura objektů, stavů a vlastníků |
| MM-DB-003 | Canonical Entity Model MatchMatrix | Entity, identity a hlavní vazby |
| MM-DB-004 | Raw, staging, merge a public datový tok | Detailní pipeline a transformační hranice |
| MM-DB-005 | Standard názvosloví databázových objektů | Normativní pravidla názvů |
| MM-DB-006 | Primární klíče, vazby, constraints a integrita | Integritní model |
| MM-DB-007 | Migrace a verzování databázového schématu | Reprodukovatelné změny |
| MM-DB-008 | Indexy, výkon a partitioning | Výkonový model |
| MM-DB-009 | Zálohování, obnova a retence | Provozní odolnost |
| MM-DB-010 | Databázová bezpečnost a přístupová práva | Role a least privilege |
| MM-DB-011 | Databázové audity a kvalita dat | Kontrolní framework |
| MM-DB-012 | Databázový slovník MatchMatrix | Význam objektů a sloupců |

### 16.2 Bezprostřední další krok

Po schválení `MM-DB-001` má vzniknout `MM-DB-002`.

Jeho zdrojem budou:

- A33 JSON,
- A33 CSV exporty,
- governance registr,
- Git vyhledání aplikačních závislostí,
- ruční klasifikace objektů bez governance shody.

### 16.3 Aktualizace tohoto dokumentu

`MM-DB-001` musí být aktualizován při:

- přidání nebo odstranění fyzického schématu,
- změně odpovědnosti schématu,
- zavedení samostatné raw nebo runtime vrstvy,
- významné změně canonical modelu,
- změně PostgreSQL major verze,
- významné změně datového toku,
- schválení nové databázové bezpečnostní nebo migrační architektury.

### 16.4 Kritérium dokončení verze 1.0

Verze 1.0 může být schválena, pokud:

- A17 nemá FAIL ani PARTIAL,
- terminologie je ručně potvrzena,
- dokument je uložen kanonicky,
- Git commit a push jsou dokončeny,
- A24 VALIDATE_ONLY je úspěšný,
- A24 APPLY je úspěšný,
- A7 skončí `VERIFIED`,
- index MM-DB-1000 je aktualizován na nový stav dokumentu.

### Závěr kapitoly

Kapitola určila navazující dokumenty a podmínky dokončení. Přínosem je přechod od architektonického přehledu k úplnému katalogu a normativním standardům. Návaznost pokračuje závěrem dokumentu.

---

## Související dokumenty

- MM-DB-1000 – Index databázové dokumentace MatchMatrix
- MM-DOC-001 – Mapa dokumentačních oblastí MatchMatrix
- MM-DOC-200 – Governance MatchMatrix
- MM-DOC-300 – Architektura MatchMatrix
- MM-DOC-800 – Development Handbook MatchMatrix
- MM-STD-001 – Standard tvorby hlavních dokumentů
- MM-STD-003 – Standard životního cyklu dokumentace a verzování
- MM-STD-004 – Standard názvosloví a struktury dokumentace
- MM-STD-006 – Standard terminologie a slovníku pojmů
- MM-STD-007 – Identifikace a číslování dokumentů MatchMatrix
- MM-STD-009 – AI Context a Project Snapshot
- MM-REF-001 – Slovník pojmů MatchMatrix

### Závěr kapitoly

Kapitola shrnula dokumenty, které tvoří normativní, architektonický a terminologický rámec databázové dokumentace MatchMatrix. Přínosem je jednoznačná dohledatelnost pravidel a souvislostí, ze kterých dokument vychází. Návaznost pokračuje přehledem zdrojových auditních artefaktů.

---

## Zdrojové auditní artefakty

- `reports/documentation/database_audit/database_structure_audit_20260714_111917.json`
- `reports/documentation/database_audit/database_structure_audit_20260714_111917.md`
- `reports/documentation/database_audit/database_structure_schemas_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_objects_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_columns_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_constraints_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_indexes_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_routines_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_triggers_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_dependencies_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_privileges_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_governance_20260714_111917.csv`
- `reports/documentation/database_audit/database_structure_warnings_20260714_111917.csv`

### Závěr kapitoly

Kapitola uvedla úplnou sadu auditních artefaktů použitých pro ověření databázové architektury. Přínosem je reprodukovatelnost, kontrolovatelnost a možnost zpětně ověřit všechna hlavní tvrzení dokumentu. Návaznost směřuje k navazujícímu katalogu databázových objektů MM-DB-002.

## Závěr dokumentu

Databáze MatchMatrix je vícevrstvý PostgreSQL systém s pěti fyzickými schématy:

- `staging`,
- `public`,
- `ops`,
- `documentation`,
- `work`.

Ověřený stav potvrzuje:

- silnou canonical vrstvu v `public`,
- objemově dominantní staging vrstvu,
- rozsáhlou řídicí a dashboardovou vrstvu v `ops`,
- samostatnou řízenou dokumentační databázi,
- dočasné pracovní množiny v `work`,
- přechod mezi staršími provider-specific objekty a sjednoceným `stg_*` modelem.

Nejdůležitější architektonické závěry jsou:

1. `public` je canonical zdroj pravdy.
2. `staging` nesmí být přímým produktovým kontraktem.
3. `ops` je control plane a read-model vrstva.
4. `documentation` je oddělená znalostní vrstva.
5. `work` nesmí přerůst v neřízenou produkční vrstvu.
6. Raw a runtime jsou nyní logické odpovědnosti, nikoli samostatná schémata.
7. Legacy a auditní nález nejsou automatickým pokynem k odstranění.
8. Každá změna musí mít dependency audit, migraci, validaci a rollback.
9. Plně kvalifikované názvy jsou povinné.
10. Dalším krokem je úplný katalog `MM-DB-002`.

Tento dokument vytváří první ověřený architektonický základ databázové dokumentace MatchMatrix.

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---|---:|---|---|
| 0.9 | 2026-07-14 | REVIEW | První ověřená TECH verze vytvořená z read-only auditu A33 |

---

*Konec dokumentu MM-DB-001.*
