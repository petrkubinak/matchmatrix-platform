# MM-PRV-003

# PROVIDER ROUTING A FALLBACK MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-003 |
| Document ID | MM-PRV-003 |
| Název dokumentu | Provider routing a fallback MatchMatrix |
| Typ dokumentu | PROVIDER_ROUTING_AND_FALLBACK |
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
| Navazuje na | MM-PRV-001, MM-PRV-002 |
| Související dokumenty | MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DB-001, MM-DB-002, MM-DB-003, MM-REF-001, MM-REF-002 |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-008 |

---

# 1. Úvod

Provider routing určuje, který zdroj se má použít pro konkrétní datovou potřebu. Fallback určuje, jak se má systém bezpečně zachovat, pokud preferovaný zdroj není dostupný, neposkytuje potřebná data nebo nesplňuje požadovanou kvalitu.

MatchMatrix nesmí vybírat providera pouze podle sportu nebo podle pořadí, v jakém byly integrace vytvořeny. Rozhodnutí musí vycházet z přesně vymezeného kontextu.

Základní rozhodovací klíč je:

```text
sport
+ datová entita
+ sezona nebo časové období
+ region nebo soutěž
+ režim použití
+ požadovaná čerstvost
+ požadovaná kvalita
+ dostupný tarif a request budget
```

Dokument stanovuje pravidla pro:

- primární a sekundární providery,
- fallback řetězce,
- směrování podle sportu a entity,
- směrování historie, pre-match a live dat,
- řízení priorit,
- kontrolu kvality před přepnutím,
- prevenci duplicit,
- návrat k primárnímu zdroji,
- provozní blokace,
- auditní stopu,
- napojení na panel a databázi.

## 1.1 Účel dokumentu

Cílem je zajistit, aby systém:

- používal nejvhodnější dostupný zdroj,
- nepřepisoval kvalitnější data horšími,
- nezpůsoboval duplicitní harvest,
- automaticky nereagoval nebezpečným přepnutím,
- respektoval stav providera,
- respektoval schválený rozsah,
- respektoval licence a tarifní limity,
- dokázal bezpečně pokračovat při výpadku,
- dokázal návrat k primárnímu zdroji,
- uchoval původ každého významného rozhodnutí.

## 1.2 Rozsah

Pravidla se vztahují na:

- Core data,
- People data,
- Media data,
- Odds data,
- Knowledge data,
- historické harvesty,
- aktuální sezonu,
- plánované zápasy,
- live data,
- periodické aktualizace,
- jednorázové doplnění,
- ručně spuštěné i autonomní workery.

## 1.3 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola vymezila provider routing a fallback jako řízený výběr zdroje podle sportu, entity, období, regionu, režimu, čerstvosti, kvality a provozních omezení.

**Přínos pro projekt:** MatchMatrix získává jednotné rozhodovací pravidlo, které omezuje nahodilý výběr providera a riziko nebezpečného automatického přepnutí.

**Návaznost na další kapitolu:** Následující kapitola definuje základní pojmy a role používané v routingovém workflow.

---

# 2. Základní pojmy a role

## 2.1 Routing

Routing je rozhodnutí, který schválený provider obslouží konkrétní datový požadavek.

Routing může proběhnout:

- před spuštěním workeru,
- při sestavení harvest plánu,
- před každým requestem,
- po selhání primárního zdroje,
- při změně kvality,
- při překročení limitu,
- po governance rozhodnutí.

## 2.2 Primární provider

Primární provider je preferovaný zdroj pro přesně vymezený rozsah.

Primární status neplatí obecně pro celý provider. Musí být veden například takto:

```text
Provider A
+ Football
+ Matches
+ season 2025/2026
+ Europe
+ historical
= PRIMARY
```

## 2.3 Sekundární provider

Sekundární provider je schválený alternativní zdroj.

Může sloužit pro:

- doplnění chybějících dat,
- kontrolní porovnání,
- omezený fallback,
- historická období,
- specifické regiony,
- specifické entity,
- obohacení vybraných atributů.

## 2.4 Fallback provider

Fallback provider je sekundární zdroj, který smí převzít přesně definovanou část provozu při splnění fallback podmínek.

Ne každý sekundární provider je automaticky fallback.

## 2.5 Routing rule

Routing rule je řízené pravidlo obsahující minimálně:

- sport,
- entitu,
- rozsah,
- režim,
- primární provider,
- fallback provider,
- prioritu,
- podmínku aktivace,
- podmínku návratu,
- platnost,
- schválení.

## 2.6 Routing decision

Routing decision je konkrétní výsledek aplikace pravidla.

Musí být možné zjistit:

- které pravidlo bylo použito,
- proč byl vybrán daný provider,
- zda byl použit fallback,
- které podmínky byly splněny,
- kdy rozhodnutí vzniklo.

## 2.7 Failover

Failover je provozní přepnutí z primárního providera na fallback.

Failover není totéž jako změna dlouhodobé strategie. Může být:

- dočasný,
- omezený,
- automaticky navržený,
- ručně potvrzený,
- okamžitý při bezpečnostním incidentu.

## 2.8 Failback

Failback je řízený návrat z fallback zdroje k primárnímu providerovi.

Návrat nesmí proběhnout pouze proto, že primární endpoint jednou odpověděl.

## 2.9 Source authority

Source authority vyjadřuje, pro které atributy má provider vyšší autoritu než jiný zdroj.

Příklad:

- oficiální liga může mít nejvyšší autoritu pro rozpis,
- specializovaný provider pro live statistiky,
- klub pro oficiální fotografii,
- Odds provider pro konkrétní sázkový trh.

## 2.10 Odpovědnosti

Routingová pravidla navrhuje Provider Governance společně s technickou, datovou a provozní kontrolou.

Strategické změny primárního providera schvaluje vlastník projektu.

Automatizace smí pravidlo aplikovat, ale nesmí sama vytvořit nový strategický primární vztah bez schválení.

## 2.11 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala routing, primární, sekundární a fallback providery, routingové rozhodnutí, failover, failback a autoritu zdroje.

**Přínos pro projekt:** Jednotné pojmy zabraňují zaměňování dočasného přepnutí, doplňkového zdroje a dlouhodobé změny primárního providera.

**Návaznost na další kapitolu:** Následující kapitola stanovuje routingový klíč a jeho povinné dimenze.

---

# 3. Routingový klíč

## 3.1 Povinné dimenze

Routing musí vycházet nejméně z těchto dimenzí:

| Dimenze | Význam |
|---|---|
| Sport | Football, Hockey, Basketball a další podporované sporty. |
| Entita | Matches, Teams, Players, Standings, Odds, Media a další. |
| Období | Sezona, historický rozsah nebo konkrétní časové okno. |
| Region | Země, kontinent, soutěž nebo jiná územní oblast. |
| Režim | Historical, Current, Pre-match, Live, Incremental nebo Full. |
| Čerstvost | Maximální přípustné stáří dat. |
| Kvalita | Minimální požadovaná úplnost, přesnost a mapovatelnost. |
| Náklad | Povolený tarif, request budget a finanční limit. |

## 3.2 Sport

Provider může být:

- aktivní pro jeden sport,
- aktivní pro více sportů,
- omezený jen na vybrané soutěže,
- kvalitní pro jeden sport a nepoužitelný pro jiný.

Stav `ACTIVE` u jednoho sportu se nepřenáší na další sport.

## 3.3 Entita

Směrování se vždy posuzuje podle entity.

Příklady entit:

- competitions,
- seasons,
- teams,
- players,
- coaches,
- referees,
- matches,
- standings,
- statistics,
- media,
- odds,
- venues.

Provider může být primární pro zápasy, ale pouze doplňkový pro hráče.

## 3.4 Období

Historická data a aktuální data mohou vyžadovat jiného providera.

Rozlišuje se například:

- historie do roku 2024,
- sezona 2025,
- sezona 2026,
- budoucí plánované zápasy,
- live události,
- posledních 24 hodin.

## 3.5 Region a soutěž

Globální provider nemusí mít stejné pokrytí ve všech regionech.

Routing může být definován pro:

- svět,
- kontinent,
- zemi,
- soutěž,
- úroveň soutěže,
- konkrétní federaci.

## 3.6 Režim použití

Doporučené režimy:

| Režim | Účel |
|---|---|
| HISTORICAL_FULL | Úplný historický harvest. |
| HISTORICAL_INCREMENTAL | Doplňování historie. |
| CURRENT_SEASON | Pravidelná aktualizace aktuální sezony. |
| PREMATCH | Aktualizace před začátkem zápasu. |
| LIVE | Časově citlivá data během události. |
| POSTMATCH | Uzavření a kontrola výsledku. |
| ENRICHMENT | Doplňování profilů a atributů. |
| AUDIT | Kontrolní porovnání bez přímého merge. |

## 3.7 Požadovaná čerstvost

Čerstvost může být vyjádřena:

- maximálním stářím,
- frekvencí aktualizace,
- časem od události,
- tolerancí zpoždění,
- požadavkem na live režim.

Fallback s pomalejší aktualizací může být vhodný pro historii, ale ne pro live data.

