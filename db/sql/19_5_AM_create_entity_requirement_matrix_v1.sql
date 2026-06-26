/*
===============================================================================
MATCHMATRIX 19_5_AM
ENTITY REQUIREMENT MATRIX V1
===============================================================================

KAM ULOŽIT:
C:\MatchMatrix-platform\sql\governance\

NÁZEV SOUBORU:
19_5_AM_create_entity_requirement_matrix_v1.sql

CO TO JE:
Master definice požadavků na entity.

K ČEMU TO JE:
Definuje minimální datový standard pro CORE, PEOPLE, MEDIA a ODDS.

KDE TO UVIDÍME:
OPS Dashboard
Harvest Readiness
Autonomous Brain
Provider Routing

JAK SE TO VYUŽIJE:
Určuje zda jsou data READY / PARTIAL / MISSING.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.entity_requirement_matrix (

    id BIGSERIAL PRIMARY KEY,

    sport_code TEXT,
    entity_type TEXT,

    required_field TEXT,

    is_required BOOLEAN DEFAULT TRUE,

    web_required BOOLEAN DEFAULT TRUE,
    prediction_required BOOLEAN DEFAULT FALSE,
    ticket_engine_required BOOLEAN DEFAULT FALSE,

    importance_score INTEGER DEFAULT 100,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_entity_requirement_matrix_01
ON ops.entity_requirement_matrix (
    sport_code,
    entity_type
);

TRUNCATE TABLE ops.entity_requirement_matrix;

-- ============================================================================
-- PLAYERS
-- ============================================================================

INSERT INTO ops.entity_requirement_matrix
(
sport_code,
entity_type,
required_field,
web_required,
prediction_required,
ticket_engine_required,
importance_score
)
VALUES

('ALL','PLAYERS','full_name',TRUE,TRUE,TRUE,100),
('ALL','PLAYERS','team_id',TRUE,TRUE,TRUE,100),
('ALL','PLAYERS','position',TRUE,TRUE,TRUE,95),
('ALL','PLAYERS','nationality',TRUE,FALSE,FALSE,70),
('ALL','PLAYERS','birth_date',TRUE,FALSE,FALSE,60),
('ALL','PLAYERS','provider_profile',TRUE,TRUE,TRUE,90),
('ALL','PLAYERS','photo_url',TRUE,FALSE,FALSE,50);

-- ============================================================================
-- COACHES
-- ============================================================================

INSERT INTO ops.entity_requirement_matrix
(
sport_code,
entity_type,
required_field,
web_required,
prediction_required,
ticket_engine_required,
importance_score
)
VALUES

('ALL','COACHES','full_name',TRUE,FALSE,FALSE,100),
('ALL','COACHES','team_id',TRUE,FALSE,FALSE,100),
('ALL','COACHES','role',TRUE,FALSE,FALSE,90),
('ALL','COACHES','provider_profile',TRUE,FALSE,FALSE,80);

-- ============================================================================
-- FIXTURES
-- ============================================================================

INSERT INTO ops.entity_requirement_matrix
(
sport_code,
entity_type,
required_field,
web_required,
prediction_required,
ticket_engine_required,
importance_score
)
VALUES

('ALL','FIXTURES','match_date',TRUE,TRUE,TRUE,100),
('ALL','FIXTURES','league_id',TRUE,TRUE,TRUE,100),
('ALL','FIXTURES','home_team_id',TRUE,TRUE,TRUE,100),
('ALL','FIXTURES','away_team_id',TRUE,TRUE,TRUE,100),
('ALL','FIXTURES','status',TRUE,TRUE,TRUE,100),
('ALL','FIXTURES','score',TRUE,TRUE,TRUE,90);

-- ============================================================================
-- ODDS
-- ============================================================================

INSERT INTO ops.entity_requirement_matrix
(
sport_code,
entity_type,
required_field,
web_required,
prediction_required,
ticket_engine_required,
importance_score
)
VALUES

('ALL','ODDS','match_id',TRUE,TRUE,TRUE,100),
('ALL','ODDS','bookmaker',TRUE,TRUE,TRUE,100),
('ALL','ODDS','market_type',TRUE,TRUE,TRUE,100),
('ALL','ODDS','odd_value',TRUE,TRUE,TRUE,100);

-- ============================================================================
-- MEDIA
-- ============================================================================

INSERT INTO ops.entity_requirement_matrix
(
sport_code,
entity_type,
required_field,
web_required,
prediction_required,
ticket_engine_required,
importance_score
)
VALUES

('ALL','MEDIA','title',TRUE,FALSE,FALSE,100),
('ALL','MEDIA','article_url',TRUE,FALSE,FALSE,100),
('ALL','MEDIA','published_at',TRUE,FALSE,FALSE,90),
('ALL','MEDIA','source_name',TRUE,FALSE,FALSE,90);

-- ============================================================================
-- PHOTOS
-- ============================================================================

INSERT INTO ops.entity_requirement_matrix
(
sport_code,
entity_type,
required_field,
web_required,
prediction_required,
ticket_engine_required,
importance_score
)
VALUES

('ALL','PHOTOS','asset_url',TRUE,FALSE,FALSE,100),
('ALL','PHOTOS','source_name',TRUE,FALSE,FALSE,90),
('ALL','PHOTOS','license_type',TRUE,FALSE,FALSE,90);

ANALYZE ops.entity_requirement_matrix;