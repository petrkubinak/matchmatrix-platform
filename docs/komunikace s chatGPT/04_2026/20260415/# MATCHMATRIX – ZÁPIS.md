# MATCHMATRIX – ZÁPIS (FB REBUILD + AFB HOTOVO)

## 📅 Stav projektu k dnešku

### ✅ HOTOVÉ SPORTY (END-TO-END)

* **BK (basketbal)** → CONFIRMED
* **VB (volejbal)** → CONFIRMED
* **AFB (americký fotbal)** → CONFIRMED

AFB bylo dnes dotaženo:

* ingest fixtures běží
* ENV + dispatch opraven
* canonical teams vytvořeny
* `team_provider_map` existuje
* `public.matches` = 335 (318 FINISHED, 17 SCHEDULED)

➡️ AFB je plně zapojené do core pipeline

---

## ⚠️ ROZPRACOVANÉ SPORTY

### HK (hokej)

* teams: CONFIRMED
* fixtures: PARTIAL
  ➡️ chybí finální merge validace

### BSB (baseball)

* teams: CONFIRMED
* fixtures: ❌ zatím ne
  ➡️ chybí fixtures pipeline

---

## ❗ HLAVNÍ PROBLÉM PROJEKTU

### FB (api_football)

Stav před rebuildu:

* staging fixtures: **76k+**
* public.matches: **0**
* league mapping: OK
* team mapping: ❌

➡️ ROOT CAUSE:

# **chybějící team_provider_map → identity layer**

---

# 🔄 FB CLEAN REBUILD – AKTUÁLNÍ STAV

## 1️⃣ LEAGUES

* ingest: ✅ OK
* staging: naplněn
* duplicity: ❌
* konflikty: ❌

➡️ leagues jsou čisté

---

## 2️⃣ TEAMS

### Ingest:

* běží správně
* data ukládá do:

```text
staging.api_football_teams
```

### Stav:

* rows: **2254**
* data validní (Manchester United, Newcastle, atd.)

### PROBLÉM:

```text
stg_provider_teams = 0
team_provider_map = 0
```

➡️ teams nejsou napojené do unified pipeline

---

# ❗ ROOT CAUSE (KLÍČOVÉ)

FB pipeline je rozdělená:

```text
API → staging.api_football_teams  ✅
API → stg_provider_teams          ❌
```

➡️ chybí bridge:

# **api_football_teams → stg_provider_teams**

---

# 🧠 DŮSLEDEK

Bez toho:

* ❌ nevznikne `team_provider_map`
* ❌ fixtures se nepřipojí
* ❌ public.matches zůstane prázdné

---

# 🎯 DALŠÍ KROK (JEDINÝ SPRÁVNÝ)

## Vytvořit FB TEAMS BRIDGE SCRIPT

### 📁 Soubor:

```text
C:\MatchMatrix-platform\ingest\API-Football\parse_api_football_teams_to_stg_provider_teams.py
```

---

## 📌 Funkce scriptu

Transformace:

```text
staging.api_football_teams
        ↓
staging.stg_provider_teams
```

---

## 📊 Mapování

| source     | target             |
| ---------- | ------------------ |
| team_id    | external_team_id   |
| name       | team_name          |
| league_id  | external_league_id |
| season     | season             |
| provider   | 'api_football'     |
| sport_code | 'football'         |
| fetched_at | updated_at         |

---

## 🎯 Cíl

Po spuštění:

```sql
SELECT COUNT(*) 
FROM staging.stg_provider_teams 
WHERE provider = 'api_football';
```

➡️ musí být **> 0**

---

# 🚀 NÁSLEDNÉ KROKY

Po bridge:

## 1️⃣ team_provider_map build

➡️ canonical identity vrstva

## 2️⃣ fixtures ingest

➡️ už se propojí přes team_id

## 3️⃣ merge do public.matches

➡️ konečně FB ožije

---

# 🧭 STRATEGIE PRO DALŠÍ DNY

## PRIORITA 1

👉 FB pipeline dokončit

## PRIORITA 2

👉 BSB fixtures doplnit

## PRIORITA 3

👉 HK dotáhnout do CONFIRMED

---

# 🏁 SHRNUTÍ

## Co máme:

* systém funguje
* architektura správná
* AFB/BK/VB hotové

## Co chybí:

# 👉 FB identity bridge (TEAMS)

---

# 🔥 KLÍČOVÁ VĚTA

Projekt není rozbitý.

# 👉 chybí JEDEN SCRIPT:

**teams → provider layer**

---

# ▶️ DALŠÍ CHAT ZAČÍNÁ:

👉 vytvořením `parse_api_football_teams_to_stg_provider_teams.py`
👉 jeho spuštěním
👉 validací `stg_provider_teams`

---

## READY TO CONTINUE 🚀
