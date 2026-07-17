# MM-PRV-004

# PROVIDER HEALTH MONITORING MATCHMATRIX

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PRV-004 |
| Document ID | MM-PRV-004 |
| Název dokumentu | Provider Health Monitoring MatchMatrix |
| Typ dokumentu | PROVIDER_HEALTH_MONITORING |
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
| Navazuje na | MM-PRV-001, MM-PRV-002, MM-PRV-003 |
| Související dokumenty | MM-DOC-200, MM-DOC-300, MM-DOC-800, MM-DB-001, MM-DB-002, MM-DB-003, MM-REF-001, MM-REF-002 |
| Referenční standardy | MM-STD-001, MM-STD-003, MM-STD-004, MM-STD-006, MM-STD-007, MM-STD-008 |

---

# 1. Úvod

Provider Health Monitoring je řízené sledování technické dostupnosti, datové kvality, provozní stability, čerstvosti, nákladů a skutečného dopadu providerových toků na cílové vrstvy MatchMatrix.

Samotná úspěšná odpověď API neznamená, že provider funguje správně. Provider může vracet HTTP 200, ale současně:

- poskytovat prázdná data,
- vracet neúplné sezony,
- měnit identifikátory,
- zvyšovat počet konfliktů,
- způsobovat chyby parseru,
- produkovat nízkou mapovací úspěšnost,
- opožďovat live data,
- spotřebovávat nepřiměřený počet requestů,
- zapisovat méně dat než očekáváno,
- vytvářet nekvalitní nebo duplicitní kanonické záznamy.

Health monitoring proto musí sledovat celý tok:

```text
provider
→ request
→ odpověď
→ RAW
→ parser
→ staging
→ mapování
→ validace
→ merge
→ cílová vrstva
→ post-importní kontrola
```

## 1.1 Účel dokumentu

Dokument stanovuje:

- sledované health dimenze,
- provozní stavy,
- metriky,
- prahové hodnoty,
- pravidla alertů,
- hysterézi,
- incidentní eskalaci,
- vazbu na routing a fallback,
- revalidaci,
- auditní stopu,
- panelové zobrazení,
- cílové databázové objekty.

## 1.2 Rozsah

Pravidla se vztahují na:

- Core providery,
- People providery,
- Media providery,
- Odds providery,
- Knowledge providery,
- oficiální zdroje,
- API providery,
- souborové exporty,
- pravidelné i jednorázové harvesty,
- historické, aktuální i live režimy.

## 1.3 Základní princip

Health provideru se neposuzuje jednou globální hodnotou bez kontextu.

Stav musí být možné vyhodnotit pro kombinaci:

```text
provider
+ sport
+ entita
+ endpoint nebo datový tok
+ režim
+ období
+ cílová vrstva
```

## 1.4 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola vymezila Provider Health Monitoring jako sledování celého datového toku od requestu po cílovou vrstvu.

**Přínos pro projekt:** MatchMatrix nebude zaměňovat technicky dostupný endpoint za skutečně použitelný a kvalitní providerový tok.

**Návaznost na další kapitolu:** Následující kapitola definuje health dimenze, ze kterých se skládá celkový stav providera.

---

# 2. Health dimenze

## 2.1 Dostupnost

Dostupnost sleduje, zda provider a jeho konkrétní endpointy odpovídají v požadovaném čase.

Sleduje se zejména:

- počet úspěšných požadavků,
- počet timeoutů,
- počet síťových chyb,
- počet odpovědí 5xx,
- délka výpadku,
- počet opakovaných výpadků,
- dostupnost podle regionu nebo endpointu.

## 2.2 Výkon

Výkon sleduje:

- průměrnou latenci,
- medián,
- percentily,
- maximální latenci,
- čas zpracování odpovědi,
- čas parseru,
- čas staging zápisu,
- čas merge.

## 2.3 Stabilita schématu

Kontroluje se:

- přidání nebo odstranění polí,
- změna datového typu,
- změna struktury vnořených objektů,
- změna stránkování,
- změna identifikátorů,
- změna formátu času,
- změna enum hodnot,
- změna názvů polí.

## 2.4 Datová úplnost

Sleduje se:

- očekávaný počet záznamů,
- skutečný počet záznamů,
- počet prázdných payloadů,
- počet chybějících sezon,
- počet chybějících soutěží,
- počet chybějících povinných atributů,
- míra pokrytí.

## 2.5 Datová přesnost

Přesnost se hodnotí porovnáním:

- s oficiálním zdrojem,
- s jiným providerem,
- s historickou konzistencí,
- s kanonickými daty,
- s ručně ověřeným vzorkem.

## 2.6 Čerstvost

Sleduje se:

- čas poslední úspěšné aktualizace,
- stáří posledních dat,
- zpoždění proti události,
- zpoždění proti jinému zdroji,
- dodržení plánované frekvence.

## 2.7 Mapovací kvalita

Sleduje se:

- počet přesně spárovaných entit,
- počet nových mapování,
- počet nespárovaných entit,
- počet konfliktů,
- počet mapování v HOLD,
- počet ručně potvrzených mapování.

## 2.8 Merge kvalita

Sleduje se:

- počet vytvořených kanonických záznamů,
- počet aktualizací,
- počet odmítnutých změn,
- počet konfliktů,
- počet duplicit,
- post-importní rozdíl,
- počet rollbacků.

## 2.9 Nákladová efektivita

Sleduje se:

- počet requestů,
- použitelné záznamy na request,
- cena na záznam,
- čerpání limitu,
- předpokládané vyčerpání tarifu,
- podíl nevyužitelných odpovědí.

## 2.10 Právní a licenční stav

Health stav musí zahrnout také:

- platnost licence,
- platnost tarifu,
- změnu podmínek,
- změnu atribuce,
- omezení ukládání,
- omezení publikace,
- právní incident.

## 2.11 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola rozdělila health do oblastí dostupnosti, výkonu, schématu, úplnosti, přesnosti, čerstvosti, mapování, merge, nákladů a licencí.

**Přínos pro projekt:** Celkový stav providera lze vysvětlit konkrétními měřitelnými příčinami.

**Návaznost na další kapitolu:** Následující kapitola definuje jednotné provozní stavy providera.

---

# 3. Provozní health stavy

## 3.1 Přehled stavů

| Stav | Český význam | Základní charakteristika |
|---|---|---|
| HEALTHY | V pořádku | Tok funguje v očekávaném rozsahu. |
| DEGRADED | Zhoršený | Tok funguje, ale některé ukazatele jsou pod očekáváním. |
| RATE_LIMITED | Omezen limitem | Další provoz je omezen request budgetem nebo tarifem. |
| PARTIAL | Částečný | Funguje pouze část endpointů, sportů nebo entit. |
| STALE | Neaktuální | Data jsou starší než povolený práh. |
| SCHEMA_CHANGED | Změna schématu | Struktura odpovědi se změnila a vyžaduje kontrolu. |
| DATA_QUALITY_RISK | Riziko kvality | Data jsou dostupná, ale kvalita je pod minimálním prahem. |
| FAILED | Selhání | Tok nevytvořil použitelný výsledek. |
| HOLD | Pozastaveno | Automatické použití je governance nebo bezpečnostně zakázáno. |
| UNKNOWN | Neznámý | Stav nelze spolehlivě určit. |
| RECOVERING | Obnovování | Provider se po incidentu vrací do stabilního provozu. |

## 3.2 HEALTHY

Provider je `HEALTHY`, pokud:

- odpovídá v definovaném rozsahu,
- plní požadovanou čerstvost,
- parser je stabilní,
- mapování je nad minimálním prahem,
- merge nevytváří nepřijatelný počet konfliktů,
- limit je dostatečný,
- neexistuje aktivní právní blokace.

## 3.3 DEGRADED

Provider je `DEGRADED`, pokud:

- odpovědi jsou pomalé,
- část dat chybí,
- čerstvost se zhoršuje,
- roste počet retry,
- mapovací úspěšnost klesá,
- ale tok je stále použitelný v omezeném rozsahu.

## 3.4 RATE_LIMITED

Stav `RATE_LIMITED` vzniká při:

- 429,
- vyčerpaném denním limitu,
- vyčerpaném měsíčním limitu,
- dosažení finanční stop hranice,
- rezervaci zbývajícího limitu pro vyšší prioritu.

## 3.5 PARTIAL

Provider je `PARTIAL`, pokud:

- fungují jen některé endpointy,
- chybí některé soutěže,
- fungují jen některé sporty,
- některé entity jsou použitelné a jiné ne,
- část regionu není dostupná.

## 3.6 STALE

Stav `STALE` znamená, že:

- data jsou starší než povolený práh,
- poslední úspěšný harvest je příliš starý,
- plánovaný běh neproběhl,
- provider vrací historicky poslední hodnotu bez nové aktualizace.

## 3.7 SCHEMA_CHANGED

Stav vzniká při nečekané změně struktury odpovědi.

Podle dopadu může vést k:

- zvýšenému monitoringu,
- omezení parseru,
- zastavení merge,
- HOLD.

## 3.8 DATA_QUALITY_RISK

Používá se při:

- vysokém počtu duplicit,
- nízké mapovací úspěšnosti,
- nestabilních identifikátorech,
- neúplných sezonách,
- nekonzistentních výsledcích,
- konfliktech s autoritativním zdrojem.

## 3.9 FAILED

Tok je `FAILED`, pokud:

- request nedoběhl,
- parser selhal,
- staging zápis selhal,
- merge selhal,
- nevznikl použitelný výsledek,
- post-importní kontrola prokázala zásadní chybu.

## 3.10 HOLD

`HOLD` je řízená blokace. Má přednost před ostatními stavy.

Provider v HOLD nesmí být automaticky použit pro:

- produkční routing,
- fallback,
- merge,
- publikaci,
- vytváření nových entit.

## 3.11 UNKNOWN

Stav `UNKNOWN` znamená, že:

- monitoring nemá dostatek dat,
- metriky se nepodařilo načíst,
- stav je zastaralý,
- nebyl dokončen kontrolní běh.

UNKNOWN se nesmí automaticky interpretovat jako HEALTHY.

## 3.12 RECOVERING

Provider je `RECOVERING`, pokud:

- incident skončil,
- probíhají testovací requesty,
- probíhá porovnání,
- failback ještě nebyl dokončen,
- stabilita zatím není potvrzena.

## 3.13 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala jedenáct health stavů a jejich konkrétní význam.

**Přínos pro projekt:** Panel i automatizace mohou používat jednotné stavy bez zaměňování výpadku, omezení, zastaralosti a datového rizika.

**Návaznost na další kapitolu:** Následující kapitola stanovuje metriky a jejich výpočet.

---

# 4. Metriky

## 4.1 Úspěšnost requestů

```text
úspěšné requesty / všechny requesty × 100
```

Úspěšný request musí být definován přísněji než pouze HTTP 200.

Může vyžadovat:

- platný payload,
- očekávanou strukturu,
- neprázdný výsledek,
- úspěšný parser.

## 4.2 Latence

Sleduje se:

- průměr,
- medián,
- P90,
- P95,
- P99,
- maximum.

## 4.3 Parser success rate

```text
úspěšně zpracované payloady / všechny payloady × 100
```

## 4.4 Mapping success rate

```text
spárované entity / všechny entity vyžadující mapování × 100
```

## 4.5 Merge success rate

```text
úspěšně aplikované změny / všechny validní změny × 100
```

## 4.6 Freshness lag

```text
čas kontroly - čas posledních validních providerových dat
```

## 4.7 Completeness rate

```text
skutečný počet platných záznamů / očekávaný počet záznamů × 100
```

## 4.8 Conflict rate

```text
konfliktní záznamy / všechny porovnané záznamy × 100
```

## 4.9 Duplicate rate

```text
duplicitní kandidáti / všechny nové kandidáty × 100
```

## 4.10 Request efficiency

```text
použitelné záznamy / počet requestů
```

## 4.11 Budget consumption

Sleduje se:

- absolutní čerpání,
- procento limitu,
- rychlost čerpání,
- odhad do vyčerpání,
- rezervovaná kapacita,
- využití podle priority.

## 4.12 Recovery time

```text
čas obnovení stabilního stavu - čas začátku incidentu
```

## 4.13 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila základní metriky dostupnosti, výkonu, parseru, mapování, merge, čerstvosti, úplnosti, konfliktů, duplicit, efektivity a obnovy.

**Přínos pro projekt:** Health stav lze vypočítat z jednotných a porovnatelných ukazatelů.

