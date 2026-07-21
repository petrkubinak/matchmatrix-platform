# MM-PRV-007

# REFERENČNÍ KATALOG PROVIDERŮ, TARIFŮ A POKRYTÍ

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-007 |
| Document ID | MM-PRV-007 |
| Název dokumentu | Referenční katalog providerů, tarifů a pokrytí |
| Typ dokumentu | PROVIDER_REFERENCE_CATALOG |
| Dokumentační oblast | 05_PROVIDERS |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | NOVÝ DOKUMENT |
| Datum | 2026-07-21 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Cílové umístění | `docs/05_PROVIDERS/` |
| Nahrazuje | — |
| Navazuje na | MM-PRV-001, MM-PRV-002, MM-PRV-003, MM-PRV-004, MM-PRV-005, MM-PRV-006 |
| Související dokumenty | MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DB-001, MM-DB-002, MM-DB-003, MM-REF-001, MM-REF-002 |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-005, MM-STD-006, MM-STD-007, MM-STD-008, MM-STD-009 |
| Čas platnosti katalogového snapshotu | 2026-07-21 |
| Hlavní zdroj aktuální runtime pravdy | Databázové OPS objekty, runtime audity, planner, job runs a provider mapy |
| Bezpečnostní klasifikace | Bez API klíčů, tokenů, hesel a tajných smluvních údajů |

---

# 1. Úvod

Referenční katalog providerů, tarifů a pokrytí převádí obecná pravidla providerového ekosystému MatchMatrix do řízeného přehledu konkrétních zdrojů.

Dokument odpovídá na praktické otázky:

- který provider je v projektu evidován,
- pod jakým interním kódem je používán,
- pro které sporty, vrstvy a entity je určen,
- zda plní roli primárního, záložního nebo specializovaného zdroje,
- jaký je doložený tarifní nebo smluvní stav,
- jaká omezení jsou známá,
- jaký je technický, datový, právní a provozní stav,
- kdy a z jakého důkazu byl záznam naposledy ověřen,
- co musí být znovu prověřeno před produkčním nebo placeným použitím.

Katalog není náhradou runtime auditů ani smluvní dokumentace. Je řízeným lidsky čitelným snapshotem, který propojuje technickou realitu, obchodní podmínky, právní omezení a plán dalšího ověření.

## 1.1 Proč dokument vzniká

Dokument `MM-PRV-001` výslovně odděluje stabilní architekturu od měněného seznamu konkrétních providerů. Dokumenty `MM-PRV-002` až `MM-PRV-006` následně definují životní cyklus, routing, health, integraci a právní řízení.

Bez samostatného katalogu by se konkrétní údaje rozpadaly mezi:

- pracovní zápisy,
- OPS tabulky,
- skripty,
- provider mapy,
- panelové pohledy,
- smlouvy,
- cenové nabídky,
- poznámky k tarifům,
- historické audity.

Výsledkem by byla obtížná dohledatelnost a riziko, že se při rozhodování použije zastaralá informace.

## 1.2 Rozsah dokumentu

Katalog zahrnuje:

- externí datová API,
- interní providerové kódy a adaptéry,
- specializované zdroje pro PEOPLE, MEDIA a ODDS,
- oficiální weby a syndikační kanály,
- blokované nebo chybějící providerové oblasti,
- známé tarifní a licenční stavy,
- známé sportovní a entitní pokrytí,
- stav implementace a runtime ověření.

Dokument neobsahuje:

- API klíče,
- přístupové tokeny,
- hesla,
- celé smlouvy,
- tajné obchodní podmínky,
- platební údaje,
- neověřené ceny vydávané za aktuální skutečnost.

## 1.3 Určení dokumentu

Dokument je určen pro:

- vlastníka projektu,
- správce providerů,
- vývoj integračních workerů,
- správu datových vrstev,
- řízení harvestu,
- provozní audit,
- právní a licenční kontrolu,
- budoucí Provider Matrix panel,
- budoucí automatizované rozhodování o routingu.

## 1.4 Pravidlo interpretace

Každý údaj musí být čten společně s:

- datem posledního ověření,
- typem důkazu,
- stupněm jistoty,
- stavem záznamu,
- případným požadavkem na revalidaci.

Údaj označený `REVALIDATE`, `REVIEW`, `UNKNOWN` nebo `PARTIAL` nesmí být automaticky interpretován jako plně schválený nebo produkčně spolehlivý.

## 1.5 Závěr kapitoly

Kapitola vymezila účel, rozsah a bezpečnostní hranice katalogu. Přínosem pro MatchMatrix je vytvoření jednoho řízeného místa pro konkrétní providerová fakta bez záměny s runtime nebo smluvní pravdou. Na tuto kapitolu navazuje kapitola 2, která stanovuje autoritu katalogu a hierarchii zdrojů pravdy.

---

# 2. Autorita katalogu a zdroje pravdy

Katalog je referenční dokument, nikoli jediný technický zdroj pravdy. Jeho autorita spočívá v řízeném shrnutí a propojení důkazů.

## 2.1 Hierarchie zdrojů pravdy

Při rozporu se používá následující pořadí:

1. platná smlouva, licence nebo oficiální podmínky providera pro právní a tarifní otázky,
2. runtime databázové audity pro skutečně dosažené technické a datové pokrytí,
3. provider mapy a kanonické tabulky pro skutečně uložené identity a data,
4. planner, job runs a execution trace pro skutečně provedené běhy,
5. aktivní konfigurace a worker kód pro implementovaný způsob přístupu,
6. tento katalog jako konsolidovaný referenční snapshot,
7. historické zápisy jako podpůrný důkaz vývoje.

Textový údaj v katalogu nesmí přebít novější runtime důkaz.

## 2.2 Runtime zdroje

Za hlavní provozní zdroje se považují zejména:

```text
ops.runtime_entity_audit
ops.sport_completion_audit
ops.ingest_targets
ops.ingest_planner
ops.provider_entity_coverage
ops.job_runs
provider map tabulky
RAW a staging auditní objekty
post-importní kontroly
```

Konkrétní názvy se mohou vyvíjet. Záznam katalogu proto používá logickou roli zdroje, nikoli pouze jeden pevný objekt.

## 2.3 Dokumentační zdroje

Katalog navazuje zejména na:

| Dokument | Autorita |
|---|---|
| MM-PRV-001 | Providerový ekosystém a oddělení stabilní architektury od měněného katalogu. |
| MM-PRV-002 | Životní cyklus, schvalování a stavové přechody. |
| MM-PRV-003 | Routing, role providerů a fallback. |
| MM-PRV-004 | Health dimenze a provozní zásahy. |
| MM-PRV-005 | Povinný integrační tok do datových vrstev. |
| MM-PRV-006 | Právní, licenční a smluvní omezení. |
| MM-DOC-200 | Provider Governance a Source Governance. |
| MM-DOC-300 | Víceproviderová architektura a datový tok. |
| MM-DB-001 až MM-DB-003 | Databázové principy, schémata a datový slovník. |

## 2.4 Rozdělení odpovědnosti

| Oblast | Primární autorita |
|---|---|
| Identita providera | řízený provider registry záznam |
| Skutečné pokrytí | runtime audit a data v DB |
| Tarif | datovaný tarifní důkaz nebo smlouva |
| Právní použití | právní profil podle MM-PRV-006 |
| Routing | schválená routing pravidla |
| Health | Provider Health Monitoring |
| Implementace | aktivní worker a integrační audit |
| Dokumentační soulad | A17, A23, A24 a A7 |

## 2.5 Závěr kapitoly

Kapitola stanovila, že katalog konsoliduje důkazy, ale nepřebíjí smlouvu ani runtime databázovou realitu. Přínosem je jednoznačné rozhodování při rozporu různých zdrojů. Na tuto kapitolu navazuje kapitola 3, která definuje jednotnou strukturu každého katalogového záznamu.

---

# 3. Datový model katalogového záznamu

Každý provider musí být evidován ve stejné struktuře, aby bylo možné záznamy porovnávat, filtrovat a později převést do databáze.

## 3.1 Identifikační pole

| Pole | Význam |
|---|---|
| `provider_code` | Neměnný interní kód používaný v MatchMatrix. |
| `display_name` | Lidsky čitelný název zdroje. |
| `provider_family` | Rodina nebo obchodní skupina zdroje. |
| `source_type` | API, FILE, RSS, OFFICIAL_SITE, SCRAPER, INTERNAL nebo jiný řízený typ. |
| `commercial_identity_status` | Stav ověření obchodního názvu a provozovatele. |
| `aliases` | Historické nebo technické aliasy. |
| `record_owner` | Odpovědná projektová role. |

Interní kód nesmí být měněn pouze kvůli marketingové změně názvu providera.

## 3.2 Tarifní a smluvní pole

