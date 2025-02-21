-- Question 5

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

select * from quarterly_yoy
where revenue_quarter >= '2020-01-01'
order by service_type, revenue_yoy_growth_percentage, quarterly_yoy.revenue_quarter

-- Question 6:
{{ config(materialized='table') }}

with filtered_trips as (
    select * from {{ ref('fact_trips') }} where fare_amount > 0 and trip_distance > 0 
    and payment_type_description in ('Cash','Credit card')
),

monthly_percentil as (
select service_type,  {{ dbt.date_trunc('month', 'pickup_datetime')}} as revenue_month
    ,  {{ dbt.date_trunc('year', 'pickup_datetime')}} as revenue_year,
    PERCENTILE_CONT(fare_amount, 0.97) OVER 
    (partition by service_type, {{ dbt.date_trunc('year', 'pickup_datetime')}}
    , {{ dbt.date_trunc('month', 'pickup_datetime') }}) AS p97,
    PERCENTILE_CONT(fare_amount, 0.95) OVER 
    (partition by service_type, {{ dbt.date_trunc('year', 'pickup_datetime')}}
    , {{ dbt.date_trunc('month', 'pickup_datetime') }}) AS p95,
    PERCENTILE_CONT(fare_amount, 0.90) OVER (
        partition by service_type,{{ dbt.date_trunc('year', 'pickup_datetime')}}
        , {{ dbt.date_trunc('month', 'pickup_datetime')}}) AS p90
from filtered_trips
)

--select * from grouped_revenue

select distinct service_type, revenue_year, revenue_month, p97, p95, p90
from monthly_percentil
where revenue_month = '2020-04-01' and revenue_year = '2020-01-01'

--Question 7
{{ config(materialized='table') }}

with fhv_data as (
    select *, TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) AS trip_duration from {{ref('dim_fhv_trips')}} 
),

p90_percentil as (
select puzone,dozone,trip_duration,pu_month,pu_year,
    PERCENTILE_CONT(trip_duration, 0.90) OVER (
        partition by {{ dbt.date_trunc('year', 'pickup_datetime')}}
                    ,{{ dbt.date_trunc('month', 'pickup_datetime')}}
                    ,pulocationid
                    ,dolocationid) AS p90
from fhv_data
),

final_results as (
select *, dense_rank() over(partition by puzone order by p90 desc) as Rank
from p90_percentil
where pu_month = '2019-11-01' and pu_year = '2019-01-01'
and puzone in ('Newark Airport', 'SoHo','Yorkville East') )

select distinct puzone, dozone, p90,Rank from final_results where Rank =2

