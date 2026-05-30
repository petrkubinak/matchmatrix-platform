/*
MATCHMATRIX NON-UNIFIED SPORT FLOWS AUDIT V1

Co to je:
- Evidenční audit sportů, které ještě nejsou plně sjednocené na Python RAW -> parser flow.

K čemu to je:
- Rozhodneme, co převést ze SQL parserů do Pythonu jako první.

Kde se výsledek projeví:
- V DBeaveru jako kontrolní poznámka pro další práci.

Jak se využije na webu:
- Jednotná pipeline pro všechny sporty zjednoduší automatické aktualizace výsledků,
  standings, statistik, team power a AI modelů.
*/

SELECT *
FROM (
    VALUES
        ('BK',  'Basketball', 'PARTIAL', 'RAW existuje, parser/merge ještě SQL; nutné převést na Python'),
        ('BSB', 'Baseball',   'PARTIAL', 'část pipeline je SQL; nutné ověřit pull/parser/merge'),
        ('FB',  'Football',   'PYTHON_OK', 'hlavní pattern pro sjednocení'),
        ('HK',  'Hockey',     'CHECK', 'ověřit, zda parsery jsou plně Python'),
        ('HB',  'Handball',   'CHECK', 'ověřit, zda parsery jsou plně Python'),
        ('CK',  'Cricket',    'CHECK', 'ověřit, zda parsery jsou plně Python')
) AS x(sport_code, sport_name, status, note)
ORDER BY status, sport_code;