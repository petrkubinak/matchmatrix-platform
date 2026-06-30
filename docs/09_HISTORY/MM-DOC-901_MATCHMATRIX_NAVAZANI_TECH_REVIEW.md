# MM-DOC-901

# MATCHMATRIX NAVÁZÁNÍ

## TECH EDITION

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DOC-901 |
| Název | MatchMatrix Navázání |
| Edice | MM-DOC TECH |
| Verze | 1.1 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Původní pracovní označení | MM-DOC-006 |
| Umístění | `docs/09_HISTORY/MM-DOC-901_MATCHMATRIX_NAVAZANI_TECH.md` |

## Poznámka k přečíslování

Původní pracovní označení dokumentu bylo **MM-DOC-006**. V nové dokumentační struktuře je dokument zařazen jako **MM-DOC-901**, protože tvoří součást řady provozní historie a kontinuity projektu společně s dokumenty:

- **MM-DOC-900 – MatchMatrix Denní zápisy**,
- **MM-DOC-902 – MatchMatrix Changelog**,
- **MM-DOC-903 – MatchMatrix Architectural Decisions**.

Přečíslování nemění účel ani odborný obsah dokumentu. Zajišťuje jeho správné zařazení do aktuálního dokumentačního systému MatchMatrix.

## Motto

> **Každé ukončení práce je současně přípravou na její pokračování.**

## Účel dokumentu

Tento dokument definuje roli, strukturu, životní cyklus a pravidla používání dokumentů **NAVÁZÁNÍ** v projektu MatchMatrix. Dokument NAVÁZÁNÍ představuje spojovací článek mezi jednotlivými pracovními etapami. Jeho hlavním cílem je umožnit plynulé pokračování vývoje bez nutnosti znovu analyzovat historii projektu.

## Rozsah dokumentu

Dokument upravuje:

- smysl a filozofii navazování práce,
- základní principy navazovacího dokumentu,
- životní cyklus navázání,
- povinné části konkrétního navázání,
- vztah k ostatní dokumentaci,
- pravidla správy a archivace,
- budoucí vazby na Git, milestone a Documentation Management System.

## Cílová skupina

- autor a architekt projektu,
- vývojáři,
- databázoví specialisté,
- správci provozu a OPS,
- správci dokumentace,
- budoucí spolupracovníci,
- systémy umělé inteligence navazující na předchozí práci.

## Související dokumenty

- **MM-DOC-000 – MatchMatrix Documentation Framework**
- **MM-DOC-100 – MatchMatrix Master**
- **MM-DOC-200 – MatchMatrix Governance**
- **MM-DOC-300 – MatchMatrix Architecture**
- **MM-DOC-800 – MatchMatrix Development Handbook**
- **MM-DOC-900 – MatchMatrix Denní zápisy**
- **MM-DOC-902 – MatchMatrix Changelog**
- **MM-DOC-903 – MatchMatrix Architectural Decisions**
- **MM-STD-001 až MM-STD-009**
- **MM-REF-001 – Slovník pojmů MatchMatrix**

## Zdroje REVIEW

REVIEW vychází z původního dokumentu MM-DOC-006 a z aktuálních dokumentačních zdrojů MM-DOC-000, MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DOC-900, MM-STD-001 až MM-STD-009 a MM-REF-001. Při rozdílu mezi původním pracovním označením a novou dokumentační řadou bylo použito aktuální označení MM-DOC-901.

## Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026 | DRAFT | První pracovní verze vedená pod označením MM-DOC-006. |
| 1.1 | 2026-06-29 | REVIEW | Přečíslování na MM-DOC-901, sjednocení struktury, terminologie a vazeb, doplnění kontextových sekcí podle MM-STD-009. |

# Obsah

