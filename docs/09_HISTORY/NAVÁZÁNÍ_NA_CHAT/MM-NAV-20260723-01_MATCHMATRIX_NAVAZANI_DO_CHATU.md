# MatchMatrix – navázání do nového chatu – 2026-07-23

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260723-01 |
| Název dokumentu | MatchMatrix – navázání do nového chatu – 2026-07-23 |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | 1.1 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-23 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | AI kontext, fotbaloví provideři, kanonické identity soutěží, týmů a zápasů |
| Primární formát | Markdown (`.md`) |
| Kanonické umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260723-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Zdrojový denní zápis | `MM-DL-20260723_MATCHMATRIX_DENNI_ZAPIS.md` |
| Předchozí navázání | `MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Šablona | `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md` |

---

# 1. Identifikace navázání

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260723-01 |
| Datum pracovního dne | 2026-07-23 |
| Datum a čas uzavření | 2026-07-23T23:57:49+02:00 |
| Aktivní projekt | MatchMatrix-platform |
| Aktivní sport | Fotbal (`FB`) |
| Aktivní oblast | Providerová struktura fotbalu a bezpečná oprava kanonických identit |
| Zdrojový denní zápis | `MM-DL-20260723` |
| Poslední pushnutý commit | `498ad4c` |
| Databázový režim dosavadní práce | READ ONLY / REPEATABLE READ / ROLLBACK |
| Bezprostřední dokumentační krok | Uložit, auditovat, schválit a publikovat DL/NAV |
| První následný technický krok | Navrhnout providerovou identitu kanonického zápasu a rollbackovatelnou belgickou migraci |

---

# 2. Účel navázání

Tento dokument předává přesný stav po dokončení:

- A34 AI Context Package Exporteru,
- panelových ovládacích prvků A33/A34,
- ověření skutečných 13 soutěží Football-Data,
- auditu dvojích soutěžních identit Football-Data a API-Football,
- dohledání legacy importu Football-Data UK,
- odhalení chybného mapování `B1`,
- nalezení správné Jupiler Pro League,
- auditu dvojích belgických týmových identit,
- dry-runu sjednocení zápasů,
- auditu chybějící providerové identity kanonického zápasu.

Nový chat nemá opakovat uvedené read-only audity. Má navázat na potvrzená čísla a pokračovat návrhem bezpečné cílové struktury pro providerové identity zápasů.

---

# 3. Výchozí kontext

Pracovní etapa navázala na dokončený dokumentační a auditní rámec MatchMatrix, zejména na A33, A34, providerovou dokumentaci MM-PRV-001 až MM-PRV-008 a předchozí navázání `MM-NAV-20260722-01`.

Cílem etapy bylo ověřit skutečný stav fotbalových providerů, zachovat existující databázovou strukturu a přesně určit příčinu dvojích kanonických identit soutěží, týmů a zápasů.

Výchozí bezpečnostní režim práce byl:

```text
READ ONLY
REPEATABLE READ
ROLLBACK
bez destruktivních databázových změn
bez použití --allow-dirty
```

# 11. Co bylo dokončeno

V uzavřené etapě bylo dokončeno:

1. ověření, že Football-Data vrací pro používaný účet 13 soutěží;
2. potvrzení odpovídajících API-Football identit všech 13 soutěží;
3. audit dvojích kanonických identit soutěží a jejich databázových vazeb;
4. dohledání legacy importu `football_data_uk_history_pull.py`;
5. nalezení chybného mapování CSV kódu `B1` na brazilskou Série A;
6. určení správného cíle historie `B1`, kterým je Jupiler Pro League `league_id=20853`;
7. audit 25 historických a 23 API-Football belgických týmů;
8. potvrzení 21 dvojic týmových identit;
9. dry-run sjednocení 2 214 historických belgických zápasů;
10. potvrzení 1 284 unikátních historických zápasů, 927 překryvů a 3 kontrolních rozdílů;
11. audit struktury `public.matches`, jejích omezení, indexů a 18 downstream referencí;
12. potvrzení, že v aktivní veřejné vrstvě chybí samostatná providerová mapa kanonického zápasu.

# 12. Co zůstává rozpracováno

Rozpracovaná zůstává návrhová a migrační část řešení:

- návrh úzké providerové identity kanonického zápasu;
- rozhodnutí, zda vznikne `public.match_provider_map` nebo ekvivalentní objekt;
- přesná pravidla pro kanonický zápas a více providerových identit;
- rollbackovatelný plán migrace Jupiler Pro League;
- převod 21 dvojic belgických týmových identit;
- bezpečné zpracování 927 překryvných zápasů;
- migrace všech 18 skupin downstream vazeb;
- samostatné rozhodnutí tří kontrolních případů skóre;
- oprava legacy seedu `B1`;
- následné rozšíření stejné metodiky na zbývajících 12 soutěží.

Databáze zatím nebyla změněna. Další technický krok musí zůstat návrhový a read-only.

# 13. Rizika a upozornění

1. `public.matches` dnes uchovává pouze jednu dvojici `ext_source` a `ext_match_id`; bez nové nebo rozšířené providerové mapy by odstranění překryvného řádku mohlo ztratit zdrojovou provenienci.
2. Na `public.matches.id` odkazuje 18 tabulek. Přesun nebo odstranění zápasu proto vyžaduje řízenou migraci všech závislostí.
3. Chybný seed `B1` nesmí být znovu spuštěn v původní podobě.
4. Čtyři historické belgické kluby bez potvrzeného API protějšku se nesmí automaticky slučovat ani mazat.
5. Dva případy obsahují skutečný rozdíl skóre a jeden případ neúplné skóre; automatický přepis je zakázán.
6. Současná dvojí `league_id` a `team_id` nesmějí být hromadně odstraněna bez validačního a rollback plánu.
7. A24 vyžaduje čistý Git pracovní strom. Po opravě dokumentů musí následovat A17, A23, schválení, Git commit a push; teprve potom A24 `VALIDATE_ONLY`.
8. Nepoužívat `--allow-dirty` a nevypisovat tokeny, hesla ani obsah `.env`.

# 14. AI CONTEXT

AI má při pokračování vycházet z těchto závazných pravidel:

```text
- neopakovat již uzavřené read-only audity;
- zachovat současná schémata a hlavní tabulkovou strukturu;
- řešit kanonické identity a providerové vazby;
- postupovat vždy po jednom jasném kroku;
- nejprve návrh a validace, potom teprve změna databáze;
- žádné destruktivní SQL bez schváleného rollback plánu;
- API-Football může být hlavní detailní provider;
- Football-Data zůstává aktuálním CORE, fallbackem a validací;
- Football-Data UK zůstává historickým zdrojem;
- skórové konflikty ponechat ve stavu REVIEW;
- zachovat čtyři historické belgické kluby bez API protějšku;
- nepoužívat --allow-dirty.
```

Bezprostředním výstupem další etapy má být:

```text
MATCH PROVIDER IDENTITY – TARGET DESIGN
+
BELGIUM MIGRATION PLAN – VALIDATE ONLY
```

# 15. PROJECT SNAPSHOT

```text
Projekt             : MatchMatrix-platform
Repozitář           : C:\MatchMatrix-platform
Větev                : main
Poslední push commit : 498ad4c
PC1                  : ovládací pracoviště
PC2                  : 192.168.3.119
Aktivní sport        : Fotbal (FB)
Aktivní panel        : tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
A33                  : 25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py
A34                  : 25_1_A_34_EXPORT_AI_CONTEXT_PACKAGE_V1.py
A34 package ID       : 20260723_202723_MATCHMATRIX_AI_CONTEXT_PACKAGE
A34 files            : 23
A34 warnings         : 0
```

Dokumentační etapa je věcně dokončena. Před databázovým importem DL/NAV zbývá opravit A17 nálezy, provést A23, dokumenty schválit a publikovat do Git.

# 16. DATABASE SNAPSHOT

## 9.1 Dokumentační databáze

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 350 |
| Verze celkem | 356 |
| Aktuální verze | 350 |
| Sekce | 6 900 |
| Vazby | 471 |
| Historie stavů | 356 |
| Importní běhy | 44 |
| Aktivní dokumenty | 350 |

## 9.2 Hlavní technický stav

```text
Databáze             : matchmatrix
PostgreSQL           : 16.14
Schémata A33         : staging, public, ops, documentation, work
Režim auditu         : READ ONLY / REPEATABLE READ / ROLLBACK
public.matches       : jedna aktivní providerová identita na řádek
Reference na matches : 18 tabulek
```

## 9.3 Belgický pilot

| Ukazatel | Hodnota |
|---|---:|
| Chybně umístěné řádky `football_data_uk` pod `league_id=4` | 2 214 |
| Existující API-Football zápasy Jupiler Pro League `20853` | 960 |
| Unikátní historie k zachování | 1 284 |
| Překryvy se stejným skóre | 927 |
| Kontrolní rozdíly | 3 |
| Předpokládaný kanonický počet zápasů | 2 244 |

---

# 17. CURRENT STATUS

## 10.1 Git

```text
Repozitář           : C:\MatchMatrix-platform
Větev                : main
Poslední push commit : 498ad4c
Popis                : Add paged documentation workspace and A34 controls
Pracovní strom       : po dokončení A34 potvrzen jako čistý
```

Nové soubory `MM-DL-20260723` a `MM-NAV-20260723-01` ještě nejsou uložené v repozitáři.

## 10.2 Dokumentační databáze

| Ukazatel | Hodnota |
|---|---:|
| Dokumenty | 350 |
| Verze celkem | 356 |
| Aktuální verze | 350 |
| Sekce | 6 900 |
| Vazby | 471 |
| Historie stavů | 356 |
| Importní běhy | 44 |
| Aktivní dokumenty | 350 |

## 10.3 Aktivní technické prostředí

```text
PC1                : ovládací pracoviště
PC2                : 192.168.3.119
Repo root          : C:\MatchMatrix-platform
Databáze           : matchmatrix
DB host pro skripty: localhost na PC2
PostgreSQL server  : 16.14
Aktivní panel      : tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

