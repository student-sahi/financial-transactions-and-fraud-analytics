# Financial Transaction & Fraud Analytics Dashboard

An end-to-end **Power BI** project that analyzes **250,000 card transactions** to measure fraud exposure, identify where fraud concentrates, and test whether existing risk signals (merchant risk level, channel, payment method) actually predict it.

> **Tools:** Power BI · DAX · Power Query · Data Modeling (Star Schema)
> **Domain:** Banking / Fintech · Risk & Fraud Analytics
> **Period covered:** Jan 2023 – Aug 2026

---

## Table of Contents

1. [Business Problem](#1-business-problem)
2. [Objectives](#2-objectives)
3. [Dataset](#3-dataset)
4. [Data Model](#4-data-model)
5. [Data Preparation](#5-data-preparation)
6. [DAX Measures](#6-dax-measures)
7. [Dashboard Pages](#7-dashboard-pages)
8. [Key Insights](#8-key-insights)
9. [Recommendations](#9-recommendations)
10. [Limitations](#10-limitations)
11. [How to Run](#11-how-to-run)
12. [Repository Structure](#12-repository-structure)
13. [Skills Demonstrated](#13-skills-demonstrated)
14. [Author](#14-author)

---

## 1. Business Problem

Card fraud directly erodes revenue and customer trust. A bank or payments company needs to know **where** fraud occurs, **how much** it costs, and **which controls work**. This project builds an interactive dashboard that answers those questions from transaction-level data.

## 2. Objectives

- Track overall transaction volume, value and fraud performance, including year-over-year (YoY) change.
- Quantify fraud in both **cases** and **rupee value**.
- Identify the transaction, geographic and customer segments where fraud is most concentrated.
- Evaluate whether merchant risk tiers, channels and payment methods are useful fraud predictors.
- Provide clear, data-backed recommendations for fraud controls.

## 3. Dataset

The dataset is stored in four related tables:

| Table | Rows | Description |
|---|---|---|
| `Transaction_Data_250k` | 250,000 | Transaction ID, date/time, amount, payment method, channel, device, status, international flag, fraud flag, fraud reason, amount bucket |
| `Customer_Data` | 25,000 | Demographics, occupation, annual income, customer segment, account type, state/city |
| `Cards_Data` | 32,457 | Card type, network, credit limit, card status, contactless, card mode, issue/expiry dates |
| `merchant_table` | 500 | Merchant name, category, state/city, risk level, rating, status |

A separate `Calendar` table supports time-intelligence calculations.

> The data appears to be synthetic (for example, several fraud rates are uniform across categories and some fraud reasons are labelled 100% fraud by rule). It is used here to demonstrate analytical and BI skills, not to draw conclusions about a real institution.

## 4. Data Model

The model follows a **star schema** with one fact table and three dimension tables, all with many-to-one, single-direction relationships:

```
Customer_Data ──┐
                ├──< Transaction_Data_250k >── merchant_table
Cards_Data ─────┘            │
                          Calendar
```

| Relationship | Key | Cardinality |
|---|---|---|
| Transaction → Customer | `Customer_ID` | Many-to-one |
| Transaction → Card | `Card_ID` | Many-to-one |
| Transaction → Merchant | `Merchant_ID` | Many-to-one |
| Transaction → Calendar | `Transaction_Date` | Many-to-one |

## 5. Data Preparation

Performed in **Power Query**:

- Checked data types and set correct types for dates, times, amounts and flags.
- Created an `Amount_Bucket` column (for example 5K, 5–15K, 16–30K, up to 100K+) to analyze fraud by transaction size.
- Created an `International Vs Domestic` label from the `Is_International` flag for readable visuals.
- Built a `Calendar` table with `Month` and `Monthnum` for time-series analysis and correct month sorting.

## 6. DAX Measures

| Measure | Purpose |
|---|---|
| `Total_Transactions` | `COUNTROWS` of the fact table |
| `Total_Amount` | Sum of `Transaction_Amount` |
| `Fraudlent Transactions` | Sum of `Fraud_Flag` |
| `Fraud_rate` | Fraud cases ÷ total transactions |
| `Fraud_Amount` | Transaction value where `Fraud_Flag = 1` |
| `Unique_cust` | Customer count |
| `PY_*` measures | Prior-year values using `SAMEPERIODLASTYEAR` |
| `YOY_Amount %`, `YOY _Transaction %`, `YOY_Fraud Transaction %`, `YOY_Fraud_amount %`, `Yoy cust Growth` | Year-over-year growth using `DIVIDE` |

## 7. Dashboard Pages

### Page 1: Overview
Executive summary of transaction activity: KPI cards with YoY change, monthly amount trend (area chart), transactions by payment method, card type by credit limit, account/card distribution, card status, and channel-wise amount. Slicers for date and transaction status.

### Page 2: Fraud Analysis
The core analytical page: fraud KPIs (cases, amount, rate, YoY change), fraud-rate trend over time, fraud rate by international vs domestic, fraud rate by amount bucket, fraud value by fraud reason, and merchant risk level by payment method. Slicers for date, year and transaction status.

### Page 3: Transactions
Drill-down detail table (customer, segment, merchant, category, payment method, channel, amount, date, status) with date and customer-name slicers, so an analyst can investigate individual records.

Navigation buttons link all three pages.

## 8. Key Insights

All figures below were recalculated from the data model.

| # | Insight |
|---|---|
| 1 | **Overall exposure:** 13,473 fraud cases (5.4% of transactions) worth **₹105 Cr, about 25% of the ₹415 Cr** total transaction value. |
| 2 | **High-value concentration:** Transactions above ₹100K are only **1.5% of volume** but have a **58% fraud rate** and carry **₹84 Cr (80%)** of fraud value. |
| 3 | **Credit-limit alerts drive loss:** "Unusual High Transaction Amount vs Credit Limit" accounts for ~73% of fraud value from only ~13% of fraud cases. |
| 4 | **International risk:** International transactions have a **19.7% fraud rate vs 4.6% domestic (4.3x)** and make up 5% of volume but 18% of fraud cases. |
| 5 | **Merchant risk tiers do not predict fraud:** High-risk merchants show a 5.3% fraud rate versus 5.4% for low-risk merchants. Channel and payment-method rates are also near-identical (5.3–5.6%). |
| 6 | **Detection gap:** About 77% of fraud cases were declined or failed, but **3,147 fraud transactions (₹37 Cr) still succeeded**, including 2,312 above ₹100K. |
| 7 | **No improvement over time:** The fraud rate is ~5.4% every year from 2023 to 2026. |


## 8. Repository Structure

```
Financial-Fraud-Analytics/
├── Financial_Fraud.pbix     # Power BI report
├── README.md                # Project documentation
├── screenshots/             # Dashboard images (add here)
│   ├── overview.png
│   ├── fraud_analysis.png
│   └── transactions.png
└── data/                    # Source data (if sharing is permitted)
```

## 9. Skills Demonstrated

- Star-schema data modeling and relationship design
- DAX: aggregations, `CALCULATE`, `FILTER`, `DIVIDE`, and time intelligence (`SAMEPERIODLASTYEAR`)
- Power Query data cleaning and feature creation
- KPI design and dashboard storytelling
- Fraud and risk analytics: segmentation, concentration analysis, control evaluation
- Translating findings into business recommendations


**Sahil Mhaske**
Aspiring Data Analyst | Power BI · SQL · Excel
[LinkedIn](https://linkedin.com/in/your-profile) · [GitHub](https://github.com/your-username) · your.email@example.com
