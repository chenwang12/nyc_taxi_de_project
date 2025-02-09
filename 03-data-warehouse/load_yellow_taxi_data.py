import os
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from google.cloud import storage
import time
import requests


#Change this to your bucket name
BUCKET_NAME = "gcp-warehouse"  

#If you authenticated through the GCP SDK you can comment out these two lines
CREDENTIALS_FILE = "03-gcs.json"  
client = storage.Client.from_service_account_json(CREDENTIALS_FILE)


BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-"
MONTHS = [f"{i:02d}" for i in range(1, 7)] 
DOWNLOAD_DIR = "."

CHUNK_SIZE = 8 * 1024 * 1024  

os.makedirs(DOWNLOAD_DIR, exist_ok=True)

bucket = client.bucket(BUCKET_NAME)


def download_file(month):
    """Download the parquet file from the given URL."""
    url = f"{BASE_URL}{month}.parquet"
    file_path = os.path.join(DOWNLOAD_DIR, f"yellow_tripdata_2024-{month}.parquet")

    try:
        print(f"Downloading {url}...")
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for bad status codes
        with open(file_path, 'wb') as f:
            f.write(response.content)
        print(f"File downloaded to {file_path}")
        return file_path
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return None

def verify_gcs_upload(blob_name):
    return storage.Blob(bucket=bucket, name=blob_name).exists(client)

def upload_to_gcs(file_path, max_retries=3):
    blob_name = os.path.basename(file_path)
    blob = bucket.blob(blob_name)
    blob.chunk_size = CHUNK_SIZE  
    
    for attempt in range(max_retries):
        try:
            print(f"Uploading {file_path} to {BUCKET_NAME} (Attempt {attempt + 1})...")
            blob.upload_from_filename(file_path)
            print(f"Uploaded: gs://{BUCKET_NAME}/{blob_name}")
            
            if verify_gcs_upload(blob_name):
                print(f"Verification successful for {blob_name}")           
                return
            else:
                print(f"Verification failed for {blob_name}, retrying...")
            
        except Exception as e:
            print(f"Failed to upload {file_path} to GCS: {e}")
        
        time.sleep(5)  
    
    print(f"Giving up on {file_path} after {max_retries} attempts.")


if __name__ == "__main__":
    with ThreadPoolExecutor(max_workers=4) as executor:
        file_paths = list(executor.map(download_file, MONTHS))
    with ThreadPoolExecutor(max_workers=4) as executor:
        executor.map(upload_to_gcs, filter(None, file_paths))  # Remove None values

    print("All files processed and verified.")