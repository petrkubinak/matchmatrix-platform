-- =====================================================================
-- 245_premerge_fk_and_alias_cleanup_batch_20_next.sql
-- Dalsi batch 20 z aktualniho MULTI_MATCH exportu
-- =====================================================================

-- =========================
-- MARTIGNY SPORTS keep = 26787
-- old = 28696
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28696
  AND newa.team_id = 26787
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26787 WHERE team_id = 28696;
UPDATE public.league_standings         SET team_id = 26787 WHERE team_id = 28696;
SELECT public.merge_team(28696, 26787, 'merge Martigny Sports dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- METZ keep = 1021
-- old = 27001
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27001
  AND newa.team_id = 1021
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1021 WHERE team_id = 27001;
UPDATE public.league_standings         SET team_id = 1021 WHERE team_id = 27001;
SELECT public.merge_team(27001, 1021, 'merge Metz dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ML VITEBSK keep = 13461
-- old = 26457
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26457
  AND newa.team_id = 13461
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13461 WHERE team_id = 26457;
UPDATE public.league_standings         SET team_id = 13461 WHERE team_id = 26457;
SELECT public.merge_team(26457, 13461, 'merge ML Vitebsk dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MONTANA keep = 12741
-- old = 25730
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25730
  AND newa.team_id = 12741
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12741 WHERE team_id = 25730;
UPDATE public.league_standings         SET team_id = 12741 WHERE team_id = 25730;
SELECT public.merge_team(25730, 12741, 'merge Montana dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MONTPELLIER keep = 1027
-- old = 12106
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12106
  AND newa.team_id = 1027
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 1027 WHERE team_id = 12106;
UPDATE public.league_standings         SET team_id = 1027 WHERE team_id = 12106;
SELECT public.merge_team(12106, 1027, 'merge Montpellier dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- MOTOR LUBLIN keep = 13024
-- old = 26476
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26476
  AND newa.team_id = 13024
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13024 WHERE team_id = 26476;
UPDATE public.league_standings         SET team_id = 13024 WHERE team_id = 26476;
SELECT public.merge_team(26476, 13024, 'merge Motor Lublin dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- NAC BREDA keep = 565
-- old = 12168
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 12168
  AND newa.team_id = 565
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 565 WHERE team_id = 12168;
UPDATE public.league_standings         SET team_id = 565 WHERE team_id = 12168;
SELECT public.merge_team(12168, 565, 'merge NAC Breda dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- NAFTA keep = 13400
-- old = 27216
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27216
  AND newa.team_id = 13400
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13400 WHERE team_id = 27216;
UPDATE public.league_standings         SET team_id = 13400 WHERE team_id = 27216;
SELECT public.merge_team(27216, 13400, 'merge Nafta dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- NAVALCARNERO keep = 16840
-- old = 26349
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26349
  AND newa.team_id = 16840
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16840 WHERE team_id = 26349;
UPDATE public.league_standings         SET team_id = 16840 WHERE team_id = 26349;
SELECT public.merge_team(26349, 16840, 'merge Navalcarnero dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- NEFTCHI BAKU keep = 12324
-- old = 25798
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 25798
  AND newa.team_id = 12324
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12324 WHERE team_id = 25798;
UPDATE public.league_standings         SET team_id = 12324 WHERE team_id = 25798;
SELECT public.merge_team(25798, 12324, 'merge Neftchi Baku dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- NORTHAMPTON keep = 13503
-- old = 26525
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26525
  AND newa.team_id = 13503
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13503 WHERE team_id = 26525;
UPDATE public.league_standings         SET team_id = 13503 WHERE team_id = 26525;
SELECT public.merge_team(26525, 13503, 'merge Northampton dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- NORWICH keep = 12197
-- old = 27679
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27679
  AND newa.team_id = 12197
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12197 WHERE team_id = 27679;
UPDATE public.league_standings         SET team_id = 12197 WHERE team_id = 27679;
SELECT public.merge_team(27679, 12197, 'merge Norwich dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ODRA OPOLE keep = 12459
-- old = 26301
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26301
  AND newa.team_id = 12459
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12459 WHERE team_id = 26301;
UPDATE public.league_standings         SET team_id = 12459 WHERE team_id = 26301;
SELECT public.merge_team(26301, 12459, 'merge Odra Opole dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- OFI keep = 13270
-- old = 27282
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27282
  AND newa.team_id = 13270
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 13270 WHERE team_id = 27282;
UPDATE public.league_standings         SET team_id = 13270 WHERE team_id = 27282;
SELECT public.merge_team(27282, 13270, 'merge OFI dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- OLIMPIJA LJUBLJANA keep = 12548
-- old = 26998
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 26998
  AND newa.team_id = 12548
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12548 WHERE team_id = 26998;
UPDATE public.league_standings         SET team_id = 12548 WHERE team_id = 26998;
SELECT public.merge_team(26998, 12548, 'merge Olimpija Ljubljana dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- OLOT keep = 26501
-- old = 28806
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28806
  AND newa.team_id = 26501
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 26501 WHERE team_id = 28806;
UPDATE public.league_standings         SET team_id = 26501 WHERE team_id = 28806;
SELECT public.merge_team(28806, 26501, 'merge Olot dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- OLYMPIAKOS PIRAEUS keep = 12670
-- old = 27833
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27833
  AND newa.team_id = 12670
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12670 WHERE team_id = 27833;
UPDATE public.league_standings         SET team_id = 12670 WHERE team_id = 27833;
SELECT public.merge_team(27833, 12670, 'merge Olympiakos Piraeus dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- ORIHUELA keep = 27757
-- old = 28807
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 28807
  AND newa.team_id = 27757
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 27757 WHERE team_id = 28807;
UPDATE public.league_standings         SET team_id = 27757 WHERE team_id = 28807;
SELECT public.merge_team(28807, 27757, 'merge Orihuela dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- OSTERSUNDS FK keep = 12357
-- old = 27189
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27189
  AND newa.team_id = 12357
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 12357 WHERE team_id = 27189;
UPDATE public.league_standings         SET team_id = 12357 WHERE team_id = 27189;
SELECT public.merge_team(27189, 12357, 'merge Ostersunds FK dup', 'FB_MULTI_MATCH', true, true);

-- =========================
-- OURENSE CF keep = 16824
-- old = 27754
-- =========================
DELETE FROM public.team_aliases olda
USING public.team_aliases newa
WHERE olda.team_id = 27754
  AND newa.team_id = 16824
  AND LOWER(BTRIM(olda.alias)) = LOWER(BTRIM(newa.alias));
UPDATE public.player_season_statistics SET team_id = 16824 WHERE team_id = 27754;
UPDATE public.league_standings         SET team_id = 16824 WHERE team_id = 27754;
SELECT public.merge_team(27754, 16824, 'merge Ourense CF dup', 'FB_MULTI_MATCH', true, true);