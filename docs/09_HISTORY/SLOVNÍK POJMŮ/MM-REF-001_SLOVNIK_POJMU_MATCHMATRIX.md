# MM-REF-001

# SLOVNÍK POJMŮ MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-REF-001 |
| Název | Slovník pojmů MatchMatrix |
| Edice | MM-REF |
| Verze | 1.5 |
| Stav | REVIEW |
| Autor projektu | Petr Kubinák |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Nahrazuje | MM-REF-001 v1.4 po schválení |
| Referenční standardy | MM-STD-006, MM-STD-008 |

---

# 1. Účel

Tento dokument představuje centrální referenční slovník odborných pojmů projektu MatchMatrix.

Verze 1.5:

- slučuje úplný obsah verzí 1.2 a 1.3,
- obnovuje pojmy, které byly ve verzi 1.3 omylem vynechány,
- doplňuje terminologii z posledních standardů a technických dokumentů,
- doplňuje pojmy z dokumentačního workflow A6, A7, A17 až A25,
- doplňuje pojmy z denního zápisu a dokumentu NAVÁZÁNÍ ze dne 2026-07-01,
- doplňuje chybějící technické a cizojazyčné pojmy z Project Snapshotů za březen, duben a květen 2026,
- sjednocuje překlady stavů, ingestní terminologie, providerových pojmů, analytiky, MEDIA vrstvy a Ticket Engine.

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

