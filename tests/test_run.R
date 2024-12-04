install.packages('jinjar')
library(jinjar)

funding_page <- "How much funding has been committed to health care?

The Department of Health and Social Care’s overall budget (known as DHSC TDEL) sets the limit on overall health funding in England. It is made up of revenue (RDEL) and capital (CDEL) funding. The {{ current_budget_name }} set new funding plans for DHSC in {{ final_budget_year }} {{ updated_planned_figures }} following the most recent Supplementary Estimates (the mechanism by which government departments request additional in-year funding from parliament). {{additional_issues}}

The Autumn Budget confirmed planned DHSC TDEL of {{current_budget_year_dhsc_tdel}} in {{ current_budget_year }}. {{current_dhsc_tdel_minus_last_budget_dhsc_tdel}}. The planned budget for {{final_budget_year}} is {{end_year_dhsc_tdel}}, an increase of {{end_year_dhsc_tdel_minus_current_budget_year}} compared with {{current_budget_year}}. Once this is adjusted for inflation and in-year budget transfers are incorporated, the average annual increase is {{ annual_dhsc_tdel_cagr }} in real terms."

params <- list(
current_budget_name = 'Autumn 2024 Budget',
final_budget_year = '2025/26',
updated_planned_figures = 'Nothing else',
additional_issues = 'Nothing else',
current_dhsc_tdel_minus_last_budget_dhsc_tdel = '£14bn',
current_budget_year = '2024/25',
end_year_dhsc_tdel = '£241bn',
annual_dhsc_tdel_cagr = '3.2%',
current_budget_year_dhsc_tdel = '£201bn',
end_year_dhsc_tdel_minus_current_budget_year = '£13bn'
)

expand.grid(
  'start_year' = c(2009:2026),
  'end_year' = c(2009:2026),
  'start_year_budget' = NA,
  'end_year_budget' = NA,
  'budget_type' = c('DHSC CDEL','NHS RDEL','Other RDEL','DHSC TDEL'),
  'change_absolute' = NA,
  'change_cagr' = NA
)

jinjar::render(funding_page, !!!params)
