# MM-DOC-000

# MATCHMATRIX DOCUMENTATION FRAMEWORK

## TECH EDITION

---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-000 |
| Název | MatchMatrix Documentation Framework |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Stabilní Document ID | MM-DOC-000 |
| Aktivní soubor | `docs/00_DOCUMENTATION/MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK.md` |
| Původní pracovní označení | MM-DOC-090 |

## Poznámka k identitě dokumentu

Původní pracovní označení **MM-DOC-090** bylo použito pouze během vzniku dokumentačního rámce.

Stabilní a finální identita kořenového dokumentu je **MM-DOC-000**. Toto Document ID se dále nemění, protože dokument představuje kořenový rámec oblasti **00_DOCUMENTATION**.

Označení **MM-DOC-090** je historický alias a nesmí být znovu použito jako aktivní identita.

V souladu s pravidlem jediné aktivní verze zůstává název aktivního souboru neměnný. Číslo verze, datum, stav a historie změn se vedou uvnitř dokumentu. Předchozí řízená verze se při vydání nové verze přesouvá do `docs/99_ARCHIVE`.

## Účel dokumentu

Tento dokument definuje architekturu, pravidla a provozní model dokumentačního systému MatchMatrix.

Určuje, jak se z pracovních informací, databázových auditů, Git historie, denních zápisů, navazovacích dokumentů a komunikace s AI stávají ověřené, řízené a dlouhodobě použitelné znalosti projektu.

Dokument je kořenovým rámcem pro hlavní dokumenty, standardy, referenční dokumenty, šablony, exporty a dokumentační workflow MatchMatrix.

## Rozsah dokumentu

- filozofie a architektura dokumentačního systému,
- stabilní identita dokumentů a pravidlo jediné aktivní verze,
- dokumentační typy, edice, prefixy a vazby,
- správa znalostí a hierarchie důvěryhodnosti zdrojů,
- využití historie chatů jako ověřovacího podkladu,
- AI Context, Project Snapshot a Database Snapshot,
- dokumentační databáze a řízené workflow Q3,
- audit, kontrola terminologie, schvalování a publikace,
- vztah TECH, BOOK a GLOBAL edic,
- další rozvoj Documentation Management System.

## Související dokumenty

- MM-STD-001 až MM-STD-009
- MM-STD-1000 – Index standardů MatchMatrix
- MM-REF-001 – Referenční slovník pojmů MatchMatrix
- MM-DOC-1000 – Index dokumentů MatchMatrix
- MM-DOC-100 – MatchMatrix Master
- MM-DOC-200 – MatchMatrix Governance
- MM-DOC-300 – MatchMatrix Architecture
- MM-DOC-800 – MatchMatrix Development Handbook
- MM-DOC-900 – MatchMatrix Denní zápisy
- MM-TPL-001 – Šablona navázání do nového chatu
- MM-TPL-002 – Šablona denního zápisu
- `docs/14_EXPORT/HISTORIE_CHATU/MM-EXP-20260727-01_EXTRAKCNI_MATICE_HISTORIE_CHATU_V1.xlsx`

## Historie verzí

| Verze | Datum | Popis |
|--------|--------|-------|
| 0.9 | 2026 | Pracovní kapitoly vedené pod označením MM-DOC-090. |
| 1.0 | 2026 | První sjednocený REVIEW dokument pod identitou MM-DOC-000. |
| 1.1 | 2026-06-29 | Doplněn smysl projektu, AI Context, Project Snapshot a základní stavové sekce. |
| 1.2 | 2026-07-27 | Zapracován ověřený kontext z historie chatů, pravidlo jediné aktivní verze, stabilní hlavní Document ID, hierarchie zdrojů, skutečný stav dokumentační databáze a workflow Q3. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |

# Obsah

- Kapitola A – Základy dokumentační architektury
- Kapitola B – Dokumentační ekosystém MatchMatrix
- Kapitola C – Znalostní báze MatchMatrix
- Kapitola D – Governance dokumentačního systému
- Kapitola E – Budoucnost dokumentačního systému MatchMatrix
- Kapitola F – Aktuální provozní model a práce s kontextem

---


# 0. Smysl projektu MatchMatrix
## Poslání

MatchMatrix vzniká s cílem vybudovat dlouhodobě úspěšnou technologickou společnost zaměřenou na sportovní data, analytiku a digitální služby.

Databáze, webové aplikace, API, umělá inteligence, infrastruktura i dokumentace představují prostředky k dosažení tohoto cíle.

## Hlavní cíl

Hlavním cílem projektu není vytvořit databázi ani dokumentaci.

Hlavním cílem je vytvářet produkty a služby s vysokou hodnotou pro uživatele, které povedou k dlouhodobě prosperující a ziskové společnosti.

## Role dokumentace

Dokumentace představuje systém řízení znalostí společnosti MatchMatrix. Uchovává architektonická rozhodnutí, zaznamenává vývoj projektu, vytváří kontext pro další rozvoj a umožňuje rychlé navázání práce lidem i systémům AI.

---


## 0.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „0. Smysl projektu MatchMatrix“ v rámci dokumentu MM-DOC-000 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „1. Základy dokumentační architektury“, která rozvíjí další část řízeného dokumentu.

# 1. Základy dokumentační architektury
---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-000 |
| Kapitola | A – Základy dokumentační architektury |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |

---

## Historie verzí

| Verze | Datum | Popis |
|--------|--------|-------|
| 1.0 | 2026 | První referenční verze připravená k odbornému review podle MM-STD-001 až MM-STD-006. |
| 1.2 | 2026-07-27 | Aktualizace podle ověřeného projektového kontextu, standardů MM-STD-001 až MM-STD-009 a dokumentačního workflow. |

---

## Účel kapitoly

Kapitola A definuje filozofii, poslání a základní architekturu dokumentačního systému MatchMatrix. Představuje referenční základ celého dokumentu MM-DOC-000 a určuje principy, na kterých bude postavena veškerá dokumentace projektu.

---

## Rozsah kapitoly

