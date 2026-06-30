# MM-DOC-008

# MATCHMATRIX ARCHITECTURAL DECISIONS (TECH)

---

## Informace o dokumentu

| Položka              | Hodnota                                                                          |
| :------------------- | :------------------------------------------------------------------------------- |
| Název dokumentu      | MATCHMATRIX ARCHITECTURAL DECISIONS                                              |
| Označení             | MM-DOC-008                                                                       |
| Edice                | TECH                                                                             |
| Verze                | 1.0 (Pracovní verze)                                                             |
| Stav                 | Rozpracováno                                                                     |
| Autor projektu       | Petr                                                                             |
| Technická spolupráce | OpenAI ChatGPT                                                                   |
| Primární formát      | Markdown (.md)                                                                   |
| Umístění             | `docs/08_ARCHITECTURAL_DECISIONS/08_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH.md` |

---

# Motto

> **Architektura není soubor technologií. Architektura je soubor rozhodnutí.**

---

# Obsah

1. Úvod
2. Účel dokumentu
3. Co je architektonické rozhodnutí
4. Proč rozhodnutí evidovat
5. Životní cyklus rozhodnutí
6. Struktura rozhodnutí
7. Klasifikace rozhodnutí
8. Vazby na ostatní dokumentaci
9. Závěr

---

# 1. Úvod

Každý dlouhodobý projekt postupně vytváří stovky technických rozhodnutí.

Některá mají pouze krátkodobý význam.

Jiná ovlivňují celý projekt na mnoho let.

Právě tato druhá skupina tvoří architekturu systému.

Během vývoje MatchMatrix vznikla řada rozhodnutí, která zásadně ovlivnila podobu databáze, harvest pipeline, governance, OPS panelu i celé dokumentace.

Bez jejich znalosti je obtížné pochopit, proč je systém navržen právě současným způsobem.

Proto vznikl tento dokument.

---

# 2. Účel dokumentu

MATCHMATRIX ARCHITECTURAL DECISIONS představuje centrální registr všech významných architektonických rozhodnutí projektu.

Jeho hlavním cílem je zachytit nejen samotné rozhodnutí, ale také důvody, které k němu vedly.

Každé rozhodnutí obsahuje:

* problém,
* zvažované možnosti,
* zvolené řešení,
* očekávaný přínos,
* dlouhodobý dopad.

Dokument tak vytváří znalostní základnu architektury MatchMatrix.

---

# 3. Co je architektonické rozhodnutí

Architektonickým rozhodnutím se rozumí každé rozhodnutí, které významně ovlivňuje návrh nebo budoucí vývoj systému.

Nejde o běžné programátorské úpravy.

Jedná se například o:

* změnu databázové architektury,
* vznik nové Layer,
* nový způsob harvestu,
* změnu workflow,
* změnu governance,
* změnu dokumentačního standardu.

Taková rozhodnutí bývají přijímána zřídka.

Jejich dopad je však dlouhodobý.

---

# 4. Proč rozhodnutí evidovat

Po několika měsících nebo letech bývá obtížné vzpomenout si, proč bylo určité řešení zvoleno.

Bez této informace vzniká riziko, že bude stejné rozhodnutí znovu analyzováno nebo dokonce zbytečně změněno.

Evidence architektonických rozhodnutí umožňuje:

* pochopit historii systému,
* zachovat důvody jednotlivých návrhů,
* usnadnit předání projektu,
* podpořit dlouhodobou konzistenci architektury.

Každé rozhodnutí představuje zkušenost získanou během vývoje projektu.

---

# Závěr první části

Architektonická rozhodnutí tvoří základ dlouhodobé stability projektu MatchMatrix. Jejich systematická evidence umožňuje pochopit vývoj architektury, zachovat důvody jednotlivých návrhů a vytváří znalostní základnu, která bude využitelná i po mnoha letech dalšího rozvoje platformy.

V další části dokumentu budou popsány životní cyklus architektonických rozhodnutí, jejich doporučená struktura, systém označování AD-xxxx a pravidla jejich evidence.

# 5. Životní cyklus architektonického rozhodnutí

Architektonické rozhodnutí nevzniká okamžitě.

Každé významné rozhodnutí prochází několika navazujícími etapami.

Tento postup umožňuje přijímat změny na základě zkušeností získaných během skutečného vývoje projektu, nikoliv pouze na základě teoretických úvah.

Každé rozhodnutí by mělo být výsledkem analýzy, ověření a praktického používání.

---

# 5.1 Identifikace problému

Každé architektonické rozhodnutí začíná identifikací problému.

Je nejprve potřeba přesně určit:

* co nefunguje,
* jaké jsou současné limity,
* proč je potřeba změna,
* jaký bude přínos nového řešení.

Bez jasně definovaného problému by nemělo vznikat nové architektonické rozhodnutí.

---

# 5.2 Analýza možností

Před přijetím rozhodnutí je vhodné zvážit více možných řešení.

Každá varianta by měla být posouzena z hlediska:

