# Produces a tibble of historic and planned DHSC RDEL, CDEL and TDEL
# Used in Table 1 and all figures

GetData <- function(){

  pesa_data2 <- pesa_data |> 
    dplyr::mutate(values=as.numeric(values)) |> 
    dplyr::select(!c(department, pesa_year)) |> 
    dplyr::filter(date <= first_year_sr) |> # This is correct and should NOT be latest_outturn_year. This is to avoid changing the vector length as each Spending Review period progresses
    rbind(planned_budget_data, adjustments_data_m) |> 
    tidyr::pivot_wider(names_from=pod,values_from=values) |> 
    dplyr::mutate(
      planned_or_outturn = dplyr::case_when(
        date <= latest_outturn_year ~ 'outturn',
        TRUE ~ 'planned'
      ),
      dhsc_tdel = dplyr::case_when(
        is.na(dhsc_tdel) ~ dhsc_cdel + dhsc_rdel,
        TRUE ~ dhsc_tdel
        )
    ) |> 
    dplyr::mutate(
      pensions =  pensions,
      nics = nics,
      dhsc_rdel_less_pensions = dhsc_rdel - pensions - nics - other_adjustments,
      dhsc_tdel_less_pensions = dhsc_tdel - pensions - nics - other_adjustments
    ) |> 
    dplyr::filter(date >= 2013) # Start date for Figure 3
  
  pesa_data3 <- pesa_data2 |> 
    tidyr::pivot_longer(
      cols = !c(date,planned_or_outturn),
      names_to='budget_type',
      values_to='cash_values'
    ) |>
    dplyr::mutate(real_values = cash_values) |> 
    CashToReal(
      deflator_data = combined_deflator_series,
      baseline_year = baseline_year,
      mutate_col = 'real_values'
    ) 
  
  return(pesa_data3)
}

CAGRData <- function(){
  
  cagr_table <- expand.grid(
    'start_year' = c(start_year:end_year),
    'end_year' = c(start_year:end_year),
    'budget_type' = unique(output_budget_data$budget_type),
    'money' = c('real_values','cash_values')
  ) |> 
    #adds the start year
    dplyr::left_join(
      output_budget_data |> 
        tidyr::pivot_longer(cols=c(cash_values,real_values),names_to='money',values_to='values') |> 
        dplyr::rename(start_year_value = values,
                      start_year = date,
                      start_planned_outtrun = planned_or_outturn) |> 
        dplyr::select(!c(deflator_index)),
      by = c('budget_type','start_year','money')
    ) |> 
    #adds the end_year
    dplyr::left_join(
      output_budget_data |> 
        tidyr::pivot_longer(cols=c(cash_values,real_values),names_to='money',values_to='values') |> 
        dplyr::rename(end_year_value = values,
                      end_year = date,
                      end_planned_outtrun = planned_or_outturn) |> 
        dplyr::select(!deflator_index),
      by = c('budget_type','end_year','money')
    ) |> 
    #can't go backwards in time (unfortunately)
    dplyr::filter(end_year > start_year) |> 
    dplyr::mutate(
      cagr = (end_year_value/start_year_value)^(1/(end_year-start_year))-1
    )
  
  return(cagr_table)
}
output_budget_data <- GetData()
rm(GetData)

output_cagr_table <- CAGRData()
rm(CAGRData)
