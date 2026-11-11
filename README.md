# Health care funding page
Last updated: November 2026

## Overview

This repository contains code to produce the [health care funding page](https://www.health.org.uk/reports-and-analysis/analysis/health-care-funding) produced by the Economics team (formerly the REAL Centre).

## Quick start
Before you get started (**only the first time** you open the project), type in 
```
renv::restore()
```

After you have updated the variables in `glob.R`, then run:
```
source("src/main.R")
```

The outputs produced will be generated in `outputs/`. Note that we do not have a separate script to create Figure 1, as Table 1 and Figure 1 draw on the same estimates produced by `src/create_figures/create_table_1.R`.

## Adjustments
There are five main adjustments we make to DHSC RDEL:
- **nics_adjustment_m** (Employer National Insurance Contributions): this is hard-coded and not changed for each fiscal event (unless the fiscal event includes a change to the employer NICs rate).
- **pension_2019_adjustment_m** and **pension_2024_adjustment_m**: these adjustments reflect changes in the NHS employer pension contribution rate in 2019 and 2024 and are hard-coded. For the 2026 Autumn Budget update, the team used pre-adjusted DHSC RDEL in the Budget document (as the employer contribution rate will change in 2027), so no further adjustment was needed. For future fiscal events, if DHSC stops publishing the pre-adjusted planned RDEL, you will need to add a new adjustment to reflect this.
- **redundancies**: adjustments to cover restructuring and reform funding made for 2025/26 and 2026/27 only and should be 0 for subsequent years (unless transfers to DHSC to cover redundancies are announced in the fiscal event).
- **planned_treasury**: adjustment for inter-departmental transfers. This should be 0 in outturn years and -1610 in planned years (including the current financial year). For outturn years, the Budget document will already reflect the actual value of inter-departmental transfers. For the current financial year, we need to subtract transfers already reflected in the DHSC Main Estimate. For subsequent years (after the current financial year), we use the default Treasury estimate of inter-departmental transfers (as no better data is available).
- **main_estimates_transfers**: adjustment for inter-departmental transfers in the current financial year ONLY, based on the DHSC Main Estimate (see above).

In general, the main values you will need to change are **main_estimates_transfers** and **planned_treasury**. Changes to other values will generally be reflected in the supplementary documents published by HMT (on Budget day) and should be double-checked with Stephen Rocks and Sally Gainsbury (Nuffield Trust) if possible.

## Historic values (in glob.R)
These are for reference only.
### RDEL
|             | 2024/25 | 2025/26 | 2026/27 | 2027/28 | 2028/29 |
| ----------- | ------- | ------- | ------- | ------- | ------- |
| Autumn 2026 | 193,200 | 204,100 | 212,500 | 221,200 | 231,100 |
| Spring 2026 | 193,200 | 204,500 | 211,400 | 221,300 | 231,200 |
### CDEL
|             | 2024/25 | 2025/26 | 2026/27 | 2027/28 | 2028/29 |
| ----------- | ------- | ------- | ------- | ------- | ------- |
| Autumn 2026 | 11,500  | 13,300  | 13,800  | 13,500  | 14,500  |
| Spring 2026 | 11,600  | 13,600  | 14,000  | 13,800  | 14,800  |

## Data sources
- "an additional £1.61bn will be allocated to the NHS annually": [Spending Review 2025 unrounded departmental Resource DEL, Capital DEL and Total DEL tables](https://assets.publishing.service.gov.uk/media/685bf942c07c71e5a870981b/SR25_Department_DEL_tables.xlsx), Table 5.3, comment on "Total adjustments"
- "an additional £0.43bn earmarked for restructuring and reform funding": [2026-27 DHSC Main Estimate](https://committees.parliament.uk/publications/52967/documents/295399/default/), page 7
- "excluding the £0.774bn tranche already incorporated": [2026-27 DHSC Main Estimate](https://committees.parliament.uk/publications/52967/documents/295399/default/), page 7
- Figure 3 age and population weighting: [OBR September 2024 Fiscal risks and sustainability report](https://obr.uk/frs/fiscal-risks-and-sustainability-september-2024/), Chapter 3 Chart 3.11.

## Contact
For more information, please reach out to Eric Yang (eric.yang@health.org.uk) or Jack Elliott (jack.elliott@health.org.uk).