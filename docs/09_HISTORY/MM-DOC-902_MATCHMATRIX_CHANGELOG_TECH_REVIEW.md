# MM-DOC-902
# MATCHMATRIX CHANGELOG
## TECH EDITION

## Informace o dokumentu
| Položka | Hodnota |
|---|---|
| Dokument | MM-DOC-902 |
| Název | MatchMatrix Changelog |
| Edice | MM-DOC TECH |
| Verze | 1.1 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Původní pracovní označení | MM-DOC-007 |
| Umístění | `docs/09_HISTORY/MM-DOC-902_MATCHMATRIX_CHANGELOG_TECH.md` |

## Poznámka k přečíslování
Původní pracovní označení dokumentu bylo **MM-DOC-007**. V aktuální dokumentační struktuře je dokument zařazen jako **MM-DOC-902**, protože tvoří součást řady provozní historie a kontinuity projektu společně s dokumenty:
- **MM-DOC-900 – MatchMatrix Denní zápisy**,
- **MM-DOC-901 – MatchMatrix Navázání**,
- **MM-DOC-903 – MatchMatrix Architectural Decisions**.

Přečíslování nemění účel ani odborný obsah dokumentu. Zajišťuje jeho správné zařazení do současného dokumentačního systému MatchMatrix.

## Motto
> **Ne každá změna je důležitá. Changelog zachycuje pouze ty, které mění projekt.**

## Účel dokumentu
Tento dokument definuje roli, strukturu, pravidla a životní cyklus dokumentu **CHANGELOG** v projektu MatchMatrix. CHANGELOG představuje chronologický přehled významných změn a milníků, které mají dlouhodobý dopad na platformu, její architekturu, funkce, governance, data nebo dokumentaci.

Jeho úkolem není zaznamenávat každou pracovní úpravu. Jeho cílem je uchovat stručnou a důvěryhodnou historii změn, které budou důležité i po delší době.

## Rozsah dokumentu
Dokument upravuje:
- smysl a filozofii evidence významných změn,
- hranici mezi CHANGELOGEM a ostatní dokumentací,
- kategorie změn,
- kritéria pro zařazení záznamu,
- povinnou strukturu záznamu,
- pravidla vytváření, ověřování a publikace,
- správu, verzování a opravy záznamů,
- vazby na Git, milestone, denní zápisy, navázání a architektonická rozhodnutí,
- budoucí propojení s Documentation Management System.

## Cílová skupina
- autor a architekt projektu,
- vývojáři,
- databázoví specialisté,
- správci provozu a OPS,
- správci dokumentace,
- projektové řízení,
- budoucí spolupracovníci,
- systémy umělé inteligence vyhodnocující historii projektu.

## Související dokumenty
- **MM-DOC-000 – MatchMatrix Documentation Framework**
- **MM-DOC-100 – MatchMatrix Master**
- **MM-DOC-200 – MatchMatrix Governance**
- **MM-DOC-300 – MatchMatrix Architecture**
- **MM-DOC-800 – MatchMatrix Development Handbook**
- **MM-DOC-900 – MatchMatrix Denní zápisy**
- **MM-DOC-901 – MatchMatrix Navázání**
- **MM-DOC-903 – MatchMatrix Architectural Decisions**
- **MM-STD-001 až MM-STD-009**
- **MM-REF-001 – Slovník pojmů MatchMatrix**

## Zdroje REVIEW
REVIEW vychází z původního dokumentu **MM-DOC-007 – MatchMatrix Changelog (TECH)** a z aktuálních dokumentačních zdrojů MM-DOC-000, MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DOC-900, MM-DOC-901, MM-STD-001 až MM-STD-009 a MM-REF-001. Při rozdílu mezi původním pracovním označením a novou dokumentační řadou bylo použito aktuální označení **MM-DOC-902**.

## Historie verzí
| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026 | DRAFT | První pracovní verze vedená pod označením MM-DOC-007. |
| 1.1 | 2026-06-29 | REVIEW | Přečíslování na MM-DOC-902, sjednocení struktury, terminologie, vazeb a pravidel evidence, doplnění kontextových sekcí podle MM-STD-009. |

