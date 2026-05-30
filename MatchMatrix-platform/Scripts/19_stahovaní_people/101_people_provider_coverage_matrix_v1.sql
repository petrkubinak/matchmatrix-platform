/*
===============================================================================
MATCHMATRIX – PEOPLE PROVIDER COVERAGE MATRIX V1
===============================================================================

CO TO DĚLÁ
-----------
Zobrazí reálný stav PEOPLE layer pro všechny sporty/provider kombinace.

K ČEMU TO JE
-------------
Pomůže rozhodnout:
- které sporty už mají usable PEOPLE provider
- kde jsou jen partial endpointy
- kde provider vrací empty data
- kde je nutné hledat nový provider

CO UVIDÍME
-----------
SPORT
PROVIDER
ENTITY
ENDPOINT
TECHNICAL STATUS
FINAL VERDICT
REQUIRES_PRO
NEXT STEP

JAK TO VYUŽIJEME
----------------
Výstup bude hlavní rozhodovací tabulka pro:
- nákup providerů
- prioritizaci sportů
- roadmapu PEOPLE layer
- AI/rating/player pages
===============================================================================
*/

SELECT
    provider,
    sport_code,
    entity,
    endpoint_name,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    usable_for_league,
    usable_for_team,
    usable_for_season,
    technical_status,
    data_quality_status,
    final_verdict,
    requires_pro,
    alternative_provider_needed,
    next_step,
    evidence_note,
    updated_at
FROM ops.provider_people_audit
ORDER BY
    sport_code,
    entity,
    provider,
    updated_at DESC;