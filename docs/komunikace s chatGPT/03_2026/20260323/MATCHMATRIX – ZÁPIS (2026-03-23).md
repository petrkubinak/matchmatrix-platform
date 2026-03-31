MATCHMATRIX – ZÁPIS (2026-03-23)
1️⃣ STAV PIPELINE (KLÍČOVÉ)

✔ Ingest cycle V3 = plně funkční

planner ✔
worker ✔
extract teams ✔
merge ✔

✔ Stabilní běh:

žádné fatální chyby
pouze expected WARNING (no data / free plan omezení)
2️⃣ FIXTURES – FB_BOOTSTRAP_V1
DONE: 6
PENDING: 1211
Realita:
část lig vrací data ✔
část vrací No fixtures → OK (normální)

✔ staging plně plněn
✔ merge → public.matches = 107k+

3️⃣ TEAMS – FB_BOOTSTRAP_V1
DONE: 6
PENDING: 1208+
Dnešní run:
431 → OK (18 týmů)
120 → OK (12 týmů)
796 → OK (16 týmů)
143 → OK (125 týmů)
1105 → OK (2 týmy)
některé ligy → No teams (WARNING)

✔ pipeline:

fixtures → extract teams → teams ingest → merge

✔ public.teams = 5369
✔ team_provider_map = 5350

4️⃣ ODDS – PROBLÉM (ALE OČEKÁVANÝ)
error: 4
skipped: 119
Důvod:

👉 API FREE plán nemá odds

Chyba:

"The From field do not exist."

✔ závěr:

pipeline je OK
data nejsou dostupná → správné chování
5️⃣ MULTISPORT PROBLÉM (VYŘEŠENO)

Dříve:

api_cricket / api_esports → FATAL ERROR

✔ řešení:

provider OFF / filtr

✔ aktuálně:

běží jen:
api_football
api_hockey
6️⃣ SQL ERROR (COALESCE)
COALESCE types text and integer cannot be matched

✔ příčina:

mix typů (text vs int)

✔ stav:

identifikováno
víme jak řešit (CAST)
7️⃣ CHOVÁNÍ PLANNERU

✔ důležité pochopení:

čísla (např. 218) = ID jobu
NE pořadí

✔ retry logika:

attempts 0 → fresh
attempts 1–2 → retry
attempts 3 → max
8️⃣ STAV FRONTY (KLÍČOVÉ)
TEAMS
pending (0): ~1208
retry: 3 joby
FIXTURES
pending: ~1211

✔ fronta je:

velká
čistá
správně strukturovaná
🔥 CO JSME DNES DOSÁHLI

✔ Funkční end-to-end pipeline
✔ Stabilní ingest pro:

fixtures
teams

✔ Validovaný:

planner
worker
merge

✔ Ověřený:

retry systém
warning handling
free plan limity

👉 Tohle je první moment, kdy MatchMatrix běží jako skutečný systém.

🚀 KAM SE POSUNEME (DALŠÍ KROK)
🔹 PRIORITA 1

👉 DOJET FB_BOOTSTRAP_V1 (teams + fixtures)

Cíl:

co nejvíce lig pokrýt
připravit DB na PRO měsíc
🔹 PRIORITA 2 (po bootstrapu)

👉 PLAYERS PIPELINE

Navážeme na:

teams → players → player_stats → MMR
🔹 PRIORITA 3

👉 ODDS (až PRO plán)

teď ignorovat
připraveno ✔
🔗 NA CO NAVÁŽEME V DALŠÍM CHATU

Napiš:
👉 „Pokračujeme teams bootstrap“

A jedeme:

Krok 1:
optimalizace běhu (limit ↑)
Krok 2:
automatické skipování "no data" lig
Krok 3:
přechod na players pipeline
⚡ KRÁTKÉ SHRNUTÍ

Dnes:

pipeline = FUNKČNÍ
data = se plní
architektura = drží
systém = škálovatelný

👉 Teď už:
neřešíme „jestli to funguje“
ale „jak rychle to naplníme“

Pokud chceš, v dalším kroku ti připravím:
👉 automatický režim (semi-autopilot) pro bootstrap
→ aby jsi to nemusel klikat ručně.