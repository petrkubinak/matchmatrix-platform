/*
MATCHMATRIX SQL 117_X
MEDIA TEAM MATCH SAFE RULES V1

CO TO JE:
- Bezpečnostní pravidla pro media team matcher.

K ČEMU TO JE:
- Oddělí názvy týmů, které můžeme automaticky vložit,
  od falešných nebo moc obecných shod.

KDE TO UVIDÍME:
- OPS Panel -> MEDIA
- Audit před zápisem do public.article_team_map

JAK SE TO VYUŽIJE:
- Další skript vloží do article_team_map jen SAFE_RULE_ALLOW.
*/

CREATE OR REPLACE VIEW ops.v_media_team_match_safe_rules_v1 AS
SELECT
    q.article_id,
    q.title,
    q.team_id,
    q.team_name,
    q.match_score,
    q.quality_status,

    CASE
        WHEN q.team_name IN (
            'Real Madrid',
            'FC Barcelona',
            'Bayer Leverkusen',
            'Borussia Dortmund',
            'Mallorca',
            'Real Betis',
            'Real Sociedad',
            'Red Bull Salzburg'
        )
        THEN 'SAFE_RULE_ALLOW'

        WHEN q.team_name IN (
            'Sporting',
            'England'
        )
        THEN 'SAFE_RULE_BLOCK'

        ELSE q.quality_status
    END AS final_match_status,

    CASE
        WHEN q.team_name IN (
            'Real Madrid',
            'FC Barcelona',
            'Bayer Leverkusen',
            'Borussia Dortmund',
            'Mallorca',
            'Real Betis',
            'Real Sociedad',
            'Red Bull Salzburg'
        )
        THEN 'Bezpečný whitelist tým pro automatický zápis.'

        WHEN q.team_name IN (
            'Sporting',
            'England'
        )
        THEN 'Blokováno: obecný nebo falešně pozitivní název.'

        ELSE q.recommendation_cz
    END AS recommendation_cz,

    now() AS generated_at

FROM ops.v_media_team_match_quality_audit_v1 q;