**Návaznost na další kapitolu:** Následující kapitola stanovuje prahové hodnoty a pravidla jejich správy.

---

# 5. Prahové hodnoty

## 5.1 Prah není univerzální

Prahy se musí definovat podle:

- sportu,
- entity,
- režimu,
- rizikové třídy,
- priority,
- typu providera,
- očekávané frekvence.

## 5.2 Doporučené typy prahů

| Typ | Význam |
|---|---|
| Warning threshold | Zhoršení vyžadující zvýšený dohled. |
| Critical threshold | Stav vyžadující zásah nebo omezení. |
| Recovery threshold | Hodnota nutná pro návrat ke zdravému stavu. |
| Stop threshold | Hodnota, při které se tok musí zastavit. |

## 5.3 Příklad dostupnosti

| Stav | Příklad |
|---|---|
| HEALTHY | úspěšnost ≥ 99 % |
| DEGRADED | 95–98,99 % |
| FAILED | < 95 % |

Příklad je orientační a musí být přizpůsoben konkrétnímu režimu.

## 5.4 Příklad mapování

| Stav | Příklad |
|---|---|
| HEALTHY | mapování ≥ 98 % |
| DEGRADED | 90–97,99 % |
| DATA_QUALITY_RISK | < 90 % |

## 5.5 Příklad čerstvosti

Pro live data mohou být prahy v sekundách nebo minutách.

Pro historii mohou být v hodinách nebo dnech.

## 5.6 Příklad request budgetu

| Stav | Čerpání |
|---|---|
| HEALTHY | pod 70 % |
| DEGRADED | 70–89 % |
| RATE_LIMITED | 90–99 % |
| STOP | 100 % nebo finanční stop hranice |

## 5.7 Recovery threshold

Recovery threshold má být přísnější než podmínka ukončení jedné chyby.

Příklad:

- failover při 5 chybách za 10 minut,
- návrat až po 30 minutách stabilního provozu.

## 5.8 Změna prahu

Změna prahu musí být:

- zdůvodněná,
- verzovaná,
- časově označená,
- auditovatelná,
- schválená podle dopadu.

## 5.9 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila warning, critical, recovery a stop prahy a zdůraznila jejich závislost na konkrétním režimu.

**Přínos pro projekt:** Systém nereaguje na neurčité dojmy, ale na předem definované hranice.

**Návaznost na další kapitolu:** Následující kapitola stanovuje vyhodnocovací okna, hysterézi a stabilizaci stavů.

---

# 6. Vyhodnocovací okna a hystereze

## 6.1 Okamžitá hodnota nestačí

Jeden request nemusí představovat skutečný stav providera.

Monitoring používá:

- početní okno,
- časové okno,
- klouzavé okno,
- poslední úplný běh,
- trend.

## 6.2 Krátké okno

Používá se pro:

- live data,
- timeouty,
- rate limit,
- dostupnost.

## 6.3 Dlouhé okno

Používá se pro:

- mapovací kvalitu,
- úplnost historie,
- nákladovou efektivitu,
- trend konfliktů,
- trend duplicit.

## 6.4 Hystereze

Hystereze zabraňuje rychlému přepínání mezi HEALTHY a DEGRADED.

Používá:

- rozdílný práh pro zhoršení a zlepšení,
- minimální dobu v novém stavu,
- minimální počet vzorků,
- recovery threshold.

## 6.5 Stabilizační doba

Po incidentu může provider zůstat v `RECOVERING`, dokud:

- neproběhne dostatečný počet úspěšných requestů,
- parser není stabilní,
- data nejsou čerstvá,
- neproběhne reconciliation,
- neproběhne post-importní kontrola.

## 6.6 Neznámý stav

Pokud okno neobsahuje dostatek dat, výsledek je `UNKNOWN`, nikoli HEALTHY.

## 6.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila časová a početní okna, hysterézi, stabilizační dobu a konzervativní práci s nedostatkem dat.

**Přínos pro projekt:** Monitoring nebude kolísat při jednotlivých chybách ani falešně označovat neznámý stav jako zdravý.

**Návaznost na další kapitolu:** Následující kapitola stanovuje alerty a jejich závažnost.

---

# 7. Alerty

## 7.1 Alert musí být akční

Alert musí odpovědět:

