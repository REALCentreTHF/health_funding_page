GetData <- function(){
  
  old_deflator_link <- Rpublic::extract_links(old_deflator_url,paste0('september','-',latest_efo_year),ignore.case=T)
  
  old_deflator_link2 <- Rpublic::extract_links(paste0('https://www.gov.uk/',old_deflator_link),'.xls')
  
  dat <- Rpublic::extract_sheets(old_deflator_link2,'deflator')[[1]] |> 
    _[-c(1:4),] |> 
    dplyr::rename(date=1,
                  gdp_deflator = 3) |> 
    dplyr::select(date,gdp_deflator) |> 
    dplyr::mutate(gdp_deflator = (as.numeric(gdp_deflator)+100)/100,
                  date = as.integer(substr(date,1,4))) |> 
    tidyr::drop_na() |> 
    dplyr::arrange(date) |> 
    dplyr::mutate(deflator = cumprod(gdp_deflator))
  
  return(dat)
  
}

old_deflator_series <- GetData()
rm(GetData)
