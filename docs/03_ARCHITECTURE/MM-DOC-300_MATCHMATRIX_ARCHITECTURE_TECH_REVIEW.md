# MM-DOC-300

# MATCHMATRIX ARCHITECTURE

---

## Informace o dokumentu

| Položka              | Hodnota                                               |
| :------------------- | :---------------------------------------------------- |
| Název dokumentu      | MATCHMATRIX ARCHITECTURE                              |
| Označení             | MM-DOC-300                                            |
| Verze                | 1.0                                  |
| Stav                 | REVIEW                                          |
| Autor projektu       | Petr                                                  |
| Technická spolupráce | OpenAI ChatGPT                                        |
| Primární formát      | Markdown (.md)                                        |
| Umístění             | `docs/03_ARCHITECTURE/03_MATCHMATRIX_ARCHITECTURE.md` |

---

# Motto

> **Architektura není způsob, jak systém postavit. Architektura je důvod, proč bude systém správně fungovat i za deset let.**

---

# Obsah

1. Úvod
2. Architektonická filozofie
3. Vývoj architektury MatchMatrix
4. Základní stavební kameny systému
5. Životní cyklus dat
6. Vícevrstvá databázová architektura
7. Architektura jednotlivých Layer
8. Architektura providerů
9. Harvest architektura
10. Automatizace
11. Architektura PC1 / PC2
12. Budoucí cloudová architektura

---

---

# 0. Smysl architektury

Architektura MatchMatrix nevznikla s cílem vytvořit pouze databázi nebo technické řešení.

Jejím hlavním účelem je vytvořit dlouhodobě udržitelnou technologickou platformu společnosti MatchMatrix, která bude schopna poskytovat kvalitní služby uživatelům, rozšiřovat se o nové sporty, nové poskytovatele dat a nové produkty bez nutnosti měnit své základní principy.

Architektura propojuje obchodní cíle společnosti s technickou realizací platformy. Každé architektonické rozhodnutí musí dlouhodobě zvyšovat hodnotu platformy pro uživatele i společnost.

---

# 1. Úvod

Architektura projektu MatchMatrix představuje základní konstrukci celé platformy. Stejně jako architekt navrhuje nosnou konstrukci budovy dříve, než vzniknou jednotlivé místnosti, byla i architektura MatchMatrix navržena ještě před samotným plněním databáze rozsáhlými objemy sportovních dat.

Během vývoje se ukázalo, že největší výzvou není získávání dat. Moderní API dokáží poskytovat miliony záznamů.

Skutečnou výzvou je jejich dlouhodobá správa.

Jakmile začne systém kombinovat desítky providerů, miliony historických zápasů, stovky tisíc hráčů, fotografie, články, kurzy a další informace, stává se architektura důležitější než samotná data.

Právě z tohoto důvodu byla většina vývoje věnována návrhu architektury ještě před samotným masivním harvestem.

To je jeden z nejvýznamnějších rozdílů mezi MatchMatrix a běžnými sportovními databázemi.

---

# 2. Architektonická filozofie

Architektura MatchMatrix stojí na několika základních principech.

Prvním z nich je oddělení jednotlivých odpovědností.

Každá část systému řeší pouze jednu přesně definovanou oblast.

Provider získává data.

Harvest je plánuje.

Staging je bezpečně ukládá.

Parser je převádí.

Merge vytváří jednotné entity.

Public publikuje výsledky.

OPS kontroluje kvalitu.

Runtime řídí provoz.

Žádná vrstva nepřebírá odpovědnost jiné vrstvy.

Tento princip výrazně zjednodušuje další rozvoj systému.

---

## Druhým principem je dlouhodobá stabilita.

Architektura nesmí být navržena pouze pro současný stav projektu.

Musí být připravena na situaci, kdy bude databáze obsahovat:

* desítky sportů,
* stovky providerů,
* miliony hráčů,
* stovky milionů zápasů,
* miliardy statistických údajů.

Právě proto byla zvolena modulární architektura.

Každá část systému může být rozšiřována samostatně.

Aniž by bylo nutné měnit celý projekt.

---

## Třetím principem je nezávislost.

MatchMatrix není závislý na jednom API.

Není závislý na jednom sportu.

Není závislý na jednom typu dat.

Celá architektura je navržena tak, aby bylo možné kdykoliv přidat nový sport, nového providera nebo úplně novou datovou vrstvu bez zásahu do již existujících částí systému.

