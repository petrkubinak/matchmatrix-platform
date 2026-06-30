MATCHMATRIX – ZÁPIS (API-SPORT + API-HOCKEY UNIFIKACE)
🎯 Cíl dne

Sjednotit ingest pipeline pro další sporty (BK + HK) stejně jako FB:

jednotný raw ingest → stg_api_payloads
jednotný parser → stg_provider_*
připravit základ pro multi-sport systém
✅ 1. BASKETBALL (API-SPORT)
🔧 Co bylo vyřešeno
oprava provideru (GenericApiSportProvider → doplnění sport)
oprava PowerShell skriptu (Host kolize)
oprava endpointu:
❌ fixtures
✅ games
oprava URL builderu (/games?league=...&season=...)
doplnění season do ingest_targets
📦 Výsledek
raw ingest: OK (stg_api_payloads)
parser: OK (stg_provider_fixtures)
validní data: ✔️
✅ 2. HOCKEY (API-HOCKEY)
🔧 Co bylo vyřešeno
🔹 2.1 Leagues
přepsán script na unified model:
ukládá do stg_api_payloads
odstraněn starý RAW model (api_hockey_leagues_raw)
🔹 2.2 Fixtures (games)
vytvořen nový script:
pull_api_hockey_fixtures.ps1
napojení do:
run_unified_ingest_v1.py
sjednocení parametrů:
-LeagueId
-Season
-SportCode
🔹 2.3 Problémy a fixy
❌ chyběla season → výsledky = 0
❌ špatný target (limit 1 → jiný řádek)
✅ fix:
disable ostatních targetů
explicitní test (id = 2126)
📊 TEST (ECHL – league 59)
Input:
league = 59
season = 2024
Output:
results = 1146

✔️ API funguje
✔️ data validní

✅ 3. PARSER HK FIXTURES
❌ problém

score nebylo mapováno:

"scores": {
  "away": 4,
  "home": 3
}

parser čekal:

scores.home.total
scores.home.goals
✅ fix
i.item_json -> 'scores' ->> 'home'
i.item_json -> 'scores' ->> 'away'
❗ druhý problém
ON CONFLICT DO NOTHING

→ stará data se nepřepsala

✅ řešení
DELETE ... raw_payload_id = 330
+ znovu parse
📦 Výsledek HK
provider = api_hockey
sport    = hockey
fixtures = 1146

Sample:

Finished | 4 : 1
Finished | 3 : 1
Finished | 3 : 2

✔️ kompletní mapping OK

🧠 KLÍČOVÉ ARCHITEKTONICKÉ POSUNY
🔹 1. FULL UNIFICATION

Všechny sporty jedou přes:

staging.stg_api_payloads (RAW)
staging.stg_provider_* (NORMALIZED)

❌ žádné legacy RAW tabulky
✔️ jeden model pro všechny sporty

🔹 2. STANDARD PARAMETRY

Všechny pull skripty:

-RunId
-SportCode
-LeagueId
-Season
🔹 3. ENDPOINT NORMALIZACE
Sport	Endpoint
Football	fixtures
Basketball	games
Hockey	games
🔹 4. TARGET CONTROL (DŮLEŽITÉ)

Batch bere:

LIMIT 1 → první enabled target

→ nutné:

řídit enabled
řídit season
🚀 AKTUÁLNÍ STAV
Sport	Leagues	Fixtures	Parser	Stav
FB	✅	✅	✅	HOTOVO
BK	✅	✅	✅	HOTOVO
HK	✅	✅	✅	HOTOVO
▶️ CO BUDEME DĚLAT ZÍTRA

Další krok (navazující logika):

🔹 1. Zobecnění API-SPORT

udělat generický model pro:

tennis
volleyball
handball
cricket
atd.

→ už máme základ (BK)

🔹 2. Rozšíření HK
teams
standings (pokud existují)
players (pokud API dovolí)
🔹 3. MERGE DO PUBLIC

napojit:

stg_provider_fixtures → public.matches
🔹 4. AUTOMATIZACE TARGETŮ
generování season automaticky
řízení run_group
🧩 STRUČNÉ SHRNUTÍ

Dnes jsi udělal zásadní krok:

👉 MatchMatrix už není jen football projekt
👉 má funkční multi-sport ingest engine

A hlavně:
👉 architektura je správně nastavená pro škálování (PRO plán)

Až budeš chtít pokračovat, napiš:
👉 „jedeme další sport“
nebo
👉 „napoj merge“