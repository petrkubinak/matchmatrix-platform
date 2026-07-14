# INDEX DATABÁZOVÉ DOKUMENTACE MATCHMATRIX

**Document ID:** `MM-DB-1000`  
**Edice:** MM-DOC TECH

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DB-1000 |
| Document ID | MM-DB-1000 |
| Název dokumentu | Index databázové dokumentace MatchMatrix |
| Typ dokumentu | DATABASE_DOCUMENTATION_INDEX |
| Dokumentační oblast | 04_DATABASE |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum | 2026-07-13 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Primární formát | Markdown (.md) |
| Cílové umístění | `docs/04_DATABASE/MM-DB-1000_INDEX_DATABAZOVE_DOKUMENTACE_MATCHMATRIX.md` |
| Nadřazená mapa | MM-DOC-001 |
| Nadřazený rámec | MM-DOC-000 |
| Hlavní architektonický zdroj | MM-DOC-300 |
| Hlavní governance zdroj | MM-DOC-200 |
| Hlavní vývojový zdroj | MM-DOC-800 |
| Související standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-009 |
| Výchozí Git commit | `6297568a80e23c492ff8dea5fc3e835ebf8e9c73` |
| Git synchronizace | `HEAD = origin/main` |
| Zdroj pravdy | Git + PostgreSQL + řízená dokumentační databáze |

---

## 1. Úvod – Účel a rozsah databázové oblasti

### 1.1 Účel dokumentu

Tento dokument vytváří základ oblasti `docs/04_DATABASE`.

Jeho účelem je:

- určit, co patří do databázové dokumentace,
- určit, co do databázové dokumentace nepatří,
- stanovit základní databázové principy MatchMatrix,
- vytvořit plán navazujících dokumentů,
- oddělit ověřený stav od návrhů a plánů,
- připravit jednotný referenční bod pro další rozvoj databáze,
- vytvořit index, podle kterého budou databázové změny dlouhodobě dokumentovány.

Dokument není úplným katalogem všech databázových objektů. Je oblastním rozcestníkem a základní databázovou mapou.

### 1.2 Rozsah platnosti

Dokument se vztahuje na:

- produkční PostgreSQL databázi MatchMatrix,
- datové vrstvy raw, staging, merge a canonical,
- schéma `public`,
- operační a governance objekty,
- dokumentační databázovou vrstvu,
- tabulky, pohledy, funkce, procedury, indexy a constraints,
- databázové migrace,
- auditní a kontrolní objekty,
- pravidla integrity, výkonu, bezpečnosti, záloh a obnovy,
- databázové vazby na ingest, workery, panel, web, analytiku a AI.

### 1.3 Co dokument nenahrazuje

Tento dokument nenahrazuje:

- detailní architekturu celé platformy,
- providerovou dokumentaci,
- dokumentaci jednotlivých workerů,
- provozní runbook Operator panelu,
- SQL migrační soubory,
- technické specifikace jednotlivých tabulek,
- denní zápisy a historické Project Snapshoty.

### Závěr kapitoly

Kapitola vymezila účel a hranice databázové oblasti. Jejím přínosem je jasné oddělení databázové dokumentace od architektury, providerů, vývoje a provozní historie. Návaznost pokračuje v další kapitole, která stanovuje ověřené zdroje a úroveň důvěry jednotlivých informací.

---

## 2. Ověřené zdroje a důkazní pravidla

### 2.1 Primární zdroje

| Zdroj | Úloha |
|---|---|
| MM-DOC-001 | Určuje odpovědnost složky `04_DATABASE` a vznik tohoto indexu |
| MM-DOC-300 | Popisuje vícevrstvou architekturu, jednotné `stg_*`, parser a merge |
| MM-DOC-200 | Definuje Database Governance a ochranu konzistence |
| MM-DOC-800 | Potvrzuje PostgreSQL jako hlavní databázový systém |
| MM-STD-001 | Určuje strukturu hlavních dokumentů |
| MM-STD-003 | Určuje životní cyklus a verzování |
| MM-STD-004 | Určuje názvosloví a strukturu |
| MM-STD-007 | Určuje prefix `MM-DB` a Document ID |
| Git repozitář | Zdroj pravdy pro schválené SQL, migrace a dokumenty |
| PostgreSQL databáze | Zdroj pravdy pro skutečně existující objekty a data |
| Q3 dokumentační workflow | Řízené schválení, Git publikace a databázový import |

