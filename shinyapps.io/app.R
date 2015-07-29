library(shiny)
library(leaflet)
library(DT)
library(marray)
library(lattice)
library(grid)

wards_SA_ordered <- readRDS("wards_SA_ordered.rds")
wards_SA_ordered@data$DENSITY <- round(wards_SA_ordered@data$DENSITY, digits = 1)

ui <- navbarPage(
  title = "Night Light & Population Density",
  tabPanel(
    title = "Map", 
    leafletOutput(outputId = "map", width = "100%", height = "600px"),
    absolutePanel(top = 70, left = 70,
      h3("Manipulating a population density choropleth map of South Africa to match
         satelite imagery of Night Light",
         style="color:white"),
      p("Experiment with different upper threshold values to alter how the 
        population density choropleth displays.",
        br(),
        "The default setting is to include the 70% least densely populated wards in the choropleth palette.",
        br(),
        "The remaining 30% most densely populated wards are coded as the color 'white' by default.",
        br(),
        "See how changing these defaults with the slider and dropdown, changes the map display",
         style="color:white"),
      sliderInput(inputId = "integer", 
                  label = span(HTML("Density Threshold in People/km<sup>2</sup>"), style="color:white"),  
                  min = min(wards_SA_ordered@data$DENSITY),
                  max = max(wards_SA_ordered@data$DENSITY), 
                  round = -1, 
                  step = 1,
                  value = round(quantile(x = wards_SA_ordered@data$DENSITY, 
                                         probs = 0.7), 
                                digits = 0),
                  width = "850px"
      ),
      selectInput(
        inputId = "select_densities", 
        label = span("Density Threshold in % of Wards",style="color:white"),
        choices = trunc(quantile(x = wards_SA_ordered@data$DENSITY, 
                                 probs = seq(0, 1, 0.05)
                                 ),
                        digits = 1), 
        selected = trunc(quantile(x = wards_SA_ordered@data$DENSITY, 
                                  probs = 0.7),digits = 1)
        ),
      checkboxInput(
        inputId = "ward_polygons", 
        label = span("Show Population Density Polygons over Satelite Imagery", style="color:white"), TRUE
      )
                  
    )
  ),
  
  tabPanel(
    title = "Documentation",
    wellPanel(style = "color: #09183e;",
      includeMarkdown("documentation.md")
    )
  ),
  
  tabPanel(
    title = "Ward Data",
    wellPanel(style = "color: #09183e;",
              datatable(wards_SA_ordered@data)
    )
  )
)

  
                 
server <- function(input, output, session) {
  #   # Reactive expression for the data subsetted to what the user selected
  #   filteredData <- reactive({
  #     wards_SA_ordered[wards_SA_ordered@data$DENSITY >= 0 & wards_SA_ordered@data$DENSITY <= input$integer,]
  #   })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(c(marray::maPalette(low = "#09183e", mid = "yellow", high = "white",
                                     k = dim(wards_SA_ordered[wards_SA_ordered@data$DENSITY <= input$integer,])[1]),
                   rep(x = "#FFFFFF", 
                       times = (4277 - dim(wards_SA_ordered[wards_SA_ordered@data$DENSITY <= input$integer,])[1]))),
                 domain = c(0, input$integer), na.color = "white")
  })
  
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet() %>% 
      addTiles(
        urlTemplate <- "http://map1.vis.earthdata.nasa.gov/wmts-webmerc/VIIRS_CityLights_2012/default/GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpeg", 
        group = "Night Light (default)",
        attribution = paste('Imagery provided by GIBS,',
                            'operated by the NASA/GSFC/<a href="https://earthdata.nasa.gov">EOSDIS</a>',
                            'with funding provided by NASA/HQ.')
      ) %>%
      setView(lng = 25, lat = -28, zoom = 6)
  })
  
  # control the slider to match the dropdown when the user chooses the dropdown 
  # rather than the slider
  observe({
    val <- input$select_densities
    # Control the value, min, max, and step.
    # Step size is 2 when input value is even; 1 when value is odd.
    updateSliderInput(session, "integer", value = val)
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    proxy1 <- leafletProxy("map", data = wards_SA_ordered) 
    
    proxy1 %>% clearShapes()
    pal <- colorpal()
    if (input$ward_polygons) {proxy1 %>%
        addPolygons(stroke = T, weight = 1, opacity = 0, color = "white", fillOpacity = 1,
                    smoothFactor = 0.5, fillColor = ~pal(DENSITY),
                    popup = ~paste0(wards_SA_ordered@data$MUNICNAME,
                                    "<br />",
                                    "<strong> Ward </strong>",
                                    wards_SA_ordered@data$WARDNO,
                                    "<br />",
                                    "<strong>Density: </strong>",
                                    round(wards_SA_ordered@data$DENSITY, digits = 1),
                                    " people/km",
                                    "<sup>2</sup>"),
                    options = popupOptions()
        )
    }    
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy2 <- leafletProxy("map", data = wards_SA_ordered)
    
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





  
          
          