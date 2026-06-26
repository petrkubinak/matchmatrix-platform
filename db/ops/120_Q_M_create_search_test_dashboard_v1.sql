/*
===============================================================================
MATCHMATRIX SQL 120_Q_M
SEARCH TEST DASHBOARD V1
===============================================================================

CO TO JE:
- Dashboard pro testování Universal Context Resolveru.

K ČEMU TO JE:
- Kontrola kvality vyhledávání.
- Ladění scoringu.
- Audit relevance výsledků.

KDE TO UVIDÍME:
- OPS
- AI Search Development
- Universal Context Resolver

JAK SE TO VYUŽIJE:
- Rychlé ověření kvality výsledků.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_search_test_dashboard_v1 AS

SELECT
    search_term,
    entity_type,
    COUNT(*) AS results_found
FROM (

    SELECT
        'barcelona' AS search_term,
        entity_type
    FROM ops.fn_context_search_v2('barcelona',100)

    UNION ALL

    SELECT
        'real madrid',
        entity_type
    FROM ops.fn_context_search_v2('real madrid',100)

    UNION ALL

    SELECT
        'premier league',
        entity_type
    FROM ops.fn_context_search_v2('premier league',100)

    UNION ALL

    SELECT
        'nhl',
        entity_type
    FROM ops.fn_context_search_v2('nhl',100)

    UNION ALL

    SELECT
        'bundesliga',
        entity_type
    FROM ops.fn_context_search_v2('bundesliga',100)

) x

GROUP BY
    search_term,
    entity_type

ORDER BY
    search_term,
    results_found DESC;