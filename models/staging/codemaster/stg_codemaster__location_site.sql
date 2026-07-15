with source as (

    select *
    from {{ source('codemaster', 'location_site') }}

)

select

    change_date,
    legal_unit_code,
    legal_unit_name,
    operating_unit_code,
    operating_unit_name,
    location_site_id,
    location_site_name,
    street_address,
    zip_code,
    city_name,
    country_name,
    country_code_iso2,
    country_code_iso3,
    country_iso_number,
    time_zone_name,
    coordinates,
    longitude,
    latitude

from source