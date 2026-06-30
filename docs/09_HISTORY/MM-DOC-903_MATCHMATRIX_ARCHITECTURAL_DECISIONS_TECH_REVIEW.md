# MM-DOC-903
# MATCHMATRIX ARCHITECTURAL DECISIONS
## TECH EDITION

## Informace o dokumentu
| Položka | Hodnota |
|---|---|
| Dokument | MM-DOC-903 |
| Název | MatchMatrix Architectural Decisions |
| Edice | MM-DOC TECH |
| Verze | 1.1 |
| Stav | REVIEW |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Původní pracovní označení | MM-DOC-008 |
| Umístění | `docs/09_HISTORY/MM-DOC-903_MATCHMATRIX_ARCHITECTURAL_DECISIONS_TECH.md` |

## Poznámka k přečíslování
Původní pracovní označení dokumentu bylo **MM-DOC-008**. V aktuální dokumentační struktuře je dokument zařazen jako **MM-DOC-903**, protože tvoří součást řady projektové historie, kontinuity a řízené znalosti společně s dokumenty:
- **MM-DOC-900 – MatchMatrix Denní zápisy**,
- **MM-DOC-901 – MatchMatrix Navázání**,
- **MM-DOC-902 – MatchMatrix Changelog**.

Přečíslování nemění účel ani odborný obsah dokumentu. Zajišťuje jeho správné zařazení do nové dokumentační architektury MatchMatrix.

## Motto
> **Architektura není soubor technologií. Architektura je soubor rozhodnutí.**

## Účel dokumentu
Tento dokument definuje pravidla pro evidenci, posuzování, schvalování, implementaci a dlouhodobou správu významných architektonických rozhodnutí projektu MatchMatrix. Stanovuje jednotný životní cyklus a strukturu záznamu **Architecture Decision Record (ADR; záznam architektonického rozhodnutí)**, který je v projektu označován identifikátorem `AD-xxxx`.

Dokument chrání nejen výslednou architekturu, ale také kontext, alternativy, důvody a důsledky rozhodnutí, která ji vytvořila.

## Rozsah dokumentu
Dokument upravuje:
- definici architektonického rozhodnutí,
- kritéria pro vznik samostatného záznamu `AD-xxxx`,
- životní a stavový cyklus rozhodnutí,
- strukturu jednotlivého záznamu,
- klasifikaci podle významu a oblasti,
- pravidla schvalování, implementace a ověření,
- neměnnost historických rozhodnutí a jejich nahrazování,
- vazby na CHANGELOG, ARCHITECTURE, GOVERNANCE, denní zápisy, NAVÁZÁNÍ, Git a milestone,
- budoucí správu prostřednictvím Documentation Management System.

## Cílová skupina
- autor a architekt projektu,
- vývojáři,
- databázoví specialisté,
- správci provozu a OPS,
- správci dokumentace,
- projektové řízení,
- budoucí spolupracovníci,
- systémy umělé inteligence analyzující architekturu a její historii.

## Související dokumenty
- **MM-DOC-000 – MatchMatrix Documentation Framework**
- **MM-DOC-100 – MatchMatrix Master**
- **MM-DOC-200 – MatchMatrix Governance**
- **MM-DOC-300 – MatchMatrix Architecture**
- **MM-DOC-800 – MatchMatrix Development Handbook**
- **MM-DOC-900 – MatchMatrix Denní zápisy**
- **MM-DOC-901 – MatchMatrix Navázání**
- **MM-DOC-902 – MatchMatrix Changelog**
- **MM-STD-001 až MM-STD-009**
- **MM-REF-001 – Slovník pojmů MatchMatrix**

## Zdroje REVIEW
REVIEW vychází z původního dokumentu **MM-DOC-008 – MatchMatrix Architectural Decisions (TECH)** a z aktuálních dokumentačních zdrojů MM-DOC-000, MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DOC-900, MM-DOC-901, MM-DOC-902, MM-STD-001 až MM-STD-009 a MM-REF-001. Při rozdílu mezi původním pracovním označením a novou dokumentační řadou bylo použito aktuální označení **MM-DOC-903**.

## Historie verzí
| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026 | DRAFT | První pracovní verze vedená pod označením MM-DOC-008. |
| 1.1 | 2026-06-29 | REVIEW | Přečíslování na MM-DOC-903, sjednocení struktury, terminologie, životního cyklu, stavů, vazeb a kontextových sekcí podle MM-STD-009. |

# Obsah
1. Úvod
2. Účel a hranice registru rozhodnutí
3. Definice architektonického rozhodnutí
4. Význam evidence rozhodnutí
5. Kritéria pro vznik záznamu AD
6. Životní a stavový cyklus rozhodnutí
7. Struktura záznamu AD
8. Klasifikace rozhodnutí
9. Schvalování, implementace a ověření
10. Vazby na ostatní dokumentaci a technické zdroje
11. Správa registru AD, verzování a archivace
12. Budoucí rozvoj a TECH V2
13. Závěr dokumentu
14. AI CONTEXT
15. PROJECT SNAPSHOT
16. DATABASE SNAPSHOT
17. CURRENT STATUS
18. OPEN QUESTIONS
19. NEXT STEP

# 0. Smysl registru architektonických rozhodnutí
Každá významná architektura vzniká posloupností rozhodnutí. Samotný výsledný stav systému však nevysvětluje, proč byly určité možnosti přijaty, jiné odmítnuty a jaké důsledky byly v okamžiku rozhodování známé.

Registr architektonických rozhodnutí chrání tuto znalost. Odpovídá zejména na otázku:
> **Proč je systém navržen právě tímto způsobem a jaké rozhodnutí k tomu vedlo?**

MM-DOC-903 stanovuje pravidla registru. Jednotlivé záznamy `AD-xxxx` uchovávají konkrétní rozhodnutí.

