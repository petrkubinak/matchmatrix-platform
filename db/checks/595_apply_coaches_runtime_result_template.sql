-- 595_apply_coaches_runtime_result_template.sql
-- FIXED VERSION (bez CTE)
-- Spouštět v DBeaveru

-- =========================================================
-- 1) PARAMETRY
-- =========================================================

drop table if exists tmp_params;

create temp table tmp_params as
select
    'api_football'::text as provider,
    'FB'::text as sport_code,
    'coachs'::text as endpoint_name,
    true::boolean as exists_result,
    true::boolean as returns_result,
    false::boolean as mapping_result,
    'PARTIAL_ONLY'::text as final_verdict,
    'runtime_tested'::text as technical_status,
    'partial'::text as quality_status,
    'Endpoint existuje a vrací data, ale mapování zatím není plně potvrzené.'::text as evidence_note,
    'Doplnit konkrétní mapování coach -> team/provider identity.'::text as next_step;

-- =========================================================
-- 2) CHECKLIST UPDATES
-- =========================================================

-- endpoint_exists
update ops.provider_coaches_runtime_checklist c
set
    check_status = case when p.exists_result then 'confirmed' else 'failed' end,
    test_note = p.evidence_note,
    next_step = p.next_step,
    updated_at = now()
from tmp_params p
where c.provider = p.provider
  and c.sport_code = p.sport_code
  and c.endpoint_name = p.endpoint_name
  and c.check_scope = 'endpoint_exists';

-- returns_data
update ops.provider_coaches_runtime_checklist c
set
    check_status = case when p.returns_result then 'confirmed' else 'failed' end,
    test_note = p.evidence_note,
    next_step = p.next_step,
    updated_at = now()
from tmp_params p
where c.provider = p.provider
  and c.sport_code = p.sport_code
  and c.endpoint_name = p.endpoint_name
  and c.check_scope = 'returns_data';

-- usable_mapping
update ops.provider_coaches_runtime_checklist c
set
    check_status = case when p.mapping_result then 'confirmed' else 'failed' end,
    test_note = p.evidence_note,
    next_step = p.next_step,
    updated_at = now()
from tmp_params p
where c.provider = p.provider
  and c.sport_code = p.sport_code
  and c.endpoint_name = p.endpoint_name
  and c.check_scope = 'usable_mapping';

-- =========================================================
-- 3) PEOPLE AUDIT UPDATE
-- =========================================================

update ops.provider_people_audit a
set
    endpoint_name = p.endpoint_name,
    endpoint_exists = p.exists_result,
    endpoint_tested = true,
    endpoint_returns_data = p.returns_result,
    usable_for_team = p.mapping_result,
    technical_status = p.technical_status,
    data_quality_status = p.quality_status,
    final_verdict = p.final_verdict,
    alternative_provider_needed =
        case
            when p.final_verdict in ('USABLE', 'PARTIAL_ONLY') then false
            else true
        end,
    evidence_note = p.evidence_note,
    next_step = p.next_step,
    updated_at = now()
from tmp_params p
where a.provider = p.provider
  and a.sport_code = p.sport_code
  and a.entity = 'coaches';

-- =========================================================
-- 4) CONTROL OUTPUT
-- =========================================================

select *
from ops.provider_coaches_runtime_checklist
where (provider, sport_code) in (('api_football','FB'), ('api_hockey','HK'))
order by priority_rank, provider, check_scope;

select
    provider,
    sport_code,
    entity,
    endpoint_name,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    usable_for_team,
    technical_status,
    data_quality_status,
    final_verdict,
    alternative_provider_needed,
    evidence_note,
    next_step
from ops.provider_people_audit
where entity = 'coaches'
  and (provider, sport_code) in (('api_football','FB'), ('api_hockey','HK'))
order by sport_code, provider;