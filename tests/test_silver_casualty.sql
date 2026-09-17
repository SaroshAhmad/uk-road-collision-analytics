/*
=====================================================================
Script      : test_silver_casualty.sql
Purpose     : Checks silver.casualty against bronze.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- C1: Row count must match bronze. Expected: 652821, 652821
SELECT
    (SELECT COUNT(*) FROM bronze.dft_casualty) AS bronze_rows,
    (SELECT COUNT(*) FROM silver.casualty)     AS silver_rows;

-- C2: Severity must match bronze. Expected: 8033 Fatal, 129011 Serious, 515777 Slight
SELECT casualty_severity_code, casualty_severity, COUNT(*) AS casualties
FROM silver.casualty
GROUP BY casualty_severity_code, casualty_severity
ORDER BY casualty_severity_code;

-- C3: Who gets hurt? (casualty_class)
SELECT casualty_class, COUNT(*) AS casualties
FROM silver.casualty
GROUP BY casualty_class
ORDER BY casualties DESC;

-- C4: Every casualty must belong to a collision in silver. Expected: 0
SELECT COUNT(*) AS orphan_casualties
FROM silver.casualty AS c
WHERE NOT EXISTS (
    SELECT 1 FROM silver.collision AS s
    WHERE s.collision_index = c.collision_index
);

-- C5: 10 sample rows.
SELECT TOP 10 collision_index, casualty_reference, casualty_class,
       sex_of_casualty, age_of_casualty, casualty_severity, casualty_type
FROM silver.casualty;