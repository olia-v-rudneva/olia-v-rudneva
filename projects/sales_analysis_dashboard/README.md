# Electronics E-Commerce Sales & Revenue Dashboard

An interactive business intelligence dashboard created in Data Studio (formerly Looker Studio) to analyze sales performance, revenue drivers, customer segmentation, and geographic distribution for an online electronics retailer.

🔗 **Live Dashboard:** [Data Studio Report](https://datastudio.google.com/reporting/717a2b38-d184-4635-88a4-e6fb2b55c1b3/page/VpbzF)

---

## Business Questions Addressed
* How is revenue distributed across clients, products, and cities?
* Which key factors and customer loyalty segments drive the most revenue?
* How does revenue fluctuate over time across different sales channels?
* Which geographical regions and top-selling products generate the core business value?

---

## Tech Stack & Skills Applied
* **Data Source:** Relational Database (SQL server).
* **Data Extraction:** Connected via **Custom Query** with a unified dataset formed by joining multiple operational tables (`orders`, `order_items`, `products`, `users`, `payments`, `shipments`, etc.).
* **Data Engineering & Preparation:**
  * Configured data freshness to update automatically every 4 hours.
  * Formatted field data types (Date, Number, Currency).
  * Converted text location data into `Geo -> City` data type for geospatial visualization.
  * Created a custom-calculated field for **Revenue** based on product price and quantity.
* **BI Dashboarding & Design:** Data Studio (formerly Looker Studio) with consistent typography, custom color palette, and aligned grids suitable for stakeholder presentations.

---

## Dashboard Structure & Features

### 1. Control Panel (Filters)
* Date Range Control
* Payment Method
* Payment Status
* Customer Status
* Sales Channel

### 2. Key Performance Indicators (Scorecards)
* Total Revenue
* Total Orders
* Unique Customers
* Unique Products Sold
* Total Cities Reached

### 3. Visualizations
* **Time Series Chart:** Revenue dynamics tracked by sales channels over time.
* **Geo Map:** Regional revenue distribution by cities to identify high-performing geographical markets.
* **Bar Chart:** Revenue breakdown by customer loyalty segments.
* **Table:** Top-performing products sorted by total revenue.
* **Interactivity:** Enabled cross-filtering across all visual elements to allow dynamic data exploration.

---

## Dashboard Preview

![Dashboard Screenshot](sad_1.jpg)
