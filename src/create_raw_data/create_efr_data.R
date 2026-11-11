# Reads the age-cost curve from the OBR September 2024 Fiscal risks and sustainability report
# https://obr.uk/frs/fiscal-risks-and-sustainability-september-2024/
# Note: this only needs to be updated when OBR publishes a new age-cost curve for health spending. The Fiscal risks and sustainability publication is different from the Economic and fiscal outlook publication released at each fiscal event.

GetData <- function(){

  dat <- readxl::read_excel(
    "const/obr_sept24_age_cost_curve.xlsx",
    sheet = "C3.11",
    range = "C26:CZ27",
    col_names = FALSE
  ) |>
    t() |>
    as.data.frame() |>
    dplyr::rename(
      age = 1,
      age_cost_weight = 2
    )
  
  return(dat)
  
  }

age_cost_data <- GetData()
rm(GetData)
