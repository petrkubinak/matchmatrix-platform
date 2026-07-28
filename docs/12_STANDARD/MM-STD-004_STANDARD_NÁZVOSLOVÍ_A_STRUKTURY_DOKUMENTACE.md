# MM-STD-004

# STANDARD NÁZVOSLOVÍ A STRUKTURY DOKUMENTACE

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-STD-004 |
| Název | Standard názvosloví a struktury dokumentace |
| Edice | MM-STD |
| Verze | 1.1 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Aktivní soubor | `docs/12_STANDARD/MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md` |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
| 1.0 | 2026 | ACTIVE | První vydání standardu. Aktivní název souboru obsahoval číslo verze. |
| 1.1 | 2026-07-27 | REVIEW | Odstraněno číslo verze z aktivního názvu, sjednoceny typy dokumentů, metadata, názvy, struktura, cesty a vazba na MM-STD-003 a MM-STD-007. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |

---

## Úvod a účel dokumentu
Tento standard stanovuje jednotná pravidla pro:

- názvosloví dokumentů,
- popisnou část názvu souboru,
- strukturu aktivních souborů,
- základní metadata,
- názvy kapitol a sekcí,
- kanonické umístění dokumentů,
- odkazy mezi dokumenty,
- pojmenování archivních a exportních souborů,
- rozlišení Document ID, typu dokumentu, edice, verze a stavu.

Identitu a číslování dokumentů upravuje podrobněji `MM-STD-007`.

Životní cyklus, aktivní verzi a archivaci upravuje `MM-STD-003`.

---

## Rozsah

Standard je závazný pro všechny řízené dokumenty projektu MatchMatrix, zejména:

- `MM-DOC`,
- `MM-STD`,
- `MM-REF`,
- `MM-PRV`,
- `MM-TPL`,
- `MM-DL`,
- `MM-NAV`,
- `MM-EXP`,
- další schválené typy evidované v dokumentačním indexu.

---

# 1. Základní pojmy

## 1.1 Document ID

Document ID je jedinečný identifikátor řízeného dokumentu.

Příklad:

```text
MM-DOC-300
```

Document ID:

- určuje identitu dokumentu,
- je stabilní po celý životní cyklus,
- nemění se při nové verzi,
- nemění se při změně stavu,
- nemění se při přesunu do jiné složky,
- nemění se při změně popisného názvu,
- nesmí být znovu použit pro jiný dokument.

## 1.2 Typ dokumentu

Typ dokumentu vyjadřuje funkci dokumentu v dokumentačním systému.

Příklady:

```text
MM-DOC
MM-STD
MM-REF
MM-PRV
MM-TPL
MM-DL
MM-NAV
MM-EXP
```

Typ dokumentu není totéž co edice.

## 1.3 Edice

Edice vyjadřuje způsob zpracování nebo cílovou úroveň obsahu.

Používané edice mohou zahrnovat zejména:

- TECH,
- BOOK,
- GLOBAL.

TECH popisuje ověřený současný technický nebo provozní stav.

BOOK vysvětluje vývoj, důvody, souvislosti, zkušenosti a dlouhodobý význam.

GLOBAL sjednocuje obsah pro širší nebo nadřazené použití.

Edice se uvádí v metadatech nebo názvu dokumentu pouze tehdy, pokud je pro daný typ relevantní.

## 1.4 Verze

Verze označuje obsahový stav dokumentu.

Příklad:

```text
1.2
```

Verze patří:

- do metadat dokumentu,
- do historie verzí,
- do dokumentační databáze,
- případně do názvu archivní nebo exportní kopie.

Verze nepatří do názvu aktivního řízeného souboru.

## 1.5 Stav

Stav vyjadřuje životní fázi dokumentu.

Příklady:

```text
DRAFT
REVIEW
APPROVED
ACTIVE
ARCHIVED
SUPERSEDED
WITHDRAWN
```

