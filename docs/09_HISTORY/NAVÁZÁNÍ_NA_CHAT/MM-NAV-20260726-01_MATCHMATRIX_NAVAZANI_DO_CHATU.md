# MatchMatrix – navázání do nového chatu – 2026-07-26

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260726-01 |
| Název dokumentu | MatchMatrix – navázání do nového chatu – 2026-07-26 |
| Typ dokumentu | CHAT_CONTINUATION |
| Verze | 1.1 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-26 |
| Datum poslední aktualizace | 2026-07-26 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | Fotbal, kanonická zápasová identita a belgická historická migrace |
| Primární formát | Markdown (`.md`) |
| Kanonické umístění | `docs/09_HISTORY/NAVÁZÁNÍ_NA_CHAT/MM-NAV-20260726-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Zdrojový denní zápis | `MM-DL-20260726_MATCHMATRIX_DENNI_ZAPIS.md` |
| Předchozí známé navázání | `MM-NAV-20260723-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Šablona | `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md` |

---

# 1. Identifikace navázání

| Položka | Hodnota |
|---|---|
| Document ID | MM-NAV-20260726-01 |
| Datum pracovního dne | 2026-07-26 |
| Datum a čas uzavření | 2026-07-26T21:31:13+02:00 |
| Aktivní projekt | MatchMatrix-platform |
| Aktivní sport | Fotbal (`FB`) |
| Aktivní oblast | Belgická Jupiler Pro League – providerové identity zápasů |
| Zdrojový denní zápis | `MM-DL-20260726` |
| Databáze | PostgreSQL `matchmatrix` |
| Poslední dokončená technická etapa | Sloučení 930 belgických překryvů a finální read-only audit |
| Git stav | Větev `main`; lokální commit `8d7f4ff` vytvořen; vzdálený push nebyl v tomto pracovním bloku ověřen |
| První následný krok | Dokončit opakovaný audit A17 a databázový import tohoto NAV; poté spustit READ ONLY audit 1 284 unikátních historických belgických zápasů |

---

# 2. Účel navázání

Tento dokument předává přesný stav po dokončení belgického pilotu kanonických zápasů a identit poskytovatelů dat (providerových identit).

Nový chat nemá znovu vytvářet `public.match_provider_map`, opakovat sloučení 927 bezpečných překryvů ani znovu rozhodovat tři disciplinární případy. Tyto oblasti jsou dokončeny a potvrzeny závěrečným auditem.

Nový chat má pokračovat jedinou následující etapou:

```text
AUDIT POUZE PRO ČTENÍ (READ ONLY AUDIT)
1 284 UNIQUE BELGIUM HISTORY MATCHES
TEAM MAP COVERAGE
LEAGUE + TEAM CANONICALIZATION PLAN
```

---

# Terminologie

Tato sekce sjednocuje odborné a cizojazyčné pojmy používané v dokumentu. Referenčním zdrojem terminologie je `MM-REF-001 – Slovník pojmů MatchMatrix`.

| Pojem | Význam v tomto dokumentu |
|---|---|
| Kanonický zápas | Jediný hlavní řádek zápasu v `public.matches`, na který mohou být navázány identity více poskytovatelů dat. |
| Provider / poskytovatel dat | Externí nebo interní systém, který dodává data. Provider není totéž co zdrojový soubor, organizace, publisher ani technický adaptér. |
| Providerová identita | Vazba mezi kanonickým zápasem a externím identifikátorem poskytovatele v `public.match_provider_map`. |
| Primární identita | Jediná aktivní providerová identita určená jako hlavní identita kanonického zápasu. |
| Sekundární identita | Další aktivní identita téhož kanonického zápasu, která zachovává historickou nebo alternativní provenienci. |
| Provenience | Dohledatelný původ dat, včetně poskytovatele, původního identifikátoru, způsobu převodu a rozhodnutí o sloučení. |
| Překryv | Dva řádky různých zdrojů, které reprezentují stejný skutečný zápas. |
| Sloučení | Řízený převod identit a navázaných dat na jeden kanonický zápas a následné odstranění duplicitního master řádku. |
| Downstream tabulka / navazující tabulka | Tabulka závislá na zápasu, například `public.match_features` nebo `public.mm_match_ratings`. |
| Orphan / osiřelý řádek | Řádek, jehož `match_id` neodkazuje na existující kanonický zápas. |
| READ ONLY | Režim pouze pro čtení, který nesmí trvale změnit data. |
| VALIDATE ONLY | Zkušební transakční provedení změny ukončené povinným rollbackem. |
| APPLY | Schválené trvalé provedení změny zakončené commitem. |
| ROLLBACK | Vrácení transakce do původního stavu bez trvalého zápisu. |
| PROJECT SNAPSHOT | Stručný přehled stavu projektu, cíle, aktivní etapy a pracovních pravidel. |
| DATABASE SNAPSHOT | Ověřený přehled relevantních databázových objektů a kontrolních počtů. |

