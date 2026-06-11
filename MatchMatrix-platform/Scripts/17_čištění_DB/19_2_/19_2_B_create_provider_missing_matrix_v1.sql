/*
MATCHMATRIX SQL 19_2_B Create Provider Missing Matrix V1

CO TO JE:
- Zakládá tabulku ops.provider_missing_matrix.
- Slouží jako hlavní matice chybějících providerů podle sportu a entity.

K ČEMU TO JE:
- Abychom přesně věděli, co pro každý sport chybí.
- Abychom věděli, který provider to může dodat.
- Abychom rozlišili FREE / LIMITED_FREE / PAID / WAIT_FOR_PAID.

KDE TO UVIDÍME:
- OPS Panel V18
- Provider Command Center
- People Command Center
- Harvest Readiness
- PC2 Harvest Preparation

JAK SE TO VYUŽIJE:
- Pro plánování PC2 harvestu.
- Pro výběr providerů.
- Pro prioritu datových mezer.
*/

CREATE TABLE IF NOT EXISTS ops.provider_missing_matrix (
    id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    sport_name TEXT,

    entity_type TEXT NOT NULL,
    layer_code TEXT NOT NULL,

    current_status TEXT NOT NULL DEFAULT 'MISSING',
    priority_score INTEGER NOT NULL DEFAULT 100,

    current_provider TEXT,
    recommended_provider TEXT,
    provider_type TEXT,

    access_type TEXT NOT NULL DEFAULT 'UNKNOWN',

    historical_supported BOOLEAN DEFAULT false,
    live_supported BOOLEAN DEFAULT false,
    api_available BOOLEAN DEFAULT false,
    automation_possible BOOLEAN DEFAULT false,

    estimated_coverage_pct NUMERIC(6,2),

    blocker_reason TEXT,
    next_action TEXT,
    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT provider_missing_matrix_status_chk CHECK (
        current_status IN (
            'READY',
            'PARTIAL',
            'MISSING',
            'RESEARCH_REQUIRED',
            'WAIT_FOR_PAID_PLAN',
            'BLOCKED'
        )
    ),

    CONSTRAINT provider_missing_matrix_access_chk CHECK (
        access_type IN (
            'FREE',
            'LIMITED_FREE',
            'PAID',
            'ENTERPRISE',
            'UNKNOWN'
        )
    ),

    CONSTRAINT provider_missing_matrix_unique_key UNIQUE (
        sport_code,
        entity_type
    )
);

CREATE INDEX IF NOT EXISTS idx_provider_missing_matrix_sport
ON ops.provider_missing_matrix (sport_code);

CREATE INDEX IF NOT EXISTS idx_provider_missing_matrix_entity
ON ops.provider_missing_matrix (entity_type);

CREATE INDEX IF NOT EXISTS idx_provider_missing_matrix_status
ON ops.provider_missing_matrix (current_status);

CREATE INDEX IF NOT EXISTS idx_provider_missing_matrix_priority
ON ops.provider_missing_matrix (priority_score);

INSERT INTO ops.provider_missing_matrix (
    sport_code,
    sport_name,
    entity_type,
    layer_code,
    current_status,
    priority_score,
    current_provider,
    recommended_provider,
    provider_type,
    access_type,
    historical_supported,
    live_supported,
    api_available,
    automation_possible,
    estimated_coverage_pct,
    blocker_reason,
    next_action,
    notes
)
VALUES
-- FOOTBALL
('FB','Football','PLAYER_PHOTOS','VISUAL_ASSETS','MISSING',100,NULL,'Wikimedia Commons / Wikipedia / API-Football PRO','PHOTO','FREE',true,true,true,true,NULL,NULL,'Research free + paid photo sources','Critical for player cards and web profiles'),
('FB','Football','TEAM_LOGOS','VISUAL_ASSETS','PARTIAL',95,'API-Football','API-Football / Wikimedia / Official Sites','LOGO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Audit logo coverage','Needed for team pages, match cards and standings'),
('FB','Football','COACH_PHOTOS','VISUAL_ASSETS','MISSING',90,NULL,'Wikipedia / Wikimedia / Official Sites','PHOTO','FREE',true,true,false,true,NULL,NULL,'Research coach photo sources','Needed for coach profiles'),
('FB','Football','STADIUM_PHOTOS','VISUAL_ASSETS','MISSING',80,NULL,'Wikipedia / Wikimedia / Official Stadium Sites','PHOTO','FREE',true,true,false,true,NULL,NULL,'Research stadium photo sources','Needed for venue pages'),

