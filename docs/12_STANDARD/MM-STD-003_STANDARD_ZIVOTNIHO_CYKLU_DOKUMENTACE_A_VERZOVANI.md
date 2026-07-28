# MM-STD-003

# STANDARD ŽIVOTNÍHO CYKLU DOKUMENTACE A VERZOVÁNÍ

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-STD-003 |
| Název | Standard životního cyklu dokumentace a verzování |
| Edice | MM-STD |
| Verze | 1.2 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Aktivní soubor | `docs/12_STANDARD/MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md` |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
| 1.0 | 2026 | ACTIVE | První vydání standardu. |
| 1.1 | 2026 | ACTIVE | Doplněna pravidla jediné aktivní verze, stabilního názvu souboru a identity dokumentu. |
| 1.2 | 2026-07-27 | REVIEW | Sjednocen celý životní cyklus dokumentů, stav REVIEW, stabilní aktivní názvy, řízený archiv, historické dokumenty, Git a databázová publikace podle ověřeného workflow projektu. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |

---

## Úvod a účel dokumentu
Tento standard stanovuje závazný životní cyklus řízených dokumentů projektu MatchMatrix.

Definuje:

- vznik dokumentu,
- přidělení identity,
- pracovní návrh,
- odbornou a uživatelskou revizi,
- schválení,
- aktivní verzi,
- aktualizaci,
- verzování,
- archivaci,
- opravy historických dokumentů,
- publikaci do Git repozitáře,
- import do dokumentační databáze,
- ukončení nebo nahrazení dokumentu.

Cílem je zajistit, aby pro každý dokument existovala jednoznačná aktivní pravda, úplná historie a bezpečná návaznost pro lidi i systémy AI.

---

## Rozsah

Tento standard je závazný pro všechny řízené dokumenty MatchMatrix, zejména pro:

- hlavní dokumenty `MM-DOC`,
- standardy `MM-STD`,
- referenční dokumenty `MM-REF`,
- providerové dokumenty `MM-PRV`,
- šablony `MM-TPL`,
- denní zápisy `MM-DL`,
- dokumenty NAVÁZÁNÍ `MM-NAV`,
- exportní artefakty `MM-EXP`,
- další dokumentové typy evidované v dokumentačním systému.

Pracovní poznámka, dočasný export nebo pomocný soubor se stává řízeným dokumentem teprve tehdy, když obdrží Document ID, kanonické umístění a vstoupí do dokumentačního workflow.

---

# 1. Základní principy

## 1.1 Jedna identita

Každý řízený dokument má jeden jedinečný a dlouhodobě stabilní Document ID.

Příklady:

```text
MM-DOC-000
MM-DOC-100
MM-STD-003
MM-REF-001
MM-DL-20260727
MM-NAV-20260727-01
```

Document ID určuje identitu dokumentu.

Identitu neurčuje:

- název souboru,
- složka,
- číslo verze,
- stav,
- edice TECH nebo BOOK,
- přípona formátu,
- přítomnost slova REVIEW v pracovním názvu.

Jednou přidělené Document ID se znovu nepoužívá pro jiný dokument.

## 1.2 Jeden aktivní soubor

Pro jeden Document ID a jednu aktivní edici existuje standardně pouze jeden oficiální aktivní zdrojový soubor.

Aktivní soubor:

- používá stabilní název,
- neobsahuje číslo verze v názvu,
- neobsahuje dlouhodobě příponu `_REVIEW`,
- je průběžně aktualizován,
- obsahuje aktuální číslo verze uvnitř dokumentu,
- obsahuje historii verzí uvnitř dokumentu.

Příklad:

```text
MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md
```

Správný nový stav:

```text
stejný aktivní název souboru
+ nová verze uvnitř dokumentu
+ doplněná historie verzí
+ archivovaná předchozí významná verze
```

## 1.3 Jedna aktivní pravda

V aktivních složkách nesmějí dlouhodobě existovat dvě rozdílné varianty, které vypadají jako současně platné zdroje téhož dokumentu.

Za konfliktní aktivní varianty se považují například:

```text
MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md
MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_REVIEW.md
MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_v1.md
```

Po dokončení revize musí být nový obsah převeden pod stabilní aktivní název a předchozí významná verze uložena do archivu.

## 1.4 Historie se neztrácí

Aktivní soubor zachovává tabulku historie verzí.

Předchozí úplná kopie vzniká zejména při:

- významném obsahovém milníku,
- přechodu z pracovní nebo REVIEW varianty na novou aktivní verzi,
- změně s významným právním, auditním nebo architektonickým dopadem,
- požadavku jiného standardu,
- potřebě dlouhodobé forenzní dohledatelnosti.

Archiv není druhou aktivní pravdou.

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Základní principy“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Dokumentové stavy“, která rozvíjí další část řízeného dokumentu.

# 2. Dokumentové stavy

## 2.1 DRAFT

Stav `DRAFT` označuje pracovní návrh, který ještě není připraven k uživatelskému nebo odbornému schválení.

Používaná přesnější varianta může být například:

```text
DRAFT – NEEDS_USER_APPROVAL
```

DRAFT dokument může obsahovat otevřená pole nebo pracovní poznámky, ale nesmí být vydáván za schválený aktuální standard.

## 2.2 REVIEW

Stav `REVIEW` označuje novější opravenou nebo doplněnou verzi, která navazuje na předchozí obsah a čeká na kontrolu nebo schválení.

REVIEW není automaticky vedlejší kopie.

V projektovém workflow může REVIEW verze představovat obsahově nejnovější kandidátní verzi dokumentu.

Po jejím přijetí:

1. její obsah přechází pod stabilní aktivní název,
2. číslo verze a stav zůstávají uvnitř dokumentu,
3. pracovní soubor s `_REVIEW` se odstraní z aktivní složky nebo archivuje,
4. předchozí významná verze se uloží do řízeného archivu.

## 2.3 APPROVED

Stav `APPROVED` potvrzuje, že uživatel nebo oprávněný schvalovatel věcně schválil obsah dokumentu.

Schválení obsahu samo o sobě nemusí znamenat dokončený Git commit nebo databázový import. Publikační kroky se evidují samostatně.

## 2.4 ACTIVE

Stav `ACTIVE` označuje dokument platný pro běžné používání jako aktuální referenční zdroj.

Aktivace může následovat po:

- věcném schválení,
- úspěšném auditu,
- publikaci do repozitáře,
- importu do dokumentační databáze,
- splnění dalších podmínek daného typu dokumentu.

## 2.5 ARCHIVED

Stav `ARCHIVED` označuje historickou kopii nebo dokument, který již není aktivním zdrojem.

Archivovaný dokument:

- zůstává dohledatelný,
- nesmí být používán jako současná aktivní pravda,
- musí mít zřejmý vztah k aktivnímu nebo nástupnickému dokumentu.

## 2.6 SUPERSEDED

Stav `SUPERSEDED` označuje dokument nahrazený jiným řízeným dokumentem.

Musí být uvedeno:

- který dokument jej nahradil,
- od kdy,
- z jakého důvodu.

## 2.7 WITHDRAWN

Stav `WITHDRAWN` označuje dokument stažený bez přímého nástupce.

Důvod stažení musí být zaznamenán.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Dokumentové stavy“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Životní cyklus hlavního řízeného dokumentu“, která rozvíjí další část řízeného dokumentu.

# 3. Životní cyklus hlavního řízeného dokumentu

Standardní životní cyklus:

```text
POTŘEBA DOKUMENTU
        ↓
PŘIDĚLENÍ DOCUMENT ID
        ↓
DRAFT
        ↓
REVIEW
        ↓
UŽIVATELSKÉ SCHVÁLENÍ
        ↓
AUDIT A KONTROLA
        ↓
APPROVED / ACTIVE
        ↓
PRŮBĚŽNÁ AKTUALIZACE POD STEJNÝM NÁZVEM
        ↓
NOVÁ VERZE UVNITŘ DOKUMENTU
        ↓
ŘÍZENÝ ARCHIV PŘEDCHOZÍHO MILNÍKU
```

Nová obsahová verze nevytváří automaticky nový Document ID.

Nový Document ID vzniká pouze tehdy, pokud vzniká nový samostatný dokument s jiným účelem a odpovědností.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Životní cyklus hlavního řízeného dokumentu“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Stabilní aktivní název souboru“, která rozvíjí další část řízeného dokumentu.

# 4. Stabilní aktivní název souboru

## 4.1 Obecné pravidlo

Aktivní název používá formát definovaný názvoslovným standardem, typicky:

```text
<DOCUMENT_ID>_<POPISNÝ_NÁZEV>.md
```

Příklad:

