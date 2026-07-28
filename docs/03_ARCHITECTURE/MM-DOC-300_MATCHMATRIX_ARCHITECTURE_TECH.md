# MM-DOC-300

# MATCHMATRIX ARCHITECTURE

## TECH EDITION

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-DOC-300 |
| Název | MatchMatrix Architecture |
| Edice | MM-DOC TECH |
| Verze | 1.1 |
| Stav | REVIEW |
| Datum aktualizace | 2026-07-27 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (`.md`) |
| Aktivní soubor | `docs/03_ARCHITECTURE/MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH.md` |
| Historické pracovní označení | MM-DOC-003 |

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---:|---|---|---|
| 0.9 | 2026-06 | Rozpracováno | Původní pracovní verze vedená pod historickým označením MM-DOC-003. |
| 1.0 | 2026-06-30 | REVIEW | Opravená REVIEW verze se stabilní identitou MM-DOC-300 a doplněným strategickým smyslem architektury. |
| 1.1 | 2026-07-27 | REVIEW | Aktualizace podle ověřené historie projektové komunikace, databázového auditu A33, skutečné architektury repozitáře, provider mappingu a belgického pilotu historické canonicalizace. Doplněna formální hierarchie a závěry hlavních kapitol podle výsledku A17 ze dne 2026-07-28. |

---

## Úvod a účel dokumentu
Tento dokument popisuje aktuální technickou architekturu platformy MatchMatrix.

Jeho úkolem je:

- vymezit jednotlivé vrstvy systému a jejich odpovědnosti,
- popsat životní cyklus sportovních dat od zdroje až po produktové využití,
- vysvětlit databázovou, aplikační, provozní a dokumentační architekturu,
- určit hranice mezi vstupními daty, canonical entitami a downstream vrstvami,
- zachytit principy providerového mapování a historické canonicalizace,
- vysvětlit rozdělení odpovědností mezi PC1 a PC2,
- vytvořit referenční základ pro další technický rozvoj platformy.

Tento dokument nepopisuje každý jednotlivý skript nebo tabulku. Detailní implementace patří do specializovaných dokumentů, databázových auditů, skriptové dokumentace a provozních zápisů.

---

## Související dokumenty

- `MM-DOC-000` – MatchMatrix Documentation Framework
- `MM-DOC-100` – MatchMatrix Master
- `MM-DOC-200` – MatchMatrix Governance
- `MM-DOC-800` – MatchMatrix Development Handbook
- `MM-DOC-900` – MatchMatrix Denní zápisy
- `MM-STD-003` – Standard životního cyklu dokumentace a verzování
- `MM-STD-007` – Identifikace a číslování dokumentů
- `MM-STD-009` – AI Context a Project Snapshot
- `MM-REF-001` – Slovník pojmů MatchMatrix

---

# Motto

> **Architektura není pouze způsob, jak systém postavit. Architektura je soubor pravidel, díky kterým bude možné systém bezpečně rozvíjet i za mnoho let.**

---

# Obsah

1. Smysl architektury
2. Architektonické principy
3. Vývoj architektury MatchMatrix
4. Celkový životní cyklus dat
5. Databázová architektura
6. Schéma `staging`
7. Schéma `public`
8. Schéma `ops`
9. Schéma `documentation`
10. Schéma `work`
11. Providerová architektura
12. Canonical entity a identity mapping
13. Architektura zápasů a `match_provider_map`
14. Historická canonicalizace
15. Downstream vrstvy
16. Harvest, parser a merge pipeline
17. Provozní architektura PC1 / PC2
18. Automatizace, audit a bezpečné změny
19. Dokumentační a AI kontextová architektura
20. Produktové a budoucí vrstvy
21. Aktuální stav architektury
22. Otevřené otázky a další krok

---

# 1. Smysl architektury

Architektura MatchMatrix nevznikla s cílem vytvořit pouze databázi sportovních výsledků.

Jejím účelem je vybudovat dlouhodobě udržitelnou technologickou platformu, která dokáže:

- kombinovat data z více zdrojů,
- uchovávat původ a historii každé významné informace,
- vytvářet jednotné canonical entity,
- rozlišovat ověřená data od pracovních a neověřených dat,
- rozšiřovat se o nové sporty, soutěže, providery a produkty,
- podporovat analytiku, predikce, média, kurzy a další služby,
- chránit databázi před nekontrolovaným slučováním a přepisem dat,
- zachovat znalosti projektu v řízené dokumentaci.

Architektura propojuje obchodní cíl společnosti s technickou realizací platformy. Databáze, skripty, dokumentace, panely, audity a infrastruktura jsou prostředky. Výsledným cílem jsou důvěryhodné produkty a služby založené na kvalitních sportovních datech.

---


## 1.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „1. Smysl architektury“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „2. Architektonické principy“, která rozvíjí další část řízeného dokumentu.

# 2. Architektonické principy

## 2.1 Jedna odpovědnost pro každou vrstvu