* složitosti,
* dlouhodobé udržitelnosti,
* rozšiřitelnosti,
* dopadu na stávající systém,
* budoucích nákladů.

Ne vždy je nejlepší nejrychlejší řešení.

---

# 5.3 Přijetí rozhodnutí

Po vyhodnocení jednotlivých možností je přijato architektonické rozhodnutí.

Součástí rozhodnutí by měl být také stručný popis důvodů, proč byla zvolena právě tato varianta.

Tato informace bývá po několika měsících často důležitější než samotné technické řešení.

---

# 5.4 Implementace

Po přijetí rozhodnutí následuje jeho realizace.

Během implementace může dojít k drobným úpravám.

Samotný princip rozhodnutí by však měl zůstat zachován.

Pokud se během implementace ukáže potřeba zásadní změny, je vhodné vytvořit nové architektonické rozhodnutí místo úpravy původního.

---

# 5.5 Ověření v praxi

Ne každé architektonické rozhodnutí se osvědčí.

Proto je důležité jeho dlouhodobé ověření.

Pokud se rozhodnutí ukáže jako správné, zůstává součástí architektury.

Pokud se objeví nové skutečnosti, může být nahrazeno novým rozhodnutím.

Původní záznam však zůstává zachován jako součást historie projektu.

---

# 6. Struktura architektonického rozhodnutí

Každé rozhodnutí bude zapisováno podle jednotné struktury.

To umožní jejich snadné porovnávání i dlouhodobou správu.

---

# 6.1 Identifikátor

Každé rozhodnutí dostane vlastní jedinečný identifikátor.

Například:

```text
AD-0001
AD-0002
AD-0003
```

Identifikátor se již nikdy nemění.

Na tento identifikátor mohou odkazovat ostatní dokumenty projektu.

---

# 6.2 Doporučená struktura

Každé rozhodnutí by mělo obsahovat následující části.

```text
ID:

Název:

Datum:

Stav:

Oblast:

Problém:

Možná řešení:

Zvolené řešení:

Důvod rozhodnutí:

Očekávaný přínos:

Dlouhodobý dopad:

Navazuje na:

Související dokumenty:
```

Tato struktura bude používána jednotně pro všechna budoucí architektonická rozhodnutí.

---

# 7. Klasifikace rozhodnutí

Ne všechna rozhodnutí mají stejnou důležitost.

Proto budou rozdělena do několika kategorií.

## Strategická rozhodnutí

Rozhodnutí ovlivňující celou platformu.

Například:

* databázová architektura,
* víceproviderový model,
* Layer Architecture.

---

## Architektonická rozhodnutí

Rozhodnutí ovlivňující jednotlivé části systému.

Například:

* harvest pipeline,
* OPS,
* governance,
* dokumentace.

---

## Technická rozhodnutí

Rozhodnutí týkající se implementace.

Například:

* použitý nástroj,
* struktura adresářů,
* způsob logování.

Toto rozdělení umožní snadnější orientaci při větším počtu evidovaných rozhodnutí.

---

# Závěr druhé části

Jednotný životní cyklus i struktura architektonických rozhodnutí zajišťují, že všechna důležitá rozhodnutí projektu MatchMatrix budou zaznamenána stejným způsobem. Díky tomu bude možné kdykoliv pochopit nejen výslednou architekturu systému, ale také důvody, které vedly k jejímu vzniku.

V závěrečné části dokumentu budou popsány vazby na ostatní dokumentaci, pravidla dlouhodobé správy registru AD-xxxx a doporučený způsob využití architektonických rozhodnutí při dalším rozvoji projektu MatchMatrix.

# 8. Vazba na ostatní dokumentaci

Dokument ARCHITECTURAL DECISIONS nepředstavuje samostatnou dokumentaci.

Je součástí celého dokumentačního systému MatchMatrix.

Každé architektonické rozhodnutí je úzce propojeno s ostatními dokumenty projektu.

Tím vzniká jednotná znalostní základna, ve které lze snadno dohledat nejen samotné rozhodnutí, ale také jeho důvody, průběh implementace i dlouhodobé důsledky.

---

# 8.1 Vazba na ARCHITECTURE

Dokument **MATCHMATRIX ARCHITECTURE** popisuje výslednou architekturu systému.

Dokument **ARCHITECTURAL DECISIONS** vysvětluje, proč byla tato architektura vytvořena právě tímto způsobem.

Oba dokumenty se vzájemně doplňují.

ARCHITECTURE odpovídá na otázku:

> Jak je systém navržen?

ARCHITECTURAL DECISIONS odpovídá na otázku:

> Proč je navržen právě takto?

---

# 8.2 Vazba na GOVERNANCE

Řada architektonických rozhodnutí vede ke vzniku nových pravidel projektu.

Jakmile je rozhodnutí dlouhodobě ověřeno, mělo by být promítnuto také do dokumentu GOVERNANCE.

Tím se z jednorázového rozhodnutí stává trvalý standard projektu.

---

# 8.3 Vazba na CHANGELOG

Každé významné architektonické rozhodnutí představuje důležitý milník projektu.

