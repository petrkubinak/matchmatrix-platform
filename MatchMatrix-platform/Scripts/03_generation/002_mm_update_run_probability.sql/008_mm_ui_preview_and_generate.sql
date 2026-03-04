-- Preview (UI tlačítko „Spočítat“)
select * from public.mm_preview_run(1);

-- Generate (UI tlačítko „Generovat“)
select public.mm_generate_run(1) as run_id;
