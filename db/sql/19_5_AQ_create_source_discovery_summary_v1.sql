/*
================================================================================
MATCHMATRIX 19_5_AQ - SOURCE DISCOVERY SUMMARY V1
================================================================================

CO TO JE:
-----------
Souhrnné view nad Source Discovery Engine.

Agreguje doporučené zdroje dat z
ops.v_missing_data_source_recommendations_v1
na úroveň:

SPORT
→ ENTITY
→ PROVIDER
→ SOURCE TYPE
→ RECOMMENDED MODE

K ČEMU TO JE:
--------------
Zjednodušuje tisíce řádků doporučení na přehledný dashboard.

Místo jednotlivých polí:

full_name
team_id
birth_date
photo_url
provider_profile

ukazuje souhrn:

FB PLAYERS → API_PROVIDER
FB PLAYERS → WIKIDATA
FB PLAYERS → OFFICIAL_TEAM_SITE

a jejich prioritu.

KDE TO UVIDÍME:
----------------
OPS Panel V18+

Sekce:

SOURCE DISCOVERY
PROVIDER DISCOVERY
AUTONOMOUS HARVEST
DATA GAP ENGINE

Budoucí:

AI Source Discovery Dashboard

JAK SE TO VYUŽIJE:
------------------
Autonomní mozek MatchMatrix bude používat toto view jako:

1)
Výběr dalšího zdroje dat.

2)
Výběr fallback providera.

3)
Generování Source Discovery Queue.

4)
Automatické rozhodování:

API_PROVIDER
↓
WIKIDATA
↓
OFFICIAL_SITE
↓
FEDERATION_SITE

5)
Budoucí autonomní vyhledávání nových providerů.

VÝSTUP:
--------
sport_code
entity_type
provider
coverage_status
source_type
recommended_mode
missing_fields
best_score

================================================================================
*/


DROP VIEW IF EXISTS ops.v_source_discovery_summary_v1;

CREATE VIEW ops.v_source_discovery_summary_v1 AS

SELECT
    sport_code,
    entity_type,
    provider,
    coverage_status,
    source_type,
    recommended_mode,
    COUNT(*) AS missing_fields,
    MAX(discovery_score) AS best_score

FROM ops.v_missing_data_source_recommendations_v1

GROUP BY
    sport_code,
    entity_type,
    provider,
    coverage_status,
    source_type,
    recommended_mode;