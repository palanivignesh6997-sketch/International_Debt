import pandas as pd
import numpy as np
import psycopg2
from sqlalchemy import create_engine
from io import StringIO
import matplotlib.pyplot as plt

DB_CONFIG = {
    "user": "postgres",
    "password": "1234",
    "host": "localhost",
    "port": "5432",
    "database": "International_Debt"
}

engine = create_engine(
    f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

conn = psycopg2.connect(
    dbname=DB_CONFIG["database"],
    user=DB_CONFIG["user"],
    password=DB_CONFIG["password"],
    host=DB_CONFIG["host"],
    port=DB_CONFIG["port"]
)
cursor = conn.cursor()

print("Loading files...")
df_full = pd.read_csv("IDS_ALLCountries_Data.csv", skipfooter=2, engine='python', encoding='latin1')
df_country = pd.read_csv("IDS_CountryMetaData.csv", encoding='latin1')
df_series = pd.read_csv("IDS_SeriesMetaData.csv", encoding='latin1')
df_cs = pd.read_csv("Country-Series - Metadata.csv", encoding='latin1')
df_foot = pd.read_csv("IDS_FootNoteMetaData.csv", encoding='latin1')

year_cols = [col for col in df_full.columns if col.isdigit() and 2000 <= int(col) <= 2024]

df = df_full.iloc[:, :6].copy()
df.columns = df.columns.str.strip()
df = pd.concat([df, df_full[year_cols]], axis=1)

df = df.dropna(subset=['Series Code', 'Country Code'])
df['Series Code'] = df['Series Code'].str.strip()
df['Country Code'] = df['Country Code'].str.strip()

df[year_cols] = df[year_cols].apply(pd.to_numeric, errors='coerce')
df[year_cols] = df[year_cols].fillna(0).clip(lower=0)

df_all = df.melt(
    id_vars=df.columns[:6],
    value_vars=year_cols,
    var_name='Year',
    value_name='Debt_Value'
)

df_all['Year'] = pd.to_numeric(df_all['Year'], errors='coerce')
df_all = df_all.dropna(subset=['Year'])
df_all['Year'] = df_all['Year'].astype(np.int16)

remove_list = ["Low income", "Lower middle income", "Low & middle income",
               "Middle income", "Upper middle income", "IDA total", "IDA only"]

df_all = df_all[~df_all['Country Name'].isin(remove_list)]

def clean_meta(df_m):
    df_m.columns = df_m.columns.str.strip()
    for col in df_m.select_dtypes(include='object').columns:
        df_m[col] = df_m[col].str.strip()
        df_m[col] = df_m[col].fillna("Unknown")
    for col in df_m.select_dtypes(exclude='object').columns:
        df_m[col] = df_m[col].fillna(df_m[col].median())
    return df_m

df_country = clean_meta(df_country)
df_series = clean_meta(df_series)
df_cs = clean_meta(df_cs)
df_foot = clean_meta(df_foot)

def copy_to_postgres(df, table_name):
    buffer = StringIO()
    df.to_csv(buffer, index=False, header=False)
    buffer.seek(0)

    cursor.execute(f"DROP TABLE IF EXISTS {table_name};")

    cols = ", ".join([f'"{col}" TEXT' for col in df.columns])
    cursor.execute(f"CREATE TABLE {table_name} ({cols});")

    cursor.copy_expert(f"COPY {table_name} FROM STDIN WITH CSV", buffer)
    conn.commit()

tables = {
    "debt_data": df_all,
    "country_metadata": df_country,
    "series_metadata": df_series,
    "country_series_map": df_cs,
    "footnotes": df_foot
}

print("\nUploading to PostgreSQL (FAST COPY)...")
for name, data in tables.items():
    try:
        copy_to_postgres(data, name)
        print(f"Loaded: {name}")
    except Exception as e:
        print(f" Error: {name} -> {e}")

print("\nGenerating Plot...")
plt.figure(figsize=(10, 6))
df_all.groupby('Year')['Debt_Value'].sum().plot()
plt.title("Total Global Debt Trend (2000-2024)")
plt.grid(True)
plt.show()

cursor.close()
conn.close()

print("\n DONE — Data loaded directly to PostgreSQL FAST.")