| Pole | Význam |
|---|---|
| `tariff_status` | FREE, TRIAL, PAID, CONTRACT, PUBLIC, REVALIDATE nebo UNKNOWN. |
| `tariff_name` | Název plánu, pouze pokud je doložen. |
| `billing_cycle` | Měsíční, roční, jednorázový nebo jiný režim. |
| `request_limit` | Doložený limit požadavků a jeho časová jednotka. |
| `concurrency_limit` | Povolená souběžnost, je-li známa. |
| `overage_rule` | Chování při překročení limitu. |
| `renewal_date` | Datum obnovy nebo expirace. |
| `tariff_verified_at` | Datum posledního ověření. |
| `tariff_evidence_ref` | Odkaz na neveřejný důkaz bez vložení tajných údajů. |

Cena se eviduje pouze s měnou, obdobím, datem a zdrojem důkazu. Nedoložená cena se nezapisuje.

## 3.3 Pole pokrytí

Pokrytí se nesmí vyjádřit pouze textem „provider podporuje fotbal“. Minimální granularita je:

```text
provider
× sport
× vrstva
× entita
× soutěž nebo geografický rozsah
× sezóna nebo historické období
× live / pre-match / post-match režim
× stupeň úplnosti
```

Povinná pole:

| Pole | Význam |
|---|---|
| `sport_code` | Interní kód sportu. |
| `layer_code` | CORE, PEOPLE, MEDIA, ODDS nebo jiná řízená vrstva. |
| `entity_type` | leagues, teams, fixtures, players, odds, articles a další entity. |
| `coverage_status` | CONFIRMED, PARTIAL, ASSUMED, UNKNOWN nebo NOT_SUPPORTED. |
| `time_scope` | Historie, aktuální sezóna, live nebo kombinace. |
| `geography_scope` | Globální, regionální, soutěžní nebo neurčené pokrytí. |
| `evidence_count` | Počet doložených objektů, pokud je relevantní. |
| `coverage_verified_at` | Datum posledního runtime ověření. |

## 3.4 Technická pole

| Pole | Význam |
|---|---|
| `integration_status` | NOT_STARTED, PLANNED, PARTIAL, OPERATIONAL, VERIFIED nebo BLOCKED. |
| `worker_group` | Skupina workerů nebo integrační subsystém. |
| `raw_storage_status` | Stav ukládání RAW payloadů. |
| `parser_status` | Stav parseru. |
| `staging_status` | Stav normalizovaného stagingu. |
| `provider_map_status` | Stav identity mapování. |
| `canonical_merge_status` | Stav zápisu do kanonické vrstvy. |
| `last_successful_run_at` | Poslední úspěšný běh. |
| `last_runtime_evidence_ref` | Odkaz na auditní běh nebo report. |

## 3.5 Kvalitativní a právní pole

| Pole | Význam |
|---|---|
| `health_status` | Aktuální souhrnný health stav. |
| `data_quality_status` | Stav úplnosti, správnosti a konzistence. |
| `legal_status` | APPROVED, CONDITIONAL, REVIEW, HOLD, EXPIRED nebo UNKNOWN. |
| `publication_rights` | Povolený rozsah veřejného zobrazení. |
| `storage_rights` | Povolený rozsah ukládání a archivace. |
| `attribution_required` | Požadavek na atribuci. |
| `media_rights_status` | Samostatný stav pro fotografie, loga, články a video. |
| `known_restrictions` | Stručný souhrn omezení. |

## 3.6 Důkazní a časová pole

Každý významný údaj musí obsahovat:

- datum ověření,
- zdroj ověření,
- odpovědnou roli,
- stupeň jistoty,
- datum příští kontroly,
- případný důvod zastarání.

Záznam bez data ověření se považuje za historický nebo neúplný.

## 3.7 Minimální katalogový objekt

```text
provider_code
display_name
source_type
lifecycle_status
provider_role
tariff_status
legal_status
integration_status
health_status
sports_and_entities
last_verified_at
evidence_ref
next_review_at
notes
```

## 3.8 Závěr kapitoly

Kapitola definovala jednotný datový model providerového záznamu od identity přes tarif a pokrytí až po důkazy a právní stav. Přínosem je možnost porovnávat zdroje bez improvizovaných poznámek. Na tuto kapitolu navazuje kapitola 4, která sjednocuje stavové kódy používané v katalogu.

---

# 4. Stavové kódy a klasifikace

Stavové kódy musí být jednoznačné a nesmí míchat obchodní, technický, datový a právní význam.

## 4.1 Životní cyklus providera

| Stav | Význam |
|---|---|
| `DISCOVERED` | Zdroj byl nalezen, ale nebyl ověřen. |
| `REVIEW` | Probíhá technické, datové, tarifní nebo právní posouzení. |
| `PILOT` | Probíhá omezený test bez plného produkčního závazku. |
| `ACTIVE` | Zdroj je schválen pro přesně vymezený rozsah. |
| `HOLD` | Použití je dočasně blokováno. |
| `RETIRED` | Zdroj byl řízeně vyřazen. |

## 4.2 Role providera

| Role | Význam |
|---|---|
| `PRIMARY` | Preferovaný zdroj pro konkrétní sport, vrstvu a entitu. |
| `FALLBACK` | Schválený záložní zdroj. |
| `SPECIALIZED` | Zdroj určený pro vybranou entitu nebo vrstvu. |
| `SUPPLEMENTARY` | Doplňkový zdroj pro obohacení nebo kontrolu. |
| `RESEARCH` | Kandidát bez produkčního routingu. |
| `BLOCKED` | Zdroj nesmí být použit. |

Role se vždy vztahuje ke konkrétnímu rozsahu. Provider může být například `PRIMARY` pro PEOPLE a současně `SUPPLEMENTARY` pro CORE.

## 4.3 Stav integrace

| Stav | Význam |
|---|---|
| `NOT_STARTED` | Integrace neexistuje. |
| `PLANNED` | Je schválena nebo popsána, ale nebyla implementována. |
| `PARTIAL` | Funguje pouze část povinného toku. |
| `OPERATIONAL` | Tok běží, ale není plně potvrzen pro celý deklarovaný rozsah. |
| `VERIFIED` | Povinný tok i post-importní kontroly byly doloženy. |
| `BLOCKED` | Integrace je technicky nebo řídicím pravidlem zablokována. |

## 4.4 Stav pokrytí

| Stav | Význam |
|---|---|
| `CONFIRMED` | Pokrytí bylo doloženo daty nebo runtime auditem. |
| `PARTIAL` | Pokrytí existuje, ale je omezené nebo nepravidelné. |
| `ASSUMED` | Pokrytí se předpokládá podle nabídky, nikoli podle projektu. |
| `UNKNOWN` | Stav nebyl ověřen. |
| `NOT_SUPPORTED` | Provider daný rozsah nepodporuje nebo jej projekt nemůže použít. |

## 4.5 Tarifní stav

| Stav | Význam |
|---|---|
| `FREE` | Doložený bezplatný plán. |
| `TRIAL` | Časově nebo funkčně omezený testovací plán. |
| `PAID` | Standardní placený plán. |
| `CONTRACT` | Individuální smluvní režim. |
| `PUBLIC` | Zdroj bez klasického API tarifu, například veřejný RSS kanál. |
| `NOT_APPLICABLE` | Tarif se na interní adaptér nebo nekomerční technický objekt nevztahuje. |
| `REVALIDATE` | Poslední známý stav je historický a musí být znovu ověřen. |
| `UNKNOWN` | Tarifní stav není doložen. |

## 4.6 Právní stav

| Stav | Význam |
|---|---|
| `APPROVED` | Rozsah použití je doložen a schválen. |
| `CONDITIONAL` | Použití je povoleno pouze s omezeními. |
| `REVIEW` | Probíhá posouzení nebo chybí část důkazů. |
| `HOLD` | Použití je z právních důvodů blokováno. |
| `EXPIRED` | Oprávnění nebo smlouva skončily. |
| `UNKNOWN` | Právní profil nebyl vytvořen nebo ověřen. |

## 4.7 Pravidlo nejpřísnějšího stavu

Při rozhodování se uplatní nejpřísnější relevantní stav.

Příklady:

- `ACTIVE` + `legal_status=HOLD` znamená zákaz použití,
- `integration_status=VERIFIED` + `tariff_status=EXPIRED` znamená zákaz dalšího pullu,
- `coverage_status=PARTIAL` neumožňuje deklarovat plné pokrytí,
- `PRIMARY` bez platného health stavu nesmí být automaticky routován.

## 4.8 Závěr kapitoly

Kapitola oddělila životní cyklus, roli, integraci, pokrytí, tarif a právní stav. Přínosem je odstranění nejasných souhrnných označení typu „funguje“. Na tuto kapitolu navazuje kapitola 5, která podrobně stanovuje evidenci tarifů, limitů a smluvních podmínek.

