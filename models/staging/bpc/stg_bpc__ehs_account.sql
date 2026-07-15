{{ config(
    materialized='table'
) }}

with ct_final_name as (

    select
        ACCOUNT_ID,
        ACCOUNT_DESCRIPTION,
        ACCOUNT_TYPE,
        "GROUP",
        RATE_TYPE,
        PARENT_ACCOUNT_ID_H1

    from {{ source('bpc', 'account') }}

)

select

    {{ dbt_utils.generate_surrogate_key([
        'ACCOUNT_ID',
        '"GROUP"',
        'RATE_TYPE',
        'PARENT_ACCOUNT_ID_H1'
    ]) }} as ACCOUNT_EHS_KEY,

    ACCOUNT_ID,
    ACCOUNT_DESCRIPTION,
    ACCOUNT_TYPE,
    "GROUP",
    RATE_TYPE,
    PARENT_ACCOUNT_ID_H1,

    {{ add_audit_columns() }}

from ct_final_name