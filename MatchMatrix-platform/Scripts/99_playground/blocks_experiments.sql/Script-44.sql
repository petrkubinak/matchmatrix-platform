SELECT id, template_id, created_at, run_probability
FROM generated_runs
WHERE id IN (4,5)
ORDER BY id;