## 10.4 A34

```text
Aktivní soubor : tools\documentation\25_1_A_34_EXPORT_AI_CONTEXT_PACKAGE_V1.py
Engine         : A34_AI_CONTEXT_PACKAGE_V1_3
Poslední stav  : AI_CONTEXT_PACKAGE_CREATED
Package ID     : 20260723_202723_MATCHMATRIX_AI_CONTEXT_PACKAGE
Files          : 23
Warnings       : 0
Sport          : FB
```

A34 vyžaduje čistý Git pracovní strom. Nepoužívat ani nedoplňovat `--allow-dirty`.

---

# 11. Potvrzený providerový stav fotbalu

## 11.1 Football-Data má 13 soutěží

Skutečný poslední RAW payload `/competitions` obsahuje:

```text
BSA, ELC, PL, CL, EC, FL1, BL1, SA, DED, PPL, CLI, PD, WC
```

Předpoklad 14 soutěží byl zrušen.

## 11.2 Role providerů

```text
API-Football
→ detailní historie 2022–2024
→ hráči, trenéři, statistiky a další detailní entity
→ kandidát na hlavní detailní zdroj

Football-Data
→ aktuální sezona 2025/26 a turnaje 2026
→ CORE data
→ fallback a validační zdroj

Football-Data UK
→ historické výsledky převážně 2018/19–2024/25
```

