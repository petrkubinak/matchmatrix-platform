# MatchMatrix – denní zápis – 2026-07-23

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Document ID | MM-DL-20260723 |
| Název dokumentu | MatchMatrix – denní zápis – 2026-07-23 |
| Typ dokumentu | DAILY_LOG |
| Verze | 1.0 |
| Stav | APPROVED |
| Původní stav zdrojového dokumentu | DRAFT – NEEDS_USER_APPROVAL |
| Datum | 2026-07-23 |
| Autor | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Pracovní oblast | AI kontext projektu, Q3 panel, providerová struktura fotbalu a audit kanonických identit |
| Primární formát | Markdown (`.md`) |
| Kanonické umístění | `docs/09_HISTORY/DENNÍ_ZÁPISY/MM-DL-20260723_MATCHMATRIX_DENNI_ZAPIS.md` |
| Navazující dokument | `MM-NAV-20260723-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Předchozí denní zápis | `MM-DL-20260722_MATCHMATRIX_DENNI_ZAPIS.md` |
| Šablona | `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md` |

---

# 1. Identifikace denního zápisu

| Položka | Hodnota |
|---|---|
| Document ID | MM-DL-20260723 |
| Datum pracovního dne | 2026-07-23 |
| Datum a čas uzavření | 2026-07-23T23:57:49+02:00 |
| Aktivní projekt | MatchMatrix-platform |
| Aktivní sport | Fotbal (`FB`) |
| Aktivní prostředí | PC1 jako ovládací pracoviště, PC2 `192.168.3.119` jako databázový a výpočetní uzel |
| Databáze | PostgreSQL `matchmatrix` na PC2 |
| Režim dnešních databázových auditů | READ ONLY / REPEATABLE READ / ROLLBACK |
| Konečný stav dne | Dokončen A34 a panelové ovládání; přesně odhalen historický problém fotbalových soutěží a týmových identit; databáze nebyla změněna |
| Bezprostřední dokumentační cíl | Uložit a auditovat denní zápis a NAV |
| Bezprostřední technický cíl | Připravit cílový model providerové identity zápasu a bezpečný migrační plán bez ztráty historie |

---

# 2. Výchozí stav

Na začátku dne byla dokončena providerová dokumentace `MM-PRV-001` až `MM-PRV-008`. Dokument `MM-PRV-008` zůstává cílovým návrhem, nikoli potvrzenou implementací.

Fotbal byl potvrzen jako nejpokročilejší referenční sport projektu. Bylo známo, že:

- API-Football poskytuje detailnější historii, PEOPLE a statistická data,
- Football-Data bylo použito hlavně pro aktuální sezonu a CORE,
- Football-Data UK poskytuje historické výsledky,
- jednotlivé zdroje nejsou plně sjednoceny na společné kanonické soutěže a týmy,
- před jakoukoli opravou musí následovat pouze read-only audit skutečných vazeb.

Současně bylo nutné dokončit nástroj A34, jeho napojení do Q3 panelu a vytvořit aktuální AI kontext projektu.

---

# 3. Cíle pracovního dne

1. Dokončit A34 AI Context Package Exporter a ověřit jej v panelu.
2. Zachovat požadavek čistého Git pracovního stromu bez obcházení pomocí `--allow-dirty`.
3. Ověřit skutečný počet soutěží dostupných z Football-Data.
4. Porovnat Football-Data a API-Football na úrovni kanonických soutěží.
5. Zjistit, zda současná databázová struktura vyžaduje přestavbu, nebo pouze opravu mapování.
6. Dohledat původ historických dat Football-Data UK.
7. Přesně určit příčinu chybných historických zápasů pod brazilskou Série A.
8. Najít správnou belgickou soutěž a odpovídající týmové identity.
9. Nasimulovat sjednocení bez jakéhokoli zápisu do databáze.
10. Ověřit, zda současná struktura umí uchovat více providerových identit jednoho kanonického zápasu.

---

# 4. Provedené práce

## 4.1 Dokončení A34 AI Context Package Exporteru

Aktivní nástroj:

```text
tools/documentation/25_1_A_34_EXPORT_AI_CONTEXT_PACKAGE_V1.py
```

Interní engine:

```text
A34_AI_CONTEXT_PACKAGE_V1_3
```

Ověřené vlastnosti:

- read-only přístup k databázi,
- izolace `REPEATABLE READ`,
- ukončení transakce přes `ROLLBACK`,
- povinný čistý Git pracovní strom,
- kontrola A33,
- podpora `--validate-only`,
- podpora `--skip-a33`,
- citlivé hodnoty nejsou součástí balíčku,
- nebyla přidána možnost `--allow-dirty`.

Finální úspěšný balíček:

```text
Package ID : 20260723_202723_MATCHMATRIX_AI_CONTEXT_PACKAGE
Status     : AI_CONTEXT_PACKAGE_CREATED
Files      : 23
Warnings   : 0
Sport      : FB
```

## 4.2 Dokončení panelového ovládání A33 a A34

Aktivní panel:

```text
C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V20_1_Q3_DOCUMENTATION_WORKFLOW.py
```

Panel byl rozdělen do čtyř hlavních pracovních stran:

```text
1. PRACOVNÍ POSTUP
2. AUDITY A AI KONTEXT
3. PŘEKLADY A VÝKLADY
4. DATABÁZOVÝ PŘEHLED
```

Na straně `AUDITY A AI KONTEXT` byly ověřeny ovládací prvky A33 a A34.

Změny byly commitnuty a pushnuty:

```text
498ad4c  Add paged documentation workspace and A34 controls
```

Po dokončení byl potvrzen čistý Git pracovní strom.

## 4.3 Vyřešení blokace čistého Git stromu

A34 byl nejprve zablokován neřízeným pomocným souborem:

```text
?? "cd cMatchMatrix-Platform.txt"
```

Soubor byl odstraněn z pracovního stromu. Nebyla použita žádná výjimka obcházející kontrolu čistoty repozitáře.

Přijaté pravidlo:

```text
A34 se spouští pouze nad čistým Git pracovním stromem.
```

## 4.4 Ověření počtu soutěží Football-Data

Token nebyl dostupný ve vzdálené procesní proměnné, ale byl bezpečně uložen v `.env`. Hodnota tokenu nebyla vypsána ani přenesena do chatu.

Pro ověření nebylo nakonec nutné spouštět nový import. Byl přečten poslední uložený RAW payload endpointu `/competitions`.

Výsledek:

```text
POCET_SOUTEZI=13
```

| Kód | Soutěž | Oblast | Football-Data ID |
|---|---|---|---:|
| BSA | Campeonato Brasileiro Série A | Brazil | 2013 |
| ELC | Championship | England | 2016 |
| PL | Premier League | England | 2021 |
| CL | UEFA Champions League | Europe | 2001 |
| EC | European Championship | Europe | 2018 |
| FL1 | Ligue 1 | France | 2015 |
| BL1 | Bundesliga | Germany | 2002 |
| SA | Serie A | Italy | 2019 |
| DED | Eredivisie | Netherlands | 2003 |
| PPL | Primeira Liga | Portugal | 2017 |
| CLI | Copa Libertadores | South America | 2152 |
| PD | Primera Division | Spain | 2014 |
| WC | FIFA World Cup | World | 2000 |

Dřívější předpoklad 14 soutěží byl zrušen jako neplatný.

## 4.5 Ověření role importu Football-Data

Soubor `football_data_pull_V6.py` nemá pevně zadaný seznam soutěží. Načítá všechny soutěže vrácené endpointem `/competitions` a následně jejich zápasy.

Football-Data je v současném stavu využito hlavně pro soutěže, týmy, zápasy, skóre a aktuální sezonu. API-Football zůstává vhodnějším kandidátem pro detailnější entity, PEOPLE a statistiky. Football-Data se neruší; jeho cílová role je aktuální CORE, záložní zdroj a validační zdroj.

## 4.6 Audit paralelních identit 13 soutěží

Tabulka `public.league_provider_map` obsahovala 13 map Football-Data, ale žádná z nich nebyla připojena ke stejnému kanonickému `league_id` jako API-Football.

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

Závěr:

```text
13 reálných soutěží je v public.leagues vedeno jako 26 oddělených identit.
```

## 4.7 Audit strukturálních vazeb soutěží

Bylo nalezeno 15 referenčních objektů odkazujících na `public.leagues.id`.

Nízké Football-Data identity nesou převážně produktově aktivní soutěže, většinu zápasů, tabulky pořadí, historické vazby a část médií. Vysoké API-Football identity nesou převážně zápasy API-Football za roky 2022 až 2024, hráčské sezonní statistiky, některé články, mediální vazby, samostatné ingest cíle a sezony.

Potvrzeno bylo:

```text
kanonická identita soutěže není totéž jako hlavní datový provider.
```

## 4.8 Audit původu sezon a zápasů

Bylo potvrzeno rozdělení zdrojů:

```text
football_data     → aktuální sezona 2025/26 a turnaje 2026
api_football      → detailní sezony 2022, 2023 a 2024
football_data_uk  → historické sezony převážně 2018/19 až 2024/25
```

Část zápasů `football_data_uk` skončila pod vysokými API-Football `league_id`. Příklady rozdělení jedné sezony:

| Soutěž / sezona | Nízké ID | Vysoké ID | Součet |
|---|---:|---:|---:|
| Championship 2022/23 | 540 | 12 | 552 |
| Ligue 1 2022/23 | 308 | 72 | 380 |
| Bundesliga 2022/23 | 264 | 42 | 306 |
| Serie A 2022/23 | 338 | 42 | 380 |
| Primeira Liga 2022/23 | 264 | 42 | 306 |
| La Liga 2022/23 | 368 | 12 | 380 |

## 4.9 Dohledání historického importu Football-Data UK

Byl nalezen legacy import:

```text
C:\MatchMatrix-Platform\legacy\ingest\football_data_uk_history_pull.py
```

Skript vybíral soutěže pomocí:

```sql
select id, ext_csv_code
from leagues
where ext_csv_code is not null
```

Následně skládal externí identitu zápasu s použitím `league_id`:

```text
league_id|season|date|home|away
```

To umožnilo vytvoření oddělených zápasových identit při chybném nebo změněném mapování soutěže.

## 4.10 Odhalení chybného CSV kódu `B1`

Seed obsahoval:

```sql
update leagues
set ext_csv_code='B1'
where name='Campeonato Brasileiro Série A';
```

Toto mapování bylo potvrzeno jako chybné.

Pod brazilskou soutěží `league_id=4` bylo:

```text
380 zápasů football_data pro brazilskou sezonu 2026
2214 zápasů football_data_uk z belgické Jupiler Pro League
```

Historické bloky `1819` až `2526` s 16 až 18 týmy a obdobím léto–jaro nemohou patřit brazilské Série A.

## 4.11 Nalezení správné belgické soutěže

Správný existující cíl:

```text
LEAGUE_ID            : 20853
NAME                 : Jupiler Pro League
COUNTRY              : Belgium
PROVIDER             : api_football
PROVIDER_LEAGUE_ID   : 144
API_FOOTBALL_MATCHES : 960
```

Zápasy `football_data_uk` s kódem `B1` tedy mají historicky patřit k této soutěži, ne k brazilskému `league_id=4`.

## 4.12 Porovnání belgických zápasů

První audit podle názvu týmů a data zjistil:

| Výsledek | Počet |
|---|---:|
| `football_data_uk` zápasy B1 | 2 214 |
| API-Football zápasy Jupiler Pro League | 960 |
| Napárované podle názvu a stejného dne | 261 |
| Nenapárované | 1 953 |
| Konflikty skóre | 1 |

Nulový počet shodných týmových ID potvrdil, že stejné kluby mají oddělené kanonické identity.

## 4.13 Audit belgických týmových identit

Bylo potvrzeno:

```text
25 týmů v historii B1
23 týmů v aktuální API-Football větvi
21 potvrzených dvojic stejných klubů
4 historické týmy bez potvrzeného API protějšku
```

Příklady dvojích identit:

| Klub | `football_data_uk team_id` | `api_football team_id` |
|---|---:|---:|
| Anderlecht | 972 | 12940 |
| Antwerp | 964 | 13172 |
| Club Brugge | 976 | 12803 |
| Genk | 977 | 12254 |
| Gent | 979 | 12719 |
| Standard Liège | 971 | 13537 |
| Union St. Gilloise | 965 | 13160 |
| Westerlo | 973 | 13279 |

Týmy bez potvrzeného API protějšku:

```text
Lokeren
Mouscron
RAAL La Louviere
Waasland-Beveren
```

Tyto týmy zůstávají platnými historickými identitami a nesmějí být automaticky odstraněny.

## 4.14 Audit vazeb belgických týmů

Bylo nalezeno 26 referenčních objektů odkazujících na `public.teams.id`.

Historická ID nesou hlavně historické zápasy, starší pořadí, aliasy a providerovou mapu `football_data_uk`. API-Football ID nesou hlavně novější zápasy, hráče, hráčské sezonní statistiky a providerovou mapu API-Football.

Přijatý pracovní směr:

```text
Pro 21 potvrzených dvojic budou cílovými kanonickými identitami API-Football team_id,
ale teprve po bezpečném převodu všech vazeb a zachování providerové provenience.
```

## 4.15 Dry-run sjednocení belgické soutěže

Byla nasimulována operace:

```text
league_id 4 → 20853
21 historických team_id → odpovídající API-Football team_id
```

Výsledek:

| Klasifikace | Počet |
|---|---:|
| Unikátní historické zápasy k přesunu | 1 284 |
| Překryv se stejným skóre | 927 |
| Překryv se skórovým rozdílem nebo chybějícím skóre | 3 |
| Duplicitní zdrojové řádky navíc | 0 |
| Neplatný zápas stejného týmu proti sobě | 0 |

Pokrytí týmového mapování v zápasech:

| Stav | Počet |
|---|---:|
| Obě strany namapované | 1 983 |
| Jedna strana namapovaná | 221 |
| Žádná strana namapovaná | 10 |

Předpokládaný počet kanonických zápasů Jupiler Pro League po bezpečném sjednocení:

```text
960 existujících API-Football zápasů
+ 1284 unikátních historických zápasů
= 2244 kanonických zápasů
```

## 4.16 Kontrolní případy skóre

| Datum | Zápas | Football-Data UK | API-Football | Stav |
|---|---|---:|---:|---|
| 2022-10-23 | Standard Liège – Anderlecht | 5:0 | bez skóre | doplnění chybějící hodnoty, ne automatický konflikt |
| 2022-11-12 | Charleroi – KV Mechelen | 0:5 | 1:0 | REVIEW |
| 2024-09-29 | Antwerp – Beerschot VA | 5:0 | 4:0 | REVIEW |

## 4.17 Audit providerové identity zápasu

V databázi nebyla nalezena samostatná kanonická mapa typu:

```text
canonical_match_id
provider
provider_match_id
```

Existující relevantní objekty:

```text
staging.stg_provider_fixtures
public.matches
public.article_match_map
```

`staging.stg_provider_fixtures` uchovává providerovou identitu ve staging vrstvě. `public.matches` však obsahuje pouze jednu dvojici `ext_source` a `ext_match_id`. To nestačí pro bezpečné uchování více providerových identit jednoho kanonického zápasu po deduplikaci.

Na `public.matches.id` odkazuje 18 tabulek, mimo jiné:

```text
article_match_map
lineups
match_events
match_features
match_officials
match_weather
ml_predictions
odds
player_match_statistics
team_match_statistics
generated_ticket_fixed
selection_items
ticket_block_matches
ticket_variant_matches
```

Z toho plyne vysoké riziko přímého mazání nebo nahrazování zápasů bez připravené migrace všech vazeb.

---

# 5. Hlavní výsledky dne

1. A34 byl dokončen, ověřen a napojen do Q3 panelu.
2. Panelové změny byly pushnuty v commitu `498ad4c`.
3. Football-Data pro používaný účet skutečně vrací 13 soutěží, nikoli 14.
4. Všech 13 soutěží existuje v databázi ve dvojí kanonické identitě.
5. Databázovou strukturu není nutné plošně přestavět.
6. Je nutné opravit významové mapování a sjednotit identity soutěží a týmů.
7. Byla přesně odhalena chyba `B1`: belgická Jupiler Pro League byla historicky importována pod brazilskou Série A.
8. Správný belgický cíl je `league_id=20853`.
9. Bylo potvrzeno 21 dvojic belgických klubů vedených pod dvěma `team_id`.
10. Dry-run prokázal možnost zachovat 1 284 unikátních historických zápasů a rozpoznat 927 překryvů bez ztráty historie.
11. Současný veřejný model neobsahuje samostatnou providerovou mapu zápasů.
12. Žádná produkční data nebyla změněna.

---

# 6. Přijatá rozhodnutí

## 6.1 Zachování struktury

```text
ZACHOVAT:
- schémata staging, public, ops, documentation a work,
- existující veřejné tabulky,
- providerové mapy soutěží a týmů,
- kanonické vazby, dokud nebude schválena migrace,
- RAW a staging historii,
- původ jednotlivých providerových dat.
```

Nebude prováděn plošný rebuild databáze.

## 6.2 Role providerů

```text
API-Football
→ kandidát na hlavní detailní zdroj pro zápasy, PEOPLE a statistiky

