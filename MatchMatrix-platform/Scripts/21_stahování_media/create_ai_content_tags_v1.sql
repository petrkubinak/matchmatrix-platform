-- create_ai_content_tags_v1.sql
--
-- CO TO JE:
-- AI CONTENT TAGGING ENGINE
--
-- CO TO DĚLÁ:
-- Umožňuje AI automaticky označovat články a videa
-- podle témat, významu a typu obsahu.
--
-- K ČEMU TO JE:
-- MatchMatrix nebude jen ukládat články.
-- Bude rozumět jejich významu.
--
-- KAM TO VEDE:
-- public.ai_content_tags
-- public.article_ai_tags
--
-- KDE TO UVIDÍME:
-- homepage
-- personalized feed
-- trending cards
-- AI summaries
-- player/team pages
--
-- JAK TO BUDE VYPADAT NA WEBU:
--
-- článek:
-- "PLAYOFF | TRENDING | VIDEO"
--
-- player page:
-- "Most discussed topics"
--
-- homepage:
-- "Breaking News"
-- "Transfer Rumors"
-- "Top Highlights"
--
-- NAVAZNOST:
-- articles
-- videos
-- AI summaries
-- discovery engine
-- recommendation engine

CREATE TABLE IF NOT EXISTS public.ai_content_tags (
    id bigserial PRIMARY KEY,

    tag_code text NOT NULL UNIQUE,
    tag_name text NOT NULL,
    tag_category text,

    description text,

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.article_ai_tags (
    article_id bigint NOT NULL,
    tag_id bigint NOT NULL,

    confidence_score numeric,

    tagged_by text DEFAULT 'ai_engine',

    created_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (article_id, tag_id),

    CONSTRAINT fk_article_ai_tags_article
        FOREIGN KEY (article_id)
        REFERENCES public.articles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_article_ai_tags_tag
        FOREIGN KEY (tag_id)
        REFERENCES public.ai_content_tags(id)
        ON DELETE CASCADE
);

INSERT INTO public.ai_content_tags (
    tag_code,
    tag_name,
    tag_category,
    description
)
VALUES

('PLAYOFF', 'Playoff', 'competition', 'Playoff or knockout stage content.'),
('TRANSFER', 'Transfer', 'transaction', 'Player transfer or signing news.'),
('RUMOR', 'Rumor', 'news', 'Unconfirmed report or speculation.'),
('HIGHLIGHT', 'Highlight', 'media', 'Highlights or key moments.'),
('INTERVIEW', 'Interview', 'media', 'Interview content.'),
('TRENDING', 'Trending', 'popularity', 'Currently popular topic.'),
('BREAKING', 'Breaking News', 'news', 'Urgent or major sports news.'),
('INJURY', 'Injury', 'health', 'Injury-related content.'),
('TACTICAL', 'Tactical Analysis', 'analysis', 'Tactical or expert analysis.'),
('GAME_RECAP', 'Game Recap', 'match', 'Post-game recap content.'),
('LIVE_UPDATE', 'Live Update', 'live', 'Live match updates.'),
('STAR_PLAYER', 'Star Player', 'player', 'Star player focused content.'),
('VIDEO_ARTICLE', 'Video Article', 'video', 'Article containing embedded video.'),
('REAL_VIDEO', 'Real Video', 'video', 'Standalone real video content.')

ON CONFLICT (tag_code)
DO NOTHING;


-- KONTROLA

SELECT
    tag_category,
    COUNT(*) AS tags
FROM public.ai_content_tags
GROUP BY tag_category
ORDER BY tag_category;