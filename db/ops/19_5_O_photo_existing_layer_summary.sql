/*
===============================================================================
MATCHMATRIX SQL 19_5_O
PHOTO EXISTING LAYER SUMMARY
===============================================================================

CO TO JE:
- Souhrn existující photo vrstvy.
- Nevytváří novou roadmapu, pouze čte už existující photo views.

K ČEMU TO JE:
- Ověříme, co už máme připravené:
  provider research, license review, paid/free kandidáty, PC2 readiness.

KDE TO UVIDÍME:
- Photo Provider Research
- PC2 Photo Harvest Readiness
- Photo License Review
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Rozhodneme, kterou photo větev spustit jako první:
  FREE/Wikimedia nebo PAID/SportsDataIO.
===============================================================================
*/

-- 1. Research summary
SELECT *
FROM ops.v_photo_provider_research_summary_v1;

-- 2. Full research detail
SELECT *
FROM ops.v_photo_provider_research_v1
ORDER BY priority_score DESC, sport_code, entity_type;

-- 3. License review summary
SELECT *
FROM ops.v_photo_license_review_summary_v2;

-- 4. Top license action plan
SELECT *
FROM ops.v_photo_license_review_top_v2
ORDER BY priority_score DESC, sport_code, entity_type;

-- 5. PC2 readiness
SELECT *
FROM ops.v_pc2_photo_harvest_readiness_summary_v1;

SELECT *
FROM ops.v_pc2_photo_harvest_readiness_v1
ORDER BY priority_score DESC, sport_code, entity_type;

-- 6. Ready for test
SELECT *
FROM ops.v_pc2_photo_ready_for_test_v1
ORDER BY priority_score DESC, sport_code, entity_type;

-- 7. Waiting for paid
SELECT *
FROM ops.v_pc2_photo_wait_for_paid_v1
ORDER BY priority_score DESC, sport_code, entity_type;