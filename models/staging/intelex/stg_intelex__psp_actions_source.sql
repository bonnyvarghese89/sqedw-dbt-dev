with source as (

    select *
    from {{ source('intelex', 'psp_actions_source') }}

)

select

    "Record No."         as record_no,
    "Related Complaint"  as related_complaint,
    "Location"           as location,
    "Issue Description"  as issue_description,
    "Due Date"           as due_date,
    "Verification Date"  as verification_date,
    "Date Reported"      as date_reported,
    "Action No."         as action_no,
    "Status"             as status

from source