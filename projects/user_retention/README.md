# Cohort Analysis: User Retention Rate Evaluation

This repository contains an analytical project focused on cleaning raw e-commerce data using **SQL (PostgreSQL)** and executing a comprehensive **Cohort Analysis** to evaluate user **Retention Rate** via **Google Sheets**.

🔗 **Live Cohort Dashboard:** [User Retention & Cohort Analysis (Google Sheets)](https://docs.google.com/spreadsheets/d/1izFDyh0IKHF2RubBb7z4JZSIkfAUlAxoYfWGFws4EXM/edit?gid=0#gid=0)

## Project Overview
The goal is to monitor and compare user behavioral patterns over a 6-month observation window (January – June 2025). Specifically, the analysis evaluates the performance and acquisition quality of promotional signups (**Promo Users**) against organic signups (**Organic Users**).

## Repository Structure
* [**`PostgresSQL.sql`**](./PostgresSQL.sql): Comprehensive PostgreSQL script encompassing data cleaning, time-parsing templates, data filtration (exclusion of test events and system NULLs), month offset calculations, and final aggregations.
* [**`data.csv`**](./data.csv): Aggregated dataset exported from the database containing cohort definitions, monthly lifetime offsets, and unique user counts.
* [**`Presentation.mp4`**](./Presentation.mp4): A recorded video presentation detailing the methodology, analytical steps, dynamic Google Sheets dashboard functionality, and strategic business conclusions.
* [**`User Retention & Cohort Analysis`**](https://docs.google.com/spreadsheets/d/1izFDyh0IKHF2RubBb7z4JZSIkfAUlAxoYfWGFws4EXM/edit?gid=0#gid=0): Cohort tables and conclusions

## Database Schema & Data Extraction
The SQL workflow processes two core tables within the `project` schema:
1.  `cohort_users_raw`: Evaluates user baseline metadata and standardizes highly inconsistent string-based registration timestamps (`signup_datetime`).
2.  `cohort_events_raw`: Tracks transactional and behavioral touchpoints (`login`, `view_content`, `purchase`, `registration`), filters out `test_event` rows, and standardizes action timestamps.

## Key Metrics Computed
* **Cohort Month (`cohort_month`)**: The standardized starting month of user registration.
* **Month Offset (`month_offset`)**: The relative lifetime month of a user in the system (calculated as the difference in months between the event date and the signup date, ranging from 0 to 5).
* **Retention Rate (%)**: The percentage of unique active users returning in later months relative to the size of the initial Month 0 cohort.

## Key Insights Summary

The cohort analysis revealed a substantial difference in Retention Rate between the two user groups:

* **Organic users (`promo_signup_flag = 0`) — high quality and loyalty.** They not only sign up in greater numbers but also return to the product consistently. In the January cohort, half of the users (56%) were still active even after 5 months. Because these people found the service on their own (via search or word of mouth), they have strong, genuine intent and a real need for the product.

* **Promo users (`promo_signup_flag = 1`) — acquired in smaller numbers and churn fast.** In the January cohort their Retention Rate drops sharply: 62% return in the first month, but by the fifth month only 9% remain (just 3 people). Promotional offers (discounts or gifts) motivate sign-up but not lasting engagement — interest fades once the incentive ends.

### Business Recommendations
Organic acquisition is far more effective. For promo campaigns, the business should strengthen the retention logic for incentivized customers (e.g. improve onboarding) and focus on optimizing acquisition cost, since most promo users leave as soon as the offer ends.

## Dashboard Preview

![Dashboard Screenshot](ur_p1.png)
