# MatchMatrix – navázání do nového chatu – 2026-07-22

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260722-01 |
| Název dokumentu | MatchMatrix – navázání do nového chatu – 2026-07-22 |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | 1.1 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-22 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | Provider Registry, Provider Matrix a úplná příprava fotbalu |
| Primární formát | Markdown (`.md`) |
| Kanonické umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Zdrojový denní zápis | `MM-DL-20260722_MATCHMATRIX_DENNI_ZAPIS.md` |
| Předchozí navázání | `MM-NAV-20260721-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Šablona | `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md` |

---

---

# 1. Identifikace navázání

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260722-01 |
| Datum pracovního dne | 2026-07-22 |
| Datum a čas uzavření | 2026-07-22T23:48:34+02:00 |
| Zdrojový denní zápis | `MM-DL-20260722` |
| Aktivní oblast | Providerová dokumentace a databázový audit |
| Referenční sport | Fotbal |
| Providerový pilot | Házená |
| Poslední dokončený hlavní dokument | `MM-PRV-008` |
| Připravovaný dokument | `MM-PRV-009` |
| Bezprostřední další krok | Nahradit NAV opravenou verzí 1.1 a znovu spustit A17 |
| Následující odborný krok | Vytvořit úplnou fotbalovou datovou a providerovou matici |

---

---

# 2. Výchozí kontext pro nový chat

Providerová dokumentace `MM-PRV-001` až `MM-PRV-008` je dokončena a importována do dokumentační databáze.

`MM-PRV-008` je:

```text
TARGET DESIGN – NOT YET IMPLEMENTED
```

Dne 2026-07-22 začal read-only audit skutečné databáze před přípravou implementačního plánu.

Bylo potvrzeno:

```text
fotbal = nejpokročilejší referenční sport
házená = první dílčí providerový pilot
```

Cílem není pouze doplnit několik providerových tabulek. Cílem je připravit fotbal kompletně od providerů a zdrojů přes RAW, staging, mapování, merge a public data až po monitoring, právní řízení, historický hromadný harvest a každodenní aktualizace.

---

---

# 3. CURRENT STATUS

## 3.1 Dokumentace

```text
MM-PRV-001 až MM-PRV-008: dokončeno
MM-PRV-008: návrh, nikoli implementace
MM-PRV-009: dosud nevytvořen
```

Nové dokumenty:

```text
MM-DL-20260722_MATCHMATRIX_DENNI_ZAPIS.md
MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

byly uloženy do kanonických složek a při této opravě zůstávají ve stavu:

```text
DRAFT – NEEDS_USER_APPROVAL
```

Dosud nejsou v dokumentační databázi. Čekají na dokončení A17, A23, schválení, Git a A24.

## 3.2 Dokumentační databáze

Poslední potvrzený stav:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 344 |
| Verze | 350 |
| Aktuální verze | 344 |
| Sekce | 6 542 |
| Vazby | 393 |
| Historie stavů | 350 |
| Aktivní dokumenty | 344 |
| Varování | 0 |
| Blokátory | 0 |

## 3.3 Git

```text
Repo: C:\MatchMatrix-platform
Branch: main
Poslední potvrzený remote commit: e81a4f5
Aktuální Git stav při uzavření: nebyl znovu ověřen
```

## 3.4 Databázové prostředí

```text
Execution host: PC2 (192.168.3.119)
DB host: localhost
DB target: matchmatrix
PostgreSQL server: 16.14
Audit režim: READ ONLY / ROLLBACK
```

---

---

# 4. Co bylo dokončeno

## 4.1 Strukturální audit databáze

Byl úspěšně proveden A33 audit:

- 1 115 objektů,
- 283 tabulek,
- 596 pohledů,
- 12 257 sloupců,
- 603 constraints,
- 856 indexů,
- 95 rutin,
- 23 triggerů,
- 747 závislostí,
- velikost 659,66 MB.

Databáze nebyla změněna.

## 4.2 Audit providerových registrů

Byly rozlišeny role:

```text
public.data_providers
ops.provider_entity_coverage
ops.provider_sport_matrix
ops.provider_accounts
ops.provider_audit_registry
ops.global_source_registry
ops.source_registry
```