- co se stalo,
- kde se to stalo,
- kdy to začalo,
- jaký je dopad,
- zda existuje fallback,
- jaký je doporučený zásah.

## 7.2 Závažnost alertů

| Úroveň | Význam |
|---|---|
| INFO | Informace bez nutnosti zásahu. |
| WARNING | Zhoršení vyžadující sledování. |
| HIGH | Významný problém s dopadem na část provozu. |
| CRITICAL | Riziko poškození dat, výpadku nebo právního problému. |

## 7.3 Deduplikace alertů

Stejný incident nesmí vytvářet nekontrolované množství upozornění.

Používá se:

- incident ID,
- agregace,
- cooldown,
- změna stavu,
- potvrzení vyřešení.

## 7.4 Eskalace

Alert se eskaluje, pokud:

- trvá déle,
- zvyšuje se dopad,
- selže fallback,
- hrozí vyčerpání limitu,
- vzniká datové poškození,
- není potvrzena odpovědná osoba.

## 7.5 Potlačení

Alert lze dočasně potlačit pouze s:

- důvodem,
- časovou platností,
- odpovědnou osobou,
- definovaným rizikem.

## 7.6 Ukončení alertu

Alert se uzavírá až po:

- obnovení podmínek,
- potvrzení stabilizace,
- kontrole dopadu,
- záznamu výsledku.

## 7.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala akční alerty, jejich závažnost, deduplikaci, eskalaci, potlačení a uzavření.

**Přínos pro projekt:** Uživatel nebude zahlcen technickými hláškami bez kontextu a dostane pouze smysluplné provozní informace.

**Návaznost na další kapitolu:** Následující kapitola popisuje incidentní workflow od detekce po uzavření.

---

# 8. Incidentní workflow

## 8.1 Detekce

Incident může vzniknout:

- automatickou metrikou,
- post-importní kontrolou,
- uživatelským zjištěním,
- porovnáním providerů,
- změnou licence,
- upozorněním providera.

## 8.2 Klasifikace

Určuje se:

- typ incidentu,
- závažnost,
- provider,
- sport,
- entita,
- režim,
- dopad,
- riziko datového poškození.

## 8.3 Okamžité opatření

Podle rizika lze:

- spustit retry,
- omezit rozsah,
- zastavit merge,
- aktivovat fallback,
- nastavit HOLD,
- zachovat pouze RAW,
- zastavit plánovač.

## 8.4 Diagnostika

Diagnostika porovnává:

- request log,
- payload,
- parser,
- staging,
- mapování,
- merge,
- cílovou vrstvu,
- jiný zdroj.

## 8.5 Oprava

Oprava může zahrnovat:

- změnu parseru,
- změnu mapování,
- opravu konfigurace,
- změnu limitu,
- změnu routing rule,
- změnu priority,
- rollback,
- reimport.

## 8.6 Obnova

Obnova vyžaduje:

- test,
- kontrolu dat,
- reconciliation,
- postupný návrat,
- monitoring v RECOVERING.

## 8.7 Uzavření incidentu

Incident se uzavírá s údaji:

- příčina,
- dopad,
- řešení,
- ověření,
- preventivní opatření,
- odpovědná osoba,
- datum uzavření.

## 8.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila incidentní workflow od detekce přes klasifikaci, opatření, diagnostiku, opravu a obnovu až po uzavření.

**Přínos pro projekt:** Providerový incident má jednotný a auditovatelný průběh místo nahodilých technických zásahů.

**Návaznost na další kapitolu:** Následující kapitola propojuje health monitoring s routingem, fallbackem a HOLD.

---

# 9. Vazba na routing, fallback a HOLD

## 9.1 Health jako vstup routingu

Routing používá health stav jako jeden z rozhodovacích vstupů.

Health nesmí být jediným kritériem. Musí být kombinován s:

- schváleným rozsahem,
- prioritou,
- licencí,
- request budgetem,
- source authority.

## 9.2 Automatický failover

Automatický failover je povolen jen pokud:

- je definováno routing rule,
- fallback je schválen,
- trigger je měřitelný,
- health stav splnil podmínku,
- nevznikne duplicitní produkční harvest.

## 9.3 HOLD má přednost

Provider v HOLD nesmí být vybrán ani tehdy, pokud technické metriky vypadají zdravě.

