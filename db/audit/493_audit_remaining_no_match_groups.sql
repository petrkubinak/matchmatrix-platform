-- ============================================================================
-- 493_audit_remaining_no_match_groups.sql
-- Audit zbyvajicich NO_MATCH_ID pripadu po TheOdds canonical cleanup
--
-- ULOZENI:
--   C:\MatchMatrix-platform\db\audit\493_audit_remaining_no_match_groups.sql
--
-- SPUSTENI:
--   DBeaver -> matchmatrix -> spustit cely script
--
-- CO SCRIPT DELA:
--   1) najde tabulku unmatched_theodds_<run_id> (default 165)
--   2) normalizuje raw export do temp tabulky
--   3) zkusi rozpoznat home/away tym pres teams + team_aliases
--   4) zkusi najit stejne dvojice v public.matches
--   5) rozdeli pripady do skupin:
--        - unresolved_team_name
--        - exact_or_near_match_exists
--        - time_mismatch_same_pair_same_day
--        - reversed_pair_exists
--        - possible_league_or_branch_mismatch
--        - missing_fixture
--
-- POZNAMKA:
--   Script je zamerne odolny vuci ruznym nazvum sloupcu v exportu
--   unmatched_theodds_165. Pokud je tvoje importni tabulka pojmenovana jinak,
--   zmen jen hodnotu v sekci CONFIG.
-- ============================================================================

begin;

-- ----------------------------------------------------------------------------
-- CONFIG
-- ----------------------------------------------------------------------------

drop table if exists tmp_nm_cfg;
create temp table tmp_nm_cfg (
    run_id bigint not null,
    source_table text not null
);

insert into tmp_nm_cfg(run_id, source_table)
values
(
    165,
    'unmatched_theodds_165'
);

-- ----------------------------------------------------------------------------
-- 1) NACTENI ZDROJE
-- ----------------------------------------------------------------------------

drop table if exists tmp_no_match_src_raw;

do $$
declare
    v_run_id bigint;
    v_source text;
    v_regclass regclass;
    v_sql text;
begin
    select run_id, source_table
    into v_run_id, v_source
    from tmp_nm_cfg
    limit 1;

    v_regclass := coalesce(
        to_regclass(v_source),
        to_regclass('public.'  || v_source),
        to_regclass('staging.' || v_source),
        to_regclass('work.'    || v_source)
    );

    if v_regclass is null then
        raise exception 'Zdrojova tabulka % nebyla nalezena. Nejdriv naimportuj unmatched_theodds export nebo uprav CONFIG.', v_source;
    end if;

    v_sql := format($fmt$
        create temp table tmp_no_match_src_raw as
        select
            row_number() over () as src_row_id,
            x.j as raw_json
        from (
            select to_jsonb(t) as j
            from %s t
        ) x
    $fmt$, v_regclass);

    execute v_sql;
end $$;

-- ----------------------------------------------------------------------------
-- 2) NORMALIZACE SLOUPCU Z RAW EXPORTU
-- ----------------------------------------------------------------------------

drop table if exists tmp_no_match_src;
create temp table tmp_no_match_src as
select
    r.src_row_id,
    coalesce(nullif(r.raw_json ->> 'run_id', '')::bigint, cfg.run_id)                        as run_id,
    coalesce(
        nullif(r.raw_json ->> 'sport_key', ''),
        nullif(r.raw_json ->> 'league_key', ''),
        nullif(r.raw_json ->> 'theodds_key', ''),
        nullif(r.raw_json ->> 'provider_league_key', ''),
        nullif(r.raw_json ->> 'key', '')
    )                                                                                         as league_key,
    coalesce(
        nullif(r.raw_json ->> 'league_name', ''),
        nullif(r.raw_json ->> 'competition', ''),
        nullif(r.raw_json ->> 'sport_title', ''),
        nullif(r.raw_json ->> 'group_name', '')
    )                                                                                         as league_name_raw,
    coalesce(
        nullif(r.raw_json ->> 'home_team', ''),
        nullif(r.raw_json ->> 'home_name', ''),
        nullif(r.raw_json ->> 'home', ''),
        nullif(r.raw_json ->> 'team_home', '')
    )                                                                                         as home_name_raw,
    coalesce(
        nullif(r.raw_json ->> 'away_team', ''),
        nullif(r.raw_json ->> 'away_name', ''),
        nullif(r.raw_json ->> 'away', ''),
        nullif(r.raw_json ->> 'team_away', '')
    )                                                                                         as away_name_raw,
    coalesce(
        nullif(r.raw_json ->> 'commence_time', ''),
        nullif(r.raw_json ->> 'kickoff', ''),
        nullif(r.raw_json ->> 'start_time', ''),
        nullif(r.raw_json ->> 'match_time', ''),
        nullif(r.raw_json ->> 'event_time', '')
    )::timestamptz                                                                            as commence_time_utc,
    r.raw_json                                                                                as raw_json
