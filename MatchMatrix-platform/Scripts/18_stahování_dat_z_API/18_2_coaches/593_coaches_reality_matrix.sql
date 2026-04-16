-- 593_coaches_reality_matrix.sql
-- Účel:
-- vytvořit čistý rozhodovací přehled pro coaches napříč sporty/providery
-- Spouštět v DBeaveru

-- 1) Základní coaches audit
select
    provider,
    sport_code,
    entity,
    endpoint_name,
    technical_status,
    data_quality_status,
    final_verdict,
    alternative_provider_needed,
    requires_pro,
    priority_rank,
    evidence_note,
    next_step
from ops.provider_people_audit
where entity = 'coaches'
order by priority_rank, sport_code, provider;

------------------------------------------------------------

-- 2) Coaches jen pro hlavní sporty, které řešíme teď
select
    provider,
    sport_code,
    endpoint_name,
    technical_status,
    data_quality_status,
    final_verdict,
    alternative_provider_needed,
    requires_pro,
    next_step
from ops.provider_people_audit
where entity = 'coaches'
  and sport_code in ('FB', 'HK', 'BK', 'VB', 'HB')
order by
    case sport_code
        when 'FB' then 1
        when 'HK' then 2
        when 'BK' then 3
        when 'VB' then 4
        when 'HB' then 5
        else 99
    end,
    provider;

------------------------------------------------------------

-- 3) Co je kandidát na okamžitý reality check
select
    provider,
    sport_code,
    endpoint_name,
    technical_status,
    final_verdict,
    alternative_provider_needed,
    next_step
from ops.provider_people_audit
where entity = 'coaches'
  and final_verdict in ('WAIT_PROVIDER', 'PARTIAL_ONLY')
order by priority_rank, sport_code, provider;

------------------------------------------------------------

-- 4) Agregace po sportech
select
    sport_code,
    count(*) as coaches_rows,
    sum(case when final_verdict = 'USABLE' then 1 else 0 end) as usable_cnt,
    sum(case when final_verdict = 'PARTIAL_ONLY' then 1 else 0 end) as partial_cnt,
    sum(case when final_verdict = 'BLOCKED' then 1 else 0 end) as blocked_cnt,
    sum(case when final_verdict = 'WAIT_PROVIDER' then 1 else 0 end) as wait_provider_cnt
from ops.provider_people_audit
where entity = 'coaches'
group by sport_code
order by sport_code;