Právě tato otevřenost představuje jednu z největších hodnot projektu.

---

# 3. Jak vznikala současná architektura

Dnešní podoba MatchMatrix nevznikla jedním návrhem.

Vznikala postupně.

První verze projektu byla zaměřena především na fotbalová data.

S rozšiřováním databáze se však začaly objevovat problémy, které původní návrh nepředpokládal.

Postupně bylo nutné řešit:

* různé identifikátory providerů,
* rozdílné názvy týmů,
* duplicitní zápasy,
* historické změny soutěží,
* správu fotografií,
* správu článků,
* různé formáty statistik.

Každý nový problém vedl k vytvoření nové části architektury.

Tak vznikly například:

* Governance Layer,
* Source Intelligence Layer,
* OPS Layer,
* jednotné staging tabulky,
* canonical entity systém,
* provider mapping.

Současná architektura proto není výsledkem teorie.

Je výsledkem několikaměsíčního praktického vývoje a řešení skutečných problémů.

---

# Závěr první části

Architektura MatchMatrix vznikala společně s projektem samotným. Každá její část představuje odpověď na konkrétní problém, který se během vývoje objevil. Díky tomu není architektura tvořena izolovanými moduly, ale systémem vzájemně propojených vrstev, které společně vytvářejí dlouhodobě udržitelnou sportovní datovou platformu.

V další části dokumentu budou podrobně popsány jednotlivé databázové vrstvy (`staging`, `public`, `ops`, `runtime`), jejich odpovědnosti a důvody, proč byla zvolena právě tato architektura. Tato kapitola bude vycházet přímo z reálné databáze MatchMatrix, nikoliv z obecného návrhu.

# 4. Vícevrstvá databázová architektura

Jedním z nejdůležitějších architektonických rozhodnutí během vývoje MatchMatrix bylo opustit myšlenku jedné centrální databáze, do které by byla ukládána všechna data bez dalšího zpracování.

Na první pohled se může zdát takové řešení jednodušší. V praxi se však ukázalo jako dlouhodobě neudržitelné.

Každý provider používá vlastní datový model.

Každý sport obsahuje jinou strukturu dat.

Historické informace mají často jiný formát než data aktuální.

Některé zdroje poskytují pouze základní výsledky, jiné obsahují detailní statistiky, fotografie nebo články.

Pokud by všechna tato data byla ukládána přímo do jediné produkční databáze, velmi rychle by docházelo ke ztrátě konzistence, vzniku duplicit a komplikovaným migracím.

Proto byla navržena vícevrstvá architektura, ve které každá databázová vrstva plní přesně definovanou úlohu.

Výsledkem není pouze lepší organizace databáze.

Výsledkem je systém, který umožňuje dlouhodobě rozvíjet platformu bez zásadních změn jejího základu.

---

# 5. Databázové vrstvy MatchMatrix

Současná architektura databáze je rozdělena do několika hlavních schémat.

Každé schéma představuje samostatnou část životního cyklu dat.

Toto rozdělení patří mezi nejdůležitější architektonická rozhodnutí celého projektu.

---

## 5.1 STAGING

Schéma **staging** představuje vstupní bránu celé databáze.

Právě zde začíná život každé informace.

Do této vrstvy přicházejí data získaná od jednotlivých providerů.

Nejsou zde považována za správná ani definitivní.

Jsou pouze bezpečně uložena.

Jejich hlavním účelem je zachovat původní podobu dat tak, aby bylo možné kdykoliv dohledat jejich zdroj, znovu provést zpracování nebo analyzovat případné chyby.

V průběhu vývoje projektu došlo k významné změně této vrstvy.

Původně byly vytvářeny samostatné tabulky pro jednotlivé sporty, například:

* api_football_*
* api_hockey_*
* api_basketball_*

S rostoucím počtem sportů se však ukázalo, že tento přístup není dlouhodobě udržitelný.

Bylo proto rozhodnuto přejít na jednotnou architekturu založenou na univerzálních tabulkách **stg_***.

Tato změna výrazně zjednodušila další rozvoj platformy.

Nový provider již nevyžaduje vytváření nové databázové struktury.

Pouze se mapuje do existující architektury.

Toto rozhodnutí dnes představuje jeden z největších technologických posunů projektu MatchMatrix.

---

## 5.2 PUBLIC

Schéma **public** představuje oficiální databázi celé platformy.

Do této vrstvy se dostávají pouze informace, které úspěšně prošly všemi kontrolami.

