-- 564_linker_rules_proposal.sql
-- Návrh pravidel pro další fázi THEODDS match attach/linker logiky

SELECT
    1 AS rule_order,
    'EXACT_PAIR_EXACT_KICKOFF' AS rule_code,
    'Pokud home_team_id + away_team_id sedi presne a kickoff sedi presne, vzdy attach na match_id.' AS rule_logic,
    'Resi Casa Pia vs Benfica, Cusco FC vs Flamengo-RJ, Rosario Central vs Independiente del Valle.' AS target_cases

UNION ALL
SELECT
    2,
    'EXACT_PAIR_TIME_TOLERANCE',
    'Pokud home_team_id + away_team_id sedi presne, ale kickoff nesedi, povolit attach v rozsirene toleranci a vybrat nejblizsi match.',
    'Resi Chapecoense vs Vitoria, Palmeiras vs Gremio.'

UNION ALL
SELECT
    3,
    'FALSE_PAIRING_BLACKLIST',
    'Pokud kandidat vypada jako false pairing (napr. Australia/Austria), neattachovat a oznacit jako ignore.',
    'Resi Australia vs Jordan ve World Cup.'

UNION ALL
SELECT
    4,
    'NO_ALIAS_MERGE_FOR_FALSE_PAIRING',
    'False pairing nikdy nesmi vytvorit alias ani merge tymu.',
    'Chrana canonical identity vrstvy.'

UNION ALL
SELECT
    5,
    'ATTACH_AUDIT_LOG',
    'Kazdy attach mimo exact kickoff zapisovat do auditu jako reason_code.',
    'Pro pozdejsi kontrolu linker quality.';