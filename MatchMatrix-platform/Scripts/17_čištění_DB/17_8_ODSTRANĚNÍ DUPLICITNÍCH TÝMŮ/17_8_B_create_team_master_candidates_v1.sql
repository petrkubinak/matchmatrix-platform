CREATE OR REPLACE VIEW ops.v_team_master_candidates_v1 AS
WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY lower(team_name)
            ORDER BY
                master_candidate_score DESC,
                matches_count DESC,
                provider_maps_count DESC,
                team_id
        ) AS rn
    FROM ops.v_team_duplicate_audit_v1
)
SELECT
    team_name,
    team_id,

    CASE
        WHEN team_name ~* ' U[0-9]+'
            THEN 'YOUTH_NATIONAL_TEAM'

        WHEN team_name IN (
            'England','France','Germany','Italy','Spain',
            'Portugal','Netherlands','Belgium','Denmark',
            'Scotland','Brazil','Argentina','Japan',
            'Australia','Canada','Croatia','Norway',
            'Sweden','Hungary','Austria',

            'Colombia','Egypt','India','Iran','Ireland',
            'Kenya','Mexico','Morocco','Nigeria','Panama',
            'Poland','Saudi Arabia','Senegal','Serbia',
            'South Africa','South Korea','Switzerland',
            'Tunisia','Uruguay'
        )
            THEN 'NATIONAL_TEAM'

        ELSE 'CLUB'
    END AS duplicate_type,

    duplicate_count,
    matches_count,
    article_links_count,
    provider_maps_count,
    master_candidate_score,

    CASE
        WHEN team_name ~* ' U[0-9]+'
          OR team_name IN (
            'England','France','Germany','Italy','Spain',
            'Portugal','Netherlands','Belgium','Denmark',
            'Scotland','Brazil','Argentina','Japan',
            'Australia','Canada','Croatia','Norway',
            'Sweden','Hungary','Austria',

            'Colombia','Egypt','India','Iran','Ireland',
            'Kenya','Mexico','Morocco','Nigeria','Panama',
            'Poland','Saudi Arabia','Senegal','Serbia',
            'South Africa','South Korea','Switzerland',
            'Tunisia','Uruguay'
          )
            THEN 'HOLD_REVIEW'

        WHEN rn = 1
            THEN 'MASTER_TEAM'

        ELSE 'MERGE_CANDIDATE'
    END AS candidate_status,

    MAX(
        CASE
            WHEN rn = 1 THEN team_id
        END
    ) OVER (
        PARTITION BY lower(team_name)
    ) AS suggested_master_team_id,

    ext_source,
    ext_team_id,
    sport_id

FROM ranked
ORDER BY
    lower(team_name),
    candidate_status,
    master_candidate_score DESC;