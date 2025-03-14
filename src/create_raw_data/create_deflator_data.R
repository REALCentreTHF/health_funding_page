link <- 'https://obr.uk/efo/'

link2<-Rpublic::extract_links(link,paste0('efo/economic-and-fiscal-outlook-',tolower(latest_efo_month)))
link3 <- Rpublic::extract_links(link2,'detailed-forecast-tables-economy')

Rpublic::extract_sheets(
  files = link3,
  pattern = '1.7'
)
