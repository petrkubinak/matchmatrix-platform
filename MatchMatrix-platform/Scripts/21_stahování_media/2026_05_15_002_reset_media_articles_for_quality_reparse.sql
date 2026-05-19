UPDATE staging.stg_media_articles
SET
    parse_status = 'pending',
    parse_message = 'reset for quality filter v1',
    updated_at = now()
WHERE parse_status = 'parsed'
  AND article_quality_score IS NULL;