- dokumentace jako architektura znalostí
- poslání dokumentace
- filozofie dokumentace
- dokumentace jako součást vývoje
- vztah ke standardům
- dokument jako řízený objekt
- vztah mezi TECH, BOOK a GLOBAL
- dlouhodobá vize dokumentace

---

## Cílová skupina

- architekt platformy
- vývojáři
- databázoví specialisté
- AI specialisté
- správci dokumentace
- projektové řízení

---

## Související dokumenty

- MM-STD-001 až MM-STD-006
- MM-STD-1000
- MM-REF-001

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Základy dokumentační architektury“ v rámci dokumentu MM-DOC-000 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Dokumentační ekosystém MatchMatrix“, která rozvíjí další část řízeného dokumentu.

# Obsah

A.1 Úvod

A.2 Poslání dokumentace

A.3 Filozofie dokumentace

A.4 Dokumentace jako architektura znalostí

A.5 Dokumentace jako součást vývoje

A.6 Vztah ke standardům

A.7 Dokument jako řízený objekt

A.8 TECH × BOOK × GLOBAL

A.9 Závěr kapitoly

---

## A.1 Úvod

Dokumentace představuje jeden ze základních pilířů platformy MatchMatrix. Stejně jako databáze uchovává data a zdrojový kód implementuje funkcionalitu, dokumentace uchovává znalosti projektu.

S růstem platformy se dokumentace stává samostatnou architektonickou vrstvou. Jejím úkolem není pouze popis implementace, ale řízená správa znalostí, zkušeností a architektonických rozhodnutí.

---

## A.2 Poslání dokumentace

Dokumentace vzniká současně s vývojem platformy. Každá významná změna architektury, databáze, aplikace nebo procesu musí být doprovázena odpovídající dokumentací.

Dokumentace není vedlejším produktem vývoje. Je jeho nedílnou součástí.

---

## A.3 Filozofie dokumentace

Dokumentace MatchMatrix stojí na těchto principech:

- každá informace má jedno referenční místo,
- dokumentace je verzována,
- dokumentace se rozvíjí společně s projektem,
- standardy určují jednotná pravidla,
- dokumentace podporuje dlouhodobou udržitelnost projektu,
- dokumentace je součástí architektury platformy,
- dokumentace podporuje automatizaci a správu znalostí.

---

## A.4 Dokumentace jako architektura znalostí

Stejně jako databáze spravuje data, dokumentace spravuje znalosti projektu.

Znalosti jsou považovány za stejně důležitý zdroj projektu jako data, zdrojový kód nebo infrastruktura.

Cílem dokumentace není pouze popsat systém, ale uchovat důvody rozhodnutí, zkušenosti, souvislosti a dlouhodobou kontinuitu vývoje.

---

## A.5 Dokumentace jako součást vývoje

Funkcionalita není považována za dokončenou, pokud není dokončena i odpovídající dokumentace.

Za dokončenou změnu se považuje pouze taková změna, která obsahuje implementaci, dokumentaci, aktualizované reference a historii změn.

---

## A.6 Vztah ke standardům

Dokumentační systém rozlišuje **typ dokumentu**, **Document ID**, **edici** a **fyzický soubor**.

Základní rodiny dokumentů jsou:

- **MM-DOC** – hlavní technická, strategická a provozní dokumentace,
- **MM-STD** – závazné standardy,
- **MM-REF** – referenční dokumenty a slovníky,
- **MM-TPL** – řízené šablony,
- **MM-EXP** – exportní a analytické výstupy,
- specializované rodiny, například **MM-PRV**, **MM-DB** a **MM-OPS**.

Edice **TECH**, **BOOK** a **GLOBAL** popisují způsob zpracování obsahu. Samy o sobě nemění stabilní Document ID.

Platná pravidla musí být vzájemně sladěna zejména mezi MM-STD-003, MM-STD-004 a MM-STD-007. Při rozporu se nesmí mechanicky přejmenovat již zavedený aktivní dokument; nejprve se provede řízené rozhodnutí a aktualizace standardů.

---

## A.7 Dokument jako řízený objekt

Dokument je řízený objekt s jednoznačným a stabilním Document ID, vlastníkem, stavem, historií verzí, vazbami a referenčním umístěním.

Pro každý aktivní dokument existuje právě **jeden oficiální aktivní soubor**. Jeho název zůstává při běžné aktualizaci neměnný. Nová verze vzniká aktualizací obsahu původního aktivního souboru; předchozí řízená verze se přesune do archivu.

Stav `REVIEW` je stav obsahu uvnitř dokumentu, nikoli důvod pro trvalou paralelní existenci druhého aktivního souboru s příponou `_REVIEW`.

Hlavní stabilní identity dokumentační řady jsou:

- MM-DOC-000 – Documentation Framework,
- MM-DOC-100 – MatchMatrix Master,
- MM-DOC-200 – MatchMatrix Governance,
- MM-DOC-300 – MatchMatrix Architecture,
- MM-DOC-800 – Development Handbook,
- MM-DOC-900 – Denní zápisy.

Původní označení MM-DOC-001 až MM-DOC-005 jsou historické pracovní aliasy a nesmějí nahradit současné stabilní identity.

---

## A.8 TECH × BOOK × GLOBAL

**TECH** popisuje ověřený aktuální technický a provozní stav.

**BOOK** vysvětluje vývoj, důvody rozhodnutí, zkušenosti, souvislosti a dlouhodobý význam.

**GLOBAL** je řízená cizojazyčná edice vycházející z aktuální schválené české verze.

Edice se mohou obsahově lišit rozsahem a stylem, ale nesmějí vytvářet konkurenční pravdu o stejném stavu systému. Technická fakta mají jedno referenční místo.

## A.9 Závěr kapitoly
Kapitola A vymezuje filozofii dokumentační architektury MatchMatrix a vytváří základ pro celý dokumentační systém.

Na tuto kapitolu navazuje Kapitola B – Dokumentační ekosystém MatchMatrix.

---

### Shrnutí
- Dokumentace je architektura znalostí.
- Dokument je řízený objekt.
- Dokumentace je nedílnou součástí vývoje.
- Standardy řídí celý dokumentační systém.
- TECH, BOOK a GLOBAL představují tři vzájemně propojené edice.

