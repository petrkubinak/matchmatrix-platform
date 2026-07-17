# MM-PRV-001

# PROVIDEROVÝ EKOSYSTÉM MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-001 |
| Document ID | MM-PRV-001 |
| Název dokumentu | Providerový ekosystém MatchMatrix |
| Typ dokumentu | PROVIDER_ECOSYSTEM |
| Dokumentační oblast | 05_PROVIDERS |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | NOVÝ DOKUMENT |
| Datum | 2026-07-17 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Cílové umístění | `docs/05_PROVIDERS/` |
| Nahrazuje | — |
| Navazuje na | MM-DOC-200, MM-DOC-300, MM-DB-001, MM-DB-002, MM-DB-003 |
| Související dokumenty | MM-DOC-100, MM-DOC-800, MM-REF-001, MM-REF-002 |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-008 |

---

# 1. Úvod

Providerový ekosystém je soubor pravidel, technických vazeb, provozních stavů a rozhodovacích mechanismů, kterými MatchMatrix pracuje s externími a interními poskytovateli dat.

MatchMatrix není navržen jako aplikace závislá na jednom konkrétním API. Databáze, datové vrstvy ani produktové funkce nesmí být pevně svázány s datovým modelem jediného providera. Každý provider je samostatný zdroj, který je připojen přes řízené integrační rozhraní a mapován do interního modelu MatchMatrix.

Tento dokument stanovuje společný technický a provozní rámec pro:

- objevování a evidenci providerů,
- posouzení jejich použitelnosti,
- začlenění do architektury,
- řízení priorit a záložních zdrojů,
- sledování kvality, dostupnosti a omezení,
- bezpečné zpracování providerových dat,
- dlouhodobou nahraditelnost jednotlivých zdrojů.

Dokument nevede úplný a průběžně měněný katalog konkrétních providerů. Takový katalog má být spravován v samostatném referenčním dokumentu, aby se provozní údaje neduplikovaly v architektonické dokumentaci.

## 1.1 Proč dokument vzniká

Providerová oblast byla dosud popsána v hlavní architektuře, governance dokumentaci, projektových snapshotech a provozních auditech. Tyto informace však byly rozptýlené mezi více dokumenty.

Samostatný dokument `MM-PRV-001` sjednocuje základní model oblasti `05_PROVIDERS` a vytváří výchozí bod pro další providerové dokumenty.

## 1.2 Rozsah dokumentu

Dokument se vztahuje na všechny zdroje, které dodávají nebo obohacují data MatchMatrix, zejména:

- sportovní výsledky a harmonogramy,
- soutěže, sezony, týmy a zápasy,
- hráče, trenéry a další osoby,
- statistiky,
- články, fotografie a videa,
- sázkové kurzy a trhy,
- znalostní a referenční data,
- oficiální informace federací, soutěží a klubů.

## 1.3 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola vymezila providerový ekosystém jako samostatnou řízenou oblast a stanovila účel, důvod vzniku a rozsah dokumentu.

**Přínos pro projekt:** Projekt získává jednotný výchozí rámec pro správu externích a interních zdrojů dat.

**Návaznost na další kapitolu:** Následující kapitola stanovuje základní principy platné pro všechny providery bez ohledu na sport nebo typ dat.

---

# 2. Základní principy providerového ekosystému

## 2.1 Nezávislost databáze na providerovi

Interní databázový model se navrhuje podle potřeb MatchMatrix, nikoli podle struktury konkrétního API.

Providerová data se musí přizpůsobit internímu modelu prostřednictvím:

- RAW uložení,
- parseru,
- providerového mapování,
- staging vrstvy,
- validačních pravidel,
- merge procesu.

Změna nebo výpadek providera proto nesmí vyžadovat zásadní změnu kanonického datového modelu.

## 2.2 Nahraditelnost

Žádný provider nesmí být považován za nenahraditelnou součást systému.

U kritických datových oblastí má být dlouhodobým cílem:

- více než jeden použitelný zdroj,
- známá náhradní cesta,
- možnost přesměrování harvestu,
- oddělení providerového identifikátoru od kanonické identity.

