# MM-DOC-002

# MATCHMATRIX GOVERNANCE

---

## Informace o dokumentu

| Položka              | Hodnota                                           |
| :------------------- | :------------------------------------------------ |
| Název dokumentu      | MATCHMATRIX GOVERNANCE                            |
| Označení             | MM-DOC-002                                        |
| Verze                | 1.0                              |
| Stav                 | REVIEW                                      |
| Autor projektu       | Petr                                              |
| Technická spolupráce | OpenAI ChatGPT                                    |
| Primární formát      | Markdown (.md)                                    |
| Umístění             | `docs/02_GOVERNANCE/02_MATCHMATRIX_GOVERNANCE.md` |

---

# Motto

> **Databázi lze vytvořit za několik měsíců. Dlouhodobě kvalitní systém lze udržet pouze pomocí jasně definovaných pravidel.**

---

# Obsah

1. Úvod
2. Proč vznikla Governance
3. Filozofie Governance
4. Cíle Governance
5. Oblasti řízení projektu
6. Budoucí rozvoj Governance

---

---

# 0. Smysl Governance

Governance v projektu MatchMatrix nevznikla jako administrativní vrstva ani jako soubor formálních pravidel.

Jejím hlavním účelem je chránit dlouhodobou hodnotu společnosti MatchMatrix prostřednictvím ochrany kvality dat, procesů, produktů, služeb a znalostí.

Databáze představuje strategické aktivum společnosti. Governance zajišťuje, aby toto aktivum bylo dlouhodobě konzistentní, důvěryhodné, rozšiřitelné a připravené podporovat všechny produkty a služby platformy.

Každé pravidlo Governance musí v konečném důsledku přispívat ke zvýšení hodnoty platformy pro její uživatele a tím i k dlouhodobému rozvoji společnosti.

---

# 1. Úvod

Během prvních měsíců vývoje projektu MatchMatrix bylo hlavním cílem vytvořit funkční databázovou architekturu a připravit systém pro získávání sportovních dat z různých poskytovatelů. Postupně vznikaly nové tabulky, nové harvest skripty, merge procesy i první automatizované kontroly.

S rostoucím rozsahem projektu se však začal objevovat nový problém.

Nebyl technický.

Byl organizační.

Každý nový provider přinášel jinou strukturu dat.

Každý sport používal odlišné identifikátory.

Každý nový modul vyžadoval vlastní pravidla.

Ukázalo se, že samotná databáze již nestačí.

Bylo potřeba vytvořit vrstvu, která nebude ukládat sportovní data, ale bude řídit způsob jejich vzniku, kontroly a dlouhodobé správy.

Tak vznikla Governance.

---

# 2. Proč vznikla Governance

Governance nebyla součástí původního návrhu projektu.

Vznikla až ve chvíli, kdy databáze začala obsahovat desetitisíce týmů, stovky tisíc zápasů a stále větší počet poskytovatelů dat.

Právě tehdy se začaly objevovat problémy, které nebylo možné řešit běžnými SQL skripty.

Například:

stejný tým měl u různých providerů odlišné identifikátory,

hráči byli zapisováni pod různými jmény,

jednotlivé soutěže měly několik různých názvů,

některé zápasy byly staženy vícekrát,

historická data měla jinou strukturu než data aktuální.

Každý podobný problém bylo možné jednorázově opravit.

Bylo však zřejmé, že takový přístup není dlouhodobě udržitelný.

Projekt potřeboval systém, který nebude pouze opravovat chyby.

Bude jejich vzniku předcházet.

Právě tímto okamžikem začala vznikat Governance Layer.

---

# 3. Filozofie Governance

Governance v projektu MatchMatrix nepředstavuje administrativní pravidla.

Jejím hlavním úkolem je chránit kvalitu celé platformy.

Každé pravidlo, audit nebo kontrolní mechanismus vznikl jako reakce na konkrétní problém, který se během vývoje skutečně objevil.

To je důležitý rozdíl oproti běžným projektům.

Pravidla nevznikají teoreticky.

Vznikají na základě praktických zkušeností.

Stejným způsobem budou vznikat i v budoucnu.

Governance proto není uzavřený dokument.

Je to živý systém pravidel, který se bude vyvíjet společně s celou platformou.

---

# 4. Cíle Governance

Governance byla vytvořena s několika dlouhodobými cíli.

Prvním cílem je ochrana kvality dat.

Databáze musí obsahovat správné informace.

