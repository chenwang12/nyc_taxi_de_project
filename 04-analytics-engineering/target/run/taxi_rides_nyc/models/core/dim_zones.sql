
  
    

    create or replace table `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`dim_zones`
      
    
    

    OPTIONS()
    as (
      

select 
    locationid, 
    borough, 
    zone, 
    replace(service_zone,'Boro','Green') as service_zone 
from `atomic-amulet-448415-d9`.`taxi_rides_nyc`.`taxi_zone_lookup`
    );
  