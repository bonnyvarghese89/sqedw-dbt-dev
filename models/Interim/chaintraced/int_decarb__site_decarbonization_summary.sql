{{
  config(
    materialized='table',
    schema='interim',
    alias='int_decarb__site_decarbonization_summary'
  )
}}

WITH targets AS (

    SELECT *
    FROM {{ ref('stg_decarb__master_data_targets') }}

),

site_data AS (

    SELECT *
    FROM {{ ref('stg_decarb__site_data') }}

),

rollup AS (

    SELECT *
    FROM {{ ref('stg_decarb__site_rollup') }}

),

/* =========================
   SITE DIMENSION BASE
========================= */
site_base AS (

    SELECT

        SITE_CODE,
        SITE_NAME,
        COUNTRY_NAME,
        BUSINESS_AREA_LONG_NAME,
        BUSINESS_UNIT_NAME,
        BUSINESS_AREA_SHORT_NAME,
        SKF_REGION_NAME,
        PARENT_NAME,
        DIVISION_NAME,
        PRIMARY_EMAIL,
        SECONDARY_EMAIL,
        BACKUP_EMAIL,
        REMAIN_NEWCO,
        DECARBONIZED_SITE

    FROM rollup

),

/* =========================
   TARGETS (DECARB GOALS)
========================= */
target_base AS (

    SELECT

        SITE_CODE,
        COUNTRY,
        DECARB_SCOPE,
        DECARB_SITE_TARGET_T_CO2E,
        DECARBONIZED_SITES_TARGET_YEAR,
        ROADMAP_MATURITY_SCOPE_BASED_ON_COMPLETENESS_EVALUATION

    FROM targets

),

/* =========================
   SITE ACTUAL EMISSIONS / DATA
========================= */
site_metrics AS (

    SELECT

        SITE AS SITE_CODE,
        YEAR,
        ASPECT,
        UNIT_OF_MEASUREMENT,
        VALUE,
        INTEGER_VALUE,
        DECIMAL_VALUE,
        IS_CALCULATED

    FROM site_data

),

/* =========================
   FINAL CONSOLIDATION
========================= */
final AS (

    SELECT

        /* ================= SITE INFO ================= */
        s.SITE_CODE,
        s.SITE_NAME,
        s.COUNTRY_NAME,
        s.BUSINESS_AREA_LONG_NAME,
        s.BUSINESS_UNIT_NAME,
        s.SKF_REGION_NAME,
        s.DIVISION_NAME,
        s.DECARBONIZED_SITE,

        /* ================= TARGET INFO ================= */
        t.DECARB_SCOPE,
        t.DECARB_SITE_TARGET_T_CO2E,
        t.DECARBONIZED_SITES_TARGET_YEAR,
        t.ROADMAP_MATURITY_SCOPE_BASED_ON_COMPLETENESS_EVALUATION,

        /* ================= METRICS ================= */
        m.YEAR,
        m.ASPECT,
        m.UNIT_OF_MEASUREMENT,

        COALESCE(m.VALUE, 0) AS ACTUAL_VALUE,
        COALESCE(m.DECIMAL_VALUE, 0) AS DECIMAL_VALUE,
        COALESCE(m.INTEGER_VALUE, 0) AS INTEGER_VALUE,

        /* ================= KPI CALCULATIONS ================= */

        CASE 
            WHEN m.ASPECT ILIKE '%CO2%' THEN 'EMISSIONS'
            WHEN m.ASPECT ILIKE '%ENERGY%' THEN 'ENERGY'
            WHEN m.ASPECT ILIKE '%WATER%' THEN 'WATER'
            ELSE 'OTHER'
        END AS KPI_CATEGORY,

        CASE 
            WHEN t.DECARB_SITE_TARGET_T_CO2E IS NULL THEN 'NO_TARGET'
            WHEN COALESCE(m.VALUE, 0) <= t.DECARB_SITE_TARGET_T_CO2E THEN 'ON_TRACK'
            ELSE 'BEHIND_TARGET'
        END AS TARGET_STATUS,

        CASE 
            WHEN t.DECARB_SITE_TARGET_T_CO2E > 0
            THEN ROUND((COALESCE(m.VALUE, 0) / t.DECARB_SITE_TARGET_T_CO2E) * 100, 2)
            ELSE NULL
        END AS PROGRESS_PCT,

        CURRENT_TIMESTAMP() AS MODEL_REFRESH_TS

    FROM site_base s

    LEFT JOIN target_base t
        ON s.SITE_CODE = t.SITE_CODE

    LEFT JOIN site_metrics m
        ON s.SITE_CODE = m.SITE_CODE
)

SELECT *
FROM final