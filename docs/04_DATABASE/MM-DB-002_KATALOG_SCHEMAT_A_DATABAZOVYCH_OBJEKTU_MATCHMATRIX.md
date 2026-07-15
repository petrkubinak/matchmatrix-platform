# KATALOG SCHÉMAT A DATABÁZOVÝCH OBJEKTŮ MATCHMATRIX

**Document ID:** `MM-DB-002`  
**Edice:** MM-DOC TECH

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DB-002 |
| Document ID | MM-DB-002 |
| Název dokumentu | Katalog schémat a databázových objektů MatchMatrix |
| Typ dokumentu | DATABASE_OBJECT_CATALOG |
| Dokumentační oblast | 04_DATABASE |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-15 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Primární formát | Markdown (.md) |
| Cílové umístění | `docs/04_DATABASE/MM-DB-002_KATALOG_SCHEMAT_A_DATABAZOVYCH_OBJEKTU_MATCHMATRIX.md` |
| Nadřazený index | MM-DB-1000 |
| Nadřazená dokumentační mapa | MM-DOC-001 |
| Architektonický základ | MM-DB-001 |
| Auditní nástroj | 25_1_A_33 v1.0 |
| Auditní snapshot | 2026-07-14T09:19:17.812347+00:00 |
| Auditovaná databáze | `matchmatrix` |
| Auditovaný databázový server | PostgreSQL 16.14 |
| Auditní režim | READ ONLY / REPEATABLE READ / ROLLBACK |
| Auditní Git commit | `62433559998916901299959ce1d8566cfa03b7be` |
| Auditní JSON SHA-256 | `feaa7c5fd92e21071528a3c1f4ecdd837e86237c51171de32e03b98c79edadd0` |
| Objektový CSV SHA-256 | `2e324dd855821d83fabc5c60fa4026f7bde3a5677094881f7850cfcdc281ad29` |
| Počet katalogizovaných objektů | 1 115 |
| Související standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-009 |
| Zdroj pravdy | A33 JSON + aktuální PostgreSQL + Git + řízená dokumentační databáze |

---

## Úvod

### Účel dokumentu

Tento dokument představuje úplný katalog fyzických schémat a hlavních databázových objektů zachycených read-only auditem A33.

Katalog plní čtyři základní úlohy:

- eviduje všech 1 115 objektů typu TABLE, VIEW a SEQUENCE,
- odděluje fyzické schéma od funkční vrstvy a životního cyklu objektu,
- propojuje objekty s dostupnými governance metadaty, doménami a vlastnickými vrstvami,
- vytváří referenční podklad pro dependency audit, čištění legacy objektů, další databázovou dokumentaci a budoucí automatizaci.

Dokument nenahrazuje detailní datový slovník sloupců ani kompletní katalog constraints, indexů, oprávnění a závislostí. Tyto oblasti mají vlastní navazující dokumenty v řadě MM-DB.

### Rozsah

Katalog pokrývá pět fyzických schémat:

- `staging`,
- `public`,
- `ops`,
- `documentation`,
- `work`.

Součástí dokumentu jsou také samostatné úplné registry:

- 95 rutin,
- 23 triggerů,
- 226 auditních nálezů.

### Důležité omezení

Katalog je snapshot stavu databáze k `2026-07-14T09:19:17.812347+00:00`.

Odhady řádků vycházejí ze statistik PostgreSQL. Nejde o plné `COUNT(*)`.

Governance klasifikace je úplná pouze u objektů spárovaných s registrem `ops.database_object_governance`. Nezařazený objekt nesmí být automaticky považován za nepotřebný.

Označení `DROP_CANDIDATE` není povolením k odstranění. Před změnou je povinný audit databázových závislostí, Git repozitáře, panelu, workerů a plánovaných úloh.

### Závěr kapitoly

Úvod vymezil účel, rozsah a bezpečnostní omezení katalogu. Přínosem je oddělení úplné evidence objektů od jejich budoucího technického čištění. Návaznost pokračuje důkazním základem a pravidly klasifikace.

---

## 1. Důkazní základ a pravidla důvěryhodnosti

### 1.1 Primární zdroje

| Zdroj | Úloha |
|---|---|
| `database_structure_audit_latest.json` | Strojový zdroj pravdy pro katalog |
| `database_structure_objects_*.csv` | Objektový export všech TABLE, VIEW a SEQUENCE |
| `database_structure_routines_*.csv` | Úplný seznam rutin |
| `database_structure_triggers_*.csv` | Úplný seznam triggerů |
| `database_structure_governance_*.csv` | Governance registr zachycený v okamžiku auditu |
| `database_structure_warnings_*.csv` | Auditní nálezy a rizikové signály |
| MM-DB-001 | Architektonický význam schémat a datových toků |
| MM-DB-1000 | Pořadí a plán databázové dokumentace |
| Git repozitář | Implementační definice, workery, panel a SQL |
| PostgreSQL `matchmatrix` | Zdroj pravdy pro fyzickou existenci objektů |

### 1.2 Pořadí důvěryhodnosti

```text
aktuální PostgreSQL
→ reprodukovatelný A33 audit
→ aktuální Git definice a použití
→ schválená řízená dokumentace
→ governance registr
→ historické dokumenty a pracovní poznámky
```

Governance registr poskytuje důležitý kontext, ale nemůže sám přepsat skutečnou fyzickou existenci objektu ani aktuální použití v kódu.

### 1.3 Integrita zdrojového auditu

| Artefakt | SHA-256 |
|---|---|
| A33 JSON | `feaa7c5fd92e21071528a3c1f4ecdd837e86237c51171de32e03b98c79edadd0` |
| A33 Markdown | `c8824afddd1459f4d6bc2dcd71fcc3aff881505b6ccf1b4ae5e0a139f4e2a49c` |
| Objekty CSV | `2e324dd855821d83fabc5c60fa4026f7bde3a5677094881f7850cfcdc281ad29` |
| Governance CSV | `d19e6f1a422b66b3aa312de86204ac679458dec5ca053df5a7931ae413c60c01` |
| Varování CSV | `f4c7171c0f6a6ef7a32fc95843b2f998b3fb23a2241f9b566631f02e59cd730a` |

### Závěr kapitoly

Kapitola stanovila zdroje, pořadí důvěryhodnosti a kryptografickou dohledatelnost auditu. Přínosem je reprodukovatelnost katalogu. Návaznost pokračuje katalogizačním modelem.

---

## 2. Katalogizační model

### 2.1 Oddělené klasifikační osy

Každý objekt je posuzován nejméně ve čtyřech osách:

| Osa | Význam |
|---|---|
| Fyzické schéma | Skutečné umístění v PostgreSQL |
| Primární role | STAGING, PUBLIC/CANONICAL, OPERATIONAL, DOCUMENTATION nebo WORK |
| Governance stav | ACTIVE_MASTER, ACTIVE, ACTIVE_PANEL, ACTIVE_REVIEW, LEGACY_KEEP, DROP_CANDIDATE nebo UNCLASSIFIED |
| Funkční doména | PEOPLE, MEDIA, ODDS, PROVIDER, TICKETS, RUNTIME a další domény z governance registru |

Tyto osy se nesmějí zaměňovat. Objekt v `public` není automaticky potvrzený master objekt. Objekt s názvem obsahujícím verzi není automaticky legacy. Objekt bez governance shody není automaticky nepoužívaný.

### 2.2 Primární role podle fyzického schématu

| Schéma | Primární role | Tabulky | Views | Sekvence | Funkce | Velikost | Účel |
|---|---|---|---|---|---|---|---|
| `staging` | STAGING | 31 | 5 | 21 | 0 | 415 MB | Vstupní, providerová, importní a normalizační vrstva. Uchovává příchozí a mezistupňová data před jejich řízeným sloučením. |
| `public` | PUBLIC / CANONICAL | 131 | 100 | 108 | 68 | 215 MB | Produktová a canonical vrstva. Obsahuje oficiální entity, mapování, analytická data a veřejné pohledy používané dalšími částmi platformy. |
| `ops` | OPERATIONAL / GOVERNANCE | 111 | 488 | 100 | 26 | 18 MB | Provozní, auditní, plánovací, governance a panelová vrstva. Řídí pracovní fronty, kontroly, doporučení a provozní dohled. |
| `documentation` | DOCUMENTATION | 7 | 3 | 7 | 1 | 8648 kB | Řízená databázová vrstva dokumentace a znalostí projektu MatchMatrix. |
| `work` | WORK / TEMPORARY | 3 | 0 | 0 | 0 | 848 kB | Dočasné pracovní množiny a pomocné tabulky. Nejde o dlouhodobý canonical zdroj pravdy. |

### 2.3 Governance stavy

| Governance stav | Výklad |
|---|---|
| ACTIVE_MASTER | Referenční nebo hlavní aktivní objekt podle governance registru |
| ACTIVE | Aktivně používaný objekt |
| ACTIVE_PANEL | Objekt používaný řídicím nebo dokumentačním panelem |
| ACTIVE_REVIEW | Aktivní objekt, jehož role nebo cílový stav vyžaduje další kontrolu |
| LEGACY_KEEP | Starší objekt, který se do dependency auditu zachovává |
| DROP_CANDIDATE | Kandidát k odstranění až po úplném dependency auditu |
| UNCLASSIFIED | Objekt bez jednoznačné shody v governance registru |

### 2.4 Povinné pravidlo bezpečné změny

```text
nález nebo návrh
→ ověření fyzického objektu
→ databázové závislosti
→ Git vyhledání
→ worker a panel usage
→ provozní plánovače
→ náhrada a migrační cesta
→ schválení
→ řízená změna
→ audit po změně
```

### Závěr kapitoly

Kapitola definovala víceosý katalogizační model a zabránila zjednodušenému hodnocení objektů podle jediného atributu. Přínosem pro projekt je jednotný způsob rozlišení fyzického umístění, primární role, governance stavu a funkční domény každého databázového objektu. Návaznost pokračuje ověřeným fyzickým snapshotem.

---

## 3. Ověřený fyzický snapshot

### 3.1 Souhrn databáze

| Metrika | Ověřená hodnota |
|---|---:|
| Schémata | 5 |
| Objekty TABLE/VIEW/SEQUENCE | 1 115 |
| Tabulky | 283 |
| Views | 596 |
| Materialized views | 0 |
| Sekvence | 236 |
| Sloupce | 12 257 |
| Constraints | 603 |
| Indexy | 856 |
| Rutiny | 95 |
| Triggery | 23 |
| Závislosti | 747 |
| Oprávnění | 7 679 |
| Celková velikost | 656.52 MB |
| Auditní nálezy | 226 |

### 3.2 Typy hlavních objektů

| Typ objektu | Počet |
|---|---|
| VIEW | 596 |
| TABLE | 283 |
| SEQUENCE | 236 |

### 3.3 Rozložení podle schémat

| Schéma | Primární role | Tabulky | Views | Sekvence | Funkce | Velikost | Účel |
|---|---|---|---|---|---|---|---|
| `staging` | STAGING | 31 | 5 | 21 | 0 | 415 MB | Vstupní, providerová, importní a normalizační vrstva. Uchovává příchozí a mezistupňová data před jejich řízeným sloučením. |
| `public` | PUBLIC / CANONICAL | 131 | 100 | 108 | 68 | 215 MB | Produktová a canonical vrstva. Obsahuje oficiální entity, mapování, analytická data a veřejné pohledy používané dalšími částmi platformy. |
| `ops` | OPERATIONAL / GOVERNANCE | 111 | 488 | 100 | 26 | 18 MB | Provozní, auditní, plánovací, governance a panelová vrstva. Řídí pracovní fronty, kontroly, doporučení a provozní dohled. |
| `documentation` | DOCUMENTATION | 7 | 3 | 7 | 1 | 8648 kB | Řízená databázová vrstva dokumentace a znalostí projektu MatchMatrix. |
| `work` | WORK / TEMPORARY | 3 | 0 | 0 | 0 | 848 kB | Dočasné pracovní množiny a pomocné tabulky. Nejde o dlouhodobý canonical zdroj pravdy. |

### 3.4 Největší tabulky

| Objekt | Odhad řádků | Celkem | Data | Indexy | PK | Governance stav |
|---|---|---|---|---|---|---|
| `staging.api_football_fixtures` | 184 158 | 254 MB | 244 MB | 10184 kB | ANO | LEGACY_KEEP |
| `public.matches` | 121 911 | 63 MB | 16 MB | 48 MB | ANO | ACTIVE_MASTER |
| `staging.api_football_leagues` | 40 345 | 41 MB | 40 MB | 1256 kB | ANO | LEGACY_KEEP |
| `public.context_entity_registry` | 156 283 | 36 MB | 21 MB | 15 MB | ANO | UNCLASSIFIED |
| `public.api_raw_payloads` | 1 740 | 35 MB | 416 kB | 88 kB | ANO | ACTIVE_REVIEW |
| `staging.stg_provider_player_season_stats` | 110 319 | 29 MB | 15 MB | 15 MB | ANO | ACTIVE_MASTER |
| `staging.stg_media_articles` | 486 | 26 MB | 512 kB | 112 kB | ANO | ACTIVE_MASTER |
| `public.mm_match_ratings` | 106 401 | 25 MB | 19 MB | 6184 kB | ANO | ACTIVE_MASTER |
| `staging.stg_provider_fixtures` | 98 090 | 24 MB | 13 MB | 11 MB | ANO | ACTIVE_MASTER |
| `staging.stg_api_payloads` | 1 750 | 19 MB | 856 kB | 56 kB | ANO | ACTIVE_MASTER |
| `public.odds` | 82 386 | 15 MB | 5120 kB | 10 MB | ANO | ACTIVE_MASTER |
| `staging.stg_provider_players` | 19 432 | 6864 kB | 3696 kB | 3128 kB | ANO | ACTIVE_MASTER |
| `public.players` | 19 493 | 5568 kB | 2784 kB | 2744 kB | ANO | ACTIVE_MASTER |
| `staging.players_import` | 2 745 | 4832 kB | 4352 kB | 440 kB | NE | LEGACY_KEEP |
| `public.league_standings` | 8 806 | 4408 kB | 2688 kB | 1680 kB | ANO | ACTIVE |
| `public.player_provider_map` | 19 493 | 4152 kB | 2120 kB | 1992 kB | ANO | ACTIVE_MASTER |
| `documentation.document_sections` | 3 779 | 3696 kB | 1960 kB | 848 kB | ANO | UNCLASSIFIED |
| `public.match_features` | 26 746 | 3480 kB | 2632 kB | 808 kB | ANO | ACTIVE_MASTER |
| `ops.job_runs` | 2 030 | 3152 kB | 2496 kB | 192 kB | ANO | ACTIVE_MASTER |
| `ops.media_asset_enrichment_queue` | 12 250 | 3128 kB | 1696 kB | 1392 kB | ANO | ACTIVE |
| `documentation.document_versions` | 314 | 3024 kB | 512 kB | 968 kB | ANO | UNCLASSIFIED |
| `public.teams` | 9 773 | 2544 kB | 1016 kB | 1488 kB | ANO | ACTIVE_MASTER |
| `staging.api_football_teams` | 2 554 | 1904 kB | 1664 kB | 200 kB | ANO | LEGACY_KEEP |
| `staging.stg_provider_leagues` | 9 797 | 1832 kB | 1144 kB | 648 kB | ANO | ACTIVE_MASTER |
| `public.team_provider_map` | 9 510 | 1736 kB | 696 kB | 1000 kB | ANO | ACTIVE_MASTER |
| `staging.stg_provider_teams` | 6 859 | 1664 kB | 824 kB | 800 kB | ANO | ACTIVE_MASTER |
| `public.articles` | 363 | 1648 kB | 384 kB | 256 kB | ANO | ACTIVE_MASTER |
| `public.team_aliases` | 4 557 | 1496 kB | 352 kB | 1104 kB | ANO | ACTIVE |
| `ops.ingest_targets` | 4 428 | 1448 kB | 872 kB | 536 kB | ANO | ACTIVE_MASTER |
| `documentation.documents` | 312 | 1360 kB | 416 kB | 904 kB | ANO | UNCLASSIFIED |

### Závěr kapitoly

Kapitola vytvořila kvantitativní základ katalogu. Přínosem je jednotný ověřený snapshot všech fyzických schémat a hlavních objektových typů. Návaznost pokračuje jednotlivými schématy.

---

## 4. Schéma `staging`

### 4.1 Úloha

`staging` je vstupní a mezivrstvové schéma. Obsahuje provider-specific legacy struktury, sjednocené `stg_*` objekty, importní tabulky a payloadové struktury.

### 4.2 Ověřený stav

| Metrika | Hodnota |
|---|---:|
| Objekty | 57 |
| Tabulky | 31 |
| Views | 5 |
| Sekvence | 21 |
| Velikost | 415 MB |

### 4.3 Governance profil

| Governance stav | Počet |
|---|---|
| UNCLASSIFIED | 22 |
| ACTIVE_MASTER | 14 |
| ACTIVE_REVIEW | 11 |
| LEGACY_KEEP | 10 |

### 4.4 Hlavní interpretační pravidla

- objekty `stg_*` obecně představují cílovější sjednocenou staging architekturu,
- objekty `api_*` a importní pomocné tabulky mohou být přechodové,
- `LEGACY_KEEP` znamená zachovat do dependency auditu,
- staging tabulka bez primárního klíče může být legitimní, ale musí být výslovně odůvodněna,
- žádný staging objekt nesmí být považován za veřejný canonical zdroj pravdy.

### Závěr kapitoly

Kapitola vymezila roli a rizika schématu `staging`. Přínosem je oddělení aktivní sjednocené staging architektury od provider-specific legacy objektů. Návaznost pokračuje produktovou vrstvou `public`.

---

## 5. Schéma `public`

### 5.1 Úloha

`public` obsahuje canonical entity, provider mapování, produktové tabulky, analytické objekty a veřejné views. Jde o nejdůležitější datovou vrstvu pro web, API, analytiku a další produktové části platformy.

### 5.2 Ověřený stav

