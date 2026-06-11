/* ============================================================
MATCHMATRIX 119_F COACHES DASHBOARD VIEW V1

CO TO JE:
- Dashboard view pro Coaches Layer.
- Agreguje data z public.coaches a public.team_coaches.
- Poskytuje rychlý přehled připravenosti trenérské vrstvy.

K ČEMU TO JE:
- Kontrola kvality Coaches Layer.
- Kontrola vazeb coach → team.
- Podklad pro OPS Panel V18.

KDE TO UVIDÍME:
OPS PANEL V18
→ PEOPLE
→ COACHES

OPS AUDIT

WEB (budoucí)
→ Profil trenéra
→ Profil týmu

JAK SE TO VYUŽIJE:
- People Layer Governance
- Match Context Engine
- Team Intelligence
- Ticket Engine
- Media Layer
============================================================ */

CREATE OR REPLACE VIEW ops.v_coaches_dashboard_v1 AS

SELECT
    c.id AS coach_id,
    c.name AS coach_name,

    s.code AS sport_code,
    s.name AS sport_name,

    c.ext_source,
    c.ext_coach_id,

    tc.team_id,
    t.name AS team_name,

    tc.role_code,
    tc.is_current,

    tc.confidence,

    CASE
        WHEN tc.team_id IS NOT NULL
             AND c.ext_source IS NOT NULL
             AND c.ext_coach_id IS NOT NULL
        THEN 'READY'

        WHEN tc.team_id IS NOT NULL
        THEN 'LINKED_NO_PROVIDER_ID'

        WHEN c.ext_source IS NOT NULL
        THEN 'PROVIDER_ONLY'

        ELSE 'REVIEW'
    END AS coach_status,

    c.created_at,
    c.updated_at

FROM public.coaches c

LEFT JOIN public.sports s
       ON s.id = c.sport_id

LEFT JOIN public.team_coaches tc
       ON tc.coach_id = c.id

LEFT JOIN public.teams t
       ON t.id = tc.team_id;