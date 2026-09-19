/*
=====================================================================
Script      : 05_who.sql
Purpose     : Question 8 - drivers, vehicles and road users.
Baseline    : 24.21% of collisions are serious or fatal.
Note        : Driver age is missing for parked and untraced vehicles
              (15%, D-019), so those rows are excluded, not imputed.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- Q8a: Driver age band
SELECT
    age_band_of_driver,
    COUNT(*)                 AS vehicles,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_vehicle
WHERE age_band_of_driver <> 'Not recorded'
GROUP BY age_band_of_driver
ORDER BY age_band_of_driver;


-- Q8b: Vehicle type (only types with enough rows to be meaningful)
SELECT
    vehicle_type,
    COUNT(*)                 AS vehicles,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal
FROM gold.fact_vehicle
GROUP BY vehicle_type
HAVING COUNT(*) >= 1000
ORDER BY pct_serious_or_fatal DESC;


-- Q8c: Road user type - who actually gets hurt, and how badly
SELECT
    casualty_type,
    COUNT(*)                 AS casualties,
    SUM(is_fatal)            AS fatalities,
    CAST(100.0 * SUM(is_serious_or_fatal) / COUNT(*) AS DECIMAL(5,2)) AS pct_serious_or_fatal,
    CAST(100.0 * SUM(is_fatal)            / COUNT(*) AS DECIMAL(5,2)) AS pct_fatal
FROM gold.fact_casualty
GROUP BY casualty_type
HAVING COUNT(*) >= 1000
ORDER BY casualties DESC;