GetData <- function(){
  # Nominal figures: unadjusted budgets, using cash_values.
  nominal_data <- output_budget_data |>
    dplyr::ungroup() |>
    dplyr::filter(
      date %in% 2025:2028,
      budget_type %in% c("dhsc_rdel", "dhsc_cdel", "dhsc_tdel")
    ) |>
    dplyr::transmute(
      funding_type = dplyr::recode(
        budget_type,
        dhsc_rdel = "DHSC revenue",
        dhsc_cdel = "DHSC capital",
        dhsc_tdel = "DHSC total"
      ),
      date,
      basis = "Nominal",
      value = cash_values / 1000
    )
  
  # Real figures: adjusted revenue/total budgets, using real_values.
  real_data <- output_budget_data |>
    dplyr::ungroup() |>
    dplyr::filter(
      date %in% 2025:2028,
      budget_type %in% c(
        "dhsc_rdel_less_pensions",
        "dhsc_cdel",
        "dhsc_tdel_less_pensions"
      )
    ) |>
    dplyr::transmute(
      funding_type = dplyr::recode(
        budget_type,
        dhsc_rdel_less_pensions = "DHSC revenue",
        dhsc_cdel = "DHSC capital",
        dhsc_tdel_less_pensions = "DHSC total"
      ),
      date,
      basis = "Real",
      value = real_values / 1000
    )
  
  # Combine and arrange into a table.
  table_1 <- dplyr::bind_rows(nominal_data, real_data) |>
    dplyr::mutate(
      financial_year = paste0(date, "/", substr(date + 1, 3, 4)),
      funding_type = factor(
        funding_type,
        levels = c("DHSC revenue", "DHSC capital", "DHSC total")
      )
    ) |>
    dplyr::arrange(basis, date) |>
    dplyr::select(funding_type, basis, financial_year, value) |>
    tidyr::pivot_wider(
      names_from = c(basis, financial_year),
      values_from = value,
      names_glue = "{basis}_{financial_year}"
    ) |>
    dplyr::arrange(funding_type)
  
  table_1_unadjusted <- output_budget_data |>
    dplyr::ungroup() |>
    dplyr::filter(
      date %in% 2025:2028,
      budget_type %in% c("dhsc_rdel", "dhsc_cdel", "dhsc_tdel")
    ) |>
    dplyr::transmute(
      funding_type = dplyr::recode(
        budget_type,
        dhsc_rdel = "DHSC revenue",
        dhsc_cdel = "DHSC capital",
        dhsc_tdel = "DHSC total"
      ),
      financial_year = paste0(date, "/", substr(date + 1, 3, 4)),
      Nominal = cash_values / 1000,
      Real = real_values / 1000
    ) |>
    tidyr::pivot_longer(
      cols = c(Nominal, Real),
      names_to = "basis",
      values_to = "value"
    ) |>
    dplyr::mutate(
      funding_type = factor(
        funding_type,
        levels = c("DHSC revenue", "DHSC capital", "DHSC total")
      )
    ) |>
    dplyr::arrange(basis, financial_year) |>
    tidyr::pivot_wider(
      names_from = c(basis, financial_year),
      values_from = value,
      names_glue = "{basis}_{financial_year}"
    ) |>
    dplyr::arrange(funding_type)
  
  real_growth_2025_2028 <- output_cagr_table |>
    dplyr::ungroup() |>
    dplyr::filter(
      start_year == 2025,
      end_year == 2028,
      money == "real_values",
      budget_type %in% c(
        "dhsc_rdel_less_pensions",
        "dhsc_cdel",
        "dhsc_tdel_less_pensions"
      )
    ) |>
    dplyr::transmute(
      funding_type = dplyr::recode(
        budget_type,
        dhsc_rdel_less_pensions = "DHSC revenue",
        dhsc_cdel = "DHSC capital",
        dhsc_tdel_less_pensions = "DHSC total"
      ),
      cagr_percent = cagr * 100
    )
  
  real_growth_unadjusted <- output_cagr_table |>
    dplyr::ungroup() |>
    dplyr::filter(
      start_year == 2025,
      end_year == 2028,
      money == "real_values",
      budget_type %in% c("dhsc_rdel", "dhsc_cdel", "dhsc_tdel")
    ) |>
    dplyr::transmute(
      funding_type = dplyr::recode(
        budget_type,
        dhsc_rdel = "DHSC revenue",
        dhsc_cdel = "DHSC capital",
        dhsc_tdel = "DHSC total"
      ),
      start_year_value,
      end_year_value,
      cagr_percent = cagr * 100
    )
  
  table_1 <- table_1 |>
    dplyr::left_join(
      real_growth_2025_2028 |>
        dplyr::select(funding_type, cagr_percent),
      by = "funding_type"
    )
}
table_1 <- GetData()
rm(GetData)