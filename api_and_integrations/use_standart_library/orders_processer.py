import csv
import os
import re
import subprocess
import zipfile
from datetime import datetime, timedelta

INPUT_FILE = "orders.csv"
OUTPUT_FILE = "orders_cleaned.csv"
BASE_DATE = datetime(2025, 1, 1)

rows = []

# -----------------------------
# Read and process CSV
# -----------------------------
with open(INPUT_FILE, newline="", encoding="utf-8") as csvfile:
    reader = csv.DictReader(csvfile)
    fieldnames = reader.fieldnames + ["morning_order", "date_ordered"]

    for row in reader:
        # 1. Extract morning hours (05–10) using regex
        hour = row["order_hour_of_day"].zfill(2)
        if re.match(r"^(0[5-9]|10)$", hour):
            row["morning_order"] = "yes"
        else:
            row["morning_order"] = "no"

        # 2. Create date_ordered using datetime
        days = row.get("days_since_prior_order")
        if days and days.isdigit():
            order_date = BASE_DATE + timedelta(days=int(days))
            row["date_ordered"] = order_date.strftime("%Y-%m-%d")
        else:
            row["date_ordered"] = ""

        rows.append(row)

# -----------------------------
# Write cleaned CSV
# -----------------------------
with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"Cleaned data written to {OUTPUT_FILE}")

# -----------------------------
# 3. Calculate total orders where order_dow == 3
# -----------------------------
dow_3_count = sum(int(r["order_dow"]) == 3 for r in rows if r["order_dow"].isdigit())


print(f"Total orders with order_dow = 3: {dow_3_count}")

# -----------------------------
# 4. Create reports directory
# -----------------------------
os.makedirs("reports", exist_ok=True)
print("Directory 'reports' created.")


# -----------------------------
# 5. List files using subprocess
# -----------------------------
def list_files():
    result = subprocess.run(["ls"], capture_output=True, text=True)
    return result.stdout


print("Files in current directory:")
print(list_files())

# -----------------------------
# Compress orders.csv into ZIP
# -----------------------------
with zipfile.ZipFile("orders.zip", "w", zipfile.ZIP_DEFLATED) as zipf:
    zipf.write(INPUT_FILE)

print("orders.csv compressed into orders.zip")
