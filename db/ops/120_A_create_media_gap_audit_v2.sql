/* ============================================================
MATCHMATRIX 120_A MEDIA GAP AUDIT V2

CO TO JE:
- Audit public.articles podle skutečné struktury databáze.
- Nehádá staré názvy sloupců.
- Používá content_source_id místo source_name.

K ČEMU TO JE:
- Zjistit kvalitu Media Layer.
- Ověřit URL, titulky, texty, summary, thumbnaily a video obsah.

KDE TO UVIDÍME:
- OPS Panel V18 → MEDIA
- Media Command Center
- Release readiness

JAK SE TO VYUŽIJE:
- Match Context Engine
- Team / Player / League pages
- AI summary
- Ticket Engine
============================================================ */

CREATE OR REPLACE VIEW ops.v_media_gap_audit_v1 AS
SELECT
    a.content_source_id,

    COUNT(*) AS articles_total,

    COUNT(*) FILTER (WHERE a.url IS NOT NULL) AS with_url,
    COUNT(*) FILTER (WHERE a.title IS NOT NULL) AS with_title,
    COUNT(*) FILTER (WHERE a.published_at IS NOT NULL) AS with_published_at,
    COUNT(*) FILTER (WHERE a.summary IS NOT NULL) AS with_summary,
    COUNT(*) FILTER (WHERE a.raw_text IS NOT NULL) AS with_raw_text,
    COUNT(*) FILTER (WHERE a.ai_summary IS NOT NULL) AS with_ai_summary,
    COUNT(*) FILTER (WHERE a.thumbnail_url IS NOT NULL) AS with_thumbnail,
    COUNT(*) FILTER (WHERE a.is_video = true) AS video_articles,
    COUNT(*) FILTER (WHERE a.is_feed_eligible = true) AS feed_eligible,
    COUNT(*) FILTER (WHERE a.is_breaking_news = true) AS breaking_news,

    ROUND(100.0 * COUNT(*) FILTER (WHERE a.url IS NOT NULL) / NULLIF(COUNT(*),0), 2) AS url_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE a.title IS NOT NULL) / NULLIF(COUNT(*),0), 2) AS title_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE a.published_at IS NOT NULL) / NULLIF(COUNT(*),0), 2) AS published_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE a.raw_text IS NOT NULL) / NULLIF(COUNT(*),0), 2) AS raw_text_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE a.thumbnail_url IS NOT NULL) / NULLIF(COUNT(*),0), 2) AS thumbnail_pct,
    ROUND(AVG(a.quality_score), 2) AS avg_quality_score,
    ROUND(AVG(a.ai_relevance_score), 2) AS avg_ai_relevance_score,

    CASE
        WHEN COUNT(*) = 0 THEN 'NO_DATA'
        WHEN COUNT(*) FILTER (WHERE a.url IS NOT NULL) = 0 THEN 'URL_GAP'
        WHEN COUNT(*) FILTER (WHERE a.title IS NOT NULL) = 0 THEN 'TITLE_GAP'
        WHEN COUNT(*) FILTER (WHERE a.raw_text IS NOT NULL) = 0 THEN 'TEXT_GAP'
        WHEN ROUND(AVG(COALESCE(a.quality_score, 0)), 2) < 50 THEN 'LOW_QUALITY'
        WHEN COUNT(*) FILTER (WHERE a.thumbnail_url IS NOT NULL) = 0 THEN 'THUMBNAIL_GAP'
        ELSE 'READY'
    END AS media_gap_status

FROM public.articles a
GROUP BY a.content_source_id;