Struktura providerů se zachovává. Neprovádět plošný rebuild.

---

# 12. Dvojí identity 13 soutěží

| Soutěž | Football-Data `league_id` | API-Football `league_id` | API-Football ID |
|---|---:|---:|---:|
| Campeonato Brasileiro Série A | 4 | 20854 | 71 |
| Championship | 5 | 20871 | 40 |
| Premier League | 6 | 20855 | 39 |
| UEFA Champions League | 7 | 20969 | 2 |
| European Championship | 8 | 20848 | 4 |
| Ligue 1 | 26 | 20852 | 61 |
| Bundesliga | 27 | 20856 | 78 |
| Serie A | 28 | 20857 | 135 |
| Eredivisie | 29 | 20849 | 88 |
| Primeira Liga | 30 | 20858 | 94 |
| Copa Libertadores | 31 | 21450 | 13 |
| Primera Division / La Liga | 32 | 20859 | 140 |
| FIFA World Cup | 33 | 20862 | 1 |

Platí:

```text
13 reálných soutěží
→ 26 oddělených řádků public.leagues
```

Nízké identity nesou více produktových, historických a aktuálních CORE vazeb. Vysoké identity nesou více API-Football detailů a statistik. Konečnou kanonickou identitu nelze určovat pouze podle počtu zápasů.

