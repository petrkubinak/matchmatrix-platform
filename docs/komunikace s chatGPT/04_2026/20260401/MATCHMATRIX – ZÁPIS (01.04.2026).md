MATCHMATRIX – ZÁPIS (01.04.2026)
🧠 1. Hlavní cíl dne

✔ sjednotit ingest + panel
✔ rozjet multi-provider (API + Football-Data + TheOdds)
✔ začít reálně vyhodnocovat kvalitu tiketů
✔ přidat první diagnostiku (debug → řízení kvality dat)

⚙️ 2. Stav ingest pipeline
✅ Funkční provideri
1️⃣ API (api_sport / api_football)
běží přes ingest cycle V3
slouží jako core data (fixtures, teams, leagues)
2️⃣ Football-Data
worker:
ingest/Football-Data/football_data_pull_V6.py
přesunut a napojen do panelu
stav:
✔ běží
✔ ukládá matches
⚠️ občas missing team id

👉 role:
➡️ hlavní zdroj fixtures + výsledků

3️⃣ TheOdds
worker:
workers/run_theodds_ingest_v2.py
parser:
ingest/TheOdds/theodds_parse_multi_FINAL.py
Stav:
✔ běží end-to-end
✔ ukládá odds (+1118 v runu)
✔ snapshot funguje
⚠️ problémy:
❗ hlavní issues:
NO MATCH ID
NO TEAM MATCH
LOW COVERAGE

encoding:

'charmap' codec can't encode character

👉 role:
➡️ hlavní zdroj odds (kritický pro tiket engine)

🧩 3. Control Panel V11
✅ Hotové
multi-provider run
run_provider_update() opraveno
run_command_stream() opraveno
snapshot summary:
matches
odds
payloads
runs
🧠 NOVINKA: Provider Diagnostics (Krok 11 + 12)

Panel nově umí:

THEODDS:
počítá:
NO TEAM MATCH
NO MATCH ID
Inserted odds
loguje poslední problémy
FOOTBALL_DATA:
filtr → bez šumu

👉 Výsledek:
➡️ máš první monitor kvality ingestu

🎯 4. Ticket Engine – stav
✅ Hotové
generování tiketů (AUTO_SAFE_01 / 02 / 03)
history ukládání
pattern tracking:
pattern_code
pattern_id
📊 Pattern systém
vytvořeno:
ticket_patterns
pattern_candidates
pattern_map
view:
v_ticket_pattern_history_quality
🧪 Výsledek:
Pattern	Stav
FIX3	NORMALIZED
FIX4	NORMALIZED
FIX5 (1+1)	LEGACY_MIXED ⚠️

👉 závěr:
➡️ stará data jsou mix → nová už čistá

📉 5. Vyhodnocení strategie
nejlepší:
🟢 AUTO_SAFE_01
hit rate: ~4.39 %
EV: 3.21 (nejlepší)
stabilní kurz
horší:
🔴 AUTO_SAFE_02
vysoké kurzy
extrémně nízká pravděpodobnost
insight dne:

👉 nižší kurzy + vyšší pravděpodobnost = lepší long-term EV

🧠 6. KLÍČOVÝ POSUN

Dnes jsi udělal zásadní věc:

❗ systém už není jen generátor tiketů

➡️ ale začíná být:

👉 SELF-LEARNING BETTING ENGINE

protože:

ukládá všechny tikety
ukládá patterny
vyhodnocuje úspěšnost
sleduje kvalitu dat
🚧 7. PROBLÉMY (aktuální bottleneck)
1. Matching (NEJVĚTŠÍ PROBLÉM)
TheOdds ↔ matches
chybí:
provider_map
aliasy
fuzzy matching
2. Encoding (TheOdds)
diakritika (Bolívar, Peñarol…)
řešení: UTF-8
3. Coverage
některé ligy:
low coverage
missing matches
🚀 8. SMĚR (co budeme dělat dál)
🔥 FÁZE 1 – stabilizace ingestu
1️⃣ TheOdds V3 worker
UTF-8 fix
lepší logging
rozdělení chyb:
team mismatch
match mismatch
2️⃣ Matching engine V1
team_aliases rozšíření
provider_map fix
fallback matching (name similarity)
3️⃣ Coverage score
% napárovaných zápasů
% dostupných odds
🔥 FÁZE 2 – ticket intelligence
4️⃣ Pattern performance table
ROI
hit rate
profit
5️⃣ Automatický výběr strategie
už začíná fungovat
posun:
dynamic learning
🔥 FÁZE 3 – UI / Panel V12
6️⃣ přidáme:
health score providerů
doporučení:
"THIS LEAGUE IS LOW QUALITY"
tlačítko:
„Run best strategy“
🧭 9. Kam směřujeme (BIG PICTURE)

Cíl:

🧠 MATCHMATRIX = autonomní betting engine

který:

stáhne data
spáruje data
vytvoří tikety
vyhodnotí výsledky
naučí se z historie
automaticky zlepší strategii
▶️ 10. Co uděláme v novém chatu

Navážeme přesně tady:

Krok 1:

👉 vytvoříme

THEODDS INGEST V3
fix encoding
lepší logika matchingu
Krok 2:

👉 začneme

MATCHING ENGINE V1
alias + fuzzy match
Krok 3:

👉 přidáme

PROVIDER HEALTH SCORE
💬 Shrnutí jednou větou

👉 Dnes jsi přešel z „generování tiketů“ na řízení kvality dat + učení systému, což je klíčový milestone.

Až založíš nový chat, napiš jen:

👉 „Pokračujeme – THEODDS V3“

a jedeme dál přesně odtud.