---

# Aktuální stav

## Dokumentační stav

- Denní zápis `MM-DL-20260726` byl v Q3 workflow kanonicky auditován, uložen do Git historie, importován do dokumentační databáze a ověřen kontrolou A7.
- Dokument `MM-NAV-20260726-01` prošel prvním auditem A17 se skóre 76,67 % a stavem `RESTRUCTURE_REQUIRED`.
- Připomínky A17 byly v této verzi `1.1` zapracovány doplněním samostatných sekcí `Aktuální stav`, `Otevřené úkoly`, `Přijatá rozhodnutí`, `PROJECT SNAPSHOT`, `DATABASE SNAPSHOT`, `Otevřené otázky`, `NEXT STEP` a `Terminologie`.
- Po uložení této opravy musí následovat nové spuštění A17. A24 APPLY zůstává do úspěšného výsledku A17 zablokovaný.

## Git stav

```text
BRANCH              = main
LOCAL COMMIT        = 8d7f4ff
COMMIT CONTENT      = 25 SQL auditních/migračních skriptů + MM-NAV-20260726-01
REMOTE PUSH STATUS  = v tomto pracovním bloku neověřen
DIRTY POLICY        = nepoužívat --allow-dirty
```

## Technický stav projektu

- Belgická migrace providerových identit zápasů je dokončena a uzavřena závěrečným READ ONLY auditem.
- Sloučeno bylo 930 překryvů: 927 bezpečných shod a 3 ručně ověřené disciplinární případy.
- Zachováno zůstává 1 284 unikátních historických belgických zápasů.
- Další datová etapa nesmí začít před dokončením publikace tohoto NAV.

---

# PROJECT SNAPSHOT

| Položka | Aktuální hodnota |
|---|---|
| Projekt | MatchMatrix-platform |
| Aktivní sport | Fotbal (`FB`) |
| Aktivní soutěžní oblast | Belgická Jupiler Pro League |
| Hlavní cíl dokončené etapy | Zavedení víceproviderové identity zápasů a odstranění potvrzených duplicit bez ztráty provenience |
| Dokončený milník | 930 belgických překryvů sloučeno a auditně uzavřeno |
| Zachovaná unikátní historie | 1 284 zápasů |
| Aktivní dokumentační úkol | Oprava a publikace `MM-NAV-20260726-01` po připomínkách A17 |
| Následující datová etapa | READ ONLY audit mapovatelnosti 1 284 historických zápasů |
| Pracovní režim | Jeden jasný krok, audit → VALIDATE ONLY → APPLY |
| Zakázané zkratky | `--allow-dirty`, neověřené hromadné UPDATE/DELETE, odhadované mapování týmů |

Projektový stav je stabilní: dokončená sloučení se nemají opakovat a další práce se soustředí na bezpečné kanonizování zachované unikátní historie.

---

# DATABASE SNAPSHOT

Snapshot vychází ze závěrečného auditu belgické migrace provedeného dne 2026-07-26.

| Ukazatel | Hodnota |
|---|---:|
| `public.matches` | 120 981 |
| `public.match_provider_map` | 121 908 |
| Distinct mapped matches | 120 978 |
| Aktivní primární identity | 120 978 |
| Osiřelé providerové identity | 0 |
| Zbývající unikátní belgická historie | 1 284 |
| Belgické API-Football zápasy | 960 |
| Uzavřené belgické překryvy | 930 |
| Správně složené cíle se dvěma identitami | 930 |
| Převedené `match_features` | 930 |
| Převedené `mm_match_ratings` | 930 |
| Rozměrově sjednocené ratingy | 930 |
| Osiřelé `match_features` | 0 |
| Globální osiřelé `mm_match_ratings` | 78 794 |
| Nezmapované ruční testovací zápasy | 3 |

