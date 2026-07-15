with source as (

    select *
    from {{ source('codemaster', 'calendar') }}

)

select

    date_key,
    date,
    year,
    quarter,
    month,
    month_name,
    week_number,
    day_of_month,
    day_of_year,
    day_name,
    quarter_name,
    quarter_name_year,
    month_name_year,
    day_of_week_iso,
    day_of_week_us,
    week_of_year,
    packaging_date

from source