GetData <- function(){
  dat <- read.csv(old_deflator_url) |> 
    _[-c(1:7),] |> 
    dplyr::rename(date=1,
                  gdp_deflator = 2) |> 
    dplyr::mutate(gdp_deflator = (as.numeric(gdp_deflator)+100)/100,
                  date = as.integer(date)) |> 
    dplyr::arrange(date) |> 
    dplyr::mutate(deflator = cumprod(gdp_deflator))
  
  return(dat)
  
}

old_deflator_series <- GetData()
rm(GetData)
