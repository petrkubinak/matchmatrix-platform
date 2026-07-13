**Document ID:** `MM-DOC-001`

# MAPA DOKUMENTAČNÍCH OBLASTÍ MATCHMATRIX

**Edice:** MM-DOC TECH

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DOC-001 |
| Název dokumentu | Mapa dokumentačních oblastí MatchMatrix |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum | 2026-07-13 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Primární formát | Markdown (.md) |
| Cílové umístění | `docs/00_DOCUMENTATION/MM-DOC-001_MAPA_DOKUMENTACNICH_OBLASTI_MATCHMATRIX.md` |
| Zdrojový audit | `MATCHMATRIX_DOCS_STRUCTURE_AUDIT_20260713.md` |
| Výchozí Git commit | `3bca659f49e02d35eb0b1140e4ef00b724daae29` |
| Související standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-008, MM-STD-009 |
| Kořenový rámec | MM-DOC-000 |
| Centrální index dokumentů | MM-DOC-1000 |
| Index standardů | MM-STD-1000 |

---

## 1. Účel dokumentu

Tento dokument stanovuje jednotnou mapu aktivních dokumentačních oblastí projektu MatchMatrix.

Jeho cílem je určit:

- co patří do jednotlivých složek,
- co do nich nepatří,
- jaký typ dokumentů se v nich vede,
- který obsah je referenční,
- jaké jsou vazby mezi oblastmi,
- jak mají vznikat nové dokumenty,
- kde se uchovává historie, pracovní návrhy, exporty a zdrojové důkazy,
- jaký základní dokument má být postupně vytvořen v každé oblasti.

Dokument slouží jako centrální zdroj pravdy pro fyzickou organizaci adresáře `docs`.

---

### Závěr kapitoly

Kapitola vymezila účel centrální mapy a potvrdila, že dokument řídí fyzické i významové uspořádání stromu `docs`. Jejím přínosem je společný výchozí rámec pro další dokumentační práci. Následující kapitola jednoznačně určuje identitu dokumentu, jeho návaznosti a rozsah platnosti.

---

## 2. Identifikace a návaznosti

### 2.1 Identifikace dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | `MM-DOC-001` |
| Typ dokumentu | Hlavní dokumentační mapa |
| Dokumentační oblast | `00_DOCUMENTATION` |
| Řízený objekt | Aktivní strom `docs` |
| Nadřazený rámec | `MM-DOC-000` |
| Centrální index | `MM-DOC-1000` |
| Index standardů | `MM-STD-1000` |
| Stav návrhu | REVIEW |
| Cílový stav | APPROVED |

### 2.2 Návaznosti

Dokument navazuje zejména na:

- `MM-DOC-000` – MatchMatrix Documentation Framework,
- `MM-STD-001` – Standard tvorby hlavních dokumentů,
- `MM-STD-003` – Standard životního cyklu dokumentace a verzování,
- `MM-STD-004` – Standard názvosloví a struktury dokumentace,
- `MM-STD-006` – Standard terminologie a slovníku pojmů,
- `MM-STD-007` – Identifikace a číslování dokumentů MatchMatrix,
- `MM-STD-008` – Správa terminologie a referenčního slovníku,
- `MM-STD-009` – AI Context a Project Snapshot.

Výstup dokumentu bude použit jako základ pro oblastní indexy v aktivních složkách dokumentace.

### 2.3 Rozsah platnosti

Dokument se vztahuje na celý aktivní strom:

```text
C:\MatchMatrix-platform\docs
```

Nevztahuje se na zdrojové kódy mimo `docs`, pokud nejsou přímo součástí dokumentačního workflow.

### Závěr kapitoly

Kapitola shrnula identitu dokumentu, jeho nadřazené zdroje a rozsah platnosti. Jejím přínosem je pevná vazba mezi dokumentačním rámcem, standardy a budoucími oblastními indexy. Návaznost pokračuje v následující kapitole, která uvádí ověřené zdroje a způsob jejich použití.

---

## 3. Ověřené zdroje a odkazy

### 3.1 Primární zdroje

| Zdroj | Typ | Ověření | Použití |
|---|---|---|---|
| `MATCHMATRIX_DOCS_STRUCTURE_AUDIT_20260713.md` | Strukturální audit | Ověřeno proti stromu `docs` | Počty složek, souborů a fyzická struktura |
| `C:\MatchMatrix-platform\docs` | Aktivní dokumentační strom | Ověřeno na PC2 | Zdroj fyzického uspořádání |
| Git commit `3bca659f49e02d35eb0b1140e4ef00b724daae29` | Verzovaný stav repozitáře | Ověřeno přes Git | Výchozí stav auditu |
| `MM-DOC-000` | Dokumentační rámec | Aktivní dokument | Nadřazená architektura dokumentace |
| `MM-STD-001` | Standard | Aktivní dokument | Povinná struktura hlavních dokumentů |
| `MM-STD-003` | Standard | Aktivní dokument | Životní cyklus a verzování |
| `MM-STD-004` | Standard | Aktivní dokument | Názvosloví a struktura |
| `MM-STD-006` | Standard | Aktivní dokument | Terminologie |
| `MM-STD-007` | Standard | Aktivní dokument | Document ID a prefixy |
| `MM-STD-008` | Standard | Aktivní dokument | Referenční terminologie |
| `MM-STD-009` | Standard | REVIEW | Kontextové a snapshotové sekce |

### 3.2 Zásada práce se zdroji

Každý budoucí oblastní index musí rozlišovat:

- kanonický dokument,
- fyzický soubor,
- databázový záznam,
- generovaný report,
- historický důkaz,
- pracovní návrh.

Generovaný report nebo chatový export nesmí být bez schválení považován za aktivní zdroj pravdy.

### Závěr kapitoly

Kapitola shrnula ověřené zdroje, z nichž byla mapa vytvořena, a pravidla jejich interpretace. Jejím přínosem je dohledatelný původ strukturálních rozhodnutí a omezení použití nekanonických zdrojů. Návaznost pokračuje v následující kapitole, která shrnuje dokončenou práci a dosažený výsledek.

---

