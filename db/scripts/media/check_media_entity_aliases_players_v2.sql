-- check_media_entity_aliases_players_v2.sql
-- Audit SAFE PLAYER ALIASES V2 podle skutečné struktury tabulky.

SELECT
    entity_type,
    COUNT(*) AS alias_count
FROM public.media_entity_aliases
WHERE is_active = true
GROUP BY entity_type
ORDER BY entity_type;


SELECT
    mea.entity_id AS player_id,
    p.name AS player_name,
    mea.alias_text,
    mea.source_scope,
    mea.provider_scope,
    mea.is_active
FROM public.media_entity_aliases mea
LEFT JOIN public.players p
    ON p.id = mea.entity_id
WHERE mea.entity_type = 'player'
  AND mea.is_active = true
ORDER BY p.name, mea.alias_text;


SELECT
    mea.entity_id AS player_id,
    p.name AS player_name,
    mea.alias_text,
    COUNT(DISTINCT a.id) AS matched_articles
FROM public.media_entity_aliases mea
LEFT JOIN public.players p
    ON p.id = mea.entity_id
LEFT JOIN public.articles a
    ON position(lower(mea.alias_text) in lower(coalesce(a.title, ''))) > 0
WHERE mea.entity_type = 'player'
  AND mea.is_active = true
GROUP BY
    mea.entity_id,
    p.name,
    mea.alias_text
ORDER BY
    matched_articles DESC,
    p.name,
    mea.alias_text;