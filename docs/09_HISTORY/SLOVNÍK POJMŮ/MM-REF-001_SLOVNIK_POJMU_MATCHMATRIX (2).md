# MM-REF-001

# SLOVNÍK POJMŮ MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-REF-001 |
| Název | Slovník pojmů MatchMatrix |
| Edice | MM-REF |
| Verze | 1.4 |
| Stav | REVIEW |
| Autor projektu | Petr Kubinák |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Nahrazuje | MM-REF-001 v1.3 po schválení |
| Referenční standardy | MM-STD-006, MM-STD-008 |

---

# 1. Účel

Tento dokument představuje centrální referenční slovník odborných pojmů projektu MatchMatrix.

Verze 1.4:

- slučuje úplný obsah verzí 1.2 a 1.3,
- obnovuje pojmy, které byly ve verzi 1.3 omylem vynechány,
- doplňuje terminologii z posledních standardů a technických dokumentů,
- doplňuje pojmy z dokumentačního workflow A6, A7, A17 až A25,
- doplňuje pojmy z denního zápisu a dokumentu NAVÁZÁNÍ ze dne 2026-07-01.

---

# 2. Pravidla používání slovníku

- Jeden pojem má jednu referenční definici.
- Český význam se používá jako základní vysvětlení cizojazyčného nebo technického pojmu.
- Technické identifikátory, názvy stavů, databázových vrstev a skriptů se nepřekládají uvnitř kódu.
- Nový odborný pojem se při prvním použití vysvětlí a následně doplní do MM-REF-001.
- Zastaralé pojmy se označují stavem `DEPRECATED`.
- Po schválení této verze se soubor stane jedinou aktivní verzí MM-REF-001.

---

# 3. Slovník pojmů