# 1. Úvod
Každý dlouhodobý projekt postupně vytváří stovky technických a organizačních rozhodnutí. Některá mají krátkodobý význam a týkají se pouze jednotlivé implementace. Jiná ovlivňují celý projekt na mnoho let. Právě tato druhá skupina vytváří architekturu systému.

Během vývoje MatchMatrix vznikla řada rozhodnutí, která zásadně ovlivnila podobu databáze, víceproviderové architektury, harvest pipeline, canonical entity modelu, Governance Layer, OPS panelu, infrastruktury PC1/PC2 i dokumentačního systému. Bez znalosti jejich kontextu je obtížné pochopit, proč je platforma navržena současným způsobem.

Dokument MATCHMATRIX ARCHITECTURAL DECISIONS proto zavádí centrálně řízený registr významných rozhodnutí. Jeho úkolem není pouze zaznamenat zvolené řešení. Stejně důležité je zachovat problém, omezení, posuzované alternativy, důvod volby, očekávané přínosy, rizika a skutečné dlouhodobé důsledky.

## 1.1 Přínos pro projekt
Systematická evidence rozhodnutí:
- zachovává důvody architektury,
- omezuje opakované analyzování již uzavřených problémů,
- zabraňuje neuváženému rušení principů bez znalosti jejich původu,
- podporuje předání projektu novým spolupracovníkům a AI,
- vytváří auditní stopu vývoje architektury,
- propojuje strategii, architekturu, governance, implementaci a historii změn.

## 1.2 Závěr kapitoly
Architektonická rozhodnutí představují dlouhodobou znalost projektu. Registr AD uchovává nejen výsledek, ale také kontext a důvody, bez kterých nelze architekturu bezpečně rozvíjet. Následující kapitola vymezuje účel a hranice tohoto registru.

# 2. Účel a hranice registru rozhodnutí
MM-DOC-903 představuje řídicí dokument pro celý systém architektonických rozhodnutí. Definuje, kdy má vzniknout samostatný záznam, jakou musí mít strukturu, jak prochází životním cyklem a jak se dlouhodobě spravuje.

Jednotlivé záznamy `AD-xxxx` tvoří centrální registr významných rozhodnutí projektu. Každý záznam má zachytit minimálně:
- problém a jeho kontext,
- omezení a požadavky,
- posuzované alternativy,
- zvolené řešení,
- důvod rozhodnutí,
- očekávané přínosy a rizika,
- dlouhodobé důsledky,
- vazbu na implementaci a související dokumentaci.

## 2.1 Co registr AD není
Registr architektonických rozhodnutí není:
- seznam všech programátorských úprav,
- kopie Git historie,
- denní pracovní zápis,
- seznam otevřených úkolů,
- CHANGELOG,
- úplný technický popis současné architektury,
- náhrada dokumentů MASTER, GOVERNANCE nebo ARCHITECTURE.

Každý z těchto zdrojů má vlastní odpovědnost. Registr AD vysvětluje rozhodnutí; ARCHITECTURE popisuje výsledný stav; CHANGELOG eviduje významný historický okamžik změny; denní zápisy zachycují pracovní průběh.

## 2.2 Rozhodnutí místo obecné diskuse
Záznam AD má vzniknout tehdy, když existuje konkrétní problém nebo volba s dlouhodobým dopadem. Nezakládá se pouze proto, že proběhla obecná technická diskuse nebo krátkodobý experiment.

## 2.3 Jedno rozhodnutí = jeden hlavní problém
Jeden záznam AD má řešit jeden hlavní architektonický problém. Pokud návrh současně obsahuje několik nezávislých rozhodnutí, rozdělí se do více záznamů s explicitními vazbami.

## 2.4 Závěr kapitoly
Registr AD je specializovaným zdrojem důvodů a důsledků významných rozhodnutí. Jasné oddělení od ostatní dokumentace zajišťuje jeho dlouhodobou použitelnost. Následující kapitola definuje, co je v MatchMatrix považováno za architektonické rozhodnutí.

# 3. Definice architektonického rozhodnutí
Architektonickým rozhodnutím se rozumí rozhodnutí, které významně ovlivňuje návrh, odpovědnosti, kvalitu, rozšiřitelnost, bezpečnost, provoz nebo budoucí vývoj systému.

Nejde o běžnou implementační úpravu. Typickým architektonickým rozhodnutím může být:
- změna databázové architektury,
- přechod ze sport-specific staging tabulek na sjednocené tabulky `stg_*`,
- zavedení víceproviderového modelu,
- zavedení Canonical Entity Model,
- vznik nové Layer,
- změna datového toku nebo harvest orchestrace,
- rozdělení odpovědností mezi PC1 a PC2,
- změna způsobu governance nebo automatizace,
- změna dokumentační architektury,
- volba významné infrastrukturní nebo bezpečnostní strategie.

Uvedené příklady představují typy rozhodnutí, nikoliv automaticky již publikované záznamy s přidělenými identifikátory.

## 3.1 Architektonický dopad
Rozhodnutí má architektonický dopad, pokud mění alespoň jednu z následujících oblastí:
- hranice a odpovědnosti modulů,
- datový model nebo tok dat,
- integraci poskytovatelů,
- provozní model,
- způsob škálování,
- kvalitu, auditovatelnost nebo bezpečnost,
- závazné technické principy,
- dlouhodobé náklady nebo obtížnost změny.

## 3.2 Rozdíl mezi rozhodnutím a standardem
Architektonické rozhodnutí zachycuje volbu v konkrétním kontextu. Standard stanovuje opakovaně platné pravidlo. Pokud se přijaté a ověřené rozhodnutí stane závazným pro širší část projektu, musí být podle potřeby promítnuto do GOVERNANCE, DEVELOPMENT HANDBOOK nebo MM-STD.