Každá vrstva řeší jednu jasně definovanou oblast:

- provider poskytuje zdrojová data,
- harvest zajišťuje jejich získání,
- vstupní a staging vrstva zachovává zdrojový obsah,
- parser a normalizace převádějí data do interního modelu,
- merge a mapping rozhodují o identitě,
- `public` uchovává canonical entity,
- downstream vrstvy vytvářejí funkce, ratingy, predikce a produktový obsah,
- `ops` sleduje kvalitu a provoz,
- `documentation` uchovává řízené znalosti,
- `work` slouží pro pracovní a pomocné procesy.

Žádná vrstva nesmí bez výslovně definovaného důvodu převzít odpovědnost jiné vrstvy.

## 2.2 Zdrojová data se nepovažují automaticky za pravdu

Data přijatá od provideru jsou důkazním vstupem, nikoli okamžitě canonical pravdou.

Mohou obsahovat:

- odlišné identifikátory,
- chybné názvy,
- neúplné vazby,
- duplicitní zápasy,
- rozdílné časy výkopu,
- změněné názvy soutěží,
- nástupnické nebo historické týmy,
- rozdílné skóre nebo stav zápasu.

Proto musí projít kontrolovaným životním cyklem.

## 2.3 Stabilní interní identity

Interní canonical identita nesmí být závislá na jednom providerovi.

Providerové ID je externí identita. Interní ID MatchMatrix je dlouhodobá identita platformy.

Změna provideru proto nesmí znamenat změnu identity:

- týmu,
- hráče,
- soutěže,
- sezony,
- zápasu,
- stadionu,
- média nebo jiné entity.

## 2.4 Dohledatelnost

Každé významné rozhodnutí musí být dohledatelné podle:

- zdroje,
- providerové identity,
- canonical identity,
- mapovacího záznamu,
- skriptu,
- auditu,
- databázové změny,
- Git historie,
- dokumentace.

## 2.5 Bezpečnost před rychlostí

Rizikové změny se neprovádějí přímo.

Standardní pořadí je:

1. READ ONLY audit,
2. přesná klasifikace kandidátů,
3. `VALIDATE_ONLY` v transakci s rollbackem,
4. kontrola dopadu,
5. `APPLY`,
6. post-commit READ ONLY audit,
7. aktualizace dokumentace a historie.

## 2.6 Modulární multisportovní architektura

Systém není navržen pouze pro fotbal.

Fotbal slouží jako referenční sport, protože obsahuje velký objem historických dat a složité identity. Stejné principy se ale používají pro hokej, basketbal, baseball, tenis, kriket, MMA, házenou, ragby, volejbal, šipky, esport a další sporty.

---


## 2.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „2. Architektonické principy“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „3. Vývoj architektury MatchMatrix“, která rozvíjí další část řízeného dokumentu.

# 3. Vývoj architektury MatchMatrix

První fáze projektu byla zaměřena především na získávání sportovních dat a vytváření základních tabulek.

S růstem databáze se ukázalo, že hlavním problémem není samotný harvest, ale:

- rozdílná struktura providerů,
- opakující se entity,
- chybějící providerové vazby,
- historické změny týmů a soutěží,
- nekonzistentní názvy,
- duplicity zápasů,
- rozdílné časové údaje,
- potřeba zpětného auditu,
- návaznost na downstream data.

Architektura se proto postupně rozšířila o:

- jednotné staging tabulky,
- canonical entity systém,
- provider mapping,
- Governance Layer,
- Source Intelligence,
- OPS audity,
- dokumentační databázi,
- řízené `VALIDATE_ONLY` a `APPLY` workflow,
- Project Snapshot a AI Context,
- specializované nástroje pro kontrolu a publikaci dokumentace.

Současná architektura není jednorázovým teoretickým návrhem. Je výsledkem praktických problémů, auditů a bezpečně ověřovaných změn.

---


## 3.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „3. Vývoj architektury MatchMatrix“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „4. Celkový životní cyklus dat“, která rozvíjí další část řízeného dokumentu.

# 4. Celkový životní cyklus dat

Referenční datový tok MatchMatrix je:

```text
ZDROJ / PROVIDER
        ↓
HARVEST / INGEST
        ↓
RAW NEBO PŮVODNÍ PAYLOAD
        ↓
STAGING / STG_*
        ↓
PARSER A NORMALIZACE
        ↓
IDENTITY RESOLUTION A PROVIDER MAPPING
        ↓
MERGE / CANONICALIZACE
        ↓
PUBLIC CANONICAL ENTITY
        ↓
DOWNSTREAM VRSTVY
        ↓
PRODUKTY A SLUŽBY
```

Downstream vrstvy zahrnují zejména:

- match features,
- ratingy,
- predikce,
- people data,
- média,
- kurzy,
- historické profily,
- Ticket Engine,
- API,
- webovou a mobilní prezentaci,
- analytické a AI služby.

