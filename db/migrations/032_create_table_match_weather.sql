-- =========================================================
-- Soubor: 032_create_table_match_weather.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: počasí a podmínky zápasu
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.match_weather (
    id                      BIGSERIAL PRIMARY KEY,

    match_id                BIGINT NOT NULL,
    temperature_c           NUMERIC(5,2) NULL,
    feels_like_c            NUMERIC(5,2) NULL,
    humidity_pct            NUMERIC(5,2) NULL,
    wind_speed_kph          NUMERIC(6,2) NULL,
    precipitation_mm        NUMERIC(6,2) NULL,
    weather_condition       TEXT NULL,   -- clear / rain / snow / cloudy / windy

    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_match_weather_match
        FOREIGN KEY (match_id)
        REFERENCES public.matches(id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_match_weather_match
    ON public.match_weather (match_id);

CREATE INDEX IF NOT EXISTS ix_match_weather_condition
    ON public.match_weather (weather_condition);

COMMIT;