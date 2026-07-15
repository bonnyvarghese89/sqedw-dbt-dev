{{
    config(
        materialized='table'
    )
}}

with product_master as (

    select distinct

        MATERIAL_ID,
        ITEM_NUMBER,
        ITEM_DESCRIPTION,
        STANDARD_COST,
        ITEM_UOM,
        ITEM_WEIGHT,
        ITEM_SIZE,
        ITEM_OUTER_DIAMETER,
        ITEM_WIDTH,
        PU1A_DESC,
        COMMODITY_CODE_MM,
        WEIGHT_UOM

    from {{ ref('stg_sievo__material_master') }}

),

product_usage as (

    select
        ITEM_NUMBER,
        count(*) as procurement_record_count,
        sum(coalesce(TOTAL_QUANTITY,0)) as total_procured_quantity

    from {{ ref('int_sievo__co2_factory_emissions') }}

    where ITEM_NUMBER is not null

    group by ITEM_NUMBER

),

final as (

    select

        {{ dbt_utils.generate_surrogate_key([
            'pm.ITEM_NUMBER'
        ]) }} as product_key,

        pm.MATERIAL_ID,
        pm.ITEM_NUMBER,
        pm.ITEM_DESCRIPTION,

        pm.COMMODITY_CODE_MM,
        pm.PU1A_DESC,

        pm.ITEM_UOM,
        pm.WEIGHT_UOM,

        pm.ITEM_WEIGHT,
        pm.ITEM_SIZE,
        pm.ITEM_OUTER_DIAMETER,
        pm.ITEM_WIDTH,

        pm.STANDARD_COST,

        case
            when pu.ITEM_NUMBER is not null then 'Y'
            else 'N'
        end as has_procurement_activity,

        coalesce(pu.procurement_record_count,0)
            as procurement_record_count,

        coalesce(pu.total_procured_quantity,0)
            as total_procured_quantity,

        current_timestamp() as created_ts

    from product_master pm

    left join product_usage pu
        on pm.ITEM_NUMBER = pu.ITEM_NUMBER

)

select *
from final