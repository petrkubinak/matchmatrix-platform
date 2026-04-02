MATCHMATRIX – plán na zítra (THEODDS V3 pokračování)
🎯 Hlavní cíl

Dostat THEODDS ingest do stabilního stavu, kde:

NO TEAM MATCH ≈ minimum (to už skoro máme)
NO MATCH ID = reálně pochopený a řízený stav
ingest běží stabilně bez rozbíjení DB
máme připravený základ pro Ticket Engine
📊 Stav, ze kterého vycházíme
Co funguje

✔ team matching (V3) → velmi dobrý
✔ alias systém → aktivní a funkční
✔ ingest pipeline → běží stabilně
✔ RAW payloads → ukládají se

Co nefunguje

❌ NO MATCH ID vysoké (≈100+)
❌ mismatch mezi TheOdds a public.matches
❌ testy rozbily konzistenci (aliasy + odds duplicity)

🔥 REALITA (důležitý insight)

problém není v názvech týmů
problém je v napojení na fixtures (matches)

To je zásadní posun.

🧭 ZÍTŘEJŠÍ POSTUP – krok po kroku

Půjdeme přesně po jedné věci (jak chceš 👍)

✅ KROK 1 – AUDIT DB po testech

👉 Cíl: zjistit, co jsme si „rozbili“ testováním

Uděláme:

kolik máme:
team_aliases WHERE source='theodds'
odds z TheOdds
kolik jich přibylo během testů
jaké aliasy se vytvořily

👉 Výstup:

rozhodnutí:
ponechat aliasy
nebo je vyčistit
✅ KROK 2 – STABILIZACE TESTOVÁNÍ

👉 Cíl: už si dál neničit DB

Zavedeme:

režim:
THEODDS_AUTO_INSERT_ALIAS=0

➡️ parser nebude zapisovat aliasy při testu

👉 Výsledek:

čisté testování
žádné side-effecty
✅ KROK 3 – ANALÝZA NO MATCH ID

👉 Tohle je KLÍČ

Rozdělíme NO MATCH ID na typy:

typy problémů:
🔴 fixture neexistuje vůbec
🟡 existuje jiná větev týmu
🟡 existuje, ale jiný čas
🟡 existuje, ale opačné home/away
🟢 existuje → jen špatná logika

👉 uděláme SQL + logiku v parseru

✅ KROK 4 – FIND_MATCH_ID V2

👉 nejdůležitější změna dne

Vylepšíme:

současný stav:
home_team_id = X AND away_team_id = Y
nový stav:
přesný match
obrácený match
fallback:
oba týmy existují v čase
nearest kickoff

👉 přidáme DEBUG:

typ matchnutí (EXACT / REVERSED / NEAREST)
✅ KROK 5 – LOGIKA „NEAREST MATCH“

👉 pokud nenajdeme přesný match:

najdeme:

nejbližší zápas pro oba týmy
v rozumném okně (např. ±3 dny)

➡️ to dramaticky sníží NO MATCH ID

✅ KROK 6 – VALIDACE NA 1 LIZE

👉 nebudeme testovat všech 13 lig

vezmeme:

např. soccer_epl
nebo soccer_efl_champ

a ladíme jen tam

✅ KROK 7 – METRIKY

👉 budeme sledovat:

odds_inserted
no_team
no_match

cílový stav:

metrika	cíl
no_team	~0
no_match	výrazně dolů
odds_inserted	stabilní růst
🚫 CO ZÍTRA NEBUDU DĚLAT

abychom se nezacyklili:

❌ žádné další fuzzy matching úpravy
❌ žádné další alias magie
❌ žádné branch hacky (KROK 5 byl slepá ulička)

🧠 STRATEGICKÝ POSUN

Tohle je důležité:

THEODDS problém = DATA INTEGRATION problém, ne matching problém

To znamená:

musíme sladit:
providers (TheOdds vs API-Football / Football-Data)
leagues
fixtures
🔜 Kam to směřuje dál

Po vyřešení match_id:

👉 další fáze
kvalita odds dat
coverage lig
napojení na Ticket Engine
🎯 Zítřejší první akce (jedna věc!)

Abychom jeli podle tvého stylu:

👉 začneme:

AUDIT DB (aliasy + odds)

Napiš zítra:

START KROK 1