## 3.3 Rozdíl mezi rozhodnutím a implementací
Záznam AD popisuje, co a proč bylo rozhodnuto. Implementace popisuje, jak bylo rozhodnutí technicky realizováno. Jedno rozhodnutí může být realizováno více skripty, databázovými objekty, commity nebo etapami.

## 3.4 Závěr kapitoly
Architektonické rozhodnutí je dlouhodobá volba ovlivňující strukturu nebo vlastnosti platformy. Následující kapitola vysvětluje, proč musí být tyto volby systematicky evidovány.

# 4. Význam evidence rozhodnutí
Po několika měsících nebo letech bývá obtížné přesně určit, proč bylo určité řešení zvoleno. Zdrojový kód ukazuje výslednou implementaci, ale obvykle neobsahuje úplný kontext rozhodování. Dokument ARCHITECTURE ukazuje výsledný stav, ale nemusí vysvětlovat všechny odmítnuté alternativy.

Bez registru rozhodnutí vznikají zejména tato rizika:
- opakovaná analýza stejného problému,
- návrat k dříve odmítnutému řešení bez znalosti důvodu odmítnutí,
- odstranění důležitého principu jako zdánlivě zbytečné složitosti,
- ztráta historických souvislostí při předání projektu,
- nekonzistentní změny jednotlivých vrstev,
- závislost architektury na osobní paměti autora.

## 4.1 Rozhodnutí jako znalostní aktivum
Každé kvalitně zpracované rozhodnutí představuje zkušenost získanou během skutečného vývoje. Registr AD tak vytváří znalostní základnu, která podporuje budoucí návrh, audit, refaktoring i strategické plánování.

## 4.2 Důvěryhodnost a auditovatelnost
Záznam musí umožnit dohledat:
- kdo nebo co rozhodnutí navrhlo,
- kdo jej schválil,
- z jakých podkladů vycházelo,
- kdy bylo implementováno,
- zda bylo ověřeno v praxi,
- zda je stále platné nebo bylo nahrazeno.

## 4.3 Závěr kapitoly
Evidence rozhodnutí chrání projekt před ztrátou důvodů a opakováním minulých chyb. Další kapitola stanovuje kritéria, podle kterých se určuje, zda má vzniknout samostatný záznam AD.

# 5. Kritéria pro vznik záznamu AD
Samostatný záznam `AD-xxxx` vzniká, pokud rozhodnutí splňuje alespoň jedno z následujících kritérií:
- mění dlouhodobou architekturu platformy nebo některé hlavní Layer,
- mění hranice odpovědností mezi moduly, službami, schématy nebo uzly,
- významně ovlivňuje datový model, canonical mapping nebo datový tok,
- zavádí nový strategický princip, který bude opakovaně používán,
- má vysoké náklady na budoucí změnu nebo návrat,
- ovlivňuje více oblastí projektu,
- zásadně mění kvalitu, bezpečnost, dostupnost, auditovatelnost nebo škálovatelnost,
- řeší opakující se problém, který nelze bezpečně řídit pouze lokální implementační úpravou,
- vybírá jednu z více dlouhodobě relevantních alternativ,
- má významný dopad na produkty, provoz nebo dlouhodobé náklady společnosti.

## 5.1 Rozhodnutí, která zpravidla nevyžadují AD
Samostatný záznam obvykle nevzniká pro:
- opravu chyby bez změny architektury,
- kosmetickou změnu uživatelského rozhraní,
- přejmenování lokální proměnné nebo funkce,
- běžnou optimalizaci dotazu bez dopadu na datový model,
- jednorázový test,
- krátkodobou pracovní pomůcku,
- změnu obsaženou v již schváleném rozhodnutí bez změny jeho principu.

## 5.2 Hraniční případy
Pokud není zřejmé, zda změna vyžaduje AD, posuzuje se:
1. jak dlouho bude mít dopad,
2. kolik oblastí ovlivní,
3. jak obtížné bude rozhodnutí změnit,
4. zda bude budoucí vývojář potřebovat znát důvod volby,
5. zda existovaly reálné alternativy.

Pokud je alespoň několik odpovědí významných, je vhodné vytvořit záznam AD.

## 5.3 Závěr kapitoly
Záznam AD vzniká pouze pro rozhodnutí s dlouhodobým nebo širokým dopadem. Práh významnosti chrání registr před zahlcením běžnými úpravami. Následující kapitola popisuje životní a stavový cyklus rozhodnutí.

# 6. Životní a stavový cyklus rozhodnutí
Architektonické rozhodnutí nevzniká okamžitě. Prochází řízeným procesem od identifikace problému přes schválení a implementaci až po dlouhodobé ověření nebo nahrazení.

## 6.1 Identifikace problému
Rozhodnutí začíná přesnou definicí problému. Musí být popsáno:
- co nefunguje nebo co je potřeba změnit,
- jaké jsou současné limity,
- proč je změna potřebná,
- kterých oblastí se problém týká,
- co se stane, pokud nebude řešen.

Bez jasně definovaného problému se architektonické rozhodnutí nezakládá.

## 6.2 Shromáždění kontextu a omezení
Před návrhem řešení se evidují relevantní podmínky, například:
- současná architektura,
- dostupné technologie,
- datové a provozní požadavky,
- licenční a finanční omezení,
- závislosti na providerech,
- bezpečnostní požadavky,
- zpětná kompatibilita,
- dostupná infrastruktura a kapacita týmu.

## 6.3 Analýza alternativ
Před přijetím rozhodnutí se posuzují reálné možnosti. Každá významná alternativa se hodnotí minimálně z hlediska:
- přínosů,
- rizik,
- složitosti,
- dlouhodobé udržitelnosti,
- rozšiřitelnosti,
- dopadu na stávající systém,
- nákladů a možnosti návratu.

Nejrychlejší řešení nemusí být dlouhodobě nejvhodnější.

