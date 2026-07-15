with source as (

    select *
    from {{ source('sustainability', 'vendor_details') }}

)

select

    vendor_id,
    vendor_name,
    country_name,
    city_name,
    contact_email,
    vendor_category,
    sustainability_rating,
    active_flag,
    created_ts

from source