## 2.3 Provider není zdroj pravdy

Provider dodává vstupní tvrzení, nikoli automaticky pravdivý kanonický záznam.

Každé providerové tvrzení může být:

- úplné,
- neúplné,
- opožděné,
- chybné,
- duplicitní,
- v rozporu s jiným zdrojem.

Zdroj pravdy vzniká až po validaci, mapování, merge a případném governance rozhodnutí.

## 2.4 Oddělení identity a datového obsahu

Providerový identifikátor je externí klíč platný pouze v kontextu konkrétního providera.

Kanonická identita MatchMatrix musí zůstat stabilní i tehdy, když:

- provider změní ID,
- provider změní název entity,
- dojde ke změně tarifu,
- provider přestane být používán,
- stejná entita přijde z jiného zdroje.

## 2.5 Auditovatelnost

Každý významný providerový proces musí být dohledatelný.

Auditní stopa má umožnit zjistit:

- odkud data přišla,
- kdy byla stažena,
- který worker je získal,
- který parser je zpracoval,
- jaké mapování bylo použito,
- zda vznikl konflikt,
- jak byl záznam sloučen,
- zda byl výsledek přijat, odmítnut nebo pozastaven.

## 2.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila nezávislost databáze na providerovi, nahraditelnost zdrojů, oddělení identit a povinnou auditovatelnost providerových procesů.

**Přínos pro projekt:** Tyto principy chrání kanonický model MatchMatrix před přímou závislostí na jednotlivém externím zdroji.

**Návaznost na další kapitolu:** Následující kapitola rozděluje providery podle jejich skutečné funkce v platformě.

---

# 3. Funkční kategorie providerů

Provider může patřit do jedné nebo více funkčních kategorií. Zařazení se řídí skutečně dodávanými daty, nikoli pouze marketingovým označením služby.

## 3.1 Core provideři

Core provideři dodávají základní sportovní data, například:

- sporty,
- země a regiony,
- soutěže,
- sezony,
- týmy a účastníky,
- zápasy a události,
- výsledky,
- tabulky soutěží,
- základní zápasové statistiky.

Core data tvoří základní kostru, na kterou se vážou další vrstvy.

## 3.2 People provideři

People provideři dodávají informace o osobách:

- hráči,
- trenéři,
- rozhodčí,
- členové realizačních týmů,
- přestupy a týmové vazby,
- sezonní a zápasové statistiky osob,
- profily a fotografie.

People data vyžadují zvláštní důraz na identitu, jmenné varianty, datum narození, národnost a vazbu na správný sport.

## 3.3 Media provideři

Media provideři dodávají nebo zpřístupňují:

- články,
- oficiální zprávy,
- fotografie,
- videa,
- tiskové zprávy,
- klubové a federační aktuality.

U media zdrojů musí být kromě kvality dat posuzováno také právo použití, původ obsahu a možnost zveřejnění.

## 3.4 Odds provideři

Odds provideři dodávají:

- sázkové kanceláře,
- kurzy,
- trhy,
- výběry,
- časové změny kurzů,
- stav otevření nebo uzavření trhu.

Odds data jsou časově citlivá. Jejich použitelnost závisí na rychlosti aktualizace, přesném napojení na zápas a jednoznačném mapování trhu.

## 3.5 Knowledge provideři

Knowledge provideři slouží k obohacování kanonických entit.

Mohou poskytovat:

- alternativní názvy,
- historické názvy,
- oficiální weby,
- popisy,
- loga a fotografie,
- zeměpisné údaje,
- referenční identifikátory.

Tyto zdroje obvykle nenahrazují Core providery, ale zlepšují úplnost a dohledatelnost profilů.

## 3.6 Oficiální zdroje

Za zvláštní skupinu se považují oficiální weby a datové zdroje:

- sportovních federací,
- lig a soutěží,
- klubů,
- týmů,
- pořadatelů,
- hráčských asociací.

Oficiální zdroj může mít vysokou autoritu pro konkrétní údaj, ale i on musí projít kontrolou původu, aktuálnosti, struktury a podmínek použití.

