with source as (

    select *
    from {{ source('moc', 'moc_wb_tool_access') }}

)

select

    sheeteid            as sheet_id,
    sheetname           as sheet_name,
    useremail           as user_email,
    hasaccess           as has_access,
    access_granted_by   as access_granted_by,
    access_granted_ts   as access_granted_ts

from source