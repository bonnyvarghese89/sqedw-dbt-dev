with source as (

    select *
    from {{ source('moc', 't_change_case_table_history') }}

)

select

    "Change_Case_RowID"   as change_case_row_id,
    change_case_id,
    version_number,
    status,
    comments,
    updated_by,
    updated_by_email,
    updated_timestamp

from source