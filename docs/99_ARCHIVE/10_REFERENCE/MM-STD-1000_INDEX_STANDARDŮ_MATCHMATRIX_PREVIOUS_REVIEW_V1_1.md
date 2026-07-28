# MM-STD-1000

# INDEX STANDARDŮ MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-STD-1000 |
| Název | Index standardů MatchMatrix |
| Edice | MM-STD |
| Verze | 1.1 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Aktivní soubor | `docs/10_REFERENCE/MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md` |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
| 1.0 | 2026 | ACTIVE | První vydání indexu se standardy MM-STD-001 až MM-STD-005. |
| 1.1 | 2026-07-27 | REVIEW | Doplněny standardy MM-STD-006 až MM-STD-009, aktuální verze, stavy, aktivní soubory, odpovědnosti, vzájemné vazby a pravidla správy indexu. |

---

## Účel dokumentu

Tento dokument představuje centrální registr standardů dokumentačního systému MatchMatrix.

Slouží jako:

- jediný referenční přehled existujících standardů,
- orientační mapa jejich odpovědností,
- registr aktuálních verzí a stavů,
- kontrolní bod pro nové standardy,
- podklad pro dokumentační audit,
- zdroj pro Documentation Management System a AI Context.

Index neurčuje vlastní obsah jednotlivých standardů. Eviduje jejich identitu, účel, stav, vztahy a kanonické umístění.

---

## Rozsah

Index eviduje všechny dokumenty typu `MM-STD`.

Zahrnuje:

- základní dokumentační standardy `MM-STD-001` až `MM-STD-009`,
- centrální index `MM-STD-1000`,
- budoucí standardy po jejich schváleném přidělení.

Nový standard se nesmí považovat za plně zavedený, dokud není zapsán v tomto indexu.

---

# 1. Základní pravidla indexu

## 1.1 Jedna identita standardu

Každý standard má jeden stabilní Document ID.

Příklad:

```text
MM-STD-003
```

Nová verze používá stejné Document ID.

## 1.2 Jeden aktivní soubor

Každý standard má jeden aktivní zdrojový soubor se stabilním názvem bez čísla verze.

Číslo verze a stav jsou uvedeny uvnitř dokumentu a v tomto indexu.

## 1.3 Index eviduje skutečný stav

Tabulka standardů musí odpovídat:

- aktivním souborům v repozitáři,
- metadatům uvnitř dokumentů,
- dokumentační databázi,
- nejnovějšímu schválenému rozhodnutí.

## 1.4 Stav REVIEW

Stav `REVIEW` znamená, že jde o novější opravenou nebo doplněnou verzi čekající na kontrolu nebo schválení.

REVIEW standard může být obsahově novější než předchozí ACTIVE verze.

## 1.5 Stav ACTIVE

Stav `ACTIVE` znamená platný referenční standard pro běžné používání.

## 1.6 Nezapsaný standard

Soubor s prefixem `MM-STD`, který není evidován v tomto indexu, musí být před použitím prověřen.

---

# 2. Přehled standardů

| Dokument | Název | Aktuální verze | Stav | Hlavní odpovědnost |
|---|---|---:|---|---|
| `MM-STD-001` | Standard tvorby hlavních dokumentů | 1.0 | ACTIVE | Minimální struktura a obsah hlavních řízených dokumentů. |
| `MM-STD-002` | Standard tvorby rozsáhlých dokumentů | 1.0 | ACTIVE | Pravidla pro rozsáhlé dokumenty, kapitoly, návaznost a čitelnost. |
| `MM-STD-003` | Standard životního cyklu dokumentace a verzování | 1.2 | REVIEW | Identity dokumentu v čase, stavy, verze, REVIEW workflow, aktivní soubor a archivace. |
| `MM-STD-004` | Standard názvosloví a struktury dokumentace | 1.1 | REVIEW | Názvy aktivních souborů, metadata, složky, struktura a formáty. |
| `MM-STD-005` | Standard vizuální identity dokumentace | 1.0 | ACTIVE | Vizuální pravidla dokumentů a odvozených výstupů. |
| `MM-STD-006` | Standard terminologie a slovníku pojmů | 1.0 | ACTIVE | Jazyk, používání termínů a vazba na MM-REF-001. |
| `MM-STD-007` | Identifikace a číslování dokumentů MatchMatrix | 1.1 | REVIEW | Document ID, registry prefixů, číselné bloky, aliasy a kolize. |
| `MM-STD-008` | Správa terminologie a referenčního slovníku | 1.0 | REVIEW | Životní cyklus termínů a řízená aktualizace MM-REF-001. |
| `MM-STD-009` | AI Context a Project Snapshot | 1.0 | REVIEW | Povinné kontextové sekce pro předávání stavu lidem a AI. |
| `MM-STD-1000` | Index standardů MatchMatrix | 1.1 | REVIEW | Centrální registr standardů, jejich verzí, stavů a vztahů. |