Data v této části databáze jsou považována za ověřená a připravená pro využití ostatními částmi systému.

Právě z této vrstvy čerpá:

* webová aplikace,
* mobilní aplikace,
* analytické nástroje,
* AI Layer,
* exporty,
* veřejné API.

Public představuje jediný oficiální zdroj pravdy celé platformy.

Žádná jiná databázová vrstva nesmí být přímo využívána uživatelskými aplikacemi.

---

## 5.3 OPS

S postupným růstem databáze vznikla potřeba vytvořit samostatnou provozní vrstvu.

Tak vzniklo schéma **ops**.

Neobsahuje sportovní data.

Obsahuje informace o samotném provozu systému.

Například:

* dashboardy,
* auditní pohledy,
* KPI,
* kontrolní reporty,
* doporučení operátorovi,
* monitorovací pohledy,
* plánování harvestů,
* přehled stavu jednotlivých vrstev.

OPS představuje řídicí centrum celé platformy.

Díky této vrstvě není nutné analyzovat databázi ručně.

Operátor získává přehled prostřednictvím připravených dashboardů a kontrolních pohledů.

---

## 5.4 RUNTIME

Poslední významnou vrstvu představuje **runtime**.

Tato část databáze neukládá sportovní informace.

Jejím úkolem je řídit běh systému.

Obsahuje například:

* běžící úlohy,
* fronty,
* plánovače,
* stav workerů,
* informace o spuštěných procesech,
* dočasné pracovní struktury.

Runtime umožňuje řídit automatizované procesy bez zásahu do produkčních dat.

Tím je výrazně zvýšena bezpečnost celé platformy.

---

# 6. Proč byla zvolena právě tato architektura

Rozdělení databáze do několika vrstev nebylo provedeno z akademických důvodů.

Vzniklo jako přímá reakce na praktické problémy.

Během vývoje se ukázalo, že jednotlivé části systému mají zcela odlišné požadavky.

Harvest potřebuje pracovat s neověřenými daty.

Merge proces potřebuje porovnávat informace z více providerů.

Webová aplikace naopak musí pracovat pouze s kvalitními ověřenými daty.

OPS potřebuje sledovat provoz systému.

Pokud by všechny tyto činnosti probíhaly nad stejnými tabulkami, databáze by se velmi rychle stala nepřehlednou.

Vícevrstvá architektura tento problém elegantně řeší.

Každá vrstva má svou vlastní odpovědnost.

Každá část systému přesně ví, odkud data přebírá a kam je předává.

Tím vzniká jasně definovaný tok informací napříč celou platformou.

---

# 7. Datový tok mezi vrstvami

Datový tok v MatchMatrix je vždy jednosměrný.

Data se pohybují od jejich získání až po publikaci.

Typický životní cyklus jedné informace vypadá následovně:

**Provider**

↓

**Harvest**

↓

**STAGING**

↓

**Parser**

↓

**Merge**

↓

**PUBLIC**

↓

**OPS Audit**

↓

**Web / API / AI / Panel**

Tento tok je jedním ze základních pravidel architektury.

Jednotlivé vrstvy se navzájem neobcházejí.

Každá změna musí projít všemi příslušnými kroky.

Díky tomu lze kdykoliv dohledat původ každé informace uložené v databázi.

---

# Závěr druhé části

Vícevrstvá databázová architektura představuje technologický základ celé platformy MatchMatrix. Rozdělení na schémata **staging**, **public**, **ops** a **runtime** umožnilo oddělit jednotlivé odpovědnosti systému a vytvořit prostředí, které je dlouhodobě stabilní, bezpečné a snadno rozšiřitelné.

Jedním z nejvýznamnějších kroků vývoje bylo sjednocení historických sportovních tabulek do univerzální architektury **stg_***. Toto rozhodnutí výrazně zjednodušilo připojování nových providerů a vytvořilo jednotný základ pro všechny sporty.

V další části dokumentu bude podrobně popsána architektura jednotlivých Layer (Core, People, Media, Odds, Source Intelligence a AI), jejich vzájemné vztahy a způsob, jakým společně vytvářejí kompletní ekosystém platformy MatchMatrix.


# 8. Layer Architecture

Jedním z nejvýznamnějších architektonických rozhodnutí projektu MatchMatrix bylo rozdělení celé platformy do samostatných funkčních vrstev označovaných jako **Layer**.

