#These need to run in advance of everything as global options
source('const/glob.R')
source('src/functions.R')

#Step 1: Read in the raw data
tryCatch(
  purrr::map(.x = fs::dir_ls('src/create_raw_data'),
             .f = source),
  error = function(e){
    cat("An error occurred:", 
        conditionMessage(e), 
        "\n",
        'This means analysis cannot be run due to an error in the raw data collection')}
  )
  
#Step 2: Create the analysis associated
tryCatch(
  purrr::map(.x = fs::dir_ls('src/create_analysis'),
             .f = source),
  error = function(e){
    cat("An error occurred:", 
        conditionMessage(e),
        "\n",
        'This means the figures cannot be run due to an error in the analysis')}
)

#Step 3: Create the figures
tryCatch(
  purrr::map(.x = fs::dir_ls('src/create_figures'),
             .f = source),
  error = function(e){
    cat("An error occurred:", 
        conditionMessage(e),
        "\n",
        'This means the figures cannot be run due to an error in /src/create_figures/')}
)

#Step 4: Jinjar
tryCatch(
  purrr::map(.x = fs::dir_ls('src/create_document'),
             .f = source),
  error = function(e){
    cat("An error occurred:", 
        conditionMessage(e),
        "\n",
        'This means the figures cannot be run due to an error in /src/create_document/')}
)

write.csv(output_budget_data,'output/budget_data.csv')
write.csv(output_cagr_table,'output/cagr_table.csv')
write.csv(fig_3,'output/fig_3.csv')
write.csv(fig_4,'output/fig_4.csv')
write.csv(deflator,'output/deflator.csv')

#Clean up environment
rm(list=ls()[!grepl(pattern='output|fig',x=ls())])