# Obsah
1. Úvod
2. Účel a hranice CHANGELOGU
3. Filozofie evidence změn
4. Kategorie významných změn
5. Kritéria pro zařazení změny
6. Životní cyklus záznamu
7. Struktura záznamu
8. Pravidla evidence a oprav
9. Vazba na ostatní dokumentaci
10. Správa, verzování a budoucí rozvoj
11. Závěr dokumentu
12. AI CONTEXT
13. PROJECT SNAPSHOT
14. DATABASE SNAPSHOT
15. CURRENT STATUS
16. OPEN QUESTIONS
17. NEXT STEP

# 0. Smysl dokumentu CHANGELOG
CHANGELOG chrání dlouhodobou paměť projektu MatchMatrix. Zachycuje pouze změny, které mění platformu, její architekturu, pravidla, schopnosti nebo strategický stav. Nepopisuje celý průběh práce. Uchovává výsledek, důvod a dlouhodobý dopad významné změny.

CHANGELOG odpovídá zejména na otázku:
> **Co se v projektu významně změnilo, proč k tomu došlo a jaký to má dlouhodobý dopad?**

# 1. Úvod
Vývoj projektu MatchMatrix probíhá nepřetržitě. Vznikají nové skripty, databázové objekty, dokumenty, poskytovatelé dat, provozní mechanismy i architektonická rozhodnutí. Ne všechny změny však mají stejnou důležitost.

Právě proto vznikl dokument MATCHMATRIX CHANGELOG. Jeho úkolem není zaznamenat každou úpravu, test nebo pracovní krok. Jeho cílem je evidovat pouze změny, které mají dlouhodobý význam pro celý projekt nebo některou z jeho hlavních oblastí.

CHANGELOG poskytuje rychlý historický přehled bez nutnosti procházet rozsáhlé denní zápisy, technické logy nebo jednotlivé Git commity.

## 1.1 Přínos pro projekt
CHANGELOG:
- vytváří stručnou historii významných milníků,
- vysvětluje důvod a dopad změn,
- propojuje technickou historii s dlouhodobou dokumentací,
- usnadňuje orientaci novým spolupracovníkům a AI,
- pomáhá určit, kdy se změnil důležitý princip, modul nebo stav,
- snižuje závislost na osobní paměti a izolovaných pracovních poznámkách.

## 1.2 Závěr kapitoly
CHANGELOG představuje přehled dlouhodobě významných výsledků vývoje, nikoliv detailní kroniku každodenní práce. Následující kapitola přesně vymezuje jeho účel a hranice.

# 2. Účel a hranice CHANGELOGU
CHANGELOG představuje chronologický přehled významných změn a milníků projektu. Slouží zejména k evidenci:
- nových modulů,
- dokončených etap,
- významných architektonických změn,
- změn databázové struktury s dlouhodobým dopadem,
- vzniku nebo změny hlavních Layer,
- změn workflow,
- významných governance pravidel,
- důležitých dokumentačních změn,
- klíčových změn providerů, provozu nebo infrastruktury,
- rozhodnutí, která změnila další směr projektu.

Na rozdíl od denních zápisů CHANGELOG neobsahuje podrobný průběh práce. Obsahuje ověřený výsledek a jeho význam.

## 2.1 Co CHANGELOG není
CHANGELOG není:
- denní pracovní zápis,
- seznam všech commitů,
- technický log aplikace,
- úplná dokumentace implementace,
- registr architektonických rozhodnutí,
- seznam otevřených úkolů,
- aktuální navázání na další práci.

Každá z těchto informací má vlastní referenční místo v dokumentačním nebo technickém systému MatchMatrix.

## 2.2 Výsledek místo průběhu
Do CHANGELOGU se zapisuje dokončená, potvrzená nebo oficiálně přijatá změna. Rozpracované pokusy, nepotvrzené návrhy a dočasné testy se evidují v denních zápisech, pracovních navázáních nebo specializovaných technických zdrojích.

## 2.3 Závěr kapitoly
Účelem CHANGELOGU je uchovat stručnou historii významných výsledků. Jasné oddělení od pracovních logů, úkolů a architektonických rozhodnutí udržuje dokument přehledný a důvěryhodný. Na tuto hranici navazuje filozofie evidence změn.

# 3. Filozofie evidence změn
Do CHANGELOGU se zapisují pouze změny, které budou důležité i po delší době. Každý záznam musí odpovědět minimálně na tři základní otázky:
- **Co se změnilo?**
- **Proč ke změně došlo?**
- **Jaký je její dlouhodobý dopad?**

