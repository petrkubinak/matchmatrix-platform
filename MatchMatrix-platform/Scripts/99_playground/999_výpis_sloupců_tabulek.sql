SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
    'mm_ticket_scenarios',
    'mm_ticket_scenario_blocks',
    'mm_ticket_scenario_block_matches',
    'mm_ticket_scenario_variants'
  )
ORDER BY table_name, ordinal_position;