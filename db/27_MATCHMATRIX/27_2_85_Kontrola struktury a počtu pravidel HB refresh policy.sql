-- CO: Kontrola struktury a počtu pravidel HB refresh policy
-- K ČEMU: Připravit přesný, bezpečně podmíněný zápis 300 pravidel
-- KDE: DBeaver, databáze matchmatrix na PC2
-- JAK: Spustit celý dotaz; pouze čte, nic nemění

SELECT
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.is_nullable,
    s.rule_rows
FROM information_schema.columns AS c
CROSS JOIN (
    SELECT count(*) AS rule_rows
    FROM ops.harvest_scope_refresh_policy
) AS s
WHERE c.table_schema = 'ops'
  AND c.table_name = 'harvest_scope_refresh_policy'
ORDER BY c.ordinal_position;