## 6.4 Návrh rozhodnutí
Navržené řešení se zapíše jako záznam ve stavu **PROPOSED**. Musí být zřejmé, že ještě nejde o závaznou součást architektury.

## 6.5 Review a přijetí
Rozhodnutí prochází obsahovou a architektonickou kontrolou. Po přijetí získá stav **ACCEPTED**. Součástí schválení je odůvodnění, proč byla zvolena právě daná varianta.

## 6.6 Implementace
Po přijetí následuje realizace. Po dokončení hlavní implementace získá rozhodnutí stav **IMPLEMENTED**. Implementace může probíhat ve více etapách, ale nesmí bez nového posouzení změnit základní princip přijatého rozhodnutí.

## 6.7 Ověření v praxi
Po ověření výsledků v reálném provozu může rozhodnutí získat stav **VALIDATED**. Ověření má uvést, zda se naplnily očekávané přínosy a jaké neočekávané důsledky se objevily.

## 6.8 Nahrazení nebo odmítnutí
Pokud je přijaté rozhodnutí později nahrazeno, původní záznam získá stav **SUPERSEDED** a odkaz na nové rozhodnutí. Pokud návrh nebyl přijat, získá stav **REJECTED**. Historie zůstává zachována.

## 6.9 Doporučené stavy
| Stav | Význam |
|---|---|
| DRAFT | Neúplný pracovní záznam před formálním návrhem. |
| PROPOSED | Formálně navržené rozhodnutí čekající na review. |
| ACCEPTED | Rozhodnutí bylo schváleno, ale nemusí být plně implementováno. |
| IMPLEMENTED | Hlavní technická realizace byla dokončena. |
| VALIDATED | Rozhodnutí bylo ověřeno v praktickém provozu. |
| REJECTED | Návrh nebyl přijat. |
| SUPERSEDED | Rozhodnutí bylo nahrazeno novějším záznamem. |
| DEPRECATED | Rozhodnutí se již nedoporučuje pro nové použití, ale dosud může existovat v části systému. |
| ARCHIVED | Záznam je historický a již není aktivně používán. |

## 6.10 Závěr kapitoly
Životní cyklus zajišťuje, že rozhodnutí není považováno za platné pouze na základě návrhu a že jeho skutečný přínos může být později ověřen. Následující kapitola stanovuje povinnou strukturu jednotlivého záznamu.

# 7. Struktura záznamu AD
Každé rozhodnutí používá jednotnou strukturu. Díky tomu lze záznamy porovnávat, vyhledávat a automaticky zpracovávat.

## 7.1 Identifikátor
Každé rozhodnutí získá jedinečný a neměnný identifikátor ve formátu:
```text
AD-0001
AD-0002
AD-0003
```

Jednou přidělený identifikátor se znovu nepoužívá, ani pokud je návrh odmítnut nebo rozhodnutí později nahrazeno.

## 7.2 Povinná metadata
Každý záznam obsahuje minimálně:
- ID,
- název,
- datum vytvoření,
- datum rozhodnutí,
- stav,
- klasifikaci a oblast,
- autora návrhu,
- schvalující roli nebo osobu,
- související dokumenty,
- vazbu na předchozí nebo nahrazující rozhodnutí.

## 7.3 Povinný obsah
Každý záznam obsahuje minimálně:
1. **Kontext a problém** – co je potřeba vyřešit a proč.
2. **Požadavky a omezení** – podmínky ovlivňující řešení.
3. **Posuzované alternativy** – reálně zvažované možnosti.
4. **Rozhodnutí** – jednoznačně formulované zvolené řešení.
5. **Důvod rozhodnutí** – proč byla vybrána právě tato varianta.
6. **Pozitivní důsledky** – očekávané přínosy.
7. **Negativní důsledky a rizika** – vědomé kompromisy a náklady.
8. **Implementace** – hlavní kroky nebo vazby na technické zdroje.
9. **Ověření** – způsob a výsledek praktického potvrzení.
10. **Vazby** – související dokumenty, změny, commity, milestone a rozhodnutí.

## 7.4 Doporučená šablona
```text
# AD-xxxx – NÁZEV ROZHODNUTÍ

## Metadata
ID:
Stav:
Datum návrhu:
Datum rozhodnutí:
Oblast:
Klasifikace:
Autor návrhu:
Schválil:
Nahrazuje:
Nahrazeno rozhodnutím:

## Kontext a problém

## Požadavky a omezení

## Posuzované alternativy

## Rozhodnutí

## Důvod rozhodnutí

## Pozitivní důsledky

## Negativní důsledky a rizika

## Implementace

## Ověření v praxi

## Související dokumenty a technické zdroje

## Historie stavu
```

## 7.5 Kvalita formulace
Rozhodnutí musí být konkrétní a ověřitelné. Nevhodné je:
> Použijeme lepší architekturu.

Vhodné je:
> Providerová data budou ukládána do sjednocených staging tabulek `stg_*`; nové sport-specific tabulky se nebudou vytvářet bez samostatně schválené výjimky.

## 7.6 Evidence alternativ
Alternativy se neuvádějí pouze formálně. Každá uvedená alternativa musí být skutečně relevantní a její odmítnutí musí být stručně odůvodněno. Pokud reálná alternativa neexistovala, uvede se tato skutečnost.

## 7.7 Závěr kapitoly
Jednotná struktura zajišťuje, že záznam uchová celý rozhodovací kontext a nebude pouze krátkým tvrzením bez důvodů. Následující kapitola definuje klasifikaci rozhodnutí.

# 8. Klasifikace rozhodnutí
Klasifikace umožňuje určit význam, rozsah a primární oblast rozhodnutí. Každý záznam musí mít jednu hlavní klasifikaci a jednu nebo více oblastí dopadu.

