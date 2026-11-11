GetData <- function(){

output_funding_page <- jinjar::render(funding_page, !!!output_params)
output_disclaimer <- jinjar::render(disclaimer, !!!output_params)

fin <- paste(output_disclaimer,output_funding_page)

return(fin)

}

output_funding_page <- GetData()
rm(GetData)
