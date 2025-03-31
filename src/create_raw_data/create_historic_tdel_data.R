CreateData <- function(){
    
  #data is historic from a parliamentary briefing. see:
  #https://researchbriefings.files.parliament.uk/documents/SN00724/SN00724.pdf
  #https://researchbriefings.files.parliament.uk/documents/SN00724/CBP0724-expenditure-tables.xlsx
  
  #dat1 <- Rpublic::extract_sheets(historic_dhsc_tdel_url,'dhsc')
  dat <- read.csv('const/historic_dhsc_tdel.csv')
  
  dhsc_tdel <- dat[,c(2,4)] |> 
    tidyr::drop_na() |> 
    dplyr::rename('date' = 1,
                'dhsc_tdel' = 2) |> 
    dplyr::mutate(dhsc_tdel = as.numeric(dhsc_tdel),
                type = 'fyear',
                date = as.integer(substr(date,1,4))) |> 
    #removes covid years, which still include planned in old dataset
    dplyr::filter(date != max(date))
  
  return(dhsc_tdel)
  
}

historic_dhsc_tdel_data <- CreateData()
rm(CreateData)
