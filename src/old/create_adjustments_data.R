other_adjustments_data <- expand.grid(
  date = c(start_year:end_year),
  type = 'fyear',
  pod = 'Adjustments',
  #This is assumed to be constant. I don't like this and I don't know where it
  #came from but it was there since the dawn of time and i was told to include it.
  values = 0
)

other_adjustments_data$values <- adjustments
