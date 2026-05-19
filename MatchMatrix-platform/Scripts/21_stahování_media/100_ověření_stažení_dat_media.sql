SELECT
    provider,
    sport_code,
    source_name,
    health_status,
    http_status,
    found_urls,
    inserted_rows,
    skipped_rows,
    last_run_at,
    health_note
FROM ops.media_source_health_audit
ORDER BY last_run_at DESC;