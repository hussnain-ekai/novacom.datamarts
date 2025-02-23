{{ config(materialized='table') }}

-- support_performance_dashboard model
-- This model aggregates performance metrics for support tickets

with sup_tickets as (
    select *
    from {{ source('dbt_project_source', 'SUP_TICKETS') }}
)

select 
    CREATED_DATE,
    count(TICKET_ID) as total_tickets,
    count(case when STATUS = 'Open' then 1 end) as open_tickets,
    count(case when STATUS = 'Resolved' then 1 end) as resolved_tickets,
    avg(datediff(day, CREATED_DATE, RESOLUTION_DATE)) as avg_resolution_time
from sup_tickets

group by CREATED_DATE