### 2.2 Důkazní klasifikace

Každé budoucí databázové tvrzení musí být označitelné jednou z následujících kategorií:

| Klasifikace | Význam |
|---|---|
| DB VERIFIED | Objekt nebo stav byl ověřen přímo v databázi |
| GIT VERIFIED | Definice byla ověřena v aktuálním Git repozitáři |
| DOCUMENTED | Informace je uvedena ve schváleném dokumentu |
| IMPLEMENTED | Existuje konkrétní implementace |
| PARTIAL | Existuje pouze část řešení |
| PLANNED | Jde o plán dalšího rozvoje |
| HISTORICAL | Jde o dřívější stav, který nemusí být aktuální |
| REQUIRES AUDIT | Informace musí být před použitím znovu ověřena |

### 2.3 Pravidlo aktuálnosti

Při rozporu zdrojů platí toto pořadí:

```text
aktuální databáze
→ aktuální Git definice
→ schválená řízená dokumentace
→ historický dokument
→ chat nebo pracovní poznámka
```

Historický dokument nesmí být použit jako důkaz současného databázového stavu bez nové kontroly.

### Závěr kapitoly

Kapitola stanovila důvěryhodné zdroje a důkazní klasifikaci. Jejím přínosem je ochrana před přenosem zastaralých názvů tabulek, schémat nebo počtů do aktivní dokumentace. Návaznost pokračuje v další kapitole, která shrnuje základní databázové principy MatchMatrix.

---

## 3. Základní databázové principy

### 3.1 PostgreSQL jako hlavní databázový systém

Hlavním databázovým systémem MatchMatrix je PostgreSQL.

Databáze je provozována primárně na PC2 a poskytuje datový základ pro:

- harvest,
- ingest,
- parsování,
- canonical merge,
- governance,
- People,
- Media,
- Odds,
- analytiku,
- predikce,
- Ticket Engine,
- Operator panel,
- budoucí webové a mobilní rozhraní,
- řízenou dokumentační databázi.

### 3.2 Jediný canonical zdroj pravdy

Oficiální entity platformy musí být vedeny v canonical vrstvě.

Providerová data nesmějí bez kontroly přímo určovat:

- identitu sportu,
- ligu,
- sezónu,
- tým,
- osobu,
- stadion,
- zápas,
- kurz,
- mediální objekt.

Provider dodává zdrojová data a externí identifikátory. MatchMatrix určuje canonical identitu.

### 3.3 Oddělení vrstev

Databázová architektura musí oddělovat:

1. získané zdrojové payloady,
2. normalizovaná staging data,
3. mapování externích identit,
4. merge a kontrolní logiku,
5. canonical data,
6. operační a auditní data,
7. analytické a odvozené výstupy.

### 3.4 Auditovatelnost

Každá důležitá databázová změna musí být dohledatelná alespoň podle:

- zdroje,
- času,
- importního běhu,
- provideru,
- entity,
- externího ID,
- canonical ID,
- skriptu nebo migrace,
- Git commitu,
- výsledného stavu.

### 3.5 Bezpečnost před rychlostí

Při konfliktu mezi rychlým importem a ochranou dat má přednost:

- integrita,
- dohledatelnost,
- možnost rollbacku,
- zachování historie,
- bezpečné opakování běhu.

### Závěr kapitoly

Kapitola stanovila hlavní databázové principy: PostgreSQL, canonical zdroj pravdy, oddělené vrstvy, auditovatelnost a bezpečnost. Jejím přínosem je jednotný základ pro všechny budoucí databázové dokumenty. Návaznost pokračuje v další kapitole, která popisuje logickou architekturu databázových vrstev.

---

## 4. Logická databázová architektura

### 4.1 Zdrojová a raw vrstva

Raw vrstva uchovává původní nebo minimálně změněná data získaná od providerů.

Jejím účelem je:

- zachovat originální payload,
- umožnit opakované parsování,
- dohledat chybu providera,
- doložit zdroj dat,
- zabránit ztrátě informace při změně parseru.

Raw data nejsou canonical data.

### 4.2 Staging vrstva

