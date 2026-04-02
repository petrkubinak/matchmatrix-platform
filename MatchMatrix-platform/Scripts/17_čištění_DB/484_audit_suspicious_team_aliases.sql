-- 484_audit_suspicious_team_aliases.sql
-- Cíl:
-- najít podezřelé aliasy, které vedou na zjevně špatné canonical týmy

SELECT
    ta.team_id,
    t.name AS mapped_team_name,
    ta.alias,
    ta.source,
    t.ext_source,
    t.ext_team_id
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE lower(ta.alias) IN (
    'barcelona sc',
    'junior fc',
    'sporting cristal',
    'rosario central',
    'czech republic',
    'flamengo-rj',
    'palmeiras-sp',
    'corinthians-sp',
    'universidad católica (chi)',
    'independiente del valle',
    'nacional de montevideo',
    'libertad asuncion'
)
ORDER BY lower(ta.alias), t.name;