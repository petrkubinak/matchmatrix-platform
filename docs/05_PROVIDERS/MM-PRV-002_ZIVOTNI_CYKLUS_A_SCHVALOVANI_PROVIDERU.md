# MM-PRV-002

# ŽIVOTNÍ CYKLUS A SCHVALOVÁNÍ PROVIDERŮ MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-002 |
| Document ID | MM-PRV-002 |
| Název dokumentu | Životní cyklus a schvalování providerů MatchMatrix |
| Typ dokumentu | PROVIDER_LIFECYCLE_AND_APPROVAL |
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
| Navazuje na | MM-PRV-001 |
| Související dokumenty | MM-DOC-100, MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DB-001, MM-DB-002, MM-DB-003, MM-REF-001, MM-REF-002 |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-008 |

---

# 1. Úvod

Tento dokument stanovuje podrobný životní cyklus providerů MatchMatrix od prvního objevení zdroje až po jeho aktivaci, omezení, pozastavení nebo úplné vyřazení.

Dokument rozvíjí rámec definovaný v `MM-PRV-001` a převádí obecné principy providerového ekosystému do konkrétního řízeného workflow.

Cílem je zabránit tomu, aby byl nový provider připojen pouze proto, že:

- nabízí technicky dostupné API,
- má atraktivní marketingový popis,
- poskytuje velký počet endpointů,
- je momentálně levný,
- byl nalezen dříve než jiný zdroj,
- jej lze rychle napojit na existující worker.

Provider smí být použit v produkčním rozsahu pouze tehdy, pokud je znám jeho účel, rozsah, kvalita, cena, právní použitelnost, technická stabilita, integrační cesta, rizika a způsob náhrady.

## 1.1 Účel dokumentu

Dokument definuje:

- stavy životního cyklu providera,
- povolené přechody mezi stavy,
- schvalovací brány,
- povinné důkazy,
- role a odpovědnosti,
- pravidla testování,
- pravidla aktivace,
- podmínky omezení nebo pozastavení,
- pravidla pravidelného přehodnocení,
- řízené ukončení providera,
- auditní stopu celého procesu.

## 1.2 Rozsah

Pravidla se vztahují na všechny zdroje používané nebo zvažované pro MatchMatrix, zejména:

- Core providery,
- People providery,
- Media providery,
- Odds providery,
- Knowledge providery,
- oficiální weby a datové zdroje,
- placená API,
- bezplatná API,
- partnerské datové kanály,
- souborové exporty,
- řízené webové zdroje,
- interně odvozené nebo agregované zdroje.

## 1.3 Co dokument neřeší

Dokument nevede:

- aktuální seznam konkrétních providerů,
- aktuální tarify,
- API klíče,
- hesla,
- endpointové konfigurace,
- provozní request budgety jednotlivých účtů,
- přesné implementační detaily všech workerů.

Tyto informace patří do referenčního katalogu, konfigurace, bezpečného úložiště tajných údajů a specializované technické dokumentace.

## 1.4 Základní pravidlo

Žádný provider není automaticky schválen pouze na základě technické dostupnosti.

Schválení vždy platí pro konkrétní rozsah:

```text
provider + sport + entita + sezona + region + režim + účel použití
```

Provider schválený pro fotbalové zápasy nemusí být schválen pro hráče, kurzy, fotografie ani jiné sporty.

## 1.5 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola vymezila účel, rozsah a hranice dokumentu a stanovila, že schválení providera musí být vždy omezeno na konkrétní datový a provozní rozsah.

**Přínos pro projekt:** MatchMatrix získává jednoznačné pravidlo, které odděluje technickou dostupnost zdroje od skutečného produkčního schválení.

**Návaznost na další kapitolu:** Následující kapitola definuje role a odpovědnosti používané při posuzování a schvalování providerů.

---

# 2. Role a odpovědnosti

Role v tomto dokumentu představují logické odpovědnosti. Nemusí vždy odpovídat samostatným pracovním pozicím. Jedna osoba může vykonávat více rolí, ale rozhodnutí a důkazy musí zůstat oddělené a dohledatelné.

## 2.1 Vlastník projektu

Vlastník projektu:

- schvaluje strategické použití providera,
- potvrzuje obchodní a rozpočtový dopad,
- schvaluje přechod do stavu `ACTIVE`,
- schvaluje zásadní změnu rozsahu,
- rozhoduje o přechodu do `HOLD`, `DEPRECATED` nebo `RETIRED`, pokud má změna strategický dopad,
- potvrzuje přijetí známých zbytkových rizik.

## 2.2 Provider Governance

Provider Governance:

- vede životní cyklus providera,
- kontroluje úplnost důkazů,
- navrhuje stavový přechod,
- eviduje rozsah schválení,
- sleduje revalidaci,
- vyhodnocuje dlouhodobou nahraditelnost,
- koordinuje rozhodnutí mezi technickou, datovou, provozní a právní oblastí.

## 2.3 Source Governance

Source Governance:

- prověřuje původ zdroje,
- eviduje podmínky použití,
- kontroluje licenční a publikační omezení,
- vyhodnocuje robots.txt nebo obdobná pravidla, pokud jsou relevantní,
- rozlišuje oficiální, partnerský, veřejný a neověřený zdroj,
- určuje, zda lze data ukládat, spojovat a publikovat.

## 2.4 Technický hodnotitel

Technický hodnotitel:

- ověřuje autentizaci,
- testuje endpointy,
- prověřuje stránkování,
- kontroluje časová pásma,
- sleduje chybové odpovědi,
- ověřuje změny struktury payloadu,
- hodnotí stabilitu API,
- navrhuje parser a integrační cestu,
- potvrzuje technickou opakovatelnost běhu.

## 2.5 Datový hodnotitel

Datový hodnotitel:

- ověřuje úplnost dat,
- prověřuje stabilitu identifikátorů,
- porovnává data s jinými zdroji,
- měří duplicity a konflikty,
- kontroluje mapování entit,
- vyhodnocuje použitelnost historie,
- potvrzuje kvalitu cílových záznamů po merge.

## 2.6 Provozní hodnotitel

Provozní hodnotitel:

- prověřuje běh workerů,
- hodnotí retry,
- sleduje request budget,
- ověřuje monitoring a alerty,
- hodnotí zatížení PC2 a databáze,
- potvrzuje obnovitelnost po výpadku,
- ověřuje chování při rate limiting.

## 2.7 Dokumentační a auditní kontrola

Dokumentační kontrola:

- ověřuje existenci povinných záznamů,
- kontroluje Document ID a vazby,
- potvrzuje, že jsou odděleny skutečnosti, návrhy a rozhodnutí,
- zajišťuje auditní dohledatelnost,
- kontroluje, že dokumentace neobsahuje tajné údaje.

## 2.8 Automatizované kontroly

Automatizované kontroly mohou:

- ověřovat dostupnost,
- měřit latenci,
- počítat úspěšnost požadavků,
- detekovat změnu schématu,
- měřit mapovací úspěšnost,
- hledat duplicity,
- kontrolovat post-importní rozdíly.

Automatizovaný výsledek nenahrazuje strategické, právní ani obchodní schválení.

## 2.9 Schvalovací odpovědnost

Finální schválení stavu `ACTIVE` musí být explicitní.

Za schválení se nepovažuje:

- vytvoření workeru,
- úspěšný test endpointu,
- zápis do stagingu,
- existence dat v databázi,
- dlouhodobé používání bez formálního rozhodnutí,
- absence nalezené chyby.

## 2.10 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola rozdělila odpovědnosti mezi vlastníka projektu, Provider Governance, Source Governance, technické, datové, provozní a dokumentační kontroly.

**Přínos pro projekt:** Rozhodnutí o providerovi není založeno na jediném technickém pohledu a lze dohledat, kdo ověřil jednotlivé části procesu.

**Návaznost na další kapitolu:** Následující kapitola definuje závazné stavy životního cyklu providera.

---

# 3. Stavový model životního cyklu

Každý provider musí mít právě jeden hlavní životní stav.

Stav nepopisuje pouze technickou dostupnost. Vyjadřuje celkovou připravenost providera v definovaném rozsahu.

## 3.1 Přehled stavů

| Stav | Český význam | Základní charakteristika |
|---|---|---|
| DISCOVERED | Objevený | Zdroj byl nalezen, ale nebyl posouzen. |
| REVIEW | Posuzovaný | Probíhá technické, datové, právní a obchodní posouzení. |
| CANDIDATE | Kandidát | Zdroj je vhodný pro omezený integrační test. |
| TESTING | Testovaný | Probíhá řízený technický a datový test. |
| INTEGRATED | Integrován | Existuje funkční integrační cesta, ale není potvrzena produkční kvalita. |
| VERIFIED | Ověřen | End-to-end test pro konkrétní rozsah byl úspěšně dokončen. |
| ACTIVE | Aktivní | Provider je schválen pro běžný provoz ve vymezeném rozsahu. |
| LIMITED | Omezený | Provider je použitelný pouze za stanovených omezení. |
| HOLD | Pozastavený | Použití je dočasně zastaveno nebo blokováno. |
| DEPRECATED | Určený k nahrazení | Nemá být používán pro nové rozšíření a směřuje k ukončení. |
| RETIRED | Vyřazený | Není součástí aktivního provozu. |
| REJECTED | Zamítnutý | Provider nebyl schválen pro zamýšlený rozsah. |

## 3.2 Stav DISCOVERED

Provider je evidován minimálně s těmito údaji:

- název,
- web nebo dokumentace,
- typ zdroje,
- podporované sporty,
- předpokládané entity,
- způsob přístupu,
- datum objevení,
- osoba nebo proces, který provider nalezl,
- předběžný důvod zájmu.

Ve stavu `DISCOVERED` se nesmí provider použít jako zdroj kanonických dat.

## 3.3 Stav REVIEW

Ve stavu `REVIEW` se prověřuje:

- technická dostupnost,
- obchodní model,
- licence,
- podmínky ukládání,
- podmínky publikace,
- historické pokrytí,
- čerstvost dat,
- kvalita dokumentace,
- stabilita společnosti nebo zdroje,
- známá omezení.

Provider může být ze stavu `REVIEW`:

- posunut do `CANDIDATE`,
- vrácen k doplnění,
- označen jako `REJECTED`,
- dočasně ponechán bez rozhodnutí.

## 3.4 Stav CANDIDATE

Stav `CANDIDATE` znamená, že provider prošel základním screeningem a smí být technicky testován.

Před testem musí být určeno:

- co se testuje,
- v jakém sportu,
- pro jakou entitu,
- v jaké sezoně,
- s jakým request budgetem,
- s jakým maximálním dopadem,
- kam budou data zapisována,
- jak budou testovací data odstraněna nebo archivována.

## 3.5 Stav TESTING

Ve stavu `TESTING` je povoleno:

- omezené stahování dat,
- ukládání RAW payloadů,
- tvorba parseru,
- zápis do testovací nebo staging vrstvy,
- řízené mapování,
- porovnání s kanonickými daty,
- měření kvality.

Není povoleno bez dalšího schválení:

- nekontrolované přepisování kanonických dat,
- hromadná publikace,
- spuštění neomezeného historického harvestu,
- automatické vytvoření velkého množství nových entit,
- odstranění dat jiného providera.

## 3.6 Stav INTEGRATED

Provider je `INTEGRATED`, pokud existuje:

- funkční request nebo pull proces,
- RAW uložení,
- parser,
- staging cesta,
- provider map,
- merge mechanismus nebo bezpečný návrh merge,
- základní logování,
- základní chybové ošetření.

Stav `INTEGRATED` nepotvrzuje datovou kvalitu ani produkční připravenost.

## 3.7 Stav VERIFIED

Provider je `VERIFIED`, pokud byla pro přesně popsaný rozsah ověřena celá cesta:

```text
zdroj
→ request
→ RAW
→ parser
→ staging
→ mapování
→ validace
→ merge
→ cílová vrstva
→ post-importní kontrola
```

Ověření musí obsahovat konkrétní důkazy a výsledky.

## 3.8 Stav ACTIVE

Provider je `ACTIVE`, pokud:

- je dokončen technický a datový test,
- jsou známé licence a omezení,
- je schválen rozsah použití,
- je nastavena priorita,
- je znám fallback nebo zdůvodněna jeho absence,
- je aktivní monitoring,
- je znám vlastník provozního rozhodnutí,
- jsou definovány podmínky pro omezení nebo HOLD.

## 3.9 Stav LIMITED

Provider se nastaví jako `LIMITED`, pokud je použitelný pouze:

- pro část sportů,
- pro část entit,
- pro omezenou historii,
- pro omezený tarif,
- jako sekundární zdroj,
- pouze pro doplňování,
- pouze pro ručně potvrzené použití,
- dočasně při známém problému.

