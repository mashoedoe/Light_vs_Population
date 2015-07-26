library(shiny)
library(leaflet)

#load("gis.RData")
town_SA <- readRDS("RDS/town_SA.rds")
town_dbf <- readRDS("RDS/town_dbf.rds")
town_tj <- readRDS("RDS/town_tj.rds")
m_colors <- marray::maPalette(low = "royal blue", mid = "yellow", high = "white", k = 234)
m_pal <- colorNumeric(palette = m_colors, domain = c(0,233))
town_popup <- paste0("<strong>Muncipality: </strong>",
                     town_SA@data$MUNICNAME,
                     "<br />",
                     "<strong>Density: </strong>",
                     town_SA@data$ORDER1,
                     " order")

ui <- fluidPage(
  leafletOutput(outputId = "mymap"),
  p(),
  actionButton(inputId = "recalc", label = "New order")
)

server <- function(input, output, session) {

  town_SA <- eventReactive(input$recalc, {
     sp::SpatialPolygonsDataFrame(data = cbind(town_dbf, "ORDER1" = sample(x = 0:233, size = 234, replace = F)), 
                                          Sr = town_tj, match.ID = "ORDER")
    }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.DarkMatter", group = "CartoDB Dark Matter",
                       options = providerTileOptions(noWrap = TRUE)
                       ) %>%
      addPolygons(data = town_SA(), color = "red", weight = 0.5, fillColor = ~m_pal(ORDER1), 
                  fillOpacity = 1, group = "Towns", popup = town_popup, options = popupOptions(),
                 ) %>%
      addLayersControl(baseGroups = c("CartoDB Dark Matter"),
                       overlayGroups = c("Towns"),
                       options = layersControlOptions(collapse = FALSE)
      )
    
  })
}


shinyApp(ui, server)
