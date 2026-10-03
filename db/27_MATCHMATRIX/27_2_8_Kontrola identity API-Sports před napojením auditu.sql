/*
CO: Kontrola identity API-Sports před napojením auditu.
K ČEMU: Rozlišit kandidátní registr a hlavní identitu zdroje.
KDE: Databáze matchmatrix.
JAK: Pouze SELECT, bez změn dat.
*/

SELECT
    (
        SELECT COUNT(*)
        FROM ops.source_intelligence_map
        WHERE source_map_id = 31
          AND source_name = 'API-Sports'
          AND sport_code = 'HB'
    ) AS kandidat_31,

    (
        SELECT COUNT(*)
        FROM ops.source_master
    ) AS hlavni_identity_celkem,

    (
        SELECT COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'source_id', source_id,
                    'source_code', source_code,
                    'nazev', canonical_name,
                    'stav', lifecycle_status,
                    'domena', canonical_domain
                )
                ORDER BY source_id
            ),
            '[]'::jsonb
        )
        FROM ops.source_master
        WHERE lower(source_code)
                  IN ('api_sports', 'api-sports', 'apisports')
           OR lower(canonical_name)
                  IN ('api-sports', 'api sports', 'apisports')
           OR lower(COALESCE(canonical_domain, ''))
                  = 'api-sports.io'
    ) AS nalezene_identity_api_sports,

    (
        SELECT COUNT(*)
        FROM ops.source_alias
        WHERE valid_to IS NULL
          AND lower(normalized_alias)
              IN ('api-sports', 'api sports', 'apisports',
                  'api_sports', 'api-sports.io')
    ) AS odpovidajici_aliasy,

    (
        SELECT COUNT(*)
        FROM ops.runtime_adapter
        WHERE adapter_code = 'api_handball'
          AND runtime_status = 'REGISTERED'
    ) AS registrovany_adapter,

    (
        SELECT COUNT(*)
        FROM ops.source_adapter_binding b
        JOIN ops.runtime_adapter a
          ON a.adapter_id = b.adapter_id
        WHERE a.adapter_code = 'api_handball'
          AND b.is_active = true
    ) AS aktivni_vazby_adapteru;