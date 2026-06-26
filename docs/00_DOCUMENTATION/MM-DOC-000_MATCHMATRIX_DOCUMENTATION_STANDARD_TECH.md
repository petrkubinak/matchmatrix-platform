# MM-DOC-000

# MATCHMATRIX DOCUMENTATION STANDARD

---

## Informace o dokumentu

| Položka              | Hodnota                                                          |
| :------------------- | :--------------------------------------------------------------- |
| Název dokumentu      | MATCHMATRIX DOCUMENTATION STANDARD                               |
| Označení             | MM-DOC-000                                                       |
| Verze                | 0.9 (Pracovní návrh)                                             |
| Stav                 | Rozpracováno                                                     |
| Autor projektu       | Petr                                                             |
| Technická spolupráce | OpenAI ChatGPT                                                   |
| Primární formát      | Markdown (.md)                                                   |
| Výstupy              | Markdown • DOCX • PDF • HTML                                     |
| Umístění             | `docs/00_DOCUMENTATION/00_MATCHMATRIX_DOCUMENTATION_STANDARD.md` |

---

# Motto

> **Dobrá dokumentace není sbírkou poznámek. Je to znalostní základna, která umožňuje pochopit celý systém, navázat na jeho vývoj a dlouhodobě jej rozvíjet.**

---

# Obsah

1. Úvod
2. Účel dokumentace
3. Filozofie dokumentace MatchMatrix
4. Rozsah dokumentace
5. Základní principy
6. Struktura dokumentace
7. Životní cyklus dokumentů
8. Standard psaní
9. Základní pravidla
10. Navazující dokumenty

---

# 1. Úvod

Projekt MatchMatrix je dlouhodobě budovaná sportovní datová platforma, jejímž cílem je vytvářet komplexní ekosystém pro sběr, správu, obohacení, analýzu a prezentaci sportovních dat napříč různými sporty, soutěžemi a poskytovateli dat. Rozsah projektu zahrnuje databázovou architekturu, automatizovaný harvest dat, inteligentní správu poskytovatelů, analytickou vrstvu, mediální obsah, webovou aplikaci i nástroje pro každodenní provoz.

Takto rozsáhlý projekt nelze dlouhodobě udržovat pouze prostřednictvím zdrojového kódu nebo jednotlivých pracovních poznámek. Každé významné rozhodnutí, architektonický princip i způsob práce musí být zachycen v jednotné dokumentaci, která bude představovat oficiální znalostní základnu projektu.

Tento dokument proto definuje pravidla, podle kterých bude vytvářena a udržována veškerá dokumentace MatchMatrix. Nestanovuje pouze vzhled dokumentů, ale především způsob jejich psaní, strukturu, obsah a vzájemné vztahy mezi jednotlivými dokumenty.

Cílem není vytvářet rozsáhlé texty bez praktického významu. Dokumentace má být pracovní pomůckou, která umožní rychle pochopit fungování systému, navázat na předchozí práci a vysvětlit důvody důležitých rozhodnutí i po mnoha letech vývoje.

---

# 2. Účel dokumentace

Dokumentace projektu MatchMatrix je považována za plnohodnotnou součást systému. Stejně jako databáze, zdrojové kódy nebo aplikační vrstvy podléhá řízenému vývoji, verzování a průběžné údržbě.

Jejím hlavním účelem není popisovat jednotlivé soubory nebo tabulky. Skutečnou hodnotou dokumentace je schopnost vysvětlit souvislosti mezi jednotlivými částmi systému a zachovat znalosti, které během vývoje vznikají.

Dobře vedená dokumentace umožňuje:

* rychle pochopit architekturu projektu,
* orientovat se v jednotlivých modulech systému,
* vysvětlit důvody přijatých rozhodnutí,
* zachovat znalosti i při dlouhodobém vývoji,
* usnadnit budoucí rozšiřování systému,
* minimalizovat závislost projektu na znalostech jediné osoby.

Dokumentace proto není vytvářena pouze pro současný stav projektu. Je navrhována jako dlouhodobá znalostní základna, která bude využívána po celou dobu existence platformy MatchMatrix.

---

# 3. Filozofie dokumentace MatchMatrix

Dokumentace projektu MatchMatrix vychází z jednoduché myšlenky:

> **Každá důležitá informace má mít své jediné oficiální místo.**

Stejná informace nesmí být udržována v několika různých dokumentech, protože by časem docházelo k jejich rozcházení. Každý dokument proto odpovídá za přesně vymezenou oblast projektu a ostatní dokumenty na něj pouze odkazují.

