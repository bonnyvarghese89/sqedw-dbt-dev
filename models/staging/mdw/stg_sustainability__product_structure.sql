with source as (

    select *
    from {{ source('sustainability', 'product_structure') }}

)

select

    product_id,
    product_description,
    component_id,
    component_description,
    component_quantity,
    uom,
    effective_from_date,
    effective_to_date,
    active_flag,
    created_ts

from source