Tím vzniká stručná, ale informačně hodnotná historie vývoje projektu bez zbytečných implementačních detailů.

## 3.1 Význam před množstvím
Hodnota CHANGELOGU není dána počtem záznamů. Příliš podrobný CHANGELOG ztrácí svou hlavní funkci, protože významné milníky zaniknou mezi běžnými úpravami. Zařazení záznamu musí být založeno na skutečném významu změny, nikoliv na množství práce, které její implementace vyžadovala.

## 3.2 Ověřitelnost
Každý záznam musí vycházet z ověřitelného výsledku. Podle charakteru změny může odkazovat na:
- dokument,
- Git commit nebo release,
- SQL či databázový objekt,
- worker nebo modul,
- auditní výstup,
- milestone,
- architektonické rozhodnutí,
- provozní nebo testovací výsledek.

## 3.3 Jedno referenční místo
CHANGELOG nesmí nahrazovat podrobnou referenční dokumentaci. Pokud změna vyžaduje rozsáhlejší vysvětlení, CHANGELOG obsahuje stručné shrnutí a odkaz na dokument, ve kterém je změna popsána podrobně.

## 3.4 Chronologie a souvislosti
Záznamy se řadí chronologicky. Pokud nová změna opravuje, nahrazuje nebo rozšiřuje změnu starší, musí být jejich vazba dohledatelná. Historie se nemaže pouze proto, že se projekt později vydal jiným směrem.

## 3.5 Závěr kapitoly
Filozofie CHANGELOGU upřednostňuje význam, ověřitelnost a dlouhodobý dopad před množstvím detailů. Další kapitola vymezuje základní kategorie změn.

# 4. Kategorie významných změn
Kategorie umožňuje rychle určit povahu změny a její primární dopad. Jedna změna může zasahovat do více oblastí, musí však mít jednu hlavní kategorii.

## 4.1 Architektonické změny
Patří sem zejména:
- vznik nové Layer,
- změna databázové architektury,
- změna datového toku,
- nový způsob harvestu nebo orchestrace,
- změna hlavního workflow,
- změna rozdělení odpovědností mezi moduly,
- změna infrastruktury s dlouhodobým dopadem.

Pokud změna vychází z významného architektonického rozhodnutí, CHANGELOG odkazuje na příslušný záznam v MM-DOC-903.

## 4.2 Funkční změny
Patří sem zejména:
- nový modul,
- nová významná funkce,
- nový dashboard nebo pracovní panel,
- nový provider zařazený do produkčního použití,
- nový parser, merge engine nebo worker s významem pro platformu,
- dokončení funkční etapy nebo produktu.

Běžná úprava existující funkce se zapisuje pouze tehdy, pokud mění její účel, rozsah nebo dlouhodobé chování.

## 4.3 Governance změny
Patří sem zejména:
- nový standard,
- nové závazné pravidlo,
- změna řízení projektu,
- nový kontrolní mechanismus,
- změna procesu schvalování,
- zavedení nové prevence chyb nebo duplicit,
- významná změna řízení kvality.

## 4.4 Dokumentační změny
Patří sem zejména:
- vznik hlavního dokumentu,
- změna dokumentační architektury,
- nové dokumentační pravidlo,
- změna číslování nebo identity celé dokumentační řady,
- zavedení nové edice nebo referenčního systému,
- významný posun ve Documentation Management System.

Běžné opravy textu, formátování nebo jednotlivých odkazů se do CHANGELOGU nezapisují.

## 4.5 Datové a providerové změny
Tato kategorie se použije, pokud změna zásadně ovlivňuje datovou základnu nebo strategii zdrojů, například:
- připojení významného poskytovatele dat,
- nahrazení klíčového provideru,
- dokončení rozsáhlého historického harvestu,
- změna canonical entity strategie,
- zásadní rozšíření sportovního nebo historického pokrytí,
- změna licenčního nebo komerčního modelu důležitého zdroje.

## 4.6 Provozní a infrastrukturní změny
Tato kategorie se použije pro změny, které dlouhodobě mění provoz platformy, například:
- zavedení nového výpočetního uzlu,
- přechod na nový provozní model,
- nasazení plánovače nebo autonomní orchestrace,
- zásadní změna monitoringu,
- významná změna zálohování, bezpečnosti nebo dostupnosti.

