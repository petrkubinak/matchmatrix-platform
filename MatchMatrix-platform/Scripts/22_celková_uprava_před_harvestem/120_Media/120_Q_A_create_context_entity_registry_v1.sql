/*
===============================================================================
MATCHMATRIX SQL 120_Q_A
CONTEXT ENTITY REGISTRY V1
===============================================================================

CO TO JE:
- Centrální registr všech vyhledatelných entit MatchMatrix.

K ČEMU TO JE:
- Základ Universal Context Resolveru.
- Jednotné vyhledávání napříč systémem.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Team Pages
- Player Pages
- Match Pages
- Ticket Engine
- Mobile App

JAK SE TO VYUŽIJE:
- Uživatel zadá text.
- Resolver najde relevantní entity.
- Systém nabídne správné výsledky.

PŘÍKLAD:

"Barcelona"

→ TEAM
→ LEAGUE
→ PLAYER
→ ARTICLE

===============================================================================
*/

CREATE TABLE IF NOT EXISTS public.context_entity_registry (

    id BIGSERIAL PRIMARY KEY,

    entity_type TEXT NOT NULL,

    entity_id BIGINT NOT NULL,

    canonical_name TEXT NOT NULL,

    sport_id BIGINT,

    country TEXT,

    search_priority INTEGER DEFAULT 100,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_context_entity_type
ON public.context_entity_registry(entity_type);

CREATE INDEX IF NOT EXISTS idx_context_entity_name
ON public.context_entity_registry(lower(canonical_name));

CREATE INDEX IF NOT EXISTS idx_context_entity_active
ON public.context_entity_registry(is_active);