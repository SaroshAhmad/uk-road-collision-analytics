/*
=====================================================================
Script      : test_bronze_structure.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Checks that each bronze table has the same number of
              columns as its source CSV (D-009).
Expected    : dft_casualty = 23, dft_collision = 44, dft_vehicle = 32
=====================================================================
*/

-- Check: each bronze table has the same number of columns as its CSV
SELECT
    TABLE_NAME,
    COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;