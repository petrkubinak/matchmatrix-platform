-- 817_create_media_alias_team_bridge.sql
-- MEDIA ALIAS -> CANONICAL TEAM BRIDGE

CREATE TABLE IF NOT EXISTS public.media_team_alias_bridge (
    id BIGSERIAL PRIMARY KEY,

    media_team_alias_rule_id BIGINT NOT NULL
        REFERENCES public.media_team_alias_rules(id),

    canonical_team_id INTEGER NOT NULL
        REFERENCES public.teams(id),

    confidence_score NUMERIC(5,2) NOT NULL DEFAULT 1.00,

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_media_team_alias_bridge
ON public.media_team_alias_bridge (
    media_team_alias_rule_id,
    canonical_team_id
);

-- kontrola
SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'media_team_alias_bridge';