Každé omezení musí být napsáno explicitně.

## 3.10 Stav HOLD

`HOLD` blokuje běžné použití.

Důvody mohou zahrnovat:

- právní nejistotu,
- změnu podmínek,
- nečekanou změnu API,
- vysoký počet konfliktů,
- nárůst duplicit,
- chybné mapování,
- nestabilní identifikátory,
- překročení nákladů,
- bezpečnostní incident,
- podezření na nekorektní data.

## 3.11 Stav DEPRECATED

Provider je `DEPRECATED`, pokud:

- existuje lepší náhrada,
- služba se dlouhodobě zhoršuje,
- provider není ekonomicky vhodný,
- stará verze API končí,
- data se již nemají rozšiřovat,
- aktivní použití se má řízeně utlumit.

## 3.12 Stav RETIRED

Provider je `RETIRED`, pokud:

- není používán aktivním workerem,
- neprobíhá nový harvest,
- není primárním ani fallback zdrojem,
- byly zneplatněny aktivní přístupové údaje,
- byla uzavřena provozní dokumentace,
- byly zachovány provider mapy a auditní historie.

## 3.13 Stav REJECTED

`REJECTED` znamená, že provider nebyl schválen pro hodnocený účel.

Důvod zamítnutí musí být uveden, například:

- nepoužitelná licence,
- nízká kvalita,
- nedostatečné pokrytí,
- vysoká cena,
- nestabilní API,
- chybějící dokumentace,
- nemožnost dlouhodobého ukládání,
- neakceptovatelné riziko.

`REJECTED` neznamená, že provider nelze nikdy znovu posoudit. Nové posouzení však musí uvést, co se změnilo.

## 3.14 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala dvanáct stavů od objevení po vyřazení nebo zamítnutí providera a vymezila jejich přesný význam.

**Přínos pro projekt:** Stav providera již nelze zaměnit s pouhou technickou funkčností endpointu nebo existencí workeru.

**Návaznost na další kapitolu:** Následující kapitola stanovuje povolené přechody mezi stavy a zakázané zkratky workflow.

---

# 4. Přechody mezi stavy

## 4.1 Standardní cesta

Doporučená standardní cesta je:

```text
DISCOVERED
→ REVIEW
→ CANDIDATE
→ TESTING
→ INTEGRATED
→ VERIFIED
→ ACTIVE
```

Každý přechod musí být podložen schvalovací bránou a důkazy.

## 4.2 Povolené boční přechody

Podle výsledku lze použít například:

```text
REVIEW → REJECTED
CANDIDATE → REVIEW
TESTING → CANDIDATE
TESTING → HOLD
INTEGRATED → TESTING
VERIFIED → LIMITED
ACTIVE → LIMITED
ACTIVE → HOLD
LIMITED → ACTIVE
LIMITED → HOLD
HOLD → TESTING
HOLD → LIMITED
HOLD → ACTIVE
ACTIVE → DEPRECATED
LIMITED → DEPRECATED
DEPRECATED → RETIRED
```

## 4.3 Zakázané zkratky

Bez výslovné výjimky se nesmí provést:

```text
DISCOVERED → ACTIVE
REVIEW → ACTIVE
CANDIDATE → ACTIVE
TESTING → ACTIVE
INTEGRATED → ACTIVE
REJECTED → ACTIVE
RETIRED → ACTIVE
```

Provider musí před stavem `ACTIVE` projít stavem `VERIFIED`.

## 4.4 Návrat do dřívější fáze

Návrat není selháním procesu.

Provider se vrací do dřívější fáze, pokud:

- nebyly splněny důkazy,
- změnil se rozsah,
- změnilo se API,
- test nebyl reprezentativní,
- byl nalezen konflikt,
- chybí právní potvrzení,
- je nutná změna parseru nebo mapování.

## 4.5 Opětovná aktivace

Provider ze stavu `HOLD`, `DEPRECATED` nebo `RETIRED` nesmí být aktivován bez nového posouzení.

Rozsah nového posouzení se určuje podle:

- délky odstávky,
- rozsahu změn,
- změny API,
- změny licence,
- změny datového modelu,
- změny obchodního modelu.

## 4.6 Rozsah stavového rozhodnutí

Stav může být veden:

- pro celý provider,
- pro konkrétní sport,
- pro konkrétní entitu,
- pro konkrétní endpoint,
- pro konkrétní tarif,
- pro konkrétní režim použití.

Pokud má provider různé stavy pro různé oblasti, musí být hlavní stav doplněn stavovou maticí.

## 4.7 Stavová matice

Příklad:

| Provider | Sport | Entita | Režim | Stav |
|---|---|---|---|---|
| Provider A | Football | Matches | Historical | ACTIVE |
| Provider A | Football | Players | Historical | LIMITED |
| Provider A | Hockey | Matches | Historical | TESTING |
| Provider A | Football | Odds | Live | REJECTED |

## 4.8 Stavový záznam

Každý přechod musí obsahovat:

- předchozí stav,
- nový stav,
- datum,
- rozsah,
- důvod,
- rozhodující důkazy,
- známá omezení,
- schvalující osobu nebo roli,
- odkaz na report nebo dokument.

## 4.9 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila standardní a boční stavové přechody, zakázané zkratky a pravidla opětovné aktivace.

**Přínos pro projekt:** Provider nemůže být neformálně přesunut do produkčního provozu bez předchozího ověření a dohledatelného rozhodnutí.

**Návaznost na další kapitolu:** Následující kapitola zavádí schvalovací brány, které jednotlivé stavové přechody řídí.

---

# 5. Schvalovací brány

Schvalovací brána představuje ověřitelný kontrolní bod.

Provider může přejít do dalšího stavu pouze tehdy, pokud je výsledek příslušné brány zaznamenán.

## 5.1 Přehled bran

| Brána | Přechod | Účel |
|---|---|---|
| G0 | Neevidovaný zdroj → DISCOVERED | Založení základního záznamu. |
| G1 | DISCOVERED → REVIEW | Potvrzení relevance pro projekt. |
| G2 | REVIEW → CANDIDATE | Základní technické, právní a obchodní posouzení. |
| G3 | CANDIDATE → TESTING | Schválení omezeného testu. |
| G4 | TESTING → INTEGRATED | Potvrzení funkční integrační cesty. |
| G5 | INTEGRATED → VERIFIED | Potvrzení end-to-end výsledku a datové kvality. |
| G6 | VERIFIED → ACTIVE nebo LIMITED | Produkční schválení konkrétního rozsahu. |
| G7 | ACTIVE/LIMITED → HOLD | Bezpečnostní nebo governance pozastavení. |
| G8 | ACTIVE/LIMITED → DEPRECATED | Zahájení řízeného nahrazení. |
| G9 | DEPRECATED → RETIRED | Úplné provozní ukončení. |

