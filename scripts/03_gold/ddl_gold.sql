/*
=====================================================================
Script      : ddl_gold.sql
Project     : UK Road Collision Risk Analytics
Author      : Ahmad Sarosh
Purpose     : Creates the gold layer: a date dimension table plus
              the fact views used by Power BI.
=====================================================================
*/

USE RoadSafetyDW;
GO

-- ------------------------------------------------------------------
-- Table : gold.dim_date
-- Grain : one row per calendar day (2021-01-01 to 2025-12-31)
-- Note  : Generated, not derived from silver.
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS gold.dim_date;
GO

CREATE TABLE gold.dim_date (
    date_key        DATE         NOT NULL PRIMARY KEY,
    year_number     SMALLINT     NOT NULL,
    quarter_number  TINYINT      NOT NULL,
    quarter_name    NVARCHAR(10) NOT NULL,   -- 'Q1'
    month_number    TINYINT      NOT NULL,   -- 1-12, for correct sorting
    month_name      NVARCHAR(20) NOT NULL,   -- 'January'
    month_year      NVARCHAR(20) NOT NULL,   -- 'Jan 2021'
    day_of_month    TINYINT      NOT NULL,
    day_name        NVARCHAR(20) NOT NULL,   -- 'Monday'
    day_number      TINYINT      NOT NULL,   -- 1 = Monday ... 7 = Sunday
    is_weekend      BIT          NOT NULL    -- 1 = Saturday or Sunday
);
GO

-- Fill it, one row per day across the five years
WITH date_series AS (
    SELECT CAST('2021-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM date_series
    WHERE d < '2025-12-31'
)
INSERT INTO gold.dim_date (
    date_key, year_number, quarter_number, quarter_name,
    month_number, month_name, month_year,
    day_of_month, day_name, day_number, is_weekend
)
SELECT
    d,
    YEAR(d),
    DATEPART(QUARTER, d),
    'Q' + CAST(DATEPART(QUARTER, d) AS NVARCHAR(1)),
    MONTH(d),
    DATENAME(MONTH, d),
    LEFT(DATENAME(MONTH, d), 3) + ' ' + CAST(YEAR(d) AS NVARCHAR(4)),
    DAY(d),
    DATENAME(WEEKDAY, d),
    CASE DATENAME(WEEKDAY, d)
        WHEN 'Monday' THEN 1 WHEN 'Tuesday'  THEN 2 WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday'  THEN 6
        ELSE 7 END,
    CASE WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 1 ELSE 0 END
FROM date_series
OPTION (MAXRECURSION 0);   -- allow more than the default 100 loops
GO