Žádný z těchto objektů sám nepokrývá celý cílový Provider Registry.

## 4.3 Audit providerových kódů

Výsledek:

```text
MATCH: 317
MISSING_IN_DATA_PROVIDERS: 96
CANONICAL_UNUSED: 4
```

Bylo zjištěno 43 rozdílných nekanonických hodnot.

## 4.4 Audit providerových map

Specializované mapy pro leagues, teams, players a coaches zůstávají aktivním základem.

`public.canonical_provider_map` byl klasifikován jako:

```text
PROTOTYPE – REVIEW BEFORE REUSE
```

Obsahuje 107 duplicitních klíčových skupin a nemá přesný překryv se specializovanými mapami.

## 4.5 Audit házené

Házená má ověřený dílčí CORE pilot:

- 211 league maps,
- 1 005 team maps,
- runtime teams a fixtures,
- players blocked,
- coaches planned,
- odds planned.

Házená není cílový vzor úplného sportu.

## 4.6 Audit všech sportů

Ověřený snapshot:

| Oblast | Počet |
|---|---:|
| Sporty | 14 |
| Kanoničtí provideři | 22 |
| Sportovní matice | 16 |
| Detailní coverage | 107 |
| Ingest plány | 106 |
| Worker registry | 50 |
| Provider účty | 10 |

Coverage:

```text
runtime_tested: 32
tech_ready: 10
planned: 57
blocked: 8
```

## 4.7 Audit fotbalu

Fotbal má:

| Entita | Počet |
|---|---:|
| Soutěže | 2 030 |
| Týmy | 6 854 |
| Zápasy | 105 506 |
| Hráči | 5 340 |
| Trenéři | 3 |
| Veřejné sezonní statistiky | 3 121 |
| Staging sezonní statistiky | 110 319 |

Mapping coverage:

```text
leagues: 60,99 %
teams: 98,70 %
players: 99,98 %
coaches: 100 %
```

Největší people mezery:

```text
hráčské fotografie: chybí 72,02 %
aktuální tým hráče: chybí 27,21 %
pozice: chybí 9,83 %
trenéři v public: pouze 3
```

---

## 4.8 Ověřená časová coverage fotbalu

## 4.1 API-Football free

```text
2022: 20 530 zápasů
2023: 26 851 zápasů
2024: 30 054 zápasů
```

Role:

```text
novější historie 2022–2024
+ detailnější CORE
+ PEOPLE
+ statistiky podle dostupnosti
```

## 4.2 Football-Data

Role:

```text
aktuální sezony vybraných prestižních soutěží
```

Aktuálně namapováno 13 soutěží, přestože záměr je 14.

Ověřená data:

```text
2024: 51 zápasů
2025: 3 110 zápasů
2026: 578 zápasů
```

`football_data` nesmí být označován jako hlavní historický zdroj.

## 4.3 Football-Data UK

Ověřená historie v databázi:

```text
2018/19 až 2025/26
```

Jde o samostatný historický CSV zdroj.

## 4.4 The Odds

- 13 soutěží má `theodds_key`,
- aktuálně je aktivní pouze Premier League,
- používá se pro aktuální kurzy,
- hluboká potřebná historie není v současné implementaci a tarifu pokryta.

## 4.5 Statistiky hráčů

Staging obsahuje sezony 2022 a 2024.

Sezona 2023 není v `stg_provider_player_season_stats` potvrzena.

---

---

# 5. Co zůstává rozpracováno

Práce byla přerušena po dokončení read-only auditů a před vytvořením úplné fotbalové datové a providerové matice. Rozpracované zůstávají následující oblasti.

## 5.1 Dokumentační uzavření pracovního dne

Dokumenty:

