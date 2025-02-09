CREATE OR REPLACE EXTERNAL TABLE `atomic-amulet-448415-d9.taxi_rides_ny.yellow_tripdata_2024-01-06`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://gcp-warehouse/yellow_tripdata_2024-*.parquet']
);

CREATE VIEW  `taxi_rides_ny.yellow_tripdata_nonpartitioned_2024-01-06`
AS 
SELECT * FROM `taxi_rides_ny.yellow_tripdata_2024-01-06`;

SELECT COUNT(*) FROM `taxi_rides_ny.yellow_tripdata_2024-01-06`;
SELECT COUNT(DISTINCT PULocationID) FROM `taxi_rides_ny.yellow_tripdata_2024-01-06`;

SELECT DISTINCT PULocationID FROM `taxi_rides_ny.yellow_tripdata_nonpartitioned_2024-01-06`;
SELECT DISTINCT PULocationID,DOLocationID FROM `taxi_rides_ny.yellow_tripdata_nonpartitioned_2024-01-06`;

SELECT COUNT(*) FROM `taxi_rides_ny.yellow_tripdata_nonpartitioned_2024-01-06` where fare_amount = 0;

CREATE OR REPLACE TABLE `taxi_rides_ny.yellow_tripdata_partitioned_2024-01-06`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS (
  SELECT * FROM `taxi_rides_ny.yellow_tripdata_2024-01-06`
);

SELECT DISTINCT VendorId  FROM `taxi_rides_ny.yellow_tripdata_nonpartitioned_2024-01-06`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' and '2024-03-15'; 

SELECT DISTINCT VendorId  FROM `taxi_rides_ny.yellow_tripdata_partitioned_2024-01-06`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' and '2024-03-15' ;

SELECT COUNT(*) FROM `taxi_rides_ny.yellow_tripdata_nonpartitioned_2024-01-06`;
