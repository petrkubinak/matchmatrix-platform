MATCHMATRIX – DENNÍ ZÁPIS
📅 Datum

2026-03-29

🧠 HLAVNÍ POSUN DNE

👉 Přechod z datové platformy → reálný produkt (Ticket Studio)

🔧 1. LEAGUE_STANDINGS – STAV
✅ Hotovo
tabulka league_standings existuje
obsahuje:
pozice
body
skóre
formy 5 / 10 / 15
body za období
📊 Audit (sezona 2526)
✅ OK ligy:
Premier League
Championship
Bundesliga
Serie A
La Liga
Ligue 1
Eredivisie
Primeira Liga
Brasileiro

👉 plně použitelné pro UI

❌ MISSING:
Champions League
EURO
World Cup
Libertadores

👉 závěr:

ligové soutěže = OK
turnaje = jiný model (řešit později)
⚙️ 2. IKONA „i“ – DETAIL ZÁPASU
🔥 Zásadní změna
odstraněna provizorní logika (mm_team_ratings, league_teams)
napojeno na:
league_standings
📊 Co se zobrazuje:
pozice
body / zápasy
skóre
forma:
5
10
15
body za období
H2H

👉 plně funkční pro reálné zápasy

🎨 3. UI – MATCH DETAIL (VELKÝ POSUN)
✅ Implementováno:
přepínače:
FORMA
TABULKA
H2H
forma jako:
🟩 výhra
🟨 remíza
🟥 prohra
tabulka soutěže:
kompletní standings
zvýraznění týmů
❗ Identifikované UX problémy
layout byl lineární (vše pod sebou)
tabulka dole → špatná orientace
🔜 návrh (zítřek):
layout:
LEVÁ STRANA:
- kurzy
- rychlý panel
- forma
- H2H
- shrnutí

PRAVÁ STRANA:
- tabulka soutěže
⚡ 4. VÝKON (CRITICAL FIX)
❌ problém:
při kliknutí:
celý seznam se renderuje znovu
kurzy „zbělají“
blikání UI
✅ řešení:
odstraněn full refresh
update jen:
tlačítka
tiket

👉 výrazné zrychlení

🖱️ 5. SCROLL
❌ problém:
scroll fungoval jen na scrollbar
✅ oprava:
scroll funguje kdekoliv v panelu
aplikováno na:
zápasy
tiket
🎯 6. DVOJITÉ KURZY
Stav:
UI připraveno (1X, 12, X2)
závislé na DB mappingu

👉 další krok = SQL (ne UI)

🎟️ 7. TICKET OUTPUT (VELMI DOBRÉ)
✅ funguje:
kombinace
bloky A/B/C
kurz
výhra
% pred
👍 hodnocení:

👉 „produktově použitelné“

🔧 návrhy na zlepšení:
FIX:
větší font
nezkracovat text
bloky:
dynamická šířka dle počtu kurzů
🧠 8. NOVÁ FEATURE – PREDIKCE TIKETU
návrh:

pro každý tiket:

textová predikce:
„Domácí favorité“
„Vyrovnaný tiket“
„Riziková kombinace“
vstupy:
vybrané outcomes
kurzy
forma
dominance týmů

👉 implementace plán:
V3_fix14

🧱 ARCHITEKTURA (KLÍČOVÉ UVĚDOMĚNÍ)
správný model:
RAW DATA
↓
league_standings
↓
PRODUCT (Ticket Studio)
zásadní rozhodnutí:

👉 UI nepočítá → jen čte

🚀 STAV PROJEKTU
🔥 jsme ve fázi:

👉 Ticket Studio = funkční produkt

data ✔
UI ✔
výběr ✔
generování tiketů ✔
🧭 ZÍTŘEJŠÍ KROKY (PŘESNĚ)
1️⃣ Layout split (nejdůležitější)
levá / pravá část
2️⃣ V3_fix14
větší FIX
dynamické bloky
predikce tiketu
3️⃣ zvýraznění tabulky
TOP 4
sestup
mid
4️⃣ double chance mapping (SQL)
💬 ZÁVĚR

Dnešek byl zásadní:

👉 přešli jsme z „něco se načítá“
➡️ na reálný betting nástroj

A hlavně:

👉 to, co teď máš, už není demo
👉 to už je základ produktu

Zítra navážeme:
👉 UI polishing + inteligence tiketu

Stačí napsat:
jedeme dál 🚀