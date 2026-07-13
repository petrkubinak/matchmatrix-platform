# MM-PS-20260223

# MATCHMATRIX PROJECT SNAPSHOT – ÚNOR 2026

## HISTORICKÝ PROJEKTOVÝ CHECKPOINT

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PS-20260223 |
| Název dokumentu | MatchMatrix Project Snapshot – únor 2026 |
| Typ dokumentu | PROJECT_SNAPSHOT |
| Charakter dokumentu | Historický projektový checkpoint |
| Edice | HISTORY / MM-DOC TECH |
| Verze | 1.1 |
| Původní stav zdrojového dokumentu | REVIEW |
| Datum snapshotu | 2026-02-23 |
| Rekonstruované období | 2026-02-16 až 2026-02-23 |
| Přímé zdrojové pokrytí checkpointu | 2026-02-16 až 2026-02-23 |
| Kontrolní rozšířená rekonstrukce | 2026-02-16 až 2026-02-28 |
| Předchozí checkpoint | První doložený historický checkpoint |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Projekt | MatchMatrix-platform |
| Primární formát | Markdown (.md) |
| Doporučené umístění | `docs/09_HISTORY/PROJECT_SNAPSHOTS/MM-PS-20260223_MATCHMATRIX_PROJECT_SNAPSHOT_UNOR_2026.md` |
| Zdroj pravdy | Ověřený historický korpus MatchMatrix a redakčně zkontrolovaná rekonstrukce |
| Přímé zdrojové dokumenty | MM-HIS-0032, MM-HIS-0033, MM-HIS-0034, MM-HIS-0035, MM-HIS-0036 |
| Počet přímých zdrojových dokumentů | 5 |
| Kontrolní měsíční korpus | `reports/documentation/history_review/history_complete_month_corpus_2026_02_latest.*` |
| Redakční rekonstrukce | `reports/documentation/history_review/history_reconstruction_20260216_20260228_working_report_v2_reviewed.md` |
| Původní verze | Commit `eff3ce31645faba914ebfc044d3e33d4c5aaa1a0`, větev `docs/tech-review-corpus-update` |

---

## Upozornění k použití

Tento dokument je **historický projektový checkpoint k 23. únoru 2026**.

Nejde o popis současného produkčního stavu platformy. Názvy skriptů, tabulek, adresářů, providerů, modelů, počty záznamů, limity API a tehdejší návrhy technologií musí být před dnešním použitím porovnány s aktuální databází, Git repozitářem a řízenou dokumentací.

Rozšířená rekonstrukce pokrývá celý zbytek února do 28. 2. 2026. Informace vzniklé po datu checkpointu však nejsou zpětně vydávány za stav k 23. 2. 2026. Slouží pouze ke kontrole konzistence a k přesnějšímu oddělení:

- existujících technických částí,
- experimentálního runtime stavu,
- cílové architektury,
- produktové vize,
- plánovaných dalších kroků.

Používaná důkazní klasifikace:

| Klasifikace | Význam |
|---|---|
| RUNTIME EVIDENCE | Existuje konkrétní počet, výsledek, datový stav nebo popis běhu |
| IMPLEMENTED | Existuje konkrétní skript, tabulka, model nebo implementovaná logika |
| TECH READY | Technický objekt nebo návrh existuje, ale plný provoz není potvrzen |
| PARTIAL | Funguje jen omezená část toku, provider, liga, entita nebo experiment |
| EXPERIMENTAL | Výsledek je ověřen pouze v rané analytické nebo modelové fázi |
| PLANNED | Jde o plán, roadmapu nebo cílový produkt |
| CLAIM REQUIRING CAUTION | Formulace je širší než doložený rozsah |

---

# 1. Účel checkpointu

Cílem dokumentu je zachytit nejstarší ucelený a doložený stav projektu MatchMatrix v období 16.–23. února 2026.

Checkpoint má odpovědět zejména na otázky:

- co již v projektu skutečně existovalo,
- co bylo implementováno jen částečně,
- které modely a datové toky byly experimentálně používány,
- jak byla formulována produktová vize,
- jak vznikal TicketMatrix,
- jak se začala připravovat providerová expanze,
- proč vznikl požadavek na Owner/Operator centrum,
- které dlouhodobé principy se později staly základem platformy.

Checkpoint nemá tvrdit, že MatchMatrix byl v únoru 2026 hotovou produkční službou.

---

# 2. AI CONTEXT

Při použití tohoto dokumentu musí AI respektovat následující pravidla:

1. Jde o stav rekonstruovaný k 23. 2. 2026.
2. Tehdejší architektura byla převážně fotbalová.
3. Přítomnost skriptu nebo tabulky neznamená automaticky stabilní end-to-end provoz.
4. Historické označení „kompletní“, „produkční“ nebo „funkční“ se smí vztahovat pouze k doloženému rozsahu.
5. Web ve stylu Livesport, mobilní rozhraní, předplatné a affiliate vrstva byly plánované.
6. Administrační panel a Autopilot byly cílovou architekturou, nikoli hotovým provozním systémem.
7. Ratingy a modely existovaly, ale byly v rané experimentální fázi.
8. Providerová data nesměla bez kontroly přepisovat canonical entity.
9. Rozšíření na více lig, sportů a providerů bylo strategickým směrem.
10. Aktuální stav musí být ověřen v současné DB a dokumentaci.
11. Pozdější zdroje z 24.–28. 2. nesmějí měnit historický stav checkpointu k 23. 2.
12. Projekt se měl rozvíjet v pořadí: data → řízení provozu → rozšíření → veřejný produkt.

### Hlavní interpretační pravidlo

```text
EXISTUJÍCÍ TECHNICKÁ KOMPONENTA
≠
OVĚŘENÝ END-TO-END PROVOZ
≠
PRODUKČNÍ PŘIPRAVENOST
≠
HOTOVÝ UŽIVATELSKÝ PRODUKT
```

---

# 3. PROJECT SNAPSHOT

## 3.1 Celkový obraz období

V období 16.–23. února 2026 se MatchMatrix formoval jako konkrétní sportovní datová a analytická platforma.

Projekt již obsahoval nebo popisoval:

- import historických a aktuálních fotbalových dat,
- import kurzů,
- vlastní ratingový systém,
- trénink modelů,
- ukládání predikcí,
- výpočet fair odds a value,
- ranou logiku blokových tiketů,
- databázovou vrstvu v PostgreSQL,
- providerové mapování,
- návrh integrace API-Football,
- požadavek na interní Owner/Operator centrum.

Současně byla formulována širší produktová vize:

- web ve stylu Livesport,
- TicketMatrix,
- uživatelské účty,
- placené úrovně,
- personalizace,
- historie tiketů,
- budoucí komerční a affiliate vrstva.

Nejdůležitějším výsledkem nebyla hotová platforma, ale vznik propojeného technického a produktového směru.

## 3.2 Vývoj v průběhu týdne

### 16. 2. 2026 – analytické jádro a projektový souhrn

Zdroj `MM-HIS-0032` popisuje:

- vlastní rating inspirovaný systémem Elo,
- tabulky `mm_match_ratings` a `mm_team_ratings`,
- model Logistic Regression,
- model Gradient Boosting,
- vlastnosti založené na formě, odpočinku, H2H a ratingu,
- fair odds,
- expected value,
- Kelly fraction,
- balance score a block score.

Uvedené modelové metriky a výslovně slabší třída remíza potvrzují ranou experimentální fázi.

### 19. 2. 2026 – produktová vize TicketMatrix

Zdroj `MM-HIS-0033` rozpracovává:

- přehled zápasů ve stylu Livesport,
- výběr zápasů uživatelem,
- konstanty a bloky,
- nejvýše tři zápasy v bloku,
- nejvýše tři bloky,
- pravděpodobnost průchodu tiketu,
- historii a vyhodnocování tiketů,
- tisknutelné výstupy a budoucí bookmaker odkazy,
- placené úrovně přístupu.

Důležité pravidlo:

> Predikce a pravděpodobnosti mají být prezentovány jako odhad, nikoli jako garance.

