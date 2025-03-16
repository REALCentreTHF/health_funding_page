
GetData <- function(){
  #Get URLS
  pesa_url_2 <- Rpublic::extract_links(pesa_url,'public-expenditure-statistical-analyses-')
  pesa_url_3 <- pesa_url_2[grepl(x=pesa_url_2,pattern=2017)]
  pesa_link <- Rpublic::extract_links(paste0('https://www.gov.uk//',pesa_url_3),'Chapter_1_')
  
  dhsc_rdel_exc_dep <- Rpublic::extract_sheets(pesa_link,'Table 1.5')[['Table 1.5']]
  names(dhsc_rdel_exc_dep) <- dhsc_rdel_exc_dep[3,]
  dhsc_rdel_exc_dep_a <- dhsc_rdel_exc_dep |> 
    _[-c(1:5),] |> 
    dplyr::rename('department'=1) |> 
    tidyr::pivot_longer(cols = -department,names_to='date',values_to='values') |> 
    dplyr::mutate(date = as.integer(substr(date,1,4)),
                  values = as.numeric(values),
                  type = 'fyear',
                  pod = 'DHSC RDEL') |> 
    tidyr::drop_na()
  
  
  dhsc_cdel <- Rpublic::extract_sheets(pesa_link,'Table 1.8$')[['Table 1.8']]
  names(dhsc_cdel) <- dhsc_cdel[3,]
  dhsc_cdel_a <- dhsc_cdel |> 
    _[-c(1:5),-c(10:12)] |> 
    dplyr::rename('department'=1) |> 
    tidyr::pivot_longer(cols = -department,names_to='date',values_to='values') |> 
    dplyr::mutate(date = as.integer(substr(date,1,4)),
                  values = as.numeric(values),
                  type = 'fyear',
                  pod = 'CDEL') |> 
    tidyr::drop_na() |> 
    dplyr::filter(values >= 1000)
  
  dhsc_tdel <- Rpublic::extract_sheets(pesa_link,'Table 1.10')[['Table 1.10']]
  names(dhsc_tdel) <- dhsc_tdel[3,]
  dhsc_tdel_a <- dhsc_tdel |> 
    _[-c(1:5),-c(9:11)] |> 
    dplyr::rename('department'=1) |> 
    tidyr::pivot_longer(cols = -department,names_to='date',values_to='values') |> 
    dplyr::mutate(date = as.integer(substr(date,1,4)),
                  values = as.numeric(values),
                  type = 'fyear',
                  pod = 'DHSC TDEL') |> 
    tidyr::drop_na()
  
  
  return(list(
    dhsc_tdel_a,
    dhsc_cdel_a,
    dhsc_rdel_exc_dep_a
  ))
}

dhsc_2013_17_data <- GetData()
rm(GetData)
