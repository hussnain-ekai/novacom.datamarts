{{ config(materialized='table', schema='mart') }}

WITH mkt_campaigns AS (
    SELECT *
    FROM {{ source('dbt_project_source', 'MKT_CAMPAIGNS') }}
),

mkt_campaign_targets AS (
    SELECT *
    FROM {{ source('dbt_project_source', 'MKT_CAMPAIGN_TARGETS') }}
)

SELECT
    c.campaign_id,
    c.name,
    count(c.campaign_id) over () as total_campaigns,
    COALESCE(t.total_targets, 0) as total_targets,
    COALESCE(t.engaged_targets, 0) as engaged_targets,
    CASE
        WHEN t.total_targets > 0 THEN ROUND(t.engaged_targets::decimal / t.total_targets, 2)
        ELSE 0
    END as conversion_rate
FROM mkt_campaigns c
LEFT JOIN (
    SELECT 
        campaign_id, 
        COUNT(target_id) AS total_targets, 
        COUNT(CASE WHEN status = 'Engaged' THEN 1 END) AS engaged_targets
    FROM {{ source('dbt_project_source', 'MKT_CAMPAIGN_TARGETS') }}
    GROUP BY campaign_id
) t
    ON c.campaign_id = t.campaign_id
GROUP BY c.campaign_id, c.name, t.total_targets, t.engaged_targets