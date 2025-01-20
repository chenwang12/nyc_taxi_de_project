#!/usr/bin/env python
# coding: utf-8
import pyarrow.parquet as pq
import requests
import pandas as pd
from sqlalchemy import create_engine
import os
import argparse

#url = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet"
output_file="green_tripdata_2019-10.parquet"

def download_parquet_file(url, output_file):
    """Download the parquet file from the given URL."""
    response = requests.get(url)
    response.raise_for_status()  # Raise an error for bad status codes
    with open(output_file, 'wb') as f:
        f.write(response.content)
    print(f"File downloaded to {output_file}")

def insert_data_to_postgres(file_path, table_name, url, chunk_size=100000):
    """Insert data from a Parquet file into a PostgreSQL database in chunks."""
    engine = create_engine(url, connect_args={'connect_timeout': 10})

    with engine.connect() as con:
        print("Starting data insertion...")
        count = 0
        file = pq.ParquetFile(file_path)
        for batch in file.iter_batches(batch_size=chunk_size):
            count+=1
            batch_df = batch.to_pandas()
            #print(f'inserting batch {count}...')
            batch_df.to_sql(table_name, con, if_exists='append', index=False)
            print(f"Inserted chunk {count + 1}")
    print("Data insertion completed.")  

def main():
    parser = argparse.ArgumentParser(description="Download a Parquet file and insert its data into a PostgreSQL database.")
    parser.add_argument('--url', required=True, help="URL of the Parquet file.")
    parser.add_argument('--user', required=True, help="Database username.")
    parser.add_argument('--password', required=True, help="Database password.")
    parser.add_argument('--host', required=True, help="Database host.")
    parser.add_argument('--port', required=True, help="Database port.")
    parser.add_argument('--db_name', required=True, help="Database name.")
    parser.add_argument('--table_name', required=True, help="Table name to insert data into.")
    parser.add_argument('--chunk_size', type=int, default=10000, help="Number of rows per chunk for insertion.")

    args = parser.parse_args()

    db_url = f"postgresql://{args.user}:{args.password}@{args.host}:{args.port}/{args.db_name}"

    # Step 1: Download the Parquet file
    download_parquet_file(args.url, output_file)

    # Step 2: Insert data into PostgreSQL
    insert_data_to_postgres(output_file, args.table_name, db_url, args.chunk_size)

    # Clean up downloaded file
    if os.path.exists(output_file):
        os.remove(output_file)
        print(f"Cleaned up downloaded file: {output_file}")

if __name__ == "__main__":
    main()