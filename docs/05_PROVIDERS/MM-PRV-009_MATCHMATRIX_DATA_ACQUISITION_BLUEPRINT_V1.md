# MM-PRV-009

# MATCHMATRIX DATA ACQUISITION BLUEPRINT

## ŘÍDICÍ DOKUMENT PRO VÝBĚR ZDROJŮ, HARVEST A DLOUHODOBOU SPRÁVU DAT

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-PRV-009 |
| Název dokumentu | MatchMatrix Data Acquisition Blueprint |
| Český význam | Plán získávání, ověřování a dlouhodobé správy datových zdrojů MatchMatrix |
| Typ dokumentu | PROVIDER / DATA ACQUISITION BLUEPRINT |
| Edice | MM-PRV / TECH |
| Verze | 1.0 |
| Stav | DRAFT |
| Datum založení | 2026-09-24 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Cílové umístění | `docs/05_PROVIDERS/` |
| Aktivní soubor | `MM-PRV-007_MATCHMATRIX_DATA_ACQUISITION_BLUEPRINT_V1.md` |
| Primární databáze | PostgreSQL `matchmatrix` |
| Hlavní provozní uzel harvestu | PC2 / MATCHMATRIX |
| Stav realizace | PŘÍPRAVA BLUEPRINTU – HARVEST ZATÍM NESPOUŠTĚT |

> **Poznámka k Document ID:** Označení `MM-PRV-007` je pracovní návrh pro nový dokument v oblasti `05_PROVIDERS`. Před schválením dokumentu musí být jedinečnost čísla ověřena proti aktuálnímu dokumentačnímu indexu a dokumentační databázi.

---

# 1. Úvod

## 1.1 Proč tento dokument vzniká

MatchMatrix je multisportovní platforma, jejíž dlouhodobá hodnota závisí na kvalitě, úplnosti, dohledatelnosti a udržitelnosti získávaných sportovních dat.

Samotná skutečnost, že určitý provider nabízí API nebo že určitý web obsahuje sportovní informace, nestačí pro rozhodnutí, že bude zdroj použit v produkčním harvestu. Každý zdroj musí být posouzen nejméně z hlediska:

- sportu a konkrétní entity,
- historické hloubky,
- aktuálního a budoucího pokrytí,
- kvality a úplnosti dat,
- technické dostupnosti,
- automatizovatelnosti,
- ceny a request limitů,
- licenčních a právních podmínek,
- možnosti komerčního použití,
- návaznosti na datový model MatchMatrix,
- schopnosti bezpečného canonical merge s jinými zdroji.

Tento dokument vytváří jednotný rámec, podle kterého budou všechny datové zdroje MatchMatrix vyhledávány, ověřovány, vybírány, implementovány, provozovány a pravidelně přehodnocovány.

## 1.2 Hlavní rozhodnutí

**Rozsáhlý harvest nebude spuštěn dříve, než bude pro všechny aktivní sporty připraven a uživatelem schválen Data Acquisition Blueprint.**

Blueprint musí před spuštěním produkčního harvestu odpovědět zejména na otázky:

1. Jaká data chceme pro daný sport skutečně uchovávat?
2. Z jakého zdroje bude získána každá konkrétní entita?
3. Jaký zdroj je PRIMARY, FALLBACK, MERGE nebo SUPPLEMENT?
4. Jak hluboko do historie půjdeme?
5. Jak bude oddělena historie pro predikce a historie pro fanouškovskou/encyklopedickou vrstvu?
6. Jak budou získávána CURRENT a FUTURE data?
7. Jak často se budou jednotlivé entity obnovovat?
8. Kolik bude získávání dat stát a jaké jsou request limity?
9. Je použití zdroje právně a licenčně přijatelné?
10. Do jaké RAW, STAGING a PUBLIC vrstvy se budou data ukládat?
11. Jak budou identity spojovány mezi providery?
12. Jak bude kvalita výsledku ověřena před rozšířením harvestu?

## 1.3 Účel dokumentu

Dokument má dvě role:

**Řídicí role** – stanovuje jednotný postup realizace Data Acquisition programu.

**Referenční role** – postupně obsahuje kompletní mapu `SPORT × ENTITA × ČASOVÁ VRSTVA × ZDROJ × TECHNICKÁ CESTA × PRÁVNÍ/OBCHODNÍ STAV`.

## 1.4 Závěr kapitoly

Data Acquisition Blueprint je vstupní podmínkou pro řízené naplnění platformy. Nejde o seznam providerů, ale o dlouhodobý plán správy datového zásobování celé platformy.

---

# 2. Rozsah Blueprintu

## 2.1 Aktivní sporty

Výchozí rozsah tvoří všechny sporty vedené v `public.sports` jako aktivní:

| Kód | Sport | Typ zobrazení |
|---|---|---|
| FB | Football | team_vs_team |
| HK | Hockey | team_vs_team |
| BK | Basketball | team_vs_team |
| TN | Tennis | player_vs_player |
| MMA | MMA | player_vs_player |
| DRT | Darts | player_vs_player |
| VB | Volleyball | team_vs_team |
| HB | Handball | team_vs_team |
| BSB | Baseball | team_vs_team |
| RGB | Rugby | team_vs_team |
| CK | Cricket | team_vs_team |
| FH | Field Hockey | team_vs_team |
| AFB | American Football | team_vs_team |
| ESP | Esports | player_vs_player |

Blueprint musí být navržen tak, aby bylo možné stejným mechanismem později přidat další sporty bez změny základních principů.

## 2.2 Datové domény

Každý sport bude analyzován podle sportovně relevantních entit. Základní univerzální domény jsou:

### CORE

