-- 426_prepare_auto_safe_pipeline_notes.sql
-- Kontrolní dotazy před zabalením SAFE pipeline do Python workeru

-- 1) Poslední AUTO SAFE template
SELECT
    t.id,
    t.name,
    t.max_variable_blocks
FROM public.templates t
WHERE t.id = 201;

-- 2) FIX picks v template 201
SELECT
    tfp.template_id,
    tfp.match_id,
    tfp.market_id,
    tfp.market_outcome_id
FROM public.template_fixed_picks tfp
WHERE tfp.template_id = 201
ORDER BY tfp.match_id;

-- 3) Block matches v template 201
SELECT
    tbm.template_id,
    tbm.block_index,
    tbm.match_id,
    tbm.market_id
FROM public.template_block_matches tbm
WHERE tbm.template_id = 201
ORDER BY tbm.block_index, tbm.match_id;

-- 4) Poslední generated run pro template 201
SELECT
    gr.id,
    gr.template_id,
    gr.bookmaker_id,
    gr.created_at,
    gr.run_probability
FROM public.generated_runs gr
WHERE gr.template_id = 201
ORDER BY gr.id DESC
LIMIT 5;

-- 5) History záznamy pro run 105
SELECT
    thb.id,
    thb.run_id,
    thb.ticket_index,
    thb.source_system,
    thb.ticket_size,
    thb.total_odd,
    thb.probability,
    thb.created_at
FROM public.ticket_history_base thb
WHERE thb.run_id = 105
ORDER BY thb.ticket_index;