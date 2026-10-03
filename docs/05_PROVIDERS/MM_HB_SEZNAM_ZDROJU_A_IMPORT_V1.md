# MatchMatrix – HB kandidáti zdrojů a příprava importu

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Pracovní identifikátor | HB-CANDIDATES-20260928 |
| Edice / typ | TECH – pracovní návrh mimo centrální číselnou řadu |
| Verze / stav | 1.0 / REVIEW – PREPARED_NOT_APPLIED |
| Datum | 28. 9. 2026 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Cíl | ops.source_intelligence_map |
| Vazby | G4D closure; MM-NAV-20260927-03; inventář DB z 28. 9. 2026 13:33 |
| Doporučené umístění | docs/05_PROVIDERS/ |
| Standardy | MM-STD-001, 003, 004, 006, 009 |

Pracovní identifikátor se nepovažuje za přidělené centrální Document ID; pracovní návrh využívá výjimku MM-STD-004 §11. Názvy aktivních souborů končí _V1 podle uživatelova workflow.

## 1. Úvod a hranice tohoto kroku

Seznam obsahuje **34 konkrétních kandidátů pro audit HB**, z toho **4 již evidované zdroje a 30 navržených nových řádků**. Podle dodaného exportu je dnes v registru 6 řádků: 4 konkrétní zdroje a 2 obecné discovery kategorie. Po bezkolizním vložení 30 nových by tabulka obsahovala 36 řádků, z toho 34 konkrétních zdrojů. Jde o očekávání podle exportu, nikoliv zjištění z živé DB.

Rešerše ověřuje existenci relevantních webů nebo produktových stránek. Nepředstavuje dokončený technický, právní ani kvalitativní audit. Popis „k auditu“ je návrh toho, co hledat, nikoliv slib dostupného pokrytí. Veřejné zobrazení webu neprokazuje oprávnění k automatickému stahování, redistribuci ani použití fotografií.

**V databázi nebylo v tomto kroku nic vloženo ani změněno.** Součástí jsou importní data a READ ONLY precheck. APPLY připravíme po vyhodnocení jeho výstupu, v souladu s postupem po jednom kroku.

## 2. Seznam zdrojů

Pořadí je pracovní pořadí auditu, ne skóre kvality. U čtyř existujících zdrojů se zachová jejich současný stav, priorita i starší audit. Označení HB-CAND je identifikátor položky tohoto balíku, nikoliv canonical source_id nebo source_map_id.