## 3.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola rozdělila providery na Core, People, Media, Odds, Knowledge a oficiální zdroje podle skutečně poskytovaných dat.

**Přínos pro projekt:** Funkční členění umožňuje vybírat vhodný zdroj podle konkrétní datové potřeby namísto předpokladu, že jeden provider pokryje vše.

**Návaznost na další kapitolu:** Následující kapitola stanovuje životní cyklus providera od objevení po ukončení jeho používání.

---

# 4. Životní cyklus providera

## 4.1 DISCOVERED – objevený zdroj

Provider byl nalezen, ale ještě nebyl technicky ani právně posouzen.

V této fázi se eviduje minimálně:

- název zdroje,
- web nebo dokumentace,
- typ poskytovaných dat,
- podporované sporty,
- dostupný tarif,
- způsob přístupu,
- datum objevení.

## 4.2 REVIEW – posouzení

Probíhá kontrola:

- technické dokumentace,
- autentizace,
- limitů požadavků,
- historického rozsahu,
- datové úplnosti,
- licenčních podmínek,
- obchodního modelu,
- stability služby,
- právních a provozních omezení.

## 4.3 CANDIDATE – integrační kandidát

Provider je považován za potenciálně použitelný a je připraven omezený test.

Vzniká:

- testovací konfigurace,
- bezpečný rozsah požadavků,
- ukázkový RAW payload,
- návrh parseru,
- návrh mapování,
- seznam očekávaných entit.

## 4.4 TESTING – technické ověření

Provider je testován v omezeném rozsahu.

Ověřuje se zejména:

- úspěšnost požadavků,
- stabilita odpovědí,
- kvalita identifikátorů,
- konzistence datových typů,
- stránkování,
- časová pásma,
- chybové odpovědi,
- reálná spotřeba request budgetu,
- opakovatelnost harvestu.

## 4.5 INTEGRATED – technicky integrován

Existuje použitelný worker, parser a staging cesta.

Stav `INTEGRATED` neznamená automaticky produkční připravenost. Musí být doloženo, že data bezpečně procházejí celým tokem.

## 4.6 VERIFIED – ověřen v cílovém rozsahu

Provider prošel definovaným end-to-end testem:

- API nebo zdroj,
- RAW,
- parser,
- staging,
- mapování,
- merge,
- cílová entita,
- audit výsledku.

Rozsah ověření musí být uveden. Ověření jednoho sportu nebo jedné entity nelze automaticky přenést na celý provider.

## 4.7 ACTIVE – aktivní provider

Provider je schválen pro běžné použití v přesně vymezeném rozsahu.

Musí být známo:

- pro které sporty je aktivní,
- pro které entity je aktivní,
- zda je primární nebo záložní,
- jaké má limity,
- jaké workery ho používají,
- jaké jsou jeho provozní kontroly.

## 4.8 LIMITED nebo HOLD

`LIMITED` znamená, že provider může být používán pouze v omezeném rozsahu.

`HOLD` znamená, že další použití nebo publikace výsledků je pozastavena, například kvůli:

- konfliktům dat,
- změně API,
- nejasné licenci,
- překročení limitů,
- nevyřešeným duplicitám,
- neověřenému mapování.

## 4.9 DEPRECATED a RETIRED

`DEPRECATED` označuje zdroj, který se již nemá používat pro nové integrace, ale může být dočasně zachován kvůli kompatibilitě.

`RETIRED` označuje ukončený zdroj, který není součástí aktivního provozu.

Historická data, mapování a auditní záznamy se nemažou bez řízeného rozhodnutí.

## 4.10 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala řízené stavy providera od DISCOVERED přes REVIEW, TESTING a ACTIVE až po DEPRECATED nebo RETIRED.

**Přínos pro projekt:** Životní cyklus odděluje pouhé objevení zdroje od technicky a provozně ověřeného použití.

**Návaznost na další kapitolu:** Následující kapitola stanovuje kritéria, podle kterých se provider hodnotí před zařazením do aktivního provozu.

---

# 5. Hodnocení providera

## 5.1 Datové pokrytí

Posuzuje se:

- počet podporovaných sportů,
- počet soutěží,
- geografické pokrytí,
- historická hloubka,
- aktuální sezony,
- předzápasová a živá data,
- dostupnost osob, médií a kurzů.

Pokrytí musí být hodnoceno po kombinacích:

```text
sport × provider × entita × sezona × region
```

Obecné tvrzení „provider sport podporuje“ není dostatečné.

## 5.2 Datová kvalita

Kontroluje se:

- úplnost,
- přesnost,
- stabilita identifikátorů,
- konzistence názvů,
- časová správnost,
- počet duplicit,
- chybovost mapování,
- výskyt neplatných hodnot,
- četnost oprav poskytovatele.

## 5.3 Provozní stabilita

Posuzuje se:

- dostupnost služby,
- latence,
- četnost výpadků,
- kvalita chybových kódů,
- změny dokumentace,
- zpětná kompatibilita,
- podpora retry,
- chování při rate limiting.

## 5.4 Ekonomická vhodnost

Sleduje se:

- cena tarifu,
- request budget,
- cena za širší historii,
- cena za živá data,
- cena za jednotlivé sporty nebo entity,
- riziko budoucího zdražení,
- možnost kombinace s jiným providerem.

## 5.5 Právní a licenční vhodnost

Musí být známo:

- zda je povoleno data ukládat,
- zda je povoleno je dlouhodobě archivovat,
- zda je povoleno je zobrazovat uživatelům,
- zda je povoleno je kombinovat s jinými zdroji,
- zda je vyžadována atribuce,
- zda existují omezení pro fotografie nebo média,
- zda jsou pravidla slučitelná s obchodním modelem MatchMatrix.

## 5.6 Dokumentační kvalita a podpora

Hodnotí se:

- úplnost API dokumentace,
- dostupnost příkladů,
- changelog,
- verze API,
- rychlost podpory,
- transparentnost incidentů,
- oznámení plánovaných změn.

## 5.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila hodnocení datového pokrytí, kvality, stability, ekonomiky, licencí a dokumentační podpory providera.

**Přínos pro projekt:** MatchMatrix může rozhodovat o použití providera na základě doložené kombinace technických, provozních, právních a ekonomických kritérií.

**Návaznost na další kapitolu:** Následující kapitola popisuje standardní technickou integrační cestu providerových dat.

---

# 6. Technická integrační cesta

## 6.1 Přehled toku

Standardní tok providerových dat je:

```text
PROVIDER
→ REQUEST / PULL
→ RAW PAYLOAD
→ PARSER
→ PROVIDER-NORMALIZED STAGING
→ PROVIDER MAP
→ VALIDACE
→ MERGE
→ PUBLIC / CÍLOVÁ VRSTVA
→ POST-IMPORT VERIFICATION
```

Žádný nový provider nemá zapisovat přímo do kanonických tabulek bez řízené integrační vrstvy.

## 6.2 Request a Pull

Worker sestaví požadavek podle:

- providera,
- sportu,
- entity,
- sezony,
- stránky,
- priority,
- request budgetu.

Požadavek a jeho výsledek musí být provozně dohledatelné.

## 6.3 RAW payload

RAW vrstva uchovává původní odpověď zdroje v nezměněné nebo technicky bezpečně zabalené podobě.

RAW slouží pro:

- audit,
- opakovaný parsing,
- diagnostiku,
- porovnání změn API,
- doložení původu dat.

## 6.4 Parser

Parser převádí providerovou strukturu do interního formátu.

Provádí zejména:

- převod datových typů,
- normalizaci času,
- sjednocení textu,
- extrakci providerových ID,
- validaci povinných polí,
- vytvoření staging záznamu,
- zachycení neznámých hodnot.

## 6.5 Staging

Staging je bezpečná přípravná vrstva.

Záznam ve stagingu ještě není automaticky kanonickým záznamem. Může čekat na:

- mapování,
- kontrolu identity,
- doplnění vazeb,
- řešení konfliktu,
- merge.

## 6.6 Provider map

Provider map propojuje externí identifikátor s kanonickou entitou.

