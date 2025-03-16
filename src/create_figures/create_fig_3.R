GetData <- function(){
  
  dat1 <- output_budget_data |> 
    dplyr::filter(budget_type == 'dhsc_tdel') |> 
    dplyr::select(date,cash_values) |> 
    dplyr::rename(dhsc_tdel = cash_values) |> 
    dplyr::mutate(dhsc_tdel = dhsc_tdel / 1000) |> 
    dplyr::filter(date > max(historic_dhsc_tdel_data$date))
  
  dat2 <- historic_dhsc_tdel_data |> 
    dplyr::select(!type) |> 
    rbind(dat1) |> 
    dplyr::rowwise() |> 
    dplyr::mutate(
      govt = unlist(govt_list)[grepl(pattern = date,x = unlist(govt_list))] |> names(),
      govt_simple = gsub('[[:digit:]]+', '', govt)
    ) |> 
    CashToReal(
      deflator_data = old_deflator_series,
      baseline_year = baseline_year,
      mutate_col = 'dhsc_tdel'
    )
  
  dat3 <- dat2 |> 
    dplyr::group_by(govt_simple) |> 
    dplyr::filter(date == min(date)|
                  date == max(date)) |> 
    dplyr::mutate(
      year_end_start = dplyr::case_when(
        date == min(date) ~ 'start_govt',
        date == max(date) ~ 'end_govt'
      )
    ) |> 
    dplyr::select(date,dhsc_tdel,govt_simple,year_end_start)
  
  dat4 <- dat3 |> 
    dplyr::filter(year_end_start=='start_govt') |> 
    dplyr::rename(start_tdel=dhsc_tdel,
                  start_date = date) |> 
    dplyr::select(!year_end_start) |> 
    dplyr::left_join(dat3 |> 
                       dplyr::filter(year_end_start=='end_govt') |> 
                       dplyr::rename(end_tdel=dhsc_tdel,
                                     end_date = date) |> 
                       dplyr::select(!year_end_start),
                     by = c('govt_simple')) |> 
    dplyr::rowwise() |> 
    dplyr::mutate(
      cagr = (end_tdel /start_tdel)^(1/(end_date-start_date))-1
    )
  return(dat4)
}

fig_3 <- GetData()
rm(GetData)