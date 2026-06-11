/*
MATCHMATRIX SQL 18_1_B
PLAYER PROVIDER IDENTITY COLLISION PLAN V1

CO TO JE:
- Detailní plán oprav kolizí provider identity hráčů.

K ČEMU TO JE:
- Najde případy, kdy stejný provider + external_player_id ukazuje na více player_id.

KDE TO UVIDÍME:
- OPS Panel V18 → People Layer → Provider Governance.

JAK SE TO VYUŽIJE:
- Připraví bezpečný plán, který player_id zachovat a který opravit / přemapovat.
*/

CREATE OR REPLACE VIEW ops.v_player_provider_identity_collision_plan_v1 AS
WITH collisions AS (
    SELECT
        provider,
        external_player_id,
        COUNT(DISTINCT player_id) AS player_id_count
    FROM ops.v_player_provider_map_governance_audit_v1
    WHERE governance_issue = 'PROVIDER_IDENTITY_COLLISION'
    GROUP BY provider, external_player_id
),

details AS (
    SELECT
        a.source_table,
        a.source_id,
        a.player_id,
        p.name,
        p.first_name,
        p.last_name,
        p.birth_date,
        p.nationality,
        p.position,
        p.team_id,
        a.provider,
        a.external_player_id,
        a.external_team_id,
        a.external_player_name,
        a.created_at,
        a.updated_at,

        ROW_NUMBER() OVER (
            PARTITION BY a.provider, a.external_player_id
            ORDER BY
                CASE WHEN p.birth_date IS NOT NULL THEN 1 ELSE 2 END,
                CASE WHEN p.photo_url IS NOT NULL AND trim(p.photo_url) <> '' THEN 1 ELSE 2 END,
                p.created_at ASC,
                p.id ASC
        ) AS preferred_rank

    FROM ops.v_player_provider_map_governance_audit_v1 a
    JOIN collisions c
      ON c.provider = a.provider
     AND c.external_player_id = a.external_player_id
    LEFT JOIN public.players p
      ON p.id = a.player_id
    WHERE a.governance_issue = 'PROVIDER_IDENTITY_COLLISION'
)

SELECT
    source_table,
    source_id,
    player_id,
    name,
    first_name,
    last_name,
    birth_date,
    nationality,
    position,
    team_id,
    provider,
    external_player_id,
    external_team_id,
    external_player_name,
    created_at,
    updated_at,

    CASE
        WHEN preferred_rank = 1 THEN true
        ELSE false
    END AS suggested_canonical_player,

    preferred_rank,

    CASE
        WHEN preferred_rank = 1
            THEN 'Zachovat jako canonical player_id pro tuto provider identitu.'
        ELSE 'Přemapovat nebo odstranit duplicitní provider identitu podle canonical player_id.'
    END AS proposed_action

FROM details
ORDER BY
    provider,
    external_player_id,
    preferred_rank;