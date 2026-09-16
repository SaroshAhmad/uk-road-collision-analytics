/*
=====================================================================
Script      : test_bronze_load.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Checks that the bronze load worked correctly:
              row counts, year coverage, and no hidden characters.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- CHECK 2: Row count in the table.
-- Must equal the file's line count minus 1 (the header).
SELECT COUNT(*) AS collision_rows
FROM bronze.dft_collision;

-- CHECK 3: Which years does the data cover, and how many collisions per year?
-- Confirms the year range for decision D-003.
SELECT
    collision_year,
    COUNT(*) AS collisions
FROM bronze.dft_collision
GROUP BY collision_year
ORDER BY collision_year;

-- CHECK 4: Hidden carriage-return characters (CHAR(13)) in the LAST column.
-- If the row terminator were wrong, every row would have one here.
-- Expected: 0
SELECT COUNT(*) AS rows_with_hidden_cr
FROM bronze.dft_collision
WHERE collision_adjusted_severity_slight LIKE '%' + CHAR(13) + '%';

-- CHECK 5 (visual): Look at a few rows and confirm values sit in the right columns,
-- e.g. collision_severity is 1/2/3 and date looks like dd/mm/yyyy.
SELECT TOP 5 *
FROM bronze.dft_collision;

-- ------------------------------------------------------------------
-- VEHICLE and CASUALTY checks
-- ------------------------------------------------------------------

-- CHECK 6: Row counts (compare with PowerShell line counts minus 1)
SELECT 'vehicle'  AS table_name, COUNT(*) AS row_count FROM bronze.dft_vehicle
UNION ALL
SELECT 'casualty' AS table_name, COUNT(*) AS row_count FROM bronze.dft_casualty;

-- CHECK 7: Hidden CR in the LAST column of each table. Expected: 0 and 0
SELECT
    (SELECT COUNT(*) FROM bronze.dft_vehicle
     WHERE driver_distance_banding LIKE '%' + CHAR(13) + '%')   AS vehicle_hidden_cr,
    (SELECT COUNT(*) FROM bronze.dft_casualty
     WHERE casualty_distance_banding LIKE '%' + CHAR(13) + '%') AS casualty_hidden_cr;

-- CHECK 8: Year coverage should match the collision table (2021-2025)
SELECT collision_year, COUNT(*) AS vehicles
FROM bronze.dft_vehicle
GROUP BY collision_year
ORDER BY collision_year;

SELECT collision_year, COUNT(*) AS casualties
FROM bronze.dft_casualty
GROUP BY collision_year
ORDER BY collision_year;