---

# 13. Přesně potvrzená chyba `B1`

Legacy import:

```text
legacy\ingest\football_data_uk_history_pull.py
```

načítal všechny soutěže s `ext_csv_code IS NOT NULL`.

Seed chybně obsahoval:

```sql
update leagues
set ext_csv_code='B1'
where name='Campeonato Brasileiro Série A';
```

Výsledek pod `league_id=4`:

```text
football_data    : 380 správných brazilských zápasů pro sezonu 2026
football_data_uk : 2214 belgických historických zápasů
```

Správný cíl belgické historie:

```text
LEAGUE_ID          : 20853
NAME               : Jupiler Pro League
COUNTRY            : Belgium
API-FOOTBALL ID    : 144
EXISTING API ROWS  : 960
```

---

# 14. Belgické týmové identity

## 14.1 Potvrzených 21 dvojic

| Klub | Historické `team_id` | API-Football `team_id` |
|---|---:|---:|
| Anderlecht | 972 | 12940 |
| Antwerp | 964 | 13172 |
| Beerschot VA | 980 | 12515 |
| Cercle Brugge | 967 | 12844 |
| Charleroi | 975 | 13032 |
| Club Brugge | 976 | 12803 |
| Dender | 966 | 12665 |
| Eupen | 982 | 13516 |
| Genk | 977 | 12254 |
| Gent | 979 | 12719 |
| Kortrijk | 981 | 13043 |
| Mechelen | 969 | 12517 |
| Oostende | 985 | 15765 |
| OH Leuven | 974 | 12636 |
| RWD Molenbeek | 983 | 13328 |
| Seraing | 984 | 12565 |
| Standard Liège | 971 | 13537 |
| Union St. Gilloise | 965 | 13160 |
| St. Truiden | 978 | 12277 |
| Zulte Waregem | 968 | 12993 |
| Westerlo | 973 | 13279 |

Cílovými kanonickými identitami mají být pracovními kandidáty API-Football `team_id`, protože nesou aktuální providerovou identitu, hráče a sezonní statistiky. Převod však musí zahrnout všechny cizí klíče a providerové mapy.

## 14.2 Historické týmy bez potvrzeného API protějšku

```text
TEAM_ID=970  RAAL La Louviere
TEAM_ID=986  Mouscron
TEAM_ID=987  Waasland-Beveren
TEAM_ID=988  Lokeren
```

Tyto identity zachovat. Nemazat je pouze proto, že nejsou v aktuálních sezonách API-Football.

---

# 15. Výsledek belgického dry-runu

Simulováno:

```text
league_id 4 → 20853
21 historických team_id → API-Football team_id
```

| Metrika | Počet |
|---|---:|
| Zdrojové `football_data_uk` řádky | 2 214 |
| Existující API-Football řádky | 960 |
| Unikátní historické zápasy k zachování | 1 284 |
| Překryv se stejným skóre | 927 |
| Kontrolní rozdíly výsledku | 3 |
| Duplicitní zdrojové řádky navíc | 0 |
| Neplatný stejný tým proti sobě | 0 |
| Předpokládaný kanonický počet zápasů | 2 244 |

Pokrytí týmů:

```text
OBĚ STRANY NAMAPOVANÉ   : 1983
JEDNA STRANA NAMAPOVANÁ : 221
ŽÁDNÁ STRANA NAMAPOVANÁ : 10
```

---

# 16. Kontrolní případy skóre

