-- 733_repoint_rgb_runtime_rows_to_api_rugby.sql

update ops.runtime_entity_audit
set
    provider = 'api_rugby',
    state_reason = case
        when entity = 'teams' then 'RGB teams zatim neimplementovany, ale realny potvrzeny provider je api_rugby.'
        when entity = 'fixtures' then 'RGB fixtures zatim neimplementovany, ale realny potvrzeny provider je api_rugby.'
        else state_reason
    end,
    next_action = case
        when entity = 'teams' then 'Navrhnout RGB teams ingest (pull -> raw -> staging -> provider_map -> public)'
        when entity = 'fixtures' then 'Navrhnout RGB fixtures ingest (pull -> raw -> staging -> public.matches)'
        else next_action
    end,
    audit_note = case
        when entity = 'teams' then 'RGB teams skeleton presunut na realneho providera api_rugby.'
        when entity = 'fixtures' then 'RGB fixtures skeleton presunut na realneho providera api_rugby.'
        else audit_note
    end,
    updated_at = now()
where sport_code = 'RGB'
  and entity in ('teams', 'fixtures');