select *
from {{ ref('fact_trips') }}
where pickup_datetime >= CAST(CURRENT_DATE() as TIMESTAMP) - interval {{ env_var("days_back", 30) }} DAY