## 4. Co bylo dokončeno

K datu 2026-07-13 bylo dokončeno:

- zmapování aktivního stromu `docs`,
- oddělení aktivní dokumentace od `99_ARCHIVE`,
- zjištění počtu aktivních adresářů a souborů,
- klasifikace všech hlavních složek podle účelu,
- vymezení obsahu, který do jednotlivých oblastí patří a nepatří,
- identifikace prázdných nebo obsahově nezaložených oblastí,
- návrh oblastních indexů,
- určení priorit dalšího rozvoje,
- identifikace rizika duplicitního `MM-REF-001`,
- identifikace neaktuálního indexu standardů,
- identifikace chybějícího pravidla pro `17_CHAT`,
- identifikace nerozhodnuté oblasti `16_DECISIONS`,
- stanovení workflow pro vznik nových řízených dokumentů.

### Výsledek

Vznikl první jednotný základ, podle kterého lze postupně doplňovat obsah do všech dokumentačních složek bez nahodilého zakládání souborů a bez vytváření paralelních zdrojů pravdy.

### Závěr kapitoly

Kapitola shrnula dokončené kroky při mapování dokumentačního stromu a vznik jednotného organizačního základu. Jejím přínosem je kontrolovaný výchozí bod pro další dokumentační rozvoj. Návaznost pokračuje v následující kapitole, která odděluje známá rizika a potřebná nápravná opatření.

---

## 5. Rizika a upozornění

| Riziko nebo upozornění | Dopad | Závažnost | Navržené opatření |
|---|---|---|---|
| Dvě aktivně působící kopie `MM-REF-001` | Nejednoznačný zdroj terminologie | HIGH | Potvrdit canonical soubor a druhou kopii archivovat |
| Neúplný `MM-STD-1000` | Standardy 006–009 nemusí být dohledatelné | HIGH | Aktualizovat index standardů |
| `17_CHAT` nemá definovaný prefix | Riziko nesprávných Document ID | MEDIUM | Doplnit MM-STD-007 |
| `16_DECISIONS` neexistuje | Rozhodnutí zůstávají smíšená s historií | MEDIUM | Rozhodnout o založení samostatné oblasti |
| `11_VISUAL` obsahuje duplicity | Nejasná aktivní vizuální identita | MEDIUM | Vytvořit asset registry |
| Oblasti 04–07 jsou bez základních dokumentů | Technická znalost není centralizována | HIGH | Vytvořit oblastní indexy podle priority |
| Kořenové registry nemají potvrzenou odpovědnost | Nejasné umístění generovaných registrů | LOW | Rozhodnout mezi kořenem a `00_DOCUMENTATION` |
| Oblastní prefixy musí odpovídat MM-STD-007 | Chybné ID mohou blokovat import | HIGH | Před vytvořením každého indexu ověřit prefix |
| Mapa je k datu auditu, nikoli automaticky aktuální | Pozdější soubory nemusí být zachyceny | MEDIUM | Audit opakovat při významné změně struktury |

### Upozornění k interpretaci

Tento dokument stanovuje cílové odpovědnosti složek. Nepotvrzuje automaticky technickou správnost všech souborů, které se v nich aktuálně nacházejí.

### Závěr kapitoly

Kapitola shrnula známá strukturální rizika a upozornění vztahující se k aktivnímu stromu dokumentace. Jejím přínosem je řízený seznam problémů, dopadů a konkrétních opatření, který lze postupně uzavírat. Návaznost pokračuje v následující kapitole, která dokládá provozní stav dokumentační databáze.

---

## 6. DATABASE SNAPSHOT

### 6.1 Dokumentační databáze

Tato sekce popisuje databázi řízené dokumentace, nikoli hlavní sportovní databázi MatchMatrix.

Stav po ověření únorového Project Snapshotu `MM-PS-20260223`:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 326 |
| Verze celkem | 331 |
| Aktuální verze | 326 |
| Sekce | 3 605 |
| Vazby | 141 |
| Historie stavů | 331 |
| Importní běhy | 18 |
| Aktivní dokumenty | 326 |

### 6.2 Význam snapshotu

Databázový snapshot potvrzuje, že:

- dokumentační databáze je aktivní,
- podporuje více verzí jednoho dokumentu,
- eviduje sekce, vazby a historii stavů,
- oblastní indexy mohou být vedeny jako samostatné řízené dokumenty,
- každý nový dokument musí projít kontrolovaným importem a integritním ověřením.

### 6.3 Omezení

Hodnoty odpovídají stavu k 2026-07-13 a budou se měnit s dalšími importy.

Aktuální hodnoty musí být při budoucí revizi získány z dokumentační databáze nebo z Q3 panelu.

### Závěr kapitoly

Kapitola shrnula stav dokumentační databáze a její schopnost evidovat dokumenty, verze, sekce, vazby a historii stavů. Jejím přínosem je potvrzení provozuschopného základu pro řízené oblastní indexy. Návaznost pokračuje v následující kapitole, která popisuje skutečný stav aktivní dokumentace k datu auditu.

---

## 7. Výchozí stav k 2026-07-13

Audit aktivní dokumentace potvrdil:

| Ukazatel | Stav |
|---|---:|
| Aktivní adresáře mimo `99_ARCHIVE` | 30 |
| Aktivní soubory mimo `99_ARCHIVE` | 160 |
| Hlavní aktivní složky v `docs` | 17 |
| Archivní adresáře | 92 |
| Archivní soubory | 390 |
| Měsíční Project Snapshoty | 5 |
| Denní zápisy | 11 |
| Dokumenty NAVÁZÁNÍ | 13 |
| Aktivní standardy ve složce `12_STANDARD` | 9 |

Audit současně odhalil, že některé oblasti již obsahují rozvinutou dokumentaci, zatímco jiné mají pouze `.gitkeep` a dosud nemají základní oblastní dokument.

### 7.1 Oblasti s rozvinutým obsahem

- `00_DOCUMENTATION`
- `01_MASTER`
- `02_GOVERNANCE`
- `03_ARCHITECTURE`
- `08_DEVELOPMENT`
- `09_HISTORY`
- `10_REFERENCE`
- `11_VISUAL`
- `12_STANDARD`
- `13_TEMPLATES`
- `17_CHAT`
- `99_ARCHIVE`

