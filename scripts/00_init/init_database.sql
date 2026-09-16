/*
==================================================================================================================================
Script		: init_database.sql
Project		: UK Road Collision Risk Analytics
Author		: Ahmad Sarosh
Purpose		: Creates the RoadSafetyDW database and the three schemas used in the Medallion architecture (bronze, silver, gold).
Run order	: First script in the project. Run once.
==================================================================================================================================
*/

-- Switch to the master database.
-- New databases are created from master, SQL Server's system database.
USE master;
GO

-- Create the data warehouse database.
-- "DW" = Data Warehouse (see decisions log D-007).
CREATE DATABASE RoadSafetyDW;
GO

-- Switch into the new database so the schemas are created here,
-- not inside master.
USE RoadSafetyDW;
GO

-- BRONZE: raw data, loaded exactly as downloaded from DfT.
-- Never modified, so every number can be traced back to the source.
CREATE SCHEMA bronze;
GO

-- SILVER: cleaned, correctly typed and decoded data
-- (e.g. severity code 2 becomes 'Serious').
CREATE SCHEMA silver;
GO

-- GOLD: business-ready model that Power BI connects to.
CREATE SCHEMA gold;
GO

-- Note: each CREATE SCHEMA must run in its own batch,
-- which is why a GO follows each one.