-- 432_preview_template_202.sql
-- Ověření, že AUTO SAFE_02 template 202 je runtime-validní

SELECT *
FROM public.mm_preview_run(202, 36);