Kontrolní stav:

```text
BELGIUM_MIGRATION_FINAL_AUDIT_OK
930 SLOUČENÍ UZAVŘENO
1284 UNIKÁTNÍCH HISTORICKÝCH ZÁPASŮ ZACHOVÁNO
```

---

# Přijatá rozhodnutí

1. `public.matches` zůstává jedinou kanonickou tabulkou zápasů.
2. `public.match_provider_map` je závazná tabulka víceproviderových identit zápasů.
3. API-Football zůstává u 930 sloučených cílů primární identitou.
4. `football_data_uk` zůstává sekundární historickou identitou a nesmí být při čištění zahozena.
5. Zbývajících 1 284 unikátních historických zápasů se nesmí odstranit.
6. Čtyři historické kluby bez potvrzeného API protějšku se nesmí mapovat odhadem podle názvu.
7. Ratingové metriky se při změně zápasových dimenzí nepřepočítávají ani nemění.
8. Globálních 78 794 osiřelých ratingových řádků se bude řešit v samostatné etapě.
9. Každá budoucí destruktivní změna musí projít pořadím `READ ONLY audit → VALIDATE ONLY → ROLLBACK_OK → APPLY → post-commit audit`.
10. Dokumentační import se provádí pouze nad čistým Git stromem; `--allow-dirty` se nepoužívá.
11. Nejprve se dokončí publikace tohoto NAV, teprve potom začne další datová etapa.

---

# Otevřené úkoly

| Priorita | Úkol | Stav | Podmínka dokončení |
|---:|---|---|---|
| 1 | Uložit opravenou verzi `MM-NAV-20260726-01` do kanonické složky | OTEVŘENO | Aktivní soubor obsahuje verzi 1.1 |
| 2 | Spustit A17 nad opraveným NAV | OTEVŘENO | Stav již není `RESTRUCTURE_REQUIRED` a kritické/vysoké strukturální nálezy jsou uzavřeny |
| 3 | Zajistit čistý Git strom a uložit opravu do Git historie | OTEVŘENO | `git status --short` je prázdný |
| 4 | Spustit A24 `VALIDATE_ONLY` | BLOKOVÁNO A17 | Výsledek `HISTORY_DOCUMENT_IMPORT_VALIDATED` |
| 5 | Spustit A24 `APPLY` a ověření A6 + A7 | BLOKOVÁNO VALIDACÍ | Dokument je importován a A7 potvrzuje správnost |
| 6 | Ověřit push větve `main` na vzdálený repozitář | OTEVŘENO | Git potvrzuje úspěšný push |
| 7 | Připravit READ ONLY audit 1 284 unikátních belgických zápasů | ČEKÁ | Dokumentační workflow je dokončeno |
| 8 | Opravit legacy seed `B1` | ČEKÁ | Je schválen samostatný bezpečný postup |
| 9 | Auditovat 78 794 globálních ratingových orphanů | ODLOŽENO | Belgická soutěžní etapa je plně uzavřena |

---

# Otevřené otázky (OPEN QUESTIONS)

1. Které z 1 284 unikátních historických zápasů mají oba týmy potvrzeně mapované na cílové API identity?
2. Kolik zápasů obsahuje jeden nebo dva historické týmy bez potvrzeného cíle?
3. Jak budou evidovány čtyři historické kluby, pro které není potvrzený API protějšek?
4. Má se první APPLY týkat pouze plně mapovatelné sady, nebo bude potřeba další mezivrstva kanonických týmových identit?
5. Ve které samostatné etapě bude řešeno 78 794 globálních osiřelých řádků `public.mm_match_ratings`?

Tyto otázky se nesmějí rozhodovat odhadem. Odpovědi musí vzniknout z následného READ ONLY auditu a samostatného uživatelského schválení.

---

# NEXT STEP

## Bezprostřední dokumentační krok

Nahradit aktivní soubor touto opravenou verzí `1.1` a znovu spustit audit A17.

Požadovaný výsledek:

```text
CONT-CURRENT-STATUS    = SPLNĚNO
CONT-OPEN-TASKS        = SPLNĚNO
CONT-DECISIONS         = SPLNĚNO
CONT-PROJECT-SNAPSHOT  = SPLNĚNO
CONT-DATABASE-SNAPSHOT = SPLNĚNO
```

## První technický krok po publikaci dokumentu

