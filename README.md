# 🏦 Indian Loan Finance — SQL Data Analysis Project

> A complete end-to-end SQL analytics project built on a **synthetic Indian banking dataset** covering 867,000+ records across 8 relational tables. Designed to simulate real-world loan lifecycle management, credit risk analysis, EMI collection, and NPA recovery operations.

---

## 📌 Project Overview

This project generates and analyses a realistic Indian bank loan portfolio using pure SQL. It covers everything from basic data retrieval to advanced window functions, CTEs, stored procedures, and BI-ready views — making it suitable for data analyst portfolios, SQL interview preparation, and banking domain learning.

**Database:** MySQL 8.0+  
**Domain:** Banking & Finance — Retail Lending  
**Difficulty range:** Beginner → Advanced  
**Total queries:** 63 analytical SQL queries

---

## 📂 Repository Structure

```
indian-loan-finance-sql/
│
├── data/
│   ├── 00_MASTER_SCHEMA.sql          # All CREATE TABLE statements (load first)
│   ├── 01_branches.sql               # 120 bank branches across India
│   ├── 02_loan_products.sql          # 22 loan products (Home, Personal, Gold, etc.)
│   ├── 03_customers.sql              # 3,200 customers with realistic Indian profiles
│   ├── 04_loan_applications.sql      # 52,000 loan applications
│   ├── 05_loans.sql                  # 32,000 disbursed loans
│   ├── 06a_emi_payments_part1.sql    # EMI payments — Part 1 (~382K rows)
│   ├── 06b_emi_payments_part2.sql    # EMI payments — Part 2 (~382K rows)
│   ├── 07_guarantors.sql             # 10,000 guarantor records
│   └── 08_loan_recovery.sql          # NPA recovery cases
│
├── analysis/
│   └── loan_data_analysis.sql        # 63 SQL queries (Easy → Advanced)
│
└── README.md
```

---

## 🗄️ Database Schema

### Entity Relationship Overview

```
branches (120)
    │
    ├──< customers (3,200)
    │       └──< loan_applications (52,000)
    │
    ├──< loan_applications (52,000)
    │       └──< loans (32,000)
    │
loan_products (22) ──< loan_applications
                   └──< loans
                           ├──< emi_payments (764,000+)
                           ├──< guarantors (10,000)
                           └──< loan_recovery (5,500+)
```

### Tables at a Glance

| Table | Rows | Key Columns |
|-------|------|-------------|
| `branches` | 120 | branch_id, bank_name, city, state, ifsc_code |
| `loan_products` | 22 | product_id, product_code, interest_rate_min/max |
| `customers` | 3,200 | customer_id, credit_score, annual_income, occupation |
| `loan_applications` | 52,000 | application_id, status, loan_amount_requested |
| `loans` | 32,000 | loan_id, loan_status, days_past_due, emi_amount |
| `emi_payments` | 764,000+ | payment_id, payment_status, paid_amount, penalty |
| `guarantors` | 10,000 | guarantor_id, relationship, credit_score |
| `loan_recovery` | 5,500+ | recovery_action, amount_recovered, recovery_status |

---

## 📊 Dataset Characteristics

| Metric | Value |
|--------|-------|
| Total records | ~867,000 |
| Date range | 2015 – 2024 |
| Loan amount range | ₹50,000 – ₹50,00,000 |
| Credit score range | 300 – 900 |
| Rejection rate | ~9.1% |
| Default rate | ~4.5% |
| Late payment rate | ~15.0% |
| Indian states covered | 28 |
| Bank brands | 20 |

**Loan products included:** Home Loan · Personal Loan · Vehicle Loan · Education Loan · Business Loan · Gold Loan · Agricultural Loan · Loan Against Property · MSME Loan · Consumer Durable · PMAY · Kisan Credit Card · Mudra (Shishu / Kishore / Tarun) · Staff Loan · Working Capital · Plot Loan · Overdraft · Top Up · Flexi Loan

---

## 🔍 SQL Analysis — Query Index

The file `analysis/loan_data_analysis.sql` contains **63 queries** organized by difficulty.

### 🟢 Easy (Q1–Q12) — Basic SELECT, GROUP BY, WHERE
| # | Query |
|---|-------|
| 1 | List all branches with city, state and bank name |
| 2 | Count customers per state |
| 3 | Find all customers with credit score above 750 |
| 4 | List all active loan products with interest rate range |
| 5 | Count loan applications by status |
| 6 | Total loan amount disbursed per year |
| 7 | List customers with KYC status 'Pending' |
| 8 | Average credit score by occupation |
| 9 | Count EMI payments by payment status |
| 10 | List all loans in 'Default' status |
| 11 | Maximum and minimum loan amounts |
| 12 | Guarantors with their relationship to borrowers |

