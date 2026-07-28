# MM-DOC-800

# MATCHMATRIX DEVELOPMENT HANDBOOK (TECH)

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DOC-800 |
| Název | MatchMatrix Development Handbook |
| Edice | MM-DOC TECH |
| Verze | 1.2 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Aktivní soubor | `docs/08_DEVELOPMENT/MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md` |
| Historické pracovní označení | MM-DOC-004 |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
| 1.0 | 2026-06 | Rozpracováno | Původní pracovní verze vedená pod historickým označením MM-DOC-004. |
| 1.1 | 2026-06-30 | REVIEW | Opravená REVIEW verze se stabilní identitou MM-DOC-800 a odstraněnými duplicitními částmi. |
| 1.2 | 2026-07-27 | REVIEW | Aktualizace podle ověřené historie komunikace, skutečného workflow PC1/PC2, databázové governance, dokumentačního panelu Q3 a pravidel spolupráce s AI. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |

---

# Motto

> **Kvalitní software nevzniká náhodou. Vzniká dodržováním stejných pravidel každý den.**

---

# Obsah

0. Smysl Development Handbook
1. Úvod
2. Účel dokumentu
3. Filozofie vývoje MatchMatrix
4. Základní pravidla vývoje
5. Vývojové prostředí a PC1/PC2
6. Rozdělení odpovědností nástrojů
7. Struktura projektu
8. Názvy, aktivní soubory a verzování
9. Společný standard skriptů
10. Standard SQL a databázových změn
11. Standard Python
12. Standard PowerShell a VBS
13. Workflow vývoje
14. Kontrolní checklist
15. Doporučený pracovní postup
16. Standard Git a publikace
17. Standard panelů a uživatelského rozhraní
18. Dokumentace, denní zápisy a AI Context
19. Definition of Done
20. Závěr dokumentu

---

---

# 0. Smysl Development Handbook

Development Handbook sjednocuje každodenní pravidla vývoje platformy MatchMatrix. Jeho cílem je zajistit jednotný, dlouhodobě udržitelný vývoj připravený pro spolupráci lidí i AI.

---


## 0.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „0. Smysl Development Handbook“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „1. Úvod“, která rozvíjí další část řízeného dokumentu.

# 1. Úvod

Vývoj platformy MatchMatrix se během času rozrostl z několika skriptů na rozsáhlý projekt obsahující databázové vrstvy, harvest pipeline, governance mechanismy, OPS dashboardy, automatizační procesy i vlastní dokumentační systém.

S rostoucím rozsahem projektu se ukázalo, že samotná znalost programování nestačí.

Stejně důležité je dodržování jednotných pracovních postupů.

Právě proto vznikl tento dokument.

Jeho úkolem je popsat standardy, které jsou při vývoji MatchMatrix používány každý den.

Nejde o obecnou příručku programování.

Jedná se o pracovní manuál vytvořený přímo pro potřeby tohoto projektu.

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Úvod“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Účel dokumentu“, která rozvíjí další část řízeného dokumentu.

# 2. Účel dokumentu

Development Handbook slouží jako hlavní technická příručka pro vývoj platformy MatchMatrix.

Je určen především pro:

* hlavního vývojáře,
* budoucí spolupracovníky,
* správce databáze,
* administrátory systému,
* vývojáře nových modulů.

Dokument sjednocuje způsob práce napříč celým projektem a zajišťuje, že všechny nové části systému vznikají podle stejných pravidel.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Účel dokumentu“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Filozofie vývoje MatchMatrix“, která rozvíjí další část řízeného dokumentu.

# 3. Filozofie vývoje MatchMatrix

Vývoj MatchMatrix je založen na několika základních principech.

Tyto principy vznikly během praktického vývoje projektu a postupně se staly standardem pro všechny další práce.

## Nejprve architektura

Nejdříve se navrhuje struktura systému.

Teprve poté vzniká samotný kód.

---

## Nejprve databáze

Databáze představuje základ celé platformy.

Webová aplikace i ostatní moduly vznikají až poté, co je připravena odpovídající databázová architektura.

---

## Nejprve kvalita

Nové funkce nejsou vytvářeny co nejrychleji.

Přednost má správnost návrhu, dlouhodobá udržitelnost a návaznost na již existující části systému.

---

## Evoluční vývoj

MatchMatrix nevzniká jedním velkým návrhem.

Každá nová verze navazuje na zkušenosti získané při používání předchozí verze.

Stejným způsobem vzniká databáze, dokumentace i jednotlivé pracovní postupy.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Filozofie vývoje MatchMatrix“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Základní pravidla vývoje“, která rozvíjí další část řízeného dokumentu.

# 4. Základní pravidla vývoje

Každá nová část systému musí splňovat několik základních pravidel.

* Musí zapadat do existující architektury.
* Musí být zdokumentována.
* Musí být pojmenována podle standardů projektu.
* Musí mít jasně definovaný účel.
* Musí být připravena pro dlouhodobou správu.
* Musí být navržena s ohledem na budoucí rozšiřování.

Tato pravidla platí bez výjimky pro všechny nové databázové objekty, skripty, dashboardy i dokumenty.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Základní pravidla vývoje“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Vývojové prostředí“, která rozvíjí další část řízeného dokumentu.

