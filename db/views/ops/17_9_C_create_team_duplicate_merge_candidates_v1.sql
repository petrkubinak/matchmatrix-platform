/*
MATCHMATRIX SQL 17_9_C
TEAM DUPLICATE MERGE CANDIDATES V1

CO TO JE:
- Detailní audit kandidátů na bezpečný merge týmů.

K ČEMU TO JE:
- Oddělí reálné duplicity od správných multiprovider záznamů.
- Připraví podklad pro bezpečné sloučení týmů.

KDE TO UVIDÍME:
- OPS Panel → DATA QUALITY / TEAM DUPLICATE PREVENTION.

JAK SE TO VYUŽIJE:
- Nejprve ověříme CRITICAL a HIGH případy.
- Teprve potom vytvoříme opravný merge skript.
*/

CREATE OR REPLACE VIEW ops.v_team_duplicate_merge_candidates_v1 AS
WITH base AS (
    SELECT
        t.id AS team_id,
        t.name,
        lower(trim(t.name)) AS normalized_name,
        t.sport_id,
        t.ext_source,
        t.ext_team_id,
        t.logo_url,
        t.created_at,
        t.updated_at
    FROM public.teams t
    WHERE t.name IS NOT NULL
      AND trim(t.name) <> ''
      AND t.sport_id IS NOT NULL
),

risk_groups AS (
    SELECT *
    FROM ops.v_team_canonical_identity_audit_v1
    WHERE identity_status IN (
        'REAL_PROVIDER_DUPLICATE',
        'SUSPECT_MISSING_CANONICAL',
        'SUSPECT_SAME_PROVIDER_MULTIPLE_IDS'
    )
),

joined AS (
    SELECT
        rg.identity_status,
        rg.risk_level,
        rg.normalized_name,
        rg.sport_id,
        rg.team_rows,
        rg.team_id_count,
        rg.provider_count,
        rg.provider_team_id_count,
        rg.providers,
        rg.provider_team_ids,

        b.team_id,
        b.name,
        b.ext_source,
        b.ext_team_id,
        b.logo_url,
        b.created_at,
        b.updated_at,

        ROW_NUMBER() OVER (
            PARTITION BY rg.normalized_name, rg.sport_id
            ORDER BY
                CASE
                    WHEN b.ext_source NOT LIKE '%missing_canonical%' THEN 1
                    ELSE 2
                END,
                CASE
                    WHEN b.logo_url IS NOT NULL AND trim(b.logo_url) <> '' THEN 1
                    ELSE 2
                END,
                b.created_at ASC,
                b.team_id ASC
        ) AS preferred_rank

    FROM risk_groups rg
    JOIN base b
      ON b.normalized_name = rg.normalized_name
     AND b.sport_id = rg.sport_id
)

SELECT
    identity_status,
    risk_level,
    normalized_name,
    sport_id,
    team_rows,
    team_id_count,
    provider_count,
    provider_team_id_count,
    providers,
    provider_team_ids,

    team_id,
    name,
    ext_source,
    ext_team_id,
    logo_url,
    created_at,
    updated_at,

    CASE
        WHEN preferred_rank = 1 THEN true
        ELSE false
    END AS suggested_canonical,

    preferred_rank,

    CASE
        WHEN identity_status = 'REAL_PROVIDER_DUPLICATE'
            THEN 'Bezpečný kandidát: stejný provider + stejné ext_team_id. Sloučit na suggested_canonical team_id.'

        WHEN identity_status = 'SUSPECT_MISSING_CANONICAL'
         AND ext_source LIKE '%missing_canonical%'
            THEN 'Kandidát k přemapování na canonical tým a následnému odstranění duplicitního missing_canonical záznamu.'

        WHEN identity_status = 'SUSPECT_MISSING_CANONICAL'
         AND ext_source NOT LIKE '%missing_canonical%'
            THEN 'Pravděpodobný canonical tým. Zachovat.'

        WHEN identity_status = 'SUSPECT_SAME_PROVIDER_MULTIPLE_IDS'
            THEN 'Ruční kontrola: stejný název, stejný provider, ale více ext_team_id. Může jít o různé týmy.'

        ELSE 'Ruční kontrola.'
    END AS merge_action

FROM joined
ORDER BY
    CASE risk_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        ELSE 3
    END,
    normalized_name,
    preferred_rank;