1. Úvod
2. Filozofie navazování
3. Základní principy
4. Životní cyklus navázání
5. Povinné části konkrétního navázání
6. Doporučené pracovní postupy
7. Vztah k ostatní dokumentaci
8. Správa, verzování a archivace
9. Dlouhodobý význam a budoucí rozvoj
10. Závěr dokumentu
11. AI CONTEXT
12. PROJECT SNAPSHOT
13. DATABASE SNAPSHOT
14. CURRENT STATUS
15. OPEN QUESTIONS
16. NEXT STEP

# 0. Smysl dokumentu NAVÁZÁNÍ

Dokument NAVÁZÁNÍ chrání kontinuitu vývoje MatchMatrix. Jeho hlavní hodnotou je schopnost přesně zachytit aktuální stav projektu, bezpečně ukončit pracovní etapu a připravit jednoznačný výchozí bod pro pokračování práce. NAVÁZÁNÍ není náhradou denních zápisů, strategických dokumentů, architektury ani changelogu. Propojuje je do jednoho pracovního vstupu zaměřeného na otázku:

> **Kde se právě nacházíme a jaký bude další krok?**

# 1. Úvod

Jedním z největších problémů dlouhodobých projektů je ztráta souvislostí mezi jednotlivými pracovními etapami. Po několika dnech nebo týdnech bývá obtížné přesně určit:

- na čem se naposledy pracovalo,
- jaká rozhodnutí byla přijata,
- které úkoly byly dokončeny,
- které problémy zůstaly otevřené,
- jaký měl být další krok.

Projekt MatchMatrix tento problém řeší samostatným systémem navazovacích dokumentů. Jejich úkolem není opakovat denní zápisy. Jejich úkolem je připravit co nejlepší výchozí bod pro další pokračování práce. Dobře připravené navázání umožňuje začít další pracovní etapu během několika minut. Tím šetří čas a snižuje riziko opakování již vyřešených problémů.

## 1.1 Přínos pro projekt

Dokument NAVÁZÁNÍ:

- omezuje ztrátu pracovního kontextu,
- urychluje zahájení další etapy,
- snižuje závislost na osobní paměti,
- podporuje předávání práce mezi lidmi a AI,
- propojuje aktuální stav s dlouhodobou dokumentací.

## 1.2 Závěr kapitoly

NAVÁZÁNÍ představuje pracovní most mezi ukončenou a následující etapou. Jeho úkolem je zachytit současný stav, nikoliv opakovat celou historii projektu. Na tuto kapitolu navazuje vymezení filozofie navazování.

# 2. Filozofie navazování

Navázání není pracovní plán. Není ani denní zápis. Představuje stručný, ale přesný popis aktuálního stavu projektu. Každé navázání zachycuje pouze informace potřebné pro pokračování práce. Historie zůstává v denních zápisech. Strategie zůstává v dokumentu MASTER. Pravidla zůstávají v dokumentu GOVERNANCE a ve standardech MM-STD. Architektura zůstává v dokumentu ARCHITECTURE. Praktické postupy zůstávají v DEVELOPMENT HANDBOOK. Významné změny zůstávají v CHANGELOGU. Dlouhodobá architektonická rozhodnutí zůstávají v ARCHITECTURAL DECISIONS. NAVÁZÁNÍ tyto informace propojuje do jednoho aktuálního výchozího bodu.

## 2.1 Jedno referenční místo

NAVÁZÁNÍ nesmí vytvářet trvalou duplicitní definici informace, která má své referenční místo v jiném dokumentu. Pokud je pro pokračování práce nutné takovou informaci uvést, zapíše se stručně a doplní se odkaz na její referenční dokument nebo technický zdroj.

## 2.2 Závěr kapitoly

Filozofie navazování odděluje aktuální pracovní stav od podrobné historie, strategie, architektury a governance. Díky tomu zůstává dokument stručný, praktický a jednoznačný. Na tuto kapitolu navazují základní principy kvality navázání.

# 3. Základní principy

Každé konkrétní navázání musí být:

- **aktuální** – odpovídá skutečnému stavu v okamžiku ukončení etapy,
- **jednoznačné** – neobsahuje nejasné nebo protichůdné formulace,
- **praktické** – umožňuje zahájit další práci bez rozsáhlého dohledávání,
- **ověřitelné** – uvádí relevantní zdroje, soubory, objekty nebo výsledky,
- **stručné** – neobsahuje dlouhou historii dostupnou v jiných dokumentech,
- **zaměřené na pokračování** – určuje hlavní další krok,
- **časově ukotvené** – obsahuje datum a pracovní etapu,
- **stavově konzistentní** – rozlišuje dokončené, rozpracované, blokované a plánované oblasti.

## 3.1 Faktický obsah

Do navázání se zapisují pouze skutečně provedené nebo ověřené práce. Plánované kroky musí být zřetelně odděleny od dokončených výsledků. Předpoklad nebo pracovní hypotéza nesmí být prezentována jako potvrzený stav.

## 3.2 Jeden hlavní další krok

Každé navázání musí určit jeden hlavní další krok. Může obsahovat více otevřených úkolů, ale musí být zřejmé, kterým z nich má následující pracovní etapa začít.

## 3.3 Přiměřený rozsah

Navázání má být možné přečíst během několika minut. Podrobné logy, úplné SQL výstupy a dlouhé seznamy testů zůstávají v denních zápisech nebo specializované dokumentaci. Do NAVÁZÁNÍ se uvádí jejich závěr, stav a odkaz.

## 3.4 Závěr kapitoly

Základní principy zajišťují, že navázání bude důvěryhodné, rychle čitelné a přímo použitelné. Další kapitola popisuje jeho životní cyklus.

# 4. Životní cyklus navázání

Navázání vzniká na konci významnější pracovní etapy. Jeho vytvoření není administrativní povinností, ale součástí samotného vývoje projektu. Každé navázání představuje řízený přechod mezi dvěma pracovními obdobími.

## 4.1 Ukončení pracovní etapy

Na konci pracovní etapy se provede krátké zhodnocení. Posuzuje se zejména:

- co bylo dokončeno,
- co zůstává rozpracováno,
- jaký je aktuální stav systému,
- jaké výsledky byly potvrzeny,
- jaké problémy zůstávají otevřené,
- zda byla přijata nová architektonická nebo governance rozhodnutí,
- zda je potřeba aktualizovat další dokumentaci.

Teprve poté vzniká konkrétní navázání.

## 4.2 Vytvoření navázání

Navázání se vytváří z ověřených zdrojů, například z:

- posledního denního zápisu,
- výsledků testů a auditů,
- databázových výstupů,
- zdrojových souborů a Git historie,
- stavu OPS a runtime procesů,
- platných referenčních dokumentů.

Neobsahuje celý průběh práce. Obsahuje pouze informace potřebné pro bezpečné pokračování.

## 4.3 Zahájení další etapy

Nová pracovní etapa začíná přečtením posledního platného navázání pro danou oblast. Před pokračováním se ověří, zda od jeho vytvoření nedošlo ke změně skutečného stavu. Pokud je navázání stále platné, práce pokračuje uvedeným hlavním krokem. Tím se omezují duplicitní úkoly a opakovaná analýza již vyřešených problémů.

## 4.4 Ukončení platnosti

Konkrétní navázání přestává být aktuálním pracovním vstupem, jakmile:

- je dokončen jeho hlavní další krok,
- vznikne novější navázání,
- dojde k významné změně stavu,
- je pracovní etapa uzavřena nebo nahrazena jiným směrem.

Starší záznam zůstává zachován jako součást historie projektu.

## 4.5 Závěr kapitoly

Životní cyklus navázání začíná ověřením ukončované etapy a končí jeho nahrazením novějším pracovním stavem. Další kapitola definuje povinné části konkrétního navázání.