- competitions / leagues / tournaments / promotions,
- seasons / editions,
- teams / participants,
- fixtures / matches / bouts / events,
- results,
- standings / rankings, pokud jsou pro sport relevantní,
- venues / locations, pokud jsou dostupné a užitečné.

### PEOPLE

- players / athletes / fighters,
- coaches,
- staff,
- profiles,
- squads / rosters,
- career history,
- season statistics,
- match statistics,
- rankings,
- biographies a identifikační údaje,
- fotografie – pouze pokud je licenční použití vyřešeno.

### MATCH DETAIL

- lineups / starting lineups,
- substitutes,
- incidents / events,
- match statistics,
- player statistics,
- injuries,
- suspensions / absences,
- officials / referees,
- live state,
- final state a korekce výsledku.

### ODDS

- bookmakers,
- markets,
- selections,
- pre-match odds,
- live odds,
- closing odds,
- timestamps jednotlivých snapshotů,
- vazba odds na canonical match.

### MEDIA / FAN

- official news,
- articles,
- previews,
- reports,
- highlights,
- video metadata,
- fotografie,
- achievements / honours,
- records,
- historical squads,
- club/team/player milestones,
- historical context pro srovnávání generací.

## 2.3 Sportovně specifické entity

Univerzální model nesmí nutit všechny sporty do fotbalové struktury.

Příklady:

- Tennis: tournaments, rounds, matches, players, rankings, surfaces.
- MMA: promotions, events, bouts, fighters, weight classes, rankings.
- Darts: tournaments, stages, matches, players, rankings.
- Cricket: competitions, matches, innings, scorecards, teams, players.
- Baseball: leagues, teams, games, innings, pitchers/batters, box score.
- Esports: games/titles, competitions, teams/players, maps/rounds podle dostupnosti.

Každý sport proto dostane vlastní schválený Entity Catalogue.

## 2.4 Závěr kapitoly

Blueprint je společný rámec, ale výsledná datová struktura je vždy řízena realitou konkrétního sportu.

---

# 3. Časový model dat

## 3.1 Povinné časové vrstvy

Každá entita musí být posouzena minimálně ve čtyřech časově-uživatelských režimech.

### HISTORY_FAN

Účel:

- dlouhodobá historie sportu,
- historie soutěží a klubů,
- srovnávání generací,
- historické rekordy,
- úspěchy hráčů, trenérů a týmů,
- historické soupisky,
- encyklopedický a fanouškovský obsah.

Cíl:

**získat historii co nejhlouběji, pokud je spolehlivě, legálně a technicky dostupná.**

HISTORY_FAN není omezena desetiletým predikčním oknem.

### HISTORY_PREDICTION

Účel:

- trénink a validace modelů,
- ratings,
- features,
- predikce,
- analýza výkonnosti a formy.

Výchozí pracovní maximum:

**přibližně posledních 10 let historie.**

Konkrétní model může používat kratší období podle kvality a relevance dat.

### CURRENT

Účel:

- aktuální den,
- právě probíhající sezóna,
- live/current stav,
- průběžně se měnící informace.

CURRENT není jednorázový harvest. Jde o provozní refresh vrstvu.

### FUTURE

Účel:

- naplánované zápasy a eventy,
- budoucí termíny,
- odds,
- preview,
- očekávané a potvrzené lineups,
- injuries / absences,
- předzápasové informace,
- informace potřebné pro Ticket Engine a prediction pipeline.

## 3.2 Přibližování se události

Frekvence FUTURE refresh nemusí být konstantní. U entit, které se mění s blížícím se začátkem události, bude navržena dynamická cadence.

Příklad konceptu:

```text
T-30d   existence fixture/eventu a základní metadata
T-7d    forma, news, injuries/absences podle dostupnosti
T-24h   odds, projected lineups, updated context
T-6h    změny odds, absencí a předzápasových údajů
T-1h    confirmed lineups / finální pre-match snapshot
LIVE    live data podle sportu a licence providera
FINAL   výsledek, finální statistiky, closing snapshot
POST    případné oficiální korekce
```

Toto není univerzální pevný harmonogram. Každý sport, entita a provider dostane vlastní cadence podle reality dat a request limitu.

## 3.3 Závěr kapitoly

Historie pro modely a historie pro fanoušky jsou dva různé produkty. Jejich oddělení zabrání tomu, aby analytické omezení zbytečně omezovalo historickou hodnotu celé platformy.

---

# 4. Role datových zdrojů

## 4.1 PRIMARY

Hlavní zdroj entity. Musí mít nejvyšší kombinaci kvality, stability, coverage, právní použitelnosti, ceny a technické integrace.

## 4.2 FALLBACK

Náhradní zdroj použitelný při výpadku PRIMARY nebo pro soutěže/entity, které PRIMARY nepokrývá.

## 4.3 MERGE

Zdroj, jehož data se mají kombinovat s PRIMARY za účelem rozšíření nebo zkvalitnění canonical entity.

## 4.4 SUPPLEMENT

Doplňkový zdroj, který nepřebírá hlavní CORE identitu, ale přidává například historii, media, profily, fotografie, rekordy nebo jiné atributy.

## 4.5 DISCOVERY ONLY

Zdroj určený pouze k průzkumu. Nesmí být bez dalšího schválení použit v automatizovaném produkčním harvestu.

## 4.6 BLOCKED

Zdroj nebo entita, která je technicky, obchodně, právně nebo kvalitativně nevhodná pro daný účel.

## 4.7 Závěr kapitoly

Jeden sport může a zpravidla bude používat více providerů současně. Cílem není najít jediný univerzální zdroj, ale optimální zdroj pro každou entitu a časovou vrstvu.

---

# 5. Stavový model a úrovně důkazu

