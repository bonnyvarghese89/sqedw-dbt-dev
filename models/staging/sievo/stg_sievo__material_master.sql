with source as (

    select *
    from {{ source('sievo', 'material_master') }}

)

select

    "MD_MaterialNoId"       as material_id,
    "Item description"      as item_description,
    "Item number"           as item_number,
    "Standard cost"         as standard_cost,
    "Item UOM"              as item_uom,
    "Item weight"           as item_weight,
    "Item size"             as item_size,
    "Item outer diameter"   as item_outer_diameter,
    "Item width"            as item_width,
    "PU1ADesc"              as pu1a_desc,
    "CommodityCodeMM"       as commodity_code_mm,
    "WeightUOM"             as weight_uom

from source