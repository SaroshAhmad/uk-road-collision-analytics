/*
==========================================================================
Script		: ddl_bronze.sql
Project		: UK Road Collision Risk Analytics
Author		: Ahmad Sarosh
Purpose		: Creates the bronze (raw) tables.
			  Column names and order match the DfT CSV headers EXACTLY,
			  because BULK INSERT loads columns by position (D-009).
			  All columns are text so the laod never fails or 
			  silently changes a value (D-010, D-013).
WARNING		: Drops and recreates the table. Any data in them is lost.
===========================================================================
*/

USE RoadSafetyDW;
GO

-- ------------------------------------------------------------------
-- Table   : bronze.dft_collision
-- Source  : dft-road-casualty-statistics-collision-last-5-years.csv
-- Grain   : one row per collision
-- Columns : 44
-- ------------------------------------------------------------------

-- Drop the table if it already exists so this script can be re-run
DROP TABLE IF EXISTS bronze.dft_collision;
GO

CREATE TABLE bronze.dft_collision (
    -- Identifiers
    collision_index                                   NVARCHAR(50),  -- unique ID, joins to vehicle and casualty
    collision_year                                    NVARCHAR(50),
    collision_ref_no                                  NVARCHAR(50),  -- text: can have leading zeros

    -- Location
    location_easting_osgr                             NVARCHAR(50),
    location_northing_osgr                            NVARCHAR(50),
    longitude                                         NVARCHAR(50),
    latitude                                          NVARCHAR(50),
    police_force                                      NVARCHAR(50),

    -- Severity and scale
    collision_severity                                NVARCHAR(50),  -- 1 Fatal, 2 Serious, 3 Slight
    number_of_vehicles                                NVARCHAR(50),
    number_of_casualties                              NVARCHAR(50),

    -- When
    date                                              NVARCHAR(50),  -- dd/mm/yyyy, converted in silver
    day_of_week                                       NVARCHAR(50),
    time                                              NVARCHAR(50),

    -- Local authority
    local_authority_district                          NVARCHAR(50),
    local_authority_ons_district                      NVARCHAR(50),
    local_authority_highway                           NVARCHAR(50),
    local_authority_highway_current                   NVARCHAR(50),

    -- Road details
    first_road_class                                  NVARCHAR(50),
    first_road_number                                 NVARCHAR(50),
    road_type                                         NVARCHAR(50),
    speed_limit                                       NVARCHAR(50),
    junction_detail_historic                          NVARCHAR(50),  -- old (pre-2024) codes
    junction_detail                                   NVARCHAR(50),
    junction_control                                  NVARCHAR(50),
    second_road_class                                 NVARCHAR(50),
    second_road_number                                NVARCHAR(50),
    pedestrian_crossing_human_control_historic        NVARCHAR(50),  -- old codes
    pedestrian_crossing_physical_facilities_historic  NVARCHAR(50),  -- old codes
    pedestrian_crossing                               NVARCHAR(50),

    -- Conditions
    light_conditions                                  NVARCHAR(50),
    weather_conditions                                NVARCHAR(50),
    road_surface_conditions                           NVARCHAR(50),
    special_conditions_at_site                        NVARCHAR(50),
    carriageway_hazards_historic                      NVARCHAR(50),  -- old codes
    carriageway_hazards                               NVARCHAR(50),
    urban_or_rural_area                               NVARCHAR(50),

    -- Reporting and area
    did_police_officer_attend_scene_of_accident       NVARCHAR(50),
    trunk_road_flag                                   NVARCHAR(50),
    lsoa_of_accident_location                         NVARCHAR(50),

    -- Severity reporting method and adjustments
    enhanced_severity_collision                       NVARCHAR(50),
    collision_injury_based                            NVARCHAR(50),
    collision_adjusted_severity_serious               NVARCHAR(50),
    collision_adjusted_severity_slight                NVARCHAR(50)
);
GO

-- ------------------------------------------------------------------
-- Table   : bronze.dft_vehicle
-- Source  : dft-road-casualty-statistics-vehicle-last-5-years.csv
-- Grain   : one row per vehicle per collision
-- Key     : collision_index + vehicle_reference
-- Columns : 32
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS bronze.dft_vehicle;
GO

