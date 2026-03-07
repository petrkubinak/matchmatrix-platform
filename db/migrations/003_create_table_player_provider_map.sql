-- =========================================================
-- Soubor: 003_create_table_player_provider_map.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.player_provider_map
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.player_provider_map (
    id                  BIGSERIAL PRIMARY KEY,
    provider            TEXT NOT NULL,
    provider_player_id  TEXT NOT NULL,
    player_id           BIGINT NOT NULL,
    provider_team_id    TEXT NULL,
    provider_team_name  TEXT NULL,
    provider_player_name TEXT NULL,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_player_provider_map_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE
);

-- jeden provider + jeho player_id musí ukazovat jen na jednoho canonical hráče
CREATE UNIQUE INDEX IF NOT EXISTS ux_player_provider_map_provider_player
    ON public.player_provider_map (provider, provider_player_id);

-- pro rychlé joiny na canonical hráče
CREATE INDEX IF NOT EXISTS ix_player_provider_map_player_id
    ON public.player_provider_map (player_id);

-- pro filtrování aktivních mapování
CREATE INDEX IF NOT EXISTS ix_player_provider_map_is_active
    ON public.player_provider_map (is_active);

-- pro provider-based dotazy
CREATE INDEX IF NOT EXISTS ix_player_provider_map_provider
    ON public.player_provider_map (provider);

COMMIT;