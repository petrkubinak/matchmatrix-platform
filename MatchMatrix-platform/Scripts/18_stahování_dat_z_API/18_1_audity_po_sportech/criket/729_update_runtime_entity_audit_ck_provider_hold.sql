-- 729_update_runtime_entity_audit_ck_provider_hold.sql

update ops.runtime_entity_audit
set
    current_state = 'PLANNED',
    state_reason = 'CK zatim nema realne overeny aktivni provider/execution chain. OPS target existuje, ale endpoint/provider neni potvrzen.',
    next_action = 'Pozdeji zvolit jineho cricket providera nebo CK docasne nechat mimo core build backlog.',
    audit_note = 'CK target v OPS existuje, ale execution chain nelze aktualne potvrdit. Provider je treba doresit pred buildem.',
    updated_at = now()
where sport_code = 'CK';