Dalším základním principem je vysvětlování důvodů jednotlivých rozhodnutí. Dokumentace nemá pouze uvádět, že systém něco dělá. Musí vysvětlit také proč byla zvolena právě daná architektura, jaké alternativy byly zvažovány a jaké výhody přináší současné řešení.

Projekt MatchMatrix vzniká jako dlouhodobá platforma. Je proto pravděpodobné, že některé dokumenty budou používány i za mnoho let. Z tohoto důvodu nesmí být dokumentace závislá na znalosti jednotlivých chatů, e-mailů nebo osobních poznámek. Veškeré důležité informace musí být zaznamenány přímo v oficiálních dokumentech.

Každý dokument má čtenáři odpovědět na několik základních otázek:

* Jaký problém tato část systému řeší?
* Proč byla vytvořena právě tímto způsobem?
* Jak spolupracuje s ostatními částmi projektu?
* Jaké výhody přináší zvolené řešení?
* Jaké jsou další plánované kroky?

Pokud dokument nedokáže na tyto otázky odpovědět, není považován za dokončený.

---

# 4. Rozsah dokumentace

Dokumentace MatchMatrix pokrývá celý životní cyklus projektu. Neomezuje se pouze na technické části systému, ale zahrnuje také strategii projektu, architekturu, pravidla vývoje, každodenní provoz i historická rozhodnutí.

Oficiální dokumentace je rozdělena do devíti hlavních dokumentů, z nichž každý představuje samostatnou oblast projektu. Dohromady tvoří ucelenou znalostní základnu MatchMatrix.

Jednotlivé dokumenty jsou navrženy tak, aby byly dlouhodobě udržitelné. Každý z nich může být průběžně rozšiřován, aniž by bylo nutné měnit jeho základní strukturu nebo účel.

---

# Závěr kapitoly

První část dokumentu stanovila základní filozofii dokumentace projektu MatchMatrix. Byla definována její role v rámci projektu, hlavní cíle i principy, které budou závazné pro všechny budoucí dokumenty.

V následující části budou popsány základní pravidla tvorby dokumentace, její struktura, jednotlivé typy dokumentů a jejich vzájemné vazby.

# 5. Základní principy dokumentace

Dokumentace projektu MatchMatrix je založena na několika základních principech, které budou závazné pro všechny současné i budoucí dokumenty. Tyto principy nevznikly jako formální pravidla, ale jako výsledek praktických zkušeností získaných během návrhu databáze, vývoje jednotlivých vrstev systému i každodenní práce na projektu.

Jejich společným cílem je zajistit, aby dokumentace zůstala dlouhodobě přehledná, konzistentní a snadno udržovatelná bez ohledu na rozsah projektu.

---

## 5.1 Jedna informace – jedno oficiální místo

Každá důležitá informace smí být spravována pouze v jednom oficiálním dokumentu.

Ostatní dokumenty mohou na tuto informaci odkazovat, ale nesmí vytvářet vlastní upravené kopie. Tím se předchází situacím, kdy jsou stejné informace popsány různým způsobem na několika místech a jejich obsah se postupně začne rozcházet.

Pokud je například popsána architektura databáze v dokumentu **MATCHMATRIX ARCHITECTURE**, nebude stejný text kopírován do dokumentů GOVERNANCE nebo MASTER. Tyto dokumenty pouze vysvětlí souvislosti a odkáží čtenáře na příslušnou kapitolu.

Tento princip výrazně zjednodušuje údržbu dokumentace a umožňuje provádět změny pouze na jednom místě.

---

## 5.2 Dokumentace vysvětluje důvody

Jedním z nejdůležitějších principů MatchMatrix je skutečnost, že dokumentace nesmí pouze popisovat výsledný stav systému.

Každé významné rozhodnutí musí být doplněno vysvětlením, proč bylo přijato právě toto řešení, jaké alternativy byly zvažovány a jaké výhody současné řešení přináší.

Po několika letech vývoje již většina technických rozhodnutí nebude zřejmá pouze ze zdrojového kódu. Dokumentace proto musí uchovávat nejen technické informace, ale také znalosti získané během návrhu systému.

Právě tato část dokumentace představuje jednu z největších hodnot projektu.

---

## 5.3 Dokumentace musí být dlouhodobě udržitelná

Projekt MatchMatrix je navrhován jako dlouhodobá platforma, která bude postupně rozšiřována o nové sporty, poskytovatele dat, analytické vrstvy i nové funkce aplikace.

