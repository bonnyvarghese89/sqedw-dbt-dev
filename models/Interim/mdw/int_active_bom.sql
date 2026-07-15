{{ config(materialized='view') }}

WITH BOM AS (

    SELECT
        PRODUCT_ID,
        PRODUCT_DESCRIPTION,
        COMPONENT_ID,
        COMPONENT_DESCRIPTION,
        COMPONENT_QUANTITY,
        UOM,
        EFFECTIVE_FROM_DATE,
        EFFECTIVE_TO_DATE,
        ACTIVE_FLAG,
        CREATED_TS
    FROM {{ ref('stg_sustainability__product_structure') }}

),

VARIANT AS (

    SELECT
        VARIANT_ID,
        PRODUCT_ID,
        VARIANT_NAME,
        CUSTOMER_SEGMENT,
        PACKAGING_TYPE,
        MARKET_REGION,
        STATUS
    FROM {{ ref('stg_sustainability__final_variant') }}

),

VENDOR AS (

    SELECT
        VENDOR_ID,
        VENDOR_NAME,
        COUNTRY_NAME,
        CITY_NAME,
        SUSTAINABILITY_RATING,
        ACTIVE_FLAG
    FROM {{ ref('stg_sustainability__vendor_details') }}

),

WAREHOUSE AS (

    SELECT
        WAREHOUSE_ID,
        WAREHOUSE_CODE,
        SITE_CODE,
        COUNTRY_NAME,
        ACTIVE_FLAG
    FROM {{ ref('stg_sustainability__warehouse_master') }}

),

ENRICHED AS (

    SELECT

        /* =========================
           CORE KEYS
        ========================= */
        B.PRODUCT_ID,
        B.COMPONENT_ID,

        /* =========================
           BUSINESS ATTRIBUTES
        ========================= */
        B.PRODUCT_DESCRIPTION,
        B.COMPONENT_DESCRIPTION,
        B.COMPONENT_QUANTITY,
        B.UOM,

        V.VARIANT_ID,
        V.VARIANT_NAME,
        V.CUSTOMER_SEGMENT,
        V.MARKET_REGION,

        VD.VENDOR_ID,
        VD.VENDOR_NAME,
        VD.SUSTAINABILITY_RATING,

        WH.WAREHOUSE_ID,
        WH.SITE_CODE,

        /* =========================
           COMPLEX BUSINESS CHECKS
        ========================= */

        /* 1. Quantity validation */
        CASE
            WHEN B.COMPONENT_QUANTITY IS NULL THEN 'MISSING_QTY'
            WHEN B.COMPONENT_QUANTITY <= 0 THEN 'INVALID_QTY'
            WHEN B.COMPONENT_QUANTITY > 100000 THEN 'OUTLIER_QTY'
            ELSE 'OK'
        END AS QTY_STATUS,

        /* 2. Lifecycle validity check */
        CASE
            WHEN B.EFFECTIVE_FROM_DATE IS NULL THEN 'NO_START_DATE'
            WHEN B.EFFECTIVE_TO_DATE IS NOT NULL
                 AND B.EFFECTIVE_TO_DATE < B.EFFECTIVE_FROM_DATE
                THEN 'INVALID_DATE_RANGE'
            WHEN B.EFFECTIVE_TO_DATE < CURRENT_DATE() THEN 'EXPIRED'
            ELSE 'ACTIVE'
        END AS LIFECYCLE_STATUS,

        /* 3. Product-component integrity */
        CASE
            WHEN B.PRODUCT_ID = B.COMPONENT_ID THEN 'SELF_REFERENCE_ERROR'
            WHEN B.COMPONENT_ID IS NULL THEN 'MISSING_COMPONENT'
            ELSE 'OK'
        END AS STRUCTURE_STATUS,

        /* 4. Variant alignment check */
        CASE
            WHEN V.PRODUCT_ID IS NULL THEN 'NO_VARIANT_MAPPING'
            WHEN V.STATUS != 'ACTIVE' THEN 'INACTIVE_VARIANT'
            ELSE 'OK'
        END AS VARIANT_STATUS_FLAG,

        /* 5. Sustainability risk scoring */
        CASE
            WHEN VD.SUSTAINABILITY_RATING IN ('A','B') THEN 'LOW_RISK'
            WHEN VD.SUSTAINABILITY_RATING IN ('C') THEN 'MEDIUM_RISK'
            WHEN VD.SUSTAINABILITY_RATING IN ('D','E') THEN 'HIGH_RISK'
            ELSE 'UNKNOWN_RISK'
        END AS SUPPLIER_RISK_LEVEL,

        /* 6. Warehouse validation */
        CASE
            WHEN WH.ACTIVE_FLAG = FALSE THEN 'INACTIVE_WAREHOUSE'
            WHEN WH.WAREHOUSE_ID IS NULL THEN 'MISSING_WAREHOUSE'
            ELSE 'OK'
        END AS WAREHOUSE_STATUS,

        /* =========================
           FINAL QUALITY SCORE
        ========================= */
        CASE
            WHEN
                (B.COMPONENT_QUANTITY > 0)
                AND B.PRODUCT_ID <> B.COMPONENT_ID
                AND B.ACTIVE_FLAG = TRUE
                AND V.STATUS = 'ACTIVE'
            THEN 'GOOD'
            ELSE 'BAD'
        END AS RECORD_QUALITY

    FROM BOM B

    LEFT JOIN VARIANT V
        ON B.PRODUCT_ID = V.PRODUCT_ID

    LEFT JOIN VENDOR VD
        ON VD.ACTIVE_FLAG = TRUE

    LEFT JOIN WAREHOUSE WH
        ON WH.ACTIVE_FLAG = TRUE
)

SELECT *

FROM ENRICHED

WHERE
    RECORD_QUALITY = 'GOOD'
    AND LIFECYCLE_STATUS != 'EXPIRED'