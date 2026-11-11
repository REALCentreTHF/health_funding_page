# This is the main file to run for each health funding page update

# Dependencies
library(tidyr)
library(dplyr)
library(readxl)
library(readODS)
library(janitor)
library(purrr)
library(data.table)
source('const/glob.R')
source('src/functions.R')

# Set to TRUE if you are running the entire pipeline
# This saves outputs into a timestamped folder in outputs/
use_timestamp <- TRUE

# Base output directory
output_dir <- "output"

#Step 1: Read in the raw data
tryCatch(
  purrr::walk(.x = fs::dir_ls('src/create_raw_data'),
             .f = source),
  error = function(e){
    stop("An error occurred:", 
        conditionMessage(e), 
        "\n",
        'This means analysis cannot be run due to an error in the raw data collection')}
  )
  
#Step 2: Create the analysis associated
tryCatch(
  purrr::walk(.x = fs::dir_ls('src/create_analysis'),
             .f = source),
  error = function(e){
    stop("An error occurred:", 
        conditionMessage(e),
        "\n",
        'This means the figures cannot be run due to an error in the analysis')}
)

#Step 3: Create the figures
tryCatch(
  purrr::walk(.x = fs::dir_ls('src/create_figures'),
             .f = source),
  error = function(e){
    stop("An error occurred:", 
        conditionMessage(e),
        "\n",
        'This means the figures cannot be run due to an error in /src/create_figures/')}
)

# Step 4: Export outputs
if (use_timestamp) {
  timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
  output_dir <- file.path(output_dir, timestamp)
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(table_1, file.path(output_dir, 'table_1_updated.csv'))
write.csv(fig_2, file.path(output_dir, 'figure_2_updated.csv'))
write.csv(fig_3, file.path(output_dir, 'figure_3_updated.csv'))

# CAGR for Figure 3
round(fig3_cagr * 100, 2)