| Datum | Zápas | Football-Data UK | API-Football | Zacházení |
|---|---|---:|---:|---|
| 2022-10-23 | Standard Liège – Anderlecht | 5:0 | NULL:NULL | doplnění chybějícího skóre až po kontrole |
| 2022-11-12 | Charleroi – KV Mechelen | 0:5 | 1:0 | `REVIEW`, bez automatického přepisu |
| 2024-09-29 | Antwerp – Beerschot VA | 5:0 | 4:0 | `REVIEW`, bez automatického přepisu |

---

# 17. Kritické zjištění o zápasové identitě

`public.matches` obsahuje pouze:

```text
ext_source
ext_match_id
```

Neexistuje potvrzená tabulka typu:

```text
canonical_match_id
provider
provider_match_id
```

`staging.stg_provider_fixtures` uchovává providerové ID ve staging vrstvě, ale po kanonickém sloučení není v `public` potvrzen mechanismus pro více providerových identit jednoho zápasu.

Na `public.matches.id` odkazuje 18 tabulek:

```text
article_match_map
generated_ticket_fixed
lineups
match_events
match_features
match_officials
match_weather
ml_predictions
mm_ticket_scenario_block_matches
odds
player_match_statistics
selection_items
team_match_statistics
template_block_matches
template_fixed_picks
ticket_block_matches
ticket_constants
ticket_variant_matches
```

Proto nesmí být překryvné zápasy jednoduše smazány bez migrace všech závislostí a zachování providerové provenience.

---

# 18. Závazná rozhodnutí pro nový chat

1. Zachovat současná schémata a hlavní tabulkovou strukturu.
2. Opravovat kanonické identity a providerové mapování, ne stavět paralelní databázi.
3. API-Football může být hlavní detailní provider, aniž by se automaticky vybrala jeho současná `league_id`.
4. Football-Data zůstává aktuálním CORE, fallbackem a validačním zdrojem.
5. Football-Data UK zůstává historickým zdrojem.
6. Chybný `B1` nesmí znovu směřovat na brazilskou Série A.
7. Žádné mazání soutěží, týmů nebo zápasů před schválenou migrací.
8. Skórové konflikty neposuzovat automaticky.
9. Zachovat 4 historické belgické kluby bez API protějšku.
10. Postupovat po jednom jasném technickém kroku.
11. Nevypisovat hesla, tokeny ani hodnoty `.env`.
12. Nepoužívat `--allow-dirty`.

---

# 19. Co se nemá opakovat

Nový chat nemá znovu provádět:

- zjištění počtu Football-Data soutěží,
- audit 13 dvojic soutěží,
- hledání legacy Football-Data UK skriptu,
- hledání příčiny `B1`,
- hledání Jupiler Pro League `20853`,
- audit 21 belgických týmových dvojic,
- dry-run 2 214 historických zápasů,
- audit sloupců a constraints `public.matches`,
- zjištění 18 referencí na zápasy.

Tyto výsledky jsou uzavřené jako read-only zjištění.

---

# 20. Otevřené otázky

1. Má vzniknout úzká tabulka `public.match_provider_map`?
2. Jaké mají být její unikátní klíče, auditní sloupce a pravidla aktualizace?
3. Jak převést providerové identity 927 překryvných zápasů bez ztráty zdrojové informace?
4. Jak migrovat 18 skupin downstream vazeb na vybraný kanonický zápas?
5. Jaký zápas ponechat jako kanonický při konfliktu nebo neúplném skóre?
6. Jak opravit a governance označit legacy seed `B1`?
7. Jak následně aplikovat stejnou metodiku na zbývajících 12 soutěží?

---

# 21. Jediný hlavní další krok

Po uložení a publikování tohoto NAV:

```text
Navrhnout cílovou providerovou identitu kanonického zápasu
a přesný rollbackovatelný migrační plán pro Jupiler Pro League.
```

První krok musí být pouze návrhový a read-only. Databáze se v tomto kroku nemění.

Doporučený výstup příštího kroku:

```text
MATCH PROVIDER IDENTITY – TARGET DESIGN
+
BELGIUM MIGRATION PLAN – VALIDATE ONLY
```

---

# 22. Doporučené pořadí pokračování