Stejně důležité však je, aby byly správně propojeny.

Proto Governance kontroluje nejen jednotlivé záznamy, ale také jejich vzájemné vztahy.

Dalším cílem je dlouhodobá stabilita architektury.

Projekt bude v budoucnu obsahovat desítky providerů, miliony záznamů a stovky automatizačních procesů.

Bez jednotných pravidel by se architektura postupně stávala stále složitější.

Governance proto vytváří společný rámec pro celý projekt.

Třetím cílem je automatizace kontrol.

Ruční kontrola databáze je možná pouze u malých systémů.

MatchMatrix je navržen tak, aby většina kontrol probíhala automaticky prostřednictvím auditů, kontrolních skriptů a monitorovacích nástrojů.

Posledním cílem je uchování dlouhodobé konzistence projektu.

Stejná pravidla musí platit bez ohledu na to, kolik let bude projekt vyvíjen nebo kolik nových modulů vznikne.

---

# 5. Governance jako základ důvěryhodnosti

Jedním z hlavních principů MatchMatrix je skutečnost, že žádná informace není považována za správnou pouze proto, že ji poskytl některý provider.

Každá informace prochází vlastním systémem ověřování.

Tento přístup se může na první pohled zdát složitější.

Ve skutečnosti však představuje jednu z největších výhod celé platformy.

MatchMatrix totiž postupně přestává být databází providerů.

Stává se vlastní autoritou.

Databází, která sama rozhoduje o kvalitě ukládaných informací.

Právě díky Governance bude možné dlouhodobě kombinovat data z mnoha různých zdrojů a přitom zachovat jejich konzistenci.

---

# Závěr první části

Governance vznikla jako přirozená reakce na růst projektu MatchMatrix. S rostoucím množstvím dat již nestačilo pouze ukládat informace do databáze. Bylo nutné vytvořit systém pravidel, kontrol a auditů, který bude dlouhodobě chránit kvalitu celé platformy.

V dalších kapitolách budou podrobně popsány jednotlivé oblasti Governance – databázová pravidla, standardy vývoje, řízení providerů, prevence duplicit, auditní mechanismy, pravidla tvorby skriptů i způsob dlouhodobé správy architektury projektu.

# 6. Oblasti Governance

Governance projektu MatchMatrix nepředstavuje jednu samostatnou funkci nebo jediný kontrolní mechanismus. Jedná se o soubor vzájemně propojených pravidel, jejichž společným cílem je zajistit dlouhodobou kvalitu celé platformy.

Každá oblast Governance vznikla na základě konkrétních zkušeností získaných během vývoje projektu. V okamžiku, kdy se některý problém začal opakovat, nebyl řešen pouze jednorázovou opravou. Byl navržen systém, který podobným situacím zabrání i v budoucnu.

Díky tomuto přístupu se Governance postupně stala jedním z nejdůležitějších pilířů celé architektury MatchMatrix.

---

# 6.1 Database Governance

Databáze představuje základ celé platformy.

Jakmile dojde k narušení její konzistence, projeví se problém postupně ve všech dalších vrstvách systému.

Proto byla jako první vytvořena Database Governance.

Jejím hlavním úkolem je zajistit, aby databáze dlouhodobě zachovávala jednotnou strukturu, konzistentní vztahy mezi jednotlivými entitami a správné mapování všech dat.

Database Governance se zaměřuje zejména na:

* návrh databázových schémat,
* pravidla vytváření nových tabulek,
* správu primárních a cizích klíčů,
* jednotné pojmenování databázových objektů,
* správu indexů,
* pravidla migrací,
* ochranu historických dat.

Každá změna databáze musí být navržena tak, aby nenarušila již existující architekturu systému.

---

# 6.2 Provider Governance

Jedním z největších rizik každé sportovní platformy je závislost na poskytovatelích dat.

Projekt MatchMatrix byl od začátku navržen tak, aby žádný provider nepředstavoval nenahraditelnou součást systému.

Provider Governance proto stanovuje pravidla pro:

* zařazování nových providerů,
* hodnocení jejich kvality,
* správu licenčních podmínek,
* sledování změn API,
* správu verzí providerů,
* plánování jejich náhrady.

Součástí této oblasti je také pravidelné vyhodnocování dlouhodobé spolehlivosti jednotlivých zdrojů.

Provider není považován pouze za zdroj dat.

Je hodnocen jako dlouhodobý partner systému.

---

# 6.3 Entity Governance

