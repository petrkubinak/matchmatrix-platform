# MM-PRV-005

# INTEGRACE PROVIDERŮ DO DATOVÝCH VRSTEV MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-005 |
| Document ID | MM-PRV-005 |
| Název dokumentu | Integrace providerů do datových vrstev MatchMatrix |
| Typ dokumentu | PROVIDER_DATA_LAYER_INTEGRATION |
| Dokumentační oblast | 05_PROVIDERS |
| Edice | MM-DOC TECH |
| Verze | 0.9 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | NOVÝ DOKUMENT |
| Datum | 2026-07-18 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Cílové umístění | `docs/05_PROVIDERS/` |
| Nahrazuje | — |
| Navazuje na | MM-PRV-001, MM-PRV-002, MM-PRV-003, MM-PRV-004 |
| Související dokumenty | MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DB-001, MM-DB-002, MM-DB-003, MM-REF-001, MM-REF-002 |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-008 |

---

# 1. Úvod

Tento dokument stanovuje jednotný technický model integrace providerů do datových vrstev MatchMatrix.

Providerová integrace není pouze stažení dat z API. Jde o řízený tok, který musí zachovat původ dat, oddělit externí strukturu od interního modelu, zabránit přímému neověřenému zápisu do kanonických tabulek a umožnit opakované zpracování, audit, rollback a změnu providera.

Standardní integrační tok je:

```text
PROVIDER
→ REQUEST / PULL
→ RAW
→ PARSER
→ PROVIDER-NORMALIZED STAGING
→ VALIDACE
→ PROVIDER MAP
→ MERGE CANDIDATE
→ KANONICKÁ VRSTVA
→ POST-IMPORTNÍ OVĚŘENÍ
```

## 1.1 Účel dokumentu

Dokument definuje:

- odpovědnosti jednotlivých datových vrstev,
- povinné kroky integračního toku,
- pravidla RAW uložení,
- pravidla parseru,
- provider-normalized staging,
- validaci,
- provider map,
- merge,
- post-importní ověření,
- idempotenci,
- retry a obnovu,
- izolaci chyb,
- auditní stopu,
- bezpečné nasazení do produkce.

## 1.2 Rozsah

Pravidla se vztahují na:

- Core data,
- People data,
- Media data,
- Odds data,
- Knowledge data,
- historické harvesty,
- aktuální sezony,
- incremental aktualizace,
- pre-match,
- live,
- post-match,
- enrichment,
- ruční i automatické integrační běhy.

## 1.3 Základní pravidlo

Žádný nový provider nesmí zapisovat přímo do kanonické vrstvy bez:

- RAW evidence,
- parseru,
- staging vrstvy,
- validace,
- mapování,
- merge pravidla,
- post-importní kontroly.

## 1.4 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola vymezila providerovou integraci jako řízený tok od externího zdroje po ověřenou kanonickou vrstvu.

**Přínos pro projekt:** MatchMatrix chrání interní datový model před přímou závislostí na struktuře a chybách jednotlivého providera.

**Návaznost na další kapitolu:** Následující kapitola rozděluje odpovědnosti jednotlivých datových vrstev.

---

# 2. Datové vrstvy a jejich odpovědnosti

## 2.1 Provider source

Provider source je externí nebo interní zdroj dat.

Může jít o:

- API,
- souborový export,
- partnerský feed,
- oficiální web,
- veřejný datový zdroj,
- interní odvozený feed.

Provider source není součástí kanonického modelu MatchMatrix.

## 2.2 Request vrstva

Request vrstva odpovídá za:

- sestavení požadavku,
- autentizaci,
- parametry,
- stránkování,
- retry,
- timeout,
- rate limit,
- request budget,
- provozní log.

## 2.3 RAW vrstva

RAW vrstva uchovává původní odpověď zdroje.

RAW neslouží jako finální datový model. Slouží pro:

- audit,
- opakovaný parsing,
- diagnostiku,
- porovnání změn API,
- rollback,
- doložení původu.

## 2.4 Parser vrstva

Parser převádí providerovou strukturu do řízeného interního přenosového modelu.

Parser nesmí:

- rozhodovat o kanonické identitě bez mapování,
- nekontrolovaně vytvářet nové veřejné entity,
- skrývat neplatná data bez záznamu,
- přepisovat původní RAW.

