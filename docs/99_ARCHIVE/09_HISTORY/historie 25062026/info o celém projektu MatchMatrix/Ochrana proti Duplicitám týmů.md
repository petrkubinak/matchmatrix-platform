Jasně. Nová sekce bude:

17_9 = TEAM DUPLICATE PREVENTION / OCHRANA PROTI NOVÝM DUPLICITÁM
Cíl 17_9

Neřešit už jen následky, ale zabránit tomu, aby další ingest znovu vytvářel duplicity v public.teams.

Navržený postup
17_9_A_create_team_insert_risk_audit_v1.sql

CO TO JE: audit, kde by při dalším insertu mohl vzniknout duplicitní tým.

K ČEMU TO JE: najde rizikové kombinace name + sport_id + ext_source + ext_team_id.

KDE TO UVIDÍME: OPS Panel → ČIŠTĚNÍ DB / DATA QUALITY.

JAK SE TO VYUŽIJE: ukáže, které providery/workery musíme chránit.

17_9_B_create_team_provider_guard_v1.sql

CO TO JE: view, které říká: pokud už existuje provider + provider_team_id, nesmí vzniknout nový tým.

K ČEMU TO JE: ochrana proti duplicitám z API.

17_9_C_create_team_name_sport_guard_v1.sql

CO TO JE: kontrola podobných týmů podle lower(trim(name)) + sport_id.

K ČEMU TO JE: pokud provider nemá mapu, hledáme existující tým podle názvu a sportu.

17_9_D_create_team_alias_guard_v1.sql

CO TO JE: kontrola přes aliasy.

K ČEMU TO JE: aby Barcelona, FC Barcelona, Barcelona FC nevedly ke třem týmům.

17_9_E_create_team_duplicate_prevention_dashboard_v1.sql

CO TO JE: souhrnné view pro panel.

K ČEMU TO JE: ukáže nové riziko duplicit po každém ingestu.

Důležité pravidlo pro workery

Před každým budoucím insertem do public.teams musí worker udělat:

1. hledat provider mapu
2. hledat alias
3. hledat name + sport_id
4. teprve potom INSERT
Pokračování v novém chatu

Začneme tímto:

17_9_A_create_team_insert_risk_audit_v1.sql

Až otevřeme nový chat, napiš jen:

Pokračujeme 17_9_A Team Duplicate Prevention Audit