Během vývoje se ukázalo, že právě entity představují jednu z nejsložitějších oblastí celé databáze.

Stejný tým může být u různých providerů veden pod několika názvy.

Stejný hráč může mít odlišný způsob zápisu jména.

Stejná soutěž může být přejmenována nebo rozdělena podle sezón.

Entity Governance vznikla proto, aby každá reálná entita měla v databázi právě jednu oficiální reprezentaci.

Veškeré ostatní názvy, identifikátory nebo varianty jsou pouze alternativními odkazy na stejnou entitu.

Tento princip výrazně zjednodušuje práci celé databáze a umožňuje bezpečně spojovat data z různých zdrojů.

---

# 6.4 Duplicate Prevention Governance

Jedním z největších problémů při slučování dat z více providerů jsou duplicity.

Nejde pouze o duplicitní týmy.

Stejný problém se může týkat:

* hráčů,
* trenérů,
* stadionů,
* soutěží,
* zápasů,
* fotografií,
* článků.

V projektu MatchMatrix proto vznikl samostatný systém prevence duplicit.

Jeho cílem není pouze duplicitní záznamy odstraňovat.

Mnohem důležitější je zabránit jejich vzniku.

Každá nová entita prochází kontrolou ještě před svým zařazením do produkční databáze.

Díky tomu zůstává databáze dlouhodobě konzistentní i při zpracování milionů záznamů.

---

# 6.5 Source Governance

Jedním z charakteristických znaků MatchMatrix je práce se samotnými zdroji informací.

Nestačí pouze evidovat poskytovatele dat.

Je nutné znát také:

* jejich původ,
* důvěryhodnost,
* rozsah dat,
* způsob licencování,
* obchodní model,
* omezení použití,
* robots.txt,
* podmínky využití.

Právě z těchto důvodů vznikla Source Governance.

Ta úzce spolupracuje se Source Intelligence Layer a vytváří centrální evidenci všech datových zdrojů využívaných projektem.

Tato oblast bude v budoucnu patřit mezi nejvýznamnější konkurenční výhody MatchMatrix.

---

# 6.6 Script Governance

Rozsah projektu postupně vedl ke vzniku stovek skriptů.

Bez jednotných pravidel by se jejich údržba stala velmi obtížnou.

Script Governance proto stanovuje jednotný standard pro všechny skripty projektu.

Každý nový skript musí obsahovat:

* popis účelu,
* popis vstupů,
* popis výstupů,
* přesnou cestu k uložení,
* návaznost na další části systému,
* způsob spuštění.

Tento standard výrazně usnadňuje orientaci v projektu a umožňuje rychle navázat na práci i po delší době.

---

# 6.7 Documentation Governance

Stejně důležitá jako databáze je také dokumentace.

Documentation Governance zajišťuje, že všechny dokumenty vznikají podle jednotného standardu definovaného dokumentem **MM-DOC-000**.

Současně určuje pravidla:

* verzování dokumentace,
* struktury dokumentů,
* vzájemného odkazování,
* práce s přílohami,
* schvalování změn.

Dokumentace se tak stává plnohodnotnou součástí architektury projektu.

---

# 7. Governance jako konkurenční výhoda

Většina sportovních databází se soustředí především na získávání nových dat.

MatchMatrix jde jinou cestou.

Stejnou pozornost věnuje také kvalitě těchto dat.

Právě Governance představuje rozdíl mezi databází, která pouze ukládá informace, a platformou, která je schopna dlouhodobě garantovat jejich konzistenci.

Čím bude projekt větší, tím větší význam bude Governance mít.

Ve skutečnosti lze očekávat, že její význam poroste rychleji než samotná databáze.

To je jeden z hlavních důvodů, proč byla Governance od určité fáze vývoje povýšena na samostatnou architektonickou vrstvu projektu.

---

# Závěr druhé části

Governance dnes zasahuje prakticky do všech oblastí projektu MatchMatrix. Chrání databázovou architekturu, řídí práci s poskytovateli dat, spravuje entity, zabraňuje duplicitám, stanovuje pravidla pro vývoj skriptů i pro tvorbu dokumentace.

Ve třetí části dokumentu budou popsány konkrétní governance procesy, které již byly během vývoje MatchMatrix vytvořeny. Půjde například o řízení canonical entit, systém auditů, kontrolní mechanismy OPS, řízení kvality harvestu a praktické zkušenosti získané při budování platformy.

