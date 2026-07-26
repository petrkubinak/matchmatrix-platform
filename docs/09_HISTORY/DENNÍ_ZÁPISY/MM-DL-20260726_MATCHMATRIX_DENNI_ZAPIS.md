# MatchMatrix – denní zápis – 2026-07-26

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-DL-20260726 |
| Název dokumentu | MatchMatrix – denní zápis – 2026-07-26 |
| Typ dokumentu | DAILY_LOG |
| Verze | 1.0 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-26 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | Fotbal, kanonické zápasy, providerové identity a řízené sloučení belgické historie |
| Primární formát | Markdown (`.md`) |
| Kanonické umístění | `docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260726_MATCHMATRIX_DENNI_ZAPIS.md` |
| Navazující dokument | `MM-NAV-20260726-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Předchozí známý denní zápis | `MM-DL-20260723_MATCHMATRIX_DENNI_ZAPIS.md` |
| Šablona | `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md` |

---

# 1. Identifikace denního zápisu

| Položka | Hodnota |
|---|---|
| Document ID | MM-DL-20260726 |
| Datum pracovního dne | 2026-07-26 |
| Datum a čas uzavření | 2026-07-26T21:31:13+02:00 |
| Aktivní projekt | MatchMatrix-platform |
| Aktivní sport | Fotbal (`FB`) |
| Aktivní oblast | Belgická Jupiler Pro League – kanonické zápasy a víceproviderová identita |
| Databáze | PostgreSQL `matchmatrix` |
| Hlavní tabulka | `public.matches` |
| Nová providerová mapa | `public.match_provider_map` |
| Bezpečnostní režim | `REPEATABLE READ`, nejprve `VALIDATE ONLY` s `ROLLBACK`, následně řízené `APPLY` |
| Konečný stav dne | Belgická sada 930 překryvných zápasů je sloučena, tři konfliktní případy jsou ověřeny a závěrečný audit je `OK` |
| Bezprostřední další technický cíl | Read-only audit 1 284 unikátních historických belgických zápasů před jejich přesunem na správné kanonické soutěžní a týmové identity |

---

# 2. Výchozí stav

Pracovní etapa navázala na předchozí audit historických belgických dat z provideru `football_data_uk` a aktuálnějších zápasů provideru `api_football`.

Před zahájením dne bylo potvrzeno:

- historická data Jupiler Pro League byla kvůli chybnému legacy mapování CSV kódu `B1` vedena pod nesprávným `league_id=4`,
- správná kanonická Jupiler Pro League používá `league_id=20853`,
- historický zdroj obsahoval 2 214 zápasů,
- API-Football obsahoval 960 zápasů stejné soutěže,
- bylo potvrzeno 21 dvojic historických a API týmových identit,
- 927 historických zápasů mělo bezpečný protějšek se stejným skóre,
- 1 284 historických zápasů bylo unikátních,
- tři případy vyžadovaly ruční rozhodnutí,
- tabulka `public.matches` nedokázala sama uchovat více externích identit jednoho kanonického zápasu.

Cílem dne nebylo pouze odstranit duplicity. Cílem bylo zachovat úplnou zdrojovou provenienci, přenést všechny downstream vazby, provést každou destruktivní změnu nejprve v rollbackovaném režimu a po dokončení získat jednoznačný závěrečný audit.

---

# 3. Cíle pracovního dne

1. Dokončit a ověřit víceproviderovou identitu zápasu v `public.match_provider_map`.
2. Přenést 927 bezpečných překryvů na API kanonické zápasy bez ztráty historické identity.
3. Převést související `match_features` a `mm_match_ratings`.
4. Odstranit historické duplicitní řádky až po kontrole všech FK a měkkých vazeb.
5. Jednotlivě vyřešit tři belgické případy s neúplným nebo rozdílným skóre.
6. Zachovat v metadatech rozdíl mezi výsledkem na hřišti a oficiálním disciplinárním výsledkem.
7. Ověřit nulový počet osiřelých providerových identit a feature vazeb.
8. Potvrdit, že počet existujících globálních osiřelých ratingů nebyl migrací změněn.
9. Uzavřít belgickou migrační sadu závěrečným read-only auditem.
10. Připravit přesné navázání pro další pracovní chat.

---

# 4. Provedené práce

## 4.1 Potvrzení cílové architektury kanonického zápasu

Bylo potvrzeno architektonické pravidlo:

```text
public.matches = jeden kanonický řádek zápasu
public.match_provider_map = jedna nebo více externích identit tohoto zápasu
```

Stávající sloupce `public.matches.ext_source` a `public.matches.ext_match_id` byly dočasně zachovány kvůli kompatibilitě. Nová tabulka `public.match_provider_map` převzala roli dlouhodobé víceproviderové identity.

Zásadní pravidlo:

```text
jeden kanonický zápas může mít více aktivních providerových identit,
ale pouze jednu aktivní primární identitu
```

Nebyla použita starší tabulka `public.canonical_provider_map`, protože obsahuje duplicitní klíčové skupiny a byla dříve klasifikována pouze jako prototyp vyžadující samostatný review.

## 4.2 Stav `public.match_provider_map`

Tabulka obsahuje 17 sloupců:

```text
id
match_id
provider
provider_match_id
identity_origin
external_id_kind
mapping_status
is_primary
confidence_score
source_record_hash
first_seen_at
last_seen_at
metadata
created_at
updated_at
created_by
updated_by
```

Ověřené vlastnosti:

- unikátní externí identita `(provider, provider_match_id)`,
- nejvýše jedna aktivní primární identita na kanonický zápas,
- FK na `public.matches(id)`,
- auditní metadata a uživatelské stopy,
- podpora sekundárních zdrojových identit,
- uchování původu migrace a možnosti reverzního dohledání.

Výchozí backfill vytvořil:

| Ukazatel | Hodnota |
|---|---:|
| Kompletní identity převzaté z `public.matches` | 121 908 |
| Řádky v `public.match_provider_map` | 121 908 |
| Zápasy s providerovou identitou před slučováním | 121 908 |
| Neúplné ruční testovací zápasy bez identity | 3 |
| Duplicitní providerové identity | 0 |

Tři záměrně nezmapované řádky jsou `public.matches.id IN (1, 2, 3)`.

## 4.3 Providerové rozložení backfillu

| Provider | Počet identit |
|---|---:|
| `api_football` | 77 435 |
| `football_data_uk` | 23 118 |
| `api_handball` | 9 275 |
| `football_data` | 3 739 |
| `api_baseball` | 2 945 |
| `api_hockey` | 2 430 |
| `api_sport` | 2 325 |
| `api_american_football` | 335 |
| `api_volleyball` | 178 |
| `api_tennis` | 69 |
| `api_cricket` | 44 |
| `api_rugby` | 15 |

Backfill zachoval všechny kompletní identity a nevytvořil žádnou osiřelou vazbu.

## 4.4 Klasifikace belgické historie

Vstupní sada:

| Oblast | Počet |
|---|---:|
| Historické zápasy `football_data_uk` | 2 214 |
| API-Football zápasy cílové soutěže | 960 |
| Potvrzené týmové dvojice | 21 |

Klasifikace:

| Třída | Počet |
|---|---:|
| `UNIQUE_HISTORY` | 1 284 |
| `OVERLAP_SAME_SCORE` | 927 |
| `REVIEW_INCOMPLETE_SCORE` | 1 |
| `REVIEW_SCORE_CONFLICT` | 2 |
| Ambiguous | 0 |

Tato klasifikace umožnila oddělit bezpečně slučitelné překryvy od tří případů vyžadujících individuální kontrolu.

## 4.5 Přenos 927 bezpečných providerových identit

U 927 překryvů se stejným skóre byla historická identita `football_data_uk` přesunuta z původního historického řádku na existující kanonický zápas API-Football.

Po převodu měl každý cílový zápas:

- jednu primární identitu `api_football`,
- jednu sekundární identitu `football_data_uk`,
- dvě dohledatelné externí identity,
- zachovaná metadata původu.

Provenienční značka:

```text
belgium_identity_transfer = BELGIUM_JPL_MATCH_IDENTITY_TRANSFER_V1
```

Bylo ověřeno:

```text
927 cílových zápasů
927 sekundárních historických identit
927 aktivních primárních API identit
0 duplicit externího klíče
0 osiřelých providerových identit
```

## 4.6 Přenos downstream dat 927 překryvů

Byly převedeny dvě aktivně naplněné downstream oblasti:

| Tabulka | Přenesené řádky |
|---|---:|
| `public.match_features` | 927 |
| `public.mm_match_ratings` | 927 |

U `public.mm_match_ratings` byly současně sjednoceny dimenze:

```text
match_id
league_id
kickoff
home_team_id
away_team_id
```

Výpočtové metriky ratingu nebyly změněny.

Byla zachována explicitní UTC konverze, protože:

```text
public.matches.kickoff          = timestamp without time zone
public.mm_match_ratings.kickoff = timestamp with time zone
```

Použitý princip:

```sql
target.kickoff::timestamp AT TIME ZONE 'UTC'
```

## 4.7 Odstranění 927 historických duplicit

Po úspěšném `VALIDATE ONLY` a kontrole FK vazeb byly původní historické duplicitní zápasy odstraněny v řízeném `APPLY` režimu.

Po tomto kroku:

| Ukazatel | Hodnota |
|---|---:|
| Odstraněné bezpečné duplicity | 927 |
| Původní duplicitní zápasy zbývající | 0 |
| Kanonické cílové zápasy | 927 |
| Belgická historie zbývající před ručními případy | 1 287 |
| Unikátní historie | 1 284 |
| Případy k revizi | 3 |

Počet FK řádků v ostatních tabulkách zůstal nezměněn a kontrola `CASCADE` neodhalila nečekané ztráty.

## 4.8 Ruční případ 1 – Standard Liège × Anderlecht

### Identifikace

| Položka | Historický řádek | Kanonický cíl |
|---|---:|---:|
| `match_id` | 7545 | 344386 |
| Provider | `football_data_uk` | `api_football` |
| Výsledek ve zdroji | 5:0 | skóre `NULL`, status `CANCELLED` |
| Datum | 2022-10-23 | 2022-10-23 |

Bylo potvrzeno, že zápas byl na hřišti přerušen při skóre 3:1 a následně byl disciplinárně uzavřen oficiálním výsledkem 5:0 pro Standard Liège.

Kanonické řešení:

```text
match_id               = 344386
home_score             = 5
away_score             = 0
status                 = FINISHED
primary identity       = api_football
secondary identity     = football_data_uk
resolution_code        = DISCIPLINARY_FORFEIT_5_0
on-field score         = 3-1
```

Převedeno:

- 1 řádek `match_features`,
- 1 řádek `mm_match_ratings`,
- 1 historická providerová identita.

Historický zápas `7545` byl po validaci odstraněn.

## 4.9 Oprava auditního SQL

Při auditu druhého případu se objevila chyba:

```text
ERROR: column match.created_at does not exist
Hint: Perhaps you meant to reference the column match.updated_at.
```

Příčina:

```text
public.matches neobsahuje sloupec created_at
```

Řešení:

- transakce byla bezpečně ukončena,
- neexistující sloupec byl z auditního `SELECT` odstraněn,
- audit byl spuštěn znovu,
- nedošlo k žádné produkční změně.

Opakované hlášky:

```text
there is no transaction in progress
there is already a transaction in progress
```

byly vyhodnoceny jako informační důsledek bezpečnostního úvodního `ROLLBACK;` nebo opakovaného `BEGIN` v jedné relaci. Neměly vliv na data ani na úspěšnost kontrol.

## 4.10 Ruční případ 2 – Charleroi × KV Mechelen

### Auditní stav

| Položka | Historický řádek | Kanonický cíl |
|---|---:|---:|
| `match_id` | 7569 | 344421 |
| Provider | `football_data_uk` | `api_football` |
| Skóre | 0:5 | 1:0 |
| Stav | `FINISHED` | `FINISHED` |
| Datum | 2022-11-12 | 2022-11-12 |

Dohledaný význam rozdílu:

- 1:0 byl stav na hřišti při přerušení,
- oficiální disciplinární výsledek je 0:5 pro KV Mechelen,
- rozhodnutí bylo spojeno s belgickým sportovním arbitrážním řízením.

Kanonické řešení:

```text
match_id               = 344421
home_score             = 0
away_score             = 5
status                 = FINISHED
primary identity       = api_football
secondary identity     = football_data_uk
resolution_code        = CBAS_FORFEIT_0_5
on-field score         = 1-0
```

### Validace

`VALIDATE ONLY` potvrdil:

- dvě identity po sloučení,
- jednu aktivní primární identitu,
- převod 1 `match_features`,
- převod a rozměrové sjednocení 1 `mm_match_ratings`,
- nulové zbývající FK a měkké vazby,
- odstranění historické duplicity pouze uvnitř rollbackované transakce,
- návrat původního stavu přes `ROLLBACK_OK`.

### Trvalý APPLY

Konečný stav:

```text
APPLY_OK – REVIEW CASE 2 TRVALE SLOUČEN
```

Počet `public.matches` po druhém případu:

```text
120 982
```

## 4.11 Ruční případ 3 – Antwerp × Beerschot

### Auditní stav

| Položka | Historický řádek | Kanonický cíl |
|---|---:|---:|
| `match_id` | 6865 | 317481 |
| Provider | `football_data_uk` | `api_football` |
| Skóre | 5:0 | 4:0 |
| Stav | `FINISHED` | `FINISHED` |
| Datum | 2024-09-29 | 2024-09-29 |

Bylo potvrzeno:

- 4:0 byl stav při přerušení zápasu,
- oficiální disciplinární výsledek je 5:0 pro Royal Antwerp,
- oficiální statistiky odehrané části utkání zůstaly zachovány.

Kanonické řešení:

```text
match_id               = 317481
home_score             = 5
away_score             = 0
status                 = FINISHED
primary identity       = api_football
secondary identity     = football_data_uk
resolution_code        = KBVB_FORFEIT_5_0
on-field score         = 4-0
official statistics    = retained
```

### Validace

`VALIDATE ONLY` prošel bez odchylky:

```text
HISTORICAL_MATCH_REMAINING              0
CANONICAL_MATCH_OFFICIAL_RESULT         5:0 / FINISHED
CANONICAL_PROVIDER_IDENTITIES            2
CANONICAL_ACTIVE_PRIMARY_IDENTITIES      1
CANONICAL_MATCH_FEATURES                 1
CANONICAL_MATCH_RATINGS                  1
REVIEW_CASES_REMAINING                   0
```

Rollback potvrdil úplné obnovení původního stavu před trvalým zápisem.

### Trvalý APPLY

Konečný stav:

```text
APPLY_OK – REVIEW CASE 3 TRVALE SLOUČEN; BELGICKÉ REVIEW PŘÍPADY UZAVŘENY
```

Počet `public.matches` po dokončení:

```text
120 981
```

## 4.12 Závěrečný read-only audit belgické migrace

Po všech trvalých změnách byl spuštěn samostatný audit:

```text
READ ONLY
REPEATABLE READ
UTC
ROLLBACK
```

Výsledek:

```text
BELGIUM_MIGRATION_FINAL_AUDIT_OK – 930 SLOUČENÍ UZAVŘENO, 1284 UNIKÁTNÍCH HISTORICKÝCH ZÁPASŮ ZACHOVÁNO
```

Kontrolní počty:

| Kontrola | Výsledek |
|---|---:|
| `public.matches` celkem | 120 981 |
| Zbývající unikátní belgická historie | 1 284 |
| Belgické API-Football zápasy | 960 |
| Vyřešené dvojice celkem | 930 |
| Unikátní původní ID | 930 |
| Unikátní cílová ID | 930 |
| Původní sloučené zápasy zbývající | 0 |
| Cílové kanonické zápasy zbývající | 930 |
| Řádky `match_provider_map` | 121 908 |
| Zápasy s providerovou identitou | 120 978 |
| Aktivní primární identity | 120 978 |
| Osiřelé providerové identity | 0 |
| Cíle se dvěma správnými identitami | 930 |
| Převedené `match_features` | 930 |
| Převedené `mm_match_ratings` | 930 |
| Rozměrově sjednocené ratingy | 930 |
| Osiřelé `match_features` | 0 |
| Globální osiřelé `mm_match_ratings` | 78 794 |
| Ručně ověřené výsledky | 3 |
| Historické ruční případy zbývající | 0 |
| Nezmapované zápasy | 3 |
| Očekávané ruční nezmapované zápasy `1,2,3` | 3 |

Globálních 78 794 osiřelých řádků `public.mm_match_ratings` existovalo již před belgickou migrací. Migrace jejich počet nezvýšila ani nesnížila.

---

# 5. Hlavní výsledky dne

1. Vznikla a byla prakticky ověřena víceproviderová identita kanonického zápasu.
2. Bylo bezpečně sloučeno 927 překryvů se stejným skóre.
3. Byly samostatně ověřeny a sloučeny tři disciplinární případy.
4. Celkem bylo uzavřeno 930 dvojic historický zápas × API kanonický zápas.
5. Všech 930 cílových zápasů má jednu API a jednu historickou identitu.
6. U všech 930 cílů zůstává právě jedna aktivní primární identita.
7. Bylo převedeno 930 feature řádků a 930 ratingových řádků.
8. Všechny převedené ratingy byly rozměrově sjednoceny s kanonickým zápasem.
9. Nebyla vytvořena žádná osiřelá providerová identita ani feature vazba.
10. Bylo zachováno 1 284 unikátních historických zápasů bez API protějšku.
11. Belgické review případy byly sníženy z 3 na 0.
12. Finální počet `public.matches` je 120 981.

---

# 6. Přijatá rozhodnutí

## 6.1 Kanonická identita zápasu

```text
public.matches zůstává kanonickým masterem zápasu
```

Externí identity se ukládají odděleně v `public.match_provider_map`.

## 6.2 Primární a sekundární provider

Pro uzavřených 930 belgických překryvů platí:

```text
api_football     = primární aktivní identita
football_data_uk = sekundární historická identita
```

Toto rozhodnutí neznamená, že historický zdroj je méně důležitý. Znamená pouze, že detailnější API řádek zůstává kanonickým technickým nosičem zápasu.

## 6.3 Disciplinární výsledky

Kanonické skóre musí odpovídat konečnému oficiálnímu výsledku soutěže nebo disciplinárního řízení. Skóre při přerušení se nesmí ztratit a ukládá se do providerových metadat jako provenience.

## 6.4 Bezpečnostní workflow

Každá změna typu merge/delete musí projít pořadím:

```text
AUDIT
→ VALIDATE ONLY
→ ROLLBACK_OK
→ APPLY
→ POST-COMMIT AUDIT
```

## 6.5 Globální ratingové orphan řádky

78 794 osiřelých řádků `public.mm_match_ratings` se nebude řešit jako součást belgické migrace. Jde o samostatný globální problém vyžadující vlastní audit a rozhodnutí.

## 6.6 Zachování unikátní historie

1 284 historických zápasů bez API protějšku se nesmí odstranit. Musí být zachovány a později řízeně převedeny na správnou soutěžní a týmovou kanonickou identitu.

---

# 7. Problémy a jejich řešení

| Problém | Řešení | Výsledek |
|---|---|---|
| `public.matches` neuměl uchovat více externích identit | Vytvořena `public.match_provider_map` | Historická i API identita jsou zachovány |
| 927 duplicitních řádků zápasů | Přenos identity a downstream vazeb před delete | 927 bezpečných sloučení |
| Neúplné API skóre u Standard–Anderlecht | Ověřen oficiální disciplinární výsledek | Kanonické skóre 5:0 |
| Rozdíl 0:5 vs 1:0 u Charleroi–Mechelen | Oddělen stav na hřišti a oficiální výsledek | Kanonické skóre 0:5 |
| Rozdíl 5:0 vs 4:0 u Antwerp–Beerschot | Oddělen stav na hřišti a disciplinární výsledek | Kanonické skóre 5:0 |
| Neexistující `match.created_at` v auditním SQL | Sloupec odstraněn, použit `updated_at` | Audit úspěšně zopakován |
| Rozdílné datové typy `kickoff` | Explicitní převod na UTC | 930 ratingů správně sjednoceno |
| Hláška `there is no transaction in progress` | Vyhodnocena jako neškodný bezpečnostní notice | Bez dopadu na data |
| 78 794 ratingových orphanů | Odděleno od belgické migrace | Počet se migrací nezměnil |

---

# 8. Databázový a Git stav

## 8.1 Databáze

```text
Databáze                       : matchmatrix
public.matches                 : 120 981
public.match_provider_map      : 121 908
Distinct mapped matches        : 120 978
Active primary identities      : 120 978
Provider orphans               : 0
Belgium unique history         : 1 284
Belgium API matches            : 960
Belgium resolved overlaps      : 930
Belgium review cases remaining : 0
Resolved target features       : 930
Resolved target ratings        : 930
Resolved ratings aligned       : 930
Feature orphans                : 0
Rating orphans                 : 78 794
Expected unmapped matches      : 3
```

## 8.2 Git

V tomto pracovním bloku nebyl proveden ani doložen nový Git commit nebo push. Před publikací tohoto denního zápisu a NAV je nutné samostatně ověřit aktuální větev, poslední commit a čistotu pracovního stromu.

## 8.3 Dokumentační databáze

Stav dokumentační databáze nebyl v tomto pracovním bloku znovu auditován. Nové dokumenty musí projít standardním Q3 dokumentačním workflow před importem.

---

# 9. Rizika a otevřené otázky

1. Zbývajících 1 284 unikátních historických zápasů je stále nutné přesunout z chybné legacy soutěžní identity na správnou Jupiler Pro League.
2. Před tímto přesunem je nutné ověřit pokrytí všech použitých historických týmů potvrzenými team mapami.
3. Čtyři dříve identifikované historické kluby bez potvrzeného API protějšku se nesmějí automaticky přemapovat.
4. Je nutné rozhodnout, zda se u unikátní historie použijí API týmová `team_id`, nebo zda se nejprve dokončí jednotný kanonický team provider model.
5. Legacy seed s chybným významem kódu `B1` nesmí být znovu spuštěn v původní podobě.
6. Stávající `public.matches.ext_source` a `ext_match_id` jsou stále kompatibilitní sloupce a zatím se neodstraňují.
7. Globálních 78 794 orphan ratingů vyžaduje samostatný audit, ale nemá být mícháno do právě dokončeného belgického workflow.
8. Všechny další hromadné změny musí nejprve proběhnout v `VALIDATE ONLY` režimu s úplným rollbackem.

---

# 10. Nedokončené práce

- read-only profil 1 284 unikátních belgických historických zápasů,
- rozpad podle sezon, týmů a dostupnosti team map,
- potvrzení počtu zápasů s oběma mapovanými týmy,
- identifikace zápasů obsahujících historický tým bez potvrzeného API protějšku,
- cílový migrační plán `league_id=4 → league_id=20853`,
- cílový migrační plán historických `home_team_id` a `away_team_id`,
- audit všech downstream vazeb unikátní historie,
- validace dopadu na feature a rating dimenze,
- oprava legacy seedu `B1`,
- samostatný globální audit orphanů v `public.mm_match_ratings`,
- Git a dokumentační publikace nových DL/NAV.

---

# 11. Plán pokračování

1. Nejprve pouze read-only auditovat zbývajících 1 284 historických belgických zápasů.
2. Rozdělit je podle sezony a použitých historických týmů.
3. Připojit potvrzené team provider mapy a vyčíslit úplně mapovatelné, částečně mapovatelné a nemapovatelné zápasy.
4. Oddělit čtyři historické kluby bez potvrzeného API protějšku.
5. Teprve po tomto auditu navrhnout `VALIDATE ONLY` převod soutěžní a týmové identity.
6. Zachovat všechny historické providerové identity v `public.match_provider_map`.
7. Po úspěšné validaci provést řízený APPLY a samostatný závěrečný audit.
8. Orphan ratingy řešit až v oddělené etapě.

---

# 12. Jediný hlavní další krok

Spustit jeden read-only audit zbývajících 1 284 řádků `football_data_uk` pod `league_id=4`, který pro každý zápas vyhodnotí:

```text
season
historical home_team_id
historical away_team_id
existenci potvrzené team mapy pro domácí tým
existenci potvrzené team mapy pro hostující tým
cílové API team_id
počet downstream FK a měkkých vazeb
```

Výstup musí rozdělit zápasy na:

```text
FULLY_MAPPABLE
PARTIALLY_MAPPABLE
UNMAPPED_TEAM_REQUIRED
```

Audit nesmí provést žádnou trvalou databázovou změnu.

---

# 13. Vazba na dokument NAVÁZÁNÍ

Navazující dokument:

```text
MM-NAV-20260726-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```

Nový chat má použít NAV jako hlavní provozní kontext a tento denní zápis jako podrobný důkaz průběhu práce.

---

# 14. Související dokumenty, tabulky a výstupy

## 14.1 Dokumentace

- `MM-DOC-300_MATCHMATRIX_ARCHITECTURE_TECH_REVIEW.md`
- `MM-DOC-800_MATCHMATRIX_DEVELOPMENT_HANDBOOK_TECH_REVIEW.md`
- `MM-DOC-900_MATCHMATRIX_DENNÍ_ZÁPISY_TECH_REVIEW.md`
- `MM-STD-003_STANDARD_ZIVOTNIHO_CYKLU_DOKUMENTACE_A_VERZOVANI.md`
- `MM-STD-004_STANDARD_NÁZVOSLOVÍ_A_STRUKTURY_DOKUMENTACE.md`
- `MM-STD-007_IDENTIFIKACE_A_CISLOVANI_DOKUMENTU_MATCHMATRIX.md`
- `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md`
- `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md`

## 14.2 Databázové objekty

- `public.matches`
- `public.match_provider_map`
- `public.match_features`
- `public.mm_match_ratings`
- `public.teams`
- `public.team_provider_map`
- `public.league_provider_map`

## 14.3 Klíčové kanonické zápasy

| Případ | Historické ID | Kanonické ID | Oficiální výsledek |
|---|---:|---:|---:|
| Standard Liège–Anderlecht | 7545 | 344386 | 5:0 |
| Charleroi–KV Mechelen | 7569 | 344421 | 0:5 |
| Antwerp–Beerschot | 6865 | 317481 | 5:0 |

---

# 15. Terminologická kontrola

V dokumentu se používají tyto závazné významy:

| Pojem | Význam |
|---|---|
| Kanonický zápas | Jediný aktivní master řádek zápasu v `public.matches` |
| Providerová identita | Externí identifikace zápasu u konkrétního provideru nebo zdroje |
| Primární identita | Aktivní providerová identita určená jako hlavní technický odkaz |
| Sekundární identita | Další zachovaná externí identita stejného kanonického zápasu |
| Historický zdroj | Zdroj poskytující starší soutěžní výsledky, zde `football_data_uk` |
| Překryv | Historický a API řádek reprezentující stejný skutečný zápas |
| Provenience | Dohledatelný původ dat, rozhodnutí a provedené migrace |
| Stav na hřišti | Skóre v okamžiku přerušení utkání |
| Oficiální výsledek | Konečný soutěžní nebo disciplinární výsledek používaný kanonicky |
| Orphan | Řádek odkazující na neexistující master entitu |
| `VALIDATE ONLY` | Zkušební provedení změny s úplnou kontrolou a povinným rollbackem |
| `APPLY` | Trvalé provedení již úspěšně ověřené změny |

Terminologické označení provider, zdroj, organizace, publisher, interní proces a adapter nesmí být zaměňováno; jde o rozdílné typy identity.

---

# 16. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-07-26 | APPROVED | První vydání denního zápisu po dokončení belgického slučování 930 zápasů a závěrečném auditu |

---

# Závěr dokumentu

Dne 2026-07-26 byla dokončena první úplná praktická migrace víceproviderových identit kanonických zápasů v projektu MatchMatrix.

Bylo uzavřeno 930 belgických překryvů, zachováno 1 284 unikátních historických zápasů, převedeny všechny dotčené feature a ratingové vazby a odstraněny všechny tři review případy. Závěrečný audit potvrdil nulové providerové orphan řádky, nulové feature orphan řádky a úplnou rozměrovou shodu 930 převedených ratingů.

Další etapa nesmí znovu řešit již uzavřené překryvy. Má navázat read-only auditem 1 284 unikátních historických belgických zápasů a připravit jejich bezpečné zařazení pod správnou kanonickou soutěžní a týmovou strukturu.
