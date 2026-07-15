with source as (

    select *
    from {{ source('sievo', 'transactiondata') }}

)

select

    "SourceRowId"          as source_row_id,
    "MD_VendorNoId"        as vendor_id,
    "MD_MaterialNoId"      as material_id,
    "MD_OperationalUnitNoId" as operational_unit_id,
    "PONumber"             as po_number,
    "POLineNumber"         as po_line_number,
    "POLineDesc"           as po_line_description,
    "InvoiceNo"            as invoice_no,
    "PostingDate"          as posting_date,
    "InvoiceDate"          as invoice_date,
    "DueDate"              as due_date,
    "OriginalCurrency"     as original_currency,
    "SpendOriginalCurrency" as spend_amount,
    "Quantity"             as quantity,
    "UOM"                  as uom

from source