Každá vazba musí být jednoznačná v kontextu:

- providera,
- sportu,
- typu entity,
- externího ID.

Mapování nesmí být vytvářeno pouze podle názvu bez dalších kontrolních znaků.

## 6.7 Merge

Merge rozhoduje, zda:

- vzniká nová kanonická entita,
- aktualizuje se existující entita,
- data pouze doplňují chybějící atribut,
- vzniká konflikt,
- je nutný stav HOLD,
- je nutná ruční kontrola.

## 6.8 Post-import verification

Po merge musí následovat ověření skutečného výsledku.

Kontrola má porovnat:

- očekávaný počet,
- skutečný počet,
- nové vazby,
- konflikty,
- duplicity,
- chybějící entity,
- změnu stavu cílové vrstvy.

## 6.9 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola popsala standardní tok od požadavku a RAW payloadu přes parser, staging a provider map až po merge a kontrolu po importu.

**Přínos pro projekt:** Řízená integrační cesta chrání kanonická data před přímým a neověřeným zápisem z externího zdroje.

**Návaznost na další kapitolu:** Následující kapitola popisuje rozhodování o tom, který provider se použije pro konkrétní sport, entitu a provozní režim.

---

# 7. Směrování, priority a záložní zdroje

## 7.1 Směrování podle entity

Provider se nevybírá pouze podle sportu.

Směrování má používat kombinaci:

```text
sport + entita + sezona + region + režim + požadovaná čerstvost
```

Jeden provider může být vhodný pro zápasy, jiný pro hráče a další pro fotografie nebo kurzy.

## 7.2 Primární provider

Primární provider je preferovaný zdroj pro vymezenou kombinaci.

Primární status musí být založen na doloženém hodnocení, nikoli pouze na tom, že byl integrován jako první.

## 7.3 Sekundární provider

Sekundární provider může sloužit pro:

- doplnění chybějících dat,
- kontrolní porovnání,
- náhradu při výpadku,
- širší historii,
- specifickou entitu,
- řešení regionálních mezer.

## 7.4 Fallback

Fallback cesta se aktivuje pouze podle definovaných pravidel.

Typické důvody:

- nedostupnost primárního API,
- vyčerpaný limit,
- chybějící entita,
- neúplný payload,
- známá chyba providera,
- dočasný stav HOLD.

Fallback nesmí vytvářet duplicitní harvest nebo nekontrolované přepisování kvalitnějších dat.

## 7.5 Kombinace více providerů

Víceproviderový model umožňuje sestavit úplnější entitu z více zdrojů.

Při kombinaci musí být pro každý atribut známo:

- zdroj,
- datum získání,
- priorita,
- důvěryhodnost,
- pravidlo přepsání,
- pravidlo konfliktu.

## 7.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila směrování podle sportu, entity, sezony, regionu a čerstvosti a vymezila roli primárních, sekundárních a záložních zdrojů.

**Přínos pro projekt:** MatchMatrix může využívat silné stránky více providerů bez nekontrolovaných duplicit a bez závislosti na jediném zdroji.

**Návaznost na další kapitolu:** Následující kapitola stanovuje provozní dohled, metriky a stavové kategorie Provider Health Monitoringu.

---

# 8. Provider Health Monitoring

## 8.1 Účel

Provider Health Monitoring sleduje, zda je provider skutečně použitelný v běžném provozu.

Nestačí ověřit, že endpoint odpovídá. Je nutné sledovat kvalitu celého toku až po cílovou databázovou vrstvu.

## 8.2 Základní provozní ukazatele

Sledují se zejména:

- dostupnost,
- úspěšnost požadavků,
- průměrná a maximální latence,
- počet odpovědí `429`,
- počet odpovědí `5xx`,
- počet prázdných payloadů,
- změny struktury odpovědi,
- úspěšnost parseru,
- počet staging záznamů,
- úspěšnost mapování,
- úspěšnost merge,
- počet konfliktů,
- čas od posledních čerstvých dat.

## 8.3 Stavové kategorie

Doporučené provozní stavy:

| Stav | Význam |
|---|---|
| HEALTHY | Provider i navazující tok fungují v očekávaném rozsahu. |
| DEGRADED | Data jsou dostupná, ale část kvality nebo výkonu je zhoršena. |
| RATE_LIMITED | Další provoz je omezen request budgetem nebo limitem API. |
| PARTIAL | Funguje pouze část sportů, entit nebo endpointů. |
| FAILED | Běh skončil chybou a nevytvořil použitelný výsledek. |
| HOLD | Provoz je pozastaven rozhodnutím governance nebo operátora. |
| UNKNOWN | Stav nelze spolehlivě určit. |

## 8.4 Alerty

Alert má vzniknout pouze tehdy, když je možné určit:

- co se změnilo,
- jaký je dopad,
- kterého sportu nebo entity se problém týká,
- zda existuje fallback,
- jaký je doporučený zásah.

Pouhé technické selhání bez kontextu nemá být prezentováno jako dostatečný provozní závěr.

## 8.5 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala sledování dostupnosti, chybovosti, limitů, parserů, mapování, merge a čerstvosti providerových dat.

**Přínos pro projekt:** Health monitoring propojuje technickou dostupnost API se skutečnou použitelností dat v cílových vrstvách.

**Návaznost na další kapitolu:** Následující kapitola stanovuje governance, bezpečnost a změnové řízení providerové oblasti.

---

# 9. Provider Governance a bezpečnost

## 9.1 Schválení změn

Změny s dopadem na aktivní providerový tok musí být řízené.

To se týká zejména:

- nového providera,
- nového tarifu,
- změny endpointu,
- změny parseru,
- změny mapování,
- změny priority,
- změny fallbacku,
- změny licenčních podmínek.

## 9.2 Správa tajných údajů

API klíče, tokeny a přihlašovací údaje:

- nesmí být ukládány do dokumentace,
- nesmí být commitovány do Git repozitáře,
- nesmí být zapisovány do běžných logů,
- musí být odděleny od zdrojového kódu,
- musí být spravovány podle principu minimálního oprávnění.

## 9.3 Změny API

Každá významná změna API musí být posouzena z hlediska:

- kompatibility parseru,
- nových nebo odstraněných polí,
- změn datových typů,
- změn ID,
- změn stránkování,
- změn limitů,
- dopadu na historická data.

## 9.4 Licence a podmínky použití

Provider nesmí být používán mimo schválený právní a obchodní rozsah.

Nejasné podmínky vedou ke stavu REVIEW nebo HOLD, nikoli k automatickému produkčnímu použití.

## 9.5 Ukončení providera

Při ukončení se musí určit:

- náhradní zdroj,
- dopad na aktivní workery,
- dopad na historii,
- zachování provider map,
- zachování auditní stopy,
- archivace konfigurace,
- odstranění aktivních tajných údajů.

## 9.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila pravidla pro schvalování změn, ochranu tajných údajů, změny API, licence a řízené ukončení providera.

**Přínos pro projekt:** Governance omezuje technická, právní a provozní rizika spojená s externími zdroji.

**Návaznost na další kapitolu:** Následující kapitola popisuje vztah providerových dat ke kanonickým identitám a prevenci duplicit.

---

# 10. Providerová data a kanonická identita

## 10.1 Kanonická entita

Kanonická entita představuje oficiální interní reprezentaci reálného objektu.

Může jít například o:

- soutěž,
- sezonu,
- tým,
- hráče,
- trenéra,
- stadion,
- zápas,
- článek,
- fotografii,
- sázkový trh.

## 10.2 Alternativní názvy

Providerové názvy jsou vedeny jako zdrojové nebo alternativní názvy, nikoli jako důvod ke vzniku nové identity.

Párování může používat:

- provider ID,
- aliasy,
- sport,
- zemi,
- soutěž,
- sezonu,
- datum,
- účastníky,
- další doménové znaky.

## 10.3 Prevence duplicit

Nový provider zvyšuje riziko duplicit.

Před vytvořením nové kanonické entity musí systém prověřit:

- existující provider map,
- přesné aliasy,
- podobnost názvu,
- shodu sportu,
- shodu země nebo regionu,
- shodu soutěže,
- časovou a vztahovou konzistenci.

