/*
=====================================================================
Script      : load_bronze.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Loads the DfT CSV files into the bronze tables.
Method      : Full load. Each table is emptied, then reloaded (D-014).
Notes       : Files use LF line endings, so ROWTERMINATOR = '0x0a' (D-015).
              File paths are read by the SQL Server service account,
              which is why the CSVs are in C:\sql_data\stats19\.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- ------------------------------------------------------------------
-- Load: bronze.dft_collision
-- ------------------------------------------------------------------

-- Empty the table first so re-running never duplicates rows
TRUNCATE TABLE bronze.dft_collision;

BULK INSERT bronze.dft_collision
FROM 'C:\sql_data\stats19\dft-road-casualty-statistics-collision-last-5-years.csv'
WITH (
    FORMAT          = 'CSV',     -- understands CSV rules, e.g. values in "quotes"
    FIRSTROW        = 2,         -- row 1 is the header, skip it
    FIELDTERMINATOR = ',',       -- columns are separated by commas
    ROWTERMINATOR   = '0x0a',    -- rows end with LF only (D-015)
    CODEPAGE        = '65001',   -- read the file as UTF-8
    TABLOCK                      -- lock the whole table: faster bulk loading
);
GO

-- ------------------------------------------------------------------
-- Load: bronze.dft_vehicle
-- ------------------------------------------------------------------

-- Empty the table first so re-running never duplicates rows
TRUNCATE TABLE bronze.dft_vehicle;

BULK INSERT bronze.dft_vehicle
FROM 'C:\sql_data\stats19\dft-road-casualty-statistics-vehicle-last-5-years.csv'
WITH (
    FORMAT          = 'CSV',     -- handles quoted values (e.g. make/model text)
    FIRSTROW        = 2,         -- skip header
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',    -- LF line endings (D-015)
    CODEPAGE        = '65001',   -- UTF-8
    TABLOCK
);
GO

-- ------------------------------------------------------------------
-- Load: bronze.dft_casualty
-- ------------------------------------------------------------------

TRUNCATE TABLE bronze.dft_casualty;

BULK INSERT bronze.dft_casualty
FROM 'C:\sql_data\stats19\dft-road-casualty-statistics-casualty-last-5-years.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

-- ------------------------------------------------------------------
-- Load: bronze.dft_code_list
-- NOTE: This file was created by Excel, so it uses Windows line
--       endings (CRLF), unlike the DfT files which use LF (D-015).
-- ------------------------------------------------------------------

TRUNCATE TABLE bronze.dft_code_list;

BULK INSERT bronze.dft_code_list
FROM 'C:\sql_data\stats19\dft_code_list.csv'
WITH (
    FORMAT          = 'CSV',      -- essential: labels contain commas
    FIRSTROW        = 2,          -- skip the header row
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0d0a',   -- CRLF, because Excel wrote this file
    CODEPAGE        = '65001',
    TABLOCK
);
GO