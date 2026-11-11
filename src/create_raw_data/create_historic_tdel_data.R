# Extracts a tibble of historic DHSC TDEL from House of Commons Library research briefing CBP0724
# https://commonslibrary.parliament.uk/research-briefings/sn00724/
# The data is taken from the expenditure tables listed under "Supporting documents": https://researchbriefings.files.parliament.uk/documents/SN00724/CBP0724-expenditure-tables.xlsx
# Only TDEL data from 2014 and earlier is taken from this tibble

CreateData <- function(){
  
  dhsc_tdel <- readxl::read_excel(
    "const/CBP0724-expenditure-tables.xlsx",
    sheet = "DHSC",
    range = "B7:C59",
    col_names = c("date", "dhsc_tdel")
  ) |>
    tidyr::drop_na(date, dhsc_tdel) |>
    dplyr::mutate(
      dhsc_tdel = as.numeric(dhsc_tdel),
      date = as.integer(substr(date, 1, 4))
    ) |>
    # Remove the final year
    dplyr::filter(date != max(date))
  
  return(dhsc_tdel)
}

historic_dhsc_tdel_data <- CreateData()
rm(CreateData)
