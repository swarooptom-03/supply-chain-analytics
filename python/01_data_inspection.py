import pandas as pd

file_path = "/Users/swarooptom/Documents/Supply_Chain_Analytics_Project/data/DataCoSupplyChainDataset.csv"

df = pd.read_csv(file_path, encoding="latin1")

print("Rows:", df.shape[0])
print("Columns:", df.shape[1])

print("\nFirst 5 rows:")
print(df.head())

print("\nColumn names:")
print(df.columns)

print("\nData types:")
print(df.dtypes)

print("\nMissing values:")
print(df.isnull().sum().sort_values(ascending=False))

print("\nDuplicate rows:")
print(df.duplicated().sum())

print("\nUnique IDs:")
print("Unique Order IDs:", df["Order Id"].nunique())
print("Unique Order Item IDs:", df["Order Item Id"].nunique())
print("Unique Customer IDs:", df["Customer Id"].nunique())

print("\nOrder items per order:")
print(df.groupby("Order Id")["Order Item Id"].nunique().describe())

order_date = pd.to_datetime(df["order date (DateOrders)"])
shipping_date = pd.to_datetime(df["shipping date (DateOrders)"])

print("\nOrder date range:")
print(order_date.min())
print(order_date.max())

print("\nShipping date range:")
print(shipping_date.min())
print(shipping_date.max())

print("\nShipping before order:")
print((shipping_date < order_date).sum())

print("\nNumerical sanity checks:")

print("\nOrder Item Quantity:")
print(df["Order Item Quantity"].describe())

print("\nSales")
print(df["Sales"].describe())

print("\nOrder Item Discount Rate:")
print(df["Order Item Discount Rate"].describe())

print("\nOrder Item Profit Ratio:")
print(df["Order Item Profit Ratio"].describe())

print("\nNegative profit ratio:")
print((df["Order Item Profit Ratio"] < 0).sum())

print("\nMost negative profit ratios:")
print(
    df.loc[
        df["Order Item Profit Ratio"] < 0,
        ["Order Item Profit Ratio", "Sales", "Order Item Discount Rate",
         "Order Item Product Price", "Order Profit Per Order"]
    ]
    .sort_values("Order Item Profit Ratio")
    .head(10)
)

print("\nNegative profit ratio percentage ")
print((df["Order Item Profit Ratio"] < 0).mean() * 100)

print("\nNon-positive Sales:")
print((df["Sales"] <= 0).sum())

print("\nNon-positive Product Price:")
print((df["Order Item Product Price"] <= 0).sum())

print("\nNon-positive Quantity:")
print((df["Order Item Quantity"] <= 0).sum())

df["Order_date"] = pd.to_datetime(df["order date (DateOrders)"])
df["shipping_date"] = pd.to_datetime(df["shipping date (DateOrders)"])

print(df[["Order_date", "shipping_date"]].dtypes)

print("\ndate columns:")
print(df[["Order_date", "shipping_date"]].head())

print(
    (df["Order_date"] == pd.to_datetime(df["order date (DateOrders)"])).all()
)

print(
    (df["shipping_date"] == pd.to_datetime(df["shipping date (DateOrders)"])).all()
)

df = df.drop(columns=["order date (DateOrders)", "shipping date (DateOrders)"])

df = df.rename(columns={"Order_date": "order_date"})

df = df.drop(columns=["Product Description"])

print("Product Description" in df.columns)

print("Order Zipcode data type:")
print(df["Order Zipcode"].dtypes)

print("Available Unique Zipcodes")
print(df["Order Zipcode"].dropna().nunique())

print("\nCustomer Zipcode data type:")
print(df["Customer Zipcode"].dtype)

print("\nMissing Customer Zipcodes:")
print(df["Customer Zipcode"].isna().sum())

print("\nUnique Customer Zipcodes:")
print(df["Customer Zipcode"].nunique())

print("\nCustomer Lname missing count:")
print(df["Customer Lname"].isna().sum())

print(
    df.loc[
        df["Customer Lname"].isna(),
        ["Customer Id", "Customer Fname", "Customer Lname"]
    ]
)

print("\nID columns:")
print(df[[
    "Customer Id",
    "Order Customer Id",
    "Order Id",
    "Order Item Id",
    "Product Card Id",
    "Product Category Id",
    "Category Id",
    "Department Id"
]].dtypes)

