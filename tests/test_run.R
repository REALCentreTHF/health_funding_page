install.packages('jinjar')
library(jinjar)

params <- list(
data=2019
)

test <- 'Growth of DHSC TDEL (real) between 2018 and 2020 was {{data}}' 

data <- GetCAGR(data=output_cagr_table,
             cagr_start_year = 2019,
             cagr_end_year = 2023,
             cagr_money='real_values',
             cagr_budget_type='dhsc_tdel')

jinjar::render(test, !!!params)
