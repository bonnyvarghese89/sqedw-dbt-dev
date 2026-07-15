with source as (

    select *
    from {{ source('intelex', 'ehshs_4_bpc') }}

)

select

    "By Group"            as by_group,
    "Level1"              as level1,
    "Location Name"       as location_name,
    "Operating Unit"      as operating_unit,
    "Department"          as department,
    "Incident Date"       as incident_date,
    "Day of Incident"     as day_of_incident,
    "Incident Created Date" as incident_created_date,
    "Incident ID"         as incident_id,
    "Current Case"        as current_case,
    "Incident Type"       as incident_type

from source