Na první pohled se může zdát, že jednotlivé vrstvy pouze logicky třídí data. Ve skutečnosti však představují mnohem důležitější princip.

Každá Layer řeší přesně jednu oblast systému.

Díky tomu je možné jednotlivé části platformy rozvíjet samostatně, aniž by bylo nutné zasahovat do celé architektury.

Tento přístup významně zvyšuje dlouhodobou udržitelnost projektu.

Každá nová Layer vzniká pouze tehdy, pokud řeší samostatnou oblast s jasně definovanou odpovědností.

---

# 8.1 Core Layer

Core Layer představuje základ celé platformy.

Bez této vrstvy nemůže fungovat žádná další část systému.

Obsahuje všechny základní sportovní entity, které tvoří kostru databáze.

Patří sem zejména:

* sporty,
* státy,
* soutěže,
* sezóny,
* týmy,
* zápasy,
* stadiony,
* rozhodčí,
* základní statistiky.

Core Layer je navržena tak, aby byla maximálně stabilní.

Právě zde vznikají vazby, na které navazují všechny ostatní vrstvy systému.

Jakákoliv změna této vrstvy má dopad prakticky na celý projekt.

Proto je její vývoj řízen velmi opatrně.

---

# 8.2 People Layer

Po stabilizaci základních sportovních dat bylo možné začít budovat druhou nejvýznamnější část platformy.

People Layer.

Jejím cílem není pouze evidence hráčů.

Ve skutečnosti představuje kompletní databázi sportovních osobností.

Každý člověk v systému může být propojen s:

* týmy,
* soutěžemi,
* sezónami,
* zápasy,
* fotografiemi,
* články,
* statistikami,
* historickým působením.

Významnou součástí této vrstvy je také správa trenérů.

Projekt MatchMatrix od počátku počítá s tím, že trenéři budou stejně důležitou entitou jako samotní hráči.

People Layer bude v budoucnu jednou z nejrozsáhlejších databází celé platformy.

---

# 8.3 Media Layer

Sportovní statistiky poskytují fakta.

Média poskytují kontext.

Právě proto vznikla Media Layer.

Jejím úkolem je propojit jednotlivé sportovní entity s:

* články,
* fotografiemi,
* videi,
* tiskovými zprávami,
* oficiálními oznámeními.

Media Layer výrazně rozšiřuje informační hodnotu celé platformy.

Uživatel tak nebude vidět pouze výsledek zápasu.

Bude mít k dispozici také související články, fotografie hráčů, klubové zprávy nebo oficiální vyjádření trenérů.

Tím se MatchMatrix přibližuje spíše sportovnímu informačnímu systému než klasické databázi výsledků.

---

# 8.4 Odds Layer

Kurzy představují specifický druh sportovních informací.

Nejsou součástí samotného sportu.

Přesto poskytují velmi cenný pohled na očekávání trhu.

Odds Layer proto vznikla jako samostatná architektonická vrstva.

Jejím úkolem není pouze ukládání aktuálních kurzů.

Dlouhodobým cílem je vytvářet historickou databázi kurzů, která umožní:

* analyzovat změny očekávání trhu,
* porovnávat jednotlivé sázkové kanceláře,
* vytvářet podklady pro predikční modely,
* podporovat AI analýzy.

Tato vrstva bude v budoucnu významným zdrojem informací pro analytické nástroje.

---

# 8.5 Source Intelligence Layer

Jednou z největších zvláštností MatchMatrix je Source Intelligence Layer.

Většina sportovních databází eviduje pouze samotná data.

MatchMatrix eviduje také jejich původ.

Source Intelligence Layer spravuje například:

* registry providerů,
* oficiální federace,
* klubové weby,
* licenční podmínky,
* robots.txt,
* obchodní modely,
* kvalitu jednotlivých zdrojů,
* historii změn.

Tato vrstva vznikla na základě zkušeností získaných během hledání nových providerů.

Ukázalo se, že správa samotných zdrojů představuje samostatnou disciplínu.

Proto byla oddělena od ostatních částí systému.

V budoucnu bude Source Intelligence Layer jednou z největších konkurenčních výhod MatchMatrix.

---

# 8.6 AI Layer

AI Layer představuje vrchol celé architektury.

Nevytváří vlastní data.

Nevykonává harvest.

Neprovádí merge.

Jejím úkolem je využít znalosti vytvořené všemi ostatními vrstvami.

Umělá inteligence bude pracovat například s:

* historickými výsledky,
* statistikami,
* fotografiemi,
* články,
* kurzy,
* kvalitou providerů,
* historií změn,
* governance daty.

Výsledkem budou:

* predikce,
* automatické analýzy,
* inteligentní doporučení,
* detekce anomálií,
* automaticky generované reporty.

AI Layer proto není samostatnou databází.

Je inteligentní nadstavbou celé platformy.

---

# 9. Vzájemná spolupráce Layer

Přestože jsou jednotlivé vrstvy navrženy jako samostatné části systému, žádná z nich nefunguje izolovaně.

Každá Layer využívá informace vytvořené ostatními vrstvami.

Například:

Core Layer poskytuje základní sportovní data.

People Layer rozšiřuje informace o hráčích.

Media Layer připojuje články a fotografie.

Odds Layer doplňuje očekávání trhu.

Source Intelligence Layer hodnotí samotné zdroje.

AI Layer následně využívá informace ze všech těchto vrstev současně.

Výsledkem není několik oddělených databází.

Vzniká jeden propojený znalostní systém.

Právě toto propojení představuje hlavní filozofii architektury MatchMatrix.

---

# 10. Proč nevznikají další Layer

Během vývoje projektu vznikla řada návrhů na vytvoření dalších vrstev.

Například:

* Photo Layer,
* Statistics Layer,
* Community Layer,
* Video Layer.

Po podrobnější analýze však bylo rozhodnuto tyto oblasti nezařazovat jako samostatné Layer.

Důvod je jednoduchý.

Každá nová vrstva zvyšuje složitost celé architektury.

Nová Layer vznikne pouze tehdy, pokud:

* řeší samostatnou oblast,
* má vlastní datový model,
* má vlastní životní cyklus,
* přináší dlouhodobou hodnotu.

Tím zůstává architektura přehledná i při dalším rozšiřování projektu.

---

# Závěr třetí části

Layer Architecture představuje jeden z nejvýznamnějších architektonických principů projektu MatchMatrix. Rozdělení systému na samostatné funkční vrstvy umožňuje dlouhodobý rozvoj platformy bez zbytečného zvyšování její složitosti.

Každá Layer má jasně definovanou odpovědnost, vlastní datový model i vlastní strategii rozvoje. Přesto všechny společně vytvářejí jeden propojený znalostní systém.

V následující části dokumentu bude popsána architektura providerů, harvest pipeline, automatizační procesy a role druhého serveru (PC2) při dlouhodobém získávání historických sportovních dat.

# 11. Architektura poskytovatelů dat (Provider Architecture)

Jednou z největších předností platformy MatchMatrix je skutečnost, že není postavena kolem jednoho poskytovatele sportovních dat. Celá architektura byla od počátku navržena jako víceproviderový systém, ve kterém představuje každý zdroj pouze jednu část rozsáhlého datového ekosystému.

Toto rozhodnutí zásadně ovlivnilo podobu celé databáze.

Ve většině sportovních aplikací je databáze navržena podle struktury konkrétního API. Pokud se následně změní poskytovatel nebo jeho datový model, musí se měnit také samotná databáze.

MatchMatrix používá opačný přístup.

Databáze není navržena podle providerů.

Provideři jsou mapováni do databáze.

Díky tomu může být kterýkoliv poskytovatel kdykoliv přidán, nahrazen nebo dočasně vypnut, aniž by bylo nutné měnit architekturu platformy.

Tato nezávislost představuje jeden z nejvýznamnějších strategických pilířů celého projektu.

---

# 11.1 Životní cyklus providerů

Každý nový provider prochází v projektu MatchMatrix stejným procesem.

Nejprve je analyzována jeho dokumentace.

Následuje ověření:

* licenčních podmínek,
* dostupnosti API,
* kvality dat,
* historického rozsahu,
* omezení použití,
* rychlosti aktualizací.

Současně jsou prověřovány také veřejně dostupné informace, například obchodní model, stabilita společnosti nebo dlouhodobá perspektiva daného zdroje.

Teprve poté je provider zařazen do Source Intelligence Layer.

Následuje vytvoření mapování do interního datového modelu a příprava harvest pipeline.

Díky tomuto postupu se do produkční architektury dostávají pouze prověření poskytovatelé.

---

# 11.2 Rozdělení providerů podle účelu

V projektu MatchMatrix nejsou provideři rozděleni pouze podle sportů.

Stejně důležité je jejich funkční zařazení.

Postupně vzniklo několik základních kategorií.

### Core Providers

