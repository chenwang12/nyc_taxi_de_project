
    
    

with dbt_test__target as (

  select tripid as unique_field
  from `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`stg_yellow_trip_data`
  where tripid is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


