/*
MATCHMATRIX SQL 17_8_E
TEAM SAFE MERGE PLAN V3

CO TO JE:
- Bezpečný návrhový plán sloučení duplicitních týmů.
- Nic nemění v databázi.
- Chrání reprezentace, mládežnické týmy, týmy bez sport_id a konfliktní provider ID.

K ČEMU TO JE:
- Ukáže OLD_TEAM_ID -> MASTER_TEAM_ID.
- Oddělí bezpečné klubové merge kandidáty od rizikových.
- Zabrání automatickému sloučení týmů, kde má stejný provider více různých provider_team_id.

KDE TO UVIDÍME:
- OPS Panel -> ČIŠTĚNÍ DB
- OPS Panel -> DATA QUALITY
- DBeaver audit před čištěním DB

JAK SE TO VYUŽIJE:
- 17_8_F může později zpracovat pouze SAFE_LOW_USAGE_MERGE.
- SAFE_PROVIDER_MAP_MERGE půjde až po kontrole provider map.
- HOLD_PROVIDER_ID_CONFLICT zůstane na ruční kontrolu.
*/

CREATE OR REPLACE VIEW ops.v_team_safe_merge_plan_v1 AS
WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY lower(trim(team_name)), sport_id
            ORDER BY
                master_candidate_score DESC,
                matches_count DESC,
                provider_maps_count DESC,
                team_id
        ) AS rn
    FROM ops.v_team_duplicate_audit_v2
),

masters AS (
    SELECT
        lower(trim(team_name)) AS team_name_norm,
        sport_id,
        team_id AS master_team_id
    FROM ranked
    WHERE rn = 1
),

base_plan AS (
    SELECT
        r.team_name,
        lower(trim(r.team_name)) AS team_name_norm,
        r.sport_id,
        r.team_id AS old_team_id,
        m.master_team_id,
        r.ext_source,
        r.ext_team_id,
        r.matches_count,
        r.article_links_count,
        r.provider_maps_count,
        r.master_candidate_score,
        r.rn
    FROM ranked r
    JOIN masters m
        ON m.team_name_norm = lower(trim(r.team_name))
       AND m.sport_id = r.sport_id
),

provider_conflicts AS (
    SELECT
        team_name_norm,
        sport_id,
        master_team_id,
        ext_source,
        COUNT(DISTINCT ext_team_id) AS distinct_provider_team_ids
    FROM base_plan
    WHERE rn <> 1
      AND matches_count = 0
      AND provider_maps_count > 0
      AND ext_source IS NOT NULL
      AND ext_team_id IS NOT NULL
    GROUP BY
        team_name_norm,
        sport_id,
        master_team_id,
        ext_source
    HAVING COUNT(DISTINCT ext_team_id) > 1
),