## 10.4 Konflikty

Konflikt vzniká, když dva nebo více zdrojů poskytují neslučitelné údaje.

Výsledek se nesmí rozhodnout pouze podle pořadí importu.

Používají se:

- priorita zdroje,
- čerstvost,
- autorita pro konkrétní atribut,
- historická spolehlivost,
- ruční rozhodnutí,
- stav HOLD.

## 10.5 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola popsala kanonické entity, alternativní názvy, prevenci duplicit a řešení konfliktů mezi zdroji.

**Přínos pro projekt:** Providerové mapování umožňuje kombinovat více zdrojů bez rozmnožování kanonických entit a bez rozhodování pouze podle pořadí importu.

**Návaznost na další kapitolu:** Následující kapitola vymezuje dokumentační model oblasti 05_PROVIDERS a její navazující dokumenty.

---

# 11. Dokumentační model oblasti 05_PROVIDERS

`MM-PRV-001` je hlavní vstupní dokument providerové oblasti.

Další dokumenty mají rozdělit stabilní pravidla od často měněných provozních údajů.

## 11.1 Doporučené navazující dokumenty

| Document ID | Pracovní název | Účel |
|---|---|---|
| MM-PRV-002 | Životní cyklus a schvalování providerů | Podrobný workflow od objevení po ACTIVE nebo RETIRED. |
| MM-PRV-003 | Provider routing a fallback | Pravidla směrování podle sportu, entity a režimu. |
| MM-PRV-004 | Provider health monitoring | Metriky, stavy, alerty a provozní zásahy. |
| MM-PRV-005 | Integrace providerů do datových vrstev | Technický tok RAW, parser, staging, mapování a merge. |
| MM-PRV-006 | Právní a licenční řízení providerů | Licence, podmínky použití, atribuce a omezení. |

Číslování je návrh pro další řízenou tvorbu dokumentace. Každý nový dokument musí být před založením ověřen proti aktuálnímu indexu.

## 11.2 Referenční katalog

Přesný seznam konkrétních providerů, tarifů, endpointů, pokrytí a provozních stavů má být veden v samostatném referenčním dokumentu.

Tím se zabrání tomu, aby změna tarifu nebo aktuální dostupnosti vyžadovala přepis stabilního architektonického dokumentu.

## 11.3 Vazby na existující dokumentaci

| Dokument | Vazba |
|---|---|
| MM-DOC-100 | Celkový technický stav a priority projektu. |
| MM-DOC-200 | Provider Governance, Source Governance a auditní pravidla. |
| MM-DOC-300 | Víceproviderová architektura, harvest, parser, staging a merge. |
| MM-DOC-800 | Vývojové a provozní postupy, retry a monitoring. |
| MM-DB-001 | Databázové principy a odpovědnosti datových vrstev. |
| MM-DB-002 | Schémata a struktury používané providerovými toky. |
| MM-DB-003 | Datový slovník tabulek a sloupců. |
| MM-REF-001 | Jednotné české překlady odborných pojmů. |
| MM-REF-002 | Výklady pojmů a klikací navigace. |

## 11.4 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila roli MM-PRV-001, navrhla navazující providerové dokumenty a oddělila stabilní pravidla od průběžně měněného katalogu providerů.

**Přínos pro projekt:** Dokumentace může být rozvíjena bez duplicit a bez nutnosti přepisovat stabilní architekturu při každé změně tarifu nebo dostupnosti zdroje.

**Návaznost na další kapitolu:** Následující kapitola shrnuje aktuální stav a cílový rozvoj providerového ekosystému.

---

# 12. Aktuální stav a cílový rozvoj

## 12.1 Aktuální stav

MatchMatrix již používá víceproviderovou architekturu napříč různými sporty a typy entit.

V projektu existují:

- providerové konfigurace,
- specializované workery,
- RAW a staging toky,
- provider mapy,
- merge procesy,
- audity datového pokrytí,
- kontroly kvality a duplicit,
- počáteční provider health monitoring,
- řízení harvest úloh přes planner.