## 8.1 Strategická rozhodnutí
Strategická rozhodnutí ovlivňují celou platformu, dlouhodobý směr společnosti nebo základní provozní model. Patří sem například:
- víceproviderová strategie,
- lokální versus cloudová architektura,
- hlavní produktová nebo datová platforma,
- zásadní rozdělení výpočetních uzlů,
- dlouhodobý model správy dat a znalostí.

## 8.2 Architektonická rozhodnutí
Architektonická rozhodnutí mění strukturu nebo odpovědnosti některé hlavní části systému, například:
- databázové vrstvy,
- Layer Architecture,
- harvest pipeline,
- orchestrace,
- canonical entity model,
- OPS a governance mechanismy,
- dokumentační architektura.

## 8.3 Technická rozhodnutí
Technická rozhodnutí se týkají významné implementační volby s dlouhodobým dopadem, například:
- databázová technologie,
- framework nebo komunikační mechanismus,
- způsob logování a observability,
- formát integračního rozhraní,
- významný standard adresářů nebo nasazení.

Běžná lokální implementační volba bez dlouhodobého dopadu se jako samostatný záznam AD neeviduje.

## 8.4 Governance rozhodnutí
Governance rozhodnutí zavádí nebo mění způsob řízení kvality, odpovědností, schvalování, auditů, prevence duplicit nebo správy providerů.

## 8.5 Dokumentační rozhodnutí
Dokumentační rozhodnutí mění architekturu dokumentace, identifikaci dokumentů, správu znalostí, dokumentační databázi nebo automatizaci Documentation Management System.

## 8.6 Oblasti dopadu
Doporučené oblasti zahrnují:
- BUSINESS,
- PLATFORM,
- DATABASE,
- CORE,
- PEOPLE,
- MEDIA,
- ODDS,
- PROVIDERS,
- SOURCE INTELLIGENCE,
- GOVERNANCE,
- OPS,
- RUNTIME,
- INFRASTRUCTURE,
- SECURITY,
- AI,
- WEB,
- MOBILE,
- DOCUMENTATION.

## 8.7 Závažnost
TECH V2 může zavést úrovně závažnosti, například:
- **CRITICAL** – rozhodnutí ovlivňující základní princip celé platformy,
- **HIGH** – rozhodnutí s dopadem na více hlavních oblastí,
- **MEDIUM** – rozhodnutí s dlouhodobým dopadem na jednu významnou oblast,
- **LOW** – lokálnější rozhodnutí, které však stále splňuje kritéria pro AD.

Do schválení finálního modelu není závažnost povinným metadatem.

## 8.8 Závěr kapitoly
Klasifikace a oblasti dopadu umožňují registr filtrovat a vyhodnocovat bez ztráty individuálního kontextu rozhodnutí. Další kapitola stanovuje pravidla schvalování, implementace a ověření.

# 9. Schvalování, implementace a ověření
Architektonické rozhodnutí se nestává platným pouze jeho zapsáním. Musí projít přiměřenou kontrolou odpovídající jeho významu.

## 9.1 Review rozhodnutí
Review ověřuje zejména:
- zda je problém správně definován,
- zda jsou uvedena relevantní omezení,
- zda byly posouzeny reálné alternativy,
- zda rozhodnutí odpovídá MASTER, GOVERNANCE a ARCHITECTURE,
- zda jsou popsána rizika a negativní důsledky,
- zda je řešení dlouhodobě udržitelné,
- zda nevytváří neřízenou duplicitu nebo novou závislost.

## 9.2 Schválení
Schvalující autorita se určuje podle rozsahu rozhodnutí. V současné fázi projektu je finální schválení v odpovědnosti autora a architekta projektu. Budoucí governance může zavést víceúrovňové schvalování podle oblasti a závažnosti.

## 9.3 Implementační vazby
Přijaté rozhodnutí musí podle charakteru odkazovat na relevantní implementační zdroje, například:
- Git commit, branch, tag nebo pull request,
- SQL skripty a migrace,
- Python nebo PowerShell workery,
- databázové objekty,
- OPS pohledy a audity,
- milestone nebo projektovou etapu,
- změny souvisejících dokumentů.

## 9.4 Kontrola souladu implementace
Po implementaci se ověří, zda skutečné řešení odpovídá schválenému rozhodnutí. Pokud implementace významně změnila princip, nesmí se původní záznam tiše přepsat. Musí proběhnout nové review nebo vzniknout navazující rozhodnutí.

## 9.5 Ověření přínosu
Stav VALIDATED se používá pouze tehdy, pokud existují praktické podklady, že rozhodnutí splnilo svůj účel. Ověření může vycházet z:
- auditních výsledků,
- provozních metrik,
- snížení chybovosti,
- zjednodušení architektury,
- zlepšení výkonu,
- úspěšného rozšíření na další sporty nebo providery,
- dlouhodobého používání bez zásadních problémů.

## 9.6 Závěr kapitoly
Schválení potvrzuje vhodnost návrhu, implementace potvrzuje jeho realizaci a validace potvrzuje skutečný přínos. Následující kapitola popisuje vazby registru na ostatní dokumentaci a technické zdroje.

# 10. Vazby na ostatní dokumentaci a technické zdroje
Registr AD není samostatným izolovaným dokumentem. Každé rozhodnutí je součástí širší znalostní a technické sítě MatchMatrix.

## 10.1 MM-DOC-300 – Architecture
ARCHITECTURE popisuje aktuální výslednou podobu systému. ARCHITECTURAL DECISIONS vysvětluje, proč tato podoba vznikla.

ARCHITECTURE odpovídá na otázku:
> **Jak je systém navržen?**

ARCHITECTURAL DECISIONS odpovídá na otázku:
> **Proč je navržen právě takto?**

Pokud přijaté rozhodnutí mění aktuální architekturu, musí být po implementaci promítnuto do MM-DOC-300.