# 8. Praktická implementace Governance v projektu MatchMatrix

Předchozí kapitoly popsaly filozofii a hlavní oblasti Governance. V této části dokumentu jsou uvedeny konkrétní mechanismy, které byly během vývoje MatchMatrix skutečně vytvořeny a které dnes představují základ řízení kvality celé platformy.

Na rozdíl od obecných metodik se Governance MatchMatrix neopírá o teoretická doporučení. Vznikala postupně jako reakce na reálné problémy objevené při budování databáze, ingest pipeline a víceproviderové architektury.

Každý nový governance mechanismus byl vytvořen proto, že řešil konkrétní problém, který již nebylo možné efektivně řešit ručně.

---

# 8.1 Canonical Entity Governance

Jedním z prvních velkých problémů projektu bylo zjištění, že různí provideři používají pro stejné sportovní entity odlišné identifikátory, názvy i strukturu dat.

Například jeden fotbalový klub mohl být u různých providerů veden pod několika různými názvy, přestože šlo stále o stejnou organizaci.

Stejný problém se postupně objevil také u:

* hráčů,
* trenérů,
* soutěží,
* stadionů,
* rozhodčích,
* zápasů.

Jednorázové opravy již nebyly možné.

Proto vznikl systém Canonical Entity Governance.

Jeho hlavním principem je vytvoření jediné interní reprezentace každé skutečné entity.

Provider již neurčuje identitu objektu.

Pouze dodává data.

Identitu vytváří MatchMatrix.

Tím vzniká stabilní základ celé databáze.

---

# 8.2 Duplicate Prevention

Další významný krok představoval vznik systému prevence duplicit.

Zpočátku byly duplicity odstraňovány ručně.

S rostoucím počtem providerů však začal jejich počet rychle narůstat.

Bylo proto rozhodnuto vytvořit samostatný governance proces, který bude duplicity odhalovat ještě před jejich zařazením do produkční databáze.

Postupně vznikly samostatné mechanismy například pro:

* Team Duplicate Prevention,
* Player Duplicate Prevention,
* League Duplicate Prevention,
* Match Duplicate Prevention.

Každý z těchto mechanismů využívá vlastní pravidla porovnávání a vlastní systém hodnocení rizika.

Výsledkem není pouze odstranění duplicit.

Výsledkem je především zabránění jejich dalšímu vzniku.

---

# 8.3 League Governance

Jednou z nejsložitějších oblastí se ukázala být správa sportovních soutěží.

Různí provideři často používají:

* odlišné názvy soutěží,
* různé úrovně členění,
* rozdílné identifikátory,
* historické názvy,
* regionální varianty.

Proto vznikl systém League Governance.

Jeho úkolem je vytvářet jednotnou evidenci všech soutěží bez ohledu na jejich původ.

Součástí této oblasti je také správa:

* canonical league,
* provider mapping,
* historických názvů,
* slučování duplicit,
* kontrol integrity soutěží.

League Governance dnes představuje jeden z nejdůležitějších pilířů celé Core Layer.

---

# 8.4 Provider Health Monitoring

Během vývoje projektu se ukázalo, že jednotliví provideři mají velmi rozdílnou kvalitu služeb.

Někteří mění API.

Jiní mění limity.

Další přestávají poskytovat určitá data.

Vznikl proto systém průběžného sledování stavu providerů.

Provider Health Monitoring průběžně vyhodnocuje například:

* dostupnost API,
* rychlost odpovědí,
* počet chyb,
* změny endpointů,
* úspěšnost harvestu,
* kvalitu získaných dat.

Na základě těchto informací lze včas rozhodnout o změně strategie nebo přechodu na jiného poskytovatele.

---

# 8.5 Harvest Governance

Harvest představuje jednu z nejkritičtějších částí celé platformy.

Jakmile selže harvest, začnou se postupně zastavovat všechny další procesy.

Harvest Governance proto neřídí pouze samotné stahování dat.

Řídí celý životní cyklus harvest úloh.

Součástí této oblasti je například:

* plánování harvestu,
* priority sportů,
* priority providerů,
* retry mechanismy,
* kontrola timeoutů,
* řízení historických harvestů,
* řízení denních aktualizací,
* audit úspěšnosti.

Výsledkem je systém, který dokáže dlouhodobě pracovat s minimální potřebou manuálních zásahů.

---

# 8.6 OPS Governance

S růstem projektu již nebylo možné sledovat stav systému pouze pomocí SQL dotazů.

