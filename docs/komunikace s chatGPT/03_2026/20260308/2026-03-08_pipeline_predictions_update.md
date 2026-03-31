# MatchMatrix – denní zápis
Datum: 2026-03-08

Autor: Petr Kubinák / ChatGPT spolupráce

---

# 1. Stabilizace Daily Pipeline

Byl dokončen a otestován automatický skript:

ops/run_daily_pipeline.py

Pipeline nyní spouští tyto kroky:

1️⃣ compute_mmr_ratings.py  
- přepočet ratingů týmů  
- tabulky:
  - mm_match_ratings
  - mm_team_ratings

Výsledek dnešního běhu:

Loaded finished matches: 85857  
Saved mm_match_ratings: 85857  
Saved mm_team_ratings: 3027  

---

2️⃣ build_match_features (SQL)

SQL rebuild tabulky:

match_features

počítané features:

- home_last5_points
- away_last5_points
- home_last5_gf
- home_last5_ga
- away_last5_gf
- away_last5_ga
- home_rest_days
- away_rest_days
- h2h_last5_goal_diff

Výsledek:

87386 rows updated

Tabulka je nyní kompletní.

---

3️⃣ predict_matches_V3.py

Model:

baseline_logreg_v3

feature view:

public.ml_match_predict_dataset_v1

Predikce ukládány do:

public.ml_predictions

---

# 2. Rozšíření horizontu predikcí

Byl dočasně změněn horizont:

MM_PRED_DAYS_AHEAD = 365

Cíl:
ověřit, že systém dokáže vytvořit predikce pro všechny budoucí zápasy.

Výsledek:

Future matches loaded: 1194  
Inserted predictions: 1194  

Pipeline funguje správně.

---

# 3. Návrat k produkční logice

Bylo rozhodnuto, že:

produkční horizont = **14 dní**

Důvod:

forma týmů se během sezóny výrazně mění.

Predikce:

- 7–14 dní → realistické
- 30+ dní → výrazně méně stabilní
- 365 dní → pouze test coverage

Produkční nastavení:

MM_PRED_DAYS_AHEAD = 14

---

# 4. Value analýza

Byl vytvořen dotaz porovnávající:

model probability  
vs  
implied odds probability

vzorec:

edge = model_probability − bookmaker_probability

Ukázka výsledků:

match_id | home_team | away_team | best_value_edge
---|---|---|---
62648 | Middlesbrough | Bristol City | 0.292
62650 | Birmingham | Sheffield Utd | 0.201
65707 | Fiorentina | Parma | 0.190
61870 | Sao Paulo | Chapecoense | 0.183

Tyto zápasy mají potenciální **value bet**.

---

# 5. Coverage kontrola predikcí

Kontrola budoucích zápasů bez predikce:

dotaz:

SELECT ...
WHERE has_prediction = 0

Výsledek:

222 zápasů bez predikce

Po rozšíření horizonu:

1194 predikcí vytvořeno.

---

# 6. Stav systému

Pipeline běží kompletně:

✔ MMR ratingy  
✔ match features  
✔ ML predikce  
✔ odds ingest  
✔ ticket settlement refresh  

Výstup pipeline:

Daily pipeline OK

---

# 7. Další plán (další session)

Následující kroky projektu:

### 1️⃣ Value betting layer

vytvořit tabulku:

mm_value_bets

bude obsahovat:

- match_id
- model probabilities
- bookmaker odds
- edge
- recommended pick

---

### 2️⃣ Ticket engine

napojení na:

mm_ticket_templates  
mm_ticket_runs  
mm_ticket_run_matches

cílem je:

automatické generování tiketů.

---

### 3️⃣ UI nabídka zápasů

připravit query pro frontend podobné:

Fortuna / Tipsport / Livesport

obsah:

- zápasy
- kurzy
- model predikce
- value indikátor

---

# 8. Shrnutí dne

Dnes se podařilo:

✔ stabilizovat daily pipeline  
✔ přepočítat 85k historických ratingů  
✔ vytvořit 87k match features  
✔ generovat 1194 ML predikcí  
✔ otestovat coverage systému  
✔ připravit value betting logiku  

Systém MatchMatrix je nyní:

**plně funkční pro predikce budoucích zápasů.**

---

Další práce bude zaměřena na:

ticket engine + value betting systém.