| Pojem | Český význam | Definice | Kategorie | První použití | Zdroj | Stav |
|---|---|---|---|---|---|---|
| Documentation Framework | Rámec dokumentace | Kořenová architektura dokumentačního systému MatchMatrix. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Knowledge Base | Znalostní báze | Centrální systém uchovávání, propojování a správy znalostí projektu. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Governance | Řízení systému | Soubor pravidel, odpovědností, kontrol a rozhodovacích mechanismů pro dlouhodobou správu systému. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Provider | Poskytovatel dat | Externí nebo interní zdroj, ze kterého MatchMatrix získává data. | Data | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Harvest | Sběr dat | Řízený proces získávání dat z jednoho nebo více providerů. | Data | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Worker | Pracovní proces | Samostatný programový proces vykonávající konkrétní úlohu v pipeline. | Technologie | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| TECH | Technická edice | Edice dokumentace popisující aktuální technický a provozní stav systému. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| BOOK | Znalostní edice | Edice dokumentace vysvětlující důvody rozhodnutí, historii, souvislosti a zkušenosti. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| GLOBAL | Mezinárodní edice | Oficiální anglická edice vybraných dokumentů určená pro mezinárodní spolupráci. | Dokumentace | MM-STD-006 | MM-STD-006 | ACTIVE |
| Document ID | Jedinečný identifikátor dokumentu | Neměnný identifikátor určující identitu dokumentu nezávisle na názvu a fyzickém umístění. | Dokumentace | MM-STD-007 | MM-STD-007 | ACTIVE |
| Prefix dokumentu | Označení typu dokumentu | Část Document ID, která určuje typ nebo dokumentační oblast dokumentu. | Dokumentace | MM-STD-007 | MM-STD-007 | ACTIVE |
| Typ dokumentu | Kategorie dokumentu | Klasifikace dokumentu podle jeho účelu, například STANDARD, DAILY_LOG nebo CHAT_CONTINUATION. | Dokumentace | MM-STD-007 | MM-STD-007 | ACTIVE |
| Dokumentační oblast | Tematická oblast dokumentace | Logická část dokumentačního systému, která sdružuje dokumenty podobného účelu. | Dokumentace | MM-STD-007 | MM-STD-007 | ACTIVE |
| Identita dokumentu | Identita dokumentu | Soubor vlastností tvořený zejména Document ID, metadaty, obsahem a řízenou správou dokumentu. | Dokumentace | MM-STD-007 | MM-DOC-000 | ACTIVE |
| Documentation Platform | Dokumentační platforma | Celý technický a procesní systém pro tvorbu, správu, kontrolu, ukládání a publikaci dokumentace. | Dokumentace | MM-STD-007 | MM-STD-007 | ACTIVE |
| Dokumentační index | Centrální evidence dokumentů | Řízený seznam dokumentů, jejich identifikátorů, verzí, stavů a umístění. | Dokumentace | MM-STD-007 | MM-STD-1000 | ACTIVE |
| Lokální číselná řada | Samostatné číslování oblasti | Nezávislá posloupnost čísel používaná v konkrétní dokumentační oblasti. | Dokumentace | MM-STD-007 | MM-STD-007 | ACTIVE |
| Dokumentační ekosystém | Ekosystém dokumentace | Soubor všech dokumentačních edic, standardů, referencí, procesů, nástrojů a vzájemných vazeb. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Documentation Management System (DMS) | Systém správy dokumentace | Budoucí modul MatchMatrix pro řízenou správu dokumentů, znalostí, verzí, vazeb a publikace. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Metadata dokumentu | Strukturované informace o dokumentu | Údaje popisující identitu, verzi, stav, autora, vztahy, umístění a další vlastnosti dokumentu. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Referenční informace | Sdílená referenční informace | Informace, která má jedno určené referenční místo a používá se napříč dokumentací. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Dokumentační governance | Řízení dokumentace | Soubor pravidel a kontrol pro správu dokumentačního systému. | Governance | MM-DOC-000 | MM-DOC-200 | ACTIVE |
| Audit dokumentace | Kontrola dokumentace | Systematická kontrola úplnosti, kvality, konzistence a souladu dokumentu se standardy. | Governance | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Vlastník dokumentu | Odpovědná osoba za dokument | Osoba nebo role odpovědná za správnost, aktualizaci a životní cyklus dokumentu. | Governance | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Revize dokumentu | Odborná kontrola dokumentu | Proces posouzení obsahu, struktury, terminologie a souladu dokumentu před schválením. | Governance | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Kontrola kvality dokumentace | Kontrola kvality dokumentu | Soubor automatických a manuálních kontrol prováděných před schválením nebo publikací. | Governance | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Dokumentační databáze | Databázová vrstva dokumentace | Databáze uchovávající dokumenty, verze, sekce, vztahy, stavy a auditní údaje. | Dokumentace | MM-DOC-000 | MM-DL-20260701 | ACTIVE |
| Webový dokumentační portál | Webové rozhraní dokumentace | Uživatelské rozhraní pro vyhledávání, čtení, správu a publikování dokumentace. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| AI kontrola dokumentace | Automatická kontrola pomocí AI | Kontrola struktury, kvality, konzistence a terminologie dokumentace pomocí umělé inteligence. | AI | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Dokument jako řízený objekt | Řízený dokument | Dokument s vlastní identitou, verzí, stavem, vlastníkem, historií a vazbami. | Dokumentace | MM-DOC-000 | MM-DOC-000 | ACTIVE |
| Dokumentační edice | Edice dokumentace | Řízená skupina dokumentů se společným účelem, například MM-STD, MM-DOC, MM-BOOK nebo MM-REF. | Dokumentace | MM-STD-004 | MM-STD-004 | ACTIVE |
| Životní cyklus dokumentu | Životní cyklus dokumentace | Řízený postup od návrhu přes review, schválení, aktivní používání až po archivaci. | Dokumentace | MM-STD-003 | MM-STD-003 | ACTIVE |
| Aktivní dokument | Oficiálně používaný dokument | Jediná oficiální průběžně aktualizovaná verze konkrétního dokumentu. | Dokumentace | MM-STD-003 | MM-STD-003 | ACTIVE |
| Referenční dokument | Autoritativní dokument | Dokument určený jako jediný závazný zdroj určité informace nebo pravidla. | Dokumentace | MM-STD-008 | MM-STD-008 | ACTIVE |
| Master dokument | Sloučený hlavní dokument | Kompletní dokument vzniklý spojením schválených částí nebo kapitol. | Dokumentace | MM-STD-002 | MM-STD-002 | ACTIVE |
| Zdrojový soubor | Samostatný zdroj dokumentu | Soubor používaný jako zdroj pro sestavení rozsáhlého nebo master dokumentu. | Dokumentace | MM-STD-002 | MM-STD-002 | ACTIVE |
| Kanonický dokument | Referenční kanonická podoba | Dokument považovaný za správnou a řízenou referenční podobu pro další zpracování. | Dokumentace | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Kanonický kandidát | Kandidát na kanonický dokument | Dokument připravený ke kontrole a případnému schválení jako kanonická verze. | Dokumentace | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Denní zápis | Pracovní denní záznam | Historický dokument zachycující výchozí stav, provedené práce, rozhodnutí, výsledky a další krok konkrétního dne. | Historie | MM-DOC-900 | MM-DOC-900 | ACTIVE |
| NAVÁZÁNÍ | Dokument pro pokračování práce | Krátký kontextový dokument umožňující bezpečně pokračovat v novém chatu nebo pracovní relaci. | Historie | MM-DOC-900 | MM-NAV-20260701-02 | ACTIVE |
| Chat Continuation | Navázání do nového chatu | Typ dokumentu určený pro předání aktuálního stavu, omezení a dalšího kroku do nové konverzace. | Historie | MM-NAV-20260701-02 | MM-NAV-20260701-02 | ACTIVE |
| Přijaté rozhodnutí | Schválené projektové rozhodnutí | Rozhodnutí přijaté během práce, které má být zachováno jako závazný kontext pro další postup. | Governance | MM-DOC-900 | MM-DL-20260701 | ACTIVE |
| AI CONTEXT | Kontext pro umělou inteligenci | Povinná sekce shrnující informace nutné pro správné navázání práce systémem AI. | AI | MM-STD-009 | MM-STD-009 | ACTIVE |
| PROJECT SNAPSHOT | Snímek projektu | Stručný souhrn aktuálního projektového stavu, prostředí, hlavních komponent a návazností. | Řízení projektu | MM-STD-009 | MM-STD-009 | ACTIVE |
| DATABASE SNAPSHOT | Snímek databáze | Stručný přehled relevantního stavu databáze a klíčových počtů v daném okamžiku. | Databáze | MM-STD-009 | MM-STD-009 | ACTIVE |
| CURRENT STATUS | Aktuální stav | Povinná sekce shrnující stav hlavních oblastí, úkolů nebo komponent. | Řízení projektu | MM-STD-009 | MM-STD-009 | ACTIVE |
| OPEN QUESTIONS | Otevřené otázky | Povinná sekce evidující nerozhodnuté otázky, rizika nebo témata vyžadující další rozhodnutí. | Řízení projektu | MM-STD-009 | MM-STD-009 | ACTIVE |
| NEXT STEP | Další krok | Povinná sekce určující jediný bezprostředně následující úkon. | Řízení projektu | MM-STD-009 | MM-STD-009 | ACTIVE |
| Pravidlo jednoho dalšího kroku | Postup po jednom kroku | Pravidlo, podle kterého se technická práce řídí vždy jedním příkazem nebo jedním jasným úkonem. | Proces | MM-DOC-900 | MM-DOC-900 | ACTIVE |
| Dokumentační workflow | Pracovní tok dokumentace | Řízená posloupnost kroků od vytvoření dokumentu přes kontrolu a schválení až po import a ověření. | Dokumentace | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Terminologická revize | Kontrola terminologie | Kontrola odborných pojmů proti MM-REF-001 včetně návrhu nových nebo nejednotných termínů. | Dokumentace | MM-STD-006 | MM-DL-20260701 | ACTIVE |
| Přírůstkový import | Incremental import | Import pouze nových nebo změněných dokumentů do již existující dokumentační databáze. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Úplný snapshot | Full snapshot | Kompletní obraz celé sledované množiny dokumentů používaný pro globální porovnání. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Importní manifest | Manifest importu | Strukturovaný seznam dokumentů, verzí, sekcí a vazeb určených pro konkrétní import. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Přírůstkový manifest | Incremental manifest | Importní manifest obsahující pouze dokumenty zahrnuté do aktuálního přírůstkového běhu. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Dry run | Zkušební běh bez zápisu | Režim, který ověří připravovanou operaci bez trvalé změny databáze nebo produkčních dat. | Proces | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| APPLY režim | Režim provedení změny | Režim, ve kterém se připravený import nebo změna skutečně zapíše a potvrdí. | Proces | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Databázový importer | Importní nástroj databáze | Skript nebo modul, který zapisuje dokumenty a jejich související objekty do databáze. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Ověření importu | Post-import verification | Následná kontrola, že importované dokumenty, verze, sekce a vazby odpovídají očekávanému stavu. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Importní běh | Import run | Jedno konkrétní spuštění importního procesu evidované jako samostatná auditní událost. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Sekce dokumentu | Document section | Samostatně evidovaná část dokumentu uložená v dokumentační databázi. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Vazba dokumentů | Document relation | Řízený vztah mezi dvěma dokumenty, například návaznost, reference nebo související dokument. | Dokumentace | MM-STD-004 | MM-DL-20260701 | ACTIVE |
| Cílový Document ID | Identifikátor cíle vazby | Document ID dokumentu, na který směřuje vazba z jiného dokumentu. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Aktuální verze dokumentu | Current document version | Verze dokumentu označená jako právě platná a používaná v systému. | Dokumentace | MM-STD-003 | MM-DL-20260701 | ACTIVE |
| Historie stavů dokumentu | Document status history | Chronologická evidence změn stavů dokumentu v dokumentační databázi. | Databáze | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Auditní stopa | Audit trail | Dohledatelný záznam změn, běhů, rozhodnutí a výsledků umožňující zpětnou kontrolu. | Governance | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Historie skriptů | Historické verze skriptů | Řízené uchovávání předchozích implementací skriptů pro audit a možnost zpětného dohledání. | Vývoj | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Aktivní skript | Produkčně používaný skript | Aktuální verze skriptu ponechaná v jeho produkční složce a používaná ostatními částmi systému. | Vývoj | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Historická verze skriptu | Archivovaná verze skriptu | Předchozí implementace skriptu uložená mimo aktivní produkční umístění. | Vývoj | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| DOCUMENT_IMPORT_APPLIED | Import dokumentu proveden | Stav potvrzující úspěšné provedení a commit databázového importu dokumentu. | Stav workflow | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| DOCUMENTATION_IMPORT_VERIFIED | Import dokumentace ověřen | Stav potvrzující, že importovaný rozsah prošel všemi požadovanými kontrolami. | Stav workflow | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| HISTORY_DOCUMENT_IMPORT_BLOCKED | Import historického dokumentu blokován | Stav použitý tehdy, když import nebyl bezpečně proveden nebo nemohl pokračovat. | Stav workflow | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| HISTORY_DOCUMENT_IMPORT_APPLIED_VERIFICATION_FAILED | Import proveden, ověření selhalo | Stav potvrzující, že databázový import byl commitnut, ale následné ověření nebylo úspěšné. | Stav workflow | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| HISTORY_DOCUMENT_IMPORT_APPLIED_AND_VERIFIED | Import proveden a ověřen | Finální stav potvrzující úspěšný import historického dokumentu i následné ověření. | Stav workflow | MM-DL-20260701 | MM-DL-20260701 | ACTIVE |
| Database Governance | Řízení databáze | Pravidla pro strukturu, kvalitu, změny, integritu a bezpečnost databáze. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Provider Governance | Řízení providerů | Pravidla pro výběr, evidenci, hodnocení a provoz poskytovatelů dat. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Entity Governance | Řízení entit | Pravidla pro identitu, mapování, slučování a správu doménových entit. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Duplicate Prevention Governance | Řízení prevence duplicit | Pravidla a kontroly zabraňující vzniku nebo nekontrolovanému slučování duplicitních entit. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Source Governance | Řízení zdrojů | Pravidla pro důvěryhodnost, právní stav, původ a použití datových zdrojů. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Script Governance | Řízení skriptů | Pravidla pro identitu, verzování, umístění, odpovědnost a audit skriptů. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Canonical Entity | Kanonická entita | Referenční entita, ke které jsou mapovány záznamy pocházející z různých providerů. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Duplicate Prevention | Prevence duplicit | Soubor kontrol a procesů zabraňujících vzniku více záznamů pro tutéž reálnou entitu. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Provider Health Monitoring | Monitoring zdraví providerů | Průběžné sledování dostupnosti, úspěšnosti, chybovosti a použitelnosti providerů. | Provoz | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| Harvest Governance | Řízení sběru dat | Pravidla pro plánování, spouštění, kontrolu a audit procesů harvestu. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| OPS Governance | Provozní governance | Pravidla pro provozní řízení, dohled, rozhodování a řešení chyb v OPS vrstvě. | Governance | MM-DOC-200 | MM-DOC-200 | ACTIVE |
| STAGING | Vstupní databázová vrstva | Vrstva pro dočasné uložení, normalizaci a přípravu dat před sloučením do veřejné vrstvy. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| PUBLIC | Veřejná databázová vrstva | Vrstva obsahující vyčištěná a sjednocená data určená pro další používání platformou. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| OPS | Provozní vrstva | Vrstva obsahující provozní pohledy, fronty, audity, dashboardy a řídicí objekty. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| RUNTIME | Běhová vrstva | Vrstva obsahující data a struktury potřebné pro aktuální běh aplikací a procesů. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Layer Architecture | Vrstevná architektura | Architektonický model rozdělující systém do jasně vymezených funkčních vrstev. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Core Layer | Základní datová vrstva | Vrstva spravující základní sportovní entity, soutěže, týmy a zápasy. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| People Layer | Vrstva osob | Vrstva spravující hráče, trenéry a další osoby včetně jejich profilů a vazeb. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Media Layer | Mediální vrstva | Vrstva spravující články, fotografie, videa a jejich vazby na entity. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Odds Layer | Vrstva kurzů | Vrstva spravující sázkové kurzy, trhy a jejich vazby na sportovní události. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Source Intelligence Layer | Vrstva inteligence zdrojů | Vrstva pro objevování, hodnocení, právní kontrolu a řízení datových zdrojů. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| AI Layer | Vrstva umělé inteligence | Vrstva využívající data a znalosti MatchMatrix pro automatizaci, doporučení a analytiku. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Provider Architecture | Architektura providerů | Model určující role, životní cyklus a zapojení jednotlivých poskytovatelů dat. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Harvest Planner | Plánovač sběru dat | Komponenta připravující a prioritizující úlohy pro získávání dat. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Parser Pipeline | Pipeline parserů | Řetězec procesů převádějících surová data providerů do jednotné interní struktury. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |
| Merge Engine | Slučovací engine | Komponenta slučující připravená providerová data do kanonických veřejných entit. | Architektura | MM-DOC-300 | MM-DOC-300 | ACTIVE |

