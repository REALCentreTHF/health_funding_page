#Adjustable globals -------

#These are the basic parameters that need to go into the list.
#delete any of these everything breaks. 
latest_efo_month <- 'November'
latest_efs_month <- 'September'
latest_pop_year <- '2023'
latest_pop_proj_year <- '2022'
latest_pesa_year <- '2025'
latest_budget_name <- 'Autumn Budget'
baseline_year <- 2025
latest_efo_year <- 2025
latest_outtrun_year <- 2023
#Adjustments 
pensions_adjustment_value = 2.851
pensions_adjustment_value_2 = 1.965
nics_adjustment_value <- 1.427

#FORCED inputs for posterity
#Date = Fall 2024 Budget. These can either be extracted automatically or inputted
#in manually. i have kept the manual as default just to check. if this does not
#match the actuals extracted, it should throw an error.
planned_cdel <- c(11600,13600,14000,13800,14800) #updated
planned_dhsc_rdel_less_adjustments <- c(193200,203400,211400,221300,231200) #updated
planned_nhs_rdel <- c(186800,195600,204900,215400,226100)
adjustments <- c(0,-1500,0,0,0)
#adjustments
planned_dhsc_rdel <- planned_dhsc_rdel_less_adjustments + adjustments
planned_dhsc_tdel <- planned_cdel + planned_dhsc_rdel 


#Governments. Older values should not change unless a time traveller alters election results
#Note. The logic behind the start / end year selection needs to be examined.
#Fig 3. Doesn't align with it because of the way the selection occurs. 
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
#THIS is the year from which fig4 takes the cagrs, starting from 79
fig_3_max_year <- 2019
efs_url <- 'https://obr.uk/frs/fiscal-risks-and-sustainability-july-2025/'

# Non-adjustable globals ---------
efo_link <- 'https://obr.uk/efo/'
pop_link <- 'https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales'
pop_proj_link <- 'https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationprojections/datasets/tablea11principalprojectionuksummary'
pesa_url <- 'https://www.gov.uk/government/collections/public-expenditure-statistical-analyses-pesa'
old_deflator_url <- 'https://www.gov.uk/government/collections/gdp-deflators-at-market-prices-and-money-gdp'
historic_dhsc_tdel_url <- 'https://researchbriefings.files.parliament.uk/documents/SN00724/CBP0724-expenditure-tables.xlsx'

#need this for everything
source('const/disclaimer.R')
source('const/healthcare_funding_page.R')
