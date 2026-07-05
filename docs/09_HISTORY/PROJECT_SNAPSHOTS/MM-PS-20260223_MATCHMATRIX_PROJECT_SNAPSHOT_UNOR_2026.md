# MM-PS-20260223

# MATCHMATRIX PROJECT SNAPSHOT – ÚNOR 2026

## HISTORICKÝ PROJEKTOVÝ CHECKPOINT

---

## Informace o dokumentu

| Položka | Hodnota |
|---|---|
| Dokument | MM-PS-20260223 |
| Název | MatchMatrix Project Snapshot – únor 2026 |
| Typ | Project Snapshot / historický projektový checkpoint |
| Edice | MM-DOC TECH |
| Verze | 1.0 |
| Stav | REVIEW |
| Datum snapshotu | 2026-02-23 |
| Rekonstruované období | 2026-02-16 až 2026-02-23 |
| Autor projektu | Petr |
| Technická spolupráce | OpenAI ChatGPT |
| Primární formát | Markdown (.md) |
| Doporučené umístění | `docs/09_HISTORY/PROJECT_SNAPSHOTS/MM-PS-20260223_MATCHMATRIX_PROJECT_SNAPSHOT_UNOR_2026.md` |
| Zdroj pravdy | Databázový historický korpus MatchMatrix |
| Zdrojové dokumenty | MM-HIS-0032, MM-HIS-0033, MM-HIS-0034, MM-HIS-0035, MM-HIS-0036 |

---

## Upozornění k použití

Tento dokument je **historický projektový checkpoint**. Popisuje stav, vizi, rozhodnutí a plán projektu MatchMatrix k období 16.–23. února 2026.

Nejde o popis současného produkčního stavu platformy. Názvy skriptů, tabulek, adresářů, počty záznamů, limity API a návrhy technologií uvedené v tomto dokumentu musí být před použitím porovnány s aktuální architekturou a databází.

Dokument nesmí být použit jako náhrada aktuálního Project Snapshotu. Slouží jako časově ukotvený důkaz vývoje projektu a jako zdroj pro aktualizaci hlavních dokumentů MatchMatrix.

---

# 1. Účel checkpointu

Cílem dokumentu je rekonstruovat nejstarší ucelený stav projektu MatchMatrix uložený v databázovém historickém korpusu.

Checkpoint zachycuje:

- původní smysl projektu,
- tehdejší datovou a analytickou architekturu,
- vznik širší produktové vize,
- počátky TicketMatrix,
- první providerovou expanzi,
- vznik požadavku na Owner/Operator centrum,
- implementované části,
- návrhy, které tehdy ještě nebyly realizovány,
- rozhodnutí, která ovlivnila další vývoj platformy.

---

# 2. Metodika rekonstrukce

Checkpoint byl vytvořen syntézou následujících historických dokumentů:

| Zdroj | Datum | Hlavní přínos |
|---|---:|---|
| MM-HIS-0032 | 2026-02-16 | Kompletní projektový souhrn, analytické jádro, MMR, ML a value |
| MM-HIS-0033 | 2026-02-19 | Produktová vize, web, TicketMatrix, placené úrovně |
| MM-HIS-0034 | 2026-02-21 | Přehled pipeline, skriptů, tabulek a kontrolních kroků |
| MM-HIS-0035 | 2026-02-23 | Integrace API-Sports / API-Football a providerová pravidla |
| MM-HIS-0036 | 2026-02-23 | Owner/Operator centrum, provozní monitoring a priorita robustních dat |

Při syntéze byly informace rozděleny do tří skupin:

1. **prokazatelně implementovaný stav k datu checkpointu,**
2. **schválená nebo formulovaná vize a architektonický směr,**
3. **návrhy a otevřené body bez potvrzené implementace.**

---

# 3. AI CONTEXT

MatchMatrix byl v únoru 2026 rozvíjen jako sportovní datová a analytická platforma s počátečním zaměřením na fotbal.

Projekt již nebyl chápán pouze jako databáze výsledků. Cílová vize zahrnovala propojení:

- sportovních dat,
- historických výsledků,
- kurzů bookmakerů,
- vlastních ratingů,
- strojového učení,
- value analýzy,
- TicketMatrix,
- uživatelského webu,
- placených účtů,
- interního provozního řízení.

Základním strategickým problémem bylo rozhodnutí, zda nejprve rozšiřovat počet lig a sportů, nebo nejdříve stabilizovat datový provoz. Z historických zdrojů vyplývá preferovaný směr:

> Nejprve vytvořit robustní datovou, providerovou a provozní platformu. Veřejný placený web stavět až nad stabilními a kontrolovanými daty.

---

# 4. PROJECT SNAPSHOT

## 4.1 Původní zaměření

K 16. únoru 2026 byl MatchMatrix především fotbalovým analytickým systémem zaměřeným na:

- predikci výsledků zápasů,
- identifikaci value příležitostí,
- generování blokových tiketů,
- budoucí komerční webovou službu,
- dlouhodobé vyhodnocování pravděpodobností a výsledků.

Projekt byl popisován jako pokročilé analytické jádro, nikoli jako dokončený veřejný produkt.

## 4.2 Rozšíření produktové vize

Do 19. února 2026 byla formulována širší platforma podobná z hlediska orientace uživatele službám typu Livesport, ale s vlastní analytickou a tiketovou vrstvou.

Cílový uživatelský produkt měl obsahovat:

- výběr sportu,
- výběr země, ligy a časového období,
- seznam zápasů,
- kurzy více bookmakerů,
- statistiky týmů a zápasů,
- poslední výsledky a vzájemné zápasy,
- domácí a venkovní sílu,
- vlastní ratingy a predikce,
- výběr zápasů do TicketMatrix,
- historii vytvořených tiketů,
- následné vyhodnocení úspěšnosti.

## 4.3 TicketMatrix

TicketMatrix byl navržen jako vlastní produktová vrstva nad zápasy, kurzy a predikcemi.

Základní principy:

- zápas mohl být použit jako konstanta nebo součást bloku,
- maximálně tři bloky,
- každý blok mohl obsahovat maximálně tři zápasy,
- blok se choval jako jedna logická jednotka,
- tři bloky mohly vytvořit až 27 variant tiketů,
- uživatel měl vidět kurz, pravděpodobnost, potenciální výhru a riziko jednotlivých variant,
- vytvořené tikety měly být ukládány a později vyhodnocovány.

Bylo rozlišováno mezi:

- pravděpodobností průchodu tiketu,
- důvěryhodností modelové predikce,
- value / expected value,
- celkovým rizikem souboru tiketů.

## 4.4 Obchodní a uživatelský směr

V únoru 2026 byly navrženy čtyři úrovně služby:

- Free,
- Basic,
- Pro,
- Elite.

Jednotlivé úrovně se měly lišit rozsahem:

- zobrazovaných dat,
- dostupných filtrů,
- predikcí,
- fair odds,
- value a edge,
- blokových variant,
- portfoliových metrik,
- pokročilých pravidel rizika.

Ceny, platební systém a konkrétní ekonomický model v této fázi nebyly potvrzeny.

---

# 5. DATABASE SNAPSHOT

## 5.1 Tehdejší hlavní databázové oblasti

Historické dokumenty uvádějí zejména tyto tabulky a oblasti:

- `matches`,
- `match_features`,
- `odds`,
- `ml_predictions`,
- `mm_match_ratings`,
- `mm_team_ratings`,
- tabulky `generated_*`,
- `sports`,
- `leagues`,
- `teams`,
- `league_teams`,
- `team_aliases`,
- `bookmakers`,
- `markets`,
- `market_outcomes`,
- `api_import_runs`,
- `api_raw_payloads`.

Uvedené názvy popisují historickou architekturu a nesmí být automaticky považovány za dnešní canonical model.

## 5.2 Historický datový tok

K 21. únoru 2026 byl datový tok popsán přibližně takto:

```text
MATCH DATA INGEST
    → RAW
    → SPORTS / LEAGUES / TEAMS / MATCHES

ODDS INGEST
    → RAW
    → BOOKMAKERS / MARKETS / MARKET OUTCOMES / ODDS

MATCH DATA
    → MMR RATINGS
    → ML DATASET
    → MODEL TRAINING
    → PREDICTIONS
    → FAIR ODDS / VALUE / EDGE
    → TICKET ENGINE
```

## 5.3 Historické kontrolní oblasti

Pravidelně se mělo kontrolovat:

- počet budoucích zápasů,
- ligy bez kurzů,
- unmatched týmy,
- zápasy bez ratingu,
- počet predikcí podle modelu,
- chybějící aliasy,
- duplicity providerových identifikátorů,
- referenční integrita.

## 5.4 Historické počty

Dokument MM-HIS-0032 uváděl přibližně:

- 27 598 zpracovaných zápasů,
- 304 týmů v ratingové tabulce.

Tyto hodnoty jsou historické a nejsou současným stavem databáze.

---

# 6. ANALYTICKÁ A ML VRSTVA

## 6.1 MMR rating

Byl implementován vlastní rating inspirovaný systémem ELO:

- odděleně podle lig,
- aktualizovaný po zápase,
- ukládaný pro zápas a tým,
- používaný jako vstup do modelu.

Používané atributy zahrnovaly například:

- rating domácího týmu,
- rating hostujícího týmu,
- rozdíl ratingů.

## 6.2 Modely

Historické zdroje uvádějí:

- baseline model Logistic Regression,
- Gradient Boosting model,
- formu z posledních zápasů,
- odpočinek mezi zápasy,
- rozdíl H2H,
- rozdíl ratingů.

Bylo konstatováno, že remíza byla nejslabší predikovanou třídou.

Konkrétní metriky modelů jsou pouze historickým záznamem a nejsou platným hodnocením současné ML vrstvy.

## 6.3 Value logika

Používané nebo plánované principy:

- fair odds jako převrácená hodnota modelové pravděpodobnosti,
- expected value,
- Kelly fraction,
- balance score,
- block score,
- filtry minimálního kurzu,
- pozdější historický backtesting.

---

# 7. PROVIDER SNAPSHOT

## 7.1 Původní zdroje

Historická pipeline používala nebo plánovala používat zejména:

- football-data.co.uk,
- football-data.org,
- TheOdds API,
- API-Sports / API-Football.

## 7.2 API-Sports / API-Football

Dne 23. února 2026 byl definován nový směr integrace API-Sports jako významného provideru pro:

- ligy,
- týmy,
- fixtures,
- pozdější rozšíření na další sporty.

Jako první testovací oblast byla uváděna MLS.

## 7.3 Providerová pravidla

Již v únoru byly formulovány důležité principy:

- providerová data nesmí bez kontroly přepisovat canonical entity,
- musí být zachován `ext_source`,
- merge musí probíhat řízeně,
- musí existovat kontrola duplicit,
- musí být auditována alias coverage,
- musí být kontrolována referenční integrita,
- architektura musí být rozšiřitelná na další sporty,
- počet API požadavků musí být řízen a minimalizován.

Tyto principy jsou dlouhodobě platné, i když jejich technická implementace se později změnila.

---

# 8. OPERATOR / OWNER SNAPSHOT

## 8.1 Vznik požadavku

Dne 23. února 2026 byl jasně oddělen:

- veřejný produkt pro zákazníky,
- interní řídicí prostředí pro vlastníka a administrátora projektu.

Tím vznikl základ budoucího Operator panelu.

## 8.2 Požadované funkce

Owner/Operator centrum mělo umožnit:

- spustit import,
- nastavit parametry běhu,
- aktivovat nebo vypnout automatický režim,
- zobrazit poslední běhy,
- zobrazit stav OK / FAIL,
- zobrazit počet zpracovaných záznamů,
- sledovat API limity,
- zobrazit chyby a logy,
- kontrolovat kvalitu dat,
- spouštět ratingy a predikce,
- provádět databázovou údržbu,
- později sledovat uživatele, předplatné, výnosy a churn.

## 8.3 Strategická priorita

Byla doporučena tato posloupnost:

1. robustní ingest a data,
2. řízení jobů a kvality,
3. rozšiřování lig a sportů,
4. veřejný web,
5. komerční a uživatelská vrstva.

---

# 9. CURRENT STATUS K 2026-02-23

## 9.1 Prokazatelně existující nebo označené jako funkční

Historické zdroje uvádějí jako funkční:

- základní datovou pipeline,
- import historických a aktuálních fotbalových dat,
- základní ingest kurzů,
- MMR rating,
- dva ML modely,
- ukládání predikcí,
- value výpočty,
- generování blokových kandidátů,
- PostgreSQL databázi,
- základní mapování lig a týmů.

## 9.2 Rozpracované

Rozpracované nebo připravované byly:

- providerová expanze přes API-Sports,
- robustnější ingest fixtures a týmů,
- kontrola duplicit a aliasů,
- Owner/Operator centrum,
- více providerů,
- více sportů,
- robustní Ticket Engine,
- systematické vyhodnocování tiketů.

## 9.3 Pouze navržené

Bez potvrzené implementace byly zejména:

- veřejný placený web,
- uživatelské účty,
- předplatné,
- mobilní aplikace,
- QR výstupy tiketů,
- přesměrování k bookmakerům,
- business dashboard,
- DAU / WAU / MAU,
- MRR / ARR,
- churn,
- plnohodnotný job scheduler,
- produkční admin web,
- kompletní multisportovní pokrytí.

---

# 10. KLÍČOVÁ ROZHODNUTÍ

## 10.1 Data před veřejným webem

Nejdříve musí vzniknout stabilní, auditovatelná a automatizovatelná datová platforma. Veřejný produkt se má stavět až nad spolehlivými daty.

## 10.2 Providerová data nesmí přepisovat canonical entity

Provider je zdroj, nikoli vlastník canonical identity. Každé slučování musí být kontrolované.

## 10.3 MatchMatrix bude multisportovní

Architektura nesmí být trvale závislá pouze na fotbalu ani na jednom providerovi.

## 10.4 TicketMatrix je samostatná produktová vrstva

TicketMatrix není pouze technický výstup modelu. Má vlastní logiku variant, pravděpodobností, rizika, ukládání a vyhodnocování.