Každý přechod mezi vrstvami musí mít definované vstupy, výstupy, kontrolní pravidla a auditní stopu.

---


## 4.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „4. Celkový životní cyklus dat“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „5. Databázová architektura“, která rozvíjí další část řízeného dokumentu.

# 5. Databázová architektura

Podle aktuálního ověřeného auditu A33 pracuje databáze MatchMatrix s pěti hlavními schématy:

| Schéma | Hlavní odpovědnost |
|---|---|
| `staging` | vstupní, zdrojová a normalizovaná pracovní data |
| `public` | canonical a produkčně využitelné entity |
| `ops` | provozní kontroly, audity, monitoring a řízení kvality |
| `documentation` | dokumenty, verze, sekce, vazby a importní historie |
| `work` | pracovní, pomocné a přechodné procesy |

Historicky se v některých dokumentech objevovalo označení `runtime`. Poslední ověřený databázový audit však jako samostatné aktivní schéma uvádí `work`, nikoli `runtime`. Provozní odpovědnosti mohou být implementovány ve více objektech a nástrojích, ale dokumentace musí rozlišovat logickou provozní vrstvu od skutečného názvu databázového schématu.

## 5.1 Rozsah databáze podle aktuálního A33 baseline

Aktuální ověřený baseline uvádí:

| Ukazatel | Hodnota |
|---|---:|
| Schémata | 5 |
| Objekty | 1 117 |
| Tabulky | 284 |
| Pohledy | 596 |
| Sloupce | 12 274 |
| Omezení | 615 |
| Indexy | 862 |
| Rutiny | 96 |
| Triggery | 24 |
| Závislosti | 753 |
| Celková velikost | 741,67 MB |

Tyto hodnoty představují snapshot, nikoli trvalou konstantu. Při každém novém A33 auditu musí být tato sekce aktualizována.

---


## 5.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „5. Databázová architektura“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „6. Schéma `staging`“, která rozvíjí další část řízeného dokumentu.

# 6. Schéma `staging`

## 6.1 Účel

Schéma `staging` představuje vstupní a pracovní oblast databáze.

Jeho úkolem je:

- zachovat data přijatá od providerů,
- umožnit opakované zpracování,
- oddělit zdrojový stav od canonical databáze,
- připravit data pro parser, normalizaci a merge,
- uchovat providerové identifikátory a původní hodnoty.

## 6.2 Jednotné tabulky `stg_*`

Původní přístup používal více providerově nebo sportovně specifických tabulek.

S růstem platformy bylo nutné přejít k jednotnějšímu modelu `stg_*`, který:

- snižuje počet specializovaných struktur,
- usnadňuje přidání nového provideru,
- sjednocuje kontroly,
- umožňuje společné parsery a audity,
- zjednodušuje další rozvoj.

To neznamená, že všechny sporty mají stejná data. Znamená to, že vstupní architektura používá společné principy a společná metadata.

## 6.3 Povinná metadata vstupních dat

Vstupní záznam by měl podle typu entity uchovávat zejména:

- provider,
- providerové ID,
- typ entity,
- sport,
- datum získání,
- původní payload nebo jeho dohledatelnou referenci,
- stav zpracování,
- případnou chybu,
- vazbu na canonical záznam, pokud již existuje.

---


## 6.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „6. Schéma `staging`“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „7. Schéma `public`“, která rozvíjí další část řízeného dokumentu.

# 7. Schéma `public`

## 7.1 Účel

Schéma `public` je canonical vrstva platformy.

Obsahuje entity, které mohou být využity ostatními částmi systému.

Typické oblasti:

- sporty,
- soutěže,
- sezony,
- týmy,
- hráči a další osoby,
- zápasy,
- stadiony,
- providerové mapy,
- funkce a ratingy,
- média,
- další produkční entity.

## 7.2 Canonical neznamená neměnné

Canonical záznam může být aktualizován, ale pouze řízeně.

Aktualizace musí respektovat:

- existující provider mapping,
- kvalitu nového zdroje,
- historii entity,
- konflikty,
- downstream vazby,
- auditní stopu.

## 7.3 Oddělení identity a atributů

Interní ID entity určuje její identitu.

Název, logo, datum založení, aktuální soutěž nebo jiné atributy se mohou měnit. Tyto změny nesmí automaticky vytvořit novou interní entitu.

Stejně tak shodný nebo podobný název nesmí automaticky znamenat stejnou entitu.

---


## 7.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „7. Schéma `public`“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „8. Schéma `ops`“, která rozvíjí další část řízeného dokumentu.

# 8. Schéma `ops`

Schéma `ops` podporuje provozní řízení a kvalitu.

Jeho odpovědnosti zahrnují:

- auditní výsledky,
- monitoring pipeline,
- identifikaci chyb a mezer,
- klasifikaci kandidátů,
- provozní stav providerů,
- přehledy kvality,
- kontroly duplicit,
- podklady pro dashboardy,
- informace potřebné pro bezpečné rozhodování.

