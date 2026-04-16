-- =====================================================================
-- 269_export_club_work_queue_only.sql
-- Pracovni fronta jen pro klubove pripady, ktere chceme resit ted
-- =====================================================================

WITH base AS (
    SELECT
        s.provider,
        s.external_team_id,
        s.team_name
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
      AND NOT EXISTS (
          SELECT 1
          FROM public.team_provider_map m
          WHERE m.provider = s.provider
            AND m.provider_team_id = s.external_team_id
      )
      AND NOT EXISTS (
          SELECT 1
          FROM public.teams t
          WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(s.team_name))
      )
),
bucketed AS (
    SELECT
        provider,
        external_team_id,
        team_name,
        CASE
            WHEN team_name ~ '\?' THEN 'ENCODING_OR_BROKEN_TEXT'
            WHEN team_name ~* '(^| )(U16|U17|U18|U19|U20|U21|U23|W U20|W U19|W)$' THEN 'YOUTH_OR_WOMEN_NATIONAL'
            WHEN team_name ~* '(^| )(II|III|Amateurs|B)$' THEN 'B_TEAMS_OR_AMATEURS'
            WHEN team_name ~* '^(Afghanistan|Albania|Algeria|Andorra|Angola|Argentina|Armenia|Aruba|Austria|Azerbaijan|Bahrain|Bangladesh|Belarus|Belize|Benin|Bermuda|Bhutan|Bolivia|Bonaire|Botswana|Brunei|Bulgaria|Burkina Faso|Burundi|Cambodia|Cameroon|Cayman Islands|Central African Republic|Chile|China|Chinese Taipei|Comoros|Congo|Costa Rica|Cuba|Cyprus|Czech Republic|Djibouti|Dominica|Dominican Republic|El Salvador|Equatorial Guinea|Estonia|Ethiopia|Faroe Islands|Fiji|Finland|French Guyana|Gabon|Gambia|Gibraltar|Greece|Grenada|Guatemala|Guinea|Guinea-Bissau|Guyana|Honduras|Hong Kong|Iceland|India|Indonesia|Israel|Jamaica|Kazakhstan|Kenya|Kosovo|Kuwait|Kyrgyzstan|Laos|Latvia|Lebanon|Lesotho|Libya|Liechtenstein|Luxembourg|Madagascar|Malawi|Malaysia|Maldives|Mali|Malta|Martinique|Mauritania|Mauritius|Moldova|Mongolia|Montenegro|Mozambique|Myanmar|Namibia|Nepal|New Caledonia|Nicaragua|Niger|Nigeria|Northern Ireland|North Korea|Oman|Palestine|Papua New Guinea|Peru|Philippines|Puerto Rico|Russia|Rwanda|San Marino|Sierra Leone|Singapore|Solomon Islands|Sri Lanka|Sudan|Suriname|Syria|Tajikistan|Tanzania|Thailand|Togo|Trinidad and Tobago|Turkmenistan|Uganda|United Arab Emirates|USA|Vanuatu|Venezuela|Vietnam|Wales|Yemen|Zambia|Zimbabwe)$'
                THEN 'NATIONAL_TEAMS'
            ELSE 'OTHER_CLUB_CASES'
        END AS bucket
    FROM base
)
SELECT
    bucket,
    provider,
    external_team_id,
    team_name
FROM bucketed
WHERE bucket IN ('ENCODING_OR_BROKEN_TEXT', 'OTHER_CLUB_CASES')
ORDER BY
    CASE WHEN bucket = 'ENCODING_OR_BROKEN_TEXT' THEN 1 ELSE 2 END,
    team_name;