Každý zdroj a každá entita musí mít stav, který rozlišuje konfiguraci od skutečného ověření.

## 5.1 Základní úrovně

### CONFIGURED

Zdroj nebo job existuje v MatchMatrix konfiguraci.

To samo o sobě neznamená, že endpoint vrací požadovaná data.

### TECH_READY

Existuje technická cesta, worker nebo staging model, ale nemusí být potvrzena reálná coverage.

### RUNTIME_TESTED

Endpoint byl skutečně spuštěn a technicky odpověděl.

### DATA_CONFIRMED

Bylo potvrzeno, že odpověď obsahuje reálně použitelná data pro zamýšlený scope.

### COVERAGE_VERIFIED

Byla ověřena skutečná hloubka a rozsah dat pro konkrétní sport/entity/soutěže/sezóny.

### LEGAL_REVIEWED

Byly zkontrolovány relevantní robots, terms, licence a komerční použití.

### COMMERCIAL_REVIEWED

Byly ověřeny ceny, limity, tarif a očekávaná provozní ekonomika.

### APPROVED_FOR_HARVEST

Zdroj splnil všechny povinné gate pro danou entitu a časový režim.

### BLOCKED

Existuje známý důvod zdroj nepoužít.

## 5.2 Pravidlo

**`supports_* = true`, `planned`, `enabled = true` nebo existence jobu není důkaz produkční použitelnosti.**

## 5.3 Závěr kapitoly

Blueprint musí vždy uvést nejen co je nakonfigurováno, ale také z jakého důkazu pochází tvrzení o použitelnosti zdroje.

---

# 6. Povinný záznam pro každou entitu

Pro každou kombinaci `SPORT × ENTITY × TIME_MODE` musí být vytvořen záznam s minimálně následujícími poli:

| Pole | Význam |
|---|---|
| SPORT_CODE | interní kód sportu |
| SPORT_NAME | název sportu |
| ENTITY | konkrétní entita |
| ENTITY_DOMAIN | CORE / PEOPLE / MATCH_DETAIL / ODDS / MEDIA / FAN |
| TIME_MODE | HISTORY_FAN / HISTORY_PREDICTION / CURRENT / FUTURE |
| PURPOSE | proč data potřebujeme |
| PRIMARY_SOURCE | hlavní zdroj |
| FALLBACK_SOURCE | náhradní zdroj |
| MERGE_SOURCE | zdroj pro sloučení |
| SUPPLEMENT_SOURCE | doplňkový zdroj |
| SOURCE_TYPE | API / federation / league / club / open data / media / jiný |
| ENDPOINT_OR_URL | konkrétní endpoint nebo URL pattern |
| REQUEST_PARAMETERS | league/team/season/date apod. |
| COVERAGE_SCOPE | globální / regionální / soutěžní / týmový |
| HISTORY_FROM | nejstarší ověřený rok/sezóna |
| HISTORY_TO | konec historického rozsahu |
| HISTORY_DEPTH | skutečná hloubka |
| FUTURE_HORIZON | jak daleko dopředu zdroj poskytuje data |
| REFRESH_POLICY | provozní cadence |
| FREE_OR_PAID | tarifní model |
| PLAN | konkrétní tarif, pokud relevantní |
| REQUEST_LIMIT | denní/měsíční/minutový limit |
| COST | měsíční/roční náklad |
| COMMERCIAL_STATUS | stav obchodního ověření |
| ROBOTS_STATUS | relevantní pro webové zdroje |
| TERMS_STATUS | stav Terms review |
| MEDIA_LICENSE | photo/video licence |
| COMMERCIAL_USE_STATUS | možnost komerčního použití |
| LEGAL_RISK | LOW / MEDIUM / HIGH / BLOCKED |
| QUALITY | kvalita dat |
| COMPLETENESS | úplnost |
| RUNTIME_STATUS | stav technického ověření |
| EVIDENCE | konkrétní důkaz/test/report |
| RAW_TARGET | cílová RAW vrstva |
| STAGING_TARGET | cílová staging tabulka |
| PUBLIC_TARGET | canonical/public cíl |
| CANONICAL_KEYS | klíče pro identitní propojení |
| MERGE_RULE | pravidlo sloučení |
| RETENTION | pravidlo uchování |
| OWNER | odpovědná oblast |
| NEXT_ACTION | nejbližší další krok |
| DECISION | APPROVE / REVIEW / BLOCK / TBD |

Žádné zásadní pole nesmí být „dopočítáno“ pouze z domněnky. Neznámá hodnota je explicitně označena `TBD`, `UNKNOWN` nebo `REVIEW_REQUIRED`.

---

# 7. Zdrojové tabulky MatchMatrix pro Blueprint

Aktuální stav Blueprintu bude primárně sestavován z databáze a z následného externího ověření.

## 7.1 `public.sports`

Autoritativní seznam aktivních sportů a jejich interních kódů.

## 7.2 `ops.provider_sport_matrix`

Evidence deklarovaných schopností providerů podle sportu.

Použití:

- základní capability mapa,
- nikoli samostatný důkaz skutečné coverage.

## 7.3 `ops.provider_entity_coverage`

Evidence providerů podle konkrétních entit, priority, primary/fallback role, target tabulek, workerů, omezení a dalšího kroku.

## 7.4 `ops.people_master_provider_matrix`

People-provider mapa pro players/coaches/profiles/statistics/photos.

## 7.5 `ops.provider_jobs`

Provozní job katalog – endpoint, režim, priority, batch, request budget, days_back a days_forward.

## 7.6 `ops.ingest_targets`

Konkrétní harvest scope po ligách/provider league ID/sezónách a provozních horizontech.