Stejnou životnost musí mít také dokumentace.

Dokumenty proto nesmí obsahovat krátkodobé pracovní poznámky, neaktuální informace ani texty závislé na konkrétním okamžiku vývoje. Naopak musí být psány tak, aby zůstaly použitelné i po několika letech.

Pokud některá informace přestane být aktuální, nebude odstraněna bez náhrady. Bude nahrazena novou verzí nebo přesunuta do historické části dokumentace, aby bylo možné zpětně dohledat vývoj projektu.

---

## 5.4 Dokumentace je součástí systému

V projektu MatchMatrix není dokumentace považována za vedlejší produkt vývoje.

Stejně jako databázové schéma, zdrojové kódy nebo automatizační skripty představuje samostatnou součást systému.

Každá významná změna architektury, databáze nebo způsobu práce musí být doplněna odpovídající aktualizací dokumentace. Dokumentace se tak vyvíjí společně se systémem a nikdy nesmí zůstat dlouhodobě pozadu.

---

## 5.5 Přednost má srozumitelnost

Technická dokumentace často používá odbornou terminologii, která může být pro nového čtenáře obtížně pochopitelná.

Dokumentace MatchMatrix proto používá jednoduchý princip:

Nejdříve vysvětlit myšlenku.

Teprve poté popsat technické detaily.

Každá kapitola by měla být čitelná i pro člověka, který projekt dosud nezná. Odborné pojmy jsou používány pouze tam, kde jsou skutečně potřebné, a při prvním použití jsou doplněny vysvětlením.

Cílem není zjednodušovat technický obsah, ale usnadnit jeho pochopení.

---

# 6. Struktura dokumentace

Celá dokumentace MatchMatrix je rozdělena do několika hlavních dokumentů. Každý z nich má přesně vymezenou odpovědnost a pokrývá pouze jednu oblast projektu.

Tato struktura vznikla s cílem oddělit strategické informace od technické dokumentace, každodenní práce i historických záznamů.

Výsledkem je přehledná znalostní základna, ve které má každý dokument jasně definovaný účel.

Základ dokumentace tvoří následující dokumenty:

* **00_MATCHMATRIX_DOCUMENTATION_STANDARD.md** – pravidla tvorby dokumentace.
* **01_MATCHMATRIX_MASTER.md** – hlavní dokument projektu obsahující strategii, vizi a přehled systému.
* **02_MATCHMATRIX_GOVERNANCE.md** – pravidla řízení projektu, standardy a konvence.
* **03_MATCHMATRIX_ARCHITECTURE.md** – technická architektura systému.
* **04_MATCHMATRIX_DEVELOPMENT_HANDBOOK.md** – vývojářská příručka a doporučené postupy.
* **05_MATCHMATRIX_DENNI_ZAPISY.md** – chronologický pracovní deník projektu.
* **06_MATCHMATRIX_NAVAZANI.md** – stručné shrnutí aktuálního stavu projektu pro navázání práce.
* **07_MATCHMATRIX_CHANGELOG.md** – historie významných změn projektu.
* **08_MATCHMATRIX_ARCHITECTURAL_DECISIONS.md** – přehled všech důležitých architektonických rozhodnutí.

Každý z těchto dokumentů je možné dále rozšiřovat, avšak jeho základní účel se v průběhu projektu nebude měnit.

---

# 7. Životní cyklus dokumentů

Stejně jako software prochází jednotlivými verzemi, vyvíjí se také dokumentace.

Každý dokument vzniká jako pracovní návrh, který je průběžně doplňován a upravován. Po dosažení stabilního stavu je označen jako schválená verze a stává se oficiální součástí dokumentace projektu.

Významné změny jsou zaznamenávány do dokumentu **MATCHMATRIX CHANGELOG**, zatímco důvody architektonických rozhodnutí jsou ukládány do dokumentu **MATCHMATRIX ARCHITECTURAL DECISIONS**.

Tím je zajištěno, že hlavní dokumenty zůstávají přehledné a současně je možné dohledat historii jejich vývoje.

---

# 8. Standard psaní

Všechny dokumenty projektu MatchMatrix budou vytvářeny podle jednotného stylu.

Jednotlivé kapitoly budou psány souvislým odborným textem, nikoliv pouze seznamem bodů nebo stručných poznámek. Každá kapitola musí čtenáři vysvětlit význam popisované oblasti, její účel a návaznost na ostatní části systému.

Při psaní dokumentace budou dodržována zejména následující pravidla:

* Každá kapitola začíná stručným vysvětlením svého účelu.
* Technické informace jsou uváděny až po vysvětlení souvislostí.
* Odborné pojmy jsou při prvním použití vysvětleny.
* Kapitoly jsou psány jako souvislý text s přirozenou strukturou odstavců.
* Výčty jsou používány pouze tam, kde skutečně zvyšují přehlednost.
* Každá větší kapitola končí krátkým shrnutím dosažených závěrů a uvedením návaznosti na další část dokumentace.

Dokumentace není určena pouze současnému autorovi projektu. Je psána tak, aby umožnila pochopit systém i člověku, který se s projektem MatchMatrix setká poprvé.

---

# Závěr druhé části

Tato část dokumentu stanovila základní pravidla, podle kterých bude vytvářena veškerá dokumentace projektu MatchMatrix. Byly definovány hlavní principy, struktura dokumentace, způsob její správy i jednotný styl psaní.

V následující části budou popsány konkrétní pravidla pro tvorbu jednotlivých kapitol, používání tabulek, diagramů, příloh, verzování dokumentů a vzájemné odkazování mezi dokumenty. Tyto kapitoly dokončí standard, podle kterého bude následně vytvářena celá znalostní základna projektu.

# 9. Pravidla tvorby jednotlivých dokumentů

Každý dokument zařazený do oficiální dokumentace MatchMatrix představuje samostatnou část znalostní základny projektu. Přestože se jednotlivé dokumenty obsahově liší, jejich vnitřní struktura musí být jednotná. Díky tomu se čtenář dokáže rychle orientovat bez ohledu na to, zda studuje strategický dokument, technickou architekturu nebo vývojářskou příručku.

Jednotná struktura zároveň výrazně usnadňuje budoucí rozšiřování dokumentace. Nově vytvářené kapitoly automaticky zapadají do již existujícího systému a není nutné pokaždé znovu navrhovat jejich uspořádání.

Každý hlavní dokument bude zpravidla obsahovat následující části:

* informace o dokumentu,
* účel dokumentu,
* rozsah dokumentu,
* hlavní kapitoly,
* shrnutí,
* návaznosti na ostatní dokumenty,
* historii významných změn.

Tato struktura nemusí být ve všech dokumentech zcela totožná, avšak její základní logika musí být zachována.

---

## 9.1 Úvod každé kapitoly

Každá kapitola začíná krátkým vysvětlením.

Její první odstavec má čtenáři odpovědět na otázku:

> **Proč tato kapitola existuje?**

Teprve poté následuje technický popis.

Tím je zajištěno, že dokument nebude působit jako seznam technických údajů, ale jako souvislé vysvětlení fungování systému.

---

## 9.2 Technická část

Po úvodním vysvětlení následuje samotný odborný obsah.

Technická část může obsahovat například:

* popis architektury,
* databázové schéma,
* SQL příklady,
* diagramy,
* ukázky konfigurace,
* pracovní postupy,
* doporučení.

Všechny technické informace musí být dostatečně podrobné, aby bylo možné podle dokumentace navázat na vývoj projektu i po delší době.

---

## 9.3 Shrnutí kapitoly

Každá významnější kapitola bude zakončena stručným shrnutím.

Shrnutí nebude opakováním předchozího textu. Jeho cílem je připomenout hlavní myšlenky kapitoly a vysvětlit jejich význam pro další části projektu.

Součástí shrnutí bude také informace o tom, na kterou kapitolu nebo dokument text dále navazuje.

Tím vznikne přirozené propojení celé dokumentace.

---

# 10. Používání tabulek

Tabulky představují důležitou součást technické dokumentace. Slouží především k přehlednému porovnávání informací, nikoliv k nahrazování souvislého textu.

Tabulka nikdy nesmí být použita jako jediný zdroj informací. Pokud je některé téma popsáno pomocí tabulky, musí být její význam vysvětlen také v okolním textu.

Při tvorbě tabulek budou dodržována následující pravidla:

* tabulka obsahuje pouze informace, které se skutečně porovnávají,
* názvy sloupců jsou stručné a jednoznačné,
* nepoužívají se zbytečné dekorativní prvky,
* před tabulkou je vždy uvedeno krátké vysvětlení jejího účelu,
* po tabulce následuje stručná interpretace výsledků.

Grafické provedení tabulek bude jednoduché. Používány budou pouze jemné oddělovací čáry a odstíny šedé.

---

# 11. Používání diagramů

Některé části systému nelze dostatečně vysvětlit pouze textem.