from tmp_no_match_src_raw r
cross join tmp_nm_cfg cfg;

create index if not exists ix_tmp_no_match_src_row_id on tmp_no_match_src(src_row_id);

-- ----------------------------------------------------------------------------
-- 3) NORMALIZACE JMEN A RESOLVE TYMU
-- ----------------------------------------------------------------------------

drop table if exists tmp_no_match_resolved;
create temp table tmp_no_match_resolved as
with
src as (
    select
        s.*,
        lower(public.unaccent(trim(s.home_name_raw))) as home_norm,
        lower(public.unaccent(trim(s.away_name_raw))) as away_norm
    from tmp_no_match_src s
),
alias_pool as (
    select
        t.id as team_id,
        t.name as canonical_team_name,
        lower(public.unaccent(trim(t.name))) as norm_name,
        'team_name'::text as resolve_source
    from public.teams t

    union all

    select
        a.team_id,
        t.name as canonical_team_name,
        lower(public.unaccent(trim(a.alias))) as norm_name,
        'team_alias'::text as resolve_source
    from public.team_aliases a
    join public.teams t
      on t.id = a.team_id
),
home_best as (
    select distinct on (s.src_row_id)
        s.src_row_id,
        p.team_id,
        p.canonical_team_name,
        p.resolve_source,
        similarity(s.home_norm, p.norm_name) as sim
    from src s
    left join alias_pool p
      on p.norm_name = s.home_norm
      or similarity(s.home_norm, p.norm_name) >= 0.92
    order by s.src_row_id,
             case when p.norm_name = s.home_norm then 0 else 1 end,
             similarity(s.home_norm, p.norm_name) desc,
             p.team_id
),
away_best as (
    select distinct on (s.src_row_id)
        s.src_row_id,
        p.team_id,
        p.canonical_team_name,
        p.resolve_source,
        similarity(s.away_norm, p.norm_name) as sim
    from src s
    left join alias_pool p
      on p.norm_name = s.away_norm
      or similarity(s.away_norm, p.norm_name) >= 0.92
    order by s.src_row_id,
             case when p.norm_name = s.away_norm then 0 else 1 end,
             similarity(s.away_norm, p.norm_name) desc,
             p.team_id
)
select
    s.src_row_id,
    s.run_id,
    s.league_key,
    s.league_name_raw,
    s.home_name_raw,
    s.away_name_raw,
    s.commence_time_utc,
    s.raw_json,
    s.home_norm,
    s.away_norm,
    h.team_id as home_team_id,
    h.canonical_team_name as home_team_name,
    h.resolve_source as home_resolve_source,
    round(coalesce(h.sim, 0)::numeric, 4) as home_similarity,
    a.team_id as away_team_id,
    a.canonical_team_name as away_team_name,
    a.resolve_source as away_resolve_source,
    round(coalesce(a.sim, 0)::numeric, 4) as away_similarity
from src s
left join home_best h on h.src_row_id = s.src_row_id
left join away_best a on a.src_row_id = s.src_row_id;

create index if not exists ix_tmp_no_match_resolved_teams on tmp_no_match_resolved(home_team_id, away_team_id, commence_time_utc);

