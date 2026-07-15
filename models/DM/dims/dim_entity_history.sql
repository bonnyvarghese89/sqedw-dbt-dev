{{
    config(
        materialized='table'
    )
}}

SELECT

    {{ dbt_utils.generate_surrogate_key([
        'ENTITY_ID',
        'DBT_VALID_FROM'
    ]) }} AS ENTITY_HISTORY_KEY,

    ENTITY_ID,
    ENTITY_DESCRIPTION,
    ENTITY,
    ENTITY_TYPE,
    ENTITY_LEVEL,

    DBT_VALID_FROM,
    DBT_VALID_TO,

    CASE
        WHEN DBT_VALID_TO IS NULL
        THEN 'Y'
        ELSE 'N'
    END AS CURRENT_FLAG

FROM {{ ref('snap_entity') }}