Architektura databáze, tok dat nebo vzájemné vztahy mezi moduly jsou typickými příklady oblastí, kde je vhodné použít diagram.

Každý diagram musí být doplněn vysvětlením.

Diagram nikdy nesmí nahrazovat text.

Jeho úkolem je usnadnit pochopení popisovaného řešení.

Dokumentace MatchMatrix bude využívat zejména:

* architektonické diagramy,
* datové toky,
* schémata databází,
* workflow,
* procesní diagramy,
* hierarchické diagramy.

Grafické provedení diagramů bude sjednoceno napříč celým projektem.

---

# 12. Používání příloh

Některé informace jsou příliš rozsáhlé na to, aby byly součástí hlavního textu.

Jedná se například o:

* rozsáhlé SQL skripty,
* seznamy providerů,
* dlouhé referenční tabulky,
* exporty z databáze,
* historické přehledy,
* technické specifikace.

Takové informace budou umístěny do příloh.

Hlavní text bude obsahovat pouze odkaz na příslušnou přílohu a stručné vysvětlení jejího významu.

Díky tomu zůstane dokument dobře čitelný i při velkém rozsahu.

---

# 13. Verzování dokumentace

Stejně jako zdrojové kódy podléhá verzování také dokumentace.

Každá významná změna dokumentu musí být zaznamenána.

Verzování umožňuje sledovat vývoj dokumentace v čase a usnadňuje návrat ke starším verzím v případě potřeby.

Každý dokument bude obsahovat minimálně následující informace:

* číslo verze,
* datum poslední úpravy,
* autora změny,
* stručný popis významných změn.

Podrobnější historie změn bude vedena v dokumentu **MATCHMATRIX CHANGELOG**.

---

# 14. Odkazování mezi dokumenty

Jednotlivé dokumenty tvoří společně jeden celek.

Není proto žádoucí opakovat stejný obsah na více místech.

Pokud některá kapitola navazuje na jiný dokument, bude na něj výslovně odkazovat.

Například dokument **MATCHMATRIX MASTER** nebude znovu podrobně popisovat architekturu databáze. Uvede pouze její význam a odkáže čtenáře na dokument **MATCHMATRIX ARCHITECTURE**, kde je problematika popsána podrobně.

Tím je zajištěna konzistence celé dokumentace a výrazně jednodušší údržba.

---

# Závěr třetí části

Touto částí byly definovány základní stavební prvky dokumentace MatchMatrix. Byl popsán doporučený způsob tvorby kapitol, práce s tabulkami, diagramy, přílohami i systém verzování a vzájemného propojení dokumentů.

V závěrečné části dokumentu bude popsán proces schvalování dokumentace, pravidla dlouhodobé údržby, doporučený pracovní postup při tvorbě nových dokumentů a závěrečné shrnutí celého standardu. Tím bude dokončena první oficiální verze dokumentu **MATCHMATRIX DOCUMENTATION STANDARD**.

# 15. Proces tvorby nové dokumentace

Dokumentace projektu MatchMatrix nevzniká jednorázově. Vyvíjí se společně se systémem a reaguje na jeho průběžný rozvoj. Každý nový dokument proto vzniká podle jednotného pracovního postupu, jehož cílem je zajistit vysokou kvalitu, dlouhodobou udržitelnost a konzistenci celé znalostní základny.

Při vytváření nového dokumentu není cílem pouze zaznamenat technické informace. Dokument musí především vysvětlit význam popisované oblasti, její místo v architektuře projektu a důvody přijatých rozhodnutí.

Každý nový dokument prochází následujícími kroky:

1. Definování účelu dokumentu.
2. Stanovení rozsahu dokumentu.
3. Návrh základní struktury kapitol.
4. Zpracování odborného obsahu.
5. Kontrola návazností na ostatní dokumenty.
6. Revize textu.
7. Zařazení mezi oficiální dokumentaci.

Dodržování tohoto postupu zajistí, že všechny dokumenty budou vznikat jednotným způsobem bez ohledu na oblast projektu, které se týkají.

---

## 15.1 Dokumentace vzniká průběžně

Jedním z důležitých principů projektu MatchMatrix je skutečnost, že dokumentace nevzniká až po dokončení vývoje.

Naopak.

Významné architektonické změny, nově vytvořené moduly nebo zásadní rozhodnutí jsou dokumentovány průběžně. Díky tomu nedochází ke ztrátě znalostí a dokumentace vždy odpovídá skutečnému stavu systému.