Football-Data
→ aktuální CORE, záložní a validační zdroj

Football-Data UK
→ historický zdroj výsledků
```

## 6.3 Bezpečnost migrace

Zakázáno do schválení migračního plánu:

- mazat soutěže nebo týmy,
- přepisovat `league_id` a `team_id` bez auditu všech referencí,
- mazat překryvné zápasy bez zachování providerové identity,
- automaticky rozhodnout skutečné konflikty skóre,
- spouštět legacy import `football_data_uk_history_pull.py`,
- znovu použít kód `B1` pro brazilskou Série A.

---

# 7. Problémy a jejich řešení

| Problém | Zjištěná příčina | Přijaté řešení |
|---|---|---|
| A34 blokoval nečistý Git | pomocný neřízený soubor | soubor odstraněn, čistota nebyla obcházena |
| Token nebyl v remote procesu | uložen v `.env`, ne v procesním prostředí | token nebyl zveřejněn; využit uložený RAW payload |
| Předpoklad 14 soutěží | starší neověřený údaj | potvrzen skutečný počet 13 |
| Stejné soutěže pod dvěma ID | providerové importy vytvářely vlastní kanonické řádky | připravit sjednocení map, ne nový model celé DB |
| `EXACT_OVERLAP=0` | rozdílné týmové ID a čas 00:00 v CSV | porovnání podle normalizovaných týmů a data |
| Belgická historie pod Brazílií | chybný `ext_csv_code='B1'` | nalezen správný cíl Jupiler Pro League |
| Výpis končil `UnicodeEncodeError` | konzole `cp1250` | další audity spuštěny s UTF-8 |
| Chybí více providerových ID zápasu | `public.matches` má jen jednu dvojici ext_source/ext_match_id | připravit úzkou providerovou mapu nebo jiný schválený cílový mechanismus |

---

# 8. Databázový a Git stav

## 8.1 Dokumentační databáze

Poslední potvrzený stav po importu dubnového a květnového Project Snapshotu:

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

Dnešní fotbalové audity do databáze nic nezapsaly.

## 8.2 Git

```text
Repozitář           : C:\MatchMatrix-platform
Větev                : main
Poslední push commit : 498ad4c
Pracovní strom       : potvrzen jako čistý po dokončení A34 a panelu
```

Nové dokumenty `MM-DL-20260723` a `MM-NAV-20260723-01` zatím nejsou uložené ani commitnuté.

---

# 9. Rizika a otevřené otázky

1. Jak přesně uchovat více providerových identit jednoho kanonického zápasu?
2. Má vzniknout úzká tabulka `public.match_provider_map`, nebo bude použita jiná schválená struktura?
3. Které z nízkých a vysokých `league_id` budou po migraci kanonické u ostatních 12 soutěží?
4. Jak převést 18 skupin downstream vazeb při deduplikaci zápasů?
5. Jak ověřit dva skutečné konflikty skóre a jeden případ chybějícího skóre?
6. Jak opravit seed `029_leagues_set_csv_codes.sql`, aby se chyba `B1` nemohla vrátit?
7. Jak označit starý legacy import a jeho výstupy v governance, aniž by byla ztracena auditní historie?
8. Jak rozšířit stejné sjednocení z Belgie na zbývajících 12 soutěží?

---

# 10. Nedokončené práce

Dnes nebylo provedeno:

- žádné `UPDATE`, `DELETE`, `INSERT`, `TRUNCATE` ani migrace produkčních dat,
- sjednocení soutěžních `league_id`,
- sjednocení týmových `team_id`,
- přesun 1 284 historických zápasů,
- odstranění 927 překryvů,
- oprava dvou skutečných konfliktů skóre,
- změna seedu `B1`,
- vytvoření nové tabulky providerové identity zápasů,
- audit všech downstream tabulek před migrací,
- audit a oprava dalších 12 soutěží.

---

# 11. Plán pokračování

```text
A. uložit MM-DL-20260723 a MM-NAV-20260723-01
B. provést A17 a A23
C. schválit, commitnout a pushnout oba historické dokumenty
D. importovat je přes A24 a ověřit přes A7
E. navrhnout cílovou providerovou identitu kanonického zápasu
F. připravit přesný rollbackovatelný migrační plán pro Jupiler Pro League
G. auditovat všech 18 referenčních tabulek zápasu
H. samostatně vyřešit tři kontrolní případy skóre
I. opravit seed ext_csv_code B1
J. provést nejprve VALIDATE_ONLY / DRY RUN
K. po schválení aplikovat migraci Belgie
L. ověřit počty, vazby, provenienci a nulovou ztrátu historie
M. stejnou metodiku použít na zbývajících 12 soutěží
```

---

# 12. Jediný hlavní další krok

Uložit oba vytvořené dokumenty do:

```text
C:\MatchMatrix-platform\docs\09_HISTORY\DENNÍ_ZÁPISY\
C:\MatchMatrix-platform\docs\09_HISTORY\NAVÁZÁNÍ_NA_CHAT\
```

a načíst je v Q3 panelu pro A17 a A23.

Po jejich publikování je prvním technickým krokem nového chatu návrh bezpečné providerové identity kanonického zápasu.

---

# 13. Vazba na dokument NAVÁZÁNÍ

Aktualizace dokumentu NAVÁZÁNÍ je pro tento pracovní den potřebná, protože byly dokončeny významné změny a audity, na které musí další pracovní etapa přímo navázat.

Navazující dokument byl vytvořen:

```text
MM-NAV-20260723-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md
```



# 14. Související dokumenty a výstupy

| Vazba | Dokument nebo výstup |
|---|---|
| Navazující dokument | `MM-NAV-20260723-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Předchozí denní zápis | `MM-DL-20260722_MATCHMATRIX_DENNI_ZAPIS.md` |
| Předchozí NAV | `MM-NAV-20260722-01_MATCHMATRIX_NAVAZANI_DO_CHATU.md` |
| Providerový cílový model | `MM-PRV-008_DATOVY_MODEL_PROVIDER_REGISTRY_A_PROVIDER_MATRIX.md` |
| Budoucí implementační plán | `MM-PRV-009_IMPLEMENTACNI_PLAN_PROVIDER_REGISTRY_A_PROVIDER_MATRIX.md` |
| AI standard | `MM-STD-009_AI_CONTEXT_A_PROJECT_SNAPSHOT.md` |
| A33 | `25_1_A_33_EXPORT_DATABASE_STRUCTURE_AUDIT_V1.py` |
| A34 | `25_1_A_34_EXPORT_AI_CONTEXT_PACKAGE_V1.py` |
| Football-Data import | `ingest/Football-Data/football_data_pull_V6.py` |
| Legacy historický import | `legacy/ingest/football_data_uk_history_pull.py` |
| Chybný seed | `029_leagues_set_csv_codes.sql` |
| Šablona denního zápisu | `MM-TPL-002_SABLONA_DENNIHO_ZAPISU.md` |
| Šablona NAV | `MM-TPL-001_SABLONA_NAVAZANI_DO_NOVEHO_CHATU.md` |