# 5. Povinné části konkrétního navázání

Každé konkrétní navázání používá jednotnou strukturu. Díky tomu lze rychle nalézt potřebné informace a předat je lidem i systémům AI.

## 5.1 Identifikace

Každé navázání obsahuje minimálně:

- datum a čas uzavření,
- pracovní oblast,
- název pracovní etapy,
- autora nebo zdroj vytvoření,
- vazbu na předchozí denní zápis nebo pracovní záznam,
- stav navázání.

## 5.2 Výchozí kontext

Stručně popisuje:

- na jakou práci se navazovalo,
- jaký byl cíl etapy,
- které dokumenty, skripty nebo databázové objekty tvořily hlavní kontext.

Nemá opakovat celou historii.

## 5.3 Aktuální stav

Obsahuje podle charakteru práce například:

- dokončené etapy,
- rozpracované části,
- aktuální milestone,
- stav databáze,
- stav dokumentace,
- stav providerů,
- stav workerů a front,
- stav testů a auditů.

Tato část musí vycházet z posledních dostupných ověřených informací.

## 5.4 Co bylo dokončeno

Uvádějí se významné výsledky poslední pracovní etapy, například:

- dokončené dokumenty,
- nové nebo upravené skripty,
- nové databázové objekty,
- dokončené audity,
- provedené migrace,
- potvrzená rozhodnutí,
- ověřené výsledky testů.

Nejde o seznam všech drobných změn.

## 5.5 Co zůstává rozpracováno

Musí být zřejmé:

- co již bylo provedeno,
- co ještě chybí,
- v jakém bodě byla práce přerušena,
- které soubory, objekty nebo příkazy mají být použity při pokračování.

## 5.6 Otevřené úkoly

Otevřené úkoly se doporučuje seřadit podle priority:

- **CRITICAL** – blokuje bezpečné pokračování,
- **HIGH** – má být řešeno v nejbližší etapě,
- **MEDIUM** – důležité, ale neblokující,
- **LOW** – odložitelné nebo rozvojové.

## 5.7 Rizika a upozornění

Zapisují se známá omezení a rizika, například:

- čekající rozhodnutí,
- závislost na providerovi,
- plánovaná změna architektury,
- nedokončené testování,
- technický dluh,
- neověřený předpoklad,
- riziko nekonzistence dat,
- omezení API, licence nebo provozního prostředí.

## 5.8 Přijatá rozhodnutí

Významná rozhodnutí se uvádějí samostatně. Pokud rozhodnutí dlouhodobě ovlivňuje architekturu, governance nebo standardy, musí být následně promítnuto do příslušného referenčního dokumentu a případně do **MM-DOC-903 – Architectural Decisions**.

## 5.9 Ověřené zdroje a odkazy

Podle charakteru práce se uvádějí:

- názvy a umístění souborů,
- Git commit nebo větev,
- SQL skripty,
- Python a PowerShell skripty,
- databázové tabulky, pohledy a funkce,
- výstupy auditů,
- související Document ID.

## 5.10 Doporučený další krok

Tato část obsahuje jeden hlavní krok, kterým má následující pracovní etapa začít. Nejde o kompletní plán. Uvádí se nejbližší konkrétní a proveditelná akce. Podle potřeby obsahuje:

- přesný cíl,
- název souboru nebo objektu,
- umístění,
- vstupní příkaz nebo dotaz,
- očekávaný výsledek,
- kontrolu úspěchu.

## 5.11 Závěr kapitoly

Jednotná struktura navázání zajišťuje, že každý záznam obsahuje aktuální kontext, ověřený stav, otevřená rizika a jednoznačný další krok. Následující kapitola převádí tuto strukturu do pracovního postupu.

# 6. Doporučené pracovní postupy

## 6.1 Vytváření bezprostředně po práci

