CreateData <- function() {
  pop_proj_link2 <- Rpublic::extract_links(pop_proj_link,latest_pop_proj_year)
  data <- Rpublic::extract_sheets(paste0('www.ons.gov.uk/',pop_proj_link2),'PERSONS')
  dat <- data[["PERSONS"]]
  names(dat) <- dat[6,] 

  dat2 <- dat |> 
    dplyr::filter(Components == 'Population at end') |> 
    dplyr::mutate(type = 'midyear') |> 
    dplyr::select(!c(1:2)) |> 
    tidyr::pivot_longer(cols=!type,names_to='date',values_to='projected_population') |> 
    dplyr::mutate(projected_population = as.numeric(projected_population))
  
  return(dat2)
}

pop_proj_data <- CreateData()
rm(CreateData)