---

# 5. Tarifní, limitní a smluvní evidence

Tarif je provozní závislost. Změna ceny, limitu nebo rozsahu může ovlivnit celý harvest plán.

## 5.1 Povinný rozsah evidence

U každého placeného, bezplatného nebo testovacího plánu se eviduje:

- název plánu,
- měna,
- cena a fakturační období, pokud jsou doloženy,
- limit požadavků,
- limit souběžných požadavků,
- limit přenesených dat,
- podporované endpointy nebo produktové balíčky,
- retenční nebo exportní omezení,
- pravidla překročení limitu,
- datum aktivace,
- datum obnovy nebo expirace,
- automatické prodloužení,
- způsob výpovědi,
- poslední datum ověření,
- neveřejný odkaz na smluvní důkaz.

## 5.2 Zakázané údaje

Do katalogu se nesmí zapsat:

- celé API klíče,
- celé tokeny,
- hesla,
- čísla platebních karet,
- bankovní přístupové údaje,
- tajné smluvní přílohy,
- neveřejné osobní údaje obchodních kontaktů,
- obsah, jehož vložení by porušilo smlouvu.

Místo tajného údaje se používá pouze bezpečný referenční identifikátor.

## 5.3 Evidence limitů

Limit se zapisuje v normalizované podobě:

```text
limit_value
limit_unit
limit_period
endpoint_scope
burst_limit
concurrency_limit
reset_rule
```

Formulace „má dost requestů“ není přípustná.

## 5.4 Výpočet provozní kapacity

Provozní plán musí rozlišovat:

- teoretický limit tarifu,
- rezervu pro retry,
- rezervu pro ruční diagnostiku,
- požadavky spotřebované neúspěšnými odpověďmi,
- endpointy s rozdílnou cenou,
- denní a měsíční maximum,
- špičkový live režim,
- obnovu historických dat.

Doporučená základní rezerva nesmí být nahrazena pevným procentem bez měření konkrétního providera.

## 5.5 Tarifní revalidace

Tarifní profil se kontroluje:

- před aktivací placeného plánu,
- před automatickým prodloužením,
- při změně ceníku,
- při změně limitů,
- při změně rozsahu endpointů,
- při nárůstu chyb souvisejících s limitem,
- před rozšířením na nový sport nebo vrstvu.

## 5.6 Stav v první verzi katalogu

První verze katalogu nezapisuje žádnou nedoloženou aktuální cenu.

Historické informace o bezplatném plánu API-Sports jsou vedeny jako poslední známý stav s povinnou revalidací. U ostatních providerů je tarifní stav označen podle dostupného projektového důkazu, nikoli odhadu.

## 5.7 Závěr kapitoly

Kapitola stanovila, jak evidovat tarify, limity, obnovy a smluvní důkazy bez zveřejnění tajných údajů. Přínosem je možnost plánovat harvest podle skutečné kapacity a včas zachytit expiraci. Na tuto kapitolu navazuje kapitola 6, která definuje přesný model sportovního a datového pokrytí.

---

# 6. Model sportovního a datového pokrytí

Pokrytí je vícerozměrná vlastnost. Jeden provider nemusí být nejlepší pro všechny entity stejného sportu.

## 6.1 Vrstvy pokrytí

| Vrstva | Typický obsah |
|---|---|
| `CORE` | sporty, soutěže, sezóny, týmy, zápasy, výsledky, tabulky |
| `PEOPLE` | hráči, trenéři, soupisky, profily, kariéra, statistiky osob |
| `MEDIA` | články, RSS, oficiální zprávy, fotografie, loga a další média |
| `ODDS` | kurzy, bookmakeři, trhy, časové snapshoty |
| `RATINGS` | vstupy pro ratingy a odvozené metriky |
| `PREDICTIONS` | predikční vstupy nebo externí predikce |
| `REFERENCE` | aliasy, klasifikace, mapovací a referenční data |

## 6.2 Entity

Minimální řízený seznam zahrnuje:

```text
sports
countries
leagues
seasons
teams
venues
fixtures
results
standings
events
lineups
team_statistics
players
coaches
rosters
player_statistics
player_match_statistics
odds
bookmakers
markets
articles
images
logos
videos
```

Nová entita musí být přidána do řízeného slovníku, nikoli pouze do poznámky jednoho providera.

## 6.3 Časové pokrytí

Rozlišuje se:

- historické pokrytí,
- aktuální sezóna,
- budoucí program,
- pre-match data,
- live data,
- post-match data,
- dlouhodobá retence.

Deklarace „historie“ musí obsahovat konkrétní ověřený rozsah nebo stav `UNKNOWN`.

## 6.4 Geografické a soutěžní pokrytí

Provider může mít:

- globální pokrytí,
- omezení na vybrané země,
- omezení na vybrané soutěže,
- rozdílnou hloubku podle ligy,
- rozdílnou kvalitu u nižších soutěží,
- rozdílné licenční podmínky podle území.

Proto se pokrytí ověřuje na reprezentativním vzorku, nikoli pouze na jedné hlavní lize.

## 6.5 Stupeň úplnosti

Pro každou entitu se sleduje:

- dostupnost,
- počet očekávaných a získaných objektů,
- podíl prázdných odpovědí,
- podíl povinných polí,
- mapovatelnost identit,
- čerstvost,
- duplicity,
- konflikty,
- stabilita schématu.

HTTP 200 není důkazem datového pokrytí.

## 6.6 Důkaz pokrytí

Přijatelné důkazy:

- runtime audit,
- počet uložených RAW payloadů,
- počet staging objektů,
- počet provider map,
- počet kanonicky sloučených objektů,
- post-importní porovnání,
- opakovaný úspěšný běh,
- datovaný ruční test endpointu.

Marketingová stránka providera je pouze předběžný důkaz nabídky, nikoli důkaz skutečného pokrytí v MatchMatrix.

## 6.7 Závěr kapitoly

Kapitola rozložila pokrytí podle sportu, vrstvy, entity, času, geografie a úplnosti. Přínosem je přesnější volba „best source per entity“ a menší riziko přecenění providera. Na tuto kapitolu navazuje kapitola 7, která stanovuje aktualizaci katalogu a práci s důkazy.

---

# 7. Aktualizace katalogu a práce s důkazy

Katalog je živý dokument. Jeho změny však musí být řízené a auditovatelné.

## 7.1 Události vyvolávající změnu

Záznam se aktualizuje při:

- přidání nového providera,
- změně interního kódu nebo aliasu,
- aktivaci nebo ukončení tarifu,
- změně ceny nebo limitu,
- změně smluvních podmínek,
- potvrzení nového sportu nebo entity,
- ztrátě pokrytí,
- změně role PRIMARY nebo FALLBACK,
- změně životního cyklu,
- významném health incidentu,
- právním HOLD,
- vyřazení integrace,
- změně oficiálního názvu nebo provozovatele.

## 7.2 Stáří důkazu

Doporučené provozní kategorie:

| Stáří | Stav |
|---|---|
| do 30 dnů | čerstvý provozní důkaz |
| 31–90 dnů | použitelný s kontrolou změn |
| 91–180 dnů | vyžaduje revalidaci před významným rozhodnutím |
| více než 180 dnů | historický důkaz |
| bez data | neověřený údaj |

Pro smlouvy a právní podmínky rozhoduje jejich platnost, nikoli pouze stáří.

## 7.3 Minimální změnový záznam

Každá změna musí uvést:

- co se změnilo,
- proč se to změnilo,
- zdroj důkazu,
- datum účinnosti,
- dopad na routing,
- dopad na harvest,
- dopad na právní profil,
- odpovědnou roli,
- další termín kontroly.

## 7.4 Schvalování změn

Automatický proces smí navrhnout změnu, ale nesmí sám:

- aktivovat placený tarif,
- schválit právní použití,
- změnit strategického PRIMARY providera,
- zrušit kritický fallback,
- vyřadit zdroj s nevyřešenými závislostmi.

## 7.5 Verzování katalogu

První schválené vydání bude verze `1.0`.

Menší změny jednotlivých záznamů mohou zvyšovat vedlejší verzi. Významná změna datového modelu, stavových kódů nebo autority katalogu vyžaduje hlavní verzi.

## 7.6 Závěr kapitoly

Kapitola stanovila události, důkazy, stáří informací a schvalování změn katalogu. Přínosem je ochrana před tichým zastaráváním údajů. Na tuto kapitolu navazuje kapitola 8, která obsahuje souhrnný katalog aktuálně evidovaných providerů a zdrojových typů.

---

# 8. Souhrnný katalog providerů a zdrojů

Následující tabulka představuje první řízený snapshot. Neznámý nebo historický údaj je označen stavem, nikoli doplněn odhadem.

