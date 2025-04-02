CreateData <- function() {
  dat <- read.csv('const/pop_proj_data.csv') |> 
    tidyr::pivot_longer(
      cols = !c(age,sex),
      names_to='date',
      values_to='population'
    ) |> 
    dplyr::group_by(age,date) |> 
    dplyr::summarise(population=sum(population,na.rm=T)) |> 
    dplyr::mutate(
      country = 'E',
      type = 'midyear',
      date = as.integer(substr(date,2,5))
    ) |> 
    dplyr::filter(date > 2023)

  return(dat)
}

pop_proj_data <- CreateData()
rm(CreateData)