---

# 2. Dokumentační ekosystém MatchMatrix
---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-000 |
| Kapitola | B – Dokumentační ekosystém MatchMatrix |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |

---

## Historie verzí

| Verze | Datum | Popis |
|--------|--------|-------|
|1.0|2026|První referenční verze připravená k odbornému review.|
|1.2|2026-07-27|Aktualizace podle ověřeného projektového kontextu a skutečného stavu dokumentačního systému.|

---

## Účel kapitoly

Kapitola popisuje dokumentační ekosystém MatchMatrix, jeho jednotlivé edice, jejich vzájemné vazby a principy spolupráce. Definuje architekturu dokumentačního systému jako jednoho řízeného celku.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Dokumentační ekosystém MatchMatrix“ v rámci dokumentu MM-DOC-000 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Znalostní báze (Knowledge Base) MatchMatrix“, která rozvíjí další část řízeného dokumentu.

# Obsah

B.1 Dokumentační ekosystém

B.2 Dokumentační edice

B.3 TECH × BOOK × GLOBAL

B.4 Referenční dokumenty

B.5 Standardy dokumentace

B.6 Vazby mezi dokumenty

B.7 Architektura dokumentačního systému

B.8 Dokumentační indexy

B.9 Budoucí rozvoj

B.10 Závěr

---

## B.1 Dokumentační ekosystém

Dokumentační ekosystém MatchMatrix představuje ucelený systém vzájemně propojených dokumentů, standardů, referenčních informací a znalostí. Jeho cílem je podporovat návrh, vývoj, správu i dlouhodobý rozvoj celé platformy.

Dokumentace není souborem samostatných dokumentů, ale propojeným systémem řízených znalostí.

---

## B.2 Dokumentační typy a rodiny

| Rodina | Účel | Příklady obsahu |
|--------|------|-----------------|
| MM-DOC | Hlavní dokumentace | Master, Governance, Architecture, Handbook, historie |
| MM-STD | Standardy | tvorba, verzování, terminologie, vizuální identita, AI Context |
| MM-REF | Referenční dokumenty | slovníky, katalogy, rejstříky |
| MM-TPL | Šablony | denní zápis, navázání do nového chatu |
| MM-EXP | Exporty a analytické podklady | extrakční matice, auditní exporty |
| MM-PRV / MM-DB / MM-OPS | Specializované oblasti | provideři, databáze, provoz a panely |

Typ dokumentu určuje jeho odpovědnost. Edice TECH, BOOK a GLOBAL určují způsob zpracování obsahu.

---

## B.3 TECH × BOOK × GLOBAL

TECH je referenčním místem pro ověřený aktuální stav.

BOOK doplňuje důvody, historii a zkušenosti, aniž by přepisoval technická fakta vlastní variantou.

GLOBAL je překladová nebo mezinárodní edice a vzniká až z určené aktuální zdrojové verze.

---

## B.4 Referenční dokumenty

Referenční dokumenty poskytují sdílené informace používané napříč projektem.

Klíčovým dokumentem je **MM-REF-001 – Slovník pojmů MatchMatrix**. Pro jedno Document ID smí existovat pouze jedna aktivní referenční verze. Starší nebo neúplné varianty patří do historie.

Další referenční dokumenty mohou zahrnovat výkladový rejstřík, datový slovník, katalog technologií, katalog providerů a centrální indexy.

---

## B.5 Standardy dokumentace

Standardy MM-STD definují závazná pravidla pro strukturu, rozsah, životní cyklus, identitu, terminologii, vizuální podobu, správu slovníku a předávání kontextu.

Aktuální rámec počítá minimálně se standardy MM-STD-001 až MM-STD-009. Index MM-STD-1000 musí vždy zobrazovat skutečný úplný seznam standardů a nesmí zůstat omezen na starší podmnožinu.

---

## B.6 Vazby mezi dokumenty

Každá informace má jedno referenční místo. Ostatní dokumenty na ni odkazují pomocí Document ID, řízené vazby nebo přesného odkazu na kapitolu.

Opakování stručného kontextu je přípustné, ale duplicitní správa stejné definice nebo stejného aktuálního čísla není přípustná.

---

## B.7 Architektura dokumentačního systému

Dokumentační systém tvoří pět spolupracujících vrstev:

1. **Souborová vrstva** – aktivní dokumenty, šablony, exporty a archiv ve stromu `docs`.
2. **Metadata a databáze** – dokumenty, verze, sekce, vazby, stavy a importní běhy ve schématu `documentation`.
3. **Governance a automatizace** – panel Q3 a nástroje A17, A18, A19, A20 a A24.
4. **Kontextová vrstva** – AI Context, Project Snapshot, Database Snapshot, denní zápisy a NAV dokumenty.
5. **Důkazní vrstva** – Git, databázové audity, výstupy skriptů, historie chatů a další podklady pro ověření.

Řídicím principem není samotné uložení souboru, ale dohledatelnost původu informace, její ověření a řízené publikování.

---

## B.8 Dokumentační indexy

Centrální orientaci zajišťují zejména:

- MM-DOC-1000 – index dokumentů,
- MM-STD-1000 – index standardů,
- dokumentační databáze,
- řízené vazby mezi dokumenty,
- exporty a auditní reporty.

Index musí obsahovat nejméně Document ID, název, typ, edici, verzi, stav, aktivní cestu, datum aktualizace a vazby.

---

## B.9 Současný stav a další rozvoj

Základ Documentation Management System již není pouze budoucí návrh. V projektu existuje dokumentační databáze, panelové workflow Q3, audit standardu, návrh standardizace, kontrola mapování, builder a řízený import.

Další rozvoj se zaměřuje na:

- automatické generování aktuálních snapshotů,
- přesnější evidenci původu jednotlivých tvrzení,
- vizualizaci vazeb a konfliktů,
- vyhledávání v dokumentační databázi,
- řízenou přípravu BOOK a GLOBAL edic,
- webový dokumentační portál.

