select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select tripid
from `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`stg_green_trip_data`
where tripid is null



      
    ) dbt_internal_test