### 7.2 Oblasti bez skutečného obsahového základu

- `04_DATABASE`
- `05_PROVIDERS`
- `06_LAYERS`
- `07_OPERATOR`
- `14_EXPORT`
- `15_DRAFT`

Tyto složky musí postupně získat vlastní řízený oblastní index a následné odborné dokumenty.

---

### Závěr kapitoly

Kapitola shrnula skutečný stav aktivní dokumentace k datu auditu a oddělila rozvinuté oblasti od složek bez obsahového základu. Jejím přínosem je doložený výchozí bod pro plánování další práce. Následující kapitola stanovuje zásady, podle kterých se má celý strom dlouhodobě organizovat.

---

## 8. Základní principy organizace

### 8.1 Jedna informace má jedno referenční místo

Každá významná informace musí mít jedno určené referenční místo.

Jiné dokumenty ji nesmějí bezdůvodně kopírovat. Mají na ni odkazovat pomocí Document ID.

### 8.2 Složka určuje tematickou oblast

Fyzická složka určuje, do které tematické oblasti dokument patří.

Document ID určuje identitu dokumentu a zůstává stabilní i při změně názvu.

### 8.3 Aktivní dokument je pouze jeden

Pro jeden Document ID smí existovat pouze jeden aktivní kanonický soubor.

Starší, nahrazené nebo historické kopie patří do `99_ARCHIVE`.

### 8.4 Zdrojový důkaz není automaticky kanonický dokument

Chat, export, report, screenshot, CSV nebo diagnostický výstup může být důkazem.

Kanonickou projektovou znalostí se stává až po:

1. analýze,
2. standardizaci,
3. schválení,
4. uložení do správné oblasti,
5. Git publikaci,
6. databázovém importu a ověření, pokud je import vyžadován.

### 8.5 Kořen složky `docs` není běžná dokumentační oblast

Do kořene `docs` patří pouze:

- centrální strojově generované registry,
- globální manifesty,
- technické indexy vztahující se k celému stromu,
- výjimečné kořenové soubory schválené dokumentačním standardem.

Běžné odborné dokumenty musí být uloženy v tematické podsložce.

---

### Závěr kapitoly

Kapitola stanovila základní organizační zásady: jedno referenční místo, stabilní identitu, jediný aktivní kanonický soubor a řízené zpracování zdrojových důkazů. Jejím přínosem je ochrana proti duplicitám a nahodilému ukládání dokumentů. Následující kapitola převádí tyto zásady do centrální mapy konkrétních složek.

---

## 9. Centrální mapa dokumentačních složek

| Složka | Hlavní účel | Primární obsah | Obsah, který sem nepatří |
|---|---|---|---|
| `00_DOCUMENTATION` | Řízení dokumentačního systému | rámec dokumentace, workflow, DMS, mapa oblastí | doménová architektura, denní historie |
| `01_MASTER` | Celkový obraz projektu | poslání, produktová vize, cíle, aktuální master | detailní SQL, jednotlivé providery |
| `02_GOVERNANCE` | Pravidla řízení platformy | odpovědnosti, kontroly, identity, kvalita, schvalování | detailní implementační postupy |
| `03_ARCHITECTURE` | Architektura platformy | komponenty, vrstvy, datové toky, integrační hranice | denní provozní logy |
| `04_DATABASE` | Databázová dokumentace | model, schémata, entity, migrace, integrita, výkon | obecná produktová vize |
| `05_PROVIDERS` | Dokumentace datových zdrojů | registry, coverage, smlouvy, limity, licence, mapování | canonical definice bez providerové vazby |
| `06_LAYERS` | Funkční a datové vrstvy platformy | ingest, people, media, odds, rating, prediction, Ticket Engine | obecná governance bez vazby na vrstvu |
| `07_OPERATOR` | Řízení provozu | panely, runbooky, plánovač, workery, incidenty, obsluha | vývojové standardy zdrojového kódu |
| `08_DEVELOPMENT` | Vývojářská dokumentace | prostředí, kód, testy, Git, release, diagnostika | business roadmapa |
| `09_HISTORY` | Řízená historie projektu | denní zápisy, NAV, snapshoty, changelog, historická rozhodnutí | aktivní slovník a aktuální technické specifikace |
| `10_REFERENCE` | Referenční znalosti a indexy | slovníky, rejstříky, centrální indexy, katalogy | pracovní návrhy |
| `11_VISUAL` | Vizuální identita a assety | loga, ikony, brand pack, pravidla použití | neuspořádané duplicity bez evidence |
| `12_STANDARD` | Závazná pravidla | MM-STD dokumenty a jejich index | doporučení bez normativní platnosti |
| `13_TEMPLATES` | Schválené šablony | šablony řízených dokumentů | vyplněné konkrétní dokumenty |
| `14_EXPORT` | Odvozené výstupy | PDF, DOCX, balíčky, reportovací exporty | primární zdroj pravdy |
| `15_DRAFT` | Dočasné pracovní návrhy | rozpracované dokumenty před schválením | schválené aktivní dokumenty |
| `17_CHAT` | Surové chatové zdroje | exporty chatů, HTML, PDF, přílohy, pracovní texty | kanonická projektová dokumentace |
| `99_ARCHIVE` | Historické a nahrazené kopie | superseded dokumenty, staré verze, zrušené návrhy | aktivní zdroj pravdy |

---

### Závěr kapitoly

Kapitola poskytla souhrnnou mapu všech aktivních dokumentačních oblastí a jejich hlavního účelu. Jejím přínosem je rychlá orientace v celém stromu `docs`. Následující kapitola rozpracovává odpovědnost každé oblasti, povolený obsah a navržené základní dokumenty.

---

## 10. Detailní pravidla jednotlivých oblastí

### 10.1 `00_DOCUMENTATION`

#### Poslání

Řídí celý dokumentační ekosystém MatchMatrix.

#### Patří sem

