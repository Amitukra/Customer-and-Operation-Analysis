# -*- coding: utf-8 -*-
"""Question[3] Python Assignment.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1-cc-x-c-csWIqPcv_MZ2Ms_V_RNlgOHo

# 3. Python Assignment: Customer Segmentation & Demand Patterns
## Objective
### Segment customers based on purchasing behavior and detect demand trends.
# Tasks
###(A)	Segment customers into high-value, frequent, and occasional buyers using K-Means clustering.
###(B) Analyze sales trends to identify peak ordering periods.
###(C) Visualize customer segments and order patterns using graphs.
## Dataset: customers.csv, sales_data.csv
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

customers_data = pd.read_csv('/content/customers.csv')

customers_data.head(20)

sales_data = pd.read_csv('/content/sales_data.csv')

sales_data

""" ## [3(A)] Segment customers into high-value, frequent, and occasional buyers using K-Means clustering."""

# data preprocessing

scaler = StandardScaler()
scaled_data = scaler.fit_transform(customers_data[['total_spend', 'num_orders']])

# Apply K-means clustering
kmeans = KMeans(n_clusters=3, random_state=42)  # We choose 3 clusters for high, frequent, and occasional buyers
customers_data['cluster'] = kmeans.fit_predict(scaled_data)

# Visualize the clusters
plt.scatter(customers_data['total_spend'], customers_data['num_orders'], c=customers_data['cluster'], cmap='viridis')
plt.xlabel('Total Spend')
plt.ylabel('Number of Orders')
plt.title('Customer Segmentation based on Purchasing Behavior')
plt.colorbar(label='Cluster')
plt.show()

# Analyze the segments
# Group by clusters to see the average_spending and orders per cluster
segment_analysis = customers_data.groupby('cluster').agg({
    'total_spend': ['mean', 'std'],
    'num_orders': ['mean', 'std']
})

print(segment_analysis)

# Question(2):  Analyze sales trends to identify peak ordering periods.

"""##[3(B)] Analyze sales trends to identify peak ordering periods."""

sales_data["order_date"].dtype

sales_data.info()

sales_data['order_date'] = pd.to_datetime(sales_data['order_date'])

# Extract time features
sales_data['month'] = sales_data['order_date'].dt.month
sales_data['day'] = sales_data['order_date'].dt.day
sales_data['weekday'] = sales_data['order_date'].dt.weekday  # 0=monday, 6=sun

# Aggregate by month
monthly_sales = sales_data.groupby('month').agg({'revenue': 'sum'}).reset_index()

# Visualize the sales_trends
plt.figure(figsize=(10, 6))
plt.plot(monthly_sales['month'], monthly_sales['revenue'], marker='o', color='b')
plt.title('Monthly Sales Trend')
plt.xlabel('Month')
plt.ylabel('Total Revenue')
plt.xticks(monthly_sales['month'])
plt.grid(True)
plt.show()

# Aggregate by weekday
weekday_sales = sales_data.groupby('weekday').agg({'revenue': 'sum'}).reset_index()

# Visualize sales by weekday
plt.figure(figsize=(10, 6))
plt.bar(weekday_sales['weekday'], weekday_sales['revenue'], color='g')
plt.title('Sales by Weekday')
plt.xlabel('Weekday (0=Monday, 6=Sunday)')
plt.ylabel('Total Revenue')
plt.xticks(weekday_sales['weekday'])
plt.grid(True)
plt.show()

sales_data



"""# [3(C)] Visualize customer segments and order patterns using graphs."""

# Convert last_order_date to datetime format
customers_data["last_order_date"] = pd.to_datetime(customers_data["last_order_date"])
customers_data

# Plot 1: (Distribution of total_spend)
plt.figure(figsize=(8, 5))
sns.histplot(customers_data["total_spend"], bins=10, kde=True, color="blue")
plt.xlabel("Total Spend")
plt.ylabel("Frequency")
plt.title("Distribution of Total Spend")
plt.show()

# Plot 2: [Distribution of number of orders]
plt.figure(figsize=(8, 5))
sns.histplot(customers_data["num_orders"], bins=10, kde=True, color="green")
plt.xlabel("Number of Orders")
plt.ylabel("Frequency")
plt.title("Distribution of Number of Orders")
plt.show()

# Plot 3: [Total_spend VS number of orders]
plt.figure(figsize=(8, 5))
sns.scatterplot(x=customers_data["num_orders"], y=customers_data["total_spend"], hue=customers_data["total_spend"], size=customers_data["total_spend"], sizes=(20, 200), palette="coolwarm", edgecolor="black")
plt.xlabel("Number of Orders")
plt.ylabel("Total Spend")
plt.title("Total Spend vs. Number of Orders")
plt.legend(title="Total Spend", loc="upper left")
plt.show()

# Plot 4: [Order Activity]
plt.figure(figsize=(10, 5))
sns.histplot(customers_data["last_order_date"], bins=10, kde=True, color="purple")
plt.xlabel("Last Order Date")
plt.ylabel("Frequency")
plt.title("Last Order Date Distribution")
plt.xticks(rotation=45)
plt.show()