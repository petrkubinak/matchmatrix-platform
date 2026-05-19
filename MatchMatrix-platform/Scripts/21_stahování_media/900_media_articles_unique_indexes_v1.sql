-- 900_media_articles_unique_indexes_v1.sql
-- MEDIA / ARTICLES deduplikace
-- Cíl: umožnit bezpečný opakovaný ingest bez duplicit.

CREATE UNIQUE INDEX IF NOT EXISTS ux_content_sources_name_type
ON public.content_sources (name, source_type);

CREATE UNIQUE INDEX IF NOT EXISTS ux_articles_source_url
ON public.articles (content_source_id, url);

CREATE UNIQUE INDEX IF NOT EXISTS ux_article_match_map_article_match
ON public.article_match_map (article_id, match_id);

CREATE UNIQUE INDEX IF NOT EXISTS ux_article_team_map_article_team
ON public.article_team_map (article_id, team_id);

CREATE UNIQUE INDEX IF NOT EXISTS ux_article_league_map_article_league
ON public.article_league_map (article_id, league_id);

CREATE UNIQUE INDEX IF NOT EXISTS ux_article_translations_article_language
ON public.article_translations (article_id, language_code);