### 🟡 Medium (Q13–Q30) — JOINs, HAVING, Aggregations
| # | Query |
|---|-------|
| 13 | Rejection rate % per loan product |
| 14 | Branches with more than 500 loan applications |
| 15 | Top 10 customers by total loan amount |
| 16 | Monthly EMI collection trend for 2023 |
| 17 | Customers with both Home Loan and Personal Loan |
| 18 | Average days past due (DPD) per product |
| 19 | Loan accounts where outstanding > 70% of loan amount |
| 20 | States with highest default count |
| 21 | Processing fee revenue per branch |
| 22 | Loans where EMI was missed 3 or more times |
| 23 | Low-income customers with high-value loans |
| 24 | Total penalty collected per year |
| 25 | Customers applying for loans multiple times |
| 26 | Average EMI by product and tenor bucket |
| 27 | Active loans per branch with DENSE_RANK |
| 28 | Recovery cases where recovered amount is zero |
| 29 | Top 5 loan officers by approvals |
| 30 | Collection efficiency % per branch |

### 🟠 Hard (Q31–Q46) — Window Functions, CTEs, PAR Analysis
| # | Query |
|---|-------|
| 31 | Portfolio at Risk — PAR30, PAR60, PAR90 by product |
| 32 | Cohort analysis — default rate by disbursement year |
| 33 | Running total of EMI collections (cumulative sum) |
| 34 | At-risk customers: missed > 2 EMIs + DPD 30–89 |
| 35 | Month-over-month disbursement growth rate |
| 36 | Top 3 branches per state by loan volume |
| 37 | Customer lifetime value (total interest paid) |
| 38 | Suspicious application patterns by branch + date |
| 39 | Customers where EMI > 50% of monthly income |
| 40 | NPA migration report by quarter |
| 41 | EMI bounce rate trend over 24 months |
| 42 | Guarantors linked to more than 2 customers |
| 43 | Weighted average interest rate of loan portfolio |
| 44 | Branch concentration risk (> 20% of portfolio) |
| 45 | Average application-to-disbursement TAT per product |
| 46 | Recovery rate % by action type — effectiveness ranking |

### 🔴 Advanced (Q47–Q63) — Stored Procedures, Recursive CTEs, JSON, BI Views
| # | Query |
|---|-------|
| 47 | Credit risk scorecard — AAA to D risk tiers |
| 48 | Recursive CTE — loan restructuring chain |
| 49 | Pivot: EMI payment status as columns per product |
| 50 | Stored procedure — complete loan amortisation statement |
| 51 | First missed EMI number per loan (early stress signal) |
| 52 | Duplicate Aadhar number detection — data quality check |
| 53 | Branch composite performance score (weighted KPIs) |
| 54 | Loan seasoning analysis — default rate by loan age |
| 55 | Cross-sell opportunity — Home Loan customers without Personal Loan |
| 56 | FOIR calculation — flag over-leveraged customers (> 55%) |
| 57 | EMI payment seasonality by calendar month |
| 58 | Customer net profitability (interest earned vs recovery cost) |
| 59 | Customer loan summary as nested JSON output |
| 60 | 3-month sliding average default rate per branch |
| 61 | Rule-based next-month default prediction flag |
| 62 | EMI schedule reconciliation — detect missing payment records |
| 63 | Master BI dashboard view joining all 8 tables |

---

## ⚙️ How to Set Up

### Prerequisites
- MySQL 8.0 or higher (window functions and CTEs required)
- MySQL Workbench, DBeaver, or any SQL client
- ~500 MB free disk space

### Step 1 — Create the database
```sql
CREATE DATABASE indian_loan_finance;
USE indian_loan_finance;
```

### Step 2 — Load the schema
```sql
SOURCE data/00_MASTER_SCHEMA.sql;
```

### Step 3 — Load data in order (referential integrity)
```sql
SOURCE data/01_branches.sql;
SOURCE data/02_loan_products.sql;
SOURCE data/03_customers.sql;
SOURCE data/04_loan_applications.sql;
SOURCE data/05_loans.sql;
SOURCE data/06a_emi_payments_part1.sql;
SOURCE data/06b_emi_payments_part2.sql;
SOURCE data/07_guarantors.sql;
SOURCE data/08_loan_recovery.sql;
```

> ⚠️ The EMI payment files are large (~47 MB each). Increase `max_allowed_packet` if needed:
> ```sql
> SET GLOBAL max_allowed_packet = 256 * 1024 * 1024;
> ```

### Step 4 — Run the analysis
```sql
SOURCE analysis/loan_data_analysis.sql;
```

---

## 💡 Key SQL Concepts Demonstrated

