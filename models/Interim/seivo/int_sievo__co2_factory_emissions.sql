{{ 
  config(
    materialized='table',
    schema='stg',
    alias='int_sievo__vendor_item_details'
  )
}}

WITH base_tr AS (
    SELECT *
    FROM {{ ref('stg_sievo__transactiondata') }}
),

hmap AS (
    SELECT *
    FROM {{ ref('stg_sievo__hierarchy_mapping_v2') }}
),

op_unit AS (
    SELECT *
    FROM {{ ref('stg_sievo__operationalunit_master') }}
),

vendor AS (
    SELECT *
    FROM {{ ref('stg_sievo__vendor_master_v2') }}
),

vendor_region AS (
    SELECT *
    FROM {{ ref('stg_sievo__vendor_region_hierarchy') }}
),

material AS (
    SELECT *
    FROM {{ ref('stg_sievo__material_master') }}
)

SELECT DISTINCT

    /* Operational Unit */
    TRIM(LEFT(op_unit.OPERATIONAL_UNIT_DESC, 4)) AS OUC_CODE,

    TRIM(
        SUBSTR(
            op_unit.OPERATIONAL_UNIT_DESC,
            REGEXP_INSTR(op_unit.OPERATIONAL_UNIT_DESC, ' ') + 1
        )
    ) AS OPERATIONAL_UNIT_NAME,

    /* Material */
    material.ITEM_NUMBER AS ITEM_NUMBER,
    material.ITEM_DESCRIPTION AS PRODUCT_DESCRIPTION,

    /* Transaction */
    base_tr.QUANTITY AS TOTAL_QUANTITY,
    base_tr.UOM AS UNIT,

    /* Vendor */
    vendor.ERP_SUPPLIER_DESC AS COUNTERPARTY_NAME,
    vendor.SAP_VENDOR_NAME AS SAP_VENDOR_NAME,
    vendor.SAP_VENDOR_NO AS SAP_VENDOR_NO,

    'TRUE' AS COUNTERPARTY_IS_SUPPLIER,

    vendor.CITY AS COUNTERPARTY_SUPPLIER_CITY,

    /* Country mapping (optional - can be enhanced later) */
    vr.SUPPLIER_COUNTRY AS COUNTERPARTY_COUNTRY,

    NULL AS NEXT_PCF_REQUEST_DATE

FROM base_tr

LEFT JOIN hmap
    ON base_tr.SOURCE_ROW_ID = hmap.SOURCE_ROW_ID

LEFT JOIN op_unit
    ON base_tr.OPERATIONAL_UNIT_ID = op_unit.OPERATIONAL_UNIT_ID

LEFT JOIN vendor
    ON base_tr.VENDOR_ID = vendor.VENDOR_ID

LEFT JOIN vendor_region vr
    ON hmap.VENDOR_REGION_ID = vr.VENDOR_REGION_ID

LEFT JOIN material
    ON base_tr.MATERIAL_ID = material.MATERIAL_ID

WHERE base_tr.POSTING_DATE > DATEADD(YEAR, -3, CURRENT_DATE())