```text
MM-DL-20260722_MATCHMATRIX_DENNI_ZAPIS.md
MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

jsou uloženy, ale dosud nejsou publikovány v dokumentační databázi. Zbývá:

```text
A17
→ A23
→ uživatelské schválení
→ Git commit a push
→ A24 VALIDATE_ONLY
→ A24 APPLY
→ A7
```

## 5.2 Úplná fotbalová datová matice

Dosud nebyla dokončena matice:

```text
sport
× soutěž
× sezona
× entita
× časové období
× účel dat
× provider nebo zdroj
```

Bez této matice nelze korektně určit chybějící historické, aktuální, people, statistické, odds a media zdroje.

## 5.3 Výběr vhodných providerů a zdrojů

Konečné providerové portfolio dosud nebylo schváleno. Je nutné:

- ověřit aktuální bezplatné a placené kandidáty,
- porovnat datové pokrytí, historii, cenu, limity a stabilitu ID,
- posoudit práva k získávání, ukládání, archivaci, kombinování a publikaci dat,
- určit role `PRIMARY`, `FALLBACK`, `MERGE_SOURCE`, `BACKFILL_ONLY` a `DAILY_UPDATE`.

## 5.4 Databázové sjednocení

Rozpracované zůstává:

- sjednocení providerových identit a aliasů,
- rozlišení provider × source × organization × process,
- normalizace `FB` a `football`,
- ověření multi-provider mapování zápasů a odds událostí,
- odstranění rozporu mezi deklarovanou podporou a skutečnou runtime připraveností,
- dokončení provenance, worker vazeb a stavových pravidel.

## 5.5 Cílový stav fotbalu

Fotbal má být kompletně připraven pro:

## Historický bulk harvest

- maximální požadovaná historie,
- řízení po soutěžích a sezonách,
- checkpointy,
- retry,
- budget požadavků,
- restart po chybě,
- přesná provenance,
- post-importní audit.

## Každodenní aktualizace

- nové zápasy,
- změny stavů a výsledků,
- tabulky,
- soupisky,
- hráči,
- trenéři,
- přestupy,
- zranění,
- statistiky,
- kurzy,
- články,
- fotografie a media metadata.

Historický a denní režim musí být oddělený.

---

## 5.6 Povinná připravenost před koupí placeného API

Musí být hotové:

1. cílové DB struktury,
2. provider identity a aliasy,
3. soutěž × sezona × entita matice,
4. RAW,
5. parsery,
6. staging,
7. provider mapy,
8. merge a deduplikace,
9. provenance,
10. historické fronty,
11. denní fronty,
12. checkpointy a retry,
13. monitoring limitů,
14. kalkulace request budgetu,
15. právní a licenční schválení,
16. smoke test,
17. rollback,
18. panelový přehled.

Teprve potom lze schválit:

```text
PAID_PROVIDER_PURCHASE_READY
```

---

## 5.7 Doporučené pořadí pokračování

```text
1. dokumentačně uzavřít 2026-07-22
2. definovat požadovanou fotbalovou matici
3. identifikovat existující coverage a mezery
4. vyhledat aktuální providery a zdroje
5. porovnat coverage, cenu, limity a licenci
6. vybrat primary, fallback, merge a backfill zdroje
7. dokončit MM-PRV-009
8. schválit databázové změny
9. připravit RAW → staging → maps → merge → public
10. připravit historický harvest
11. koupit tarif až po readiness gate
12. provést backfill
13. přejít na denní provoz
```

---

---

# 6. Otevřené úkoly

1. Dokončit A17 a A23 pro dnešní DAILY_LOG a CHAT_CONTINUATION a následně je publikovat.
2. Vytvořit úplnou fotbalovou matici požadovaných dat.
3. Stanovit seznam cílových soutěží.
4. Stanovit minimální a ideální historickou hloubku.
5. Stanovit denní aktualizační frekvence.
6. Dohlédat 14. Football-Data soutěž.
7. Ověřit season 2023 player stats.
8. Ověřit 792 soutěží vedených jako `api_sport`.
9. Ověřit match provider mapping.
10. Ověřit odds event mapping.
11. Provést aktuální provider research.
12. Připravit shortlist bezplatných a placených zdrojů.
13. Provést technický benchmark.
14. Provést cenový benchmark.
15. Provést právní a licenční audit.
16. Připravit `MM-PRV-009`.
17. Schválit DB migrace.
18. Připravit harvest infrastrukturu.
19. Potvrdit `PAID_PROVIDER_PURCHASE_READY`.
20. Provést historický bulk harvest.
21. Přepnout na každodenní aktualizace.
22. Aplikovat ověřený model na ostatní sporty.

---

---

# 7. Rizika a upozornění

## 7.1 Známá omezení a neověřené předpoklady

1. `enabled = true` neznamená runtime ready.
2. `provider_sport_matrix` často nadhodnocuje reálnou připravenost.
3. Coverage, ingest plán a worker registry mají rozdílné významy.
4. `FB` a `football` se používají současně.
5. `theodds` a `the_odds` nejsou sjednoceny.
6. `football_data` a `football_data_uk` jsou rozdílné zdroje.
7. 792 fotbalových soutěží není ve specializované league mapě.
8. 89 týmů není namapováno.
9. 1 hráč není namapován.
10. Sezonní statistiky mají velký rozdíl staging vs public.
11. Match player stats staging je prázdný.
12. Fotbalový `provider_audit_registry` je prázdný.
13. U zápasů není zatím potvrzena multi-provider mapa.
14. RAW provenance je u části staging dat neúplná.
15. Čtrnáctá Football-Data soutěž není v aktuální mapě.
16. Historická odds coverage není připravena.

---

## 7.2 Zakázané nebo předčasné kroky

- Nevytvářet ihned novou `ops.provider_registry`.
- Nemazat specializované provider mapy.
- Nepoužít `canonical_provider_map` jako master bez auditu a migrace.
- Nepřidávat provider FK před normalizací kódů.
- Nekupovat placený tarif před technickou a právní připraveností.
- Neoznačovat providerovu deklarovanou schopnost za ověřený runtime.
- Nezaměňovat `football_data` za historický zdroj.
- Nezaměňovat zdroj, organizaci, provider a interní proces.
- Nezapisovat API klíče, tokeny nebo hesla do registrů a dokumentace.
- Neprovádět hromadný historický harvest bez checkpointů a request budgetu.
- Neměnit DB před schválením `MM-PRV-009`.

---

## 7.3 Právní a provozní rizika

1. Technická dostupnost endpointu neznamená automaticky oprávnění data dlouhodobě ukládat, kombinovat nebo veřejně zobrazovat.
2. Aktuální ceny, tarify, limity, dostupné sezony a licenční podmínky se mohou měnit a musí být před rozhodnutím znovu ověřeny.
3. Hromadný historický harvest bez checkpointů, retry, request budgetu a obnovy po chybě může způsobit neúplná data nebo zbytečné vyčerpání placeného tarifu.
4. Nejednotné providerové kódy mohou při předčasném zavedení cizích klíčů zablokovat existující importy.
5. `enabled = true` nesmí být interpretováno jako důkaz produkční připravenosti.
6. Neověřený zdroj nebo nejasná licence musí zůstat ve stavu `REVIEW` nebo `HOLD`.

## 7.4 Bezpečnostní upozornění

Do dokumentace, Git repozitáře, auditních reportů ani providerových registrů se nesmějí ukládat API klíče, tokeny, hesla nebo jiné tajné údaje.

---

# 8. Přijatá rozhodnutí

Fotbal musí být postaven jako řízené portfolio více providerů a zdrojů.

```text
soutěž
× sezona
× entita
× časové období
× účel
→ vhodný provider nebo zdroj
```

Současné role:

| Zdroj | Role |
|---|---|
| `api_football` free | 2022–2024, detailní CORE, PEOPLE a statistiky |
| `football_data` | aktuální sezony 14 plánovaných prestižních soutěží |
| `football_data_uk` | starší historické výsledky |
| `the_odds` | aktuální kurzy |
| oficiální zdroje | články, osoby, fotografie a ověřování |
| budoucí placení provideři | hluboký backfill a dlouhodobé aktualizace |

Jeden provider nemusí pokrývat celý sport.

---

Další platná rozhodnutí:

1. Fotbal je nejpokročilejší referenční sport MatchMatrix.
2. Házená je první dílčí providerový pilot, nikoli nejpokročilejší sport.
3. `MM-PRV-008` zůstává cílovým návrhem a nesmí být popisován jako již implementovaná databázová realita.
4. `football_data` slouží pro aktuální sezony vybraných prestižních soutěží.
5. `api_football` free pokrývá v projektu novější historii 2022–2024 a detailnější vrstvy.
6. `football_data_uk` je samostatný historický CSV zdroj.
7. `the_odds` slouží v současné implementaci pro aktuální kurzy; potřebná hluboká historie není pokryta.
8. Placený tarif smí být zakoupen až po potvrzení `PAID_PROVIDER_PURCHASE_READY`.
9. Historický backfill a každodenní aktualizace budou samostatné provozní režimy.
10. Databázové migrace se nesmějí zahájit před schválením `MM-PRV-009`.

---

# 9. Ověřené zdroje a odkazy

## 9.1 Řídicí dokumentace

```text
docs/05_PROVIDERS/MM-PRV-006_PRAVNI_A_LICENCNI_RIZENI_PROVIDERU.md
docs/05_PROVIDERS/MM-PRV-007_REFERENCNI_KATALOG_PROVIDERU_TARIFU_A_POKRYTI.md
docs/05_PROVIDERS/MM-PRV-008_DATOVY_MODEL_PROVIDER_REGISTRY_A_PROVIDER_MATRIX.md
docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260722_MATCHMATRIX_DENNI_ZAPIS.md
docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
docs/13_TEMPLATES/MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md
docs/13_TEMPLATES/MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md
```

## 9.2 Použité auditní nástroje

```text
tools/documentation/25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py
tools/documentation/25_1_A_17_AUDIT_DOCUMENT_STANDARD_COMPLIANCE_V1.py
tools/documentation/25_1_A_23_REVIEW_TERMINOLOGY_CANDIDATES_V1.py
tools/documentation/25_1_A_24_IMPORT_HISTORY_DOCUMENTS_TO_DB_V1.py
tools/documentation/25_1_A_7_VERIFY_DOCUMENTATION_IMPORT_V1.py
```

## 9.3 Ověřené auditní výstupy

```text
C:\MatchMatrix-platform\reports\documentation\database_audit\
```

Klíčové soubory:

```text
provider_registry_core_audit_20260722.json
provider_code_alignment_audit_20260722.csv
provider_mapping_structure_audit_20260722.json
provider_mapping_data_audit_20260722.json
provider_mapping_usage_references_20260722.csv
handball_provider_pilot_audit_20260722.json
handball_live_runtime_binding_audit_20260722.json
all_sports_provider_runtime_snapshot_20260722.json
football_reference_state_audit_20260722.json
football_core_people_completeness_audit_20260722.json
football_core_people_table_structure_20260722.json
football_provider_temporal_coverage_audit_20260722.json
```

---

## 9.4 Ověřené databázové objekty

```text
public.data_providers
public.league_provider_map
public.team_provider_map
public.player_provider_map
public.coach_provider_map
public.canonical_provider_map
public.leagues
public.teams
public.matches
public.players
public.coaches
public.player_season_statistics
ops.global_source_registry
ops.source_registry
ops.provider_accounts
ops.provider_audit_registry
ops.provider_sport_matrix
ops.provider_entity_coverage
ops.ingest_entity_plan
ops.provider_worker_registry
staging.stg_provider_leagues
staging.stg_provider_teams
staging.stg_provider_fixtures
staging.stg_provider_players
staging.stg_provider_coaches
staging.stg_provider_player_profiles
staging.stg_provider_player_stats
staging.stg_provider_player_season_stats
staging.stg_provider_odds
```

## 9.5 Git stav

```text
Repozitář: C:\MatchMatrix-platform
Větev: main
Poslední potvrzený vzdálený commit: e81a4f5
Aktuální čistota pracovního stromu: při uzavření 2026-07-22 nebyla znovu ověřena
```

## 9.6 Stav důkazů

Všechny databázové údaje uvedené v tomto NAV vycházejí z read-only auditů ukončených příkazem `ROLLBACK`. Marketingová tvrzení providerů, aktuální ceny, tarify, limity a licence nejsou tímto NAV považovány za konečně ověřené a musí být před výběrem znovu prověřeny z aktuálních oficiálních zdrojů.

---

# 10. AI CONTEXT

Při pokračování musí AI:

1. Zachovat všechny závěry tohoto NAV.
2. Nejprve ověřit, zda byly dnešní DAILY_LOG a CHAT_CONTINUATION uloženy.
3. Pokud byly uloženy, pokračovat A17 a A23.
4. Poté připravit Git, A24 VALIDATE_ONLY, A24 APPLY a A7.
5. Nezahajovat SQL migrace dříve než bude schválen implementační plán.
6. Fotbal vést jako referenční end-to-end sport.
7. Házenou vést jako dílčí providerový pilot.
8. Vytvořit úplnou fotbalovou datovou matici.
9. Rozdělit požadavky na CORE, MATCH DETAIL, PEOPLE, STATISTICS, ODDS, MEDIA a GOVERNANCE.
10. U každé entity určit požadovanou historii a frekvenci aktualizace.
11. Pro výběr providerů použít aktuální oficiální zdroje a webový výzkum.
12. Ověřit ceny, tarify, limity, dostupné sezony a licenční podmínky.
13. Preferovat vhodné bezplatné API, free tiers, open data a oficiální zdroje.
14. Placené zdroje použít pro mezery, hluboký backfill a stabilní denní provoz.
15. Dohlédat 14. Football-Data soutěž.
16. Ověřit historický rozsah Football-Data UK.
17. Ověřit sezonu 2023 u player season stats.
18. Ověřit multi-provider mapování zápasů a odds eventů.
19. Rozlišit `api_sport`, `api_football`, `api_football_squads` a další adapterové identity.
20. Zachovat právní stav `REVIEW` nebo `HOLD` při nejistotě.
21. Panelové popisky vést česky.
22. Technické kódy ponechat dohledatelné.
23. Postupovat po jednom jasném úkonu.
24. Denní zápis a NAV poskytovat jako kompletní Markdown soubory.

---

---

# 11. PROJECT SNAPSHOT

| Oblast | Stav |
|---|---|
| Projekt | MatchMatrix-platform |
| Repo | `C:\MatchMatrix-platform` |
| Branch | `main` |
| Poslední potvrzený remote commit | `e81a4f5` |
| PC2 | hlavní DB a harvest host |
| DB | `matchmatrix` |
| PostgreSQL | 16.14 |
| Provider docs | `MM-PRV-001` až `MM-PRV-008` |
| Referenční sport | Fotbal |
| Providerový pilot | Házená |
| Sporty | 14 |
| Kanoničtí provideři | 22 |
| Dokumenty v DB | 344 |
| Verze v DB | 350 |
| Sekce v DB | 6 542 |
| Vazby v DB | 393 |
| Aktivní dokumenty | 344 |
| Dnešní DB změny | Žádné |

---

---

# 12. DATABASE SNAPSHOT

## 12.1 Provozní databáze

| Položka | Ověřený stav |
|---|---|
| Databáze | `matchmatrix` |
| Host | `localhost` na PC2 |
| PostgreSQL server | 16.14 |
| Auditní režim | `READ ONLY` |
| Ukončení auditů | `ROLLBACK` |
| Změna provozní databáze během auditů | NE |
| Schémata | `staging`, `public`, `ops`, `documentation`, `work` |

Celkový strukturální audit:

| Ukazatel | Hodnota |
|---|---:|
| Objekty | 1 115 |
| Tabulky | 283 |
| Pohledy | 596 |
| Sloupce | 12 257 |
| Constraints | 603 |
| Indexy | 856 |
| Rutiny | 95 |
| Triggery | 23 |
| Závislosti | 747 |
| Velikost | 659,66 MB |

## 12.2 Dokumentační databáze

Poslední potvrzený stav před importem dokumentů za 2026-07-22:

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 344 |
| Verze | 350 |
| Aktuální verze | 344 |
| Sekce | 6 542 |
| Vazby | 393 |
| Historie stavů | 350 |
| Aktivní dokumenty | 344 |
| Varování | 0 |
| Blokátory | 0 |

Dokumenty `MM-DL-20260722` a `MM-NAV-20260722-01` dosud nejsou importované. Po úspěšném A17, A23, schválení a Git commitu musí následovat:

```text
A24 VALIDATE_ONLY
→ A24 APPLY
→ A7
```

## 12.3 Providerový snapshot

| Oblast | Počet |
|---|---:|
| Sporty | 14 |
| Kanoničtí provideři | 22 |
| Sportovní matice | 16 |
| Detailní coverage | 107 |
| Ingest plány | 106 |
| Worker registry | 50 |
| Providerové účty | 10 |

Stavy detailní coverage:

```text
runtime_tested: 32
tech_ready: 10
planned: 57
blocked: 8
```

---

# 13. Jeden doporučený další krok

Nahradit současný soubor NAV touto opravenou verzí 1.1 a znovu spustit A17.

Po úspěšném A17 bude následovat A23, uživatelské schválení, Git commit, A24 VALIDATE_ONLY, A24 APPLY a A7.

---

# 14. Terminologická kontrola

Terminologie byla sjednocena podle aktivních pravidel MatchMatrix.

| Technický termín | Český význam v běžném textu | Použití |
|---|---|---|
| Provider | Poskytovatel dat | Technické kódy a názvy objektů zůstávají v původním tvaru. |
| Source | Zdroj | Nesmí být automaticky zaměněn s poskytovatelem dat. |
| Coverage | Datové pokrytí | Databázové pole `coverage_status` se nepřekládá. |
| Worker | Pracovní proces | Názvy skriptů a `provider_worker_registry` zůstávají beze změny. |
| Harvest | Sběr dat | Technické označení backfillu může zůstat v `backticku`. |
| Backfill | Historické doplnění dat | Používá se pro řízený hromadný historický sběr. |
| Merge | Sloučení | Přesné názvy databázových procesů se nemění. |
| Fallback | Záložní zdroj nebo postup | Technická role může být uvedena přesným kódem. |
| Runtime | Provozní stav při spuštění | Stavové kódy se zachovávají. |

Ruční kontrola musí potvrdit zejména rozdíl mezi:

```text
provider
source
organization
publisher
adapter
internal process
```

a také mezi zdroji:

```text
football_data
football_data_uk
```

Pravidlo `COMMON-TERMINOLOGY` zůstává záměrně předmětem ručního potvrzení A17.

---

# 15. Technická dohledatelnost

```text
Repo root:
C:\MatchMatrix-platform

