with TR as (

    select
        t.posting_date,
        t.source_row_id,
        t.operational_unit_id as md_operational_unit_no_id,
        t.vendor_id as md_vendor_no_id,
        t.material_id as md_material_no_id,
        t.uom as unit,
        m.item_number
    from {{ ref('stg_sievo__transactiondata') }} t
    left join {{ ref('stg_sievo__material_master') }} m
        on t.material_id = m.material_id

),

HMAP as (

    select
        source_row_id,
        vendor_region_id,
        product_id
    from {{ ref('stg_sievo__hierarchy_mapping_v2') }}

),

OP_UNIT as (

    select
        operational_unit_id as md_operational_unit_no_id,
        operational_unit_desc as operational_unit_name
    from {{ ref('stg_sievo__operationalunit_master') }}

),

VENDOR as (

    select
        vendor_id as md_vendor_no_id,
        supplier_address,
        city as supplier_city,
        state as md_vendor_state,
        postal_code as md_vendor_postal_code,
        vendor_international_name as vendor_name
    from {{ ref('stg_sievo__vendor_master_v2') }}

),

VENDOR_REGION as (

    select
        vendor_region_id,
        supplier_country
    from {{ ref('stg_sievo__vendor_region_hierarchy') }}

),

PRODUCT as (

    select
        product_id,
        procurement_type as indirect_direct
    from {{ ref('stg_sievo__product_hierarchy') }}

),

MATERIAL as (

    select
        material_id,
        item_number,
        item_description as product_description
    from {{ ref('stg_sievo__material_master') }}

),

COUNTRY_ISO as (

    select
        country_name,
        country_iso2_code
    from {{ ref('stg_codemaster__iso_country_codes') }}

),

SEED as (

    select
        source_row_id as ct_id,
        posting_date as ouc_next_date,
        operational_unit_id as ouc,
        vendor_id as counterparty_internal_id,
        'n/a' as counterparty_name,
        'n/a' as last_pcf_request_date
    from {{ ref('stg_sievo__transactiondata') }}

),

JOINS as (

    select

        'PCF_REQUEST' as certificate_type,

        vendor.supplier_address as counterparty_supplier_address,
        vendor.supplier_city as counterparty_supplier_city,
        country_iso.country_iso2_code as counterparty_country_iso2_code,

        seed.counterparty_internal_id,
        seed.counterparty_name,

        'FALSE' as counterparty_is_customer,
        'TRUE' as counterparty_is_supplier,

        material.product_description,
        material.item_number as number,

        'FALSE' as settings_allow_sending_tests_out_of_spec,
        'IfNotFound' as settings_create_new_product,
        'NO' as settings_create_new_reference,
        'FALSE' as settings_override_product_description,
        'FALSE' as settings_submit_manually,

        'Environmental Declaration' as template_type,

        tr.unit,

        seed.ouc,
        seed.ct_id,

        dateadd(day, 30, seed.ouc_next_date) as delivery_date,

        seed.last_pcf_request_date

    from TR

    left join HMAP
        on TR.source_row_id = HMAP.source_row_id

    inner join OP_UNIT
        on TR.md_operational_unit_no_id = OP_UNIT.md_operational_unit_no_id

    inner join VENDOR
        on TR.md_vendor_no_id = VENDOR.md_vendor_no_id

    inner join VENDOR_REGION
        on HMAP.vendor_region_id = VENDOR_REGION.vendor_region_id

    inner join PRODUCT
        on HMAP.product_id = PRODUCT.product_id

    inner join MATERIAL
        on TR.item_number = MATERIAL.item_number

    inner join COUNTRY_ISO
        on VENDOR_REGION.supplier_country = COUNTRY_ISO.country_name

    inner join SEED
        on TR.source_row_id = SEED.ct_id

    where PRODUCT.indirect_direct = 'Direct'
      and seed.ouc_next_date = current_date()
      and tr.posting_date >= dateadd(year, -3, current_date())

),

FINAL as (

    select *
    from JOINS

    qualify row_number() over (
        partition by ouc, number, counterparty_internal_id, ct_id
        order by ct_id
    ) = 1

)

select *
from FINAL
where ct_id is not null