```text
1. uložit MM-DL-20260723 a MM-NAV-20260723-01
2. A17
3. A23
4. schválení
5. Git commit a push
6. A24 VALIDATE_ONLY
7. A24 APPLY
8. A7
9. návrh match provider identity
10. audit všech downstream referencí
11. belgický migrační dry-run
12. samostatné rozhodnutí tří skórových případů
13. oprava B1 seedu
14. schválená migrace Belgie
15. post-migration audit a rollback check
16. rozšíření metodiky na dalších 12 soutěží
```

---

# 23. Důležité cesty a soubory

```text
Repo:
C:\MatchMatrix-platform

Aktivní panel:
C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py

A33:
C:\MatchMatrix-platform\tools\documentation\25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py

A34:
C:\MatchMatrix-platform\tools\documentation\25_1_A_34_EXPORT_AI_CONTEXT_PACKAGE_V1.py

Football-Data:
C:\MatchMatrix-platform\ingest\Football-Data\football_data_pull_V6.py

Legacy Football-Data UK:
C:\MatchMatrix-platform\legacy\ingest\football_data_uk_history_pull.py

Chybný seed:
MatchMatrix-platform\Scripts\00_Schema\020_generated_runs_add_bookmaker_id.sql\029_leagues_set_csv_codes.sql

Denní zápisy:
C:\MatchMatrix-platform\docs\09_HISTORY\DENNÍ_ZÁPISY\

NAV:
C:\MatchMatrix-platform\docs\09_HISTORY\NAVÁZÁNÍ_NA_CHAT\
```

---

# 24. Bezpečnostní a pracovní pravidla

```text
- vždy pouze jeden příkaz nebo jeden jasný úkon,
- nejprve read-only audit,
- žádné destruktivní SQL bez schváleného migračního plánu,
- žádné tokeny, hesla nebo API klíče ve výstupech,
- SQL posílat jako text do chatu,
- opravené Python skripty dodávat jako celý aktivní soubor,
- původní verze uživatel ukládá do tools/histori/,
- aktivní nástroje mají název končící _V1,
- Git musí být před A34 čistý,
- nedoplňovat --allow-dirty.
```

---

# 25. Vazby

| Vazba | Dokument nebo výstup |
|---|---|
| Zdrojový denní zápis | `MM-DL-20260723_MATCHMATRIX_DENNI_ZAPIS.md` |
| Předchozí NAV | `MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Providerový cílový model | `MM-PRV-008_DATOVY_MODEL_PROVIDER_REGISTRY_A_PROVIDER_MATRIX.md` |
| Budoucí implementační plán | `MM-PRV-009_IMPLEMENTACNI_PLAN_PROVIDER_REGISTRY_A_PROVIDER_MATRIX.md` |
| AI standard | `MM-STD-009_AI_CONTEXT_A_PROJECT_SNAPSHOT.md` |
| Šablona NAV | `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md` |
| Šablona denního zápisu | `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md` |

---

# 26. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-07-23 | DRAFT – NEEDS_USER_APPROVAL | Navázání po dokončení A34 a panelu, potvrzení 13 soutěží, auditu dvojích fotbalových identit, chyby `B1`, belgického dry-runu a chybějící veřejné providerové mapy zápasů. |
| 1.1 | 2026-07-23 | DRAFT – NEEDS_USER_APPROVAL | Strukturální oprava podle A17: doplněny samostatné sekce Výchozí kontext, Co bylo dokončeno, Co zůstává rozpracováno, Rizika a upozornění, AI CONTEXT, PROJECT SNAPSHOT a DATABASE SNAPSHOT. |

---

# Závěr dokumentu

Projekt má nyní přesně doložený první konkrétní případ strukturálního sjednocení providerových dat.

Stávající databázová architektura se zachovává. Opravovat se budou chybné kanonické identity a providerové vazby. Belgická Jupiler Pro League je referenčním pilotem: 2 214 historických zápasů bylo chybně vedeno pod brazilskou Série A, ale dry-run potvrdil možnost zachovat 1 284 unikátních zápasů a rozpoznat 927 překryvů.

Před migrací je nutné vyřešit providerovou identitu kanonického zápasu a bezpečný převod 18 skupin downstream vazeb. Do té doby se databáze nemění.
