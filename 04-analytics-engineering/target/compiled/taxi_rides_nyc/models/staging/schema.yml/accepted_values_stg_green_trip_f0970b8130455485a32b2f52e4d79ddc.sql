
    
    

with all_values as (

    select
        Payment_type as value_field,
        count(*) as n_records

    from `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`stg_green_trip_data`
    group by Payment_type

)

select *
from all_values
where value_field not in (
    1,2,3,4,5,6
)


