MATCHMATRIX – ZÁPIS (DNES)

🎯 HLAVNÍ CÍL DNES



Rozjet Baseball (BSB) ingest pipeline → staging → parser → validace



🧱 1. PROBLÉMY (a jejich řešení)

❌ 1.1 DSN chyba

invalid dsn: missing "=" after "set"

🔧 ŘEŠENÍ

upraven get\_dsn() → odstranění:

set DB\_DSN=

DB\_DSN=

přidán fallback DSN

❌ 1.2 Permission denied (staging schema)

permission denied for schema staging

🔧 ROOT CAUSE



Používal jsi:



user=mm\_ingest



➡️ ten NEMÁ práva na staging



✅ ŘEŠENÍ



Používáš:



user=matchmatrix



✔️ confirmed:



usage=True

create=True

❌ 1.3 Column "entity" does not exist

column "entity" does not exist

🔧 ŘEŠENÍ



Parser upraven na dynamické mapování sloupců



Používá:



entity\_type

payload\_json

sport\_code

❌ 1.4 Script nic nedělal (ticho)



➡️ nebyl main entrypoint / debug



🔧 ŘEŠENÍ

doplněn běh + logy

ověřen run přes -u

🚀 2. FUNKČNÍ PIPELINE (CONFIRMED)

🔗 FLOW

API-Sport (baseball)

&#x20;       ↓

staging.stg\_api\_payloads

&#x20;       ↓

parse\_api\_baseball\_teams\_to\_staging.py

&#x20;       ↓

staging.stg\_provider\_teams

📊 3. VÝSLEDEK

RAW payload id: 480

results: 32

Filtrace:

❌ American League

❌ National League

✔️ FINAL:

30 teams vloženo

✅ OPS CONFIRM

api\_baseball | baseball | league\_id=1 | season=2024



rows\_count = 30

distinct\_teams = 30



✔️ 100% match

✔️ žádné duplicity

✔️ parser funguje správně



🧠 4. CO JE HOTOVÉ



✔️ DB connection robustní

✔️ staging payload load funguje

✔️ parser dynamický (schema-proof)

✔️ filtr non-playable entit

✔️ zápis do stg\_provider\_teams

✔️ OPS validace



🚧 5. CO JE ROZDĚLANÉ



➡️ CHYBÍ:



staging → public (canonical vrstva)



Konkrétně:



public.teams

team\_aliases

team\_provider\_map

🔥 6. KLÍČOVÝ POSUN



Dnes se stalo tohle:



👉 Baseball už NENÍ skeleton

👉 Je to plnohodnotný ingest chain jako FB



To je zásadní milestone pro:



multi-sport architekturu

provider abstraction

budoucí odds + tickets

▶️ 7. ZÍTRA – PŘESNĚ NAVÁZÁNÍ

🎯 KROK 1 (HNED RÁNO)



Spustíš:



136\_bsb\_teams\_provider\_map.sql

🎯 KROK 2



Validace:



count teams

count provider\_map

sample teams

🎯 KROK 3 (NAVÁŽEME SPOLU)



👉 Přechod na:



BSB fixtures ingest

📈 8. STRATEGICKÝ SMĚR



Teď jedeme:



BSB → teams ✔️

BSB → provider\_map (zítra)

BSB → fixtures

BSB → odds



A pak:



→ BK

→ HK

→ VB

→ AFB

⚠️ DŮLEŽITÉ (NA ZÁVĚR)



Tohle si zapamatuj:



👉 NEPOUŽÍVEJ mm\_ingest pro staging

👉 vždy:



user=matchmatrix



Pokud tohle změníš → rozbije se ingest



🧾 SHRNUTÍ



Dnes:



✔️ opraven parser

✔️ opraven DSN

✔️ opraven permissions

✔️ baseball teams ingest běží

✔️ data validní

✔️ připraveno na canonical vrstvu



Zítra:



👉 provider\_map

👉 fixtures



💬 Dobrá práce dnes. Tohle byl velký krok.

Zítra už jedeme rychleji 🚀

Perfektní, tohle ještě doplním do dnešního zápisu:



BSB fixtures raw pull je už také potvrzený.



Z logu je hotové:



provider = api\_baseball

sport = BSB

entity = fixtures

league\_id = 1

season = 2024

batch doběhl OK

pull\_api\_sport\_fixtures.ps1 se spustil správně

RUN ID = 20260412002129042



To znamená, že zítra už nenavazujeme od fixtures pullu, ale rovnou od:



BSB fixtures parser raw → staging



Takže přesné navázání do nového chatu je:



Dnes bylo dokončeno BSB teams včetně auditní tabulky a navíc byl úspěšně potvrzen i BSB fixtures raw pull. Zítra první krok: připravit parse\_api\_baseball\_fixtures\_to\_staging.py, napojit baseball fixtures payload na staging.stg\_provider\_fixtures, udělat validaci počtu rows a potom navázat mergem do public.matches. Pokud bude fixtures staging v pořádku, hned poté zapíšeme i BSB fixtures do ops.runtime\_entity\_audit.



Aktuální stav BSB:



leagues raw ✔

teams raw ✔

teams staging ✔

provider\_map ✔

teams audit ✔

fixtures raw ✔

fixtures staging ❌ zítra

public.matches ❌ zítra



Dobrou, zítra nový chat a jedeme přímo BSB fixtures parser



