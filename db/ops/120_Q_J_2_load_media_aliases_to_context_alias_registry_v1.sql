/*
===============================================================================
MATCHMATRIX SQL 120_Q_J_2
MEDIA ALIAS LOADER TO CONTEXT ALIAS REGISTRY V1
===============================================================================

CO TO JE:
- Načtení media aliasů do Universal Context Resolveru.

K ČEMU TO JE:
- Aby AI/Web Search uměl využít aliasy vytvořené Media Layerem.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Media Search
- Team/Player Pages

JAK SE TO VYUŽIJE:
- Resolver bude umět najít entity i podle media aliasů.
===============================================================================
*/

INSERT INTO public.context_alias_registry
(
    entity_type,
    entity_id,
    alias_text,
    alias_priority
)
SELECT
    upper(mea.entity_type),
    mea.entity_id,
    mea.alias_text,
    90
FROM public.media_entity_aliases mea
WHERE mea.alias_text IS NOT NULL
  AND trim(mea.alias_text) <> ''
  AND COALESCE(mea.is_active, true) = true
  AND NOT EXISTS
(
    SELECT 1
    FROM public.context_alias_registry r
    WHERE r.entity_type = upper(mea.entity_type)
      AND r.entity_id = mea.entity_id
      AND lower(trim(r.alias_text)) = lower(trim(mea.alias_text))
);