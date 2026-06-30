# MM-DOC-800

# MATCHMATRIX DEVELOPMENT HANDBOOK (TECH)

---

## Informace o dokumentu

| Položka              | Hodnota                                                                    |
| :------------------- | :------------------------------------------------------------------------- |
| Název dokumentu      | MATCHMATRIX DEVELOPMENT HANDBOOK                                           |
| Označení             | MM-DOC-800                                                                 |
| Edice                | TECH                                                                       |
| Verze                | 1.1                                                       |
| Stav                 | REVIEW                                                               |
| Autor projektu       | Petr                                                                       |
| Technická spolupráce | OpenAI ChatGPT                                                             |
| Primární formát      | Markdown (.md)                                                             |
| Umístění             | `docs/04_DEVELOPMENT_HANDBOOK/04_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH.md` |

---

# Motto

> **Kvalitní software nevzniká náhodou. Vzniká dodržováním stejných pravidel každý den.**

---

# Obsah

1. Úvod
2. Účel dokumentu
3. Filozofie vývoje MatchMatrix
4. Základní pravidla vývoje
5. Vývojové prostředí
6. Struktura projektu
7. Standard adresářů
8. Standard názvů souborů
9. Standard skriptů
10. Standard databáze
11. Workflow vývoje
12. Kontrolní checklist
13. Závěr

---

---

# 0. Smysl Development Handbook

Development Handbook sjednocuje každodenní pravidla vývoje platformy MatchMatrix. Jeho cílem je zajistit jednotný, dlouhodobě udržitelný vývoj připravený pro spolupráci lidí i AI.

---

# 1. Úvod

Vývoj platformy MatchMatrix se během času rozrostl z několika skriptů na rozsáhlý projekt obsahující databázové vrstvy, harvest pipeline, governance mechanismy, OPS dashboardy, automatizační procesy i vlastní dokumentační systém.

S rostoucím rozsahem projektu se ukázalo, že samotná znalost programování nestačí.

Stejně důležité je dodržování jednotných pracovních postupů.

Právě proto vznikl tento dokument.

Jeho úkolem je popsat standardy, které jsou při vývoji MatchMatrix používány každý den.

Nejde o obecnou příručku programování.

Jedná se o pracovní manuál vytvořený přímo pro potřeby tohoto projektu.

---

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

# 5.1 Pracovní stanice PC1

PC1 představuje hlavní vývojové pracoviště.

Je určeno především pro:

* návrh databáze,
* tvorbu SQL skriptů,
* vývoj aplikace,
* správu dokumentace,
* správu projektu,
* administraci databáze,
* řízení harvestu,
* kontrolu OPS panelu.

PC1 není určeno pro dlouhodobé výpočetně náročné úlohy.

Jeho hlavním cílem je poskytovat stabilní pracovní prostředí pro každodenní vývoj.

---

# 5.2 Harvest Server PC2

S rostoucím množstvím historických dat bylo rozhodnuto oddělit běžný vývoj od dlouhodobého harvestu.

Vznikl samostatný server PC2.

Jeho hlavní úlohou je:

* historický harvest,
* dlouhodobé ingest procesy,
* spouštění workerů,
* testování providerů,
* zpracování velkých objemů dat,
* budoucí automatický provoz.

Oddělením těchto činností od vývojového prostředí došlo ke zvýšení stability i výkonu celé platformy.

Tato architektura vytváří základ pro budoucí rozšiřování o další výpočetní uzly.

---

# 5.3 PostgreSQL

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

# 5.4 DBeaver

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

# 5.5 Python

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

# 5.6 Visual Studio Code

Zdrojové kódy projektu jsou vytvářeny a spravovány především ve Visual Studio Code.

Toto prostředí slouží pro:

* vývoj Python skriptů,
* PowerShell skriptů,
* dokumentace,
* konfigurace projektu,
* správu Git repozitáře.

Visual Studio Code představuje hlavní pracovní prostředí vývoje.

---

# 5.7 Docker

Docker slouží pro provoz jednotlivých služeb projektu.

Je využíván především pro:

* databázové služby,
* Redis,
* budoucí pomocné služby,
* izolované testovací prostředí.

Použití Dockeru umožňuje jednodušší správu infrastruktury a snadnější přenos projektu mezi jednotlivými počítači.

---

# 5.8 Git

Veškerý zdrojový kód projektu je verzován pomocí Git.

Git umožňuje:

* historii změn,
* návrat ke starším verzím,
* bezpečný vývoj,
* budoucí spolupráci více vývojářů.

Správa verzí představuje nedílnou součást vývoje MatchMatrix.

---

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

# Závěr druhé části

Vývojové prostředí MatchMatrix bylo navrženo tak, aby jednotlivé nástroje tvořily jeden vzájemně propojený celek. Každý z nich má přesně definovanou odpovědnost a jejich společným cílem je zajistit stabilní, přehledný a dlouhodobě udržitelný vývoj platformy.