```text
MM-DOC-000_MATCHMATRIX_DOCUMENTATION_FRAMEWORK.md
MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md
MM-REF-001_SLOVNIK_POJMU_MATCHMATRIX.md
```

Číslo verze patří do metadat dokumentu, nikoli do aktivního názvu.

## 4.2 Změna názvu dokumentu

Popisnou část názvu souboru lze změnit, pokud:

- se nezmění Document ID,
- nový název lépe odpovídá skutečnému obsahu,
- jsou aktualizovány odkazy a indexy,
- změna je zachycena v historii verzí.

## 4.3 Změna umístění

Přesun do jiné kanonické složky nemění identitu dokumentu.

Přesun musí být:

- zaznamenán,
- promítnut do indexu,
- promítnut do dokumentační databáze,
- proveden tak, aby nezůstala druhá aktivní kopie.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Stabilní aktivní název souboru“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Číslování verzí“, která rozvíjí další část řízeného dokumentu.

# 5. Číslování verzí

## 5.1 Hlavní verze

Hlavní verze se zvyšuje při zásadní změně účelu, struktury nebo závazného modelu dokumentu.

Příklad:

```text
1.2 → 2.0
```

## 5.2 Vedlejší verze

Vedlejší verze se zvyšuje při významné obsahové aktualizaci, která zachovává základní účel dokumentu.

Příklad:

```text
1.1 → 1.2
```

## 5.3 Opravná verze

Opravná verze může být použita při malé věcné nebo formální opravě bez změny významu.

Příklad:

```text
1.2 → 1.2.1
```

Opravné trojčlenné verzování se používá pouze tehdy, pokud je potřeba přesně rozlišit malou opravu. Není povinné pro každý překlep před publikací.

## 5.4 Verze před prvním schválením

Pracovní vývoj může používat verze pod `1.0`, například:

```text
0.8
0.9
```

Verze `1.0` standardně označuje první úplnou referenční verzi.

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Číslování verzí“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. REVIEW soubory a jejich převod“, která rozvíjí další část řízeného dokumentu.

# 6. REVIEW soubory a jejich převod

## 6.1 Dočasný pracovní název

Během revize může vzniknout pracovní soubor:

```text
MM-DOC-200_MATCHMATRIX_GOVERNANCE_TECH_REVIEW.md
```

Tento název smí sloužit pouze jako dočasný kandidát během přípravy a kontroly.

## 6.2 Přijetí REVIEW verze

Pokud je REVIEW verze novější opravenou verzí navazující na původní dokument:

1. původní aktivní soubor se uloží do archivu,
2. obsah REVIEW verze se přesune pod původní stabilní aktivní název,
3. dokument uvnitř obdrží nové číslo verze,
4. doplní se historie verzí,
5. pracovní REVIEW soubor přestane existovat v aktivní složce.

## 6.3 Odmítnutí REVIEW verze

Pokud REVIEW verze není přijata:

- aktivní dokument se nemění,
- REVIEW varianta se odstraní nebo archivuje jako odmítnutý návrh,
- důvod odmítnutí se zaznamená, pokud má dlouhodobý význam.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. REVIEW soubory a jejich převod“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „7. Řízený archiv“, která rozvíjí další část řízeného dokumentu.

# 7. Řízený archiv

## 7.1 Umístění

Archivní dokumenty se ukládají do:

```text
docs/99_ARCHIVE/
```

Doporučená struktura zachovává původní oblast a důvod archivace, například:

```text
docs/99_ARCHIVE/03_ARCHITECTURE/20260727_DOCUMENT_ID_CLEANUP/
```

## 7.2 Název archivní kopie

Archivní název smí obsahovat verzi, datum nebo důvod, protože archivní soubor není aktivním názvem.

Příklad:

```text
MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_PREVIOUS_V0_9.md
```

## 7.3 Povinné vlastnosti archivu

Archiv musí umožnit zjistit:

- Document ID,
- původní verzi,
- vztah k aktivnímu dokumentu,
- důvod archivace,
- přibližné datum nebo milník.

## 7.4 Co není archiv

Dočasný zámkový soubor, například:

```text
~$-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH.docx
```

není archivní dokument a před publikací se odstraňuje po uzavření příslušné aplikace.

---


## 7.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „7. Řízený archiv“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „8. Historické dokumenty MM-DL a MM-NAV“, která rozvíjí další část řízeného dokumentu.

# 8. Historické dokumenty MM-DL a MM-NAV