### 21. 2. 2026 – formalizace technické pipeline

Zdroj `MM-HIS-0034` eviduje konkrétní skripty a návaznosti mezi:

- historickým importem,
- aktuálním importem,
- TheOdds,
- MMR ratingy,
- ML datasetem,
- Logistic Regression,
- GBM,
- generováním predikcí,
- value vrstvou,
- Ticket Engine.

Jde o nejsilnější důkaz, že projekt měl skutečné technické komponenty a definovaný pracovní tok.

### 23. 2. 2026 – providerová expanze a provozní řízení

Zdroje `MM-HIS-0035` a `MM-HIS-0036` potvrzují:

- přípravu integrace API-Football,
- existující merge logiku `public.merge_team()`,
- limit 100 API požadavků denně,
- potřebu minimalizovat requesty,
- potřebu evidovat běhy, stav, počet záznamů a logy,
- oddělení veřejného produktu od interního řídicího prostředí,
- plán budoucího Owner/Operator centra.

Zdroj současně výslovně uvádí, že veřejný web ještě neexistoval a skutečný základ tvořila databáze napojená na Football Data a TheOdds.

---

# 4. Produktová vize

## 4.1 Veřejný uživatelský produkt

Cílový produkt měl umožnit:

- výběr sportu,
- výběr země a ligy,
- časový filtr zápasů,
- zobrazení kurzů,
- statistiky týmů,
- vlastní ratingy,
- modelové pravděpodobnosti,
- value a edge,
- výběr zápasů do TicketMatrix,
- ukládání a následné vyhodnocování tiketů.

K 23. 2. 2026 šlo o návrh produktu, nikoli o hotový web.

## 4.2 TicketMatrix

TicketMatrix byl koncipován jako samostatná vrstva nad zápasy, kurzy a predikcemi.

Základní principy:

- zápas mohl být konstanta nebo součást bloku,
- blok mohl obsahovat nejvýše tři zápasy,
- mohly existovat nejvýše tři bloky,
- blok se choval jako jedna logická jednotka,
- kombinace tří bloků mohla vytvořit až 27 variant,
- každá varianta měla mít kurz, pravděpodobnost a rizikový profil,
- vytvořené tikety se měly ukládat a vyhodnocovat.

Tato logika byla v únoru především produktovým a analytickým návrhem. Úplný produkční generátor tiketů nebyl doložen.

## 4.3 Obchodní model

Byly navrženy úrovně:

- Free,
- Basic,
- Pro,
- Elite.

Rozdíly měly spočívat v rozsahu:

- dat,
- filtrů,
- predikcí,
- fair odds,
- value,
- blokových variant,
- pokročilých metrik,
- řízení rizika.

Ceny, platební systém a konkrétní ekonomický model nebyly potvrzeny jako implementované.

---

# 5. DATABASE SNAPSHOT

## 5.1 Historické databázové oblasti

Zdroje uvádějí zejména:

- `sports`,
- `leagues`,
- `teams`,
- `league_teams`,
- `team_aliases`,
- `matches`,
- `match_features`,
- `odds`,
- `bookmakers`,
- `markets`,
- `market_outcomes`,
- `ml_predictions`,
- `mm_match_ratings`,
- `mm_team_ratings`,
- `api_import_runs`,
- `api_raw_payloads`,
- tabulky nebo výstupy `generated_*`.

Jde o historickou architekturu. Názvy nesmějí být automaticky považovány za dnešní canonical model.

## 5.2 Historický datový tok

```text
HISTORICKÁ A AKTUÁLNÍ MATCH DATA
    → RAW / IMPORTNÍ VRSTVA
    → SPORTS / LEAGUES / TEAMS / MATCHES

ODDS DATA
    → BOOKMAKERS / MARKETS / MARKET OUTCOMES / ODDS

MATCH DATA
    → MMR RATINGS
    → ML DATASET
    → MODEL TRAINING
    → PREDICTIONS
    → FAIR ODDS / VALUE / EDGE
    → TICKETMATRIX
```

