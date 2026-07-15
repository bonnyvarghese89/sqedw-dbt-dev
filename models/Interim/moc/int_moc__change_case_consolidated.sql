{{ 
  config(
    materialized='table',
    schema='stg',
    alias='int_moc__change_case_consolidated'
  )
}}

WITH case_base AS (
    SELECT *
    FROM {{ ref('stg_moc__change_case_table') }}
),

case_history AS (
    SELECT *
    FROM {{ ref('stg_moc__change_case_history') }}
),

wb_access AS (
    SELECT *
    FROM {{ ref('stg_moc__wb_tool_access') }}
),

/* Get latest history record per case */
latest_history AS (
    SELECT *
    FROM (
        SELECT
            ch.*,
            ROW_NUMBER() OVER (
                PARTITION BY ch.CHANGE_CASE_ID
                ORDER BY ch.VERSION_NUMBER DESC, ch.UPDATED_TIMESTAMP DESC
            ) AS rn
        FROM case_history ch
    )
    WHERE rn = 1
)

SELECT

    /* Case Details */
    cb.CHANGE_CASE_ID,
    cb.CHANGE_TITLE,
    cb.CHANGE_DESCRIPTION,
    cb.CHANGE_CATEGORY,
    cb.CHANGE_TYPE,

    cb.REQUESTOR_NAME,
    cb.REQUESTOR_EMAIL,

    cb.SITE_CODE,
    cb.DEPARTMENT,

    cb.PRIORITY,

    /* Current workflow status (from main table) */
    cb.STATUS AS CURRENT_STATUS,

    cb.IMPACT_ASSESSMENT,

    cb.APPROVER_NAME,
    cb.APPROVER_EMAIL,

    cb.CREATED_DATE,
    cb.TARGET_COMPLETION_DATE,
    cb.ACTUAL_COMPLETION_DATE,
    cb.LAST_UPDATED_DATE,

    /* Latest history snapshot */
    lh.VERSION_NUMBER AS LATEST_VERSION,
    lh.STATUS AS LATEST_HISTORY_STATUS,
    lh.COMMENTS AS LATEST_COMMENTS,
    lh.UPDATED_BY AS LAST_UPDATED_BY,
    lh.UPDATED_BY_EMAIL,
    lh.UPDATED_TIMESTAMP AS LAST_UPDATED_TIMESTAMP,

    /* Access control flag */
    CASE 
        WHEN wa.HAS_ACCESS = TRUE THEN 'Y'
        ELSE 'N'
    END AS HAS_WB_ACCESS,

    wa.ACCESS_GRANTED_BY,
    wa.ACCESS_GRANTED_TS

FROM case_base cb

LEFT JOIN latest_history lh
    ON cb.CHANGE_CASE_ID = lh.CHANGE_CASE_ID

LEFT JOIN wb_access wa
    ON cb.REQUESTOR_EMAIL = wa.USER_EMAIL