## 9.4 DEGRADED

DEGRADED může vést k:

- snížení frekvence,
- omezení rozsahu,
- zvýšení monitoringu,
- přípravě fallbacku,
- ručnímu posouzení.

## 9.5 DATA_QUALITY_RISK

Při riziku kvality se doporučuje:

- zachovat RAW,
- povolit staging,
- blokovat merge,
- vytvořit porovnávací report,
- zahájit incident.

## 9.6 Failback

Failback vyžaduje stav `RECOVERING` a následně potvrzení stabilního `HEALTHY`.

## 9.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila, jak health stav ovlivňuje routing, failover, failback, omezení a HOLD.

**Přínos pro projekt:** Monitoring se promítá do bezpečných provozních akcí bez obcházení governance pravidel.

**Návaznost na další kapitolu:** Následující kapitola stanovuje revalidaci a dlouhodobé trendy provideru.

---

# 10. Revalidace a trend

## 10.1 Revalidace

Revalidace potvrzuje, zda provider stále splňuje schválený rozsah.

Kontroluje:

- dostupnost,
- kvalitu,
- cenu,
- limit,
- licenci,
- API,
- mapování,
- fallback,
- incidenty.

## 10.2 Trend

Trend může být:

- IMPROVING,
- STABLE,
- DEGRADING,
- CRITICAL_DECLINE,
- UNKNOWN.

## 10.3 Dlouhodobé zhoršování

Dlouhodobý pokles může vést k:

- změně priority,
- LIMITED,
- HOLD,
- DEPRECATED,
- hledání náhrady.

## 10.4 Zlepšování

Zlepšení může vést k:

- rozšíření testu,
- zvýšení rozsahu,
- změně priority,
- návrhu ACTIVE.

Změna vyžaduje schvalovací workflow.

## 10.5 Povinná revalidace

Revalidace se spouští:

- periodicky,
- po změně API,
- po změně licence,
- po významném incidentu,
- po změně tarifu,
- před rozšířením rozsahu.

## 10.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila periodickou i událostní revalidaci a dlouhodobé trendové hodnocení providera.

**Přínos pro projekt:** Schválení provideru zůstává aktuální a reaguje na postupné zhoršování i změny služby.

**Návaznost na další kapitolu:** Následující kapitola stanovuje auditní stopu health monitoringu.

---

# 11. Auditní stopa

## 11.1 Povinný health záznam

Health záznam má obsahovat:

- provider,
- sport,
- entitu,
- režim,
- endpoint nebo tok,
- čas,
- stav,
- metriky,
- použité prahy,
- důkaz,
- zdroj měření.

## 11.2 Historie stavů

Při změně stavu se eviduje:

- stav před,
- stav po,
- čas změny,
- příčina,
- dopad,
- automatické nebo ruční rozhodnutí,
- navazující akce.

## 11.3 Alertní historie

Uchovává se:

- alert ID,
- závažnost,
- první výskyt,
- poslední výskyt,
- počet opakování,
- eskalace,
- potvrzení,
- uzavření.

## 11.4 Vazba na běh

Health záznam má být propojitelný s:

- worker run,
- request log,
- RAW payloadem,
- parser během,
- importem,
- routing decision,
- incidentem.

## 11.5 Neměnnost historie

Historie se nemaže při:

- obnovení,
- změně providera,
- změně priority,
- změně parseru,
- ukončení tarifu,
- vyřazení zdroje.

## 11.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola definovala health záznam, historii stavů, alertní historii a vazby na technické běhy.

**Přínos pro projekt:** Každý health stav lze zpětně doložit konkrétními metrikami a událostmi.

**Návaznost na další kapitolu:** Následující kapitola popisuje cílové databázové objekty.

---

# 12. Databázový model

## 12.1 Doporučené logické objekty

Databáze má dlouhodobě podporovat:

- provider health snapshot,
- provider health metric,
- provider health state history,
- provider alert,
- provider incident,
- provider threshold,
- provider recovery event,
- provider trend,
- provider health scope.

## 12.2 Health snapshot

Obsahuje:

- čas,
- provider,
- scope,
- celkový stav,
- hlavní důvod,
- souhrn metrik,
- aktivní alert,
- routing dopad.