## 8.1 Denní zápisy

Denní zápis používá časově specifický Document ID:

```text
MM-DL-YYYYMMDD
```

Jeden den má standardně jeden kanonický denní zápis.

Po schválení se denní zápis považuje za historický záznam daného dne.

## 8.2 NAV dokumenty

NAV dokument používá:

```text
MM-NAV-YYYYMMDD-NN
```

Více NAV dokumentů stejného dne je možné a rozlišuje je pořadové číslo `NN`.

## 8.3 Opravy historických dokumentů

Schválený historický dokument se neopravuje tichým přepisem, který by zničil původní historii.

Podle závažnosti se použije:

- opravená nová verze téhož dokumentu se zachovanou historií,
- následný opravný zápis,
- nový NAV nebo Project Snapshot,
- poznámka o nahrazení starší informace novějším ověřeným stavem.

Starší snapshot může být správný pro okamžik svého vzniku, i když již není aktuální.

---


## 8.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „8. Historické dokumenty MM-DL a MM-NAV“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „9. Dokumentace a Git“, která rozvíjí další část řízeného dokumentu.

# 9. Dokumentace a Git

## 9.1 Git jako historie zdrojových souborů

Git eviduje:

- změnu aktivního dokumentu,
- odstranění dočasné REVIEW varianty,
- přidání archivní kopie,
- změnu indexu,
- změnu souvisejících odkazů.

## 9.2 Stav před commitem

Před commitem se kontroluje:

- jediný aktivní soubor pro každý Document ID,
- správný obsah archivu,
- odstranění dočasných souborů,
- správné Document ID a verze,
- související indexy,
- čistota rozsahu commitu.

Nesouvisející databázové skripty nebo exporty se nesmějí omylem zahrnout do dokumentačního commitu, pokud nejsou součástí stejného schváleného milníku.

## 9.3 Commit a push

Lokální commit a vzdálený push jsou dva různé stavy.

Dokumentace nesmí tvrdit, že proběhl push, pokud je potvrzen pouze commit.

---


## 9.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „9. Dokumentace a Git“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „10. Dokumentační databáze“, která rozvíjí další část řízeného dokumentu.

# 10. Dokumentační databáze

## 10.1 Vztah souboru a databáze

Aktivní Markdown soubor je kanonický zdrojový dokument v repozitáři.

Dokumentační databáze uchovává jeho řízenou reprezentaci:

- dokument,
- verze,
- aktuální verzi,
- sekce,
- vazby,
- stavovou historii,
- importní běhy.

## 10.2 Q3 workflow

Publikace dokumentu používá podle aktuálního workflow zejména:

- A17 – audit standardu,
- A18 – standardizační návrh,
- A19 – kontrolu mapování,
- A20 – builder,
- A24 – import do dokumentační databáze,
- A6 a A7 – navazující kontroly integrity.

## 10.3 VALIDATE_ONLY a APPLY

A24 nejprve používá `VALIDATE_ONLY`.

Úspěšná validace neznamená trvalý import.

Teprve `APPLY` vytvoří trvalou databázovou změnu.

## 10.4 Čistý Git strom

Dokumentační import se standardně provádí nad čistým Git stromem, aby bylo možné jednoznačně určit importovaný obsah a commit.

Odchylka musí být výslovně zdůvodněna a nesmí obcházet ochranné kontroly.

---


## 10.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „10. Dokumentační databáze“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „11. AI Context a Project Snapshot“, která rozvíjí další část řízeného dokumentu.

# 11. AI Context a Project Snapshot

Významný řízený dokument má podle svého typu podporovat sekce:

- AI CONTEXT,
- PROJECT SNAPSHOT,
- DATABASE SNAPSHOT,
- CURRENT STATUS,
- OPEN QUESTIONS,
- NEXT STEP.

Tyto sekce:

- patří do aktivní verze dokumentu,
- aktualizují se spolu s dokumentem,
- musí odpovídat ověřenému stavu,
- nesmějí vydávat plán za dokončený výsledek,
- nesmějí zaměnit `VALIDATE_ONLY` za `APPLY`.

Novější ověřený Project Snapshot může aktualizovat provozní stav uvedený ve starším historickém dokumentu.

---


## 11.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „11. AI Context a Project Snapshot“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „12. Kontrola před aktivací nové verze“, která rozvíjí další část řízeného dokumentu.

# 12. Kontrola před aktivací nové verze