OPS vrstva nemá nahrazovat canonical data. Má vysvětlovat jejich stav, kvalitu a rizika.

---


## 8.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „8. Schéma `ops`“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „9. Schéma `documentation`“, která rozvíjí další část řízeného dokumentu.

# 9. Schéma `documentation`

Dokumentace je samostatnou datovou oblastí platformy.

Schéma `documentation` uchovává zejména:

- dokumenty,
- verze dokumentů,
- aktuální verze,
- sekce,
- vztahy mezi dokumenty,
- historii stavů,
- importní běhy,
- podklady pro AI Context a Project Snapshot.

Aktuální ověřený stav dokumentační databáze:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 354 |
| Verze | 360 |
| Aktuální verze | 354 |
| Sekce | 7 075 |
| Vazby | 495 |
| Importní běhy | 48 |

Dokumentační databáze není náhradou aktivních souborů v repozitáři. Je jejich řízenou databázovou reprezentací a musí být synchronizována prostřednictvím dokumentačního workflow.

---


## 9.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „9. Schéma `documentation`“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „10. Schéma `work`“, která rozvíjí další část řízeného dokumentu.

# 10. Schéma `work`

Schéma `work` slouží pro pracovní a pomocné procesy.

Může obsahovat:

- dočasné pracovní tabulky,
- přípravné výpočty,
- mezivýsledky,
- kandidátní mapování,
- kontrolní podklady,
- data určená pro následnou validaci.

Data ve `work` nesmí být bez další kontroly považována za canonical.

Přechod z pracovní vrstvy do `public` musí být řízený, auditovatelný a v případě rizikových změn nejprve ověřený v režimu `VALIDATE_ONLY`.

---


## 10.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „10. Schéma `work`“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „11. Providerová architektura“, která rozvíjí další část řízeného dokumentu.

# 11. Providerová architektura

## 11.1 Vícezdrojový model

MatchMatrix nepoužívá jeden univerzální provider.

Různé zdroje mají různé role:

- aktuální soutěže,
- novější historie,
- hluboká historická data,
- lidé,
- média,
- kurzy,
- oficiální identity,
- doplňková metadata.

Například u fotbalu je cílem řízená kombinace zdrojů, nikoli závislost na jednom API.

## 11.2 Provider jako externí identita

Providerová identita musí být uchována odděleně od canonical identity.

Jedna canonical entita může mít:

- jednu providerovou identitu,
- více providerových identit,
- historickou identitu,
- novější identitu,
- identity od různých zdrojů.

## 11.3 Source Intelligence

Source Intelligence určuje:

- co provider poskytuje,
- pro které sporty a soutěže,
- v jakém období,
- v jaké kvalitě,
- za jakých licenčních podmínek,
- s jakými limity,
- pro jakou část pipeline je vhodný.

Provider nesmí být hodnocen pouze podle počtu dostupných endpointů. Rozhodující je jeho skutečná role v architektuře.

---


## 11.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „11. Providerová architektura“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „12. Canonical entity a identity mapping“, která rozvíjí další část řízeného dokumentu.

# 12. Canonical entity a identity mapping

## 12.1 Základní pravidlo

Mapování entity se nikdy nesmí provádět pouze podle podobnosti názvu.

Musí se kombinovat více důkazů, například:

- providerová identita,
- sport,
- soutěž,
- země,
- období,
- historie názvů,
- zápasové shody,
- datum založení,
- stadion,
- oficiální zdroj,
- návaznost na předchůdce nebo nástupce.

## 12.2 Historická entita není automaticky současná entita

Historický tým může:

- pokračovat pod novým názvem,
- být právním předchůdcem,
- zaniknout,
- být nahrazen jiným klubem,
- sdílet město nebo značku bez identity,
- existovat souběžně s jinou organizací.

Proto nelze historickou entitu automaticky sloučit s moderním klubem pouze podle názvu nebo lokality.

## 12.3 Otevřené historické případy

V belgickém pilotu zůstávají příklady, které vyžadují zvláštní zacházení:

- Lokeren,
- Mouscron.

Tyto případy nesmí být automaticky připojeny k potenciálním nástupcům bez dostatečných právních a sportovně-historických důkazů.

---


## 12.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „12. Canonical entity a identity mapping“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „13. Architektura zápasů a `match_provider_map`“, která rozvíjí další část řízeného dokumentu.

# 13. Architektura zápasů a `match_provider_map`

## 13.1 Účel mapy

Tabulka `public.match_provider_map` odděluje canonical zápas od providerových identit.

To umožňuje, aby jeden zápas měl:

- interní `match_id`,
- jednu nebo více providerových identit,
- identitu historického zdroje,
- identitu současného API,
- auditovatelnou vazbu mezi nimi.

## 13.2 Ověřený stav mapování

Při zavedení mapy bylo ověřeno:

| Ukazatel | Hodnota |
|---|---:|
| Kandidátní řádky | 121 908 |
| Cílové řádky | 121 908 |
| Odlišné mapované zápasy | 121 908 |
| Chybějící mapování | 0 |
| Duplicitní mapování | 0 |

Aktuální celkový stav:

| Oblast | Hodnota |
|---|---:|
| `public.matches` | 120 981 |
| `public.match_provider_map` | 121 908 |

Rozdíl není automaticky chybou. Providerová mapa může obsahovat více identit pro jeden canonical zápas.

## 13.3 Význam více identit

Pokud je bezpečně prokázáno, že historický a API záznam představují stejný zápas, canonical databáze má obsahovat jeden zápas a providerová mapa obě identity.

Tím se:

- zachová původ obou zdrojů,
- odstraní canonical duplicita,
- ochrání downstream vazby,
- umožní budoucí zpětný audit.

---


## 13.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „13. Architektura zápasů a `match_provider_map`“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „14. Historická canonicalizace“, která rozvíjí další část řízeného dokumentu.

# 14. Historická canonicalizace

## 14.1 Cíl

Historická canonicalizace neslouží pouze k mazání duplicit.

Jejím cílem je:

- sjednotit totožné zápasy,
- zachovat všechny providerové identity,
- přesunout downstream data na canonical záznam,
- chránit historické a moderní zdroje,
- oddělit bezpečné shody od konfliktních případů.

## 14.2 Belgický pilot

Belgická historie slouží jako referenční pilot pro bezpečnou canonicalizaci historických zápasů.

Ověřené výsledky zahrnují:

- 930 dříve sloučených překryvů,
- 1 053 unikátních historických zápasů canonicalizovaných do cílové soutěže `league_id = 20853`,
- po tomto APPLY zůstalo 231 legacy zápasů pod `league_id = 4`,
- dalších 110 zápasů prošlo úspěšným `VALIDATE_ONLY`,
- těchto 110 zápasů zatím nebylo v okamžiku snapshotu trvale aplikováno,
- po případném přesném APPLY těchto 110 se očekává 121 zbývajících legacy případů,
- z nich je 119 částečně mapovatelných a 2 vyžadují obě dosud nenamapované týmové identity.

## 14.3 Ověřené týmové identity

Příklady ověřených vazeb:

- RAAL historická identita `970` → canonical tým `12427` → API-Football identita `5902`,
- Waasland-Beveren historická identita `987` → canonical SK Beveren `13137` → API-Football identita `738`.

Tyto vazby byly ověřeny kombinací historických dat, providerových identit a zápasových shod.

## 14.4 Ochrana transakční hranice

Každý APPLY musí pracovat pouze s přesně definovaným počtem kandidátů.

Například APPLY pro 110 zápasů nesmí:

- znovu zpracovat již aplikovaných 1 053,
- zasáhnout zbývajících 121 případů,
- měnit otevřené týmové identity,
- vytvářet nové semantic duplicity,
- měnit celkový počet zápasů bez výslovně očekávaného důvodu.

## 14.5 Downstream ochrana

Při canonicalizaci se musí kontrolovat zejména:

- `match_features`,
- `mm_match_ratings`,
- cizí klíče,
- providerové payloady,
- identity,
- počet canonical zápasů,
- semantic duplicity,
- orphan záznamy.

Globální stav 78 794 orphan řádků v `mm_match_ratings` je samostatný problém. Nesmí být nesprávně přisuzován belgické migraci a musí se řešit odděleným auditem.

---


## 14.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „14. Historická canonicalizace“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „15. Downstream vrstvy“, která rozvíjí další část řízeného dokumentu.

# 15. Downstream vrstvy

Canonical data jsou vstupem pro další vrstvy.

## 15.1 Features

`match_features` obsahuje vlastnosti a odvozené charakteristiky zápasů.

Při změně canonical identity musí být funkce správně přesměrovány nebo zachovány.

## 15.2 Ratingy

`mm_match_ratings` a další ratingové struktury podporují analytiku a predikce.

Rating nesmí zůstat navázán na odstraněnou duplicitu.

## 15.3 People Layer

People Layer obsahuje:

- hráče,
- trenéry,
- rozhodčí,
- další osoby,
- jejich providerové identity,
- fotografie,
- týmové a soutěžní vazby.

## 15.4 Media Layer

Media Layer propojuje:

- články,
- fotografie,
- videa,
- týmy,
- hráče,
- soutěže,
- zápasy.

Mediální obsah nesmí být považován za izolované soubory. Je součástí znalostního kontextu sportovní entity.

## 15.5 Odds Layer

Odds Layer uchovává kurzy a jejich historický nebo aktuální kontext.

Zdroj aktuálních kurzů nemusí poskytovat historii. Architektura proto musí oddělit:

- aktuální kurz,
- historický kurz,
- zdroj,
- čas získání,
- trh,
- bookmaker identity.