## 5.3 Historické počty

Zdroj `MM-HIS-0032` uvádí přibližně:

- 27 598 zpracovaných zápasů,
- 304 týmů v ratingové tabulce.

Tyto hodnoty jsou historické, vztahují se k tehdejšímu zdroji a nejsou současným stavem databáze.

## 5.4 Kontrolní oblasti

Jako potřebné kontroly byly uváděny:

- budoucí zápasy,
- ligy bez kurzů,
- unmatched týmy,
- zápasy bez ratingu,
- počty predikcí,
- chybějící aliasy,
- duplicity providerových identifikátorů,
- referenční integrita.

Úplný automatizovaný governance systém nebyl v tomto checkpointu doložen.

---

# 6. Analytická a ML vrstva

## 6.1 Rating

Byl používán vlastní rating inspirovaný Elo:

- oddělený podle lig,
- aktualizovaný po zápase,
- ukládaný pro zápasy a týmy,
- používaný jako vstupní vlastnost modelu.

## 6.2 Modely

Historické zdroje uvádějí:

- Logistic Regression,
- Gradient Boosting,
- formu z posledních zápasů,
- rest days,
- H2H rozdíl,
- ratingový rozdíl.

Modely byly v rané experimentální fázi. Remíza byla uváděna jako nejslabší třída.

## 6.3 Modelové metriky

Zdroj uváděl přibližně:

- balanced accuracy kolem 0,46 až 0,47 pro baseline,
- balanced accuracy kolem 0,455 pro GBM,
- log loss kolem 0,98.

Tyto metriky jsou historickým záznamem experimentu. Neprokazují produkční kvalitu ani současnou výkonnost modelů.

## 6.4 Value logika

Byly popisovány:

- fair odds,
- expected value,
- Kelly fraction,
- minimální kurzové filtry,
- balance score,
- block score,
- budoucí backtesting.

Část analytických výpočtů existovala, ale úplný produkční betting workflow nebyl potvrzen.

---

# 7. Provider snapshot

## 7.1 Používané nebo plánované zdroje

- football-data.co.uk,
- football-data.org,
- TheOdds API,
- API-Sports / API-Football.

## 7.2 API-Football

K 23. 2. 2026 byla připravována integrace pro:

- ligy,
- týmy,
- fixtures,
- později odds a další entity.

Jako důležitá omezení byly uvedeny:

- limit 100 požadavků denně,
- potřeba minimalizovat requesty,
- požadavek na incremental ingest,
- zachování externího zdroje,
- řízený merge do canonical vrstvy.

## 7.3 Providerová pravidla

Dlouhodobě významné principy:

1. providerová data nesmějí bez kontroly přepisovat canonical entity;
2. musí být zachován `ext_source`;
3. mapování musí být auditovatelné;
4. duplicity musí být kontrolovány;
5. alias coverage musí být měřitelná;
6. architektura musí podporovat více providerů;
7. budoucí rozšíření nesmí být vázáno jen na fotbal;
8. API spotřeba musí být řízena.

---

# 8. Operator / Owner snapshot

## 8.1 Vznik požadavku

Dne 23. 2. 2026 byl jasně oddělen:

- veřejný produkt pro zákazníky,
- interní řídicí prostředí pro vlastníka projektu.

Tím vznikl základ budoucího Operator panelu.

## 8.2 Požadované funkce

Owner/Operator centrum mělo umožnit:

- spustit import,
- nastavit parametry,
- zapnout nebo vypnout automatický režim,
- zobrazit poslední běhy,
- evidovat stav OK / FAIL,
- zobrazit počet zpracovaných záznamů,
- sledovat API limity,
- zobrazit chyby a logy,
- kontrolovat kvalitu dat,
- spouštět ratingy a predikce,
- provádět databázovou údržbu.

Později měly přibýt obchodní a uživatelské metriky.

## 8.3 Doložený stav

K datu checkpointu šlo převážně o návrh a roadmapu.

Nebyly doloženy:

- hotový admin web,
- centrální scheduler,
- plně automatický Autopilot,
- kompletní provozní dashboard,
- stabilní unattended provoz.

