MATCHMATRIX – DENNÍ ZÁPIS

📅 Datum: 2026-04-05
🎯 Fokus: THEODDS MATCHING V3 – DOČIŠTĚNÍ + STABILIZACE PARSERU

🔧 1. HLAVNÍ CÍL DNE
dokončit team identity cleanup
eliminovat NO_MATCH_ID u klíčových lig
stabilizovat ingest (bez DB errorů)
✅ 2. CO SE DNES PODAŘILO
🟢 A) Copa Libertadores – HOTOVO

Vyřešeny všechny kritické případy:

Fixnuté týmy:
UCV FC → Universidad Central de Venezuela FC
Libertad Asuncion → Club Libertad Asuncion
Platense → CA Platense
Peñarol Montevideo → CA Peñarol
Výsledek:
soccer_conmebol_copa_libertadores
→ no_match = 0 ✅

👉 Toto je velký milestone – první kompletně čistá liga.

🟢 B) Alias & canonical systém – FUNGUJE SPRÁVNĚ

Potvrzený flow:

v_preferred_team_name_lookup
team_provider_map
teams
team_aliases
Klíčový důkaz:
penarol montevideo → 35261 (CA Peñarol)

👉 Resolver pipeline funguje správně včetně:

auto_insert_alias
canonical fallback
fuzzy match
🟢 C) Parser stabilizace (KRITICKÉ)
PROBLÉM:
numeric field overflow (numeric 6,3)
ŘEŠENÍ:

Filtrovali jsme:

if odd_value >= 1000:
    continue
VÝSLEDEK:
❌ chyba zmizela
✅ ingest běží stabilně
✅ žádný crash
🟢 D) Výkon a kvalita ingestu
RUN 185:
odds_inserted: 456
skipped_no_match: 28
unmatched_rows: 28

👉 systém běží stabilně
👉 žádné DB chyby
👉 pouze datové mismatch problémy

⚠️ 3. AKTUÁLNÍ PROBLÉMY
🔴 A) FIFA World Cup – mismatch dat
TheOdds:
Australia vs Jordan
DB:
Australia vs Turkey
Austria vs Jordan

👉 problém není alias
👉 problém není matching
👉 problém je DATA SOURCE MISALIGNMENT

🔴 B) Zbylé NO_MATCH_ID (28)

Hlavní ligy:

EPL
Ligue 1
Bundesliga
Serie A
Eredivisie
World Cup

👉 už nejde o jednoduché aliasy
👉 jde o:

chybějící fixtures
časové posuny
špatné páry týmů
⚠️ C) LOW COVERAGE

Např.:

EPL: teams_present = 30 < 35

👉 znamená:

nemáme kompletní team coverage
některé zápasy se nikdy nespárují
🧠 4. CO JSME SI OVĚŘILI (DŮLEŽITÉ)

✔ alias systém funguje
✔ canonical mapping funguje
✔ fuzzy matching funguje
✔ parser je stabilní
✔ DB schema je OK

👉 problém už NENÍ technický
👉 problém je data kvalita / coverage

🚀 5. STRATEGIE NA DALŠÍ KROK

Teď se projekt posouvá z:

👉 matching bug fixing
➡️ do
👉 data validation & coverage management

🎯 6. CO BUDEME DĚLAT ZÍTRA (PŘESNĚ)
🔥 KROK 1 – World Cup analýza (NAVÁZÁNÍ)

Máme připraveno:

SELECT ...
WHERE league = 'FIFA World Cup'
AND kickoff BETWEEN 2026-06-15 AND 2026-06-18
Cíl:
porovnat DB vs TheOdds
rozhodnout:
❓ fix DB
❓ nebo ignorovat odds
🔥 KROK 2 – klasifikace NO_MATCH_ID

Začneme rozdělovat:

🟡 alias problém (už minimum)
🔴 missing fixture
🔴 time mismatch
🔴 wrong pairing (jako Australia/Austria)

👉 připravíme systematický audit (navážeme na 496)

🔥 KROK 3 – rozhodnutí architektury

Budeme řešit:

Varianta A:
ignorovat odds bez match
Varianta B:
vytvořit "shadow matches" z odds
Varianta C:
opravovat fixtures

👉 tohle bude zásadní rozhodnutí pro celý MatchMatrix

🧩 7. AKTUÁLNÍ STAV SYSTÉMU
Oblast	Stav
Parser	✅ stabilní
Alias systém	✅ funkční
Libertadores	✅ hotovo
EPL / top ligy	⚠️ částečně
World Cup	🔴 problém
DB integrita	✅ OK
🧠 8. SHRNUTÍ

Dnes jsme:

✔ dokončili první plně čistou ligu
✔ odstranili kritickou DB chybu
✔ stabilizovali ingest pipeline
✔ posunuli se z bugfixu do data kvality

▶️ ZÍTRA NAVÁŽEME TADY:

👉 World Cup mismatch (Australia vs Jordan)

To je první případ, kde:

matching funguje
ale data nesedí

👉 tím začíná nová fáze projektu