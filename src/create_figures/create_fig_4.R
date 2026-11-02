GetData <- function(){
  
  test<-population_data |> 
    rbind(pop_proj_data) |> 
    dplyr::filter(country == 'E') |> 
    dplyr::mutate(age = dplyr::case_when(
                    is.na(as.integer(age)) == T | as.integer(age) >= 101 ~ 101,
                    T ~ as.integer(age)
                  )) |> 
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
    dplyr::filter(budget_type == 'dhsc_rdel_less_pensions') |>   
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
  
  # Calculate CAGR
  start_year <- 2013
  end_year <- 2028
  
  # Calculate CAGR for columns B–E
  cagr <- sapply(test3[, 2:5], function(x) {
    start_value <- x[test3$date == start_year]
    end_value <- x[test3$date == end_year]
    
    (end_value / start_value)^(1 / (end_year - start_year)) - 1
  })
  
  # Display CAGR as percentages
  round(cagr * 100, 2)

  return(test3)
}

fig_4 <- GetData()
rm(GetData)
