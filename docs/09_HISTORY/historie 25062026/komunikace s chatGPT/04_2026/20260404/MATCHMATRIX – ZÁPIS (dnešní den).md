MATCHMATRIX – ZÁPIS (dnešní den)
🔧 1. Stabilizace ingest pipeline

potvrzeno správné pořadí:

FOOTBALL_DATA → THEODDS
football_data = zdroj truth pro matches
theodds = enrichment (odds)

✅ pipeline funguje stabilně
✅ žádné pády, RC = 0

🧩 2. Přechod na V3 matching engine

Nasazeno:

run_theodds_ingest_v3.py
theodds_parse_multi_V3.py
helper: theodds_matching_v3.py

Výsledek:

odstraněny staré chyby z V2
sjednocené logování (no_team / no_match / low_coverage)
🌍 3. FIFA – kompletní oprava

Dříve:

NO TEAM MATCH: South Korea vs Czech Republic

Teď:

skipped_no_team = 0 ✅
aliasy:
Czech Republic → Czechia
DR Congo → Congo DR
apod.

👉 FIFA matching je hotový

Zůstává:

Australia vs Jordan → potvrzeno jako:

PROVIDER_DATA_MISMATCH

(neřešíme)

🔥 4. KLÍČOVÝ PRŮLOM – Barcelona SC bug

Identifikováno:

Problém:
Barcelona SC → normalizace → barcelona → FC Barcelona ❌
Root cause:

v helperu:

GENERIC_WORDS obsahoval "sc"
Fix:
odebráno "sc"
Výsledek:
Barcelona SC → barcelona sc ✅
FC Barcelona → barcelona ✅

👉 odstraněno křížení týmů
👉 opravilo NO_MATCH_ID pro tuto větev

📊 5. Aktuální stav (po fixu)

Z logu:

odds_inserted: 2162
skipped_no_team: 0 ✅
skipped_no_match: 24 ⬇️ (výrazný pokles)
match_ok_leagues: 11/13

👉 systém je poprvé:

🔥 "globálně funkční, ale ne ještě čistý"
🎯 CO TEĎ ZBÝVÁ (REALITA)

Už neřešíme:

aliasy ❌
diakritiku ❌
parser ❌

👉 teď řešíme:

👉 MATCH LOOKUP GAP

tzn.:

match existuje v raw
match existuje v DB
ALE nenajde se přes canonical team pair
🚀 NAVAZUJEME (DALŠÍ KROK – přesně 1 věc)
🎯 Cíl:

Najít pattern pro zbývající NO_MATCH_ID

🔍 Vezmeme první případ z logu:
Universidad Católica (CHI) vs Boca Juniors
👉 Spusť v DBeaveru:
SELECT
    m.id,
    ht.name AS home_team,
    at.name AS away_team,
    m.kickoff,
    l.name AS league_name
FROM public.matches m
JOIN public.teams ht ON ht.id = m.home_team_id
JOIN public.teams at ON at.id = m.away_team_id
LEFT JOIN public.leagues l ON l.id = m.league_id
WHERE lower(ht.name) LIKE '%catolica%'
   OR lower(at.name) LIKE '%catolica%'
ORDER BY m.kickoff;
🧠 Co tím zjistíme

Jestli:

existuje match pod jiným názvem (např. bez (CHI))
existuje jiný canonical team
nebo chybí úplně (football_data merge issue)
📌 STRATEGIE NA ZÍTŘEK

Až po tomto kroku:

👉 vytvoříme:

MATCH RESOLUTION LAYER

který bude řešit:

varianty názvů klubů (CHI, U20, atd.)
fallback matching mezi canonical teams
případně "league-aware matching"
🏁 SHRnutí

Dnes jsme udělali:

✔ nasazení V3
✔ fix FIFA
✔ fix kritického bugu (Barcelona SC)
✔ eliminace NO_TEAM_MATCH
✔ dramatické snížení NO_MATCH_ID

👉 a hlavně:

🔥 poprvé máme systém, který se chová konzistentně

Pošli výsledek toho SQL a jdeme rovnou na další vrstvu 👍