Stav patří do metadat dokumentu.

Stav se standardně nepřidává do stabilního aktivního názvu souboru.

## 1.6 Aktivní soubor

Aktivní soubor je jediný kanonický zdrojový soubor pro daný Document ID a edici.

Používá stabilní název bez čísla verze a bez dlouhodobé přípony `_REVIEW`.

## 1.7 Archivní soubor

Archivní soubor je historická kopie.

Může obsahovat:

- verzi,
- datum,
- stav,
- důvod archivace,
- označení `PREVIOUS`,
- označení `REVIEW`.

Archivní název nesmí být zaměnitelný s aktivním názvem.

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Základní pojmy“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Typy dokumentů“, která rozvíjí další část řízeného dokumentu.

# 2. Typy dokumentů

## 2.1 MM-DOC

`MM-DOC` označuje hlavní technickou, provozní, architektonickou nebo řídicí dokumentaci.

Příklady:

```text
MM-DOC-000
MM-DOC-100
MM-DOC-200
MM-DOC-300
MM-DOC-800
MM-DOC-900
```

## 2.2 MM-STD

`MM-STD` označuje závazný standard projektu.

Příklad:

```text
MM-STD-003
```

## 2.3 MM-REF

`MM-REF` označuje referenční dokument.

Příklady:

- slovník pojmů,
- výkladový rejstřík,
- referenční seznam,
- mapovací dokument.

## 2.4 MM-PRV

`MM-PRV` označuje providerovou, právní nebo licenční dokumentaci poskytovatelů dat.

## 2.5 MM-TPL

`MM-TPL` označuje oficiální šablonu.

Příklady:

```text
MM-TPL-001
MM-TPL-002
```

## 2.6 MM-DL

`MM-DL` označuje denní zápis.

Formát identity:

```text
MM-DL-YYYYMMDD
```

## 2.7 MM-NAV

`MM-NAV` označuje dokument NAVÁZÁNÍ do nového chatu nebo pracovní etapy.

Formát identity:

```text
MM-NAV-YYYYMMDD-NN
```

## 2.8 MM-EXP

`MM-EXP` označuje řízený exportní artefakt.

Formát identity může obsahovat datum a pořadí:

```text
MM-EXP-YYYYMMDD-NN
```

## 2.9 Nový typ dokumentu

Nový prefix lze zavést pouze:

1. změnou příslušného standardu,
2. doplněním `MM-STD-007`,
3. doplněním dokumentačního indexu,
4. schválením jeho účelu a číselného modelu.

Prefix nesmí vzniknout pouze ad hoc názvem souboru.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Typy dokumentů“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Formát Document ID“, která rozvíjí další část řízeného dokumentu.

# 3. Formát Document ID

## 3.1 Standardní číselný dokument

Používá formát:

```text
MM-XXX-NNN
```

kde:

- `MM` označuje projekt MatchMatrix,
- `XXX` označuje typ dokumentu,
- `NNN` nebo jiný schválený číselný blok určuje jedinečné číslo.

Příklady:

```text
MM-STD-004
MM-DOC-300
MM-DOC-1000
```

## 3.2 Časově specifický dokument

Denní a navazovací dokumenty používají datum.

Příklady:

```text
MM-DL-20260727
MM-NAV-20260727-01
MM-EXP-20260727-01
```

## 3.3 Zápis Document ID

Document ID:

- používá velká písmena,
- používá spojovník `-`,
- neobsahuje mezery,
- neobsahuje diakritiku,
- zapisuje se vždy stejně,
- nesmí být zkrácen v oficiálních metadatech.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Formát Document ID“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Stabilní název aktivního souboru“, která rozvíjí další část řízeného dokumentu.

# 4. Stabilní název aktivního souboru

## 4.1 Obecný formát

Aktivní řízený soubor používá:

```text
<DOCUMENT_ID>_<POPISNÝ_NÁZEV>.<PŘÍPONA>
```

