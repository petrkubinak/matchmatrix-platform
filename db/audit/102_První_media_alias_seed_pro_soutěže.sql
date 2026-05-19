-- První media alias seed pro soutěže / obecné ligové fráze.
-- Zatím vkládáme jen aliasy bez entity_id = přesnou league vazbu doplníme až po kontrole konkrétních league_id.

INSERT INTO public.media_entity_aliases
(
    entity_type,
    entity_id,
    alias_text,
    source_scope,
    provider_scope
)
VALUES
    ('league', 0, 'NBA', 'NBA', 'nba_official_site'),
    ('league', 0, 'NBA Playoffs', 'NBA', 'nba_official_site'),
    ('league', 0, 'NHL', 'NHL', 'nhl_official_site'),
    ('league', 0, 'Stanley Cup', 'NHL', 'nhl_official_site'),
    ('league', 0, 'Stanley Cup Playoffs', 'NHL', 'nhl_official_site'),
    ('league', 0, 'UEFA Champions League', 'UEFA', 'uefa_official_site'),
    ('league', 0, 'Champions League', 'UEFA', 'uefa_official_site'),
    ('league', 0, 'UCL', 'UEFA', 'uefa_official_site')
ON CONFLICT DO NOTHING;