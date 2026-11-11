## QA log
Last completed: 11/11/26

### Methodological decisions
- Change from NHS RDEL to DHSC RDEL in Figure 3
- Change in adjustments in glob.R 
- Use of "pre-adjusted plans" rather than plans (to net out technical adjustment for pensions, which do not reflect actual increase in DHSC spending power as confirmed by HMT)
- Use of combined HMT/OBR deflator vintage with 2026 as "switch" year in glob.R and create_deflator_data (previously we used the OBR series for Table 1/Figure 3 and the combined HMT/OBR deflator series only for Figure 2). Note that the historical GDP deflator series published by HMT and OBR differ slightly (for the 2026 Autumn Budget, the HMT release included Blue Book 2026 but the OBR economy forecast closed on 8 September 2026).

### Consistencies with previous versions
- `pension_2024_adjustment_value` is applied from 2025/26, not 2024/25
- The long-run pre-COVID average spreads 1979.80 to 2019/20 over 39 periods (not 40)
- Each government's bar starts in the year before its first full year in office.

### Checklist
- `latest_efo_month` and `efo_report_url` point to the right EFO
- `baseline_year` is the correct financial year (i.e. October 2026 means 2026)
- `planned_dhsc_rdel` in `const/glob.R` matches Budget 2026 Table B.1 (in £m)
- `planned_cdel` in `const/glob.R` matches Budget 2026 Table B.2 (in £m)
- `latest_pop_year` is the latest ONS mid-year estimate
- Correct PESA table numbers are read in `create_pesa_data.R`, with RDEL excluding depreciation, and only the DEL row "Health and Social Care" row is read (not AME)
- TDEL = RDEL + CDEL for every year
- CashToReal only uses 2026/27 prices
- Check CAGR uses correct intervals

### Manual spot-check calculations
- Table 1, 2025/26, real RDEL
- Table 1, 2028/29, real RDEL
- Table 1 real RDEL CAGR