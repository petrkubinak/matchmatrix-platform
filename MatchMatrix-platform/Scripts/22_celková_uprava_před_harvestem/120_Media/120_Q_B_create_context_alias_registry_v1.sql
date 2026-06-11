/*
===============================================================================
MATCHMATRIX SQL 120_Q_B
CONTEXT ALIAS REGISTRY V1
===============================================================================

CO TO JE:
- Aliasy pro všechny entity.

K ČEMU TO JE:
- Vyhledávání podle přezdívek,
  zkratek,
  historických názvů.

PŘÍKLAD:

Barcelona
Barca
FCB

→ stejné výsledky
===============================================================================
*/

CREATE TABLE IF NOT EXISTS public.context_alias_registry (

    id BIGSERIAL PRIMARY KEY,

    entity_type TEXT NOT NULL,

    entity_id BIGINT NOT NULL,

    alias_text TEXT NOT NULL,

    alias_priority INTEGER DEFAULT 100,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_context_alias_text
ON public.context_alias_registry(lower(alias_text));