## 2.5 Provider-normalized staging

Staging obsahuje data normalizovaná pro potřeby MatchMatrix, ale stále oddělená podle providera.

Staging záznam ještě není zdroj pravdy.

## 2.6 Provider map

Provider map propojuje externí identifikátor s kanonickou identitou.

Je samostatnou governance vrstvou a nesmí být skryta pouze uvnitř parseru.

## 2.7 Merge candidate

Merge candidate obsahuje návrh:

- vytvořit entitu,
- aktualizovat entitu,
- doplnit atribut,
- označit konflikt,
- odmítnout změnu,
- převést záznam do HOLD.

## 2.8 Kanonická vrstva

Kanonická vrstva představuje interní řízenou reprezentaci entit MatchMatrix.

Provider nesmí určovat její fyzický model.

## 2.9 Auditní a kontrolní vrstva

Auditní vrstva eviduje:

- běhy,
- requesty,
- RAW payloady,
- parser výsledky,
- mapování,
- merge rozhodnutí,
- post-importní kontroly,
- chyby,
- rollbacky.

## 2.10 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola rozdělila providerový tok na source, request, RAW, parser, staging, provider map, merge candidate, kanonickou a auditní vrstvu.

**Přínos pro projekt:** Každá vrstva má jednoznačnou odpovědnost a lze určit, kde chyba vznikla.

**Návaznost na další kapitolu:** Následující kapitola stanovuje vstupní kontrakt providerové integrace.

---

# 3. Vstupní kontrakt integrace

## 3.1 Povinné identifikátory

Každý integrační běh musí znát:

- provider,
- sport,
- entitu,
- režim,
- sezonu nebo období,
- region nebo soutěž,
- routing rule,
- worker,
- čas spuštění,
- execution ID.

## 3.2 Execution ID

Execution ID jednoznačně identifikuje celý integrační běh.

Musí být použitelné napříč:

- request logem,
- RAW,
- parserem,
- stagingem,
- merge,
- post-importním ověřením.

## 3.3 Request scope

Scope určuje přesný rozsah požadavku:

```text
provider
+ sport
+ entity
+ season
+ region
+ page
+ mode
```

## 3.4 Konfigurace

Konfigurace obsahuje:

- endpoint,
- parametry,
- stránkování,
- timeout,
- retry policy,
- rate limit,
- parser version,
- staging target,
- merge policy.

Tajné údaje nesmí být součástí dokumentace ani běžných logů.

## 3.5 Očekávaný výstup

Před spuštěním má být známo:

- očekávaný typ dat,
- minimální povinná pole,
- očekávaný počet nebo rozsah,
- cílová staging tabulka,
- validační pravidla,
- post-importní kontrola.

## 3.6 Stop podmínky

Běh se musí zastavit při:

- opakované chybě autentizace,
- překročení request budgetu,
- změně schématu s kritickým dopadem,
- zápisu mimo schválenou vrstvu,
- nekontrolovaném růstu chyb,
- nečekaném množství duplicit,
- aktivním HOLD.

## 3.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila povinné identifikátory, scope, konfiguraci, očekávaný výstup a stop podmínky integračního běhu.

**Přínos pro projekt:** Každý běh je předem vymezený, auditovatelný a provozně omezený.

**Návaznost na další kapitolu:** Následující kapitola popisuje request a pull vrstvu.

---

# 4. Request a pull vrstva

## 4.1 Sestavení požadavku

Požadavek musí vzniknout z řízené konfigurace.

Nesmí být závislý na ručně vložených hodnotách ukrytých ve zdrojovém kódu.

## 4.2 Autentizace

Autentizační údaje:

- jsou mimo Git,
- nejsou v dokumentaci,
- nejsou v běžném logu,
- jsou dostupné pouze oprávněnému procesu,
- lze je samostatně deaktivovat.

## 4.3 Timeout

Timeout musí být definován podle režimu.

Příliš dlouhý timeout:

- blokuje worker,
- zhoršuje retry,
- zvyšuje dobu incidentu.

Příliš krátký timeout:

- vytváří falešné chyby,
- zvyšuje request consumption.

## 4.4 Retry

Retry smí být použit pouze u chyb, které mohou být dočasné.

Retry policy má obsahovat:

- počet pokusů,
- čekání,
- backoff,
- jitter,
- retryable chyby,
- non-retryable chyby,
- stop hranici.