Aktuální `fixtures_days_back` a `fixtures_days_forward` se nesmí zaměňovat za strategii dlouhodobého historického harvestu.

## 7.7 `ops.global_source_registry`

Registr oficiálních a dalších globálních zdrojů mimo běžnou provider matici.

## 7.8 `ops.source_coverage_matrix`

Evidence skutečně ověřené coverage podle domény/entity, včetně quality/history/automation skóre.

## 7.9 `ops.source_commercial_model`

Cena, tarif, request limity, historický přístup, coverage a ROI.

## 7.10 `ops.source_legal_audit`

Robots, sitemap, privacy, terms, scraping status, photo/video licence, commercial use a legal risk.

## 7.11 Závěr kapitoly

Tyto tabulky společně tvoří interní zdroj pravdy. Externí dokumentace providerů se používá pro ověření a doplnění, nikoliv pro přepis interního stavu bez auditovatelného rozhodnutí.

---

# 8. Výchozí snapshot 2026-09-24

## 8.1 Aktivní sporty

V `public.sports` je evidováno 14 aktivních sportů.

## 8.2 Provider matrix

`ops.provider_sport_matrix` obsahuje aktivní provider konfiguraci pro všechny současné sporty, u některých sportů také více než jednoho kandidáta.

## 8.3 Entity coverage

`ops.provider_entity_coverage` již obsahuje kombinaci stavů například:

- `runtime_tested`,
- `tech_ready`,
- `planned`,
- `blocked`.

Tyto stavy jsou důležité pro rozlišení skutečně ověřených a pouze plánovaných entit.

## 8.4 Provider jobs

`ops.provider_jobs` obsahuje již existující provozní a historické joby, ale jejich `days_back` / `days_forward` odrážejí dosavadní provozní model a nejsou finálním Data Acquisition plánem.

## 8.5 Ingest targets

Snapshot obsahuje 4 428 řádků `ops.ingest_targets`.

Pokrytí není mezi sporty rovnoměrné. Některé sporty mají tisíce konkrétních targetů, jiné pouze bootstrap cíle.

## 8.6 Global source registry

Aktuálně obsahuje 6 objevených oficiálních federálních/konfederačních zdrojů:

- FIBA,
- UEFA,
- FIFA,
- European Handball Federation,
- International Handball Federation,
- International Ice Hockey Federation.

Většina je zatím ve stavu discovery / not verified a musí projít detailním ověřením.

## 8.7 Coverage, commercial a legal pilot

Nejpodrobněji je v současnosti zpracován Handball / European Handball Federation.

EHF je proto vhodným pilotem metodiky Blueprintu, nikoliv automaticky jediným zdrojem pro házenou.

---

# 9. Povinná struktura sportovní kapitoly

Každý sport bude v Blueprintu zpracován podle stejné kostry.

## 9.1 Identita sportu

- sport_code,
- sport_name,
- team/player/event model,
- hlavní soutěžní struktura,
- sportovně specifické entity.

## 9.2 Entity Catalogue

Přesný seznam entit, které bude MatchMatrix pro sport uchovávat.

## 9.3 CURRENT provider mapa

Pro každou entitu:

- současný nakonfigurovaný provider,
- runtime stav,
- endpoint,
- staging/public cesta,
- známá omezení.

## 9.4 HISTORY_PREDICTION mapa

- požadovaná datová hloubka,
- zdroje,
- historická konzistence,
- feature relevance,
- dostupné statistiky,
- canonical merge strategie.

## 9.5 HISTORY_FAN mapa

- co nejhlubší historie,
- oficiální federace,
- oficiální soutěžní weby,
- klubové weby,
- open-data zdroje,
- historické profily a records,
- licence textu/fotografií/videa.

## 9.6 FUTURE mapa

- scheduled events,
- odds,
- lineups,
- injuries/absences,
- preview/news,
- refresh cadence.

## 9.7 PEOPLE mapa

- players,
- coaches,
- staff,
- profiles,
- career history,
- statistics,
- photos.

## 9.8 ODDS mapa

- primary odds source,
- fallback/global coverage source,
- premium/sharp kandidáti,
- market coverage,
- bookmaker coverage,
- snapshot cadence,
- attach úspěšnost na canonical matches.

## 9.9 MEDIA/FAN mapa

- official articles,
- records,
- historical context,
- photos,
- videos/highlights,
- licenční režim.

## 9.10 Commercial audit

- free/paid,
- ceny,
- limity,
- ROI,
- plán tarifu.

## 9.11 Legal audit

- robots,
- sitemap,
- terms,
- scraping,
- commercial use,
- photo/video licence,
- výsledné riziko.

## 9.12 Technická implementace

- worker,
- planner/job,
- RAW target,
- staging target,
- public target,
- canonical merge,
- monitoring,
- retry/rate-limit strategie.

## 9.13 Acceptance checklist

Sport není připraven na produkční harvest, dokud není splněn jeho sportovní gate.

---

# 10. Realizační postup – end-to-end

Tato kapitola je závaznou kostrou realizace.

## FÁZE 0 – Zmrazení výchozího stavu

### Cíl

Uchovat přesný auditovatelný obraz toho, co je v projektu před změnami.

### Kroky

1. READ ONLY snapshot relevantních `ops.*` tabulek.
2. Export provider/entity/jobs/targets/source/legal/commercial registrů.
3. Zapsat datum snapshotu.
4. Oddělit stav `configured` od stavu `verified`.
5. Nevytvářet nové harvest běhy.

### Výstup

`BASELINE SNAPSHOT` pro danou iteraci Blueprintu.

### Gate

Výchozí stav je reprodukovatelný a dohledatelný.

---

## FÁZE 1 – Entity Catalogue

### Cíl