# Závěr první části

Development Handbook představuje pracovní příručku projektu MatchMatrix. Na rozdíl od dokumentů MASTER, GOVERNANCE nebo ARCHITECTURE se zaměřuje především na každodenní vývoj a praktické standardy práce.

V dalších kapitolách budou podrobně popsány používané nástroje, struktura projektu, pravidla pro tvorbu SQL skriptů, Python aplikací, PowerShell automatizací, databázových objektů i doporučené pracovní postupy při dalším rozšiřování platformy.

# 5. Vývojové prostředí

Stabilní vývojové prostředí představuje jeden ze základních předpokladů dlouhodobého rozvoje projektu MatchMatrix. Již v počátečních fázích vývoje bylo rozhodnuto, že všechny používané nástroje budou standardizovány a jejich role budou jednoznačně definovány.

Cílem není používat co největší množství aplikací.

Naopak.

Každý nástroj má v projektu přesně určenou odpovědnost.

Tím se výrazně snižuje složitost vývoje a usnadňuje se dlouhodobá údržba celého systému.

---

## 5.1 Pracovní stanice PC1

PC1 představuje hlavní ovládací a vývojové pracoviště.

Je určeno především pro:

* návrh architektury a databáze,
* přípravu a kontrolu SQL skriptů,
* vývoj Python, PowerShell a panelových nástrojů,
* správu dokumentace a Git repozitáře,
* řízení práce a kontrolu výsledků,
* ovládání harvestu a vzdálených kroků na PC2,
* práci s DBeaverem, Visual Studio Code a dokumentačním panelem Q3.

PC1 není hlavním místem dlouhodobého produkčního harvestu. Jeho prioritou je bezpečné řízení, vývoj, kontrola a dohledatelnost změn.

---

## 5.2 Databázový a harvest uzel PC2

PC2 představuje hlavní databázový a výpočetní uzel projektu.

Jeho hlavní úlohou je:

* provoz hlavní databáze PostgreSQL,
* dlouhodobý historický harvest,
* ingest a zpracování velkých objemů dat,
* spouštění workerů, parserů a pomocných procesů,
* automatický a plánovaný provoz,
* uchování pracovních dat určených pro další zpracování.

Při spuštění nástroje z PC1 musí být jednoznačně rozlišeno:

* kde běží uživatelské rozhraní,
* kde leží projektový soubor,
* na kterém počítači se spouští příkaz,
* ke které databázi se příkaz připojuje.

Panel Q3 a další přenositelné nástroje mají být hostitelsky nezávislé a použitelné na PC1 i PC2. Nesmějí předpokládat, že hostitelský počítač je současně databázovým serverem.

---

## 5.3 PostgreSQL

Hlavním databázovým systémem projektu je PostgreSQL.

PostgreSQL byl zvolen z několika důvodů.

Především nabízí:

* vysokou stabilitu,
* kvalitní práci s rozsáhlými databázemi,
* podporu moderních datových typů,
* kvalitní indexování,
* výbornou podporu SQL standardu,
* možnost budoucího škálování.

Veškerá produkční data projektu jsou uložena právě zde.

---

## 5.4 DBeaver

Pro každodenní práci s databází je používán DBeaver.

V projektu slouží zejména pro:

* tvorbu SQL skriptů,
* správu databázových objektů,
* analýzu dat,
* tvorbu pohledů,
* kontrolu výsledků,
* export dat.

Veškeré SQL skripty jsou primárně připravovány právě v tomto prostředí.

---

## 5.5 Python

Hlavním programovacím jazykem projektu je Python.

Python je využíván především pro:

* harvest workery,
* parsery,
* merge procesy,
* automatizaci,
* správu providerů,
* OPS nástroje,
* pomocné utility.

Nové funkce jsou vytvářeny přednostně v Pythonu, pokud není důvod použít jinou technologii.

---

## 5.6 Visual Studio Code

Zdrojové kódy projektu jsou vytvářeny a spravovány především ve Visual Studio Code.

Toto prostředí slouží pro:

* vývoj Python skriptů,
* PowerShell skriptů,
* dokumentace,
* konfigurace projektu,
* správu Git repozitáře.

Visual Studio Code představuje hlavní pracovní prostředí vývoje.

---

## 5.7 Docker

Docker slouží pro provoz jednotlivých služeb projektu.

Je využíván především pro:

* databázové služby,
* Redis,
* budoucí pomocné služby,
* izolované testovací prostředí.

Použití Dockeru umožňuje jednodušší správu infrastruktury a snadnější přenos projektu mezi jednotlivými počítači.

---

## 5.8 Git

Veškerý zdrojový kód projektu je verzován pomocí Git.

Git umožňuje:

* historii změn,
* návrat ke starším verzím,
* bezpečný vývoj,
* budoucí spolupráci více vývojářů.

Správa verzí představuje nedílnou součást vývoje MatchMatrix.

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Vývojové prostředí“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. Rozdělení odpovědností jednotlivých nástrojů“, která rozvíjí další část řízeného dokumentu.

# 6. Rozdělení odpovědností jednotlivých nástrojů

V projektu MatchMatrix platí jednoduché pravidlo.