Poskytují základní sportovní data.

Například:

* soutěže,
* týmy,
* zápasy,
* výsledky,
* sezóny.

---

### People Providers

Dodávají informace o hráčích, trenérech a dalších osobách.

Jejich význam bude v budoucnu dále růst.

---

### Media Providers

Zajišťují:

* články,
* fotografie,
* videa,
* oficiální zprávy.

Právě zde hrají významnou roli oficiální weby federací a klubů.

---

### Odds Providers

Dodávají kurzy jednotlivých sázkových kanceláří.

Tyto informace tvoří základ Odds Layer.

---

### Knowledge Providers

Specifickou skupinu představují zdroje typu:

* Wikidata,
* Wikimedia Commons,
* další veřejné znalostní databáze.

Jejich úkolem není poskytovat výsledky zápasů.

Slouží především k obohacování databáze.

---

# 12. Harvest Architecture

Jednou z největších investic během vývoje MatchMatrix bylo vytvoření vlastní harvest architektury.

Na první pohled by bylo možné stáhnout data jednoduchým skriptem.

Takový přístup však funguje pouze u malých projektů.

MatchMatrix je navržen pro dlouhodobý provoz.

Harvest proto představuje samostatný systém.

Jeho úkolem není pouze stahovat data.

Řídí celý proces jejich získávání.

---

# 12.1 Harvest Planner

První část harvest architektury představuje plánovač.

Planner rozhoduje:

* který sport bude zpracován,
* který provider bude použit,
* jaká sezóna bude stahována,
* jaká je priorita úlohy,
* zda jde o historický nebo běžný harvest.

Planner umožňuje dlouhodobě řídit tisíce harvest úloh bez manuálních zásahů.

---

# 12.2 Harvest Workers

Samotné stahování dat provádějí specializované workery.

Každý worker řeší přesně jednu oblast.

Například:

* leagues,
* teams,
* fixtures,
* players,
* coaches,
* statistics,
* media,
* odds.

Tím je zajištěna vysoká modularita celé harvest architektury.

---

# 12.3 Parser Pipeline

Stažená data nejsou ukládána přímo do produkční databáze.

Nejprve procházejí parserem.

Parser:

* převádí datové typy,
* sjednocuje názvy,
* mapuje provider ID,
* připravuje merge proces,
* zapisuje výsledky do staging.

Parser představuje most mezi providerem a interní databází MatchMatrix.

---

# 12.4 Merge Engine

Po dokončení parseru přichází Merge Engine.

Jeho úkolem je rozhodnout:

* jedná se o novou entitu?
* existuje již v databázi?
* jedná se o aktualizaci?
* vzniká konflikt?
* je potřeba HOLD?

Merge představuje jednu z nejsložitějších částí celé platformy.

Právě zde vznikají canonical entity.

Právě zde spolupracuje Governance s databází.

---

# 13. Automatizační architektura

Jedním z dlouhodobých cílů MatchMatrix je maximální automatizace.

Během několika let nebude možné systém spravovat ručně.

Proto vzniká samostatná automatizační architektura.

Ta bude postupně řídit:

* plánování harvestů,
* kontrolu providerů,
* automatické retry,
* monitoring workerů,
* merge procesy,
* audity,
* reporty,
* doporučení operátorovi.

Budoucím cílem je, aby většina běžných operací probíhala bez lidského zásahu.

Operátor bude řešit pouze výjimky a strategická rozhodnutí.

---

# 14. Architektura PC1 a PC2

Jedním z praktických architektonických rozhodnutí projektu bylo oddělení vývojového prostředí od prostředí určeného pro rozsáhlý harvest dat.

Vznikla tak dvoupočítačová architektura.

## PC1

PC1 představuje pracovní stanici vývojáře.

Slouží především pro:

* návrh databáze,
* SQL,
* vývoj,
* správu projektu,
* dokumentaci,
* řízení systému.

Neprovádí dlouhodobý harvest.

Jeho hlavní úlohou je řízení celé platformy.

---

## PC2

PC2 představuje výpočetní uzel určený především pro:

* rozsáhlé historické harvesty,
* dlouhodobé ingest procesy,
* automatizované workery,
* budoucí nepřetržitý provoz.

Toto rozdělení významně snižuje zatížení vývojového prostředí.

Současně umožňuje provozovat dlouhé harvesty bez omezení běžné práce na projektu.

Do budoucna bude možné architekturu dále rozšiřovat o další výpočetní uzly nebo cloudové služby.

