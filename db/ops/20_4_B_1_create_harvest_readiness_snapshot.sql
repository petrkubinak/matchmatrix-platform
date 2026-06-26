/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_B_1_create_harvest_readiness_snapshot.sql

CO TO JE:
Snapshot tabulka pro rychlé čtení harvest připravenosti.

K ČEMU TO JE:
Panel a později web nebudou počítat těžké audity nad živými daty.
Budou číst hotový snapshot.

KDE TO UVIDÍME:
OPS Panel → Denní práce / Harvest Readiness.
Později Web Admin / interní monitoring.

JAK SE TO VYUŽIJE:
CORE → PEOPLE → MEDIA → ODDS bude řízeno rychle z této tabulky.
*/

CREATE TABLE IF NOT EXISTS ops.harvest_readiness_snapshot (
    id bigserial PRIMARY KEY,

    snapshot_at timestamptz NOT NULL DEFAULT now(),

    sport_code text NOT NULL,
    sport_name text,

    leagues_count integer NOT NULL DEFAULT 0,
    teams_count integer NOT NULL DEFAULT 0,
    matches_count integer NOT NULL DEFAULT 0,
    players_count integer NOT NULL DEFAULT 0,
    media_articles_count integer NOT NULL DEFAULT 0,

    core_status text NOT NULL DEFAULT 'UNKNOWN',
    people_status text NOT NULL DEFAULT 'UNKNOWN',
    media_status text NOT NULL DEFAULT 'UNKNOWN',
    odds_status text NOT NULL DEFAULT 'UNKNOWN',

    historical_core_status text NOT NULL DEFAULT 'UNKNOWN',
    current_core_status text NOT NULL DEFAULT 'UNKNOWN',
    current_people_status text NOT NULL DEFAULT 'UNKNOWN',
    current_media_status text NOT NULL DEFAULT 'UNKNOWN',
    current_odds_status text NOT NULL DEFAULT 'UNKNOWN',

    final_harvest_status text NOT NULL DEFAULT 'UNKNOWN',

    harvest_priority integer NOT NULL DEFAULT 999,
    next_layer_step text,
    operator_action_cz text,
    operator_note_cz text,

    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_harvest_readiness_snapshot_active
ON ops.harvest_readiness_snapshot (is_active, harvest_priority, sport_code);

CREATE INDEX IF NOT EXISTS idx_harvest_readiness_snapshot_sport
ON ops.harvest_readiness_snapshot (sport_code);

CREATE INDEX IF NOT EXISTS idx_harvest_readiness_snapshot_status
ON ops.harvest_readiness_snapshot (final_harvest_status, next_layer_step);