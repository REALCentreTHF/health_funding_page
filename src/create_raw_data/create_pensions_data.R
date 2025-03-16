pension_adjustments <- expand.grid(
  date = c(start_year:end_year),
  type = 'fyear',
  pod = 'Pensions',
  #This is assumed to be constant. I don't like this and I don't know where it
  #came from but it was there since the dawn of time and i was told to include it.
  values = pensions_adjustment_value*1000
)
