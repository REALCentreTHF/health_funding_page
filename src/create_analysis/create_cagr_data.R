GetData <- function(){

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

output_cagr_table <- GetData()
rm(GetData)