## 5.2 Brána G0 – Evidence

Povinné minimum:

- jednoznačný providerový záznam,
- název,
- web nebo dokumentace,
- typ dat,
- předpokládaný rozsah,
- datum objevení,
- zdroj informace.

Výsledek:

```text
DISCOVERED
```

## 5.3 Brána G1 – Relevance

Prověřuje se:

- zda provider řeší reálnou datovou potřebu,
- zda nepřináší pouze duplicitu bez přínosu,
- zda odpovídá prioritám projektu,
- zda je vhodný pro některou funkční kategorii,
- zda má smysl investovat čas do posouzení.

Výsledek:

```text
REVIEW nebo REJECTED
```

## 5.4 Brána G2 – Základní způsobilost

Musí být prověřeno:

- existence dokumentace,
- způsob přístupu,
- autentizace,
- podmínky použití,
- možnost ukládání,
- možnost publikace,
- cena nebo tarif,
- rate limit,
- historický rozsah,
- podporované sporty a entity,
- známá rizika.

Výsledek:

```text
CANDIDATE, REVIEW nebo REJECTED
```

## 5.5 Brána G3 – Povolení testu

Testovací plán musí obsahovat:

- testovaný rozsah,
- maximální počet požadavků,
- vybrané endpointy,
- testovací sport,
- testovací sezonu,
- cílovou staging vrstvu,
- způsob logování,
- očekávané metriky,
- stop podmínky,
- dobu testu.

Výsledek:

```text
TESTING
```

## 5.6 Brána G4 – Integrační připravenost

Musí existovat:

- request nebo pull proces,
- RAW uložení,
- parser,
- staging zápis,
- základní validace,
- provider ID,
- mapovací mechanismus,
- chybové ošetření,
- opakovatelný běh,
- technický report.

Výsledek:

```text
INTEGRATED nebo návrat do TESTING
```

## 5.7 Brána G5 – Ověření kvality

Musí být doloženo:

- reprezentativní testovací období,
- očekávaný a skutečný počet záznamů,
- úspěšnost parseru,
- úspěšnost mapování,
- počet duplicit,
- počet konfliktů,
- počet záznamů v HOLD,
- post-importní rozdíl,
- kontrola kanonických entit,
- kontrola historického rozsahu,
- známé mezery.

Výsledek:

```text
VERIFIED, LIMITED, HOLD nebo návrat do TESTING
```

## 5.8 Brána G6 – Produkční schválení

Produkční rozhodnutí musí určit:

- schválený sport,
- schválené entity,
- schválené sezony nebo historii,
- schválený region,
- primární nebo sekundární roli,
- prioritu zdroje,
- pravidlo fallbacku,
- frekvenci běhu,
- request budget,
- monitoring,
- revalidační termín,
- známá zbytková rizika.

Výsledek:

```text
ACTIVE nebo LIMITED
```

## 5.9 Brána G7 – Pozastavení

`HOLD` může být vyvolán okamžitě, pokud hrozí:

- poškození dat,
- právní problém,
- bezpečnostní problém,
- nekontrolovaný nárůst nákladů,
- velké množství duplicit,
- chybný merge,
- závažná změna API,
- ztráta důvěryhodnosti zdroje.

Pozastavení má přednost před kontinuitou harvestu.

## 5.10 Brána G8 – Nahrazení

Před stavem `DEPRECATED` se stanoví:

- náhradní provider,
- migrační plán,
- dopad na data,
- dopad na mapování,
- dopad na workery,
- termín ukončení,
- zachování historie.

## 5.11 Brána G9 – Vyřazení

Před stavem `RETIRED` musí být potvrzeno:

- vypnutí aktivních běhů,
- ukončení plánovače,
- deaktivace přístupových údajů,
- zachování auditních záznamů,
- zachování provider map,
- archivace dokumentace,
- absence aktivního fallback odkazu.

## 5.12 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala deset schvalovacích bran od prvního založení záznamu po úplné vyřazení providera.

**Přínos pro projekt:** Každý významný stavový přechod má konkrétní účel, povinné důkazy a jednoznačný výsledek.

**Návaznost na další kapitolu:** Následující kapitola rozepisuje povinné důkazy a dokumenty, které musí workflow vytvářet.

---

# 6. Povinné důkazy a dokumentace

## 6.1 Princip dostatečného důkazu

Rozhodnutí nesmí být založeno pouze na větě „funguje“.

Důkaz musí být:

- konkrétní,
- opakovatelný,
- časově označený,
- spojený s rozsahem,
- dohledatelný,
- přiměřený riziku.

## 6.2 Základní providerový záznam

Minimální pole:

| Pole | Význam |
|---|---|
| Provider ID | Interní identifikátor providera. |
| Název | Oficiální nebo používaný název. |
| Kategorie | Core, People, Media, Odds, Knowledge nebo oficiální zdroj. |
| Web | Hlavní adresa zdroje. |
| Dokumentace | Adresa dokumentace nebo popis přístupu. |
| Obchodní model | Free, trial, placený, partnerský nebo jiný. |
| Licence | Zjištěný stav podmínek. |
| Stav | Aktuální životní stav. |
| Rozsah | Sporty, entity, sezony, regiony a režimy. |
| Vlastník | Odpovědná role. |
| Poslední kontrola | Datum posledního ověření. |
| Další kontrola | Datum plánované revalidace. |

## 6.3 Technický report

Technický report má obsahovat:

- použité endpointy,
- datum testu,
- autentizaci bez uvedení tajných hodnot,
- parametry,
- stránkování,
- počet requestů,
- úspěšnost,
- chybové kódy,
- latenci,
- změny schématu,
- velikost payloadů,
- limity,
- retry chování,
- závěr.

## 6.4 Datový report

Datový report má obsahovat:

- počet přijatých záznamů,
- počet platných záznamů,
- počet odmítnutých záznamů,
- počet nových entit,
- počet spárovaných entit,
- počet nespárovaných entit,
- počet duplicit,
- počet konfliktů,
- rozsah historie,
- chybějící období,
- porovnání s jiným zdrojem,
- reprezentativní vzorky.

## 6.5 Právní a licenční záznam