---

# 3. Kanonické aktivní soubory

| Dokument | Aktivní soubor |
|---|---|
| `MM-STD-001` | `docs/12_STANDARD/MM-STD-001_STANDARD_TVORBY_HLAVNÍCH_DOKUMENTŮ.md` |
| `MM-STD-002` | `docs/12_STANDARD/MM-STD-002_STANDARD_TVORBY_ROZSÁHLÝCH_DOKUMENTŮ.md` |
| `MM-STD-003` | `docs/12_STANDARD/MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md` |
| `MM-STD-004` | `docs/12_STANDARD/MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md` |
| `MM-STD-005` | `docs/12_STANDARD/MM-STD-005_STANDARD_VIZUÁLNÍ_IDENTITY_DOKUMENTACE.md` |
| `MM-STD-006` | `docs/12_STANDARD/MM-STD-006_STANDARD_TERMINOLOGIE_A_SLOVNIKU_POJMU.md` |
| `MM-STD-007` | `docs/12_STANDARD/MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md` |
| `MM-STD-008` | `docs/12_STANDARD/MM-STD-008_SPRAVA_TERMINOLOGIE_A_REFERENCNIHO_SLOVNIKU.md` |
| `MM-STD-009` | `docs/12_STANDARD/MM-STD-009_AI_CONTEXT_A_PROJECT_SNAPSHOT.md` |
| `MM-STD-1000` | `docs/10_REFERENCE/MM-STD-1000_INDEX_STANDARDŮ_MATCHMATRIX.md` |

---

# 4. Odpovědnosti standardů

## 4.1 MM-STD-001 – Hlavní dokumenty

Určuje základní požadavky na hlavní řízený dokument.

Řeší zejména:

- účel,
- metadata,
- obsah,
- kapitoly,
- závěr,
- vazby,
- historii verzí.

Neřeší podrobně číslování, aktivní názvy ani životní cyklus.

## 4.2 MM-STD-002 – Rozsáhlé dokumenty

Určuje pravidla pro dokumenty, jejichž rozsah vyžaduje:

- strukturované kapitoly,
- přehledný obsah,
- dílčí závěry,
- návaznosti mezi částmi,
- kontrolu duplicity textu,
- dlouhodobou čitelnost.

## 4.3 MM-STD-003 – Životní cyklus a verzování

Je nadřazeným standardem pro:

- vznik dokumentu,
- stavy,
- čísla verzí,
- REVIEW workflow,
- jediný aktivní soubor,
- převod REVIEW verze pod stabilní název,
- řízenou archivaci,
- Git a dokumentační databázovou publikaci.

Při konfliktu o aktivní verzi, stav nebo archivaci má přednost nejnovější platná verze `MM-STD-003`.

## 4.4 MM-STD-004 – Názvosloví a struktura

Určuje:

- formát názvu aktivního souboru,
- popisnou část názvu,
- metadata,
- strukturu kapitol,
- kanonické cesty,
- archivní a exportní názvy,
- jazykové a technické názvosloví.

Aktivní soubor neobsahuje číslo verze.

## 4.5 MM-STD-005 – Vizuální identita

Určuje:

- vizuální styl dokumentace,
- typografii,
- tabulky,
- zvýraznění,
- barvy,
- práci s odvozenými DOCX, PDF nebo HTML výstupy.

Nesmí měnit identitu, verzi nebo stav dokumentu.

## 4.6 MM-STD-006 – Terminologie

Určuje:

- primární jazyk dokumentace,
- používání technických identifikátorů,
- vysvětlení odborných pojmů,
- vazbu na `MM-REF-001`,
- základní terminologickou konzistenci.

## 4.7 MM-STD-007 – Identifikace a číslování

Určuje:

- Document ID,
- prefixy,
- číselné rozsahy,
- časové identity,
- historické aliasy,
- ochranu před kolizemi,
- pravidla přidělení nového ID.

Složka neurčuje prefix.

## 4.8 MM-STD-008 – Správa terminologie

Určuje procesní životní cyklus termínu:

```text
vznik
→ návrh
→ review
→ schválení
→ zápis do MM-REF-001
→ aktivní používání
→ archivace nebo DEPRECATED
```

Doplňuje `MM-STD-006`.