plan AS (
    SELECT
        b.team_name,
        b.sport_id,
        b.old_team_id,
        b.master_team_id,
        b.ext_source,
        b.ext_team_id,
        b.matches_count,
        b.article_links_count,
        b.provider_maps_count,
        b.master_candidate_score,

        CASE
            WHEN b.rn = 1
                THEN 'MASTER_KEEP'

            WHEN b.sport_id <= 0
                THEN 'HOLD_NO_SPORT_ID'

            WHEN b.team_name ~* ' U[0-9]+'
                THEN 'HOLD_NATIONAL_OR_YOUTH_TEAM'

            WHEN b.team_name IN (
                'Afghanistan','Albania','Algeria','Andorra','Angola','Argentina',
                'Armenia','Aruba','Australia','Austria','Azerbaijan','Bahrain',
                'Bangladesh','Belarus','Belgium','Belize','Benin','Bermuda',
                'Bhutan','Bolivia','Bonaire','Bosnia & Herzegovina','Botswana',
                'Brazil','Brunei','Bulgaria','Burkina Faso','Burundi','Cambodia',
                'Cameroon','Canada','Cape Verde Islands','Cayman Islands',
                'Central African Republic','Chile','China','Colombia','Croatia',
                'Denmark','Egypt','England','France','Germany','India','Iran',
                'Ireland','Italy','Japan','Kenya','Kuwait','Mexico','Morocco',
                'Netherlands','Nigeria','Norway','Panama','Poland','Portugal',
                'Qatar','Saudi Arabia','Scotland','Senegal','Serbia',
                'South Africa','South Korea','Spain','Sweden','Switzerland',
                'Tunisia','Turkey','Uganda','United Arab Emirates','Uruguay',
                'Wales','Zambia','Zimbabwe'
            )
                THEN 'HOLD_NATIONAL_OR_YOUTH_TEAM'

            WHEN pc.distinct_provider_team_ids IS NOT NULL
                THEN 'HOLD_PROVIDER_ID_CONFLICT'

            WHEN b.matches_count = 0
             AND b.article_links_count = 0
             AND b.provider_maps_count = 0
                THEN 'SAFE_LOW_USAGE_MERGE'

            WHEN b.matches_count = 0
             AND b.provider_maps_count > 0
                THEN 'SAFE_PROVIDER_MAP_MERGE'

            WHEN b.matches_count > 0
                THEN 'RISK_HAS_MATCHES'

            ELSE 'REVIEW'
        END AS merge_status,

        CASE
            WHEN b.rn = 1
                THEN 'Ponechat jako master tým.'

            WHEN b.sport_id <= 0
                THEN 'Neslučovat automaticky. Chybí sport_id.'

            WHEN b.team_name ~* ' U[0-9]+'
                THEN 'Neslučovat automaticky. Reprezentace nebo mládežnický tým.'

            WHEN b.team_name IN (
                'Afghanistan','Albania','Algeria','Andorra','Angola','Argentina',
                'Armenia','Aruba','Australia','Austria','Azerbaijan','Bahrain',
                'Bangladesh','Belarus','Belgium','Belize','Benin','Bermuda',
                'Bhutan','Bolivia','Bonaire','Bosnia & Herzegovina','Botswana',
                'Brazil','Brunei','Bulgaria','Burkina Faso','Burundi','Cambodia',
                'Cameroon','Canada','Cape Verde Islands','Cayman Islands',
                'Central African Republic','Chile','China','Colombia','Croatia',
                'Denmark','Egypt','England','France','Germany','India','Iran',
                'Ireland','Italy','Japan','Kenya','Kuwait','Mexico','Morocco',
                'Netherlands','Nigeria','Norway','Panama','Poland','Portugal',
                'Qatar','Saudi Arabia','Scotland','Senegal','Serbia',
                'South Africa','South Korea','Spain','Sweden','Switzerland',
                'Tunisia','Turkey','Uganda','United Arab Emirates','Uruguay',
                'Wales','Zambia','Zimbabwe'
            )
                THEN 'Neslučovat automaticky. Reprezentace / národní tým.'

            WHEN pc.distinct_provider_team_ids IS NOT NULL
                THEN 'Neslučovat automaticky. Stejný provider má pro stejný master tým více různých provider_team_id.'

            WHEN b.matches_count = 0
             AND b.article_links_count = 0
             AND b.provider_maps_count = 0
                THEN 'Bezpečný kandidát: nemá zápasy, články ani provider mapu.'

            WHEN b.matches_count = 0
             AND b.provider_maps_count > 0
                THEN 'Relativně bezpečné: přesunout provider mapu na master tým.'

            WHEN b.matches_count > 0
                THEN 'Riziko: tým má zápasy. Neslučovat automaticky bez kontroly.'

            ELSE 'Vyžaduje ruční kontrolu.'
        END AS recommendation_cz

    FROM base_plan b
    LEFT JOIN provider_conflicts pc
        ON pc.team_name_norm = b.team_name_norm
       AND pc.sport_id = b.sport_id
       AND pc.master_team_id = b.master_team_id
       AND pc.ext_source = b.ext_source
)

SELECT
    team_name,
    sport_id,
    old_team_id,
    master_team_id,
    ext_source,
    ext_team_id,
    matches_count,
    article_links_count,
    provider_maps_count,
    master_candidate_score,
    merge_status,
    recommendation_cz,
    now() AS generated_at
FROM plan
ORDER BY
    team_name,
    sport_id,
    CASE merge_status
        WHEN 'MASTER_KEEP' THEN 1
        WHEN 'SAFE_LOW_USAGE_MERGE' THEN 2
        WHEN 'SAFE_PROVIDER_MAP_MERGE' THEN 3
        WHEN 'HOLD_PROVIDER_ID_CONFLICT' THEN 4
        WHEN 'HOLD_NO_SPORT_ID' THEN 5
        WHEN 'HOLD_NATIONAL_OR_YOUTH_TEAM' THEN 6
        WHEN 'REVIEW' THEN 7
        ELSE 8
    END,
    master_candidate_score DESC;