CREATE TABLE bronze.dft_vehicle (
    -- Identifiers
    collision_index                            NVARCHAR(50),  -- joins to dft_collision
    collision_year                             NVARCHAR(50),
    collision_ref_no                           NVARCHAR(50),
    vehicle_reference                          NVARCHAR(50),  -- 1, 2, 3... within a collision

    -- Vehicle and movement
    vehicle_type                               NVARCHAR(50),
    towing_and_articulation                    NVARCHAR(50),
    vehicle_manoeuvre_historic                 NVARCHAR(50),  -- old (pre-2024) codes
    vehicle_manoeuvre                          NVARCHAR(50),
    vehicle_direction_from                     NVARCHAR(50),
    vehicle_direction_to                       NVARCHAR(50),
    vehicle_location_restricted_lane_historic  NVARCHAR(50),  -- old codes
    vehicle_location_restricted_lane           NVARCHAR(50),
    junction_location                          NVARCHAR(50),

    -- What happened
    skidding_and_overturning                   NVARCHAR(50),
    hit_object_in_carriageway                  NVARCHAR(50),
    vehicle_leaving_carriageway                NVARCHAR(50),
    hit_object_off_carriageway                 NVARCHAR(50),
    first_point_of_impact                      NVARCHAR(50),
    vehicle_left_hand_drive                    NVARCHAR(50),

    -- Journey and driver
    journey_purpose_of_driver_historic         NVARCHAR(50),  -- old codes
    journey_purpose_of_driver                  NVARCHAR(50),
    sex_of_driver                              NVARCHAR(50),
    age_of_driver                              NVARCHAR(50),  -- -1 = missing, handled in silver
    age_band_of_driver                         NVARCHAR(50),

    -- Vehicle details
    engine_capacity_cc                         NVARCHAR(50),
    propulsion_code                            NVARCHAR(50),
    age_of_vehicle                             NVARCHAR(50),
    generic_make_model                         NVARCHAR(100), -- free text, may be long (D-013)

    -- Driver area and other
    driver_imd_decile                          NVARCHAR(50),
    lsoa_of_driver                             NVARCHAR(50),
    escooter_flag                              NVARCHAR(50),
    driver_distance_banding                    NVARCHAR(50)
);
GO

-- ------------------------------------------------------------------
-- Table   : bronze.dft_casualty
-- Source  : dft-road-casualty-statistics-casualty-last-5-years.csv
-- Grain   : one row per casualty per collision
-- Key     : collision_index + casualty_reference
-- Columns : 23
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS bronze.dft_casualty;
GO

CREATE TABLE bronze.dft_casualty (
    -- Identifiers
    collision_index                      NVARCHAR(50),  -- joins to dft_collision
    collision_year                       NVARCHAR(50),
    collision_ref_no                     NVARCHAR(50),  -- text: can have leading zeros
    vehicle_reference                    NVARCHAR(50),  -- links casualty to a vehicle
    casualty_reference                   NVARCHAR(50),  -- 1, 2, 3... within a collision

    -- Who
    casualty_class                       NVARCHAR(50),  -- driver, passenger or pedestrian
    sex_of_casualty                      NVARCHAR(50),
    age_of_casualty                      NVARCHAR(50),
    age_band_of_casualty                 NVARCHAR(50),
    casualty_severity                    NVARCHAR(50),  -- 1 Fatal, 2 Serious, 3 Slight

    -- Pedestrian and passenger details
    pedestrian_location                  NVARCHAR(50),
    pedestrian_movement                  NVARCHAR(50),
    car_passenger                        NVARCHAR(50),
    bus_or_coach_passenger               NVARCHAR(50),
    pedestrian_road_maintenance_worker   NVARCHAR(50),
    casualty_type                        NVARCHAR(50),

    -- Area
    casualty_imd_decile                  NVARCHAR(50),
    lsoa_of_casualty                     NVARCHAR(50),

    -- Severity reporting method and adjustments
    enhanced_casualty_severity           NVARCHAR(50),
    casualty_injury_based                NVARCHAR(50),
    casualty_adjusted_severity_serious   NVARCHAR(50),
    casualty_adjusted_severity_slight    NVARCHAR(50),

    -- Other
    casualty_distance_banding            NVARCHAR(50)
);
GO

-- ------------------------------------------------------------------
-- Table   : bronze.dft_code_list
-- Source  : 2024_code_list sheet of the DfT data guide (exported to CSV)
-- Grain   : one row per code, per field, per table
-- Purpose : Translates codes into labels (e.g. severity 2 = 'Serious')
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS bronze.dft_code_list;
GO

CREATE TABLE bronze.dft_code_list (
    table_name  NVARCHAR(50),   -- collision, vehicle or casualty
    field_name  NVARCHAR(100),  -- the column the code belongs to
    code        NVARCHAR(50),   -- the stored value
    label       NVARCHAR(200),  -- what it means in words
    note        NVARCHAR(500)   -- extra explanation, often blank
);
GO