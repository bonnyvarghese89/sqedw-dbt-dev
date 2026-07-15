{{
    config(
        materialized='table'
    )
}}

WITH dates AS (

    SELECT
        DATEADD(
            DAY,
            ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1,
            '2020-01-01'
        ) AS calendar_date
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))

)

SELECT

    TO_NUMBER(TO_CHAR(calendar_date,'YYYYMMDD')) AS date_key,

    calendar_date,

    YEAR(calendar_date) AS year,

    QUARTER(calendar_date) AS quarter,

    MONTH(calendar_date) AS month,

    MONTHNAME(calendar_date) AS month_name,

    TO_CHAR(calendar_date,'YYYY-MM') AS year_month,

    WEEK(calendar_date) AS week_number,

    DAY(calendar_date) AS day_of_month,

    DAYOFWEEK(calendar_date) AS day_of_week,

    CASE
        WHEN DAYOFWEEK(calendar_date) IN (0,6)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    LAST_DAY(calendar_date) AS month_end_date,

    DATE_TRUNC('MONTH',calendar_date) AS month_start_date

FROM dates