## 3.8 Požadovaná kvalita

Routing musí respektovat minimální hranice:

- úplnost,
- mapovací úspěšnost,
- stabilita ID,
- chybovost parseru,
- počet konfliktů,
- počet duplicit,
- post-importní rozdíl.

## 3.9 Náklad a limit

Provider nesmí být vybrán, pokud:

- není dostupný schválený tarif,
- request budget nestačí,
- byl překročen finanční limit,
- hrozí nekontrolované zpoplatnění,
- přístup je vyhrazen pro jinou prioritu.

## 3.10 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila routingový klíč založený na sportu, entitě, období, regionu, režimu, čerstvosti, kvalitě a nákladu.

**Přínos pro projekt:** Výběr zdroje lze provést přesně pro konkrétní potřebu a není nutné používat jeden globální provider pro celý sport.

**Návaznost na další kapitolu:** Následující kapitola stanovuje priority providerů a pravidla jejich porovnávání.

---

# 4. Priority providerů

## 4.1 Účel priority

Priorita určuje pořadí, v jakém se schválené zdroje zvažují.

Priorita sama o sobě nepovoluje použití. Provider musí současně:

- mít platný stav,
- být schválen pro daný rozsah,
- splnit kvalitativní podmínky,
- mít dostupný limit,
- nebýt v HOLD.

## 4.2 Doporučené úrovně

| Priorita | Význam |
|---|---|
| P0 | Povinný autoritativní zdroj pro vybraný atribut nebo rozhodnutí. |
| P1 | Primární produkční provider. |
| P2 | Sekundární produkční provider. |
| P3 | Fallback provider. |
| P4 | Doplňkový nebo enrichment zdroj. |
| P5 | Auditní nebo porovnávací zdroj. |
| P9 | Zakázaný pro automatické použití. |

## 4.3 Priorita není globální

Jeden provider může mít:

- P1 pro Football Matches,
- P2 pro Football Players,
- P3 pro Basketball Matches,
- P5 pro Hockey,
- P9 pro Media.

## 4.4 Autorita atributu

Priorita může být rozdílná podle atributu.

Příklad:

| Atribut | Primární autorita |
|---|---|
| Začátek zápasu | Oficiální soutěž nebo ověřený Core provider |
| Výsledek | Ověřený Core provider |
| Fotografie hráče | Oficiální klub nebo licencovaný Media provider |
| Název stadionu | Oficiální klub nebo Knowledge provider |
| Kurz | Konkrétní Odds provider |

## 4.5 Dynamické provozní skóre

K pevné prioritě lze přidat provozní skóre.

Skóre může zahrnovat:

- dostupnost,
- latenci,
- chybovost,
- čerstvost,
- mapovací úspěšnost,
- spotřebu limitu,
- nedávné incidenty.

Dynamické skóre nesmí změnit strategické pořadí bez definovaných mezí.

## 4.6 Zákaz tichého přepsání priority

Automatizace nesmí trvale změnit P1 na jiného providera bez:

- evidence problému,
- návrhu změny,
- schválení,
- aktualizace routing rule,
- auditní stopy.

## 4.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala prioritní úrovně, atributovou autoritu a možnost doplnění pevné priority o provozní skóre.

**Přínos pro projekt:** MatchMatrix může oddělit dlouhodobou strategii zdrojů od krátkodobého provozního stavu a současně zabránit tichým změnám priority.

**Návaznost na další kapitolu:** Následující kapitola stanovuje podmínky, za kterých může být fallback aktivován.

---

# 5. Podmínky aktivace fallbacku

## 5.1 Fallback není první reakce na každou chybu

Jednotlivý timeout nebo jedna chybová odpověď obvykle neznamená okamžité přepnutí.

Před fallbackem se podle typu provozu používá:

- retry,
- krátké zpoždění,
- jiný endpoint stejného providera,
- snížení rozsahu,
- pokračování pouze v RAW,
- ruční posouzení.

## 5.2 Technické podmínky

Fallback může být aktivován například při:

- opakovaném timeoutu,
- dlouhodobém `5xx`,
- nedostupné autentizaci,
- změně schématu blokující parser,
- nedostupném endpointu,
- opakovaném prázdném payloadu,
- nedostupnosti služby v definovaném čase.

## 5.3 Limitní podmínky

Fallback může být aktivován při:

- `429 Too Many Requests`,
- vyčerpaném denním limitu,
- vyčerpaném měsíčním limitu,
- dosažení finanční stop hranice,
- rezervaci limitu pro vyšší prioritu,
- dočasném snížení tarifu.

## 5.4 Datové podmínky

