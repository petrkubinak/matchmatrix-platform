MATCHMATRIX – STAV PROJEKTU (NO_MATCH_ID AUDIT)
📅 Datum: 02.04.2026
🎯 CO JSME ŘEŠILI

Cíl:

proč TheOdds → nemá match (NO_MATCH_ID)

🧩 FÁZE ANALÝZY
1️⃣ Import a audit
vytvořen audit 493
napojení na unmatched_theodds
2️⃣ PROBLÉM – resolver

Zjištěno:

chybné sloupce (home_raw, away_raw)
resolver nebral správná data

✔ opraveno

3️⃣ PROBLÉM – aliasy

Zjištěno:

špatné větve:
U18 / U20
jiný sport (hockey vs football)
špatná země (Vitória SC vs Brazil)

✔ vyřešeno:

odstranění chybných aliasů
přidání správných:
Vitoria → EC Vitória
Sporting Cristal → CS Cristal
Czech Republic → Czechia
4️⃣ PROBLÉM – záložní párování

Zjištěno:

resolver bral špatné kandidáty mimo aliasy

✔ potvrzeno auditem 494

📊 FINÁLNÍ STAV
neřešený_název_týmu = 0 ✅ 
chybějící_zápas = 72 ❗
🧠 INTERPRETACE

👉 systém už:

správně pozná týmy
správně mapuje aliasy
správně resolve funguje

👉 problém je už pouze:

❗ CHYBÍ MATCH DATA (fixtures)

📦 ROZPAD 72 (realita)
❌ alias / řešení → 0
❌ chyba → 0
❗ pokrytí → 72
🚀 DALŠÍ KROK
🎯 496 – krytí auditu

Cíl:

rozpadnout 72 podle lig
zjistit:
kde chybí ingest
kde chybí sezóny
kde existují zápasy jinde
🧭 SMĚR PROJEKTU

Teď už neřešíme:

alias
vyřešit
názvy

👉 řešíme:

DATOVÉ POKRYTÍ (zápasy)

🔥 CO JE HOTOVO (KLÍČOVÉ)

✔ kanonická vrstva
✔ alias systém
✔ resolver
✔ auditní kanál

❗ CO CHYBÍ
doplnit fixtures
optimalizovat ingest
napojit na odds → match → ticket
🏁 SHRNUTÍ

👉 systém je funkční
👉 problém je čistě datový