MATCHMATRIX – ZÁPIS (THEODDS + CANONICAL LAYER)
📅 Datum

2026-04-02

🎯 HLAVNÍ CÍL DNE

Dostat TheOdds ingest do stavu:

✔ bez chaosu v názvech týmů
✔ napojený na jednotnou kanonickou vrstvu
✔ maximální match rate mezi odds a matches
🔥 CO SE PODAŘILO (KLÍČOVÉ)
1️⃣ Kanonická vrstva (CORE HOTOVO)

Vytvořeno a funkční:

canonical_league_map
canonical_team_map
v_canonical_team_resolve
v_canonical_match_lookup

👉 Výsledek:

✅ jednotná identita týmů napříč providery
2️⃣ Resolver názvů (GAME CHANGER)

Vytvořeno:

v_preferred_team_name_lookup

Logika:

confirmed mapping
review
auto
team_alias
fallback (self)

👉 Výsledek:

✅ konec problémů typu:
Flamengo vs Flamengo-RJ
Palmeiras vs Palmeiras-SP
Internazionale vs Inter
3️⃣ Cleanup aliasů (kritické)

Odstraněny chybné aliasy:

❌ Barcelona SC → FC Barcelona
❌ Junior FC → Argentinos Juniors
❌ Rosario Central → Leones de Rosario
❌ Sporting Cristal → U20
❌ Czech Republic → U18

👉 Výsledek:

✅ resolver přestal dělat chybná rozhodnutí
4️⃣ Missing teams doplněny

Doplněno do DB:

Deportes Tolima
Lanus
Peñarol Montevideo
Estudiantes La Plata
FC Zwolle
Iraq
DR Congo

👉 Výsledek:

✅ unresolved_teams téměř 0
5️⃣ Přepis parseru (KLÍČOVÉ)

theodds_parse_multi_V3.py upraven na:

v_preferred_team_name_lookup
v_canonical_match_lookup

👉 Výsledek:

✅ TheOdds jede přes canonical model
📊 FINÁLNÍ VÝSLEDKY
RUN_ID: 165
odds_inserted     = 2520
skipped_no_team   = 0
skipped_no_match  = 72
leagues_ok        = 12 / 13
📈 INTERPRETACE
✅ OBROVSKÝ POSUN
PŘEDTÍM:
vysoké NO TEAM MATCH
chaos v názvech
špatné mapování
TEĎ:
🔥 NO TEAM MATCH = 0
❗ ZBÝVAJÍCÍ PROBLÉM
NO MATCH ID = 72

ALE:

👉 už to není problém:

názvů
aliasů
mappingu
🔍 CO TO TEĎ JE
1️⃣ Missing fixtures v DB

např.:

Libertadores
některé evropské ligy
2️⃣ Match existuje, ale:
jiný čas
jiná liga
jiná větev
3️⃣ Nové týmy bez historie

např.:

Lanus
Tolima
Peñarol
🧠 KLÍČOVÝ POSUN MYŠLENÍ
PŘEDTÍM:

👉 „nenašel jsem tým“

TEĎ:

👉 „tým mám, ale nemám zápas“

🧭 KDE JSME TEĎ
✅ ARCHITEKTURA HOTOVÁ

Máš:

ingest pipeline ✔
canonical model ✔
resolver ✔
mapping ✔
❗ ZBÝVÁ
▶️ DATA COVERAGE

(ne logika)

🚀 DALŠÍ KROK (NAVAZUJÍCÍ CHAT)
🎯 CÍL

Rozdělit 72 NO_MATCH_ID na:

❌ chybí fixture
⚠ existuje jinde
⚠ čas mismatch
▶️ první úkol v novém chatu

Napiš:

👉 „pokračujeme audit NO_MATCH_ID“

a já hned navážu:

skriptem:

493_audit_remaining_no_match_groups.sql

🔮 CO BUDE DÁL
1️⃣ Audit NO_MATCH_ID

→ přesná klasifikace

2️⃣ Fix strategie:
doplnění fixtures
rozšíření lookup tolerance
případně league mapping
3️⃣ Výsledek:
🎯 cílový stav:
NO MATCH ID < 20
🏁 SHRNUTÍ
🔥 DNEŠEK = BREAKTHROUGH

✔ canonical model hotový
✔ resolver funguje
✔ alias chaos vyřešen
✔ TheOdds napojen
✔ systém stabilní