Staging vrstva převádí různorodé providerové struktury do jednotného interního tvaru.

Dlouhodobý směr MatchMatrix používá univerzální objekty `stg_*` namísto oddělených sportovních struktur typu `api_football_*`, `api_hockey_*` nebo `api_basketball_*`.

Staging vrstva musí podporovat zejména:

- providerové ligy,
- providerové týmy,
- providerové zápasy,
- providerové hráče a další osoby,
- providerové statistiky,
- media,
- odds,
- stadiony a místa.

Přesný katalog aktivních `stg_*` objektů musí vzniknout samostatným databázovým auditem.

### 4.3 Mapovací vrstva

Mapovací vrstva spojuje:

```text
provider + external_id
→ canonical entity
```

Musí podporovat:

- více providerů pro jednu canonical entitu,
- historii změn mapování,
- stav potvrzení,
- confidence nebo kvalitu mapování,
- HOLD při konfliktu,
- audit duplicity,
- možnost řízené opravy.

### 4.4 Merge vrstva

Merge rozhoduje, zda zdrojový záznam:

- vytvoří novou canonical entitu,
- aktualizuje existující entitu,
- doplní providerovou vazbu,
- skončí v HOLD,
- vyžaduje ruční review,
- představuje duplicitu nebo konflikt.

Merge nesmí nekontrolovaně přepisovat canonical identitu.

### 4.5 Canonical a public vrstva

Canonical/public vrstva obsahuje oficiální data platformy.

Z této vrstvy mají čerpat:

- Operator panel,
- web,
- mobilní aplikace,
- veřejné API,
- analytika,
- AI,
- exporty,
- Ticket Engine.

Uživatelské aplikace nemají číst raw ani staging objekty jako oficiální zdroj dat.

### 4.6 Operační, governance a dokumentační vrstva

Vedle sportovních dat existují podpůrné oblasti:

- `ops` pro provozní řízení, workery, fronty, audity a readiness,
- governance registry a kontrolní objekty,
- `documentation` pro řízené dokumenty, verze, sekce, vazby a importní historii.

Přesná hranice jednotlivých schémat musí být popsána v katalogu schémat.

### Závěr kapitoly

Kapitola popsala logický tok od raw dat přes staging, mapování a merge až po canonical/public vrstvu. Jejím přínosem je jednotné chápání odpovědnosti každé databázové vrstvy. Návaznost pokračuje v další kapitole, která stanovuje pravidla identity, klíčů, vazeb a integrity.

---

## 5. Identita, klíče, vazby a integrita

### 5.1 Interní a externí identita

Každá významná entita musí rozlišovat:

- interní canonical identifikátor,
- provider,
- externí identifikátor,
- zdrojovou entitu,
- stav mapování.

Externí ID nesmí být používáno jako jediná globální identita platformy.

### 5.2 Primární klíče

Primární klíč musí být:

- stabilní,
- jednoznačný,
- nezávislý na názvu entity,
- nezávislý na jednom providerovi,
- vhodný pro dlouhodobé vazby.

### 5.3 Cizí klíče

Cizí klíče musí být používány všude, kde chrání skutečnou referenční integritu a nebrání oprávněnému staging workflow.

Odstranění nebo změna entity nesmí vytvořit tiché osiřelé vazby.

### 5.4 Unikátní constraints

Unikátní constraints mají chránit zejména:

- providerové mapy,
- přirozeně jedinečné vazby,
- importní identifikátory,
- kombinace zdroj + external ID,
- opakované spuštění stejné logické operace.

Constraint nesmí být nahrazen pouze kontrolou v Pythonu, pokud lze pravidlo bezpečně vynutit databází.

### 5.5 Duplicity a konflikty

Duplicitní kandidát nesmí být automaticky smazán nebo sloučen bez klasifikace.

Minimální možné stavy:

- SAFE_MERGE,
- REVIEW_REQUIRED,
- HOLD,
- PROVIDER_MAPPING_ERROR,
- SCORE_CONFLICT,
- REJECTED_DUPLICATE.

Konkrétní názvy stavů musí být potvrzeny proti aktuální implementaci.

### 5.6 Historie a auditní stopa

U kritických entit má být možné zjistit:

- kdo nebo co změnu provedlo,
- kdy změna vznikla,
- původní a novou hodnotu,
- důvod změny,
- související běh,
- související dokument nebo rozhodnutí.

### Závěr kapitoly

Kapitola stanovila pravidla oddělení interní a externí identity, klíčů, constraints, duplicit a auditní historie. Jejím přínosem je ochrana canonical modelu před nekonzistencí a providerovou závislostí. Návaznost pokračuje v další kapitole, která definuje katalog databázových objektů a odpovědnost jejich dokumentace.

---

## 6. Katalog databázových objektů

### 6.1 Povinné údaje katalogu

Každý významný databázový objekt má být v budoucím katalogu popsán minimálně těmito údaji:

| Údaj | Význam |
|---|---|
| Schema | Fyzická databázová oblast |
| Object name | Přesný technický název |
| Object type | TABLE, VIEW, MATERIALIZED VIEW, FUNCTION, PROCEDURE, SEQUENCE |
| Domain | CORE, PEOPLE, MEDIA, ODDS, OPS, DOCUMENTATION nebo jiná oblast |
| Purpose | K čemu objekt slouží |
| Source | Odkud přicházejí data |
| Target / consumers | Kdo objekt používá |
| Primary key | Hlavní identita |
| Foreign keys | Důležité vazby |
| Unique constraints | Ochrana jedinečnosti |
| Indexes | Výkonové indexy |
| Owner layer | Odpovědná vrstva |
| Governance status | ACTIVE_MASTER, ACTIVE, REVIEW, LEGACY, DROP_CANDIDATE |
| Source of truth | Ano/ne a v jakém rozsahu |
| Migration source | SQL nebo Git objekt, který jej vytvořil |
| Last verified | Datum posledního ověření |
| Notes and risks | Omezení a známé problémy |

### 6.2 Klasifikace objektů

Databázové objekty mají být klasifikovány například jako:

- ACTIVE_MASTER,
- ACTIVE_CANONICAL,
- ACTIVE_STAGING,
- ACTIVE_OPERATIONAL,
- ACTIVE_DOCUMENTATION,
- ACTIVE_REVIEW,
- LEGACY_KEEP,
- LEGACY_READ_ONLY,
- DROP_CANDIDATE,
- HISTORICAL_ONLY.

Přesný stavový slovník musí být sjednocen s governance registry.

### 6.3 Zákaz tichých legacy objektů

Objekt nesmí zůstat dlouhodobě aktivní bez určené odpovědnosti.

Každý legacy objekt musí mít:

- důvod zachování,
- náhradu nebo plán migrace,
- spotřebitele,
- zákaz nového použití, pokud je nahrazen,
- podmínku budoucího odstranění.

### Závěr kapitoly

Kapitola definovala minimální podobu katalogu databázových objektů a stavovou klasifikaci. Jejím přínosem je budoucí dohledatelnost každé tabulky, view a funkce. Návaznost pokračuje v další kapitole, která stanovuje pravidla změn, migrací a verzování databázového schématu.

---

## 7. Změny, migrace a verzování schématu

### 7.1 Každá změna musí být reprodukovatelná

Změna databáze musí být provedena prostřednictvím verzovaného SQL nebo řízeného migračního nástroje.

Ruční změna v DBeaveru nesmí být jediným existujícím záznamem změny.

### 7.2 Povinné části migrace

Významná migrace má obsahovat:

- účel,
- předpoklady,
- kontrolu výchozího stavu,
- změnu struktury,
- migraci dat,
- validační dotazy,
- rollback nebo bezpečný návratový postup,
- dopad na workery a panel,
- Git commit,
- související dokumentaci.

### 7.3 Bezpečné opakování

Migrační a instalační skripty mají být podle povahy:

- idempotentní,
- nebo jednoznačně označené jako jednorázové,
- nebo chráněné kontrolou verze databáze.

### 7.4 Destruktivní změny

Operace DROP, hromadný DELETE, změna typu sloupce nebo odstranění constraintu musí mít:

- předchozí audit závislostí,
- zálohu nebo návratový plán,
- potvrzení vlastníka projektu,
- kontrolu dopadu,
- následnou integritní validaci.

### 7.5 Vazba na dokumentaci

Každá významná změna databázové architektury musí aktualizovat:

- katalog objektů,
- relevantní MM-DB dokument,
- architektonický dokument, pokud se mění vrstvy,
- governance dokument, pokud se mění pravidla,
- denní zápis a případně Project Snapshot.

### Závěr kapitoly

Kapitola stanovila reprodukovatelnost změn, povinné části migrací, pravidla bezpečného opakování a ochranu destruktivních operací. Jejím přínosem je možnost databázi dlouhodobě rozvíjet bez ztráty historie a bez nezdokumentovaných ručních zásahů. Návaznost pokračuje v další kapitole, která řeší kvalitu, audity a provozní kontrolu.

---

## 8. Kvalita dat, audity a provozní kontrola

### 8.1 Povinné oblasti kontroly

Databázové audity mají postupně pokrývat:

- referenční integritu,
- duplicity,
- providerové mapování,
- chybějící canonical vazby,
- osiřelé záznamy,
- neplatné stavové hodnoty,
- časovou konzistenci,
- sport, ligu a sezónu,
- zápasové konflikty,
- People coverage,
- Media linking,
- Odds coverage,
- importní běhy,
- neúspěšné parsování,
- aktivní a expirované locky.

### 8.2 Auditní režimy

Audity mají rozlišovat:

- READ_ONLY,
- VALIDATE_ONLY,
- DRY_RUN,
- APPLY,
- APPLY_AND_VERIFY.

Zápisová oprava nesmí být vydávána za read-only audit.

### 8.3 Stavové výsledky

Doporučené obecné výsledky:

- VERIFIED,
- PASS,
- WARNING,
- REVIEW_REQUIRED,
- HOLD,
- BLOCKED,
- FAILED.

Každý blokátor musí mít:

- důvod,
- objekt,
- doporučený další krok,
- odpovědnou oblast,
- auditní report.

### 8.4 Vazba na Operator panel

Operator panel má zobrazovat zejména:

- stav databázových vrstev,
- poslední běhy,
- chyby,
- počty zpracovaných záznamů,
- frontu oprav,
- readiness,
- locky,
- blokátory,
- doporučenou akci.

Panel nesmí nahrazovat databázový zdroj pravdy. Má jej čitelně zpřístupňovat.

### Závěr kapitoly

Kapitola stanovila rozsah databázových auditů, režimy validace a vazbu na Operator panel. Jejím přínosem je oddělení měření, opravy a ověření výsledku. Návaznost pokračuje v další kapitole, která shrnuje výkon, bezpečnost, zálohování a obnovu.

---

## 9. Výkon, bezpečnost, zálohování a obnova

### 9.1 Indexy a výkon

Index musí vzniknout na základě skutečného způsobu použití.

Před vytvořením indexu je nutné určit:

- dotaz nebo workload,
- velikost tabulky,
- selektivitu,
- pořadí sloupců,
- dopad na zápis,
- riziko duplicity existujícího indexu.

Nevyužívané a duplicitní indexy musí být pravidelně auditovány.

### 9.2 Velké tabulky a partitioning

Partitioning se má použít pouze tam, kde je doložen přínos.

Kandidáty mohou být zejména:

- rozsáhlé raw payloady,
- importní historie,
- dlouhodobé event logy,
- odds historie,
- časové snapshoty,
- vysokofrekvenční auditní záznamy.

Konkrétní rozhodnutí musí vycházet z reálného objemu a dotazů.

### 9.3 Přístupová práva

Databázové účty mají používat princip nejmenších oprávnění.

Má být odděleno:

- čtení panelu,
- běh workerů,
- administrace,
- migrace,
- reporting,
- budoucí webové API,
- dokumentační importer.

Přihlašovací údaje nesmějí být bezdůvodně ukládány do veřejné dokumentace.

### 9.4 Zálohy

Zálohovací dokumentace musí určit:

- typ zálohy,
- frekvenci,
- retenční dobu,
- cílové umístění,
- šifrování,
- kontrolu dokončení,
- obnovovací test,
- odpovědnost PC1 a PC2.

### 9.5 Obnova

Záloha bez ověřené obnovy není považována za dostatečně ověřenou.

Musí existovat samostatný obnovovací postup pro:

- úplnou databázi,
- jednotlivé schema,
- vybrané tabulky,
- chybnou migraci,
- poškozená data,
- obnovu na náhradním stroji.

