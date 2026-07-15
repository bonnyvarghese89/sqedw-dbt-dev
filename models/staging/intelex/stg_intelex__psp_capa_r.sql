with source as (

    select *
    from {{ source('intelex', 'psp_capa_r') }}

)

select

    "Record No."        as record_no,
    "Location"          as location,
    "Issue Description" as issue_description,
    "Criticality"       as criticality,
    "Business Impact"   as business_impact,
    RPN                 as rpn,
    "Date Reported"     as date_reported,
    "Person Responsible" as person_responsible,
    "Status"            as status

from source