---

# 15. Terminologická kontrola

| Použitý pojem | Český význam v tomto dokumentu |
|---|---|
| Canonical identity | Kanonická identita |
| Provider map | Providerová mapa |
| Match provider identity | Providerová identita zápasu |
| Dry run | Zkušební běh bez zápisu |
| Overlap | Datový překryv |
| Provenance | Původ a dohledatelnost dat |
| Legacy import | Historický import, který již není aktivní cílovou cestou |
| CORE | Základní soutěžní, týmová a zápasová data |
| PEOPLE | Hráči, trenéři a související osoby |
| Downstream reference | Následná databázová vazba závislá na kanonickém záznamu |

Technické názvy tabulek, providerů a stavových kódů zůstávají v původním tvaru kvůli přesné dohledatelnosti.

---

# 16. Historie verzí

| Verze | Datum | Stav | Popis |
|---|---|---|---|
| 1.0 | 2026-07-23 | DRAFT – NEEDS_USER_APPROVAL | Denní zápis dokončení A34 a panelu, potvrzení 13 soutěží Football-Data, odhalení dvojích fotbalových identit, chyby `B1`, belgické týmové duplicity, výsledku dry-runu a chybějící providerové mapy zápasů. |

---

# Závěr dokumentu

Dne 2026-07-23 byl dokončen A34 AI Context Package Exporter a jeho panelové ovládání. Následně byl proveden rozsáhlý read-only audit fotbalové providerové struktury.

Audit potvrdil, že stávající databázovou architekturu není nutné plošně nahrazovat. Hlavním problémem jsou historicky oddělené kanonické identity soutěží, týmů a zápasů. Nejvýraznější konkrétní chyba byla přesně lokalizována: CSV kód `B1` přivedl 2 214 belgických historických zápasů pod brazilskou Série A.

Správným cílem je existující Jupiler Pro League `league_id=20853`. Dry-run potvrdil možnost zachovat 1 284 unikátních historických zápasů, rozpoznat 927 překryvů a oddělit tři kontrolní případy. Před samotnou migrací však musí být vyřešena providerová identita kanonického zápasu, protože `public.matches` dnes uchovává pouze jedno externí ID a je na něj napojeno 18 dalších tabulek.

Databáze nebyla během těchto auditů změněna.
