-- approve_media_source_candidate_v1.sql
--
-- =========================================================
-- MATCHMATRIX MEDIA SOURCE APPROVAL V1
-- =========================================================
--
-- CO TO DĚLÁ:
-- Tento script schválí kandidátní media zdroj
-- pro budoucí ingest pipeline.
--
-- Zdroj změní stav:
--
-- pending
-- → approved
--
-- =========================================================
-- KAM TO VEDE:
-- ops.media_source_discovery_candidates
--
-- =========================================================
-- K ČEMU TO BUDE:
--
-- Jen schválené zdroje:
-- ✔ půjdou do ingest workerů
-- ✔ budou použity pro scraping/RSS
-- ✔ budou vstupovat do media layer
--
-- Pending/rejected zdroje:
-- ✖ nebudou použity
--
-- =========================================================
-- VYUŽITÍ NA WEBU/APLIKACI:
--
-- Schválené zdroje budou poskytovat:
--
-- ✔ články
-- ✔ videa
-- ✔ highlights
-- ✔ live updates
-- ✔ analýzy
-- ✔ klubové/federální zprávy
--
-- pro:
-- - homepage
-- - league pages
-- - team pages
-- - player pages
-- - mobilní aplikaci
--
-- =========================================================
-- JAK POUŽÍT:
--
-- Změň source_name ve WHERE části.
--
-- Příklad:
-- 'Sport.cz Fotbal'
--
-- =========================================================


UPDATE ops.media_source_discovery_candidates
SET
    review_status = 'approved',
    reviewed_by = 'manual_admin',
    reviewed_at = now(),
    review_note = 'Source approved for future ingest pipeline.',
    updated_at = now()
WHERE source_name = 'Sport.cz Fotbal';


-- =========================================================
-- KONTROLA
-- =========================================================

SELECT
    review_status,
    source_name,
    source_domain,
    sport_code,
    source_type,
    trust_level,
    next_action,
    reviewed_by,
    reviewed_at
FROM ops.media_source_discovery_candidates
WHERE source_name = 'Sport.cz Fotbal';