- dokumentační framework,
- mapa dokumentačních oblastí,
- pravidla dokumentačního workflow,
- popis Documentation Management System,
- řízení dokumentační databáze,
- registr dokumentačních nástrojů,
- globální dokumentační architektura.

#### Nepatří sem

- technická architektura samotné platformy,
- databázová schémata sportovních dat,
- denní zápisy,
- providerové reporty.

#### Základní dokumenty

- `MM-DOC-000` – MatchMatrix Documentation Framework,
- `MM-DOC-001` – Mapa dokumentačních oblastí MatchMatrix,
- `MM-DOC-1000` – Centrální index dokumentů.

---

### 10.2 `01_MASTER`

#### Poslání

Uchovává nejvyšší souhrnný pohled na projekt a jeho směřování.

#### Patří sem

- poslání a vize,
- cílové produkty,
- obchodní a uživatelský směr,
- hlavní capability platformy,
- strategické priority,
- souhrnná roadmapa,
- stručný aktuální stav hlavních oblastí.

#### Nepatří sem

- detailní popis tabulek,
- jednotlivé SQL dotazy,
- podrobné providerové limity,
- pracovní diagnostika.

#### Základní dokument

Navržený budoucí oblastní index:

`MM-MST-1000_INDEX_MASTER_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.3 `02_GOVERNANCE`

#### Poslání

Definuje pravidla, odpovědnosti, kontroly a hranice rozhodování.

#### Patří sem

- Data Governance,
- Database Governance,
- Provider Governance,
- Entity Governance,
- Duplicate Prevention Governance,
- Source Governance,
- Script Governance,
- dokumentační governance,
- schvalovací role,
- auditní stopa,
- pravidla změn a výjimek.

#### Nepatří sem

- podrobná implementace jednotlivého skriptu,
- surové denní výsledky běhů,
- uživatelský návod panelu.

#### Základní dokument

Navržený budoucí oblastní index:

`MM-GOV-1000_INDEX_GOVERNANCE_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.4 `03_ARCHITECTURE`

#### Poslání

Popisuje strukturu platformy, její hranice a vazby.

#### Patří sem

- systémová architektura,
- logická architektura,
- datové toky,
- aplikační komponenty,
- integrační rozhraní,
- vrstvy,
- deployment topologie,
- PC1/PC2 role,
- bezpečnostní hranice,
- vazby mezi ingestem, databází, analytikou, panelem a webem.

#### Nepatří sem

- detailní provozní incidenty,
- jednotlivé providerové podmínky,
- kompletní databázový katalog.

#### Základní dokument

Navržený budoucí oblastní index:

`MM-ARC-1000_INDEX_ARCHITEKTONICKE_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.5 `04_DATABASE`

#### Poslání

Je zdrojem pravdy pro databázovou strukturu, význam dat a pravidla změn databáze.

#### Patří sem

- přehled databází a schémat,
- canonical entity model,
- tabulky a jejich odpovědnost,
- klíče, vazby a integrita,
- staging a raw vrstvy,
- merge pravidla,
- migrace,
- naming convention databázových objektů,
- retenční pravidla,
- výkon, indexy a partitioning,
- audit databázové kvality,
- datový slovník.

#### Nepatří sem

- providerové obchodní podmínky,
- uživatelský návod panelu,
- vývojová historie jednotlivých dní.

#### První základní dokument

`MM-DB-1000_INDEX_DATABAZOVE_DOKUMENTACE_MATCHMATRIX.md`

#### Následné prioritní dokumenty

- databázová architektura,
- katalog schémat a tabulek,
- canonical entity model,
- pravidla migrací,
- pravidla integrity a auditů.

---

### 10.6 `05_PROVIDERS`

#### Poslání

Řídí znalosti o externích a interních datových zdrojích.

#### Patří sem

- provider registry,
- provider coverage,
- supported sports and entities,
- API limity,
- autentizace,
- licenční a právní stav,
- robots.txt a Terms audit,
- datová kvalita,
- komerční model,
- request planning,
- mapping pravidla,
- source intelligence,
- provider health monitoring.

#### Nepatří sem

- canonical definice bez vazby na zdroj,
- interní výpočet ratingu,
- obecný vývojářský handbook.

#### První základní dokument

`MM-PRV-1000_INDEX_PROVIDEROVE_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.7 `06_LAYERS`

#### Poslání

Dokumentuje jednotlivé funkční, datové a analytické vrstvy platformy.

#### Patří sem

- ingest,
- raw a staging,
- merge a canonical,
- sport completion,
- people,
- media,
- odds,
- stadiums and venues,
- ratings,
- machine learning,
- predictions,
- value,
- Ticket Engine,
- web API,
- AI vrstva.

#### Nepatří sem

- providerový registr jako celek,
- obecné řízení projektu,
- surové historické chaty.

#### První základní dokument

`MM-LAY-1000_INDEX_VRSTEV_PLATFORMY_MATCHMATRIX.md`

#### Doporučené členění budoucích dokumentů

Každá vrstva má popsat:

1. účel,
2. vstupy,
3. výstupy,
4. databázové objekty,
5. skripty a služby,
6. kontroly,
7. provozní stav,
8. známé mezery,
9. návaznosti.

---

### 10.8 `07_OPERATOR`

#### Poslání

Dokumentuje provozní řízení MatchMatrix a práci obsluhy.

#### Patří sem

- OPS panel,
- Q3 dokumentační workflow,
- plánovač,
- workery,
- aktivní běhy,
- harvest,
- incident runbooky,
- retry pravidla,
- monitoring,
- manuální zásahy,
- role PC1 a PC2,
- postupy spuštění a zastavení,
- provozní checklisty.

#### Nepatří sem

- obecné zásady programování,
- business roadmapa,
- archivní chatové exporty.

#### První základní dokument

