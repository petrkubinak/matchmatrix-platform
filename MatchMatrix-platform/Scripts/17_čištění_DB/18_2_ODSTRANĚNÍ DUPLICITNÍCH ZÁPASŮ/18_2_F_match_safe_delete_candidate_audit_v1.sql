/*
MATCHMATRIX SQL 18_2_F Match Safe Delete Candidate Audit V1

CO TO JE:
- Finální audit kandidátů na bezpečné odstranění duplicitních zápasů.

K ČEMU TO JE:
- Ověří, že duplicate_match_id není použitý v OPS queue pro player stats.

KDE TO UVIDÍME:
- OPS Governance.

JAK SE TO VYUŽIJE:
- Pokud bude SAFE_DELETE_READY, můžeme připravit bezpečný delete skript.
*/

CREATE OR REPLACE VIEW ops.v_match_safe_delete_candidate_audit_v1 AS

WITH duplicate_ids AS (
    SELECT
        master_match_id,
        TRIM(x)::bigint AS duplicate_match_id
    FROM ops.v_match_safe_merge_plan_v1,
    LATERAL regexp_split_to_table(duplicate_match_ids, ',') AS x
),

dup_detail AS (
    SELECT
        d.master_match_id,
        d.duplicate_match_id,
        m.ext_source AS duplicate_ext_source,
        m.ext_match_id AS duplicate_ext_match_id,
        m.kickoff,
        m.home_team_id,
        m.away_team_id,
        ht.name AS home_team,
        at.name AS away_team
    FROM duplicate_ids d
    JOIN public.matches m ON m.id = d.duplicate_match_id
    JOIN public.teams ht ON ht.id = m.home_team_id
    JOIN public.teams at ON at.id = m.away_team_id
),

queue_check AS (
    SELECT
        dd.*,
        (
            SELECT COUNT(*)
            FROM ops.fixture_player_stats_queue q
            WHERE q.match_id = dd.duplicate_match_id
               OR q.provider_fixture_id = dd.duplicate_ext_match_id
        ) AS fixture_player_stats_queue_rows
    FROM dup_detail dd
)

SELECT
    *,
    CASE
        WHEN fixture_player_stats_queue_rows = 0
            THEN 'SAFE_DELETE_READY'
        ELSE 'QUEUE_REFERENCE_REVIEW'
    END AS safe_delete_status
FROM queue_check;