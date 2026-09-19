/*
=====================================================================
Script      : 01_overview.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Baseline figures for the analysis. Every later result
              is compared against these.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- Q0a: Headline numbers for the whole period
SELECT
    COUNT(*)                        AS total_collisions,
    SUM(number_of_casualties)       AS total_casualties,
    SUM(is_fatal)                   AS fatal_collisions,
    SUM(is_serious_or_fatal)        AS serious_or_fatal_collisions,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal,
    CAST(100.0 * SUM(is_fatal)            / COUNT(*) AS DECIMAL(5,2)) AS pct_fatal
FROM gold.fact_collision;


-- Q0b: The same, year by year. Is the trend improving or worsening?
SELECT
    d.year_number,
    COUNT(*)                 AS collisions,
    SUM(f.is_fatal)          AS fatal,
    SUM(f.is_serious_or_fatal) AS serious_or_fatal,
    CAST(100.0 * SUM(f.is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_collision AS f
INNER JOIN gold.dim_date AS d
        ON d.date_key = f.date_key
GROUP BY d.year_number
ORDER BY d.year_number;