Proto by mělo být současně zaznamenáno také v dokumentu CHANGELOG.

CHANGELOG obsahuje stručnou informaci o změně.

ARCHITECTURAL DECISIONS obsahuje její podrobné vysvětlení.

---

# 8.4 Vazba na DENNÍ ZÁPISY

Architektonická rozhodnutí často vznikají během běžné práce.

První zmínka o novém rozhodnutí se proto obvykle objeví v denním zápisu.

Teprve po ověření vzniká samostatný záznam AD-xxxx.

Denní zápisy tedy zachycují okamžik vzniku rozhodnutí.

ARCHITECTURAL DECISIONS představuje jeho dlouhodobou evidenci.

---

# 8.5 Vazba na NAVÁZÁNÍ

Pokud je během pracovní etapy přijato významné architektonické rozhodnutí, mělo by být uvedeno také v dokumentu NAVÁZÁNÍ.

Tím bude zajištěno, že další pracovní etapa bude na toto rozhodnutí přímo navazovat.

---

# 9. Správa registru AD

Registr architektonických rozhodnutí představuje dlouhodobou znalostní databázi projektu.

Jeho správa se řídí několika základními pravidly.

---

# 9.1 Jedinečnost identifikátoru

Každé rozhodnutí získá vlastní identifikátor.

Například:

```text
AD-0001
AD-0002
AD-0003
```

Jednou přidělený identifikátor se již nikdy nepoužije pro jiné rozhodnutí.

---

# 9.2 Neměnnost historie

Přijaté rozhodnutí se zpětně nemaže.

Pokud se později ukáže vhodnější řešení, vzniká nové rozhodnutí.

Původní záznam zůstává zachován.

Díky tomu lze sledovat vývoj architektury v čase.

---

# 9.3 Stav rozhodnutí

Každé architektonické rozhodnutí může mít svůj stav.

Například:

* **NAVRHOVANÉ**
* **SCHVÁLENÉ**
* **IMPLEMENTOVANÉ**
* **OVĚŘENÉ**
* **NAHRAZENÉ**
* **ARCHIVOVANÉ**

Tento stav umožňuje rychle zjistit, zda je rozhodnutí již součástí produkční architektury, nebo se stále nachází ve fázi návrhu.

---

# 9.4 Dlouhodobá správa

Registr AD bude průběžně rozšiřován.

Nepředpokládá se pevný počet rozhodnutí.

Naopak.

S rozvojem projektu bude registr přirozeně růst.

Každé nové významné rozhodnutí bude zařazeno jako nový záznam.

Tím vznikne dlouhodobá historie architektonického vývoje MatchMatrix.

---

# 10. Závěr dokumentu

MATCHMATRIX ARCHITECTURAL DECISIONS představuje centrální registr všech významných architektonických rozhodnutí projektu.

Jeho cílem není pouze zaznamenat přijatá řešení.

Stejně důležité je zachytit důvody, které k nim vedly, možné alternativy i jejich dlouhodobý dopad.

Společně s dokumenty MASTER, GOVERNANCE, ARCHITECTURE, DEVELOPMENT HANDBOOK, DENNÍ ZÁPISY, NAVÁZÁNÍ a CHANGELOG vytváří ucelený systém dokumentace projektu MatchMatrix.

Díky tomuto systému lze kdykoliv pochopit nejen současnou podobu platformy, ale také celý proces jejího vzniku a postupného vývoje.

---

# Stav dokumentu

**Dokument:** MM-DOC-008 – MATCHMATRIX ARCHITECTURAL DECISIONS

**Edice:** TECH

**Verze:** 1.0 – První pracovní verze

**Stav:** Připraven k první revizi

---

## Navazující etapa

Dokončením tohoto dokumentu byla uzavřena první série technické dokumentace projektu MatchMatrix.

Následující etapou bude:

> **TECH V2 – Konsolidace dokumentace**

V této fázi budou všechny dokumenty MM-DOC-000 až MM-DOC-008 sjednoceny do jednotného standardu. Budou doplněna metadata, vzájemné odkazy, společné šablony, příklady, checklisty a další prvky, které vznikly během tvorby celé série.

Po dokončení TECH V2 začne vznikat druhá dokumentační řada:

> **BOOK Edition**

BOOK nebude nahrazovat TECH dokumentaci. Bude představovat její rozšířenou podobu, zachycující historii projektu, architektonická rozhodnutí, zkušenosti z vývoje, důvody jednotlivých změn a dlouhodobou vizi platformy MatchMatrix.

---

### Poznámka pro TECH V2

Do druhé verze tohoto dokumentu budou doplněny zejména:

* katalog prvních architektonických rozhodnutí **AD-0001 až AD-00xx**,
* doporučená šablona jednotlivých rozhodnutí,
* klasifikace podle oblasti a závažnosti,
* vazby na Git commity a milestone projektu,
* odkazy na související SQL skripty, workery a dokumentaci.

Tím vznikne plnohodnotný registr architektonických rozhodnutí, který bude dlouhodobě doprovázet další vývoj projektu MatchMatrix.
