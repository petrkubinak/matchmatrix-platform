-- 814_create_media_team_alias_rules.sql
-- MEDIA TEAM ALIAS RULES V1

CREATE TABLE IF NOT EXISTS public.media_team_alias_rules (
    id BIGSERIAL PRIMARY KEY,
    sport_code TEXT NOT NULL,
    provider TEXT NOT NULL,
    team_name TEXT NOT NULL,
    alias_slug TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_media_team_alias_rules
ON public.media_team_alias_rules (sport_code, provider, alias_slug);

INSERT INTO public.media_team_alias_rules (
    sport_code,
    provider,
    team_name,
    alias_slug
)
VALUES
('HK', 'nhl_official_site', 'Montreal Canadiens', 'montreal-canadiens'),
('HK', 'nhl_official_site', 'Buffalo Sabres', 'buffalo-sabres'),
('HK', 'nhl_official_site', 'Vegas Golden Knights', 'vegas-golden-knights'),
('HK', 'nhl_official_site', 'Anaheim Ducks', 'anaheim-ducks'),
('HK', 'nhl_official_site', 'Tampa Bay Lightning', 'tampa-bay-lightning'),
('HK', 'nhl_official_site', 'Colorado Avalanche', 'avalanche'),
('HK', 'nhl_official_site', 'Minnesota Wild', 'wild'),
('HK', 'nhl_official_site', 'Florida Panthers', 'florida-panthers'),
('HK', 'nhl_official_site', 'Carolina Hurricanes', 'carolina-hurricanes'),
('HK', 'nhl_official_site', 'Philadelphia Flyers', 'flyers')
ON CONFLICT (sport_code, provider, alias_slug)
DO UPDATE SET
    team_name = EXCLUDED.team_name,
    is_active = true,
    updated_at = now();

-- kontrola
SELECT
    sport_code,
    provider,
    team_name,
    alias_slug,
    is_active
FROM public.media_team_alias_rules
ORDER BY team_name;