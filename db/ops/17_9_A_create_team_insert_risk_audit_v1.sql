/*
MATCHMATRIX SQL 17_9_A
TEAM DUPLICATE PREVENTION AUDIT V1

CO TO JE:
- Audit rizika duplicit týmů v public.teams.

K ČEMU TO JE:
- Najde týmy, které už teď vypadají jako duplicity nebo rizikové záznamy.

KDE TO UVIDÍME:
- OPS Panel → DATA QUALITY / ČIŠTĚNÍ DB / Team Duplicate Prevention.

JAK SE TO VYUŽIJE:
- Před dalšími ingest workery ukáže, kde hrozí nové duplicity.
- Navazuje na plán 17_9 ochrany proti duplicitám týmů.
*/

CREATE OR REPLACE VIEW ops.v_team_insert_risk_audit_v1 AS
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
),

provider_dupes AS (
    SELECT
        ext_source,
        ext_team_id,
        COUNT(*) AS duplicate_count
    FROM base
    WHERE ext_source IS NOT NULL
      AND ext_team_id IS NOT NULL
    GROUP BY ext_source, ext_team_id
    HAVING COUNT(*) > 1
),

name_sport_dupes AS (
    SELECT
        normalized_name,
        sport_id,
        COUNT(*) AS duplicate_count
    FROM base
    WHERE normalized_name IS NOT NULL
      AND normalized_name <> ''
      AND sport_id IS NOT NULL
    GROUP BY normalized_name, sport_id
    HAVING COUNT(*) > 1
)

SELECT
    b.team_id,
    b.name,
    b.normalized_name,
    b.sport_id,
    b.ext_source,
    b.ext_team_id,
    b.logo_url,
    b.created_at,
    b.updated_at,

    CASE
        WHEN pd.duplicate_count IS NOT NULL THEN 'PROVIDER_ID_DUPLICATE'
        WHEN nsd.duplicate_count IS NOT NULL THEN 'NAME_SPORT_DUPLICATE'
        ELSE 'OK'
    END AS risk_type,

    CASE
        WHEN pd.duplicate_count IS NOT NULL THEN pd.duplicate_count
        WHEN nsd.duplicate_count IS NOT NULL THEN nsd.duplicate_count
        ELSE 1
    END AS duplicate_count,

    CASE
        WHEN pd.duplicate_count IS NOT NULL THEN 'HIGH'
        WHEN nsd.duplicate_count IS NOT NULL THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level,

    CASE
        WHEN pd.duplicate_count IS NOT NULL
            THEN 'Stejný ext_source + ext_team_id existuje vícekrát. Worker nesmí vytvořit nový tým, ale musí použít existující team_id.'
        WHEN nsd.duplicate_count IS NOT NULL
            THEN 'Stejný normalizovaný název + sport_id existuje vícekrát. Nutná kontrola aliasů nebo ruční merge.'
        ELSE 'Bez zjištěného rizika.'
    END AS recommended_action

FROM base b
LEFT JOIN provider_dupes pd
    ON pd.ext_source = b.ext_source
   AND pd.ext_team_id = b.ext_team_id
LEFT JOIN name_sport_dupes nsd
    ON nsd.normalized_name = b.normalized_name
   AND nsd.sport_id = b.sport_id
WHERE pd.duplicate_count IS NOT NULL
   OR nsd.duplicate_count IS NOT NULL
ORDER BY
    risk_level DESC,
    duplicate_count DESC,
    sport_id,
    normalized_name;