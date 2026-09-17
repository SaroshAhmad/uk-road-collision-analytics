/*
=====================================================================
Script      : ddl_silver.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Creates the silver (cleaned) tables.
              Codes are decoded to labels, proper data types are used,
              -1 becomes NULL or 'Unknown', and redundant and
              _historic columns are dropped (D-020, D-021).
WARNING     : Drops and recreates the tables.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- ------------------------------------------------------------------
-- Table : silver.collision
-- Grain : one row per collision
-- Key   : collision_index
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS silver.collision;
GO

CREATE TABLE silver.collision (
    -- Key
    collision_index           NVARCHAR(20)  NOT NULL,

    -- When
    collision_year            SMALLINT      NOT NULL,
    collision_date            DATE          NOT NULL,
    collision_time            TIME(0)       NULL,     -- NULL if the time was not recorded
    day_of_week               NVARCHAR(20)  NULL,     -- 'Monday', 'Tuesday', ...

    -- Severity and scale
    collision_severity_code   TINYINT       NOT NULL, -- 1 Fatal, 2 Serious, 3 Slight
    collision_severity        NVARCHAR(20)  NOT NULL, -- 'Fatal', 'Serious', 'Slight'
    number_of_vehicles        SMALLINT      NULL,
    number_of_casualties      SMALLINT      NULL,

    -- Where
    longitude                 DECIMAL(9,6)  NULL,     -- NULL for the 53 rows with no coordinates
    latitude                  DECIMAL(9,6)  NULL,
    police_force              NVARCHAR(100) NULL,
    local_authority_district  NVARCHAR(100) NULL,
    local_authority_ons_code  NVARCHAR(20)  NULL,     -- ONS area code, useful for maps
    local_authority_highway   NVARCHAR(100) NULL,
    lsoa_of_collision         NVARCHAR(20)  NULL,
    urban_or_rural_area       NVARCHAR(20)  NULL,

    -- Road
    first_road_class          NVARCHAR(50)  NULL,
    first_road_number         INT           NULL,
    second_road_class         NVARCHAR(50)  NULL,
    second_road_number        INT           NULL,
    road_type                 NVARCHAR(60)  NULL,
    speed_limit               SMALLINT      NULL,     -- NULL where it was -1
    junction_detail           NVARCHAR(100) NULL,
    junction_control          NVARCHAR(100) NULL,
    pedestrian_crossing       NVARCHAR(100) NULL,

    -- Conditions
    light_conditions          NVARCHAR(100) NULL,
    weather_conditions        NVARCHAR(100) NULL,
    road_surface_conditions   NVARCHAR(100) NULL,
    special_conditions_at_site NVARCHAR(100) NULL,
    carriageway_hazards       NVARCHAR(100) NULL,

    -- Reporting
    police_attended           NVARCHAR(100) NULL,
    trunk_road_flag           NVARCHAR(60)  NULL,

    -- Constraint: one row per collision, enforced by the database
    CONSTRAINT pk_silver_collision PRIMARY KEY (collision_index)
);
GO

-- ------------------------------------------------------------------
-- Table : silver.vehicle
-- Grain : one row per vehicle in a collision
-- Key   : collision_index + vehicle_reference
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS silver.vehicle;
GO

CREATE TABLE silver.vehicle (
    collision_index             NVARCHAR(20)  NOT NULL,
    vehicle_reference           SMALLINT      NOT NULL,

    -- What kind of vehicle
    vehicle_type                NVARCHAR(60)  NULL,
    towing_and_articulation     NVARCHAR(60)  NULL,
    generic_make_model          NVARCHAR(100) NULL,

    -- What it was doing
    vehicle_manoeuvre           NVARCHAR(60)  NULL,
    junction_location           NVARCHAR(80)  NULL,
    skidding_and_overturning    NVARCHAR(60)  NULL,
    hit_object_in_carriageway   NVARCHAR(60)  NULL,
    vehicle_leaving_carriageway NVARCHAR(60)  NULL,
    hit_object_off_carriageway  NVARCHAR(60)  NULL,
    first_point_of_impact       NVARCHAR(60)  NULL,
    journey_purpose_of_driver   NVARCHAR(60)  NULL,

    -- The driver
    sex_of_driver               NVARCHAR(30)  NULL,
    age_of_driver               SMALLINT      NULL,
    age_band_of_driver          NVARCHAR(30)  NULL,
    driver_imd_decile           NVARCHAR(40)  NULL,

    -- Unreliable: 25-39% missing (D-019). Kept, but not used for conclusions.
    engine_capacity_cc          INT           NULL,
    age_of_vehicle              SMALLINT      NULL,

    escooter_flag               NVARCHAR(30)  NULL,

    CONSTRAINT pk_silver_vehicle PRIMARY KEY (collision_index, vehicle_reference)
);
GO