# SQL Query Library

> **A query library, not a case study.** These are the raw SQL files from my GoIT Data Analytics coursework — graded homework plus the two course submissions that later became full portfolio projects. There is no dashboard and no business narrative here; the point is to show the SQL itself, so anyone who wants to read my actual code can do it in one place. Every dataset is synthetic training data from the course, with one exception: `Rudnieva_HW7.sql` runs against Google's public `bigquery-public-data.ga4_obfuscated_sample_ecommerce` dataset, which is real (obfuscated) Google Merchandise Store traffic.

Comments inside the files are bilingual **Ukrainian / English** — the Ukrainian is the original course language, the English is there so the logic reads without translation.

---

## At a glance

| | |
| :--- | :--- |
| **Role** | Analyst — wrote and tested every query myself |
| **Tools** | PostgreSQL (pgAdmin / DBeaver), Google BigQuery Standard SQL |
| **Data** | Synthetic GoIT course datasets (cohort tables, ad platform logs, e-commerce schema); `bigquery-public-data.ga4_obfuscated_sample_ecommerce` for HW7 |
| **Period covered** | Cohort data Jan – Jun 2025 · ad data Feb 2021 – Dec 2022 · GA4 sample event tables (single day `20210131`, the `events_2021*` wildcard set, and the full `events_*` set) |
| **Deliverable** | 5 `.sql` files — 2 course submissions and 3 graded exercise sets, 30 numbered queries in total |

---

## Course submissions (already presented as full projects)

These two files are the **submission copies** of queries that appear in this portfolio as complete case studies. The SQL is the same query in both places — only the comments differ (the project copies carry fuller explanations). They are kept here for completeness; read the project pages for the business context, results, and dashboards.

### [`Project_1.sql`](./Project_1.sql) — cohort / retention query

Same query as [`user_retention/PostgresSQL.sql`](../user_retention/PostgresSQL.sql). A five-step CTE chain (`users_parsed` → `users_parsed_date` → `events_parsed` → `events_parsed_date` → `user_activity`) that normalises inconsistent string timestamps with `trim()` + nested `replace()`, validates the format with `regexp_match()` inside a `CASE` before casting via `split_part()` + `TO_DATE()`, filters `test_event` and `NULL` event types, `LEFT JOIN`s users to events, derives `cohort_month` with `date_trunc('month', …)::date`, computes `month_offset` from `extract(… from age(…))`, and closes with `COUNT(DISTINCT user_id)` grouped by promo flag, cohort and offset.

➡️ See it with business context: **[User Retention & Cohort Analysis](../user_retention/README.md)**

### [`Project_2.sql`](./Project_2.sql) — URL decoding & cross-platform ad blending

Same query as [`marketing_performance_analysis/PostgresSQL.sql`](../marketing_performance_analysis/PostgresSQL.sql). Defines a temporary SQL function (`CREATE OR REPLACE FUNCTION pg_temp.decode_url_part`, `IMMUTABLE STRICT`) that percent-decodes URL parameters using `regexp_matches()`, `string_agg()`, `convert_to`/`convert_from` and a `bytea` cast; then builds Facebook (`LEFT JOIN` to campaign and adset dictionaries, `coalesce()` on every metric) and Google branches, merges them with `UNION ALL`, extracts `utm_campaign` with `substring(… from 'utm_campaign=([^&]+)')`, normalises `'nan'` and `NULL` to `'empty'` via `CASE`, and aggregates the metrics at date × source × campaign × adset × utm_campaign.

➡️ See it with business context: **[Marketing Performance Analysis](../marketing_performance_analysis/README.md)**

---

## [`Rudnieva_HW5.sql`](./Rudnieva_HW5.sql) — PostgreSQL basics: aggregation, filtering, subqueries

Ten queries against the synthetic e-commerce schema (`users_sql_project`, `orders_sql_project`, `order_items_sql_project`, `products_sql_project`, `payments_sql_project`, `shipments_sql_project`) — the same dataset behind my [Sales Analysis Dashboard](../sales_analysis_dashboard/README.md).

| Query | Business question | SQL technique |
| :--- | :--- | :--- |
| Q1 | How many unique customers are there per city? | `COUNT(DISTINCT)`, `GROUP BY`, `ORDER BY` |
| Q2 | Which single order contains the most items? | `GROUP BY` with aggregate in `ORDER BY`, `LIMIT 1` |
| Q3 | How many orders were paid by card or bank transfer and not rejected? | `COUNT(DISTINCT)`, `WHERE` with `<>` and `OR` |
| Q4 | Which customers placed five or more orders? | `GROUP BY` + `HAVING` |
| Q5 | How many units and how many orders involve the `DigitalUA` brand? | `IN` with a subquery, `SUM()`, `COUNT(DISTINCT)` |
| Q6 | What is the delivery status of each shipment? | `COALESCE()` with an explicit `::text` cast for a NULL placeholder |
| Q7 | How does the customer base split into young / middle / older age groups? | `CASE` bucketing, grouping by the alias |
| Q8 | Which cities contain at least three different loyalty tiers? | `COUNT(DISTINCT)` + `HAVING` |
| Q9 | Which customers registered with a Gmail address? | `LIKE` pattern matching |
| Q10 | Which courier delivers fastest on average? | date arithmetic (`delivery_date - shipment_date`), `AVG()`, NULL filtering |

