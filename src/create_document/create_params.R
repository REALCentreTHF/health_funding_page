GetData <- function(){

map_list <- output_cagr_table |> 
  dplyr::mutate(type = paste0(money,'_',budget_type,'_',start_year,'_',end_year),
                difference = end_year_value - start_year_value)

map_list2 <- output_cagr_table |> 
  dplyr::select(start_year,budget_type,money,start_year_value) |> 
  unique() |> 
  dplyr::mutate(type = paste0(money,'_',budget_type,'_',start_year))

params <- setNames(as.list(map_list$cagr), nm =paste0(map_list$type,'_cagr'))
params_2 <- setNames(as.list(map_list$difference), nm =paste0(map_list$type,'_difference'))
params_3 <- setNames(as.list(map_list2$start_year_value), nm =map_list2$type)

fin <- c(params,params_2,params_3)
return(fin)
}

params <- GetData()
rm(GetData)