Provider docs:
C:\MatchMatrix-platform\docs\05_PROVIDERS

Daily logs:
C:\MatchMatrix-platform\docs\09_HISTORY\DENNÍ_ZÁPISY

Chat continuation:
C:\MatchMatrix-platform\docs\09_HISTORY\NAVÁZÁNÍ_NA_CHAT

Audit outputs:
C:\MatchMatrix-platform\reports\documentation\database_audit

Active panel:
C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

---

---

# 16. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-07-22 | DRAFT – NEEDS_USER_APPROVAL | Navázání po read-only auditu providerových registrů, všech sportů a fotbalu; zachycuje multi-provider strategii, přípravu před placeným backfillem a další kroky. |

---
| 1.1 | 2026-07-23 | DRAFT – NEEDS_USER_APPROVAL | Doplněny povinné sekce Co zůstává rozpracováno, Rizika a upozornění, Ověřené zdroje a odkazy a DATABASE SNAPSHOT; zpřesněn jeden doporučený další krok a terminologická kontrola. |

---

# Závěr dokumentu

Projekt přešel od obecné providerové dokumentace k ověřování skutečného databázového stavu. Fotbal byl potvrzen jako nejpokročilejší sport a bude použit jako první kompletní end-to-end implementační vzor.

Současná data jsou složena z více zdrojů s rozdílnou rolí. API-Football free pokrývá novější historii 2022–2024 a detailnější vrstvy. Football-Data poskytuje aktuální sezony vybraných prestižních soutěží. Football-Data UK obsahuje starší historické výsledky. The Odds poskytuje současné kurzy. Hluboká historie, plné PEOPLE, historické statistiky, historické odds a úplná MEDIA vrstva vyžadují další zdroje a případně placené providery.

Další práce musí začít úplnou fotbalovou datovou maticí. Teprve potom se mají aktuálně ověřit dostupní provideři, tarify, limity, licence a technická coverage. Placený tarif se zakoupí až po dokončení celé harvest infrastruktury a potvrzení `PAID_PROVIDER_PURCHASE_READY`.
