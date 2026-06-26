MATCHMATRIX – DENNÍ ZÁPIS
📅 26.03.2026
🚀 HLAVNÍ CÍL DNE

Přechod z „backend systému“ → na reálný produktový panel (Ticket Studio)
= začínáme stavět to, co bude generovat value a data.

🧱 1. CANONICAL TEAMS – ČIŠTĚNÍ (Arsenal / Bournemouth)
Stav
duplicity týmů napříč providery:
11910 → Arsenal (HLAVNÍ ✅)
13102 → Arsenal (duplicitní)
26871 → Arsenal (api_sport)
1 → Arsenal (legacy / theodds)
Bournemouth:
11905 → canonical (OK)
948 → football_data_uk
Co jsme vyřešili
provider_map sjednocen
aliasy sjednoceny
odstraněny duplicity (unique constraint)
identifikováno:
⚠️ více "Arsenal" klubů (Belarus vs EPL)
DŮLEŽITÉ ZJIŠTĚNÍ

➡️ název nestačí → nutné:

league_id
country
context

👉 tohle bude klíčové pro:

TheOdds matchování
predikce
ticket engine
📉 2. THEODDS – PROBLÉM S MATCHINGEM
Výsledek parseru
spousta:
NO MATCH ID
NO TEAM MATCH
coverage nízká
Důvod
canonical mapping není hotový globálně
názvy týmů ≠ stejné mezi providery
Ale:

✅ máme funkční odds (část)
→ to stačí pro start Ticket Engine

🎯 3. TICKET STUDIO – VELKÝ POSUN
V2.2 → V2.3 → V2.4
✅ V2.3 – nový layout
vlevo: soutěže
uprostřed: zápasy (řádkově)
vpravo: tiket

➡️ zásadní UX změna

✅ V2.4 – DYNAMICKÝ PANEL
PanedWindow → resize panelů myší
scroll:
soutěže ✔️
zápasy ✔️
tiket ✔️
grid:
pevné sloupce
připraveno na data
📊 GRID – STRUKTURA

Každý zápas = 1 řádek:

datum
liga
home / away
kurzy:
1 / X / 2
1X / 12 / X2 (dopočítané)
placeholder:
Pred
Forma
Tab
H2H
akce:
A / B / C (bloky)
🧠 4. TICKET ENGINE – LOGIKA
FIX zápasy

ukládají se do:

template_fixed_picks
BLOKY (A/B/C)

ukládají se do:

template_blocks
template_block_matches
kombinace:
3 bloky → 3^3 = 27 kombinací
dopočítané:
double chance odds:
1X
12
X2
💾 5. NAPOJENÍ NA DB

Hotovo:

load template
save template
delete template

➡️ panel je napojený na reálný systém

⚠️ 6. BUGY (VYŘEŠENO)
❌ PanedWindow crash
unknown option "-highlightthickness"

✔️ fix:

odstraněn parametr
📈 7. KDE TEĎ JSME

Máš:

✅ funkční ingest (fotbal + další sporty)
✅ staging → public merge
✅ odds (částečně z TheOdds)
✅ canonical teams (částečně vyčištěné)
✅ Ticket Studio UI (V2.4 – dynamické)
✅ ukládání tiketů do DB

🔥 KLÍČOVÉ UVĚDOMĚNÍ DNE

👉 Projekt se posunul z:

"sběr dat"

➡️ na:

"systém pro generování tiketů + budoucí predikce"

▶️ DALŠÍ KROK (ZÍTRA)
1️⃣ Predikce do gridu

doplnit:

Pred (pravděpodobnost 1/X/2)
první verze:
z odds (baseline)
nebo z MMR
2️⃣ Forma + tabulka
posledních 5 zápasů
pozice v lize
3️⃣ H2H panel (klik na zápas)
detail dole / popup
4️⃣ Ticket intelligence
pravděpodobnost tiketu
EV (expected value)
doporučení
5️⃣ AUTO GENERATION (velký krok)
generování tisíců tiketů
ukládání do DB
trénovací dataset
🧭 STRATEGICKY

Směr je teď jasný:

👉 Ticket Engine = core produktu

Data → tiket → vyhodnocení → zlepšení → predikce

Pokud chceš, zítra jedeme rovnou:

👉 Predikce do gridu (první reálný AI krok)