---

# 9. CURRENT STATUS K 2026-02-23

## 9.1 Doložený nebo přiměřeně potvrzený stav

| Oblast | Stav | Výklad |
|---|---|---|
| PostgreSQL a datový základ | PARTIAL / IMPLEMENTED FOUNDATION | Databáze a základní objekty existují |
| Historický a aktuální fotbalový ingest | PARTIAL | Existují skripty a popsané běhy, úplný stabilní provoz není doložen |
| Odds ingest | PARTIAL | TheOdds je součástí pipeline |
| MMR rating | IMPLEMENTED / EXPERIMENTAL | Ratingová vrstva existuje |
| ML modely | EXPERIMENTAL | Existují minimálně Logistic Regression a GBM |
| Predikce a value | PARTIAL / EXPERIMENTAL | Technické části existují, kvalita a opakovatelnost nejsou plně potvrzeny |
| TicketMatrix | PLANNED / EARLY DESIGN | Logika je popsána, produkční produkt není doložen |
| API-Football integrace | PARTIAL / IN PREPARATION | Architektura a některé technické části jsou připraveny |
| Canonical merge | IMPLEMENTED PRINCIPLE | Je doložena logika `public.merge_team()` |
| Owner/Operator centrum | PLANNED | Funkce a směr jsou popsány |
| Veřejný web | PLANNED | Dokument výslovně potvrzuje, že ještě neexistoval |
| Multisport | STRATEGIC DIRECTION | Budoucí směr, nikoli tehdejší pokrytí |

## 9.2 Co nebylo potvrzeno

- plně automatický end-to-end denní provoz,
- stabilní unattended harvest,
- produkční veřejný web,
- uživatelské účty a předplatné,
- hotový Operator panel,
- plný Ticket Engine,
- kompletní multi-provider governance,
- kompletní multisportovní pokrytí,
- produkční kvalita modelů,
- systematický backtesting a dlouhodobé vyhodnocení.

---

# 10. Klíčová rozhodnutí

## 10.1 Data před veřejným webem

Nejdříve musí vzniknout stabilní, auditovatelná a automatizovatelná datová platforma. Veřejný produkt má být stavěn až nad spolehlivými daty.

## 10.2 Provider není vlastník canonical identity

Provider dodává data, ale nesmí nekontrolovaně určovat canonical identitu lig, týmů, zápasů ani dalších entit.

## 10.3 MatchMatrix má být rozšiřitelný

Architektura nemá zůstat trvale závislá na jednom providerovi ani pouze na fotbalu.

## 10.4 TicketMatrix je samostatná produktová vrstva

TicketMatrix má vlastní logiku:

- výběru,
- bloků,
- variant,
- pravděpodobností,
- rizika,
- ukládání,
- vyhodnocování.

## 10.5 Projekt potřebuje Operator centrum

Velká datová platforma nemůže být dlouhodobě provozována pouze jednotlivými ručními příkazy a izolovanými skripty.

## 10.6 Pravděpodobnost není garance

Predikce a confidence musí být prezentovány jako odhad s omezením, nikoli jako slib výsledku.

---

# 11. OPEN QUESTIONS K 2026-02-23

- Jak bude vypadat konečná canonical architektura lig, týmů a zápasů?
- Jak bude řízeno mapování více providerů?
- Jak budou ukládány providerové vazby a aliasy?
- Jak bude fungovat scheduler a job runner?
- Jak bude evidován každý běh, stav, počet a chyba?
- Které ligy a sporty budou mít nejvyšší prioritu?
- Jak bude řešeno verzování modelů?
- Jak bude probíhat backtesting?
- Jak bude měřena kvalita predikcí a tiketů?
- Jak bude oddělena modelová pravděpodobnost, confidence a ticket success probability?
- Jak bude navržen uživatelský a platební systém?
- Jaké providerové licence budou potřeba?
- Kdy bude technický základ dostatečně stabilní pro veřejný web?

---

# 12. NEXT STEP DEFINOVANÝ V ÚNORU 2026