## 10.2 MM-DOC-200 – Governance
Řada rozhodnutí vede ke vzniku nových závazných pravidel. Jakmile je rozhodnutí přijato a ověřeno, musí být podle potřeby promítnuto do GOVERNANCE nebo odpovídajícího standardu.

## 10.3 MM-DOC-902 – Changelog
Přijetí nebo implementace významného architektonického rozhodnutí zpravidla představuje projektový milník. CHANGELOG obsahuje stručnou informaci o změně a odkaz na příslušný záznam AD. Registr AD obsahuje podrobný kontext, alternativy a důsledky.

## 10.4 MM-DOC-900 – Denní zápisy
První analýza problému a průběh diskuse se často objeví v denním zápisu. Po dosažení významné architektonické volby vzniká samostatný záznam AD. Denní zápis zachycuje průběh; AD uchovává řízený výsledek.

## 10.5 MM-DOC-901 – Navázání
Pokud je během pracovní etapy navrženo nebo přijato významné rozhodnutí, musí být uvedeno v NAVÁZÁNÍ včetně stavu a doporučeného dalšího kroku. Nová etapa nesmí nevědomě pokračovat v rozporu s přijatým rozhodnutím.

## 10.6 MM-DOC-100 – Master
Strategické rozhodnutí ovlivňující produkty, obchodní směr nebo dlouhodobou vizi společnosti musí být podle potřeby promítnuto do MASTER.

## 10.7 MM-DOC-800 – Development Handbook
Pokud rozhodnutí mění každodenní vývojový postup, standard skriptů, workflow nebo odpovědnosti nástrojů, musí být aktualizován DEVELOPMENT HANDBOOK.

## 10.8 Git a technické zdroje
Git uchovává detailní změny zdrojových souborů. Záznam AD vysvětluje architektonický důvod. Vazba má umožnit přejít:
- od rozhodnutí k implementaci,
- od implementace k rozhodnutí,
- od historického problému k jeho výslednému řešení.

## 10.9 Milestone a roadmapa
Rozhodnutí může být navázáno na milestone, pokud je jeho implementace součástí konkrétní etapy. Strategický důvod však nesmí být skryt pouze v nástroji pro řízení úkolů; zůstává v registru AD.

## 10.10 Závěr kapitoly
Vazby zajišťují, že rozhodnutí není izolovaným textem, ale dohledatelnou součástí architektury, implementace a historie projektu. Následující kapitola stanovuje pravidla správy registru a jednotlivých záznamů.

# 11. Správa registru AD, verzování a archivace
Je nutné rozlišovat mezi:
1. tímto aktivním řídicím dokumentem **MM-DOC-903**, který definuje pravidla registru,
2. jednotlivými historickými záznamy `AD-xxxx`.

## 11.1 Správa dokumentu MM-DOC-903
MM-DOC-903 je aktivním řízeným dokumentem. Jeho identita je určena Document ID **MM-DOC-903**. Existuje jedna oficiální aktivní verze, která se aktualizuje v souladu s MM-STD-003. Historie změn se vede v tabulce historie verzí.

## 11.2 Správa jednotlivých rozhodnutí
Jednotlivý záznam AD je historickým dokladem rozhodnutí v konkrétním kontextu. Po přijetí se nepřepisuje tak, aby se změnil původní význam, důvody nebo známé důsledky. Nový vývoj se zaznamenává změnou stavu, validační poznámkou nebo novým navazujícím rozhodnutím.

## 11.3 Neměnnost historie
Přijaté rozhodnutí se zpětně nemaže pouze proto, že bylo později nahrazeno. Původní záznam zůstává zachován se stavem SUPERSEDED a s odkazem na nové rozhodnutí. Tím lze sledovat vývoj architektury v čase.

## 11.4 Oprava chyby
Pokud záznam obsahuje faktickou chybu, oprava musí být dohledatelná. Musí uvést:
- co bylo opraveno,
- proč,
- kdy,
- kým,
- zda oprava mění význam rozhodnutí.

Pokud by oprava měnila samotné rozhodnutí, nevytváří se tichá editace, ale nový záznam.

## 11.5 Jedinečnost identifikátoru
Jednou přidělený identifikátor `AD-xxxx` se nikdy nepoužije pro jiné rozhodnutí. Číselná mezera vzniklá odmítnutým nebo zrušeným návrhem se znovu nezaplňuje.

## 11.6 Umístění a index
Finální fyzická struktura registru bude potvrzena v TECH V2 nebo v Documentation Management System. Předpokládá se:
- centrální index rozhodnutí,
- samostatný Markdown soubor pro každý záznam,
- možnost databázové evidence metadat,
- generovaný souhrnný export.

Bez ohledu na fyzickou formu musí být zachována jedinečnost ID, stav, chronologie, vazby a auditní stopa.

## 11.7 Archivace
Záznamy se archivují pouze ve smyslu změny stavu nebo přesunu do řízené historické vrstvy. Archivace nesmí odstranit dostupnost rozhodnutí ani jeho vazby na nástupnické řešení.

## 11.8 Závěr kapitoly
Oddělení aktivního řídicího dokumentu od neměnných historických rozhodnutí zajišťuje soulad s verzováním dokumentace i auditovatelností architektury. Následující kapitola popisuje plánovaný budoucí rozvoj.

# 12. Budoucí rozvoj a TECH V2
Dokončením MM-DOC-903 se uzavírá první REVIEW dokumentační řady MM-DOC-000 až MM-DOC-903. Následující etapa nebude pouze rozšiřovat texty, ale převede jejich pravidla do praktických šablon, registrů, indexů a automatizačních mechanismů.

