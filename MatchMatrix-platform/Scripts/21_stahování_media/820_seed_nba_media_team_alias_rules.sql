-- 820_seed_nba_media_team_alias_rules.sql
-- NBA MEDIA TEAM ALIAS RULES V1

INSERT INTO public.media_team_alias_rules (
    sport_code,
    provider,
    team_name,
    alias_slug
)
VALUES
('BK', 'nba_official_site', 'Boston Celtics', 'boston-celtics'),
('BK', 'nba_official_site', 'New York Knicks', 'new-york-knicks'),
('BK', 'nba_official_site', 'Indiana Pacers', 'indiana-pacers'),
('BK', 'nba_official_site', 'Oklahoma City Thunder', 'oklahoma-city-thunder'),
('BK', 'nba_official_site', 'Denver Nuggets', 'denver-nuggets'),
('BK', 'nba_official_site', 'Minnesota Timberwolves', 'minnesota-timberwolves'),
('BK', 'nba_official_site', 'Cleveland Cavaliers', 'cleveland-cavaliers'),
('BK', 'nba_official_site', 'Golden State Warriors', 'golden-state-warriors'),
('BK', 'nba_official_site', 'Los Angeles Lakers', 'los-angeles-lakers'),
('BK', 'nba_official_site', 'Dallas Mavericks', 'dallas-mavericks')
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
WHERE sport_code = 'BK'
  AND provider = 'nba_official_site'
ORDER BY team_name;