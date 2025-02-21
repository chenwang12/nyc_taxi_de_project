{{config(materialized='table')}}

with fhv_tripdata as (
    select * 
    from {{ ref('stg_fhv_tripdata_2019') }}
), 

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select 
        pickup_zone.borough as puborough,
        pickup_zone.zone as puzone, 
        pickup_zone.service_zone as puservice_zone,
        dropoff_zone.borough as doborough, 
        dropoff_zone.zone as dozone, 
        dropoff_zone.service_zone as doservice_zone,
        fhv.dispatching_base_num,
        {{ dbt.date_trunc('month', 'fhv.pickup_datetime')}} as pu_month,
        {{ dbt.date_trunc('year', 'fhv.pickup_datetime')}} as pu_year,
        fhv.pickup_datetime,
        fhv.dropoff_datetime,
        fhv.pulocationid,
        fhv.dolocationid,
        fhv.sr_flag,
        fhv.affiliated_base_number
from fhv_tripdata fhv
inner join dim_zones as pickup_zone
on fhv.pulocationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv.dolocationid = dropoff_zone.locationid