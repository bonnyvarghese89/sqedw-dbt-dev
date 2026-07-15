with source as (

    select *
    from {{ source('intelex', 'ehs') }}

)

select

    "By Group"                                                     as by_group,
    "Location"                                                     as location,
    "Location Path"                                                as location_path,
    "Operating Unit"                                               as operating_unit,
    "Operating Unit Path"                                          as operating_unit_path,
    "Department/Place where the event occurred (in English)"      as department,
    "Incident No."                                                 as incident_no,
    "Record No."                                                   as record_no,
    "Incident Type"                                                as incident_type,
    "Date"                                                         as incident_date,
    "Date Reported"                                                as date_reported,
    "Incident Description (in English)"                             as incident_description,
    "Description"                                                  as description,
    "Date Closed"                                                  as date_closed,
    "Incident Title"                                               as incident_title,
    "Incident Title (in English)"                                  as incident_title_en,
    "Status"                                                       as status

from source