## 15.6 Ticket Engine a produktové vrstvy

Ticket Engine využívá canonical a analytická data pro vytváření doporučení a tiketových scénářů.

Produktová vrstva nesmí obcházet canonical databázi ani vytvářet vlastní paralelní identity.

---


## 15.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „15. Downstream vrstvy“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „16. Harvest, parser a merge pipeline“, která rozvíjí další část řízeného dokumentu.

# 16. Harvest, parser a merge pipeline

## 16.1 Harvest

Harvest odpovídá za:

- plánování požadavků,
- volání providerů,
- retry,
- limity,
- logování,
- ukládání odpovědi,
- označení úspěchu nebo chyby.

Harvest nemá rozhodovat o canonical identitě.

## 16.2 Parser

Parser převádí providerový formát do interního modelu.

Odpovídá za:

- typy hodnot,
- normalizaci data a času,
- strukturu položek,
- přípravu providerových identit,
- standardizaci vstupu pro merge.

Parser nesmí nekontrolovaně slučovat entity.

## 16.3 Merge

Merge rozhoduje, zda záznam:

- aktualizuje existující canonical entitu,
- vytvoří novou entitu,
- vyžaduje mapping,
- vstupuje do konfliktu,
- musí být zařazen do HOLD nebo REVIEW.

## 16.4 Provider map

Provider map je dlouhodobá paměť identity.

Pokud je identity mapping ověřen, další běhy pipeline jej musí respektovat.

---


## 16.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „16. Harvest, parser a merge pipeline“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „17. Provozní architektura PC1 / PC2“, která rozvíjí další část řízeného dokumentu.

# 17. Provozní architektura PC1 / PC2

## 17.1 PC1

PC1 je hlavní ovládací a vývojové pracoviště.

Je určeno zejména pro:

- vývoj,
- návrh SQL,
- řízení dokumentace,
- práci s panelem,
- správu Git repozitáře,
- kontrolu výsledků,
- spouštění ovládacích kroků.

## 17.2 PC2

PC2 je hlavní databázový a harvest uzel.

Je určeno zejména pro:

- PostgreSQL,
- dlouhodobý harvest,
- ingest cykly,
- náročné zpracování,
- workery,
- provozní automatizaci.

## 17.3 Hostitelsky nezávislý panel

Q3 panel má fungovat na PC1 i PC2.

Panel:

- nesmí být závislý na jedné pevné hostitelské cestě,
- musí rozpoznat projektový root,
- při práci z PC1 používá bezpečný přístup k souborům na PC2,
- databázové kroky na PC2 spouští proti lokální databázi PC2,
- používá české uživatelské popisky,
- zachovává technické identifikátory v původním tvaru.

## 17.4 Síťová hranice

Architektura musí rozlišovat:

- lokální cestu,
- UNC cestu,
- databázové připojení,
- vzdálené spuštění,
- hostitelský počítač,
- cílový počítač.

Pevně zapsané cesty do jednoho počítače jsou nepřípustné pro nové přenositelné nástroje.

---


## 17.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „17. Provozní architektura PC1 / PC2“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „18. Automatizace, audit a bezpečné změny“, která rozvíjí další část řízeného dokumentu.

# 18. Automatizace, audit a bezpečné změny

## 18.1 Skript jako opakovatelný důkaz

Významná databázová změna musí existovat jako skript.

Skript musí obsahovat:

- účel,
- rozsah,
- očekávaný počet,
- bezpečnostní guard,
- režim,
- výstupy,
- kontrolu výsledku.

## 18.2 Režimy

Doporučené režimy:

- `READ_ONLY`,
- `VALIDATE_ONLY`,
- `APPLY`.

`VALIDATE_ONLY` musí provést skutečnou logiku uvnitř transakce a následně rollback. Není to pouze SELECT bez ověření změny.

## 18.3 Lock a cizí klíče

Při rizikové canonicalizaci se podle potřeby používají:

- zámky cílových tabulek,
- kontrola cizích klíčů,
- kontrola počtů před a po,
- kontrola semantic duplicit,
- kontrola downstream tabulek.

## 18.4 A33

A33 je read-only audit struktury databáze.

Jeho role:

- zdokumentovat skutečná schémata,
- objekty,
- sloupce,
- omezení,
- indexy,
- rutiny,
- triggery,
- závislosti,
- velikosti,
- varování.

A33 nemění databázi.

---


## 18.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „18. Automatizace, audit a bezpečné změny“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „19. Dokumentační a AI kontextová architektura“, která rozvíjí další část řízeného dokumentu.

# 19. Dokumentační a AI kontextová architektura

## 19.1 Dokumentace jako systémová vrstva

Dokumentace není vedlejší textový výstup.

Je to systém řízení znalostí propojený s:

- repozitářem,
- databází,
- Git historií,
- skripty,
- audity,
- denními zápisy,
- AI Context,
- Project Snapshot.

## 19.2 Q3 workflow

