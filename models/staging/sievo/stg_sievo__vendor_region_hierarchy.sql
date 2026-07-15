with source as (

    select *
    from {{ source('sievo', 'vendor_region_hierarchy') }}

)

select

    "VendorRegionId"     as vendor_region_id,
    "Supplier country"   as supplier_country,
    "Supplier region"    as supplier_region

from source