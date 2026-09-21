# Python Practice Notebooks

> **A learning section, not a portfolio case study.** These are graded coursework notebooks from the GoIT Data Analytics course, kept here as honest evidence of where my Python currently stands — core syntax, pandas, and the standard visualisation stack. The analytical projects in this portfolio are built in SQL, Tableau, Power BI, and Data Studio (formerly Looker Studio); Python is the tool I am still adding.

| | |
| :--- | :--- |
| **Role** | Coursework exercises: pandas data cleaning, feature engineering, aggregation, visualisation |
| **Tools** | Python • Jupyter Notebook / Google Colab • pandas • Matplotlib • Seaborn |
| **Data** | Synthetic training datasets (GoIT Data Analytics course coursework), plus Seaborn's public `titanic` dataset — no real company data |
| **Period covered** | Facebook Ads notebook: November 2020 – October 2022; other notebooks — |
| **Deliverable** | Three graded Jupyter notebooks (learning section, not a finished business deliverable) |

Task descriptions and comments inside the notebooks are in **Ukrainian** (course language); the analysis itself is language-neutral.

---

## Notebooks

### [`16_Rudnieva.ipynb`](./16_Rudnieva.ipynb) — Python basics, collections, first look at pandas

47 exercises covering variables and types, type conversion, arithmetic and conditional logic, lists and slicing, loops, dictionaries, sets, and an introductory pandas block (creating a `DataFrame`, selecting, filtering, sorting, grouping).

### [`17_Rudnieva.ipynb`](./17_Rudnieva.ipynb) — Exploratory analysis with pandas (Titanic)

Working with the `titanic` dataset from Seaborn:

* initial inspection (`shape`, `head`, `dtypes`, `info`, `describe(include='all')`) and notes on which columns should be recast to `category`
* feature engineering — a single `relatives` column replacing `sibsp` / `parch`, then a bucketed `relatives_category` (`above 5`)
* missing-value handling — median imputation for `age`
* binning `age` into `child` / `young` / `adult` / `senior`
* grouping and aggregation: share of large-family passengers per embarkation port, and mortality rate per age group via `groupby(...).agg()`

### [`18_Rudnieva.ipynb`](./18_Rudnieva.ipynb) — Marketing data analysis & visualisation (Facebook Ads)

Daily and campaign-level analysis of a Facebook Ads dataset (Nov 2020 – Oct 2022), read straight from a remote CSV:

* `daily_stats` — aggregation by `ad_date` with a derived `romi` (`total_value / total_spend`)
* time-series line charts of daily ad spend and daily ROMI for 2021
* `campaign_stats` — spend, revenue, and ROMI per campaign, with labelled bar charts sorted by each measure
* distribution analysis — box plot of ROMI by campaign and a ROMI histogram
* correlation heatmap across all numeric measures (spend, impressions, clicks, revenue, CPC, CPM, CTR, ROMI) and an `lmplot()` scatter of revenue against spend with a regression line

The same metric vocabulary as my [Marketing Performance Analysis](../marketing_performance_analysis/README.md) project (CTR, CPC, CPM, ROMI) — here computed in pandas instead of SQL.

---

## What this section is for

Recruiters ask whether the Python on my CV is real. It is at coursework level: I can load, clean, reshape, group, and visualise a dataset in pandas, and I read the output rather than just producing it. I am not yet presenting Python as the tool behind a finished business deliverable — when that changes, it will appear as a full project above rather than as notebooks here.
