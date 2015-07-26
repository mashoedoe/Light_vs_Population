library(shiny)
library(leaflet)
library(marray)
ward_SA <- readRDS("RDS/ward_SA.rds")

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput(inputId = "integer", "Pop Density", step = 100, 
                            min = 0, max = max(ward_SA@data$DENSITY), round = T,
                            #value = max(ward_SA@data$DENSITY),
                            value = round(quantile(x = ward_SA@data$DENSITY,
                                            probs = 0.5),digits = 0), 
                            #value = round(quantile(x = ward_SA@data$DENSITY,
                            #                probs = 0.7),digits = 0)
                            width = '1200px'
                ),
                checkboxInput("ward_polygons", "Show Ward polygons", TRUE)
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    ward_SA[ward_SA@data$DENSITY >= 0 & ward_SA@data$DENSITY <= input$integer,]
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(palette = maPalette(low = "navy", mid = "yellow", high = "white"), 
                 domain = c(0,input$integer), na.color = "white")
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(ward_SA) %>% 
      addTiles(
        urlTemplate <- "http://map1.vis.earthdata.nasa.gov/wmts-webmerc/VIIRS_CityLights_2012/default/GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpeg", 
        group = "Night Light (default)",
        attribution = paste('Imagery provided by GIBS,',
                            'operated by the NASA/GSFC/<a href="https://earthdata.nasa.gov">EOSDIS</a>',
                            'with funding provided by NASA/HQ.')
      ) %>%
      setView(lng = 28.2, lat = -26, zoom = 5)
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
      proxy1 <- leafletProxy("map", data = filteredData()) 
      
      proxy1 %>% clearShapes()
      pal <- colorpal()
      if (input$ward_polygons) {proxy1 %>%
                  addPolygons(stroke = T, weight = 1, opacity = 0, color = "white", fillOpacity = 1,
                  smoothFactor = 0.5, fillColor = ~pal(DENSITY),
                  popup = ~paste0(ward_SA@data$MUNICNAME,
                                  "<br />",
                                  "<strong> Ward </strong>",
                                  ward_SA@data$WARDNO,
                                  "<br />",
                                  "<strong>Density: </strong>",
                                  round(ward_SA@data$DENSITY, digits = 1),
                                  " people/km",
                                  "<sup>2</sup>"),
                  options = popupOptions()
      )
    }    
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy2 <- leafletProxy("map", data = ward_SA)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
      proxy2 %>% clearControls()
      pal <- colorpal()
      proxy2 %>% addLegend(position = "bottomright", pal = pal, values = ~DENSITY,
                          title = "Population/km<sup>2</sup>", opacity = 1, na.label = "Over 1500", 
                          labFormat = labelFormat(big.mark = " ")
                          
      )
    
  })
}

shinyApp(ui, server) 

ward_SA_subset <- ward_SA[ward_SA@data$DENSITY >= 0 & ward_SA@data$DENSITY <= 1474,]
sapply(slot(ward_SA_subset, "polygons"), function(x) slot(x, "ID"))
ward_SA_subset@data$ORDER

all.equal(ward_SA_subset@data$ORDER, as.numeric(sapply(slot(ward_SA_subset, "polygons"), function(x) slot(x, "ID"))))


