MATCHMATRIX – ZÁPIS (dnešek)
🧠 HLAVNÍ CÍL DNES

Vyřešit problém:

proč TheOdds má zápasy, ale public.matches ne → NO_MATCH_ID

🔍 1) FOOTBALL_DATA – REALITA
Stav:
ingest proběhl OK
RC = 0
žádné nové zápasy:
matches: 105603 -> 105603 (+0)
Problém:
desítky:
SKIP match XXXXX: missing team id (home=None, away=None)
Interpretace:
tyto zápasy:
nemají přiřazené týmy
jsou typicky:
playoff
knockout
future bracket (World Cup, UCL, Libertadores)

👉 správně se ignorují

🔗 2) THEODDS – VÝSLEDEK
Výsledek:
odds_inserted: 382
skipped_no_match: 21
Co funguje:
matching V3 funguje výborně:
EXACT_PAIR_EXACT_KICKOFF ✔
EXACT_PAIR_TIME_TOLERANCE ✔
žádné:
false pairing
no_team

👉 to je zásadní posun systému

⚠️ 3) ZBYTEK PROBLÉMU = 21 NO_MATCH_ID

Typické případy:

Ligue 1
Serie A
Eredivisie
World Cup
Libertadores
🔬 4) KLÍČOVÝ BREAKTHROUGH (audit 568)

Spustili jsme:
👉 568_audit_missing_pairs_in_football_data_raw.sql

Výsledek:

👉 99 % = RAW_DOES_NOT_HAVE_MATCH

🧠 INTERPRETACE (KRITICKÉ)

Tohle je nejdůležitější závěr dne:

❗ Football-data API ty zápasy vůbec neposílá

Tzn.:

vrstva	stav
TheOdds	má zápas ✔
football_data RAW	nemá ❌
public.matches	nemá ❌

👉 tedy:
není co attachovat

⚠️ 5) CO TO NENÍ (důležité)

Není to:

❌ bug v parseru
❌ bug v linkeru
❌ bug v football_data_pull
❌ problém aliasů
✅ 6) CO JE TO VE SKUTEČNOSTI

👉 DATA GAP MEZI PROVIDERY

Football-data:

nemá všechny fixtures
hlavně:
knockout
některé ligy
některé budoucí zápasy

TheOdds:

má širší coverage
🧩 7) KLASIFIKACE PROBLÉMU

Teď máme 4 typy:

A) ✅ MATCH EXISTUJE → attach OK

(99 % systému)

B) ⚠ RAW EXISTS + MATCH CHYBÍ

→ problém ingestu (minimum)

C) ⚠ RAW CHYBÍ + MATCH EXISTUJE

→ historické / jiný provider

D) ❗ RAW CHYBÍ + MATCH CHYBÍ

👉 HLAVNÍ PROBLÉM DNES

🎯 8) CO JE TEĎ JASNÉ

👉 systém jako celek je:

stabilní ✔
matching funguje ✔
ingest funguje ✔

👉 problém je:

coverage football-data

🚀 9) KAM SMĚŘUJEME (VELMI DŮLEŽITÉ)

Tímhle dnem se projekt posunul:

🔄 OD:

„opravujeme matching“

➡️ NA:

„řešíme multi-source fixture coverage“

🔧 10) CO BUDEME DĚLAT ZÍTRA (1 KROK)

Půjdeme přesně tímto směrem:

👉 KROK 1:

Vytvoříme pravidlo do linkeru:

IF
  EXACT_PAIR_NO_FIXTURE_FOUND
  AND RAW_DOES_NOT_HAVE_MATCH
THEN
  označit jako:
  NO_FIXTURE_SOURCE_AVAILABLE

👉 tím:

odstraníme falešné chyby
backlog bude čistý
audit bude pravdivý
📌 11) BONUS – CO NÁS ČEKÁ POTOM

Další fáze projektu:

🔜 FÁZE 2:
fallback provider pro fixtures
API-Football
API-Sport
vlastní seed
🔜 FÁZE 3:
ticket engine nad reálnými daty
🧠 TL;DR

👉 Dnes jsme zjistili:

❗ problém není v kódu
❗ problém je v datech
❗ football-data nemá všechny zápasy

👉 a to je zásadní milestone projektu

▶️ NAVÁZÁNÍ ZÍTRA

Navážeme přesně tady:

👉 implementace: NO_FIXTURE_SOURCE_AVAILABLE

Pokud chceš, zítra ti hned připravím:

SQL / logiku do linkeru
audit flag
úpravu reason_code

a posuneme to do „production ready“ stavu