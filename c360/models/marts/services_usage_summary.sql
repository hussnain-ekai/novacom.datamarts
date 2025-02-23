{{ config(materialized='table', schema='data_mart', vars={'update_frequency': 'daily'}) }}

with service_assignments as (
    select *
    from {{ source('dbt_project_source', 'PRV_SERVICE_ASSIGNMENTS') }}
),

services as (
    select *
    from {{ source('dbt_project_source', 'PRV_SERVICES') }}
),

nwk_usage as (
    select *
    from {{ source('dbt_project_source', 'NWK_USAGE') }}
),

nwk_equipment as (
    select *
    from {{ source('dbt_project_source', 'NWK_EQUIPMENT') }}
)

select
    service_assignments.ASSIGNMENT_ID,
    count(case when services.ACTIVE_FLAG = true then 1 end) as active_services,
    sum(services.MONTHLY_COST) as total_monthly_cost,
    sum(nwk_usage.DATA_CONSUMED) as total_data_consumed,
    sum(nwk_usage.USAGE_COST) as total_usage_cost,
    avg(nwk_usage.USAGE_PEAK) as average_peak_usage
from service_assignments
    LEFT JOIN services ON service_assignments.SERVICE_ID = services.SERVICE_ID
    LEFT JOIN nwk_usage ON service_assignments.ASSIGNMENT_ID = nwk_usage.ASSIGNMENT_ID
    LEFT JOIN nwk_equipment ON service_assignments.ASSIGNMENT_ID = nwk_equipment.ASSIGNMENT_ID
group by service_assignments.ASSIGNMENT_ID