-- =========================================================
-- Soubor: 030_create_table_player_social_links.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: odkazy na sociální sítě hráčů
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.player_social_links (
    id              BIGSERIAL PRIMARY KEY,

    player_id        BIGINT NOT NULL,
    platform         TEXT NOT NULL,
    url              TEXT NOT NULL,

    is_official      BOOLEAN NOT NULL DEFAULT TRUE,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,

    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_player_social_links_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE,

    CONSTRAINT ck_player_social_links_platform
        CHECK (platform IN (
            'website',
            'twitter',
            'instagram',
            'facebook',
            'youtube',
            'tiktok',
            'threads',
            'linkedin'
        ))
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_social_links_player_platform
    ON public.player_social_links (player_id, platform);

CREATE INDEX IF NOT EXISTS ix_player_social_links_player
    ON public.player_social_links (player_id);

CREATE INDEX IF NOT EXISTS ix_player_social_links_is_active
    ON public.player_social_links (is_active);

COMMIT;