## 4.9 MM-STD-009 – AI Context a Project Snapshot

Určuje kontextové sekce:

- AI CONTEXT,
- PROJECT SNAPSHOT,
- DATABASE SNAPSHOT,
- CURRENT STATUS,
- OPEN QUESTIONS,
- NEXT STEP.

Jeho cílem je zabránit ztrátě kontextu při pokračování práce člověkem nebo AI.

## 4.10 MM-STD-1000 – Index standardů

Eviduje:

- všechny standardy,
- jejich verze,
- stavy,
- aktivní soubory,
- odpovědnosti,
- vzájemné vztahy,
- budoucí standardy.

---

# 5. Hierarchie a řešení konfliktů

Standardy nemají obecnou absolutní hierarchii pro všechny otázky.

Přednost se určuje podle odpovědnosti.

## 5.1 Životní cyklus, stav a verze

Rozhodující:

```text
MM-STD-003
```

## 5.2 Název souboru, metadata a struktura

Rozhodující:

```text
MM-STD-004
```

s podmínkou souladu s `MM-STD-003`.

## 5.3 Document ID a číslování

Rozhodující:

```text
MM-STD-007
```

## 5.4 Terminologie

Rozhodující:

```text
MM-STD-006
MM-STD-008
MM-REF-001
```

## 5.5 AI kontextové sekce

Rozhodující:

```text
MM-STD-009
```

## 5.6 Vizuální úprava

Rozhodující:

```text
MM-STD-005
```

## 5.7 Rozpor mezi dvěma standardy

Při zjištění rozporu se postupuje takto:

1. určí se věcná oblast,
2. zjistí se standard odpovědný za danou oblast,
3. porovnají se verze a data,
4. upřednostní se novější ověřené pravidlo odpovědného standardu,
5. rozpor se opraví také v druhém standardu,
6. změna se zapíše do historie verzí,
7. aktualizuje se tento index.

Rozpor se nesmí řešit tichým ignorováním jednoho dokumentu.

---

# 6. Vztahy mezi standardy

```text
MM-STD-001 ─┐
             ├─ struktura hlavních a rozsáhlých dokumentů
MM-STD-002 ─┘

MM-STD-003 ─ životní cyklus, verze, stavy, archiv
      │
      ├─ MM-STD-004 ─ názvy, metadata, soubory, složky
      └─ MM-STD-007 ─ identity, číslování, aliasy

MM-STD-006 ─ základní terminologie
      │
      └─ MM-STD-008 ─ procesní správa slovníku

MM-STD-009 ─ AI Context a Project Snapshot

MM-STD-005 ─ vizuální identita

MM-STD-1000 ─ centrální registr všech standardů
```

---

# 7. Aktuální stav standardizace

## 7.1 Aktualizované standardy

K 2026-07-27 byly podle ověřeného dokumentačního workflow aktualizovány:

- `MM-STD-003` na verzi 1.2,
- `MM-STD-004` na verzi 1.1,
- `MM-STD-007` na verzi 1.1,
- `MM-STD-1000` na verzi 1.1.

## 7.2 Standardy připravené k budoucímu rozšíření

Další podrobnou revizi vyžadují zejména:

- `MM-STD-001`,
- `MM-STD-002`,
- `MM-STD-005`,
- `MM-STD-006`,
- `MM-STD-008`,
- `MM-STD-009`.

To neznamená, že jsou neplatné.

Znamená to, že jejich současný rozsah je stručší a má být později porovnán s novými hlavními dokumenty, skutečným Q3 workflow a dokumentační databází.

## 7.3 Související otevřený konflikt

`MM-REF-001` existuje ve více aktivně vypadajících variantách.

Tento konflikt je nutné vyřešit podle:

- `MM-STD-003`,
- `MM-STD-004`,
- `MM-STD-006`,
- `MM-STD-007`,
- `MM-STD-008`.

---

# 8. Přidání nového standardu

Nový standard může být vytvořen pouze tehdy, když:

- řeší samostatnou a dlouhodobou oblast,
- stejnou odpovědnost nepokrývá existující standard,
- obdrží volné Document ID podle `MM-STD-007`,
- má jasně určený rozsah,
- neobsahuje pravidla v rozporu s existujícími standardy,
- je přidán do tohoto indexu,
- projde dokumentačním workflow.

## 8.1 Přidělení čísla

Před přidělením se kontroluje:

- tento index,
- aktivní složka,
- Git historie,
- `docs/99_ARCHIVE`,
- dokumentační databáze,
- historické aliasy.

## 8.2 Aktualizace indexu

