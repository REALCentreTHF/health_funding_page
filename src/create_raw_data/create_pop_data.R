CreateData <- function() {
  pop_link2 <- Rpublic::extract_links(pop_link,paste0('2011',latest_pop_year))
  data <- Rpublic::extract_sheets(paste0('www.ons.gov.uk/',pop_link2),'MYEB2')
  dat <- data[["MYEB2"]]
  names(dat) <- dat[1,]
  
  dat2 <- dat[-1,] |> 
    dplyr::select(age,country,starts_with('population')) |> 
    tidyr::pivot_longer(cols=!c(country,age),names_to='date',values_to='population') |> 
    dplyr::mutate(population = as.numeric(population),
                  type = 'midyear',
                  date = as.integer(stringr::str_extract(date,'(\\d)+'))) |> 
    dplyr::group_by(country,age,date,type) |> 
    dplyr::summarise(
      population = sum(population,na.rm=T)
    )
  
  return(dat2)
}

population_data <- CreateData()
rm(CreateData)

