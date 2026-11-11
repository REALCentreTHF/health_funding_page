GetData <- function(){
  real_budget_table <- output_budget_data |> 
    dplyr::select(date,budget_type,real_values) |> 
    tidyr::pivot_wider(names_from = 'budget_type',values_from='real_values') |> 
    dplyr::filter(date >= 2019)
  
  cash_budget_table <- output_budget_data |> 
    dplyr::select(date,budget_type,cash_values) |> 
    tidyr::pivot_wider(names_from = 'budget_type',values_from='cash_values') |> 
    dplyr::filter(date >= 2019)
  
  return(
    list(
      cash_table = cash_budget_table,
      real_table = real_budget_table
    )
  )
}

fig_1 <- GetData()
rm(GetData)