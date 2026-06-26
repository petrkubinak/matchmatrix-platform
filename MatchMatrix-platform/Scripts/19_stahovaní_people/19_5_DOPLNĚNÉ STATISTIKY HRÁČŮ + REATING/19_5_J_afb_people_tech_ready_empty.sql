UPDATE ops.runtime_entity_audit
SET
    current_state='PARTIAL'
WHERE provider='api_american_football'
  AND sport_code='AFB'
  AND entity='players';