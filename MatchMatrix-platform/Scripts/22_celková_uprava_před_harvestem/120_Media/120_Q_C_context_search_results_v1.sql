/*
===============================================================================
MATCHMATRIX SQL 120_Q_C
CONTEXT SEARCH RESULTS V1
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_context_search_results_v1 AS

SELECT
    entity_type,
    entity_id,
    canonical_name,
    search_priority
FROM public.context_entity_registry
WHERE is_active = TRUE;