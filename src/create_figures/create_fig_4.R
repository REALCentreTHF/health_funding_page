GetData <- function(){
  
  test<-population_data |> 
    dplyr::filter(country == 'E') |> 
    dplyr::mutate(age = as.integer(age)) |> 
    dplyr::left_join(age_cost_data) |> 
    dplyr::mutate(
      age_cost_weight = age_cost_weight/age_cost_data[age_cost_data$age == 30,]$age_cost_weight,
      population_age_weighted = age_cost_weight * population
    ) |> 
    dplyr::group_by(
      date
    ) |> 
    dplyr::summarise(
      population = sum(population,na.rm=T),
      population_age_weighted = sum(population_age_weighted,na.rm=T)
    )
  
  test2 <- output_budget_data |> 
    dplyr::filter(budget_type == 'nhse_rdel') |> 
    dplyr::select(date,real_values,cash_values) |> 
    dplyr::left_join(test) |> 
    dplyr::mutate(
      real_per_capita = real_values / population,
      real_age_weighted = real_values / population_age_weighted
    ) |> 
    tidyr::drop_na() |> 
    dplyr::arrange(date) |> 
    dplyr::select(date,real_values,cash_values,real_per_capita,real_age_weighted) |> 
    tidyr::pivot_longer(cols=!date,names_to='names',values_to='values')
  
  test3 <- test2 |> 
    dplyr::left_join(
      test2 |> 
        dplyr::group_by(names) |> 
        dplyr::filter(date == min(date)) |> 
        dplyr::rename(begin_val = values) |> 
        dplyr::select(names,begin_val) 
    ) |> 
    dplyr::mutate(index = values / begin_val) |> 
    dplyr::select(date,names,index) |> 
    tidyr::pivot_wider(names_from=names,values_from=index)

  return(test3)
}

fig_4 <- GetData()
rm(GetData)