Fallback může být aktivován při:

- neúplném rozsahu,
- chybějící sezoně,
- chybějící soutěži,
- nestabilních ID,
- vysoké chybovosti mapování,
- zvýšeném počtu duplicit,
- neslučitelných výsledcích,
- dlouhodobé ztrátě čerstvosti.

## 5.5 Governance podmínky

Fallback je povinný nebo doporučený při:

- stavu HOLD primárního providera,
- právním omezení,
- změně licence,
- rozhodnutí Source Governance,
- bezpečnostním incidentu,
- dočasném zákazu publikace.

## 5.6 Časové podmínky

Podmínka musí uvádět:

- počet neúspěchů,
- délku problému,
- časové okno,
- minimální dobu fallbacku,
- maximální dobu fallbacku,
- okamžik ruční eskalace.

## 5.7 Podmínka použitelnosti fallbacku

Fallback lze aktivovat pouze tehdy, pokud:

- má stav `ACTIVE` nebo odpovídající `LIMITED`,
- je schválen pro konkrétní rozsah,
- má platný tarif,
- má dostupný request budget,
- jeho parser je funkční,
- jeho mapování je ověřené,
- jeho kvalita splňuje minimální práh.

## 5.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila technické, limitní, datové, governance a časové podmínky aktivace fallbacku.

**Přínos pro projekt:** Přepnutí probíhá pouze při předem definované a měřitelné situaci a neslouží jako nekontrolovaná reakce na každou jednotlivou chybu.

**Návaznost na další kapitolu:** Následující kapitola popisuje fallback řetězce a jejich bezpečné pořadí.

---

# 6. Fallback řetězce

## 6.1 Jednoduchý fallback

Nejjednodušší řetězec:

```text
P1 Primary
→ P3 Fallback
→ HOLD / WAIT
```

Pokud fallback není použitelný, systém nesmí pokračovat náhodným zdrojem.

## 6.2 Víceúrovňový řetězec

Příklad:

```text
P1 Provider A
→ P2 Provider B
→ P3 Official Source
→ P5 Audit Source
→ HOLD
```

Každý krok musí mít samostatné podmínky.

## 6.3 Rozdělený fallback

Fallback nemusí převzít celý rozsah.

Může převzít pouze:

- chybějící soutěže,
- konkrétní období,
- konkrétní entity,
- konkrétní atributy,
- konkrétní region,
- pouze nové zápasy,
- pouze uzavření výsledků.

## 6.4 Fallback podle režimu

Příklad:

| Režim | Primární | Fallback |
|---|---|---|
| Historical | Provider A | Provider B |
| Current season | Provider A | Official Source |
| Live | Provider C | Bez automatického fallbacku |
| Enrichment | Provider D | Provider E |
| Audit | Provider F | — |

## 6.5 Fallback bez merge

Bezpečný režim může dovolit:

```text
fallback harvest
→ RAW
→ staging
→ audit
```

bez automatického merge do kanonické vrstvy.

## 6.6 Maximální délka řetězce

Příliš dlouhý fallback řetězec:

- zvyšuje složitost,
- zhoršuje auditovatelnost,
- zvyšuje riziko duplicit,
- komplikuje návrat,
- může nečekaně spotřebovat limity.

Doporučená běžná délka je jeden až dva fallback kroky.

## 6.7 Fallback a source authority

Fallback nesmí přepsat atribut, pro který nemá dostatečnou autoritu.

Může být povoleno:

- doplnit chybějící hodnotu,
- vytvořit návrh,
- označit konflikt,
- uložit do stagingu,
- čekat na potvrzení.

## 6.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola popsala jednoduché, víceúrovňové, rozdělené a režimové fallback řetězce včetně bezpečného režimu bez merge.

**Přínos pro projekt:** Fallback lze přizpůsobit reálnému rozsahu problému a není nutné přepínat celý sport nebo celého providera.

**Návaznost na další kapitolu:** Následující kapitola stanovuje prevenci duplicit a konfliktů při použití více zdrojů.

---

# 7. Prevence duplicit a konfliktů

## 7.1 Riziko souběžného harvestu

Při fallbacku mohou být stejná data získána:

- z primárního zdroje před výpadkem,
- z fallbacku během výpadku,
- z primárního zdroje po obnovení,
- z opožděného retry.

Bez koordinace vznikají duplicity a konflikty.

## 7.2 Jedno aktivní routingové rozhodnutí

Pro jednu kombinaci routingového klíče má být v jednom čase právě jedno aktivní produkční rozhodnutí.

Výjimkou je řízený paralelní auditní režim.

## 7.3 Idempotence

