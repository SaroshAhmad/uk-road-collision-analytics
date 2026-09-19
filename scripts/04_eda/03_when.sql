/*
=====================================================================
Script      : 03_when.sql
Purpose     : Question 5 - time of day and day of week.
Baseline    : 24.21% of all collisions are serious or fatal.
Note        : All five years pooled (D-026).
=====================================================================
*/

USE RoadSafetyDW;
GO

-- Q5a: By hour of day
SELECT
    hour_of_day,
    COUNT(*)                 AS collisions,
    SUM(is_serious_or_fatal) AS serious_or_fatal,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision
WHERE hour_of_day IS NOT NULL
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- Q5b: By day of week, weekday vs weekend
SELECT
    d.day_number,
    d.day_name,
    d.is_weekend,
    COUNT(*)                   AS collisions,
    CAST(100.0 * SUM(f.is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision AS f
INNER JOIN gold.dim_date AS d ON d.date_key = f.date_key
GROUP BY d.day_number, d.day_name, d.is_weekend
ORDER BY d.day_number;

-- Q6: By month, pooled across all years
SELECT
    d.month_number,
    d.month_name,
    COUNT(*)                   AS collisions,
    CAST(100.0 * SUM(f.is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision AS f
INNER JOIN gold.dim_date AS d ON d.date_key = f.date_key
GROUP BY d.month_number, d.month_name
ORDER BY d.month_number;


-- Q5c: Weekend nights vs weekday nights.
-- Splits the night-time effect from the weekend effect.
SELECT
    CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    CASE WHEN f.hour_of_day BETWEEN 0 AND 5 THEN 'Night (00-05)'
         WHEN f.hour_of_day BETWEEN 6 AND 17 THEN 'Day (06-17)'
         ELSE 'Evening (18-23)' END AS time_band,
    COUNT(*)                   AS collisions,
    CAST(100.0 * SUM(f.is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision AS f
INNER JOIN gold.dim_date AS d ON d.date_key = f.date_key
WHERE f.hour_of_day IS NOT NULL
GROUP BY
    CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END,
    CASE WHEN f.hour_of_day BETWEEN 0 AND 5 THEN 'Night (00-05)'
         WHEN f.hour_of_day BETWEEN 6 AND 17 THEN 'Day (06-17)'
         ELSE 'Evening (18-23)' END
ORDER BY day_type, time_band;