{{ config(materialized='table', schema='mart', indexes=['INVOICE_ID']) }}

with BIL_INVOICES as (
    select * from {{ source('dbt_project_source', 'BIL_INVOICES') }} -- Core table containing invoice-level financials
),
BIL_INVOICE_ITEMS as (
    select * from {{ source('dbt_project_source', 'BIL_INVOICE_ITEMS') }} -- Detailed invoice item records (for potential future extensions)
),
BIL_PAYMENTS as (
    select * from {{ source('dbt_project_source', 'BIL_PAYMENTS') }} -- Payment transactions associated with invoices
)

select
    sum(inv.TOTAL_AMOUNT) as total_revenue,
    sum(inv.TAX_AMOUNT) as total_tax,
    sum(inv.DISCOUNT_AMOUNT) as total_discount,
    sum(pay.AMOUNT) as total_payments,
    count(distinct inv.INVOICE_ID) as invoice_count
from BIL_INVOICES as inv
join BIL_INVOICE_ITEMS as items on inv.INVOICE_ID = items.INVOICE_ID
join BIL_PAYMENTS as pay on inv.INVOICE_ID = pay.INVOICE_ID
group by inv.INVOICE_ID