## 4.7 Závěr kapitoly
Kategorie rozlišují hlavní povahu významné změny, ale nenahrazují popis jejího dopadu. Následující kapitola stanovuje kritéria, podle kterých se rozhoduje o zařazení záznamu.

# 5. Kritéria pro zařazení změny
Změna se zařazuje do CHANGELOGU, pokud splňuje alespoň jedno z následujících kritérií:
- mění dlouhodobou architekturu nebo odpovědnost některé části systému,
- zavádí nový významný modul, Layer, službu nebo datový zdroj,
- uzavírá důležitou etapu nebo milestone,
- mění závazné governance nebo vývojové pravidlo,
- významně mění rozsah, kvalitu nebo dostupnost dat,
- ovlivňuje více částí platformy,
- bude důležitá pro pochopení budoucího stavu projektu,
- představuje významné nahrazení, odstranění nebo změnu předchozího řešení.

## 5.1 Kontrolní otázky
Před vytvořením záznamu se ověří:
1. Bude tato změna důležitá i za několik měsíců nebo let?
2. Mění způsob, jakým platforma funguje, roste nebo je řízena?
3. Potřebuje budoucí vývojář nebo AI vědět, kdy a proč k této změně došlo?
4. Je změna dokončená, potvrzená nebo oficiálně přijatá?
5. Existuje ověřitelný zdroj jejího výsledku?

Pokud je odpověď na většinu otázek záporná, informace zpravidla patří pouze do denního zápisu nebo Git historie.

## 5.2 Co se nezapisuje
Do CHANGELOGU se standardně nezapisují:
- drobné opravy chyb bez širšího dopadu,
- kosmetické úpravy,
- jednotlivé testovací běhy,
- krátkodobé experimenty bez výsledku,
- rutinní aktualizace dat,
- běžné refaktoringy bez změny chování,
- pracovní návrhy, které nebyly přijaty,
- úplné seznamy změněných souborů.

## 5.3 Hraniční případy
Pokud význam změny není jednoznačný, informace se nejprve zachytí v denním zápisu nebo navázání. Po potvrzení dlouhodobého dopadu může být vytvořen záznam v CHANGELOGU. Tím se předchází zanášení dokumentu dočasnými nebo nedokončenými změnami.

## 5.4 Závěr kapitoly
Zařazení změny je založeno na dlouhodobém významu, nikoliv na množství vykonané práce. Další kapitola popisuje životní cyklus záznamu od identifikace změny po její publikaci.

# 6. Životní cyklus záznamu
Každý záznam CHANGELOGU prochází řízeným postupem. Cílem je zajistit, aby publikovaná historie obsahovala pouze ověřené a správně zařazené změny.

## 6.1 Identifikace významné změny
Potřeba záznamu může vzniknout při:
- uzavření denního zápisu,
- vytvoření navázání,
- dokončení milestone,
- schválení architektonického rozhodnutí,
- vydání nové verze modulu,
- dokončení auditu nebo významného datového procesu.

## 6.2 Ověření výsledku
Před vytvořením záznamu se ověří:
- že změna skutečně nastala,
- že nejde pouze o plán nebo návrh,
- datum jejího přijetí nebo dokončení,
- hlavní důvod změny,
- očekávaný nebo potvrzený dopad,
- relevantní odkazy a zdroje.

## 6.3 Vytvoření záznamu
Záznam se vytvoří podle jednotné struktury definované v kapitole 7. Musí být stručný, ale samostatně pochopitelný.

## 6.4 Review a publikace
Před publikací se kontroluje:
- správná kategorie,
- přesnost data a popisu,
- odlišení faktu od očekávání,
- vazba na související dokumenty,
- absence zbytečných implementačních detailů,
- soulad s terminologií projektu.

Po schválení se záznam stává součástí oficiální historie projektu.

## 6.5 Navazující aktualizace
Pokud pozdější změna původní řešení rozšíří, nahradí nebo zruší, vytvoří se nový záznam s vazbou na záznam původní. Historický záznam se nemaže ani nepřepisuje tak, aby zanikl původní stav.

## 6.6 Závěr kapitoly
Řízený životní cyklus chrání důvěryhodnost a dohledatelnost historie. Následující kapitola stanovuje povinnou strukturu jednotlivého záznamu.

# 7. Struktura záznamu
Každý záznam v CHANGELOGU používá jednotnou strukturu. Díky tomu lze rychle dohledat jednotlivé změny a porovnávat jejich význam napříč oblastmi projektu.