## 12.1 Katalog prvních rozhodnutí
TECH V2 má připravit katalog prvních architektonických rozhodnutí `AD-0001` až `AD-00xx`. Kandidáty budou zejména již existující a ověřené principy MatchMatrix, například:
- víceproviderová architektura,
- canonical entity model,
- sjednocené staging tabulky `stg_*`,
- vícevrstvá databázová architektura,
- oddělení schémat `staging`, `public`, `ops` a `runtime`,
- Layer Architecture,
- Governance First,
- Automation First,
- Documentation First,
- rozdělení rolí PC1 a PC2,
- Documentation Management System jako budoucí řídicí vrstva znalostí.

Před přidělením oficiálního ID musí být u každého kandidáta dohledán kontext, datum, zdroje a skutečný stav přijetí.

## 12.2 Oficiální šablona
Bude vytvořena oficiální Markdown šablona jednotlivého záznamu AD včetně povinných metadat, stavů, klasifikace, vazeb a historie.

## 12.3 Index rozhodnutí
Centrální index má obsahovat minimálně:
- AD ID,
- název,
- stav,
- datum návrhu a přijetí,
- klasifikaci,
- oblasti dopadu,
- nahrazené a nahrazující rozhodnutí,
- odkazy na dokumentaci a implementaci.

## 12.4 Vazba na Git a milestone
TECH V2 má definovat:
- povinnou formu odkazu na commit, branch, tag nebo pull request,
- vazbu na milestone a pracovní etapu,
- vztah mezi datem rozhodnutí a datem implementace,
- způsob dohledání všech technických artefaktů vytvořených rozhodnutím.

## 12.5 Documentation Management System
Budoucí Documentation Management System bude podporovat:
- přidělování AD ID,
- stavový workflow,
- správu metadat a vazeb,
- kontrolu povinných částí,
- vyhledávání rozhodnutí podle oblasti, stavu a dopadu,
- upozornění na chybějící aktualizace ARCHITECTURE, GOVERNANCE nebo CHANGELOGU,
- generování indexu a exportů,
- detekci rozhodnutí, která byla implementována, ale nebyla formálně zdokumentována.

## 12.6 AI podpora
AI může pomáhat při:
- identifikaci kandidátů na nové rozhodnutí,
- sumarizaci alternativ a důsledků,
- kontrole konzistence s existující architekturou,
- vyhledání souvisejících dokumentů a commitů,
- návrhu aktualizací návazné dokumentace.

AI nesmí samostatně schválit strategické nebo architektonické rozhodnutí bez odpovědné lidské autority.

## 12.7 Závěr kapitoly
TECH V2 převede základní metodiku do praktického a automatizovatelného registru. Hlavním výsledkem bude katalog skutečných rozhodnutí, oficiální šablona a dohledatelné vazby na implementaci.

# 13. Závěr dokumentu
MATCHMATRIX ARCHITECTURAL DECISIONS představuje řídicí rámec centrálního registru významných rozhodnutí projektu. Jeho cílem není pouze evidovat zvolené technologie. Uchovává celý rozhodovací kontext:
- problém,
- omezení,
- alternativy,
- zvolené řešení,
- důvod rozhodnutí,
- očekávané přínosy,
- vědomé kompromisy,
- implementaci,
- praktické ověření,
- následný vývoj a případné nahrazení.

Společně s dokumenty MASTER, GOVERNANCE, ARCHITECTURE, DEVELOPMENT HANDBOOK, DENNÍ ZÁPISY, NAVÁZÁNÍ a CHANGELOG vytváří ucelený systém řízení znalostí MatchMatrix. Díky registru AD lze pochopit nejen současnou podobu platformy, ale také důvody, které k ní vedly, a bezpečně na ně navazovat při dalším rozvoji.

Dokončením REVIEW dokumentu MM-DOC-903 je uzavřena první odborná revize hlavní technické dokumentační řady. Následující etapou je konsolidace a praktické zavedení pravidel prostřednictvím TECH V2.

# 14. AI CONTEXT
## Role dokumentu
MM-DOC-903 definuje pravidla pro evidenci, schvalování, implementaci, ověřování a dlouhodobou správu významných architektonických rozhodnutí MatchMatrix.

## Účel pro AI
AI má tento dokument používat k pochopení:
- kdy má vzniknout samostatný záznam `AD-xxxx`,
- jak odlišit architektonické rozhodnutí od běžné implementační změny,
- jak zaznamenat kontext, alternativy, důvody a důsledky,
- jak pracovat se stavy PROPOSED, ACCEPTED, IMPLEMENTED, VALIDATED a SUPERSEDED,
- jak propojit rozhodnutí s ARCHITECTURE, GOVERNANCE, CHANGELOGEM, Git historií a implementací,
- jak zachovat historickou auditní stopu bez přepisování minulosti.

## Hranice dokumentu
Dokument neobsahuje kompletní aktuální architekturu ani dosud nepřiděluje oficiální AD ID historickým rozhodnutím. Konkrétní stav systému se získává z MM-DOC-300, technických zdrojů a budoucího katalogu AD.

## Klíčové pravidlo
Přijaté architektonické rozhodnutí se zpětně nepřepisuje tak, aby změnilo historický význam. Pokud se architektura změní, vzniká nové rozhodnutí a původní záznam zůstává dohledatelný.

# 15. PROJECT SNAPSHOT
| Oblast | Aktuální stav při REVIEW |
|---|---|
| Documentation Framework | REVIEW |
| Master | REVIEW |
| Governance | REVIEW |
| Architecture | REVIEW |
| Development Handbook | REVIEW |
| Denní zápisy | REVIEW |
| Navázání | REVIEW dokončeno |
| Changelog | REVIEW dokončeno |
| Architectural Decisions | REVIEW – tento dokument |
| Dokumentační řada MM-DOC-000 až MM-DOC-903 | První REVIEW uzavřeno dokončením tohoto dokumentu |
| TECH V2 | NEXT PHASE |
| Documentation Management System | PLANNED |