-- HOCKEY
('HK','Hockey','PLAYER_PHOTOS','VISUAL_ASSETS','MISSING',95,NULL,'SportsDataIO / NHL API / Wikimedia','PHOTO','PAID',true,true,true,true,NULL,'Provider not fully connected','Research hockey player photos','Important for NHL and hockey player cards'),
('HK','Hockey','TEAM_LOGOS','VISUAL_ASSETS','PARTIAL',85,'api_hockey','NHL API / Wikimedia / Official Sites','LOGO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Audit hockey logo coverage','Needed for hockey web pages'),
('HK','Hockey','COACH_PHOTOS','VISUAL_ASSETS','MISSING',75,NULL,'NHL API / Wikipedia / Wikimedia','PHOTO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Research coach photos','Lower priority than players'),
('HK','Hockey','STADIUM_PHOTOS','VISUAL_ASSETS','MISSING',70,NULL,'Wikipedia / Wikimedia / Arena sites','PHOTO','FREE',true,true,false,true,NULL,NULL,'Research arena photos','Needed for venue profiles'),

-- BASKETBALL
('BK','Basketball','PLAYER_PHOTOS','VISUAL_ASSETS','MISSING',95,NULL,'SportsDataIO / NBA API / Wikimedia','PHOTO','PAID',true,true,true,true,NULL,NULL,'Research basketball player photos','Important for NBA/BK player cards'),
('BK','Basketball','TEAM_LOGOS','VISUAL_ASSETS','PARTIAL',85,'api_sport','NBA API / Wikimedia / Official Sites','LOGO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Audit basketball logos','Needed for team pages'),
('BK','Basketball','COACH_PHOTOS','VISUAL_ASSETS','MISSING',75,NULL,'NBA API / Wikipedia / Wikimedia','PHOTO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Research coach photos','Coach layer later'),
('BK','Basketball','STADIUM_PHOTOS','VISUAL_ASSETS','MISSING',70,NULL,'Wikipedia / Wikimedia / Arena sites','PHOTO','FREE',true,true,false,true,NULL,NULL,'Research arena photos','Venue layer'),

-- AMERICAN FOOTBALL
('AFB','American Football','PLAYER_PHOTOS','VISUAL_ASSETS','MISSING',90,NULL,'SportsDataIO / NFL API / Wikimedia','PHOTO','PAID',true,true,true,true,NULL,NULL,'Research AFB player photos','Important for NFL player profiles'),
('AFB','American Football','TEAM_LOGOS','VISUAL_ASSETS','PARTIAL',80,'api_american_football','NFL API / Wikimedia / Official Sites','LOGO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Audit AFB logos','Team branding'),
('AFB','American Football','COACH_PHOTOS','VISUAL_ASSETS','MISSING',70,NULL,'NFL API / Wikipedia / Wikimedia','PHOTO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Research AFB coach photos','Coach layer'),
('AFB','American Football','STADIUM_PHOTOS','VISUAL_ASSETS','MISSING',65,NULL,'Wikipedia / Wikimedia / Stadium sites','PHOTO','FREE',true,true,false,true,NULL,NULL,'Research stadium photos','Venue layer'),

-- BASEBALL
('BSB','Baseball','PLAYER_PHOTOS','VISUAL_ASSETS','MISSING',90,NULL,'SportsDataIO / MLB API / Wikimedia','PHOTO','PAID',true,true,true,true,NULL,NULL,'Research baseball player photos','Important for MLB player profiles'),
('BSB','Baseball','TEAM_LOGOS','VISUAL_ASSETS','PARTIAL',80,'api_baseball','MLB API / Wikimedia / Official Sites','LOGO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Audit baseball logos','Team branding'),
('BSB','Baseball','COACH_PHOTOS','VISUAL_ASSETS','MISSING',65,NULL,'MLB API / Wikipedia / Wikimedia','PHOTO','LIMITED_FREE',true,true,true,true,NULL,NULL,'Research coach photos','Coach layer'),
('BSB','Baseball','STADIUM_PHOTOS','VISUAL_ASSETS','MISSING',65,NULL,'Wikipedia / Wikimedia / Stadium sites','PHOTO','FREE',true,true,false,true,NULL,NULL,'Research stadium photos','Venue layer'),

