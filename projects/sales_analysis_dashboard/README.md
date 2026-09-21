# Electronics E-Commerce Sales & Revenue Dashboard

An interactive business intelligence dashboard created in Data Studio (formerly Looker Studio) to analyze sales performance, revenue drivers, customer segmentation, and geographic distribution for an online electronics retailer.

| | |
| :--- | :--- |
| **Role** | Dashboard build on a SQL-prepared dataset: data modelling, metric design, report design |
| **Tools** | SQL, Data Studio (formerly Looker Studio) |
| **Data** | Synthetic training dataset (GoIT Data Analytics course) — electronics e-commerce orders |
| **Period covered** | Q1 2024 (January – March) |
| **Deliverable** | Live Data Studio report + SQL exercise files |

🔗 **Live Dashboard:** [Data Studio Report](https://datastudio.google.com/reporting/717a2b38-d184-4635-88a4-e6fb2b55c1b3/page/VpbzF)

The report covers Q1 2024 (January – March), spanning **31.4M UAH in revenue**, **475 orders**, **50 customers**, **25 products**, and **15 cities** across Ukraine.

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

### SQL work against the same dataset

The dashboard's Custom Query is defined inside the Data Studio data source and is not exported here. What is in the repository are two sets of SQL exercises written against the same e-commerce tables (`users_sql_project`, `orders_sql_project`, `order_items_sql_project`, `products_sql_project`, `payments_sql_project`, `shipments_sql_project`, plus the offline-channel `store_orders` / `store_order_items`):

* [**`../sql/Rudnieva_HW5.sql`**](../sql/Rudnieva_HW5.sql): ten single-table and subquery tasks — unique customers per city, `GROUP BY` / `HAVING` aggregation, order-quantity ranking, payment-status and payment-method filtering, `CASE` age bucketing, `COALESCE` on pending deliveries, and average delivery time per courier.
* [**`../sql/Rudnieva_HW6.sql`**](../sql/Rudnieva_HW6.sql): ten multi-table tasks — revenue per customer via `LEFT JOIN` onto product prices, online/offline channel comparison with `UNION ALL` and `INTERSECT`, average order value for paid orders, most-popular products by distinct buyers, and a CTE chain that counts customers placing above-average orders per month.

These are exercise query sets, not the dashboard query itself — they are included as evidence of the SQL layer behind the same data.

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

## Key Insights Summary

* **A third of revenue has no loyalty status.** The largest bar in the loyalty breakdown is `No information` at roughly **9.3M UAH — about 30% of total revenue** — taller than any actual tier. Before any conclusion about loyalty programme performance can be drawn, this attribution gap has to be closed at the point of data capture, since it silently distorts every segment comparison on the dashboard.

* **Loyalty tiers barely differentiate spend.** Across the named tiers, revenue is remarkably flat: **Gold 6.4M → Platinum 5.4M → Standard 5.2M → Silver 4.6M UAH**. A tier system is supposed to separate high-value customers from the rest; here the top tier generates only about 40% more than the bottom one, which suggests the tiers reflect tenure rather than actual purchasing power.

* **Neither sales channel dominates.** Online and offline revenue alternate the lead throughout the quarter with frequent sharp spikes and no stable winner. The volatility points to individual large orders driving daily totals rather than a steady baseline — expected given only 475 orders from 50 customers, and a reason to read daily figures with caution.

* **Revenue is geographically concentrated.** The geo map shows one dominant cluster around the capital region with the remaining 14 cities contributing markedly smaller volumes, indicating that regional expansion is largely untapped.

* **Product revenue is evenly spread.** The top ten products range from roughly **2.3M down to 1.2M UAH**, with `Лампа Max 25` leading. There is no single hero product carrying the assortment, so revenue is not exposed to the loss of any one SKU.

### Business Recommendations

Fix loyalty-status capture at checkout first — nearly a third of revenue is currently unattributable, and no segmentation decision should be made on the remaining 70%. In parallel, review the tier thresholds so that the levels actually separate customers by value, and evaluate regional expansion beyond the dominant city cluster.

> **Note on figures:** the values above are read from the published dashboard for the Q1 2024 period with all filters cleared. Applying the date, payment, loyalty, or channel filters will change them.

---

## Dashboard Preview

![Dashboard Screenshot](sad_1.jpg)
