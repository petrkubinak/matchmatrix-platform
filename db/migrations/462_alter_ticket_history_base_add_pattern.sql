-- 462_alter_ticket_history_base_add_pattern.sql
-- Přidání pattern informace do historie tiketů

ALTER TABLE public.ticket_history_base
ADD COLUMN IF NOT EXISTS pattern_id bigint NULL,
ADD COLUMN IF NOT EXISTS pattern_code text NULL;