## B.10 Závěr kapitoly
Dokumentační ekosystém MatchMatrix vytváří jednotný rámec pro správu technické dokumentace, standardů, referenčních informací i znalostí projektu.

Na tuto kapitolu navazuje Kapitola C – Znalostní báze MatchMatrix.

---

### Shrnutí
- Dokumentace je propojený ekosystém.
- Každá edice má jasně definovanou roli.
- Každá informace má jedno referenční místo.
- Standardy řídí celý dokumentační systém.
- Documentation Management System představuje budoucí řídicí vrstvu.

---

# 3. Znalostní báze (Knowledge Base) MatchMatrix
---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-000 |
| Kapitola | C – Znalostní báze MatchMatrix |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |

---

## Historie verzí

| Verze | Datum | Popis |
|--------|--------|-------|
|1.0|2026|První referenční verze připravená k odbornému review.|
|1.2|2026-07-27|Aktualizace podle ověřeného projektového kontextu a skutečného stavu dokumentačního systému.|

---

## Účel kapitoly

Kapitola C definuje znalostní bázi jako centrální architektonickou vrstvu dokumentačního systému MatchMatrix. Stanovuje principy správy znalostí, jejich organizace, životního cyklu a budoucí automatizace.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Znalostní báze (Knowledge Base) MatchMatrix“ v rámci dokumentu MM-DOC-000 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Governance dokumentačního systému“, která rozvíjí další část řízeného dokumentu.

# Obsah

C.1 Definice znalostní báze

C.2 Filozofie správy znalostí

C.3 Architektura znalostní báze

C.4 Druhy znalostí

C.5 Životní cyklus znalosti

C.6 Vazby mezi znalostmi

C.7 Documentation Management System

C.8 Dokumentační databáze

C.9 Budoucí rozvoj

C.10 Závěr

---

## C.1 Definice znalostní báze

Znalostní báze představuje organizovaný systém znalostí projektu MatchMatrix. Jejím cílem není pouze uchovávat dokumenty, ale dlouhodobě spravovat informace, zkušenosti, rozhodnutí a souvislosti potřebné pro návrh, vývoj a správu platformy.

Dokumentace tvoří pouze jednu část znalostní báze.

---

## C.2 Filozofie správy znalostí

Znalosti jsou považovány za strategický zdroj projektu stejně jako data, zdrojový kód nebo infrastruktura.

Správa znalostí je založena na principech:

- jedno referenční místo,
- jednoznačná terminologie,
- verzování,
- dohledatelnost,
- auditovatelnost,
- dlouhodobá udržitelnost.

---

## C.3 Architektura znalostní báze

Znalostní báze pracuje se třemi odlišnými úrovněmi:

| Úroveň | Význam |
|--------|--------|
| Důkaz nebo pracovní podklad | Chat, log, audit, SQL výstup, Git změna, historický dokument |
| Ověřený aktuální základ | Potvrzené tvrzení s určenou aktuálností a cílovým dokumentem |
| Řízená znalost | Informace zapracovaná do aktivního dokumentu, prošlá kontrolou a publikací |

Historie komunikace ani automatická extrakce nejsou samy o sobě normativní dokumentací. Stávají se zdrojem znalosti až po ověření proti aktuálnímu stavu projektu.

---

## C.4 Druhy znalostí

Znalostní báze obsahuje zejména:

- strategická a produktová rozhodnutí,
- architektonická pravidla,
- databázový a provozní stav,
- standardy a terminologii,
- právní a providerová rozhodnutí,
- vývojové postupy,
- denní historii a navazovací informace,
- auditní výsledky,
- Git historii a vazby na zdrojové soubory,
- ověřené informace získané z historie chatů.

---

## C.5 Životní cyklus znalosti

Každá nová nebo měněná znalost prochází těmito etapami:

1. vznik důkazu nebo pozorování,
2. extrakce kandidátního tvrzení,
3. ověření proti aktuálním zdrojům,
4. rozhodnutí o platnosti a aktuálnosti,
5. určení jednoho referenčního dokumentu,
6. zapracování do nové verze aktivního souboru,
7. audit standardu, terminologie a vazeb,
8. schválení a publikace,
9. archivace předchozí řízené verze.

Změna se nepřenáší kopírováním stejného textu do všech dokumentů. Aktualizuje se referenční místo a navazující dokumenty se propojí odkazem nebo stručným kontextem.

---

## C.6 Vazby mezi znalostmi

Jednotlivé dokumenty, sekce, databázové objekty, skripty, Git commity a auditní běhy vytvářejí propojenou síť.

Každá významná znalost má být dohledatelná k původnímu podkladu a současně k místu, kde byla schválena jako aktuální.

---

## C.7 Documentation Management System

Současný Documentation Management System tvoří kombinace:

- souborového stromu `docs`,
- dokumentační databáze,
- panelu Q3,
- nástrojů A17, A18, A19, A20 a A24,
- oficiálních šablon MM-TPL-001 a MM-TPL-002,
- AI Context a Project Snapshot mechanismů.

Systém již podporuje analýzu, standardizaci, vytvoření návrhu, kontrolu, publikaci a import do databáze. Budoucí rozvoj rozšíří jeho automatizaci a uživatelské rozhraní.

---

## C.8 Dokumentační databáze

Dokumentační databáze je aktivní součást projektu, nikoli pouze plán.

Ověřený snapshot k 2026-07-27 uvádí:

| Objekt | Počet |
|--------|------:|
| Dokumenty | 354 |
| Verze dokumentů | 360 |
| Aktuální verze | 354 |
| Sekce | 7 075 |
| Vazby | 495 |
| Importní běhy | 48 |

Počty jsou časově omezeným snapshotem a nesmí být používány jako trvalé architektonické konstanty. Aktuální hodnotu má vždy potvrdit nový audit nebo Project Snapshot.

---

## C.9 Další rozvoj

Další rozvoj zahrnuje:

- automatické aktualizace Project Snapshot a Database Snapshot,
- evidenci původu tvrzení až na úroveň konverzace, zprávy, auditu nebo commitu,
- porovnání nové verze dokumentu s předchozí verzí,
- automatickou kontrolu aktivní identity a duplicitních souborů,
- řízené zpracování historie chatů,
- vyhledávání a graf vazeb,
- přípravu BOOK a GLOBAL edic.

## C.10 Závěr kapitoly
Znalostní báze představuje centrální pilíř dokumentačního systému MatchMatrix. Jejím úkolem je zajistit dlouhodobou správu, ochranu, rozvoj a sdílení znalostí napříč celou platformou.

Na tuto kapitolu navazuje Kapitola D – Governance dokumentačního systému.

---

### Shrnutí
- Znalosti jsou strategickým aktivem projektu.
- Dokumentace je pouze jednou částí znalostní báze.
- Každá znalost má definovaný životní cyklus.
- Documentation Management System bude budoucí řídicí vrstvou.

---

# 4. Governance dokumentačního systému
---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-000 |
| Kapitola | D – Governance dokumentačního systému |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |

---

## Historie verzí

| Verze | Datum | Popis |
|--------|--------|-------|
|1.0|2026|První referenční verze připravená k odbornému review.|
|1.2|2026-07-27|Aktualizace podle ověřeného projektového kontextu a skutečného stavu dokumentačního systému.|

---

## Účel kapitoly

Kapitola D stanovuje pravidla řízení dokumentačního systému MatchMatrix. Definuje odpovědnosti, procesy, kontrolní mechanismy a principy, které zajišťují dlouhodobou kvalitu, konzistenci a důvěryhodnost dokumentace.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Governance dokumentačního systému“ v rámci dokumentu MM-DOC-000 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Budoucnost dokumentačního systému MatchMatrix“, která rozvíjí další část řízeného dokumentu.

# Obsah

D.1 Dokumentační governance

D.2 Role a odpovědnosti

D.3 Životní cyklus dokumentu

D.4 Kontrola kvality

D.5 Řízení terminologie

D.6 Vazby mezi dokumenty

D.7 Audit dokumentace

D.8 Automatizace governance

D.9 Budoucí rozvoj

D.10 Závěr

---

## D.1 Dokumentační governance

Dokumentační governance představuje soubor pravidel, procesů a odpovědností pro vznik, správu, schvalování, aktualizaci a archivaci dokumentace. Jejím cílem je zajistit jednotný přístup ke správě znalostí napříč celou platformou.

---

## D.2 Role a odpovědnosti

| Role | Odpovědnost |
|------|-------------|
| Autor | Vytvoření a aktualizace dokumentu |
| Reviewer | Odborná kontrola obsahu |
| Architekt | Schválení architektonického souladu |
| Správce dokumentace | Evidence, verzování a publikace |
| Documentation Management System | Automatické kontroly a správa metadat |

Každý dokument má jednoznačně určeného vlastníka a definovaný stav.

---

## D.3 Životní cyklus dokumentu

Životní cyklus je řízen standardem MM-STD-003 a realizován čtyřmi fázemi panelového workflow Q3:

1. **VYBRAT A ANALYZOVAT**,
2. **OPRAVIT A ZKONTROLOVAT**,
3. **VYTVOŘIT A SCHVÁLIT**,
4. **PUBLIKOVAT**.

Aktivní dokument se aktualizuje pod původním stabilním názvem. Předchozí řízená verze se archivuje. Stav `DRAFT`, `REVIEW`, `APPROVED` nebo `ACTIVE` je metadatem dokumentu, nikoli trvalou součástí názvu aktivního souboru.

---

## D.4 Kontrola kvality

Kontrola kvality zahrnuje:

- obsahovou správnost a aktuálnost,
- soulad s MM-STD-001 až MM-STD-009,
- kontrolu struktury a závěrů kapitol,
- kontrolu terminologie podle MM-REF-001,
- kontrolu Document ID a aktivní cesty,
- kontrolu vazeb a duplicit,
- kontrolu původu důležitých tvrzení.

A17 provádí audit standardu. Výsledek `MANUAL_REVIEW_REQUIRED` není automatické zamítnutí, ale povinnost odborně posoudit označené nálezy před publikací.

---

## D.5 Řízení terminologie

Terminologie je centrálně řízena standardy MM-STD-006 a MM-STD-008 a referenčním slovníkem MM-REF-001.

Pro MM-REF-001 smí existovat pouze jedna aktivní verze. Starší, neúplné nebo sloučené pracovní varianty jsou historické podklady.

Panelové popisky a uživatelská orientace se vedou v češtině. Technické identifikátory, názvy databázových objektů, API polí a zdrojových názvů mohou zůstat v originálním tvaru a jejich význam se vysvětluje prostřednictvím slovníku a tooltipů.

---

## D.6 Vazby mezi dokumenty

Vazby používají stabilní Document ID. Název souboru ani fyzická složka nesmějí být jediným prostředkem identifikace dokumentu.

Při změně ID historického pracovního návrhu se zachovává alias a historie. Již zavedené hlavní identity MM-DOC-000, 100, 200, 300, 800 a 900 se zpětně nepřečíslovávají.

---

## D.7 Audit dokumentace

Audit se provádí před vydáním nové verze, po významné obsahové změně, před importem do dokumentační databáze a před publikací do Git.

Doporučené pořadí je:

1. analýza a porovnání zdrojů,
2. aktualizace dokumentu,
3. A17 audit,
4. terminologická a vazební kontrola,
5. uživatelské schválení,
6. A24 `VALIDATE_ONLY`,
7. A24 `APPLY`,
8. následná integritní kontrola a Git commit.

---

## D.8 Automatizace governance

Aktuální nástroje:

- **A17** – audit souladu se standardem,
- **A18** – standardizační návrh,
- **A19** – kontrola mapování v panelu,
- **A20** – builder řízeného dokumentu,
- **A24** – import do dokumentační databáze v režimech `VALIDATE_ONLY` a `APPLY`.

Automatizace pomáhá odhalovat problémy, ale nenahrazuje věcné schválení uživatelem.

---

## D.9 Další rozvoj governance

Governance bude dále rozšířena o:

- automatické porovnání aktivního souboru s databází,
- kontrolu jediného aktivního souboru pro každé Document ID,
- automatické označení zastaralých snapshotů,
- přesnější správu aliasů a historických identit,
- automatickou aktualizaci indexů,
- metriky úplnosti a aktuálnosti dokumentace.

## D.10 Závěr kapitoly
Governance představuje řídicí vrstvu dokumentačního systému MatchMatrix. Zajišťuje, aby dokumentace byla dlouhodobě kvalitní, konzistentní, auditovatelná a připravená na další automatizaci.

Na tuto kapitolu navazuje Kapitola E – Budoucnost dokumentačního systému.

---

### Shrnutí
- Governance řídí celý dokumentační systém.
- Každý dokument má vlastníka, historii a životní cyklus.
- Kvalita dokumentace je ověřována definovanými kontrolami.
- Terminologie je řízena centrálním slovníkem MM-REF-001.
- Documentation Management System bude budoucí řídicí a kontrolní vrstvou.

---

# 5. Budoucnost dokumentačního systému MatchMatrix
---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-000 |
| Kapitola | E – Budoucnost dokumentačního systému |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |

---

## Historie verzí

| Verze | Datum | Popis |
|--------|--------|-------|
| 1.0 | 2026 | První referenční verze připravená k odbornému review. |
| 1.2 | 2026-07-27 | Aktualizace podle ověřeného projektového kontextu a skutečného stavu dokumentačního systému. |

---

## Účel kapitoly

Kapitola E definuje dlouhodobou vizi rozvoje dokumentačního systému MatchMatrix. Popisuje cílovou architekturu, plán automatizace a směr budoucího vývoje dokumentace jako plnohodnotné znalostní platformy.

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Budoucnost dokumentačního systému MatchMatrix“ v rámci dokumentu MM-DOC-000 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. Aktuální provozní model a práce s kontextem“, která rozvíjí další část řízeného dokumentu.

# Obsah

E.1 Vize dokumentačního systému

E.2 Documentation Management System

E.3 Architektura dokumentační databáze

E.4 Automatizace dokumentace

E.5 Umělá inteligence

E.6 Mezinárodní dokumentace (GLOBAL)

E.7 Webový dokumentační portál

E.8 Roadmapa rozvoje

E.9 Závěr

---

## E.1 Vize dokumentačního systému

Cílem MatchMatrix není pouze vytvářet technickou dokumentaci, ale vybudovat dlouhodobě udržitelný systém řízení znalostí. Dokumentace se stává plnohodnotnou součástí architektury platformy.

---

## E.2 Documentation Management System

Documentation Management System již má funkční základ v podobě dokumentační databáze, panelu Q3 a navazujících auditních a importních nástrojů.

Další generace systému má sjednotit:

- Document ID a metadata,
- historii verzí a aktivní cesty,
- sekce a vazby,
- terminologii,
- původ tvrzení,
- workflow schvalování,
- exporty a auditní záznamy,
- AI Context a snapshoty.

Markdown zůstává primárním pracovním a verzovaným formátem. DOCX, PDF, HTML a tabulkové výstupy jsou řízené exporty nebo pracovní analytické podklady.

---

## E.3 Architektura dokumentační databáze

Dokumentační databáze spravuje zejména dokumenty, verze, aktuální verze, sekce, vazby, historii stavů a importní běhy.

Souborová a databázová vrstva se doplňují:

- Git a souborový strom uchovávají čitelný, verzovaný obsah,
- databáze zajišťuje strukturované vyhledávání, vazby, stav a automatizaci,
- audit kontroluje jejich vzájemný soulad.

---

## E.4 Automatizace dokumentace

Automatizace má postupně zajišťovat:

- indexování aktivních dokumentů,
- kontrolu standardů a terminologie,
- detekci duplicitních aktivních souborů,
- generování návrhů z šablon,
- validaci před publikací,
- import do dokumentační databáze,
- generování Project Snapshot a Database Snapshot,
- extrakci kandidátních znalostí z historie komunikace.

---

## E.5 Umělá inteligence

AI podporuje analýzu, extrakci, porovnání, návrh, kontrolu konzistence a přípravu aktualizovaných dokumentů.

AI nesmí automaticky povýšit tvrzení z chatu, starého NAV dokumentu nebo historického souboru na aktuální pravdu. Každé významné tvrzení musí být posouzeno podle data, původu a souladu s aktuálním stavem databáze, Git a aktivní dokumentace.

Konečné rozhodnutí a schválení zůstává na odpovědném člověku.

---

## E.6 Mezinárodní dokumentace (GLOBAL)

Primární dokumentace vzniká v českém jazyce. GLOBAL se připravuje z určené aktuální a schválené české verze.

Technické názvy, kódové identifikátory a názvy API se nepřekládají nekonzistentně. Překlad a výklad se řídí slovníkem.

---

## E.7 Webový dokumentační portál

Dlouhodobým cílem je portál umožňující:

- vyhledávání v dokumentech a sekcích,
- filtrování podle stavu, typu a aktuálnosti,
- zobrazení vazeb a původu tvrzení,
- porovnávání verzí,
- procházení historie,
- export dokumentů,
- přepínání TECH, BOOK a GLOBAL.

---

## E.8 Roadmapa rozvoje

## Krátkodobé cíle

1. Aktualizovat MM-DOC-000, 100, 200, 300, 800 a 900 podle ověřené extrakční matice.
2. Sjednotit pravidla MM-STD-003, MM-STD-004 a MM-STD-007.
3. Doplnit MM-STD-1000 o MM-STD-006 až MM-STD-009.
4. Určit jedinou aktivní verzi MM-REF-001.
5. Provést A17 a řízený import nových verzí.

## Střednědobé cíle

1. Automatizovat Project Snapshot a Database Snapshot.
2. Doplnit evidenci původu tvrzení a konfliktů.
3. Rozšířit panel Q3 o přehled aktivních dokumentů, archivů a exportů.
4. Zavést vyhledávání a graf vazeb dokumentační databáze.

## Dlouhodobé cíle