## 7.1 Povinné informace
Každý záznam obsahuje minimálně:
- datum změny,
- název změny,
- kategorii,
- oblast projektu,
- stručný popis změny,
- důvod změny,
- dlouhodobý dopad nebo přínos,
- vazbu na související dokumenty nebo technické zdroje.

Pokud je relevantní, doplní se také:
- stav nebo milestone,
- nahrazené řešení,
- Git commit nebo release,
- odkaz na Architectural Decision,
- odpovědná osoba,
- identifikátor změny.

## 7.2 Doporučený formát
```text
Datum:
Název změny:
Kategorie:
Oblast:
Stav:

Změna:

Důvod:

Dopad:

Nahrazuje / rozšiřuje:

Související dokumenty:

Technické zdroje:
```

## 7.3 Doporučená kompaktní tabulka
Pro souhrnné nebo strojově zpracovatelné záznamy lze použít tabulku:

| Datum | Kategorie | Oblast | Změna | Důvod | Dopad | Reference |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | ARCHITECTURE | Database | Stručný název | Stručný důvod | Dlouhodobý dopad | MM-DOC / commit / objekt |

Dlouhé nebo složité změny mají být vedeny jako samostatný strukturovaný záznam, nikoliv jako přeplněný řádek tabulky.

## 7.4 Úroveň podrobnosti
CHANGELOG není technická dokumentace. Proto se v něm neuvádějí:
- celé SQL skripty,
- zdrojové kódy,
- úplné logy,
- podrobné implementační postupy,
- rozsáhlé databázové výstupy.

Tyto informace patří do specializovaných dokumentů, repozitáře, auditů nebo denních zápisů. CHANGELOG obsahuje pouze jejich významný závěr a odkaz.

## 7.5 Formulace dopadu
Dopad musí popisovat skutečný dlouhodobý význam změny. Pokud dopad ještě nebyl potvrzen, musí být formulován jako očekávaný, nikoliv jako ověřený výsledek.

Nevhodné:
> Změna výrazně zlepší celý projekt.

Vhodné:
> Změna sjednocuje providerová data do univerzální staging architektury a omezuje potřebu vytvářet nové sport-specific tabulky.

## 7.6 Závěr kapitoly
Jednotná struktura zajišťuje, že každý záznam odpovídá na stejné základní otázky a zůstává čitelný pro lidi i AI. Další kapitola stanovuje pravidla evidence, neměnnosti a oprav.

# 8. Pravidla evidence a oprav
CHANGELOG se aktualizuje pouze tehdy, pokud vznikla významná změna. Není povinné vytvářet nový záznam každý den ani při každém commitu.

## 8.1 Četnost aktualizace
Nový záznam vzniká:
- po potvrzení významné změny,
- při uzavření významné etapy,
- při vydání důležité verze,
- po schválení změny s dlouhodobým dopadem.

Záznam má vzniknout co nejdříve po ověření změny, aby byl jeho obsah přesný a zdroje dohledatelné.

## 8.2 Neměnnost publikovaného záznamu
Publikovaný záznam se nepřepisuje způsobem, který by změnil historickou skutečnost. Pokud pozdější vývoj původní změnu překoná, vytvoří se nový navazující záznam.

## 8.3 Oprava chyby
Pokud publikovaný záznam obsahuje faktickou chybu, oprava je povolena pouze tehdy, pokud zůstane dohledatelné:
- původní znění nebo podstata chyby,
- důvod opravy,
- datum opravy,
- osoba nebo systém, který opravu provedl.

Podle budoucího systému evidence může být použito označení **CORRECTED**, samostatný opravný záznam nebo verzovaná změna s auditní stopou.

## 8.4 Zrušené nebo nahrazené řešení
Záznam o historicky platné změně se nemaže, ani když bylo řešení později zrušeno. Nový záznam uvede, že původní řešení nahrazuje, a popíše důvod změny.

## 8.5 Jazyk a terminologie
Záznamy se píší stručným odborným jazykem. Používají jednotnou terminologii projektu a při prvním použití nového odborného pojmu se postupuje podle MM-STD-006 a MM-STD-008. Nový schválený pojem se doplní do MM-REF-001.

## 8.6 Duplicitní záznamy
Jedna významná změna má mít jeden hlavní záznam. Pokud zasahuje více oblastí, uvedou se v jednom záznamu související dopady. Samostatné záznamy se vytvářejí pouze tehdy, pokud jednotlivé části změny mají vlastní datum, účel nebo samostatný dlouhodobý význam.

