/*
MATCHMATRIX SQL 108_D
AUTO REVIEW ENGINE V1

CO TO JE:
- Automatická klasifikace FIX tasků.

K ČEMU TO JE:
- Scheduler a panel poznají:
    - co lze opravit automaticky
    - co je bezpečné retry
    - co blokuje ingest
    - co je provider problém
    - co je parser problém

KDE TO UVIDÍME:
- FIX TASKS panel
- Scheduler Health
- AI OPS Engine

JAK SE TO VYUŽIJE:
- automatické retry
- automatické skipy
- prioritizace oprav
- AI orchestrace
*/

UPDATE ops.fix_tasks
SET

    issue_type = CASE

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%duplicate key%'
            THEN 'PARSER_DUPLICATE'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%timeout%'
            THEN 'TIMEOUT'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%401%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%403%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%auth%'
            THEN 'AUTH'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%json%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%parser%'
            THEN 'PARSER_ERROR'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%404%'
            THEN 'NOT_FOUND'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%500%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%502%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%503%'
            THEN 'PROVIDER_SERVER'

        ELSE 'MANUAL_REVIEW'

    END,

    auto_review_status = CASE

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%duplicate key%'
            THEN 'SAFE_RETRY'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%timeout%'
            THEN 'SAFE_RETRY'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%401%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%403%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%auth%'
            THEN 'BLOCKING'

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%500%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%502%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%503%'
            THEN 'PROVIDER_ISSUE'

        ELSE 'NEEDS_REVIEW'

    END,

    auto_fixable = CASE

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%duplicate key%'
            THEN true

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%timeout%'
            THEN true

        ELSE false

    END,

    safe_retry = CASE

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%duplicate key%'
            THEN true

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%timeout%'
            THEN true

        ELSE false

    END,

    blocks_scheduler = CASE

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%401%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%403%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%auth%'
            THEN true

        ELSE false

    END,

    review_confidence = CASE

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%duplicate key%'
            THEN 95

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%timeout%'
            THEN 90

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%401%'
          OR LOWER(COALESCE(full_message, '')) LIKE '%403%'
            THEN 98

        WHEN LOWER(COALESCE(full_message, '')) LIKE '%json%'
            THEN 75

        ELSE 50

    END,

    last_reviewed_at = NOW(),
    reviewed_by = 'auto_review_engine_v1';