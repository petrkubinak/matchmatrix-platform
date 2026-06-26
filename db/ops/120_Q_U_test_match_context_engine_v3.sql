/*
MATCHMATRIX SQL 120_Q_U Test Match Context Engine V3

CO TO JE:
- Test finální funkce ops.fn_match_context_engine_v3.

K ČEMU TO JE:
- Ověříme, že engine vrací kompletní kontext zápasu.

KDE TO UVIDÍME:
- Výsledek v DBeaveru.

JAK SE TO VYUŽIJE:
- Tento výstup později použije web Match Detail, AI Chat a Ticket Engine.
*/

SELECT *
FROM ops.fn_match_context_engine_v3(
    'Barcelona',
    'Real Madrid',
    1
);