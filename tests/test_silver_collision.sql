/*
=====================================================================
Script      : test_silver_collision.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Verifies silver.collision against bronze: row counts,
              date conversion, severity distribution and the
              handling of missing values.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- CHECK S1: Row count must match bronze exactly. Expected: 513801, 513801
SELECT
    (SELECT COUNT(*) FROM bronze.dft_collision) AS bronze_rows,
    (SELECT COUNT(*) FROM silver.collision)     AS silver_rows;


-- CHECK S2: Did the UK date conversion work?
-- The year inside the date must match the year column. Expected: 0
SELECT COUNT(*) AS year_mismatches
FROM silver.collision
WHERE DATEPART(YEAR, collision_date) <> collision_year;


-- CHECK S3: Does the date agree with DfT's own day-of-week?
-- This proves dd/mm was not read as mm/dd. Expected: 0
SELECT COUNT(*) AS weekday_mismatches
FROM silver.collision
WHERE day_of_week <> 'Unknown'
  AND DATENAME(WEEKDAY, collision_date) <> day_of_week;


-- CHECK S4: Date range. Expected: 01/01/2021 to 31/12/2025
SELECT
    MIN(collision_date) AS earliest,
    MAX(collision_date) AS latest,
    SUM(CASE WHEN collision_time IS NULL THEN 1 ELSE 0 END) AS missing_times
FROM silver.collision;


-- CHECK S5: Severity distribution must match bronze.
-- Expected: Fatal 7553, Serious 116813, Slight 389435
SELECT
    collision_severity_code,
    collision_severity,
    COUNT(*) AS collisions
FROM silver.collision
GROUP BY collision_severity_code, collision_severity
ORDER BY collision_severity_code;


-- CHECK S6: "-1" became "Not recorded" in the expected quantities.
-- Expected (D-018): junction 19982, surface 3527, light 34,
--                   weather 12, urban/rural 8, speed_limit NULL 3
SELECT
    SUM(CASE WHEN junction_detail         = 'Not recorded' THEN 1 ELSE 0 END) AS notrec_junction,
    SUM(CASE WHEN road_surface_conditions = 'Not recorded' THEN 1 ELSE 0 END) AS notrec_surface,
    SUM(CASE WHEN light_conditions        = 'Not recorded' THEN 1 ELSE 0 END) AS notrec_light,
    SUM(CASE WHEN weather_conditions      = 'Not recorded' THEN 1 ELSE 0 END) AS notrec_weather,
    SUM(CASE WHEN urban_or_rural_area     = 'Not recorded' THEN 1 ELSE 0 END) AS notrec_urban_rural,
    SUM(CASE WHEN speed_limit IS NULL                      THEN 1 ELSE 0 END) AS null_speed_limit
FROM silver.collision;

-- CHECK S9: Weather categories, so the two kinds of "no information" are visible.
SELECT weather_conditions, COUNT(*) AS collisions
FROM silver.collision
GROUP BY weather_conditions
ORDER BY collisions DESC;

-- CHECK S7: Are the numbers plausible?
SELECT
    MIN(speed_limit) AS min_speed, MAX(speed_limit) AS max_speed,
    MIN(latitude)    AS min_lat,   MAX(latitude)    AS max_lat,
    MIN(longitude)   AS min_lon,   MAX(longitude)   AS max_lon
FROM silver.collision;


-- CHECK S8: Read 10 rows and see whether they make sense as English.
SELECT TOP 10
    collision_index, collision_date, collision_time, day_of_week,
    collision_severity, urban_or_rural_area, road_type, speed_limit,
    light_conditions, weather_conditions, police_force
FROM silver.collision;