## 4.5 Rate limit

Request vrstva musí sledovat:

- 429,
- hlavičky limitu,
- zbývající počet requestů,
- čas obnovy,
- rezervovanou kapacitu,
- prioritu požadavku.

## 4.6 Stránkování

Stránkování musí chránit proti:

- nekonečnému cyklu,
- opakování stránky,
- vynechání stránky,
- změně page tokenu,
- duplicitnímu payloadu.

## 4.7 Request log

Request log eviduje:

- execution ID,
- provider,
- endpoint bez tajných údajů,
- parametry,
- čas,
- stav,
- HTTP kód,
- latenci,
- retry count,
- velikost odpovědi.

## 4.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila řízené sestavení requestu, autentizaci, timeout, retry, rate limit, stránkování a request log.

**Přínos pro projekt:** Síťový přístup k providerovi je opakovatelný, měřitelný a chráněný před nekontrolovanou spotřebou.

**Návaznost na další kapitolu:** Následující kapitola stanovuje pravidla RAW vrstvy.

---

# 5. RAW vrstva

## 5.1 Účel RAW

RAW uchovává providerovu odpověď tak, aby bylo možné:

- doložit původ dat,
- znovu spustit parser,
- porovnat změnu struktury,
- diagnostikovat chybu,
- obnovit zpracování bez nového requestu.

## 5.2 Neměnnost

Uložený RAW payload se po zápisu nemění.

Případná technická komprese nebo obalení musí zachovat obsah.

## 5.3 Metadata RAW záznamu

RAW záznam má obsahovat:

- raw ID,
- execution ID,
- provider,
- sport,
- entitu,
- režim,
- scope,
- endpoint,
- request timestamp,
- response timestamp,
- HTTP status,
- payload hash,
- parser status,
- retention class.

## 5.4 Payload hash

Hash umožňuje:

- detekovat identický payload,
- zabránit opakovanému zpracování,
- prokázat neměnnost,
- porovnat odpovědi.

## 5.5 Prázdný payload

Prázdný payload se eviduje.

Nesmí být automaticky považován za úspěch ani za důkaz, že data neexistují.

## 5.6 Chybový payload

Providerová chybová odpověď se ukládá odděleně od platných dat.

Parser ji nesmí interpretovat jako běžný datový payload.

## 5.7 Retence

Retence se stanovuje podle:

- právních podmínek,
- velikosti,
- rizika,
- typu dat,
- potřeby auditu,
- nákladů.

## 5.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila neměnné RAW uložení, metadata, hash, práci s prázdným a chybovým payloadem a retenci.

**Přínos pro projekt:** Data lze znovu zpracovat a auditovat bez opakovaného zatěžování providera.

**Návaznost na další kapitolu:** Následující kapitola definuje parser a jeho odpovědnosti.

---

# 6. Parser

## 6.1 Účel parseru

Parser převádí providerový payload do interního provider-normalized formátu.

## 6.2 Povinné operace

Parser může provádět:

- převod typů,
- normalizaci textu,
- normalizaci času,
- extrakci identifikátorů,
- normalizaci enum hodnot,
- rozdělení vnořených objektů,
- základní strukturální validaci.

## 6.3 Zakázané operace

Parser nesmí bez samostatného governance pravidla:

- rozhodovat kanonickou identitu,
- slučovat dva různé objekty,
- vytvářet public entitu,
- přepisovat hodnotu jiného providera,
- skrývat konflikt,
- odstraňovat neplatný záznam bez evidence.

## 6.4 Verze parseru

Každý parser musí mít verzi nebo dohledatelný Git commit.

Staging záznam má být propojitelný s použitou verzí parseru.

## 6.5 Schema fingerprint

Parser má kontrolovat očekávanou strukturu payloadu.

Změna fingerprintu může vést k:

- warning,
- SCHEMA_CHANGED,
- blokaci parseru,
- blokaci merge.

## 6.6 Chybové kategorie

Doporučené kategorie:

- PAYLOAD_INVALID,
- REQUIRED_FIELD_MISSING,
- TYPE_CONVERSION_FAILED,
- ENUM_UNKNOWN,
- TIME_INVALID,
- IDENTIFIER_MISSING,
- SCHEMA_CHANGED,
- PARSER_EXCEPTION.

