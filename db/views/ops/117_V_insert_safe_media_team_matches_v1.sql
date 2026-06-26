/*
MATCHMATRIX SQL 117_V
INSERT SAFE MEDIA TEAM MATCHES V1
*/

INSERT INTO public.article_team_map (
    article_id,
    team_id,
    created_at
)
SELECT
    article_id,
    team_id::integer,
    now()
FROM ops.v_media_team_match_quality_audit_v1
WHERE quality_status = 'SAFE'
ON CONFLICT DO NOTHING;