### Závěr kapitoly

Kapitola shrnula výkonové indexy, partitioning, přístupová práva, zálohy a obnovu. Jejím přínosem je ochrana databáze nejen před logickou chybou, ale také před výkonovým, bezpečnostním a provozním selháním. Návaznost pokračuje v další kapitole, která vytváří konkrétní plán databázové dokumentace.

---

## 10. Plán databázové dokumentace

### 10.1 Navržené základní dokumenty

| Pořadí | Document ID | Navržený název | Stav |
|---:|---|---|---|
| 1 | MM-DB-1000 | Index databázové dokumentace MatchMatrix | REVIEW |
| 2 | MM-DB-001 | Architektura databáze MatchMatrix | PLANNED |
| 3 | MM-DB-002 | Katalog schémat a databázových objektů | PLANNED |
| 4 | MM-DB-003 | Canonical Entity Model MatchMatrix | PLANNED |
| 5 | MM-DB-004 | Raw, staging, merge a public datový tok | PLANNED |
| 6 | MM-DB-005 | Standard názvosloví databázových objektů | PLANNED |
| 7 | MM-DB-006 | Primární klíče, vazby, constraints a integrita | PLANNED |
| 8 | MM-DB-007 | Migrace a verzování databázového schématu | PLANNED |
| 9 | MM-DB-008 | Indexy, výkon a partitioning | PLANNED |
| 10 | MM-DB-009 | Zálohování, obnova a retence | PLANNED |
| 11 | MM-DB-010 | Databázová bezpečnost a přístupová práva | PLANNED |
| 12 | MM-DB-011 | Databázové audity a kvalita dat | PLANNED |
| 13 | MM-DB-012 | Databázový slovník MatchMatrix | PLANNED |

### 10.2 Doporučené pořadí tvorby

```text
MM-DB-1000
→ MM-DB-001
→ MM-DB-002
→ MM-DB-003
→ MM-DB-004
→ MM-DB-006
→ MM-DB-007
→ MM-DB-011
→ MM-DB-008
→ MM-DB-009
→ MM-DB-010
→ MM-DB-005
→ MM-DB-012
```

Nejprve musí být popsána skutečná architektura a katalog objektů. Teprve potom je vhodné vydávat podrobné normativní nebo provozní dokumenty.

### 10.3 Aktualizace indexu

Tento index musí být aktualizován při:

- vytvoření nového MM-DB dokumentu,
- změně stavu dokumentu,
- nahrazení dokumentu,
- změně odpovědnosti databázové oblasti,
- významné změně schémat nebo canonical modelu.

### Závěr kapitoly

Kapitola vytvořila konkrétní seznam navazujících MM-DB dokumentů a jejich pořadí. Jejím přínosem je řízený plán, který zabrání nahodilému popisování jednotlivých tabulek bez celkového rámce. Návaznost pokračuje v další kapitole, která shrnuje současný stav, rizika a otevřené otázky.

---

## 11. Současný stav, rizika a otevřené otázky

### 11.1 Současný stav

| Oblast | Stav |
|---|---|
| PostgreSQL jako hlavní databáze | IMPLEMENTED |
| Provoz databáze na PC2 | IMPLEMENTED |
| Canonical/public princip | IMPLEMENTED PRINCIPLE |
| Raw a staging vrstvy | IMPLEMENTED / REQUIRES CURRENT AUDIT |
| Jednotné `stg_*` | ACTIVE ARCHITECTURAL DIRECTION |
| Providerové mapování | IMPLEMENTED / PARTIAL BY DOMAIN |
| Merge logika | IMPLEMENTED / REQUIRES CATALOG |
| OPS databázová vrstva | IMPLEMENTED |
| Dokumentační databáze | IMPLEMENTED AND VERIFIED |
| Úplný katalog schémat a objektů | MISSING |
| Úplný databázový slovník | MISSING |
| Jednotná migrační evidence | REQUIRES AUDIT |
| Formální backup/restore dokumentace | MISSING |
| Výkonový a indexový audit | MISSING |

### 11.2 Hlavní rizika

