/*
MATCHMATRIX SQL 19_A

PLAYER DUPLICATE PREVENTION AUDIT V1

CO TO JE:
- Audit možných duplicit hráčů v public.players.

K ČEMU TO JE:
- Najde hráče se stejným normalizovaným jménem.
- Rozdělí duplicity podle sportu a providerů.
- Připraví bezpečný podklad pro Player Duplicate Prevention.

KDE TO UVIDÍME:
- People Governance
- OPS Panel
- Player Identity Governance
- budoucí Player Cards

JAK SE TO VYUŽIJE:
- Před PC2 People harvestem zjistíme rizikové duplicity.
- Tento audit nic nemaže ani neslučuje.
- Pouze označí kandidáty ke kontrole.

NAVAZUJE NA:
- Team Duplicate Prevention
- Player Identity Governance
- Player Provider Map Governance

DALŠÍ KROK:
- 19_B_create_player_duplicate_candidate_detail_v1.sql
*/

DROP VIEW IF EXISTS ops.v_player_duplicate_prevention_audit_v1;

CREATE OR REPLACE VIEW ops.v_player_duplicate_prevention_audit_v1 AS

WITH player_base AS (
    SELECT
        p.id AS player_id,
        p.sport_id,
        p.team_id,
        p.name AS player_name,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.nationality,
        p.position,
        p.ext_source,
        p.ext_player_id,
        lower(
            regexp_replace(
                trim(
                    COALESCE(
                        NULLIF(p.name, ''),
                        trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, ''))
                    )
                ),
                '\s+',
                ' ',
                'g'
            )
        ) AS normalized_name,
        ppm.provider,
        ppm.provider_player_id,
        ppm.provider_team_id,
        ppm.provider_team_name,
        ppm.provider_player_name
    FROM public.players p
    LEFT JOIN public.player_provider_map ppm
        ON ppm.player_id = p.id
    WHERE COALESCE(
        NULLIF(p.name, ''),
        trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, ''))
    ) IS NOT NULL
      AND trim(
        COALESCE(
            NULLIF(p.name, ''),
            trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, ''))
        )
      ) <> ''
),

grouped AS (
    SELECT
        sport_id,
        normalized_name,
        COUNT(DISTINCT player_id) AS player_count,
        COUNT(DISTINCT provider) AS provider_count,
        COUNT(DISTINCT team_id) AS team_count,
        string_agg(DISTINCT provider, ', ' ORDER BY provider) AS providers,
        MIN(player_name) AS sample_name,
        MIN(birth_date) AS min_birth_date,
        MAX(birth_date) AS max_birth_date,
        COUNT(DISTINCT birth_date) FILTER (WHERE birth_date IS NOT NULL) AS birth_date_count,
        COUNT(DISTINCT nationality) FILTER (WHERE nationality IS NOT NULL AND nationality <> '') AS nationality_count
    FROM player_base
    GROUP BY
        sport_id,
        normalized_name
),

classified AS (
    SELECT
        sport_id,
        normalized_name,
        sample_name,
        player_count,
        provider_count,
        team_count,
        providers,
        min_birth_date,
        max_birth_date,
        birth_date_count,
        nationality_count,

        CASE
            WHEN player_count = 1
                THEN 'SINGLE_OK'

            WHEN player_count > 1
             AND birth_date_count > 1
                THEN 'SAME_NAME_DIFFERENT_BIRTHDATE_HOLD'

            WHEN player_count > 1
             AND provider_count > 1
                THEN 'CROSS_PROVIDER_DUPLICATE_CANDIDATE'

            WHEN player_count > 1
             AND provider_count = 1
                THEN 'SAME_PROVIDER_DUPLICATE_CANDIDATE'

            ELSE 'REVIEW'
        END AS duplicate_status,

        CASE
            WHEN player_count = 1
                THEN 'LOW'

            WHEN player_count > 1
             AND birth_date_count > 1
                THEN 'HIGH_HOLD'

            WHEN player_count > 1
             AND provider_count > 1
                THEN 'HIGH'

            WHEN player_count > 1
             AND provider_count = 1
                THEN 'MEDIUM'

            ELSE 'REVIEW'
        END AS risk_level,

        CASE
            WHEN player_count = 1
                THEN 'KEEP'

            WHEN player_count > 1
             AND birth_date_count > 1
                THEN 'HOLD_BIRTHDATE_REVIEW'

            WHEN player_count > 1
                THEN 'REVIEW_BEFORE_MERGE'

            ELSE 'REVIEW'
        END AS recommended_action

    FROM grouped
)

SELECT
    sport_id,
    normalized_name,
    sample_name,
    player_count,
    provider_count,
    team_count,
    providers,
    min_birth_date,
    max_birth_date,
    birth_date_count,
    nationality_count,
    duplicate_status,
    risk_level,
    recommended_action,
    now() AS refreshed_at
FROM classified
ORDER BY
    CASE risk_level
        WHEN 'HIGH_HOLD' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'REVIEW' THEN 4
        ELSE 5
    END,
    player_count DESC,
    sample_name;