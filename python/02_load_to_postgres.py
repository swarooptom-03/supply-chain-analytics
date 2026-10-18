import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

# Load cleaned dataset
csv_path = "/Users/swarooptom/Documents/Supply_Chain_Analytics_Project/data/cleaned_supply_chain.csv"

df = pd.read_csv(csv_path)

print("Rows loaded:", df.shape[0])
print("Columns loaded:", df.shape[1])

# Connect to PostgreSQL
engine = create_engine(
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)


# Load data into PostgreSQL

df.to_sql(
    "supply_chain",
    engine,
    if_exists="replace",
    index=False
)

print("Data loaded successfully!")
print("Table: supply_chain")
print("Rows inserted:", len(df))