Nejdříve přesně určit, co chceme stahovat. Teprve potom hledat provider.

### Kroky

1. Popsat sportovní strukturu.
2. Vyjmenovat CORE entity.
3. Vyjmenovat PEOPLE entity.
4. Vyjmenovat MATCH DETAIL entity.
5. Vyjmenovat ODDS entity.
6. Vyjmenovat MEDIA/FAN entity.
7. Označit povinné a volitelné entity.
8. Zohlednit sportovně specifické entity.

### Výstup

Schválený `SPORT ENTITY CATALOGUE`.

### Gate

Žádná důležitá entita není skrytě předpokládána.

---

## FÁZE 2 – Mapování současné MatchMatrix konfigurace

### Cíl

Zjistit, co již existuje a co je pouze plán.

### Kroky

1. `provider_sport_matrix`.
2. `provider_entity_coverage`.
3. `people_master_provider_matrix`.
4. `provider_jobs`.
5. `ingest_targets`.
6. příslušné worker skripty a staging/public objekty.
7. stav runtime testů.

### Výstup

`CURRENT MATCHMATRIX PROVIDER MAP`.

### Gate

Pro každou entitu je znám stav: VERIFIED / PARTIAL / PLANNED / BLOCKED / MISSING.

---

## FÁZE 3 – Externí provider research

### Cíl

Ověřit aktuální realitu providerů proti jejich dokumentaci a skutečné službě.

### Kroky

1. Oficiální provider dokumentace.
2. Seznam endpointů.
3. Parametry endpointů.
4. Supported sports/leagues/seasons.
5. Historická hloubka.
6. Current/live data.
7. Future horizon.
8. Players/coaches/statistics.
9. Odds a bookmaker coverage.
10. Rate limits.
11. Free/paid plány.
12. Změny API oproti interní konfiguraci.

### Pravidlo

Interní DB stav a externí současná dokumentace se nikdy neslučují bez označení zdroje tvrzení.

### Výstup

`PROVIDER REALITY AUDIT`.

### Gate

Každé tvrzení o provider capability má zdroj nebo runtime důkaz.

---

## FÁZE 4 – Historical Source Discovery

### Cíl

Najít zdroje pro historii, kterou běžné provozní API nepokrývá.

### Kroky

1. Globální federace.
2. Kontinentální federace.
3. Národní ligy/federace.
4. Oficiální soutěžní weby.
5. Oficiální klubové weby.
6. Open-data zdroje.
7. Knowledge graph zdroje.
8. Historické archivy, pokud jsou právně a technicky vhodné.
9. U každého zdroje určit nejstarší ověřený rok/sezónu.
10. Oddělit HISTORY_FAN a HISTORY_PREDICTION použitelnost.

### Výstup

`HISTORY SOURCE MAP`.

### Gate

Pro požadovanou historii je buď znám zdroj, nebo je mezera explicitně zaznamenána.

---

## FÁZE 5 – Coverage audit

### Cíl

Ověřit, že zdroj skutečně poskytuje potřebnou entitu v potřebném rozsahu.

### Kroky

1. Coverage domain.
2. Entity coverage.
3. Quality.
4. Completeness.
5. History depth.
6. Automation suitability.
7. Geografický scope.
8. Soutěžní scope.
9. Sample evidence.

### Výstup

Záznamy v `ops.source_coverage_matrix` nebo odpovídající evidenci.

### Gate

Zdroj není vybrán pouze podle marketingového popisu.

---

## FÁZE 6 – Commercial audit

### Cíl

Zjistit skutečnou ekonomiku zdroje.

### Kroky

1. pricing model,
2. free/trial/paid,
3. měsíční a roční cena,
4. request limit,
5. historický přístup,
6. rozdíly mezi tarify,
7. riziko překročení limitu,
8. ROI vzhledem k pokrytým entitám,
9. doporučený tarif.

### Výstup

`ops.source_commercial_model` / Commercial Decision.

### Gate

Je znám očekávaný náklad nebo je stav explicitně `UNKNOWN / RESEARCH_REQUIRED`.

---

## FÁZE 7 – Legal and Licensing audit

### Cíl

Ověřit, že technicky dostupný zdroj je vhodný pro zamýšlené použití.

### Kroky

1. robots.txt,
2. crawl-delay,
3. sitemap,
4. Terms & Conditions,
5. Privacy Policy,
6. API licence,
7. scraping podmínky,
8. commercial use,
9. photo licence,
10. video licence,
11. attribution požadavky,
12. výsledná úroveň rizika.

### Pravidlo

`robots PASS` není totéž jako `commercial use approved`.

### Výstup

`ops.source_legal_audit` / Legal Decision.

### Gate

Zdroj pro produkční automatizaci nesmí mít nevyřešený právní blocker.

---

## FÁZE 8 – Provider selection

### Cíl

Přiřadit každé entitě konkrétní zdrojovou strategii.

### Kroky

1. Vybrat PRIMARY.
2. Vybrat FALLBACK.
3. Určit MERGE zdroje.
4. Určit SUPPLEMENT zdroje.
5. Označit BLOCKED zdroje.
6. Stanovit časový režim použití zdroje.
7. Stanovit quality precedence.
8. Stanovit konfliktní pravidla.

### Výstup

`SPORT × ENTITY × TIME_MODE SOURCE MATRIX`.

### Gate

Každá povinná entita má jednoznačné rozhodnutí nebo explicitní otevřený blocker.

---

## FÁZE 9 – Technical design

### Cíl

Převést zdrojovou strategii do technického návrhu bez spuštění velkého harvestu.

### Kroky

