MATCHMATRIX – STAV A NAVÁZÁNÍ (VB + BK HOTOVO)
✅ CORE PIPELINE – POTVRZENO
🏀 BK (Basketball)
teams ✔ CONFIRMED
fixtures ✔ CONFIRMED (batch + runtime OK)
leagues ✔ CONFIRMED
vyřešen multisport problém (api_sport)
plně funkční:
pull → raw → staging → provider_map → public.matches
🏐 VB (Volleyball)
teams ✔ CONFIRMED
fixtures ✔ CONFIRMED
leagues ✔ CONFIRMED
provider: api_volleyball (bez multisport komplikací)

DB důkaz:

public.matches = 178
všechny status = FINISHED
league = SuperLega
team_provider_map = 12

➡️ potvrzen kompletní chain:

pull → raw → staging → provider_map → public.matches + league mapping

Viz audit:

📊 AUDIT VRSTVA
runtime_entity_audit

VB i BK mají:

pull_confirmed = true
raw_confirmed = true
staging_confirmed = true
provider_map_confirmed = true
public_merge_confirmed = true

➡️ end-to-end potvrzeno

sport_completion_audit

VB i BK:

core = DONE
production_readiness = READY
🧠 KLÍČOVÉ ZJIŠTĚNÍ
1️⃣ Máme 2 referenční pipeline typy
A) api_sport (multisport)
potřeba:
sport-safe identity
oddělení týmů
použito u: BK
B) single-sport provider
jednodušší flow
bez kolizí
použito u: VB
2️⃣ Pipeline pattern je FINÁLNĚ OVĚŘENÝ

Používáme:

pull (.ps1)
→ raw payload
→ staging.stg_provider_*
→ provider_map
→ public (teams + matches + leagues)

➡️ funguje univerzálně

🚀 DALŠÍ KROK
🎯 CÍL: ROZŠÍŘENÍ NA DALŠÍ SPORT
👉 další sport: AFB (American Football)
Co očekávat:
jiný provider (pravděpodobně)
menší coverage
ale:
👉 použijeme VB pattern (jednodušší)
⚙️ KONKRÉTNÍ NAVÁZÁNÍ

V novém chatu:

👉 napiš:

AFB pipeline

a jedeme:

audit dostupných dat
ingest (teams)
provider_map
fixtures
merge do public
audit zápis (stejně jako VB)
🧩 STAV SYSTÉMU
Sport	Teams	Fixtures	Leagues	Stav
FB	⚠️ runnable	⚠️ runnable	⚠️	historicky OK
HK	✅ confirmed	⚠️ partial	⚠️	rozpracované
BK	✅ confirmed	✅ confirmed	✅	HOTOVO
VB	✅ confirmed	✅ confirmed	✅	HOTOVO
AFB	❌	❌	❌	NEXT
🧭 SMĚR

Teď už neděláme experimenty.

👉 jedeme sport po sportu
👉 vždy:

pipeline
merge
audit
DONE

Stačí v novém chatu napsat:

👉 AFB pipeline

a jedeme dál přesně tam, kde teď končíme.