## 6.7 Parser report

Parser report obsahuje:

- počet payloadů,
- počet platných záznamů,
- počet odmítnutých záznamů,
- chybové kategorie,
- neznámé hodnoty,
- použitou verzi,
- čas zpracování.

## 6.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola vymezila parser jako řízený převod struktury bez rozhodování o kanonické identitě a merge.

**Přínos pro projekt:** Providerová struktura je oddělena od governance rozhodnutí a lze samostatně testovat parser.

**Návaznost na další kapitolu:** Následující kapitola stanovuje provider-normalized staging.

---

# 7. Provider-normalized staging

## 7.1 Účel stagingu

Staging je bezpečná přípravná vrstva mezi parserem a kanonickým modelem.

## 7.2 Oddělení podle providera

Staging musí zachovat:

- provider ID,
- external ID,
- execution ID,
- raw ID,
- parser version,
- source timestamp,
- ingestion timestamp.

## 7.3 Stav staging záznamu

Doporučené stavy:

| Stav | Význam |
|---|---|
| NEW | Nově zapsaný záznam. |
| VALIDATED | Prošel validačními pravidly. |
| MAPPED | Má potvrzenou kanonickou vazbu. |
| UNMAPPED | Nemá potvrzené mapování. |
| CONFLICT | Obsahuje konflikt. |
| HOLD | Čeká na rozhodnutí. |
| MERGED | Byl zpracován merge procesem. |
| REJECTED | Byl odmítnut s důvodem. |

## 7.4 Opakované zpracování

Staging má umožnit:

- opakovanou validaci,
- opakované mapování,
- nový merge,
- změnu pravidla,
- kontrolovaný reprocessing.

## 7.5 Historie změn

Pokud se staging záznam mění, musí být dohledatelný:

- původní stav,
- nový stav,
- čas,
- důvod,
- proces.

## 7.6 Staging není veřejná vrstva

Aplikace a uživatelský produkt nemají bez zvláštního důvodu číst staging jako zdroj pravdy.

## 7.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala staging jako providerově oddělenou, stavovou a opakovaně zpracovatelnou přípravnou vrstvu.

**Přínos pro projekt:** Neověřená data lze bezpečně analyzovat bez dopadu na kanonické entity.

**Návaznost na další kapitolu:** Následující kapitola stanovuje validační pravidla.

---

# 8. Validace

## 8.1 Strukturální validace

Kontroluje:

- povinná pole,
- datové typy,
- formáty,
- délky,
- povolené hodnoty,
- časové údaje.

## 8.2 Doménová validace

Kontroluje například:

- platný sport,
- logickou sezonu,
- čas zápasu,
- účastníky,
- skóre,
- vazbu na soutěž,
- geografickou konzistenci.

## 8.3 Referenční validace

Kontroluje vazby na:

- sports,
- countries,
- competitions,
- seasons,
- teams,
- people,
- venues,
- provider registry.

## 8.4 Historická validace

Kontroluje:

- časovou návaznost,
- nečekané mezery,
- změny identifikátorů,
- neplatné přechody,
- duplicity v období.

## 8.5 Kvalitativní validace

Měří:

- úplnost,
- mapovatelnost,
- konflikt rate,
- duplicate rate,
- freshness,
- expected versus actual count.

## 8.6 Výsledek validace

Výsledek může být:

- PASS,
- PASS_WITH_WARNING,
- HOLD,
- REJECTED,
- BLOCKED.

## 8.7 Validační report

Obsahuje:

- použitá pravidla,
- verze pravidel,
- počty výsledků,
- vzorky chyb,
- doporučení,
- dopad na merge.

## 8.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila strukturální, doménovou, referenční, historickou a kvalitativní validaci.

**Přínos pro projekt:** Chyby jsou zachyceny před mapováním a merge do kanonické vrstvy.

**Návaznost na další kapitolu:** Následující kapitola definuje provider map a správu identity.

---

# 9. Provider map a identita

## 9.1 Účel provider map

Provider map propojuje externí identitu s kanonickou entitou MatchMatrix.

## 9.2 Minimální klíč

Mapování musí být jednoznačné nejméně pro:

```text
provider
+ sport
+ entity type
+ external ID
```

## 9.3 Stav mapování

Doporučené stavy:

- AUTO_CONFIRMED,
- MANUAL_CONFIRMED,
- CANDIDATE,
- CONFLICT,
- HOLD,
- REJECTED,
- DEPRECATED.

## 9.4 Mapovací důkazy

Mapování může používat:

- přesné external ID,
- alias,
- název,
- sport,
- zemi,
- soutěž,
- sezonu,
- datum narození,
- týmovou vazbu,
- čas a účastníky zápasu.

## 9.5 Zákaz párování pouze názvem

Název samotný obvykle nestačí.

Výjimka musí být explicitně řízená a nízkoriziková.

## 9.6 Konflikt mapování

Konflikt vzniká, pokud:

- jedno external ID míří na více kanonických entit,
- více external ID je nesprávně sloučeno,
- chybí rozlišující atribut,
- provider změnil identifikátor.

## 9.7 Historie mapování

Při změně se uchovává:

- původní vazba,
- nová vazba,
- důvod,
- čas,
- schválení,
- dopad na již importovaná data.

## 9.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila jednoznačný mapovací klíč, stavy, důkazy, konflikty a historii provider map.

**Přínos pro projekt:** Více providerů lze spojovat bez vytváření duplicitních kanonických entit.

**Návaznost na další kapitolu:** Následující kapitola definuje merge candidate a merge rozhodnutí.

---

# 10. Merge candidate a merge

## 10.1 Merge candidate

Merge candidate obsahuje:

- zdrojový staging záznam,
- cílovou kanonickou entitu,
- navrženou operaci,
- rozdíly,
- autoritu zdroje,
- prioritu,
- konflikt,
- doporučení.

## 10.2 Povolené operace

- CREATE,
- UPDATE,
- ENRICH,
- NO_CHANGE,
- CONFLICT,
- HOLD,
- REJECT.

## 10.3 Source authority

Každý atribut může mít jiné pravidlo autority.

Merge nesmí předpokládat, že jeden provider je nejvyšší autoritou pro všechna pole.

## 10.4 Čerstvost

Novější hodnota nemusí být správnější.

Čerstvost se kombinuje s:

- autoritou,
- kvalitou,
- stavem,
- historií spolehlivosti.

## 10.5 Idempotence

Opakovaný merge stejného vstupu nesmí vytvořit další duplicitní změnu.

## 10.6 Konflikt

Konflikt se eviduje, nikoli skrývá.

Může vést k:

- zachování existující hodnoty,
- přijetí nové hodnoty,
- atributovému HOLD,
- ruční kontrole,
- revalidaci providera.

## 10.7 Transakce

Merge má být transakční v rozsahu, který zabrání částečnému nekonzistentnímu zápisu.

## 10.8 Merge report

Obsahuje:

- CREATE count,
- UPDATE count,
- ENRICH count,
- NO_CHANGE count,
- CONFLICT count,
- HOLD count,
- REJECT count,
- chyby,
- změnu cílových počtů.

## 10.9 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala merge candidate, povolené operace, autoritu, čerstvost, idempotenci, konflikty a transakční zápis.

**Přínos pro projekt:** Kanonická vrstva se mění pouze prostřednictvím vysvětlitelného a auditovatelného rozhodnutí.

**Návaznost na další kapitolu:** Následující kapitola stanovuje post-importní ověření.

---

# 11. Post-importní ověření

## 11.1 Povinná kontrola

Úspěšný SQL commit nebo návratový kód 0 není dostatečný důkaz správnosti.

## 11.2 Kontrolované hodnoty

Porovnává se:

- stav před,
- stav po,
- očekávaný rozdíl,
- skutečný rozdíl,
- počet nových entit,
- počet aktualizací,
- počet mapování,
- počet konfliktů,
- počet duplicit,
- počet chybějících záznamů.

## 11.3 Kontrola cílových entit

Provádí se vzorková nebo úplná kontrola:

- identity,
- vazeb,
- časů,
- výsledků,
- atributů,
- zdrojových vazeb.

## 11.4 Kontrola provider lineage

Musí být možné určit, které cílové změny vznikly z konkrétního:

- execution ID,
- raw ID,
- staging ID,
- provideru,
- merge runu.

## 11.5 Neshoda

Při neshodě lze:

- blokovat další běh,
- označit import jako WARNING,
- spustit rollback,
- převést provider do HOLD,
- otevřít incident.

