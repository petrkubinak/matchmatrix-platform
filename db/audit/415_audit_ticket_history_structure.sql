-- 415_audit_ticket_history_structure.sql
-- Audit struktury ticket history vrstvy před spuštěním AUTO ticket generatoru

SELECT
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'ticket_history_base',
      'ticket_settlements',
      'generated_runs',
      'generated_tickets',
      'generated_ticket_blocks',
      'ticket_generation_runs',
      'ticket_variant_features',
      'ticket_recommendation_feedback'
  )
ORDER BY table_name, ordinal_position;