Navázání má vzniknout bezprostředně po dokončení nebo přerušení pracovní etapy. Nemá být vytvářeno až po několika dnech, protože v takovém případě roste riziko nepřesností a vynechání důležitých rozhodnutí.

## 6.2 Použití ověřených výsledků

Navázání nemá být vytvářeno pouze z paměti. Před jeho uzavřením se porovnají:

- poslední pracovní záznam,
- skutečné soubory,
- výsledky příkazů,
- databázové výstupy,
- aktuální stav repozitáře,
- stav provozních front a workerů.

## 6.3 Stručnost bez ztráty přesnosti

Krátký text nesmí být na úkor přesnosti. Místo obecných formulací typu „pokračovat v databázi“ se používá konkrétní formulace s uvedením oblasti, objektu a očekávaného výsledku.

## 6.4 Doporučené stavy

| Stav | Význam |
|---|---|
| DONE | Dokončeno a ověřeno. |
| IN_PROGRESS | Práce byla zahájena a pokračuje. |
| BLOCKED | Pokračování blokuje konkrétní překážka. |
| HOLD | Záměrně pozastaveno do splnění podmínky nebo rozhodnutí. |
| PLANNED | Schváleno k budoucímu provedení. |
| CANCELLED | Zrušeno nebo nahrazeno jiným řešením. |

## 6.5 Kontrola aktuálnosti při pokračování

Při zahájení další práce se ověří, zda se od vytvoření navázání nezměnily:

- zdrojové soubory,
- databázové objekty,
- stav providerů,
- běžící procesy,
- rozhodnutí projektu,
- dokumentační standardy.

Pokud došlo k významné změně, původní navázání se nepoužije bez nového ověření.

## 6.6 Závěr kapitoly

Doporučený postup zajišťuje, že navázání vzniká v okamžiku nejvyšší dostupnosti informací a před použitím se znovu ověřuje. Další kapitola popisuje vazby na ostatní dokumentaci.

# 7. Vztah k ostatní dokumentaci

Dokument NAVÁZÁNÍ není samostatně stojící dokument. Je součástí dokumentačního ekosystému MatchMatrix a propojuje každodenní vývoj s dlouhodobou dokumentací projektu.

## 7.1 MM-DOC-900 – Denní zápisy

Denní zápisy zachycují průběh jednotlivých pracovních dnů a obsahují podrobnosti o provedené práci, problémech, rozhodnutích a testech. NAVÁZÁNÍ z těchto informací vybírá pouze to, co je důležité pro další pokračování. Platí:

- denní zápis = podrobná historie práce,
- navázání = aktuální stav a výchozí bod.

## 7.2 MM-DOC-100 – Master

MASTER obsahuje dlouhodobou strategii projektu. Pokud pracovní etapa přinese změnu dlouhodobého směru, NAVÁZÁNÍ tuto změnu zaznamená jako požadavek k aktualizaci dokumentu MASTER.

## 7.3 MM-DOC-200 – Governance

Pokud během práce vznikne nové pravidlo nebo kontrolní mechanismus, nestačí jej uvést pouze v NAVÁZÁNÍ. NAVÁZÁNÍ upozorní na změnu. Dlouhodobé pravidlo musí být následně zapracováno do GOVERNANCE nebo příslušného standardu MM-STD.

## 7.4 MM-DOC-300 – Architecture

Architektonické změny mohou být poprvé zaznamenány v NAVÁZÁNÍ jako výsledek pracovní etapy. Po jejich ověření musí být promítnuty do dokumentu ARCHITECTURE.

## 7.5 MM-DOC-800 – Development Handbook

Pokud pracovní zkušenost mění každodenní vývojový postup, NAVÁZÁNÍ identifikuje požadavek na aktualizaci DEVELOPMENT HANDBOOK.

## 7.6 MM-DOC-902 – Changelog

NAVÁZÁNÍ zachycuje pracovní stav. CHANGELOG eviduje pouze významné změny projektu, nové funkce, milníky a dlouhodobě relevantní technické změny.