Spustit jediný READ ONLY SQL audit nad 1 284 zbývajícími historickými belgickými zápasy a vyhodnotit úplnost týmových map. Do získání výsledku se nemá připravovat žádný APPLY skript.

---

# 3. Výchozí kontext pro nový chat

Historická belgická data byla importována providerem `football_data_uk`. Kvůli chybě v legacy mapování CSV kódu `B1` skončila pod `league_id=4`, který v dnešní databázi reprezentuje jinou soutěžní identitu.

Správná cílová Jupiler Pro League:

```text
league_id       = 20853
provider        = api_football
provider league = 144
```

Před migrací existovalo:

```text
2 214 historických belgických zápasů
960 API-Football zápasů
21 potvrzených dvojic týmových identit
927 bezpečných překryvů
1 284 unikátních historických zápasů
3 případy vyžadující ruční rozhodnutí
```

Po dokončené etapě:

```text
930 překryvů sloučeno
1 284 unikátních historických zápasů zachováno
0 belgických review případů
0 osiřelých providerových identit
0 osiřelých match_features
```

---

# 4. Co bylo dokončeno

1. Vytvoření a naplnění `public.match_provider_map`.
2. Backfill 121 908 kompletních identit z `public.matches`.
3. Zachování tří očekávaných ručních nezmapovaných zápasů `id IN (1,2,3)`.
4. Klasifikace 2 214 belgických historických zápasů.
5. Přenos 927 historických identit na API kanonické zápasy.
6. Přenos 927 řádků `public.match_features`.
7. Přenos a dimenzionální sjednocení 927 řádků `public.mm_match_ratings`.
8. Odstranění 927 historických duplicit.
9. Individuální audit, validace a APPLY tří ručních případů.
10. Přenos dalších 3 feature a 3 ratingových řádků.
11. Odstranění dalších 3 historických duplicit.
12. Závěrečný read-only audit všech 930 sloučení.
13. Potvrzení 1 284 unikátních historických zápasů k zachování.
14. Potvrzení nulového počtu providerových orphanů.
15. Potvrzení, že globálních 78 794 ratingových orphanů se migrace nedotkla.

---

# 5. Konečný databázový snapshot

| Ukazatel | Hodnota |
|---|---:|
| `public.matches` | 120 981 |
| `public.match_provider_map` | 121 908 |
| Distinct mapped matches | 120 978 |
| Aktivní primární identity | 120 978 |
| Osiřelé providerové identity | 0 |
| Zbývající unikátní belgická historie | 1 284 |
| Belgické API-Football zápasy | 960 |
| Vyřešené belgické dvojice | 930 |
| Původní sloučené zápasy zbývající | 0 |
| Cílové sloučené zápasy | 930 |
| Cíle se správnými dvěma identitami | 930 |
| Převedené `match_features` | 930 |
| Převedené `mm_match_ratings` | 930 |
| Rozměrově sjednocené ratingy | 930 |
| Osiřelé `match_features` | 0 |
| Globální osiřelé `mm_match_ratings` | 78 794 |
| Ručně ověřené výsledky | 3 |
| Zbývající review případy | 0 |
| Nezmapované ruční testovací zápasy | 3 |

Finální auditní stav:

```text
BELGIUM_MIGRATION_FINAL_AUDIT_OK – 930 SLOUČENÍ UZAVŘENO, 1284 UNIKÁTNÍCH HISTORICKÝCH ZÁPASŮ ZACHOVÁNO
```

---

# 6. Cílová architektura zápasové identity

Závazný model:

```text
public.matches
└── jeden kanonický zápas

public.match_provider_map
├── api_football / primární identita
└── football_data_uk / sekundární historická identita
```

Důležité podmínky:

- `(provider, provider_match_id)` je unikátní externí klíč,
- na jednom kanonickém zápase může být více aktivních identit,
- právě jedna aktivní identita smí být primární,
- providerová provenience se nesmí zahodit při odstranění duplicitního master řádku,
- `public.matches.ext_source` a `ext_match_id` se zatím ponechávají kvůli kompatibilitě,
- `public.canonical_provider_map` se pro tento účel nepoužívá.

---

# 7. Přesný stav 930 sloučení

## 7.1 Bezpečné překryvy

```text
927 × OVERLAP_SAME_SCORE
```

U všech bylo provedeno:

- přesunutí historické identity na API cíl,
- změna historické identity na sekundární,
- zachování API identity jako primární,
- převod feature,
- převod ratingu,
- sjednocení ratingových dimenzí,
- kontrola FK a měkkých vazeb,
- odstranění historického duplicitního řádku.

## 7.2 Ruční případy

| Případ | Historické ID | Kanonické ID | Stav na hřišti / provideru | Oficiální kanonický výsledek | Resolution code |
|---|---:|---:|---|---:|---|
| Standard Liège–Anderlecht | 7545 | 344386 | 3:1 při přerušení; API `CANCELLED` | 5:0 | `DISCIPLINARY_FORFEIT_5_0` |
| Charleroi–KV Mechelen | 7569 | 344421 | 1:0 při přerušení | 0:5 | `CBAS_FORFEIT_0_5` |
| Antwerp–Beerschot | 6865 | 317481 | 4:0 při přerušení | 5:0 | `KBVB_FORFEIT_5_0` |

Všechny tři případy mají:

```text
2 providerové identity
1 aktivní primární identitu
1 match_features
1 mm_match_ratings
0 původních historických master řádků
```

---

# 8. Downstream pravidla

## 8.1 `public.match_features`

- PK a FK používají `match_id`.
- Při sloučení se `match_id` převádí na kanonický cíl.
- Ostatní feature hodnoty se zachovávají.
- `updated_at` se aktualizuje.

Konečný audit:

```text
930 převedených feature řádků
0 feature orphanů
```

## 8.2 `public.mm_match_ratings`

Tabulka nemá FK na `public.matches`, ale používá `match_id` jako měkkou vazbu a PK.

Při sloučení se mění pouze dimenze:

```text
match_id
league_id
kickoff
home_team_id
away_team_id
```

Ratingové metriky se nesmějí přepočítat ani měnit.

Časové typy:

```text
matches.kickoff          = timestamp without time zone
mm_match_ratings.kickoff = timestamp with time zone
```

Povinné porovnání a převod:

```sql
match.kickoff::timestamp AT TIME ZONE 'UTC'
```

Konečný audit:

```text
930 převedených ratingů
930 dimenzionálně správných ratingů
78 794 starších globálních orphanů beze změny
```

---

# 9. Co se podařilo ochránit

- žádná historická providerová identita nebyla ztracena,
- žádný z 1 284 unikátních historických zápasů nebyl odstraněn,
- žádný feature řádek nebyl ztracen,
- žádná ratingová metrika nebyla změněna,
- nevznikla žádná osiřelá providerová identita,
- nevznikla žádná osiřelá feature vazba,
- u disciplinárních případů je zachován stav na hřišti i oficiální výsledek,
- každý APPLY byl předem ověřen rollbackovanou validací.

---

# 10. Problémy, které již není nutné řešit znovu

1. Není nutné znovu dokazovat, že 927 překryvů reprezentovalo stejné zápasy.
2. Není nutné znovu slučovat jejich providerové identity.
3. Není nutné znovu převádět jejich feature nebo ratingy.
4. Není nutné znovu rozhodovat tři disciplinární výsledky.
5. Není nutné znovu auditovat, zda po 930 sloučeních existují providerové orphan řádky.
6. Není nutné znovu vytvářet backfill 121 908 identit.
7. Není nutné používat nebo opravovat `public.canonical_provider_map` jako součást této etapy.
8. Není nutné řešit 78 794 globálních ratingových orphanů v rámci belgické soutěžní migrace.

---

# 11. Co zůstává rozpracováno

Hlavním rozpracovaným blokem je 1 284 unikátních historických belgických zápasů.

Tyto zápasy:

- nemají API zápasový protějšek,
- musí zůstat v databázi,
- mají historickou identitu `football_data_uk`,
- jsou stále spojeny s legacy soutěžní identitou,
- používají historické týmové `team_id`,
- musí být před přesunem rozděleny podle dostupnosti potvrzených team map.

Dále zůstává:

- oprava legacy seedu `B1`,
- rozhodnutí pro čtyři historické kluby bez API protějšku,
- samostatný audit globálních ratingových orphanů,
- publikace DL/NAV přes Q3 workflow.

---

# 12. Rizika a upozornění

