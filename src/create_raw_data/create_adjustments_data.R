# Builds a tibble spanning start_year to end_year with values of all RDEL adjustments in £m.

# NOTES:
# Positive adjustments are SUBTRACTED from RDEL, while negative adjustments are ADDED
# As of the 2026 Autumn Budget, the only negative adjustment is HMT's estimate of planned transfers (£1610m)
# All other transfers should be entered as positive values and subtracted from RDEL


adjustment_years <- seq.int(start_year, end_year)

component_cols <- c(
  "redundancies",
  "main_estimates_transfers",
  "planned_treasury"
)

# Check that every required future year has an explicit assumption
missing_years <- setdiff(
  adjustment_years[
    adjustment_years >= other_adjustments_start_year
  ],
  other_adjustment_components_m$date
)

if (length(missing_years) > 0) {
  stop(
    "Missing adjustment assumptions for: ",
    paste(missing_years, collapse = ", ")
  )
}

# Validate the supplied component data
stopifnot(
  all(component_cols %in% names(other_adjustment_components_m)),
  !anyNA(other_adjustment_components_m$date),
  anyDuplicated(other_adjustment_components_m$date) == 0L,
  all(vapply(
    other_adjustment_components_m[component_cols],
    is.numeric,
    logical(1)
  )),
  all(is.finite(as.matrix(
    other_adjustment_components_m[component_cols]
  )))
)

# Build the adjustment components for every financial year
adjustment_components_m <- other_adjustment_components_m |>
  dplyr::filter(date %in% adjustment_years) |>
  tidyr::complete(
    date = adjustment_years,
    fill = list(
      redundancies = 0,
      main_estimates_transfers = 0,
      planned_treasury = 0
    ),
    explicit = FALSE
  ) |>
  dplyr::mutate(
    pension_2019 = (date >= pension_2019_start_year) *
      pension_2019_adjustment_m,
    
    pension_2024 = (date >= pension_2024_start_year) *
      pension_2024_adjustment_m,
    
    nics = (date >= nics_start_year) *
      nics_adjustment_m
  )

# Reshape components and aggregate into three adjustment categories
adjustments_data_m <- adjustment_components_m |>
  tidyr::pivot_longer(
    cols = -date,
    names_to = "component",
    values_to = "value_m"
  ) |>
  dplyr::mutate(
    pod = dplyr::case_when(
      component %in% c("pension_2019", "pension_2024") ~ "pensions",
      component == "nics" ~ "nics",
      TRUE ~ "other_adjustments"
    )
  ) |>
  dplyr::group_by(date, pod) |>
  dplyr::summarise(
    values = sum(value_m),
    .groups = "drop"
  )
