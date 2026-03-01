{{ config(materialized='table') }}

WITH L0 AS (SELECT 1 AS c UNION ALL SELECT 1),                    -- 2 linhas
L1 AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),           -- 4 linhas
L2 AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),           -- 16 linhas
L3 AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),           -- 256 linhas
L4 AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),           -- 65.536 linhas (suficiente para ~180 anos)
Numbers AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM L4),
DataGerada AS (
    SELECT 
        DATEADD(DAY, n - 1, '2000-01-01') AS date_day
    FROM Numbers
    WHERE n <= DATEDIFF(DAY, '2000-01-01', '2031-01-01')
)

SELECT
    CAST(FORMAT(date_day, 'yyyyMMdd') AS INT) AS date_key,
    date_day AS full_date,
    DAY(date_day) AS day_number,
    DATENAME(WEEKDAY, date_day) AS day_name,
    DATEPART(WEEK, date_day) AS week_number,
    MONTH(date_day) AS month_number,
    DATENAME(MONTH, date_day) AS month_name,
    DATEPART(QUARTER, date_day) AS quarter_number,
    YEAR(date_day) AS year_number,
    CASE 
        WHEN DATEPART(WEEKDAY, date_day) IN (1, 7) THEN 1 
        ELSE 0 
    END AS is_weekend,
    CASE 
        WHEN (YEAR(date_day) % 4 = 0 AND YEAR(date_day) % 100 <> 0)
            OR (YEAR(date_day) % 400 = 0)
        then 1 
        else 0 
    END AS is_leap_year
FROM DataGerada