1. endpoint adapter,
2. RAW model,
3. staging model,
4. canonical mapping,
5. provider identity map,
6. deduplication,
7. merge precedence,
8. job definition,
9. ingest target definition,
10. request budget,
11. retry/backoff,
12. logging,
13. metrics,
14. error quarantine,
15. rollback / safe rerun.

### Výstup

`TECHNICAL INGEST PLAN`.

### Gate

Návrh je idempotentní, auditovatelný a má jasný canonical cíl.

---

## FÁZE 10 – Smoke test

### Cíl

Ověřit zdroj na minimálním reprezentativním vzorku.

### Kroky

1. 1–3 soutěže nebo reprezentativní entity.
2. Omezený request budget.
3. RAW response capture.
4. Parsing audit.
5. Staging audit.
6. Identity mapping audit.
7. Public merge v controlled režimu.
8. Coverage comparison proti očekávání.
9. Log response_count a error_count.
10. Zaznamenat odchylky od dokumentace providera.

### Výstup

`SMOKE TEST REPORT`.

### Gate

`DATA_CONFIRMED` nebo `BLOCKED / NEEDS_FIX`.

---

## FÁZE 11 – Historical pilot

### Cíl

Ověřit skutečnou hloubku a stabilitu backfillu.

### Kroky

1. Vybrat jednu soutěž / entitu.
2. Stáhnout omezený historický rozsah.
3. Ověřit počet sezon.
4. Ověřit chybějící období.
5. Ověřit změny formátu v čase.
6. Ověřit canonical identity napříč sezónami.
7. Ověřit objem a request budget.
8. Odhadnout celý backfill.

### Výstup

`HISTORICAL PILOT REPORT`.

### Gate

Je znám reálný čas, objem, náklad a riziko plného backfillu.

---

## FÁZE 12 – User approval gate

### Cíl

Zastavit automatickou expanzi před významným harvestem.

Před schválením uživatelem se nesmí spustit full historical harvest ani široká multisport expanze.

### Schvalovací balík musí obsahovat

- provider mapu,
- entity mapu,
- history/current/future mapu,
- ceny,
- request limity,
- legal status,
- technical readiness,
- odhad objemu,
- známá rizika,
- seznam nevyřešených míst.

### Gate

`APPROVED_FOR_CONTROLLED_HARVEST`.

---

## FÁZE 13 – Controlled harvest

### Cíl

Spustit produkční harvest po dávkách, ne jedním globálním během.

### Kroky

1. TOP/pilot scope.
2. Průběžná DB kontrola.
3. Duplicate/orphan kontroly.
4. Request budget monitoring.
5. Provider health monitoring.
6. Delta kontrola před/po.
7. Teprve následně rozšíření scope.

### Pravidlo

Každá expanze musí mít možnost bezpečně zastavit běh bez poškození již uložených dat.

---

## FÁZE 14 – Canonicalization and QA

### Cíl

Z provider dat vytvořit důvěryhodná canonical data.

### Povinné kontroly

- provider identities,
- duplicated entities,
- orphan rows,
- unexpected cardinality,
- date/time normalization,
- status normalization,
- score/result conflicts,
- team/player identity conflicts,
- missing required fields,
- source provenance.

### Výstup

`CANONICAL QA REPORT`.

---

## FÁZE 15 – CURRENT/FUTURE operations

### Cíl

Po dokončení základního backfillu přejít do dlouhodobého provozu.

### Kroky

1. Definovat cadence podle entity.
2. Rozdělit maintenance, current a future joby.
3. Přibližovat cadence k event startu, kde je to užitečné.
4. Ukládat odds snapshots.
5. Finalizovat event po skončení.
6. Provádět delayed correction refresh.
7. Sledovat provider změny a deprecated endpointy.

---

## FÁZE 16 – Pravidelný source review

### Cíl

Blueprint nesmí po čase zastarat.

### Trigger revize

- změna ceny,
- změna provider dokumentace,
- změna endpointu,
- pokles coverage,
- právní změna,
- nový kvalitnější provider,
- nové potřeby produktu,
- nový sport nebo soutěž.

### Výstup

Nová verze stejného dokumentu a aktualizovaný source registry.

---

# 11. Acceptance gates

Produční zdroj musí projít následujícími gate podle svého typu:

| Gate | Otázka | Povinné pro API | Povinné pro web/federaci |
|---|---|---:|---:|
| G1 Entity | Víme přesně, co stahujeme? | Ano | Ano |
| G2 Coverage | Vrací zdroj skutečná data? | Ano | Ano |
| G3 History | Známe reálnou hloubku? | Dle účelu | Dle účelu |
| G4 Technical | Je ingest bezpečný a auditovatelný? | Ano | Ano |
| G5 Commercial | Známe cenu a limity? | Ano | Ano / N/A |
| G6 Legal | Je použití přijatelné? | Ano | Ano |
| G7 Canonical | Umíme data bezpečně spojit? | Ano | Ano |
| G8 Smoke | Prošel reálný test? | Ano | Ano |
| G9 User approval | Je scope schválen? | Ano | Ano |
| G10 Controlled harvest | Prošel pilot? | Ano | Ano |

Nesplněný gate znamená `REVIEW_REQUIRED` nebo `BLOCKED`, nikoliv automatické pokračování.

---

# 12. Pořadí realizace sportů

## 12.1 Pilot

První metodický pilot je **HB – Handball**, protože interní databáze již obsahuje rozpracované:

- EHF source registry,
- coverage audit,
- commercial model,
- legal audit,
- api_handball core konfiguraci.

Pilot má ověřit metodiku dokumentu, nikoliv pouze házenou samotnou.

## 12.2 Následující sporty

Po dokončení HB se stejný postup zopakuje pro všech 14 aktivních sportů.

Doporučené pořadí bude stanoveno až podle kombinace:

