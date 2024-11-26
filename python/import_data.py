# After navigating to the student_files directory and installing pandas and sqlite3,
# run this script in the shell using the command: `python3 import_data.py`

import sqlite3
import pandas as pd # type: ignore
import os

# Path to the SQLite database file
db_path = "../data/E-COMMERCE.db"

# Connect to the SQLite database
conn = sqlite3.connect(db_path)

# Path to the CSV directory
csv_directory = "../data/synthetic_data"

# List of tables to import
tables = ["CUSTOMER", "PAYMENT_METHOD", "CREDIT_CARD", "GIFT_CARD", "PRODUCT", 
          "BASKET", "BASKET_PRODUCT", "ORDERS", "ORDER_PRODUCT", "DELIVERY", "REVIEW", "ORDER_RETURNS"]

for table in tables:
    # Create the path to the individual CSV
    csv_path = os.path.join(csv_directory, f"{table}.csv")

    if os.path.exists(csv_path):
        # Load the CSV file into a DataFrame
        df = pd.read_csv(csv_path)
        
        # Insert the DataFrame into the SQLite table
        df.to_sql(table, conn, if_exists="append", index=False)
        print(f"Data imported successfully into {table} from {csv_path}")
    else:
        print(f"CSV file for table {table} not found in {csv_directory}")

# Close the database connection
conn.close()
