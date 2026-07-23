# MatchMatrix – denní zápis – 2026-07-22

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-DL-20260722 |
| Název dokumentu | MatchMatrix – denní zápis – 2026-07-22 |
| Typ dokumentu | DAILY_LOG |
| Verze | 1.1 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-22 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | Provider Registry, Provider Matrix a úplná providerová připravenost fotbalu |
| Primární formát | Markdown (`.md`) |
| Kanonické umístění | `docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260722_MATCHMATRIX_DENNI_ZAPIS.md` |
| Navazující dokument | `MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Předchozí denní zápis | `MM-DL-20260721_MATCHMATRIX_DENNI_ZAPIS.md` |
| Šablona | `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md` |

---

# 1. Identifikace denního zápisu

| Položka | Hodnota |
|---|---|
| Document ID | MM-DL-20260722 |
| Datum pracovního dne | 2026-07-22 |
| Datum a čas uzavření | 2026-07-22T23:48:34+02:00 |
| Autor | Petr |
| Aktivní projekt | MatchMatrix-platform |
| Aktivní oblast | Providerový ekosystém, databázový audit a příprava fotbalu |
| Výchozí dokumentační stav | `MM-PRV-001` až `MM-PRV-008` dokončeny a publikovány |
| Konečný stav dne | Proveden rozsáhlý read-only audit providerových objektů a podrobný audit fotbalu; databáze nebyla změněna |
| Bezprostřední dokumentační cíl | Zapsat ověřený stav a připravit podklady pro `MM-PRV-009` |
| Bezprostřední technický cíl | Definovat úplnou fotbalovou matici potřebných dat a vhodných providerů před placeným harvestem |

---

# 2. Výchozí stav

Na začátku pracovního dne byla dokončena providerová dokumentace:

```text
MM-PRV-001  Providerový ekosystém MatchMatrix
MM-PRV-002  Životní cyklus a schvalování providerů
MM-PRV-003  Provider routing a fallback
MM-PRV-004  Provider Health Monitoring
MM-PRV-005  Integrace providerů do datových vrstev
MM-PRV-006  Právní a licenční řízení providerů
MM-PRV-007  Referenční katalog providerů, tarifů a pokrytí
MM-PRV-008  Datový model Provider Registry a Provider Matrix
```

`MM-PRV-008` zůstává návrhovým dokumentem:

```text
TARGET DESIGN – NOT YET IMPLEMENTED
```

Před zahájením databázové implementace bylo nutné zjistit skutečný stav existujících tabulek, providerových map, plannerů, workerů, coverage, sportů a datových vrstev.

Poslední potvrzený stav dokumentační databáze před dnešními novými návrhy:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 344 |
| Verze celkem | 350 |
| Aktuální verze | 344 |
| Sekce | 6 542 |
| Vazby | 393 |
| Historie stavů | 350 |
| Aktivní dokumenty | 344 |
| Varování | 0 |
| Blokátory | 0 |

Poslední potvrzený vzdálený Git commit:

```text
e81a4f5
```

Aktuální Git stav nebyl při uzavření tohoto zápisu znovu ověřen.

---

# 3. Cíle pracovního dne

Cílem bylo:

1. ověřit skutečnou strukturu providerových registrů a map v databázi,
2. zjistit rozdíl mezi návrhem `MM-PRV-008` a reálným stavem,
3. ověřit identitu providerů a nekanonické providerové kódy,
4. zjistit roli existujících mapovacích tabulek,
5. posoudit házenou jako první dílčí providerový pilot,
6. vytvořit centrální snapshot všech sportů,
7. potvrdit nejpokročilejší sport projektu,
8. provést podrobný audit fotbalu,
9. rozlišit aktuální, historická, people, statistická, odds a media data,
10. stanovit princip výběru vhodných providerů před nákupem placených tarifů,
11. zachovat plně read-only režim bez změny produkční databáze,
12. připravit podklady pro implementační dokument `MM-PRV-009`.

---

# 4. Provedené práce

## 4.1 Ověření databázového prostředí

Byl použit read-only nástroj:

```text
tools/documentation/25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py
```

Ověřený stav:

| Položka | Hodnota |
|---|---|
| Databáze | `matchmatrix` |
| Host | `localhost` na PC2 |
| PostgreSQL server | 16.14 |
| Schémata | `staging`, `public`, `ops`, `documentation`, `work` |
| Transakční režim | READ ONLY |
| Izolace | REPEATABLE READ |
| Ukončení | ROLLBACK |
| Databáze změněna | NE |

Poznámka: dříve uváděná verze 18.4 pravděpodobně označovala klientský nástroj, zatímco server auditem potvrdil PostgreSQL 16.14.

Celkový strukturální audit zjistil:

| Ukazatel | Počet |
|---|---:|
| Schémata | 5 |
| Objekty | 1 115 |
| Tabulky | 283 |
| Pohledy | 596 |
| Sloupce | 12 257 |
| Constraints | 603 |
| Indexy | 856 |
| Rutiny | 95 |
| Triggery | 23 |
| Závislosti | 747 |
| Celková velikost | 659,66 MB |
| Auditní upozornění | 226 |

Upozornění byla rozdělena na:

```text
HIGH: 60
MEDIUM: 57
INFO: 109
```

Jde o auditní pozorování, nikoli automaticky o potvrzené chyby.

---

## 4.2 Audit providerových registrů

Bylo identifikováno 228 objektů souvisejících s providery a zdroji:

| Schéma | Počet |
|---|---:|
| `ops` | 187 |
| `public` | 16 |
| `staging` | 25 |

Klíčové existující tabulky:

```text
public.data_providers
ops.global_source_registry
ops.source_registry
ops.provider_accounts
ops.provider_audit_registry
ops.provider_sport_matrix
ops.provider_entity_coverage
```

Ověřené role:

| Objekt | Průběžně potvrzená role |
|---|---|
| `public.data_providers` | minimální číselník identity providerů |
| `ops.provider_entity_coverage` | provozní stav provider × sport × entita |
| `ops.provider_sport_matrix` | hrubý souhrn deklarovaných schopností |
| `ops.provider_accounts` | účty, tarify a limity bez tajných údajů |
| `ops.provider_audit_registry` | technický, právní a implementační audit |
| `ops.global_source_registry` | discovery a evidence externích zdrojů |
| `ops.source_registry` | starší nebo alternativní zdrojový registr, aktuálně bez potvrzeného naplnění |

Žádná existující tabulka sama nepokrývá celý cílový Provider Registry z `MM-PRV-008`.

Přijatý závěr:

```text
Nevytvářet nyní automaticky novou ops.provider_registry.
Nejdříve sjednotit role existujících objektů a připravit schválený migrační plán.
```

---

## 4.3 Audit providerových kódů

Audit porovnal providerové hodnoty v databázi s `public.data_providers`.

Výsledek:

| Stav | Počet výskytů |
|---|---:|
| `MATCH` | 317 |
| `MISSING_IN_DATA_PROVIDERS` | 96 |
| `CANONICAL_UNUSED` | 4 |
| Chyby skenu | 0 |

Bylo zjištěno 43 rozdílných normalizovaných hodnot, které nejsou v kanonickém číselníku.

Významné případy:

- `sportsdataio` – skutečný provider s velkým počtem odkazů,
- `theodds` – pravděpodobný alias kanonického `the_odds`,
- `football_data_uk` – samostatný historický CSV zdroj,
- `api_basketball` – vyžaduje rozhodnutí o vztahu k `api_sport`,
- `api-sports` – zastřešující a nejednoznačné označení,
- `official_site`, `nba`, `nhl`, `uefa`, `fifa` – spíše zdroje nebo organizace než stejné typy technických providerů,
- `auto_enrichment`, `derived_from_matches` a další – procesní štítky, nikoli provideři.

Přijatý závěr:

```text
Provider, zdroj, organizace, publisher, interní proces a adapter musí být vedeny jako rozdílné typy identity.
```

---

## 4.4 Audit mapovacích tabulek

Byly ověřeny:

```text
public.league_provider_map
public.team_provider_map
public.player_provider_map
public.coach_provider_map
public.canonical_provider_map
ops.league_provider_map
public.data_providers
```

Specializované mapy jsou aktivními technickými základy databáze a nemají být odstraněny.

`public.canonical_provider_map` byl vyhodnocen jako raný prototyp, nikoli jako aktivní master:

- obsahuje pouze `api_football`,
- má 364 řádků,
- bylo zjištěno 107 přesně duplicitních klíčových skupin,
- z toho 100 týmových a 7 ligových,
- nemá přesný překryv se specializovanými mapami,
- není používán databázovými pohledy,
- v repozitáři se objevuje hlavně v seed SQL a schema dumpu.

Průběžná klasifikace:

```text
PROTOTYPE – REVIEW BEFORE REUSE
```

Specializované mapy zůstávají aktivním základem.

Důležitá nekonzistence:

- pouze `public.league_provider_map` vynucuje provider FK na `public.data_providers`,
- týmové, hráčské a trenérské mapy providerový FK nemají.

FK se nyní nesmí přidávat bez předchozí normalizace providerových hodnot a schválené migrace.

---

## 4.5 Házená jako providerový pilot

Bylo potvrzeno, že házená není nejpokročilejší sport projektu.

Házená představuje:

```text
první dílčí providerový a runtime pilot
```

Ověřené jádro:

- leagues,
- teams,
- fixtures,
- API Handball,
- public league maps: 211,
- team maps: 1 005,
- historické planner běhy pro teams a fixtures.

Současně:

- players jsou `blocked`,
- coaches jsou `planned`,
- odds jsou `planned`,
- highlights jsou návrhové,
- řada workerových vazeb je pouze logická nebo placeholder,
- `provider_sport_matrix` nadhodnocuje reálnou připravenost.

Přesná live cesta byla potvrzena pro:

```text
ingest/API-Házená/pull_api_handball_teams.ps1
ingest/API-Házená/pull_api_handball_fixtures.ps1
```

V repozitáři existují také historické odkazy na `API-Handball`, které musí být později sjednoceny nebo vysvětleny.

Přijatý závěr:

```text
Házená je pilot základního CORE ingestu, nikoli referenční model kompletního sportu.
```

---

## 4.6 Centrální snapshot všech sportů

Read-only snapshot všech sportů potvrdil:

| Objekt | Počet řádků |
|---|---:|
| Sporty | 14 |
| Kanoničtí provideři | 22 |
| Sportovní matice | 16 |
| Detailní coverage | 107 |
| Ingest plány | 106 |
| Registry workerů | 50 |
| Providerové účty | 10 |

Stavy detailní coverage:

| Stav | Počet |
|---|---:|
| `runtime_tested` | 32 |
| `tech_ready` | 10 |
| `planned` | 57 |
| `blocked` | 8 |

Zásadní zjištění:

```text
enabled = true
neznamená
runtime ready
```

Souhrnná matice často popisuje deklarovanou schopnost providera, zatímco detailní coverage popisuje reálný stav implementace. Oba významy musí být v cílové databázi oddělené.

---

## 4.7 Fotbal potvrzen jako referenční sport

Uživatel upřesnil, že nejdále rozpracovaným sportem je fotbal.

Fotbal byl proto stanoven jako:

```text
nejvyspělejší referenční sport platformy
```

Fotbal má rozpracované:

- CORE,
- PEOPLE,
- sezónní statistiky,
- providerové mapování,
- odds,
- media discovery,
- více zdrojů,
- plánovače,
- workery,
- governance a auditní objekty.

Fotbal nebude slepě kopírován. Nejprve se použije k identifikaci nejlepšího existujícího řešení i historických nedostatků.

---

## 4.8 Podrobný audit fotbalu

Základní počty:

| Datová oblast | Počet |
|---|---:|
| Soutěže | 2 030 |
| Týmy | 6 854 |
| Zápasy | 105 506 |
| Hráči | 5 340 |
| Trenéři | 3 |
| Veřejné sezónní statistiky hráčů | 3 121 |
| Staging zápasů | 76 608 |
| Staging hráčů | 5 279 |
| Staging sezonních statistik | 110 319 |
| Fotbalové položky ingest planneru | 5 377 |

Fotbalová coverage obsahuje 21 záznamů:

| Stav | Počet |
|---|---:|
| `runtime_tested` | 7 |
| `tech_ready` | 3 |
| `planned` | 10 |
| `blocked` | 1 |

Používaní nebo plánovaní provideři a zdroje:

```text
api_football
football_data
theodds
official_site
sportdataapi
sportradar
pinnacle
betfair
wikimedia
```

`ops.provider_audit_registry` pro fotbal nemá žádný záznam.

`ops.global_source_registry` obsahuje FIFA a UEFA, ale obě ve stavu:

```text
verification_status = NOT_VERIFIED
commercial_status = UNKNOWN
```

---

## 4.9 Úplnost fotbalového CORE

### Soutěže

| Ukazatel | Hodnota |
|---|---:|
| Soutěže celkem | 2 030 |
| Namapované na providera | 1 238 |
| Nenamapované | 792 |
| Pokrytí mapováním | 60,99 % |
| Název vyplněn | 100 % |
| Země vyplněna | 100 % |
| Logo vyplněno | 100 % |

Nenamapovaných 792 soutěží odpovídá zdroji `api_sport` v `ext_source`, ale chybí jim odpovídající řádky ve specializované league mapě. Musí být určeno, zda jde o historický import, alias, nedokončený merge nebo nekanonické sportovní zdroje.

### Týmy

| Ukazatel | Hodnota |
|---|---:|
| Týmy celkem | 6 854 |
| Namapované | 6 765 |
| Nenamapované | 89 |
| Pokrytí | 98,70 % |
| Chybějící loga | 1 920 |
| Chybějící loga v % | 28,01 % |

Týmové mapy používají:

```text
api_football
api_sport
football_data
football_data_uk
```

### Zápasy

| Stav | Počet |
|---|---:|
| `FINISHED` | 104 721 |
| `SCHEDULED` | 405 |
| `CANCELLED` | 336 |
| `POSTPONED` | 40 |
| `LIVE` | 4 |

Chybějící skóre je u 785 zápasů. Toto číslo přesně odpovídá všem nedokončeným stavům a nebylo vyhodnoceno jako obecná datová chyba.

---

## 4.10 Úplnost fotbalového PEOPLE

### Hráči

| Oblast | Chybí | Podíl |
|---|---:|---:|
| Providerová mapa | 1 | 0,02 % |
| Fotografie | 3 846 | 72,02 % |
| Aktuální tým | 1 453 | 27,21 % |
| Pozice | 525 | 9,83 % |
| First name / last name | 938 | 17,57 % |
| Datum narození | 194 | 3,63 % |
| Národnost | 62 | 1,16 % |

Existuje 5 340 mapovacích řádků `api_football`, ale pouze 5 339 rozdílných kanonických hráčů. Je nutné ověřit jeden nenamapovaný záznam a jednu vícenásobnou nebo duplicitní vazbu.

### Trenéři

```text
public.coaches: 3
staging.stg_provider_coaches: 19
```

Staging obsahuje historie působení stejného trenéra u více týmů. Veřejná vrstva zatím obsahuje pouze tři kanonické osoby.

Chybí zejména:

- úplný merge trenérů,
- týmová a historická vazba,
- fotografie,
- u části osob biografické údaje.

---

## 4.11 Statistiky hráčů

Byl potvrzen významný rozdíl:

```text
staging.stg_provider_player_season_stats: 110 319
public.player_season_statistics:           3 121
```

Veřejná vrstva obsahuje statistiky pro 2 689 z 5 340 hráčů.

Staging používá dlouhý formát:

```text
stat_name
stat_value
```

Veřejná vrstva používá široký formát:

```text
goals
assists
minutes_played
rating
shots_total
passes_total
...
```

Před hromadným harvestem musí být ověřena transformace:

```text
RAW
→ dlouhý staging
→ validace a mapování
→ seskupení hráč × tým × soutěž × sezona
→ široká public tabulka
```

`staging.stg_provider_player_stats` je aktuálně prázdná, přestože coverage uvádí match player stats jako `runtime_tested`. Musí být ověřeno, zda se data ukládají jinam, byla odstraněna, nebyla harvestována nebo je stav coverage zastaralý.

---

## 4.12 Struktura providerových identit

Staging tabulky obsahují vhodné externí identifikátory:

```text
external_league_id
external_team_id
external_fixture_id
external_player_id
external_coach_id
```

Kanonické tabulky však často stále obsahují pouze:

```text
ext_source
ext_*_id
```

To umožňuje pouze jednu hlavní externí identitu přímo v řádku.

Pro skutečný multi-provider model musí být možné mapovat jednu kanonickou entitu na více providerů.

U soutěží, týmů, hráčů a trenérů specializované mapy existují. U zápasů zatím nebyla potvrzena plnohodnotná `match_provider_map`.

Další historická provázanost:

`public.leagues` stále obsahuje providerově specifická pole:

```text
ext_source
ext_league_id
ext_csv_code
theodds_key
enabled_theodds
```

Dlouhodobě musí být rozhodnuto, která pole zůstanou kvůli kompatibilitě a která se přesunou do map nebo routing vrstvy.

---

## 4.13 Časové pokrytí fotbalových providerů

### API-Football free

Ověřené zápasy v public vrstvě:

| Sezona | Zápasy |
|---|---:|
| 2022 | 20 530 |
| 2023 | 26 851 |
| 2024 | 30 054 |

Free tarif je v projektu používán pro novější historii 2022–2024 a detailnější CORE a PEOPLE data.

### Football-Data

Ověřená role:

```text
aktuální sezony vybraných prestižních soutěží
```

Není to hlavní historický zdroj.

Ověřená data:

| Sezona | Zápasy |
|---|---:|
| 2024 | 51 |
| 2025 | 3 110 |
| 2026 | 578 |

V `public.league_provider_map` je nyní explicitně 13 soutěží:

- Campeonato Brasileiro Série A,
- Championship,
- Premier League,
- European Championship,
- UEFA Champions League,
- Ligue 1,
- Bundesliga,
- Serie A,
- Eredivisie,
- Primeira Liga,
- Copa Libertadores,
- Primera Division,
- FIFA World Cup.

Uživatel potvrdil záměr 14 prestižních soutěží. Čtrnáctá soutěž musí být dohledána v konfiguraci, původním importu nebo doplněna do mapování.

### Football-Data UK

Ověřený historický rozsah v databázi:

| Sezona | Zápasy |
|---|---:|
| 2018/19 | 3 230 |
| 2019/20 | 3 047 |
| 2020/21 | 3 296 |
| 2021/22 | 3 296 |
| 2022/23 | 3 296 |
| 2023/24 | 3 228 |
| 2024/25 | 3 228 |
| 2025/26 | 497 |

`football_data_uk` je nutné evidovat jako samostatný historický CSV zdroj, nikoli automaticky slučovat s `football_data`.

### The Odds

Třináct soutěží má uložen `theodds_key`, ale:

```text
enabled_theodds = true
```

je aktuálně pouze u Premier League.

The Odds se používá pro současné kurzy. Potřebná hlubší historická odds coverage v aktuální implementaci a tarifu chybí.

### Sezónní statistiky hráčů

Ověřená staging coverage:

| Sezona | Stat řádky | Hráči | Soutěže | Týmy |
|---|---:|---:|---:|---:|
| 2022 | 51 987 | 1 560 | 27 | 430 |
| 2024 (`football`) | 57 288 | 1 233 | 39 | 340 |
| 2024 (`FB`) | 1 044 | 20 | 57 | 48 |

Sezona 2023 v této staging tabulce chybí. Současně jsou používány dva kódy sportu:

```text
FB
football
```

Toto musí být před masovým harvestem sjednoceno normalizačním pravidlem.

---

# 5. Hlavní strategické rozhodnutí

Fotbal se nebude stavět na jednom univerzálním providerovi.

Cílový princip:

```text
SPORT
× SOUTĚŽ
× ENTITA
× SEZONA
× ČASOVÉ OBDOBÍ
× ÚČEL DAT
× PROVIDER / ZDROJ
```

Současné role:

| Zdroj | Ověřená nebo schválená role |
|---|---|
| `api_football` free | novější historie 2022–2024, CORE, PEOPLE a statistické detaily |
| `football_data` | aktuální sezony 14 plánovaných prestižních soutěží |
| `football_data_uk` | historické výsledky a případně historické doplňkové údaje |
| `the_odds` | aktuální kurzy podporovaných soutěží |
| oficiální zdroje | články, osoby, fotografie, kontrola a doplnění |
| Wikimedia / Wikidata | doplňkové identity a licenčně použitelné fotografie po ověření |
| budoucí placení provideři | hluboký backfill a následná denní aktualizace |

Historická, aktuální, people, odds a media data mohou mít odlišné primární providery.

---

# 6. Cílový postup před nákupem placených providerů

Placený tarif se nesmí koupit dříve, než bude připravena infrastruktura.

Povinné pořadí:

```text
1. definovat úplný požadovaný datový model fotbalu
2. vytvořit soutěž × sezona × entita matici
3. určit potřebnou historickou hloubku
4. vybrat kandidátní providery a bezplatné zdroje
5. právně ověřit ukládání, archivaci, kombinování a publikaci
6. připravit RAW vrstvu
7. připravit parsery
8. připravit staging
9. připravit provider mapování
10. připravit merge, deduplikaci a provenance
11. připravit historické fronty a checkpointy
12. spočítat request budget a cenu
13. provést smoke test
14. schválit PAID_PROVIDER_PURCHASE_READY
15. koupit vhodný plán
16. provést řízený hromadný historický backfill
17. ověřit úplnost a kvalitu
18. přejít na denní přírůstkové aktualizace
```

Po rozběhnutí platformy se počítá s placenými zdroji pro neustálé aktualizace od CORE až po MEDIA data. Historický bulk a denní provoz musí být oddělené režimy.

---

# 7. Požadované fotbalové datové vrstvy

## 7.1 CORE

- země,
- federace,
- soutěže,
- sezony,
- kola,
- skupiny a fáze,
- týmy,
- stadiony a místa,
- zápasy,
- výsledky,
- tabulky,
- stav soutěže a sezony.

## 7.2 MATCH DETAIL

- sestavy,
- základní jedenáctky,
- lavičky,
- střídání,
- góly,
- karty,
- penalty,
- VAR,
- rozhodčí,
- časová osa,
- týmové statistiky,
- zápasové statistiky hráčů.

## 7.3 PEOPLE

- hráči,
- trenéři,
- profily,
- aktuální soupisky,
- historické soupisky,
- kariéra,
- přestupy,
- hostování,
- zranění,
- disciplinární stav,
- fotografie,
- vazba osoba × tým × období.

## 7.4 STATISTICS

- sezónní statistiky,
- zápasové statistiky,
- forma,
- výkonnostní trendy,
- pokročilé metriky podle dostupnosti a licence,
- historická srovnání.

## 7.5 ODDS

- pre-match,
- live,
- closing odds,
- historické snapshoty,
- bookmakeři,
- trhy,
- outcomes,
- mapování provider eventu na kanonický zápas.

## 7.6 MEDIA

- oficiální články,
- týmové a ligové zprávy,
- fotografie,
- loga,
- video a highlights pouze při právním oprávnění,
- licence, atribuce a zdrojový odkaz.

## 7.7 GOVERNANCE A PROVENANCE

- provider,
- zdroj,
- endpoint,
- účet a tarif bez tajných údajů,
- request/run,
- RAW payload,
- parser,
- staging záznam,
- mapování,
- merge rozhodnutí,
- čas posledního úspěchu,
- kvalita,
- právní stav,
- primary, fallback a merge role.

---

# 8. Databázové nedostatky k řešení

1. Nejednotná identita providerů.
2. Chybějící rozlišení provider × source × organization × process.
3. Neúplný `public.data_providers`.
4. Chybějící provider FK u části specializovaných map.
5. Prototypový `public.canonical_provider_map` s duplicitami.
6. Duplicitní významy `is_primary_source` / `is_primary`.
7. Duplicitní významy `provider_priority` / `priority`.
8. Hrubá sportovní matice nadhodnocující runtime stav.
9. `enabled = true` používané i pro placeholdery.
10. Chybějící nebo rozptýlené přesné worker vazby.
11. Dva kódy fotbalu: `FB` a `football`.
12. Chybějící potvrzená multi-provider mapa zápasů.
13. Providerově specifická pole přímo v kanonických soutěžích.
14. Neúplná RAW provenance u části staging záznamů.
15. Prázdný fotbalový provider audit registry.
16. Neúplný merge sezonních statistik.
17. Neúplná people a media coverage.
18. Neověřená hluboká historie a historické odds.

Databáze se během dne neopravovala. Všechny nálezy jsou podkladem pro řízený dokumentační a migrační plán.

---

# 9. Přijatá rozhodnutí

1. Fotbal je nejpokročilejší referenční sport.
2. Házená je pouze první dílčí providerový pilot.
3. Dokumentace se dokončí před hlubokými databázovými změnami.
4. `MM-PRV-008` zůstává cílový návrh, nikoli implementovaná realita.
5. Fotbal bude dokončen end-to-end před systematickým rozšířením na ostatní sporty.
6. Providerové portfolio bude vícezdrojové.
7. `football_data` slouží pro aktuální sezony vybraných prestižních soutěží.
8. `api_football` free slouží pro novější historii 2022–2024 a detailní datové vrstvy.
9. `football_data_uk` je samostatný historický zdroj.
10. `the_odds` slouží pro aktuální kurzy; historie se musí řešit zvlášť.
11. Hluboká historie musí být doplněna vhodnými bezplatnými a následně placenými zdroji.
12. Placený provider se zakoupí až po kompletní technické, datové a právní přípravě.
13. Historický backfill a denní aktualizace budou oddělené provozní režimy.
14. Po rozběhnutí se počítá s placenými API pro průběžnou aktualizaci CORE až MEDIA.
15. Výběr providerů musí být založen na potřebné matici dat, nikoli pouze na marketingovém seznamu funkcí.
16. Aktuální ceny, tarify, endpointy, licence a podmínky se musí ověřovat z aktuálních webových a oficiálních zdrojů.
17. Právní nejistota vede do `REVIEW` nebo `HOLD`.
18. Do registrů a dokumentace se nesmí ukládat API klíče, tokeny ani hesla.

---

# 10. Problémy a jejich řešení

Tato kapitola samostatně zachycuje problémy zjištěné během práce. U každého problému je uvedena příčina, způsob analýzy, přijaté nebo navržené řešení a dosažený výsledek v souladu s `MM-DOC-900 § 5.5`.

## 10.1 Přímé připojení k databázi nebylo úspěšné

| Povinná část | Záznam |
|---|---|
| Problém | První přímý pokus o připojení prostřednictvím `psql` skončil chybou autentizace. |
| Příčina | Klient použil výchozího uživatele systému Windows a nebyla bezpečně dostupná správná databázová konfigurace. |
| Analýza | Byly ověřeny názvy dostupných proměnných prostředí a následně byl použit existující konfigurační objekt `DB_CONFIG` z aktivního Q3 panelu. Heslo nebylo vypsáno ani uloženo do auditních výstupů. |
| Řešení | Pro další práci byl použit nástroj A33 a samostatné skripty s transakcí `READ ONLY`, časovými limity a závěrečným `ROLLBACK`. |
| Výsledek | Připojení bylo úspěšně ověřeno. Všechny následné audity proběhly pouze pro čtení a databázi nezměnily. |

## 10.2 Existující registry neposkytují jednu úplnou provozní pravdu

| Povinná část | Záznam |
|---|---|
| Problém | Informace o poskytovateli dat, podporovaných entitách, spuštění, pracovním procesu a skutečné připravenosti jsou rozděleny mezi více tabulek. |
| Příčina | Registry vznikaly postupně během výstavby databáze a při dílčích implementacích jednotlivých sportů. |
| Analýza | Byly porovnány zejména `public.data_providers`, `ops.provider_sport_matrix`, `ops.provider_entity_coverage`, `ops.ingest_entity_plan`, `ops.provider_worker_registry`, `ops.provider_accounts` a mapovací tabulky. |
| Řešení | Neprovádět okamžité vytváření další paralelní tabulky. Nejprve v `MM-PRV-009` přesně určit roli každého existujícího objektu, cílový zdroj pravdy, kompatibilitu a pořadí migrace. |
| Výsledek | Skutečný stav byl zdokumentován. Databázová změna byla správně odložena do schváleného implementačního plánu. |

## 10.3 Providerové identity a technické kódy nejsou sjednocené

| Povinná část | Záznam |
|---|---|
| Problém | V databázi se používají kanonické kódy, aliasy, názvy organizací, interní procesní štítky a technické adaptéry ve stejných providerových sloupcích. |
| Příčina | Jednotlivé importy a pracovní procesy používaly vlastní historická označení bez společného registru aliasů a typů zdroje. |
| Analýza | Audit zjistil 96 nekanonických výskytů a 43 rozdílných normalizovaných hodnot. Mezi příklady patří `theodds`, `the_odds`, `football_data_uk`, `sportsdataio`, `official_site`, `fifa`, `uefa` a procesní označení. |
| Řešení | V cílovém modelu oddělit poskytovatele dat, zdroj, organizaci, vydavatele, adaptér a interní proces. Teprve poté normalizovat aliasy a zavádět referenční vazby. |
| Výsledek | Nebyly provedeny nebezpečné hromadné přepisy ani předčasné přidání cizích klíčů. Problém zůstává otevřeným migračním úkolem. |

## 10.4 Rozdíl mezi deklarovanou podporou a skutečnou připraveností

| Povinná část | Záznam |
|---|---|
| Problém | `enabled = true` nebo deklarace podpory v souhrnné matici může současně existovat s detailním stavem `planned`, `blocked` nebo bez spustitelného pracovního procesu. |
| Příčina | Souhrnná matice popisuje převážně schopnost poskytovatele dat, zatímco ostatní registry zachycují plán, technickou vazbu nebo runtime zkušenost. |
| Analýza | Bylo porovnáno 16 sportovních matic, 107 záznamů detailního pokrytí, 106 plánů ingestu a 50 záznamů pracovních procesů. |
| Řešení | V cílovém modelu oddělit deklarovanou dostupnost, technickou připravenost, stav implementace, stav testu, provozní aktivaci a poslední úspěšné spuštění. |
| Výsledek | Bylo potvrzeno, že samotné `enabled = true` nesmí být používáno jako důkaz připravenosti pro hromadný sběr dat. |

## 10.5 Nesprávná pracovní interpretace role Football-Data

| Povinná část | Záznam |
|---|---|
| Problém | Během průběžného vyhodnocení byl `football_data` dočasně popsán jako historický zdroj. |
| Příčina | V projektu současně existují podobně pojmenované, ale rozdílné zdroje `football_data` a `football_data_uk`. |
| Analýza | Uživatel upozornil na rozdíl a časový audit potvrdil, že `football_data` v projektu poskytuje aktuální sezony vybraných prestižních soutěží, zatímco `football_data_uk` obsahuje starší historické výsledky. |
| Řešení | Role byly v dokumentaci opraveny a oba zdroje musí být vedeny odděleně. |
| Výsledek | Aktuální závěr je jednoznačný: `football_data` = aktuální soutěže; `football_data_uk` = samostatný historický CSV zdroj. |

## 10.6 Neúplnost fotbalové datové vrstvy

| Povinná část | Záznam |
|---|---|
| Problém | Fotbal má rozsáhlý základ, ale některé entity, mapy, fotografie, trenéři, statistiky, historie kurzů a provenance nejsou úplné. |
| Příčina | Dosavadní práce probíhala po dílčích vrstvách, s omezeními bezplatných tarifů a bez dokončené jednotné matice požadovaných dat. |
| Analýza | Byla ověřena úplnost CORE a PEOPLE, rozdíl mezi staging a public vrstvou, mapovací pokrytí a časový rozsah jednotlivých zdrojů. |
| Řešení | Nejprve vytvořit úplnou matici sport × soutěž × sezona × entita × časové období × účel. Pro každou buňku následně určit primární, záložní, slučovací a historický zdroj. |
| Výsledek | Fotbal byl potvrzen jako referenční sport, ale nebyl nesprávně označen za kompletně připravený. Výběr konečných zdrojů a databázová implementace pokračují v dalších krocích. |

## 10.7 Rozdíl mezi 14 plánovanými a 13 namapovanými soutěžemi Football-Data

| Povinná část | Záznam |
|---|---|
| Problém | Projektový záměr počítá se 14 prestižními soutěžemi, zatímco `public.league_provider_map` obsahuje 13 explicitních vazeb na `football_data`. |
| Příčina | Čtrnáctá soutěž může být vedena pouze v konfiguraci, pod jiným označením, mimo specializovanou mapu nebo nebyla do mapy doplněna. |
| Analýza | Časový audit vypsal všech 13 aktuálně namapovaných soutěží a potvrdil jejich providerová ID. |
| Řešení | Dohlédat původní konfiguraci a rozhodnout, zda je potřeba doplnit mapu, opravit alias nebo upravit deklarovaný počet. |
| Výsledek | Problém je přesně lokalizován a zůstává otevřený. Databáze nebyla bez důkazu měněna. |

---

# 11. Výsledky dne

Tato kapitola stručně shrnuje dokončené, odložené a navazující oblasti v souladu s `MM-DOC-900 § 5.6`.

## 11.1 Dokončeno

- Byl ověřen databázový server, transakční režim a bezpečný postup auditů pouze pro čtení.
- Byl dokončen strukturální audit databáze A33.
- Byly popsány role hlavních providerových a zdrojových registrů.
- Byla provedena kontrola providerových kódů a jejich souladu s kanonickým číselníkem.
- Byly prověřeny specializované mapy soutěží, týmů, hráčů a trenérů.
- `public.canonical_provider_map` byl správně označen jako prototyp vyžadující revizi.
- Házená byla potvrzena jako první dílčí providerový pilot.
- Fotbal byl potvrzen jako nejpokročilejší referenční sport.
- Byl dokončen audit fotbalového CORE, PEOPLE, staging struktur a časového pokrytí.
- Byly rozlišeny role zdrojů `api_football`, `football_data`, `football_data_uk` a `the_odds`.
- Bylo přijato pravidlo vícezdrojového providerového portfolia.
- Bylo potvrzeno, že placený tarif smí být zakoupen až po úplné technické, datové, provozní a právní připravenosti.
- Všechny databázové kontroly skončily `ROLLBACK`; databáze nebyla změněna.

## 11.2 Odloženo

- Výběr konečných bezplatných a placených poskytovatelů dat.
- Aktuální cenový, tarifní, technický a právní průzkum kandidátů.
- Vytvoření nebo úprava databázových objektů Provider Registry a Provider Matrix.
- Normalizace providerových aliasů a zavedení referenčních vazeb.
- Oprava rozdílů mezi souhrnnou maticí, detailním pokrytím, plánem ingestu a registry pracovních procesů.
- Nákup placeného tarifu a historický hromadný sběr dat.

Odložení je záměrné. Tyto kroky nesmějí předběhnout schválenou dokumentaci a připravenost infrastruktury.

## 11.3 Pokračuje

- Příprava úplné fotbalové datové matice.
- Určení požadovaného časového rozsahu každé entity.
- Dohlédání čtrnácté soutěže Football-Data.
- Ověření chybějící sezony 2023 u sezonních statistik hráčů.
- Ověření multi-provider mapování zápasů a kurzových událostí.
- Ověření 792 soutěží vedených přes historické označení `api_sport`.
- Příprava dokumentu `MM-PRV-009`.
- Příprava brány `PAID_PROVIDER_PURCHASE_READY`.

## 11.4 Aktuální stav

```text
Dokumentace providerů: MM-PRV-001 až MM-PRV-008 dokončena
Cílový datový model: navržen, dosud neimplementován
Referenční sport: fotbal
Providerový pilot: házená
Databázové audity: dokončeny pouze pro čtení
Databázové změny dne: žádné
Finální providerové portfolio: dosud neschváleno
Bezprostřední odborný cíl: úplná fotbalová datová a providerová matice
```

Přínosem pracovního dne je přechod od obecných návrhů k ověřenému obrazu skutečné databáze a přesné vymezení podmínek, které musí být splněny před hromadným historickým sběrem dat.

---

# 12. Terminologická kontrola

Terminologie byla sjednocena podle aktivního slovníku MatchMatrix a pravidel dokumentace.

| Odborný pojem | Preferovaný český význam v běžném textu | Pravidlo použití |
|---|---|---|
| Provider | Poskytovatel dat | V běžném vysvětlujícím textu se používá „poskytovatel dat“. Přesné názvy dokumentů, tabulek, sloupců, stavů a kódů se zachovávají v původním tvaru v `backticku`. |
| Harvest | Sběr dat | Pro proces se používá „sběr dat“. Technické názvy jako `bulk harvest` mohou zůstat uvedeny jako dohledatelný původní termín. |
| Worker | Pracovní proces | V běžném textu se používá „pracovní proces“. Názvy skriptů a registry, například `provider_worker_registry`, se nemění. |
| Coverage | Datové pokrytí | V běžném textu se používá „datové pokrytí“. Databázová pole jako `coverage_status` zůstávají beze změny. |
| Read-only | Pouze pro čtení | V běžném textu se používá český význam; technický příkaz `READ ONLY` zůstává zachován. |
| Merge | Sloučení | Vysvětlující text používá „sloučení“; přesné názvy funkcí, tabulek a pracovních procesů se nemění. |
| Fallback | Záložní zdroj nebo záložní postup | Vysvětlující text používá český význam; technické role mohou být uvedeny přesným kódem. |
| Runtime | Provozní běh nebo stav při spuštění | České označení se používá v popisu; přesné stavové a databázové názvy se zachovávají. |

Ruční terminologická kontrola musí potvrdit, že:

1. stejný odborný význam není označován několika různými českými názvy,
2. původní technické kódy zůstávají dohledatelné,
3. poskytovatel dat není zaměňován se zdrojem, organizací, vydavatelem, adaptérem nebo interním procesem,
4. `football_data` a `football_data_uk` jsou vedeny jako rozdílné zdroje,
5. panelové popisky mají být české, zatímco databázové a souborové identifikátory se nepřekládají.

---

---

# 13. Ověřené technické výstupy

Výstupy byly vytvořeny v:

```text
C:\MatchMatrix-platform\reports\documentation\database_audit
```

Hlavní soubory:

```text
database_structure_*_20260722_123744.*
provider_registry_core_columns_20260722.csv
provider_registry_core_audit_20260722.json
provider_code_alignment_audit_20260722.csv
provider_mapping_structure_audit_20260722.json
provider_mapping_data_audit_20260722.json
provider_mapping_usage_references_20260722.csv
handball_provider_pilot_audit_20260722.json
handball_runtime_references_20260722.csv
handball_live_runtime_binding_audit_20260722.json
all_sports_provider_runtime_snapshot_20260722.json
football_reference_state_audit_20260722.json
football_core_people_completeness_audit_20260722.json
football_core_people_table_structure_20260722.json
football_provider_temporal_coverage_audit_20260722.json
```

Všechny dnešní databázové audity byly read-only a ukončeny rollbackem.

---

# 14. Aktuální stav

| Oblast | Stav |
|---|---|
| Providerová dokumentace | `MM-PRV-001` až `MM-PRV-008` dokončeny |
| `MM-PRV-008` | TARGET DESIGN – NOT YET IMPLEMENTED |
| Read-only audit providerů | Proveden |
| Centrální audit všech sportů | Proveden |
| Referenční sport | Fotbal |
| Fotbal CORE audit | Proveden |
| Fotbal PEOPLE audit | Proveden |
| Fotbal struktura map a staging | Provedena |
| Fotbal časová coverage | Provedena |
| Výběr finálních providerů | NE – čeká na požadovanou datovou matici a aktuální výzkum |
| Databáze změněna dnešními audity | NE |
| Nové dokumenty v dokumentační DB | Dosud NE |
| Poslední potvrzený remote commit | `e81a4f5` |
| Aktuální Git stav | Při uzavření znovu neověřen |

---

# 15. Kontext pro AI

Při pokračování musí AI:

1. Chápat fotbal jako nejpokročilejší referenční sport.
2. Neoznačovat házenou za nejpokročilejší sport.
3. Chápat házenou jako první dílčí providerový pilot.
4. Zachovat `MM-PRV-008` jako návrh, nikoli implementovanou databázi.
5. Neprovádět databázové změny bez schválené dokumentace a rollbacku.
6. Rozlišovat `football_data` od `football_data_uk`.
7. `football_data` popisovat jako zdroj aktuálních sezon prestižních soutěží.
8. `api_football` free popisovat jako zdroj novější historie 2022–2024 a detailních vrstev.
9. `the_odds` popisovat jako současný odds zdroj; hluboká historie není v aktuální implementaci pokryta.
10. Nestavět fotbal na jednom providerovi.
11. Hodnotit providery podle soutěže, entity, sezony, časového období a účelu.
12. Před placeným tarifem dokončit RAW, parser, staging, mapy, merge, validace, fronty, checkpointy a request budget.
13. Požadovat právní schválení ukládání, archivace, kombinování a publikace.
14. Pro aktuální ceny, tarify, limity, coverage a podmínky použít aktuální oficiální webové zdroje.
15. Nepoužívat neověřené marketingové tvrzení jako potvrzenou coverage.
16. Dohlédnout 14. soutěž záměru Football-Data, protože v mapě je nyní 13.
17. Ověřit sezonu 2023 u player season stats.
18. Ověřit `match_provider_map` nebo navrhnout kompatibilní řešení.
19. Ověřit 792 soutěží s `ext_source = api_sport`.
20. Neopravovat providerové FK před normalizací všech providerových kódů.
21. Zachovat technické kódy dohledatelné, panelové popisky vést česky.
22. Postupovat po jednom jasném kroku.
23. Denní zápis a NAV poskytovat jako kompletní Markdown soubory.

---

# 16. Projektový snímek

| Oblast | Ověřený stav |
|---|---|
| Projekt | MatchMatrix-platform |
| Repozitář | `C:\MatchMatrix-platform` |
| Větev | `main` |
| Poslední potvrzený remote commit | `e81a4f5` |
| Execution host | PC2 (`192.168.3.119`) |
| DB host | `localhost` na PC2 |
| DB target | `matchmatrix` |
| PostgreSQL server | 16.14 |
| Aktivní panel | `tools/matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py` |
| Provider docs | `MM-PRV-001` až `MM-PRV-008` |
| Dokumenty v DB | 344 |
| Verze v DB | 350 |
| Sekce v DB | 6 542 |
| Vazby v DB | 393 |
| Historie stavů | 350 |
| Aktivní dokumenty | 344 |
| Sporty | 14 |
| Kanoničtí provideři | 22 |
| Detailní coverage řádky | 107 |
| Ingest entity plány | 106 |
| Worker registry řádky | 50 |
| Provider accounts | 10 |

---

# 17. Databázový snímek

Dnešní audity databázi nezměnily.

```text
SET TRANSACTION READ ONLY
ROLLBACK
database_changed = false
```

Poslední potvrzený dokumentační stav zůstává:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 344 |
| Verze celkem | 350 |
| Aktuální verze | 344 |
| Sekce | 6 542 |
| Vazby | 393 |
| Historie stavů | 350 |
| Aktivní dokumenty | 344 |

Dokumenty `MM-DL-20260722` a `MM-NAV-20260722-01` jsou v okamžiku vytvoření návrhy. Do databáze se dostanou až po:

```text
uložení
→ A17
→ A23
→ uživatelské schválení
→ Git commit
→ A24 VALIDATE_ONLY
→ A24 APPLY
→ A7
```

---

# 18. Otevřené úkoly

1. Uložit dnešní denní zápis a NAV do kanonických složek.
2. Projít oba dokumenty přes A17 a A23.
3. Schválit dokumenty.
4. Commitnout a pushnout oba dokumenty.
5. Importovat je přes A24 a ověřit přes A7.
6. Připravit úplnou fotbalovou datovou matici.
7. Vymezit požadované soutěže a historickou hloubku.
8. Vymezit všechny entity CORE, MATCH DETAIL, PEOPLE, STATISTICS, ODDS a MEDIA.
9. Stanovit frekvenci denních aktualizací každé entity.
10. Provést aktuální výzkum vhodných providerů a bezplatných zdrojů.
11. Porovnat API-Football, Football-Data, Football-Data UK, The Odds a další kandidáty.
12. Dohlédat čtrnáctou soutěž Football-Data.
13. Ověřit hlubší bezplatný historický rozsah Football-Data UK.
14. Ověřit právní podmínky každého zdroje.
15. Spočítat požadovaný historický request budget.
16. Navrhnout `PAID_PROVIDER_PURCHASE_READY` gate.
17. Doplnit zjištění do `MM-PRV-009`.
18. Teprve potom připravit schválené databázové migrace.

---

# 19. Plán pokračování

Doporučené pořadí:

```text
A. uložit a publikovat MM-DL-20260722 a MM-NAV-20260722-01
B. definovat úplnou fotbalovou datovou matici
C. stanovit požadovaný historický a denní rozsah
D. provést aktuální provider research
E. vytvořit provider shortlist
F. provést technický, cenový a právní benchmark
G. dokončit MM-PRV-009
H. schválit cílový databázový model a migrace
I. připravit všechny workery a validační brány
J. potvrdit PAID_PROVIDER_PURCHASE_READY
K. provést historický bulk harvest
L. přejít na denní přírůstkové aktualizace
M. použít ověřený model pro další sporty
```

---

# 20. Jediný hlavní další krok

Uložit oba vytvořené dokumenty do:

```text
C:\MatchMatrix-platform\docs\09_HISTORY\DENNÍ_ZÁPISY
C:\MatchMatrix-platform\docs\09_HISTORY\NAVÁZÁNÍ_NA_CHAT
```

Poté je načíst v Q3 panelu pro A17 a A23.

---

# 21. Vazby a NAVÁZÁNÍ

| Vazba | Dokument nebo výstup |
|---|---|
| Navazující dokument | `MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Předchozí denní zápis | `MM-DL-20260721_MATCHMATRIX_DENNI_ZAPIS.md` |
| Předchozí NAV | `MM-NAV-20260721-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Cílový model | `MM-PRV-008_DATOVY_MODEL_PROVIDER_REGISTRY_A_PROVIDER_MATRIX.md` |
| Budoucí plán | `MM-PRV-009_IMPLEMENTACNI_PLAN_PROVIDER_REGISTRY_A_PROVIDER_MATRIX.md` |
| Právní základ | `MM-PRV-006_PRAVNI_A_LICENCNI_RIZENI_PROVIDERU.md` |
| Referenční katalog | `MM-PRV-007_REFERENCNI_KATALOG_PROVIDERU_TARIFU_A_POKRYTI.md` |
| Šablona denního zápisu | `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md` |
| Šablona NAV | `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md` |

---

# 22. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-07-22 | DRAFT – NEEDS_USER_APPROVAL | Podrobný zápis read-only auditu providerových registrů, všech sportů a fotbalu; potvrzení multi-provider strategie a přípravy před placeným historickým harvestem. |
| 1.1 | 2026-07-23 | DRAFT – NEEDS_USER_APPROVAL | Doplněny samostatné kapitoly Problémy a jejich řešení, Výsledky dne a Terminologická kontrola podle MM-DOC-900 § 5.5–5.6; sjednoceny české názvy souhrnných kapitol. |

---

# Závěr dokumentu

Dne 2026-07-22 byl proveden rozsáhlý read-only audit providerového ekosystému MatchMatrix. Byla ověřena skutečná struktura providerových tabulek, specializovaných map, kódů, plannerů a workerů. Házená byla potvrzena jako první dílčí providerový pilot, zatímco fotbal byl potvrzen jako nejpokročilejší referenční sport.

Fotbal již obsahuje rozsáhlý CORE, hráče, sezónní statistiky, providerové mapy, odds objekty a media základy. Současně byly přesně identifikovány mezery v mapování soutěží, people datech, trenérech, statistikách, odds historii, provenance, providerových identitách a runtime stavech.

Bylo rozhodnuto, že fotbal nebude závislý na jednom providerovi. `football_data` bude používán pro aktuální sezony vybraných prestižních soutěží, `api_football` free pro novější historii 2022–2024 a detailnější vrstvy, `football_data_uk` pro starší historické výsledky a `the_odds` pro aktuální kurzy. Další vhodní bezplatní a placení provideři musí být vybráni podle úplné matice soutěž × sezona × entita × účel.

Placené tarify se zakoupí až po úplné technické, datové, právní a provozní přípravě. Následně proběhne řízený historický bulk harvest a po jeho dokončení se platforma přepne na denní přírůstkové aktualizace od CORE až po MEDIA data.