| Riziko | Závažnost | Opatření |
|---|---|---|
| Používání historických `api_*` objektů místo aktivních `stg_*` | HIGH | Vytvořit katalog objektů a označit legacy |
| Nezdokumentované ruční změny v databázi | HIGH | Zavést povinné verzované migrace |
| Dvě identity pro stejnou entitu | HIGH | Posílit canonical mapování a constraints |
| Nejasná odpovědnost view a tabulek | HIGH | Zavést governance status každého objektu |
| Chybějící obnovovací test | CRITICAL | Vytvořit MM-DB-009 a provést test obnovy |
| Nadbytečné nebo chybějící indexy | MEDIUM | Vytvořit výkonový audit |
| Přímé čtení staging dat uživatelskou vrstvou | HIGH | Vynutit public/canonical source of truth |
| Neúplná dokumentace migrací | HIGH | Vytvořit MM-DB-007 |
| Citlivé údaje v dokumentaci nebo kódu | HIGH | Vytvořit pravidla přístupů a secrets |
| Rychlý růst raw a auditních tabulek | MEDIUM | Retence, partitioning a archivace |

### 11.3 Otevřené otázky

- Jaký je přesný aktuální seznam schémat v produkční databázi?
- Které `stg_*` objekty jsou aktivní master a které pouze přechodné?
- Které historické `api_*` tabulky jsou ještě používány?
- Které objekty jsou zdrojem pravdy pro jednotlivé sportovní entity?
- Jaký je úplný seznam merge funkcí a jejich priority?
- Které constraints chrání providerové mapy a duplicity?
- Jak je dnes řízena verze databázového schématu?
- Které SQL změny nejsou dosud součástí reprodukovatelné migrace?
- Jaká je současná backup politika PC2?
- Kdy proběhl poslední úspěšný obnovovací test?
- Které tabulky jsou kandidáty na partitioning?
- Jaké účty a role dnes databázi používají?
- Které objekty smí číst budoucí veřejné API?

### Závěr kapitoly

Kapitola oddělila implementované základy od chybějící dokumentace a konkrétních rizik. Jejím přínosem je přesný seznam oblastí, které musí být ověřeny přímo v databázi. Návaznost pokračuje v další kapitole, která určuje první konkrétní pracovní krok.

---

## 12. Další krok a závěr

### 12.1 Bezprostřední další krok

Po schválení tohoto indexu má vzniknout:

```text
MM-DB-001_ARCHITEKTURA_DATABAZE_MATCHMATRIX.md
```

Před jeho vytvořením musí být proveden read-only databázový audit, který získá:

- seznam schémat,
- seznam tabulek,
- seznam views a materialized views,
- seznam funkcí a procedur,
- primární a cizí klíče,
- constraints,
- indexy,
- velikosti tabulek,
- přibližné počty řádků,
- závislosti objektů,
- vlastníky a oprávnění,
- governance status, pokud existuje.

### 12.2 Pracovní postup

```text
schválit MM-DB-1000
→ Git commit a push
→ A24 VALIDATE_ONLY
→ A24 APPLY
→ A7 VERIFIED
→ provést read-only audit PostgreSQL
→ vytvořit MM-DB-001
→ vytvořit MM-DB-002
```

### 12.3 Celkový závěr

Databáze je technickým základem celé platformy MatchMatrix.

Projekt již má:

- produkční PostgreSQL,
- raw a staging princip,
- canonical/public vrstvu,
- providerové mapování,
- merge a governance logiku,
- OPS vrstvu,
- dokumentační databázi.

Chybí však jednotný a aktuálně ověřený databázový katalog.

Tento dokument vytváří první řízený základ oblasti `04_DATABASE` a určuje, jak bude databázová znalost postupně převáděna z jednotlivých skriptů, tabulek a historických dokumentů do dlouhodobě udržitelné dokumentace.

### Závěr kapitoly

Kapitola stanovila bezprostřední pokračování a shrnula význam databázového indexu. Jejím přínosem je jednoznačný přechod od obecné mapy dokumentace k ověřené databázové architektuře a katalogu skutečných objektů. Další návazností je schválení tohoto dokumentu a vytvoření `MM-DB-001`.

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---|---:|---|---|
| 0.9 | 2026-07-13 | REVIEW | První oblastní index databázové dokumentace vytvořený podle MM-DOC-001 |

---

*Konec dokumentu MM-DB-1000.*
