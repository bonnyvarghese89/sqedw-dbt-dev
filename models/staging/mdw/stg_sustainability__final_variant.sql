with source as (

    select *
    from {{ source('sustainability', 'final_variant') }}

)

select

    variant_id,
    product_id,
    variant_name,
    customer_segment,
    packaging_type,
    market_region,
    status,
    effective_from_date,
    effective_to_date,
    created_ts

from source