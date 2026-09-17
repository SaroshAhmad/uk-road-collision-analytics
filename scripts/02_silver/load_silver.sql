/*
=====================================================================
Script      : load_silver.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Loads silver.collision from bronze.dft_collision,
              decoding codes to labels and converting data types.
Method      : Full rebuild (truncate and reload).
=====================================================================
*/

USE RoadSafetyDW;
GO

TRUNCATE TABLE silver.collision;

INSERT INTO silver.collision (
    collision_index, collision_year, collision_date, collision_time, day_of_week,
    collision_severity_code, collision_severity, number_of_vehicles, number_of_casualties,
    longitude, latitude, police_force, local_authority_district, local_authority_ons_code,
    local_authority_highway, lsoa_of_collision, urban_or_rural_area,
    first_road_class, first_road_number, second_road_class, second_road_number,
    road_type, speed_limit, junction_detail, junction_control, pedestrian_crossing,
    light_conditions, weather_conditions, road_surface_conditions,
    special_conditions_at_site, carriageway_hazards, police_attended, trunk_road_flag
)
SELECT
    c.collision_index,
    CAST(c.collision_year AS SMALLINT),
    TRY_CONVERT(DATE, c.date, 103),          -- 103 = dd/mm/yyyy (UK)
    TRY_CONVERT(TIME(0), c.time),            -- invalid or blank becomes NULL
    ISNULL(dow.label, 'Unknown'),

    CAST(c.collision_severity AS TINYINT),
    sev.label,
    TRY_CAST(c.number_of_vehicles   AS SMALLINT),
    TRY_CAST(c.number_of_casualties AS SMALLINT),

    TRY_CAST(NULLIF(c.longitude, '') AS DECIMAL(9,6)),
    TRY_CAST(NULLIF(c.latitude,  '') AS DECIMAL(9,6)),
    ISNULL(pf.label,  'Not recorded'),
    ISNULL(lad.label, 'Not recorded'),
    NULLIF(c.local_authority_ons_district, '-1'),
    ISNULL(lah.label, 'Not recorded'),
    NULLIF(c.lsoa_of_accident_location, '-1'),
    ISNULL(ur.label,  'Not recorded'),

    ISNULL(frc.label, 'Not recorded'),
    TRY_CAST(NULLIF(c.first_road_number,  '-1') AS INT),
    ISNULL(src.label, 'Not recorded'),
    TRY_CAST(NULLIF(c.second_road_number, '-1') AS INT),
    ISNULL(rt.label,  'Not recorded'),
    TRY_CAST(NULLIF(c.speed_limit, '-1') AS SMALLINT),   -- -1 becomes NULL
    ISNULL(jd.label,  'Not recorded'),
    ISNULL(jc.label,  'Not recorded'),
    ISNULL(pc.label,  'Not recorded'),

    ISNULL(lc.label,  'Not recorded'),
    ISNULL(wc.label,  'Not recorded'),
    ISNULL(rsc.label, 'Not recorded'),
    ISNULL(sc.label,  'Not recorded'),
    ISNULL(ch.label,  'Not recorded'),
    ISNULL(pa.label,  'Not recorded'),
    ISNULL(tr.label,  'Not recorded')
FROM bronze.dft_collision AS c

LEFT JOIN bronze.dft_code_list AS dow ON dow.table_name='collision' AND dow.field_name='day_of_week'               AND dow.code=NULLIF(c.day_of_week,'-1')
LEFT JOIN bronze.dft_code_list AS sev ON sev.table_name='collision' AND sev.field_name='collision_severity'        AND sev.code=NULLIF(c.collision_severity,'-1')
LEFT JOIN bronze.dft_code_list AS pf  ON pf.table_name ='collision' AND pf.field_name ='police_force'              AND pf.code =NULLIF(c.police_force,'-1')
LEFT JOIN bronze.dft_code_list AS lad ON lad.table_name='collision' AND lad.field_name='local_authority_district'  AND lad.code=NULLIF(c.local_authority_district,'-1')
LEFT JOIN bronze.dft_code_list AS lah ON lah.table_name='collision' AND lah.field_name='local_authority_highway'   AND lah.code=NULLIF(c.local_authority_highway,'-1')
LEFT JOIN bronze.dft_code_list AS ur  ON ur.table_name ='collision' AND ur.field_name ='urban_or_rural_area'       AND ur.code =NULLIF(c.urban_or_rural_area,'-1')
LEFT JOIN bronze.dft_code_list AS frc ON frc.table_name='collision' AND frc.field_name='first_road_class'          AND frc.code=NULLIF(c.first_road_class,'-1')
LEFT JOIN bronze.dft_code_list AS src ON src.table_name='collision' AND src.field_name='second_road_class'         AND src.code=NULLIF(c.second_road_class,'-1')
LEFT JOIN bronze.dft_code_list AS rt  ON rt.table_name ='collision' AND rt.field_name ='road_type'                 AND rt.code =NULLIF(c.road_type,'-1')
LEFT JOIN bronze.dft_code_list AS jd  ON jd.table_name ='collision' AND jd.field_name ='junction_detail'           AND jd.code =NULLIF(c.junction_detail,'-1')
LEFT JOIN bronze.dft_code_list AS jc  ON jc.table_name ='collision' AND jc.field_name ='junction_control'          AND jc.code =NULLIF(c.junction_control,'-1')
LEFT JOIN bronze.dft_code_list AS pc  ON pc.table_name ='collision' AND pc.field_name ='pedestrian_crossing'       AND pc.code =NULLIF(c.pedestrian_crossing,'-1')
LEFT JOIN bronze.dft_code_list AS lc  ON lc.table_name ='collision' AND lc.field_name ='light_conditions'          AND lc.code =NULLIF(c.light_conditions,'-1')
LEFT JOIN bronze.dft_code_list AS wc  ON wc.table_name ='collision' AND wc.field_name ='weather_conditions'        AND wc.code =NULLIF(c.weather_conditions,'-1')
LEFT JOIN bronze.dft_code_list AS rsc ON rsc.table_name='collision' AND rsc.field_name='road_surface_conditions'   AND rsc.code=NULLIF(c.road_surface_conditions,'-1')
LEFT JOIN bronze.dft_code_list AS sc  ON sc.table_name ='collision' AND sc.field_name ='special_conditions_at_site' AND sc.code=NULLIF(c.special_conditions_at_site,'-1')
LEFT JOIN bronze.dft_code_list AS ch  ON ch.table_name ='collision' AND ch.field_name ='carriageway_hazards'       AND ch.code =NULLIF(c.carriageway_hazards,'-1')
LEFT JOIN bronze.dft_code_list AS pa  ON pa.table_name ='collision' AND pa.field_name ='did_police_officer_attend_scene_of_accident' AND pa.code=NULLIF(c.did_police_officer_attend_scene_of_accident,'-1')
LEFT JOIN bronze.dft_code_list AS tr  ON tr.table_name ='collision' AND tr.field_name ='trunk_road_flag'           AND tr.code =NULLIF(c.trunk_road_flag,'-1');
GO