Každý nástroj má svou hlavní odpovědnost.

| Nástroj            | Hlavní účel                    |
| :----------------- | :----------------------------- |
| PostgreSQL         | Produkční databáze             |
| DBeaver            | SQL a databáze                 |
| Python             | Workery, parsery, automatizace |
| Visual Studio Code | Vývoj zdrojových kódů          |
| Docker             | Provoz služeb                  |
| Git                | Verzování                      |
| PC1                | Vývoj a řízení projektu        |
| PC2                | Harvest a dlouhodobé výpočty   |

Toto rozdělení výrazně zjednodušuje orientaci v projektu a zabraňuje překrývání jednotlivých rolí.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. Rozdělení odpovědností jednotlivých nástrojů“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „7. Struktura projektu“, která rozvíjí další část řízeného dokumentu.

# Závěr druhé části

Vývojové prostředí MatchMatrix bylo navrženo tak, aby jednotlivé nástroje tvořily jeden vzájemně propojený celek. Každý z nich má přesně definovanou odpovědnost a jejich společným cílem je zajistit stabilní, přehledný a dlouhodobě udržitelný vývoj platformy.

V další části dokumentu bude popsána adresářová struktura projektu, standard pojmenování souborů, číslování skriptů a pravidla organizace zdrojových kódů.

# 7. Struktura projektu

Jedním z hlavních důvodů dlouhodobé udržitelnosti projektu MatchMatrix je důsledně dodržovaná adresářová struktura. Již od počátku vývoje bylo cílem vytvořit prostředí, ve kterém bude možné rychle nalézt libovolný skript, dokument nebo databázový objekt bez ohledu na velikost projektu.

Adresářová struktura proto není pouze způsob organizace souborů.

Představuje součást architektury systému.

Každá složka má přesně definovaný účel a její obsah musí odpovídat tomuto určení.

---

## 7.1 Hlavní adresáře projektu

Projekt je rozdělen do několika základních částí.

Každá část představuje samostatnou oblast vývoje.

Typická struktura obsahuje zejména:

* databázové skripty,
* harvest workery,
* parsery,
* merge procesy,
* OPS nástroje,
* utility,
* dokumentaci,
* konfigurační soubory,
* testovací nástroje.

Toto rozdělení umožňuje dlouhodobě rozšiřovat projekt bez ztráty přehlednosti.

---

## 7.2 Princip jedné odpovědnosti

Každá složka obsahuje pouze soubory související s jednou oblastí.

Například:

* databázové skripty nejsou ukládány mezi Python workery,
* dokumentace není ukládána mezi SQL skripty,
* pomocné utility nejsou součástí produkčních workerů.

Díky tomu lze velmi rychle určit, kam nový soubor patří.

Stejně snadné je i následné vyhledávání.

---

## 7.3 Dokumentace

Veškerá dokumentace projektu je uložena ve složce **docs**.

Dokumentace představuje samostatnou část projektu.

Není považována za doplněk.

Je součástí architektury MatchMatrix.

Každý významný modul systému musí mít odpovídající dokumentaci.

Stejně tak každé významné architektonické rozhodnutí musí být zaznamenáno.

---

## 7.4 Standard adresářů

Při vytváření nových adresářů platí několik jednoduchých pravidel.

Adresář musí:

* mít jednoznačný název,
* obsahovat pouze související soubory,
* zapadat do existující struktury,
* být dlouhodobě použitelný.

Nevytvářejí se složky pro jednorázové účely.

Pokud některá oblast projektu vyžaduje vlastní adresář, musí být zřejmé, že bude využívána i v budoucnu.

---


## 7.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „7. Struktura projektu“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „8. Standard názvů souborů“, která rozvíjí další část řízeného dokumentu.

# 8. Standard názvů souborů

Jednotné pojmenování souborů výrazně usnadňuje orientaci v projektu.

Každý název musí být čitelný, jednoznačný a pokud možno bez potřeby otevírat samotný soubor.

Název by měl již na první pohled napovědět:

* účel souboru,
* oblast projektu,
* pořadí,
* případně verzi.

---

## 8.1 Číslování skriptů

V průběhu vývoje vznikl jednotný systém číslování skriptů.

Jeho cílem není pouze pořadí.

Číslo současně označuje vývojovou etapu nebo pracovní oblast.

Například:

* databázové audity,
* governance,
* OPS,
* denní práce,
* Source Intelligence,
* další specializované větve.

Jednotné číslování umožňuje velmi rychle určit, do které části projektu konkrétní skript patří.

---

## 8.2 Popisné názvy

Každý soubor musí mít popisný název.

Používají se názvy, které co nejlépe vystihují jeho účel.

Například:

* audit,
* merge,
* parser,
* worker,
* governance,
* dashboard,
* planner,
* report.

Naopak se nepoužívají názvy typu:

* test,
* nový,
* finální,
* verze2,
* kopie.

Takové názvy po několika měsících ztrácejí význam.

---

## 8.3 Aktivní soubory a verzování

Pravidla se liší podle typu artefaktu.

### Řízené dokumenty

Každý řízený dokument má:

* stabilní Document ID,
* jeden aktivní soubor,
* stabilní aktivní název bez čísla verze v názvu,
* číslo verze a stav uvnitř dokumentu,
* historii verzí uvnitř dokumentu,
* předchozí významnou verzi uloženou v řízeném archivu.

Příklad aktivního dokumentu:

```text
MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md
```

Nová verze nepřidává `_v1.2` do aktivního názvu. Aktualizuje obsah, číslo verze a historii uvnitř dokumentu.

Označení `_REVIEW` nesmí dlouhodobě vytvářet druhý paralelní aktivní dokument. Opravená REVIEW verze je zdrojem nové aktivní verze pod stabilním názvem a předchozí soubor se archivuje.

### Skripty a programové soubory

Při předávání opraveného aktivního skriptu se poskytuje kompletní funkční soubor, nikoli pouze výřez nebo patch.

Uživatel si předchozí aktivní variantu přesouvá do historické složky. Bez výslovného požadavku se neposílá ZIP obsahující aktivní i historickou kopii.

Pokud není pro konkrétní větev stanoveno jinak, předávaný aktivní soubor používá dohodnuté aktivní označení, typicky `_V1`, zatímco historické varianty zůstávají mimo aktivní složku.

### Zásada jedné aktivní pravdy

V aktivní složce nemají současně existovat dvě rozdílné varianty, které vypadají jako platný aktivní soubor pro stejný účel.

---

## 8.4 Dokumenty TECH a BOOK

Dokumentace projektu je rozdělena do dvou hlavních edic.

**TECH**

Pracovní technická dokumentace určená především pro každodenní vývoj.

Obsahuje technické informace, standardy, architekturu, pracovní postupy a provozní pravidla.

**BOOK**

Rozšířená dokumentace zachycující historii projektu, důvody jednotlivých rozhodnutí, vývoj architektury, zkušenosti získané během vývoje a dlouhodobou vizi platformy.

Obě edice se vzájemně doplňují.

TECH slouží jako pracovní příručka.

BOOK představuje dlouhodobou znalostní základnu projektu.

---


## 8.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „8. Standard názvů souborů“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „9. Standard skriptů“, která rozvíjí další část řízeného dokumentu.

# Závěr třetí části

Přehledná struktura projektu a jednotné pojmenování souborů patří mezi základní předpoklady dlouhodobě udržitelného vývoje. Díky důslednému dodržování těchto pravidel lze projekt MatchMatrix rozšiřovat bez ztráty orientace i při postupném růstu na stovky skriptů, databázových objektů a dokumentů.

V následující části dokumentu budou popsány standardy pro tvorbu SQL skriptů, Python aplikací, PowerShell automatizací a společná pravidla, která musí splňovat každý nový soubor vytvořený v rámci projektu MatchMatrix.

# 9. Standard skriptů

Každý skript vytvořený v rámci projektu MatchMatrix představuje součást dlouhodobě budované platformy. Není považován za jednorázový nástroj, ale za stavební prvek systému, který může být používán i několik let po svém vytvoření.

Z tohoto důvodu musí všechny skripty splňovat jednotný standard.

Cílem tohoto standardu není omezovat vývoj.

Naopak.

Jeho úkolem je zajistit, aby byly všechny skripty čitelné, snadno udržovatelné a pochopitelné i po delší době.

---

## 9.1 Hlavička skriptu

Každý nový skript musí začínat jednotnou hlavičkou.

Hlavička obsahuje základní informace o účelu skriptu.

Minimálně musí obsahovat:

* název skriptu,
* účel,
* vstupy,
* výstupy,
* návaznost na další části systému,
* způsob spuštění,
* autora nebo původ.

Díky tomu lze rychle pochopit význam skriptu bez nutnosti studovat jeho implementaci.

---

## 9.2 Jedna odpovědnost

Každý skript řeší jednu konkrétní úlohu.

Například:

* jeden worker,
* jeden parser,
* jeden merge proces,
* jeden audit,
* jeden report.

Pokud skript začne plnit více rozdílných funkcí, je vhodné jeho logiku rozdělit do více samostatných částí.

Tento princip zjednodušuje údržbu i budoucí rozšiřování systému.

---

## 9.3 Čitelnost kódu

Veškerý zdrojový kód musí být psán s důrazem na čitelnost.

Preferují se:

* srozumitelné názvy proměnných,
* logické členění funkcí,
* krátké a přehledné bloky,
* komentáře vysvětlující důvod řešení.

Komentáře nemají popisovat jednotlivé příkazy.

Mají vysvětlovat jejich význam.

---

## 9.4 Komentáře

Komentáře představují nedílnou součást zdrojového kódu.

Používají se zejména pro:

* vysvětlení složitější logiky,
* popis algoritmů,
* upozornění na důležité vazby,
* upozornění na známá omezení.

Komentáře musí být aktuální.

Neaktuální komentář je horší než žádný.

---

## 9.5 Logování

Každý důležitý skript musí poskytovat informace o svém průběhu.

Standardně by měl zaznamenávat:

* spuštění,
* dokončení,
* počet zpracovaných záznamů,
* počet chyb,
* případná varování.

Logování významně usnadňuje hledání problémů při dlouhodobém provozu.

---

## 9.6 Ošetření chyb