Musí být zachyceno:

- zda lze data získávat,
- zda lze data ukládat,
- zda lze data dlouhodobě archivovat,
- zda lze data kombinovat,
- zda lze data zveřejňovat,
- zda je vyžadována atribuce,
- zda existují omezení médií,
- zda existují geografická omezení,
- datum kontroly podmínek.

Pokud není výsledek jasný, provider nesmí být `ACTIVE` bez explicitně přijatého rozhodnutí.

## 6.6 Obchodní záznam

Obsahuje:

- tarif,
- cenu,
- fakturační období,
- request budget,
- cenu překročení,
- omezení historie,
- omezení live dat,
- výpovědní podmínky,
- známé riziko zdražení,
- odhad celkových nákladů.

## 6.7 Integrační záznam

Obsahuje:

- worker,
- parser,
- RAW umístění,
- staging tabulky,
- provider map,
- merge cestu,
- konfiguraci bez tajných hodnot,
- logy,
- monitoring,
- restart a retry postup,
- rollback cestu.

## 6.8 Schvalovací záznam

Každé schválení obsahuje:

- stav před,
- stav po,
- datum,
- rozsah,
- schvalující osobu,
- odkazy na důkazy,
- známá omezení,
- termín další kontroly,
- poznámku o fallbacku.

## 6.9 Důkazy podle rizika

Čím vyšší riziko, tím rozsáhlejší musí být důkaz.

Riziko zvyšuje zejména:

- přímý dopad na kanonická data,
- vysoký objem historie,
- drahý tarif,
- živá data,
- kurzy,
- média,
- osobní údaje,
- právně nejasný zdroj,
- automatické vytváření entit,
- složitý merge.

## 6.10 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila povinné providerové, technické, datové, právní, obchodní, integrační a schvalovací záznamy.

**Přínos pro projekt:** Rozhodnutí lze zpětně ověřit a není závislé na paměti konkrétní osoby nebo na existenci jednoho skriptu.

**Návaznost na další kapitolu:** Následující kapitola stanovuje způsob hodnocení rizika a přiměřenost kontrol.

---

# 7. Rizikové třídy providerů

## 7.1 Účel rizikové klasifikace

Ne každý provider vyžaduje stejný rozsah kontroly.

Riziková třída určuje:

- hloubku testu,
- počet důkazů,
- četnost revalidace,
- požadovaný monitoring,
- nutnost fallbacku,
- úroveň schválení.

## 7.2 Třída R1 – Nízké riziko

Typické vlastnosti:

- referenční doplňkový zdroj,
- malý objem dat,
- žádný přímý přepis kanonických údajů,
- snadno ověřitelná data,
- žádné live použití,
- nízké náklady,
- jasné podmínky použití.

Příklad použití:

- doplnění oficiálního webu,
- doplnění alternativního názvu,
- pomocný znalostní údaj.

## 7.3 Třída R2 – Střední riziko

Typické vlastnosti:

- běžná sportovní data,
- pravidelné harvesty,
- staging a merge,
- omezené vytváření nových entit,
- známé licence,
- přiměřené náklady.

Příklad použití:

- zápasy,
- týmy,
- soutěže,
- sezony.

## 7.4 Třída R3 – Vysoké riziko

Typické vlastnosti:

- rozsáhlé historické harvesty,
- automatické vytváření entit,
- složité mapování,
- vysoký finanční závazek,
- významný dopad na produkt,
- live nebo časově citlivá data,
- média s licenčními omezeními.

Příklad použití:

- hráčské profily,
- fotografie,
- rozsáhlá historie,
- kurzy.

## 7.5 Třída R4 – Kritické riziko

Typické vlastnosti:

- právní nebo licenční nejistota,
- nevratné přepisy,
- bezpečnostní riziko,
- neomezený autonomní provoz,
- zásadní závislost platformy,
- vysoké náklady bez rychlé náhrady,
- potenciál rozsáhlého poškození kanonických dat.

Provider R4 nesmí být aktivován bez explicitního strategického schválení a přesně popsaného rollbacku.

## 7.6 Orientační rizikové faktory

| Faktor | Nízký | Střední | Vysoký |
|---|---|---|---|
| Objem dat | Malý | Střední | Velký |
| Frekvence | Jednorázová | Denní | Live nebo velmi častá |
| Merge | Bez merge | Řízený merge | Složitý nebo automatický |
| Licence | Jasná | Omezená | Nejasná |
| Cena | Nízká | Střední | Vysoká |
| Náhrada | Snadná | Dostupná | Obtížná |
| Dopad chyby | Lokální | Významný | Celoplatformní |
| Historie | Krátká | Několik sezon | Desítky let |

## 7.7 Revalidační frekvence

Doporučený interval:

| Riziková třída | Revalidace |
|---|---|
| R1 | nejméně jednou ročně nebo při změně zdroje |
| R2 | nejméně jednou za 6 měsíců |
| R3 | nejméně jednou za 3 měsíce |
| R4 | průběžně a při každé významné změně |

## 7.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola rozdělila providery do čtyř rizikových tříd podle objemu, frekvence, merge, licence, ceny, nahraditelnosti a dopadu chyby.

**Přínos pro projekt:** Rozsah kontrol odpovídá reálnému riziku a nevede ani k nedostatečnému ověření, ani k neúčelnému přetěžování jednoduchých zdrojů.

**Návaznost na další kapitolu:** Následující kapitola stanovuje podrobný testovací proces pro stav CANDIDATE a TESTING.

---

# 8. Testovací proces providera

## 8.1 Testovací plán

Každý test musí mít předem určený plán.

Plán obsahuje:

- cíl,
- hypotézu,
- rozsah,
- sport,
- entity,
- sezonu,
- region,
- endpointy,
- počet požadavků,
- dobu běhu,
- cílové vrstvy,
- metriky,
- kritéria úspěchu,
- stop podmínky.

## 8.2 Reprezentativní vzorek

Vzorek musí odpovídat budoucímu použití.

Není dostačující testovat pouze:

- jednu populární soutěž,
- jeden úspěšný endpoint,
- několik ručně vybraných týmů,
- krátké období bez chyb,
- data, která provider používá v dokumentaci jako ukázku.

## 8.3 Test technické stability

Ověřuje se:

- opakovaný běh,
- stránkování,
- timeout,
- retry,
- rate limit,
- neplatný požadavek,
- prázdná odpověď,
- částečná odpověď,
- změna pořadí polí,
- chybějící pole,
- nestandardní znaky,
- časová pásma,
- velký payload.