## 11.6 Výsledek

Doporučené výsledky:

- VERIFIED,
- VERIFIED_WITH_WARNING,
- REVIEW_REQUIRED,
- ROLLBACK_REQUIRED,
- BLOCKED.

## 11.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila porovnání před a po importu, kontrolu cílových entit, lineage a reakci na neshodu.

**Přínos pro projekt:** Integrace je považována za úspěšnou až po ověření skutečného databázového výsledku.

**Návaznost na další kapitolu:** Následující kapitola řeší retry, obnovu a reprocessing.

---

# 12. Retry, obnova a reprocessing

## 12.1 Oddělení retry vrstev

Retry requestu, parseru, staging zápisu a merge jsou samostatné operace.

## 12.2 Request retry

Používá se při dočasných síťových nebo providerových chybách.

## 12.3 Parser reprocessing

Pokud je RAW uložen, lze po opravě parseru znovu zpracovat payload bez nového requestu.

## 12.4 Staging revalidation

Po změně validačního pravidla lze staging znovu vyhodnotit.

## 12.5 Remapping

Po změně provider map lze znovu vyhodnotit UNMAPPED nebo CONFLICT záznamy.

## 12.6 Remerge

Po změně merge policy lze vytvořit nový merge candidate.

Musí být chráněna idempotence a historie.

## 12.7 Checkpoint

Dlouhý harvest má používat checkpoint, aby po výpadku nepokračoval od začátku.

## 12.8 Recovery report

Obnova eviduje:

- původní selhání,
- obnovený krok,
- počet znovu zpracovaných záznamů,
- výsledek,
- zbytkové chyby.

## 12.9 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola oddělila retry jednotlivých vrstev a stanovila reprocessing RAW, revalidaci, remapping, remerge a checkpoint.

**Přínos pro projekt:** Chybu lze opravit v konkrétní vrstvě bez opakovaného stahování nebo nekontrolovaného přepisu.

**Návaznost na další kapitolu:** Následující kapitola stanovuje observabilitu a auditní stopu.

---

# 13. Observabilita a auditní stopa

## 13.1 Jednotný execution trace

Execution ID propojuje:

- plán,
- routing decision,
- worker,
- request,
- RAW,
- parser,
- staging,
- mapování,
- merge,
- post-importní kontrolu.

## 13.2 Metriky

Sledují se:

- request count,
- success rate,
- latency,
- RAW count,
- parser success,
- staging count,
- mapping success,
- merge counts,
- post-importní rozdíl,
- doba běhu.

## 13.3 Logy

Log musí být:

- strukturovaný,
- časově označený,
- bez tajných údajů,
- propojený s execution ID,
- použitelný pro incidentní diagnostiku.

## 13.4 Reporty

Doporučené reporty:

- request report,
- parser report,
- validation report,
- mapping report,
- merge report,
- post-import report,
- recovery report.

## 13.5 Alerty

Alert vzniká, pokud:

- je překročen stop práh,
- vznikne schema change,
- prudce klesne mapování,
- vznikne vysoký duplicate rate,
- post-importní rozdíl neodpovídá očekávání,
- běh nedokončí cílovou vrstvu.

## 13.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila jednotný execution trace, metriky, strukturované logy, reporty a alerty.

**Přínos pro projekt:** Celý integrační tok lze sledovat a diagnostikovat bez ručního spojování nesouvisejících logů.

**Návaznost na další kapitolu:** Následující kapitola popisuje panelové workflow a bezpečnostní blokace.

---

# 14. Panelové workflow a blokace

## 14.1 Přehled integrace

Panel má zobrazovat:

- provider,
- sport,
- entitu,
- režim,
- execution ID,
- aktuální vrstvu,
- stav,
- počty,
- chyby,
- poslední kontrolu.

## 14.2 Doporučené kroky

```text
1. VYBRAT PROVIDERA A ROZSAH
2. OVĚŘIT ROUTING A HEALTH
3. SPUSTIT REQUEST
4. ZKONTROLOVAT RAW
5. SPUSTIT PARSER
6. ZKONTROLOVAT STAGING
7. OVĚŘIT MAPOVÁNÍ
8. VYTVOŘIT MERGE NÁVRH
9. PROVÉST MERGE
10. OVĚŘIT DATABÁZI
```

