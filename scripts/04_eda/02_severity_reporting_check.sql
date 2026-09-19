/*
=====================================================================
Script      : 02_severity_reporting_check.sql
Purpose     : Tests whether the rising serious-or-fatal rate reflects
              real change or a change in how severity is recorded.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- A: How was severity recorded, by year?
SELECT
    b.collision_year,
    ISNULL(cl.label, 'Not recorded') AS severity_recording_method,
    COUNT(*) AS collisions
FROM bronze.dft_collision AS b
LEFT JOIN bronze.dft_code_list AS cl
       ON cl.table_name = 'collision'
      AND cl.field_name = 'collision_injury_based'
      AND cl.code       = NULLIF(b.collision_injury_based, '-1')
GROUP BY b.collision_year, ISNULL(cl.label, 'Not recorded')
ORDER BY b.collision_year, severity_recording_method;


-- B: Fatalities alone, by year. Deaths are hard to misclassify.
SELECT
    d.year_number,
    SUM(f.is_fatal) AS fatal_collisions,
    CAST(100.0 * SUM(f.is_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_fatal
FROM gold.fact_collision AS f
INNER JOIN gold.dim_date AS d ON d.date_key = f.date_key
GROUP BY d.year_number
ORDER BY d.year_number;