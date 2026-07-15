-- stg_bpc__safety.sql

with source_data as (

    select distinct
        PERIOD_DATE,
        ENTITY_ID,
        ACCOUNT_ID,
        DAYS_OF_MONTH_ID,
        INCIDENT_ID,
        AMOUNT as NO_OF_INCIDENTS
    from {{ source('bpc', 'safety') }}

)

select
    {{ dbt_utils.generate_surrogate_key([
        'PERIOD_DATE',
        'ENTITY_ID',
        'ACCOUNT_ID',
        'DAYS_OF_MONTH_ID',
        'INCIDENT_ID'
    ]) }} as safety_key,

    PERIOD_DATE,
    ENTITY_ID,
    ACCOUNT_ID,
    DAYS_OF_MONTH_ID,
    INCIDENT_ID,
    NO_OF_INCIDENTS

from source_data