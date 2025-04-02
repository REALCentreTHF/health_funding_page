GetData <- function(){

pesa_data2<-pesa_data |> 
  dplyr::mutate(values=as.numeric(values)) |> 
  dplyr::select(!pesa_year) |> 
  rbind(nhs_rdel) |> 
  dplyr::select(!department) |> 
  dplyr::filter(date <= latest_outtrun_year) |> 
  rbind(planned_budget_data,pension_adjustments) |> 
  tidyr::pivot_wider(names_from=pod,values_from=values) |> 
  dplyr::rowwise() |> 
  janitor::clean_names() |> 
  dplyr::mutate(
    planned_or_outtrun = dplyr::case_when(
      date <= latest_outtrun_year ~ 'outtrun',
      T ~ 'planned'
    ),
    dhsc_tdel = dplyr::case_when(is.na(dhsc_tdel)==T ~ cdel + dhsc_rdel,
                                 T ~ dhsc_tdel),
    other_rdel = dhsc_rdel - nhse_rdel
  ) |> 
  janitor::clean_names() |> 
  dplyr::mutate(
    pensions = 1000 * pensions,
    other_rdel = dhsc_rdel - nhse_rdel,
    dhsc_rdel_less_pensions = dhsc_rdel - pensions,
    nhse_rdel_less_pensions = nhse_rdel - pensions, 
    dhsc_tdel_less_pensions = dhsc_tdel - pensions
  ) |> 
  dplyr::filter(date >= 2013) 

pesa_data3 <- pesa_data2 |> 
  tidyr::pivot_longer(
    cols = !c(date,type,planned_or_outtrun),
    names_to='budget_type',
    values_to='cash_values'
  ) |>
  dplyr::mutate(real_values = cash_values) |> 
  CashToReal(
    deflator_data = old_deflator_series,
    baseline_year = baseline_year,
    mutate_col = 'real_values'
  ) 

return(pesa_data3)
}

CAGRData <- function(){
  
  cagr_table<-expand.grid(
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
                      start_planned_outtrun = planned_or_outtrun) |> 
        dplyr::select(!c(deflator_index)),
      by = c('budget_type','start_year','money')
    ) |> 
    #adds the end_year
    dplyr::left_join(
      output_budget_data |> 
        tidyr::pivot_longer(cols=c(cash_values,real_values),names_to='money',values_to='values') |> 
        dplyr::rename(end_year_value = values,
                      end_year = date,
                      end_planned_outtrun = planned_or_outtrun) |> 
        dplyr::select(!deflator_index),
      by = c('budget_type','end_year','type','money')
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
