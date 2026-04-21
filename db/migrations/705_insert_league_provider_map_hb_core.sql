-- 705_insert_league_provider_map_hb_core.sql
-- Cíl:
-- Zapsat HB canonical leagues do public.league_provider_map
-- pro api_handball core soutěže:
-- 131 Champions League
-- 145 EHF European League
-- 183 African Championship

WITH src AS (
    SELECT *
    FROM (
        VALUES
            (24881::bigint, 'api_handball', '131'),
            (24882::bigint, 'api_handball', '145'),
            (24883::bigint, 'api_handball', '183')
    ) AS t(league_id, provider, provider_league_id)
)
INSERT INTO public.league_provider_map (
    league_id,
    provider,
    provider_league_id,
    created_at,
    updated_at
)
SELECT
    s.league_id,
    s.provider,
    s.provider_league_id,
    NOW(),
    NOW()
FROM src s
WHERE NOT EXISTS (
    SELECT 1
    FROM public.league_provider_map lpm
    WHERE lpm.league_id = s.league_id
      AND lpm.provider = s.provider
      AND lpm.provider_league_id = s.provider_league_id
);

-- kontrola
SELECT
    lpm.league_id,
    l.name AS league_name,
    lpm.provider,
    lpm.provider_league_id,
    lpm.created_at,
    lpm.updated_at
FROM public.league_provider_map lpm
JOIN public.leagues l
  ON l.id = lpm.league_id
WHERE lpm.provider = 'api_handball'
  AND lpm.provider_league_id IN ('131','145','183')
ORDER BY lpm.provider_league_id;