-- ----------------------------------------------------------------------------
-- 4) HLEDANI POTENCIALNICH MATCHU V DB
-- ----------------------------------------------------------------------------

drop table if exists tmp_no_match_audit;
create temp table tmp_no_match_audit as
with pair_scan as (
    select
        s.*,

        -- stejna dvojice, skoro stejny cas (+/- 10 min)
        (
            select m.id
            from public.matches m
            where m.home_team_id = s.home_team_id
              and m.away_team_id = s.away_team_id
              and s.commence_time_utc is not null
              and abs(extract(epoch from (m.kickoff - s.commence_time_utc))) <= 600
            order by abs(extract(epoch from (m.kickoff - s.commence_time_utc))), m.id
            limit 1
        ) as near_match_id,

        -- stejna dvojice, stejny den
        (
            select m.id
            from public.matches m
            where m.home_team_id = s.home_team_id
              and m.away_team_id = s.away_team_id
              and s.commence_time_utc is not null
              and (m.kickoff at time zone 'UTC')::date = (s.commence_time_utc at time zone 'UTC')::date
            order by abs(extract(epoch from (m.kickoff - s.commence_time_utc))), m.id
            limit 1
        ) as same_day_match_id,

        -- stejna dvojice, sirsi okno +/- 3 dny
        (
            select m.id
            from public.matches m
            where m.home_team_id = s.home_team_id
              and m.away_team_id = s.away_team_id
              and s.commence_time_utc is not null
              and m.kickoff between s.commence_time_utc - interval '3 day'
                               and s.commence_time_utc + interval '3 day'
            order by abs(extract(epoch from (m.kickoff - s.commence_time_utc))), m.id
            limit 1
        ) as wide_pair_match_id,

        -- stejna dvojice, ale velmi siroke okno +/- 14 dnu
        (
            select m.id
            from public.matches m
            where m.home_team_id = s.home_team_id
              and m.away_team_id = s.away_team_id
              and s.commence_time_utc is not null
              and m.kickoff between s.commence_time_utc - interval '14 day'
                               and s.commence_time_utc + interval '14 day'
            order by abs(extract(epoch from (m.kickoff - s.commence_time_utc))), m.id
            limit 1
        ) as broad_pair_match_id,

        -- reverzni dvojice v +/- 3 dnech
        (
            select m.id
            from public.matches m
            where m.home_team_id = s.away_team_id
              and m.away_team_id = s.home_team_id
              and s.commence_time_utc is not null
              and m.kickoff between s.commence_time_utc - interval '3 day'
                               and s.commence_time_utc + interval '3 day'
            order by abs(extract(epoch from (m.kickoff - s.commence_time_utc))), m.id
            limit 1
        ) as reversed_pair_match_id,

        -- jakakoli existence stejne dvojice bez ohledu na cas
        (
            select count(*)
            from public.matches m
            where m.home_team_id = s.home_team_id
              and m.away_team_id = s.away_team_id
        ) as same_pair_total,

        (
            select count(*)
            from public.matches m
            where m.home_team_id = s.away_team_id
              and m.away_team_id = s.home_team_id
        ) as reversed_pair_total
    from tmp_no_match_resolved s
),
classified as (
    select
        p.*,
        case
            when p.home_team_id is null or p.away_team_id is null then 'unresolved_team_name'
            when p.near_match_id is not null then 'exact_or_near_match_exists'
            when p.same_day_match_id is not null then 'time_mismatch_same_pair_same_day'
            when p.reversed_pair_match_id is not null then 'reversed_pair_exists'
            when p.wide_pair_match_id is not null then 'time_mismatch_same_pair_wide_window'
            when p.broad_pair_match_id is not null then 'possible_league_or_branch_mismatch'
            else 'missing_fixture'
        end as audit_group
    from pair_scan p
)
select
    c.*,
    m_near.league_id              as near_league_id,
    l_near.name                   as near_league_name,
    m_near.kickoff                as near_kickoff_utc,

    m_same.league_id              as same_day_league_id,
    l_same.name                   as same_day_league_name,
    m_same.kickoff                as same_day_kickoff_utc,

    m_rev.league_id               as reversed_league_id,
    l_rev.name                    as reversed_league_name,
    m_rev.kickoff                 as reversed_kickoff_utc,

    m_broad.league_id             as broad_league_id,
    l_broad.name                  as broad_league_name,
    m_broad.kickoff               as broad_kickoff_utc,

    case
        when c.commence_time_utc is not null and m_near.kickoff is not null
            then round((extract(epoch from (m_near.kickoff - c.commence_time_utc)) / 60.0)::numeric, 1)
        when c.commence_time_utc is not null and m_same.kickoff is not null
            then round((extract(epoch from (m_same.kickoff - c.commence_time_utc)) / 60.0)::numeric, 1)
        when c.commence_time_utc is not null and m_rev.kickoff is not null
            then round((extract(epoch from (m_rev.kickoff - c.commence_time_utc)) / 60.0)::numeric, 1)
        when c.commence_time_utc is not null and m_broad.kickoff is not null
            then round((extract(epoch from (m_broad.kickoff - c.commence_time_utc)) / 60.0)::numeric, 1)
        else null
    end as kickoff_diff_minutes
