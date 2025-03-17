GetData <- function(){
  
  efs_links <- Rpublic::extract_links(efs_url,tolower(latest_efs_month))
  efs_links2 <- efs_links[grepl(pattern = 'chapter-3',efs_links)]

  dat<-Rpublic::extract_sheets(efs_links2,'C3.11') |> 
    _[['C3.11']] |> 
    _[c(25:26),-c(1:2)] |>
    t() |> 
    as.data.frame() |> 
    dplyr::rename(
      'age'=1,
      'age_cost_weight'=2
    )
  
  return(dat)
  
  }

age_cost_data <- GetData()
rm(GetData)
