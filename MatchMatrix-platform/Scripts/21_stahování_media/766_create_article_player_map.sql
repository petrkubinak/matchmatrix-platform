BEGIN;

CREATE TABLE IF NOT EXISTS public.article_player_map (
    article_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT article_player_map_pkey
    PRIMARY KEY (article_id, player_id),

    CONSTRAINT article_player_map_article_id_fkey
    FOREIGN KEY (article_id)
    REFERENCES public.articles(id)
    ON DELETE CASCADE,

    CONSTRAINT article_player_map_player_id_fkey
    FOREIGN KEY (player_id)
    REFERENCES public.players(id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_article_player_map_player_id
ON public.article_player_map(player_id);

COMMIT;