print("\nCustomer ID mismatch count:")
print((df["Customer Id"] != df["Order Customer Id"]).sum())

print("\nCustomer Id:")
print("Unique:", df["Customer Id"].nunique())
print("Missing:", df["Customer Id"].isna().sum())

print("\nOrder Customer Id:")
print("Unique:", df["Order Customer Id"].nunique())
print("Missing:", df["Order Customer Id"].isna().sum())

df = df.drop(columns=["Order Customer Id"])

print("\nUnique values per column:")
print(df.nunique().sort_values())

print("\nConstant column values:")
print("Customer Password:", df["Customer Password"].unique())
print("Customer Email:", df["Customer Email"].unique())
print("Product Status:", df["Product Status"].unique())

df = df.drop(columns=[
    "Customer Password",
    "Customer Email",
    "Product Status"
])

print("\nPotential duplicate columns:")
print(
    "Product Category Id == Category Id:",
    (df["Product Category Id"] == df["Category Id"]).all()
)
print(
    "Product Card Id == Order Item Cardprod Id:",
    (df["Product Card Id"] == df["Order Item Cardprod Id"]).all()
)
print(
    "Order Item Product Price == Product Price:",
    (df["Order Item Product Price"] == df["Product Price"]).all()
)

df = df.drop(columns=[
    "Category Id",
    "Order Item Cardprod Id",
    "Product Price"
])

print("\nCategorical value checks:")

categorical_columns = [
    "Type",
    "Customer Segment",
    "Market",
    "Shipping Mode",
    "Delivery Status",
    "Order Status",
    "Department Name"
]

for column in categorical_columns:
    print(f"\n{column}:")
    print(df[column].value_counts())

print("\nMissing values in categorical columns:")

for column in categorical_columns:
    print(column, ":", df[column].isna().sum())

# -----------------------------
# Create financial analysis columns
# -----------------------------

df["discount_amount"] = df["Order Item Discount"]

df["discount_rate"] = df["Order Item Discount Rate"]

df["profit"] = df["Order Profit Per Order"]

df["profit_ratio"] = df["Order Item Profit Ratio"]

df["is_loss"] = df["profit"] < 0

print("\nFinancial analysis columns created:")
print(
    df[
        [
            "Sales",
            "discount_amount",
            "discount_rate",
            "profit",
            "profit_ratio",
            "is_loss"
        ]
    ].head()
)

print("\nFinancial summary:")
print("Total Sales:", df["Sales"].sum())
print("Total Profit:", df["profit"].sum())
print("Total Discount:", df["discount_amount"].sum())
print("Loss-making rows:", df["is_loss"].sum())
print("Loss-making percentage:", df["is_loss"].mean() * 100)

# -----------------------------
# Create analytical columns
# -----------------------------

df["delivery_days"] = (
    df["shipping_date"] - df["order_date"]
).dt.days

df["is_late"] = (
    df["Delivery Status"] == "Late delivery"
)

df["order_year"] = df["order_date"].dt.year

df["order_month"] = df["order_date"].dt.month

df["order_year_month"] = (
    df["order_date"].dt.to_period("M").astype(str)
)

print("\nAnalytical columns created:")
print(
    df[
        [
            "order_date",
            "shipping_date",
            "delivery_days",
            "is_late",
            "order_year",
            "order_month",
            "order_year_month"
        ]
    ].head()
)

# -----------------------------
# Final data quality check
# -----------------------------

print("\nFinal data quality check:")
print("Rows:", df.shape[0])
print("Columns:", df.shape[1])

print("\nMissing values:")
print(df.isnull().sum().sort_values(ascending=False).head(10))

print("\nDuplicate rows:")
print(df.duplicated().sum())

print("\nDelivery days:")
print(df["delivery_days"].describe())

print("\nLate deliveries:")
print(df["is_late"].value_counts())

# -----------------------------
# Save cleaned dataset
# -----------------------------

output_path = "/Users/swarooptom/Documents/Supply_Chain_Analytics_Project/data/cleaned_supply_chain.csv"

df.to_csv(output_path, index=False)

print("\nCleaned dataset saved successfully.")
print(output_path)