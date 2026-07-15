{{
    config(
        materialized='table'
    )
}}

with operational_unit_master as (

    select distinct

        OPERATIONAL_UNIT_ID,
        OPERATIONAL_UNIT_DESC,
        REPORTING_CURRENCY,
        BUSINESS_LINE_DIRECTOR,
        BUSINESS_LINE_MANAGER

    from {{ ref('stg_sievo__operationalunit_master') }}

),

procurement_activity as (

    select

        OUC_CODE,
        OPERATIONAL_UNIT_NAME,

        count(*) as transaction_count,

        count(distinct SAP_VENDOR_NO) as supplier_count,

        count(distinct ITEM_NUMBER) as product_count,

        sum(coalesce(TOTAL_QUANTITY,0)) as total_quantity

    from {{ ref('int_sievo__co2_factory_emissions') }}

    group by 1,2

),

site_mapping as (

    select distinct

        SITE_ID,
        SITE_DESCRIPTION,
        BUSINESS_AREA,
        BUSINESS_UNIT,
        COUNTRY,
        STATE,
        CITY,
        CURRENCY_CODE,
        SITE_TYPE

    from {{ ref('stg_bpc__site') }}

),

decarb_mapping as (

    select distinct

        SITE_CODE,
        COUNTRY_NAME,
        BUSINESS_AREA_LONG_NAME,
        BUSINESS_UNIT_NAME,
        SKF_REGION_NAME,
        DIVISION_NAME

    from {{ ref('stg_decarb__site_rollup') }}

)

select

    {{ dbt_utils.generate_surrogate_key([
        'pa.OUC_CODE'
    ]) }} as operational_unit_key,

    pa.OUC_CODE,
    pa.OPERATIONAL_UNIT_NAME,

    ou.OPERATIONAL_UNIT_ID,

    ou.REPORTING_CURRENCY,

    ou.BUSINESS_LINE_DIRECTOR,
    ou.BUSINESS_LINE_MANAGER,

    sm.SITE_ID,
    sm.SITE_DESCRIPTION,

    sm.BUSINESS_AREA,
    sm.BUSINESS_UNIT,

    sm.COUNTRY,
    sm.STATE,
    sm.CITY,

    sm.CURRENCY_CODE,

    sm.SITE_TYPE,

    dm.SKF_REGION_NAME,
    dm.DIVISION_NAME,

    pa.transaction_count,
    pa.supplier_count,
    pa.product_count,
    pa.total_quantity,

    current_timestamp() as created_ts

from procurement_activity pa

left join operational_unit_master ou
    on pa.OUC_CODE = left(ou.OPERATIONAL_UNIT_DESC,4)

left join site_mapping sm
    on pa.OUC_CODE = sm.SITE_ID

left join decarb_mapping dm
    on sm.SITE_ID = dm.SITE_CODE