| Metrika | Hodnota |
|---|---:|
| Objekty | 339 |
| Tabulky | 131 |
| Views | 100 |
| Sekvence | 108 |
| Velikost | 215 MB |

### 5.3 Governance profil

| Governance stav | Počet |
|---|---|
| UNCLASSIFIED | 110 |
| ACTIVE | 108 |
| ACTIVE_MASTER | 67 |
| ACTIVE_REVIEW | 37 |
| LEGACY_KEEP | 17 |

### 5.4 Hlavní interpretační pravidla

- canonical zdroj pravdy musí být výslovně potvrzen governance stavem, architekturou nebo použitím,
- `public` může obsahovat i přechodové, analytické a pomocné objekty,
- verze views se nesmějí mazat pouze podle názvu,
- provider mapování je součástí identity a dohledatelnosti canonical entit,
- raw payloady umístěné v `public` jsou architektonickou výjimkou a musí zůstat popsány v MM-DB-001.

### Závěr kapitoly

Kapitola vymezila `public` jako produktovou a canonical vrstvu, ale současně zabránila automatickému označení všech jejích objektů za master. Přínosem pro projekt je bezpečné rozlišení skutečných canonical objektů od pomocných, analytických a přechodových struktur uložených ve stejném schématu. Návaznost pokračuje provozní vrstvou `ops`.
---

## 6. Schéma `ops`

### 6.1 Úloha

`ops` obsahuje plánovače, provozní registry, fronty, audity, dashboardy, governance objekty, doporučení panelu a více generací provozních views.

### 6.2 Ověřený stav

| Metrika | Hodnota |
|---|---:|
| Objekty | 699 |
| Tabulky | 111 |
| Views | 488 |
| Sekvence | 100 |
| Velikost | 18 MB |

### 6.3 Governance profil

| Governance stav | Počet |
|---|---|
| UNCLASSIFIED | 423 |
| ACTIVE_MASTER | 125 |
| ACTIVE | 94 |
| LEGACY_KEEP | 26 |
| ACTIVE_REVIEW | 15 |
| ACTIVE_PANEL | 14 |
| DROP_CANDIDATE | 2 |

### 6.4 Hlavní interpretační pravidla

- více verzí view může představovat řízený evoluční vývoj,
- `ACTIVE_PANEL` chrání objekty používané panelem,
- `DROP_CANDIDATE` vyžaduje ověření náhrady a všech závislostí,
- runtime odpovědnost je dnes realizována především v `ops`,
- názvy obsahující `legacy` nebo starší verzi jsou pouze signál, nikoli důkaz nepoužívání.

### Závěr kapitoly

Kapitola popsala `ops` jako nejrozsáhlejší provozní a governance vrstvu podle počtu objektů. Přínosem je bezpečný rámec pro budoucí konsolidaci verzovaných views. Návaznost pokračuje dokumentační databází.

---

## 7. Schéma `documentation`

### 7.1 Úloha

Schéma `documentation` spravuje řízené dokumenty, verze, sekce, vazby, historii stavů, importní běhy a dokumentační snapshoty.

### 7.2 Ověřený stav A33

| Metrika | Hodnota |
|---|---:|
| Objekty | 17 |
| Tabulky | 7 |
| Views | 3 |
| Sekvence | 7 |
| Velikost | 8648 kB |

### 7.3 Aktuální provozní snapshot po publikaci MM-DL a MM-NAV

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 331 |
| Verze dokumentů | 336 |
| Aktuální verze | 331 |
| Sekce | 4 046 |
| Vazby | 189 |
| Historie stavů | 336 |
| Importní běhy | 23 |
| Aktivní dokumenty | 331 |

Počty řádků se od auditního snapshotu A33 zvýšily, fyzická množina objektů schématu se tímto dokumentačním importem nezměnila.

### Závěr kapitoly

Kapitola oddělila fyzický katalog schématu od aktuálních provozních počtů dokumentační databáze. Přínosem je dohledatelnost růstu dokumentace bez záměny řádkových a strukturálních změn. Návaznost pokračuje pracovním schématem.

---

## 8. Schéma `work`

### 8.1 Úloha

`work` obsahuje dočasné pracovní množiny a pomocné tabulky. Jeho objekty nesmějí být používány jako dlouhodobý canonical zdroj pravdy.

### 8.2 Ověřený stav

| Metrika | Hodnota |
|---|---:|
| Objekty | 3 |
| Tabulky | 3 |
| Views | 0 |
| Sekvence | 0 |
| Velikost | 848 kB |

### 8.3 Kontrolní pravidla

- každý pracovní objekt musí mít vlastníka, účel a očekávaný konec životnosti,
- dlouhodobě používaný objekt musí být přesunut do odpovídajícího cílového schématu,
- absence primárního klíče může být u dočasného seznamu přípustná,
- před odstraněním musí být ověřeno, že jej nepoužívá pracovní skript nebo probíhající backfill.

### Závěr kapitoly

Kapitola vymezila pracovní schéma jako dočasnou vrstvu s omezenou životností. Přínosem je ochrana canonical architektury před trvalým používáním pomocných tabulek. Návaznost pokračuje governance pokrytím celého katalogu.

---

## 9. Governance pokrytí a životní cyklus

### 9.1 Pokrytí registru

| Metrika | Hodnota |
|---|---:|
| Řádky governance registru | 540 |
| Použitelné řádky | 540 |
| Spárované objekty | 540 |
| Nejednoznačné shody | 0 |
| Nespárované objekty | 575 |
| Pokrytí | 48.4 % |

### 9.2 Rozložení governance stavů

| Governance stav | Počet | Podíl |
|---|---|---|
| UNCLASSIFIED | 575 | 51.6 % |
| ACTIVE_MASTER | 206 | 18.5 % |
| ACTIVE | 202 | 18.1 % |
| ACTIVE_REVIEW | 63 | 5.7 % |
| LEGACY_KEEP | 53 | 4.8 % |
| ACTIVE_PANEL | 14 | 1.3 % |
| DROP_CANDIDATE | 2 | 0.2 % |

### 9.3 Legacy a drop kandidáti

| Kategorie | Počet | Povinné zacházení |
|---|---:|---|
| LEGACY_KEEP | 53 | Zachovat do úplného dependency auditu |
| DROP_CANDIDATE | 2 | Neodstraňovat bez náhrady, Git auditu a schválení |
| UNCLASSIFIED | 575 | Doplnit governance klasifikaci, nikoli automaticky mazat |

### 9.4 Aktuální drop kandidáti

| Objekt | Deklarovaná náhrada | Kontrolní poznámka |
|---|---|---|
| `ops.v_provider_routing_master` | ops.v_provider_routing_master_v2 | Kandidát na odstranění po kontrole závislostí v kódu, panelu a workerech. |
| `ops.v_sport_completion_dashboard_v1` | ops.v_sport_completion_dashboard_v2 | Kandidát na odstranění po kontrole závislostí v kódu, panelu a workerech. |

### Závěr kapitoly

Kapitola doložila, že governance registr pokrývá pouze část fyzických objektů. Přínosem je jasný plán: doplnit klasifikaci, nikoli interpretovat chybějící záznam jako důkaz nepotřebnosti. Návaznost pokračuje funkčními doménami a vrstvami.

---

## 10. Funkční domény a vlastnické vrstvy

### 10.1 Domény zachycené governance registrem

| Doména | Počet objektů |
|---|---|
| UNSPECIFIED | 680 |
| TICKETS | 48 |
| MEDIA | 46 |
| PEOPLE | 39 |
| PUBLIC | 32 |
| FOOTBALL | 27 |
| MATCH_FEED | 22 |
| PROVIDER | 17 |
| AI_OPS | 17 |
| RUNTIME | 15 |
| CORE | 13 |
| ML_MMR | 13 |
| PANEL | 11 |
| USERS | 9 |
| ML | 9 |
| REPAIR | 8 |
| INGEST | 7 |
| AUTONOMOUS | 7 |
| PUBLIC_VIEW | 7 |
| ODDS | 6 |
| TRANSLATION | 6 |
| LAUNCHER | 6 |
| HOCKEY | 5 |
| TENNIS | 5 |
| SPORT | 5 |
| WORKER | 5 |
| TEAM | 5 |
| STRATEGY | 5 |
| DISPATCH | 4 |
| DEVELOPMENT | 4 |
| OPS | 4 |
| COVERAGE | 4 |
| EXECUTION | 4 |
| LEARNING | 4 |
| governance | 3 |
| GOVERNANCE | 2 |
| API | 2 |
| DEPENDENCY | 2 |
| IMPLEMENTATION | 2 |
| BASKETBALL | 2 |
| STAGING | 1 |
| SCHEDULER | 1 |
| HARVEST | 1 |

### 10.2 Vlastnické vrstvy zachycené governance registrem

| Vlastnická vrstva | Počet objektů |
|---|---|
| UNSPECIFIED | 695 |
| Public Canonical Layer | 129 |
| Public View Layer | 100 |
| Staging Layer | 35 |
| Autonomous Layer | 15 |
| Runtime Layer | 9 |
| AI OPS Layer | 9 |
| Football Legacy Planning | 7 |
| Football Orchestration | 6 |
| Launcher Layer | 6 |
| Coverage Layer | 5 |
| Learning Layer | 5 |
| Execution Layer | 4 |
| Planner Layer | 3 |
| Dispatch Layer | 3 |
| OPS | 3 |
| People Layer | 3 |
| EU Batch Legacy | 2 |
| OPS Layer | 2 |
| Data Gap Layer | 2 |
| Orchestration Layer | 2 |
| Development Layer | 2 |
| Implementation Readiness Layer | 2 |
| Development Planning Layer | 2 |
| BK Orchestration Layer | 2 |
| Media Asset Enrichment | 1 |
| Target Layer | 1 |
| DB Governance | 1 |
| Player Match Stats Queue | 1 |
| Runtime Audit | 1 |
| Provider Coverage | 1 |
| Provider Jobs | 1 |
| Fix Tasks | 1 |
| Runtime History | 1 |
| Sport Entity Rules | 1 |
| Unified Worker Registry | 1 |
| FB People Priority Buckets | 1 |
| Media Discovery Candidates | 1 |
| Entity Plan Layer | 1 |
| AI Action Log | 1 |
| Brain Log | 1 |
| Dispatch Queue | 1 |
| Legacy League Plan | 1 |
| Media Discovery | 1 |
| Media Job Runs | 1 |
| Media Refresh Queue | 1 |
| Media Source Health | 1 |
| Player Enrichment | 1 |
| People Provider Audit | 1 |
| Provider Matrix | 1 |
| Provider Worker Registry | 1 |
| Scheduler Layer | 1 |
| Sports Import Plan | 1 |
| Dependency Graph | 1 |
| Worker Registry | 1 |
| Autonomous Queue | 1 |
| Development Queue | 1 |
| People Master Matrix | 1 |
| Sport Dimensions | 1 |
| API Budget | 1 |
| Repair Layer | 1 |
| Runtime Config | 1 |
| Provider Accounts | 1 |
| Coaches Checklist | 1 |
| Migration Layer | 1 |
| Sport Completion | 1 |
| Worker Capability | 1 |
| Execution Rules | 1 |
| Lock Layer | 1 |
| Active Runs | 1 |
| FB Entity Audit | 1 |
| Job Registry | 1 |
| Media Velocity | 1 |
| Repair Catalog | 1 |
| Repair Learning | 1 |
| Repair Reset Audit | 1 |
| API Request Log | 1 |
| EU Keep IDs | 1 |
| People Backfill | 1 |
| Provider Switching | 1 |
| Automation Layer | 1 |
| Harvest Layer | 1 |
| Ingest Layer | 1 |
| Job Runs Layer | 1 |
| Operations Center | 1 |
| Provider Routing Layer | 1 |
| Project Readiness Layer | 1 |

### 10.3 Interpretace

Hodnoty `UNSPECIFIED` neznamenají, že objekt nemá funkční význam. Znamenají pouze, že auditní governance záznam neobsahoval dané pole.

Doména a vlastnická vrstva mají být postupně doplněny zejména pro:

- canonical Core entity,
- People Layer,
- Media Layer,
- Odds Layer,
- provider a ingest objekty,
- Ticket Engine,
- runtime a autonomous operations,
- panelové a dokumentační objekty.

### Závěr kapitoly

Kapitola propojila fyzický katalog s funkčními doménami a vlastnickými vrstvami. Přínosem je základ pro budoucí ownership model a odpovědnost jednotlivých modulů. Návaznost pokračuje integritou a technickými riziky.

---

## 11. Integrita, primární klíče a technická rizika

### 11.1 Tabulky bez primárního klíče

| Tabulka | Odhad řádků | Velikost | Indexy | Governance stav | Primární role |
|---|---|---|---|---|---|
| `staging.api_hockey_leagues` | 524 | 656 kB | 2 | LEGACY_KEEP | LEGACY / REVIEW |
| `staging.api_hockey_leagues_raw` | 7 | 336 kB | 2 | ACTIVE_REVIEW | STAGING |
| `staging.api_hockey_teams` | 399 | 416 kB | 2 | LEGACY_KEEP | LEGACY / REVIEW |
| `staging.api_hockey_teams_raw` | 1 333 | 616 kB | 1 | ACTIVE_REVIEW | STAGING |
| `staging.player_provider_map_import` | -1 | 16 kB | 1 | LEGACY_KEEP | LEGACY / REVIEW |
| `staging.players_import` | 2 745 | 4832 kB | 5 | LEGACY_KEEP | LEGACY / REVIEW |
| `public.closing_odds` | -1 | 8192 bytes | 0 | LEGACY_KEEP | LEGACY / REVIEW |
| `public.unmatched_theodds` | 72 | 48 kB | 0 | LEGACY_KEEP | LEGACY / REVIEW |
| `public.work_pl_aliases` | -1 | 16 kB | 0 | LEGACY_KEEP | LEGACY / REVIEW |
| `ops.eu_batch_1` | 1 | 32 kB | 1 | LEGACY_KEEP | LEGACY / REVIEW |
| `ops.eu_batch_100` | 100 | 32 kB | 1 | LEGACY_KEEP | LEGACY / REVIEW |
| `ops.people_quality_backfill_queue` | -1 | 16 kB | 0 | ACTIVE | OPERATIONAL / GOVERNANCE |
| `work.missing_player_profile_batches` | 4 379 | 784 kB | 0 | UNCLASSIFIED | WORK / TEMPORARY |
| `work.missing_player_profile_ids` | 220 | 48 kB | 0 | UNCLASSIFIED | WORK / TEMPORARY |

Absence primárního klíče není automatická chyba u dočasné nebo čistě importní tabulky. U canonical, provozních a dlouhodobých tabulek však musí být explicitně odůvodněna.

### 11.2 Auditní nálezy podle závažnosti

| Závažnost | Počet |
|---|---|
| HIGH | 60 |
| MEDIUM | 56 |
| INFO | 110 |

### 11.3 Auditní nálezy podle kódu

| Kód | Počet |
|---|---|
| INDEXES_LARGER_THAN_TABLE | 108 |
| LEGACY_OR_DEPRECATED_OBJECT | 57 |
| ANALYZE_NOT_RECORDED | 44 |
| TABLE_WITHOUT_PRIMARY_KEY | 14 |
| OBJECTS_WITHOUT_GOVERNANCE_MATCH | 1 |
| SAME_OBJECT_NAME_IN_MULTIPLE_SCHEMAS | 1 |
| LARGE_DATABASE_OBJECT | 1 |

### 11.4 Interpretace nálezů

- `LEGACY_OR_DEPRECATED_OBJECT` je signál pro review, nikoli automatický drop.
- `TABLE_WITHOUT_PRIMARY_KEY` vyžaduje rozhodnutí podle role objektu.
- `ANALYZE_NOT_RECORDED` vyžaduje ověření statistik a autovacuum konfigurace.
- `INDEXES_LARGER_THAN_TABLE` je u malých tabulek často informační stav; u velkých objektů vyžaduje výkonovou kontrolu.
- `OBJECTS_WITHOUT_GOVERNANCE_MATCH` potvrzuje neúplné katalogizační pokrytí.
- `SAME_OBJECT_NAME_IN_MULTIPLE_SCHEMAS` vyžaduje kontextové rozlišení.
- `LARGE_DATABASE_OBJECT` vyžaduje kapacitní a provozní sledování.

### Závěr kapitoly

Kapitola oddělila technické signály od schválených změn. Přínosem je bezpečný kontrolní rámec pro další integritní, výkonové a dependency audity. Návaznost pokračuje pravidly používání katalogu.

---

## 12. Pravidla používání a aktualizace katalogu

### 12.1 Kdy se katalog aktualizuje

Katalog se aktualizuje po:

- vytvoření nebo odstranění schématu,
- přidání, přejmenování nebo odstranění databázového objektu,
- změně governance stavu,
- změně master replacement,
- významné migraci,
- dokončení dependency auditu,
- změně vlastnické vrstvy nebo domény,
- významném databázovém milestone.

### 12.2 Co se nesmí provádět ručně bez evidence

- mazání objektu bez SQL skriptu a auditu,
- přejmenování bez dopadové analýzy,
- změna governance stavu bez důvodu,
- označení objektu za master pouze podle názvu,
- použití `work` nebo `staging` jako veřejného zdroje pravdy,
- odstranění staršího view pouze proto, že existuje novější verze.

### 12.3 Vazba na navazující dokumenty

| Dokument | Oblast |
|---|---|
| MM-DB-003 | Datový slovník tabulek a sloupců |
| MM-DB-004 | Klíče, constraints a integrita |
| MM-DB-005 | Indexy, výkon a dependency audit |
| MM-DB-006 | Rutiny, procedury a triggery |
| MM-DB-007 | Datové toky a lineage |
| MM-DB-008 | Migrace a změnové řízení |
| MM-DB-009 | Bezpečnost a oprávnění |
| MM-DB-010 | Zálohování a obnova |
| MM-DB-011 | Databázové konvence a naming |
| MM-DB-012 | Auditní a provozní příručka |

### Závěr kapitoly

Kapitola stanovila pravidla aktualizace a bezpečného používání katalogu. Přínosem je ochrana katalogu jako živého řízeného zdroje, nikoli jednorázového exportu. Návaznost pokračuje plánem dalšího rozvoje.

