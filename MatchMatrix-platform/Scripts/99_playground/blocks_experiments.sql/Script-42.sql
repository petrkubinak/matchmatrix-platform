SELECT column_name
FROM information_schema.columns
WHERE table_name='generated_runs' AND column_name='run_probability';
