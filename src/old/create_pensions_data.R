pension_adjustments <- expand.grid(
  date = c(start_year:end_year),
  type = 'fyear',
  pod = 'Pensions',
  #This is assumed to be constant. I don't like this and I don't know where it
  #came from but it was there since the dawn of time and i was told to include it.
  values = 0
) |> 
  dplyr::mutate(
    values=dplyr::case_when(
      date >=2025 ~ (pension_2019_adjustment_value + pension_2024_adjustment_value)*1000,
      date <= 2018 ~ 0,
      T ~ (pension_2019_adjustment_value)*1000
    )
  )