## 7.7 MM-DOC-903 – Architectural Decisions

Pokud během práce padne rozhodnutí s dlouhodobým dopadem na architekturu, nesmí zůstat pouze v NAVÁZÁNÍ. NAVÁZÁNÍ zachytí jeho pracovní dopad. Referenční rozhodnutí, důvody a důsledky se evidují v **MM-DOC-903 – MatchMatrix Architectural Decisions**.

## 7.8 MM-REF-001 – Slovník pojmů

Nové odborné pojmy se řídí standardy terminologie a po schválení se doplňují do MM-REF-001, pokud v něm dosud nejsou uvedeny.

## 7.9 Závěr kapitoly

NAVÁZÁNÍ propojuje pracovní historii s dlouhodobými referenčními dokumenty, ale nenahrazuje je. Další kapitola stanovuje pravidla jeho správy a archivace.

# 8. Správa, verzování a archivace

Je nutné rozlišovat mezi:

1. tímto řídicím dokumentem **MM-DOC-901**, který definuje pravidla navazování,
2. jednotlivými konkrétními navazovacími záznamy vznikajícími při práci.

## 8.1 Správa dokumentu MM-DOC-901

Tento dokument je aktivním řízeným dokumentem dokumentačního systému. Jeho identita je určena Document ID **MM-DOC-901**. Má jednu oficiální aktivní verzi, která se aktualizuje v souladu s MM-STD-003. Historie změn se vede v tabulce historie verzí.

## 8.2 Správa konkrétních navazovacích záznamů

Konkrétní navazovací záznam zachycuje jednu logickou pracovní etapu. Po uzavření se jeho faktický obsah nepřepisuje tak, aby došlo ke změně historického stavu. Pokud se stav projektu významně změní, vzniká nové navázání. Je-li nutná oprava chyby, musí být dohledatelné, co bylo opraveno, proč, kdy a kým.

## 8.3 Jedno navázání = jedna pracovní etapa

Jeden konkrétní záznam nemá spojovat několik nesouvisejících pracovních období. Pokud práce přejde do jiné oblasti nebo se významně změní cíl, vzniká nové navázání.

## 8.4 Identifikace konkrétních záznamů

Finální systém označování konkrétních navázání bude definován v další verzi dokumentu nebo v Documentation Management System. Do té doby musí každý záznam obsahovat minimálně:

- datum,
- pracovní oblast,
- stručný název etapy,
- vazbu na předchozí záznam.

## 8.5 Archivace

Starší navázání se nemažou. Po nahrazení novějším záznamem se stávají historickým zdrojem. Archivace musí zachovat:

- původní obsah,
- datum a pracovní etapu,
- vazbu na následující navázání,
- související denní zápisy a technické zdroje.

## 8.6 Závěr kapitoly

Oddělení řídicího dokumentu od konkrétních historických záznamů řeší rozdíl mezi aktivním verzovaným dokumentem a neměnnou pracovní historií. Následující kapitola popisuje dlouhodobý význam a budoucí rozvoj systému navazování.

# 9. Dlouhodobý význam a budoucí rozvoj

Význam dokumentu NAVÁZÁNÍ roste společně s velikostí projektu. U rozsáhlé platformy, jakou MatchMatrix buduje, představuje jeden z nejdůležitějších pracovních nástrojů. Díky němu lze:

- bezpečně přerušit práci,
- navázat po několika dnech nebo týdnech,
- předat projekt jinému vývojáři,
- rychle obnovit kontext v novém AI chatu,
- snížit závislost na osobní paměti,
- propojit provozní stav s dlouhodobou dokumentací.

## 9.1 Git a milestone

Budoucí verze systému navázání bude podporovat přímé vazby na:

- Git commit a branch,
- SQL, Python a PowerShell skripty,
- milestone projektu,
- pracovní prioritu,
- kritérium dokončení.

