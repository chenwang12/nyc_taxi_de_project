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