1. Webový dokumentační portál.
2. Řízené BOOK a GLOBAL edice.
3. Průběžná AI podpora při zachování lidského schvalování.
4. Plně auditovatelný znalostní systém propojený s Git, databází a vývojovým workflow.

## E.9 Závěr kapitoly
Budoucnost dokumentačního systému MatchMatrix spočívá v propojení dokumentace, databáze, automatizace a umělé inteligence do jednoho řízeného systému znalostí.

Po schválení této kapitoly vznikne sloučením kapitol A až E první referenční dokument:

**MM-DOC-000 – MatchMatrix Documentation Framework (TECH).**

---

### Shrnutí
- Dokumentace se bude rozvíjet jako systém řízení znalostí.
- Documentation Management System bude řídit celý životní cyklus dokumentů.
- Dokumentační databáze bude spravovat metadata a vazby.
- AI bude podporovat autory dokumentace.
- GLOBAL rozšíří dokumentaci pro mezinárodní spolupráci.

---

# 6. Aktuální provozní model a práce s kontextem
---

## Informace o dokumentu

| Položka | Hodnota |
|---------|----------|
| Dokument | MM-DOC-000 |
| Kapitola | F – Aktuální provozní model a práce s kontextem |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Datum | 2026-07-27 |

---

## Účel kapitoly

Tato kapitola převádí obecný dokumentační rámec do aktuálně používaného provozního modelu MatchMatrix.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. Aktuální provozní model a práce s kontextem“ v rámci dokumentu MM-DOC-000 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# Obsah

F.1 Jediný aktivní soubor

F.2 Hierarchie důvěryhodnosti zdrojů

F.3 Historie chatů jako důkazní zdroj

F.4 Extrakční matice historie chatů

F.5 Stabilní identity hlavních dokumentů

F.6 Workflow Q3

F.7 AI Context a snapshoty

F.8 Jazyk a terminologie

F.9 Postup vytvoření nové verze

F.10 Závěr

---

## F.1 Jediný aktivní soubor

Pro každý Document ID existuje pouze jeden aktivní soubor. Nová verze vzniká pod původním stabilním názvem.

Postup je:

1. ověřit, která verze je nejnovější a obsahově navazuje na předchozí,
2. uložit předchozí řízenou verzi do `docs/99_ARCHIVE`,
3. aktualizovat obsah aktivního souboru pod původním názvem,
4. zvýšit číslo verze a doplnit historii změn uvnitř dokumentu,
5. provést audit, schválení, import a publikaci.

---

## F.2 Hierarchie důvěryhodnosti zdrojů

Při rozporu informací se posuzuje datum, původ a možnost ověření. Výchozí pořadí je:

1. aktuální stav databáze, Git a výstupy ověřených auditů,
2. aktuální ověřený Project Snapshot, Database Snapshot a AI Context,
3. současné aktivní řízené dokumenty,
4. schválené denní zápisy, NAV dokumenty a rozhodovací záznamy,
5. historie chatů a archivní dokumenty jako důkazní podklady,
6. domněnky a neověřené návrhy, které nesmějí být vydávány za skutečnost.

Novější ověřený snapshot může překonat starší aktivní dokument v oblasti aktuálního stavu; následně však musí být tato změna zapracována do referenčního dokumentu.

---

## F.3 Historie chatů jako důkazní zdroj

Komunikace v chatech obsahuje rozhodnutí, výsledky testů, opravy, preference a provozní zkušenosti, které nemusely být včas přeneseny do hlavní dokumentace.

Chat není automaticky autoritativní zdroj. Jeho obsah se používá jako důkazní materiál a ověřuje se proti současnému repozitáři, databázi, auditům a novějším rozhodnutím.

---

## F.4 Extrakční matice historie chatů

První řízená extrakce historie chatů je uložena v:

`docs/14_EXPORT/HISTORIE_CHATU/MM-EXP-20260727-01_EXTRAKCNI_MATICE_HISTORIE_CHATU_V1.xlsx`

Vstupní export obsahoval 173 konverzací. Projektový index určil 146 konverzací vztahujících se k MatchMatrix. Automatická první extrakce vytvořila 719 kandidátů, z nichž byl sestaven aktuální základ 30 tvrzení a 4 otevřené problémy.

Tato čísla popisují pracovní verzi extrakce, nikoli konečný počet znalostí. Automatická klasifikace může obsahovat nepřesnosti, a proto každý kandidát vyžaduje věcné ověření.

---

## F.5 Stabilní identity hlavních dokumentů

| Document ID | Aktivní role |
|-------------|--------------|
| MM-DOC-000 | Kořenový dokumentační rámec |
| MM-DOC-100 | Strategie a smysl platformy |
| MM-DOC-200 | Governance |
| MM-DOC-300 | Architektura |
| MM-DOC-800 | Vývojová příručka |
| MM-DOC-900 | Pravidla denních zápisů |

Historická pracovní označení MM-DOC-001, 002, 003, 004 a 005 jsou zachována pouze jako dohledatelné aliasy.

---

## F.6 Workflow Q3

Panel Q3 realizuje řízený dokumentační proces:

1. výběr a analýza zdroje,
2. oprava a kontrola,
3. vytvoření a schválení,
4. publikace v Git a dokumentační databázi.

Denní zápisy a NAV dokumenty vznikají z oficiálních šablon. Uživatel schvaluje výsledný obsah; technické snapshoty a metadata se mají doplňovat automatizovaně, nikoli ručním vyplňováním desítek polí.

---

## F.7 AI Context a snapshoty

Podle MM-STD-009 mají kontextové dokumenty obsahovat:

- AI CONTEXT,
- PROJECT SNAPSHOT,
- DATABASE SNAPSHOT,
- CURRENT STATUS,
- OPEN QUESTIONS,
- NEXT STEP.

Snapshot je časově označený popis aktuálního stavu. Nesmí se zaměňovat s trvalým architektonickým pravidlem.

---

## F.8 Jazyk a terminologie

Primárním jazykem dokumentace a uživatelských panelů je čeština.

