/*
MATCHMATRIX SQL 120_P_A Team Alias Coverage Audit V1

CO TO JE:
- Audit aliasů týmů pro univerzální Match Context Resolver.

K ČEMU TO JE:
- Ověří, jestli máme dost aliasů pro automatické vyhledávání týmů v článcích.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Rozhodne, jestli univerzální resolver může používat existující aliasy,
  nebo musíme nejdříve doplnit alias coverage.
*/

CREATE OR REPLACE VIEW ops.v_team_alias_coverage_audit_v1 AS
WITH teams_base AS (
    SELECT
        t.id AS team_id,
        t.name AS team_name,
        t.sport_id
    FROM public.teams t
),
alias_counts AS (
    SELECT
        ta.team_id,
        COUNT(*) AS team_alias_count
    FROM public.team_aliases ta
    GROUP BY ta.team_id
),
media_alias_counts AS (
    SELECT
        mea.entity_id AS team_id,
        COUNT(*) AS media_alias_count
    FROM public.media_entity_aliases mea
    WHERE mea.entity_type = 'team'
      AND COALESCE(mea.is_active, true) = true
    GROUP BY mea.entity_id
),
preferred_lookup AS (
    SELECT
        canonical_team_id AS team_id,
        COUNT(*) AS preferred_name_count
    FROM public.v_preferred_team_name_lookup
    GROUP BY canonical_team_id
)
SELECT
    tb.team_id,
    tb.team_name,
    tb.sport_id,

    COALESCE(ac.team_alias_count, 0) AS team_alias_count,
    COALESCE(mac.media_alias_count, 0) AS media_alias_count,
    COALESCE(pl.preferred_name_count, 0) AS preferred_name_count,

    (
        COALESCE(ac.team_alias_count, 0)
      + COALESCE(mac.media_alias_count, 0)
      + COALESCE(pl.preferred_name_count, 0)
    ) AS total_alias_signals,

    CASE
        WHEN (
            COALESCE(ac.team_alias_count, 0)
          + COALESCE(mac.media_alias_count, 0)
          + COALESCE(pl.preferred_name_count, 0)
        ) >= 3
        THEN 'GOOD_ALIAS_COVERAGE'

        WHEN (
            COALESCE(ac.team_alias_count, 0)
          + COALESCE(mac.media_alias_count, 0)
          + COALESCE(pl.preferred_name_count, 0)
        ) >= 1
        THEN 'PARTIAL_ALIAS_COVERAGE'

        ELSE 'NO_ALIAS_COVERAGE'
    END AS alias_coverage_status,

    now() AS audited_at

FROM teams_base tb
LEFT JOIN alias_counts ac
    ON ac.team_id = tb.team_id
LEFT JOIN media_alias_counts mac
    ON mac.team_id = tb.team_id
LEFT JOIN preferred_lookup pl
    ON pl.team_id = tb.team_id;