/*
===============================================================================
MATCHMATRIX SQL 19_5_S
CREATE STG_PLAYER_PHOTO_CANDIDATES
===============================================================================

CO TO JE:
První staging tabulka pro PHOTO pipeline.

K ČEMU TO JE:
Worker photo_asset_discovery_worker_v1.py sem bude ukládat
nalezené kandidátní fotografie hráčů.

KDE TO UVIDÍME:
staging.stg_player_photo_candidates

JAK SE TO VYUŽIJE:
Wikidata
→ Wikimedia Commons
→ kandidátní fotografie
→ ruční/automatické schválení
→ public.players.photo_url

CÍL:
Zvýšit pokrytí player photos
FB: 27.63 % → 80 %+.
===============================================================================
*/

CREATE TABLE IF NOT EXISTS staging.stg_player_photo_candidates
(
    candidate_id              BIGSERIAL PRIMARY KEY,

    player_id                 BIGINT NOT NULL,
    player_name               TEXT,

    sport_code                TEXT,
    provider                  TEXT,

    source_system             TEXT,
    source_url                TEXT,

    wikidata_id               TEXT,
    wikipedia_url             TEXT,
    commons_file              TEXT,

    photo_url                 TEXT,

    license_name              TEXT,
    license_url               TEXT,

    confidence_score          NUMERIC(5,2),

    review_status             TEXT DEFAULT 'PENDING',

    approved_by               TEXT,
    approved_at               TIMESTAMPTZ,

    created_at                TIMESTAMPTZ DEFAULT NOW(),
    updated_at                TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stg_player_photo_candidates_player
ON staging.stg_player_photo_candidates(player_id);

CREATE INDEX IF NOT EXISTS idx_stg_player_photo_candidates_status
ON staging.stg_player_photo_candidates(review_status);

CREATE INDEX IF NOT EXISTS idx_stg_player_photo_candidates_sport
ON staging.stg_player_photo_candidates(sport_code);

COMMENT ON TABLE staging.stg_player_photo_candidates IS
'PHOTO discovery staging. Kandidátní fotografie hráčů z Wikimedia/Wikipedia/Wikidata.';