## 8.4 Test datové kvality

Ověřuje se:

- úplnost,
- přesnost,
- unikátnost,
- konzistence,
- čerstvost,
- historická návaznost,
- stabilita ID,
- mapovatelnost,
- správnost vazeb,
- správnost výsledků,
- shoda s nezávislým zdrojem.

## 8.5 Test identity

Pro týmy, hráče, soutěže a další entity se prověřuje:

- externí ID,
- alternativní názvy,
- země,
- sport,
- soutěž,
- sezona,
- datum narození nebo založení,
- vztah k jiným entitám,
- změny názvu,
- slučování a rozdělování entit.

## 8.6 Test historie

Historický test ověřuje:

- nejstarší dostupný rok,
- mezery mezi sezonami,
- úplnost jednotlivých sezon,
- změny formátu starších dat,
- chybějící výsledky,
- změny identifikátorů,
- historické přejmenování soutěží a týmů.

## 8.7 Test výkonu a nákladů

Měří se:

- počet requestů na jednotku výsledku,
- doba zpracování,
- spotřeba request budgetu,
- spotřeba CPU,
- spotřeba RAM,
- velikost RAW dat,
- velikost stagingu,
- očekávaná cena plného harvestu.

## 8.8 Stop podmínky

Test se musí zastavit při:

- nekontrolovaném růstu requestů,
- opakovaných chybách autentizace,
- podezření na porušení podmínek,
- neočekávaném zápisu do kanonické vrstvy,
- výrazném nárůstu duplicit,
- nekonzistentním mapování,
- překročení testovacího rozpočtu,
- ohrožení stabilního provozu.

## 8.9 Výsledek testu

Výsledek musí být jeden z těchto:

- `TEST PASSED`,
- `TEST PASSED WITH LIMITATIONS`,
- `RETEST REQUIRED`,
- `TEST BLOCKED`,
- `TEST FAILED`.

Výsledek musí obsahovat doporučený další stav.

## 8.10 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila testovací plán, reprezentativní vzorek, technické, datové, identitní, historické, výkonnostní a nákladové testy.

**Přínos pro projekt:** Provider se nehodnotí podle jedné úspěšné odpovědi, ale podle opakovatelného testu odpovídajícího budoucímu použití.

**Návaznost na další kapitolu:** Následující kapitola popisuje produkční aktivaci a omezení schváleného rozsahu.

---

# 9. Produkční aktivace

## 9.1 Aktivace není technický příkaz

Produkční aktivace je governance rozhodnutí.

Technický příkaz může:

- zapnout worker,
- přidat plán,
- zvýšit rozsah,
- aktivovat merge.

Samotný příkaz však nesmí předcházet schválení G6.

## 9.2 Povinné údaje aktivace

Aktivační záznam musí obsahovat:

- provider,
- sport,
- entity,
- sezony,
- region,
- režim,
- prioritu,
- primární nebo sekundární roli,
- fallback,
- plánovací frekvenci,
- request budget,
- limit nákladů,
- cílové tabulky,
- monitoring,
- odpovědnou roli,
- datum další kontroly.

## 9.3 Postupná aktivace

Doporučuje se:

1. malý rozsah,
2. omezený počet soutěží,
3. omezené období,
4. kontrola výsledku,
5. rozšíření,
6. další kontrola,
7. plný schválený rozsah.

## 9.4 Oddělení harvestu a merge

Lze schválit:

- harvest bez merge,
- RAW a staging bez publikace,
- merge pouze pro existující entity,
- merge s vytvářením nových entit,
- publikaci pouze vybraných atributů.

Tyto režimy se nesmí zaměňovat.

## 9.5 Fallback při aktivaci

Musí být známo:

- zda fallback existuje,
- kdy se aktivuje,
- co smí nahradit,
- jak zabrání duplicitám,
- zda má stejnou autoritu,
- jak se návrat k primárnímu zdroji provede.

## 9.6 Kontrola po aktivaci

Po první aktivaci se provádí rozšířená kontrola:

- první běh,
- první den,
- první úplný cyklus,
- první týden,
- první dosažení limitu,
- první chybový stav.

## 9.7 Podmíněná aktivace

Provider může být `LIMITED`, pokud:

- chybí fallback,
- část historie není ověřena,
- některé entity mají slabé mapování,
- licence omezuje publikaci,
- tarif omezuje frekvenci,
- monitoring ještě není plně automatizován.

## 9.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila povinné údaje produkční aktivace, postupné rozšiřování, oddělení harvestu a merge a kontrolu po prvním spuštění.

**Přínos pro projekt:** Aktivace je řízené rozhodnutí s omezeným dopadem, nikoli jednorázové zapnutí workeru bez následné kontroly.

**Návaznost na další kapitolu:** Následující kapitola stanovuje průběžný monitoring a pravidelnou revalidaci aktivních providerů.

---

# 10. Průběžný monitoring a revalidace

## 10.1 Průběžný dohled

Aktivní provider musí být sledován nejméně v oblastech:

- dostupnost,
- latence,
- chybovost,
- rate limit,
- parser,
- staging,
- mapování,
- merge,
- duplicity,
- konflikty,
- čerstvost,
- náklady.

## 10.2 Revalidace

Revalidace není nový úplný onboarding, pokud se provider zásadně nezměnil.

Ověřuje se:

- platnost licence,
- změny tarifu,
- změny API,
- změny dokumentace,
- změny pokrytí,
- změny kvality,
- změny výkonu,
- změny nákladů,
- změny fallbacku,
- nové incidenty.

## 10.3 Události vyžadující okamžitou revalidaci

Okamžitá revalidace je povinná při:

- nové hlavní verzi API,
- změně autentizace,
- změně licenčních podmínek,
- významné změně cen,
- změně identifikátorů,
- změně datového schématu,
- dlouhém výpadku,
- výrazném nárůstu duplicit,
- právním upozornění,
- změně vlastníka providera,
- změně obchodního modelu.

## 10.4 Výsledek revalidace

Možné výsledky:

- beze změny,
- změna rozsahu,
- změna priority,
- změna fallbacku,
- přechod do `LIMITED`,
- přechod do `HOLD`,
- přechod do `DEPRECATED`,
- nový technický test.

## 10.5 Evidence trendu

Kromě aktuálního stavu se sleduje trend:

- zlepšování,
- stabilní stav,
- pomalé zhoršování,
- náhlé zhoršení,
- neznámý trend.

