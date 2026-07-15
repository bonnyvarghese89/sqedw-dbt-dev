{{
    config(
        materialized='incremental',
        unique_key='FACT_SAFETY_KEY',
        on_schema_change='sync_all_columns'
    )
}}

WITH safety AS (

    SELECT *
    FROM {{ ref('stg_bpc__safety') }}

),

entity AS (

    SELECT *
    FROM {{ ref('dim_entity') }}

),

site AS (

    SELECT *
    FROM {{ ref('dim_site') }}

)

SELECT

    MD5(
        COALESCE(CAST(safety.safety_key AS VARCHAR),'')
    ) AS fact_safety_key,

    /* Dimension Keys */

    site.site_key,
    entity.entity_key,

    /* Business Keys */

    safety.safety_key,
    safety.entity_id,

    /* Date */

    safety.period_date AS incident_date,

    /* Incident Attributes */

    safety.account_id,
    safety.incident_id,
    safety.days_of_month_id,

    /* Measures */

    COALESCE(safety.no_of_incidents,0) AS incident_count,

    /* Derived KPI */

    CASE
        WHEN COALESCE(safety.no_of_incidents,0) = 0
            THEN 'NO INCIDENT'

        WHEN safety.no_of_incidents BETWEEN 1 AND 5
            THEN 'LOW'

        WHEN safety.no_of_incidents BETWEEN 6 AND 20
            THEN 'MEDIUM'

        ELSE 'HIGH'
    END AS incident_severity,

    CURRENT_TIMESTAMP() AS model_refresh_ts

FROM safety

LEFT JOIN entity
    ON safety.entity_id = entity.entity_id

LEFT JOIN site
    ON entity.site_id = site.site_id

{% if is_incremental() %}

WHERE safety.period_date >
(
    SELECT COALESCE(
        MAX(incident_date),
        '1900-01-01'::DATE
    )
    FROM {{ this }}
)

{% endif %}