## 9.2 Documentation Management System

Budoucí Documentation Management System bude podporovat:

- automatickou evidenci navázání,
- správu metadat,
- propojení s denními zápisy,
- generování PROJECT SNAPSHOT a DATABASE SNAPSHOT,
- aktualizaci CURRENT STATUS,
- kontrolu povinných částí,
- správu vazeb mezi dokumenty,
- vyhledání posledního platného navázání pro konkrétní oblast.

## 9.3 TECH V2

Při další významné revizi se předpokládá doplnění o:

- finální šablonu konkrétního navázání,
- systém označování navazovacích záznamů,
- doporučenou délku jednotlivých částí,
- přímou vazbu na Git commit a milestone,
- příklady z historie MatchMatrix,
- pravidla automatického generování a archivace,
- plnou vazbu na Documentation Management System.

Tyto části budou dokončeny po ověření jednotného pracovního postupu v dokumentační řadě MM-DOC-900 až MM-DOC-903.

## 9.4 Závěr kapitoly

Dlouhodobým cílem je změnit navázání z ručně vedeného pracovního dokumentu na řízenou součást znalostní platformy MatchMatrix. Jeho základní princip zůstane stejný: předat přesný aktuální stav a jednoznačný další krok.

# 10. Závěr dokumentu

MATCHMATRIX NAVÁZÁNÍ představuje pracovní mechanismus vytvořený pro bezpečné předávání aktuálního stavu projektu mezi jednotlivými etapami. Jeho hlavním úkolem není opakovat historii, ale umožnit plynulé pokračování vývoje bez ztráty souvislostí. Společně s denními zápisy, changelogem, architektonickými rozhodnutími a referenční dokumentací vytváří systém řízení znalostí, který umožňuje:

- přesně určit aktuální stav,
- rozlišit dokončenou a rozpracovanou práci,
- zachytit otevřená rizika,
- upozornit na potřebné aktualizace dokumentace,
- určit jeden hlavní další krok.

Navazujícím dokumentem dokumentační řady je:

> **MM-DOC-902 – MATCHMATRIX CHANGELOG (TECH)**

Tento dokument stanoví pravidla pro evidenci významných změn, milníků, nových funkcí a dlouhodobě relevantních technických změn projektu MatchMatrix.

# 11. AI CONTEXT

## Role dokumentu

MM-DOC-901 definuje pravidla pro předávání aktuálního pracovního stavu projektu MatchMatrix mezi pracovními etapami, lidmi a systémy AI.

## Účel pro AI

AI má tento dokument používat k pochopení:

- jak rozlišovat denní historii od aktuálního navázání,
- které části musí konkrétní navázání obsahovat,
- jak ověřovat aktuálnost před pokračováním,
- jak identifikovat hlavní další krok,
- které změny mají být promítnuty do dlouhodobé dokumentace.

## Hranice dokumentu

Dokument neobsahuje úplnou strategii, architekturu ani aktuální provozní stav celé platformy. Tyto informace se získávají z příslušných referenčních dokumentů a z konkrétního posledního navazovacího záznamu.

## Klíčové pravidlo

Konkrétní navázání je pracovní vstup, nikoliv automaticky trvale platný zdroj pravdy. Před provedením dalšího kroku se musí ověřit jeho časová a stavová platnost.

# 12. PROJECT SNAPSHOT

| Oblast | Aktuální stav při REVIEW |
|---|---|
| Documentation Framework | REVIEW |
| Master | REVIEW |
| Governance | REVIEW |
| Architecture | REVIEW |
| Development Handbook | REVIEW |
| Denní zápisy | REVIEW |
| Navázání | REVIEW – tento dokument |
| Changelog | Následující dokument k REVIEW |
| Architectural Decisions | Čeká na navazující REVIEW |
| Documentation Management System | PLANNED |

## Kontext aktuální revize

