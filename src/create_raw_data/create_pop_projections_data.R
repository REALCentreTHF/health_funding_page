CreateData <- function() {
  #dat <- read.csv('const/pop_proj_data.csv') |> 
  dat <- readxl::read_excel(
    "const/en_ppp_machine_readable.xlsx",
    sheet = "Population"
  ) |>
    dplyr::rename(sex = Sex, age = Age) |>
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
      #date = as.integer(substr(date,2,5))
      date = as.integer(date)
    ) |> 
    dplyr::filter(date > 2025) # was 2023

  return(dat)
}

pop_proj_data <- CreateData()
rm(CreateData)