Při vzniku nového standardu se v tomto dokumentu doplní:

- Document ID,
- název,
- verze,
- stav,
- účel,
- aktivní soubor,
- vztahy,
- historie změny.

---

# 9. Změna verze standardu

Při změně standardu se:

1. zachová Document ID,
2. zachová stabilní aktivní název,
3. zvýší verze uvnitř dokumentu,
4. doplní historie verzí,
5. podle významu se archivuje předchozí milník,
6. aktualizuje se tento index,
7. aktualizují se související standardy, pokud vznikl rozpor,
8. provede se audit a publikace.

---

# 10. Kontrola indexu

Index je správný, pokud:

- [ ] obsahuje všechny aktivní standardy,
- [ ] neobsahuje neexistující standard jako aktivní,
- [ ] verze odpovídají metadatům dokumentů,
- [ ] stavy odpovídají metadatům dokumentů,
- [ ] cesty odpovídají skutečným aktivním souborům,
- [ ] žádné Document ID není uvedeno dvakrát pro různé dokumenty,
- [ ] všechny nové standardy mají popsanou odpovědnost,
- [ ] konflikty mezi standardy jsou zaznamenány a opraveny,
- [ ] historické verze nejsou zaměněny za aktivní,
- [ ] index je aktualizován při každé významné změně standardu.

---

# 11. Dokumentační databáze

`MM-STD-1000` má být importován do dokumentační databáze jako centrální registr standardů.

Databázová reprezentace má umožnit:

- vyhledat standard podle Document ID,
- zjistit aktuální verzi,
- zjistit stav,
- zjistit aktivní cestu,
- zjistit vztahy,
- zjistit historii,
- kontrolovat neindexované standardy.

Import se řídí Q3 workflow a používá zejména:

- A17,
- A18,
- A19,
- A20,
- A24,
- A6,
- A7.

Úspěšný `VALIDATE_ONLY` není trvalý import.

---

# 12. Závěr

Dokumentační standardy MatchMatrix tvoří vzájemně propojený systém.

Každý standard musí mít:

- jasnou odpovědnost,
- stabilní Document ID,
- jeden aktivní soubor,
- aktuální verzi a stav,
- zřejmé vazby na ostatní standardy,
- záznam v tomto indexu.

`MM-STD-1000` je centrálním rozcestníkem tohoto systému a musí být aktualizován při každé významné změně sady standardů.

---

# AI CONTEXT

**Role dokumentu:** Centrální registr standardů MatchMatrix.

**Aktuální sada:** MM-STD-001 až MM-STD-009 a MM-STD-1000.

**Životní cyklus:** MM-STD-003.

**Názvy a struktura:** MM-STD-004.

**Identity a číslování:** MM-STD-007.

**Terminologie:** MM-STD-006 a MM-STD-008.

**AI Context:** MM-STD-009.

**Vizuální identita:** MM-STD-005.

**Kritické pravidlo:** Verze v indexu musí odpovídat verzi uvnitř aktivního standardu.

---

# PROJECT SNAPSHOT

- Hlavní dokumenty MM-DOC byly sjednoceny pod stabilními názvy.
- MM-STD-003 byl aktualizován na verzi 1.2.
- MM-STD-004 byl aktualizován na verzi 1.1.
- MM-STD-007 byl aktualizován na verzi 1.1.
- Index nyní eviduje MM-STD-001 až MM-STD-009.
- Standardy 006–009 již nejsou mimo centrální evidenci.
- Otevřeným navazujícím úkolem je sjednocení aktivní verze MM-REF-001.

---

# CURRENT STATUS

- Standards Registry: UPDATED
- MM-STD-001 to MM-STD-009: INDEXED
- Version Tracking: ACTIVE
- Status Tracking: ACTIVE
- Canonical File Tracking: ACTIVE
- Automated Index Validation: PARTIAL
- Documentation Database Synchronization: PENDING FOR NEW VERSIONS

---

# OPEN QUESTIONS

- podrobná revize MM-STD-001 a MM-STD-002,
- rozšíření MM-STD-005 podle současné vizuální identity panelů a dokumentů,
- sjednocení MM-STD-006 a MM-STD-008 bez překryvu odpovědností,
- rozšíření MM-STD-009 podle skutečného Q3 a NAV workflow,
- automatické porovnání indexu s repozitářem a dokumentační databází,
- sjednocení více aktivně vypadajících variant MM-REF-001.

---

# NEXT STEP

Uložit tuto aktualizovanou verzi pod stabilním aktivním názvem a následně vyřešit jedinou aktivní verzi `MM-REF-001`.