## 12.3 Health metric

Obsahuje:

- metric name,
- hodnota,
- jednotka,
- časové okno,
- zdroj,
- threshold,
- vyhodnocení.

## 12.4 Health state history

Obsahuje:

- stav před,
- stav po,
- čas,
- důvod,
- trigger,
- schválení,
- incident ID.

## 12.5 Threshold

Obsahuje:

- scope,
- metriku,
- warning threshold,
- critical threshold,
- recovery threshold,
- stop threshold,
- platnost,
- verzi.

## 12.6 Incident

Obsahuje:

- incident ID,
- provider,
- scope,
- závažnost,
- stav,
- dopad,
- akce,
- příčinu,
- řešení,
- čas uzavření.

## 12.7 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola navrhla logické databázové objekty pro snapshoty, metriky, historii, alerty, prahy, trendy a incidenty.

**Přínos pro projekt:** Health monitoring lze uložit strukturovaně a propojit s routingem, workery a auditní historií.

**Návaznost na další kapitolu:** Následující kapitola stanovuje cílové zobrazení v řídicím panelu.

---

# 13. Panelové zobrazení

## 13.1 Provider Health přehled

Panel má zobrazovat:

- provider,
- sport,
- entitu,
- režim,
- stav,
- poslední úspěšný běh,
- čerstvost,
- úspěšnost requestů,
- mapovací úspěšnost,
- request budget,
- aktivní incident,
- fallback.

## 13.2 Český provozní stav

Příklady:

```text
PROVIDER FUNGUJE SPRÁVNĚ
PROVIDER JE ZPOMALENÝ
DATA JSOU NEAKTUÁLNÍ
LIMIT API JE TÉMĚŘ VYČERPÁN
ČÁST DAT NENÍ DOSTUPNÁ
ZMĚNILA SE STRUKTURA API
RIZIKO KVALITY – MERGE BLOKOVÁN
PROVIDER JE V HOLD
OBNOVA PROBÍHÁ
```

## 13.3 Detail providera

Detail má zobrazit:

- graf nebo historii stavu,
- poslední metriky,
- aktivní prahy,
- poslední incident,
- doporučenou akci,
- routingový dopad,
- odkazy na reporty.

## 13.4 Akce panelu

Doporučené akce:

- spustit health check,
- otevřít poslední report,
- potvrdit alert,
- aktivovat HOLD,
- připravit fallback,
- spustit recovery test,
- otevřít incident,
- spustit revalidaci.

## 13.5 Blokace

Panel musí blokovat:

- označení HEALTHY bez platných metrik,
- automatický failback bez recovery kontroly,
- merge při DATA_QUALITY_RISK,
- routing na provider v HOLD,
- potlačení kritického alertu bez důvodu.

## 13.6 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola stanovila přehled, české provozní stavy, detail providera, panelové akce a bezpečnostní blokace.

**Přínos pro projekt:** Uživatel získá rychlý a srozumitelný přehled bez nutnosti číst technické logy.

**Návaznost na další kapitolu:** Následující kapitola uvádí rozhodovací příklady pro typické health situace.

---

# 14. Rozhodovací příklady

## 14.1 Jednorázový timeout

| Oblast | Výsledek |
|---|---|
| Dostupnost | krátké selhání |
| Stav | HEALTHY nebo krátce DEGRADED |
| Akce | retry |
| Fallback | neaktivovat |

## 14.2 Opakované 5xx

| Oblast | Výsledek |
|---|---|
| Trvání | delší než práh |
| Stav | FAILED |
| Akce | incident, fallback nebo HOLD |
| Návrat | až po RECOVERING |

## 14.3 HTTP 200, ale prázdná data

| Oblast | Výsledek |
|---|---|
| Technika | odpověď přijata |
| Úplnost | nevyhovuje |
| Stav | DATA_QUALITY_RISK nebo PARTIAL |
| Akce | blokovat merge, porovnat zdroj |

## 14.4 Nízká mapovací úspěšnost

| Oblast | Výsledek |
|---|---|
| API | funguje |
| Parser | funguje |
| Mapping | pod prahem |
| Stav | DATA_QUALITY_RISK |
| Akce | staging povolen, merge blokován |

## 14.5 Téměř vyčerpaný limit