-- OTHER SPORTS BASELINE
('VB','Volleyball','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',80,NULL,'Official Sites / Wikimedia / League Sites','PHOTO','UNKNOWN',true,true,false,true,NULL,'Provider unknown','Research volleyball photos','Data gap'),
('HB','Handball','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',80,NULL,'Official Sites / Wikimedia / League Sites','PHOTO','UNKNOWN',true,true,false,true,NULL,'Provider unknown','Research handball photos','Data gap'),
('RGB','Rugby','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',75,NULL,'Official Sites / Wikimedia / League Sites','PHOTO','UNKNOWN',true,true,false,true,NULL,'Provider unknown','Research rugby photos','Data gap'),
('CK','Cricket','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',75,NULL,'Cricbuzz / ESPNcricinfo / Wikimedia','PHOTO','UNKNOWN',true,true,true,true,NULL,'Provider terms required','Research cricket photos','Need license check'),
('TN','Tennis','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',75,NULL,'ATP/WTA / Wikipedia / Wikimedia','PHOTO','UNKNOWN',true,true,true,true,NULL,'Provider terms required','Research tennis photos','Need player profiles'),
('FH','Field Hockey','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',65,NULL,'Official Sites / Wikimedia','PHOTO','UNKNOWN',true,true,false,true,NULL,'Provider unknown','Research field hockey photos','Lower priority'),
('DRT','Darts','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',65,NULL,'PDC / Wikipedia / Wikimedia','PHOTO','UNKNOWN',true,true,false,true,NULL,'Provider unknown','Research darts photos','Lower priority'),
('ESP','Esports','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',60,NULL,'Liquipedia / Official Teams / Wikimedia','PHOTO','UNKNOWN',true,true,true,true,NULL,'Provider terms required','Research esports photos','Need license check'),
('MMA','MMA','PLAYER_PHOTOS','VISUAL_ASSETS','RESEARCH_REQUIRED',70,NULL,'SportsDataIO / UFC / Wikipedia / Wikimedia','PHOTO','UNKNOWN',true,true,true,true,NULL,'Provider terms required','Research MMA photos','Need license check')
ON CONFLICT (sport_code, entity_type)
DO UPDATE SET
    sport_name = EXCLUDED.sport_name,
    layer_code = EXCLUDED.layer_code,
    current_status = EXCLUDED.current_status,
    priority_score = EXCLUDED.priority_score,
    current_provider = EXCLUDED.current_provider,
    recommended_provider = EXCLUDED.recommended_provider,
    provider_type = EXCLUDED.provider_type,
    access_type = EXCLUDED.access_type,
    historical_supported = EXCLUDED.historical_supported,
    live_supported = EXCLUDED.live_supported,
    api_available = EXCLUDED.api_available,
    automation_possible = EXCLUDED.automation_possible,
    estimated_coverage_pct = EXCLUDED.estimated_coverage_pct,
    blocker_reason = EXCLUDED.blocker_reason,
    next_action = EXCLUDED.next_action,
    notes = EXCLUDED.notes,
    updated_at = now();

CREATE OR REPLACE VIEW ops.v_provider_missing_matrix_v1 AS
SELECT
    sport_code,
    sport_name,
    layer_code,
    entity_type,
    current_status,
    priority_score,
    current_provider,
    recommended_provider,
    provider_type,
    access_type,
    historical_supported,
    live_supported,
    api_available,
    automation_possible,
    estimated_coverage_pct,
    blocker_reason,
    next_action,
    notes,
    updated_at
FROM ops.provider_missing_matrix
ORDER BY
    priority_score DESC,
    sport_code,
    entity_type;

CREATE OR REPLACE VIEW ops.v_provider_missing_matrix_summary_v1 AS
SELECT
    current_status,
    COUNT(*) AS rows_count,
    MIN(priority_score) AS min_priority,
    MAX(priority_score) AS max_priority
FROM ops.provider_missing_matrix
GROUP BY current_status
ORDER BY rows_count DESC;

SELECT
    current_status,
    COUNT(*) AS rows_count
FROM ops.provider_missing_matrix
GROUP BY current_status
ORDER BY rows_count DESC;