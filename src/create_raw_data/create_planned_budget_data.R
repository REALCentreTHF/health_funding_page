# Creates tibble based on planned_dhsc_rdel and planned_cdel in const/glob.R

# Notes:
# Tibble should span the year following latest_outturn_year to end_year
# Remember the RDEL and CDEL vectors in const/glob.R need to be manually updated every time the health funding page is refreshed!

GetData <- function() {
  
  df <- tibble(
    date = seq.int(
      first_year_sr + 1,
      length.out = length(planned_cdel)
    ),
    dhsc_rdel = planned_dhsc_rdel,
    dhsc_cdel = planned_cdel
  ) %>%
    mutate(
      dhsc_tdel = dhsc_rdel + dhsc_cdel
    ) %>%
    pivot_longer(
      cols = starts_with("dhsc_"),
      names_to = "pod",
      values_to = "values"
    )
  
  return(df)
}

planned_budget_data <- GetData()
rm(GetData)