| ID | Zdroj / web | Kdo to je | Předběžné zaměření | Import |
|---|---|---|---|---|
| HB-CAND-001 | [API-Sports](https://api-sports.io) | Poskytovatel sportovních API | HB API; prověřit soutěže, týmy, zápasy, tabulky a kurzy | Nový kandidát |
| HB-CAND-002 | [Sportradar](https://sportradar.com) | Poskytovatel sportovních dat | HB API: výsledky, statistiky, profily, historie, LIVE; skutečný rozsah závisí na pokrytí | Nový kandidát |
| HB-CAND-003 | [STATSCORE](https://www.statscore.com) | Poskytovatel sportovních dat | HB SportsAPI: zápasy, týmy a statistiky dle úrovně balíčku | Nový kandidát |
| HB-CAND-004 | [Data Sports Group](https://datasportsgroup.com) | Poskytovatel sportovních dat | Produktová stránka HB API a živých výsledků; přesné entity prověřit | Nový kandidát |
| HB-CAND-005 | [Goalserve](https://www.goalserve.com) | Poskytovatel datových feedů | HB zápasy, výsledky, tabulky a kurzy; XML/JSON | Nový kandidát |
| HB-CAND-006 | [BetsAPI](https://betsapi.com) | Poskytovatel výsledků a sázkových dat | Dokumentace obsahuje sport_id 78 = házená; entity a dostupné kurzy otestovat | Nový kandidát |
| HB-CAND-007 | [European Handball Federation](https://www.eurohandball.com) | Evropská házenkářská federace | Evropské soutěže, týmy, hráči, zápasy; ověřit archiv a statistiky | Zachovat ID 1 |
| HB-CAND-008 | [International Handball Federation](https://www.ihf.info) | Mezinárodní házenkářská federace | Světové soutěže, účastníci, zápasy a publikované materiály | Zachovat ID 2 |
| HB-CAND-009 | [Český svaz házené](https://www.handball.cz) | Národní svaz – Česko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-010 | [Deutscher Handballbund](https://www.dhb.de) | Národní svaz – Německo | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-011 | [DanskHåndbold](https://danskhaandbold.dk) | Národní svaz – Dánsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-012 | [Norges Håndballforbund](https://www.handball.no) | Národní svaz – Norsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-013 | [Svenska Handbollförbundet](https://svenskhandboll.se) | Národní svaz – Švédsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-014 | [Fédération Française de Handball](https://www.ffhandball.fr) | Národní svaz – Francie | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-015 | [Real Federación Española de Balonmano](https://www.rfebm.com) | Národní svaz – Španělsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-016 | [Związek Piłki Ręcznej w Polsce](https://zprp.pl) | Národní svaz – Polsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-017 | [Magyar Kézilabda Szövetség](https://www.mksz.hu) | Národní svaz – Maďarsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-018 | [Federația Română de Handbal](https://frh.ro) | Národní svaz – Rumunsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-019 | [Hrvatski rukometni savez](https://hrs.hr) | Národní svaz – Chorvatsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-020 | [Rokometna zveza Slovenije](https://www.rokometna-zveza.si) | Národní svaz – Slovinsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-021 | [Schweizerischer Handball-Verband](https://www.handball.ch) | Národní svaz – Švýcarsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-022 | [Österreichischer Handballbund](https://www.oehb.at) | Národní svaz – Rakousko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-023 | [Slovenský zväz hádzanej](https://www.slovakhandball.sk) | Národní svaz – Slovensko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-024 | [Federação de Andebol de Portugal](https://portal.fpa.pt) | Národní svaz – Portugalsko | K auditu: domácí soutěže, reprezentace, týmy, hráči, výsledky a archiv. | Nový kandidát |
| HB-CAND-025 | [Handball-Bundesliga](https://www.opel-hbl.de) | Ligový web / organizátor – Německo | K auditu: ligové zápasy, týmy, hráči, statistiky a historické sekce. | Nový kandidát |
| HB-CAND-026 | [Ligue Nationale de Handball](https://www.lnh.fr) | Ligový web / organizátor – Francie | Web uvádí kalendář, výsledky, týmy, hráče, statistiky a historii sezón. | Nový kandidát |
| HB-CAND-027 | [ASOBAL](https://asobal.es) | Ligový web / organizátor – Španělsko | Web uvádí kalendář, výsledky, týmy, statistiky a historické úspěchy. | Nový kandidát |
| HB-CAND-028 | [Superliga (Polsko)](https://orlen-superliga.pl) | Ligový web / organizátor – Polsko | K auditu: ligové výsledky, program a statistiky; aktuální web nese značku LOTTO Superliga. | Nový kandidát |
| HB-CAND-029 | [Svensk Elithandboll / Handbollsligan](https://handbollsligan.se) | Ligový web / organizátor – Švédsko | K auditu: mužské i ženské soutěže; ověřena ženská stránka týmových statistik. | Nový kandidát |
| HB-CAND-030 | [Asian Handball Federation](https://asianhandball.org) | Asijská házenkářská federace | K auditu: kontinentální soutěže, programy, výsledky a zprávy. | Nový kandidát |
| HB-CAND-031 | [Confédération Africaine de Handball](https://cahbonline.info) | Africká házenkářská konfederace | K auditu: africké soutěže, účastníci, programy a výsledky. | Nový kandidát |
| HB-CAND-032 | [North America and the Caribbean Handball Confederation](https://norcahandball.com) | Severoamerická a karibská házenkářská konfederace | K auditu: regionální soutěže, účastníci a výsledky. | Nový kandidát |
| HB-CAND-033 | [Wikidata](https://www.wikidata.org) | Otevřená znalostní báze | Identity a vazby hráčů, týmů a organizací; rozsah HB ověřit | Zachovat ID 3 |
| HB-CAND-034 | [Wikimedia Commons](https://commons.wikimedia.org) | Archiv mediálních souborů | Fotografie a média; licence se ověřuje pro každý konkrétní soubor | Zachovat ID 4 |

## 3. Podklady a otevřené otázky po zdrojích

Datum rešerše všech níže uvedených odkazů: 28. 9. 2026. Číselné ceny jsou pouze pozorování veřejného ceníku, bez uzavřeného výběru tarifu. Veřejné svazové a ligové weby nemají tímto krokem potvrzenou cenu datové licence ani API. Jejich cenu proto neevidujeme jako 0.

- **HB-CAND-001 – API-Sports**. [Podklad](https://api-sports.io/sports/handball). Cena: Free 100 požadavků/den; placený PRO zobrazuje 15,00 za měsíční volbu. Měna a daně v načteném textu nedoloženy – cenu nepřenášet jako potvrzenou. api_handball je existující adapter; toto není vytvoření canonical identity ani bindingu. STEP 4A z NAV-03 zůstává samostatným otevřeným bodem.
- **HB-CAND-002 – Sportradar**. [Podklad](https://developer.sportradar.com/handball/reference/handball-overview). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Dokumentace uvádí nejvýše tři sezóny ve výstupech Competition Seasons/Seasons; dostupnost hlubší historie je otevřená otázka, nikoliv potvrzené plné historické pokrytí.
- **HB-CAND-003 – STATSCORE**. [Podklad](https://www.statscore.com/coverage/sportsapi/handball/). Cena: Cena podle soutěží a úrovně; číselná nabídka nezjištěna. 
- **HB-CAND-004 – Data Sports Group**. [Podklad](https://datasportsgroup.com/coverage/handball/). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 
- **HB-CAND-005 – Goalserve**. [Podklad](https://www.goalserve.com/en/sport-data-feeds/handball-api/prices). Cena: Veřejný ceník: 100 USD / 1 měsíc; 500 USD / 6 měsíců; 900 USD / 12 měsíců. Rozsah, daně a aktuální nabídku potvrdit. 
- **HB-CAND-006 – BetsAPI**. [Podklad](https://betsapi.com/docs/GLOSSARY.html). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 
- **HB-CAND-007 – European Handball Federation**. [Podklad](https://www.eurohandball.com). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Zachovat starý audit i částečný právní stav. Nová rešerše není nový dokončený audit.
- **HB-CAND-008 – International Handball Federation**. [Podklad](https://www.ihf.info). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 
- **HB-CAND-009 – Český svaz házené**. [Podklad](https://www.handball.cz). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-010 – Deutscher Handballbund**. [Podklad](https://www.dhb.de). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-011 – DanskHåndbold**. [Podklad](https://danskhaandbold.dk). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-012 – Norges Håndballforbund**. [Podklad](https://www.handball.no). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-013 – Svenska Handbollförbundet**. [Podklad](https://svenskhandboll.se/nyheter). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. Načtení hlavní stránky selhalo, dohledána stránka zpráv.
- **HB-CAND-014 – Fédération Française de Handball**. [Podklad](https://www.ffhandball.fr). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. Načtený obsah je velmi omezený; datové sekce ověřit.
- **HB-CAND-015 – Real Federación Española de Balonmano**. [Podklad](https://www.rfebm.com). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-016 – Związek Piłki Ręcznej w Polsce**. [Podklad](https://zprp.pl). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-017 – Magyar Kézilabda Szövetség**. [Podklad](https://www.mksz.hu). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. Načtený obsah je velmi omezený; datové sekce ověřit.
- **HB-CAND-018 – Federația Română de Handbal**. [Podklad](https://frh.ro). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-019 – Hrvatski rukometni savez**. [Podklad](https://hrs.hr). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-020 – Rokometna zveza Slovenije**. [Podklad](https://www.rokometna-zveza.si). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-021 – Schweizerischer Handball-Verband**. [Podklad](https://www.handball.ch). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-022 – Österreichischer Handballbund**. [Podklad](https://www.oehb.at). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-023 – Slovenský zväz hádzanej**. [Podklad](https://www.slovakhandball.sk). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-024 – Federação de Andebol de Portugal**. [Podklad](https://portal.fpa.pt). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Nalezen web svazu; dostupnost konkrétních dat není potvrzena. 
- **HB-CAND-025 – Handball-Bundesliga**. [Podklad](https://www.opel-hbl.de). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.
- **HB-CAND-026 – Ligue Nationale de Handball**. [Podklad](https://www.lnh.fr). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.
- **HB-CAND-027 – ASOBAL**. [Podklad](https://asobal.es). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.
- **HB-CAND-028 – Superliga (Polsko)**. [Podklad](https://orlen-superliga.pl). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.
- **HB-CAND-029 – Svensk Elithandboll / Handbollsligan**. [Podklad](https://handbollsligan.se/dam/lagstatistik/). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. Identitu právního provozovatele a vztah k dodavateli dat ověřit. Sponzorský název soutěže není nová identita zdroje.
- **HB-CAND-030 – Asian Handball Federation**. [Podklad](https://asianhandball.org). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 
- **HB-CAND-031 – Confédération Africaine de Handball**. [Podklad](https://cahbonline.info). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 
- **HB-CAND-032 – North America and the Caribbean Handball Confederation**. [Podklad](https://norcahandball.com). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 
- **HB-CAND-033 – Wikidata**. [Podklad](https://www.wikidata.org/wiki/Wikidata:Main_Page). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 
- **HB-CAND-034 – Wikimedia Commons**. [Podklad](https://commons.wikimedia.org/wiki/Category:Handball). Cena: Nezjištěna; cenu datového přístupu ověřit při auditu. 

U všech kandidátů zůstává přesný rozsah HISTORY_FAN, HISTORY_PREDICTION, CURRENT, FUTURE a LIVE **UNKNOWN**. Pozorované sekce webu a tvrzení poskytovatele se nejdříve uloží jako důkaz; teprve audit určí entity, soutěže, sezóny a režimy skutečně dostupné MatchMatrix. Fanouškovská historie nemá pevný obecný počáteční rok. Predikční historii je nutné posoudit zvlášť včetně dostupnosti dat před výkopem a rizika úniku budoucích informací do modelu.

Seznam není uzavřený: další API, klubové weby, historické archivy a mimoevropské zdroje přidáme v dalších dávkách. Nejsou zde uměle započítány obecné kategorie „Official Club Websites“ a „Official League Websites“ ani samostatné produkty téhož providera jako API-Sports a API-Handball.

## 4. Přesný kontrakt importu

Tabulka má jedinečný index `(sport_code, entity_type, source_name, source_type)`. Proto samotné ON CONFLICT podle indexu nestačí k ochraně před druhým řádkem téhož kandidáta pod jinou entitou.

| Pole / oblast | Způsob přípravy |
|---|---|
| sport_code | HB |
| entity_type | MULTI pro nové kandidáty; stávající PLAYERS/PHOTOS zachovat |
| current_status | DISCOVERY u nových řádků; v panelu „Neprověřeno“ |
| supports_* | Explicitní NULL = nezjištěno; nepřebírat default false |
| trust_score, automation_score | NULL, ne výchozí 50/0 |
| access_type, expected_depth | UNKNOWN |
| license_status, robots_status | NEEDS_REVIEW |
| historical_from_year, last_checked_at | NULL; rešerše není dokončený audit |
| priority_order | Návrh pořadí; nepoužít jako skóre kvality |
| notes | JSON uložený jako text: dávka, referenční ID, účel, podklad, datum rešerše, pozorování ceny, neznámé časové režimy |
| source_map_id | Při budoucím APPLY nechat přidělit existující sekvencí |
| created_at, updated_at | Při budoucím APPLY využít databázové defaulty |

`country_code` se zde neplní: země pokrytí není automaticky země sídla poskytovatele. Ceny zůstávají pozorováním v notes; nevytváří se nepotvrzený komerční audit. Soubor JSON obsahuje přesné názvy skutečných cílových sloupců; pole obálky `candidate_ref`, `action` a `expected_existing_source_map_id` nejsou sloupce DB.

Precheck porovnává jméno, webovou doménu a očekávaná ID čtyř existujících řádků. Shoda domény/názvu je pouze zábrana proti duplicitám. Nezakládá canonical identitu ani propojení s adapterem. Více kandidátů stejné organizace na jedné doméně by vyžadovalo ruční rozlišení.

Budoucí APPLY musí v jedné transakci zopakovat kontrolu schématu, práv, sekvence, triggerů/RLS a kolizí; použít zámek bránící souběžnému zápisu, vložit jen nové řádky a ověřit počty i zachování původních řádků. Opakovaný běh stejné dávky musí podle značky dávky a obsahu přesně rozpoznat již importované kandidáty. Při jiné shodě se zastaví. Žádné hromadné přepisování starých záznamů, reset auditů ani odvozování identity ze jména.

Závěr: využije se současný kandidátní registr bez nové fyzické tabulky. Tento krok se nedotýká source_master, source_alias, source_sport, coverage, bindingu, routingu ani starších auditních tabulek.

## 5. Návazná úprava panelu PROVIDEŘI – pracovní zadání

Realizace následuje po vložení a ověření kandidátů. Před úpravou je nutná aktuální používaná verze panelu a její .vbs spouštěč; nalezené starší kopie neprokazují současný stav.

Horní záložky: **Přehled, Zdroje, Audit, Pokrytí dat, Cena, Právní stav, Kvalita, Doporučení, Provoz**. Vlevo zůstane hlavní menu. Jedna hlavní tabulka na záložku, tlumená fialová, menší KPI bez rámečků, české názvy, tooltipy, dvojklik na detail zdroje, jeden hlavní posuvník.

Pracovní postup v detailu zdroje:

1. Vybrat zdroj a rozsah auditu; zobrazit již známé důkazy a otevřené otázky.
2. **Spustit audit** – úloha běží na PC2, vrátí identifikátor běhu a stav; uživatelské rozhraní nezamrzá.
3. Automaticky sbírat povolené podklady a testy, ukládat jejich URL, čas, hash, výsledek a chyby. Chybějící konektor znamená „Nutno doplnit ručně“, nikoliv úspěch.
4. Po doběhu zobrazit výsledky a návrh doporučení; jednotlivé oblasti mohou mít různé stavy. Dokončený běh není automaticky schválený zdroj.
5. Společně doplnit ruční rozhodnutí, důvod, autora a datum. Oprávněný uživatel schválí pouze doložený rozsah.

| Výstup | Zamýšlený cíl | Podmínka |
|---|---|---|
| Průběh jednotlivých oblastí | source_discovery_audit_tracker | Ověřit přesné přiřazení kandidáta; zachovat starší výsledky |
| Cenová fakta | source_commercial_model | Identifikovaný tarif, měna, období a podklad |
| Právní podklady a závěr | source_legal_audit | Automatická extrakce oddělená od lidského schválení |
| Měření kvality | source_quality_score | Transparentní metriky a skutečný vzorek dat |
| Důkazy canonical zdroje | source_audit_evidence | Musí existovat a být doložené source_id; toto pole je NOT NULL |
| Pokrytí | source_entity_time_coverage | Přesný SOURCE × SPORT × LAYER × ENTITY × TIME MODE a důkaz |
| Použití v platformě | data_acquisition_source_routing | Výslovné rozhodnutí a splněné závislosti, ne automatický důsledek auditu |

**Otevřený technický bod:** kandidát bez canonical identity zatím nemůže dostat řádek v source_audit_evidence, protože ta vyžaduje source_id. Před implementací audit runneru prověříme existující registr běhů/artefaktů a způsob explicitního mapování kandidáta. Pro takového kandidáta se důkazy nejprve uloží jako auditní artefakt s candidate_ref/source_map_id, nikoliv pod vypůjčenou identitou. Nepřidává se automatická vazba podle názvu.

Sjednocující SQL pohledy mají vracet stejná fakta do DBeaveru i panelu. Nesmějí násobit řádky při spojování více důkazů, tarifů a coverage záznamů; každá obrazovka musí mít definovanou granularitu a pravidlo platnosti. NULL se zobrazuje jako „Nezjištěno“, nikoliv „Ne“.

Běhy musí mít ochranu před dvojím spuštěním, časový limit, limity požadavků, opakování po chybě bez duplicit a historii chyb. API klíče se nezapisují do logů ani důkazů. Automatizace smí vyplnit fakta a návrhy, ne fingovat ruční schválení.

Závěr: panel je navazující implementační krok. Zatím nebyl změněn a audit runner není nasazen.

## AI CONTEXT

G4D zůstává dokončené. Tento balík rozšiřuje pouze discovery registr. API-Sports canonical vytvoření je podle posledního NAV stále otevřené; kandidátní zápis je jiná operace. Novější DB inventář potvrzuje source_master 17, alias 35, source_sport 17, evidence 57, runtime_adapter 27 a coverage/binding/routing 0.

## PROJECT SNAPSHOT

MatchMatrix-platform, řízení na PC1/PC2, DB a budoucí audit runner na PC2. Repozitář ani živá DB nebyly v této relaci otevřeny. Git branch/commit nejsou ověřeny.

## DATABASE SNAPSHOT

Zdroj: MM_PROVIDER_SOURCE_DATABASE_INVENTORY.zip, export 28. 9. 2026 13:33. source_intelligence_map 6 řádků; source_discovery_audit_tracker 15; source_commercial_model 6; source_legal_audit 1; source_quality_score 1. Nejde o přímý dotaz do živé DB.

## CURRENT STATUS

34 kandidátů připraveno; 30 nových / 4 existující podle exportu. JSON a READ ONLY SQL připraveny. Import, APPLY, úprava panelu i automatické audity neprovedeny. Kontrola podkladů a konzistence souborů provedena; SQL musí ověřit skutečné prostředí uživatele.

## OPEN QUESTIONS

- Výsledek prechecku v aktuální DB, případné kolize a současná oprávnění.
- Aktuální soubory panelu a spouštěče před jeho implementací.
- Existující úložiště běhů/artefaktů a explicitní vazba kandidát → audit → canonical source.
- Právní použitelnost, skutečný datový rozsah, ceny a limity každého kandidáta.

## NEXT STEP

Spustit pouze MM_HB_KANDIDATI_KROK_1_PRECHECK_V1.sql v DBeaveru a poslat výsledky. Očekáváno 30 NOVY_KANDIDAT, 4 ZACHOVAT_EXISTUJICI, 0 PROVERIT_KOLIZI; tabulka stále 6 řádků. Následně připravit jediný řízený import podle výsledku. Nezahajovat současně přestavbu panelu.

## Historie verzí

| Verze | Datum | Popis | Stav |
|---|---|---|---|
| 1.0 | 2026-09-28 | První rešerše 34 kandidátů, importní data, precheck a návazné zadání panelu | REVIEW |