| Adapter | Adaptér | Komponenta převádějící rozhraní nebo data konkrétního providera do společného interního rozhraní. | Integrace | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Advisory System | Poradní systém | Systém poskytující data, analýzy a doporučení, přičemž konečné rozhodnutí zůstává uživateli. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Analytics Core | Analytické jádro | Vrstva zajišťující ratingy, příznaky, predikce, tabulky a hodnotové analýzy. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Alias | Alternativní název | Řízený alternativní název používaný k rozpoznání stejné entity napříč zdroji. | Data | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Batch Runner | Dávkový spouštěč | Nástroj spouštějící více úloh nebo targetů jako jednu řízenou dávku. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Bookmaker | Sázková kancelář | Subjekt poskytující sázkové kurzy a přijímající sázky. | Kurzy | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Bookmaker Deep Link | Přímý odkaz do sázkové kanceláře | Odkaz otevírající konkrétní událost nebo trh přímo v rozhraní sázkové kanceláře. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Bridge | Převodní můstek | Přechodová komponenta převádějící data ze starší nebo odlišné struktury do cílového modelu. | Integrace | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Canonical Cleanup | Čištění kanonických dat | Řízené odstranění nebo sloučení chybných, duplicitních či nekonzistentních kanonických záznamů. | Governance | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Canonical Identity | Kanonická identita | Jednotná referenční identita reálné entity používaná napříč všemi providery. | Governance | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Canonical Mapping | Kanonické mapování | Přiřazení providerového záznamu ke správné kanonické entitě. | Governance | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Control Panel | Řídicí panel | Operátorské rozhraní pro spouštění, sledování, diagnostiku a nouzové řízení procesů. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Data Core | Datové jádro | Vrstva základních sportovních dat, identit, vazeb a providerových map. | Architektura | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Downstream Refresh | Obnovení navazujících vrstev | Přepočet nebo aktualizace vrstev závislých na nově importovaných datech. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Expected Value (EV) | Očekávaná hodnota | Statistická hodnota vyjadřující očekávaný dlouhodobý přínos rozhodnutí nebo sázky. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Fallback | Záložní postup | Náhradní zdroj nebo postup použitý při nedostupnosti primární cesty. | Architektura | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Feature Dataset | Datová sada příznaků | Sada odvozených vstupních proměnných používaných analytickými nebo predikčními modely. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Fixed Pick | Pevný výběr | Výběr, který zůstává součástí všech generovaných variant tiketu. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Form | Aktuální forma | Souhrn nedávných výsledků týmu nebo hráče za definovaný počet událostí. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Free Plan | Bezplatný tarif | Tarif providera s omezeným rozsahem dat, historií, rychlostí nebo počtem požadavků. | Provideři | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Head-to-Head (H2H) | Vzájemné zápasy | Historie přímých utkání dvou týmů nebo hráčů. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Ingest Cycle | Ingestní cyklus | Řízený běh zahrnující claim úloh, pull, parsing, merge, audit a uvolnění zámku. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Learning Loop | Učící smyčka | Opakovaný proces využívající výsledky minulých rozhodnutí ke zlepšování budoucích doporučení. | AI | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Legacy | Historická nebo přechodová část | Starší komponenta nebo datová cesta zachovaná kvůli kompatibilitě či postupné migraci. | Vývoj | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Market | Sázkový trh | Konkrétní typ sázkové příležitosti nabízený pro sportovní událost. | Kurzy | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Match Rating | Hodnocení zápasu | Analytické hodnocení konkrétního utkání vytvořené z dostupných dat a příznaků. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Multi-provider | Víceproviderový model | Architektura kombinující více datových providerů podle jejich silných stránek a dostupnosti. | Architektura | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Odds | Sázkové kurzy | Číselné vyjádření nabídky sázkové kanceláře pro konkrétní výsledek nebo trh. | Kurzy | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Paid Plan | Placený tarif | Tarif providera poskytující širší data, vyšší limity nebo hlubší historické pokrytí. | Provideři | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Pattern | Vzor | Opakující se struktura, kombinace nebo chování identifikované v datech nebo výsledcích. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Placeholder Team | Dočasný zástupný tým | Dočasný týmový záznam vytvořený při chybějícím kanonickém mapování. | Data | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Planner-driven Ingest | Ingest řízený plánovačem | Ingestní režim, ve kterém konkrétní práci připravuje a řídí planner. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Planner Job | Úloha plánovače | Konkrétní jednotka práce uložená ve frontě ingestního planneru. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Prediction Pipeline | Predikční pipeline | Řetězec kroků od vstupních dat a příznaků po vytvoření predikce. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Product Core | Produktové jádro | Vrstva produktových funkcí, zejména Ticket Engine, historie, settlement a doporučení. | Architektura | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Provider Map | Mapa providera | Vazba mezi kanonickou entitou a jejím identifikátorem u konkrétního providera. | Data | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Provider-normalized Staging | Providerově normalizovaná staging vrstva | Staging data převedená z providerového formátu do jednotné interní struktury. | Architektura | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Queue | Fronta úloh | Seřazený seznam čekajících úloh určených ke zpracování. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| RAW Payload | Surový datový obsah | Nezměněná odpověď providera uložená pro pozdější parsing, audit a opakované zpracování. | Data | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Recommendation Engine | Doporučovací engine | Komponenta vytvářející doporučení na základě dat, pravidel, modelů a historie. | AI | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Request Budget | Rozpočet požadavků | Povolené množství API požadavků pro daný tarif, období nebo harvest plán. | Provideři | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Return on Investment (ROI) | Návratnost investice | Poměr zisku nebo ztráty k vloženým prostředkům. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Risk Score | Skóre rizika | Číselné hodnocení rizikovosti tiketu, varianty nebo rozhodnutí. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Run Group | Skupina běhu | Logické seskupení targetů nebo úloh spouštěných podle společného účelu. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Runner | Spouštěcí komponenta | Program koordinující nebo spouštějící jeden či více workerů. | Vývoj | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Settlement | Vyhodnocení tiketu | Proces určení výsledku tiketu, zisku, ztráty a dalších navazujících metrik. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Stake | Vklad | Částka vložená do tiketu nebo sázkové varianty. | Kurzy | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Standings | Tabulka soutěže | Pořadí účastníků soutěže vypočtené podle pravidel bodování a výsledků. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Team Rating | Hodnocení týmu | Číselné analytické hodnocení výkonnosti nebo síly týmu. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Ticket Block | Blok tiketu | Skupina alternativních výběrů používaná při generování variant tiketu. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Ticket Engine | Engine tvorby tiketů | Komponenta vytvářející, kombinující, hodnotící a ukládající tiketové varianty. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Ticket Studio | Studio pro tvorbu tiketů | Uživatelské rozhraní pro výběr zápasů, tvorbu variant, práci s kurzy a uložení tiketů. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Ticket Variant | Varianta tiketu | Jedna konkrétní kombinace výběrů vzniklá z fixních voleb a bloků. | Produkt | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Total Odd | Celkový kurz | Součin kurzů všech výběrů zahrnutých v tiketu. | Kurzy | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Unified Staging | Jednotná staging vrstva | Společný staging model používaný více sporty a providery místo oddělených sportovních tabulek. | Architektura | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Value Analysis | Hodnotová analýza | Porovnání odhadované pravděpodobnosti s nabízeným kurzem za účelem hledání hodnoty. | Analytika | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Worker Lock | Zámek workeru | Mechanismus zabraňující souběžnému spuštění stejné nebo konfliktní úlohy. | Provoz | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Blocked | Blokováno | Stav, kdy úloha nebo oblast nemůže pokračovat kvůli známé překážce. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Canonical Matching | Kanonické párování | Proces bezpečného přiřazení providerových týmů, zápasů nebo kurzů ke kanonickým entitám. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Clean Rebuild | Čisté znovuvybudování | Opětovné vytvoření datové větve od kontrolovaně vyčištěného výchozího stavu. | Vývoj | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Completion Audit | Audit dokončenosti | Kontrola, zda daný sport, provider nebo entita splňuje definovaná kritéria dokončení. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Competition Risk | Riziko záměny soutěže | Riziko, že událost bude přiřazena ke špatné soutěži nebo turnaji. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Contradicted | Rozporné | Stav, kdy dostupné zdroje uvádějí vzájemně neslučitelné informace. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Controlled Reset | Řízený reset | Auditovaný proces bezpečného vyčištění vymezené datové větve před novým importem. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Coverage | Datové pokrytí | Rozsah, v jakém jsou požadované sporty, entity, sezony nebo události skutečně dostupné. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Coverage Status | Stav datového pokrytí | Klasifikace vyjadřující úplnost a použitelnost dat pro konkrétní kombinaci sportu, providera a entity. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Cross-sport Collision | Kolize mezi sporty | Chybné spojení nebo shoda identit patřících různým sportům. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Data Contract | Datový kontrakt | Přesně definovaná struktura, typy a význam dat očekávaných mezi komponentami. | Architektura | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Discovery-based Scope | Rozsah řízený objevováním zdrojů | Rozsah harvestu odvozený z aktuálně objevených soutěží a dostupnosti providera. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| End-to-End Confirmed | Potvrzeno od začátku do konce | Stav potvrzující, že celý vymezený tok prošel všemi požadovanými kroky. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Endpoint | Koncový bod API | Konkrétní adresa nebo operace rozhraní API poskytující určitý typ dat. | Integrace | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Entity Plan | Plán entit | Konfigurace určující, které entity, workery, priority a scope se mají zpracovávat. | Provoz | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| False Positive | Falešně kladný výsledek | Chybné označení nesprávné shody nebo nálezu jako správného. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| False Positive Risk | Riziko falešné shody | Riziko, že systém nesprávně označí dvě různé entity nebo události za shodné. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Fuzzy Matching | Přibližné párování | Párování podle podobnosti textu nebo dalších znaků bez přesné shody. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Healthcheck | Kontrola provozního zdraví | Rychlá kontrola dostupnosti a základní funkčnosti komponenty nebo providera. | Provoz | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| League Discovery | Objevování soutěží | Proces zjišťování soutěží dostupných u providera pro danou sezonu nebo sport. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Mapping Edge | Hraniční případ mapování | Neobvyklý případ vyžadující zvláštní pravidlo nebo ruční posouzení mapování. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Mapping Gap | Mezera v mapování | Chybějící vazba mezi providerovým záznamem a kanonickou entitou. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Match Linking | Napojení zápasu | Přiřazení externí události, kurzu nebo obsahu ke konkrétnímu kanonickému zápasu. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Nearest Match | Nejbližší odpovídající zápas | Kandidát vybraný podle nejmenší časové, názvové nebo kontextové odchylky. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| NO_MATCH_ID | Chybějící identifikátor zápasu | Stav označující, že externí záznam nebyl bezpečně napojen na kanonický zápas. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Orchestration Confirmed | Orchestrace potvrzena | Stav potvrzující, že planner, ingest, parser a merge proběhly v určeném rozsahu. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Parser Binding | Vazba parseru | Konfigurace nebo volání zajišťující, že po stažení dat bude spuštěn správný parser. | Integrace | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Partial | Částečné | Stav, kdy funguje pouze omezená část požadovaného rozsahu. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Participant Identity | Identita účastníka | Kanonická identita týmu, hráče, dvojice nebo jiného účastníka sportovní události. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Provider-by-Entity | Provider podle entity | Strategie volby providera samostatně pro každý sport a typ entity. | Architektura | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Provider Coverage | Pokrytí providera | Rozsah sportů, soutěží, sezon a entit dostupných u konkrétního providera. | Provideři | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Reason Code | Kód důvodu | Standardizovaný kód popisující skutečnou příčinu chyby, blokace nebo nespárovaného záznamu. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Runtime Audit | Běhový audit | Kontrola skutečného provedení a výsledků komponenty nebo datového toku. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Runtime Readiness | Běhová připravenost | Míra, v jaké je kombinace sportu, providera a entity schopna skutečného provozního běhu. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Runtime Tested | Běhově otestováno | Stav potvrzující, že komponenta nebo tok byl skutečně spuštěn a měl doložený výsledek. | Stav | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Safe Linker | Bezpečný propojovací nástroj | Komponenta napojující záznamy pouze při splnění přísných podmínek shody. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Same-sport Duplicate | Duplicita v rámci sportu | Více kanonických záznamů představujících stejnou reálnou entitu v jednom sportu. | Governance | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Smoke Test | Rychlý ověřovací test | Krátký test potvrzující základní průchod a funkčnost komponenty v omezeném rozsahu. | Testování | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Source Gap | Mezera ve zdrojových datech | Chybějící událost nebo entita způsobená nedostatečným pokrytím zdrojového providera. | Data | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Staging Confirmed | Staging potvrzen | Stav potvrzující data ve staging vrstvě bez potvrzeného merge do public vrstvy. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Strategic Design | Strategický návrh | Cílový model nebo architektonické rozhodnutí, které ještě nemusí být plně implementováno. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Superseded | Nahrazeno novější verzí | Stav, kdy novější dokument, výsledek nebo implementace nahrazuje starší variantu. | Stav | MM-PS-20260430 | MM-PS-20260430 | ACTIVE |
| Tech Ready | Technicky připraveno | Stav, kdy existuje potřebná architektura nebo konfigurace, ale plný runtime není potvrzen. | Stav | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| AI-ready | Připraveno jako základ pro AI | Označení datové nebo analytické připravenosti pro budoucí AI funkce, nikoli důkaz hotového AI produktu. | Stav | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Alias-first Matching | Párování nejprve podle aliasů | Metoda, která před dalšími pravidly hledá shodu pomocí řízených alternativních názvů. | Data | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Approval Workflow | Schvalovací pracovní tok | Řízený proces kontroly a schválení kandidátního zdroje, obsahu nebo změny. | Governance | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Backfill | Zpětné doplnění dat | Dodatečné doplnění chybějících historických nebo dříve nezpracovaných dat. | Data | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Backoff | Postupné prodlužování čekání | Strategie zvětšující prodlevu mezi opakovanými pokusy po chybě nebo omezení API. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| CDN-ready | Připraveno pro distribuční síť obsahu | Technická připravenost dat nebo adres pro budoucí použití přes CDN, nikoli potvrzený CDN provoz. | Stav | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Data Gap | Datová mezera | Chybějící požadovaná data nebo nedostatečné pokrytí pro další zpracování. | Stav | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Date Conflict | Rozpor v datu | Stav, kdy metadata a obsah dokumentu uvádějí rozdílné datum. | Stav | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Decay | Časový útlum | Postupné snižování váhy staršího obsahu nebo signálu v čase. | Analytika | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Dependency Graph | Graf závislostí | Model určující, které úlohy nebo komponenty musí být dokončeny před jinými. | Architektura | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Dependency-aware Execution | Spouštění se znalostí závislostí | Provádění úloh v pořadí respektujícím jejich vzájemné závislosti. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Discovery Candidate | Kandidát objeveného zdroje | Nově nalezený zdroj čekající na kontrolu, schválení a případné zapojení. | Data | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Entity Matching | Párování entit | Proces napojení článku, kurzu nebo providerového záznamu na kanonickou entitu. | Data | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Expanded Variant | Rozšířená varianta | Pozdější nebo širší verze dokumentu či řešení obsahující i část předchozího obsahu. | Dokumentace | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Feed | Datový nebo obsahový kanál | Průběžně aktualizovaný výstup seřazených dat nebo obsahu pro další použití. | Média | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Frontend-ready | Připraveno pro frontend | Stav datového nebo aplikačního rozhraní vhodného k napojení frontendu, nikoli důkaz hotového UI. | Stav | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Live Feed | Živý datový kanál | Průběžně aktualizovaný výstup aktuálně probíhajících událostí a jejich stavu. | Média | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Operations Center | Provozní řídicí centrum | Souhrnná provozní vrstva pro běhy, fronty, selhání, alerty a doporučené zásahy. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Pending Guard | Ochrana čekající fronty | Pravidlo nebo pohled bránící nesprávnému opakování či zablokování pending úloh. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Player Match Statistics | Statistiky hráče v zápase | Statistiky konkrétního hráče vztahující se k jednomu zápasu. | People | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Player Season Statistics | Sezonní statistiky hráče | Agregované statistiky hráče za konkrétní sezonu, tým a soutěž. | People | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Priority Queue | Prioritní fronta | Fronta úloh řazená podle důležitosti, připravenosti nebo naléhavosti. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Production-ready | Připraveno pro produkční provoz | Označení vyžadující potvrzenou stabilitu, opakovatelnost, monitoring a podporovaný rozsah. | Stav | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Provider Routing | Směrování providerů | Logika vybírající vhodného providera pro konkrétní sport, entitu a provozní situaci. | Architektura | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Quality Audit | Audit kvality | Systematická kontrola úplnosti, mapování a použitelnosti dat. | Governance | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Rate Limiting | Omezování frekvence požadavků | Omezení počtu požadavků, které lze odeslat providerovi v určitém čase. | Integrace | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Readiness | Připravenost | Vyhodnocení, zda komponenta nebo tok splňuje podmínky pro další fázi či provoz. | Stav | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Readiness Scoring | Skórování připravenosti | Výpočet číselného nebo stavového hodnocení připravenosti podle definovaných pravidel. | Governance | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Retry | Opakovaný pokus | Nové spuštění dříve neúspěšné operace podle řízených pravidel. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Runtime Alert | Běhové upozornění | Upozornění na chybu, varování nebo neobvyklý stav během provozu. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Safe Autonomous | Bezpečný autonomní režim | Režim, ve kterém automat běží samostatně pouze v ověřeném a kontrolovaném rozsahu. | Stav | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Scheduler | Plánovač spuštění | Komponenta spouštějící úlohy podle času, priority, připravenosti nebo pravidel. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Scheduler Candidate | Kandidát plánovače | Úloha splňující podmínky pro zařazení do plánovaného spuštění. | Provoz | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Source Discovery | Objevování zdrojů | Proces vyhledávání nových datových nebo obsahových zdrojů pro MatchMatrix. | Data | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Source of Truth | Zdroj pravdy | Autoritativní místo, jehož stav má přednost před odvozenými souhrny. | Governance | MM-PS-20260331 | MM-PS-20260331 | ACTIVE |
| Team Power | Síla týmu | Analytické hodnocení týmu založené na výsledcích, formě, hráčích a dalších příznacích. | Analytika | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |
| Trending | Trendovost | Míra aktuálního zájmu nebo významu entity odvozená z čerstvého obsahu a signálů. | Analytika | MM-PS-20260531 | MM-PS-20260531 | ACTIVE |

