GetData <- function(){
dhsc_tdel <- dhsc_data[[1]] |> 
  dplyr::filter(department == 'Health and Social Care') |> 
  dplyr::select(!department)

cdel <- dhsc_data[[2]] |> 
  dplyr::filter(department == 'Health and Social Care')|> 
  dplyr::select(!department)

dhsc_rdel <- dhsc_data[[3]] |> 
  dplyr::filter(department == 'Health and Social Care')|> 
  dplyr::select(!department)

test2<-rbind(dhsc_tdel,cdel,dhsc_rdel,nhs_rdel) |> 
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
    other_rdel = dhsc_rdel - nhse_rdel,
    dhsc_rdel_less_pensions = dhsc_rdel - pensions,
    nhse_rdel_less_pensions = nhse_rdel - pensions
  ) |> 
  dplyr::filter(date >= start_year)

output_budget_data <- test2 |> 
  tidyr::pivot_longer(
    cols = !c(date,type,planned_or_outtrun),
    names_to='budget_type',
    values_to='cash_values'
  ) |>
  dplyr::mutate(real_values = cash_values) |> 
  CashToReal(
    deflator_data = deflator |> dplyr::select(!type),
    baseline_year = baseline_year,
    mutate_col = 'real_values'
  ) 

#OLD DATASET 2017 ---------

test2_old<-historic_dhsc_data |> 
  dplyr::mutate(values=as.numeric(values)) |> 
  dplyr::select(!pesa_year) |> 
  rbind(nhs_rdel) |> 
  dplyr::filter(date <= latest_outtrun_year-4) |> 
  dplyr::select(!department) |> 
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
  dplyr::filter(date >= 2013)

output_budget_data_old <- test2_old |> 
  tidyr::pivot_longer(
    cols = !c(date,type,planned_or_outtrun),
    names_to='budget_type',
    values_to='cash_values'
  ) |>
  dplyr::mutate(real_values = cash_values) |> 
  CashToReal(
    deflator_data = deflator |> dplyr::select(!type),
    baseline_year = baseline_year,
    mutate_col = 'real_values'
  ) 

fin_output <- rbind(output_budget_data,output_budget_data_old)
return(fin_output)
}

output_budget_data <- GetData()
rm(GetData)
