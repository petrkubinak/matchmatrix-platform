# MatchMatrix – zápis (FB_EU → football_data vrstva + audit historie)

📅 Datum: 20.03.2026

---

# 🎯 HLAVNÍ POSUN

Dokončeno:

👉 první funkční **ne-TOP ingest vrstva** pro football
👉 plně funkční pipeline pro `football_data`

---

# ⚙️ CO JE HOTOVO

## 1️⃣ Run group vrstva

Zavedena nová vrstva:

* `FB_EU` (pracovní název)

Obsah:

* 10 targetů (ligy)
* provider: `football_data`
* původně disabled → opraveno na enabled

---

## 2️⃣ Entity plán (provider-aware)

Rozšířen `ops.ingest_entity_plan`:

### api_football

* leagues
* teams
* fixtures
* odds
* players
* player_season_stats
* coaches

### football_data

* leagues
* teams
* fixtures
* odds

👉 tím vznikla první **multi-provider kompatibilita**

---

## 3️⃣ Planner vrstva

Vytvořeno:

* `ops.v_fb_eu_ingest_jobs`
* `ops.v_fb_eu_ingest_jobs_test_mode`

Výsledek:

```
football_data | leagues  | 10
football_data | teams    | 10
football_data | fixtures | 10
```

👉 `odds` odstraněny pro FREE režim

---

## 4️⃣ Request náročnost

FB_EU test mode:

* cca 30 requestů celkem

👉 velmi bezpečné pro FREE režim

---

# 📊 ANALÝZA DAT (KLÍČOVÉ ZJIŠTĚNÍ)

Audit `football_data`:

## Hlavní ligy (HOTOVO)

* Premier League
* Championship
* Serie A
* Primera Division
* Ligue 1
* Primeira Liga
* Bundesliga
* Eredivisie
* Brasileiro Série A

👉 každá:

* ~9 sezón
* rozsah cca 2018/19 → 2025/26
* tisíce zápasů

👉 závěr:
**historie je prakticky kompletní**

---

## Doplňkové soutěže (NEHOTOVO)

* UEFA Champions League
* FIFA World Cup
* EURO
* Copa Libertadores

👉 pouze 1 sezóna

---

# 🧠 KLÍČOVÉ POCHOPENÍ

👉 `football_data` není:

❌ backfill provider
❌ hlavní ingest zdroj

👉 ale je:

✅ **hotový historický dataset**
✅ **maintenance zdroj pro top ligy**
✅ **nízkonákladový ingest (scope-limited)**

---

# ⚠️ DŮLEŽITÝ POSUN V MYŠLENÍ

Původní představa:

* `FB_EU` = geografická Evropa

Reálný stav:

* obsahuje i:

  * Brazílii
  * světové soutěže

👉 takže:

❗ `FB_EU` není čistě EU vrstva

---

# 🚀 NOVÝ MODEL

## Provider-driven vrstvy

Místo:

* FB_TOP
* FB_EU
* FB_WORLD

přechod na:

### 1️⃣ FB_TOP

* nejvyšší priorita
* všechny providery

### 2️⃣ FB_FD_CORE (dnešní FB_EU)

* provider: football_data
* top ligy + historie
* maintenance vrstva

### 3️⃣ FB_API_EXPANSION (budoucí)

* provider: api_football
* širší coverage
* řízený budgetem

---

# 🧩 ARCHITEKTURA TEĎ

## ✔ Konfigurace

* sport_entity_rules
* provider_sport_matrix

## ✔ Entity plan

* multisport + multi-provider

## ✔ Targety

* FB_TOP
* FB_EU (→ FB_FD_CORE)

## ✔ Planner

* TOP větev
* FB_EU větev

---

# 🔥 CO JSME REÁLNĚ POSTAVILI

👉 první:

## ✅ multi-provider ingest vrstvu

## ✅ řízený scope ingest

## ✅ oddělení historických a živých dat

---

# ⏭️ DALŠÍ KROK

👉 přejmenování vrstvy:

* `FB_EU` → `FB_FD_CORE`

a následně:

👉 vytvoření:

* `FB_API_EXPANSION`

---

# 🧠 SHRNUTÍ

MatchMatrix se posunul z:

❌ „stáhni všechno“

na:

🔥 **řízený ingest podle:**

* provideru
* kvality dat
* rozsahu
* nákladů

---