---

## 13. Plán dalšího rozvoje objektového katalogu

### 13.1 Fáze 1 – schválení základního katalogu

- projít A17,
- vyřešit případné strukturální nálezy,
- schválit verzi 0.9 jako první řízený katalog,
- uložit do Git,
- importovat přes A24,
- ověřit A7.

### 13.2 Fáze 2 – governance completion

- doplnit 575 aktuálně nespárovaných objektů,
- přiřadit doménu,
- přiřadit vlastnickou vrstvu,
- rozlišit master, active, review a legacy,
- doplnit náhrady a migrační akce.

### 13.3 Fáze 3 – dependency audit

- databázové závislosti,
- použití v Pythonu,
- použití v SQL souborech,
- použití v panelu,
- použití v workerech,
- použití v plánovaných úlohách,
- použití ve webu a API.

### 13.4 Fáze 4 – řízená konsolidace

Teprve po dokončení předchozích fází lze navrhovat:

- odstranění potvrzených drop kandidátů,
- konsolidaci verzovaných views,
- migraci provider-specific staging,
- přesun nesprávně umístěných objektů,
- doplnění primárních klíčů,
- optimalizaci indexů a statistik.

### Závěr kapitoly

Kapitola stanovila čtyřfázový plán od schválení katalogu po bezpečnou konsolidaci databáze. Přínosem je zabránění předčasným zásahům. Návaznost pokračuje řídicím kontextem pro AI a další pracovní blok.

---

## 14. Řídicí kontext a pokračování

### AI CONTEXT

- Tento dokument je objektový katalog, nikoli migrační skript.
- Zdrojovým snapshotem je A33 z 2026-07-14.
- Produkční PostgreSQL běží v Dockeru jako `matchmatrix_postgres` na PC2.
- Windows služba `postgresql-x64-18` zůstává `Stopped / Disabled`.
- Hlavní Git repozitář je `C:\MatchMatrix-platform` na PC2.
- Poslední potvrzený Git commit po publikaci denního zápisu a NAV je `eaf05c1aa6d66145cf72fde7ad1e5ec7833e5acf`.
- A33 nález nesmí být automaticky převáděn na DROP.
- Práce pokračuje vždy po jednom jasném kroku.
- Před změnou databázového objektu je povinný dependency audit.
- Katalog musí zůstat reprodukovatelný z A33 JSON/CSV.
- Aktualizace fyzických objektů vyžaduje novou verzi dokumentu a nový auditní snapshot.

### PROJECT SNAPSHOT

| Oblast | Stav |
|---|---|
| MM-DB-001 | DOKONČENO, A24 APPLY, A7 VERIFIED |
| MM-DB-002 | DRAFT 0.9, připraven k prvotnímu A17 |
| A33 | DOKONČENO, read-only |
| Dokumentační databáze | 331 dokumentů, 336 verzí, 4 046 sekcí, 189 vazeb |
| Git | `main`, poslední potvrzený push `eaf05c1` |
| Produkční DB | Docker PostgreSQL 16 na PC2 |
| Governance pokrytí objektů | 540 z 1 115 |
| Hlavní otevřená oblast | klasifikace 575 nespárovaných objektů |

### DATABASE SNAPSHOT

| Ukazatel | Hodnota |
|---|---:|
| Schémata | 5 |
| Objekty | 1 115 |
| Tabulky | 283 |
| Views | 596 |
| Sekvence | 236 |
| Rutiny | 95 |
| Triggery | 23 |
| Závislosti | 747 |
| Velikost | 656.52 MB |

### CURRENT STATUS

Dokument obsahuje:

- úplný registr všech 1 115 hlavních objektů,
- úplný registr všech 95 rutin,
- úplný registr všech 23 triggerů,
- úplný registr všech 226 auditních nálezů,
- ověřené souhrny podle schémat, typů, governance stavů, domén a vrstev,
- bezpečnostní pravidla pro legacy a drop kandidáty,
- vazbu na navazující dokumentaci.

### OPEN QUESTIONS

1. Které z 575 nespárovaných objektů jsou aktivní master, active, review nebo legacy?
2. Které objekty skutečně používá panel Q3?
3. Které objekty používají aktivní workery a plánovače?
4. Které verze `ops.v_*_vN` jsou skutečně aktuální master?
5. Které provider-specific staging objekty lze po dependency auditu nahradit `stg_*` architekturou?
6. Které tabulky bez primárního klíče jsou záměrné?
7. Které indexy s nepoměrem vůči datům vyžadují optimalizaci?
8. Které governance domény a owner layers je nutné sjednotit terminologicky?

### NEXT STEP

**V Q3 panelu vytvořit pracovní blok pro `MM-DB-002`, vložit tento kompletní soubor a spustit pouze A17 – prvotní audit.**

### Závěr kapitoly

Kapitola předala kompletní AI, projektový a databázový kontext a určila jediný následující krok. Přínosem je bezpečné pokračování bez opakování již uzavřených auditů. Návaznost pokračuje úplnými katalogovými přílohami.

---

## Příloha A – úplný katalog TABLE, VIEW a SEQUENCE

Příloha obsahuje všech 1 115 objektů zachycených v datasetu `objects` auditu A33.

Hodnota `UNCLASSIFIED` znamená, že objekt neměl jednoznačnou shodu v auditovaném governance registru. Nejde o rozhodnutí o nepotřebnosti.

### A.1 Schéma `staging`

| Schéma | Objekty | Tabulky | Views | Sekvence |
|---|---:|---:|---:|---:|
| `staging` | 57 | 31 | 5 | 21 |

| Schéma | Objekt | Typ | Primární role | Governance stav | Doména | Vlastnická vrstva | Odhad řádků | Velikost | PK | FK | Indexy | Náhrada | Účel nebo poznámka |
|---|---|---|---|---|---|---|---:|---:|---|---:|---:|---|---|
| `staging` | `api_tennis_fixtures_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `api_tennis_fixtures_raw_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `api_tennis_leagues_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `api_tennis_leagues_raw_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_api_american_football_fixtures_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_api_american_football_teams_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_api_payloads_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_media_articles_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_player_photo_candidates_candidate_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_player_source_payloads_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_coaches_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_events_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_fixtures_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_leagues_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_odds_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_player_profiles_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_player_season_stats_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_player_stats_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_players_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_team_stats_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `stg_provider_teams_id_seq` | SEQUENCE | STAGING | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `staging` | `api_football_fixtures` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | Staging Layer | 184 158 | 254 MB | ANO | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_football_leagues` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | Staging Layer | 40 345 | 41 MB | ANO | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_football_odds` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | Staging Layer | -1 | 16 kB | ANO | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_football_teams` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | Staging Layer | 2 554 | 1904 kB | ANO | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_hockey_leagues` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | HOCKEY | Staging Layer | 524 | 656 kB | NE | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_hockey_leagues_raw` | TABLE | STAGING | ACTIVE_REVIEW | HOCKEY | Staging Layer | 7 | 336 kB | NE | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_hockey_teams` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | HOCKEY | Staging Layer | 399 | 416 kB | NE | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_hockey_teams_raw` | TABLE | STAGING | ACTIVE_REVIEW | HOCKEY | Staging Layer | 1 333 | 616 kB | NE | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_tennis_fixtures` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | TENNIS | Staging Layer | 87 | 344 kB | ANO | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_tennis_fixtures_raw` | TABLE | STAGING | ACTIVE_REVIEW | TENNIS | Staging Layer | 4 | 248 kB | ANO | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_tennis_leagues` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | TENNIS | Staging Layer | 5 | 96 kB | ANO | 0 | 5 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `api_tennis_leagues_raw` | TABLE | STAGING | ACTIVE_REVIEW | TENNIS | Staging Layer | 4 | 80 kB | ANO | 0 | 4 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `player_provider_map_import` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | PEOPLE | Staging Layer | -1 | 16 kB | NE | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `players_import` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | PEOPLE | Staging Layer | 2 745 | 4832 kB | NE | 0 | 5 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_api_american_football_fixtures` | TABLE | STAGING | ACTIVE_REVIEW | FOOTBALL | Staging Layer | 335 | 800 kB | ANO | 0 | 4 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_api_american_football_teams` | TABLE | STAGING | ACTIVE_REVIEW | FOOTBALL | Staging Layer | 34 | 104 kB | ANO | 0 | 3 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_api_payloads` | TABLE | STAGING | ACTIVE_MASTER | STAGING | Staging Layer | 1 750 | 19 MB | ANO | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_media_articles` | TABLE | STAGING | ACTIVE_MASTER | MEDIA | Staging Layer | 486 | 26 MB | ANO | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_player_photo_candidates` | TABLE | STAGING | UNCLASSIFIED |  |  | 2 | 80 kB | ANO | 0 | 4 |  | PHOTO discovery staging. Kandidátní fotografie hráčů z Wikimedia/Wikipedia/Wikidata. |
| `staging` | `stg_player_source_payloads` | TABLE | STAGING | ACTIVE_MASTER | PEOPLE | Staging Layer | 1 | 96 kB | ANO | 0 | 5 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_coaches` | TABLE | STAGING | ACTIVE_MASTER | PEOPLE | Staging Layer | 19 | 96 kB | ANO | 0 | 5 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_events` | TABLE | STAGING | ACTIVE_MASTER | CORE | Staging Layer | -1 | 16 kB | ANO | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_fixtures` | TABLE | STAGING | ACTIVE_MASTER | CORE | Staging Layer | 98 090 | 24 MB | ANO | 0 | 3 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_leagues` | TABLE | STAGING | ACTIVE_MASTER | CORE | Staging Layer | 9 797 | 1832 kB | ANO | 0 | 2 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_odds` | TABLE | STAGING | ACTIVE_MASTER | ODDS | Staging Layer | -1 | 16 kB | ANO | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_player_profiles` | TABLE | STAGING | ACTIVE_MASTER | PEOPLE | Staging Layer | 1 015 | 440 kB | ANO | 1 | 5 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_player_season_stats` | TABLE | STAGING | ACTIVE_MASTER | PEOPLE | Staging Layer | 110 319 | 29 MB | ANO | 0 | 6 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_player_stats` | TABLE | STAGING | ACTIVE_MASTER | PEOPLE | Staging Layer | -1 | 48 kB | ANO | 0 | 5 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_players` | TABLE | STAGING | ACTIVE_MASTER | PEOPLE | Staging Layer | 19 432 | 6864 kB | ANO | 0 | 6 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_team_stats` | TABLE | STAGING | ACTIVE_MASTER | CORE | Staging Layer | -1 | 16 kB | ANO | 0 | 1 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `stg_provider_teams` | TABLE | STAGING | ACTIVE_MASTER | CORE | Staging Layer | 6 859 | 1664 kB | ANO | 0 | 3 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `v_api_football_leagues_latest` | VIEW | STAGING | ACTIVE_REVIEW | FOOTBALL | Staging Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `v_api_football_leagues_latest_enriched` | VIEW | STAGING | ACTIVE_REVIEW | FOOTBALL | Staging Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `v_api_football_leagues_run103` | VIEW | STAGING | ACTIVE_REVIEW | FOOTBALL | Staging Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `v_api_hockey_leagues_latest` | VIEW | STAGING | ACTIVE_REVIEW | HOCKEY | Staging Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
| `staging` | `v_api_tennis_leagues_latest` | VIEW | STAGING | ACTIVE_REVIEW | TENNIS | Staging Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako přechod mezi RAW/provider daty a public canonical vrstvou. |
### A.2 Schéma `public`

| Schéma | Objekty | Tabulky | Views | Sekvence |
|---|---:|---:|---:|---:|
| `public` | 339 | 131 | 100 | 108 |

| Schéma | Objekt | Typ | Primární role | Governance stav | Doména | Vlastnická vrstva | Odhad řádků | Velikost | PK | FK | Indexy | Náhrada | Účel nebo poznámka |
|---|---|---|---|---|---|---|---:|---:|---|---:|---:|---|---|
| `public` | `ai_content_tags_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ai_entity_summaries_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ai_translations_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `api_import_runs_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `api_raw_payloads_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `article_league_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `article_match_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `article_media_team_alias_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `article_team_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `article_translations_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `articles_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `auto_ticket_strategies_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `bookmakers_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `canonical_league_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `canonical_provider_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `canonical_team_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `coach_provider_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `coaches_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `competition_rounds_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `content_sources_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `context_alias_registry_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `context_entity_registry_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `countries_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `generated_run_pattern_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `generated_runs_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `generated_tickets_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `injuries_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `languages_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `league_standings_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `league_translations_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `leagues_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `lineups_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `market_outcomes_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `markets_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `match_events_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `match_officials_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `match_weather_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `matches_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `media_articles_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `media_content_sections_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `media_entity_aliases_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `media_team_alias_bridge_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `media_team_alias_rules_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ml_predictions_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `mm_ticket_scenario_block_matches_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `mm_ticket_scenario_blocks_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `mm_ticket_scenario_variants_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `mm_ticket_scenarios_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `mm_value_bets_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `notification_queue_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `odds_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_external_identity_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_form_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_match_statistics_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_provider_map_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_season_statistics_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_social_links_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_team_history_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_translations_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `player_trending_id_seq1` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `players_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `product_active_leagues_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `provider_request_log_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `seasons_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `selection_items_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `sports_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `stadiums_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `standings_rules_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `storage_metrics_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `subscription_plans_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `subscriptions_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_aliases_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_coach_history_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_coaches_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_match_statistics_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_power_model_notes_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_social_links_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_stadiums_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_transfers_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `team_translations_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `teams_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `template_blocks_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `templates_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_block_matches_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_blocks_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_constants_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_generation_runs_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_history_base_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_league_pattern_stats_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_pattern_catalog_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_pattern_settlements_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_pattern_stats_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_recommendation_feedback_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_settlements_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_strategy_catalog_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_variant_block_choices_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_variant_features_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_variant_matches_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ticket_variants_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `tickets_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `translation_job_logs_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `translation_jobs_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `user_favorite_leagues_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `user_favorite_players_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `user_favorite_teams_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `user_notifications_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `user_selections_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `users_id_seq` | SEQUENCE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `public` | `ai_content_tags` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | 14 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ai_entity_summaries` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | -1 | 48 kB | ANO | 0 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ai_translations` | TABLE | PUBLIC / CANONICAL | ACTIVE | TRANSLATION | Public Canonical Layer | 12 | 96 kB | ANO | 0 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `api_import_runs` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | 177 | 96 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `api_raw_payloads` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | 1 740 | 35 MB | ANO | 1 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `article_ai_tags` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | -1 | 16 kB | ANO | 2 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `article_league_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public Canonical Layer | 318 | 128 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `article_match_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public Canonical Layer | 6 | 104 kB | ANO | 2 | 6 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `article_media_team_alias_map` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | 85 | 48 kB | ANO | 2 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `article_player_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public Canonical Layer | 1 701 | 480 kB | ANO | 4 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `article_team_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public Canonical Layer | 201 | 104 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `article_translations` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | -1 | 48 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `articles` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public Canonical Layer | 363 | 1648 kB | ANO | 1 | 8 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `auto_ticket_strategies` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | 3 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `bookmakers` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ODDS | Public Canonical Layer | 46 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `canonical_league_map` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | 1 471 | 344 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `canonical_provider_map` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | 364 | 88 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `canonical_team_map` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | 100 | 80 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `closing_odds` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | ODDS | Public Canonical Layer | -1 | 8192 bytes | NE | 0 | 0 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `coach_provider_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public Canonical Layer | 3 | 80 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `coaches` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public Canonical Layer | 3 | 112 kB | ANO | 1 | 6 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `competition_rounds` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 40 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `content_sources` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public Canonical Layer | 14 | 96 kB | ANO | 0 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `context_alias_registry` | TABLE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 4 577 | 680 kB | ANO | 0 | 2 |  |  |
| `public` | `context_entity_registry` | TABLE | PUBLIC / CANONICAL | UNCLASSIFIED |  |  | 156 283 | 36 MB | ANO | 0 | 4 |  |  |
| `public` | `countries` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | CORE | Public Canonical Layer | 147 | 80 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `data_providers` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | 22 | 32 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `generated_run_pattern_map` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 99 | 80 kB | ANO | 1 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `generated_runs` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public Canonical Layer | 112 | 32 kB | ANO | 2 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `generated_ticket_blocks` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public Canonical Layer | 1 656 | 248 kB | ANO | 1 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `generated_ticket_fixed` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public Canonical Layer | 354 | 96 kB | ANO | 2 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `generated_ticket_risk` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 16 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `generated_tickets` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public Canonical Layer | 1 052 | 1160 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `injuries` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 48 kB | ANO | 2 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `languages` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | TRANSLATION | Public Canonical Layer | 31 | 64 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `league_provider_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PUBLIC | Public Canonical Layer | 2 650 | 472 kB | ANO | 2 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `league_standings` | TABLE | PUBLIC / CANONICAL | ACTIVE | CORE | Public Canonical Layer | 8 806 | 4408 kB | ANO | 2 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `league_team_seasons` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | -1 | 8192 bytes | ANO | 2 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `league_teams` | TABLE | PUBLIC / CANONICAL | ACTIVE | CORE | Public Canonical Layer | 7 648 | 856 kB | ANO | 2 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `league_translations` | TABLE | PUBLIC / CANONICAL | ACTIVE | TRANSLATION | Public Canonical Layer | -1 | 48 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `leagues` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | CORE | Public Canonical Layer | 3 471 | 1120 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `lineups` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 56 kB | ANO | 3 | 6 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `market_outcomes` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ODDS | Public Canonical Layer | 10 | 48 kB | ANO | 1 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `markets` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ODDS | Public Canonical Layer | 5 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `match_events` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 56 kB | ANO | 4 | 6 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `match_features` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ML_MMR | Public Canonical Layer | 26 746 | 3480 kB | ANO | 1 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `match_officials` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 32 kB | ANO | 1 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `match_weather` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 32 kB | ANO | 1 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `matches` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | CORE | Public Canonical Layer | 121 911 | 63 MB | ANO | 3 | 14 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_articles` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | 17 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_content_sections` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | 8 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_entity_aliases` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public Canonical Layer | 22 | 64 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_team_alias_bridge` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | -1 | 16 kB | ANO | 2 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_team_alias_rules` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | 29 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_trending_leagues` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | 6 | 24 kB | ANO | 1 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_trending_players` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | 1 | 24 kB | ANO | 1 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `media_trending_teams` | TABLE | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public Canonical Layer | 14 | 24 kB | ANO | 1 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ml_predictions` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ML_MMR | Public Canonical Layer | 3 459 | 1024 kB | ANO | 1 | 7 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_match_ratings` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ML_MMR | Public Canonical Layer | 106 401 | 25 MB | ANO | 0 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_settings` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | ML_MMR | Public Canonical Layer | 1 | 32 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_team_ratings` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ML_MMR | Public Canonical Layer | 5 237 | 840 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_ticket_scenario_block_matches` | TABLE | PUBLIC / CANONICAL | ACTIVE | ML_MMR | Public Canonical Layer | -1 | 32 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_ticket_scenario_blocks` | TABLE | PUBLIC / CANONICAL | ACTIVE | ML_MMR | Public Canonical Layer | -1 | 32 kB | ANO | 1 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_ticket_scenario_variants` | TABLE | PUBLIC / CANONICAL | ACTIVE | ML_MMR | Public Canonical Layer | -1 | 40 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_ticket_scenarios` | TABLE | PUBLIC / CANONICAL | ACTIVE | ML_MMR | Public Canonical Layer | -1 | 48 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `mm_value_bets` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ML_MMR | Public Canonical Layer | 1 298 | 440 kB | ANO | 0 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `notification_queue` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 32 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `odds` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | ODDS | Public Canonical Layer | 82 386 | 15 MB | ANO | 3 | 7 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_external_identity` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public Canonical Layer | 640 | 272 kB | ANO | 1 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_form` | TABLE | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public Canonical Layer | 50 | 128 kB | ANO | 0 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_match_statistics` | TABLE | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public Canonical Layer | 58 | 136 kB | ANO | 3 | 6 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_provider_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public Canonical Layer | 19 493 | 4152 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_season_statistics` | TABLE | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public Canonical Layer | 3 121 | 840 kB | ANO | 4 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_social_links` | TABLE | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public Canonical Layer | -1 | 40 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_team_history` | TABLE | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public Canonical Layer | -1 | 48 kB | ANO | 3 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_translations` | TABLE | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public Canonical Layer | -1 | 48 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `player_trending` | TABLE | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public Canonical Layer | 406 | 128 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `players` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public Canonical Layer | 19 493 | 5568 kB | ANO | 1 | 7 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `product_active_leagues` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | 13 | 96 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `provider_request_log` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 32 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `seasons` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | CORE | Public Canonical Layer | 2 992 | 608 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `selection_items` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 16 kB | ANO | 2 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `sports` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | CORE | Public Canonical Layer | 14 | 64 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `stadiums` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 40 kB | ANO | 0 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `standings_rules` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | 10 | 80 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `storage_metrics` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC | Public Canonical Layer | -1 | 16 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `subscription_plans` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 32 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `subscriptions` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 32 kB | ANO | 2 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_aliases` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | 4 557 | 1496 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_coach_history` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public Canonical Layer | 9 | 144 kB | ANO | 4 | 8 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_coaches` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public Canonical Layer | 3 | 96 kB | ANO | 2 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_match_statistics` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | -1 | 32 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_power_model_notes` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | 42 | 32 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_provider_map` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | PUBLIC | Public Canonical Layer | 9 510 | 1736 kB | ANO | 1 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_social_links` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | 5 | 80 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_stadiums` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | -1 | 32 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_transfers` | TABLE | PUBLIC / CANONICAL | ACTIVE | PUBLIC | Public Canonical Layer | -1 | 48 kB | ANO | 3 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `team_translations` | TABLE | PUBLIC / CANONICAL | ACTIVE | TRANSLATION | Public Canonical Layer | -1 | 48 kB | ANO | 1 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `teams` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | CORE | Public Canonical Layer | 9 773 | 2544 kB | ANO | 0 | 6 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `template_block_matches` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 13 | 88 kB | ANO | 4 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `template_blocks` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 9 | 80 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `template_fixed_picks` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 18 | 72 kB | ANO | 4 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `templates` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 4 | 32 kB | ANO | 0 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_block_matches` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 84 | 72 kB | ANO | 4 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_blocks` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 65 | 80 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_constants` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 40 kB | ANO | 4 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_generation_runs` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 20 | 64 kB | ANO | 1 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_history_base` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 998 | 952 kB | ANO | 0 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_league_pattern_stats` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 32 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_pattern_catalog` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 4 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_pattern_settlements` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 3 | 48 kB | ANO | 1 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_pattern_stats` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 32 kB | ANO | 0 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_recommendation_feedback` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 32 kB | ANO | 3 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_run_settlements` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 459 | 120 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_settlements` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 32 kB | ANO | 2 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_strategy_catalog` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | 3 | 48 kB | ANO | 0 | 2 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_variant_block_choices` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 40 kB | ANO | 2 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_variant_features` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 24 kB | ANO | 1 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_variant_matches` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 40 kB | ANO | 5 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `ticket_variants` | TABLE | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public Canonical Layer | -1 | 40 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `tickets` | TABLE | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public Canonical Layer | 33 | 80 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `translation_job_logs` | TABLE | PUBLIC / CANONICAL | ACTIVE | TRANSLATION | Public Canonical Layer | -1 | 40 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `translation_jobs` | TABLE | PUBLIC / CANONICAL | ACTIVE | TRANSLATION | Public Canonical Layer | -1 | 56 kB | ANO | 0 | 6 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `unmatched_theodds` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | PUBLIC | Public Canonical Layer | 72 | 48 kB | NE | 0 | 0 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `user_favorite_leagues` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 24 kB | ANO | 2 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `user_favorite_players` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 24 kB | ANO | 2 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `user_favorite_teams` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 24 kB | ANO | 2 | 3 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `user_notifications` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 40 kB | ANO | 1 | 4 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `user_selections` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 16 kB | ANO | 1 | 1 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `users` | TABLE | PUBLIC / CANONICAL | ACTIVE_REVIEW | USERS | Public Canonical Layer | -1 | 48 kB | ANO | 0 | 5 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `work_pl_aliases` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | PUBLIC | Public Canonical Layer | -1 | 16 kB | NE | 0 | 0 |  | Součást produktové, analytické nebo webové vrstvy. |
| `public` | `best_match_odds` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_block_candidates_latest_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_fair_odds_latest_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_feed_value_picks_latest_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_market_odds_latest_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_match_dataset` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_match_dataset_v2` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_match_predict_dataset_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_value_ev_latest_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `ml_value_latest_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | ML | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_auto_ticket_candidates_safe` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_best_ticket_candidates_today` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_breaking_news_feed_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_canonical_match_lookup` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_canonical_team_resolve` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | TEAM | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_current_product_standings` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PUBLIC_VIEW | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fb_team_power_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | TEAM | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fb_team_power_v2` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | TEAM | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fd_leagues_active_week` | VIEW | PUBLIC / CANONICAL | ACTIVE | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fd_matches_base` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fd_matches_today` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fd_matches_tomorrow` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fd_matches_week` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fd_matches_week_ui` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_fd_matches_week_with_odds` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_generated_run_pattern_candidates` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC_VIEW | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_home_feed_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PUBLIC_VIEW | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_homepage_media_feed_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_homepage_media_feed_v2` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_homepage_top_headlines_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_league_standings_enriched` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC_VIEW | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_leagues_active_week` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | PUBLIC_VIEW | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_live_match_feed` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_live_match_feed_v2` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_match_card_feed` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_match_odds_1x2` | VIEW | PUBLIC / CANONICAL | ACTIVE | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_matches_base` | VIEW | PUBLIC / CANONICAL | ACTIVE | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_matches_today` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_matches_tomorrow` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_matches_week` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_matches_with_odds_week` | VIEW | PUBLIC / CANONICAL | ACTIVE | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_feed_by_league` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_feed_by_player` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_feed_by_team` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_feed_latest` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_feed_unmatched_articles` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_feed_videos` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_layer_coverage` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_source_discovery_review` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_sources_ready_for_ingest` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_trending_leagues` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_trending_players_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_media_trending_teams` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_mm_anchor_day` | VIEW | PUBLIC / CANONICAL | ACTIVE | ML_MMR | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_mm_ticket_scenario_rating` | VIEW | PUBLIC / CANONICAL | ACTIVE | ML_MMR | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_mm_ticket_scenario_sport_features` | VIEW | PUBLIC / CANONICAL | ACTIVE | ML_MMR | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_people_stats_quality_audit` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_player_form_tiers_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_player_form_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_player_statistics_feed` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_player_trending_feed` | VIEW | PUBLIC / CANONICAL | ACTIVE | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_preferred_team_name_lookup` | VIEW | PUBLIC / CANONICAL | ACTIVE_REVIEW | TEAM | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_product_matches_dedup` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_strategy_comparison` | VIEW | PUBLIC / CANONICAL | ACTIVE | STRATEGY | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_strategy_ranking` | VIEW | PUBLIC / CANONICAL | ACTIVE | STRATEGY | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_strategy_recommendation` | VIEW | PUBLIC / CANONICAL | ACTIVE | STRATEGY | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_strategy_recommendation_by_catalog` | VIEW | PUBLIC / CANONICAL | ACTIVE | STRATEGY | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_strategy_recommendation_current` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | STRATEGY | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_team_player_form_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_team_player_form_v2` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_team_player_form_v3` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PEOPLE | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_team_results_form_v1` | VIEW | PUBLIC / CANONICAL | ACTIVE | TEAM | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_history_summary` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_history_summary_enriched` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_pattern_history_quality` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_pattern_history_summary` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_pattern_history_summary_normalized` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_pattern_settlement_aggregate` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_pattern_settlement_ready` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_ticket_pattern_settlement_source` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_video_feed_by_league` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_video_feed_by_player` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_video_feed_by_team` | VIEW | PUBLIC / CANONICAL | ACTIVE | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_video_feed_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_video_feed_v2` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | MEDIA | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `v_web_active_leagues` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | PUBLIC_VIEW | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_block_candidate_groups` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_block_outcome_candidates` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_block_sync_signals` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_data_coverage` | VIEW | PUBLIC / CANONICAL | ACTIVE | PUBLIC_VIEW | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_generated_ticket_matches` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_match_feed_for_user` | VIEW | PUBLIC / CANONICAL | ACTIVE | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_offer_matches` | VIEW | PUBLIC / CANONICAL | ACTIVE | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_offer_matches_value` | VIEW | PUBLIC / CANONICAL | ACTIVE | MATCH_FEED | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_ticket_candidate_matches` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_ticket_candidates` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_ticket_items` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_ticket_match_results` | VIEW | PUBLIC / CANONICAL | ACTIVE | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_ticket_settlement_detail` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
| `public` | `vw_ticket_summary` | VIEW | PUBLIC / CANONICAL | ACTIVE_MASTER | TICKETS | Public View Layer | -1 | 0 bytes | NE | 0 | 0 |  | Slouží jako výstupní vrstva nad public tabulkami. |
### A.3 Schéma `ops`

