-- 439_preview_template_203.sql
-- Ověření, že AUTO SAFE_03 template 203 je runtime-validní

SELECT *
FROM public.mm_preview_run(203, 36);