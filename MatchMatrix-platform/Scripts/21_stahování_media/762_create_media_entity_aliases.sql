BEGIN;

CREATE TABLE IF NOT EXISTS public.media_entity_aliases (
    id BIGSERIAL PRIMARY KEY,

    entity_type TEXT NOT NULL,
    entity_id BIGINT NOT NULL,

    alias_text TEXT NOT NULL,

    source_scope TEXT,
    provider_scope TEXT,

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_media_entity_aliases_entity_type
    CHECK (
        entity_type IN (
            'team',
            'league',
            'player'
        )
    )
);

CREATE INDEX IF NOT EXISTS ix_media_entity_aliases_entity
ON public.media_entity_aliases(entity_type, entity_id);

CREATE INDEX IF NOT EXISTS ix_media_entity_aliases_alias
ON public.media_entity_aliases(alias_text);

COMMIT;