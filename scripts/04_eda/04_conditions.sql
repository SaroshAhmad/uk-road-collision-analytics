/*
=====================================================================
Script      : 04_conditions.sql
Purpose     : Question 7 - light, weather and road surface.
Baseline    : 24.21% serious or fatal.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- Q7a: Light conditions
SELECT
    light_conditions,
    COUNT(*)                 AS collisions,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision
GROUP BY light_conditions
ORDER BY collisions DESC;


-- Q7b: Weather conditions
SELECT
    weather_conditions,
    COUNT(*)                 AS collisions,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision
GROUP BY weather_conditions
ORDER BY collisions DESC;


-- Q7c: Road surface
SELECT
    road_surface_conditions,
    COUNT(*)                 AS collisions,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision
GROUP BY road_surface_conditions
ORDER BY collisions DESC;

-- Q1: Speed limit
SELECT
    speed_limit,
    COUNT(*)                 AS collisions,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal,
    CAST(100.0 * SUM(is_fatal)            / COUNT(*) AS DECIMAL(5,2)) AS pct_fatal
FROM gold.fact_collision
WHERE speed_limit IS NOT NULL
GROUP BY speed_limit
ORDER BY speed_limit;


-- Q7d: Is the darkness effect really about lighting, or about speed?
-- Same comparison, split by speed limit.
SELECT
    speed_limit,
    light_conditions,
    COUNT(*)                 AS collisions,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision
WHERE light_conditions IN ('Daylight', 'Darkness - lights lit', 'Darkness - no lighting')
  AND speed_limit IN (30, 60)
GROUP BY speed_limit, light_conditions
ORDER BY speed_limit, light_conditions;