---

# Závěr čtvrté části

Architektura providerů, harvest pipeline i rozdělení rolí mezi PC1 a PC2 představují praktickou realizaci filozofie MatchMatrix. Platforma není navržena jako sada skriptů pro stahování dat, ale jako řízený ekosystém, ve kterém má každý provider, každý worker i každý server přesně definovanou odpovědnost.

V závěrečné části dokumentu bude popsána budoucí architektura platformy, přechod k distribuovanému zpracování, cloudová strategie, dlouhodobá škálovatelnost systému a závěrečné shrnutí celé architektury MatchMatrix.

# 15. Budoucí architektura platformy

Architektura MatchMatrix nebyla navržena pouze pro současný stav projektu. Již během prvních návrhů bylo zřejmé, že databáze bude postupně růst o další sporty, nové poskytovatele dat, nové vrstvy systému i nové služby. Proto byla celá platforma od počátku koncipována jako architektura, kterou lze dlouhodobě rozšiřovat bez zásadních zásahů do jejích základních principů.

Dlouhodobým cílem není vytvořit co největší databázi.

Cílem je vytvořit platformu, která bude schopna růst společně s množstvím dat, aniž by se stávala složitější nebo obtížněji spravovatelnou.

Právě schopnost dlouhodobé evoluce patří mezi nejdůležitější vlastnosti celé architektury.

---

# 15.1 Přechod od projektu k platformě

V počátečních fázích vývoje byl MatchMatrix především databázovým projektem.

Postupně se však ukázalo, že jednotlivé části systému začínají vytvářet samostatný ekosystém.

Databáze již neslouží pouze jako úložiště.

Harvest již není pouze skript.

OPS již není pouze dashboard.

Source Intelligence již není pouze seznam providerů.

Každá z těchto částí se postupně stává samostatným modulem platformy.

Budoucnost MatchMatrix proto nespočívá v dalším zvětšování jedné databáze.

Budoucnost spočívá ve vytvoření plnohodnotné sportovní datové platformy.

---

# 15.2 Distribuované zpracování dat

S rostoucím objemem dat bude postupně narůstat také množství výpočetních operací.

Historické harvesty, merge procesy, výpočty statistik nebo AI analýzy budou stále náročnější.

Proto byla architektura navržena tak, aby bylo možné jednotlivé části systému postupně rozdělit mezi více výpočetních uzlů.

V současné době tuto architekturu představuje dvojice:

* PC1 – řídicí a vývojová stanice,
* PC2 – harvest server.

Do budoucna však bude možné přidávat další uzly podle aktuálních potřeb.

Například:

* samostatný AI server,
* media processing server,
* reporting server,
* cloud workers.

Celá architektura je připravena na horizontální rozšiřování.

---

# 15.3 Cloud jako rozšíření, nikoliv náhrada

Při návrhu architektury bylo rozhodnuto, že cloud nebude představovat základ platformy.

Cloud bude sloužit jako rozšíření lokální infrastruktury.

Tento přístup přináší několik významných výhod.

Lokální databáze zůstává plně pod kontrolou projektu.

Historická data nejsou závislá na externích službách.

Vývoj lze provádět i bez internetového připojení.

Cloud bude využíván pouze tam, kde přinese skutečný přínos.

Například:

* výpočetně náročné AI modely,
* veřejné API,
* webová aplikace,
* CDN pro fotografie,
* zálohování,
* distribuovaný harvest.

Tím zůstává architektura flexibilní a současně ekonomicky efektivní.

---

# 16. Architektonické principy, které se nebudou měnit

Během vývoje může dojít ke změně použitých technologií, databázových systémů nebo jednotlivých providerů.

Existuje však několik principů, které tvoří samotnou podstatu MatchMatrix a které zůstanou zachovány bez ohledu na další technologický vývoj.

Mezi tyto principy patří zejména:

**Oddělení odpovědností**

Každá část systému řeší pouze jednu oblast.

---

**Víceproviderová architektura**

Žádný provider není nenahraditelný.

---

**Canonical Entity Model**

Každá skutečná entita existuje v databázi pouze jednou.

---

**Vícevrstvá databázová architektura**

Data vždy procházejí definovaným životním cyklem.

---

**Governance First**

Každá nová část systému vzniká současně s pravidly její správy.

---

**Automation First**

Opakující se činnosti mají být automatizovány.

---

**Documentation First**