---

# 4. Souhrn změn verze 1.4

| Oblast | Výsledek |
|---|---|
| Pojmy převzaté ze starších verzí | zachovány a sjednoceny |
| Obnovené pojmy z v1.2 | ano |
| Pojmy z MM-STD-007 | zachovány |
| Pojmy z MM-STD-009 | doplněny |
| Pojmy z MM-DOC-000 | doplněny a sjednoceny |
| Pojmy z MM-DOC-200 | doplněny |
| Pojmy z MM-DOC-300 | doplněny |
| Pojmy z MM-DOC-900 | doplněny |
| Pojmy z MM-DL-20260701 | doplněny |
| Pojmy z MM-NAV-20260701-02 | doplněny |
| Celkový počet pojmů | 100 |

---

# 5. Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 1.0 | 2026 | První vydání slovníku. |
| 1.1 | 2026 | Doplněny pojmy z dokumentačního ekosystému a znalostní báze. |
| 1.2 | 2026 | Doplněny pojmy z governance, revizí a dokumentační databáze. |
| 1.3 | 2026 | Doplněny pojmy z MM-STD-007; verze však neobsahovala úplný obsah v1.2. |
| 1.4 | 2026-07-02 | Sloučeny verze 1.2 a 1.3 a doplněny pojmy z posledních standardů, technických review, denního zápisu a NAVÁZÁNÍ. |

---

# 6. Schvalovací poznámka

Dokument je připraven ve stavu `REVIEW`.

Po schválení:

1. nahradí aktuální aktivní obsah MM-REF-001,
2. bude uložen pod stabilním produkčním názvem,
3. bude commitnut do GitHubu,
4. bude importován a ověřen v dokumentační databázi,
5. stane se referenčním zdrojem pro automatickou terminologickou kontrolu A23.

---

# Závěr

MM-REF-001 v1.4 vytváří sjednocený základ terminologie MatchMatrix pro dokumentaci, governance, architekturu, databázový import, denní zápisy a předávání kontextu mezi pracovními relacemi a systémy AI.
