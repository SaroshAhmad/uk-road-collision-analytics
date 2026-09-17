/*
=====================================================================
Script      : proc_load_silver.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Rebuilds the whole silver layer from bronze in one call.
Usage       : EXEC silver.load_silver;
Notes       : Full rebuild. Each table is truncated then reloaded.
              Codes are decoded via bronze.dft_code_list,
              -1 becomes NULL or 'Not recorded' (D-020, D-022).
=====================================================================
*/

USE RoadSafetyDW;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start DATETIME = GETDATE();
    DECLARE @step  DATETIME;

    BEGIN TRY
        PRINT '=== Silver load started ===';

        -- --------------------------------------------------------------
        -- silver.collision
        -- --------------------------------------------------------------
        SET @step = GETDATE();
        PRINT 'Loading silver.collision...';

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
            TRY_CONVERT(TIME(0), c.time),
            ISNULL(dow.label, 'Not recorded'),

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
            TRY_CAST(NULLIF(c.speed_limit, '-1') AS SMALLINT),
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

        PRINT '   done in ' + CAST(DATEDIFF(SECOND, @step, GETDATE()) AS NVARCHAR) + ' seconds';

        -- --------------------------------------------------------------
        -- silver.vehicle
        -- --------------------------------------------------------------
        SET @step = GETDATE();
        PRINT 'Loading silver.vehicle...';

        TRUNCATE TABLE silver.vehicle;

        INSERT INTO silver.vehicle (
            collision_index, vehicle_reference, vehicle_type, towing_and_articulation,
            generic_make_model, vehicle_manoeuvre, junction_location, skidding_and_overturning,
            hit_object_in_carriageway, vehicle_leaving_carriageway, hit_object_off_carriageway,
            first_point_of_impact, journey_purpose_of_driver, sex_of_driver, age_of_driver,
            age_band_of_driver, driver_imd_decile, engine_capacity_cc, age_of_vehicle, escooter_flag
        )
        SELECT
            v.collision_index,
            CAST(v.vehicle_reference AS SMALLINT),
            ISNULL(vt.label,  'Not recorded'),
            ISNULL(tow.label, 'Not recorded'),
            NULLIF(v.generic_make_model, '-1'),
            ISNULL(man.label, 'Not recorded'),
            ISNULL(jl.label,  'Not recorded'),
            ISNULL(sk.label,  'Not recorded'),
            ISNULL(hic.label, 'Not recorded'),
            ISNULL(lc.label,  'Not recorded'),
            ISNULL(hoc.label, 'Not recorded'),
            ISNULL(imp.label, 'Not recorded'),
            ISNULL(jp.label,  'Not recorded'),
            ISNULL(sex.label, 'Not recorded'),
            TRY_CAST(NULLIF(v.age_of_driver, '-1') AS SMALLINT),
            ISNULL(ab.label,  'Not recorded'),
            ISNULL(imd.label, 'Not recorded'),
            TRY_CAST(NULLIF(v.engine_capacity_cc, '-1') AS INT),
            TRY_CAST(NULLIF(v.age_of_vehicle, '-1') AS SMALLINT),
            ISNULL(es.label,  'Not recorded')
        FROM bronze.dft_vehicle AS v
        LEFT JOIN bronze.dft_code_list AS vt  ON vt.table_name ='vehicle' AND vt.field_name ='vehicle_type'                AND vt.code =NULLIF(v.vehicle_type,'-1')
        LEFT JOIN bronze.dft_code_list AS tow ON tow.table_name='vehicle' AND tow.field_name='towing_and_articulation'     AND tow.code=NULLIF(v.towing_and_articulation,'-1')
        LEFT JOIN bronze.dft_code_list AS man ON man.table_name='vehicle' AND man.field_name='vehicle_manoeuvre'           AND man.code=NULLIF(v.vehicle_manoeuvre,'-1')
        LEFT JOIN bronze.dft_code_list AS jl  ON jl.table_name ='vehicle' AND jl.field_name ='junction_location'           AND jl.code =NULLIF(v.junction_location,'-1')
        LEFT JOIN bronze.dft_code_list AS sk  ON sk.table_name ='vehicle' AND sk.field_name ='skidding_and_overturning'    AND sk.code =NULLIF(v.skidding_and_overturning,'-1')
        LEFT JOIN bronze.dft_code_list AS hic ON hic.table_name='vehicle' AND hic.field_name='hit_object_in_carriageway'   AND hic.code=NULLIF(v.hit_object_in_carriageway,'-1')
        LEFT JOIN bronze.dft_code_list AS lc  ON lc.table_name ='vehicle' AND lc.field_name ='vehicle_leaving_carriageway' AND lc.code =NULLIF(v.vehicle_leaving_carriageway,'-1')
        LEFT JOIN bronze.dft_code_list AS hoc ON hoc.table_name='vehicle' AND hoc.field_name='hit_object_off_carriageway'  AND hoc.code=NULLIF(v.hit_object_off_carriageway,'-1')
        LEFT JOIN bronze.dft_code_list AS imp ON imp.table_name='vehicle' AND imp.field_name='first_point_of_impact'       AND imp.code=NULLIF(v.first_point_of_impact,'-1')
        LEFT JOIN bronze.dft_code_list AS jp  ON jp.table_name ='vehicle' AND jp.field_name ='journey_purpose_of_driver'   AND jp.code =NULLIF(v.journey_purpose_of_driver,'-1')
        LEFT JOIN bronze.dft_code_list AS sex ON sex.table_name='vehicle' AND sex.field_name='sex_of_driver'               AND sex.code=NULLIF(v.sex_of_driver,'-1')
        LEFT JOIN bronze.dft_code_list AS ab  ON ab.table_name ='vehicle' AND ab.field_name ='age_band_of_driver'          AND ab.code =NULLIF(v.age_band_of_driver,'-1')
        LEFT JOIN bronze.dft_code_list AS imd ON imd.table_name='vehicle' AND imd.field_name='driver_imd_decile'           AND imd.code=NULLIF(v.driver_imd_decile,'-1')
        LEFT JOIN bronze.dft_code_list AS es  ON es.table_name ='vehicle' AND es.field_name ='escooter_flag'               AND es.code =NULLIF(v.escooter_flag,'-1');

        PRINT '   done in ' + CAST(DATEDIFF(SECOND, @step, GETDATE()) AS NVARCHAR) + ' seconds';

        -- --------------------------------------------------------------
        -- silver.casualty
        -- --------------------------------------------------------------
        SET @step = GETDATE();
        PRINT 'Loading silver.casualty...';

        TRUNCATE TABLE silver.casualty;

        INSERT INTO silver.casualty (
            collision_index, casualty_reference, vehicle_reference, casualty_class,
            sex_of_casualty, age_of_casualty, age_band_of_casualty, casualty_type,
            casualty_severity_code, casualty_severity, pedestrian_location, pedestrian_movement,
            pedestrian_road_maintenance_worker, car_passenger, bus_or_coach_passenger,
            casualty_imd_decile
        )
        SELECT
            c.collision_index,
            CAST(c.casualty_reference AS SMALLINT),
            TRY_CAST(NULLIF(c.vehicle_reference, '-1') AS SMALLINT),
            ISNULL(cls.label, 'Not recorded'),
            ISNULL(sex.label, 'Not recorded'),
            TRY_CAST(NULLIF(c.age_of_casualty, '-1') AS SMALLINT),
            ISNULL(ab.label,  'Not recorded'),
            ISNULL(typ.label, 'Not recorded'),
            CAST(c.casualty_severity AS TINYINT),
            sev.label,
            ISNULL(ploc.label, 'Not recorded'),
            ISNULL(pmov.label, 'Not recorded'),
            ISNULL(work.label, 'Not recorded'),
            ISNULL(cp.label,   'Not recorded'),
            ISNULL(bp.label,   'Not recorded'),
            ISNULL(imd.label,  'Not recorded')
        FROM bronze.dft_casualty AS c
        LEFT JOIN bronze.dft_code_list AS cls  ON cls.table_name ='casualty' AND cls.field_name ='casualty_class'                     AND cls.code =NULLIF(c.casualty_class,'-1')
        LEFT JOIN bronze.dft_code_list AS sex  ON sex.table_name ='casualty' AND sex.field_name ='sex_of_casualty'                    AND sex.code =NULLIF(c.sex_of_casualty,'-1')
        LEFT JOIN bronze.dft_code_list AS ab   ON ab.table_name  ='casualty' AND ab.field_name  ='age_band_of_casualty'               AND ab.code  =NULLIF(c.age_band_of_casualty,'-1')
        LEFT JOIN bronze.dft_code_list AS typ  ON typ.table_name ='casualty' AND typ.field_name ='casualty_type'                      AND typ.code =NULLIF(c.casualty_type,'-1')
        LEFT JOIN bronze.dft_code_list AS sev  ON sev.table_name ='casualty' AND sev.field_name ='casualty_severity'                  AND sev.code =NULLIF(c.casualty_severity,'-1')
        LEFT JOIN bronze.dft_code_list AS ploc ON ploc.table_name='casualty' AND ploc.field_name='pedestrian_location'                AND ploc.code=NULLIF(c.pedestrian_location,'-1')
        LEFT JOIN bronze.dft_code_list AS pmov ON pmov.table_name='casualty' AND pmov.field_name='pedestrian_movement'                AND pmov.code=NULLIF(c.pedestrian_movement,'-1')
        LEFT JOIN bronze.dft_code_list AS work ON work.table_name='casualty' AND work.field_name='pedestrian_road_maintenance_worker' AND work.code=NULLIF(c.pedestrian_road_maintenance_worker,'-1')
        LEFT JOIN bronze.dft_code_list AS cp   ON cp.table_name  ='casualty' AND cp.field_name  ='car_passenger'                      AND cp.code  =NULLIF(c.car_passenger,'-1')
        LEFT JOIN bronze.dft_code_list AS bp   ON bp.table_name  ='casualty' AND bp.field_name  ='bus_or_coach_passenger'             AND bp.code  =NULLIF(c.bus_or_coach_passenger,'-1')
        LEFT JOIN bronze.dft_code_list AS imd  ON imd.table_name ='casualty' AND imd.field_name ='casualty_imd_decile'                AND imd.code =NULLIF(c.casualty_imd_decile,'-1');

        PRINT '   done in ' + CAST(DATEDIFF(SECOND, @step, GETDATE()) AS NVARCHAR) + ' seconds';

        PRINT '=== Silver load finished in '
            + CAST(DATEDIFF(SECOND, @start, GETDATE()) AS NVARCHAR) + ' seconds ===';
    END TRY
    BEGIN CATCH
        PRINT '!!! SILVER LOAD FAILED !!!';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Line   : ' + CAST(ERROR_LINE() AS NVARCHAR);
    END CATCH
END;
GO