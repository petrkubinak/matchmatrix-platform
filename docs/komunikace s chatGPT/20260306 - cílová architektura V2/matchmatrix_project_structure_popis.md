
# MatchMatrix – Projektová struktura a pracovní pravidla

## 1. Kořen projektu

Cesta:

C:\MatchMatrix-platform

Aktuální struktura projektu:

```
MatchMatrix-platform
│
├── backend
├── backups
├── data
├── db
├── docs
├── experiments
├── frontend
├── infra
├── ingest
├── logs
├── MatchMatrix-platform   (DBeaver projekt)
├── ops
├── ops_admin
├── programs
├── reports
├── system
└── .git
```

Tato struktura je vhodná pro dlouhodobý vývoj platformy MatchMatrix.

---

# 2. Datová pipeline

Projekt používá standardní data engineering pipeline:

```
RAW DATA
   ↓
PROCESSING
   ↓
DATABASE
   ↓
VIEWS / ANALYTICS
   ↓
API
   ↓
FRONTEND
```

---

# 3. Složka `data`

Cesta:

```
C:\MatchMatrix-platform\data
```

Struktura:

```
data
│
├── exports
├── news_feeds
├── processed
├── raw
├── raw API payloads
├── scraped html
└── temporary datasets
```

### význam

| složka | účel |
|------|------|
raw | původní data z API |
raw API payloads | kompletní JSON odpovědi z API |
scraped html | HTML z webových scraperů |
processed | normalizovaná data |
news_feeds | RSS a news zdroje |
exports | exporty pro analýzy |
temporary datasets | testovací dataset / ML experimenty |

---

# 4. Složka `db`

Cesta:

```
C:\MatchMatrix-platform\db
```

Struktura:

```
db
│
├── checks
├── migrations
├── scripts
├── seeds
├── sql
└── views
```

### význam

| složka | účel |
|------|------|
migrations | změny databázového schématu |
views | produkční SQL views |
seeds | počáteční data |
scripts | pomocné SQL skripty |
checks | kontrola kvality dat |
sql | experimentální SQL |

---

# 5. Složka `backups`

Cesta:

```
C:\MatchMatrix-platform\backups
```

Struktura:

```
backups
│
├── archiv exportů
├── postgres dumps
└── snapshots
```

### význam

| složka | účel |
|------|------|
postgres dumps | pg_dump databáze |
snapshots | snapshoty datasetů |
archiv exportů | archiv CSV a reportů |

---

# 6. DBeaver projekt

Složka:

```
C:\MatchMatrix-platform\MatchMatrix-platform
```

Obsahuje:

```
.dbeaver
.settings
Scripts
Dump
.project
```

Tato složka obsahuje celý DBeaver workspace a je napojená na pipeline.

⚠️ **Tuto složku nepřesouvat bez úpravy pipeline.**

---

# 7. Datový model – plán rozšíření

Další fáze projektu bude obsahovat nové entity:

```
seasons
players
lineups
injuries
articles
content_sources
```

Tyto tabulky umožní:

- detail hráčů
- sestavy zápasů
- zranění
- obsah pro fanoušky
- články a news feed

---

# 8. Pravidlo pro práci se soubory

Při každém návrhu nebo tvorbě nového prvku projektu musí být vždy uvedeno:

1️⃣ **název souboru**  
2️⃣ **přesná složka kam soubor uložit**

Například:

```
Soubor:
create_players_table.sql

Uložit do:
C:\MatchMatrix-platform\db\migrations
```

nebo

```
Soubor:
ingest_players_api.py

Uložit do:
C:\MatchMatrix-platform\ingest\api
```

Toto pravidlo je důležité pro:

- udržení přehledné struktury projektu
- rychlou orientaci
- snadnou automatizaci pipeline

---

# 9. Další vývoj projektu

Další kroky vývoje:

1. rozšíření databázového modelu
2. rozšíření ingest pipeline
3. vytvoření detailu zápasu
4. vytvoření detailu týmu
5. vytvoření detailu hráče
6. integrace článků a news feed

Cílem je vytvořit **globální sportovní datovou platformu MatchMatrix**.