Dokumentační workflow používá čtyři fáze:

1. vybrat a analyzovat,
2. opravit a zkontrolovat,
3. vytvořit a schválit,
4. publikovat.

Hlavní nástroje:

- A17 – audit standardu,
- A18 – standardizační návrh,
- A19 – kontrola mapování,
- A20 – builder,
- A24 – import do dokumentační databáze.

## 19.3 Jediný aktivní soubor

Pro každý dokument existuje jeden aktivní soubor se stabilním názvem.

Nová verze:

- nepřidává verzi do aktivního názvu,
- mění číslo verze uvnitř dokumentu,
- doplňuje historii verzí,
- archivuje předchozí milestone nebo REVIEW kopii,
- zachovává stabilní Document ID.

## 19.4 Historie chatů

Historie chatů je důkazním zdrojem a pracovní pamětí.

Informace z chatů se do aktivní dokumentace přenášejí pouze po ověření proti:

- repozitáři,
- databázi,
- auditům,
- aktuálním dokumentům,
- pozdějším rozhodnutím.

Novější ověřený Project Snapshot má přednost před starším denním zápisem nebo starším dokumentem NAVÁZÁNÍ.

## 19.5 Povinné kontextové sekce

Podle `MM-STD-009` má dokument podporovat:

- AI CONTEXT,
- PROJECT SNAPSHOT,
- DATABASE SNAPSHOT,
- CURRENT STATUS,
- OPEN QUESTIONS,
- NEXT STEP.

Tyto sekce musí být stručné, ověřitelné a nesmí nahrazovat vlastní obsah dokumentu.

---


## 19.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „19. Dokumentační a AI kontextová architektura“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „20. Produktové a budoucí vrstvy“, která rozvíjí další část řízeného dokumentu.

# 20. Produktové a budoucí vrstvy

Budoucí rozvoj architektury zahrnuje:

- webovou platformu,
- veřejné a partnerské API,
- mobilní aplikaci,
- analytické služby,
- AI asistenty,
- predikční služby,
- Ticket Engine,
- pokročilé mediální propojení,
- historické profily týmů, hráčů a soutěží,
- automatizovaný Documentation Management System,
- škálovatelný harvest a další výpočetní uzly.

Cloud není samostatným cílem.

Přechod do cloudu má smysl pouze tehdy, když:

- zvyšuje spolehlivost,
- umožňuje škálování,
- zlepšuje dostupnost,
- snižuje provozní riziko,
- odpovídá obchodnímu modelu.

Architektura musí zůstat přenositelná a nesmí být zbytečně uzamčena na jednoho poskytovatele infrastruktury.

---


## 20.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „20. Produktové a budoucí vrstvy“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „21. Aktuální stav architektury“, která rozvíjí další část řízeného dokumentu.

# 21. Aktuální stav architektury

## 21.1 Stav hlavních oblastí

| Oblast | Stav |
|---|---|
| PostgreSQL databáze | ACTIVE |
| Staging a ingest | ACTIVE DEVELOPMENT |
| Canonical public vrstva | ACTIVE |
| Provider mapping | ACTIVE |
| `match_provider_map` | IMPLEMENTED |
| Governance | ACTIVE |
| OPS a audity | ACTIVE DEVELOPMENT |
| Dokumentační databáze | ACTIVE |
| Q3 dokumentační workflow | IMPLEMENTED / rozvíjeno |
| People Layer | PARTIAL |
| Media Layer | PARTIAL |
| Odds Layer | PARTIAL |
| Ratingy a predikce | PARTIAL |
| Ticket Engine | DESIGN / DEVELOPMENT |
| Web a API produkty | DESIGN / DEVELOPMENT |

## 21.2 Aktuální technické priority

1. Dokončit bezpečný APPLY přesně 110 belgických zápasů, pokud bude navázáno na již úspěšný `VALIDATE_ONLY`.
2. Provést samostatný post-commit READ ONLY audit.
3. Zachovat 121 zbývajících legacy případů mimo tento APPLY.
4. Vyřešit otevřené historické identity Lokeren a Mouscron.
5. Samostatně analyzovat globální rating orphan problém.
6. Aktualizovat dokumentaci a dokumentační databázi.
7. Pokračovat systematicky sport po sportu a vrstvu po vrstvě.

---


## 21.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „21. Aktuální stav architektury“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost pokračuje kapitolou „22. Otevřené otázky a další krok“, která rozvíjí další část řízeného dokumentu.

# 22. Otevřené otázky a další krok

## 22.1 Otevřené otázky

- přesný dlouhodobý model historických týmových nástupnictví,
- pravidla pro právní a sportovní kontinuitu klubů,
- úplné odstranění starých providerově specifických struktur,
- standardizace všech sportů na jednotné pipeline,
- cílová architektura ratingů a odstranění orphan záznamů,
- budoucí škálování harvestu,
- přesné produktové rozhraní API a Ticket Engine,
- automatická synchronizace Project Snapshotu,
- propojení dokumentace, Git historie a databázových objektů.

