# Used to construct hybrid HMT (historic) and OBR (forecast) GDP deflator series
# If the most recent HMT publication is linked to the fiscal event, then only use the HMT series (as it will already include the OBR forecast)

GetData <- function() {
  
  #######################
  # HMT GDP deflator data 
  #######################
  
  # Find the most recent HMT GDP deflator publication
  # This looks for the link after "How to use the GDP deflator series" on the webpage
  links <- Rpublic::extract_links(hmt_deflator_url)
  
  hmt_latest_deflator_url <- links[
    match(
      "/government/publications/how-to-use-the-gdp-deflator-series-practical-examples",
      links
    ) + 1
  ] |>
    paste0("https://www.gov.uk", x = _)
  
  # If the most recent data uses "budget" or "statement" in the link, it includes the most recent OBR data
  # Please manually check this!
  has_obr_forecast <- grepl(
    "budget|statement",
    hmt_latest_deflator_url,
    ignore.case = TRUE
  )
  
  # Add the GOV.UK domain only if the link is relative.
  hmt_latest_deflator_url_full <- if (grepl("^https?://", hmt_latest_deflator_url)) {
    hmt_latest_deflator_url
  } else {
    paste0(
      "https://www.gov.uk/",
      sub("^/+", "", hmt_latest_deflator_url)
    )
  }
  
  # Get the data link
  hmt_latest_deflator_data_url <- Rpublic::extract_links(
    hmt_latest_deflator_url_full,
    "\\.xls"
  )
  
  # Read HMTExcel file and produce clean tibble
  # Only rows matching the fiscal year pattern are extracted
  fy_pattern <- "^\\s*\\d{4}-\\d{2}\\b"
  
  hmt_df_raw <- Rpublic::extract_sheets(
    hmt_latest_deflator_data_url,
    "deflator"
  )[[1]] |>
    as.data.frame()
  
  matches <- vapply(hmt_df_raw, function(col) sum(grepl(fy_pattern, col)), numeric(1))
  fy_col <- which.max(matches)
  fy_rows <- grepl(fy_pattern, hmt_df_raw[[fy_col]])
  if (!any(fy_rows)) stop("No financial-year rows found; check the file layout")
  
  # Look for the column "per cent change on previous year"
  header <- unlist(hmt_df_raw[which(fy_rows)[1] - 1, ])
  right <- seq_along(header) > fy_col
  pct_col <- which(right & grepl("per cent change", header, ignore.case = TRUE))[1]
  if (is.na(pct_col)) stop("Value column headers not found")
  
  label <- trimws(hmt_df_raw[fy_rows, fy_col])
  hmt_df <- tibble(
    date = sub("^(\\d{4}-\\d{2}).*", "\\1", label), # strip " (1), (2)"
    forecast = grepl("\\(\\d\\)", label), # TRUE where footnote markers present
    gdp_deflator = as.numeric(hmt_df_raw[fy_rows, pct_col])
  ) |>
    dplyr::mutate(
      date = as.integer(substr(date, 1, 4)),
      gdp_deflator = (100 + gdp_deflator) / 100) |>
    tidyr::drop_na()
  
  hmt_forecast_years <- hmt_df |>
    filter(forecast == TRUE) |>
    pull(date)
  
  #######################
  # OBR GDP deflator data
  # Only run if has_obr_forecast = FALSE
  #######################
  
  if (has_obr_forecast == FALSE) {
    hmt_df <- hmt_df |>
      dplyr::filter(date < deflator_switch_year)
    
    # Find the OBR economy workbook using efo_report_url from glob.R.
    efo_link2 <- Rpublic::extract_links(
      efo_report_url,
      "detailed-forecast-tables-economy"
    )
    
    if (length(efo_link2) != 1) {
      stop("Expected exactly one OBR economy spreadsheet link.")
    }
    
    # Extract OBR GDP deflator growth rates.
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
    
    # Keep OBR financial-year growth from 2026-27 onwards
    obr_deflator <- obr_dat3 |>
      dplyr::filter(type == "fyear") |>
      dplyr::mutate(
        date = as.integer(substr(date, 1, 4)),
        gdp_deflator = (100 + gdp_deflator) / 100
      ) |>
      dplyr::filter(date >= deflator_switch_year) |>
      dplyr::select(date, gdp_deflator)
    
    # Checks if the HMT and OBR GDP deflator forecasts are identical
    # You can comment this out if one is shorter than the other (we want 5 years to capture the full SR period)
    if (!identical(obr_deflator %>% pull(date), hmt_forecast_years)) stop("HMT and OBR forecast years not aligned.")
    
    # Combine annual growth multipliers in chronological order.
    combined_deflator_series <- dplyr::bind_rows(
      hmt_df,
      obr_deflator
    ) |>
      dplyr::arrange(date)
    
    # Check that both sides of the joining point are present.
    if (!(deflator_switch_year - 1) %in% hmt_df$date ||
        !deflator_switch_year %in% obr_deflator$date) {
      stop("Missing Treasury 2025-26 or OBR 2026-27 data.")
    }
    
  } else combined_deflator_series <- hmt_df %>% select (!forecast)
  
  
  # Validation checks
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
  
  # Build one cumulative index from the combined multipliers.
  combined_deflator_series <- combined_deflator_series |>
    dplyr::arrange(date) |>
    dplyr::mutate(
      deflator = cumprod(gdp_deflator)
    )
}

combined_deflator_series <- GetData()
rm(GetData)