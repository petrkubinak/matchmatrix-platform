-- 559_today_cleanup_notes_2026-04-06.sql
-- Dnešní závěry - THEODDS cleanup

SELECT 'EPL' AS bucket,
       'HOTOVO' AS status,
       'Leeds 956->61, Brighton 11917->64, Newcastle 11904->56. Vsech 6 EPL case overeno jako OK.' AS notes

UNION ALL
SELECT 'FIFA World Cup',
       'UZAVRENO',
       'Australia vs Jordan (2026-06-16 a 2026-06-17) = SOURCE MISALIGNMENT / WRONG PAIRING. Ignorovat, nedelat merge Australia/Austria.'

UNION ALL
SELECT 'Bundesliga',
       'HOTOVO',
       '1. FC Heidenheim byl chybne aliasovan na 530 Borussia Monchengladbach. Alias fix presunut na 534 1. FC Heidenheim 1846.'

UNION ALL
SELECT 'Primeira Liga',
       'LINKER ISSUE',
       'Casa Pia vs Benfica existuje presne jako match_id 66365, kickoff sedi, aliasy sedi. Neni merge ani alias fix; je to attach/linking problem.'

UNION ALL
SELECT 'OPEN_BUCKETS',
       'ZBYVA',
       'Campeonato Brasileiro Serie A = 2, Copa Libertadores = 2, Primeira Liga linker = 1.';