## 10.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila průběžné provozní sledování, pravidelnou revalidaci a události vyžadující okamžité nové posouzení.

**Přínos pro projekt:** Schválení providera není jednorázové a systém reaguje na změny kvality, licence, ceny i API.

**Návaznost na další kapitolu:** Následující kapitola popisuje bezpečnostní stav HOLD a řízení incidentu.

---

# 11. HOLD a řízení incidentu

## 11.1 Účel stavu HOLD

`HOLD` chrání projekt před pokračováním rizikového procesu.

Používá se, pokud není bezpečné pokračovat, i když ještě není znám konečný výsledek šetření.

## 11.2 Okamžitý HOLD

Okamžitý HOLD lze vyhlásit bez dokončení běžného schvalovacího workflow.

Následně se musí doplnit:

- důvod,
- rozsah,
- čas,
- zasažené procesy,
- provedené blokace,
- odpovědná osoba,
- plán dalšího šetření.

## 11.3 Rozsah HOLD

HOLD může blokovat:

- celý provider,
- jeden sport,
- jeden endpoint,
- jednu entitu,
- jeden worker,
- merge,
- publikaci,
- pouze vytváření nových entit,
- pouze historický harvest.

## 11.4 Technická opatření

Podle incidentu lze:

- zastavit plánovač,
- zakázat worker,
- zablokovat merge,
- přesměrovat na fallback,
- zachovat pouze RAW,
- snížit request budget,
- vypnout publikaci,
- izolovat testovací data.

## 11.5 Analýza incidentu

Analýza musí určit:

- co se stalo,
- kdy se to stalo,
- jaký je dopad,
- které záznamy jsou dotčeny,
- zda lze data opravit,
- zda je nutný rollback,
- zda problém pochází od providera nebo interního procesu,
- zda je nutné upozornit na právní nebo finanční dopad.

## 11.6 Ukončení HOLD

HOLD může skončit:

- návratem do `TESTING`,
- přechodem do `LIMITED`,
- návratem do `ACTIVE`,
- přechodem do `DEPRECATED`,
- přechodem do `REJECTED`,
- přechodem do `RETIRED`.

Rozhodnutí musí uvést, proč je další provoz bezpečný nebo proč se ukončuje.

## 11.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala okamžité pozastavení, jeho rozsah, technická opatření, incidentní analýzu a podmínky ukončení HOLD.

**Přínos pro projekt:** Rizikový providerový tok lze zastavit dříve, než způsobí rozsáhlé poškození dat, nákladů nebo právního postavení.

**Návaznost na další kapitolu:** Následující kapitola stanovuje řízené nahrazení a úplné vyřazení providera.

---

# 12. Nahrazení a vyřazení providera

## 12.1 Důvody nahrazení

Provider může být nahrazen kvůli:

- lepší kvalitě jiného zdroje,
- širšímu pokrytí,
- nižší ceně,
- lepší licenci,
- stabilnějšímu API,
- ukončení služby,
- dlouhodobým výpadkům,
- zhoršení podpory,
- strategické změně projektu.

## 12.2 Migrační plán

Migrační plán obsahuje:

- stávající rozsah,
- cílového providera,
- rozdíly datového modelu,
- rozdíly historie,
- rozdíly identit,
- mapování,
- paralelní test,
- datum přepnutí,
- rollback,
- ukončení starého zdroje.

## 12.3 Paralelní provoz

Při významné migraci se doporučuje dočasný paralelní provoz.

Sleduje se:

- shoda záznamů,
- rozdíly,
- konflikty,
- čerstvost,
- stabilita,
- náklady,
- dopad na merge.

## 12.4 Zachování historie

Vyřazení providera nesmí automaticky smazat:

- RAW historii,
- provider mapy,
- importní logy,
- auditní reporty,
- rozhodnutí,
- historické identifikátory,
- vazby na kanonické entity.

## 12.5 Deaktivace přístupů

Po vyřazení se:

- zruší aktivní klíče,
- odstraní plánované běhy,
- deaktivují workery,
- upraví fallback,
- aktualizuje katalog,
- archivuje konfigurace bez tajných hodnot.

## 12.6 Opětovné použití

Vyřazený provider může být znovu posouzen pouze novým workflow.

Historické důkazy lze použít jako podklad, ale nesmí se předpokládat jejich aktuálnost.

## 12.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila důvody nahrazení, migrační plán, paralelní provoz, zachování historie a deaktivaci přístupů.

**Přínos pro projekt:** Provider lze nahradit bez ztráty auditní stopy a bez neřízeného přerušení datových toků.

**Návaznost na další kapitolu:** Následující kapitola popisuje napojení životního cyklu na panel, databázi a automatizaci MatchMatrix.

---

# 13. Napojení na panel, databázi a automatizaci

## 13.1 Cílový stav panelu

Řídicí panel má zobrazovat:

- provider,
- kategorii,
- hlavní stav,
- rozsah,
- rizikovou třídu,
- poslední kontrolu,
- další kontrolu,
- primární nebo fallback roli,
- aktivní omezení,
- otevřené blokátory.

## 13.2 Akce panelu

Doporučené řízené akce:

- založit provider,
- zahájit REVIEW,
- vytvořit testovací plán,
- spustit omezený test,
- otevřít technický report,
- otevřít datový report,
- navrhnout stavový přechod,
- schválit ACTIVE,
- nastavit LIMITED,
- aktivovat HOLD,
- zahájit DEPRECATED,
- potvrdit RETIRED.

## 13.3 Blokace neplatných akcí

Panel musí blokovat například:

- aktivaci bez VERIFIED,
- ACTIVE bez schváleného rozsahu,
- produkční merge bez integrační cesty,
- vyřazení s aktivním workerem,
- publikaci při HOLD,
- test bez limitu požadavků,
- zobrazení tajných údajů,
- opětovnou aktivaci RETIRED bez revalidace.

## 13.4 Databázová evidence

Databáze má dlouhodobě podporovat:

- provider registry,
- provider scope,
- provider status history,
- approval gates,
- evidence links,
- risk class,
- review schedule,
- incidents,
- replacements,
- fallback relations.

Přesný fyzický model musí odpovídat databázovým standardům a aktuálnímu datovému slovníku.

## 13.5 Automatické návrhy

Automatizace může navrhnout:

- přechod do HOLD,
- snížení priority,
- revalidaci,
- změnu fallbacku,
- změnu rizikové třídy,
- rozšíření testu.

