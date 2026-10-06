# Health care funding page

## Overview

This repository contains code to produce the [health care funding page](https://www.health.org.uk/reports-and-analysis/analysis/health-care-funding) produced by the REAL Centre. The page is built using a jinjaR-based template, with data updated after every fiscal event.

## Backlog
- Revisit long-run average in Figure 3 to be potentially inclusive of COVID
- Change Figure 3 to focus on DHSC rather than NHS funding (given the upcoming abolition of NHS England, so budget documents no longer contain a separate line for NHS England RDEL)

## Guide

To run the page, only two things are needed as it has been largely automated:
1.	Go to glob.R and change the adjustable variables (latest months for efo/efs. This is not automated as we occasionally want to specify a specific efo for ad-hoc analysis.) Also ensure you change the planned DHSC RDELS and CDELS.
a.	Important to note that NHSE’s decommissioning means that we no longer report on NHS RDEL, so if no data is forthcoming do not worry. Now we only report on DHSC RDEL/TDEL but I kept it for posterity. 
b.	You will notice a vector called adjustments with some hardcoded values called pensions and nics adjustments. This comes from ad-hoc transfers and adjustments that need to be made in order to ensure the budget is directly comparable. They are typically done in consultation with Sally G. from Nuffield or from conversations with treasury.
2. You will need to run src/main code after glob which is the main source of the code.
3.	The outputs will be generated in health_funding_page/outputs/.
