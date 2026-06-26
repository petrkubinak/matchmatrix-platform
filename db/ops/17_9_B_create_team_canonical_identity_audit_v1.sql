/*
MATCHMATRIX SQL 17_9_B
TEAM CANONICAL IDENTITY AUDIT V1

CO TO JE:
- Audit, který rozlišuje správné multiprovider týmy od podezřelých duplicit.

K ČEMU TO JE:
- Abychom neslučovali správné záznamy typu:
  api_football + api_sport + football_data.
- A zároveň našli skutečné chyby jako:
  api_football + api_football_missing_canonical.

KDE TO UVIDÍME:
- OPS Panel → DATA QUALITY / TEAM DUPLICATE PREVENTION.

JAK SE TO VYUŽIJE:
- Připraví bezpečný základ pro budoucí merge, aliasy a ochranu workerů.
*/

CREATE OR REPLACE VIEW ops.v_team_canonical_identity_audit_v1 AS
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

groups AS (
    SELECT
        normalized_name,
        sport_id,
        COUNT(*) AS team_rows,
        COUNT(DISTINCT team_id) AS team_id_count,
        COUNT(DISTINCT ext_source) AS provider_count,
        COUNT(DISTINCT ext_team_id) AS provider_team_id_count,
        STRING_AGG(DISTINCT ext_source, ', ' ORDER BY ext_source) AS providers,
        STRING_AGG(DISTINCT ext_team_id::text, ', ' ORDER BY ext_team_id::text) AS provider_team_ids,
        MIN(created_at) AS first_seen_at,
        MAX(updated_at) AS last_updated_at
    FROM base
    GROUP BY normalized_name, sport_id
    HAVING COUNT(*) > 1
),

classified AS (
    SELECT
        g.*,

        CASE
            WHEN providers LIKE '%missing_canonical%'
                THEN 'SUSPECT_MISSING_CANONICAL'

            WHEN provider_count = 1
             AND provider_team_id_count > 1
                THEN 'SUSPECT_SAME_PROVIDER_MULTIPLE_IDS'

            WHEN provider_count = 1
             AND provider_team_id_count = 1
             AND team_rows > 1
                THEN 'REAL_PROVIDER_DUPLICATE'

            WHEN provider_count > 1
             AND provider_team_id_count = 1
                THEN 'SAFE_MULTI_PROVIDER_SAME_EXTERNAL_ID'

            WHEN provider_count > 1
             AND provider_team_id_count > 1
                THEN 'MULTI_PROVIDER_NEEDS_MAPPING_REVIEW'

            ELSE 'UNKNOWN_REVIEW'
        END AS identity_status,

        CASE
            WHEN providers LIKE '%missing_canonical%'
                THEN 'HIGH'

            WHEN provider_count = 1
             AND provider_team_id_count > 1
                THEN 'HIGH'

            WHEN provider_count = 1
             AND provider_team_id_count = 1
             AND team_rows > 1
                THEN 'CRITICAL'

            WHEN provider_count > 1
             AND provider_team_id_count = 1
                THEN 'LOW'

            WHEN provider_count > 1
             AND provider_team_id_count > 1
                THEN 'MEDIUM'

            ELSE 'MEDIUM'
        END AS risk_level
    FROM groups g
)

SELECT
    c.normalized_name,
    c.sport_id,
    c.team_rows,
    c.team_id_count,
    c.provider_count,
    c.provider_team_id_count,
    c.providers,
    c.provider_team_ids,
    c.identity_status,
    c.risk_level,
    c.first_seen_at,
    c.last_updated_at,

    CASE
        WHEN c.identity_status = 'SUSPECT_MISSING_CANONICAL'
            THEN 'Záznam vznikl přes missing canonical pipeline. Ověřit a přemapovat na správný canonical team_id.'

        WHEN c.identity_status = 'SUSPECT_SAME_PROVIDER_MULTIPLE_IDS'
            THEN 'Stejný provider má pod stejným názvem více ext_team_id. Nutná ruční kontrola, může jít o dva různé týmy stejného názvu.'

        WHEN c.identity_status = 'REAL_PROVIDER_DUPLICATE'
            THEN 'Stejný provider + stejné ext_team_id existuje vícekrát. Kandidát na bezpečný merge.'

        WHEN c.identity_status = 'SAFE_MULTI_PROVIDER_SAME_EXTERNAL_ID'
            THEN 'Více providerů ukazuje na stejný externí tým. Nízké riziko, vhodné pro canonical mapping.'

        WHEN c.identity_status = 'MULTI_PROVIDER_NEEDS_MAPPING_REVIEW'
            THEN 'Více providerů a více externích ID. Pravděpodobně správný multiprovider tým, ale vyžaduje mapping audit.'

        ELSE 'Nutná ruční kontrola.'
    END AS recommended_action

FROM classified c
ORDER BY
    CASE c.risk_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
        ELSE 5
    END,
    c.team_rows DESC,
    c.normalized_name;