## 8.7 Závěr kapitoly
Pravidla evidence chrání přesnost a historickou kontinuitu CHANGELOGU. Následující kapitola vymezuje jeho vazby na ostatní dokumentaci projektu.

# 9. Vazba na ostatní dokumentaci
CHANGELOG tvoří společně s ostatní dokumentací jeden řízený systém. Nepřebírá jejich obsah, ale propojuje významné výsledky s jejich referenčními zdroji.

## 9.1 MM-DOC-900 – Denní zápisy
Denní zápisy obsahují podrobný průběh práce, testy, problémy a pracovní rozhodnutí. CHANGELOG z nich vybírá pouze dokončené výsledky s dlouhodobým významem.

## 9.2 MM-DOC-901 – Navázání
NAVÁZÁNÍ popisuje aktuální stav projektu a hlavní další krok. Pokud během pracovní etapy vznikla významná změna, navázání musí upozornit na potřebu zápisu do CHANGELOGU.

## 9.3 MM-DOC-903 – Architectural Decisions
ARCHITECTURAL DECISIONS eviduje rozhodnutí, důvody, alternativy a důsledky. CHANGELOG eviduje okamžik, kdy bylo rozhodnutí přijato nebo implementováno, a odkazuje na jeho referenční záznam.

## 9.4 MM-DOC-100 – Master
Pokud změna ovlivňuje dlouhodobou strategii, produkty nebo směřování společnosti MatchMatrix, musí být podle potřeby promítnuta také do dokumentu MASTER.

## 9.5 MM-DOC-200 – Governance
Pokud změna zavádí nebo mění závazné pravidlo, proces nebo kontrolní mechanismus, musí být referenční pravidlo promítnuto do dokumentu GOVERNANCE nebo příslušného standardu.

## 9.6 MM-DOC-300 – Architecture
Významná architektonická změna musí být popsána v dokumentu ARCHITECTURE. CHANGELOG uchovává její historický okamžik, důvod a dopad.

## 9.7 MM-DOC-800 – Development Handbook
Pokud změna ovlivňuje každodenní vývojový postup, nástroje, workflow nebo standard skriptů, musí být aktualizován DEVELOPMENT HANDBOOK.

## 9.8 Git a release historie
Git uchovává detailní historii změn souborů. CHANGELOG uchovává pouze významné projektové změny. Budoucí záznam může obsahovat odkaz na commit, tag, branch nebo release, ale nesmí se změnit na kopii seznamu commitů.

## 9.9 Závěr kapitoly
CHANGELOG propojuje chronologii projektu s referenční dokumentací a technickými zdroji. Další kapitola stanovuje pravidla správy řídicího dokumentu i jednotlivých záznamů.

# 10. Správa, verzování a budoucí rozvoj
Je nutné rozlišovat mezi:
1. tímto řídicím dokumentem **MM-DOC-902**, který definuje pravidla CHANGELOGU,
2. jednotlivými publikovanými záznamy významných změn.

## 10.1 Správa dokumentu MM-DOC-902
Tento dokument je aktivním řízeným dokumentem dokumentačního systému. Jeho identita je určena Document ID **MM-DOC-902**. Existuje jedna oficiální aktivní verze, která se aktualizuje v souladu s MM-STD-003. Historie změn dokumentu se vede v tabulce historie verzí.

## 10.2 Správa záznamů CHANGELOGU
Jednotlivé publikované záznamy tvoří historickou evidenci. Po publikaci se nemění bez dohledatelné opravy. Nová změna vytváří nový záznam, i když navazuje na dřívější řešení.

## 10.3 Umístění záznamů
Finální způsob fyzického a databázového uložení bude potvrzen v další verzi dokumentu nebo v Documentation Management System. Možné formy zahrnují:
- centrální aktivní Markdown dokument,
- samostatné zdrojové záznamy,
- databázovou evidenci s generovaným Markdown exportem,
- kombinaci databázového zdroje a verzovaných exportů.

Bez ohledu na fyzickou formu musí být zachována jednoznačná identita, chronologie, vazby a auditní stopa.