`MM-OPS-1000_INDEX_OPERATOR_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.9 `08_DEVELOPMENT`

#### Poslání

Uchovává pravidla a postupy pro bezpečný vývoj platformy.

#### Patří sem

- nastavení vývojového prostředí,
- Python, PowerShell a SQL pravidla,
- struktura repozitáře,
- Git workflow,
- testování,
- diagnostika,
- review,
- release,
- verzování skriptů,
- naming convention,
- práce s historickými verzemi,
- vývoj panelů a spouštěčů.

#### Nepatří sem

- provozní denní logy,
- providerové licenční informace,
- konečný databázový katalog.

#### Základní dokument

Navržený budoucí oblastní index:

`MM-DEV-1000_INDEX_VYVOJOVE_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.10 `09_HISTORY`

#### Poslání

Uchovává řízenou a časově ukotvenou historii projektu.

#### Patří sem

- denní zápisy,
- NAVÁZÁNÍ do nového chatu,
- Project Snapshoty,
- changelog,
- historické rekonstrukce,
- historické checkpointy,
- historie architektonických rozhodnutí do doby vytvoření samostatné rozhodovací oblasti.

#### Nepatří sem

- aktivní překladový slovník,
- aktivní výkladový rejstřík,
- aktuální technická specifikace databáze,
- pracovní drafty.

#### Podřízené složky

##### `DENNÍ_ZÁPISY`

Jeden denní zápis pro jeden pracovní den:

`MM-DL-YYYYMMDD`

##### `NAVÁZÁNÍ_NA_CHAT`

Jeden nebo více navazovacích dokumentů:

`MM-NAV-YYYYMMDD-NN`

##### `PROJECT_SNAPSHOTS`

Časově ukotvené kontrolní body projektu:

`MM-PS-YYYYMMDD`

##### `SLOVNÍK POJMŮ`

Tato složka má historický charakter a nemá zůstat aktivním referenčním umístěním slovníku.

Aktivní MM-REF dokumenty patří do `10_REFERENCE`.

#### První základní dokument