Vznikla proto samostatná OPS vrstva.

Jejím cílem je poskytovat jednotný pohled na stav celé platformy.

OPS Governance stanovuje pravidla pro:

* dashboardy,
* KPI,
* auditní pohledy,
* kontrolní reporty,
* doporučení operátorovi,
* prioritizaci úloh.

Díky tomu lze během několika minut zjistit aktuální stav celé platformy bez nutnosti ruční analýzy databáze.

---

# 9. Governance jako živý systém

Jedním z nejdůležitějších principů MatchMatrix je skutečnost, že Governance není uzavřený seznam pravidel.

Vyvíjí se společně s projektem.

Každý nový problém představuje příležitost vytvořit nové pravidlo nebo nový kontrolní mechanismus.

Stejně tak každá nová vrstva systému automaticky přináší nové požadavky na Governance.

Tento přístup umožňuje dlouhodobě udržovat kvalitu celé platformy i při jejím neustálém rozšiřování.

Governance proto nebude nikdy považována za dokončenou.

Bude růst společně s MatchMatrix.

---

# Závěr třetí části

Praktická implementace Governance představuje jednu z největších konkurenčních výhod projektu MatchMatrix. Díky ní není platforma pouze databází sportovních dat, ale systémem, který dokáže tato data dlouhodobě spravovat, ověřovat a chránit jejich kvalitu.

V závěrečné části dokumentu budou popsány pravidla dlouhodobé správy Governance, její budoucí rozvoj, vztah k ostatním architektonickým vrstvám a závěrečné shrnutí významu Governance pro celý projekt MatchMatrix.

# 10. Dlouhodobá správa Governance

Governance není jednorázový projekt ani sada pravidel, která budou po svém vytvoření neměnná. Naopak představuje dlouhodobý proces, který se bude vyvíjet společně s celou platformou MatchMatrix.

S každým novým sportem, poskytovatelem dat, databázovou vrstvou nebo funkcí aplikace budou vznikat nové situace, které si vyžádají rozšíření existujících pravidel nebo vytvoření pravidel nových.

Z tohoto důvodu je Governance navržena jako otevřený systém, který lze průběžně rozšiřovat bez narušení již existující architektury.

Každá významná změna bude dokumentována a současně bude vyhodnocen její dopad na ostatní části systému.

---

# 10.1 Governance jako součást každého nového modulu

Jedním z nejdůležitějších pravidel MatchMatrix je skutečnost, že žádný nový modul nesmí vzniknout bez odpovídající Governance.

To znamená, že při návrhu nové části systému se neřeší pouze její technická implementace.

Současně se navrhuje také:

* způsob kontroly kvality,
* pravidla správy dat,
* auditní mechanismy,
* monitorování provozu,
* vazby na ostatní vrstvy.

Díky tomu nevznikají části systému, které by fungovaly izolovaně nebo nebyly dlouhodobě udržitelné.

---

# 10.2 Governance a automatizace

Jedním z hlavních dlouhodobých cílů je postupný přechod od ručních kontrol k plně automatizovanému řízení kvality.

V současné době již značná část auditů probíhá automaticky.

Do budoucna bude systém schopen samostatně:

* vyhodnocovat rizika,
* upozorňovat na nekonzistence,
* navrhovat opravy,
* doporučovat priority,
* sledovat dlouhodobé trendy,
* připravovat podklady pro rozhodování.

Operátor nebude nahrazován.

Naopak bude mít k dispozici kvalitnější informace pro strategická rozhodnutí.

---

# 10.3 Governance jako podklad pro umělou inteligenci

Budoucí AI vrstva nebude pracovat pouze se sportovními daty.

Významnou roli budou hrát také informace vytvářené Governance.

Například:

* kvalita providerů,
* důvěryhodnost zdrojů,
* historie změn,
* úspěšnost harvestů,
* výsledky auditů,
* dlouhodobé trendy.

Umělá inteligence tak nebude analyzovat pouze výsledky zápasů.

Bude schopna vyhodnocovat také kvalitu samotné datové základny.

To představuje významný rozdíl oproti běžným sportovním databázím.

---

# 11. Vztah Governance k ostatním dokumentům

Governance není samostatně stojící dokument.

Je úzce propojena s ostatní dokumentací projektu.

Zejména s následujícími dokumenty:

**MM-DOC-001 – MATCHMATRIX MASTER**

