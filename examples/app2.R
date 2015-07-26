library(shiny)
library(leaflet)
library(RColorBrewer)
town_SA <- readRDS("RDS/town_SA.rds")

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("range", "Pop Density", min(town_SA@data$DENSITY), max(town_SA@data$DENSITY),
                            value = range(town_SA@data$DENSITY), step = 100
                ),
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                ),
                checkboxInput("legend", "Show legend", TRUE)
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    town_SA[town_SA@data$DENSITY >= input$range[1] & town_SA@data$DENSITY <= input$range[2],]
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(palette = input$colors, domain = town_SA@data$DENSITY)
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(town_SA) %>% addTiles() %>%
      setView(lng = 28.2, lat = -26, zoom = 5)
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      
      addPolygons(stroke = T, weight = 1, opacity = 0, color = "white", fillOpacity = 1,
                  smoothFactor = 1, fillColor = ~pal(DENSITY),
                  popup = ~paste0("<strong>Muncipality: </strong>",
                                  town_SA@data$MUNICNAME,
                                  "<br />",
                                  "<strong>Density: </strong>",
                                  round(town_SA@data$DENSITY, digits = 1),
                                  " people/km",
                                  "<sup>2</sup>"),
                  options = popupOptions()
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = town_SA)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright", pal = pal, values = ~DENSITY,
                          title = "Population/km<sup>2</sup>", opacity = 1, na.label = "Over 1500", 
                          labFormat = labelFormat(big.mark = " ")
                          
      )
    }
#     addLegend(position = "bottomright", pal = pal_night, 
#               values = ~ventiles[seq(from = 1, to = 15, 2)],
#               #ventiles[seq(from = 1, to = 16, 3)], # ventiles[seq(from = 1, to = 19, 3)], 
#               title = "Population/km<sup>2</sup>", opacity = 1, na.label = "Over 1500", 
#               labFormat = labelFormat(big.mark = " ")) %>%
  })
}

shinyApp(ui, server)