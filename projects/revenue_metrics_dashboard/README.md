# Revenue Metrics Dashboard

An end-to-end analytical project that monitors the financial health of a **SaaS / mobile-game product** and explains *why* recurring revenue changes from month to month. Raw payment records are aggregated and classified in **PostgreSQL** using window functions, then visualized as an interactive dashboard in **Tableau Public** built for a Head of Product who needs to separate real growth from churn covered up by new sales.

> ### The one question this dashboard answers
>
> **Are we actually growing — or is new revenue just covering up what we lose?**
>
> For this product, March–December 2022: **it is covering up.** Total MRR rose all year, but by December net growth had effectively stopped — **Net New MRR was $15** against **$8,440** of MRR. New sales and expansion brought in $4,342 and contraction and churn removed $4,328. The dashboard exists to make that $15 visible, because no top-line revenue chart shows it.

| | |
| :--- | :--- |
| **Role** | End-to-end: SQL data prep, metric design, dashboard build |
| **Tools** | PostgreSQL / DBeaver, Tableau Public |
| **Data** | Synthetic training dataset (GoIT Data Analytics course) — payment records of a SaaS / mobile-game product |
| **Period covered** | March – December 2022 |
| **Deliverable** | Live Tableau dashboard + SQL query + presentation PDF |