from classified c
left join public.matches m_near  on m_near.id  = c.near_match_id
left join public.leagues l_near  on l_near.id  = m_near.league_id
left join public.matches m_same  on m_same.id  = c.same_day_match_id
left join public.leagues l_same  on l_same.id  = m_same.league_id
left join public.matches m_rev   on m_rev.id   = c.reversed_pair_match_id
left join public.leagues l_rev   on l_rev.id   = m_rev.league_id
left join public.matches m_broad on m_broad.id = c.broad_pair_match_id
left join public.leagues l_broad on l_broad.id = m_broad.league_id;

create index if not exists ix_tmp_no_match_audit_group on tmp_no_match_audit(audit_group);

-- ----------------------------------------------------------------------------
-- 5) VYSTUP A - SOUHRN SKUPIN
-- ----------------------------------------------------------------------------
select
    audit_group,
    count(*) as rows_count
from tmp_no_match_audit
group by audit_group
order by rows_count desc, audit_group;

-- ----------------------------------------------------------------------------
-- 6) VYSTUP B - DETAIL PRO RUCNI KONTROLU
-- ----------------------------------------------------------------------------
select
    src_row_id,
    run_id,
    league_key,
    league_name_raw,
    commence_time_utc,
    home_name_raw,
    away_name_raw,
    home_team_id,
    home_team_name,
    away_team_id,
    away_team_name,
    audit_group,
    near_match_id,
    same_day_match_id,
    reversed_pair_match_id,
    broad_pair_match_id,
    near_league_name,
    same_day_league_name,
    reversed_league_name,
    broad_league_name,
    near_kickoff_utc,
    same_day_kickoff_utc,
    reversed_kickoff_utc,
    broad_kickoff_utc,
    kickoff_diff_minutes,
    same_pair_total,
    reversed_pair_total,
    home_resolve_source,
    away_resolve_source,
    home_similarity,
    away_similarity
from tmp_no_match_audit
order by
    case audit_group
        when 'missing_fixture' then 1
        when 'possible_league_or_branch_mismatch' then 2
        when 'time_mismatch_same_pair_wide_window' then 3
        when 'time_mismatch_same_pair_same_day' then 4
        when 'reversed_pair_exists' then 5
        when 'exact_or_near_match_exists' then 6
        when 'unresolved_team_name' then 7
        else 99
    end,
    league_key,
    commence_time_utc nulls last,
    home_name_raw,
    away_name_raw;

-- ----------------------------------------------------------------------------
-- 7) VYSTUP C - SKUPINY PODLE LEAGUE_KEY
-- ----------------------------------------------------------------------------
select
    coalesce(league_key, '(null)') as league_key,
    coalesce(league_name_raw, '(null)') as league_name_raw,
    audit_group,
    count(*) as rows_count
from tmp_no_match_audit
group by coalesce(league_key, '(null)'), coalesce(league_name_raw, '(null)'), audit_group
order by rows_count desc, league_key, audit_group;

commit;
