MATCHMATRIX – ZÁPIS (Volleyball + sjednocení ingestu)
📅 Datum

2026-03-24

1️⃣ Stav před dneškem
FB, BK, HK ingest funkční
unified ingest pipeline (run_unified_ingest_v1 + batch) běží
staging → public merge funguje
multi-sport architektura připravená

👉 ale:

Volleyball vracel 0 results
nebylo jasné proč
2️⃣ Hlavní problém

VB ingest používal:

endpoint = fixtures ❌

API vracelo:

"endpoint": "This endpoint do not exist."

👉 tzn. neexistující endpoint

3️⃣ Root cause

Rozdílné endpointy podle sportu:

sport	endpoint
football	fixtures
basketball	games
hockey	games
volleyball	games

👉 pipeline byla univerzální → ale endpoint nebyl mapovaný

4️⃣ Fix (klíčová změna)

Implementována funkce:

Resolve-EndpointName

Mapping:

"volleyball" → "games"
5️⃣ Výsledek po fixu
❌ před:
league=97 season=2024 → results=0
endpoint=fixtures
✅ po:
league=97 season=2024 → results=178
endpoint=games

👉 Volleyball ingest plně funkční

6️⃣ Data v DB
staging.stg_api_payloads
provider: api_volleyball
entity: fixtures
endpoint: games
results: 178
7️⃣ Parser připraven

Soubor:

C:\MatchMatrix-platform\db\migrations\236_parse_api_volleyball_fixtures.sql

👉 napojuje:

staging.stg_provider_fixtures
8️⃣ Stav systému po dnešku
INGEST LAYER (kritická část) 🔥

Funguje pro:

✅ Football
✅ Basketball
✅ Hockey
✅ Volleyball

👉 sjednocený přes:

run_unified_ingest_v1
run_unified_ingest_batch_v1
endpoint mapping
9️⃣ Architektonický milestone

Tohle je zásadní krok pro celý projekt:

👉 multi-sport ingest je:

funkční
rozšiřitelný
připravený na PRO API backfill

To přesně odpovídá části:

👉 ingest layer → raw → staging → DB

🔟 Co je teď hotovo
unified ingest pipeline
multi-sport endpoint mapping
volleyball fully working
parser připraven
DB struktura stabilní
1️⃣1️⃣ Co bude první krok v novém chatu

Navážeme přímo:

👉 sjednocení parserů pro všechny sporty

Konkrétně:

vytvořit univerzální parse_api_sport_fixtures.sql
sjednotit strukturu:
FB
BK
HK
VB
🚀 Shrnutí jednou větou

👉 Dnes jsme dokončili multi-sport ingest a odstranili poslední blok (endpoint mapping) — MatchMatrix je připravený na plný data backfill.