---

## [`Rudnieva_HW6.sql`](./Rudnieva_HW6.sql) — set operators, CTEs and online vs offline comparison

Ten queries on the same schema plus the offline sales channel (`store_orders`, `store_order_items`). The running theme is combining two channels into one comparable grain and comparing them.

| Query | Business question | SQL technique |
| :--- | :--- | :--- |
| Q1 | How much has each customer spent in total? | two `LEFT JOIN`s, `SUM(quantity * price)`, `GROUP BY` |
| Q2 | What is the combined order log across the online and offline channels? | `UNION ALL` with column aliasing, multi-key `ORDER BY` |
| Q3 | Which products are sold in both channels? | `INTERSECT` |
| Q4 | Which customers bought more than two units of something in *both* channels? | `INTERSECT` over two `IN` subqueries |
| Q5 | What is the average online basket among paid orders? | derived table (subquery in `FROM`), `AVG()` of a per-order `SUM()` |
| Q6 | How do units sold and order counts compare online vs offline? | `WITH` CTE + `UNION ALL`, aggregation by a literal channel label |
| Q7 | Which three products reach the most *unique* buyers (not the most units)? | CTE with `INNER JOIN` + `UNION ALL`, `COUNT(DISTINCT user_id)`, `LIMIT 3` |
| Q8 | Is the average basket bigger online or offline? | CTE with per-channel `GROUP BY`, then `AVG()` of order totals |
| Q9 | Which online customers bought an item priced above the average offline item price? | CTE + scalar subquery in `WHERE`, `SELECT DISTINCT` |
| Q10 | How many customers place above-average-value orders, month by month? | three chained CTEs, `UNION ALL`, `to_char(date, 'yyyy-mm')`, `INNER JOIN`, scalar subquery comparison |

---

## [`Rudnieva_HW7.sql`](./Rudnieva_HW7.sql) — BigQuery: nested GA4 data

Ten queries against `bigquery-public-data.ga4_obfuscated_sample_ecommerce`. GA4 export rows are nested — `event_params`, `user_properties` and `items` are arrays of structs — so the whole set is really about flattening (`UNNEST`) and then working with the flattened grain. Opens with a scratch query that pulls 100 `user_pseudo_id` / `item_name` pairs to pick a sample user to trace.

| Query | Business question | SQL technique |
| :--- | :--- | :--- |
| Q1 | What does one raw event row look like for a single user? | `CROSS JOIN UNNEST(items)`, `TIMESTAMP_MICROS()` |
| Q2 | How many entries do the nested arrays of that event hold? | `ARRAY_LENGTH()` on `event_params`, `user_properties`, `items` |
| Q3 | What key/value pairs sit inside one event's `event_params`? | CTE + `JOIN UNNEST(u.event_params)`, struct field access (`ep.value.string_value` / `int_value` / `double_value`) |
| Q4 | Which event parameters occur most often across 2021? | wildcard table `events_2021*`, `UNNEST(event_params)`, `COUNT(*)` + `GROUP BY` |
| Q5 | What are the item-level details of each event? | `UNNEST(items)` projecting `item_id`, `item_category`, `price`, `quantity` |
| Q6 | Which products generate the most revenue? | `SUM(price * quantity)`, `SUM(quantity)`, `GROUP BY ALL` |
| Q7 | Which events involve at least one `Apparel` item? | `EXISTS` with a correlated `UNNEST` subquery |
| Q8 | How do users, events and purchases trend day by day? | `_TABLE_SUFFIX` over `events_*`, `COUNT(DISTINCT)`, `COUNTIF()` |
| Q9 | Who are the top 20 customers by revenue, and how do the ranking functions differ? | window functions `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()` over an aggregate |
| Q10 | Which event most often starts a session? | two CTEs, `UNNEST(event_params)` filtered on `key = 'ga_session_id'`, `ROW_NUMBER() OVER (PARTITION BY user_pseudo_id, ga_session_id ORDER BY event_timestamp)`, aggregate in `ORDER BY` |

---

## What this section is for

The dashboards in this portfolio show the output; this folder shows the SQL underneath it. Between the three exercise files the coverage is: joins and set operators (`UNION ALL`, `INTERSECT`), aggregation with `GROUP BY` / `HAVING`, scalar and correlated subqueries, derived tables, multi-step CTE chains, `CASE` logic, regular expressions, date parsing and arithmetic, window functions, and BigQuery's nested-array model.