Příklady:

```text
MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md
MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md
MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX.md
```

## 4.2 Zakázané aktivní názvy

Aktivní řízený soubor standardně nesmí používat:

```text
..._V1.md
..._V1_1.md
..._v1.2.md
..._FINAL.md
..._NEW.md
..._LATEST.md
..._REVIEW.md
..._OPRAVENO.md
..._KOPIE.md
```

Takové názvy mohou vzniknout pouze jako dočasné pracovní varianty nebo archivní kopie.

Po dokončení workflow musí z aktivní složky zmizet.

## 4.3 Verze v názvu aktivního souboru

Číslo verze se do aktivního názvu nepřidává.

Správně:

```text
MM-DOC-100_MATCHMATRIX_MASTER_TECH.md
```

Nesprávně:

```text
MM-DOC-100_MATCHMATRIX_MASTER_TECH_V1_1.md
```

## 4.4 Stav v názvu aktivního souboru

Stav se do stabilního aktivního názvu standardně nepřidává.

Správně:

```text
MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH.md
```

Dočasně přípustný pracovní kandidát:

```text
MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH_REVIEW.md
```

Po přijetí REVIEW obsahu se aktivní soubor vrací pod stabilní název.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Stabilní název aktivního souboru“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Popisná část názvu souboru“, která rozvíjí další část řízeného dokumentu.

# 5. Popisná část názvu souboru

## 5.1 Účel

Popisná část má jednoznačně vyjadřovat obsah dokumentu.

Má být:

- stručná,
- srozumitelná,
- dlouhodobě použitelná,
- bez nadbytečných slov,
- bez stavových výrazů,
- bez čísla verze.

## 5.2 Oddělovače

Jednotlivé části se oddělují podtržítkem:

```text
_
```

Document ID uvnitř sebe používá spojovníky.

Příklad:

```text
MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md
```

## 5.3 Velká písmena

Aktivní řízené názvy souborů používají velká písmena v popisné části.

Přípona zůstává malými písmeny:

```text
.md
.docx
.pdf
.xlsx
.csv
.json
```

## 5.4 Mezery

Aktivní řízené názvy souborů nepoužívají mezery.

Výjimku mohou tvořit historické nebo externí vstupní soubory, které nejsou kanonickými aktivními dokumenty.

## 5.5 Diakritika

Document ID diakritiku nikdy nepoužívá.

V popisné části názvu je česká diakritika přípustná, pokud:

- odpovídá zavedenému názvu dokumentu,
- nebrání používaným nástrojům,
- je zachována konzistentně.

Existující stabilní názvy se nemají hromadně měnit pouze kvůli odstranění diakritiky.

U nových technických artefaktů, kde může docházet k problémům s interoperabilitou, lze použít popis bez diakritiky.

## 5.6 Speciální znaky

V aktivním názvu se standardně nepoužívají:

- lomítka,
- dvojtečky,
- otazníky,
- hvězdičky,
- uvozovky,
- závorky,
- čárky,
- středníky,
- symboly verze,
- jiné znaky problematické pro souborové systémy nebo skripty.

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Popisná část názvu souboru“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. Název dokumentu uvnitř souboru“, která rozvíjí další část řízeného dokumentu.

# 6. Název dokumentu uvnitř souboru

## 6.1 První řádek

První nadpis obsahuje Document ID:

```markdown
> # MM-DOC-300
```

## 6.2 Hlavní název

Následuje hlavní název dokumentu:

```markdown
> # MATCHMATRIX ARCHITECTURE
```

## 6.3 Edice

Pokud je relevantní, následuje edice:

```markdown
> ## TECH EDITION
```

## 6.4 Shoda názvu

Název uvnitř dokumentu musí významově odpovídat:

- popisné části názvu souboru,
- dokumentačnímu indexu,
- dokumentační databázi.

