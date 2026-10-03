-- CO: STEP 11G – kontrola registru Refresh Policy po vytvoření
-- K ČEMU: Ověřit počet sloupců, omezení, indexy a prázdný počáteční stav.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

WITH audit AS (
    SELECT
        (SELECT count(*)
         FROM pg_attribute
         WHERE attrelid = 'ops.harvest_scope_refresh_policy'::regclass
           AND attnum > 0 AND NOT attisdropped) AS columns_count,

        (SELECT count(*) FILTER (WHERE contype = 'p')
         FROM pg_constraint
         WHERE conrelid = 'ops.harvest_scope_refresh_policy'::regclass) AS primary_keys,

        (SELECT count(*) FILTER (WHERE contype = 'u')
         FROM pg_constraint
         WHERE conrelid = 'ops.harvest_scope_refresh_policy'::regclass) AS unique_constraints,

        (SELECT count(*) FILTER (WHERE contype = 'f')
         FROM pg_constraint
         WHERE conrelid = 'ops.harvest_scope_refresh_policy'::regclass) AS foreign_keys,

        (SELECT count(*) FILTER (WHERE contype = 'c')
         FROM pg_constraint
         WHERE conrelid = 'ops.harvest_scope_refresh_policy'::regclass) AS check_constraints,

        (SELECT count(*)
         FROM pg_constraint
         WHERE conrelid = 'ops.harvest_scope_refresh_policy'::regclass
           AND NOT convalidated) AS invalid_constraints,

        (SELECT count(*)
         FROM pg_index
         WHERE indrelid = 'ops.harvest_scope_refresh_policy'::regclass
           AND NOT indisvalid) AS invalid_indexes,

        (SELECT count(*)
         FROM ops.harvest_scope_refresh_policy) AS policy_rows
)
SELECT *,
       CASE
           WHEN columns_count = 24
            AND primary_keys = 1
            AND unique_constraints = 1
            AND foreign_keys = 6
            AND check_constraints = 8
            AND invalid_constraints = 0
            AND invalid_indexes = 0
            AND policy_rows = 0
           THEN 'PASS'
           ELSE 'REVIEW'
       END AS audit_result
FROM audit;