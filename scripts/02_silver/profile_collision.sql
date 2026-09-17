/*
=====================================================================
Script      : profile_collision.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Profiles bronze.dft_collision before designing the
              silver layer: key uniqueness, missing values and
              the distribution of key coded columns.
Note        : Read-only. This script never changes data.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- ------------------------------------------------------------------
-- PROFILE 1: Is collision_index unique?
-- If the two numbers differ, the "one row per collision" grain is broken.
-- ------------------------------------------------------------------
SELECT
    COUNT(*)                        AS total_rows,
    COUNT(DISTINCT collision_index) AS distinct_collision_ids
FROM bronze.dft_collision;


-- ------------------------------------------------------------------
-- PROFILE 2: Are any critical columns empty?
-- Counts blanks and NULLs in the columns the analysis depends on.
-- Expected: 0 everywhere. Anything else needs investigating.
-- ------------------------------------------------------------------
SELECT
    SUM(CASE WHEN collision_index      IS NULL OR LTRIM(RTRIM(collision_index))      = '' THEN 1 ELSE 0 END) AS blank_index,
    SUM(CASE WHEN date                 IS NULL OR LTRIM(RTRIM(date))                 = '' THEN 1 ELSE 0 END) AS blank_date,
    SUM(CASE WHEN time                 IS NULL OR LTRIM(RTRIM(time))                 = '' THEN 1 ELSE 0 END) AS blank_time,
    SUM(CASE WHEN collision_severity   IS NULL OR LTRIM(RTRIM(collision_severity))   = '' THEN 1 ELSE 0 END) AS blank_severity,
    SUM(CASE WHEN longitude            IS NULL OR LTRIM(RTRIM(longitude))            = '' THEN 1 ELSE 0 END) AS blank_longitude,
    SUM(CASE WHEN latitude             IS NULL OR LTRIM(RTRIM(latitude))             = '' THEN 1 ELSE 0 END) AS blank_latitude
FROM bronze.dft_collision;


-- ------------------------------------------------------------------
-- PROFILE 3: How much "-1" (missing/out of range) is there
-- in the columns we plan to analyse?
-- ------------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN speed_limit             = '-1' THEN 1 ELSE 0 END) AS missing_speed_limit,
    SUM(CASE WHEN road_type               = '-1' THEN 1 ELSE 0 END) AS missing_road_type,
    SUM(CASE WHEN junction_detail         = '-1' THEN 1 ELSE 0 END) AS missing_junction_detail,
    SUM(CASE WHEN light_conditions        = '-1' THEN 1 ELSE 0 END) AS missing_light,
    SUM(CASE WHEN weather_conditions      = '-1' THEN 1 ELSE 0 END) AS missing_weather,
    SUM(CASE WHEN road_surface_conditions = '-1' THEN 1 ELSE 0 END) AS missing_road_surface,
    SUM(CASE WHEN urban_or_rural_area     = '-1' THEN 1 ELSE 0 END) AS missing_urban_rural
FROM bronze.dft_collision;


-- ------------------------------------------------------------------
-- PROFILE 4: What values actually appear in collision_severity?
-- The data guide says 1 = Fatal, 2 = Serious, 3 = Slight.
-- ------------------------------------------------------------------
SELECT
    collision_severity,
    COUNT(*) AS collisions
FROM bronze.dft_collision
GROUP BY collision_severity
ORDER BY collision_severity;


-- ------------------------------------------------------------------
-- PROFILE 5: What values appear in urban_or_rural_area?
-- The guide lists 1 = Urban, 2 = Rural, 3 = Unallocated.
-- ------------------------------------------------------------------
SELECT
    urban_or_rural_area,
    COUNT(*) AS collisions
FROM bronze.dft_collision
GROUP BY urban_or_rural_area
ORDER BY urban_or_rural_area;