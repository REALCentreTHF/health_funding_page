CreateData <- function(){
efo_link1<-Rpublic::extract_links(efo_link,paste0('efo/economic-and-fiscal-outlook-',tolower(latest_efo_month)))
efo_link2 <- Rpublic::extract_links(efo_link1,'detailed-forecast-tables-economy')

dat <- Rpublic::extract_sheets(
  files = efo_link2,
  pattern = '1.7'
)[['1.7']]

dat2 <- dat[,-1]
names(dat2) <- dat2[3,]
dat3 <- dat2[-c(1:3),] |> 
  janitor::clean_names() |> 
  dplyr::select(na,gdp_deflator) |> 
  tidyr::drop_na() |> 
  dplyr::rename('date'=na) |> 
  dplyr::mutate(
    type = dplyr::case_when(
      substr(x = date, start = nchar(date)-1, stop = nchar(date)-1) == 'Q' ~ 'quarter',
      substr(x = date, start = nchar(date)-2, stop = nchar(date)-2) == '-' ~ 'fyear',
      T ~ 'midyear'
    ),
    gdp_deflator = as.numeric(gdp_deflator)
  )

#make any adjustments you want here.
deflator <- dat3 |> 
  dplyr::filter(type == 'fyear') |> 
  dplyr::mutate(date = as.integer(substr(date,1,4)),
                gdp_deflator = (100+gdp_deflator)/100) |> 
  dplyr::arrange(by=date) |> 
  dplyr::mutate(deflator = cumprod(gdp_deflator))

return(deflator)

}

deflator <- CreateData()
rm(CreateData)