| Schéma | Objekty | Tabulky | Views | Sekvence |
|---|---:|---:|---:|---:|
| `ops` | 699 | 111 | 488 | 100 |

| Schéma | Objekt | Typ | Primární role | Governance stav | Doména | Vlastnická vrstva | Odhad řádků | Velikost | PK | FK | Indexy | Náhrada | Účel nebo poznámka |
|---|---|---|---|---|---|---|---:|---:|---|---:|---:|---|---|
| `ops` | `active_worker_runs_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `ai_action_execution_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `api_budget_status_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `api_request_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `autonomous_execution_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `block_reason_catalog_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `brain_recommendation_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `database_object_governance_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `development_task_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `dispatch_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `entity_requirement_matrix_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `fb_entity_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `fb_players_pro_priority_buckets_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `fix_tasks_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `fixture_player_stats_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `global_source_registry_source_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `harvest_readiness_snapshot_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `harvest_run_monitor_monitor_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `hb_national_league_discovery_discovery_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `ingest_entity_plan_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `ingest_planner_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `ingest_runtime_config_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `ingest_targets_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `job_runs_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `layer_readiness_status_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `league_mapping_review_hold_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `league_mapping_safe_update_run_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `league_provider_map_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `master_architecture_map_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `match_safe_delete_run_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `media_article_velocity_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `media_asset_enrichment_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `media_discovery_requests_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `media_job_runs_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `media_refresh_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `media_source_discovery_candidates_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `media_source_health_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `odds_provider_roadmap_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `operator_fix_catalog_fix_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `operator_fix_execution_log_fix_execution_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `operator_provider_discovery_actions_discovery_action_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `operator_provider_discovery_candidates_candidate_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `operator_provider_implementation_tas_implementation_task_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `operator_provider_validation_validation_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `operator_run_queue_run_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `panel_action_registry_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `pc2_command_center_sources_source_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `pc2_execution_history_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `pc2_run_command_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `people_master_provider_matrix_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `people_source_discovery_registry_registry_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `player_enrichment_plan_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `player_identity_review_hold_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `player_provider_collision_review_hold_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `project_milestones_milestone_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `project_roadmap_milestones_v1_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_accounts_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_audit_registry_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_coaches_runtime_checklist_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_entity_coverage_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_jobs_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_missing_matrix_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_people_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_sport_matrix_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_switch_recommendations_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `provider_worker_registry_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `repair_outcome_learning_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `repair_reset_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `runtime_entity_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `runtime_execution_history_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `scheduler_queue_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `schema_migrations_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_activation_roadmap_activation_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_commercial_model_commercial_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_coverage_matrix_coverage_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_discovery_audit_tracker_audit_tracker_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_discovery_master_source_discovery_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_discovery_matrix_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_discovery_queue_discovery_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_discovery_review_plan_review_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_discovery_tasks_task_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_intelligence_map_source_map_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_legal_audit_legal_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_quality_score_quality_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_registry_source_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_review_results_review_result_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `source_verification_log_verification_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `sport_completion_audit_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `sport_dimension_rules_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `sport_entity_rules_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `sports_import_plan_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `team_missing_canonical_merge_run_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `team_real_provider_duplicate_merge_run_log_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `team_same_name_review_hold_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `unified_worker_registry_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `v18_master_panel_sources_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `worker_capability_registry_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `worker_dependency_graph_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `worker_execution_rules_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `worker_registry_id_seq` | SEQUENCE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `ops` | `active_worker_runs` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Active Runs | -1 | 32 kB | ANO | 0 | 3 |  | Chrání proti paralelním konfliktům. |
| `ops` | `ai_action_execution_log` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | AI Action Log | 24 | 80 kB | ANO | 0 | 4 |  | Historie autonomních rozhodnutí. |
| `ops` | `api_budget_status` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | API | API Budget | 23 | 48 kB | ANO | 0 | 2 |  | Denní request limity. |
| `ops` | `api_request_log` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | API | API Request Log | -1 | 24 kB | ANO | 0 | 2 |  | Budget tracking. |
| `ops` | `autonomous_execution_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AUTONOMOUS | Autonomous Queue | 6 | 64 kB | ANO | 0 | 3 |  | Autonomous OPS execution. |
| `ops` | `block_reason_catalog` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | REPAIR | Repair Layer | 12 | 48 kB | ANO | 0 | 2 |  | Zdroj pravdy pro repair engine a blocked item workflow. |
| `ops` | `brain_recommendation_log` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | Brain Log | 10 | 80 kB | ANO | 0 | 4 |  | Audit rozhodnutí AI OPS. |
| `ops` | `database_object_governance` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | GOVERNANCE | DB Governance | 540 | 352 kB | ANO | 0 | 3 |  | Evidence master/active/legacy/drop objektů. |
| `ops` | `development_task_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | DEVELOPMENT | Development Queue | 51 | 64 kB | ANO | 0 | 1 |  | Roadmapa a další kroky. |
| `ops` | `dispatch_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | DISPATCH | Dispatch Queue | 2 | 80 kB | ANO | 0 | 4 |  | Run Next / Dispatch engine. |
| `ops` | `entity_requirement_matrix` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 28 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `eu_batch_1` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | EU Batch Legacy | 1 | 32 kB | NE | 0 | 1 |  | Použití v původních FB run groups. |
| `ops` | `eu_batch_100` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | EU Batch Legacy | 100 | 32 kB | NE | 0 | 1 |  | Použití v původních FB run groups. |
| `ops` | `eu_keep_ids` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | EU Keep IDs | 101 | 24 kB | ANO | 0 | 1 |  | Použití v původním FB whitelistu. |
| `ops` | `fb_entity_audit` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | FOOTBALL | FB Entity Audit | 9 | 32 kB | ANO | 0 | 1 |  | Starší football audit vrstva. |
| `ops` | `fb_players_pro_priority_buckets` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | FB People Priority Buckets | 123 | 96 kB | ANO | 0 | 2 |  | Použít při PRO backfillu. |
| `ops` | `fix_tasks` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | REPAIR | Fix Tasks | 1 | 112 kB | ANO | 0 | 6 |  | Opravy parserů/providerů/runtime chyb. |
| `ops` | `fixture_player_stats_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | PEOPLE | Player Match Stats Queue | 260 | 200 kB | ANO | 0 | 5 |  | People stats pipeline. |
| `ops` | `global_source_registry` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Master registr všech sportovních zdrojů MatchMatrix. |
| `ops` | `harvest_dependency_layers` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 4 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `harvest_readiness_snapshot` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 80 kB | ANO | 0 | 4 |  |  |
| `ops` | `harvest_run_monitor` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 2 | 96 kB | ANO | 0 | 5 |  |  |
| `ops` | `hb_national_league_discovery` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `ingest_entity_plan` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | INGEST | Entity Plan Layer | 106 | 88 kB | ANO | 0 | 2 |  | Definuje entity, priority, scope a worker. |
| `ops` | `ingest_planner` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | INGEST | Planner Layer | 7 794 | 1304 kB | ANO | 0 | 1 |  | Řídí pending/running/done/error ingest úlohy. |
| `ops` | `ingest_runtime_config` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | INGEST | Runtime Config | 1 | 48 kB | ANO | 0 | 2 |  | Řídí sezóny, budget a režimy. |
| `ops` | `ingest_targets` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | INGEST | Target Layer | 4 428 | 1448 kB | ANO | 1 | 4 |  | Definuje provider/league/season/run_group cíle. |
| `ops` | `job_runs` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Runtime Layer | 2 030 | 3152 kB | ANO | 1 | 2 |  | Základ pro runtime metriky a health score. |
| `ops` | `jobs` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Job Registry | 20 | 32 kB | ANO | 0 | 1 |  | Definuje dostupné joby. |
| `ops` | `layer_readiness_status` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 14 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `league_canonical_registry` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 800 | 328 kB | ANO | 0 | 1 |  |  |
| `ops` | `league_import_plan` | TABLE | LEGACY / REVIEW | LEGACY_KEEP | SPORT | Legacy League Plan | 175 | 80 kB | ANO | 0 | 1 |  | Historický import plán před ingest_targets. |
| `ops` | `league_mapping_review_hold` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 2 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `league_mapping_safe_update_run_log` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 562 | 224 kB | ANO | 0 | 1 |  |  |
| `ops` | `league_provider_map` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 600 | 472 kB | ANO | 0 | 2 |  |  |
| `ops` | `master_architecture_map` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 14 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `match_safe_delete_run_log` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 629 | 440 kB | ANO | 0 | 1 |  |  |
| `ops` | `media_article_velocity_log` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | MEDIA | Media Velocity | -1 | 32 kB | ANO | 0 | 3 |  | Trending/media score. |
| `ops` | `media_asset_enrichment_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | MEDIA | Media Asset Enrichment | 12 250 | 3128 kB | ANO | 0 | 5 |  | Thumbnail/video/media enrichment. |
| `ops` | `media_discovery_requests` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | MEDIA | Media Discovery | 3 | 80 kB | ANO | 1 | 4 |  | Vyhledávání nových zdrojů. |
| `ops` | `media_job_runs` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | MEDIA | Media Job Runs | 5 | 80 kB | ANO | 0 | 4 |  | Audit media pipeline. |
| `ops` | `media_refresh_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | MEDIA | Media Refresh Queue | 2 | 80 kB | ANO | 0 | 4 |  | Aktualizace článků/videí. |
| `ops` | `media_source_discovery_candidates` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | MEDIA | Media Discovery Candidates | 9 | 96 kB | ANO | 1 | 5 |  | Rozšiřování media providerů. |
| `ops` | `media_source_health_audit` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | MEDIA | Media Source Health | 9 | 80 kB | ANO | 0 | 4 |  | Kontrola dostupnosti web/RSS zdrojů. |
| `ops` | `odds_provider_roadmap` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 15 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `operator_fix_catalog` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 8 | 80 kB | ANO | 0 | 4 |  |  |
| `ops` | `operator_fix_execution_log` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 96 kB | ANO | 0 | 5 |  |  |
| `ops` | `operator_provider_discovery_actions` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `operator_provider_discovery_candidates` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 5 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `operator_provider_implementation_tasks` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `operator_provider_validation` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `operator_run_queue` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 80 kB | ANO | 0 | 4 |  |  |
| `ops` | `panel_action_registry` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 19 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `panel_help` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 6 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `pc2_command_center_sources` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 5 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `pc2_execution_history` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `pc2_run_command_queue` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 9 | 96 kB | ANO | 0 | 2 |  |  |
| `ops` | `people_master_provider_matrix` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PEOPLE | People Master Matrix | 14 | 64 kB | ANO | 0 | 3 |  | Rozhoduje providery pro hráče/trenéry/profily/statistiky. |
| `ops` | `people_quality_backfill_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | PEOPLE | People Backfill | -1 | 16 kB | NE | 0 | 0 |  | Doplňování hráčů/profilů/statistik. |
| `ops` | `people_source_discovery_registry` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 11 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `player_enrichment_plan` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | PEOPLE | Player Enrichment | 33 | 80 kB | ANO | 1 | 4 |  | Doplňování profilů/fotek/detailů. |
| `ops` | `player_identity_review_hold` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 121 | 80 kB | ANO | 0 | 1 |  |  |
| `ops` | `player_provider_collision_review_hold` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 4 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `project_milestones` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 29 | 80 kB | ANO | 0 | 4 |  |  |
| `ops` | `project_roadmap_milestones_v1` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 14 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `provider_accounts` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | PROVIDER | Provider Accounts | 10 | 48 kB | ANO | 0 | 2 |  | Budget a API plánování. |
| `ops` | `provider_audit_registry` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 1 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `provider_coaches_runtime_checklist` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | PEOPLE | Coaches Checklist | 6 | 48 kB | ANO | 0 | 2 |  | Pomocný audit pro coaches layer. |
| `ops` | `provider_entity_coverage` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PROVIDER | Provider Coverage | 107 | 152 kB | ANO | 0 | 5 |  | Zdroj pro routing, panel, scheduler. |
| `ops` | `provider_jobs` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PROVIDER | Provider Jobs | 140 | 144 kB | ANO | 0 | 4 |  | Napojení provider/entity na job_code. |
| `ops` | `provider_missing_matrix` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 29 | 144 kB | ANO | 0 | 6 |  |  |
| `ops` | `provider_people_audit` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PEOPLE | People Provider Audit | 30 | 80 kB | ANO | 0 | 2 |  | Rozhoduje použitelnost hráčů/trenérů/statistik. |
| `ops` | `provider_sport_matrix` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PROVIDER | Provider Matrix | 16 | 80 kB | ANO | 1 | 4 |  | Určuje podporu entit podle sportu. |
| `ops` | `provider_switch_recommendations` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | PROVIDER | Provider Switching | -1 | 16 kB | ANO | 0 | 1 |  | Fallback/switch rozhodování. |
| `ops` | `provider_worker_registry` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | PROVIDER | Provider Worker Registry | 50 | 80 kB | ANO | 0 | 2 |  | Používá dispatch command layer. |
| `ops` | `repair_outcome_catalog` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | REPAIR | Repair Catalog | 5 | 32 kB | ANO | 0 | 1 |  | Learning oprav. |
| `ops` | `repair_outcome_learning` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | REPAIR | Repair Learning | 6 | 32 kB | ANO | 0 | 1 |  | Zpětná vazba pro repair engine. |
| `ops` | `repair_reset_audit` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE | REPAIR | Repair Reset Audit | 1 | 32 kB | ANO | 0 | 1 |  | Kontrola ručních oprav. |
| `ops` | `runtime_entity_audit` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Runtime Audit | 84 | 176 kB | ANO | 0 | 6 |  | Zdroj pravdy CONFIRMED/RUNNABLE/PARTIAL. |
| `ops` | `runtime_execution_history` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Runtime History | 8 | 112 kB | ANO | 0 | 4 |  | Zdroj pro alerty, health a audit. |
| `ops` | `scheduler_queue` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | SCHEDULER | Scheduler Layer | 6 | 80 kB | ANO | 0 | 4 |  | Řídí plánované běhy. |
| `ops` | `schema_migrations` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | GOVERNANCE | Migration Layer | 64 | 48 kB | ANO | 0 | 2 |  | Hlídá historii SQL změn. |
| `ops` | `source_activation_roadmap` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Roadmap aktivace zdrojů MatchMatrix. |
| `ops` | `source_commercial_model` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Source Business Intelligence - obchodní model, ceny, tarify, limity a ROI zdrojů. |
| `ops` | `source_coverage_matrix` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 80 kB | ANO | 0 | 4 |  | Centrální Source Intelligence matice pokrytí zdrojů podle sportu, entity a kvality dat. |
| `ops` | `source_discovery_audit_tracker` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 80 kB | ANO | 0 | 4 |  | Tracker auditů objevených datových zdrojů MatchMatrix. |
| `ops` | `source_discovery_master` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Master registr všech objevených zdrojů MatchMatrix. |
| `ops` | `source_discovery_matrix` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 24 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `source_discovery_queue` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Fronta úkolů pro globální Source Discovery. |
| `ops` | `source_discovery_review_plan` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  |  |
| `ops` | `source_discovery_tasks` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 16 kB | ANO | 0 | 1 |  |  |
| `ops` | `source_intelligence_map` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 48 kB | ANO | 0 | 2 |  | MatchMatrix Source Intelligence Layer - centrální mapa zdrojů dat pro sporty, hráče, trenéry, fotky, historii, média a statistiky. |
| `ops` | `source_legal_audit` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Centrální právní a licenční audit zdrojů MatchMatrix. |
| `ops` | `source_quality_score` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Centrální hodnocení kvality zdrojů MatchMatrix. |
| `ops` | `source_registry` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 16 kB | ANO | 0 | 1 |  |  |
| `ops` | `source_review_results` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Historie auditních výsledků Source Intelligence Layer. |
| `ops` | `source_verification_log` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 3 |  | Historie skutečných ověření zdrojů v Source Intelligence Layer. |
| `ops` | `sport_completion_audit` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | SPORT | Sport Completion | 24 | 48 kB | ANO | 0 | 2 |  | Zdroj pro completion dashboard. |
| `ops` | `sport_dimension_rules` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | SPORT | Sport Dimensions | 14 | 64 kB | ANO | 1 | 3 |  | Team/player/ranking/surface model. |
| `ops` | `sport_entity_rules` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | SPORT | Sport Entity Rules | 81 | 112 kB | ANO | 1 | 4 |  | Požadavky na league/team/player/match. |
| `ops` | `sports_import_plan` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | SPORT | Sports Import Plan | 13 | 80 kB | ANO | 0 | 4 |  | Budget a režim sportů. |
| `ops` | `team_missing_canonical_merge_run_log` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 38 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `team_real_provider_duplicate_merge_run_log` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 38 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `team_same_name_review_hold` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 7 | 32 kB | ANO | 0 | 1 |  |  |
| `ops` | `unified_worker_registry` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | WORKER | Unified Worker Registry | 106 | 104 kB | ANO | 0 | 3 |  | Scheduler governance. |
| `ops` | `v18_master_panel_sources` | TABLE | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | 20 | 48 kB | ANO | 0 | 2 |  |  |
| `ops` | `worker_capability_registry` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | WORKER | Worker Capability | 20 | 48 kB | ANO | 0 | 2 |  | AI launcher a execution rules. |
| `ops` | `worker_dependency_graph` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | WORKER | Dependency Graph | 5 | 80 kB | ANO | 0 | 4 |  | Dependency-aware orchestrace. |
| `ops` | `worker_execution_rules` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | WORKER | Execution Rules | 10 | 48 kB | ANO | 0 | 2 |  | AI worker selector. |
| `ops` | `worker_locks` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Lock Layer | 2 | 48 kB | ANO | 0 | 2 |  | Ochrana proti duplicitním běhům. |
| `ops` | `worker_registry` | TABLE | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | WORKER | Worker Registry | 6 | 80 kB | ANO | 0 | 4 |  | Scheduler a resolver. |
| `ops` | `api_football_coverage` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | PROVIDER | Coverage Layer | -1 | 0 bytes | NE | 0 | 0 |  | Historický coverage report. Ověřit, zda je stále využíván. |
| `ops` | `v18_master_panel_sources_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v18_master_panel_sources_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_active_runs_live_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_active_runs_live_v2 | V1 nahrazena verzí V2. |
| `ops` | `v_active_runs_live_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_active_runs_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_action_history_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_health_score` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_ops_actions_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_ops_alert_center_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_ops_dashboard_panel_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_ops_dashboard_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_ops_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_self_improvement_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_self_improvement_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ai_worker_selector_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_api_budget_today` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_auto_healing_cleanup_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | AI_OPS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_automation_execution_queue` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_automation_execution_queue_v2 | Používá starý routing master. Nahrazeno verzí V2. |
| `ops` | `v_automation_execution_queue_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_automation_ready_queue_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_automation_ready_queue_v4 | Starší vývojová verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_automation_ready_queue_v2` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_automation_ready_queue_v4 | Starší vývojová verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_automation_ready_queue_v3` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_automation_ready_queue_v4 | Starší vývojová verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_automation_ready_queue_v4` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | OPS | Automation Layer | -1 | 0 bytes | NE | 0 | 0 |  | Filtruje pouze akce, které mají provider, worker, run_group a runtime podmínky. |
| `ops` | `v_autonomous_candidate_ranking_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_autonomous_candidate_ranking_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_autonomous_candidate_ranking_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AUTONOMOUS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_autonomous_execution_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AUTONOMOUS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_autonomous_execution_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AUTONOMOUS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_autonomous_next_ranked_candidate_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AUTONOMOUS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_autonomous_ops_brain_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  | Agreguje doporučení Brainu podle provider/sport/entity/run_group. |
| `ops` | `v_autonomous_ops_brain_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_autonomous_ops_brain_v5 | Starší vývojová verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_autonomous_ops_brain_v2` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_autonomous_ops_brain_v5 | Starší vývojová verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_autonomous_ops_brain_v3` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_autonomous_ops_brain_v5 | Starší vývojová verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_autonomous_ops_brain_v4` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_autonomous_ops_brain_v5 | Starší vývojová verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_autonomous_ops_brain_v5` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AI_OPS | OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  | Vyhodnocuje kandidáty, skóre, worker registry a doporučuje RUN / WAIT / HOLD. |
| `ops` | `v_autonomous_result_collector_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AUTONOMOUS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_autonomous_result_collector_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | AUTONOMOUS | Autonomous Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_block_reason_catalog_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | REPAIR | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_blocked_items_repair_queue_cs_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_blocked_items_repair_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | REPAIR | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_blocked_items_repair_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | REPAIR | AI OPS Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_coaches_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_context_search_resolver_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_context_search_results_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_coverage_priority_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | COVERAGE | Coverage Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_coverage_priority_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_coverage_progress_by_sport_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | COVERAGE | Coverage Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_coverage_progress_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | COVERAGE | Coverage Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_dashboard_summary` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | COVERAGE | Coverage Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_data_gap_engine_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_data_gap_engine_v2 | Starší verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_data_gap_engine_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | OPS | Data Gap Layer | -1 | 0 bytes | NE | 0 | 0 |  | Převádí coverage_status providerů na srozumitelný gap status. |
| `ops` | `v_data_gap_panel_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_data_gap_panel_v2 | Starší verze. Nemazat bez kontroly závislostí. |
| `ops` | `v_data_gap_panel_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PANEL | Data Gap Layer | -1 | 0 bytes | NE | 0 | 0 |  | Zobrazuje provider, sport, entitu, status, důvod a další krok. |
| `ops` | `v_database_governance_domains_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_database_governance_masters_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_database_governance_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_dependency_aware_execution_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | DEPENDENCY | Orchestration Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_dependency_resolver_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | DEPENDENCY | Orchestration Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_development_task_queue_panel_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_development_task_queue_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | DEVELOPMENT | Development Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_development_task_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | DEVELOPMENT | Development Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_dispatch_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | DISPATCH | Dispatch Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_dispatch_ready_commands_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | DISPATCH | Dispatch Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_dispatch_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | DISPATCH | Dispatch Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_documentation_panel_payload_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Jednotný JSONB datový kontrakt dokumentační vrstvy pro MatchMatrix Python OPS panel. |
| `ops` | `v_documentation_status_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Jednořádkový dashboard posledního stavu dokumentační vrstvy MatchMatrix. |
| `ops` | `v_documentation_status_history_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Historický vývoj health stavu a KPI dokumentační vrstvy MatchMatrix. |
| `ops` | `v_documentation_status_kpi_cards_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | KPI karty dokumentační vrstvy připravené pro zobrazení v OPS panelu. |
| `ops` | `v_documentation_status_kpi_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | KPI posledního stavu dokumentační vrstvy pro MatchMatrix OPS panel. |
| `ops` | `v_documentation_status_recent_history_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Posledních 100 stavových snapshotů dokumentační vrstvy pro OPS tabulku nebo graf. |
| `ops` | `v_execution_lock_guard_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | EXECUTION | Execution Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_execution_priority_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | EXECUTION | Execution Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_execution_risk` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | EXECUTION | Execution Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_execution_risk_full` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | EXECUTION | Execution Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_api_expansion_ingest_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | Football Legacy Planning | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_api_expansion_ingest_jobs_test_mode` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | Football Legacy Planning | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_api_football_profile_enrichment_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_eu_ingest_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | Football Legacy Planning | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_eu_ingest_jobs_test_mode` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | Football Legacy Planning | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_fd_core_ingest_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | Football Legacy Planning | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_fd_core_ingest_jobs_test_mode` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | Football Legacy Planning | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_job_catalog` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | FOOTBALL | Football Orchestration | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_player_season_stats_normalized_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_provider_reality` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | FOOTBALL | Football Orchestration | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_test_execution_order` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | FOOTBALL | Football Orchestration | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_test_mode_all_layers` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | FOOTBALL | Football Legacy Planning | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_test_mode_orchestrator` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | FOOTBALL | Football Orchestration | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fb_test_phase1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | FOOTBALL | Football Orchestration | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_fix_task_ai_ops_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | FOOTBALL | Football Orchestration | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_governance_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | governance | OPS | -1 | 0 bytes | NE | 0 | 0 |  | Sjednocuje stav Team, Player a League Governance. |
| `ops` | `v_governance_panel_detail_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | governance | OPS | -1 | 0 bytes | NE | 0 | 0 |  | Ukazuje Týmy, Hráče, Ligy a Provider Mapy v čitelném stavu. |
| `ops` | `v_governance_summary_kpi_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | governance | OPS | -1 | 0 bytes | NE | 0 | 0 |  | Počítá celkové governance skóre, počet hotových a částečných oblastí. |
| `ops` | `v_harvest_dependency_status_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_dependency_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_dry_run_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_e2e_control` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | HARVEST | Harvest Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_locks_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_master_plan_pc2_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_media_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_odds_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_people_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_provider_readiness_matrix_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_readiness_current` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_readiness_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_readiness_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_readiness_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_harvest_recommendations_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_hb_source_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | HB Source Intelligence Dashboard V1 |
| `ops` | `v_hb_source_queue_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | HB Source Discovery Queue Dashboard V1 |
| `ops` | `v_implementation_readiness_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | IMPLEMENTATION | Implementation Readiness Layer | -1 | 0 bytes | NE | 0 | 0 | ops.v_implementation_readiness_v2 | Starší verze. V2 lépe rozlišuje CORE / PEOPLE / MEDIA / ODDS. |
| `ops` | `v_implementation_readiness_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | IMPLEMENTATION | Implementation Readiness Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_implementation_readiness_v3` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Implementation Readiness V3 - rozšířený readiness pohled pro Mass Harvest přípravu; kombinuje execution priority queue a development task queue. |
| `ops` | `v_ingest_overview` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | INGEST | Ingest Layer | -1 | 0 bytes | NE | 0 | 0 |  | Spojuje ingest_entity_plan, pravidla sportů a provider_sport_matrix. |
| `ops` | `v_ingest_planner_queue` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | INGEST | Planner Layer | -1 | 0 bytes | NE | 0 | 0 |  | Ukazuje pending/running/error joby a zda jsou připravené ke spuštění. |
| `ops` | `v_ingest_planner_status` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | INGEST | Planner Layer | -1 | 0 bytes | NE | 0 | 0 |  | Počítá počet jobů podle statusu a pomáhá sledovat stav fronty. |
| `ops` | `v_job_runs_recent` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | RUNTIME | Job Runs Layer | -1 | 0 bytes | NE | 0 | 0 |  | Recent job runs ordered from newest to oldest. |
| `ops` | `v_laliga_article_match_best_candidate_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_laliga_article_match_resolution_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_launcher_dispatch_next_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LAUNCHER | Launcher Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_launcher_dispatch_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LAUNCHER | Launcher Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_launcher_dispatch_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LAUNCHER | Launcher Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_launcher_next_action_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LAUNCHER | Launcher Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_launcher_permission_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LAUNCHER | Launcher Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_launcher_permission_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LAUNCHER | Launcher Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_layer_readiness_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_layer_readiness_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_canonical_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_canonical_coverage_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_canonical_detail_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_canonical_governance_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_canonical_governance_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_canonical_registry_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_canonical_review_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_dependency_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_dependency_hold_detail_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_dependency_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_duplicate_governance_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_governance_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_governance_final_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_governance_final_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_mapping_conflict_detail_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_mapping_fix_dependency_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_mapping_governance_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_mapping_governance_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_mapping_master_suggestion_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_league_mapping_safe_fix_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_learning_evaluation_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LEARNING | Learning Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_learning_evaluation_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LEARNING | Learning Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_learning_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL | Learning Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_learning_recommendations_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LEARNING | Learning Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_learning_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | LEARNING | Learning Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_mass_harvest_implementation_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Implementation Readiness V3 - rozšířený readiness pohled pro Mass Harvest přípravu; kombinuje execution priority queue a development task queue. |
| `ops` | `v_master_architecture_map_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_master_table_catalog_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_master_view_catalog_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_context_candidate_classification_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_context_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_duplicate_governance_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_duplicate_governance_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_duplicate_group_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_merge_dependency_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_safe_delete_candidate_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_safe_delete_execution_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_match_safe_merge_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_matchmatrix_player_rating_v2` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_matchmatrix_player_rating_v3` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_core_league_alignment_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_entity_mapping_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_gap_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_master_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_match_link_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_match_link_gap_reason_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_match_link_priority_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_match_mapping_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_match_mapping_gap_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_match_resolution_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_match_resolution_safe_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_team_keyword_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_team_link_priority_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_team_match_quality_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_team_match_safe_rules_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_media_title_opponent_resolver_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_missing_canonical_team_fix_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_missing_data_source_recommendations_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_next_development_plan_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL | Development Planning Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_next_development_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | DEVELOPMENT | Development Planning Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_next_harvest_layer_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operations_center_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | OPS | Operations Center | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_action_buttons_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_core_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_current_run_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_dashboard_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_error_explanation_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_fix_recommendations_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_fix_statistics_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_last_result_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_next_action_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_provider_context_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_provider_discovery_actions_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_provider_discovery_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_provider_implementation_tasks_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_provider_validation_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_recommendation_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_result_classifier_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_stop_errors_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_operator_today_progress_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_bk_core_full_job_catalog` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | BASKETBALL | BK Orchestration Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_bk_core_runnable_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | BASKETBALL | BK Orchestration Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_bk_top_full_job_catalog` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_bk_top_runnable_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_block_reason_translations_cs_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_dashboard_by_provider` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_dashboard_by_sport` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_dashboard_summary` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_core_full_job_catalog` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_core_runnable_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_full_job_catalog` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_full_runnable_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_job_catalog` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_top_full_execution_order` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_top_full_runnable_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_top_ingest_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_top_ingest_jobs_test_mode` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_top_runnable_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_hk_top_test_execution_order` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_panel_action_queue` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_panel_top_queue` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ops_people_pipeline` | VIEW | LEGACY / REVIEW | LEGACY_KEEP | PEOPLE | People Layer | -1 | 0 bytes | NE | 0 | 0 |  | Sleduje done/pending jobs pro FB players ingest. |
| `ops` | `v_orchestration_priority_queue_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_orchestration_priority_queue_v4 |  |
| `ops` | `v_orchestration_priority_queue_v2` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_orchestration_priority_queue_v4 |  |
| `ops` | `v_orchestration_priority_queue_v3` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_orchestration_priority_queue_v4 |  |
| `ops` | `v_orchestration_priority_queue_v4` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_action_recommendations_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_active_runs_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_ai_recommendations_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_ai_recommendations_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_brain_inventory_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_cooldowns_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_orchestration_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_run_control` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_run_next_button_source_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_run_next_button_state_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_panel_runtime_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_parser_flow_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_command_center_dashboard_kpi_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_command_center_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_command_center_kpi_cards_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_command_center_kpi_pack_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_command_center_next_actions_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_command_center_sources_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_command_center_top_priority_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_continue_pending_actions_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_core_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_day1_execution_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_dependency_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_execution_history_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_execution_readiness_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_go_live_checklist_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_go_live_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_master_harvest_kpi_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_master_harvest_roadmap_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_master_harvest_roadmap_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_master_next_action_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_media_asset_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_media_execution_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_media_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_media_provider_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_next_run_command_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_orchestration_actions_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_orchestration_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_panel_action_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_panel_action_matrix_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_panel_run_button_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_panel_run_button_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_people_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_phase1_capacity_estimate_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_phase1_core_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_phase2_people_execution_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_phase2_people_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_photo_commons_first_test_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_photo_harvest_readiness_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_photo_harvest_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_photo_license_review_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_photo_official_site_review_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_photo_ready_for_test_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_photo_wait_for_paid_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_run_command_queue_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_run_command_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_pc2_run_command_queue_v2` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_master_readiness_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_pipeline_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PEOPLE | People Layer | -1 | 0 bytes | NE | 0 | 0 |  | Měří průchod hráčů přes RAW payloady, staging, public.players a player_provider_map. |
| `ops` | `v_people_pipeline_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PEOPLE | People Layer | -1 | 0 bytes | NE | 0 | 0 |  | Agreguje stav PEOPLE pipeline ze sportovního pohledu. |
| `ops` | `v_people_provider_hunt_matrix_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_provider_master_matrix_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_provider_roadmap_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_provider_scorecard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_runtime_gap_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_runtime_gap_v2` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_source_discovery_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_people_source_gap_analysis_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_candidate_approved_for_merge_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_candidate_review_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_free_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_limited_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_paid_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_review_action_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_review_action_plan_v2` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_review_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_review_summary_v2` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_license_review_top_v2` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_provider_approval_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_provider_approval_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_provider_free_license_check_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_provider_paid_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_provider_pc2_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_provider_research_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_provider_research_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_review_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_review_panel_actions_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_review_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_photo_review_player_context_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_planner_cooldown_candidates_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_planner_cooldown_candidates_v2 |  |
| `ops` | `v_planner_cooldown_candidates_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_planner_pending_guard_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_planner_pending_guard_v2 |  |
| `ops` | `v_planner_pending_guard_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_planner_queue_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_planner_target_quality_guard_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_canonical_identity_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_detail_coverage_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_detail_coverage_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_detail_coverage_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_duplicate_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_duplicate_candidate_detail_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_duplicate_governance_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_duplicate_merge_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_duplicate_prevention_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_duplicate_review_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_enrichment_priority_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_enrichment_queue` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_form_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_identity_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_identity_review_hold_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_insert_guard_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_insert_guard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_profile_quality_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_profile_quality_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_provider_collision_review_hold_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_provider_governance_final_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_provider_identity_collision_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_provider_map_governance_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_provider_map_governance_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_rating_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_rating_quality_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_player_without_provider_map_fix_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_project_milestone_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_project_milestones_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_project_next_actions_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_project_roadmap_milestones_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_project_roadmap_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_alternative_lookup_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_alternative_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_discovery_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_entity_status` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  | Spojuje provider coverage, planner a targety. |
| `ops` | `v_provider_failure_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_health` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_health_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_health_full` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  | Hlavní health view providerů. |
| `ops` | `v_provider_instability` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_missing_access_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_missing_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_missing_matrix_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_missing_matrix_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_missing_sport_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_missing_status_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_missing_top_priority_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_pc2_ready_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_priority_matrix_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_profile_enrichment_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_recommendation_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_research_master_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_routing_master` | VIEW | LEGACY / REVIEW | DROP_CANDIDATE |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_provider_routing_master_v2 | Kandidát na odstranění po kontrole závislostí v kódu, panelu a workerech. |
| `ops` | `v_provider_routing_master_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | PROVIDER | Provider Routing Layer | -1 | 0 bytes | NE | 0 | 0 |  | Spojuje coverage, runtime audit, sport completion, people audit a provider matrix. |
| `ops` | `v_provider_strategy_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_strategy_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_switch_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | PROVIDER |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_provider_switch_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL | PANEL |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_public_coaches_model_status_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_public_table_catalog_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_public_view_catalog_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ranked_launcher_dispatch_next_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ranked_launcher_dispatch_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ranked_launcher_dispatch_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_ranked_launcher_dispatch_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_recent_failures_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_learning_capture_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_learning_pending_capture_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_learning_recommendations_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_learning_stats_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_reset_audit_recent_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_reset_candidate_next_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_reset_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_repair_reset_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_run_next_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_run_next_execution_candidate_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_run_next_execution_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_run_next_execution_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_run_next_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_run_ready_queue` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_runtime_alerts_grouped_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_runtime_alerts_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_runtime_cleanup_guard_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_REVIEW | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_runtime_entity_audit_summary` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_runtime_heartbeat_governance_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_runtime_operations_center_feed_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | RUNTIME | Runtime Layer | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_safe_execution_queue_v1` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_safe_execution_queue_v2 |  |
| `ops` | `v_safe_execution_queue_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_safe_run_next_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_safe_run_next_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_autopilot_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_execution_confidence_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_health_score_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_queue_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_ready_governance_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_recent_health_score_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_runtime_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_scheduler_runtime_metrics_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_search_test_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_second_wave_league_candidate_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_smart_core_quota_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_source_discovery_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_source_discovery_engine_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_source_discovery_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_source_discovery_status_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Source Discovery Status Dashboard V1 - souhrn auditních stavů zdrojů. |
| `ops` | `v_source_discovery_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_sport_completion_dashboard_v1` | VIEW | LEGACY / REVIEW | DROP_CANDIDATE |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_sport_completion_dashboard_v2 | Kandidát na odstranění po kontrole závislostí v kódu, panelu a workerech. |
| `ops` | `v_sport_completion_dashboard_v2` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER | OPS | Project Readiness Layer | -1 | 0 bytes | NE | 0 | 0 |  | Počítá CORE/PEOPLE/MEDIA/ODDS procenta a doporučený focus sportu. |
| `ops` | `v_sport_completion_people_mismatch_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_sport_completion_summary` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_sport_coverage_harvest_planner_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_sport_coverage_harvest_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_sport_daily_budget_monitor_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_sport_detail_harvest_queue_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_sport_detail_harvest_queue_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_staging_catalog_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_alias_coverage_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_canonical_identity_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_duplicate_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_duplicate_audit_v2` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_duplicate_merge_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_duplicate_prevention_dashboard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_hold_dependency_detail_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_hold_player_move_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_insert_guard_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_insert_guard_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_insert_risk_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_master_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_master_validation_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_provider_map_merge_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_provider_map_merge_execution_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_reference_columns_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_safe_merge_execution_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_safe_merge_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_same_name_review_hold_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_sport_normalization_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_team_sport_normalization_plan_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_top_development_tasks_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_top_development_tasks_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_top_ingest_jobs` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_top_ingest_jobs_full_mode` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_top_ingest_jobs_runnable |  |
| `ops` | `v_top_ingest_jobs_ordered` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_top_ingest_jobs_runnable` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_top_ingest_jobs_test_mode` | VIEW | LEGACY / REVIEW | LEGACY_KEEP |  |  | -1 | 0 bytes | NE | 0 | 0 | ops.v_top_ingest_jobs_runnable |  |
| `ops` | `v_top_ingest_targets` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_top_player_enrichment_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_universal_match_context_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_unmapped_league_audit_v1` | VIEW | OPERATIONAL / GOVERNANCE | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_capability_registry_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_execution_rules_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_health_inspector_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_launcher_candidates_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_launcher_next_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_launcher_summary_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_locks_active` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Currently active worker locks (non-expired locks). |
| `ops` | `v_worker_registry_panel_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_PANEL |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
| `ops` | `v_worker_resolver_v1` | VIEW | OPERATIONAL / GOVERNANCE | ACTIVE_MASTER |  |  | -1 | 0 bytes | NE | 0 | 0 |  |  |
### A.4 Schéma `documentation`

| Schéma | Objekty | Tabulky | Views | Sekvence |
|---|---:|---:|---:|---:|
| `documentation` | 17 | 7 | 3 | 7 |

| Schéma | Objekt | Typ | Primární role | Governance stav | Doména | Vlastnická vrstva | Odhad řádků | Velikost | PK | FK | Indexy | Náhrada | Účel nebo poznámka |
|---|---|---|---|---|---|---|---:|---:|---|---:|---:|---|---|
| `documentation` | `document_relations_relation_pk_seq` | SEQUENCE | DOCUMENTATION | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `documentation` | `document_sections_section_pk_seq` | SEQUENCE | DOCUMENTATION | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `documentation` | `document_status_history_status_history_pk_seq` | SEQUENCE | DOCUMENTATION | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `documentation` | `document_versions_version_pk_seq` | SEQUENCE | DOCUMENTATION | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `documentation` | `documents_document_pk_seq` | SEQUENCE | DOCUMENTATION | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `documentation` | `import_runs_import_run_pk_seq` | SEQUENCE | DOCUMENTATION | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `documentation` | `status_snapshots_status_snapshot_pk_seq` | SEQUENCE | DOCUMENTATION | UNCLASSIFIED |  |  | 1 | 8192 bytes | NE | 0 | 0 |  |  |
| `documentation` | `document_relations` | TABLE | DOCUMENTATION | UNCLASSIFIED |  |  | 147 | 136 kB | ANO | 2 | 4 |  | Řízené vazby mezi dokumenty, standardy, referencemi a souvisejícími oblastmi. |
| `documentation` | `document_sections` | TABLE | DOCUMENTATION | UNCLASSIFIED |  |  | 3 779 | 3696 kB | ANO | 2 | 5 |  | Strukturované kapitoly a podkapitoly konkrétní verze dokumentu. |
| `documentation` | `document_status_history` | TABLE | DOCUMENTATION | UNCLASSIFIED |  |  | 314 | 160 kB | ANO | 2 | 2 |  | Auditní historie změn stavů dokumentů. |
| `documentation` | `document_versions` | TABLE | DOCUMENTATION | UNCLASSIFIED |  |  | 314 | 3024 kB | ANO | 2 | 8 |  | Úplná historie verzí a Markdown obsahu jednotlivých dokumentů. |
| `documentation` | `documents` | TABLE | DOCUMENTATION | UNCLASSIFIED |  |  | 312 | 1360 kB | ANO | 0 | 7 |  | Centrální registr dokumentů MatchMatrix. Jeden řádek představuje jedno neměnné Document ID. |
| `documentation` | `import_runs` | TABLE | DOCUMENTATION | UNCLASSIFIED |  |  | -1 | 64 kB | ANO | 0 | 1 |  | Auditní evidence každého importu dokumentace z Git repozitáře do databáze. |
| `documentation` | `status_snapshots` | TABLE | DOCUMENTATION | UNCLASSIFIED |  |  | -1 | 152 kB | ANO | 0 | 7 |  | Historické stavové snapshoty celé dokumentační vrstvy MatchMatrix. Nejedná se o historii stavů jednotlivých dokumentů. |
| `documentation` | `v_document_integrity_v1` | VIEW | DOCUMENTATION | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Kontrolní pohled ověřující základní úplnost a konzistenci registru dokumentů. |
| `documentation` | `v_document_registry_v1` | VIEW | DOCUMENTATION | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Jednotný registr dokumentů včetně aktuální importované verze. |
| `documentation` | `v_latest_status_snapshot_v1` | VIEW | DOCUMENTATION | UNCLASSIFIED |  |  | -1 | 0 bytes | NE | 0 | 0 |  | Poslední uložený stavový snapshot dokumentační vrstvy MatchMatrix. |
### A.5 Schéma `work`

| Schéma | Objekty | Tabulky | Views | Sekvence |
|---|---:|---:|---:|---:|
| `work` | 3 | 3 | 0 | 0 |

| Schéma | Objekt | Typ | Primární role | Governance stav | Doména | Vlastnická vrstva | Odhad řádků | Velikost | PK | FK | Indexy | Náhrada | Účel nebo poznámka |
|---|---|---|---|---|---|---|---:|---:|---|---:|---:|---|---|
| `work` | `leagues_to_add` | TABLE | WORK / TEMPORARY | UNCLASSIFIED |  |  | -1 | 16 kB | ANO | 0 | 1 |  |  |
| `work` | `missing_player_profile_batches` | TABLE | WORK / TEMPORARY | UNCLASSIFIED |  |  | 4 379 | 784 kB | NE | 0 | 0 |  |  |
| `work` | `missing_player_profile_ids` | TABLE | WORK / TEMPORARY | UNCLASSIFIED |  |  | 220 | 48 kB | NE | 0 | 0 |  |  |


### Závěr kapitoly

Příloha A poskytuje úplný fyzický registr hlavních objektových typů. Přínosem je dohledatelnost každého objektu podle schématu, role, governance stavu, domény, vrstvy, velikosti a dostupného účelu. Návaznost pokračuje rutinami.

---

## Příloha B – úplný katalog rutin

Příloha obsahuje všech 95 rutin zachycených auditem A33.

| Schéma | Signatura | Typ | Jazyk | Výsledek | Volatilita | SECURITY DEFINER | Komentář |
|---|---|---|---|---|---|---|---|
| `public` | `check_max_3_matches_per_block()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `check_max_variable_blocks()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `create_block_from_selection(integer,integer,text,text)` | FUNCTION | plpgsql | `integer` | VOLATILE | NE |  |
| `public` | `fn_refresh_ticket_run_settlements()` | FUNCTION | plpgsql | `void` | VOLATILE | NE |  |
| `public` | `fn_set_updated_at_team_coach_history()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `generate_run(integer,text)` | FUNCTION | plpgsql | `integer` | VOLATILE | NE |  |
| `public` | `gin_extract_query_trgm(text,internal,smallint,internal,internal,internal,internal)` | FUNCTION | c | `internal` | IMMUTABLE | NE |  |
| `public` | `gin_extract_value_trgm(text,internal)` | FUNCTION | c | `internal` | IMMUTABLE | NE |  |
| `public` | `gin_trgm_consistent(internal,smallint,text,integer,internal,internal,internal,internal)` | FUNCTION | c | `boolean` | IMMUTABLE | NE |  |
| `public` | `gin_trgm_triconsistent(internal,smallint,text,integer,internal,internal,internal)` | FUNCTION | c | `"char"` | IMMUTABLE | NE |  |
| `public` | `gtrgm_compress(internal)` | FUNCTION | c | `internal` | IMMUTABLE | NE |  |
| `public` | `gtrgm_consistent(internal,text,smallint,oid,internal)` | FUNCTION | c | `boolean` | IMMUTABLE | NE |  |
| `public` | `gtrgm_decompress(internal)` | FUNCTION | c | `internal` | IMMUTABLE | NE |  |
| `public` | `gtrgm_distance(internal,text,smallint,oid,internal)` | FUNCTION | c | `double precision` | IMMUTABLE | NE |  |
| `public` | `gtrgm_in(cstring)` | FUNCTION | c | `gtrgm` | IMMUTABLE | NE |  |
| `public` | `gtrgm_options(internal)` | FUNCTION | c | `void` | IMMUTABLE | NE |  |
| `public` | `gtrgm_out(gtrgm)` | FUNCTION | c | `cstring` | IMMUTABLE | NE |  |
| `public` | `gtrgm_penalty(internal,internal,internal)` | FUNCTION | c | `internal` | IMMUTABLE | NE |  |
| `public` | `gtrgm_picksplit(internal,internal)` | FUNCTION | c | `internal` | IMMUTABLE | NE |  |
| `public` | `gtrgm_same(gtrgm,gtrgm,internal)` | FUNCTION | c | `internal` | IMMUTABLE | NE |  |
| `public` | `gtrgm_union(internal,internal)` | FUNCTION | c | `gtrgm` | IMMUTABLE | NE |  |
| `public` | `merge_team(integer,integer,text,text,boolean,boolean)` | FUNCTION | plpgsql | `void` | VOLATILE | NE |  |
| `public` | `mm_apply_risk_team_max(bigint,integer,boolean)` | FUNCTION | plpgsql | `void` | VOLATILE | NE |  |
| `public` | `mm_generate_run_engine(bigint,integer,integer,numeric,integer)` | FUNCTION | plpgsql | `bigint` | VOLATILE | NE |  |
| `public` | `mm_generate_tickets_engine(bigint,bigint,integer,numeric,integer)` | FUNCTION | plpgsql | `void` | VOLATILE | NE |  |
| `public` | `mm_get_max_tickets()` | FUNCTION | sql | `integer` | STABLE | NE |  |
| `public` | `mm_get_odds_compare(bigint,bigint)` | FUNCTION | sql | `TABLE(bookmaker_id integer, bookmaker_name text, odd_value numeric, collected_at timestamp with time zone)` | STABLE | NE |  |
| `public` | `mm_market_h2h_id()` | FUNCTION | sql | `bigint` | STABLE | NE |  |
| `public` | `mm_match_info_detail(bigint)` | FUNCTION | sql | `TABLE(match_id bigint, league_id integer, season text, home_team_id integer, away_team_id integer, home_team text, away_team text, home_position integer, away_position integer, home_points integer, away_points integer, home_played integer, away_played integer, home_gf integer, home_ga integer, away_gf integer, away_ga integer, home_form_5 text, away_form_5 text, home_form_10 text, away_form_10 text, home_form_15 text, away_form_15 text, home_pts_5 integer, away_pts_5 integer, home_pts_10 integer, away_pts_10 integer, home_pts_15 integer, away_pts_15 integer, h2h_home_wins integer, h2h_draws integer, h2h_away_wins integer)` | STABLE | NE |  |
| `public` | `mm_preview_run(bigint)` | FUNCTION | plpgsql | `TABLE(template_id bigint, variable_blocks integer, fixed_picks integer, estimated_tickets bigint, preview_blocks_detail jsonb, preview_warnings text[])` | VOLATILE | NE |  |
| `public` | `mm_preview_run(bigint,integer)` | FUNCTION | plpgsql | `TABLE(template_id bigint, variable_blocks integer, fixed_picks integer, estimated_tickets bigint, preview_blocks_detail jsonb, preview_warnings text[])` | VOLATILE | NE |  |
| `public` | `mm_save_generated_run_full(bigint)` | FUNCTION | plpgsql | `TABLE(out_run_id bigint, out_ticket_ref_id bigint, out_tickets_rows integer, out_ticket_blocks_rows integer, out_ticket_block_matches_rows integer, out_history_inserted_rows integer, out_history_updated_rows integer, out_status_text text)` | VOLATILE | NE |  |
| `public` | `mm_ui_run_summary(bigint,numeric)` | FUNCTION | sql | `TABLE(run_id bigint, bookmaker_id integer, tickets_count integer, stake_per_ticket numeric, total_stake numeric, max_total_odd numeric, min_total_odd numeric, avg_total_odd numeric, max_possible_win numeric)` | STABLE | NE |  |
| `public` | `mm_ui_run_tickets(bigint)` | FUNCTION | plpgsql | `TABLE(run_id bigint, ticket_index integer, bookmaker_id integer, total_odd numeric, items jsonb)` | VOLATILE | NE |  |
| `public` | `mm_ui_run_tickets_with_stake(bigint,numeric)` | FUNCTION | sql | `TABLE(run_id bigint, ticket_index integer, bookmaker_id integer, total_odd numeric, possible_win numeric, items jsonb)` | STABLE | NE |  |
| `public` | `mm_update_run_probability(bigint)` | FUNCTION | sql | `void` | VOLATILE | NE |  |
| `public` | `mm_validate_template(bigint)` | FUNCTION | plpgsql | `void` | VOLATILE | NE |  |
| `public` | `normalize_team_name(text)` | FUNCTION | sql | `text` | IMMUTABLE | NE |  |
| `public` | `refresh_league_standings(integer,text)` | FUNCTION | plpgsql | `void` | VOLATILE | NE |  |
| `public` | `refresh_product_league_standings()` | FUNCTION | plpgsql | `void` | VOLATILE | NE |  |
| `public` | `set_limit(real)` | FUNCTION | c | `real` | VOLATILE | NE |  |
| `public` | `set_updated_at()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `set_updated_at_generic()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `show_limit()` | FUNCTION | c | `real` | STABLE | NE |  |
| `public` | `show_trgm(text)` | FUNCTION | c | `text[]` | IMMUTABLE | NE |  |
| `public` | `similarity(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `similarity_dist(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `similarity_op(text,text)` | FUNCTION | c | `boolean` | STABLE | NE |  |
| `public` | `strict_word_similarity(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `strict_word_similarity_commutator_op(text,text)` | FUNCTION | c | `boolean` | STABLE | NE |  |
| `public` | `strict_word_similarity_dist_commutator_op(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `strict_word_similarity_dist_op(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `strict_word_similarity_op(text,text)` | FUNCTION | c | `boolean` | STABLE | NE |  |
| `public` | `trg_check_max_variable_blocks()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `trg_set_updated_at_league_standings()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `trg_set_updated_at_standings_rules()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `trg_template_block_matches_guard()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `trg_template_block_matches_not_empty()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `trg_template_blocks_guard()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `public` | `unaccent(regdictionary,text)` | FUNCTION | c | `text` | STABLE | NE |  |
| `public` | `unaccent(text)` | FUNCTION | c | `text` | STABLE | NE |  |
| `public` | `unaccent_init(internal)` | FUNCTION | c | `internal` | VOLATILE | NE |  |
| `public` | `unaccent_lexize(internal,internal,internal,internal)` | FUNCTION | c | `internal` | VOLATILE | NE |  |
| `public` | `word_similarity(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `word_similarity_commutator_op(text,text)` | FUNCTION | c | `boolean` | STABLE | NE |  |
| `public` | `word_similarity_dist_commutator_op(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `word_similarity_dist_op(text,text)` | FUNCTION | c | `real` | IMMUTABLE | NE |  |
| `public` | `word_similarity_op(text,text)` | FUNCTION | c | `boolean` | STABLE | NE |  |
| `ops` | `ops.fn_autonomous_postrun_learning_v1()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `ops` | `ops.fn_build_development_task_queue_v1()` | FUNCTION | plpgsql | `TABLE(success boolean, inserted_rows integer, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_context_match_pair_search_v1(text,text,integer)` | FUNCTION | sql | `TABLE(match_id bigint, kickoff timestamp without time zone, status text, home_team_id bigint, home_team text, away_team_id bigint, away_team text, league_id bigint, league_name text, season text, sport_id bigint, ext_source text, ext_match_id text, team_a_match_name text, team_b_match_name text, final_score numeric)` | VOLATILE | NE |  |
| `ops` | `ops.fn_context_match_pair_search_v2(text,text,bigint,integer)` | FUNCTION | sql | `TABLE(match_id bigint, kickoff timestamp without time zone, status text, home_team_id bigint, home_team text, away_team_id bigint, away_team text, league_id bigint, league_name text, season text, sport_id bigint, ext_source text, ext_match_id text, team_a_match_name text, team_b_match_name text, final_score numeric)` | VOLATILE | NE |  |
| `ops` | `ops.fn_context_search_v1(text,integer)` | FUNCTION | sql | `TABLE(entity_type text, entity_id bigint, search_text text, canonical_name text, sport_id bigint, country text, source_type text, final_score numeric)` | VOLATILE | NE |  |
| `ops` | `ops.fn_context_search_v2(text,integer)` | FUNCTION | sql | `TABLE(entity_type text, entity_id bigint, search_text text, canonical_name text, sport_id bigint, country text, source_type text, final_score numeric)` | VOLATILE | NE |  |
| `ops` | `ops.fn_context_search_v3(text,integer)` | FUNCTION | sql | `TABLE(entity_type text, entity_id bigint, search_text text, canonical_name text, sport_id bigint, country text, source_type text, query_mode text, final_score numeric)` | VOLATILE | NE |  |
| `ops` | `ops.fn_enqueue_next_autonomous_action_v1()` | FUNCTION | plpgsql | `TABLE(enqueue_ok boolean, queue_id bigint, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_finish_autonomous_action_v1(bigint,boolean,text)` | FUNCTION | plpgsql | `TABLE(finish_ok boolean, queue_id bigint, final_status text, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_mark_next_autonomous_action_running_v1()` | FUNCTION | plpgsql | `TABLE(mark_ok boolean, queue_id bigint, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_match_context_engine_v1(text,text,bigint)` | FUNCTION | sql | `TABLE(metric_name text, metric_value text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_match_context_engine_v2(text,text,bigint)` | FUNCTION | sql | `TABLE(section_name text, item_order integer, item_value text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_match_context_engine_v3(text,text,bigint)` | FUNCTION | sql | `TABLE(section_name text, item_order integer, item_value text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_merge_approved_player_photos_v1()` | FUNCTION | plpgsql | `TABLE(merged_count integer)` | VOLATILE | NE |  |
| `ops` | `ops.fn_operator_accept_provider_candidate_v1(bigint,text)` | FUNCTION | plpgsql | `TABLE(success boolean, validation_id bigint, sport_code text, entity_type text, accepted_provider text, implementation_status text, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_operator_create_provider_discovery_action_v1(bigint,text)` | FUNCTION | plpgsql | `TABLE(success boolean, command_id bigint, sport_code text, entity_type text, current_provider text, action_status text, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_operator_execute_fix_v1(bigint,text)` | FUNCTION | plpgsql | `TABLE(success boolean, fix_execution_id bigint, out_monitor_id bigint, out_fix_code text, execution_status text, execution_message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_operator_run_provider_discovery_engine_v1(bigint,text)` | FUNCTION | plpgsql | `TABLE(success boolean, discovery_action_id bigint, sport_code text, entity_type text, candidates_created integer, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_operator_validate_provider_candidate_v1(bigint,text)` | FUNCTION | plpgsql | `TABLE(success boolean, candidate_id bigint, candidate_provider text, sport_code text, entity_type text, validation_score numeric, validation_status text, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_pc2_insert_execution_history_v1(bigint,integer,text,integer,text,text)` | FUNCTION | plpgsql | `bigint` | VOLATILE | NE |  |
| `ops` | `ops.fn_reset_repaired_planner_item_v1(text,text,text,text,text,text,text)` | FUNCTION | plpgsql | `TABLE(reset_ok boolean, affected_rows integer, message text)` | VOLATILE | NE |  |
| `ops` | `ops.fn_write_autonomous_learning_v1()` | FUNCTION | plpgsql | `TABLE(write_ok boolean, written_rows integer, message text)` | VOLATILE | NE |  |
| `ops` | `ops.set_updated_at_provider_entity_coverage()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `ops` | `ops.set_updated_at_provider_people_audit()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `ops` | `ops.set_updated_at_runtime_entity_audit()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `ops` | `ops.set_updated_at_sport_completion_audit()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE |  |
| `documentation` | `documentation.set_updated_at()` | FUNCTION | plpgsql | `trigger` | VOLATILE | NE | Nastavuje updated_at při každé změně řádku dokumentu. |

### Závěr kapitoly

Příloha B eviduje všechny auditované rutiny včetně signatur, jazyků a bezpečnostního režimu. Přínosem je základ pro budoucí MM-DB-006. Návaznost pokračuje triggery.

---

## Příloha C – úplný katalog triggerů

Příloha obsahuje všech 23 triggerů zachycených auditem A33.

| Schéma | Objekt | Trigger | Režim | Funkce | Definice |
|---|---|---|---|---|---|
| `staging` | `api_tennis_fixtures` | `trg_tn_fx_updated` | O | `public.set_updated_at_generic` | CREATE TRIGGER trg_tn_fx_updated BEFORE UPDATE ON staging.api_tennis_fixtures FOR EACH ROW EXECUTE FUNCTION set_updated_at_generic() |
| `staging` | `api_tennis_leagues` | `trg_api_tennis_leagues_set_updated_at` | O | `public.set_updated_at_generic` | CREATE TRIGGER trg_api_tennis_leagues_set_updated_at BEFORE UPDATE ON staging.api_tennis_leagues FOR EACH ROW EXECUTE FUNCTION set_updated_at_generic() |
| `public` | `auto_ticket_strategies` | `trg_auto_ticket_strategies_updated_at` | O | `public.set_updated_at` | CREATE TRIGGER trg_auto_ticket_strategies_updated_at BEFORE UPDATE ON auto_ticket_strategies FOR EACH ROW EXECUTE FUNCTION set_updated_at() |
| `public` | `league_standings` | `trg_league_standings_updated_at` | O | `public.trg_set_updated_at_league_standings` | CREATE TRIGGER trg_league_standings_updated_at BEFORE UPDATE ON league_standings FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at_league_standings() |
| `public` | `matches` | `trg_matches_updated_at` | O | `public.set_updated_at` | CREATE TRIGGER trg_matches_updated_at BEFORE UPDATE ON matches FOR EACH ROW EXECUTE FUNCTION set_updated_at() |
| `public` | `mm_ticket_scenarios` | `trg_mm_ticket_scenarios_set_updated_at` | O | `public.set_updated_at` | CREATE TRIGGER trg_mm_ticket_scenarios_set_updated_at BEFORE UPDATE ON mm_ticket_scenarios FOR EACH ROW EXECUTE FUNCTION set_updated_at() |
| `public` | `standings_rules` | `trg_standings_rules_updated_at` | O | `public.trg_set_updated_at_standings_rules` | CREATE TRIGGER trg_standings_rules_updated_at BEFORE UPDATE ON standings_rules FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at_standings_rules() |
| `public` | `team_coach_history` | `trg_set_updated_at_team_coach_history` | O | `public.fn_set_updated_at_team_coach_history` | CREATE TRIGGER trg_set_updated_at_team_coach_history BEFORE UPDATE ON team_coach_history FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at_team_coach_history() |
| `public` | `template_block_matches` | `template_block_matches_guard` | O | `public.trg_template_block_matches_guard` | CREATE TRIGGER template_block_matches_guard BEFORE INSERT OR UPDATE ON template_block_matches FOR EACH ROW EXECUTE FUNCTION trg_template_block_matches_guard() |
| `public` | `template_block_matches` | `trg_template_block_matches_not_empty` | O | `public.trg_template_block_matches_not_empty` | CREATE TRIGGER trg_template_block_matches_not_empty BEFORE DELETE ON template_block_matches FOR EACH ROW EXECUTE FUNCTION trg_template_block_matches_not_empty() |
| `public` | `template_blocks` | `check_max_variable_blocks` | O | `public.trg_check_max_variable_blocks` | CREATE TRIGGER check_max_variable_blocks BEFORE INSERT OR UPDATE ON template_blocks FOR EACH ROW EXECUTE FUNCTION trg_check_max_variable_blocks() |
| `public` | `template_blocks` | `trg_check_max_variable_blocks` | O | `public.check_max_variable_blocks` | CREATE TRIGGER trg_check_max_variable_blocks BEFORE INSERT OR UPDATE ON template_blocks FOR EACH ROW EXECUTE FUNCTION check_max_variable_blocks() |
| `public` | `template_blocks` | `trg_template_blocks_guard` | O | `public.trg_template_blocks_guard` | CREATE TRIGGER trg_template_blocks_guard BEFORE INSERT OR UPDATE ON template_blocks FOR EACH ROW EXECUTE FUNCTION trg_template_blocks_guard() |
| `ops` | `autonomous_execution_queue` | `trg_autonomous_postrun_learning_v1` | O | `ops.fn_autonomous_postrun_learning_v1` | CREATE TRIGGER trg_autonomous_postrun_learning_v1 AFTER UPDATE ON ops.autonomous_execution_queue FOR EACH ROW EXECUTE FUNCTION ops.fn_autonomous_postrun_learning_v1() |
| `ops` | `ingest_entity_plan` | `trg_ingest_entity_plan_set_updated_at` | O | `public.set_updated_at` | CREATE TRIGGER trg_ingest_entity_plan_set_updated_at BEFORE UPDATE ON ops.ingest_entity_plan FOR EACH ROW EXECUTE FUNCTION set_updated_at() |
| `ops` | `league_import_plan` | `trg_ops_league_import_plan_updated_at` | O | `public.set_updated_at` | CREATE TRIGGER trg_ops_league_import_plan_updated_at BEFORE UPDATE ON ops.league_import_plan FOR EACH ROW EXECUTE FUNCTION set_updated_at() |
| `ops` | `provider_accounts` | `trg_provider_accounts_set_updated_at` | O | `public.set_updated_at` | CREATE TRIGGER trg_provider_accounts_set_updated_at BEFORE UPDATE ON ops.provider_accounts FOR EACH ROW EXECUTE FUNCTION set_updated_at() |
| `ops` | `provider_entity_coverage` | `trg_provider_entity_coverage_updated_at` | O | `ops.set_updated_at_provider_entity_coverage` | CREATE TRIGGER trg_provider_entity_coverage_updated_at BEFORE UPDATE ON ops.provider_entity_coverage FOR EACH ROW EXECUTE FUNCTION ops.set_updated_at_provider_entity_coverage() |
| `ops` | `provider_jobs` | `trg_provider_jobs_set_updated_at` | O | `public.set_updated_at` | CREATE TRIGGER trg_provider_jobs_set_updated_at BEFORE UPDATE ON ops.provider_jobs FOR EACH ROW EXECUTE FUNCTION set_updated_at() |
| `ops` | `provider_people_audit` | `trg_set_updated_at_provider_people_audit` | O | `ops.set_updated_at_provider_people_audit` | CREATE TRIGGER trg_set_updated_at_provider_people_audit BEFORE UPDATE ON ops.provider_people_audit FOR EACH ROW EXECUTE FUNCTION ops.set_updated_at_provider_people_audit() |
| `ops` | `runtime_entity_audit` | `trg_set_updated_at_runtime_entity_audit` | O | `ops.set_updated_at_runtime_entity_audit` | CREATE TRIGGER trg_set_updated_at_runtime_entity_audit BEFORE UPDATE ON ops.runtime_entity_audit FOR EACH ROW EXECUTE FUNCTION ops.set_updated_at_runtime_entity_audit() |
| `ops` | `sport_completion_audit` | `trg_set_updated_at_sport_completion_audit` | O | `ops.set_updated_at_sport_completion_audit` | CREATE TRIGGER trg_set_updated_at_sport_completion_audit BEFORE UPDATE ON ops.sport_completion_audit FOR EACH ROW EXECUTE FUNCTION ops.set_updated_at_sport_completion_audit() |
| `documentation` | `documents` | `trg_documentation_documents_updated_at` | O | `documentation.set_updated_at` | CREATE TRIGGER trg_documentation_documents_updated_at BEFORE UPDATE ON documentation.documents FOR EACH ROW EXECUTE FUNCTION documentation.set_updated_at() |

### Závěr kapitoly

Příloha C eviduje všechny auditované triggery a jejich vazby na funkce. Přínosem je ochrana automatických databázových mechanismů při budoucích změnách. Návaznost pokračuje auditními nálezy.

---

## Příloha D – úplný registr auditních nálezů A33

Příloha obsahuje všech 226 nálezů. Nálezy jsou kontrolní signály, nikoli automatické změnové příkazy.

| Závažnost | Kód | Objekt | Popis | Evidence |
|---|---|---|---|---|
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.database_object_governance` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "Governance registry for MatchMatrix DB objects: master, active, legacy, drop candidates.", "governance_status": "ACTIVE_MASTER"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.eu_batch_1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.eu_batch_100` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.eu_keep_ids` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.fb_entity_audit` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.league_import_plan` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_active_runs_live_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_automation_execution_queue` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_automation_ready_queue_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_automation_ready_queue_v2` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_automation_ready_queue_v3` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_autonomous_ops_brain_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_autonomous_ops_brain_v2` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_autonomous_ops_brain_v3` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_autonomous_ops_brain_v4` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_data_gap_engine_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_data_gap_panel_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_implementation_readiness_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_ops_people_pipeline` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_orchestration_priority_queue_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_orchestration_priority_queue_v2` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_orchestration_priority_queue_v3` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_planner_cooldown_candidates_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_planner_pending_guard_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_provider_routing_master` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "DROP_CANDIDATE"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_safe_execution_queue_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_sport_completion_dashboard_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "DROP_CANDIDATE"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_top_ingest_jobs_full_mode` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `ops.v_top_ingest_jobs_test_mode` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.closing_odds` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.media_articles` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "DEPRECATED / TRANSITIONAL TABLE. Do not use for final media layer. Canonical target is public.articles. Created during temporary Python media merge test on 2026-05-11.", "governance_status": "ACTIVE"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.ml_match_dataset` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.ml_match_dataset_v2` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.unmatched_theodds` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_fb_team_power_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_fd_matches_base` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_fd_matches_today` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_fd_matches_tomorrow` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_fd_matches_week` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_fd_matches_week_ui` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_fd_matches_week_with_odds` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_homepage_media_feed_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_live_match_feed` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_team_player_form_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_team_player_form_v2` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.v_video_feed_v1` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `public.work_pl_aliases` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_football_fixtures` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_football_leagues` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_football_odds` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_football_teams` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_hockey_leagues` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_hockey_teams` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `TABLE_WITHOUT_PRIMARY_KEY` | `staging.api_hockey_teams_raw` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 1333, "statistics_live_rows": 0}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_tennis_fixtures` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.api_tennis_leagues` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.player_provider_map_import` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `LEGACY_OR_DEPRECATED_OBJECT` | `staging.players_import` | Objekt je názvem, komentářem nebo governance stavem označen jako legacy/deprecated. | `{"comment": "", "governance_status": "LEGACY_KEEP"}` |
| HIGH | `TABLE_WITHOUT_PRIMARY_KEY` | `staging.players_import` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 2745, "statistics_live_rows": 0}` |
| HIGH | `TABLE_WITHOUT_PRIMARY_KEY` | `work.missing_player_profile_batches` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 4379, "statistics_live_rows": 0}` |
| MEDIUM | `OBJECTS_WITHOUT_GOVERNANCE_MATCH` | `` | Část databázových objektů nemá jednoznačnou shodu v governance registru. | `{"ambiguous_objects": 0, "matched_objects": 540, "registry_rows": 540, "unmatched_objects": 575, "usable_registry_rows": 540}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `ops.eu_batch_1` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 1, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `ops.eu_batch_100` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 100, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `ops.ingest_planner` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 7794, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `ops.ingest_targets` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 4428, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `ops.job_runs` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 2030, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `ops.league_provider_map` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1600, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `ops.match_safe_delete_run_log` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1629, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `ops.media_asset_enrichment_queue` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 12250, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `ops.people_quality_backfill_queue` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": -1, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.api_raw_payloads` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1740, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.article_player_map` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1701, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.canonical_league_map` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1471, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `public.closing_odds` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": -1, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.context_alias_registry` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 4577, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.context_entity_registry` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 156283, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.generated_ticket_blocks` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1656, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.generated_tickets` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1052, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.league_provider_map` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 2650, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.league_standings` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 8806, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.league_teams` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 7648, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.leagues` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 3471, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.match_features` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 26746, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.matches` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 121911, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.ml_predictions` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 3459, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.mm_match_ratings` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 106401, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.mm_team_ratings` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 5237, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.mm_value_bets` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1298, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.odds` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 82386, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.player_provider_map` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 19493, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.player_season_statistics` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 3121, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.players` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 19493, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.seasons` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 2992, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.team_aliases` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 4557, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.team_provider_map` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 9510, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `public.teams` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 9773, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `public.unmatched_theodds` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 72, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `public.work_pl_aliases` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": -1, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.api_football_fixtures` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 184158, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.api_football_leagues` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 40345, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.api_football_teams` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 2554, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `staging.api_hockey_leagues` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 524, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `staging.api_hockey_leagues_raw` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 7, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `staging.api_hockey_teams` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 399, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.api_hockey_teams_raw` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1333, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `staging.player_provider_map_import` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": -1, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.players_import` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 2745, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.stg_api_payloads` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1750, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.stg_provider_fixtures` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 98090, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.stg_provider_leagues` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 9797, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.stg_provider_player_profiles` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 1015, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.stg_provider_player_season_stats` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 110319, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.stg_provider_players` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 19432, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `staging.stg_provider_teams` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 6859, "statistics_live_rows": 0}` |
| MEDIUM | `ANALYZE_NOT_RECORDED` | `work.missing_player_profile_batches` | U větší tabulky není evidován ANALYZE ani AUTOANALYZE. | `{"estimated_rows": 4379, "statistics_live_rows": 0}` |
| MEDIUM | `TABLE_WITHOUT_PRIMARY_KEY` | `work.missing_player_profile_ids` | Tabulka nemá primární klíč; ověřit, zda jde o záměrný staging/work objekt. | `{"estimated_rows": 220, "statistics_live_rows": 0}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `documentation.document_relations` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "24.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `documentation.documents` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "904.00 kB", "table_size": "416.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `documentation.status_snapshots` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "120.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.ai_action_execution_log` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.api_budget_status` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.autonomous_execution_queue` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.block_reason_catalog` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.brain_recommendation_log` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.dispatch_queue` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.entity_requirement_matrix` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.fix_tasks` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "96.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.global_source_registry` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.harvest_readiness_snapshot` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.harvest_run_monitor` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.ingest_runtime_config` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.layer_readiness_status` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.master_architecture_map` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.media_discovery_requests` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.media_job_runs` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.media_refresh_queue` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.media_source_discovery_candidates` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.media_source_health_audit` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.operator_fix_catalog` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.operator_fix_execution_log` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.operator_run_queue` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.panel_action_registry` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.pc2_command_center_sources` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.people_master_provider_matrix` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.player_enrichment_plan` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.project_milestones` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.project_roadmap_milestones_v1` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.provider_accounts` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.provider_coaches_runtime_checklist` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.provider_jobs` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "32.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.provider_missing_matrix` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "96.00 kB", "table_size": "16.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.provider_sport_matrix` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.runtime_execution_history` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "16.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.scheduler_queue` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.schema_migrations` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_activation_roadmap` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_commercial_model` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_coverage_matrix` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_discovery_audit_tracker` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_discovery_master` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_discovery_matrix` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_discovery_queue` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_discovery_review_plan` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_intelligence_map` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_legal_audit` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_quality_score` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_review_results` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.source_verification_log` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.sport_completion_audit` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.sport_dimension_rules` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.sport_entity_rules` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "16.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.sports_import_plan` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.v18_master_panel_sources` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.worker_capability_registry` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.worker_dependency_graph` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.worker_execution_rules` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.worker_locks` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `ops.worker_registry` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `SAME_OBJECT_NAME_IN_MULTIPLE_SCHEMAS` | `ops,public.league_provider_map` | Stejný název existuje ve více schématech; používat kvalifikované názvy. | `{"schemas": ["ops", "public"]}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ai_content_tags` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ai_translations` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.article_league_map` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "24.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.article_match_map` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "96.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.article_media_team_alias_map` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.article_team_map` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "16.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.auto_ticket_strategies` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.bookmakers` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.coach_provider_map` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.coaches` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "96.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.content_sources` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.languages` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.market_outcomes` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.markets` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.matches` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "47.52 MB", "table_size": "15.56 MB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.media_articles` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.media_content_sections` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.media_entity_aliases` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.media_team_alias_rules` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.odds` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "10.33 MB", "table_size": "5.00 MB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.player_form` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "16.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.player_match_statistics` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "96.00 kB", "table_size": "16.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.product_active_leagues` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.sports` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.standings_rules` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.team_aliases` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "1.08 MB", "table_size": "352.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.team_coach_history` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "128.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.team_coaches` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.team_social_links` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.template_block_matches` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.template_blocks` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.template_fixed_picks` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ticket_block_matches` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ticket_blocks` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ticket_generation_runs` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "48.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ticket_pattern_catalog` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ticket_pattern_settlements` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.ticket_strategy_catalog` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `public.tickets` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `LARGE_DATABASE_OBJECT` | `staging.api_football_fixtures` | Objekt přesahuje 100 MB a musí být zahrnut do kapacitního a zálohovacího plánu. | `{"total_bytes": 266510336, "total_size": "254.16 MB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `staging.api_hockey_leagues_raw` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `staging.api_tennis_fixtures_raw` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "32.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `staging.api_tennis_leagues` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `staging.api_tennis_leagues_raw` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `staging.stg_player_photo_candidates` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "64.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `staging.stg_player_source_payloads` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |
| INFO | `INDEXES_LARGER_THAN_TABLE` | `staging.stg_provider_coaches` | Indexy jsou více než dvojnásobně větší než data tabulky. | `{"index_size": "80.00 kB", "table_size": "8.00 kB"}` |

### Závěr kapitoly

Příloha D zachovává úplný auditní registr v čitelné podobě. Přínosem je transparentní oddělení zjištění, evidence a budoucího rozhodnutí. Návaznost pokračuje související dokumentací a zdrojovými artefakty.

---

## Související dokumenty

| Dokument | Vazba |
|---|---|
| MM-DOC-000 | Dokumentační rámec MatchMatrix |
| MM-DOC-001 | Mapa dokumentačních oblastí |
| MM-DOC-200 | Governance projektu |
| MM-DOC-300 | Architektura platformy |
| MM-DOC-800 | Vývojová příručka |
| MM-DB-001 | Architektura databáze |
| MM-DB-1000 | Index databázové dokumentace |
| MM-STD-001 | Standard tvorby hlavních dokumentů |
| MM-STD-003 | Životní cyklus a verzování |
| MM-STD-004 | Názvosloví a struktura |
| MM-STD-006 | Terminologie |
| MM-STD-007 | Identifikace a číslování |
| MM-STD-009 | AI Context a Project Snapshot |

### Závěr kapitoly

Kapitola vymezila dokumentační vazby katalogu. Přínosem je jednoznačné zařazení MM-DB-002 mezi architektonický základ a navazující detailní databázové dokumenty. Návaznost pokračuje zdrojovými artefakty.

---

## Zdrojové auditní artefakty

| Artefakt | Účel |
|---|---|
| `database_structure_audit_latest.json` | Strojový kompletní snapshot |
| `database_structure_audit_latest.md` | Čitelný souhrn A33 |
| `database_structure_schemas_*.csv` | Schémata |
| `database_structure_objects_*.csv` | TABLE, VIEW a SEQUENCE |
| `database_structure_columns_*.csv` | Sloupce |
| `database_structure_constraints_*.csv` | Constraints |
| `database_structure_indexes_*.csv` | Indexy |
| `database_structure_routines_*.csv` | Rutiny |
| `database_structure_triggers_*.csv` | Triggery |
| `database_structure_dependencies_*.csv` | Databázové závislosti |
| `database_structure_privileges_*.csv` | Oprávnění |
| `database_structure_governance_*.csv` | Governance metadata |
| `database_structure_warnings_*.csv` | Auditní nálezy |
| `25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py` | Reprodukovatelný auditní nástroj |

### Závěr kapitoly

Kapitola doložila všechny zdrojové artefakty potřebné k reprodukci katalogu. Přínosem je auditovatelnost a možnost budoucí automatické regenerace. Návaznost pokračuje závěrem dokumentu.

---

## Závěr dokumentu

`MM-DB-002 – Katalog schémat a databázových objektů MatchMatrix` vytváří první úplnou řízenou evidenci fyzické databázové struktury projektu.

Dokument potvrzuje:

- pět fyzických schémat,
- 1 115 objektů TABLE, VIEW a SEQUENCE,
- 95 rutin,
- 23 triggerů,
- 226 auditních nálezů,
- částečné governance pokrytí 540 objektů,
- 575 objektů vyžadujících doplnění klasifikace,
- potřebu oddělit fyzickou existenci, primární roli, governance stav a funkční doménu.

Nejdůležitějším výsledkem není seznam kandidátů k odstranění. Nejdůležitějším výsledkem je bezpečný referenční základ pro rozhodování.

Katalog umožňuje pokračovat k datovému slovníku, integritě, dependency auditu, rutinám, lineage, migracím, bezpečnosti a provozní správě bez ztráty dohledatelnosti.

---

## Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 0.9 | 2026-07-15 | První úplný návrh katalogu vytvořený z read-only auditu A33; připraven k A17 a uživatelskému schválení. |
