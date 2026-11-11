CashToReal <- function(x,
                       deflator_data,
                       baseline_year,
                       mutate_col = "values") {
  
  # Required years include input years and baseline year
  required_years <- unique(c(x$date, baseline_year))
  
  # Find matching deflator values
  matched_deflators <- deflator_data$deflator[
    match(required_years, deflator_data$date)
  ]
  
  # Check for missing years or NA deflator values
  missing_years <- required_years[
    is.na(required_years) | is.na(matched_deflators)
  ]
  
  if (length(missing_years) > 0L) {
    stop(
      "Missing or NA deflator values for years: ",
      paste(missing_years, collapse = ", "),
      call. = FALSE
    )
  }
  
  # Extract baseline deflator
  baseline_deflator <- deflator_data$deflator[
    match(baseline_year, deflator_data$date)
  ]
  
  # Calculate real values
  deflated_data <- x |>
    dplyr::left_join(
      deflator_data,
      by = "date"
    ) |>
    dplyr::mutate(
      deflator_index = baseline_deflator / deflator,
      !!mutate_col := .data[[mutate_col]] * deflator_index
    ) |>
    dplyr::select(-dplyr::any_of(c("deflator", "gdp_deflator")))
  
  return(deflated_data)
}

ChangeDeflatorYear <- function(x,year_col='fyear',deflator_data, baseline_year,mutate_col,original_year){
  
  deflator <- deflator_data
  
  deflated_data <- x |> 
    dplyr::left_join(deflator,
                     by = c('fyear'=year_col)) |> 
    dplyr::mutate(
      deflator_index =  deflator[deflator$fyear == baseline_year,]$values / deflator[deflator$fyear == original_year,]$values,
      !!mutate_col := !!rlang::sym(mutate_col) * deflator_index) |> 
    dplyr::select(!c(values,deflator_index))
  
  return(deflated_data)
}

GetCAGR <- function(
    data,
    cagr_start_year,
    cagr_end_year,
    cagr_budget_type,
    cagr_money
){
  cagr <- data |> 
    dplyr::filter(
      start_year == cagr_start_year,
      end_year == cagr_end_year,
      money == cagr_money,
      budget_type == cagr_budget_type) |> 
        _$cagr
  
  return(cagr)
}



