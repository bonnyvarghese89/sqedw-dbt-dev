{{
    config(
        materialized='incremental',
        unique_key='FACT_FACTORY_EMISSIONS_KEY',
        on_schema_change='sync_all_columns'
    )
}}

SELECT

    MD5(
        COALESCE(SITE_ID,'') || '-' ||
        COALESCE(ENTITY_ID,'') || '-' ||
        COALESCE(TO_VARCHAR(COALESCE(EMP_PERIOD_DATE,
                                     ENERGY_PERIOD_DATE,
                                     ENV_PERIOD_DATE,
                                     SAFETY_PERIOD_DATE)),'')
    ) AS FACT_FACTORY_EMISSIONS_KEY,

    /* Site */
    SITE_ID,
    SITE_DESCRIPTION,
    BUSINESS_AREA,
    BUSINESS_UNIT,
    COUNTRY,
    STATE,
    CITY,
    SITE_TYPE,

    /* Entity */
    ENTITY_ID,
    ENTITY_DESCRIPTION,
    ENTITY_TYPE,
    ENTITY_LEVEL,
    GEO_AREA_CODE,

    /* Reporting Date */
    COALESCE(
        EMP_PERIOD_DATE,
        ENERGY_PERIOD_DATE,
        ENV_PERIOD_DATE,
        SAFETY_PERIOD_DATE
    ) AS REPORT_DATE,

    /* KPI Metrics */
    TOTAL_EMPLOYEES,
    NUMBER_OF_AGENCY_PEOPLE,
    NUMBER_OF_HOURS,

    ENERGY_CONSUMPTION,

    ENV_IMPACT_AMOUNT,
    ENV_UOM,

    INCIDENT_COUNT,

    /* Derived KPIs */

    CASE
        WHEN TOTAL_EMPLOYEES > 0
        THEN ROUND(
            ENERGY_CONSUMPTION / TOTAL_EMPLOYEES,
            2
        )
        ELSE 0
    END AS ENERGY_PER_EMPLOYEE,

    CASE
        WHEN TOTAL_EMPLOYEES > 0
        THEN ROUND(
            INCIDENT_COUNT * 1000 / TOTAL_EMPLOYEES,
            2
        )
        ELSE 0
    END AS INCIDENT_RATE_PER_1000_EMPLOYEES,

    CASE
        WHEN ENERGY_CONSUMPTION > 100000
        THEN 'HIGH'
        WHEN ENERGY_CONSUMPTION > 50000
        THEN 'MEDIUM'
        ELSE 'LOW'
    END AS ENERGY_RISK_LEVEL,

    CASE
        WHEN INCIDENT_COUNT > 10
        THEN 'HIGH'
        WHEN INCIDENT_COUNT > 0
        THEN 'MEDIUM'
        ELSE 'LOW'
    END AS SAFETY_RISK_LEVEL,

    CURRENT_TIMESTAMP() AS LOAD_TS

FROM {{ ref('int_bpc__consolidated_impact') }}

{% if is_incremental() %}
WHERE COALESCE(
        EMP_PERIOD_DATE,
        ENERGY_PERIOD_DATE,
        ENV_PERIOD_DATE,
        SAFETY_PERIOD_DATE
      ) >= (
            SELECT COALESCE(MAX(REPORT_DATE),'1900-01-01')
            FROM {{ this }}
      )
{% endif %}