-- stg_bpc__employee.sql
-- Staging view for BPC Employee data

with source_data as (

    select 
        ENTITY_ID,
        ENTITY_DESCRIPTION,
        PERIOD_DATE,
        NUMBER_OF_EMPLOYEES,
        NUMBER_OF_AGENCY_PEOPLE,
        NUMBER_OF_HOURS
    from {{ source('bpc', 'sqe_employee') }}

)

select 
    {{ dbt_utils.generate_surrogate_key([
        'ENTITY_ID',
        'ENTITY_DESCRIPTION',
        'PERIOD_DATE'
    ]) }} as employee_key,

    ENTITY_ID,
    ENTITY_DESCRIPTION,
    PERIOD_DATE,
    NUMBER_OF_EMPLOYEES,
    NUMBER_OF_AGENCY_PEOPLE,
    NUMBER_OF_HOURS

from source_data