`MM-HIS-1000_INDEX_HISTORICKE_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.11 `10_REFERENCE`

#### Poslání

Uchovává rychle použitelné referenční znalosti a centrální indexy.

#### Patří sem

- MM-REF-001 – překladový slovník cizích pojmů,
- MM-REF-002 – výkladový rejstřík,
- centrální dokumentační index,
- index standardů,
- katalogy identifikátorů,
- datové a dokumentační registry určené pro referenci.

#### Nepatří sem

- dlouhé technické návrhy,
- denní historie,
- nezpracované chaty,
- pracovní koncepty.

#### Kritické pravidlo

Aktivní terminologická architektura je:

```text
MM-REF-001 = překladový slovník
MM-REF-002 = výkladový rejstřík
```

V aktivním stromu nesmí existovat druhý kanonický dokument se stejným Document ID `MM-REF-001`.

#### První základní dokument

`MM-REF-1000_INDEX_REFERENCNI_DOKUMENTACE_MATCHMATRIX.md`

---

### 10.12 `11_VISUAL`

#### Poslání

Uchovává vizuální identitu, schválené assety a pravidla jejich použití.

#### Patří sem

- loga,
- ikony,
- favicony,
- brand pack,
- tmavé a světlé varianty,
- barevné palety,
- typografická pravidla,
- UI vzory,
- dokumentace vizuální identity,
- evidence schválených a historických variant.

#### Nepatří sem

- neurčené duplicity,
- pracovní obrázky bez popisu,
- exporty bez informace o původu,
- aktivní assety uložené pouze v ZIP souboru.

#### První základní dokument

`MM-VIS-1000_INDEX_VIZUALNI_DOKUMENTACE_A_ASSETU.md`

---

### 10.13 `12_STANDARD`

#### Poslání

Uchovává závazná pravidla platná pro celý projekt nebo jeho dokumentační systém.

#### Patří sem

- pouze dokumenty MM-STD,
- centrální index standardů,
- pravidla s normativními formulacemi,
- historie změn standardů.

#### Nepatří sem

- doporučení bez závaznosti,
- běžné návody,
- pracovní poznámky,
- konkrétní denní rozhodnutí.

#### Aktuální stav

Složka obsahuje standardy `MM-STD-001` až `MM-STD-009`.

Index `MM-STD-1000` musí být aktualizován tak, aby evidoval také standardy `006`, `007`, `008` a `009`.

#### Základní dokument

Existující:

`MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md`

---

### 10.14 `13_TEMPLATES`

#### Poslání

Uchovává schválené a opakovaně použitelné šablony.

#### Patří sem

- šablony denních zápisů,
- šablony NAVÁZÁNÍ,
- šablony Project Snapshotů,
- šablony technických dokumentů,
- šablony rozhodnutí,
- šablony auditních reportů.

#### Nepatří sem

- vyplněné konkrétní dokumenty,
- pracovní dokumenty obsahující reálná projektová data,
- historické verze šablon.

#### Základní dokument

`MM-TPL-1000_INDEX_SABLON_MATCHMATRIX.md`

---

### 10.15 `14_EXPORT`

#### Poslání

Uchovává odvozené výstupy určené k distribuci, prezentaci nebo externímu použití.

#### Patří sem

- PDF exporty,
- DOCX exporty,
- publikované balíčky,
- machine-readable exporty,
- distribuční ZIP balíčky,
- reportovací sestavy.

#### Nepatří sem

- jediná existující kopie dokumentu,
- kanonický Markdown,
- zdrojový kód exportéru,
- pracovní návrhy.

#### Základní dokument

`MM-EXP-1000_INDEX_A_PRAVIDLA_EXPORTU_DOKUMENTACE.md`

---

### 10.16 `15_DRAFT`

#### Poslání

Slouží pouze pro dočasné pracovní návrhy před jejich schválením.

#### Patří sem

- rozpracované návrhy,
- kandidátní dokumenty z A18/A20,
- pracovní mapování,
- dokumenty čekající na uživatelské rozhodnutí.

#### Nepatří sem

- schválené dokumenty,
- aktivní produkční soubory,
- dlouhodobý archiv,
- exporty.

#### Povinné pravidlo

Dokument nesmí zůstat v `15_DRAFT` bez vlastníka a dalšího kroku.

Po dokončení musí být:

- schválen a přesunut do cílové oblasti,
- nebo zamítnut a archivován,
- nebo odstraněn, pokud nemá dokumentační hodnotu.

#### Základní dokument

`MM-DRF-1000_INDEX_A_PRAVIDLA_PRACOVNICH_NAVRHU.md`

---

### 10.17 Navrhovaná oblast `16_DECISIONS`

#### Důvod návrhu

Architektonická a projektová rozhodnutí jsou dnes vedena v rámci historie, zejména dokumentem `MM-DOC-903`.

Pro dlouhodobý rozvoj platformy je vhodné oddělit:

- chronologickou historii,
- závazná rozhodnutí,
- důvody rozhodnutí,
- odmítnuté varianty,
- dopady a stav platnosti.

#### Navrhovaný obsah

- Architecture Decision Records,
- Data Decision Records,
- Product Decision Records,
- Governance Decision Records,
- rozhodnutí o providerech,
- rozhodnutí o canonical modelu,
- změny strategického směru.

#### Stav

Složka dosud v aktivním stromu neexistuje.

Její vznik musí být nejprve schválen a doplněn do MM-STD-007.

---

### 10.18 `17_CHAT`

#### Poslání

Uchovává surové zdrojové záznamy komunikace, které mohou sloužit jako historický důkaz.

#### Patří sem

- textové exporty chatů,
- PDF exporty,
- HTML exporty,
- související obrázky a přílohy,
- měsíční členění zdrojů.

#### Nepatří sem

- schválené denní zápisy,
- NAVÁZÁNÍ,
- Project Snapshoty,
- aktivní technická dokumentace.

#### Zpracování

Obsah `17_CHAT` se nepovažuje za kanonickou dokumentaci.

Používá se jako zdroj pro:

- denní zápis,
- NAVÁZÁNÍ,
- historickou rekonstrukci,
- Project Snapshot,
- rozhodovací záznam.

#### Identifikační pravidlo

Prefix pro oblast `17_CHAT` dosud není v MM-STD-007 definován.

Do vyřešení standardu se v této složce nemají vytvářet nové řízené Document ID pouze podle odhadu.

---

### 10.19 `99_ARCHIVE`

#### Poslání

Uchovává historické, nahrazené a neaktivní soubory.

#### Patří sem

- předchozí aktivní verze při významných milnících,
- zrušené dokumenty,
- superseded návrhy,
- staré skripty a balíčky vztahující se k dokumentaci,
- historické kopie přesunuté z aktivních složek.

#### Nepatří sem

- aktuální aktivní verze,
- jediná kopie potřebného dokumentu,
- pracovní draft čekající na schválení.

#### Povinné pravidlo

Archivní soubor nesmí být automaticky považován za aktuální zdroj pravdy.

#### Základní dokument

`MM-ARCV-1000_INDEX_A_PRAVIDLA_ARCHIVU_DOKUMENTACE.md`

---

### Závěr kapitoly

Kapitola vymezila odpovědnost všech dokumentačních oblastí od `00_DOCUMENTATION` po `99_ARCHIVE`, včetně návrhu oblasti `16_DECISIONS`. Jejím přínosem je praktické pravidlo, podle kterého lze každý nový soubor zařadit do správné složky a zabránit vzniku paralelních zdrojů pravdy. Následující kapitola převádí toto tematické členění do pravidel životního cyklu dokumentů.

---

## 11. Klasifikace dokumentů podle životního cyklu

| Stav obsahu | Cílové umístění |
|---|---|
| Aktivní schválený dokument | tematická složka `00` až `13` |
| Pracovní návrh | `15_DRAFT` |
| Odvozený export | `14_EXPORT` |
| Surový chatový důkaz | `17_CHAT` |
| Nahrazená nebo zrušená verze | `99_ARCHIVE` |
| Denní chronologický záznam | `09_HISTORY/DENNÍ_ZÁPISY` |
| Přenos kontextu | `09_HISTORY/NAVÁZÁNÍ_NA_CHAT` |
| Měsíční nebo milníkový checkpoint | `09_HISTORY/PROJECT_SNAPSHOTS` |
| Slovník nebo referenční rejstřík | `10_REFERENCE` |
| Závazné pravidlo | `12_STANDARD` |
| Opakovaně použitelná šablona | `13_TEMPLATES` |

---

### Závěr kapitoly

Kapitola přiřadila jednotlivé stavy obsahu k cílovému umístění: aktivní dokument, draft, export, chatový důkaz, historie a archiv. Jejím přínosem je jednotný pohyb dokumentu během jeho životního cyklu. Následující kapitola určuje konkrétní oblastní indexy, které mají vytvořit základ chybějících částí dokumentace.

---

## 12. Základní oblastní indexy k vytvoření

| Priorita | Cílová složka | Navržený dokument |
|---:|---|---|
| 1 | `04_DATABASE` | `MM-DB-1000_INDEX_DATABAZOVE_DOKUMENTACE_MATCHMATRIX.md` |
| 2 | `05_PROVIDERS` | `MM-PRV-1000_INDEX_PROVIDEROVE_DOKUMENTACE_MATCHMATRIX.md` |
| 3 | `06_LAYERS` | `MM-LAY-1000_INDEX_VRSTEV_PLATFORMY_MATCHMATRIX.md` |
| 4 | `07_OPERATOR` | `MM-OPS-1000_INDEX_OPERATOR_DOKUMENTACE_MATCHMATRIX.md` |
| 5 | `01_MASTER` | `MM-MST-1000_INDEX_MASTER_DOKUMENTACE_MATCHMATRIX.md` |
| 6 | `02_GOVERNANCE` | `MM-GOV-1000_INDEX_GOVERNANCE_DOKUMENTACE_MATCHMATRIX.md` |
| 7 | `03_ARCHITECTURE` | `MM-ARC-1000_INDEX_ARCHITEKTONICKE_DOKUMENTACE_MATCHMATRIX.md` |
| 8 | `08_DEVELOPMENT` | `MM-DEV-1000_INDEX_VYVOJOVE_DOKUMENTACE_MATCHMATRIX.md` |
| 9 | `09_HISTORY` | `MM-HIS-1000_INDEX_HISTORICKE_DOKUMENTACE_MATCHMATRIX.md` |
| 10 | `10_REFERENCE` | `MM-REF-1000_INDEX_REFERENCNI_DOKUMENTACE_MATCHMATRIX.md` |
| 11 | `11_VISUAL` | `MM-VIS-1000_INDEX_VIZUALNI_DOKUMENTACE_A_ASSETU.md` |
| 12 | `13_TEMPLATES` | `MM-TPL-1000_INDEX_SABLON_MATCHMATRIX.md` |
| 13 | `14_EXPORT` | `MM-EXP-1000_INDEX_A_PRAVIDLA_EXPORTU_DOKUMENTACE.md` |
| 14 | `15_DRAFT` | `MM-DRF-1000_INDEX_A_PRAVIDLA_PRACOVNICH_NAVRHU.md` |
| 15 | `99_ARCHIVE` | `MM-ARCV-1000_INDEX_A_PRAVIDLA_ARCHIVU_DOKUMENTACE.md` |

Standardy mají existující index `MM-STD-1000`, který se má aktualizovat, nikoli nahrazovat.

Pro `17_CHAT` se nejprve musí rozhodnout oficiální prefix a doplnit MM-STD-007.

---

### Závěr kapitoly

Kapitola stanovila pořadí a názvy základních oblastních indexů. Jejím přínosem je řízený plán budování dokumentace bez nahodilého zakládání souborů. Následující kapitola shrnuje strukturální problémy, které je nutné souběžně odstranit.

---

## 13. Zjištěné strukturální problémy

### 13.1 Duplicitní identita MM-REF-001

Audit eviduje:

- aktivní `MM-REF-001_SLOVNIK_CIZICH_POJMU_MATCHMATRIX.md` v `10_REFERENCE`,
- další soubor s identitou `MM-REF-001` ve `09_HISTORY/SLOVNÍK POJMŮ`.

To představuje riziko dvou aktivních souborů se stejným Document ID.

#### Požadované řešení

- potvrdit canonical MM-REF-001 v `10_REFERENCE`,
- historickou kopii ve `09_HISTORY` přesunout do odpovídající archivní složky,
- zabránit jejímu načítání jako aktivního dokumentu.

### 13.2 Neaktuální index standardů

`MM-STD-1000` uvádí pouze standardy `001` až `005`, zatímco aktivní složka obsahuje také `006` až `009`.

Index musí být aktualizován.

### 13.3 Chybějící oblast rozhodnutí

Aktivní strom neobsahuje `16_DECISIONS`, přestože projekt používá architektonická rozhodnutí a checkpointy na tuto oblast odkazují.

Je nutné rozhodnout, zda:

- vytvořit samostatnou oblast,
- nebo ponechat rozhodnutí v `09_HISTORY` a upravit dokumentační mapu.

### 13.4 `17_CHAT` není součástí MM-STD-007

Složka existuje a obsahuje zdrojová data, ale standard pro ni neurčuje prefix ani pravidla.

Je nutná aktualizace MM-STD-007.

### 13.5 Vizuální složka obsahuje neřízené duplicity

`11_VISUAL` obsahuje více podobných log, ZIP balíčků a souborů s nejednotnými názvy.

Musí vzniknout:

- asset registry,
- rozlišení ACTIVE / CANDIDATE / ARCHIVE,
- vazba na MM-STD-005,
- jednotné názvy schválených assetů.

### 13.6 Kořenové registry nejsou zařazeny do jasné odpovědnosti

Soubory `MATCHMATRIX_DOCUMENTATION_TOOL_REGISTRY_20260706.*` jsou v kořeni `docs`.

Je třeba rozhodnout, zda:

- zůstanou globálními generovanými registry v kořeni,
- nebo budou přesunuty pod `00_DOCUMENTATION`.

---

### Závěr kapitoly

Kapitola identifikovala konkrétní problémy aktivního stromu: duplicitní identitu `MM-REF-001`, neúplný index standardů, chybějící pravidla pro `17_CHAT`, nerozhodnutou oblast rozhodnutí, neřízené vizuální duplicity a nejasnou odpovědnost kořenových registrů. Jejím přínosem je kontrolovaný seznam nápravných úkolů. Následující kapitola stanovuje pravidla, která mají zabránit opakování těchto problémů při tvorbě nových dokumentů.

---

## 14. Pravidla pro vznik nového dokumentu

Před vytvořením nového dokumentu musí být určeno:

1. účel dokumentu,
2. tematická složka,
3. Document ID,
4. vztah k existujícím dokumentům,
5. zda informace již nemá referenční místo,
6. typ dokumentu,
7. vlastník,
8. stav,
9. plán dalšího rozvoje.

Nový dokument nesmí vzniknout pouze proto, že existuje prázdná složka.

Musí řešit konkrétní dlouhodobou potřebu projektu.

---

### Závěr kapitoly

Kapitola určila povinné otázky před založením nového dokumentu: účel, oblast, identitu, vztahy, vlastníka, stav a další vývoj. Jejím přínosem je omezení duplicitních a bezúčelných dokumentů. Následující kapitola převádí tato pravidla do konkrétního schvalovacího a publikačního workflow.

---

## 15. Doporučený pracovní postup

Každý nový základní oblastní dokument má projít tímto řetězcem:

```text
návrh obsahu
→ kontrola Document ID
→ uložení do 15_DRAFT nebo přímý řízený vstup
→ A17 audit
→ případná A18/A19/A20 standardizace
→ uživatelské schválení
→ kanonické uložení
→ Git commit a push
→ A24 VALIDATE_ONLY
→ A24 APPLY
→ A6/A7 ověření
→ aktualizace MM-DOC-1000
```

---

### Závěr kapitoly

Kapitola definovala řízený postup od návrhu přes audit a schválení až po Git, databázový import a integritní kontrolu. Jejím přínosem je reprodukovatelný proces pro všechny budoucí oblastní dokumenty. Následující kapitola stanovuje, jak má tuto mapu používat umělá inteligence při další práci.

---

## 16. AI CONTEXT

Tento dokument je centrální navigační mapa dokumentačních oblastí.

AI musí při tvorbě nového dokumentu nejprve určit:

- cílovou složku,
- odpovědnost oblasti,
- existující referenční dokument,
- možnou duplicitu,
- správný prefix,
- potřebu řízeného indexu.

AI nesmí automaticky ukládat:

- technický dokument do historie,
- slovník do historie,
- pracovní návrh mezi aktivní dokumenty,
- export jako zdroj pravdy,
- chat jako kanonickou dokumentaci.

---

### Závěr kapitoly

Kapitola stanovila interpretační pravidla pro AI a zakázala automatické zaměňování historie, draftu, exportu, chatu a aktivní dokumentace. Jejím přínosem je konzistentní rozhodování při tvorbě a zařazování dokumentů. Následující kapitola shrnuje stav dokumentačního systému v okamžiku vzniku této mapy.

---

## 17. STAV DOKUMENTAČNÍHO SYSTÉMU K 2026-07-13

| Oblast | Stav k 2026-07-13 |
|---|---|
| Dokumentační framework | EXISTUJE |
| Dokumentační workflow | IMPLEMENTOVÁNO A OVĚŘENO |
| Historické snapshoty únor–červen | DOKONČENY |
| Dokumentační databáze | AKTIVNÍ |
| Oblastní indexy | VĚTŠINOU CHYBÍ |
| Database dokumentace | PRÁZDNÝ ZÁKLAD |
| Provider dokumentace | PRÁZDNÝ ZÁKLAD |
| Layer dokumentace | PRÁZDNÝ ZÁKLAD |
| Operator dokumentace | PRÁZDNÝ ZÁKLAD |
| Referenční vrstva | EXISTUJE, NUTNÁ KONTROLA DUPLICITY |
| Standardy | EXISTUJÍ, INDEX JE NEÚPLNÝ |
| Visual assets | EXISTUJÍ, CHYBÍ REGISTR |
| Export pravidla | CHYBÍ |
| Draft pravidla | CHYBÍ |
| Chat pravidla | CHYBÍ VE STANDARDU |
| Rozhodovací oblast | DOSUD NEROZHODNUTA |

---

### Závěr kapitoly

Kapitola zachytila stav dokumentačního systému k 13. červenci 2026 a oddělila existující funkční části od dosud chybějících základů. Jejím přínosem je časově ukotvený kontrolní bod pro budoucí revize mapy. Následující kapitola převádí tento obraz do bezprostředního pracovního stavu.

---

## 18. CURRENT STATUS

```text
CURRENT STEP:
SCHVÁLENÍ MAPY DOKUMENTAČNÍCH OBLASTÍ