Worker a merge musí být navrženy tak, aby opakování stejného vstupu nevedlo k nekontrolovanému množení záznamů.

## 7.4 Provider map

Každý externí identifikátor musí být svázán s:

- providerem,
- sportem,
- entitou,
- kanonickou identitou,
- stavem mapování,
- datem ověření.

## 7.5 Deduplikační klíče

Podle entity lze použít například:

- provider ID,
- soutěž + sezona + účastníci + čas,
- tým + země + soutěž,
- osoba + datum narození + tým,
- bookmaker + market + selection + timestamp.

## 7.6 Konfliktní hodnoty

Při konfliktu se používá:

- source authority,
- pevná priorita,
- čerstvost,
- kvalita,
- historická spolehlivost,
- explicitní pravidlo atributu,
- HOLD nebo ruční kontrola.

## 7.7 Zákaz přepsání pořadím importu

Poslední příchozí hodnota nesmí automaticky vyhrát pouze proto, že byla importována později.

## 7.8 Paralelní porovnání

Při změně primárního providera se doporučuje:

- dočasný souběžný harvest,
- oddělené staging záznamy,
- porovnávací report,
- zákaz automatického dvojitého merge,
- potvrzení rozdílů.

## 7.9 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila jedno aktivní routingové rozhodnutí, idempotenci, provider map, deduplikační klíče a pravidla řešení konfliktů.

**Přínos pro projekt:** Fallback nezpůsobí nekontrolované množení záznamů ani přepisování hodnot pouhým pořadím importu.

**Návaznost na další kapitolu:** Následující kapitola popisuje řízený návrat k primárnímu providerovi.

---

# 8. Failback – návrat k primárnímu providerovi

## 8.1 Obnovení endpointu není dostatečný důkaz

Primární provider se nesmí automaticky vrátit do plného provozu po jediné úspěšné odpovědi.

## 8.2 Podmínky failbacku

Doporučené podmínky:

- stabilní dostupnost po definovanou dobu,
- úspěšné testovací requesty,
- funkční parser,
- správná struktura payloadu,
- dostatečný limit,
- platná licence,
- žádný aktivní HOLD,
- kontrola čerstvosti,
- kontrola konfliktů s fallback daty.

## 8.3 Reconciliation

Před návratem se porovnává období fallbacku:

- chybějící záznamy,
- rozdíly,
- duplicity,
- konflikty,
- aktualizace,
- konečné výsledky,
- změny identit.

## 8.4 Postupný návrat

Doporučený postup:

1. testovací request,
2. RAW bez merge,
3. staging,
4. porovnání,
5. omezený merge,
6. obnovení P1,
7. ukončení fallbacku,
8. kontrola po návratu.

## 8.5 Ochranná doba

Po failbacku může fallback zůstat připraven jako záloha, ale nesmí současně pokračovat v plném produkčním harvestu bez jasného režimu.

## 8.6 Neúspěšný failback

Pokud se problém vrátí:

- obnoví se fallback,
- incident se eskaluje,
- primární provider může přejít do `LIMITED`, `HOLD` nebo `DEPRECATED`,
- provede se revalidace.

## 8.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila podmínky návratu, porovnání dat z období fallbacku a postupný failback od testu po plné obnovení.

**Přínos pro projekt:** Návrat k primárnímu zdroji neobnoví chybu ani nezanechá nezkontrolované rozdíly mezi zdroji.

**Návaznost na další kapitolu:** Následující kapitola stanovuje zvláštní pravidla pro historická, aktuální a live data.

---

# 9. Routing podle časového režimu

## 9.1 Historický harvest

Pro historii je důležitá:

- hloubka pokrytí,
- úplnost sezon,
- stabilita ID,
- cena plného harvestu,
- možnost retry,
- nízké riziko duplicit,
- kontrola dlouhých běhů.

Historický provider nemusí být vhodný pro live provoz.

## 9.2 Aktuální sezona

Pro aktuální sezonu se sleduje:

- pravidelná čerstvost,
- změny harmonogramu,
- odložené zápasy,
- průběžné výsledky,
- opravy providera,
- aktualizace sestav a statistik.

## 9.3 Pre-match

Pre-match režim vyžaduje:

- přesný čas zápasu,
- stav zápasu,
- účastníky,
- soutěž,
- případné kurzy,
- aktualizaci před začátkem.

## 9.4 Live

Live routing má nejpřísnější požadavky na:

- latenci,
- stabilitu,
- pořadí událostí,
- časová razítka,
- přerušení,
- rate limit,
- okamžitý incidentní režim.

Automatický fallback pro live data smí být použit jen tehdy, pokud je předem plně ověřen.