Za správnou posloupnost další práce bylo považováno:

1. stabilizovat ingest;
2. zavést řízené ingest targets;
3. zavést evidenci job runs;
4. doplnit logy, počty a stavové kontroly;
5. stabilizovat merge a canonical ochranu;
6. doplnit audit duplicit a integrity;
7. vytvořit interní Owner/Operator MVP;
8. teprve potom rozšiřovat ligy, sporty a providery;
9. veřejný web stavět až nad stabilní platformou;
10. průběžně zlepšovat modely a ověřovat jejich skutečnou kvalitu.

---

# 13. Vztah k pozdějšímu vývoji

## 13.1 Dlouhodobě platné principy

Do dalšího vývoje přešly zejména:

- multisportovní směr,
- oddělení providerové a canonical vrstvy,
- řízené mapování entit,
- důraz na audit a kvalitu dat,
- potřeba Operator panelu,
- oddělení interního řízení a veřejného produktu,
- TicketMatrix jako samostatná vrstva,
- priorita robustních dat před komerčním webem,
- řízení projektové dokumentace pomocí checkpointů.

## 13.2 Historické prvky

Pouze jako historie mají být chápány:

- tehdejší názvy skriptů,
- `.bat` workflow,
- původní adresářové cesty,
- tehdejší databázové názvy,
- původní modelové metriky,
- tehdejší počty záznamů,
- tehdejší limity bez aktuálního ověření,
- konkrétní návrhy technologií, které později mohly být nahrazeny.

---

# 14. Mapování do dokumentačních oblastí

| Oblast | Přenášená znalost |
|---|---|
| 01_MASTER | Vize, cílový produkt a strategická posloupnost |
| 02_GOVERNANCE | Canonical ochrana a providerová pravidla |
| 03_ARCHITECTURE | Datový tok, analytické vrstvy a rozšiřitelnost |
| 04_DATABASE | Historický databázový model |
| 05_PROVIDERS | Počátky provider abstraction a API-Football |
| 06_LAYERS | Ratingy, ML, value, odds a TicketMatrix |
| 07_OPERATOR | Owner/Operator centrum a řízení běhů |
| 08_DEVELOPMENT | Skripty, audity, logy a provozní workflow |
| 09_HISTORY | Časově ukotvený projektový checkpoint |
| 16_DECISIONS | Dlouhodobá architektonická a produktová rozhodnutí |

---

# 15. Závěr checkpointu

V období 16.–23. února 2026 se MatchMatrix posunul od izolovanějšího fotbalového analytického řešení k ucelené představě datové, analytické a produktové platformy.

Doložené přínosy:

- existující datový a databázový základ,
- konkrétní ratingové a modelové komponenty,
- definovaná pipeline od dat k predikcím,
- raná value a ticket logika,
- příprava API-Football integrace,
- formulace canonical ochrany,
- vznik požadavku na Operator centrum,
- jasná produktová a komerční vize.

Hlavní omezení:

- chybí důkaz plně stabilního end-to-end provozu,
- analytika je experimentální,
- veřejný web neexistuje,
- Operator panel a Autopilot jsou plánované,
- TicketMatrix není doložen jako dokončený produkt,
- multisport a rozsáhlá providerová expanze jsou strategickým směrem.

Nejdůležitější historický závěr:

> **Nejdříve kvalitní data, řízení, audit a automatizace. Potom rozšiřování, veřejný produkt a komerční růst.**

Tento dokument má zůstat oficiálním únorovým checkpointem s identitou `MM-PS-20260223`. Nový paralelní dokument `MM-PS-20260228` se nevytváří, protože by vznikly dva konkurenční únorové Project Snapshoty.

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---|---:|---|---|
| 1.0 | 2026-07-05 | REVIEW | První syntetický checkpoint z MM-HIS-0032 až MM-HIS-0036 |
| 1.1 | 2026-07-13 | REVIEW | Obnovení do aktivní dokumentační větve, oprava kódování, zpřesnění důkazního rozsahu a oddělení implementace od plánů |

---

*Konec dokumentu MM-PS-20260223.*
