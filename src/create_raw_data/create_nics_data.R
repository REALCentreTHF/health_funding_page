nics_adjustments <- expand.grid(
  date = c(start_year:end_year),
  type = 'fyear',
  pod = 'NICS',
  #This is assumed to be constant. I don't like this and I don't know where it
  #came from but it was there since the dawn of time and i was told to include it.
  values = nics_adjustment_value*1000
) |> 
  dplyr::mutate(
    values=dplyr::case_when(
      date <= 2024 ~ 0,
      T ~ nics_adjustment_value
    )
  )
