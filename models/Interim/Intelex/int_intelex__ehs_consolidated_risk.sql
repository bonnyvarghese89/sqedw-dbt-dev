{{
  config(
    materialized='view',
    schema='interim',
    alias='int_intelex__ehs_consolidated_risk'
  )
}}

WITH complaints AS (

    SELECT *
    FROM {{ ref('stg_intelex__complaints') }}

),

ehs AS (

    SELECT *
    FROM {{ ref('stg_intelex__ehs') }}

),

ehshs AS (

    SELECT *
    FROM {{ ref('stg_intelex__ehshs_4_bpc') }}

),

investigations AS (

    SELECT *
    FROM {{ ref('stg_intelex__investigations') }}

),

locations AS (

    SELECT *
    FROM {{ ref('stg_intelex__locations') }}

),

monthly AS (

    SELECT *
    FROM {{ ref('stg_intelex__monthly_batch_loading') }}

),

actions AS (

    SELECT *
    FROM {{ ref('stg_intelex__psp_actions_source') }}

),

capa AS (

    SELECT *
    FROM {{ ref('stg_intelex__psp_capa_r') }}

),

/* =========================
   BASE: INCIDENT + LOCATION
========================= */
incident_base AS (

    SELECT

        e.INCIDENT_NO,
        e.RECORD_NO,
        e.INCIDENT_TYPE,
        e.INCIDENT_DATE,
        e.DATE_REPORTED,
        e.DATE_CLOSED,
        e.STATUS AS INCIDENT_STATUS,
        e.DEPARTMENT,
        e.LOCATION,
        e.OPERATING_UNIT,

        l.NAME AS LOCATION_NAME,
        l.REGION,
        l.COUNTRY_ID,
        l.CITY,
        l.STATE,
        l.SKF_SITE_ID,
        l.DIVISION

    FROM ehs e

    LEFT JOIN locations l
        ON e.LOCATION = l.NAME

),

/* =========================
   COMPLAINTS ENRICHMENT
========================= */
complaint_base AS (

    SELECT

        RECORD_NO,
        COMPLAINT_CATEGORY,
        CUSTOMER,
        COUNTRY,
        STATUS AS COMPLAINT_STATUS,
        SEVERITY,
        DATE_CREATED

    FROM complaints

),

/* =========================
   INVESTIGATIONS ENRICHMENT
========================= */
investigation_base AS (

    SELECT

        RECORDNO AS RECORD_NO,
        STATUS AS INVESTIGATION_STATUS,
        SEVERITY AS INVESTIGATION_SEVERITY,
        DATECREATED

    FROM investigations

),

/* =========================
   FINAL CONSOLIDATION
========================= */
final AS (

    SELECT

        /* INCIDENT CORE */
        i.INCIDENT_NO,
        i.RECORD_NO,
        i.INCIDENT_TYPE,
        i.INCIDENT_DATE,
        i.DATE_REPORTED,
        i.DATE_CLOSED,
        i.INCIDENT_STATUS,

        /* ORGANIZATION */
        i.OPERATING_UNIT,
        i.DEPARTMENT,
        i.LOCATION,
        i.LOCATION_NAME,
        i.CITY,
        i.STATE,
        i.REGION,
        i.COUNTRY_ID,
        i.DIVISION,
        i.SKF_SITE_ID,

        /* COMPLAINT */
        c.COMPLAINT_CATEGORY,
        c.CUSTOMER,
        c.COMPLAINT_STATUS,
        c.SEVERITY AS COMPLAINT_SEVERITY,

        /* INVESTIGATION */
        inv.INVESTIGATION_STATUS,
        inv.INVESTIGATION_SEVERITY,

        /* ACTIONS (only counts to avoid duplication explosion) */
        COUNT(DISTINCT a.ACTION_NO) AS TOTAL_ACTIONS,

        /* CAPA (risk indicators) */
        MAX(
            CASE 
                WHEN cap.CRITICALITY = 'HIGH' THEN 3
                WHEN cap.CRITICALITY = 'MEDIUM' THEN 2
                WHEN cap.CRITICALITY = 'LOW' THEN 1
                ELSE 0
            END
        ) AS MAX_CAPA_RISK_SCORE,

        /* MONTHLY INCIDENT COUNT */
        COALESCE(SUM(m.NUMBER_OF_INCIDENTS), 0) AS MONTHLY_INCIDENTS,

        /* =========================
           RISK SCORING
        ========================= */

        CASE 
            WHEN i.INCIDENT_STATUS = 'OPEN' THEN 'OPEN_RISK'
            WHEN i.INCIDENT_TYPE ILIKE '%FATAL%' THEN 'CRITICAL'
            WHEN i.INCIDENT_TYPE ILIKE '%INJURY%' THEN 'HIGH'
            ELSE 'MEDIUM'
        END AS INCIDENT_RISK_LEVEL,

        CASE 
            WHEN c.SEVERITY = 'High' OR inv.INVESTIGATION_SEVERITY = 'High'
            THEN 'HIGH_EXTERNAL_RISK'
            WHEN c.SEVERITY = 'Medium'
            THEN 'MEDIUM_EXTERNAL_RISK'
            ELSE 'LOW_EXTERNAL_RISK'
        END AS COMPLAINT_RISK_LEVEL,

        CASE 
            WHEN MAX(
                CASE 
                    WHEN cap.CRITICALITY = 'HIGH' THEN 3
                    WHEN cap.CRITICALITY = 'MEDIUM' THEN 2
                    ELSE 1
                END
            ) >= 3 THEN 'HIGH_CAPA_RISK'
            ELSE 'CONTROLLED'
        END AS CAPA_RISK_LEVEL,

        CURRENT_TIMESTAMP() AS MODEL_REFRESH_TS

    FROM incident_base i

    LEFT JOIN complaint_base c
        ON i.RECORD_NO = c.RECORD_NO

    LEFT JOIN investigation_base inv
        ON i.RECORD_NO = inv.RECORD_NO

    LEFT JOIN actions a
        ON i.RECORD_NO = a.RELATED_COMPLAINT

    LEFT JOIN capa cap
        ON i.LOCATION = cap.LOCATION

    LEFT JOIN monthly m
        ON i.LOCATION = m.SITE

    GROUP BY

        i.INCIDENT_NO,
        i.RECORD_NO,
        i.INCIDENT_TYPE,
        i.INCIDENT_DATE,
        i.DATE_REPORTED,
        i.DATE_CLOSED,
        i.INCIDENT_STATUS,
        i.OPERATING_UNIT,
        i.DEPARTMENT,
        i.LOCATION,
        i.LOCATION_NAME,
        i.CITY,
        i.STATE,
        i.REGION,
        i.COUNTRY_ID,
        i.DIVISION,
        i.SKF_SITE_ID,
        c.COMPLAINT_CATEGORY,
        c.CUSTOMER,
        c.COMPLAINT_STATUS,
        c.SEVERITY,
        inv.INVESTIGATION_STATUS,
        inv.INVESTIGATION_SEVERITY

)

SELECT *
FROM final