1. **Neprovádět hromadný UPDATE 1 284 zápasů bez předchozího read-only rozdělení podle týmové mapovatelnosti.**
2. **Nevytvářet náhradní API týmovou identitu odhadem podle názvu.**
3. **Čtyři historické kluby bez potvrzeného API protějšku ponechat ve stavu REVIEW.**
4. **Neodstraňovat historické providerové identity po přesunu soutěže nebo týmů.**
5. **Nezaměňovat změnu kanonického `team_id` za změnu providerové identity.**
6. **Neopravovat současně 78 794 globálních ratingových orphanů.**
7. **Nevypouštět explicitní UTC převod ratingového `kickoff`.**
8. **Každý budoucí delete nebo merge musí projít `VALIDATE ONLY → ROLLBACK_OK → APPLY`.**
9. **Legacy seed `B1` nesmí být znovu spuštěn bez opravy.**
10. **Git a dokumentační databáze nebyly v posledním pracovním bloku znovu auditovány.**

---

# 13. AI CONTEXT

AI má při pokračování vycházet z těchto závazných skutečností:

```text
PROJECT                         = MatchMatrix-platform
SPORT                           = football
DATABASE                        = matchmatrix
CANONICAL MATCH TABLE           = public.matches
MATCH PROVIDER IDENTITY TABLE   = public.match_provider_map
BELGIUM TARGET LEAGUE_ID        = 20853
BELGIUM LEGACY LEAGUE_ID        = 4
BELGIUM UNIQUE HISTORY          = 1284
BELGIUM API MATCHES             = 960
BELGIUM RESOLVED OVERLAPS       = 930
BELGIUM REVIEW CASES            = 0
PUBLIC.MATCHES TOTAL            = 120981
MATCH PROVIDER MAP ROWS         = 121908
DISTINCT MAPPED MATCHES         = 120978
ACTIVE PRIMARY IDENTITIES       = 120978
PROVIDER ORPHANS                = 0
RESOLVED FEATURES               = 930
RESOLVED RATINGS                = 930
RESOLVED RATINGS ALIGNED        = 930
GLOBAL RATING ORPHANS           = 78794
EXPECTED UNMAPPED MATCHES       = 3
```

Pracovní pravidla:

```text
- postupovat vždy po jednom jasném technickém kroku;
- SQL posílat přímo do chatu;
- nejprve audit, potom validate-only, teprve potom apply;
- neprovádět destruktivní změny bez rollback plánu;
- zachovat všechny providerové identity a metadata;
- API-Football zůstává primární identitou u 930 sloučených cílů;
- football_data_uk zůstává sekundární historickou identitou;
- 1284 unikátních historických zápasů se nesmí smazat;
- čtyři nemapované historické kluby nepřevádět odhadem;
- ratingové metriky při změně dimenzí neměnit;
- 78794 globálních ratingových orphanů řešit samostatně;
- nevypisovat hesla, tokeny ani obsah .env;
- nepoužívat --allow-dirty.
```

---

# 14. Co se nemá opakovat

Nový chat nemá:

- opakovat vytvoření `public.match_provider_map`,
- opakovat backfill 121 908 identit,
- opakovat klasifikaci 927 + 1 284 + 3,
- opakovat převod 927 bezpečných překryvů,
- opakovat tři ruční merge případy,
- znovu měnit kanonická skóre zápasů 344386, 344421 a 317481,
- znovu odstraňovat historická ID 7545, 7569 a 6865,
- znovu provádět konečný audit 930 sloučení, pokud se relevantní data nezmění,
- spojovat belgickou etapu s globální opravou orphan ratingů.

---

# 15. Jediný hlavní další krok

Připravit a spustit jeden read-only SQL audit nad 1 284 zbývajícími historickými belgickými zápasy:

```text
public.matches.league_id = 4
public.matches.ext_source = football_data_uk
```

Audit musí zjistit:

1. počet zápasů podle sezony,
2. všechny použité historické domácí a hostující `team_id`,
3. existenci potvrzené mapy na cílové API týmy,
4. počet zápasů s oběma týmy plně mapovanými,
5. počet zápasů s jedním nemapovaným týmem,
6. počet zápasů se dvěma nemapovanými týmy,
7. seznam historických klubů bez potvrzeného cíle,
8. FK a měkké vazby těchto zápasů,
9. počet existujících feature a ratingových řádků,
10. připravenost na budoucí `VALIDATE ONLY` změnu `league_id` a týmových dimenzí.

Po tomto kroku se má uživatel vrátit s výsledkem. Teprve potom se navrhne další jediný krok.

