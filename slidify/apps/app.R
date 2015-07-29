server <- function(input, output, session) {
  colorpal <- reactive({
    colorNumeric(c(marray::maPalette(low = "#09183e", mid = "yellow", high = "white",
                                     k = dim(wards_SA_ordered[wards_SA_ordered@data$DENSITY <= input$integer,])[1]),
                   rep(x = "#FFFFFF", 
                       times = (4277 - dim(wards_SA_ordered[wards_SA_ordered@data$DENSITY <= input$integer,])[1]))),
                 domain = c(0, input$integer), na.color = "white")
  })
  
  output$map <- renderLeaflet({
    map = leaflet(
      wards_SA_ordered
    ) %>%
      addTiles(
        urlTemplate <- "http://map1.vis.earthdata.nasa.gov/wmts-webmerc/VIIRS_CityLights_2012/default/GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpeg", 
        group = "Night Light (default)",
        attribution = paste('Imagery provided by GIBS,',
                            'operated by the NASA/GSFC/<a href="https://earthdata.nasa.gov">EOSDIS</a>',
                            'with funding provided by NASA/HQ.')
      ) %>% 
      setView(
        lng = 25, lat = -28, zoom = 5
      )
  })
  
  
  observe({
    val <- input$select_densities
    updateSliderInput(session, "integer", value = val)
  })

  observe({
    proxy1 <- leafletProxy("map", data = wards_SA_ordered) 
    proxy1 %>% clearShapes()
    pal <- colorpal()
    if (input$ward_polygons) {
      proxy1 %>%
        addPolygons(
          stroke = T, weight = 1, opacity = 0, color = "white", fillOpacity = 1,
          smoothFactor = 0.5, fillColor = ~pal(DENSITY)
        )}
  })
  
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy2 <- leafletProxy("map", data = wards_SA_ordered)
    # Remove any existing legend, and only if the legend is enabled, create a new one.
    proxy2 %>% clearControls()
    pal <- colorpal()
    proxy2 %>% addLegend(
      position = "bottomright", pal = pal, values = ~DENSITY,
      title = "Population/km<sup>2</sup>", opacity = 1, na.label = "Over 1500",
      labFormat = labelFormat(big.mark = " ")
    )
  })
  
}
