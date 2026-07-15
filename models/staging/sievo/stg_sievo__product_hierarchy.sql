with source as (

    select *
    from {{ source('sievo', 'product_hierarchy') }}

)

select

    "ProductId"                         as product_id,
    "Indirect/Direct"                  as procurement_type,
    "Category L1"                      as category_l1,
    "Category L2"                      as category_l2,
    "Category L3"                      as category_l3,
    "Category L4"                      as category_l4,
    "Category L5"                      as category_l5,
    "Director"                         as director,
    "Global Strategic Purchasing Manager" as global_strategic_purchasing_manager,
    "Global Category Manager"          as global_category_manager,
    "Category ID"                      as category_id

from source