-- ============================================================================
-- 495_fix_team_alias_blacklist_youth.sql
-- Zakaz vyberu youth / women / nesmyslnych vetvi v resolve
-- ============================================================================

begin;

-- 1) označení špatných aliasů
update public.team_aliases
set is_active = false
where lower(alias) similar to '%(u17|u18|u19|u20|u21|women|w)%';

-- 2) ochrana proti krátkým aliasům (Cerro, Lens, atd.)
update public.team_aliases
set is_active = false
where length(alias) <= 4;

commit;