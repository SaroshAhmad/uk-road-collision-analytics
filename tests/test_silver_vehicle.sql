/*
=====================================================================
Script      : test_silver_vehicle.sql
Purpose     : Checks silver.vehicle against bronze.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- V1: Row count must match bronze. Expected: 937265, 937265
SELECT
    (SELECT COUNT(*) FROM bronze.dft_vehicle) AS bronze_rows,
    (SELECT COUNT(*) FROM silver.vehicle)     AS silver_rows;

-- Expected: about 73 (0.008%) — known source-data error, too small to matter.
-- V2: Implausible ages for MOTOR vehicles only.
-- Young riders of pedal cycles, horses and mobility scooters are normal.
-- Expected: a handful (about 9), which is known source-data error.
SELECT COUNT(*) AS implausible_driver_ages
FROM silver.vehicle
WHERE age_of_driver < 15
  AND vehicle_type IN ('Car', 'Taxi/Private hire car',
                       'Van / Goods 3.5 tonnes mgw or under',
                       'Goods 7.5 tonnes mgw and over',
                       'Bus or coach (17 or more pass seats)');

-- V3: The 10 most common vehicle types.
SELECT TOP 10 vehicle_type, COUNT(*) AS vehicles
FROM silver.vehicle
GROUP BY vehicle_type
ORDER BY vehicles DESC;

-- V4: 10 sample rows, to read as English.
SELECT TOP 10 collision_index, vehicle_reference, vehicle_type,
       vehicle_manoeuvre, sex_of_driver, age_of_driver, age_band_of_driver
FROM silver.vehicle;