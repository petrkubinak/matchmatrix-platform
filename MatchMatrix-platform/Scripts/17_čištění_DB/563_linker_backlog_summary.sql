-- 563_linker_backlog_summary.sql
-- Souhrnný backlog po dnešním cleanupu

SELECT 'FIFA World Cup' AS bucket,
       'Australia vs Jordan | 2026-06-16 04:00' AS case_name,
       'FALSE_PAIRING' AS classification,
       'Ignore. Do not merge Australia/Austria.' AS action

UNION ALL
SELECT 'FIFA World Cup',
       'Australia vs Jordan | 2026-06-17 04:00',
       'FALSE_PAIRING',
       'Ignore. Do not merge Australia/Austria.'

UNION ALL
SELECT 'Campeonato Brasileiro Série A',
       'Chapecoense vs Vitoria',
       'TIME_SHIFT_ATTACH',
       'Pair exists as match_id 61914, kickoff diff 26.50 h. Linker tolerance/attach logic.'

UNION ALL
SELECT 'Campeonato Brasileiro Série A',
       'Palmeiras vs Gremio',
       'TIME_SHIFT_ATTACH',
       'Pair exists as match_id 61910, kickoff diff 93.00 h. Linker tolerance/attach logic.'

UNION ALL
SELECT 'Primeira Liga',
       'Casa Pia vs Benfica',
       'EXACT_PAIR_NOT_LINKED',
       'Pair exists as match_id 66365, exact kickoff match. Pure attach/link issue.'

UNION ALL
SELECT 'Copa Libertadores',
       'Cusco FC vs Flamengo-RJ',
       'EXACT_PAIR_NOT_LINKED',
       'Pair exists as match_id 236718, exact kickoff match. Pure attach/link issue.'

UNION ALL
SELECT 'Copa Libertadores',
       'Rosario Central vs Independiente del Valle',
       'EXACT_PAIR_NOT_LINKED',
       'Pair exists as match_id 236722, exact kickoff match. Pure attach/link issue.';