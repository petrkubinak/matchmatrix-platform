MATCHMATRIX – ZÁPIS (dnešní stav + navázání)
🧠 1. CO SE DNES PODAŘILO (KLÍČOVÉ)
🔥 A) Identifikace root cause
problém nebyl v ingestu
problém byl v:
❗ duplicitní public.teams
❗ rozpadlá identity vrstva
důsledek:
padal team_provider_map
padal merge
padal TheOdds attach
🔥 B) Ověření rozsahu problému
stovky SAME_SPORT_DUPLICATE
desítky CROSS_SPORT_COLLISION
FK vazby na teams přes 23 tabulek

👉 závěr:

ruční merge po týmech = slepá ulička

🔥 C) Rozhodnutí (zásadní krok)

👉 controlled reset api_football

Důvod:

historická data (2022–2024)
free plán
neexistující downstream závislosti (kromě match_features)
rychlejší než merge stovek týmů
🔥 D) Audit dopadu resetu

Výsledek:

matches: 74 583
fixtures staging: 74 583
teams staging: 2 285
provider_map: 2 197
🔥 E) Audit dependent tabulek

👉 pouze:

match_features: 56 091

👉 vše ostatní:

odds ❌
lineups ❌
events ❌
stats ❌
tickets ❌
🔥 F) Proveden reset

✔ smazáno:

public.matches (api_football)
match_features
team_provider_map (api_football)
staging vrstvy

✔ ověřeno:

matches = 0
match_features = 0
team_provider_map = 0
staging = 0

👉 systém je čistý

🧠 2. AKTUÁLNÍ STAV
✅ stabilní:
football_data ✔️
TheOdds ✔️
ostatní sporty ✔️
🧼 čisté:
api_football větev = resetovaná
🎯 připraveno:
rebuild od nuly
bez historického bordelu
🚀 3. STRATEGIE NA ZÍTŘEK
❗ PRINCIP

Teď už:

❌ NE merge
❌ NE fix starých dat
✅ čistý rebuild pipeline

🔥 4. ZÍTŘEK – KONKRÉTNÍ POSTUP
1️⃣ LEAGUES (jen tohle)

Spustit:

run_unified_ingest_batch_v1.py
--provider api_football
--sport FB
--entity leagues
2️⃣ VALIDACE LEAGUES
cíle:
žádné duplicity
stabilní external_league_id
1 liga = 1 identita
3️⃣ SQL kontroly
✔ count
SELECT COUNT(*)
FROM staging.stg_provider_leagues
WHERE provider = 'api_football';
✔ duplicity
HAVING COUNT(*) > 1
✔ identity konflikty
COUNT(DISTINCT league_name) > 1
🎯 OČEKÁVANÝ VÝSLEDEK
leagues = čisté
žádné duplicity
žádné konflikty
🚀 5. NAVAZUJÍCÍ KROKY (po zítřku)
2. den (po leagues):

➡️ teams

3. den:

➡️ fixtures

4. den:

➡️ team_provider_map rebuild

5. den:

➡️ public.matches merge

💡 KLÍČOVÝ POSUN DNES

Dnes se stalo tohle:

❗ projekt přešel z „debugování symptomů“
👉 na „opravu architektury“

🏁 SHRNUTÍ
Oblast	Stav
teams identity	❌ byla rozbitá
api_football data	❌ špinavá
reset	✅ hotovo
systém	✅ čistý
další krok	🚀 rebuild
👉 ZÍTRA ZAČÍNÁME

👉 api_football → leagues → clean ingest

💬 Až zítra spustíš leagues, pošli výstupy a hned navážeme