---

# 4. Souhrn změn verze 1.5

| Oblast | Výsledek |
|---|---|
| Pojmy převzaté z verze 1.4 | 100 |
| Nové pojmy z březnového Project Snapshotu | ano |
| Nové pojmy z dubnového Project Snapshotu | ano |
| Nové pojmy z květnového Project Snapshotu | ano |
| Duplicitní pojmy | nevkládány |
| Technické identifikátory a názvy skriptů | nevkládány jako samostatná slovníková hesla |
| Rozsah doplnění | architektura, ingest, provider mapping, runtime stavy, analytika, MEDIA, Ticket Engine a provoz |
| Nově doplněných pojmů | 137 |
| Celkový počet pojmů | 237 |

---

# 5. Historie verzí

| Verze | Datum | Popis |
|---|---|---|
| 1.0 | 2026 | První vydání slovníku. |
| 1.1 | 2026 | Doplněny pojmy z dokumentačního ekosystému a znalostní báze. |
| 1.2 | 2026 | Doplněny pojmy z governance, revizí a dokumentační databáze. |
| 1.3 | 2026 | Doplněny pojmy z MM-STD-007; verze však neobsahovala úplný obsah v1.2. |
| 1.4 | 2026-07-02 | Sloučeny verze 1.2 a 1.3 a doplněny pojmy z posledních standardů, technických review, denního zápisu a NAVÁZÁNÍ. |
| 1.5 | 2026-07-08 | Doplněno 137 chybějících technických a cizojazyčných pojmů z Project Snapshotů za březen, duben a květen 2026. |

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

MM-REF-001 v1.5 vytváří sjednocený základ terminologie MatchMatrix pro dokumentaci, governance, architekturu, ingest, providery, analytiku, MEDIA, Ticket Engine, databázový import, denní zápisy a předávání kontextu mezi pracovními relacemi a systémy AI.