## 10.4 TECH V2
Při další významné revizi se předpokládá doplnění o:
- klasifikaci změn podle závažnosti,
- finální systém identifikátorů jednotlivých záznamů,
- povinnou vazbu na Git commit, tag nebo release,
- vazbu na milestone projektu,
- stavový model záznamu,
- oficiální šablonu,
- příklady správných záznamů z historie MatchMatrix,
- pravidla automatického generování a archivace.

## 10.5 Documentation Management System
Budoucí Documentation Management System bude podporovat:
- evidenci jednotlivých změn,
- správu kategorií a závažnosti,
- propojení s dokumenty a Git historií,
- automatickou tvorbu chronologického přehledu,
- kontrolu duplicit,
- správu oprav a nahrazených řešení,
- generování PROJECT SNAPSHOT a release přehledů,
- vyhledávání změn podle oblasti, data a dopadu.

## 10.6 Závěr kapitoly
Oddělení aktivního řídicího dokumentu od historických záznamů zajišťuje soulad s verzováním dokumentace i neměnností projektové historie. Dlouhodobým cílem je převést CHANGELOG do řízené, vyhledatelné a automatizované součásti znalostní platformy MatchMatrix.

# 11. Závěr dokumentu
MATCHMATRIX CHANGELOG představuje oficiální přehled nejvýznamnějších změn a milníků projektu. Na rozdíl od denních zápisů nezachycuje průběh každodenní práce. Uchovává pouze ověřené změny s dlouhodobým významem.

Každý záznam musí stručně vysvětlit:
- co se změnilo,
- proč ke změně došlo,
- jaký je její dlouhodobý dopad,
- kde lze nalézt podrobnější referenční informace.

Společně s dokumenty MASTER, GOVERNANCE, ARCHITECTURE, DEVELOPMENT HANDBOOK, DENNÍ ZÁPISY, NAVÁZÁNÍ a ARCHITECTURAL DECISIONS tvoří CHANGELOG jednotný systém dokumentace a řízení znalostí projektu MatchMatrix.

Navazujícím dokumentem dokumentační řady je:
> **MM-DOC-903 – MATCHMATRIX ARCHITECTURAL DECISIONS (TECH)**

Tento dokument bude představovat centrální registr významných architektonických rozhodnutí. U každého rozhodnutí bude evidován kontext, důvod, posuzované alternativy, přijaté řešení a dlouhodobé důsledky pro platformu.

# 12. AI CONTEXT
## Role dokumentu
MM-DOC-902 definuje pravidla pro evidenci významných změn a milníků projektu MatchMatrix.

## Účel pro AI
AI má tento dokument používat k pochopení:
- které změny patří do CHANGELOGU,
- jak odlišit významnou změnu od běžné pracovní úpravy,
- jak vytvořit strukturovaný a ověřitelný záznam,
- jak propojit změnu s denním zápisem, navázáním, Git historií a referenční dokumentací,
- jak zachovat chronologii a neměnnost historických záznamů.

## Hranice dokumentu
Dokument neobsahuje úplnou technickou historii, seznam commitů ani všechna architektonická rozhodnutí. Podrobnosti se získávají z příslušných referenčních dokumentů a technických zdrojů.

## Klíčové pravidlo
Do CHANGELOGU se zapisuje pouze ověřená změna s dlouhodobým významem. Rozpracovaný návrh, běžná oprava nebo nepotvrzený výsledek do něj nepatří.

# 13. PROJECT SNAPSHOT
| Oblast | Aktuální stav při REVIEW |
|---|---|
| Documentation Framework | REVIEW |
| Master | REVIEW |
| Governance | REVIEW |
| Architecture | REVIEW |
| Development Handbook | REVIEW |
| Denní zápisy | REVIEW |
| Navázání | REVIEW dokončeno |
| Changelog | REVIEW – tento dokument |
| Architectural Decisions | Následující dokument k REVIEW |
| Documentation Management System | PLANNED |

## Kontext aktuální revize
- Původní dokument byl veden jako **MM-DOC-007**.
- V nové dokumentační řadě je zařazen jako **MM-DOC-902**.
- Odborný obsah původního dokumentu byl zachován a rozšířen pouze tam, kde to vyžadují aktuální standardy a vazby.
- Struktura byla sjednocena s MM-DOC-000 a MM-STD-001 až MM-STD-009.
- Byly aktualizovány vazby na MM-DOC-900, MM-DOC-901 a MM-DOC-903.
- Bylo doplněno rozlišení mezi aktivním řídicím dokumentem a jednotlivými historickými záznamy CHANGELOGU.
- Byla doplněna pravidla pro ověření, opravy, nahrazená řešení a budoucí automatizaci.

