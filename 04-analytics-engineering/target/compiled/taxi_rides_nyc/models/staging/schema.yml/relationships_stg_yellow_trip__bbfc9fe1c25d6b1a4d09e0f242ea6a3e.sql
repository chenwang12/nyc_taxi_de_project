
    
    

with child as (
    select Pickup_locationid as from_field
    from `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`stg_yellow_trip_data`
    where Pickup_locationid is not null
),

parent as (
    select locationid as to_field
    from `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`taxi_zone_lookup`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