Nemusí být znak po znaku totožný, pokud soubor používá technický tvar bez mezer a dokument čitelný název.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. Název dokumentu uvnitř souboru“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „7. Povinná metadata“, která rozvíjí další část řízeného dokumentu.

# 7. Povinná metadata

## 7.1 Minimální metadata hlavního dokumentu

Každý hlavní řízený dokument má uvádět minimálně:

| Položka | Povinnost |
|---|---|
| Dokument | povinné |
| Název | povinné |
| Edice nebo typ | podle dokumentu |
| Verze | povinné |
| Stav | povinné |
| Datum aktualizace | povinné u nové verze |
| Autor projektu | povinné |
| Technická spolupráce | podle skutečnosti |
| Primární formát | povinné |
| Aktivní soubor | povinné |

## 7.2 Historické označení

Pokud dokument dříve používal jiné pracovní ID, lze uvést:

```text
Historické pracovní označení
```

Historické označení není druhým aktivním Document ID.

## 7.3 Kanonická cesta

Položka `Aktivní soubor` používá cestu relativní ke kořeni projektu.

Správně:

```text
docs/03_ARCHITECTURE/MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md
```

Nesprávně:

```text
C:\MatchMatrix-platform\docs\03_ARCHITECTURE\...
```

Absolutní lokální cesta nepatří do kanonických metadat řízeného dokumentu.

## 7.4 Datum

Datum používá formát:

```text
YYYY-MM-DD
```

Příklad:

```text
2026-07-27
```

---


## 7.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „7. Povinná metadata“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „8. Povinná základní struktura hlavního dokumentu“, která rozvíjí další část řízeného dokumentu.

# 8. Povinná základní struktura hlavního dokumentu

Podle typu a rozsahu se používají zejména tyto části:

1. Document ID a název,
2. informace o dokumentu,
3. historie verzí,
4. účel,
5. rozsah,
6. související dokumenty,
7. obsah,
8. vlastní kapitoly,
9. závěr,
10. AI CONTEXT,
11. PROJECT SNAPSHOT,
12. DATABASE SNAPSHOT podle relevance,
13. CURRENT STATUS,
14. OPEN QUESTIONS,
15. NEXT STEP.

Ne každý krátký dokument musí obsahovat rozsáhlý obsah nebo Database Snapshot.

Struktura se přizpůsobuje účelu, ale metadata, identita, verze a stav musí zůstat jednoznačné.

---


## 8.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „8. Povinná základní struktura hlavního dokumentu“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „9. Struktura kapitol“, která rozvíjí další část řízeného dokumentu.

# 9. Struktura kapitol

## 9.1 Hierarchie

Markdown používá logickou hierarchii:

```markdown

## 9.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „9. Struktura kapitol“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „10. Související dokumenty a odkazy“, která rozvíjí další část řízeného dokumentu.

# hlavní úroveň
## druhá úroveň
### třetí úroveň
```

Dokument nemá bez důvodu přeskakovat úrovně.

## 9.2 Číslování

Rozsáhlé dokumenty používají číslované hlavní kapitoly.

Příklad:

```text
1. Účel
2. Rozsah
3. Základní pravidla
```

Podkapitoly:

```text
3.1
3.2
3.3
```

## 9.3 Závěry kapitol

Rozsáhlý dokument může používat závěr jednotlivých částí, pokud shrnuje skutečný význam kapitoly.

Mechanické opakování posledního odstavce se nepovažuje za kvalitní závěr.

## 9.4 Odrážky

Odrážky se používají pro rovnocenné položky.

Nemají nahrazovat vysvětlující text v situaci, kdy je potřeba uvést důvod, souvislost nebo rozhodnutí.

---

# 10. Související dokumenty a odkazy

## 10.1 Odkaz pomocí Document ID

Odkazy mezi řízenými dokumenty vždy obsahují Document ID.

Příklad:

```text
MM-STD-003 – Standard životního cyklu dokumentace a verzování
```