Tento přístup současně výrazně snižuje množství práce potřebné při pozdější aktualizaci dokumentace.

---

## 15.2 Dokumentace není pracovní poznámka

Pracovní poznámky mají v projektu své místo.

Slouží především k zaznamenávání nápadů, průběhu řešení problémů nebo krátkodobých úkolů.

Oficiální dokumentace však představuje něco jiného.

Je výsledkem zpracování těchto poznámek do ucelené a dlouhodobě použitelné podoby.

Při převodu pracovních zápisů do dokumentace se proto:

* odstraňují duplicity,
* sjednocuje terminologie,
* doplňují souvislosti,
* vysvětlují důvody rozhodnutí,
* upravuje struktura textu.

Výsledkem není přepis pracovního deníku, ale kvalitní odborný dokument.

---

# 16. Revize dokumentace

Každý dokument bude pravidelně kontrolován.

Účelem revize není pouze oprava pravopisných nebo formálních chyb.

Revize ověřuje zejména:

* aktuálnost informací,
* správnost technického popisu,
* návaznost na ostatní dokumenty,
* soulad s aktuální architekturou systému,
* dodržování pravidel dokumentace.

Pokud některá část dokumentu přestane odpovídat skutečnému stavu projektu, musí být aktualizována v co nejkratší době.

---

## 16.1 Historie dokumentů

Vývoj projektu MatchMatrix je dlouhodobý proces.

Stejně tak se bude vyvíjet i dokumentace.

Starší informace proto nebudou bezdůvodně mazány.

Pokud již nejsou součástí aktuálního řešení, budou přesunuty do historické části dokumentace nebo budou nahrazeny novější verzí s uvedením důvodu změny.

Díky tomu bude možné kdykoliv dohledat vývoj architektury projektu i důvody jednotlivých rozhodnutí.

---

# 17. Odpovědnost za dokumentaci

Dokumentace představuje oficiální znalostní základnu projektu MatchMatrix.

Za její správnost odpovídá autor projektu.

Technická spolupráce při tvorbě dokumentace může být zajištěna prostřednictvím nástrojů umělé inteligence, avšak konečné rozhodnutí o obsahu, architektuře i pravidlech dokumentace vždy přísluší autorovi projektu.

Tento princip zajišťuje, že dokumentace zůstává jednotná a odpovídá skutečnému směřování projektu.

---

# 18. Dlouhodobá strategie dokumentace

Dokumentace MatchMatrix není vytvářena pouze pro současnou fázi vývoje.

Je navržena jako dlouhodobá znalostní základna, která bude postupně rozšiřována společně s celým projektem.

Každý nový modul systému, každá nová databázová vrstva, nový poskytovatel dat nebo významné architektonické rozhodnutí budou doplněny odpovídající dokumentací.

Díky tomu bude možné kdykoliv pochopit nejen aktuální stav systému, ale také celý jeho historický vývoj.

Dokumentace se tak stává nedílnou součástí hodnoty projektu MatchMatrix.

---

# Závěr dokumentu

Dokument **MATCHMATRIX DOCUMENTATION STANDARD** představuje základní kámen celé dokumentační základny projektu.

Stanovuje pravidla, podle kterých budou vytvářeny všechny budoucí dokumenty. Definuje jejich účel, strukturu, vzájemné vazby i způsob dlouhodobé správy.

Dodržování tohoto standardu zajistí, že dokumentace bude tvořit jednotný celek, který bude možné průběžně rozšiřovat bez ztráty přehlednosti nebo kvality.

Stejně jako je databáze základem datové části systému a architektura základem technického řešení, představuje dokumentace základní prostředek pro uchování znalostí získaných během vývoje projektu.

Dokumentace proto není v projektu MatchMatrix vnímána jako administrativní povinnost. Je považována za strategickou součást systému, která umožňuje jeho dlouhodobý rozvoj, snadnou orientaci v architektuře a efektivní navazování na již vykonanou práci.

---

# Stav dokumentu

**Dokument:** MM-DOC-000 – MATCHMATRIX DOCUMENTATION STANDARD

**Verze:** 0.9 (První kompletní pracovní návrh)

**Stav:** Připraven k první revizi.

---

## Navazující dokument

Po schválení tohoto dokumentu bude vytvořen:

> **01_MATCHMATRIX_MASTER.md**

který bude představovat hlavní strategický dokument celého projektu MatchMatrix a bude obsahovat ucelený popis vize, architektury, dlouhodobých cílů a současného stavu projektu.