Každý skript musí počítat s tím, že může dojít k neočekávané situaci.

Například:

* nedostupný provider,
* prázdná odpověď,
* chyba databáze,
* výpadek sítě,
* neplatná data.

Tyto situace musí být zachyceny a odpovídajícím způsobem zaznamenány.

Skript by neměl skončit bez vysvětlení důvodu.

---


## 9.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „9. Standard skriptů“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „10. Standard SQL“, která rozvíjí další část řízeného dokumentu.

# 10. Standard SQL

SQL představuje základ práce s databází MatchMatrix.

Veškeré databázové změny jsou vytvářeny pomocí SQL skriptů.

Proto musí splňovat jednotná pravidla.

---

## 10.1 Každá změna jako skript

Žádná významná databázová změna se neprovádí ručně.

Každá změna musí existovat jako samostatný SQL skript.

Tím je zajištěna:

* opakovatelnost,
* dohledatelnost,
* možnost revize,
* možnost opětovného spuštění.

---

## 10.2 Čitelnost SQL

SQL skripty musí být psány přehledně.

Používá se:

* odsazení,
* logické členění,
* komentáře,
* popis jednotlivých kroků.

Skript musí být čitelný i několik měsíců po svém vytvoření.

---

## 10.3 Bezpečnost databázových změn

Riziková databázová změna používá řízené pořadí:

1. READ ONLY audit,
2. přesná klasifikace kandidátů,
3. `VALIDATE_ONLY` uvnitř transakce,
4. ověření očekávaných počtů a vazeb,
5. rollback validační transakce,
6. samostatný `APPLY`,
7. post-commit READ ONLY audit,
8. aktualizace dokumentace.

`VALIDATE_ONLY` nesmí být pouze orientační SELECT. Musí ověřit skutečnou změnovou logiku v transakci a následně ji vrátit zpět.

Každý rizikový skript musí obsahovat bezpečnostní guardy, například:

* očekávaný počet kandidátů,
* přesný rozsah identifikátorů,
* zákaz zásahu mimo cílovou množinu,
* kontrolu cizích klíčů,
* kontrolu duplicit,
* kontrolu downstream tabulek,
* kontrolu počtů před a po operaci.

Výsledek úspěšného `VALIDATE_ONLY` není možné popsat jako dokončený `APPLY`.

---


## 10.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „10. Standard SQL“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „11. Standard Python“, která rozvíjí další část řízeného dokumentu.

# 11. Standard Python

Python představuje hlavní programovací jazyk projektu.

Používá se zejména pro:

* harvest workery,
* parsery,
* merge procesy,
* audity,
* panely,
* importy,
* dokumentační nástroje,
* automatizaci.

Každý nový Python soubor musí:

* mít hlavičku vysvětlující **CO**, **K ČEMU**, **KDE** a **JAK**,
* používat srozumitelné názvy funkcí a proměnných,
* mít jasně oddělenou konfiguraci, logiku a spuštění,
* ošetřovat chyby a poskytovat čitelný výstup,
* používat logování přiměřené významu procesu,
* neukládat hesla nebo tajné klíče do zdrojového kódu,
* být připraven na opakované spuštění,
* respektovat hranice READ ONLY, VALIDATE_ONLY a APPLY.

## 11.1 Zákaz pevných projektových cest

Nové přenositelné skripty nesmějí používat pevně zapsané projektové cesty typu:

```python
Path(r"C:\MatchMatrix-platform")
```

Kořen projektu se odvozuje z umístění skriptu, konfigurační hodnoty nebo bezpečně předaného parametru, typicky pomocí `pathlib.Path`.

Skript musí být použitelný na PC1 i PC2, pokud jeho účel výslovně nevyžaduje konkrétní hostitelský uzel.

## 11.2 Režimy a návratové kódy

Nástroj, který provádí změny, má mít jednoznačný režim a čitelně jej uvést ve výstupu.

Chyba nesmí být skryta. Skript má skončit nenulovým návratovým kódem, pokud nedokončil požadovanou operaci správně.

## 11.3 Kompletní předávaný soubor

Při opravě se předává celý opravený aktivní soubor. Uživatel nemá být nucen skládat několik dílčích výřezů do původního programu.

---


## 11.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „11. Standard Python“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „12. Standard PowerShell a VBS“, která rozvíjí další část řízeného dokumentu.

# 12. Standard PowerShell a VBS

PowerShell je využíván především pro automatizaci prostředí Windows.

Používá se zejména pro:

* spouštění workerů a panelů,
* plánování úloh,
* správu prostředí,
* vzdálené spuštění kroků na PC2,
* administraci souborů,
* auditní a publikační workflow.

PowerShell skript musí:

* jednoznačně uvést cílový počítač a cílovou cestu,
* správně pracovat s cestami obsahujícími mezery a diakritiku,
* používat `-LiteralPath`, pokud je potřeba zabránit interpretaci speciálních znaků,
* kontrolovat existenci vstupních souborů,
* zastavit se při chybě, nikoli pokračovat s neúplným výsledkem,
* vypsat srozumitelný závěrečný stav.

## 12.1 VBS spouštěče

K panelovým aplikacím a uživatelsky spouštěným nástrojům se dodává také odpovídající `.vbs` spouštěč, pokud je pro běžné používání vhodný.

