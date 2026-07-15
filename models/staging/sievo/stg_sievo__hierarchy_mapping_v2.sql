with source as (

    select *
    from {{ source('sievo', 'hierarchy_mapping_v2') }}

)

select

    "SourceRowId"            as source_row_id,
    "TimeId"                 as time_id,
    "ProductId"              as product_id,
    "LegalUnitId"            as legal_unit_id,
    "ExtendedLegalUnitId"    as extended_legal_unit_id,
    "OperationalUnitId"      as operational_unit_id,
    "OpUnitId"               as op_unit_id,
    "SupplierId"             as supplier_id,
    "VendorRegionId"         as vendor_region_id

from source