## 8.1 Hlavní katalog

| Provider code | Zobrazovaný název | Hlavní rozsah | Projektová role | Integrace | Tarif | Právní stav | Poslední doložený projektový stav |
|---|---|---|---|---|---|---|---|
| `api_football` | API-Football / fotbalová větev API-Sports | FB CORE, PEOPLE, standings a vybrané statistiky | PRIMARY / SPECIALIZED | OPERATIONAL | REVALIDATE; historicky FREE | REVIEW | Reálné fotbalové datasety a PEOPLE pipeline byly v projektu potvrzeny. |
| `football_data` | Football Data API | FB leagues, teams, fixtures, results a historie | FALLBACK / HISTORY | OPERATIONAL | UNKNOWN | REVIEW | V projektu veden jako stabilní fallback a historický zdroj pro FB. |
| `theodds` | The Odds API | ODDS, prioritně fotbal | PRIMARY ODDS | PARTIAL | UNKNOWN | REVIEW | Integrace a odds attach byly rozvíjeny; plný placený provoz vyžaduje revalidaci. |
| `sportsdataio` | SportsDataIO | PEOPLE a profily pro BSB, MMA, HK, BK; další specializované využití | SPECIALIZED | OPERATIONAL | UNKNOWN | REVIEW | V databázi existují tisíce osob z více sportů. |
| `api_american_football` | American Football API | AFB CORE a PEOPLE | PRIMARY / SPECIALIZED | PARTIAL | REVALIDATE | REVIEW | PEOPLE data byla doložena; plný rozsah musí potvrdit runtime audit. |
| `api_basketball` | Basketball API | BK CORE | PRIMARY / FALLBACK podle entity | OPERATIONAL | REVALIDATE | REVIEW | Basketbalová CORE větev je součástí multisport toku. |
| `api_hockey` | Hockey API | HK CORE | PRIMARY | OPERATIONAL | REVALIDATE | REVIEW | Hokejová CORE větev je součástí multisport toku. |
| `api_handball` | Handball API | HB CORE | PRIMARY | OPERATIONAL | REVALIDATE | REVIEW | Házená prošla pokročilým integračním ověřením. |
| `api_volleyball` | Volleyball API | VB CORE | PRIMARY | OPERATIONAL | REVALIDATE | REVIEW | CORE pokrytí je v projektu evidováno; PEOPLE provider zůstává mezerou. |
| `api_cricket` | Cricket API | CK PEOPLE a specializovaná data | SPECIALIZED | OPERATIONAL | UNKNOWN | REVIEW | PEOPLE dataset byl doložen. |
| `api_tennis` | Tennis API | TN PEOPLE a specializovaná data | SPECIALIZED | OPERATIONAL | UNKNOWN | REVIEW | PEOPLE dataset byl doložen. |
| `api_rugby` | Rugby API | RGB CORE | PRIMARY | OPERATIONAL | REVALIDATE | REVIEW | Rugby je součástí potvrzeného multisport CORE směru. |
| `api_sport` | Obecný interní multisport alias / adaptér | Legacy a společné integrační větve | INTERNAL / SUPPLEMENTARY | PARTIAL | NOT_APPLICABLE | REVIEW | Kód nesmí být zaměněn za jednoznačnou obchodní identitu providera. |
| `official_site` | Oficiální weby klubů, lig a federací | MEDIA, oficiální oznámení, referenční metadata | PRIMARY MEDIA podle zdroje | OPERATIONAL | PUBLIC | CONDITIONAL | Funkční zejména pro NHL a NBA; UEFA a FIFA byly částečné. |
| `rss` | RSS / Atom syndikační kanály | MEDIA články a aktuality | SUPPLEMENTARY MEDIA | OPERATIONAL | PUBLIC | CONDITIONAL | Zavedena znovupoužitelná media pipeline. |
| `api_field_hockey` | Kandidát pro pozemní hokej | FH CORE | BLOCKED / RESEARCH | BLOCKED | UNKNOWN | UNKNOWN | Runtime audit doložil chybějící podporovaný zdroj. |

## 8.2 Doložený PEOPLE snapshot

Poslední projektový snapshot z června 2026 uváděl následující providerové rozdělení osob:

| Provider | Sport | Doložený počet | Interpretace |
|---|---:|---:|---|
| `sportsdataio` | BSB | 7 109 | Silný specializovaný PEOPLE zdroj pro baseball. |
| `api_football` | FB | 4 378 v provider mapě | Hlavní fotbalový PEOPLE zdroj; další počty se lišily podle vrstvy a fáze merge. |
| `sportsdataio` | MMA | 3 675 | Hlavní doložený PEOPLE zdroj pro MMA. |
| `sportsdataio` | HK | 1 950 | Hlavní doložený PEOPLE zdroj pro hokej. |
| `sportsdataio` | BK | 535 | Jedna část basketbalového PEOPLE pokrytí. |
| `api_sport` | BK | 327 | Doplňkové basketbalové PEOPLE pokrytí. |
| `api_cricket` | CK | 236 | Specializované PEOPLE pokrytí kriketu. |
| `api_tennis` | TN | 138 | Specializované PEOPLE pokrytí tenisu. |
| `api_american_football` | AFB | 86 | Počáteční PEOPLE pokrytí amerického fotbalu. |

Tyto počty jsou historickým snapshotem, nikoli automaticky aktuálním stavem k datu dokumentu.

## 8.3 Známé mezery

V projektových auditech byly evidovány zejména:

- chybějící nebo neúplný PEOPLE provider pro VB,
- chybějící runtime zdroj pro FH,
- nedokončené PEOPLE pokrytí pro DRT, HB, FH a ESP,
- nutnost revalidace placených a bezplatných tarifů,
- nutnost odděleného právního posouzení fotografií, log, článků a videa,
- nedokončené plné potvrzení ODDS vrstvy po placené aktivaci,
- rozdílná hloubka nižších fotbalových soutěží.

## 8.4 Závěr kapitoly

Kapitola vytvořila první společný seznam šestnácti providerů, interních adaptérů a zdrojových typů včetně doloženého PEOPLE snapshotu. Přínosem je okamžitý přehled o rolích, mezerách a potřebě revalidace. Na tuto kapitolu navazuje kapitola 9, která podrobně rozebírá fotbalový providerový ekosystém.

---

# 9. Fotbalový providerový ekosystém

Fotbal je nejrozvinutější víceproviderová oblast a ukazuje cílový model „best source per entity“.

## 9.1 `api_football`

### Určení

`api_football` je hluboký fotbalový zdroj používaný pro:

- soutěže,
- týmy,
- fixtures a výsledky,
- standings,
- hráče,
- vybrané statistiky hráčů a zápasů,
- potenciálně trenéry, soupisky a mediální assety podle tarifu a práv.

### Projektová role

| Rozsah | Role |
|---|---|
| FB CORE | PRIMARY nebo hlavní hluboký zdroj |
| FB PEOPLE | PRIMARY / SPECIALIZED |
| FB history | doplňkově podle dostupného tarifu |
| FB media assets | kandidát s právní revalidací |
| FB odds | není hlavním odds providerem |

### Doložený stav

Projektové audity potvrdily:

- reálné ligy, týmy a fixtures,
- RAW a staging větev,
- provider mapy,
- merge do `public.matches`,
- PEOPLE harvesting s queue, retry, RAW a parser vrstvou,
- rozdílné pokrytí podle ligy,
- prázdné odpovědi u části nižších soutěží.

### Tarifní stav

Historické projektové záznamy uváděly bezplatný plán s praktickými omezeními:

- omezený počet požadavků,
- rozdílné historické pokrytí,
- neúplné endpointy,
- častější prázdné odpovědi u nižších lig,
- potřebu PRO režimu pro hlubší PEOPLE data.

Aktuální plán musí být před dalším rozhodnutím znovu ověřen.

### Hlavní rizika

- přecenění pokrytí podle HTTP odpovědi,
- spotřeba limitu na ligy s opakovaně prázdnými výsledky,
- změny schématu,
- identity konflikty týmů a soutěží,
- právní omezení mediálních assetů,
- závislost na jednom hlubokém zdroji.

## 9.2 `football_data`

### Určení

`football_data` je v projektu veden jako stabilní fallback a historický zdroj pro:

- soutěže,
- týmy,
- program,
- výsledky,
- základní fotbalový kontext.

### Projektová role

Jeho hlavní hodnota spočívá v:

- oddělení fotbalového CORE od jednoho providera,
- doplnění historie,
- fallbacku při nedostupnosti nebo nepokrytí `api_football`,
- křížové validaci základních entit.

### Neověřené oblasti

Před produkčním rozšířením musí být ověřeny:

- aktuální tarif,
- přesné limity,
- rozsah soutěží,
- hloubka historie,
- licence pro ukládání a publikaci,
- přesná role vůči kanonickému merge.

