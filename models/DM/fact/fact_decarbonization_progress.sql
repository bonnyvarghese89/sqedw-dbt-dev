{{
    config(
        materialized='incremental',
        unique_key='FACT_DECARBONIZATION_KEY',
        on_schema_change='sync_all_columns'
    )
}}

SELECT

    MD5(
        COALESCE(CAST(s.site_id AS VARCHAR),'') || '-' ||
        COALESCE(CAST(e.entity_id AS VARCHAR),'') || '-' ||
        COALESCE(CAST(b.energy_period_date AS VARCHAR),'')
    ) AS fact_decarbonization_key,

    s.site_key,
    e.entity_key,

    s.site_id,
    s.site_description,

    e.entity_id,
    e.entity_description,

    b.energy_period_date AS reporting_date,

    /* ESG Metrics */

    b.total_employees,

    b.energy_consumption,

    b.env_impact_amount,

    b.incident_count,

    /* KPI Calculations */

    CASE
        WHEN b.total_employees > 0
        THEN ROUND(
            b.energy_consumption / b.total_employees,
            2
        )
    END AS energy_per_employee,

    CASE
        WHEN b.total_employees > 0
        THEN ROUND(
            b.incident_count * 100.0 / b.total_employees,
            2
        )
    END AS incident_rate,

    CASE
        WHEN b.energy_consumption > 100000
        THEN 'HIGH'
        WHEN b.energy_consumption > 50000
        THEN 'MEDIUM'
        ELSE 'LOW'
    END AS energy_risk,

    CURRENT_TIMESTAMP() AS model_refresh_ts

FROM {{ ref('int_bpc__consolidated_impact') }} b

LEFT JOIN {{ ref('dim_site') }} s
    ON b.site_id = s.site_id

LEFT JOIN {{ ref('dim_entity') }} e
    ON b.entity_id = e.entity_id

{% if is_incremental() %}

WHERE b.energy_period_date >
(
    SELECT COALESCE(
        MAX(reporting_date),
        '1900-01-01'::DATE
    )
    FROM {{ this }}
)

{% endif %}