---

# 16. Doporučené pořadí pokračování

```text
KROK 1  READ ONLY audit 1284 unikátních zápasů
KROK 2  klasifikace podle úplnosti team map
KROK 3  audit downstream vazeb a dimenzí
KROK 4  návrh validate-only migrace plně mapovatelných zápasů
KROK 5  rollback ověření
KROK 6  apply pouze schválené plně mapovatelné sady
KROK 7  samostatný review nemapovaných historických klubů
KROK 8  oprava legacy seedu B1
KROK 9  závěrečný audit belgické soutěžní historie
KROK 10 samostatná etapa globálních ratingových orphanů
```

V novém chatu se má provést pouze první krok a vyčkat na výsledek.

---

# 17. Kritické identifikátory

## 17.1 Soutěže

```text
legacy Belgium history league_id = 4
canonical Jupiler league_id       = 20853
```

## 17.2 Ručně uzavřené zápasy

```text
7545   → 344386   Standard Liège–Anderlecht   5:0
7569   → 344421   Charleroi–KV Mechelen        0:5
6865   → 317481   Antwerp–Beerschot             5:0
```

## 17.3 Očekávané nezmapované testovací zápasy

```text
1
2
3
```

---

# 18. Důležité databázové objekty

| Objekt | Význam |
|---|---|
| `public.matches` | Kanonické zápasy |
| `public.match_provider_map` | Víceproviderové identity zápasů |
| `public.match_features` | Předzápasové feature |
| `public.mm_match_ratings` | Ratingové a momentum hodnoty |
| `public.teams` | Kanonické týmové řádky |
| `public.team_provider_map` | Providerové identity týmů |
| `public.league_provider_map` | Providerové identity soutěží |
| `public.canonical_provider_map` | Starší prototyp; nepoužívat bez review |

---

# 19. Bezpečnostní a pracovní pravidla

- Uživatel pracuje krok po kroku a má dostat vždy pouze jeden příkaz nebo jeden jasný úkon.
- SQL se posílá přímo do chatu.
- Destruktivní SQL nesmí následovat před úspěšným `VALIDATE ONLY` a `ROLLBACK_OK`.
- Před delete musí být nulové všechny relevantní FK a měkké vazby na původní ID.
- Po APPLY musí následovat samostatný post-commit audit.
- `public.mm_match_ratings` nemá FK na `public.matches`; měkké vazby se proto kontrolují explicitně.
- Časy se mezi `matches` a `mm_match_ratings` porovnávají přes explicitní UTC.
- Git pracovní strom se před dokumentační publikací samostatně ověří.
- Tokeny, hesla a `.env` se nikdy nevypisují.

---

# 20. Vazby

| Typ vazby | Dokument nebo objekt |
|---|---|
| Zdrojový denní zápis | `MM-DL-20260726` |
| Předchozí známé NAV | `MM-NAV-20260723-01` |
| Dokumentační rámec | `MM-DOC-000` |
| Architektura | `MM-DOC-300` |
| Development handbook | `MM-DOC-800` |
| Denní zápisy | `MM-DOC-900` |
| Slovník | `MM-REF-001` |
| Šablona NAV | `MM-TPL-001` |
| Šablona denního zápisu | `MM-TPL-002` |
| Kanonická tabulka | `public.matches` |
| Providerová mapa | `public.match_provider_map` |

---

# 21. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-07-26 | APPROVED | První vydání NAV po dokončení 930 belgických sloučení a závěrečném auditu |
| 1.1 | 2026-07-26 | APPROVED | Doplněny povinné samostatné sekce podle auditu A17: Aktuální stav, Otevřené úkoly, Přijatá rozhodnutí, PROJECT SNAPSHOT, DATABASE SNAPSHOT, OPEN QUESTIONS, NEXT STEP a Terminologie. |

---

# Závěr dokumentu

Belgický pilot víceproviderové identity zápasů je dokončen a auditně uzavřen.

Projekt nyní obsahuje 930 kanonických belgických zápasů s dvojí providerovou identitou, 1 284 zachovaných unikátních historických zápasů a nulový počet nevyřešených belgických review případů.

Nový chat musí začít pouze read-only auditem mapovatelnosti zbývajících 1 284 historických zápasů. Nemá opakovat již dokončené slučování ani řešit globální ratingové orphan řádky ve stejné etapě.
