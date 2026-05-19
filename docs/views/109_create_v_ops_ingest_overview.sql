CREATE OR REPLACE VIEW ops.v_ingest_overview AS
SELECT
    iep.provider,
    iep.sport_code,
    s.name AS sport_name,
    iep.entity,
    iep.priority,
    iep.enabled,

    ser.default_run_group,
    ser.requires_season,
    ser.requires_league,
    ser.requires_team,
    ser.requires_player,
    ser.requires_match,

    psm.supports_leagues,
    psm.supports_teams,
    psm.supports_fixtures,
    psm.supports_players,
    psm.supports_player_stats,
    psm.supports_odds,
    psm.supports_coaches,

    sdr.entity_model,
    sdr.uses_teams,
    sdr.uses_players,
    sdr.uses_coaches,
    sdr.uses_rankings

FROM ops.ingest_entity_plan iep
LEFT JOIN public.sports s
    ON s.code = iep.sport_code
LEFT JOIN ops.sport_entity_rules ser
    ON ser.sport_code = iep.sport_code
   AND ser.entity = iep.entity
LEFT JOIN ops.provider_sport_matrix psm
    ON psm.provider = iep.provider
   AND psm.sport_code = iep.sport_code
LEFT JOIN ops.sport_dimension_rules sdr
    ON sdr.sport_code = iep.sport_code;