## 9.5 Post-match

Post-match routing uzavírá:

- konečný výsledek,
- stav události,
- statistiky,
- tabulky,
- navazující vazby,
- kontrolu konfliktu s live daty.

## 9.6 Enrichment

Enrichment může používat pomalejší nebo doplňkové zdroje.

Nesmí však bez pravidla přepsat autoritativní základní atributy.

## 9.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola rozdělila routing na historický, aktuální, pre-match, live, post-match a enrichment režim.

**Přínos pro projekt:** Každý časový režim může používat odlišný zdroj a odlišné bezpečnostní podmínky podle skutečné potřeby.

**Návaznost na další kapitolu:** Následující kapitola řeší request budget, náklady a ochranu tarifů.

---

# 10. Request budget a nákladové řízení

## 10.1 Routing musí znát rozpočet

Výběr providera musí respektovat:

- denní limit,
- měsíční limit,
- limit endpointu,
- rezervu pro live provoz,
- cenu překročení,
- prioritu sportu,
- prioritu entity.

## 10.2 Rezervace kapacity

Část limitu může být rezervována pro:

- live data,
- urgentní opravy,
- aktuální sezonu,
- ověřovací requesty,
- incidentní diagnostiku.

Historický harvest nesmí spotřebovat celý limit bez ochrany.

## 10.3 Budget-aware routing

Routing může přesměrovat požadavek, pokud:

- primární limit je téměř vyčerpán,
- fallback má dostupný schválený limit,
- kvalita fallbacku je dostatečná,
- přepnutí neporuší licenci ani prioritu.

## 10.4 Stop hranice

Povinné stop hranice:

- maximální počet requestů,
- maximální cena,
- maximální délka běhu,
- maximální počet chyb,
- minimální efektivita requestu.

## 10.5 Efektivita

Sleduje se:

```text
použitelné záznamy / počet requestů
```

Nízká efektivita může vést ke změně routing rule nebo k omezení providera.

## 10.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila rozpočtové limity, rezervaci kapacity, budget-aware routing a provozní stop hranice.

**Přínos pro projekt:** Fallback ani historický harvest nemohou nekontrolovaně spotřebovat tarif nebo ohrozit důležitější provoz.

**Návaznost na další kapitolu:** Následující kapitola propojuje routing s health monitoringem a incidentními stavy.

---

# 11. Health monitoring a incidentní routing

## 11.1 Vstupní signály

Routing může využívat:

- dostupnost,
- latenci,
- podíl úspěšných requestů,
- `429`,
- `5xx`,
- prázdné payloady,
- parser errors,
- změny schématu,
- mapovací úspěšnost,
- konflikty,
- čerstvost,
- spotřebu limitu.

## 11.2 Provozní stavy

| Stav | Dopad na routing |
|---|---|
| HEALTHY | Běžné použití podle priority. |
| DEGRADED | Omezení rozsahu nebo zvýšený dohled. |
| RATE_LIMITED | Budget-aware fallback nebo čekání. |
| PARTIAL | Routing jen pro funkční rozsah. |
| FAILED | Retry, fallback nebo HOLD. |
| HOLD | Automatické použití zakázáno. |
| UNKNOWN | Konzervativní režim a kontrola. |

## 11.3 Hystereze

Aby systém nepřepínal mezi providery při každém krátkém výkyvu, používá se:

- minimální doba problému,
- minimální počet chyb,
- minimální doba stabilizace,
- rozdílný práh pro failover a failback.

## 11.4 Eskalace

Eskalace je povinná, pokud:

- fallback trvá příliš dlouho,
- není dostupný žádný schválený zdroj,
- vznikají konflikty,
- hrozí vyčerpání limitu,
- je ohrožena aktuální sezona,
- je ohrožena kvalita kanonických dat.

## 11.5 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola propojila routing s health signály, provozními stavy, hysterezí a eskalačními pravidly.

**Přínos pro projekt:** Systém reaguje na skutečný trend a nekolísá mezi zdroji při jednotlivých krátkodobých chybách.

**Návaznost na další kapitolu:** Následující kapitola stanovuje auditní stopu routingových rozhodnutí.

---

# 12. Auditní stopa

## 12.1 Povinný záznam rozhodnutí

Každé významné routingové rozhodnutí má obsahovat:

- čas,
- routingový klíč,
- vybraného providera,
- předchozího providera,
- použité pravidlo,
- důvod,
- health stav,
- dostupný limit,
- režim,
- rozsah,
- výsledek.

## 12.2 Záznam failoveru

Failover záznam obsahuje:

- příčinu,
- čas začátku,
- primární zdroj,
- fallback zdroj,
- dotčené sporty a entity,
- omezení,
- předpokládanou délku,
- odpovědnou roli.

## 12.3 Záznam failbacku

Failback záznam obsahuje:

- podmínky obnovení,
- výsledek testu,
- porovnání období fallbacku,
- konflikty,
- datum návratu,
- kontrolu po návratu.

## 12.4 Vazba na data

U důležitých záznamů musí být možné určit:

- který provider data dodal,
- zda šlo o primární nebo fallback cestu,
- které routing rule bylo aktivní,
- kdy došlo k merge.

## 12.5 Uchování

Routingová historie se nemaže při:

- změně priority,
- změně providera,
- ukončení tarifu,
- vyřazení zdroje,
- změně workeru.

## 12.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila auditní záznam pro běžné rozhodnutí, failover, failback a vazbu routingového rozhodnutí na výsledná data.

**Přínos pro projekt:** Lze zpětně doložit, proč byl použit konkrétní provider a jaký dopad mělo přepnutí na databázi.

**Návaznost na další kapitolu:** Následující kapitola popisuje cílové napojení routingových pravidel na databázi a panel.

---

# 13. Databázový a panelový model

## 13.1 Doporučené logické objekty

Databázový model má dlouhodobě podporovat:

- provider registry,
- provider scope,
- routing rules,
- routing priority,
- fallback chain,
- source authority,
- health state,
- routing decision log,
- failover event,
- failback event,
- budget state,
- approval history.

## 13.2 Povinné vlastnosti routing rule

| Pole | Význam |
|---|---|
| Rule ID | Jednoznačný identifikátor pravidla. |
| Sport | Sportovní rozsah. |
| Entity | Datová entita. |
| Scope | Sezona, region nebo soutěž. |
| Mode | Historical, Current, Live a další. |
| Primary provider | Preferovaný zdroj. |
| Fallback provider | Schválená náhrada. |
| Priority | Pořadí použití. |
| Activation condition | Podmínka failoveru. |
| Recovery condition | Podmínka failbacku. |
| Valid from/to | Časová platnost. |
| Status | DRAFT, ACTIVE, HOLD nebo RETIRED. |
| Approved by | Schvalující role. |

## 13.3 Panel – Provider Matrix

Panel má zobrazovat:

- sport,
- provider,
- entitu,
- režim,
- hlavní stav,
- prioritu,
- fallback,
- health,
- limit,
- poslední běh,
- čerstvost,
- blokátory.

## 13.4 Panel – řízené akce

Doporučené akce:

- otevřít routing rule,
- navrhnout změnu priority,
- nastavit fallback,
- aktivovat failover,
- ukončit failover,
- spustit test failbacku,
- zobrazit porovnání,
- nastavit HOLD,
- otevřít auditní historii.

## 13.5 Blokace

Panel musí blokovat:

- fallback na neschválený rozsah,
- použití providera v HOLD,
- live fallback bez ověření,
- přepsání P1 bez schválení,
- dvojitý produkční harvest,
- merge bez provider map,
- přepnutí bez auditního důvodu.

## 13.6 Uživatelské zobrazení

Uživatel má vidět stručný český stav, například:

```text
PRIMÁRNÍ PROVIDER FUNGUJE
FALLBACK PŘIPRAVEN
FALLBACK AKTIVNÍ – DŮVOD: LIMIT API
NÁVRAT K PRIMÁRNÍMU ZDROJI ČEKÁ NA OVĚŘENÍ
ROUTING BLOKOVÁN – PROVIDER V HOLD
```

## 13.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala logické databázové objekty, vlastnosti routing rule, panel Provider Matrix, řízené akce a blokace.

**Přínos pro projekt:** Routing lze převést do jednoduchého panelového workflow bez ztráty technické a auditní přesnosti.

**Návaznost na další kapitolu:** Následující kapitola uvádí rozhodovací příklady pro typické situace MatchMatrix.

---

# 14. Rozhodovací příklady

## 14.1 Primární provider má krátký timeout

| Kontrola | Výsledek |
|---|---|
| Počet chyb | 1 |
| Trvání | krátké |
| Retry | povoleno |
| Fallback | neaktivovat |
| Akce | Retry a monitoring |

## 14.2 Primární provider vrací 429

| Kontrola | Výsledek |
|---|---|
| Limit | vyčerpán |
| Kritičnost | aktuální sezona |
| Fallback | schválen |
| Akce | Aktivovat budget-aware fallback |
| Návrat | Po obnovení limitu a kontrole |

## 14.3 Primární provider chybí pro starou sezonu

