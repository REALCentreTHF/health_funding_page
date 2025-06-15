GetData <- function(){
  
  dat1 <- output_budget_data |> 
    dplyr::filter(budget_type == 'dhsc_tdel_less_pensions') |> 
    dplyr::select(date,cash_values) |> 
    dplyr::rename(dhsc_tdel = cash_values) |> 
    dplyr::mutate(dhsc_tdel = dhsc_tdel / 1000) |> 
    dplyr::filter(date > 2014)
  
  dat2 <- purrr::map(
    .x = govt_list,
    .f = function(.x){
      out <- historic_dhsc_tdel_data |> 
        dplyr::select(!type) |> 
        dplyr::filter(date <= 2014) |> 
        rbind(dat1) |> 
        dplyr::filter(date %in% .x) |> 
        dplyr::rowwise() |> 
        CashToReal(
          deflator_data = old_deflator_series,
          baseline_year = baseline_year,
          mutate_col = 'dhsc_tdel'
        ) 
        
      return(out)
    }
  ) |> 
    dplyr::bind_rows(
      .id = 'id'
    ) |> 
    dplyr::rename(
      govt_simple='id'
    )
  
  max_precovid_value <- (dat2[dat2$date == fig_3_max_year,]$dhsc_tdel / dat2[dat2$date == min(dat2$date),]$dhsc_tdel)^(1/(fig_3_max_year - min(dat2$date)-1))-1
  
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
    ) |> 
    dplyr::add_row(
      start_date = 1979,
      start_tdel = 0,
      govt_simple = 'Long-run Pre-Covid',
      end_date = fig_3_max_year,
      end_tdel = 0,
      cagr = max_precovid_value
    )
  return(dat4)
}

fig_3 <- GetData()
rm(GetData)
