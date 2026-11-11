#NHS Data comes from the below PESA URL. See as needed. 
# 
# pesa_url <- 'https://assets.publishing.service.gov.uk/media/64b69e320ea2cb001315e4f6/E02929310_HMT_PESA_2023_Accessible.pdf'
# install.packages("pdftools")
# library("pdftools")
# test <- pdftools::pdf_data(pesa_url)
# ??pdftools
# 
# test2 <- test |> 
#   _[-c(1:3),]
# names(test2) <- test2[1,]
# test3 <- test2 |> 
#   _[-1,] |> 
#   _[5,] |> 
#   janitor::clean_names() |> 
#   tidyr::pivot_longer(cols=!c(1:2),names_to='date',values_to='nhs_rdel') |> 
#   dplyr::select(date,nhs_rdel) |> 
#   dplyr::mutate(date = as.integer(substr(date,2,5)),
#                 nhs_rdel = as.numeric(nhs_rdel)) |> 
#   tidyr::drop_na() |> 
#   dplyr::mutate(type = 'fyear') |> 
#   dplyr::mutate(outtrun_flag = dplyr::case_when(
#     date == max(date,na.rm=T) ~ T,
#     TRUE ~ F
#   ))
# 

nhs_rdel <- read.csv('const/historic_nhs_funding.csv',header=T) |> 
  _[-1] |> 
  dplyr::rename(values = nhs_rdel ) |> 
  dplyr::mutate(pod = 'NHSE RDEL') |> 
  dplyr::select(-outtrun_flag) |> 
  #needs to be in common units: millions
  dplyr::mutate(values = values * 1000)