## 10.2 Cesta

Cesta se přidává pouze tehdy, pokud je prakticky potřebná.

Document ID je stabilnější než cesta.

## 10.3 Historický alias

Historický alias lze uvést v historii nebo metadatech, ale nové odkazy používají pouze současný Document ID.

## 10.4 Neexistující budoucí dokument

Plánovaný dokument se označí jako budoucí nebo plánovaný.

Nesmí být vydáván za existující aktivní dokument.

---


## 10.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „10. Související dokumenty a odkazy“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „11. Kanonické složky“, která rozvíjí další část řízeného dokumentu.

# 11. Kanonické složky

Aktivní dokumenty jsou organizovány podle funkční oblasti projektu.

Příklady:

```text
docs/00_DOCUMENTATION/
docs/01_MASTER/
docs/02_GOVERNANCE/
docs/03_ARCHITECTURE/
docs/08_DEVELOPMENT/
docs/09_HISTORY/
docs/10_REFERENCE/
docs/12_STANDARD/
docs/13_TEMPLATES/
docs/14_EXPORT/
docs/99_ARCHIVE/
```

Přesná struktura je evidována v dokumentačním frameworku a indexu.

## 11.1 Aktivní složky

Aktivní složka obsahuje pouze aktuální řízené soubory a nezbytné provozní soubory dané oblasti.

## 11.2 Historická oblast

Historické dokumenty, denní zápisy a NAV mohou mít vlastní kanonickou historickou strukturu v `docs/09_HISTORY`.

## 11.3 Archiv

Nahrazené, předchozí nebo vyřazené kopie patří do:

```text
docs/99_ARCHIVE/
```

## 11.4 Export

Generované exportní artefakty patří do:

```text
docs/14_EXPORT/
```

Export není automaticky aktivním zdrojovým dokumentem.

---


## 11.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „11. Kanonické složky“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „12. Denní zápisy, NAV a exporty“, která rozvíjí další část řízeného dokumentu.

# 12. Denní zápisy, NAV a exporty

## 12.1 Denní zápis

Doporučený aktivní název:

```text
MM-DL-20260727_MATCHMATRIX_DENNI_ZAPIS.md
```

## 12.2 NAV dokument

Doporučený aktivní název:

```text
MM-NAV-20260727-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

## 12.3 Export

Příklad:

```text
MM-EXP-20260727-01_EXTRAKCNI_MATICE_HISTORIE_CHATU_V1.xlsx
```

U exportů je verze v názvu přípustná, protože export je konkrétní neměnný artefakt nebo datová dodávka, nikoli průběžně aktualizovaný aktivní Markdown dokument.

Toto pravidlo musí být zřejmé z typu `MM-EXP`.

---


## 12.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „12. Denní zápisy, NAV a exporty“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „13. Archivní názvosloví“, která rozvíjí další část řízeného dokumentu.

# 13. Archivní názvosloví

Archivní soubor může používat rozšířený název:

```text
<DOCUMENT_ID>_<NÁZEV>_PREVIOUS_V<VERZE>.<PŘÍPONA>
```

Příklad:

```text
MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_PREVIOUS_V0_9.md
```

Přípustná archivní označení:

- `PREVIOUS`,
- `ARCHIVED`,
- `SUPERSEDED`,
- `REVIEW`,
- datum archivačního milníku,
- původní verze.

Archivní označení nesmí být přeneseno zpět do aktivního názvu.

---


## 13.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „13. Archivní názvosloví“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „14. Pracovní a dočasné soubory“, která rozvíjí další část řízeného dokumentu.

# 14. Pracovní a dočasné soubory

## 14.1 Pracovní kopie

Pracovní kopie může dočasně obsahovat označení:

```text
_REVIEW
_DRAFT
_WORKING
```

Po dokončení workflow se:

- převede pod stabilní aktivní název,
- archivuje,
- nebo odstraní.

## 14.2 Dočasný zámkový soubor

Příklad:

```text
~$-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.docx
```

Takový soubor:

- není řízený dokument,
- nesmí být commitnut,
- nesmí být importován,
- odstraní se po zavření aplikace.

## 14.3 Kopie s číslem v závorce

Soubory typu:

```text
DOKUMENT(1).md
DOKUMENT - kopie.md
```

nesmějí zůstat v aktivní kanonické složce.

---


## 14.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „14. Pracovní a dočasné soubory“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „15. Formáty dokumentů“, která rozvíjí další část řízeného dokumentu.

# 15. Formáty dokumentů

## 15.1 Primární zdroj

Primárním zdrojovým formátem dokumentace je standardně Markdown:

```text
.md
```

## 15.2 Odvozené formáty

Odvozené formáty mohou zahrnovat:

```text
.docx
.pdf
.html
```

Odvozený formát není automaticky druhou aktivní pravdou.

Musí být zřejmé:

- z jaké verze vznikl,
- zda jde o export,
- kde je kanonický zdroj.

## 15.3 Tabulkové artefakty

Tabulkové artefakty mohou používat:

```text
.xlsx
.csv
```

Pokud jsou řízenými exporty, používají `MM-EXP` nebo jiný schválený typ.

---


## 15.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „15. Formáty dokumentů“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „16. Jazyk dokumentace“, která rozvíjí další část řízeného dokumentu.

# 16. Jazyk dokumentace

## 16.1 Primární jazyk

Primárním jazykem dokumentace projektu je čeština, pokud konkrétní účel nevyžaduje jiný jazyk.

## 16.2 Technické názvy

Technické identifikátory se zachovávají v původním tvaru:

- názvy tabulek,
- názvy sloupců,
- názvy funkcí,
- názvy providerů,
- kódy soutěží,
- názvy API endpointů,
- názvy režimů.

Příklad:

```text
public.match_provider_map
VALIDATE_ONLY
```

## 16.3 Překlad technických pojmů

České vysvětlení se poskytuje v textu, tooltipu nebo slovníku.

Technický identifikátor se nepřepisuje českým překladem, pokud by se ztratila přesnost.

## 16.4 Terminologie

Řízené termíny musí odpovídat `MM-REF-001` a terminologickým standardům.

---


## 16.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „16. Jazyk dokumentace“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „17. Kontrola souladu“, která rozvíjí další část řízeného dokumentu.

# 17. Kontrola souladu

Dokument splňuje tento standard, pokud:

- [ ] obsahuje správný Document ID,
- [ ] používá správný typ dokumentu,
- [ ] aktivní název neobsahuje číslo verze,
- [ ] aktivní název neobsahuje dlouhodobě `_REVIEW`,
- [ ] popisná část odpovídá obsahu,
- [ ] neexistuje druhá aktivní varianta,
- [ ] verze je uvedena v metadatech,
- [ ] stav je uveden v metadatech,
- [ ] datum používá formát `YYYY-MM-DD`,
- [ ] aktivní cesta je relativní ke kořeni projektu,
- [ ] historie verzí je uvedena,
- [ ] odkazy používají Document ID,
- [ ] dokument je v kanonické složce,
- [ ] archivní kopie není zaměnitelná s aktivním souborem,
- [ ] dočasné soubory nejsou připraveny ke commitu,
- [ ] struktura nadpisů je logická,
- [ ] terminologie odpovídá referenčnímu slovníku.

---


## 17.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „17. Kontrola souladu“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „18. Výjimky“, která rozvíjí další část řízeného dokumentu.

# 18. Výjimky

Výjimka je možná pouze tehdy, pokud:

- ji vyžaduje externí systém nebo právní podmínka,
- je zaznamenána,
- je schválena,
- nenaruší jedinečnost Document ID,
- nevytvoří dvě aktivní pravdy,
- neznemožní automatické zpracování dokumentace.

Existující stabilní název se nemění pouze kvůli kosmetickému sjednocení, pokud by změna přinesla více rizika než užitku.

---


## 18.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „18. Výjimky“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „19. Vztah k ostatním standardům“, která rozvíjí další část řízeného dokumentu.

# 19. Vztah k ostatním standardům

## MM-STD-003

Určuje životní cyklus, verze, stavy, REVIEW workflow a archivaci.

Při konfliktu týkajícím se aktivní verze a názvu má přednost novější platná verze `MM-STD-003`.

## MM-STD-007

Určuje přidělování identit, číselné rozsahy a registr Document ID.

`MM-STD-004` neurčuje nové číselné rozsahy bez návaznosti na `MM-STD-007`.

## MM-STD-006 a MM-STD-008

Určují terminologii a správu referenčního slovníku.

## MM-STD-009

Určuje AI Context a Project Snapshot.

## MM-STD-1000

Eviduje aktuální soubor standardů a jejich stav.

---


## 19.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „19. Vztah k ostatním standardům“ v rámci dokumentu MM-STD-004 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# 20. Závěr

Názvosloví dokumentace MatchMatrix musí umožnit okamžitě rozlišit:

- identitu dokumentu,
- jeho účel,
- typ,
- aktivní a archivní stav,
- zdrojový a exportní formát.

Základním pravidlem aktivních řízených dokumentů je:

```text
stabilní Document ID
+ stabilní aktivní název
+ verze uvnitř dokumentu
+ jediný aktivní soubor
+ řízený archiv historie
```

Číslo verze v aktivním názvu souboru se nepoužívá.

---

# AI CONTEXT

**Role dokumentu:** Závazný standard názvů, metadat, souborů, složek a základní struktury dokumentace MatchMatrix.

**Aktivní soubor:** `<DOCUMENT_ID>_<POPISNÝ_NÁZEV>.md`

**Verze:** Patří dovnitř dokumentu, nikoli do názvu aktivního souboru.

**REVIEW:** Je dočasný pracovní stav nebo název kandidátní kopie. Po přijetí se obsah přesune pod stabilní aktivní název.

**Document ID:** Určuje identitu. Verze, cesta a název ji nemění.

**Nadřazený životní cyklus:** MM-STD-003.

**Číslování:** MM-STD-007.

---

# PROJECT SNAPSHOT

- Aktivní hlavní dokumenty používají stabilní názvy bez čísla verze.
- REVIEW varianty hlavních dokumentů byly převedeny pod původní aktivní názvy.
- Starší významné kopie jsou v `docs/99_ARCHIVE`.
- Document ID hlavních dokumentů jsou MM-DOC-000, 100, 200, 300, 800 a 900.
- Dokumentace používá typy MM-DOC, MM-STD, MM-REF, MM-PRV, MM-TPL, MM-DL, MM-NAV a MM-EXP.
- Česká dokumentace zachovává originální technické identifikátory.

---

# CURRENT STATUS

- Stable Active Filename: ACTIVE
- Version Inside Document: ACTIVE
- Document Type Prefixes: ACTIVE / REQUIRES MM-STD-007 ALIGNMENT
- Canonical Folder Structure: ACTIVE
- Archive Naming: ACTIVE
- Automated Naming Validation: PARTIAL

---

# OPEN QUESTIONS

- úplný registr všech používaných prefixů,
- přesné číselné rozsahy jednotlivých typů,
- automatická kontrola názvu proti metadatům,
- automatická detekce druhých aktivních kopií,
- pravidla pro názvy odvozených DOCX a PDF výstupů,
- sjednocení existujících názvů s diakritikou bez zbytečných přesunů.

---

# NEXT STEP

Aktualizovat `MM-STD-007`, zachovat již zavedené Document ID a sjednotit číselné rozsahy s tímto standardem a dokumentačním indexem.