- Původní dokument byl veden jako **MM-DOC-006**.
- V nové dokumentační řadě je zařazen jako **MM-DOC-901**.
- Odborný obsah původního dokumentu byl zachován.
- Struktura byla sjednocena s MM-DOC-000 a MM-STD-001 až MM-STD-009.
- Byly aktualizovány vazby na nově číslované dokumenty.
- Bylo doplněno rozlišení mezi řídicím dokumentem a konkrétními historickými navazovacími záznamy.

# 13. DATABASE SNAPSHOT

Tento řídicí dokument neuchovává konkrétní provozní počty databáze MatchMatrix. V konkrétním pracovním navázání se DATABASE SNAPSHOT uvádí pouze tehdy, pokud je relevantní pro pokračování. Platí:

- hodnoty musí pocházet z ověřeného databázového nebo OPS zdroje,
- uvádí se datum a čas zjištění,
- zastaralé počty se nepřebírají bez nového ověření,
- podrobný stav zůstává v příslušných auditech, pohledech a technických dokumentech.

Doporučený minimální obsah:

| Položka | Požadovaný údaj |
|---|---|
| Databáze / prostředí | Název databáze a uzlu |
| Čas snapshotu | Datum a čas ověření |
| Relevantní schéma | `staging`, `public`, `ops`, `runtime` nebo jiné |
| Klíčový objekt | Tabulka, pohled, fronta nebo audit |
| Aktuální stav | Počet, status nebo výsledek |
| Zdroj ověření | SQL dotaz, pohled, skript nebo report |

# 14. CURRENT STATUS

| Oblast | Stav | Poznámka |
|---|---|---|
| Document ID | CONFIRMED | MM-DOC-901 |
| Původní označení | HISTORICAL | MM-DOC-006 |
| Edice | TECH | Technická a provozní dokumentace |
| Obsahová revize | COMPLETED | Obsah zachován a restrukturalizován |
| Soulad s MM-DOC-000 | REVIEWED | Doplněna standardní struktura a návaznosti |
| Soulad s MM-STD-009 | REVIEWED | Doplněny povinné kontextové sekce |
| Terminologie | REVIEWED | Sjednocena s dokumentační řadou a MM-REF-001 |
| Finální stav dokumentu | REVIEW | Čeká na schválení autora projektu |
| TECH V2 rozšíření | PLANNED | Šablona, Git, milestone, automatizace a příklady |

# 15. OPEN QUESTIONS

1. Jaký bude finální formát identifikace jednotlivých konkrétních navazovacích záznamů?
2. Budou konkrétní záznamy vedeny jako samostatné soubory, databázové záznamy, nebo kombinace obou forem?
3. Jaká metadata budou povinná pro vazbu na Git commit, branch a milestone?
4. Jak bude určováno poslední platné navázání pro konkrétní pracovní oblast?
5. Jak bude řešena oprava chyb v již uzavřeném historickém navázání?
6. Které části PROJECT SNAPSHOT a DATABASE SNAPSHOT budou generovány automaticky?
7. Jaká pravidla budou použita pro automatickou archivaci navazovacích záznamů?
8. Kdy bude vytvořena oficiální šablona konkrétního dokumentu NAVÁZÁNÍ pro TECH V2?

# 16. NEXT STEP

Provést odborné schválení této REVIEW verze dokumentu **MM-DOC-901 – MatchMatrix Navázání**. Po schválení pokračovat dokumentem:

> **MM-DOC-902 – MATCHMATRIX CHANGELOG (TECH)**

Při jeho REVIEW sjednotit:

- nové Document ID,
- vztah k denním zápisům a navázání,
- pravidla výběru významných změn,
- historii verzí,
- AI CONTEXT,
- PROJECT SNAPSHOT,
- DATABASE SNAPSHOT,
- CURRENT STATUS,
- OPEN QUESTIONS,
- NEXT STEP.
