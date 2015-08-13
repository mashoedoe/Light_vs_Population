# https://github.com/rstudio/leaflet/blob/master/inst/examples/shiny.R
library(jsonlite)
library(geojsonio)
library(rgdal)

library(shiny)
library(leaflet)
#options(unzip = "internal"); devtools::install_github("ropensci/geojsonio")
town_tj
town_tj2



#geodata <- paste(readLines(system.file("examples/test.json", package = "leaflet")), collapse = "\n")
town_tj <- readLines(con = "/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/Mapshaper/LocalMunicipalities2011.topojson")
#town_json <- jsonlite::validate(town_tj)
#town_json <- jsonlite::fromJSON(town_tj)
#geo_json <- jsonlite::fromJSON(geodata)
town_shp <- readOGR(dsn = "/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/Mapshaper/Towns_5.0/LocalMunicipalities2011.shp", 
                            layer = "LocalMunicipalities2011")
#geodata_sp <- geojson_read(system.file("examples/test.json", package = "leaflet"))

town_tj_sp <- topojson_read(x="/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/Mapshaper//LocalMunicipalities2011.topojson")
#or
town_tj_sp <- readOGR(dsn = "/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/Mapshaper/LocalMunicipalities2011.topojson", 
                              layer = "LocalMunicipalities2011")
#town_tj_gj <- geojson_list(town_tj_sp)
#town_gj <- geojson_write(town_shp)
#town_topojson_write(town_shp)


ui <- fluidPage(
  leafletOutput("map1"),
#  checkboxInput("addMarker", "Add marker on click"),
#  actionButton("clearMarkers", "Clear all markers"),
  textOutput("message1", container = h6),
  textOutput("message2", container = h6),
  textOutput("message3", container = h6),
  textOutput("message4", container = h6),
  textOutput("message5", container = h6),
  textOutput("message6", container = h6),
  textOutput("message7", container = h6)
)


server <- function(input, output, session) {
  v <- reactiveValues(msg1 = "")
  v <- reactiveValues(msg2 = "")
  v <- reactiveValues(msg3 = "")
  v <- reactiveValues(msg4 = "")
  v <- reactiveValues(msg5 = "")
  v <- reactiveValues(msg6 = "")
  v <- reactiveValues(msg7 = "")
  
  output$map1 <- renderLeaflet({
      leaflet() %>%
    #  addGeoJSON(map = map, geojson = geodata) %>%
         addTopoJSON(topojson = town_tj) %>%
      #      addCircles(-60, 60, radius = 5e5, layerId = "circle") %>%
      setView(zoom = 5, lng = 27, lat = -27)
      #fitBounds(lng1 = -87.1875, lat1 = 71.4131, lng2 = 128.3203, lat2 = 0.3515)
  })
  
  observeEvent(input$map1_topojson_mouseover, {
    v$msg1 <- paste("Mouse is over", input$map1_topojson_mouseover$properties$MUNICNAME)
      })
  observeEvent(input$map1_topojson_mouseout, {
    v$msg1 <- ""
  })
   observeEvent(input$map1_topojson_click, {
     v$msg2 <- paste("Size", input$map1_topojson_click$properties$AREA, "km<sup>2</sup>")
        })
#  observeEvent(input$map1_shape_mouseover, {
#    v$msg3 <- paste("Mouse is over shape", input$map1_shape_mouseover$id)
#  })
#  observeEvent(input$map1_shape_mouseout, {
#    v$msg3 <- ""
#  })
#  observeEvent(input$map1_shape_click, {
#    v$msg4 <- paste("Clicked shape", input$map1_shape_click$id)
#  })
#   observeEvent(input$map1_click, {
#     v$msg5 <- paste("Mouse coordinates: Lat", round(input$map1_click$lat, digits = 3), 
#                     "Long", round(input$map1_click$lng, digits = 3))
#   })    
  observeEvent(input$map1_topojson_click, {
   v$msg4 <- paste("Click coordinates: Lat", round(input$map1_topojson_click$lat, digits = 3), 
                    "Long", round(input$map1_topojson_click$lng, digits = 3))
  })
#   observeEvent(input$map1_topojson_mouseover, {
#     v$msg5 <- paste("Mouse coordinates: Lat", round(input$map1_topojson_mouseover$lat, digits = 3), 
#                     "Long", round(input$map1_topojson_mouseover$lng, digits = 3))
#   })
#    observeEvent(input$map1_topojson_mouseout, {
#     v$msg5 <- ""
#   })
   observeEvent(input$map1_mouseover, {
     v$msg5 <- paste("Mouse coordinates: Lat", round(input$map1_mouseover$lat, digits = 3), 
                     "Long", round(input$map1_mouseover$lng, digits = 3))
   })
   observeEvent(input$map1_mouseout, {
   v$msg5 <- ""
 })
  
  observeEvent(input$map1_zoom, {
    v$msg6 <- paste("Zoom is", input$map1_zoom)
  })
  observeEvent(input$map1_bounds, {
    v$msg7 <- paste("Bounds: lat",
                    substr(paste(input$map1_bounds[1]),start = 1, stop = 6),"long",
                    substr(paste(input$map1_bounds[4]),start = 1, stop = 6),"(topleft); lat", 
                    substr(paste(input$map1_bounds[3]),start = 1, stop = 6),"long", 
                    substr(paste(input$map1_bounds[2]),start = 1, stop = 6),"(bottomright)")
  })

  output$message1 <- renderText(v$msg1)
  output$message2 <- renderText(v$msg2)
  output$message3 <- renderText(v$msg3)
  output$message4 <- renderText(v$msg4)
  output$message5 <- renderText(v$msg5)
  output$message6 <- renderText(v$msg6)
  output$message7 <- renderText(v$msg7)
}

shinyApp(ui, server)