Nová verze může přejít do aktivního používání pouze tehdy, když jsou podle jejího typu ověřeny relevantní body:

- [ ] Document ID zůstal správný a stabilní.
- [ ] Aktivní název neobsahuje číslo verze.
- [ ] Existuje pouze jeden aktivní zdrojový soubor.
- [ ] Číslo verze je uvedeno uvnitř dokumentu.
- [ ] Historie verzí je doplněna.
- [ ] Předchozí významná verze je archivována.
- [ ] Dočasný REVIEW soubor nezůstal jako druhá aktivní pravda.
- [ ] Metadata a kanonická cesta jsou správné.
- [ ] Související odkazy a indexy jsou aktualizované.
- [ ] Dokument prošel požadovaným auditem.
- [ ] Uživatel schválil věcný obsah.
- [ ] Git stav neobsahuje nechtěné dočasné soubory.
- [ ] Databázový import správně rozlišuje VALIDATE_ONLY a APPLY.
- [ ] AI Context a Project Snapshot odpovídají skutečnosti.

---


## 12.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „12. Kontrola před aktivací nové verze“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „13. Výjimky“, která rozvíjí další část řízeného dokumentu.

# 13. Výjimky

Výjimka je přípustná pouze tehdy, pokud:

- je věcně odůvodněna,
- je zaznamenána,
- neporuší jedinečnost Document ID,
- nevytvoří dvě aktivní pravdy,
- nezničí historii,
- je schválena uživatelem nebo příslušnou governance autoritou.

Pouhé pohodlí nebo historický zvyk nejsou dostatečným důvodem pro výjimku.

---


## 13.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „13. Výjimky“ v rámci dokumentu MM-STD-003 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# 14. Závěr

Životní cyklus dokumentace MatchMatrix stojí na čtyřech základních pravidlech:

1. jeden stabilní Document ID,
2. jeden aktivní soubor se stabilním názvem,
3. verze a historie uvnitř dokumentu,
4. řízený archiv předchozích významných stavů.

REVIEW verze je součástí vývoje dokumentu, nikoli trvalou paralelní aktivní kopií.

Dokumentace musí být současně čitelná pro člověka, auditovatelná v Git historii, importovatelná do dokumentační databáze a použitelná jako bezpečný kontext pro AI.

---

# AI CONTEXT

**Role dokumentu:** Nadřazený standard životního cyklu všech řízených dokumentů MatchMatrix.

**Závazné pravidlo:** Jeden Document ID má jeden aktivní soubor se stabilním názvem. Číslo verze patří dovnitř dokumentu.

**REVIEW:** Novější opravená verze navazující na původní dokument. Po přijetí se její obsah přesune pod stabilní aktivní název a předchozí významná verze se archivuje.

**Archiv:** Je historický důkaz, nikoli druhá aktivní pravda.

**Publikace:** Audit → schválení → Git → A24 VALIDATE_ONLY → A24 APPLY → následná kontrola.

---

# PROJECT SNAPSHOT

- Hlavní dokumenty používají stabilní identity `MM-DOC-000`, `100`, `200`, `300`, `800` a `900`.
- Předchozí REVIEW varianty hlavních dokumentů byly převedeny pod stabilní aktivní názvy.
- Starší významné verze jsou ukládány do `docs/99_ARCHIVE`.
- Historie chatů slouží jako ověřovaný důkazní zdroj pro nové verze dokumentů.
- Aktivní názvy dokumentů neobsahují číslo verze.
- Dokumentační workflow používá A17 až A24 a návazné kontroly.

---

# CURRENT STATUS

- Stable Document ID: ACTIVE
- Single Active File: ACTIVE
- Version Inside Document: ACTIVE
- Controlled Archive: ACTIVE
- REVIEW Transition Rule: ACTIVE
- Git Publication: ACTIVE
- Documentation Database Import: ACTIVE
- Automated Lifecycle Enforcement: PARTIAL

---

# OPEN QUESTIONS

- automatická kontrola druhých aktivních kopií,
- automatická kontrola verze proti historii verzí,
- automatické provázání archivní kopie s aktivním dokumentem,
- pravidla oprav již publikovaných historických zápisů,
- automatická synchronizace Git, dokumentační databáze a Project Snapshotu.

---

# NEXT STEP

Aktualizovat `MM-STD-004`, aby odstranil číslo verze z aktivního názvu souboru a plně se podřídil tomuto standardu.
