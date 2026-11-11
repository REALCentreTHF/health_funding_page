###################
# GLOBAL VARIABLES 
###################

# Financial years are identified by their starting calendar year: 2025 means 2025/26.

# Suppress name-repair messages when importing data
options(rlib_name_repair_verbosity = "quiet")

############################
# VARIABLES TO ALWAYS UPDATE 
# Revisit for every fiscal event!
############################

latest_efo_month <- 'October' # current month
latest_pop_year <- '2025' # year for ONS population projections   
baseline_year <- 2026 # current year
latest_outturn_year <- 2025 # read this from the published document 

# Used to construct hybrid HMT (historic) and OBR (forecast) GDP deflator series
deflator_switch_year <- 2026 # first year of OBR GDP deflator forecasts

# Links for data inputs
efo_report_url <- "https://obr.uk/efo/economic-and-fiscal-outlook-october-2026/"

# Planned DEL - read this from the published Budget document
# In the HTML version of the Budget document, this is usually in a section called "Government spending"
# For Autumn 2026, note we use pre-adjusted plans (not reflecting the technical adjustment for the decreased employer pension contribution starting April 2027)
planned_cdel <- c(11500, 13300, 13800, 13500, 14500)
planned_dhsc_rdel <- c(193200, 204100, 212500, 221200, 231100)

# Adjustments (all values in £m)

# Start years (corresponding adjustments are 0 before this year)
pension_2019_start_year <- 2019L
pension_2024_start_year <- 2025L # Historic artifact, see tests/qa_checklist.md
nics_start_year <- 2025L
other_adjustments_start_year <- 2025L 

pension_2019_adjustment_m = 2851  
pension_2024_adjustment_m = 1965
nics_adjustment_m <- 1427
other_adjustment_components_m <- 
  data.frame(
    date = 2025:2028,
    redundancies = c(430, 430, 0, 0),
    main_estimates_transfers = c(0, 774, 0, 0),
    planned_treasury = c(0, -1610, -1610, -1610)
  )

#########################################################
# HARD-CODED VARIABLES
# Do not update these unless required by the fiscal event
#########################################################

# List of governments for Figure 2
# The start year of each government is the year before the election (historical artifact)

govt_list <- list(
  'Thatcher & Major'=1979:1996,
  'Blair & Brown'=1996:2009 ,
  'Coalition'=2009:2014,
  'Cameron & May'=2014:2018,
  'Johnson, Truss & Sunak'=2018:2023,
  'Starmer'=2023:2028
)

start_year <- 2013
end_year <- 2028
fig_2_max_year <- 2019 # last year for long-term average in Figure 2

# Year before the first year of planned_cdel and planned_dhsc_rdel
first_year_sr <- 2023

# General data input URLs without specific date references
pop_link <- 'https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales'
pesa_url <- 'https://www.gov.uk/government/collections/public-expenditure-statistical-analyses-pesa'
hmt_deflator_url <- 'https://www.gov.uk/government/collections/gdp-deflators-at-market-prices-and-money-gdp'