| Kontrola | Výsledek |
|---|---|
| Primární rozsah | neobsahuje sezonu |
| Sekundární provider | má historii |
| Režim | Historical |
| Akce | Směrovat přímo na historického providera |
| Failover | Nejde o incidentní failover |

## 14.4 Live provider selhal

| Kontrola | Výsledek |
|---|---|
| Live fallback | neověřen |
| Riziko | vysoké |
| Akce | HOLD live merge, zachovat audit |
| Povolení | Nepřepínat na neověřený zdroj |

## 14.5 Fallback má horší mapování

| Kontrola | Výsledek |
|---|---|
| Harvest | povolen |
| RAW | povoleno |
| Staging | povoleno |
| Automatický merge | zakázán |
| Akce | Porovnání a ruční kontrola |

## 14.6 Primární provider se obnovil

| Kontrola | Výsledek |
|---|---|
| Jedna odpověď | nestačí |
| Stabilizační doba | čeká |
| Parser | ověřit |
| Reconciliation | povinná |
| Akce | Postupný failback |

## 14.7 Změna primárního providera

Jde o governance změnu, nikoli běžný failover.

Vyžaduje:

- porovnávací test,
- změnu routing rule,
- schválení,
- migraci,
- kontrolu provider map,
- nový auditní záznam.

## 14.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola aplikovala routingová pravidla na timeout, rate limit, historickou mezeru, live výpadek, slabé mapování, obnovení a strategickou změnu primárního providera.

**Přínos pro projekt:** Provozní situace mají předvídatelnou reakci a systém nerozhoduje pouze podle technické dostupnosti endpointu.

**Návaznost na další kapitolu:** Následující kapitola shrnuje kontrolní kritéria dokumentu před schválením.

---

# 15. Kontrolní kritéria dokumentu

Dokument lze předložit ke schválení, pokud je potvrzeno:

- [ ] Document ID odpovídá oblasti `05_PROVIDERS`.
- [ ] Název souboru odpovídá `MM-STD-007`.
- [ ] Dokument navazuje na `MM-PRV-001` a `MM-PRV-002`.
- [ ] Routingový klíč obsahuje sport, entitu, období, region a režim.
- [ ] Primární status je omezen na konkrétní rozsah.
- [ ] Fallback provider je předem schválen.
- [ ] Podmínky failoveru a failbacku jsou měřitelné.
- [ ] Routing respektuje health stav a request budget.
- [ ] Live fallback bez ověření je zakázán.
- [ ] Víceproviderový provoz chrání před duplicitami.
- [ ] Pořadí importu nerozhoduje automaticky o konfliktu.
- [ ] Routingové změny vytvářejí auditní stopu.
- [ ] Panel blokuje neplatné přepnutí.
- [ ] Dokument neobsahuje API klíče ani tajné údaje.
- [ ] Terminologie odpovídá MM-REF-001 a MM-REF-002.
- [ ] Každá hlavní kapitola obsahuje závěr se shrnutím, přínosem a návazností.
- [ ] Historie verzí je doplněna.
- [ ] A17 neobsahuje nevyřešený strukturální blokátor.
- [ ] A24 a A7 budou spuštěny až po schválení a Git commitu.

## 15.1 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola převedla pravidla routingu, fallbacku, failoveru, failbacku, limitů, duplicit a auditní stopy do kontrolního seznamu.

**Přínos pro projekt:** Před schválením lze rychle ověřit, zda dokument obsahuje všechny bezpečnostní a provozní podmínky.

**Návaznost na další kapitolu:** Následující kapitola eviduje historii verzí dokumentu před závěrečným shrnutím.

---

# 16. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-17 | DRAFT – NEEDS_USER_APPROVAL | První návrh pravidel provider routingu, fallbacku, failoveru a failbacku MatchMatrix. |

---

# Závěr dokumentu

`MM-PRV-003` stanovuje jednotný a auditovatelný způsob výběru providerů pro jednotlivé sporty, entity, období, regiony a provozní režimy.

Routing vychází z přesného klíče a respektuje schválený rozsah, prioritu, kvalitu, health stav, request budget, licence a source authority. Fallback lze aktivovat pouze při splnění předem definovaných podmínek a pouze na provider, který je pro daný rozsah ověřený.

Dokument současně zavádí ochranu proti duplicitnímu harvestu, pravidla řešení konfliktů, řízený failback, nákladové limity, auditní stopu a panelové blokace.

Hlavním přínosem je možnost bezpečně provozovat víceproviderovou architekturu bez nekontrolovaného přepínání, přepisování kvalitnějších dat nebo ztráty dohledatelnosti.
