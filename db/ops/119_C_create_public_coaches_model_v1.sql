/* ============================================================
MATCHMATRIX 119_C CREATE PUBLIC COACHES MODEL V1

CO TO JE:
- Základní public model pro trenéry.
- Navazuje na People Layer.
- Řeší aktuální díru: FB coaches = PARTIAL / PUBLIC_MODEL_MISSING.

K ČEMU TO JE:
- Aby trenéři nebyli jen ve stagingu.
- Aby šli napojit na týmy, soutěže, zápasy, média a Match Context Engine.

KDE TO UVIDÍME:
- OPS Panel V18 → PEOPLE
- Web → profil týmu
- Web → profil trenéra
- Match Context → změna trenéra / nový trenér / vliv na formu

JAK SE TO VYUŽIJE:
- Predikce
- Ticket Engine
- Media Layer
- Match Intelligence
============================================================ */

BEGIN;

CREATE TABLE IF NOT EXISTS public.coaches (
    id BIGSERIAL PRIMARY KEY,

    sport_id INTEGER NULL REFERENCES public.sports(id),
    team_id INTEGER NULL REFERENCES public.teams(id),

    full_name TEXT NOT NULL,
    normalized_name TEXT NULL,

    birth_date DATE NULL,
    nationality TEXT NULL,
    country TEXT NULL,

    photo_url TEXT NULL,

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.coach_provider_map (
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    provider_coach_id TEXT NOT NULL,

    coach_id BIGINT NOT NULL REFERENCES public.coaches(id) ON DELETE CASCADE,

    provider_team_id TEXT NULL,
    provider_team_name TEXT NULL,
    provider_coach_name TEXT NULL,

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_coach_provider_map UNIQUE (provider, provider_coach_id)
);

CREATE INDEX IF NOT EXISTS idx_coaches_sport_id
    ON public.coaches(sport_id);

CREATE INDEX IF NOT EXISTS idx_coaches_team_id
    ON public.coaches(team_id);

CREATE INDEX IF NOT EXISTS idx_coaches_normalized_name
    ON public.coaches(normalized_name);

CREATE INDEX IF NOT EXISTS idx_coach_provider_map_provider
    ON public.coach_provider_map(provider);

CREATE INDEX IF NOT EXISTS idx_coach_provider_map_coach_id
    ON public.coach_provider_map(coach_id);

COMMIT;