Popisuje strategické důvody vzniku Governance a její místo v architektuře celé platformy.

**MM-DOC-003 – MATCHMATRIX ARCHITECTURE**

Detailně vysvětluje technickou architekturu databáze, pipeline a jednotlivých vrstev systému, nad kterými Governance vykonává dohled.

**MM-DOC-004 – MATCHMATRIX DEVELOPMENT HANDBOOK**

Obsahuje konkrétní pracovní postupy pro vývojáře, kteří musí pravidla Governance při své práci dodržovat.

**MM-DOC-008 – MATCHMATRIX ARCHITECTURAL DECISIONS**

Zachycuje historické důvody jednotlivých governance rozhodnutí a jejich vývoj v průběhu projektu.

Toto rozdělení umožňuje ponechat dokument Governance přehledný a současně zabránit zbytečnému opakování informací.

---

# 12. Budoucí rozvoj Governance

Vývoj Governance bude pokračovat společně s vývojem celé platformy.

V dalších etapách projektu se předpokládá zejména rozšíření o:

* AI Governance,
* Data Quality Score,
* automatické schvalování merge procesů,
* inteligentní detekci duplicit,
* správu licencí providerů,
* řízení životního cyklu dat,
* správu historických verzí entit,
* automatické doporučování nových providerů,
* komplexní monitoring všech vrstev platformy.

Tyto oblasti budou rozvíjeny postupně podle potřeb projektu a budou navazovat na již existující governance mechanismy.

---

# 13. Závěr dokumentu

Governance představuje jeden z nejvýznamnějších architektonických prvků projektu MatchMatrix.

Nevznikla jako administrativní vrstva ani jako soubor formálních pravidel. Je výsledkem praktických zkušeností získaných během budování rozsáhlé sportovní databáze, která postupně začala pracovat s miliony záznamů, desítkami providerů a stále složitějšími vazbami mezi jednotlivými entitami.

Dlouhodobým cílem Governance není kontrolovat jednotlivé databázové tabulky.

Jejím skutečným posláním je chránit kvalitu celé platformy.

Každé pravidlo, audit nebo kontrolní mechanismus představuje investici do budoucnosti projektu. Díky nim bude možné MatchMatrix dále rozšiřovat, aniž by docházelo ke ztrátě konzistence nebo přehlednosti systému.

Governance tak není pouze jednou z vrstev architektury.

Stává se jejím stabilizačním prvkem.

Stejně jako databáze představuje základ datové části systému, představuje Governance základ dlouhodobé důvěryhodnosti celé platformy.

---

# Stav dokumentu

**Dokument:** MM-DOC-002 – MATCHMATRIX GOVERNANCE

**Verze:** 0.9 – První kompletní pracovní návrh

**Stav:** Připraven k první odborné revizi

---

## Navazující dokument

Dalším dokumentem dokumentační řady bude:

> **MM-DOC-003 – MATCHMATRIX ARCHITECTURE**

Tento dokument bude představovat technické srdce celé dokumentace. Podrobně popíše architekturu databáze, jednotlivé databázové vrstvy (`staging`, `public`, `ops`, `runtime`), datové toky, ingest pipeline, merge procesy, Source Intelligence Layer, Control Panel, PC1/PC2 architekturu, automatizaci harvestu a vazby mezi všemi hlavními moduly systému. Na rozdíl od předchozích dokumentů bude vycházet přímo ze skutečné architektury MatchMatrix, kterou jsme během posledních měsíců vybudovali.


---

# AI CONTEXT

**Role dokumentu:** Definuje systém řízení pravidel, kvality a dlouhodobé udržitelnosti platformy MatchMatrix.

**Navazuje na:** MM-DOC-000, MM-DOC-001, MM-STD-001 až MM-STD-009.

---

# PROJECT SNAPSHOT

*Tato sekce je připravena pro automatické generování z Documentation Management System.*

---

# CURRENT STATUS

| Oblast | Stav |
|--------|------|
| Database Governance | ACTIVE |
| Provider Governance | ACTIVE |
| Entity Governance | ACTIVE |
| Documentation Governance | ACTIVE |
| Source Governance | DEVELOPMENT |
| AI Governance | PLANNED |

---

# OPEN QUESTIONS

- AI Governance
- Security Governance
- Billing Governance
- Legal Governance

---

# NEXT STEP

Navázat dokumentem MM-DOC-003 – MatchMatrix Architecture a rozpracovat technickou architekturu celé platformy.