| Concept | Queries |
|---------|---------|
| `GROUP BY` + `HAVING` | Q2, Q14, Q22, Q25, Q42 |
| Multi-table `JOIN` | Q12, Q15, Q18, Q20, Q30 |
| `CASE WHEN` aggregation | Q31, Q32, Q49, Q54, Q61 |
| Window functions (`RANK`, `DENSE_RANK`, `LAG`, `SUM OVER`) | Q27, Q33, Q35, Q36, Q46, Q60 |
| Common Table Expressions (CTE) | Q33, Q35, Q36, Q44, Q47 |
| Recursive CTE | Q48 |
| Subqueries | Q34, Q55, Q63 |
| `NULLIF` / `COALESCE` | Q31, Q43, Q56, Q58 |
| `DATE_FORMAT`, `YEAR()`, `QUARTER()`, `DATEDIFF()` | Q16, Q35, Q40, Q45 |
| `GROUP_CONCAT` | Q40, Q42 |
| `JSON_OBJECT` / `JSON_ARRAYAGG` | Q59 |
| Stored Procedure with Cursor | Q50 |
| `CREATE VIEW` | Q63 |
| Data quality checks | Q52, Q62 |

---

## 🏦 Banking Domain Concepts Covered

| Concept | Description |
|---------|-------------|
| **PAR (Portfolio at Risk)** | Outstanding amount overdue > 30/60/90 days |
| **NPA (Non-Performing Asset)** | Loan unpaid for 90+ days — classified under RBI norms |
| **DPD (Days Past Due)** | Number of days since a payment was missed |
| **FOIR (Fixed Obligation to Income Ratio)** | Total EMIs / Monthly income — should be < 55% |
| **GNPA / NNPA** | Gross NPA / Net NPA — portfolio stress indicators |
| **Cohort Analysis** | Tracking default rates by loan origination year |
| **Loan Seasoning** | Risk profile by loan age (months since disbursement) |
| **TAT (Turnaround Time)** | Days from application to disbursement |
| **OTS (One Time Settlement)** | Negotiated settlement for NPA recovery |
| **SARFAESI Action** | Legal asset recovery mechanism under Indian law |
| **Kisan Credit Card** | Short-term agricultural credit product |
| **PMAY** | Pradhan Mantri Awas Yojana — government housing scheme |
| **Mudra Loans** | Micro-enterprise loans under PMMY scheme |

---

## 📈 Sample Query Output Snapshots

**Q31 — PAR Analysis (Portfolio at Risk)**
```
product_name          | total_loans | par30_pct | par60_pct | par90_pct
----------------------|-------------|-----------|-----------|----------
Personal Loan         |    4,821    |   8.34%   |   5.12%   |   3.67%
Business Loan         |    3,204    |   7.91%   |   4.88%   |   3.21%
Home Loan             |    6,112    |   4.23%   |   2.44%   |   1.87%
```

**Q47 — Credit Risk Scorecard**
```
full_name        | credit_score | max_dpd | risk_tier
-----------------|--------------|---------|------------------
Rahul Sharma     |     812      |    0    | AAA - Very Low Risk
Priya Patel      |     724      |   15    | AA - Low Risk
Amit Gupta       |     581      |   45    | B - Elevated Risk
Sunita Yadav     |     423      |  210    | D - Very High Risk
```

---

## 🛠️ Tools & Technologies

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange)
![Banking Domain](https://img.shields.io/badge/Domain-Banking%20%26%20Finance-green)
![Data Size](https://img.shields.io/badge/Records-867K%2B-red)
![Python](https://img.shields.io/badge/Data%20Generated%20with-Python-yellow?logo=python)

- **MySQL 8.0** — primary database engine
- **Python 3.12** — synthetic data generation script (`generate_loan_data.py`)
- **MySQL Workbench / DBeaver** — recommended SQL clients
- Compatible with **Power BI**, **Tableau**, and **Excel** via ODBC connection

---

## 🎯 Who Is This For?

- **SQL learners** building towards intermediate and advanced proficiency
- **Data analysts** looking for a realistic portfolio project
- **Banking domain aspirants** learning BFSI terminology and KPIs
- **Data engineering students** working with large-scale relational datasets
- **Interview preparation** for SQL-heavy data analyst and BI developer roles

---

## 📝 Data Disclaimer

All data in this project is **100% synthetic and fictional**. Names, Aadhar numbers, PAN numbers, phone numbers, and financial figures are randomly generated and do not represent any real individual, bank, or financial institution. This dataset is intended solely for educational and portfolio purposes.

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add new analytical queries
- Improve existing queries with better performance
- Add Power BI / Tableau dashboard files
- Report issues or suggest enhancements

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 👤 Author

**[Your Name]**  
Aspiring Data Analyst | SQL | Power BI | Python  
[LinkedIn](https://linkedin.com/in/jaiprkh) · [GitHub](https://github.com/jaiprkh)

---

*If you find this project useful, please consider giving it a ⭐ on GitHub!*