- současného technického stavu,
- dostupnosti zdrojů,
- produktové priority,
- kvality historie,
- nákladů,
- potřeb prediction layeru.

Dokument záměrně neurčuje pevné pořadí ostatních sportů dříve, než bude HB pilot dokončen.

---

# 13. Handball – pilotní struktura

Tato kapitola bude první plně vyplněnou sportovní implementací metodiky.

## 13.1 CORE

- European competitions,
- national leagues,
- teams,
- fixtures/results,
- standings,
- seasons.

## 13.2 PEOPLE

- players,
- coaches,
- staff,
- profiles,
- player history,
- statistics,
- photos.

## 13.3 MATCH DETAIL

- lineups,
- incidents,
- match/player stats,
- injuries/absences podle skutečné dostupnosti.

## 13.4 ODDS

- pre-match,
- live pokud ekonomicky a právně vhodné,
- bookmaker/market coverage,
- odds snapshots.

## 13.5 HISTORY_FAN

EHF je již interně evidovaný jako silný kandidát pro evropské soutěže, hráče, trenéry a historii, ale národní ligy mají pouze omezené pokrytí. Proto musí být doplněn samostatný discovery proces pro národní ligy.

## 13.6 HISTORY_PREDICTION

Kombinace provozního API a historických zdrojů bude vyhodnocena podle posledních přibližně 10 let, kvality fixtures/results/statistics a možností canonical merge.

## 13.7 CURRENT/FUTURE

`api_handball` je nakonfigurován pro leagues/teams/fixtures. People, odds a další vrstvy musí být posouzeny samostatně podle skutečné runtime reality.

## 13.8 Legal

EHF pilot obsahuje PASS pro robots/sitemap a crawl-delay 5 s, ale Terms, scraping, fotografie, video a commercial use vyžadují dokončení review před produkční automatizací.

---

# 14. Databázová realizace Blueprintu

## 14.1 Co již existuje

Současná OPS databáze již obsahuje základní registry potřebné pro Blueprint.

## 14.2 Co musí být prověřeno po dokončení pilotu

Po HB pilotu bude rozhodnuto, zda stávající tabulky dostačují, nebo zda je vhodné doplnit například explicitní evidenci:

- `time_mode`,
- history purpose,
- verified history from/to,
- future horizon,
- refresh cadence,
- source role per entity/time mode,
- approval gate status,
- evidence reference,
- retention policy.

Nové DB sloupce nebo tabulky se nevytvářejí před dokončením logického návrhu Blueprintu.

## 14.3 Zdroj pravdy

Blueprint a OPS registry musí být vzájemně synchronizované. Dokument popisuje rozhodnutí a jejich důvody, databáze drží strukturovaný provozní stav.

---

# 15. Pravidla pro externí research

1. Preferovat oficiální dokumentaci providera.
2. U federací a oficiálních webů preferovat primární zdroj.
3. Ceny a limity vždy ověřovat jako časově citlivé údaje.
4. Nezaměňovat existenci endpointu za skutečnou coverage.
5. U každého webového zdroje oddělit technickou dostupnost a licenční oprávnění.
6. Fotografie a video auditovat samostatně od textových/statistických dat.
7. U komunitních a open-data zdrojů ověřit původ a licenci.
8. Pokud se externí dokumentace rozchází s runtime testem, zaznamenat rozdíl a jako provozní pravdu použít ověřenou realitu.
9. Datum ověření je povinná součást každého časově citlivého rozhodnutí.

---

# 16. Pravidla pro canonical merge

Každý nový provider musí mít před širším importem definováno:

- provider external ID,
- canonical entity target,
- matching keys,
- normalizaci názvů,
- časové tolerance,
- pravidla konfliktu výsledků,
- source precedence,
- audit provenance,
- duplicate prevention,
- orphan detection.

Historická data nesmějí vytvářet paralelní identity pouze proto, že používají starší nebo odlišné provider ID.

---

# 17. Pravidla pro historii

## 17.1 Historická hloubka

Neexistuje univerzální pevný rok, od kterého se musí stahovat všechny sporty.

HISTORY_FAN se stahuje od nejstaršího období, které je:

- spolehlivě dostupné,
- technicky zpracovatelné,
- právně přijatelné,
- ekonomicky rozumné.

## 17.2 Prediction window

Pro modelovou vrstvu je výchozí maximum přibližně 10 let, ale konkrétní feature/model může použít kratší okno.

## 17.3 Oddělení archivní a provozní cadence

Historický backfill je dávkový proces. CURRENT/FUTURE je průběžný provoz. Tyto dva režimy nesmí být řízeny jedním společným parametrem `days_back`.

---

# 18. Provozní monitoring

Po schválení zdroje se sleduje minimálně:

- request count,
- success/error rate,
- response_count,
- latency,
- empty responses,
- schema drift,
- provider availability,
- coverage drift,
- rate-limit pressure,
- DB growth,
- canonical attach rate,
- duplicate/orphan rate.

Významný propad některé metriky automaticky vyvolává provider/source review.

---

# 19. Definition of Done – jeden sport

Sport je z pohledu Data Acquisition Blueprintu připraven pro řízený produkční harvest, pokud:

- má schválený Entity Catalogue,
- každá povinná entita má zdrojovou roli,
- HISTORY_FAN má zdroj nebo explicitně zdokumentovanou mezeru,
- HISTORY_PREDICTION má definované období a zdroj,
- CURRENT má provider a refresh model,
- FUTURE má horizon a refresh model,
- primary/fallback role jsou jasné,
- endpointy/URL jsou ověřené,
- ceny a limity jsou ověřené,
- právní stav je přijatelný,
- worker/staging/public cesta je navržena,
- canonical merge je definován,
- smoke test prošel,
- historical pilot prošel, pokud je relevantní,
- uživatel schválil production scope.

