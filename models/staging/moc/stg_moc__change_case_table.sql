with source as (

    select *
    from {{ source('moc', 't_change_case_table') }}

)

select

    "Change_Case_RowID"        as change_case_row_id,
    change_case_id,
    change_title,
    change_description,
    change_category,
    change_type,
    requestor_name,
    requestor_email,
    site_code,
    department,
    priority,
    status,
    impact_assessment,
    approver_name,
    approver_email,
    created_date,
    target_completion_date,
    actual_completion_date,
    last_updated_date

from source