Každé významné rozhodnutí musí být zdokumentováno.

---

Právě tyto principy tvoří dlouhodobou identitu projektu.

---

# 17. Architektura jako konkurenční výhoda

Ve světě sportovních databází bývá hlavní pozornost věnována množství dat.

MatchMatrix se vydává jinou cestou.

Jeho hlavní konkurenční výhodou nebude pouze rozsah databáze.

Tou největší hodnotou bude architektura.

Díky ní bude možné:

* bezpečně připojovat nové providery,
* rozšiřovat nové sporty,
* vytvářet nové analytické vrstvy,
* přidávat nové AI modely,
* budovat komunitní funkce,
* rozšiřovat databázi bez ztráty kvality.

Architektura se tak stává nejdůležitější investicí celého projektu.

Data lze stáhnout znovu.

Dobře navrženou architekturu je možné rozvíjet desítky let.

---

# 18. Závěr dokumentu

Dokument **MATCHMATRIX ARCHITECTURE** popisuje technický základ celé platformy.

Ukazuje, že MatchMatrix není pouze databází sportovních výsledků ani souborem harvest skriptů.

Jedná se o komplexní datovou platformu, jejíž jednotlivé části byly navrženy jako dlouhodobě spolupracující celek.

Architektura vznikala postupně.

Každé významné rozhodnutí bylo výsledkem praktických zkušeností získaných při budování databáze, vývoji harvest pipeline, řešení duplicit, návrhu governance i postupném rozšiřování jednotlivých vrstev systému.

Díky tomu nevznikla teoretická architektura.

Vznikla architektura ověřená každodenním používáním.

Právě tato zkušenost představuje jednu z největších hodnot projektu MatchMatrix.

Budoucí vývoj platformy bude samozřejmě pokračovat.

Budou vznikat nové moduly, nové vrstvy i nové technologie.

Základní architektonické principy však zůstanou zachovány.

Budou představovat stabilní základ, na kterém bude možné budovat další generace systému.

---

# Stav dokumentu

**Dokument:** MM-DOC-300 – MATCHMATRIX ARCHITECTURE

**Verze:** 0.9 – První kompletní pracovní návrh

**Stav:** Připraven k první odborné revizi

---

## Navazující dokument

Dalším dokumentem dokumentační řady bude:

> **MM-DOC-800 – MATCHMATRIX DEVELOPMENT HANDBOOK**

Na rozdíl od předchozích dokumentů nebude zaměřen na strategii ani architekturu. Bude představovat praktickou příručku pro vývoj MatchMatrix. Bude vycházet přímo z našich skutečných standardů: číslování skriptů, struktury složek, pravidel pro SQL, Python, PowerShell, Docker, DBeaver, Visual Studio, OPS Panel, dokumentaci i každodenní pracovní postupy.

---

### Poznámka autora

Od tohoto dokumentu dál se dokumentace začne ještě více opírat o skutečnou historii projektu. Development Handbook nebude obecná vývojářská příručka – bude popisovat přesně způsob práce, který jsme během vývoje MatchMatrix společně vytvořili a který používáme každý den. Právě zde se začnou promítat konkrétní standardy projektu, které dělají MatchMatrix jedinečným.




---

# AI CONTEXT

**Role dokumentu:** Definuje technickou architekturu platformy MatchMatrix.

**Navazuje na:** MM-DOC-000, MM-DOC-100, MM-DOC-200 a standardy MM-STD-001 až MM-STD-009.

**Architektonické principy:** Modularita, vícevrstvá databáze, Canonical Entity Model, Governance First, Automation First, Documentation First.

---

# PROJECT SNAPSHOT

*Tato sekce je připravena pro budoucí automatické generování z Documentation Management System.*

---

# CURRENT STATUS

| Oblast | Stav |
|--------|------|
| Core Layer | ACTIVE |
| People Layer | ACTIVE |
| Media Layer | DEVELOPMENT |
| Odds Layer | DEVELOPMENT |
| Source Intelligence | ACTIVE DEVELOPMENT |
| AI Layer | DESIGN |
| Documentation Platform | DEVELOPMENT |

---

# OPEN QUESTIONS

- Distribuovaná architektura.
- AI orchestrace.
- Cloud strategie.
- Dokumentační databáze.
- Business Services Layer.

---

# NEXT STEP

Navázat dokumentem **MM-DOC-800 – MatchMatrix Development Handbook**, který převede architektonické principy do každodenních pravidel vývoje.

