{{ config(materialized='table') }}

with trips_data as (
    select * from {{ ref('fact_trips') }} where pickup_datetime >= '2019-01-01' 
    and pickup_datetime <= '2020-12-31'
),

quarterly_revenue as (
    select 
        {{ dbt.date_trunc('quarter', 'pickup_datetime') }} as revenue_quarter,
        service_type,
        sum(total_amount) as revenue_quarterly_total_amount
    from trips_data
    group by 1,2
),

quarterly_yoy as (
    select 
        revenue_quarter,
        service_type,
        revenue_quarterly_total_amount as current_quarter_revenue,
        lag(revenue_quarterly_total_amount, 4) over (
            partition by service_type 
            order by revenue_quarter
        ) as previous_quarter_revenue,
        round(
            ((revenue_quarterly_total_amount - lag(revenue_quarterly_total_amount, 4) over (
                partition by service_type 
                order by revenue_quarter
            )) / nullif(lag(revenue_quarterly_total_amount, 4) over (
                partition by service_type 
                order by revenue_quarter
            ), 0)) * 100,
            2
        ) as revenue_yoy_growth_percentage
    from quarterly_revenue
)

select *, rank() over(partition by service_type order by revenue_yoy_growth_percentage desc) as Rank
from quarterly_yoy
where revenue_quarter >= '2020-01-01'
order by service_type, revenue_yoy_growth_percentage, quarterly_yoy.revenue_quarter