## 10.5 Projekt potřebuje vlastní Operator centrum

Velká platforma nemůže být dlouhodobě řízena pouze jednotlivými příkazy a ručními skripty.

---

# 11. OPEN QUESTIONS K 2026-02-23

V historickém bodě zůstávaly otevřené zejména tyto otázky:

- Jaká bude konečná canonical architektura lig, týmů a zápasů?
- Jak bude řízeno mapování více providerů?
- Který nástroj bude použit pro Operator panel?
- Jak bude řešen scheduler a job runner?
- Jaké sporty a ligy mají mít nejvyšší prioritu?
- Jak bude řešeno verzování modelů?
- Jak bude probíhat backtesting?
- Jak bude vyhodnocována kvalita predikcí a tiketů?
- Jak bude navržen uživatelský a platební systém?
- Jaké providerové licence budou potřeba?
- Jaké údaje budou Free, Basic, Pro a Elite?

---

# 12. NEXT STEP DEFINOVANÝ V ÚNORU 2026

Za nejlepší další směr bylo považováno:

1. stabilizovat ingest,
2. vytvořit databázově řízené ingest targets,
3. zavést job runs a audit běhů,
4. doplnit kvalitu dat a monitoring,
5. vytvořit interní Owner/Operator MVP,
6. následně rozšiřovat ligy a sporty,
7. veřejný web stavět až nad stabilní platformou.

---

# 13. VZTAH K SOUČASNÉMU PROJEKTU

## 13.1 Dlouhodobě platné principy

Do současné dokumentace lze převzít:

- multisportovní směr,
- oddělení providerové a canonical vrstvy,
- řízené mapování entit,
- význam auditů a kvality dat,
- potřebu Operator panelu,
- oddělení interního řízení a veřejného produktu,
- TicketMatrix jako samostatnou vrstvu,
- prioritu robustních dat před veřejným webem.

## 13.2 Historické technické prvky

Pouze jako historie musí být vedeny:

- staré názvy skriptů,
- `.bat` workflow,
- původní adresářová struktura,
- původní jednoduché providerové identifikátory,
- tehdejší `api_raw_payloads`,
- tehdejší tabulky a view,
- tehdejší modelové metriky,
- tehdejší počty záznamů,
- tehdejší limity API,
- původní doporučení Streamlit jako konkrétní technologie.

## 13.3 Oblasti pro aktualizaci Review

Z checkpointu mají být později aktualizovány zejména:

- MM-DOC-100 – MatchMatrix Master,
- MM-DOC-200 – MatchMatrix Governance,
- MM-DOC-300 – MatchMatrix Architecture,
- MM-DOC-800 – Development Handbook,
- MM-DOC-900 – Denní zápisy,
- MM-DOC-901 – Navázání,
- MM-DOC-902 – Changelog,
- MM-DOC-903 – Architectural Decisions.

---

# 14. MAPOVÁNÍ DO DOKUMENTAČNÍCH SLOŽEK

| Složka | Přenášená znalost |
|---|---|
| 01_MASTER | Vize, cílový produkt, obchodní směr |
| 02_GOVERNANCE | Canonical ochrana, providerová pravidla |
| 03_ARCHITECTURE | Datový tok, analytické vrstvy, multisportovní směr |
| 04_DATABASE | Historický databázový model a jeho vývoj |
| 05_PROVIDERS | Počátky provider abstraction a API-Sports |
| 06_LAYERS | Rating, ML, value, odds, TicketMatrix |
| 07_OPERATOR | Owner/Operator centrum a řízení jobů |
| 08_DEVELOPMENT | Skripty, běhy, audity a provozní workflow |
| 09_HISTORY | Časově ukotvený projektový checkpoint |
| 16_DECISIONS | Klíčová rozhodnutí a jejich důvody |

---

# 15. ZÁVĚR CHECKPOINTU

V únoru 2026 se MatchMatrix během jednoho týdne posunul od funkčního fotbalového analytického jádra k vizi velké multisportovní platformy.

Byly formulovány základní stavební kameny, které zůstávají důležité i pro další vývoj:

- robustní databáze,
- více providerů,
- canonical governance,
- ratingy a predikce,
- value analýza,
- TicketMatrix,
- Operator centrum,
- budoucí placený web.

Nejdůležitějším výsledkem únorového období nebyla konkrétní technologie, ale strategická posloupnost vývoje:

> **Nejdříve kvalitní data, řízení a automatizace. Potom veřejný produkt a komerční růst.**

---

## Historie verzí

| Verze | Datum | Stav | Popis |
|---|---:|---|---|
| 1.0 | 2026-07-05 | REVIEW | První syntetický checkpoint rekonstruovaný z historického korpusu MM-HIS-0032 až MM-HIS-0036 |

---

*Konec dokumentu MM-PS-20260223.*