V další části dokumentu bude popsána adresářová struktura projektu, standard pojmenování souborů, číslování skriptů a pravidla organizace zdrojových kódů.

# 7. Struktura projektu

Jedním z hlavních důvodů dlouhodobé udržitelnosti projektu MatchMatrix je důsledně dodržovaná adresářová struktura. Již od počátku vývoje bylo cílem vytvořit prostředí, ve kterém bude možné rychle nalézt libovolný skript, dokument nebo databázový objekt bez ohledu na velikost projektu.

Adresářová struktura proto není pouze způsob organizace souborů.

Představuje součást architektury systému.

Každá složka má přesně definovaný účel a její obsah musí odpovídat tomuto určení.

---

# 7.1 Hlavní adresáře projektu

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

# 7.2 Princip jedné odpovědnosti

Každá složka obsahuje pouze soubory související s jednou oblastí.

Například:

* databázové skripty nejsou ukládány mezi Python workery,
* dokumentace není ukládána mezi SQL skripty,
* pomocné utility nejsou součástí produkčních workerů.

Díky tomu lze velmi rychle určit, kam nový soubor patří.

Stejně snadné je i následné vyhledávání.

---

# 7.3 Dokumentace

Veškerá dokumentace projektu je uložena ve složce **docs**.

Dokumentace představuje samostatnou část projektu.

Není považována za doplněk.

Je součástí architektury MatchMatrix.

Každý významný modul systému musí mít odpovídající dokumentaci.

Stejně tak každé významné architektonické rozhodnutí musí být zaznamenáno.

---

# 7.4 Standard adresářů

Při vytváření nových adresářů platí několik jednoduchých pravidel.

Adresář musí:

* mít jednoznačný název,
* obsahovat pouze související soubory,
* zapadat do existující struktury,
* být dlouhodobě použitelný.

Nevytvářejí se složky pro jednorázové účely.

Pokud některá oblast projektu vyžaduje vlastní adresář, musí být zřejmé, že bude využívána i v budoucnu.

---

# 8. Standard názvů souborů

Jednotné pojmenování souborů výrazně usnadňuje orientaci v projektu.

Každý název musí být čitelný, jednoznačný a pokud možno bez potřeby otevírat samotný soubor.

Název by měl již na první pohled napovědět:

* účel souboru,
* oblast projektu,
* pořadí,
* případně verzi.

---

# 8.1 Číslování skriptů

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

# 8.2 Popisné názvy

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

# 8.3 Verze souborů

Pokud vzniká nová významná verze souboru, je vytvářena jako nová verze.

Nepřepisuje se původní soubor bez důvodu.

To umožňuje:

* dohledání historie,
* porovnání změn,
* bezpečný návrat ke starší verzi.

Verzování představuje důležitou součást dlouhodobého vývoje projektu.

---

# 8.4 Dokumenty TECH a BOOK

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

# 9.1 Hlavička skriptu

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

# 9.2 Jedna odpovědnost

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

# 9.3 Čitelnost kódu

Veškerý zdrojový kód musí být psán s důrazem na čitelnost.

Preferují se:

* srozumitelné názvy proměnných,
* logické členění funkcí,
* krátké a přehledné bloky,
* komentáře vysvětlující důvod řešení.

Komentáře nemají popisovat jednotlivé příkazy.

Mají vysvětlovat jejich význam.

---

# 9.4 Komentáře

Komentáře představují nedílnou součást zdrojového kódu.

Používají se zejména pro:

* vysvětlení složitější logiky,
* popis algoritmů,
* upozornění na důležité vazby,
* upozornění na známá omezení.

Komentáře musí být aktuální.

Neaktuální komentář je horší než žádný.

---

# 9.5 Logování

Každý důležitý skript musí poskytovat informace o svém průběhu.

Standardně by měl zaznamenávat:

* spuštění,
* dokončení,
* počet zpracovaných záznamů,
* počet chyb,
* případná varování.

Logování významně usnadňuje hledání problémů při dlouhodobém provozu.

---

# 9.6 Ošetření chyb

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

# 10. Standard SQL

SQL představuje základ práce s databází MatchMatrix.

Veškeré databázové změny jsou vytvářeny pomocí SQL skriptů.

Proto musí splňovat jednotná pravidla.

---

# 10.1 Každá změna jako skript

Žádná významná databázová změna se neprovádí ručně.

Každá změna musí existovat jako samostatný SQL skript.

Tím je zajištěna:

* opakovatelnost,
* dohledatelnost,
* možnost revize,
* možnost opětovného spuštění.

---

# 10.2 Čitelnost SQL

SQL skripty musí být psány přehledně.

Používá se:

* odsazení,
* logické členění,
* komentáře,
* popis jednotlivých kroků.