# 14. DATABASE SNAPSHOT
Tento řídicí dokument neuchovává aktuální provozní počty databáze MatchMatrix. Konkrétní záznam CHANGELOGU může obsahovat databázový snapshot pouze tehdy, pokud je nezbytný pro pochopení významu změny.

Platí následující pravidla:
- hodnoty musí pocházet z ověřeného databázového nebo OPS zdroje,
- musí být uvedeno datum a čas zjištění,
- musí být zřejmé, zda jde o stav před změnou nebo po změně,
- podrobný výstup zůstává v auditu, denním zápisu nebo technickém zdroji,
- CHANGELOG uvádí pouze hodnoty potřebné pro doložení dopadu.

Doporučený minimální obsah:
| Položka | Požadovaný údaj |
|---|---|
| Databáze / prostředí | Název databáze a uzlu |
| Čas snapshotu | Datum a čas ověření |
| Stav | BEFORE / AFTER |
| Relevantní objekt | Schéma, tabulka, pohled, fronta nebo modul |
| Klíčová hodnota | Počet, status, coverage nebo výsledek |
| Zdroj ověření | SQL dotaz, audit, pohled, skript nebo report |

# 15. CURRENT STATUS
| Oblast | Stav | Poznámka |
|---|---|---|
| Document ID | CONFIRMED | MM-DOC-902 |
| Původní označení | HISTORICAL | MM-DOC-007 |
| Edice | TECH | Technická a provozní dokumentace |
| Obsahová revize | COMPLETED | Původní obsah zachován a restrukturalizován |
| Soulad s MM-DOC-000 | REVIEWED | Doplněna standardní struktura, závěry a návaznosti |
| Soulad s MM-STD-009 | REVIEWED | Doplněny povinné kontextové sekce |
| Terminologie | REVIEWED | Sjednocena s dokumentační řadou a MM-REF-001 |
| Pravidla zařazení změn | DEFINED | Význam, ověřitelnost a dlouhodobý dopad |
| Struktura záznamu | DEFINED | Povinné údaje a doporučená šablona |
| Opravy a nahrazená řešení | DEFINED | Historie musí zůstat dohledatelná |
| Finální stav dokumentu | REVIEW | Čeká na schválení autora projektu |
| TECH V2 rozšíření | PLANNED | Závažnost, identifikátory, Git, milestone, automatizace |

# 16. OPEN QUESTIONS
1. Budou jednotlivé záznamy CHANGELOGU vedeny v jednom aktivním dokumentu, jako samostatné soubory, v databázi, nebo kombinací těchto forem?
2. Jaký bude finální identifikátor jednotlivého záznamu změny?
3. Jaké kategorie a úrovně závažnosti budou závazné v TECH V2?
4. Které typy změn musí povinně odkazovat na Git commit, tag nebo release?
5. Jak bude evidována vazba na milestone projektu?
6. Jaký stavový model bude použit pro DRAFT, REVIEW, PUBLISHED, CORRECTED a SUPERSEDED záznamy?
7. Jak bude Documentation Management System automaticky rozpoznávat kandidáty na nový záznam?
8. Kdo bude schvalovat, zda změna splňuje práh významnosti?
9. Jak bude řešeno generování veřejného produktového changelogu z interní technické evidence?
10. Kdy budou do CHANGELOGU zpětně doplněny nejvýznamnější historické milníky MatchMatrix?

# 17. NEXT STEP
Provést odborné schválení této REVIEW verze dokumentu **MM-DOC-902 – MatchMatrix Changelog**. Po schválení pokračovat dokumentem:
> **MM-DOC-903 – MATCHMATRIX ARCHITECTURAL DECISIONS (TECH)**

Při jeho REVIEW sjednotit:
- nové Document ID,
- vztah k CHANGELOGU, denním zápisům a NAVÁZÁNÍ,
- strukturu architektonického rozhodnutí,
- evidenci kontextu, alternativ, důvodů a důsledků,
- stavový a životní cyklus rozhodnutí,
- AI CONTEXT,
- PROJECT SNAPSHOT,
- DATABASE SNAPSHOT,
- CURRENT STATUS,
- OPEN QUESTIONS,
- NEXT STEP.
