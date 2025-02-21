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

select distinct service_type, revenue_year, revenue_month, p97, p95, p90
from monthly_percentil
where revenue_month = '2020-04-01' and revenue_year = '2020-01-01'