| Oblast | Výsledek |
|---|---|
| Budget | nad warning prahem |
| Stav | RATE_LIMITED |
| Akce | omezit historii, chránit live rezervu |
| Fallback | jen pokud je schválen |

## 14.6 Změna schématu

| Oblast | Výsledek |
|---|---|
| Schema fingerprint | změněn |
| Parser | částečně funguje |
| Stav | SCHEMA_CHANGED |
| Akce | zastavit merge a spustit test |

## 14.7 Provider se po výpadku obnovil

| Oblast | Výsledek |
|---|---|
| Endpoint | odpovídá |
| Stav | RECOVERING |
| Akce | test, reconciliation, postupný failback |
| HEALTHY | až po stabilizační době |

## 14.8 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola aplikovala health pravidla na timeout, 5xx, prázdná data, slabé mapování, limit, změnu schématu a obnovu.

**Přínos pro projekt:** Typické incidenty mají konzistentní a bezpečný postup.

**Návaznost na další kapitolu:** Následující kapitola shrnuje kontrolní kritéria dokumentu před schválením.

---

# 15. Kontrolní kritéria dokumentu

Dokument lze předložit ke schválení, pokud je potvrzeno:

- [ ] Document ID odpovídá oblasti `05_PROVIDERS`.
- [ ] Název souboru odpovídá `MM-STD-007`.
- [ ] Dokument navazuje na `MM-PRV-001`, `MM-PRV-002` a `MM-PRV-003`.
- [ ] Health stav je vyhodnocován pro konkrétní scope.
- [ ] Dokument rozlišuje technickou dostupnost a datovou kvalitu.
- [ ] Stavy HEALTHY, DEGRADED, FAILED, HOLD a UNKNOWN jsou jednoznačné.
- [ ] UNKNOWN se nepovažuje za HEALTHY.
- [ ] Prahy obsahují warning, critical, recovery a stop hodnotu.
- [ ] Hystereze brání rychlému kolísání stavů.
- [ ] Alert obsahuje dopad a doporučenou akci.
- [ ] Incidentní workflow obsahuje detekci, zásah, diagnostiku, obnovu a uzavření.
- [ ] Health monitoring je propojen s routingem a fallbackem.
- [ ] Provider v HOLD nelze automaticky použít.
- [ ] Databázové a panelové objekty jsou popsány.
- [ ] Dokument neobsahuje API klíče ani tajné údaje.
- [ ] Terminologie odpovídá MM-REF-001 a MM-REF-002.
- [ ] Každá hlavní kapitola obsahuje závěr se shrnutím, přínosem a návazností.
- [ ] Historie verzí je doplněna.
- [ ] A17 neobsahuje nevyřešený strukturální blokátor.
- [ ] A24 a A7 budou spuštěny až po schválení a Git commitu.

## 15.1 Závěr kapitoly

**Shrnutí kapitoly:** Kapitola převedla health monitoring, metriky, stavy, prahy, alerty, incidenty, routingové vazby a panelové blokace do kontrolního seznamu.

**Přínos pro projekt:** Před schválením lze ověřit úplnost technických, provozních i governance pravidel.

**Návaznost na další kapitolu:** Následující kapitola eviduje historii verzí dokumentu před závěrečným shrnutím.

---

# 16. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 0.9 | 2026-07-17 | DRAFT – NEEDS_USER_APPROVAL | První návrh pravidel Provider Health Monitoringu MatchMatrix. |

---

# Závěr dokumentu

`MM-PRV-004` stanovuje jednotný a auditovatelný systém sledování providerů MatchMatrix.

Health monitoring vyhodnocuje celý tok od requestu přes parser, staging, mapování a merge až po cílovou vrstvu. Rozlišuje dostupnost, výkon, čerstvost, úplnost, přesnost, stabilitu schématu, mapovací kvalitu, merge kvalitu, náklady a licenční stav.

Dokument zavádí jednotné provozní stavy, měřitelné metriky, prahy, hysterézi, alerty, incidentní workflow, revalidaci, auditní stopu a vazbu na routing, fallback a HOLD.

Hlavním přínosem je schopnost včas rozpoznat, zda provider pouze technicky odpovídá, nebo zda skutečně dodává kvalitní, čerstvá a bezpečně použitelná data.
