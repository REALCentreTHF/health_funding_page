source('src/main.R')

ui <- shiny::fluidPage(
  
  shiny::fluidRow(
    shiny::column(6, 
                  align="center", 
                  offset = 3,
                  shiny::h1('PRESS ME'),
                  shiny::h2('This is a simple test run'),
                  downloadButton("dl", "Download"),
                  shiny::actionButton("generate",label = "Generate Funding Page"),
                  tags$style(type='text/css', "#button { vertical-align- middle; height- 50px; width- 100%; font-size- 30px;}"))
    )
  )

server <- function(input, output) {
  #source('src/main.R')
  
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb,'fig_1') 
  openxlsx::writeData(wb, fig_1[[1]], sheet = 1,startCol = 1,startRow = 1)
  openxlsx::writeData(wb, fig_1[[2]], sheet = 1,startCol = 1,startRow = 11)
  openxlsx::addWorksheet(wb,'fig_2') 
  openxlsx::writeData(wb, fig_2[[1]], sheet = 2,startCol = 1,startRow = 1)
  openxlsx::writeData(wb, fig_2[[2]], sheet = 2,startCol = 1,startRow = 16)
  openxlsx::addWorksheet(wb,'fig_3') 
  openxlsx::writeData(wb, fig_3, sheet = 3,startCol = 1,startRow = 1)
  openxlsx::addWorksheet(wb,'fig_4') 
  openxlsx::addWorksheet(wb,'output_budget_data') 
  openxlsx::writeData(wb, output_budget_data, sheet = 5,startCol = 1,startRow = 1)
  openxlsx::addWorksheet(wb,'output_cagr_table') 
  openxlsx::writeData(wb, output_cagr_table, sheet = 6,startCol = 1,startRow = 1)
  
  
  output$dl <- downloadHandler(
    filename = function(){
      paste0(Sys.Date(),'healthcare_funding_page.xlsx')},
    content = function(file){
      openxlsx::saveWorkbook(wb, file = file,overwrite = T)},
    contentType = "file/xlsx"
    
  )

  }

shiny::shinyApp(ui = ui, server = server)