Skript musí být čitelný i několik měsíců po svém vytvoření.

---

# 10.3 Bezpečnost

Před každou významnější změnou databáze musí být ověřeno:

* jaký objekt bude změněn,
* jaký bude dopad,
* zda nedojde ke ztrátě dat.

V případě rizikových operací je doporučeno provést zálohu nebo nejprve změnu otestovat na testovacím prostředí.

---

# 11. Standard Python

Python představuje hlavní programovací jazyk projektu.

Všechny nové workery, parsery i automatizační nástroje se vytvářejí podle společných pravidel.

Každý Python skript by měl:

* mít jednotnou hlavičku,
* používat srozumitelnou strukturu,
* obsahovat logování,
* ošetřovat chyby,
* být připraven pro budoucí rozšiřování.

Významnou součástí je také používání společných pomocných knihoven tam, kde je to možné.

---

# 12. Standard PowerShell

PowerShell je využíván především pro automatizaci prostředí Windows.

Používá se zejména pro:

* spouštění workerů,
* plánování úloh,
* správu prostředí,
* administraci serverů,
* pomocné utility.

Stejně jako ostatní skripty musí i PowerShell dodržovat jednotný standard pojmenování, komentářů a logování.

---

# Závěr čtvrté části

Jednotný standard skriptů představuje jeden z nejdůležitějších předpokladů dlouhodobě udržitelného vývoje projektu MatchMatrix. Díky společným pravidlům lze snadno porozumět i skriptům vytvořeným před delší dobou a bezpečně na ně navazovat při dalším rozšiřování systému.

V další části dokumentu budou popsány standardní pracovní postupy při přidávání nových providerů, databázových tabulek, workerů, parserů, dashboardů i nových architektonických vrstev.

# 13. Workflow vývoje

Vývoj platformy MatchMatrix probíhá podle předem definovaných pracovních postupů. Tyto postupy vznikly během praktického vývoje projektu a jejich cílem je zajistit, aby všechny nové části systému vznikaly jednotným způsobem.

Každá významná změna prochází obdobným životním cyklem.

Díky tomu lze snadno navázat na předchozí práci, kontrolovat kvalitu výsledků a minimalizovat riziko chyb.

---

# 13.1 Přidání nového provideru

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

# 13.2 Přidání nového sportu

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

# 13.3 Přidání nové databázové tabulky

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

# 13.4 Přidání nového workeru

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

# 13.5 Přidání parseru

Parser slouží k převodu dat z providerů do interního datového modelu.

Každý parser:

* pracuje pouze s jedním typem dat,
* převádí hodnoty,
* sjednocuje názvy,
* připravuje data pro merge.

Parser nesmí zapisovat přímo do produkčních tabulek.

Jeho úkolem je připravit kvalitní vstup pro další část pipeline.

---

# 13.6 Přidání merge procesu

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

# 13.7 Přidání OPS dashboardu

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

# 16. Závěr dokumentu

MATCHMATRIX DEVELOPMENT HANDBOOK představuje pracovní příručku pro každodenní vývoj platformy.

Nejde o obecnou metodiku programování.

Dokument zachycuje konkrétní standardy, které byly vytvořeny během vývoje MatchMatrix a které se osvědčily při budování rozsáhlé vícevrstvé sportovní databáze.

Dodržování těchto pravidel zajišťuje, že jednotlivé části systému vznikají jednotným způsobem, jsou dlouhodobě udržitelné a lze na ně bezpečně navazovat při dalším rozšiřování platformy.

---

# Stav dokumentu

**Dokument:** MM-DOC-800 – MATCHMATRIX DEVELOPMENT HANDBOOK

**Edice:** TECH

**Verze:** 1.0 – První pracovní verze

**Stav:** Připraven k první revizi

---

## Navazující dokument

Dalším dokumentem dokumentační řady bude:

> **MM-DOC-005 – MATCHMATRIX DENNÍ ZÁPISY (TECH)**

Tento dokument stanoví jednotný standard pro vedení denních zápisů projektu. Popíše jejich strukturu, obsah, pravidla zapisování, způsob navazování na předchozí práci i jejich využití při dlouhodobém řízení vývoje MatchMatrix. Denní zápisy budou představovat oficiální kroniku každodenního vývoje projektu a současně jeden z hlavních podkladů pro budoucí BOOK dokumentaci.



---
# AI CONTEXT

Role dokumentu: Hlavní technická příručka vývoje MatchMatrix.

# PROJECT SNAPSHOT

Připraveno pro Documentation Management System.

# CURRENT STATUS

- Development Standards: ACTIVE
- SQL Standards: ACTIVE
- Python Standards: ACTIVE
- AI Assisted Development: DESIGN

# OPEN QUESTIONS

- CI/CD
- AI Pair Programming

# NEXT STEP

MM-DOC-900 – MatchMatrix Daily Log.
