/*
=====================================================================
Script      : profile_vehicle_casualty.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Profiles bronze.dft_vehicle and bronze.dft_casualty
              before designing the silver layer.
Note        : Read-only.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- ------------------------------------------------------------------
-- PROFILE 6: Is collision_index + vehicle_reference unique?
-- This is the expected grain of the vehicle table.
-- ------------------------------------------------------------------
SELECT
    COUNT(*)                                             AS total_rows,
    COUNT(DISTINCT collision_index + '|' + vehicle_reference) AS distinct_keys
FROM bronze.dft_vehicle;


-- ------------------------------------------------------------------
-- PROFILE 7: Is collision_index + casualty_reference unique?
-- ------------------------------------------------------------------
SELECT
    COUNT(*)                                              AS total_rows,
    COUNT(DISTINCT collision_index + '|' + casualty_reference) AS distinct_keys
FROM bronze.dft_casualty;


-- ------------------------------------------------------------------
-- PROFILE 8: Missing values in the driver columns we care about.
-- ------------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN age_of_driver     = '-1' THEN 1 ELSE 0 END) AS missing_driver_age,
    SUM(CASE WHEN sex_of_driver     IN ('-1','3') THEN 1 ELSE 0 END) AS unknown_driver_sex,
    SUM(CASE WHEN vehicle_type      = '-1' THEN 1 ELSE 0 END) AS missing_vehicle_type,
    SUM(CASE WHEN age_of_vehicle    = '-1' THEN 1 ELSE 0 END) AS missing_vehicle_age,
    SUM(CASE WHEN engine_capacity_cc = '-1' THEN 1 ELSE 0 END) AS missing_engine_cc
FROM bronze.dft_vehicle;


-- ------------------------------------------------------------------
-- PROFILE 9: Missing values in the casualty columns we care about.
-- ------------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN age_of_casualty   = '-1' THEN 1 ELSE 0 END) AS missing_casualty_age,
    SUM(CASE WHEN sex_of_casualty   IN ('-1','3') THEN 1 ELSE 0 END) AS unknown_casualty_sex,
    SUM(CASE WHEN casualty_severity = '-1' THEN 1 ELSE 0 END) AS missing_severity,
    SUM(CASE WHEN casualty_class    = '-1' THEN 1 ELSE 0 END) AS missing_class
FROM bronze.dft_casualty;


-- ------------------------------------------------------------------
-- PROFILE 10: Casualty severity distribution.
-- Compare the shape with the collision severity split.
-- ------------------------------------------------------------------
SELECT
    casualty_severity,
    COUNT(*) AS casualties
FROM bronze.dft_casualty
GROUP BY casualty_severity
ORDER BY casualty_severity;


-- ------------------------------------------------------------------
-- PROFILE 11: Referential integrity.
-- Every vehicle and casualty must belong to a collision that exists.
-- Expected: 0 and 0.
-- ------------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM bronze.dft_vehicle v
     WHERE NOT EXISTS (SELECT 1 FROM bronze.dft_collision c
                       WHERE c.collision_index = v.collision_index)) AS orphan_vehicles,
    (SELECT COUNT(*) FROM bronze.dft_casualty cas
     WHERE NOT EXISTS (SELECT 1 FROM bronze.dft_collision c
                       WHERE c.collision_index = cas.collision_index)) AS orphan_casualties;