## 9.3 `theodds`

### Určení

`theodds` je hlavní projektový kandidát a historicky používaný zdroj pro fotbalové kurzy.

### Požadovaný tok

```text
TheOdds
→ RAW odds payload
→ staging odds
→ bookmaker a market normalizace
→ match linker
→ kontrola NO_MATCH_ID
→ public.odds
→ odds audit
```

### Hlavní rizika

- nesprávné párování na zápas,
- časové posuny,
- duplicity bookmakerů a trhů,
- různé názvy týmů,
- vysoká frekvence změn,
- tarifní náklady live režimu,
- licence pro zobrazování a redistribuci kurzů.

## 9.4 Fotbalový cílový routing

```text
FB CORE:
api_football PRIMARY
football_data FALLBACK / HISTORY

FB PEOPLE:
api_football PRIMARY / SPECIALIZED

FB ODDS:
theodds PRIMARY
další odds zdroj pouze po samostatném schválení

FB MEDIA:
official_site + rss
asset provider pouze po právním ověření
```

## 9.5 Závěr kapitoly

Kapitola popsala rozdělení fotbalových rolí mezi hluboký CORE a PEOPLE zdroj, fallback/history zdroj a samostatný ODDS zdroj. Přínosem je omezení závislosti na jednom API a přesnější routing podle entity. Na tuto kapitolu navazuje kapitola 10, která katalogizuje multisport rodinu sportovních API a interní společné adaptéry.

---

# 10. Multisport rodina sportovních API

Projekt používá více sportovních větví se společnými integračními principy, ale každý sport musí mít samostatně ověřené pokrytí.

## 10.1 Přehled větví

| Provider code | Sport | Hlavní vrstva | Souhrnný stav |
|---|---|---|---|
| `api_hockey` | HK | CORE | OPERATIONAL |
| `api_basketball` | BK | CORE | OPERATIONAL |
| `api_handball` | HB | CORE | OPERATIONAL |
| `api_volleyball` | VB | CORE | OPERATIONAL |
| `api_american_football` | AFB | CORE / PEOPLE | PARTIAL až OPERATIONAL podle entity |
| `api_rugby` | RGB | CORE | OPERATIONAL |
| `api_sport` | více sportů | společný nebo historický adaptér | PARTIAL / INTERNAL_REVIEW |

## 10.2 Společný integrační princip

Každá větev musí splnit:

```text
provider-specific request
→ RAW
→ parser
→ provider-normalized staging
→ validační audit
→ provider map
→ kanonický merge
→ post-importní ověření
```

Společná rodina názvů nesmí vést k předpokladu stejného pokrytí nebo stejných limitů.

## 10.3 Hokej

Pro hokej jsou v projektu doloženy:

- CORE data,
- PEOPLE data přes `sportsdataio`,
- media pipeline pro NHL,
- potřeba oddělit výsledky, profily osob a mediální assety podle zdroje.

Cílový model může využívat `api_hockey` pro CORE a `sportsdataio` pro PEOPLE.

## 10.4 Basketbal

Basketbal používá více zdrojů:

- `api_basketball` nebo sportovní API větev pro CORE,
- `sportsdataio` pro část PEOPLE,
- `api_sport` pro další část PEOPLE,
- official sites a RSS pro MEDIA.

Tento stav vyžaduje silné provider mapy a deduplikaci osob.

## 10.5 Házená

Házená dosáhla pokročilého technického stavu CORE. Otevřenou oblastí zůstává PEOPLE a případně hlubší statistiky.

Provider se nesmí označit jako plně pokrývající házenou pouze na základě leagues, teams a fixtures.

## 10.6 Volejbal

Volejbal má potvrzený CORE směr, ale PEOPLE vrstva byla v projektových plánech vedena jako mezera vyžadující specializovaného providera.

## 10.7 Americký fotbal

`api_american_football` je doložen jako zdroj pro AFB PEOPLE v menším rozsahu a jako větev CORE. Před rozšířením je nutné ověřit:

- soutěžní pokrytí,
- soupisky,
- player IDs,
- historické sezóny,
- statistiky,
- obrázky a práva.

## 10.8 Rugby

Rugby je součástí multisport CORE směru. Detailní PEOPLE, MEDIA a ODDS pokrytí musí být vedeno samostatně.

## 10.9 Interní alias `api_sport`

`api_sport` může označovat:

- společný adaptér,
- historický provider code,
- generickou multisport větev,
- záznam vzniklý před přesnějším rozdělením sportovních providerů.

Proto musí být každý záznam s tímto kódem revidován a přiřazen ke konkrétní obchodní identitě, sportu a workeru. Kód nesmí být použit jako důkaz jednoho konkrétního tarifu nebo licence.

## 10.10 Závěr kapitoly

Kapitola katalogizovala sportovní API větve a upozornila, že společná rodina neznamená shodné pokrytí. Přínosem je samostatné řízení každého sportu a odstranění nejednoznačnosti aliasu `api_sport`. Na tuto kapitolu navazuje kapitola 11, která podrobně popisuje specializovanou roli SportsDataIO.

---

# 11. SportsDataIO

`sportsdataio` je v MatchMatrix významným specializovaným providerem zejména pro PEOPLE vrstvu.

## 11.1 Doložené sportovní rozdělení

| Sport | Doložená role | Historický počet osob |
|---|---|---:|
| BSB | hlavní PEOPLE zdroj | 7 109 |
| MMA | hlavní PEOPLE zdroj | 3 675 |
| HK | hlavní PEOPLE zdroj | 1 950 |
| BK | částečný PEOPLE zdroj | 535 |
| AFB | kandidát pro profily a assety | projektově evidovaný směr |

## 11.2 Silné stránky

Projektové důkazy ukazují přínos zejména v:

- velkém objemu osob,
- sportech s omezeným PEOPLE pokrytím jiných API,
- profilových údajích,
- potenciálu pro fotografie a obohacení,
- oddělení PEOPLE providera od CORE providera.

## 11.3 Omezení

Před dlouhodobým produkčním využitím musí být ověřeny:

- přesný aktuální tarif,
- produktové balíčky podle sportu,
- request limity,
- práva k fotografiím,
- práva k veřejnému zobrazení profilů,
- možnost dlouhodobé archivace,
- rozsah historických sezón,
- podmínky odvozených dat a exportu.

## 11.4 Identitní požadavky

Každý záznam osoby musí zachovat:

- originální provider ID,
- sport,
- týmový kontext,
- zdrojový payload nebo jeho auditní referenci,
- provider map,
- stav identity,
- případný konflikt s jiným providerem.

Pouhý shodný název osoby není dostatečný pro automatické sloučení.

## 11.5 Assety

Fotografie a další mediální assety musí mít oddělený právní stav od textových profilových dat.

Možné stavy:

```text
PROFILE_DATA_ALLOWED
PHOTO_REVIEW_REQUIRED
PHOTO_ALLOWED_WITH_ATTRIBUTION
PHOTO_INTERNAL_ONLY
PHOTO_BLOCKED
```

## 11.6 Cílová role

SportsDataIO má být veden jako:

- `SPECIALIZED` pro PEOPLE podle sportu,
- případně `PRIMARY` pro konkrétní PEOPLE entitu po ověření,
- nikoli automaticky jako CORE provider,
- nikoli jako univerzální zdroj mediálních práv.

## 11.7 Závěr kapitoly

Kapitola vymezila SportsDataIO jako silný specializovaný PEOPLE zdroj s doloženými datasety, ale s nutností samostatné tarifní a mediálně-právní kontroly. Přínosem je využití jeho hloubky bez rozšíření práv nad doložený rozsah. Na tuto kapitolu navazuje kapitola 12, která katalogizuje specializované zdroje pro kriket a tenis.

---

# 12. Specializované zdroje pro kriket a tenis

Kriket a tenis používají vlastní providerové kódy pro PEOPLE a specializovaná data.

## 12.1 `api_cricket`

### Doložený stav

Historický PEOPLE snapshot obsahoval 236 osob pro sport CK.

### Požadované ověření

- stabilita player ID,
- týmové a reprezentační vazby,
- soutěže a sezóny,
- role a pozice hráčů,
- dostupnost fotografií,
- zápasové a sezónní statistiky,
- geografické pokrytí,
- aktuální tarif a limit.

### Cílová role

`api_cricket` je veden jako `SPECIALIZED` pro PEOPLE. CORE role musí být potvrzena samostatným runtime auditem.

## 12.2 `api_tennis`

### Doložený stav

Historický PEOPLE snapshot obsahoval 138 osob pro sport TN.

### Specifika tenisu

Tenis vyžaduje jiné identity než týmové sporty:

- hráč může dlouhodobě existovat bez klubové vazby,
- dvojice a týmové soutěže vytvářejí vztahové výjimky,
- žebříčky se mění často,
- turnaje a kola vyžadují vlastní identitní model,
- jméno hráče může mít více přepisů.

### Požadované ověření

- ATP, WTA a další soutěžní rozsahy,
- turnaje, kola a zápasy,
- žebříčky,
- profily a biografická data,
- fotografie,
- historické sezóny,
- live skóre a limity,
- práva k veřejnému zobrazení.

## 12.3 Společná pravidla

Oba providery musí:

- uchovat RAW,
- používat provider map,
- oddělit profil od fotografie,
- vykazovat prázdné odpovědi,
- rozlišovat CORE a PEOPLE pokrytí,
- evidovat tarif po sportu nebo produktovém balíčku,
- neodvozovat plné pokrytí z malého vzorku.

## 12.4 Závěr kapitoly

Kapitola popsala doložené PEOPLE základy kriketu a tenisu a jejich sportovní specifika. Přínosem je zabránění použití týmového identitního modelu tam, kde neodpovídá realitě sportu. Na tuto kapitolu navazuje kapitola 13, která řeší oficiální weby, RSS a další mediální zdroje.

---

# 13. Oficiální weby, RSS a mediální zdroje

MEDIA vrstva používá jiný typ providerů než CORE a PEOPLE.

## 13.1 `official_site`

`official_site` představuje řízenou kategorii oficiálních zdrojů:

- klubové weby,
- ligové weby,
- federace,
- organizátoři soutěží,
- oficiální tisková centra.

Každý konkrétní web musí mít vlastní source record, i když používá společný provider code.

## 13.2 `rss`

RSS nebo Atom kanál je technický způsob distribuce, nikoli automatické oprávnění k libovolné redistribuci obsahu.

Eviduje se:

- vlastník feedu,
- URL uložená v konfiguraci, nikoli v tajném registru,
- jazyk,
- sport a entity,
- interval aktualizace,
- pravidla atribuce,
- rozsah ukládaného textu,
- právo zobrazit celý článek nebo pouze výňatek,
- kanonický odkaz,
- datum posledního úspěšného načtení.

## 13.3 Doložený stav media pipeline

Projektový snapshot uváděl:

- funkční MEDIA směr pro NHL,
- funkční MEDIA směr pro NBA,
- částečný stav pro UEFA,
- částečný stav pro FIFA,
- tok přes staging, public články, alias mapping a media audit.

## 13.4 Články

U článku se musí oddělit:

- metadata,
- titulek,
- krátký výňatek,
- celý text,
- obrázek,
- autor,
- zdroj,
- kanonická URL,
- jazyk,
- datum publikace.

Právo použít metadata nebo odkaz neznamená právo uložit a znovu publikovat celý text.

## 13.5 Fotografie, loga a video

Každý asset potřebuje samostatný právní profil:

- vlastník nebo licencující subjekt,
- povolené použití,
- atribuce,
- území,
- doba platnosti,
- možnost změny velikosti nebo ořezu,
- možnost cache,
- možnost veřejného zobrazení,
- takedown postup.

## 13.6 Cílové providerové rozdělení

```text
MEDIA články:
official_site PRIMARY podle konkrétní organizace
rss SUPPLEMENTARY / TRANSPORT

MEDIA assety:
samostatný schválený asset provider
nebo oficiální zdroj s doloženými právy

MEDIA vztahy:
alias map + entity linker + audit
```

## 13.7 Závěr kapitoly

Kapitola oddělila technický přístup k oficiálním webům a RSS od práv k článkům a assetům. Přínosem je bezpečnější MEDIA pipeline s dohledatelným původem. Na tuto kapitolu navazuje kapitola 14, která eviduje blokované oblasti a chybějící providery.

---

# 14. Blokované oblasti a Missing Provider Matrix

Chybějící provider je řízený stav, nikoli důvod k improvizovanému scrapingu nebo použití neověřeného zdroje.

## 14.1 Pozemní hokej

Runtime audit doložil, že:

- projektová větev `api_field_hockey` neměla funkční podporovaný pull,
- obecný sportovní provider nepodporoval požadovaný sport,
- nebyla potvrzena runtime data,
- další postup byl odložen do nalezení nového providera nebo bezpečné vlastní integrace.

Stav:

```text
sport: FH
provider_role: BLOCKED / RESEARCH
integration_status: BLOCKED
coverage_status: NOT_SUPPORTED
next_action: PROVIDER_RESEARCH
```

## 14.2 PEOPLE mezery

Mezi známé mezery patřily:

- VB players,
- DRT players,
- HB players,
- FH players,
- ESP players.

Každá mezera musí uvést:

- sport,
- entitu,
- požadovanou hloubku,
- prioritu,
- důvod chybění,
- kandidátní providery,
- právní omezení,
- odhadovaný tarifní dopad,
- další výzkumný krok.

## 14.3 Rozhodovací kritéria nového providera

Kandidát se hodnotí podle:

1. pokrytí prioritních soutěží,
2. dostupnosti historie,
3. kvality identit,
4. úplnosti PEOPLE nebo CORE dat,
5. stability schématu,
6. limitů a nákladů,
7. práv k ukládání a publikaci,
8. možností RAW archivace,
9. rychlosti a dostupnosti,
10. nahraditelnosti,
11. existence testovacího režimu,
12. schopnosti projít standardním integračním tokem.

## 14.4 Zakázané zkratky

Nesmí se:

- použít neověřený scraper jen proto, že API chybí,
- přidat provider bez provider code a právního profilu,
- zapisovat přímo do public vrstvy,
- smíchat data bez provider map,
- koupit tarif bez ověření reálného coverage vzorku,
- deklarovat sport jako hotový pouze podle marketingového seznamu.

## 14.5 Závěr kapitoly

Kapitola převedla chybějící a blokované oblasti do řízené Missing Provider Matrix. Přínosem je bezpečné plánování výzkumu bez obcházení integračních a právních pravidel. Na tuto kapitolu navazuje kapitola 15, která shrnuje cílové providerové role podle sportu a vrstvy.

---

# 15. Cílová providerová matice podle sportu a vrstvy

Matice je pracovní referenční pohled. Skutečný routing musí být potvrzen databázovými pravidly a aktuálním health stavem.

## 15.1 Přehled

| Sport | CORE | PEOPLE | MEDIA | ODDS | Hlavní otevřená oblast |
|---|---|---|---|---|---|
| FB | `api_football` PRIMARY; `football_data` FALLBACK/HISTORY | `api_football` | `official_site`, `rss`; assety k ověření | `theodds` | placený rozsah, lower leagues, asset rights |
| HK | `api_hockey` | `sportsdataio` | official NHL sources, RSS | RESEARCH / REVALIDATE | sjednocení CORE a PEOPLE identit |
| BK | `api_basketball` | `sportsdataio` + `api_sport` | official NBA sources, RSS | RESEARCH / REVALIDATE | deduplikace PEOPLE, odds provider |
| BSB | REVALIDATE / samostatný audit | `sportsdataio` | RESEARCH | RESEARCH | potvrdit CORE zdroj |
| MMA | RESEARCH / specializovaný model | `sportsdataio` | official promotion sources | RESEARCH | events, fighters, odds a media práva |
| HB | `api_handball` | MISSING / RESEARCH | RESEARCH | RESEARCH | PEOPLE provider |
| VB | `api_volleyball` | MISSING / RESEARCH | RESEARCH | RESEARCH | players a profily |
| CK | REVALIDATE | `api_cricket` | RESEARCH | RESEARCH | sjednotit CORE a PEOPLE |
| RGB | `api_rugby` | RESEARCH | RESEARCH | RESEARCH | PEOPLE a media |
| AFB | `api_american_football` | `api_american_football`; další enrichment k ověření | RESEARCH | RESEARCH | hloubka soutěží a profilů |
| TN | REVALIDATE | `api_tennis` | RESEARCH | RESEARCH | turnajová identita a live data |
| DRT | RESEARCH | MISSING / RESEARCH | RESEARCH | RESEARCH | komplexní provider gap |
| FH | BLOCKED | BLOCKED | RESEARCH | RESEARCH | chybí funkční CORE provider |
| ESP | RESEARCH | MISSING / RESEARCH | official competition sources | RESEARCH | standardizace titulů, týmů a hráčů |

## 15.2 Pravidlo směrování

Routing nesmí používat pouze sloupec sportu. Minimální klíč:

```text
sport
+ layer
+ entity
+ competition
+ time_mode
+ legal_scope
+ provider_health
+ tariff_capacity
```

## 15.3 Konflikty rolí

Při více kandidátech se rozhoduje podle:

- schváleného rozsahu,
- datové kvality,
- čerstvosti,
- identity stability,
- health,
- právního stavu,
- ceny na skutečně použitelný objekt,
- schopnosti fallbacku,
- historie incidentů.

