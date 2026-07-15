{{ 
  config(
    materialized='view',
    schema='interim',
    alias='int_bpc__consolidated_impact'
  ) 
}}

WITH site AS (

    SELECT *
    FROM {{ ref('stg_bpc__site') }}

),

entity AS (

    SELECT *
    FROM {{ ref('stg_bpc__entity') }}

),

employee AS (

    SELECT *
    FROM {{ ref('stg_bpc__employee') }}

),

energy AS (

    SELECT *
    FROM {{ ref('stg_bpc__energy') }}

),

environment AS (

    SELECT *
    FROM {{ ref('stg_bpc__environment') }}

),

safety AS (

    SELECT *
    FROM {{ ref('stg_bpc__safety') }}

),

/* =========================
   BASE LAYER
========================= */
base AS (

    SELECT

        /* ================= SITE ================= */
        s.SITE_ID,
        s.SITE_DESCRIPTION,
        s.IS_ACTIVE AS SITE_ACTIVE,
        s.BUSINESS_AREA,
        s.BUSINESS_UNIT,
        s.COUNTRY,
        s.STATE,
        s.CITY,
        s.CURRENCY_CODE,
        s.SITE_TYPE,

        /* ================= ENTITY ================= */
        e.ENTITY_ID,
        e.ENTITY_DESCRIPTION,
        e.ENTITY,
        e.COUNTRY AS ENTITY_COUNTRY,
        e.CURRENCY_CODE AS ENTITY_CURRENCY,
        e.ENTITY_TYPE,
        e.ENTITY_LEVEL,
        e.GEO_AREA_CODE,

        /* ================= EMPLOYEE ================= */
        emp.PERIOD_DATE AS EMP_PERIOD_DATE,
        emp.NUMBER_OF_EMPLOYEES,
        emp.NUMBER_OF_AGENCY_PEOPLE,
        emp.NUMBER_OF_HOURS,

        /* ================= ENERGY ================= */
        en.PERIOD_DATE AS ENERGY_PERIOD_DATE,
        en.ACCOUNT_ID AS ENERGY_ACCOUNT_ID,
        en.CATEGORY AS ENERGY_CATEGORY,
        en.ENERGY_KWH,

        /* ================= ENVIRONMENT ================= */
        env.PERIOD_DATE AS ENV_PERIOD_DATE,
        env.ACCOUNT_ID AS ENV_ACCOUNT_ID,
        env.CATEGORY AS ENV_CATEGORY,
        env.AMOUNT AS ENV_AMOUNT,
        env.UOM AS ENV_UOM,

        /* ================= SAFETY ================= */
        saf.PERIOD_DATE AS SAFETY_PERIOD_DATE,
        saf.ACCOUNT_ID AS SAFETY_ACCOUNT_ID,
        saf.NO_OF_INCIDENTS,

        /* ================= DERIVED METRICS ================= */

        COALESCE(emp.NUMBER_OF_EMPLOYEES, 0) AS TOTAL_EMPLOYEES,

        COALESCE(en.ENERGY_KWH, 0) AS ENERGY_CONSUMPTION,

        COALESCE(env.AMOUNT, 0) AS ENV_IMPACT_AMOUNT,

        COALESCE(saf.NO_OF_INCIDENTS, 0) AS INCIDENT_COUNT,

        CASE 
            WHEN COALESCE(saf.NO_OF_INCIDENTS, 0) > 0 THEN 'HIGH_RISK'
            ELSE 'LOW_RISK'
        END AS SAFETY_RISK_FLAG,

        CASE 
            WHEN COALESCE(en.ENERGY_KWH, 0) > 100000 THEN 'HIGH_ENERGY'
            WHEN COALESCE(en.ENERGY_KWH, 0) BETWEEN 50000 AND 100000 THEN 'MEDIUM_ENERGY'
            ELSE 'LOW_ENERGY'
        END AS ENERGY_RISK_FLAG,

        CASE 
            WHEN COALESCE(env.AMOUNT, 0) > 10000 THEN 'HIGH_ENV_IMPACT'
            ELSE 'CONTROLLED'
        END AS ENVIRONMENT_RISK_FLAG,

        CURRENT_TIMESTAMP() AS MODEL_REFRESH_TS

    FROM site s

    LEFT JOIN entity e
        ON s.SITE_ID = e.SITE_ID

    LEFT JOIN employee emp
        ON e.ENTITY_ID = emp.ENTITY_ID

    LEFT JOIN energy en
        ON s.SITE_ID = en.SITE_ID

    LEFT JOIN environment env
        ON s.SITE_ID = env.SITE_ID

    LEFT JOIN safety saf
        ON e.ENTITY_ID = saf.ENTITY_ID

)

SELECT *
FROM base