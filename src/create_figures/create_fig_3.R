# Analysis to produce Figure 3 outputs
# Indexed to 2013/14 = 1

CreateFigure3 <- function(
    population_data,
    pop_proj_data,
    age_cost_data,
    output_budget_data,
    end_year,
    index_base_year = 2013L
) {
  fail <- function(...) stop("Figure 3: ", ..., call. = FALSE)
  show_values <- function(x) paste(sort(unique(x), na.last = TRUE), collapse = ", ")
  
  check_columns <- function(data, required, label) {
    missing <- setdiff(required, names(data))
    if (length(missing) > 0L) {
      fail(label, " is missing columns: ", show_values(missing))
    }
  }
  
  check_integers <- function(x, label) {
    if (!is.numeric(x) || any(!is.finite(x) | x < 0 | x != floor(x))) {
      fail(label, " must contain finite, non-negative whole numbers.")
    }
  }
  
  check_values <- function(x, label, positive = FALSE) {
    if (!is.numeric(x) || any(!is.finite(x))) {
      fail(label, " must contain finite numeric values with no missing values.")
    }
    if (any(if (positive) x <= 0 else x < 0)) {
      fail(label, if (positive) " must be strictly positive." else " must be non-negative.")
    }
  }
  
  check_coverage <- function(years, label) {
    missing <- setdiff(required_years, years)
    if (length(missing) > 0L) {
      fail(label, " is missing required years: ", show_values(missing))
    }
  }
  
  if (length(index_base_year) != 1L || length(end_year) != 1L) {
    fail("index_base_year and end_year must each be a single year.")
  }
  check_integers(index_base_year, "index_base_year")
  check_integers(end_year, "end_year")
  if (end_year < index_base_year) fail("end_year must not precede index_base_year.")
  required_years <- seq.int(index_base_year, end_year)
  
  # Validate age labels before collapsing ages 101+ into the top band.
  # The supplied projection workbook uses single ages, "105 - 109" and "110 and over". Other aggregate labels require an explicit method.
  prepare_population <- function(data, label) {
    check_columns(data, c("country", "date", "age", "population"), label)
    data <- data |>
      dplyr::ungroup() |>
      dplyr::filter(country == "E")
    
    check_integers(data$date, paste(label, "years"))
    data <- data |>
      dplyr::filter(date %in% required_years) |>
      dplyr::transmute(
        date = as.integer(date),
        age_label = trimws(tolower(as.character(age))),
        population
      )
    check_values(data$population, paste(label, "values"))
    
    age_key <- gsub("[[:space:]]+", "", data$age_label)
    single_age <- !is.na(age_key) & grepl("^[0-9]+$", age_key)
    known_group <- age_key %in% c("105-109", "110andover")
    invalid <- is.na(age_key) | !(single_age | known_group)
    if (any(invalid)) {
      fail("Unrecognised age labels in ", label, ": ",
           show_values(data$age_label[invalid]),
           ". Expected single ages, '105 - 109' or '110 and over'.")
    }
    
    lower <- rep(NA_real_, nrow(data))
    lower[single_age] <- as.numeric(age_key[single_age])
    lower[age_key %in% "105-109"] <- 105
    lower[age_key %in% "110andover"] <- 110
    check_integers(lower, paste(label, "ages"))
    
    upper <- lower
    upper[age_key %in% "105-109"] <- 109
    upper[age_key %in% "110andover"] <- Inf
    
    # Check duplicates/overlapping source bands BEFORE top-coding.
    # Distinct ages such as 101 and 102 share the final band.
    data <- data |>
      dplyr::mutate(age_lower = lower, age_upper = upper) |>
      dplyr::arrange(date, age_lower, age_upper) |>
      dplyr::group_by(date) |>
      dplyr::mutate(
        overlaps = age_lower <= dplyr::lag(cummax(age_upper), default = -Inf)
      ) |>
      dplyr::ungroup()
    
    if (any(data$overlaps)) {
      fail("Overlapping age bands or duplicate rows in ", label,
           " for years: ", show_values(data$date[data$overlaps]))
    }
    
    data |>
      dplyr::mutate(age = as.integer(pmin(age_lower, 101))) |>
      dplyr::group_by(date, age) |>
      dplyr::summarise(population = sum(population), .groups = "drop")
  }
  
  observed <- prepare_population(population_data, "observed population")
  projected <- prepare_population(pop_proj_data, "projected population")
  
  overlap_years <- intersect(observed$date, projected$date)
  if (length(overlap_years) > 0L) {
    fail("Observed and projected population overlap in years: ",
         show_values(overlap_years),
         ". Update the projection cutoff in create_pop_projections_data.R.")
  }
  
  population <- dplyr::bind_rows(observed, projected)
  check_coverage(population$date, "Population data")
  
  # Require one valid weight for every population age used in the figure.
  check_columns(age_cost_data, c("age", "age_cost_weight"), "Age-cost data")
  weights <- age_cost_data |>
    dplyr::ungroup() |>
    dplyr::select(age, age_cost_weight)
  check_integers(weights$age, "Age-cost ages")
  check_values(weights$age_cost_weight, "Age-cost weights", positive = TRUE)
  
  if (anyDuplicated(weights$age)) {
    fail("Duplicate ages in age-cost data: ",
         show_values(weights$age[duplicated(weights$age)]))
  }
  if (!30 %in% weights$age) fail("Age-cost data must include age 30.")
  
  missing_ages <- setdiff(population$age, weights$age)
  if (length(missing_ages) > 0L) {
    fail("Missing age-cost weights for ages: ", show_values(missing_ages))
  }
  
  age_30_weight <- weights$age_cost_weight[weights$age == 30]
  weights <- weights |>
    dplyr::mutate(age_cost_weight = age_cost_weight / age_30_weight)
  
  annual_population <- population |>
    dplyr::left_join(weights, by = "age", relationship = "many-to-one") |>
    dplyr::mutate(population_age_weighted = population * age_cost_weight) |>
    dplyr::group_by(date) |>
    dplyr::summarise(
      population = sum(population),
      population_age_weighted = sum(population_age_weighted),
      .groups = "drop"
    )
  check_values(annual_population$population, "Annual population", positive = TRUE)
  check_values(annual_population$population_age_weighted,
               "Annual age-weighted population", positive = TRUE)
  
  # Require the full spending period, then use the explicit index base.
  check_columns(output_budget_data,
                c("date", "budget_type", "real_values", "cash_values"),
                "Budget data")
  spending <- output_budget_data |>
    dplyr::ungroup() |>
    dplyr::filter(budget_type == "dhsc_rdel_less_pensions")
  check_integers(spending$date, "Spending years")
  spending <- spending |>
    dplyr::filter(date %in% required_years) |>
    dplyr::select(date, real_values, cash_values)
  
  if (anyDuplicated(spending$date)) {
    fail("Duplicate spending years: ",
         show_values(spending$date[duplicated(spending$date)]))
  }
  check_coverage(spending$date, "Spending data")
  check_values(spending$real_values, "Real spending", positive = TRUE)
  check_values(spending$cash_values, "Cash spending", positive = TRUE)
  
  series_cols <- c("real_values", "cash_values", "real_per_capita", "real_age_weighted")
  series <- spending |>
    dplyr::left_join(annual_population, by = "date", relationship = "one-to-one") |>
    dplyr::mutate(
      real_per_capita = real_values / population,
      real_age_weighted = real_values / population_age_weighted
    ) |>
    dplyr::select(date, dplyr::all_of(series_cols)) |>
    dplyr::arrange(date)
  check_values(as.matrix(series[series_cols]), "Figure values", positive = TRUE)
  
  base_row <- match(index_base_year, series$date)
  result <- series |>
    dplyr::mutate(
      date = as.integer(date),
      dplyr::across(dplyr::all_of(series_cols), ~ .x / .x[base_row])
    )
  check_values(as.matrix(result[series_cols]), "Figure indices", positive = TRUE)
  result
}

# The index base is distinct from baseline_year, the real-price base in glob.R.
# end_year comes from glob.R; e.g. 2031 requests coverage through 2031/32.
fig_3 <- CreateFigure3(
  population_data = population_data,
  pop_proj_data = pop_proj_data,
  age_cost_data = age_cost_data,
  output_budget_data = output_budget_data,
  end_year = end_year,
  index_base_year = 2013L
)

# Calculate CAGR for real, real per capita, and real age-adjusted DHSC funding
fig3_start_year <- 2013
fig3_end_year <- 2028

fig3_cagr <- sapply(fig_3[, 2:5], function(x) {
  start_value <- x[fig_3$date == fig3_start_year]
  end_value <- x[fig_3$date == fig3_end_year]
  
  (end_value / start_value)^(1 / (fig3_end_year - fig3_start_year)) - 1
})