## 15.4 Závěr kapitoly

Kapitola vytvořila pracovní providerovou matici napříč čtrnácti sporty a čtyřmi hlavními vrstvami. Přínosem je viditelnost mezer a hybridních kombinací providerů. Na tuto kapitolu navazuje kapitola 16, která stanovuje ověřovací a revalidační workflow každého katalogového záznamu.

---

# 16. Ověření a revalidace providerového záznamu

Záznam se považuje za důvěryhodný pouze v rozsahu doloženého ověření.

## 16.1 První ověření providera

Povinný postup:

```text
DISCOVERED
→ identifikace obchodního subjektu
→ tarifní a právní kontrola
→ testovací účet nebo povolený vzorek
→ endpoint inventory
→ RAW test
→ schema audit
→ coverage sample
→ parser a staging
→ provider map
→ merge test
→ data quality audit
→ cost projection
→ rozhodnutí REVIEW / PILOT / ACTIVE / HOLD
```

## 16.2 Reprezentativní vzorek

Test musí zahrnout:

- alespoň jednu hlavní soutěž,
- alespoň jednu nižší nebo méně běžnou soutěž,
- aktuální sezónu,
- historický rozsah, je-li požadován,
- běžný i hraniční případ,
- prázdnou odpověď,
- chybový stav,
- rate-limit reakci,
- změnu stránky nebo pagination,
- duplicitu a konflikt identity.

## 16.3 Pravidelná revalidace

| Oblast | Doporučený spouštěč |
|---|---|
| Runtime dostupnost | průběžný monitoring |
| Coverage | měsíčně a při změně sezóny |
| Tarif | před obnovou a při změně ceníku |
| Licence | při změně podmínek a periodicky |
| Schéma | při parser chybě nebo změně payloadu |
| Identity | při růstu kolizí |
| Health | průběžně |
| Role PRIMARY/FALLBACK | při významné změně kvality nebo ceny |

## 16.4 Revalidace před nákupem

Před placenou aktivací musí být potvrzeno:

- že požadované entity skutečně vracejí data,
- že pokrytí odpovídá prioritním soutěžím,
- že historie odpovídá cíli projektu,
- že tarifní limit stačí po započtení retry,
- že data lze uložit a použít zamýšleným způsobem,
- že existuje bezpečný plán ukončení,
- že provider nepřekrývá levnější nebo kvalitnější existující zdroj bez důvodu.

## 16.5 Výsledek revalidace

Výsledek musí být jeden z:

```text
CONFIRMED_NO_CHANGE
CONFIRMED_CHANGED
REQUIRES_ROUTING_CHANGE
REQUIRES_TARIFF_CHANGE
REQUIRES_LEGAL_REVIEW
HOLD_REQUIRED
RETIREMENT_RECOMMENDED
```

## 16.6 Závěr kapitoly

Kapitola definovala úplný testovací a revalidační cyklus od objevení providera po rozhodnutí o změně nebo HOLD. Přínosem je nákup a routing založený na reálných datech. Na tuto kapitolu navazuje kapitola 17, která navrhuje cílové databázové objekty a panelové pohledy katalogu.

---

# 17. Cílový databázový a panelový model

Markdown katalog je přechodný lidsky čitelný snapshot. Cílovým stavem je strukturovaný provider registry.

## 17.1 Navrhované databázové objekty

### `ops.provider_catalog`

Základní identita providera:

```text
provider_id
provider_code
display_name
provider_family
source_type
lifecycle_status
record_owner
commercial_identity_status
created_at
updated_at
```

### `ops.provider_tariff_profile`

```text
provider_id
tariff_status
tariff_name
billing_cycle
price_amount_encrypted_or_restricted
price_currency
request_limit
limit_period
concurrency_limit
renewal_date
verified_at
evidence_ref
```

Citlivé údaje musí být odděleny přístupovými právy.

### `ops.provider_coverage`

```text
provider_id
sport_code
layer_code
entity_type
competition_scope
geography_scope
time_scope
coverage_status
evidence_count
verified_at
runtime_evidence_ref
```

### `ops.provider_integration_profile`

```text
provider_id
worker_group
raw_status
parser_status
staging_status
provider_map_status
merge_status
integration_status
last_successful_run_at
```

### `ops.provider_evidence`

```text
provider_id
evidence_type
evidence_ref
observed_at
valid_from
valid_to
confidence
reviewed_by
notes
```

### Související právní objekty

Právní profil a práva mají navazovat na model definovaný v `MM-PRV-006`, nikoli být duplikovány v nekontrolovaném textu.

## 17.2 Navrhované pohledy

```text
ops.v_provider_catalog_current
ops.v_provider_matrix
ops.v_missing_provider_matrix
ops.v_provider_tariff_expiry
ops.v_provider_coverage_stale
ops.v_provider_legal_hold
ops.v_provider_routing_readiness
ops.v_provider_cost_capacity
```

## 17.3 Panelové sekce

Provider Matrix panel má zobrazit:

- providery,
- sporty,
- vrstvy,
- entity,
- roli,
- lifecycle,
- integration status,
- health,
- tarifní stav,
- právní stav,
- poslední ověření,
- expiraci,
- chybějící coverage,
- doporučený další krok.

Popisky panelu mají být v češtině. Interní provider code zůstává zachován.

## 17.4 Bezpečnostní blokace

Panel musí blokovat nebo výrazně označit:

- právní HOLD,
- expirovaný tarif,
- neověřený PRIMARY routing,
- zastaralý coverage důkaz,
- chybějící provider map,
- přímý zápis do kanonické vrstvy,
- provider bez jasné obchodní identity,
- pokus zobrazit tajný údaj.

## 17.5 Automatizace

Automatizace smí:

- načíst runtime evidence,
- navrhnout změnu stavu,
- označit zastaralý záznam,
- upozornit na expiraci,
- připravit porovnání providerů,
- doporučit revalidaci.

Automatizace nesmí sama schválit právní nebo obchodní rozhodnutí.

## 17.6 Závěr kapitoly

Kapitola převedla katalog do návrhu databázových tabulek, pohledů a českého Provider Matrix panelu. Přínosem je budoucí odstranění ruční duplicity a automatická kontrola expirací a mezer. Na tuto kapitolu navazuje kapitola 18, která popisuje provozní workflow práce s katalogem.

---

# 18. Provozní workflow katalogu

Katalog musí být součástí běžného providerového řízení.

## 18.1 Založení nového záznamu

1. Přidělit stabilní `provider_code`.
2. Ověřit, zda provider nebo alias již neexistuje.
3. Zapsat obchodní identitu a source type.
4. Nastavit lifecycle `DISCOVERED` nebo `REVIEW`.
5. Založit tarifní a právní profil.
6. Vymezit testovaný sport, vrstvu a entity.
7. Provést pilotní integrační audit.
8. Zapsat důkazy a datum kontroly.
9. Rozhodnout roli.
10. Schválit nebo aktivovat HOLD.

## 18.2 Změna existujícího záznamu

Změna se provádí jako auditovatelná událost. Původní stav musí být dohledatelný.

Při změně PRIMARY nebo FALLBACK se navíc ověřuje:

- dopad na všechny routing rules,
- pending a retry queue,
- provider mapy,
- kanonická data,
- downstream vrstvy,
- náklady,
- právní rozsah,
- návratový plán.

## 18.3 Provozní incident

Při incidentu se katalog neaktualizuje pouze poznámkou. Musí vzniknout:

- health incident,
- případný stav HOLD,
- dopad na routing,
- dočasný fallback,
- důkaz opravy,
- revalidace,
- změna katalogu, pokud se změnil dlouhodobý stav.

## 18.4 Ukončení providera

Před stavem `RETIRED` se ověří:

- zda neexistují aktivní workery,
- zda není provider v routing pravidlech,
- zda nejsou otevřené queue,
- zda jsou zachovány povolené RAW a auditní záznamy,
- zda je vyřešena retence a smazání,
- zda existuje náhrada,
- zda byly odstraněny tajné údaje z aktivní konfigurace,
- zda byl aktualizován katalog a dokumentace.

## 18.5 Dokumentační workflow

Změna tohoto dokumentu pokračuje standardně:

```text
úprava katalogu
→ A17
→ A23
→ uživatelské schválení
→ Git commit
→ A24 VALIDATE_ONLY
→ A24 APPLY
→ A7
→ Git push podle řízeného workflow
```

Před A24 musí být pracovní strom čistý.

## 18.6 Závěr kapitoly

Kapitola popsala založení, změnu, incident a ukončení providerového záznamu včetně dokumentační publikace. Přínosem je spojení katalogu s reálným životním cyklem a provozem. Na tuto kapitolu navazuje kapitola 19, která odděluje aktuální ověřený stav od dalšího rozvoje.

