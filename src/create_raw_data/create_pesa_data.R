
GetData <- function(){
  #Get URLS
  pesa_url_2 <- Rpublic::extract_links(pesa_url,'public-expenditure-statistical-analyses-')
  pesa_url_3 <- pesa_url_2[grepl(x=pesa_url_2,pattern='')]
  pesa_link <- purrr::map(
    .x = pesa_url_3,
    .f = function(.x){
      a <- Rpublic::extract_links(paste0('https://www.gov.uk//',.x),'Chapter_1|chapter1|chapter_1')
      b<-a[grepl(pattern='.xlsx|.xls|ods',a)]
      c<-b[grepl(pattern='1.x|1_Tables.x|1_tables.x|1_tables.ods',b)]
    }) |> 
    purrr::flatten_chr()
  
  ## RDEL--------
  pesa_link2 <- purrr::map(
    .x = pesa_link,
    .f = function(.x){
      if(tools::file_ext(.x) == 'ods'){
        temp <- tempfile()
        utils::download.file(.x, temp)
        sheet<-readODS::list_ods_sheets(temp)
        sheet_name <- sheet[grepl(pattern='1.5|1_5',sheet)]
        data <- readODS::read_ods(temp, sheet = sheet_name)
        unlink(temp, recursive = T)
        return(as.data.frame(data))
      } else {
        data <- Rpublic::extract_sheets(.x,'1.5|1_5')
        return(as.data.frame(data))
      }
    }
  ) |> 
    purrr::set_names(pesa_link)

  pesa_link3 <- purrr::map2(
    .x = pesa_link2,
    .y = names(pesa_link2),
    .f = function(.x,.y){
      out <- .x
      names(out) <- .x[3,]
      dat <- out |> 
        _[-c(1:5),] |> 
        janitor::clean_names() |> 
        dplyr::rename('department'=1) |> 
        tidyr::pivot_longer(cols = -department,names_to='date',values_to='values') |> 
        dplyr::mutate(type = 'fyear',
                      pod = 'DHSC RDEL',
                      date = as.numeric(substr(date,2,5))) |> 
        tidyr::drop_na() |> 
        dplyr::mutate(pesa_year = substr(stringr::str_extract(.y, "(?<=PESA_|pesa_).*"),1,4),
                      pesa_year = as.numeric(pesa_year))
      return(dat)
    }) |> 
    data.table::rbindlist()
  
  ##CDEL -------
  pesa_link_cdel2 <- purrr::map(
    .x = pesa_link,
    .f = function(.x){
      if(tools::file_ext(.x) == 'ods'){
        temp <- tempfile()
        utils::download.file(.x, temp)
        sheet<-readODS::list_ods_sheets(temp)
        sheet_name <- sheet[grepl(pattern='1.8$|1_8$',sheet)]
        data <- readODS::read_ods(temp, sheet = sheet_name)
        unlink(temp, recursive = T)
        return(as.data.frame(data))
      } else {
        data <- Rpublic::extract_sheets(.x,'1.8$|1_8$')
        return(as.data.frame(data))
      }
    }
  ) |> 
    purrr::set_names(pesa_link)
  
  pesa_link_cdel3 <- purrr::map2(
    .x = pesa_link_cdel2,
    .y = names(pesa_link_cdel2),
    .f = function(.x,.y){
      
      out <- .x
      names(out) <- .x[3,]
      
      dat <- out |> 
        _[-c(1:5),-c(10:12)] |> 
        janitor::clean_names() |> 
        dplyr::rename('department'=1) |> 
        tidyr::pivot_longer(cols = -department,names_to='date',values_to='values') |> 
        dplyr::mutate(values = as.numeric(values),
                      type = 'fyear',
                      pod = 'CDEL',
                      date = as.numeric(substr(date,2,5))) |> 
        tidyr::drop_na() |> 
        dplyr::filter(values >= 3000) |> 
        dplyr::mutate(pesa_year = substr(stringr::str_extract(.y, "(?<=PESA_|pesa_).*"),1,4),
                      pesa_year = as.numeric(pesa_year))

      return(dat)
    }) |> 
    data.table::rbindlist()
  
  #DHSC TDEL -----
  
  pesa_link_tdel2 <- purrr::map(
    .x = pesa_link,
    .f = function(.x){
      if(tools::file_ext(.x) == 'ods'){
        temp <- tempfile()
        utils::download.file(.x, temp)
        sheet<-readODS::list_ods_sheets(temp)
        sheet_name <- sheet[grepl(pattern='1.10|1_10',sheet)]
        data <- readODS::read_ods(temp, sheet = sheet_name)
        unlink(temp, recursive = T)
        return(as.data.frame(data))
      } else {
        data <- Rpublic::extract_sheets(.x,'1.10$|1_10$|1.10a$')
        return(as.data.frame(data))
      }
    }
  ) |> 
    purrr::set_names(pesa_link)
  
  pesa_link_tdel3 <- purrr::map2(
    .x = pesa_link_tdel2,
    .y = names(pesa_link_tdel2),
    .f = function(.x,.y){
      
      out <- .x
      names(out) <- .x[3,]
      
      dat <- out |> 
        _[-c(1:5),-c(9:11)] |> 
        janitor::clean_names() |> 
        dplyr::rename('department'=1) |> 
        tidyr::pivot_longer(cols = -department,names_to='date',values_to='values') |> 
        dplyr::mutate(values = as.numeric(values),
                      type = 'fyear',
                      pod = 'DHSC TDEL',
                      date = as.numeric(substr(date,2,5))) |> 
        tidyr::drop_na() |> 
        dplyr::mutate(pesa_year = substr(stringr::str_extract(.y, "(?<=PESA_|pesa_).*"),1,4),
                      pesa_year = as.numeric(pesa_year))
      
      return(dat)
    }) |> 
    data.table::rbindlist()
  
  final_output <- rbind(
    pesa_link_tdel3,pesa_link_cdel3,pesa_link3
  ) |> 
    dplyr::filter(
      grepl(pattern='health|Health',x=department)
    ) |> 
    dplyr::group_by(pod,date,type) |> 
    dplyr::filter(pesa_year == max(pesa_year))
  
  return(final_output)
  
}

pesa_data <- GetData()
rm(GetData)