## 22.2 Nejbližší další krok

Nejbližším architektonickým krokem je bezpečně dokončit a zdokumentovat přesně vymezenou belgickou migraci 110 zápasů:

```text
VALIDATE_ONLY již ověřeno
→ APPLY přesně 110
→ post-commit READ ONLY audit
→ aktualizace Project Snapshot
→ dokumentační import
```

---


## 22.99 Závěr kapitoly

Shrnutí kapitoly: Kapitola vymezila oblast „22. Otevřené otázky a další krok“ v rámci dokumentu MM-DOC-300 a stanovila její význam, pravidla nebo ověřený stav. Přínos kapitoly spočívá v tom, že daná oblast je popsána jednoznačně a může sloužit jako řízený podklad pro další práci. Návaznost směřuje k závěru dokumentu a k navazujícím kontextovým, auditním a publikačním krokům.

# Závěr dokumentu

Dokument MM-DOC-300 uzavírá řízený popis oblasti architektury MatchMatrix. Shrnuje pravidla, ověřený stav, odpovědnosti a vazby, které jsou potřebné pro další bezpečnou práci v projektu MatchMatrix. Přínos dokumentu spočívá v jednotném a dohledatelném zachycení této oblasti pro vývoj, audit, rozhodování a dlouhodobou správu. Návaznost pokračuje kontextovými sekcemi AI CONTEXT, PROJECT SNAPSHOT, CURRENT STATUS, OPEN QUESTIONS a NEXT STEP.

# AI CONTEXT

**Role dokumentu:** Referenční technický popis architektury MatchMatrix.

**Hlavní princip:** Providerová data procházejí řízeným životním cyklem od vstupu přes staging, normalizaci, mapping a canonicalizaci do `public` a downstream vrstev.

**Stabilní identita:** Document ID je `MM-DOC-300`. Historické pracovní označení `MM-DOC-003` se již nepoužívá jako aktivní identita.

**Databázová schémata:** `staging`, `public`, `ops`, `documentation`, `work`.

**Bezpečné změny:** READ ONLY → VALIDATE_ONLY → APPLY → post-commit audit.

**Důležitá hranice:** 1 053 belgických zápasů již bylo aplikováno; dalších 110 bylo pouze validováno a nesmí se zaměnit s dokončeným APPLY.

---

# PROJECT SNAPSHOT

- MatchMatrix je multisportovní sportovní datová a znalostní platforma.
- PC1 slouží primárně pro vývoj a řízení.
- PC2 slouží primárně pro databázi a harvest.
- Q3 panel má být hostitelsky nezávislý.
- Aktivní dokumentace používá stabilní názvy souborů bez verze v názvu.
- Historie chatů byla převedena do extrakční matice a slouží jako ověřovaný důkazní zdroj.
- Fotbal je referenční sport; házená je pilotní sport pro další rozvoj.
- Historické pokrytí se plánuje od vzniku soutěže nebo od nejstaršího legálně, technicky a spolehlivě dostupného období.

---

# DATABASE SNAPSHOT

| Ukazatel | Hodnota |
|---|---:|
| Schémata | 5 |
| Objekty | 1 117 |
| Tabulky | 284 |
| Pohledy | 596 |
| Sloupce | 12 274 |
| Omezení | 615 |
| Indexy | 862 |
| Rutiny | 96 |
| Triggery | 24 |
| Závislosti | 753 |
| Velikost | 741,67 MB |
| `public.matches` | 120 981 |
| `public.match_provider_map` | 121 908 |
| Dokumenty v dokumentační DB | 354 |
| Verze dokumentů | 360 |
| Sekce | 7 075 |
| Vazby | 495 |
| Importní běhy | 48 |

---

# CURRENT STATUS

- Architecture: ACTIVE DEVELOPMENT
- Database Core: ACTIVE
- Provider Mapping: ACTIVE
- Belgium Historical Canonicalization: PARTIALLY COMPLETE
- Documentation Architecture: ACTIVE
- AI Context and Project Snapshot: ACTIVE / MANUAL WITH FUTURE AUTOMATION
- Web/API Product Layer: DESIGN / DEVELOPMENT
- Cloud Architecture: FUTURE

---

# OPEN QUESTIONS

- Jak přesně modelovat historické nástupnictví klubů?
- Jak odstranit 78 794 orphan rating záznamů bez narušení správných ratingů?
- Kdy a jak dokončit APPLY 110 validovaných belgických zápasů?
- Jak sjednotit všechny sportovní pipeline bez ztráty sportovně specifických dat?
- Jak automatizovat synchronizaci dokumentace, databáze a Git historie?

---

# NEXT STEP

Provést pouze přesně ohraničený APPLY 110 již validovaných belgických historických zápasů, následně samostatný post-commit READ ONLY audit a aktualizaci dokumentace.