CURRENT RESULT:
FYZICKÁ STRUKTURA DOCS BYLA ZMAPOVÁNA

CURRENT BLOCKERS:
DUPLICITNÍ MM-REF-001
NEAKTUÁLNÍ MM-STD-1000
CHYBĚJÍCÍ PRAVIDLO PRO 17_CHAT
NEROZHODNUTÁ OBLAST 16_DECISIONS

NEXT ACTION:
PROVÉST A17 AUDIT MM-DOC-001
```

---

### Závěr kapitoly

Kapitola jednoznačně určila aktuální krok, dosažený výsledek, známé blokátory a další akci. Jejím přínosem je přímá použitelnost dokumentu v řízeném workflow. Následující kapitola uvádí rozhodnutí, která ještě musí být učiněna.

---

## 19. OPEN QUESTIONS

- Má vzniknout samostatná oblast `16_DECISIONS`?
- Jaký prefix bude závazný pro `17_CHAT`?
- Mají globální registry zůstat v kořeni `docs`?
- Který soubor ve `09_HISTORY/SLOVNÍK POJMŮ` má být archivován?
- Má být `MM-DOC-1000` aktualizován ručně, nebo automaticky z dokumentační databáze?
- Budou oblastní indexy importovány jako samostatné řízené dokumenty?
- Má každá oblastní mapa obsahovat také automaticky generovaný seznam dokumentů?

---

### Závěr kapitoly

Kapitola soustředila otevřené otázky týkající se oblasti rozhodnutí, prefixu pro chaty, umístění registrů, archivace duplicit a automatizace indexů. Jejím přínosem je jasné oddělení schválených pravidel od dosud nerozhodnutých bodů. Následující kapitola stanovuje první konkrétní pokračovací krok.

---

## 20. NEXT STEP

Spustit A17 audit dokumentu:

```text
MM-DOC-001_MAPA_DOKUMENTACNICH_OBLASTI_MATCHMATRIX.md
```

Po jeho schválení vznikne jako první oblastní základ:

```text
MM-DB-1000_INDEX_DATABAZOVE_DOKUMENTACE_MATCHMATRIX.md
```

Databázová oblast má nejvyšší prioritu, protože představuje technický základ celé platformy a je v aktivním stromu dosud prázdná.

---

### Závěr kapitoly

Kapitola určila jediný bezprostřední krok: dokončit audit a schválení `MM-DOC-001`, poté založit databázový oblastní index. Jejím přínosem je jednoznačná návaznost bez paralelního rozpracování více oblastí. Následuje celkový závěr dokumentu.

---

## 21. Závěr

Dokumentační strom MatchMatrix již obsahuje silnou historickou, standardizační a základní technickou vrstvu. Chybí mu však jednotné oblastní rozcestníky a několik zásadních tematických základů.

Tento dokument stanovuje:

- odpovědnost každé složky,
- hranice mezi aktivní dokumentací, historií, drafty, exporty a chaty,
- pravidla pro zakládání nových dokumentů,
- seznam prvních oblastních indexů,
- strukturální problémy vyžadující opravu,
- pořadí dalšího rozvoje.

Po schválení bude sloužit jako centrální zdroj pravdy pro organizaci celé dokumentace MatchMatrix.

---

### Historie verzí

| Verze | Datum | Stav | Popis |
|---|---:|---|---|
| 0.9 | 2026-07-13 | REVIEW | První kompletní mapa; doplněna identifikace návazností, ověřené zdroje, dokončené práce, rizika a databázový snapshot; opravena hierarchie nadpisů a významově zpřesněny závěry hlavních kapitol |

---

*Konec dokumentu MM-DOC-001.*
