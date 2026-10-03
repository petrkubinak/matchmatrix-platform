/*
===============================================================================
MATCHMATRIX – HB STEP 1B FINAL CHECK
OPRAVA DIAGNOSTIKY LAYER / ENTITY / TIME MODE
===============================================================================
*/


-- 1. SPORT × LAYER

SELECT
    sport_code,
    layer_type,
    COUNT(*) AS checklist_rows
FROM ops.data_acquisition_checklist_definition
GROUP BY
    sport_code,
    layer_type
ORDER BY
    sport_code,
    layer_type;


-- 2. SPORT × ENTITY × TIME MODE

SELECT
    sport_code,
    layer_type,
    entity,
    time_mode,
    COUNT(*) AS checklist_items
FROM ops.data_acquisition_checklist_definition
GROUP BY
    sport_code,
    layer_type,
    entity,
    time_mode
ORDER BY
    sport_code,
    layer_type,
    entity,
    time_mode;


-- 3. POČET JEDINEČNÝCH ENTITY/TIME SCOPES

SELECT
    sport_code,
    COUNT(
        DISTINCT (layer_type, entity, time_mode)
    ) AS entity_time_scopes
FROM ops.data_acquisition_checklist_definition
GROUP BY sport_code
ORDER BY sport_code;


-- 4. CELKOVÝ POČET ENTIT PODLE SPORTU

SELECT
    sport_code,
    COUNT(DISTINCT entity) AS distinct_entities
FROM ops.data_acquisition_checklist_definition
GROUP BY sport_code
ORDER BY sport_code;