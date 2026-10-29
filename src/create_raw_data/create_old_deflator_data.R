# Reload settings required by this script.
source("const/glob.R")

GetData <- function() {
  
  treasury_release_year <- 2026
  deflator_switch_year <- 2026
  
  # 1. Find the September 2026 Treasury workbook.
  old_deflator_link <- Rpublic::extract_links(
    old_deflator_url,
    paste0("september-", treasury_release_year),
    ignore.case = TRUE
  )
  
  if (length(old_deflator_link) != 1) {
    stop("Expected exactly one September 2026 Treasury publication link.")
  }
  
  # Add the GOV.UK domain only if the link is relative.
  treasury_page <- if (grepl("^https?://", old_deflator_link)) {
    old_deflator_link
  } else {
    paste0(
      "https://www.gov.uk/",
      sub("^/+", "", old_deflator_link)
    )
  }
  
  old_deflator_link2 <- Rpublic::extract_links(
    treasury_page,
    "\\.xls"
  )
  
  if (length(old_deflator_link2) != 1) {
    stop("Expected exactly one Treasury spreadsheet link.")
  }
  
  # 2. Find the OBR economy workbook using efo_report_url from glob.R.
  efo_link2 <- Rpublic::extract_links(
    efo_report_url,
    "detailed-forecast-tables-economy"
  )
  
  if (length(efo_link2) != 1) {
    stop("Expected exactly one OBR economy spreadsheet link.")
  }
  
  # 3. Extract OBR GDP deflator growth rates.
  obr_dat <- Rpublic::extract_sheets(
    files = efo_link2,
    pattern = "1[.]7$"
  )[["1.7"]]
  
  obr_dat2 <- obr_dat[, -1]
  names(obr_dat2) <- obr_dat2[3, ]
  
  obr_dat3 <- obr_dat2[-c(1:3), ] |>
    janitor::clean_names() |>
    dplyr::select(na, gdp_deflator) |>
    tidyr::drop_na() |>
    dplyr::rename(date = na) |>
    dplyr::mutate(
      type = dplyr::case_when(
        substr(date, nchar(date) - 1, nchar(date) - 1) == "Q" ~
          "quarter",
        substr(date, nchar(date) - 2, nchar(date) - 2) == "-" ~
          "fyear",
        TRUE ~ "midyear"
      ),
      gdp_deflator = as.numeric(gdp_deflator)
    )
  
  # Keep OBR financial-year growth from 2026-27 onwards.
  obr_deflator <- obr_dat3 |>
    dplyr::filter(type == "fyear") |>
    dplyr::mutate(
      date = as.integer(substr(date, 1, 4)),
      gdp_deflator = (100 + gdp_deflator) / 100
    ) |>
    dplyr::filter(date >= deflator_switch_year) |>
    dplyr::select(date, gdp_deflator)
  
  # 4. Extract Treasury financial-year growth through 2025-26.
  hmt_dat <- Rpublic::extract_sheets(
    old_deflator_link2,
    "deflator"
  )[[1]] |>
    _[-c(1:4), ] |>
    dplyr::rename(
      date = 1,
      gdp_deflator = 3
    ) |>
    dplyr::select(date, gdp_deflator) |>
    dplyr::mutate(
      gdp_deflator = (as.numeric(gdp_deflator) + 100) / 100,
      date = as.integer(substr(date, 1, 4))
    ) |>
    tidyr::drop_na() |>
    dplyr::filter(date < deflator_switch_year) |>
    dplyr::arrange(date)
  
  # 5. Combine annual growth multipliers in chronological order.
  combined_deflator_series <- dplyr::bind_rows(
    hmt_dat,
    obr_deflator
  ) |>
    dplyr::arrange(date)
  
  # Check that both sides of the joining point are present.
  if (!(deflator_switch_year - 1) %in% hmt_dat$date ||
      !deflator_switch_year %in% obr_deflator$date) {
    stop("Missing Treasury 2025-26 or OBR 2026-27 data.")
  }
  
  if (anyDuplicated(combined_deflator_series$date)) {
    stop("Duplicate financial years in the combined deflator.")
  }
  
  if (any(diff(combined_deflator_series$date) != 1)) {
    stop("Missing financial years in the combined deflator.")
  }
  
  if (anyNA(combined_deflator_series$gdp_deflator) ||
      any(!is.finite(combined_deflator_series$gdp_deflator)) ||
      any(combined_deflator_series$gdp_deflator <= 0)) {
    stop("Missing or invalid GDP deflator growth multipliers.")
  }
  
  if (!baseline_year %in% combined_deflator_series$date) {
    stop("The selected baseline year is missing from the deflator.")
  }
  
  # 6. Build one cumulative index from the combined multipliers.
  combined_deflator_series |>
    dplyr::mutate(
      deflator = cumprod(gdp_deflator)
    )
}

old_deflator_series <- GetData()
rm(GetData)

View(old_deflator_series)