---

# 20. Definition of Done – celý program

Data Acquisition Blueprint V1 je připraven pro přechod do rozsáhlého harvestu, pokud všech 14 aktivních sportů má:

1. Entity Catalogue.
2. HISTORY_FAN mapu.
3. HISTORY_PREDICTION mapu.
4. CURRENT mapu.
5. FUTURE mapu.
6. PEOPLE mapu.
7. ODDS mapu.
8. MEDIA/FAN mapu.
9. Primary/fallback rozhodnutí.
10. Technical readiness stav.
11. Commercial stav.
12. Legal stav.
13. Canonical merge plán.
14. Otevřené mezery jasně označené.
15. Uživatelské schválení.

Teprve poté je možné plánovat celkový multisport historical harvest.

---

# 21. Dokumentační výstupy během realizace

Tento dokument zůstává centrálním řídicím dokumentem. Detailní podklady mohou vznikat jako:

- sportovní provider audit,
- source coverage report,
- commercial audit,
- legal audit,
- endpoint reality audit,
- smoke test report,
- historical pilot report,
- canonical QA report,
- harvest run report.

Každý detailní dokument nebo report musí odkazovat zpět na tento Blueprint nebo na příslušnou sportovní kapitolu.

---

# 22. Otevřené otázky

Na začátku V1 zůstávají otevřené zejména:

- definitivní pořadí sportů po HB pilotu,
- konečný model ukládání časových režimů do OPS DB,
- přesná refresh cadence podle sportu/entity,
- konečná role premium odds providerů,
- source discovery pro národní ligy a hlubokou historii mimo stávající API,
- právní model pro fotografie a video,
- dlouhodobá retention policy pro odds/live snapshots,
- přesný model provenance pro media/fan data.

Otevřená otázka není chyba dokumentu. Musí však být explicitní a mít navržený další krok.

---

# 23. Bezprostřední další krok

1. Dokončit **HB – Handball** jako pilot podle tohoto dokumentu.
2. Zpracovat Handball Entity Catalogue.
3. Porovnat interní `api_handball` konfiguraci s aktuální provider dokumentací.
4. Dokončit EHF legal review.
5. Zmapovat IHF.
6. Zahájit discovery národních handball lig.
7. Sestavit první kompletní `HB × ENTITY × TIME_MODE × SOURCE MATRIX`.
8. Teprve poté rozhodnout o smoke testech a technických změnách.

**V této fázi se nespouští rozsáhlý harvest.**

---

# 24. Závěr dokumentu

MatchMatrix Data Acquisition Blueprint zavádí jednotný systém, který odděluje pouhou dostupnost dat od skutečné připravenosti datový zdroj používat.

Každý sport a každá entita budou před produkčním harvestem posouzeny z hlediska historie, current/future provozu, technické integrace, ceny, licence a canonicalizace.

Nejdůležitějším principem dokumentu je, že MatchMatrix nebude stahovat data pouze proto, že je umí získat. Data budou získávána až tehdy, když bude jasné:

- proč je potřebujeme,
- odkud je získáme,
- jak budou ověřena,
- kam budou uložena,
- jak budou spojena s ostatními zdroji,
- kolik bude jejich získávání stát,
- zda je jejich použití přijatelné,
- jak budou dlouhodobě aktualizována.

Tím se z harvestu stává řízený datový program místo souboru izolovaných ingest skriptů.

---

# 25. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-09-24 | DRAFT | Založen řídicí Data Acquisition Blueprint. Definována struktura SPORT × ENTITY × HISTORY/CURRENT/FUTURE × SOURCE, acceptance gates a kompletní end-to-end postup realizace. |

---

# AI CONTEXT

**Role dokumentu:** Centrální řídicí dokument pro návrh a realizaci získávání dat MatchMatrix před rozsáhlým multisport harvestem.

**Primární princip:** Nejdříve úplný, ověřený a schválený provider/source Blueprint; teprve potom rozsáhlý harvest.

**Časový model:** HISTORY_FAN, HISTORY_PREDICTION, CURRENT, FUTURE.

**Pilot:** HB – Handball.

**Interní zdroje pravdy:** `public.sports`, `ops.provider_sport_matrix`, `ops.provider_entity_coverage`, `ops.people_master_provider_matrix`, `ops.provider_jobs`, `ops.ingest_targets`, `ops.global_source_registry`, `ops.source_coverage_matrix`, `ops.source_commercial_model`, `ops.source_legal_audit`.

**Důležité omezení:** Stav `configured`, `enabled`, `supports_*`, `planned` nebo existence jobu neznamená automaticky production approval.

**Další krok:** Vyplnit pilotní Handball source matrix bez spuštění rozsáhlého harvestu.

---

# PROJECT SNAPSHOT

| Oblast | Stav k 2026-09-24 |
|---|---|
| Aktivní sporty | 14 |
| Provider baseline | načten |
| Entity coverage baseline | načten |
| People provider baseline | načten |
| Provider jobs baseline | načten |
| Ingest targets baseline | 4 428 řádků |
| Global source registry | 6 zdrojů |
| Coverage pilot | HB / EHF |
| Commercial pilot | HB |
| Legal pilot | HB / EHF |
| Rozsáhlý harvest | BLOKOVÁN do schválení Blueprintu |
| První realizační sport | HB – Handball |

---

# CURRENT STATUS

**DRAFT – BLUEPRINT FRAMEWORK CREATED**

Dokument je připraven k odbornému review, doplnění Handball pilotu a následnému průchodu řízeným dokumentačním workflow MatchMatrix.