VBS spouštěč má:

* odvodit cestu k aktivnímu skriptu,
* fungovat bez ručního otevírání terminálu,
* nezobrazovat zbytečné konzolové okno,
* zachovat přenositelnost mezi PC1 a PC2,
* nezakrývat chybu samotného nástroje.

---


## 12.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „12. Standard PowerShell a VBS“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „13. Workflow vývoje“, která rozvíjí další část řízeného dokumentu.

# Závěr čtvrté části

Jednotný standard skriptů představuje jeden z nejdůležitějších předpokladů dlouhodobě udržitelného vývoje projektu MatchMatrix. Díky společným pravidlům lze snadno porozumět i skriptům vytvořeným před delší dobou a bezpečně na ně navazovat při dalším rozšiřování systému.

V další části dokumentu budou popsány standardní pracovní postupy při přidávání nových providerů, databázových tabulek, workerů, parserů, dashboardů i nových architektonických vrstev.

# 13. Workflow vývoje

Vývoj platformy MatchMatrix probíhá podle předem definovaných pracovních postupů. Tyto postupy vznikly během praktického vývoje projektu a jejich cílem je zajistit, aby všechny nové části systému vznikaly jednotným způsobem.

Každá významná změna prochází obdobným životním cyklem.

Díky tomu lze snadno navázat na předchozí práci, kontrolovat kvalitu výsledků a minimalizovat riziko chyb.

---

## 13.1 Přidání nového provideru

Každý nový provider představuje zásah do architektury systému.

Proto jeho zařazení probíhá v několika navazujících krocích.

Nejprve je provedena analýza poskytovatele.

Posuzuje se zejména:

* rozsah dat,
* kvalita dat,
* podporované sporty,
* licence,
* obchodní model,
* limity použití,
* dokumentace,
* dlouhodobá perspektiva.

Následně je provider zařazen do Source Intelligence Layer.

Teprve poté vznikají:

* harvest worker,
* parser,
* merge logika,
* OPS monitoring,
* dokumentace.

Provider není považován za dokončeného, dokud nejsou všechny tyto části připraveny.

---

## 13.2 Přidání nového sportu

Nový sport nevzniká vytvořením několika tabulek.

Nejprve je analyzováno:

* jaká data jsou dostupná,
* kteří provideři sport podporují,
* jaké entity sport obsahuje,
* jaká historická data existují,
* jaké jsou možnosti rozšíření.

Následně se připravuje:

* Core Layer,
* People Layer,
* Media Layer,
* Odds Layer,
* Governance,
* OPS monitoring.

Teprve po dokončení těchto kroků je sport považován za připravený pro produkční harvest.

---

## 13.3 Přidání nové databázové tabulky

Každá nová tabulka musí být navržena s ohledem na celou architekturu systému.

Před vytvořením tabulky se ověřuje:

* zda již obdobná tabulka neexistuje,
* do kterého schématu patří,
* jaké budou vazby,
* jaké budou indexy,
* jaké budou primární klíče,
* jaké budou cizí klíče.

Každá tabulka musí být vytvořena pomocí SQL skriptu.

Ruční vytváření databázových objektů není doporučeno.

---

## 13.4 Přidání nového workeru

Worker představuje samostatnou jednotku harvest pipeline.

Každý nový worker musí mít:

* jednoznačný účel,
* jednotnou hlavičku,
* logování,
* ošetření chyb,
* dokumentaci,
* návaznost na parser.

Worker by neměl obsahovat logiku parseru ani merge procesu.

Každá část pipeline má svou vlastní odpovědnost.

---

## 13.5 Přidání parseru

Parser slouží k převodu dat z providerů do interního datového modelu.

Každý parser:

* pracuje pouze s jedním typem dat,
* převádí hodnoty,
* sjednocuje názvy,
* připravuje data pro merge.

Parser nesmí zapisovat přímo do produkčních tabulek.

Jeho úkolem je připravit kvalitní vstup pro další část pipeline.

---

## 13.6 Přidání merge procesu

Merge představuje jednu z nejdůležitějších částí systému.

Každý nový merge proces musí řešit:

* identifikaci entity,
* canonical mapování,
* aktualizaci dat,
* vznik konfliktů,
* HOLD stavy,
* audit výsledků.

Merge nikdy nesmí bez kontroly přepsat již ověřená produkční data.

---

## 13.7 Přidání OPS dashboardu

Každý nový dashboard musí odpovídat skutečné potřebě.

Dashboard není vytvářen pouze proto, že je možné zobrazit další graf.

Musí přinášet informace využitelné při řízení systému.

Každý dashboard by měl odpovídat na otázky:

* Co se děje?
* Je vše v pořádku?
* Pokud ne, proč?
* Co doporučuje systém udělat?

Tento přístup vytváří z OPS panelu pracovní nástroj, nikoliv pouze vizualizaci databáze.

---


## 13.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „13. Workflow vývoje“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „14. Kontrolní checklist“, která rozvíjí další část řízeného dokumentu.

# 14. Kontrolní checklist

Před dokončením každé významné změny je vhodné projít základní kontrolní seznam.

## Architektura