## Kontext aktuální revize
- Původní dokument byl veden jako **MM-DOC-008**.
- V nové dokumentační řadě je zařazen jako **MM-DOC-903**.
- Odborný obsah původního dokumentu byl zachován a rozšířen o pravidla potřebná pro řízený registr rozhodnutí.
- Struktura byla sjednocena s MM-DOC-000 a MM-STD-001 až MM-STD-009.
- Bylo doplněno oddělení aktivního řídicího dokumentu od jednotlivých historických záznamů `AD-xxxx`.
- Byl sjednocen životní cyklus, stavový model, pravidla neměnnosti, nahrazování a oprav.
- Byly doplněny vazby na MM-DOC-900, MM-DOC-901, MM-DOC-902, Git, milestone a budoucí Documentation Management System.

# 16. DATABASE SNAPSHOT
Tento řídicí dokument neuchovává aktuální provozní počty databáze MatchMatrix. Jednotlivý záznam AD obsahuje DATABASE SNAPSHOT pouze tehdy, pokud je databázový stav součástí kontextu, problému, rozhodnutí nebo ověření jeho dopadu.

Platí následující pravidla:
- hodnoty musí pocházet z ověřeného databázového nebo OPS zdroje,
- musí být uvedeno datum, čas a prostředí,
- musí být zřejmé, zda jde o stav BEFORE, AFTER nebo VALIDATION,
- detailní výstup zůstává v auditu, SQL skriptu nebo technickém reportu,
- AD uvádí pouze údaje potřebné k pochopení rozhodnutí a jeho výsledku.

Doporučený minimální obsah:
| Položka | Požadovaný údaj |
|---|---|
| Databáze / prostředí | Název databáze a uzlu |
| Čas snapshotu | Datum a čas ověření |
| Fáze | BEFORE / AFTER / VALIDATION |
| Relevantní schéma | `staging`, `public`, `ops`, `runtime` nebo jiné |
| Relevantní objekt | Tabulka, pohled, funkce, fronta nebo modul |
| Klíčová hodnota | Počet, stav, výkon, coverage nebo výsledek auditu |
| Zdroj ověření | SQL dotaz, audit, pohled, skript nebo report |

# 17. CURRENT STATUS
| Oblast | Stav | Poznámka |
|---|---|---|
| Document ID | CONFIRMED | MM-DOC-903 |
| Původní označení | HISTORICAL | MM-DOC-008 |
| Edice | TECH | Technická a provozní dokumentace |
| Obsahová revize | COMPLETED | Původní obsah zachován a restrukturalizován |
| Soulad s MM-DOC-000 | REVIEWED | Doplněna standardní struktura, závěry a návaznosti |
| Soulad s MM-STD-009 | REVIEWED | Doplněny povinné kontextové sekce |
| Terminologie | REVIEWED | Definován ADR / záznam AD a sjednoceny vazby |
| Kritéria pro vznik AD | DEFINED | Dlouhodobý dopad, šíře, obtížnost změny a alternativy |
| Životní cyklus | DEFINED | Od problému po validaci nebo nahrazení |
| Stavový model | DEFINED | DRAFT až ARCHIVED |
| Struktura záznamu | DEFINED | Metadata, kontext, alternativy, důsledky a ověření |
| Neměnnost historie | DEFINED | Nahrazené rozhodnutí zůstává dohledatelné |
| Katalog historických AD | PLANNED | Bude vytvořen v TECH V2 |
| Finální stav dokumentu | REVIEW | Čeká na schválení autora projektu |
| TECH V2 | NEXT PHASE | Šablona, index, katalog, Git, milestone a DMS |

# 18. OPEN QUESTIONS
1. Jaký bude finální fyzický formát registru: samostatné Markdown soubory, databázové záznamy, nebo kombinace obou forem?
2. Kdo bude přidělovat nové identifikátory `AD-xxxx` a řídit centrální číselnou řadu?
3. Které role budou schvalovat strategická, architektonická, technická a governance rozhodnutí?
4. Které stavy budou závazné ve finálním workflow Documentation Management System?
5. Jaké úrovně závažnosti budou povinné v TECH V2?
6. Které typy rozhodnutí musí povinně obsahovat Git commit, tag, pull request nebo milestone?
7. Jak bude řešena zpětná dokumentace historických rozhodnutí, u kterých nebyl původní proces formálně zaznamenán?
8. Která historická rozhodnutí získají jako první identifikátory AD-0001 až AD-00xx?
9. Jak se bude automaticky kontrolovat, zda přijaté rozhodnutí bylo promítnuto do ARCHITECTURE, GOVERNANCE, CHANGELOGU a DEVELOPMENT HANDBOOK?
10. Kdy lze rozhodnutí označit jako VALIDATED a jaké důkazy budou pro tento stav minimálně požadovány?
11. Jak bude řešeno rozhodnutí, které bylo implementováno pouze částečně nebo odlišně od schváleného návrhu?
12. Jaká část registru bude interní a která může být později publikována v BOOK nebo GLOBAL edici?

# 19. NEXT STEP
Provést odborné schválení této REVIEW verze dokumentu:
> **MM-DOC-903 – MATCHMATRIX ARCHITECTURAL DECISIONS (TECH)**

Po schválení uzavřít REVIEW dokumentační řady MM-DOC-000 až MM-DOC-903 a zahájit etapu:
> **TECH V2 – Konsolidace a praktické zavedení dokumentačního systému**

Prvním doporučeným krokem TECH V2 je vytvořit:
1. oficiální šablonu jednotlivého záznamu `AD-xxxx`,
2. centrální index architektonických rozhodnutí,
3. návrh katalogu prvních historických rozhodnutí MatchMatrix,
4. pravidla vazeb na Git, milestone, CHANGELOG a ARCHITECTURE,
5. jednotný schvalovací a stavový workflow pro budoucí Documentation Management System.
