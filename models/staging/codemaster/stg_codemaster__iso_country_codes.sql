with source as (

    select *
    from {{ source('codemaster', 'iso_country_codes') }}

)

select

    change_date,
    country_full_name,
    country_iso_number,
    country_iso2_code,
    country_iso3_code,
    country_name,
    un_area_code,
    un_area_name,
    un_region_code,
    un_region_name

from source