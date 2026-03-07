-- =========================================================
-- Soubor: 019_create_table_team_social_links.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: odkazy na oficiální weby a sociální sítě klubů
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.team_social_links (
    id              BIGSERIAL PRIMARY KEY,

    team_id         INTEGER NOT NULL,
    platform        TEXT NOT NULL,      -- website / twitter / instagram / facebook / youtube / tiktok
    url             TEXT NOT NULL,

    is_official     BOOLEAN NOT NULL DEFAULT TRUE,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_team_social_links_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE,

    CONSTRAINT ck_team_social_links_platform
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

-- jeden typ platformy pouze jednou na tým
CREATE UNIQUE INDEX IF NOT EXISTS ux_team_social_links_team_platform
    ON public.team_social_links (team_id, platform);

-- rychlé načítání sociálních sítí týmu
CREATE INDEX IF NOT EXISTS ix_team_social_links_team_id
    ON public.team_social_links (team_id);

-- filtrování aktivních odkazů
CREATE INDEX IF NOT EXISTS ix_team_social_links_is_active
    ON public.team_social_links (is_active);

COMMIT;