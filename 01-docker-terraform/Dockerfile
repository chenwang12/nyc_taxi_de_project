FROM python:3.13

RUN pip install pandas sqlalchemy pyarrow requests psycopg2

WORKDIR /app
COPY ingest_data.py ingest_data.py
ENTRYPOINT [ "python","ingest_data.py"]








