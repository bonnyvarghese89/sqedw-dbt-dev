with source as (

    select *
    from {{ source('sustainability', 'warehouse_master') }}

)

select

    warehouse_id,
    warehouse_code,
    warehouse_name,
    site_code,
    country_name,
    city_name,
    warehouse_type,
    active_flag,
    created_ts

from source