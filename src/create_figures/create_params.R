GetData <- function(){

map_list <- output_cagr_table |> 
  dplyr::mutate(type = paste0(money,'_',budget_type,'_',start_year,'_',end_year),
                difference = end_year_value - start_year_value)

map_list2 <- output_cagr_table |> 
  dplyr::select(end_year,budget_type,money,end_year_value) |> 
  unique() |> 
  dplyr::rowwise() |> 
  dplyr::mutate(type = paste0(money,'_',budget_type,'_',end_year)) |> 
  unique()

params <- setNames(as.list(map_list$cagr), nm =paste0(map_list$type,'_cagr'))
params_2 <- setNames(as.list(map_list$difference), nm =paste0(map_list$type,'_difference'))
params_3 <- setNames(as.list(map_list2$end_year_value), nm =map_list2$type)

params_4 <- list(
  latest_efo_month=latest_efo_month,
  latest_pop_year=latest_pop_year,
  latest_pop_proj_year =latest_pop_proj_year,
  latest_pesa_year =latest_pesa_year,
  latest_budget_name =latest_budget_name,
  baseline_year = baseline_year,
  latest_outtrun_year =latest_outtrun_year,
  pensions_adjustment_value = pensions_adjustment_value,
  start_year = start_year,
  end_year = end_year
)

fin <- c(params,params_2,params_3,params_4)
return(fin)
}

output_params <- GetData()
rm(GetData)