Rozsah implementace není u všech sportů a entit stejný. Stav musí být proto vždy vyhodnocován pro konkrétní kombinaci sportu, providera a entity.

## 12.2 Krátkodobé cíle

Krátkodobým cílem je:

- dokončit dokumentaci providerové oblasti,
- sjednotit evidenci providerů,
- zpřesnit aktivní a záložní mapování,
- doplnit stavové kategorie,
- sjednotit provider health monitoring,
- propojit providerové audity s řídicím panelem,
- připravit bezpečné spuštění rozsáhlých historických harvestů.

## 12.3 Střednědobé cíle

Střednědobým cílem je:

- automatické hodnocení kvality providerů,
- automatické směrování podle entity,
- řízený fallback,
- sledování spotřeby tarifů,
- včasná detekce změn API,
- doporučování vhodného zdroje podle pokrytí a ceny.

## 12.4 Dlouhodobý cíl

Dlouhodobým cílem je autonomní, ale auditovatelný providerový ekosystém.

Systém má samostatně:

- plánovat běžné harvesty,
- vyhodnocovat stav providerů,
- volit bezpečnou trasu,
- opakovat dočasně neúspěšné úlohy,
- zastavovat rizikové toky,
- upozorňovat operátora pouze na výjimky a strategická rozhodnutí.

## 12.5 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola shrnula existující víceproviderovou architekturu a stanovila krátkodobé, střednědobé a dlouhodobé cíle jejího rozvoje.

**Přínos pro projekt:** Projekt získává jasný směr od současných integračních prvků k autonomnímu, ale auditovatelnému providerovému ekosystému.

**Návaznost na další kapitolu:** Následující kapitola převádí požadavky dokumentu do kontrolních kritérií před schválením a publikací.

---

# 13. Kontrolní kritéria dokumentu

Dokument lze předložit ke schválení, pokud je potvrzeno:

- [ ] Document ID a cílové umístění odpovídají MM-STD-007.
- [ ] Terminologie odpovídá MM-REF-001 a MM-REF-002.
- [ ] Dokument neobsahuje tajné údaje ani API klíče.
- [ ] Dokument neuvádí neověřené tvrzení jako produkční skutečnost.
- [ ] Aktuální stav je oddělen od cílového návrhu.
- [ ] Každá hlavní kapitola obsahuje závěr.
- [ ] Vazby na navazující dokumenty jsou uvedeny.
- [ ] Historie verzí je doplněna.
- [ ] A17 neobsahuje nevyřešený blokátor.
- [ ] A24 a A7 budou spuštěny až po schválení a Git commitu.

---

## 13.1 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola soustředila povinná kontrolní kritéria pro identitu dokumentu, terminologii, bezpečnost, oddělení skutečnosti od návrhu, závěry kapitol, vazby, historii verzí a publikační workflow.

**Přínos pro projekt:** Kontrolní seznam snižuje riziko schválení nebo importu dokumentu s chybějícími náležitostmi, tajnými údaji nebo nevyřešenými blokátory.

**Návaznost na další kapitolu:** Následující kapitola eviduje historii verzí dokumentu a umožňuje dohledat jeho vývoj před závěrečným shrnutím.

---

# 14. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-17 | DRAFT – NEEDS_USER_APPROVAL | První návrh hlavního dokumentu providerové oblasti MatchMatrix; doplněny samostatné závěry hlavních kapitol se shrnutím, přínosem a návazností. |

---

# Závěr dokumentu

`MM-PRV-001` definuje providerový ekosystém jako řízenou a auditovatelnou vrstvu mezi externími zdroji a kanonickými daty MatchMatrix.

Hlavním principem je nezávislost interního modelu na konkrétním providerovi. Providerová data musí procházet přes RAW, parser, staging, mapování, validaci a merge. Každý provider musí mít známý životní cyklus, rozsah použití, kvalitu, limity, provozní stav a pravidla náhrady.

Dokument vytváří výchozí rámec pro další dokumenty oblasti `05_PROVIDERS`, zejména pro životní cyklus providerů, routing, fallback, health monitoring a technickou integraci.
