ZÁPIS PRO NOVÝ CHAT — MatchMatrix PEOPLE PIPELINE

Dnes jsme dokončili a napojili PEOPLE monitoring do DB/panelu.

Hotové DB view
ops.v_people_pipeline_audit_v1
ops.v_people_pipeline_summary_v1

Summary view už ukazuje všech 14 sportů z public.sports, včetně těch bez dat.

Stav PEOPLE vrstvy
FB   Football           5279 staging   2725 public   2726 map   51.62 %   PARTIAL
HK   Hockey             1950 staging   1950 public   1950 map   100 %     READY
BK   Basketball          862 staging    862 public    862 map   100 %     READY
TN   Tennis                0 staging      0 public      0 map     0 %     DATA_GAP
MMA  MMA                3675 staging   3675 public   3675 map   100 %     READY
DRT  Darts                 0 staging      0 public      0 map     0 %     DATA_GAP
VB   Volleyball            0 staging      0 public      0 map     0 %     DATA_GAP
HB   Handball              0 staging      0 public      0 map     0 %     DATA_GAP
BSB  Baseball           7109 staging   7109 public   7109 map   100 %     READY
RGB  Rugby                 0 staging      0 public      0 map     0 %     DATA_GAP
CK   Cricket             236 staging    236 public    236 map   100 %     READY
FH   Field Hockey          0 staging      0 public      0 map     0 %     DATA_GAP
AFB  American Football    86 staging     86 public     86 map   100 %     READY
ESP  Esports               0 staging      0 public      0 map     0 %     DATA_GAP
Hotové sporty PEOPLE READY
BK
HK
BSB
CK
AFB
MMA
Částečně hotové
FB

Fotbal má staging 5279, ale public jen 2725 a map 2726. Další logický krok je dočistit FB PEOPLE merge, aby byl READY.

DATA_GAP sporty
TN
DRT
VB
HB
RGB
FH
ESP

Pro tyto sporty zatím nejsou staging players. Bude potřeba připravit pull → parser → merge.

Důležité opravy dne

Sjednotili jsme sport kódy:

football → FB
basketball → BK
hockey → HK
baseball → BSB
cricket → CK
american_football → AFB
field_hockey → FH

Opravili jsme provider_maps, aby se nepočítaly jen podle providera, ale podle player_id → players.sport_id → sports.code.

Doplnili jsme sport_id do public.players pro sporty:

BK = 3
HK = 2
BSB = 12
AFB = 16
MMA = 9
Panel

Používaný panel:

C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_11_06.py

Spuštění:

C:\Python314\python.exe C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_11_06.py

Panel má záložku PEOPLE napojenou na:

ops.v_people_pipeline_summary_v1
ops.v_people_pipeline_audit_v1
Doporučené pokračování v novém chatu

Začít tímto:

Pokračujeme MatchMatrix PEOPLE pipeline.
Máme hotové BK/HK/BSB/CK/AFB/MMA READY.
FB je PARTIAL: 5279 staging, 2725 public, 2726 map, coverage 51.62 %.
Chci teď dočistit FB PEOPLE merge na READY.

První SQL pro nový chat:

SELECT
    provider,
    sport_code,
    season,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT external_player_id) AS distinct_players,
    COUNT(DISTINCT external_team_id) AS teams,
    MIN(raw_payload_id) AS min_payload_id,
    MAX(raw_payload_id) AS max_payload_id
FROM staging.stg_provider_players
WHERE sport_code IN ('FB', 'football')
GROUP BY provider, sport_code, season
ORDER BY provider, sport_code, season;