Originální technické názvy se zachovávají tam, kde jejich překlad zhoršuje přesnost nebo návaznost na kód a databázi. Český význam se poskytuje prostřednictvím slovníku, vysvětlení nebo tooltipu.

---

## F.9 Postup vytvoření nové verze

Nová verze hlavního dokumentu vzniká takto:

1. vybere se nejnovější navazující verze,
2. shromáždí se ověřené změny z extrakční matice, auditů, Git a databáze,
3. změny se zapracují do původního aktivního názvu,
4. předchozí verze se archivuje,
5. dokument projde A17 a věcným review,
6. po schválení se provede A24 `VALIDATE_ONLY` a `APPLY`,
7. následuje integritní kontrola a Git commit.

---

## F.10 Závěr kapitoly
Aktuální provozní model spojuje dokumenty, databázi, Git, automatizaci, historii práce a AI do jednoho auditovatelného systému. Rozhodující není množství uložených textů, ale schopnost určit, která informace je aktuální, kde má referenční místo a z jakého důkazu vznikla.

---

### Shrnutí
- Aktivní soubor má stabilní název.
- Předchozí řízená verze patří do archivu.
- Chatová historie je důkazní zdroj, nikoli automatická pravda.
- Ověřený současný stav má přednost před starým kontextem.
- Q3 a dokumentační databáze tvoří funkční základ DMS.

---

# Závěr dokumentu

Dokumentační systém MatchMatrix je aktivně používaný systém řízení znalostí, nikoli pouze návrh budoucí dokumentace.

Tento dokument stanovuje základní architekturu, identity, edice, správu zdrojů, governance, práci s AI kontextem a provozní workflow. Jeho úkolem je zajistit, aby se nové poznatky z vývoje, auditů a komunikace promítaly do jediných aktivních referenčních dokumentů kontrolovaným a dohledatelným způsobem.

---

# Kontrolní poznámky pro schválení verze 1.2

Před změnou stavu z REVIEW na APPROVED nebo ACTIVE musí být provedeno:

- kontrola souladu s MM-STD-001 až MM-STD-009,
- kontrola terminologie podle jediné aktivní verze MM-REF-001,
- kontrola vazeb na MM-STD-1000 a MM-DOC-1000,
- A17 audit a vyhodnocení všech nálezů,
- ověření aktivní cesty a nepřítomnosti paralelní `_REVIEW` verze,
- aktualizace dokumentační databáze pomocí A24,
- následná integritní kontrola a Git commit.

---

# AI CONTEXT

**Role dokumentu:** Kořenový rámec dokumentačního a znalostního systému MatchMatrix.

**Hlavní pravidlo:** Nové ověřené informace se zapracovávají do původního aktivního názvu dokumentu. Předchozí řízená verze se archivuje.

**Práce se zdroji:** Chat, NAV, denní zápis a archiv jsou důkazní podklady. Aktuální tvrzení musí být ověřeno proti novějšímu snapshotu, databázi, Git nebo auditu.

**Stabilní hlavní identity:** MM-DOC-000, 100, 200, 300, 800 a 900.

**Navazuje na:** MM-STD-001 až MM-STD-009, MM-REF-001, MM-DOC-1000 a panelové workflow Q3.

---

# PROJECT SNAPSHOT

| Oblast | Stav k 2026-07-27 |
|--------|-------------------|
| Dokumentační rámec | Aktualizace MM-DOC-000 na verzi 1.2 |
| Historie chatů | Export analyzován, extrakční matice V1 uložena |
| Projektové konverzace | 146 identifikovaných konverzací |
| Kandidátní důkazy | 719 automaticky extrahovaných kandidátů |
| Aktuální základ | 30 kurátorovaných tvrzení |
| Otevřené dokumentační problémy | 4 položky |
| Hlavní dokumenty | Identity MM-DOC-100/200/300/800/900 sjednoceny pod stabilními názvy |
| Workflow Q3 | Implementováno a používané |
| Publikace této změny | Zatím neprovedena; dokument čeká na audit a schválení |

---

# DATABASE SNAPSHOT

## Dokumentační databáze

| Objekt | Počet k 2026-07-27 |
|--------|-------------------:|
| Dokumenty | 354 |
| Verze | 360 |
| Aktuální verze | 354 |
| Sekce | 7 075 |
| Vazby | 495 |
| Importní běhy | 48 |

## Projektová databáze

Aktuální technické počty sportovní databáze nejsou trvalou součástí tohoto rámce. Musí být čerpány z nejnovějšího A33 nebo navazujícího databázového auditu a uváděny v MM-DOC-300 nebo v časově označeném Project Snapshot.

---

# CURRENT STATUS

| Oblast | Stav |
|--------|------|
| Dokumentační architektura | ACTIVE DEVELOPMENT |
| Dokumentační databáze | ACTIVE |
| Panel Q3 | IMPLEMENTED |
| Standardy MM-STD-001 až MM-STD-009 | EXISTUJÍ, vyžadují sjednocení některých pravidel |
| MM-DOC-000 | REVIEW – verze 1.2 |
| MM-DOC-100 / 200 / 300 / 800 / 900 | Připraveny pod stabilními aktivními názvy pro obsahovou aktualizaci |
| Extrakční matice historie chatů | V1 – pracovní podklad k ověření |
| Git commit této etapy | NEPROVEDEN |

---

# OPEN QUESTIONS

- Sjednotit rozpory mezi MM-STD-003, MM-STD-004 a MM-STD-007.
- Doplnit MM-STD-1000 o standardy MM-STD-006 až MM-STD-009.
- Určit a potvrdit jedinou aktivní verzi MM-REF-001.
- Prověřit duplicitní strom `docs/docs` a přesunout exportní DOCX mimo aktivní zdrojovou dokumentaci.
- Dokončit obsahovou aktualizaci MM-DOC-100, 200, 300, 800 a 900 podle ověřené extrakční matice.

---

# NEXT STEP

Nahradit aktivní soubor `MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK.md` touto verzí 1.2, provést A17 audit a po odstranění nálezů pokračovat aktualizací MM-DOC-100 podle potvrzeného aktuálního základu.
