/*
=====================================================================
Script      : ddl_gold.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Creates the gold layer: a date dimension table plus
              the fact views used by Power BI.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- ------------------------------------------------------------------
-- Table : gold.dim_date
-- Grain : one row per calendar day (2021-01-01 to 2025-12-31)
-- Note  : Generated, not derived from silver.
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS gold.dim_date;
GO

CREATE TABLE gold.dim_date (
    date_key        DATE         NOT NULL PRIMARY KEY,
    year_number     SMALLINT     NOT NULL,
    quarter_number  TINYINT      NOT NULL,
    quarter_name    NVARCHAR(10) NOT NULL,   -- 'Q1'
    month_number    TINYINT      NOT NULL,   -- 1-12, for correct sorting
    month_name      NVARCHAR(20) NOT NULL,   -- 'January'
    month_year      NVARCHAR(20) NOT NULL,   -- 'Jan 2021'
    day_of_month    TINYINT      NOT NULL,
    day_name        NVARCHAR(20) NOT NULL,   -- 'Monday'
    day_number      TINYINT      NOT NULL,   -- 1 = Monday ... 7 = Sunday
    is_weekend      BIT          NOT NULL    -- 1 = Saturday or Sunday
);
GO

-- Fill it, one row per day across the five years
WITH date_series AS (
    SELECT CAST('2021-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM date_series
    WHERE d < '2025-12-31'
)
INSERT INTO gold.dim_date (
    date_key, year_number, quarter_number, quarter_name,
    month_number, month_name, month_year,
    day_of_month, day_name, day_number, is_weekend
)
SELECT
    d,
    YEAR(d),
    DATEPART(QUARTER, d),
    'Q' + CAST(DATEPART(QUARTER, d) AS NVARCHAR(1)),
    MONTH(d),
    DATENAME(MONTH, d),
    LEFT(DATENAME(MONTH, d), 3) + ' ' + CAST(YEAR(d) AS NVARCHAR(4)),
    DAY(d),
    DATENAME(WEEKDAY, d),
    CASE DATENAME(WEEKDAY, d)
        WHEN 'Monday' THEN 1 WHEN 'Tuesday'  THEN 2 WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday'  THEN 6
        ELSE 7 END,
    CASE WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 1 ELSE 0 END
FROM date_series
OPTION (MAXRECURSION 0);   -- allow more than the default 100 loops
GO

-- ------------------------------------------------------------------
-- View  : gold.fact_collision
-- Grain : one row per collision
-- Note  : A view, so it always reflects current silver data.
-- ------------------------------------------------------------------

CREATE OR ALTER VIEW gold.fact_collision AS
SELECT
    -- Keys
    c.collision_index,
    c.collision_date            AS date_key,   -- joins to gold.dim_date

    -- Time of day
    c.collision_time,
    DATEPART(HOUR, c.collision_time) AS hour_of_day,

    -- Severity
    c.collision_severity_code,
    c.collision_severity,

    -- Flags: 1 or 0, so they can be summed and averaged into rates
    CASE WHEN c.collision_severity_code = 1 THEN 1 ELSE 0 END AS is_fatal,
    CASE WHEN c.collision_severity_code = 2 THEN 1 ELSE 0 END AS is_serious,
    CASE WHEN c.collision_severity_code IN (1,2) THEN 1 ELSE 0 END AS is_serious_or_fatal,

    -- Counts
    c.number_of_vehicles,
    c.number_of_casualties,

    -- Where
    c.police_force,
    c.local_authority_district,
    c.local_authority_ons_code,
    c.urban_or_rural_area,
    c.latitude,
    c.longitude,

    -- Road
    c.road_type,
    c.speed_limit,
    c.first_road_class,
    c.junction_detail,
    c.junction_control,

    -- Conditions
    c.light_conditions,
    c.weather_conditions,
    c.road_surface_conditions,
    c.carriageway_hazards,

    -- Reporting
    c.police_attended,
    c.trunk_road_flag
FROM silver.collision AS c;
GO

-- ------------------------------------------------------------------
-- View  : gold.fact_casualty
-- Grain : one row per casualty
-- ------------------------------------------------------------------

CREATE OR ALTER VIEW gold.fact_casualty AS
SELECT
    cas.collision_index,
    cas.casualty_reference,
    col.collision_date AS date_key,

    cas.casualty_class,
    cas.casualty_type,
    cas.sex_of_casualty,
    cas.age_of_casualty,
    cas.age_band_of_casualty,

    cas.casualty_severity_code,
    cas.casualty_severity,
    CASE WHEN cas.casualty_severity_code = 1 THEN 1 ELSE 0 END AS is_fatal,
    CASE WHEN cas.casualty_severity_code IN (1,2) THEN 1 ELSE 0 END AS is_serious_or_fatal,

    -- Collision context, so casualties can be sliced without extra joins
    col.urban_or_rural_area,
    col.road_type,
    col.speed_limit,
    col.light_conditions,
    col.weather_conditions,
    col.police_force
FROM silver.casualty AS cas
INNER JOIN silver.collision AS col
        ON col.collision_index = cas.collision_index;
GO


-- ------------------------------------------------------------------
-- View  : gold.fact_vehicle
-- Grain : one row per vehicle in a collision
-- ------------------------------------------------------------------

CREATE OR ALTER VIEW gold.fact_vehicle AS
SELECT
    v.collision_index,
    v.vehicle_reference,
    col.collision_date AS date_key,

    v.vehicle_type,
    v.vehicle_manoeuvre,
    v.first_point_of_impact,
    v.junction_location,
    v.skidding_and_overturning,
    v.journey_purpose_of_driver,

    v.sex_of_driver,
    v.age_of_driver,
    v.age_band_of_driver,

    -- Collision context
    col.collision_severity,
    CASE WHEN col.collision_severity_code IN (1,2) THEN 1 ELSE 0 END AS is_serious_or_fatal,
    col.urban_or_rural_area,
    col.road_type,
    col.speed_limit,
    col.light_conditions,
    col.weather_conditions
FROM silver.vehicle AS v
INNER JOIN silver.collision AS col
        ON col.collision_index = v.collision_index;
GO

SELECT
    (SELECT COUNT(*) FROM gold.fact_collision) AS collisions,   -- 513801
    (SELECT COUNT(*) FROM gold.fact_casualty)  AS casualties,   -- 652821
    (SELECT COUNT(*) FROM gold.fact_vehicle)   AS vehicles;     -- 937265