---

# 19. Aktuální projektový snapshot a cílový rozvoj

## 19.1 Ověřený dokumentační stav

K datu vytvoření dokumentu je dokončena základní providerová řada:

```text
MM-PRV-001  Providerový ekosystém MatchMatrix
MM-PRV-002  Životní cyklus a schvalování providerů
MM-PRV-003  Provider routing a fallback
MM-PRV-004  Provider Health Monitoring
MM-PRV-005  Integrace providerů do datových vrstev
MM-PRV-006  Právní a licenční řízení providerů
```

`MM-PRV-006` prošel A17, A23, Git, A24 a A7 a byl pushnut na větev `main` v commitu `98f7c67`.

## 19.2 Stav této první verze katalogu

První verze:

- definuje katalogový datový model,
- sjednocuje stavové kódy,
- zakazuje nedoložené ceny,
- obsahuje první seznam providerů,
- eviduje doložený PEOPLE snapshot,
- popisuje fotbalový hybridní model,
- rozlišuje sportovní API větve,
- eviduje media zdroje,
- zavádí Missing Provider Matrix,
- navrhuje databázový a panelový cílový stav.

## 19.3 Co ještě není potvrzeno

Tento návrh záměrně neprohlašuje za ověřené:

- aktuální ceny providerů,
- aktuální názvy všech tarifů,
- přesné obnovovací termíny,
- právní schválení všech zdrojů,
- úplné coverage všech sportů,
- aktuální počet objektů v každé provider mapě,
- plný ODDS provoz po placené aktivaci,
- práva k fotografiím a logům.

Tyto údaje musí být získány z aktuálních smluv, účtů a runtime auditů.

## 19.4 Krátkodobý rozvoj

1. Převést souhrnný katalog do strukturovaného provider registry.
2. Napojit Provider Matrix panel na runtime evidence.
3. Doplnit tarifní revalidaci hlavních providerů.
4. Doplnit právní profily.
5. Potvrdit sport po sportu CORE, PEOPLE, MEDIA a ODDS.
6. Aktualizovat Missing Provider Matrix.
7. Zavést expirace a automatická upozornění.

## 19.5 Střednědobý rozvoj

- porovnání ceny na využitelný objekt,
- automatický coverage diff,
- doporučení PRIMARY/FALLBACK,
- detekce nevyužívaného placeného tarifu,
- simulace kapacity harvestu,
- historie změn pokrytí,
- provázání s rozpočtem a roadmapou sportů.

## 19.6 Dlouhodobý cíl

Dlouhodobým cílem je providerový řídicí systém, který dokáže pro každý sport, vrstvu a entitu doložit:

- odkud data pocházejí,
- proč byl zdroj zvolen,
- co jeho tarif dovoluje,
- co jeho licence dovoluje,
- jaké je skutečné pokrytí,
- jaký je health,
- jaký fallback je připraven,
- kolik zdroj stojí,
- kdy musí být znovu ověřen,
- jak bude bezpečně ukončen.

## 19.7 Závěr kapitoly

Kapitola oddělila ověřený dokumentační stav od neověřených tarifních a runtime detailů a stanovila další rozvoj. Přínosem je transparentní snapshot bez předstírání přesnosti. Na tuto kapitolu navazuje kapitola 20, která shrnuje vazby a kontrolní kritéria dokumentu.

---

# 20. Vazby a kontrolní kritéria dokumentu

## 20.1 Vazby na providerovou řadu

| Dokument | Vazba |
|---|---|
| MM-PRV-001 | Katalog naplňuje požadavek na samostatnou evidenci konkrétních providerů. |
| MM-PRV-002 | Lifecycle stav katalogového záznamu používá stejné schvalovací principy. |
| MM-PRV-003 | Role PRIMARY, FALLBACK a SPECIALIZED vstupují do routingu. |
| MM-PRV-004 | Health stav a incidenty ovlivňují aktuální použitelnost. |
| MM-PRV-005 | Integration status vychází z povinného datového toku. |
| MM-PRV-006 | Tarifní a právní záznam musí respektovat schválená práva a omezení. |

## 20.2 Vazby na hlavní dokumentaci

| Dokument | Vazba |
|---|---|
| MM-DOC-100 | Strategické priority sportů a vrstev. |
| MM-DOC-200 | Provider Governance, role a audit. |
| MM-DOC-300 | Víceproviderová architektura a Source Intelligence Layer. |
| MM-DOC-800 | Vývojové, bezpečnostní a provozní postupy. |
| MM-DB-001 | Databázové principy. |
| MM-DB-002 | Schémata a registry. |
| MM-DB-003 | Datový slovník implementovaných objektů. |
| MM-REF-001 | Český překlad cizích a technických výrazů. |
| MM-REF-002 | Výklad pojmů a navigace. |

## 20.3 Kontrolní kritéria obsahu

Před schválením musí být potvrzeno:

- [ ] Document ID a název souboru jsou správné.
- [ ] Dokument neobsahuje API klíče, tokeny ani hesla.
- [ ] Nedoložené ceny nejsou vydávány za aktuální skutečnost.
- [ ] Každý hlavní provider má stabilní interní kód.
- [ ] Obchodní identita není zaměněna s interním aliasem.
- [ ] Role providera je vymezena podle sportu, vrstvy a entity.
- [ ] Pokrytí má datum a důkaz.
- [ ] Historické počty jsou označeny jako snapshot.
- [ ] Tarifní stav `REVALIDATE` nebo `UNKNOWN` není interpretován jako schválený.
- [ ] Právní stav respektuje `MM-PRV-006`.
- [ ] Provider bez mapování nezapisuje přímo do kanonické vrstvy.
- [ ] Blokované oblasti jsou vedeny v Missing Provider Matrix.
- [ ] Změny mají auditní stopu.
- [ ] Všechny hlavní kapitoly mají shrnutí, přínos a návaznost.
- [ ] A17 neobsahuje FAIL.
- [ ] A23 byl vyhodnocen.
- [ ] Uživatel dokument schválil.
- [ ] Git commit předchází A24.
- [ ] A24 VALIDATE_ONLY uspěl.
- [ ] A24 APPLY a A7 ověřily integritu.

## 20.4 Kritéria budoucí databázové implementace

Databázová implementace musí:

- zachovat neměnný provider code,
- oddělit tarifní, technický, coverage a právní stav,
- evidovat platnost a datum ověření,
- podporovat historii změn,
- blokovat tajné údaje v běžném panelu,
- umožnit více rolí podle entity,
- podporovat více tarifních profilů v čase,
- provázat evidence s runtime běhy,
- umožnit automatickou detekci zastarání,
- nepovolit automatické strategické schválení.

## 20.5 Závěr kapitoly

Kapitola sjednotila vazby na providerovou a hlavní dokumentaci a vytvořila závěrečný kontrolní seznam. Přínosem je jednoznačné ověření obsahové, bezpečnostní, terminologické a publikační připravenosti dokumentu. Na tuto kapitolu navazuje kapitola 21 – Historie verzí, která zaznamenává vznik a další vývoj katalogu.

---

# 21. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-21 | DRAFT – NEEDS_USER_APPROVAL | První úplný návrh referenčního katalogu providerů, tarifů, pokrytí, rolí, důkazů, mezer a cílového databázového modelu. |

---

# Závěr dokumentu

`MM-PRV-007` vytváří první řízený referenční katalog konkrétních providerů MatchMatrix.

Dokument navazuje na stabilní providerovou řadu `MM-PRV-001` až `MM-PRV-006` a převádí její principy do praktické evidence:

- providerových identit,
- tarifních a smluvních stavů,
- sportovního a entitního pokrytí,
- rolí PRIMARY, FALLBACK a SPECIALIZED,
- technické integrace,
- health a právních stavů,
- runtime důkazů,
- historických snapshotů,
- známých mezer,
- revalidačního workflow,
- cílového databázového a panelového modelu.

První verze záměrně neuvádí nedoložené aktuální ceny ani nepředstírá právní schválení zdrojů, u nichž dosud nebyl vytvořen úplný profil. Historická fakta jsou označena datem nebo jako snapshot a všechny nejisté oblasti používají řízené stavy `REVALIDATE`, `REVIEW`, `UNKNOWN`, `PARTIAL` nebo `BLOCKED`.

Hlavním přínosem dokumentu je vytvoření jednoho společného rámce, podle kterého lze rozhodovat, který provider je vhodný pro konkrétní sport, vrstvu a entitu, jaké důkazy toto rozhodnutí podporují a co musí být ověřeno před aktivací, nákupem, publikací nebo změnou routingu.

Dalším realizačním krokem po schválení dokumentu je převod katalogových polí do databázového provider registry a jejich zobrazení v českém Provider Matrix panelu.