## 14.3 Blokace

Panel musí blokovat:

- request na provider v HOLD,
- běh bez schváleného scope,
- parser bez RAW,
- merge bez validace,
- merge bez mapování,
- přímý zápis do kanonické vrstvy,
- opakovaný ne-idempotentní merge,
- publikaci bez post-importního ověření.

## 14.4 Český stav

Příklady:

```text
ČEKÁ NA STAŽENÍ DAT
RAW DATA ULOŽENA
PARSER DOKONČEN
ČÁST ZÁZNAMŮ NELZE SPÁROVAT
MERGE ČEKÁ NA KONTROLU
DATABÁZOVÝ ZÁPIS PROVEDEN
VÝSLEDEK OVĚŘEN
INTEGRACE BLOKOVÁNA
```

## 14.5 Detail chyby

Detail má obsahovat:

- vrstvu,
- důvod,
- dopad,
- počet záznamů,
- doporučenou akci,
- odkaz na report.

## 14.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola převedla integrační tok do panelových kroků, českých stavů a bezpečnostních blokací.

**Přínos pro projekt:** Uživatel může řídit složitý tok po jednotlivých ověřitelných krocích bez přímé práce s databázovými skripty.

**Návaznost na další kapitolu:** Následující kapitola shrnuje kontrolní kritéria dokumentu.

---

# 15. Kontrolní kritéria dokumentu

Dokument lze předložit ke schválení, pokud je potvrzeno:

- [ ] Document ID odpovídá oblasti `05_PROVIDERS`.
- [ ] Název souboru odpovídá `MM-STD-007`.
- [ ] Dokument navazuje na `MM-PRV-001` až `MM-PRV-004`.
- [ ] Integrační tok obsahuje request, RAW, parser, staging, mapování, merge a ověření.
- [ ] Provider nemůže zapisovat přímo do kanonické vrstvy.
- [ ] RAW payload je neměnný a auditovatelný.
- [ ] Parser nerozhoduje o kanonické identitě.
- [ ] Staging zachovává providerovou identitu a execution ID.
- [ ] Validace probíhá před merge.
- [ ] Provider map je samostatná řízená vrstva.
- [ ] Merge je idempotentní a auditovatelný.
- [ ] Konflikt se neskrývá pořadím importu.
- [ ] Post-importní ověření porovnává očekávaný a skutečný stav.
- [ ] Retry jednotlivých vrstev je oddělený.
- [ ] Execution ID propojuje celý tok.
- [ ] Panel blokuje neplatné nebo nebezpečné operace.
- [ ] Dokument neobsahuje API klíče ani tajné údaje.
- [ ] Terminologie odpovídá MM-REF-001 a MM-REF-002.
- [ ] Každá hlavní kapitola obsahuje závěr se shrnutím, přínosem a návazností.
- [ ] Historie verzí je doplněna.
- [ ] A17 neobsahuje nevyřešený strukturální blokátor.
- [ ] A24 a A7 budou spuštěny až po schválení a Git commitu.

## 15.1 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola převedla integrační vrstvy, validaci, mapování, merge, ověření, retry, audit a panelové blokace do kontrolního seznamu.

**Přínos pro projekt:** Před schválením lze ověřit, že dokument pokrývá celý bezpečný integrační tok.

**Návaznost na další kapitolu:** Následující kapitola eviduje historii verzí dokumentu před závěrečným shrnutím.

---

# 16. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-18 | DRAFT – NEEDS_USER_APPROVAL | První návrh pravidel integrace providerů do datových vrstev MatchMatrix. |

---

# Závěr dokumentu

`MM-PRV-005` stanovuje jednotný a auditovatelný model integrace providerů do datových vrstev MatchMatrix.

Každý providerový tok prochází přes request, RAW, parser, provider-normalized staging, validaci, provider map, merge candidate, kanonický merge a post-importní ověření. Jednotlivé vrstvy mají oddělené odpovědnosti a jsou propojeny prostřednictvím execution ID.

Dokument chrání kanonická data před přímým zápisem, skrytými konflikty, neauditovatelným mapováním, ne-idempotentním merge a neověřeným výsledkem.

Hlavním přínosem je možnost přidávat a měnit providery bez narušení interního datového modelu, se zachováním opakovatelnosti, auditu, obnovy a bezpečného řízení z panelu.