* Zapadá změna do architektury?
* Nenarušuje existující řešení?
* Je dlouhodobě udržitelná?

---

## Databáze

* Jsou správně navrženy tabulky?
* Jsou vytvořeny indexy?
* Jsou správně definovány vazby?

---

## Skripty

* Obsahují hlavičku?
* Jsou okomentované?
* Je zajištěno logování?
* Jsou ošetřeny chyby?

---

## Dokumentace

* Je změna popsána?
* Je uvedena návaznost?
* Je doplněn changelog?
* Je případně aktualizována governance?

---

## OPS

* Je možné změnu monitorovat?
* Existuje audit?
* Je připraven dashboard?
* Je možné zjistit stav bez SQL?

---


## 14.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „14. Kontrolní checklist“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „15. Doporučený pracovní postup“, která rozvíjí další část řízeného dokumentu.

# 15. Doporučený pracovní postup

Během vývoje projektu se osvědčil následující postup.

1. Analýza problému.

2. Návrh architektury.

3. Návrh databáze.

4. Návrh workflow.

5. Implementace.

6. Testování.

7. Audit.

8. Dokumentace.

9. Zařazení do produkce.

Tento postup významně snižuje počet následných úprav.

---


## 15.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „15. Doporučený pracovní postup“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „16. Standard Git a publikace“, která rozvíjí další část řízeného dokumentu.

# 16. Standard Git a publikace

Git je oficiální historie změn zdrojových souborů projektu.

Před commitem musí být ověřeno:

* co se změnilo,
* které soubory jsou nové,
* které soubory byly archivovány,
* zda nezůstal dočasný soubor,
* zda jsou změny vzájemně související,
* zda dokumentace odpovídá skutečně provedenému stavu.

Do commitu nepatří například:

* dočasné zámkové soubory Wordu `~$...`,
* náhodné exporty mimo určenou exportní složku,
* neověřené pracovní kopie,
* tajné klíče,
* lokální konfigurace obsahující citlivé údaje.

Commit message má stručně a věcně popsat dokončenou změnu. Commit se vytváří až po kontrole, ne pouze proto, že soubor existuje.

---


## 16.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „16. Standard Git a publikace“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „17. Standard panelů a uživatelského rozhraní“, která rozvíjí další část řízeného dokumentu.

# 17. Standard panelů a uživatelského rozhraní

Panel je pracovní nástroj, nikoli pouze vizualizace.

## 17.1 Jazyk

Uživatelské popisky panelu mají být v češtině.

Technické identifikátory, názvy tabulek, názvy sloupců, providerové kódy a další originální systémové hodnoty se nepřekládají tam, kde by překlad poškodil přesnost.

Cílem je:

* česká orientace v ovládání,
* zachování přesných technických názvů v datech,
* možnost zobrazit vysvětlení nebo překlad pomocí slovníku a tooltipu.

## 17.2 Vzhled a ovládání

Preferovaný styl panelu:

* tlumená fialová jako hlavní akcent,
* přehledné české názvy,
* menší KPI bez zbytečně silných rámečků,
* rozklikávací řádky,
* tooltipy,
* tabulky uprostřed pracovního prostoru,
* spodní záložky podle potřeby i ve dvou řadách,
* jeden hlavní posuvník místo několika soupeřících posuvníků.

## 17.3 Hostitelská nezávislost

Panel nesmí předpokládat pevné spuštění pouze na PC1 nebo pouze na PC2.

Musí oddělit:

* hostitelský počítač panelu,
* umístění projektových souborů,
* cílový počítač příkazu,
* databázové připojení.

## 17.4 Ochrana uživatele

Panel má před změnovou operací zobrazit:

* co bude provedeno,
* v jakém režimu,
* nad jakým souborem nebo databází,
* zda jde o kontrolu, návrh, validaci nebo skutečný zápis.

---


## 17.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „17. Standard panelů a uživatelského rozhraní“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „18. Dokumentace, denní zápisy a AI Context“, která rozvíjí další část řízeného dokumentu.

# 18. Dokumentace, denní zápisy a AI Context

Dokumentace vzniká současně s vývojem.

Významná změna není dokončena, pokud chybí:

* aktualizace příslušného hlavního dokumentu,
* denní zápis,
* dokument NAVÁZÁNÍ při ukončení pracovního bloku,
* historie verze,
* potřebný Project Snapshot nebo AI Context.

## 18.1 Denní zápis

Denní zápis zachycuje skutečně provedenou práci, výsledky, přijatá rozhodnutí, problémy a další krok.

Nevytváří se jako formulář, který uživatel ručně vyplňuje desítkami technických údajů. ChatGPT jej sestavuje z průběhu práce a uživatel kontroluje věcnou správnost.

## 18.2 Dokument NAVÁZÁNÍ

NAV dokument shrnuje stav potřebný pro pokračování v novém chatu.

Musí obsahovat zejména:

* co bylo dokončeno,
* co bylo pouze validováno,
* co zůstává otevřené,
* které soubory a skripty jsou aktivní,
* přesný další krok,
* bezpečnostní omezení.

## 18.3 Historie chatů

Historie komunikace je důkazní a kontextový zdroj.

Informace z chatu se nepřebírá automaticky. Ověřuje se proti:

* repozitáři,
* databázi,
* auditům,
* pozdějším rozhodnutím,
* aktivní dokumentaci.

Novější ověřený Project Snapshot má přednost před starším NAV dokumentem nebo denním zápisem.

## 18.4 Q3 dokumentační workflow

Dokumentační workflow používá fáze:

1. vybrat a analyzovat,
2. opravit a zkontrolovat,
3. vytvořit a schválit,
4. publikovat.

Používané nástroje zahrnují:

* A17 – audit standardu,
* A18 – standardizační návrh,
* A19 – kontrolu mapování,
* A20 – builder,
* A24 – import do dokumentační databáze.

---


## 18.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „18. Dokumentace, denní zápisy a AI Context“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „19. Definition of Done“, která rozvíjí další část řízeného dokumentu.

# 19. Definition of Done

Úkol se považuje za dokončený teprve tehdy, když jsou splněny všechny relevantní podmínky.

## Kód a skripty

* aktivní soubor je úplný,
* syntaxe a spuštění byly ověřeny,
* chyby jsou ošetřeny,
* cesty nejsou zbytečně pevně zapsané,
* logování a návratový stav jsou srozumitelné.

## Databáze

* existuje audit vstupního stavu,
* změna má přesný rozsah,
* riziková operace prošla `VALIDATE_ONLY`,
* APPLY byl proveden samostatně,
* proběhl post-commit audit,
* není zaměněn rollback s trvalou změnou.

## Dokumentace

* aktivní Document ID a název jsou správné,
* existuje jediný aktivní soubor,
* historie verze je doplněna,
* starší významná verze je archivována,
* dokumentace odpovídá skutečnosti.

## Git

* dočasné soubory byly odstraněny,
* změny byly zkontrolovány,
* commit obsahuje související celek,
* repozitář je po publikaci synchronizován.

---


## 19.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „19. Definition of Done“ v rámci dokumentu MM-DOC-800 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# 20. Závěr dokumentu

MATCHMATRIX DEVELOPMENT HANDBOOK představuje praktickou příručku pro každodenní vývoj platformy.

Nejde o obecnou metodiku programování. Dokument zachycuje konkrétní pravidla, která vznikla při skutečné práci na databázi, harvest pipeline, panelech, dokumentaci a provozu na PC1 a PC2.

Jeho hlavní zásadou je, že správný výsledek nestačí vytvořit. Musí být také:

* bezpečně ověřen,
* opakovatelný,
* dohledatelný,
* správně uložený,
* zdokumentovaný,
* připravený pro další navázání člověkem i AI.

---

# Stav dokumentu

**Dokument:** MM-DOC-800 – MATCHMATRIX DEVELOPMENT HANDBOOK
**Edice:** TECH
**Verze:** 1.2
**Stav:** REVIEW
**Aktivní soubor:** `docs/08_DEVELOPMENT/MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md`

---

## Navazující dokument

> **MM-DOC-900 – MATCHMATRIX DENNÍ ZÁPISY (TECH)**

MM-DOC-900 stanovuje pravidla pracovní paměti projektu, denních zápisů a předávání kontextu mezi jednotlivými pracovními etapami.

---

# AI CONTEXT

**Role dokumentu:** Hlavní praktická technická příručka vývoje MatchMatrix.

**Klíčová pravidla:**

* PC1 je primárně ovládací a vývojové pracoviště.
* PC2 je primárně databázový a harvest uzel.
* Python nástroje nesmějí bez důvodu používat pevné projektové cesty.
* Panelové nástroje mají mít VBS spouštěče a české uživatelské popisky.
* Rizikové DB změny používají READ ONLY → VALIDATE_ONLY → APPLY → post-commit audit.
* Řízený dokument má jeden aktivní soubor se stabilním názvem.
* Při opravě skriptu se předává celý aktivní soubor.

---

# PROJECT SNAPSHOT

* Projektový root: `C:\MatchMatrix-platform`.
* Hlavní databáze a harvest jsou provozovány na PC2.
* Q3 dokumentační panel je navržen jako hostitelsky nezávislý.
* Dokumentační workflow používá A17, A18, A19, A20 a A24.
* Historie chatů byla převedena do extrakční matice a používá se jako ověřovaný zdroj kontextu.
* Aktivní hlavní dokumenty používají identity MM-DOC-000, 100, 200, 300, 800 a 900.

---

# CURRENT STATUS

- Development Standards: ACTIVE
- SQL Safety Workflow: ACTIVE
- Python Standards: ACTIVE
- PowerShell/VBS Workflow: ACTIVE
- Q3 Documentation Workflow: IMPLEMENTED / ACTIVE DEVELOPMENT
- AI Assisted Development: ACTIVE WITH HUMAN REVIEW
- CI/CD: OPEN

---

# OPEN QUESTIONS

- budoucí CI/CD architektura,
- automatizované testování panelů a vzdálených kroků,
- jednotný linter a kontrola hlaviček skriptů,
- automatická synchronizace Project Snapshotu,
- další rozvoj Documentation Management System.

---

# NEXT STEP

Aktualizovat MM-DOC-900 podle současného systému denních zápisů, NAV dokumentů, šablon a AI Context workflow.
