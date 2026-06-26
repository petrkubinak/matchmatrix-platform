/*
===============================================================================
MATCHMATRIX SQL 116_B
PROJECT MILESTONES V1

CO TO JE:
- Centrální roadmapa projektu MatchMatrix.

K ČEMU TO JE:
- Eviduje hlavní milníky projektu.
- Umožňuje sledovat postup projektu.
- Bude zdrojem pro OPS panel a budoucí admin web.

KDE TO UVIDÍME:
- OPS panel
- Mission Control
- Admin web
- Projektové reporty

JAK SE TO VYUŽIJE:
- řízení projektu
- roadmapa
- release readiness
- reporting
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.project_milestones (

    milestone_id        BIGSERIAL PRIMARY KEY,

    milestone_code      TEXT NOT NULL UNIQUE,
    milestone_name      TEXT NOT NULL,

    category            TEXT NOT NULL,

    planned_date        DATE,
    completed_date      DATE,

    status              TEXT NOT NULL DEFAULT 'PLANNED',

    priority            INTEGER NOT NULL DEFAULT 100,

    progress_percent    NUMERIC(5,2) NOT NULL DEFAULT 0,

    description         TEXT,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_milestones_status
ON ops.project_milestones(status);

CREATE INDEX IF NOT EXISTS idx_project_milestones_category
ON ops.project_milestones(category);