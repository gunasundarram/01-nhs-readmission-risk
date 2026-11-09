# 🏥 NHS 30-Day Readmission Risk Analysis

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Excel](https://img.shields.io/badge/Analysis-Excel-green)
![Tableau](https://img.shields.io/badge/Dashboard-Tableau%20Public-orange)
![Domain](https://img.shields.io/badge/Domain-Healthcare-red)

> **Project 01** of my data analytics portfolio | NHS Digital emergency readmissions, 2014/15 to 2024/25 | 155,573 provider records

![Dashboard preview](tableau/dashboard_preview.png)

👉 **[Open the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/gunasundar.ram.chandrasekhar.sholingaram/viz/NHS-Weekend-Admissions-Readmission-Analysis/Dashboard1)** · 🧮 [SQL queries](sql/) · 📊 [Excel cost model](excel/nhs_cost_model.xlsx)

---

## In 30 seconds

- **Question:** which NHS trusts, diagnosis groups and deprivation levels drive disproportionate 30-day emergency readmission, and what is the annual cost of closing the gap at the worst trusts?
- **Answer:** the variation is large and concentrated. **13 NHS trusts** with 5,000+ discharges sit at least 2.3 points above the England rate of 14.7%. Bringing the **three costliest trusts** down to the England average is worth about **£28.9 million a year** (£14.5 million if only half the gap is closed), and readmission rates climb steadily with deprivation (**15.4% vs 14.0%**).
- **Output:** a 4-visual Tableau Public dashboard, six PostgreSQL scripts, and a formula-driven Excel cost model with a sensitivity grid.
- **Skills shown:** SQL (CTEs, regex cleaning of text columns, window functions, cross-join baselines), Excel (formula model, scenario grid, reconciliation checks), Tableau Public, and judgement about what a number can and cannot support.

---

## Business question
Which NHS Trusts, diagnosis groups and deprivation levels drive disproportionate 30-day readmission rates, and what is the projected annual cost of closing the top 3 gaps?

## Headline findings
All rates are the published **standardised** percentages (see [How to read the rates](#how-to-read-the-rates)). England average, 2024/25: **14.7%**.

| # | Finding | Evidence | Caveat |
|---|---|---|---|
| 1 | **Midlands Partnership NHS Foundation Trust has the highest rate of any provider with at least 100 discharges: 25.4%, about 1.7 times England.** | 2,275 readmissions on 6,855 discharges. The only higher rate in the data (38.7%) belongs to a private hospital with 45 discharges. | Its discharges rose more than tenfold in 2023/24 (540 to 5,765), so its earlier history is not comparable. |
| 2 | **13 NHS trusts with 5,000+ discharges have a rate of 17.0% or more** (at least 2.3 points above England). | Ranking table below. Barking, Havering and Redbridge and Gloucestershire are tied at 18.8%. | The top-20 chart on the dashboard also includes independent-sector providers and small units; the table below keeps NHS trusts only. |
| 3 | **Barking, Havering and Redbridge rose from 12.7% (2014/15) to 18.8% (2024/25), +6.1 points.** | Peak of 19.6% in 2020/21, then 17.7%, 18.7%, 19.3%, 18.8%. | Not a straight line, and its discharges grew 50% in 2023/24, so read the last two years with care. |
| 4 | **Chesterfield Royal Hospital rose faster: 13.5% to 20.7%, +7.2 points,** and most of that came after 2019/20 (14.1%). | Highest rate among trusts with more than 40,000 discharges. | Trend of a standardised rate; it does not identify the cause. |
| 5 | **Closing the gap to England at the three costliest trusts is worth about £28.9 million a year.** | Barking £11.6m (4,147 excess readmissions), University Hospitals of North Midlands £8.9m (3,163), Gloucestershire £8.5m (3,019). Total 10,329 excess readmissions at £2,800 each. | One-year upper bound. Range £20.7m to £36.2m for £2,000 to £3,500 per readmission. See the [cost model](#cost-model). |
| 6 | **Readmission rises with deprivation, step by step.** | 15.4%, 15.0%, 14.6%, 14.2%, 14.0% from most to least deprived: a **1.4-point gap (10% higher)** across 1.5 million discharges in the most deprived group alone. | The indicator is deliberately not adjusted for deprivation. Matching the least deprived rate would mean about 21,600 fewer readmissions a year (indicative, same method as finding 5). |
| 7 | **Hip fracture patients are readmitted slightly more often than stroke patients: 12.6% vs 11.9%** (2023/24). | 7,024 of 55,898 hip fracture discharges and 8,294 of 69,835 stroke discharges. | Different year and indicator from the other findings, so not compared with 14.7%. |

### NHS trusts with the highest rates (2024/25, 5,000+ discharges)
Taken from the query 1 output. Any trust with 5,000+ discharges and a rate above 17.0% would appear in that top-20 list, so this table is complete.

| Rank | Trust | Standardised rate | Discharges |
|---|---|---|---|
| 1 | Midlands Partnership NHS Foundation Trust | 25.4% | 6,855 |
| 2 | Chesterfield Royal Hospital NHS Foundation Trust | 20.7% | 43,555 |
| 3 | Royal Surrey County Hospital NHS Foundation Trust | 19.3% | 42,515 |
| 4= | Barking, Havering and Redbridge University Hospitals NHS Trust | 18.8% | 101,155 |
| 4= | Gloucestershire Hospitals NHS Foundation Trust | 18.8% | 73,635 |
| 6 | Torbay and South Devon NHS Foundation Trust | 18.7% | 35,700 |
| 7 | Maidstone and Tunbridge Wells NHS Trust | 18.4% | 74,880 |
| 8 | University Hospitals of North Midlands NHS Trust | 17.9% | 98,850 |
| 9 | Portsmouth Hospitals NHS Trust | 17.7% | 65,730 |
| 10 | Lewisham and Greenwich NHS Trust | 17.5% | 63,560 |
| 11 | North West Anglia NHS Foundation Trust | 17.3% | 61,205 |
| 12 | Buckinghamshire Healthcare NHS Trust | 17.2% | 58,330 |
| 13 | Bradford Teaching Hospitals NHS Foundation Trust | 17.0% | 48,450 |

Rates and the trust with the highest *rate* are not the same as the trust with the highest *cost*. The cost ranking multiplies the gap by volume, which is why Barking, University Hospitals of North Midlands and Gloucestershire head the cost list and Midlands Partnership does not.

![Top 20 providers by standardised rate](<tableau/Top 20 Trusts.png>)
![10-year trend](<tableau/10 Year Trend.png>)

## How to read the rates
The published rate is an **indirectly standardised percentage** (adjusted for age, sex, method of admission and diagnosis or procedure). The readmission and discharge counts are **raw** (rounded to the nearest 5). So the rate does **not** equal readmissions divided by discharges, and the two should not be mixed:

| Trust | Published rate | Readmissions ÷ discharges |
|---|---|---|
| Midlands Partnership | 25.4% | 33.2% |
| Barking, Havering and Redbridge | 18.8% | 20.7% |

NHS Digital labels this series *experimental statistics*. Comparisons between trusts use the standardised rate; cost calculations multiply that rate gap by raw discharges, which is an approximation.

## Cost model
`excel/nhs_cost_model.xlsx` rebuilds query 4 as live Excel formulas and checks itself against the SQL output (all five trusts reconcile to the pound).

```
excess readmissions = discharges x (trust rate - England rate)
excess cost         = excess readmissions x £2,800
```

Annual saving at the top three trusts, by cost per readmission and share of the gap closed (£ million):

| Cost per readmission | 25% of gap | 50% | 75% | 100% |
|---|---|---|---|---|
| £2,000 | 5.2 | 10.3 | 15.5 | 20.7 |
| **£2,800 (reference cost)** | 7.2 | **14.5** | 21.7 | **28.9** |
| £3,500 | 9.0 | 18.1 | 27.1 | 36.2 |

The £2,800 is the NHS National Schedule of Reference Costs 2023/24 figure used throughout; the £2,000 and £3,500 rows are illustrative sensitivities, not published cost ranges.

![Cost projection](<tableau/Cost Projection.png>)

## Deprivation gradient
![Deprivation gap](<tableau/Depriviation Gap.png>)

## SQL scripts
| Script | Purpose |
|---|---|
| `01_top20_trusts.sql` | Top 20 providers by standardised rate, 2024/25 |
| `02_trust_trends.sql` | Year-by-year trend for Barking, Chesterfield and Midlands Partnership |
| `03_diagnosis_groups.sql` | Stroke and hip fracture rates, England, 2023/24 |
| `04_cost_projection.sql` | Excess readmissions and cost against the England average |
| `05_deprivation.sql` | Rate by deprivation quintile, 2024/25 |
| `06_data_checks.sql` | NHS-trusts-only ranking with crude vs standardised rates, year-on-year discharge changes, and banding counts: the checks that qualify the findings above |

## Recommendations
Hypotheses to test, not proven causes.

1. **Prioritise review by excess readmissions, not rank alone.** Barking, University Hospitals of North Midlands and Gloucestershire carry over 10,000 excess readmissions between them even though none has the highest rate.
2. **Check the reporting scope at Midlands Partnership before acting.** A tenfold jump in discharges in 2023/24 suggests a change in what is counted, which should be ruled out before treating 25.4% as a quality signal.
3. **Run a focused review at Chesterfield Royal.** It has the steepest sustained rise (+6.6 points since 2019/20) and the highest rate among large trusts.
4. **Target discharge support at the most deprived areas.** The gradient holds across all five quintiles, and the most deprived group alone accounts for about 21,600 readmissions above the least deprived rate.
5. **Compare condition pathways.** Hip fracture runs 0.7 points above stroke; pathway differences are a natural place to look for transferable practice.

## Assumptions and limitations
- **Standardised indicator:** adjusted for age, sex, method of admission and diagnosis or procedure, but not for deprivation. Rates are published to one decimal place and counts are rounded to the nearest 5.
- **Mixed provider types:** the query 1 output includes independent-sector providers and units with very few discharges (for example 45). Headline claims use providers with at least 100 discharges or, for trust rankings, 5,000+ discharges.
- **Query 4** ranks all providers by excess cost without a volume filter; its top 10 are all NHS trusts with more than 40,000 discharges, so small providers do not affect the result.
- **Coverage changes:** discharges change sharply in 2023/24 (Barking +50%, Chesterfield +15%, Midlands Partnership more than tenfold), and 2020/21 is a COVID year. Trend comparisons across those points need care.
- **Cost:** £2,800 per emergency readmission (NHS National Schedule of Reference Costs 2023/24); one-year, upper-bound illustration assuming a trust reaches the England average.
- **Diagnosis rates** are for 2023/24 and come from a separate indicator, so they are not compared with the all-cause 2024/25 rate.
- **Associations, not causes:** a high trust rate is a prompt for review, not evidence of poor care.

## Repository structure
```
01-nhs-readmission-risk/
├── data/        query1 to query5 result files (CSV)
├── excel/       nhs_readmissions_analysis.xlsx (summary and chart), nhs_cost_model.xlsx (formula model)
├── sql/         01 to 06 PostgreSQL scripts
├── tableau/     dashboard screenshots
└── README.md
```

## How to reproduce
1. Download the NHS Digital compendium data (indicators I02040 and I02041) from the [Emergency readmissions compendium](https://digital.nhs.uk/data-and-information/publications/statistical/compendium-emergency-readmissions).
2. In PostgreSQL create the tables `readmissions_provider` and `readmissions_diagnosis` and import the CSV files with **every column as text** (the queries clean values with regular expressions). Columns used: `level_description`, `level`, `year`, `breakdown`, `age_breakdown`, `sex_breakdown`, `method`, `indicator_value`, `numerator`, `denominator`, `banding`, and `diagnosis` for the diagnosis table.
3. Run `sql/01` to `sql/06` one query at a time (highlight, F5) and compare with the CSV files in `data/`.
4. Open `excel/nhs_cost_model.xlsx`; the check cells on the `Cost_Model` and `Sensitivity` sheets should read **OK**.

## Data source
NHS Digital, [Compendium: Emergency readmissions to hospital within 30 days of discharge](https://digital.nhs.uk/data-and-information/publications/statistical/compendium-emergency-readmissions), indicators I02040 and I02041, 2014/15 to 2024/25.

## More from my portfolio
- **Project 02**: [Olist Seller Survival Analysis](https://github.com/gunasundarram/02-olist-seller-survival) (SQL, Power BI)
- **Project 03**: [The Attrition Blindspot](https://github.com/gunasundarram/03-hr-attrition-blindspot) (SQL, Power BI, Python)
