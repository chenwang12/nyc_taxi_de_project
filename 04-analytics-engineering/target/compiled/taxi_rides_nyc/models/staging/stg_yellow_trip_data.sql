
 
with tripdata as 
(
  select *,
    row_number() over(partition by vendorid, tpep_pickup_datetime) as rn
  from `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`yellow_trip_data`
  where vendorid is not null 
)
select
   -- identifiers
    to_hex(md5(cast(coalesce(cast(vendorid as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(tpep_pickup_datetime as string), '_dbt_utils_surrogate_key_null_') as string))) as tripid,    
    safe_cast(vendorid as INT64) as vendorid,
    safe_cast(ratecodeid as INT64) as ratecodeid,
    safe_cast(pulocationid as INT64) as pickup_locationid,
    safe_cast(dolocationid as INT64) as dropoff_locationid,

    -- timestamps
    cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    safe_cast(passenger_count as INT64) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    -- yellow cabs are always street-hail
    1 as trip_type,
    
    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(0 as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    coalesce(safe_cast(payment_type as INT64),0) as payment_type,
    case safe_cast(payment_type as INT64)  
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
        else 'EMPTY'
    end as payment_type_description
from tripdata
where rn = 1

-- dbt build --select <model.sql> --vars '{'is_test_run: false}'


  limit 100

