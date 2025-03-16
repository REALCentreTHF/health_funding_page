CashToReal <- function(x,
                       deflator_data,
                       baseline_year,
                       mutate_col = 'values'){
  
  deflated_data <- x |> 
    dplyr::left_join(deflator_data,
                     by = 'date') |> 
    dplyr::mutate(
      deflator_index =  dplyr::case_when(
        is.na(deflator)==T ~ 1,
        T ~ deflator_data[deflator_data$date == baseline_year,]$deflator / deflator),
      !!mutate_col := !!rlang::sym(mutate_col) * deflator_index) |> 
    dplyr::select(!c(deflator,gdp_deflator))
  
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

GetValue <- function(
    data,
    year,
    cagr_budget_type,
    cagr_money
){
  cagr <- data |> 
    dplyr::filter(
      start_year == year,
      end_year == cagr_end_year,
      money == cagr_money,
      budget_type == cagr_budget_type) |> 
    _$start_year_value
  
  return(cagr)
}

GetDifference <- function(
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
    dplyr::mutate(diff = end_year_value - start_year_value) |> 
    _$diff
  
  return(cagr)
}