Automatizace nesmí bez řízeného oprávnění sama schválit strategický stav `ACTIVE`.

## 13.6 Auditní vazba

Každá panelová akce musí vytvořit auditní stopu:

- kdo,
- kdy,
- co změnil,
- proč,
- z jakého stavu,
- do jakého stavu,
- na základě jakých důkazů.

## 13.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola popsala cílové zobrazení providerového workflow v panelu, blokace neplatných akcí, databázovou evidenci a roli automatických návrhů.

**Přínos pro projekt:** Životní cyklus lze převést z dokumentovaného pravidla do praktického, auditovatelného a uživatelsky jednoduchého workflow.

**Návaznost na další kapitolu:** Následující kapitola stanovuje rozhodovací matice pro nejčastější provozní situace.

---

# 14. Rozhodovací matice

## 14.1 Nový provider s dobrým API, ale nejasnou licencí

| Oblast | Výsledek |
|---|---|
| Technika | Vyhovuje |
| Data | Předběžně vyhovují |
| Licence | Nejasná |
| Stav | REVIEW nebo HOLD |
| Povolený provoz | Pouze omezený test bez publikace, pokud je právně přípustný |
| ACTIVE | Zakázáno do vyjasnění |

## 14.2 Provider s kvalitními daty a vysokou cenou

| Oblast | Výsledek |
|---|---|
| Technika | Vyhovuje |
| Data | Vyhovují |
| Cena | Vysoká |
| Stav | VERIFIED nebo LIMITED |
| Rozhodnutí | Schválit pouze prioritní sporty nebo entity |
| Další krok | Porovnat s alternativou a stanovit budget |

## 14.3 Provider s nízkou mapovací úspěšností

| Oblast | Výsledek |
|---|---|
| API | Funguje |
| Parser | Funguje |
| Mapování | Nevyhovuje |
| Stav | TESTING nebo LIMITED |
| ACTIVE | Pouze bez automatického vytváření entit |
| Další krok | Zlepšit provider map a entity matching |

## 14.4 Provider s výpadkem

| Situace | Akce |
|---|---|
| Krátký výpadek | Retry a monitoring |
| Opakovaný výpadek | DEGRADED nebo LIMITED |
| Dlouhý výpadek | HOLD a fallback |
| Trvalé ukončení | DEPRECATED → RETIRED |

## 14.5 Změna API bez předchozího upozornění

| Dopad | Akce |
|---|---|
| Bez dopadu na parser | Zaznamenat a sledovat |
| Částečné chyby parseru | LIMITED nebo HOLD |
| Chybné kanonické zápisy | Okamžitý HOLD |
| Změna identifikátorů | Nový test mapování a revalidace |

## 14.6 Nový sport u existujícího providera

Existující stav `ACTIVE` se nepřenáší automaticky.

Nový sport prochází minimálně:

```text
REVIEW rozsahu
→ CANDIDATE
→ TESTING
→ VERIFIED
→ ACTIVE nebo LIMITED
```

## 14.7 Nová entita u existujícího sportu

Například provider aktivní pro zápasy, ale nově použitý pro hráče.

Musí se ověřit:

- nové endpointy,
- nová identita,
- nové mapování,
- nové duplicity,
- nové licenční podmínky,
- nový merge.

## 14.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola aplikovala životní cyklus na typické situace s nejasnou licencí, vysokou cenou, slabým mapováním, výpadkem, změnou API a rozšířením rozsahu.

**Přínos pro projekt:** Rozhodovací pravidla lze použít konzistentně i při provozním tlaku a není nutné improvizovat u každého incidentu.

**Návaznost na další kapitolu:** Následující kapitola shrnuje kontrolní kritéria dokumentu před schválením.

---

# 15. Kontrolní kritéria dokumentu

Dokument lze předložit ke schválení, pokud je potvrzeno:

- [ ] Document ID odpovídá oblasti `05_PROVIDERS`.
- [ ] Název souboru odpovídá `MM-STD-007`.
- [ ] Dokument navazuje na `MM-PRV-001`.
- [ ] Stavový model je jednoznačný.
- [ ] Povolené a zakázané přechody jsou popsány.
- [ ] Schvalovací brány obsahují účel a povinné důkazy.
- [ ] Role a odpovědnosti jsou odděleny.
- [ ] `ACTIVE` vyžaduje stav `VERIFIED`.
- [ ] HOLD může být vyhlášen okamžitě.
- [ ] RETIRED zachovává historii a provider mapy.
- [ ] Dokument neobsahuje API klíče ani tajné údaje.
- [ ] Terminologie odpovídá MM-REF-001 a MM-REF-002.
- [ ] Každá hlavní kapitola obsahuje závěr se shrnutím, přínosem a návazností.
- [ ] Historie verzí je doplněna.
- [ ] A17 neobsahuje nevyřešený strukturální blokátor.
- [ ] A24 a A7 budou spuštěny až po schválení a Git commitu.

## 15.1 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola převedla obsah dokumentu do konkrétního kontrolního seznamu pro identitu, strukturu, stavový model, schvalovací brány, bezpečnost a publikační workflow.

**Přínos pro projekt:** Před schválením lze rychle ověřit, zda dokument neobsahuje zásadní strukturální nebo governance mezeru.

**Návaznost na další kapitolu:** Následující kapitola eviduje historii verzí dokumentu před jeho závěrečným shrnutím.

---

# 16. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-17 | DRAFT – NEEDS_USER_APPROVAL | První návrh podrobného životního cyklu a schvalovacího workflow providerů MatchMatrix. |

---

# Závěr dokumentu

`MM-PRV-002` stanovuje jednotný, řízený a auditovatelný proces pro celý životní cyklus providerů MatchMatrix.

Provider postupuje od stavu `DISCOVERED` přes posouzení, testování, integraci a ověření až do přesně vymezeného stavu `ACTIVE` nebo `LIMITED`. Aktivace je možná pouze po dokončení schvalovacích bran a doložení technických, datových, právních, obchodních a provozních důkazů.

Dokument současně zavádí bezpečný stav `HOLD`, pravidelnou revalidaci, rizikové třídy, řízené nahrazení a zachování auditní historie po vyřazení providera.

Hlavním přínosem je oddělení pouhé technické funkčnosti od skutečného produkčního schválení. MatchMatrix tak může rozšiřovat víceproviderový ekosystém bez ztráty kontroly nad kvalitou dat, náklady, licencemi, provozní stabilitou a dlouhodobou nahraditelností zdrojů.