🔗 **Live Dashboard:** [Revenue Metrics Dashboard (Tableau Public)](https://public.tableau.com/app/profile/olha.rudnieva/viz/RevenueMetricsFilter/RevenueMetrics)
📄 **Presentation:** [View in Canva](https://canva.link/ofl5ozg8gzwzd96) &nbsp;•&nbsp; [Revenue Metrics Dashboard.pdf](Revenue%20Metrics%20Dashboard.pdf) — executive summary slides

---

## Project Overview

The analysis covers 10 months of monetization activity (March 2022 – December 2022), spanning **$63,141 in total revenue**, **383 distinct paying users across the period**, and **17 revenue metrics** tracked month over month.

**Business questions addressed** — the main question above breaks down into four that the dashboard answers directly:

* What exactly drives MRR up or down each month — new customers, expansion, contraction, churn, or returning users?
* How does retention quality look when LTV dynamics are placed next to User and Revenue Churn Rate?
* Which month broke the trend, and what caused it?
* Where should the team spend its next effort — acquisition, or retention?

---

## Repository Structure

* [**`query.sql`**](./query.sql): PostgreSQL script that turns individual payments into a user × month grain and classifies every row into an MRR change factor — a chain of CTEs (`monthly_mrr` → `user_monthly_mrr` → `user_payments_history` → `base_metrics` → `unfolded_events`) plus `LAG()` / `LEAD()` window functions and `CASE` classification. The `UNION ALL` inside `unfolded_events` reshapes the result into a long format keyed by a single `metric_month`, so that growth factors and churn factors land on the month each event actually belongs to (see *Methodology Notes*).
* [**`Revenue Metrics Dashboard.pdf`**](./Revenue%20Metrics%20Dashboard.pdf): Executive presentation slides covering the project idea, methodology, dashboard walkthrough, and business conclusions — also available [online in Canva](https://canva.link/ofl5ozg8gzwzd96).
* [**`RevenueMetricsDashboard.png`**](./RevenueMetricsDashboard.png): Static preview of the redesigned overview screen with every filter set to *(All)*.
* [**`RevenueMetricsDashboard_with_date_filer.png`**](./RevenueMetricsDashboard_with_date_filer.png): The same overview screen with the Date filter narrowed to June–August 2022, showing the KPI cards retitled to *August 2022*.
* [**`RevenueMetricsDashboard_summary_table.png`**](./RevenueMetricsDashboard_summary_table.png): The second screen — the Summary Metrics Table with all 17 metrics across the 10 months.
* [**`Revenue Metrics Dashboard`**](https://public.tableau.com/app/profile/olha.rudnieva/viz/RevenueMetricsFilter/RevenueMetrics): Live interactive report on Tableau Public.

---

## Tech Stack & Skills Applied

* **Database & Querying:** PostgreSQL / DBeaver
  * `date_trunc('month', …)` aggregation of payments to a user × game × month grain.
  * `LEFT JOIN` onto the paid-users dictionary to attach `language`, `age`, and device attributes used as dashboard filters.
  * `LAG()` and `LEAD()` window functions partitioned by user to compare each payment month with the adjacent calendar months.
  * `CASE` classification into the five MRR change factors (New, Expansion, Contraction, Churn, Back from Churn) — a gap between `previous_payment_month` and `previous_calendar_month` is what distinguishes a returning user from a continuing one.
* **Business Intelligence & Data Visualization:** Tableau Public
  * **Aggregate-only measure design:** because the SQL layer already dates every factor by `metric_month`, `Net New MRR`, `Churn Rate`, `LT`, and `LTV` are plain ratios of `SUM()`s rather than table calculations — which is what keeps the date filter honest (a dimension filter drops rows *before* a table calculation runs, so a `LOOKUP(…, -1)` churn measure silently returns NULL as soon as a single month is selected).
  * A `Filter - Latest Month` calculated field (`LAST() = 0`), addressed explicitly along the month dimension, doing double duty: it pins each KPI card to a single-month snapshot instead of an incorrect sum across the whole period, **and** it feeds the cards' dynamic titles, so every card names the month it reports and follows the date filter (*MRR — Dec 2022* → *MRR — Aug 2022*). See *Challenges & How They Were Solved*.
  * A **parameter** (`Select Metric View`) driving a dynamic trend chart across all 17 metrics, with the chart title generated from the selection (e.g. *ARPPU Dynamic Metric Trend*).
  * **Dashboard navigation buttons** — *View Summary Table* from the overview screen and *Back to Overview* from the table screen.
  * **Filters** on date, user language, and age group applied consistently across every view, stacked together with the metric parameter in a single control column.
  * **Visual design pass:** one unified olive/sage-green palette, a single *Revenue Metrics* title band, a grouped legend panel, direct value labels on every mark, zero baselines on all factor charts, and dual axes labelled on both sides.

---

## Key Metrics Computed

| Metric | Business Definition | Formula / Logic |
| :--- | :--- | :--- |
| **MRR** | Monthly Recurring Revenue | `SUM([Revenue])` per calendar month |
| **Paid Users** | Distinct paying users in the month | `COUNTD([User Id])` |
| **ARPPU** | Average Revenue Per Paid User | `MRR / Paid Users` |
| **New MRR** | Revenue from users paying for the first time | `mrr` where `previous_payment_month IS NULL` |
| **Expansion MRR** | Increase from users who started paying more | `mrr - previous_mrr` where `mrr > previous_mrr` |
| **Contraction MRR** | Decrease from users who started paying less | `mrr - previous_mrr` where `mrr < previous_mrr` |
| **Churned MRR** | Revenue lost from users who stopped paying | `-1 * mrr` where next payment month is missing |
| **Back from Churn MRR** | Revenue recovered from returning users | `mrr` where the previous payment gap > 1 month |
| **Net New MRR** | Net monthly change in recurring revenue | Sum of all five change factors |
| **Churn Rate** | Share of last month's users who left | `SUM(churned_users) / SUM(churn_base_users)` — the base being every user who paid in the previous month |
| **Revenue Churn Rate** | Share of last month's revenue lost | `-SUM(churned_mrr) / SUM(churn_base_mrr)` |
| **LT / LTV** | Customer Lifetime and Lifetime Value | Average paying months and cumulative revenue per user |

**Period totals (March – December 2022):** $63,141 total revenue • 383 distinct paying users over the whole period

**Latest-month KPI row (December 2022 snapshot):** MRR $8,440 · Paid Users 189 · LTV $131 · Net New MRR $15

---

## Key Insights Summary

* **The "leaky bucket" effect.** In December the positive factors added **$4,342** (New MRR $1,268 + Expansion MRR $1,713 + Back from Churn MRR $1,361), while contraction and churn removed **-$4,328** (Contraction -$2,381 + Churned -$1,947). The month only closed positive because of the $1,361 recovered from previously churned users — Net New MRR ended at just **$15** against an MRR of **$8,440**. Headline revenue looked stable while net growth had effectively stopped.

* **November 2022 was the anomaly of the year.** Churned MRR spiked to **-$2,800** across **71 churned users**, dragging Net New MRR into negative territory at **-$919**. MRR Churn Rate peaked at **30.0%** that month — the single clearest retention failure in the period.

* **Retention is deteriorating, not acquisition.** User Churn Rate rose from **25.6%** in April to a **35.7%** peak in November and closed at **34.0%** in December; MRR Churn Rate followed the same shape — **20.1%** (April) → **30.0%** peak (November) → **23.1%** (December). Paid users climbed steadily to a **199** peak in October, then plateaued at 188 and 189 in November and December — the flattening is itself a symptom of the rising churn, not of weaker acquisition. Acquisition works; the product is losing cohorts faster than it keeps them.

* **Premium plans are losing perceived value.** Contraction MRR stays persistently high (**-$2,381** in December), meaning existing customers are actively downgrading rather than leaving outright.

* **LTV is trending down.** LTV fell from a $236 peak in July to **$131** in December, with LT dropping from 5.0 to 2.9 months — consistent with the rising churn rather than with any pricing change.

### Business Recommendations

Shift focus from acquisition to retention. Revise onboarding and lifecycle communication at the stages where churn concentrates, and audit the contents of the premium tiers to reduce Contraction MRR. Both changes should be re-measured against Net New MRR rather than total revenue, since total MRR masks the underlying losses.

---

## Challenges & How They Were Solved

The hardest part of this project was not writing the metrics — it was making them **survive the date filter**. Every measure that looks at a neighbouring month, and every KPI card that reports "the latest month", breaks in a different way the moment a user narrows the range. Three concrete failures and their fixes:

**1. The KPI cards contradicted themselves under a date filter.**
The cards have to answer "where are we right now", but *right now* is not a fixed month — it is the last month of whatever the user has selected. Two naive versions both failed:

* A plain `SUM()` turns the card into a period total. That is what the first version of the MRR card did — it showed **$63,141** for the whole period while the bar chart beside it showed a **$8.4K** month, so the same word "MRR" meant two different things on one screen. Worse, summing LTV or Net New MRR across ten months is arithmetically meaningless: they are a snapshot and a delta, not additive flows.
* Hard-coding December 2022 fixes the number but freezes it — the card then keeps reporting December no matter what the Date filter says.

**Fix:** a `Filter - Latest Month` field (`LAST() = 0`) with its addressing set **explicitly along the month dimension** rather than left to the default table layout — otherwise the calculation re-anchors to the on-screen grid and picks the wrong column as soon as the filter changes how many months are in view. Because `LAST()` is evaluated *inside the current selection*, "latest" recomputes on every filter change, and the same field also feeds the card titles. Narrowing Date to June–August 2022 therefore retitles the cards to **MRR — Aug 2022** and shows August's own values ($7,617 / 165 / $163 / $825). The card can no longer be misread, because it states its own month.

**2. The churn charts went blank when a single month was selected.**
Churn Rate compares two adjacent months, and it was originally computed in Tableau as `LOOKUP(SUM([Churned Mrr]), -1)`. This looked correct across the full range and was therefore easy to miss — but picking one month in the Date filter returned **NULL**, silently emptying the churn charts. The cause is order of operations: a dimension filter removes the previous month's row *before* any table calculation runs, so there is nothing left to look back at.

**Fix:** move the month-shifting out of the BI layer and into SQL. `query.sql` emits each payment as two rows sharing one `metric_month` — a `payment` row and a `churn_check` row dated `payment_month + 1` that carries both the churn factors and the churn-rate denominator. Numerator and denominator now sit on the same date, so both churn rates became plain ratios of `SUM()`s, and the same reshape let `Net New MRR`, `LT`, and `LTV` drop their table calculations too. See *Methodology Notes* below for the full mechanics.

**3. The date filter listed a month that does not exist.**
Shifting churn forward by one month meant every December 2022 payer produced a churn row in **January 2023** — a phantom month that appeared in the Date filter and showed the entire December MRR collapsing to zero, purely because the data simply ends there.

**Fix:** bound the shifted branch with `where next_calendar_month <= (select max(payment_month) from monthly_mrr)`. The Date filter now lists exactly the ten real months, March–December 2022.

**The takeaway:** a dashboard that is correct at full range is not yet correct. Each of these bugs was invisible until a filter was actually used, which is why the interaction — not just the numbers — became part of the testing.

---

## Methodology Notes

1. **Waterfall chart rejected on purpose.** A classic waterfall stacked the negative Churn values upward, artificially inflating the revenue bar. The dashboard uses an **MRR Change Factors** chart instead: positive factors extend up from zero, negative factors down into the minus, and a line tracks Net New MRR — mathematically exact at every point.
2. **KPI cards are snapshots, charts are trends.** The cards deliver a single-month pulse via `LAST() = 0`; the charts below them supply the historical context. Because a snapshot next to a trend line can be read as a period total, each card title is now generated dynamically and names its month — *MRR — Dec 2022* at full range, *MRR — Aug 2022* once the Date filter is narrowed to June–August 2022. The ambiguity disappears: the card always states which month it reports.
3. **Churn is dated one month after the last payment, and the SQL — not Tableau — does the shifting.** A user's churn flags are derived from the row of their *last* payment, but the month they are actually counted as lost is the following calendar month. Aggregating churn by payment month would shift the whole curve back by one month and invent a false mass churn in the final month of data, since users still active in December 2022 simply have no next payment recorded yet.

   Rather than patch this in the BI layer, `query.sql` emits each payment as **two rows sharing one `metric_month`** column: a `payment` row carrying MRR, the paid-user flag, and the growth factors, and a `churn_check` row on `payment_month + 1` carrying the churn factors plus the churn-rate base. The `churn_check` branch is **unconditional** — every payment produces one. When a user stays, `churned_mrr` and `churned_users` are `NULL` while `churn_base_mrr` / `churn_base_users` still carry the user's `mrr` and `1`, which puts the denominator ("everyone who paid the previous month") on the *same* `metric_month` as the churn itself. Both churn rates therefore become a ratio of two `SUM()`s inside one month, which is exactly why **the dashboard date filter stays correct at any selection** — including a single month. The earlier `LOOKUP(SUM([Churned Mrr]), -1)` approach produced the same chart at full range but dropped churn entirely once one month was picked, because a dimension filter removes the `-1` row before the table calculation is evaluated.

   Two details make the reshape safe. The `churn_check` rows carry `NULL` MRR, `NULL` growth factors, and `NULL::int as paid_users`, so revenue and user counts are plain `SUM()`s over the non-null payment rows and there is nothing to double-count in the BI layer. And the branch is bounded by `where next_calendar_month <= (select max(payment_month) from monthly_mrr)` — without it, everyone who paid in December 2022 would receive a churn row in January 2023, adding a phantom month to the axis that collapses the entire December MRR. Note also that churn is flagged by `next_payment_month IS NULL OR next_payment_month != next_calendar_month`, so a *gap* counts as churn rather than only a permanent exit: a user who pauses is counted as churned and then picked up again in Back from Churn when they return.
4. **No Grand Totals in the Summary table.** Snapshot metrics (MRR, LTV), flow metrics (New MRR), and relative metrics (Churn Rate %) cannot be summed together, so the total row is switched off rather than shown as a misleading figure.

---

## Dashboard Features

1. **KPI header:** Four cards — MRR, Paid Users, LTV, and Net New MRR — pinned to the latest month in the current selection, each with a **dynamic title naming that month** (*MRR — Dec 2022* by default; *MRR — Aug 2022*, $7,617 / 165 / $163 / $825, when the Date filter is set to June–August 2022).
2. **MRR Change Factors & User Change Factors:** Two paired charts decomposing revenue and user movement into five factors each, with an overlaid Net New line.
3. **Total MRR & Paid Users:** Combined bar-and-line view of the overall growth trend.
4. **LT & LTV:** Customer lifetime against lifetime value to judge retention quality.
5. **User Churn vs Revenue Churn:** Dual-axis comparison of the two churn rates.
6. **Dynamic Metric Trend:** A single parameter-driven chart covering all 17 metrics, its title following the selection (*ARPPU Dynamic Metric Trend*, and so on).
7. **Summary Metrics Table:** A second screen with the full month-by-month audit — all 17 metrics × 10 months — reached through the *View Summary Table* button and left again through *Back to Overview*.
8. **Control column:** The `Select Metric View` parameter together with the Date, Language, and Age Group filters, stacked in one panel so every view responds to the same selection.

---

## Dashboard Preview

**Overview screen — all filters set to *(All)*:**

![Revenue Metrics dashboard overview](RevenueMetricsDashboard.png)

**Same screen with the Date filter narrowed to June–August 2022 — the KPI cards retitle themselves to *August 2022* and report that month's values:**

![Revenue Metrics dashboard with the date filter applied](RevenueMetricsDashboard_with_date_filer.png)

**Summary Metrics Table — all 17 metrics across March–December 2022:**

![Revenue Metrics summary table](RevenueMetricsDashboard_summary_table.png)
