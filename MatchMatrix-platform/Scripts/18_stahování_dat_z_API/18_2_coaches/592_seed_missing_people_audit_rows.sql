-- 592_seed_missing_people_audit_rows.sql
-- Účel:
-- doplnit do ops.provider_people_audit všechny chybějící provider/sport/entity
-- kombinace pro players a coaches podle ops.provider_entity_coverage
-- Spouštět v DBeaveru

insert into ops.provider_people_audit (
    provider,
    sport_code,
    entity,
    provider_role,
    source_category,
    endpoint_name,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    usable_for_league,
    usable_for_team,
    usable_for_season,
    technical_status,
    data_quality_status,
    final_verdict,
    requires_pro,
    alternative_provider_needed,
    evidence_note,
    next_step,
    priority_rank
)
select
    c.provider,
    c.sport_code,
    c.entity,

    case
        when c.is_primary_source then 'primary'
        when c.is_fallback_source then 'fallback'
        else 'candidate'
    end as provider_role,

    'api' as source_category,

    coalesce(nullif(c.source_endpoint, ''), c.entity) as endpoint_name,

    false as endpoint_exists,
    false as endpoint_tested,
    false as endpoint_returns_data,

    false as usable_for_league,
    false as usable_for_team,
    false as usable_for_season,

    c.coverage_status as technical_status,

    case
        when c.coverage_status = 'blocked' then 'empty'
        when c.coverage_status = 'planned' then 'unknown'
        when c.coverage_status = 'tech_ready' then 'unknown'
        else 'unknown'
    end as data_quality_status,

    case
        when c.coverage_status = 'blocked' then 'BLOCKED'
        when c.coverage_status in ('planned', 'tech_ready') then 'WAIT_PROVIDER'
        else 'WAIT_PROVIDER'
    end as final_verdict,

    coalesce(c.paid_plan_supported, false) and not coalesce(c.free_plan_supported, false) as requires_pro,

    true as alternative_provider_needed,

    concat(
        'Seednuto automaticky z ops.provider_entity_coverage. ',
        'coverage_status=',
        coalesce(c.coverage_status, 'null'),
        ', expected_depth=',
        coalesce(c.expected_depth, 'null'),
        ', availability_scope=',
        coalesce(c.availability_scope, 'null')
    ) as evidence_note,

    'Provést ruční people reality audit endpointu a kvality dat.' as next_step,

    case c.sport_code
        when 'FB' then 10
        when 'HK' then 20
        when 'BK' then 30
        when 'VB' then 40
        when 'HB' then 50
        else 90
    end as priority_rank
from ops.provider_entity_coverage c
left join ops.provider_people_audit p
    on p.provider = c.provider
   and p.sport_code = c.sport_code
   and p.entity = c.entity
where c.entity in ('players', 'coaches')
  and p.id is null;

-- kontrola: co bylo po seedu doplněno
select
    provider,
    sport_code,
    entity,
    endpoint_name,
    technical_status,
    data_quality_status,
    final_verdict,
    alternative_provider_needed,
    priority_rank
from ops.provider_people_audit
order by priority_rank, sport_code, provider, entity;