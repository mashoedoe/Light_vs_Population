# https://github.com/rstudio/leaflet/blob/master/inst/examples/shiny.R
library(shiny)
library(leaflet)
#options(unzip = "internal"); devtools::install_github("ropensci/geojsonio")
library(geojsonio)
library(spatstat)
library(rgdal)

#town_SA <- readRDS("/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/RDS/town_SA.rds")
#geodata <- paste(readLines(system.file("examples/test.json", package = "leaflet")), collapse = "\n")
town_tj <- paste(readLines("/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/TopoJSON/LocalMunicipalities2011.json"), collapse = "\n")
#town_json <- jsonlite::validate(town_tj)
#town_json <- jsonlite::fromJSON(town_tj)
#geo_json <- jsonlite::fromJSON(geodata)
town_shp <- readOGR(dsn = "/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/Mapshaper/Towns_5.0/LocalMunicipalities2011.shp", 
                            layer = "LocalMunicipalities2011")
#geodata_sp <- geojson_read(system.file("examples/test.json", package = "leaflet"))
#file.copy(from = "/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/TopoJSON/LocalMunicipalities2011.json",
#          to = "/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/TopoJSON/LocalMunicipalities2011.topojson")
#town_tj_sp1 <- topojson_read(x="/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/TopoJSON/LocalMunicipalities2011.topojson")
#town_tj_sp <- readOGR(dsn = "/media/mashudu/A296E14C96E12191/Copy/git/Light_vs_Population/TopoJSON/LocalMunicipalities2011.json", 
#                      layer = "LocalMunicipalities2011")
town_shp_gj <- geojson_list(town_shp)
town_shp_gj$features[1]

# replace geojson with town_shp_gj
# town_json$type
# 
# geo_json$type
# head(town_json$objects$LocalMunicipalities2011$type)
# 
# geo_json$features$geometry$type
# head(town_json$objects$LocalMunicipalities2011$geometries$type)
# 
# geo_json$features$geometry$coordinates
# 
# geo_json$features$properties
# town_json$objects$LocalMunicipalities2011$geometries$properties
# 
# town_json$objects$LocalMunicipalities2011$geometries$properties$CAT_B
#   
# geo_json$features$type
# town_json$objects$LocalMunicipalities2011$geometries$type
# 
# geo_json$features
# town_json$objects$LocalMunicipalities2011$geometries
# 
# 
# head(town_json$objects$LocalMunicipalities2011$geometries$properties$CAT_B)


ui_gj <- fluidPage(
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


server_gj <- function(input, output, session) {
  v <- reactiveValues(msg1 = "")
  v <- reactiveValues(msg2 = "")
  v <- reactiveValues(msg3 = "")
  v <- reactiveValues(msg4 = "")
  v <- reactiveValues(msg5 = "")
  v <- reactiveValues(msg6 = "")
  v <- reactiveValues(msg7 = "")
  
  output$map1 <- renderLeaflet({
    leaflet() %>%
        addGeoJSON(geojson = town_shp_gj) %>%
      # addTopoJSON(topojson = town_tj) %>%
      #      addCircles(-60, 60, radius = 5e5, layerId = "circle") %>%
      setView(zoom = 5, lng = 27, lat = -27)
    #fitBounds(lng1 = -87.1875, lat1 = 71.4131, lng2 = 128.3203, lat2 = 0.3515)
  })
  
  observeEvent(input$map1_geojson_mouseover, {
    v$msg1 <- paste("Mouse is over", input$map1_geojson_mouseover$properties$MUNICNAME)
  })
  observeEvent(input$map1_geojson_mouseout, {
    v$msg1 <- ""
  })
  observeEvent(input$map1_geojson_click, {
    v$msg2 <- paste("AREA IS:", input$map1_geojson_click$properties$AREA)
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
  observeEvent(input$map1_click, {
    v$msg5 <- paste("Mouse coordinates: Lat", round(input$map1_click$lat, digits = 3), 
                    "Long", round(input$map1_click$lng, digits = 3))
    #     if (input$addMarker) {
    #       leafletProxy("map1") %>%
    #         addMarkers(lng = input$map1_click$lng, lat = input$map1_click$lat)
    #     }
  })
  observeEvent(input$map1_geojson_mouseover, {
    v$msg5 <- paste("Mouse coordinates: Lat", round(input$map1_geojson_mouseover$lat, digits = 3), 
                    "Long", round(input$map1_geojson_mouseover$lng, digits = 3))
  })
  observeEvent(input$map1_geojson_mouseout, {
    v$msg5 <- ""
  })
  
  #  observeEvent(input$map1_mouseout, {
  #    v$msg5 <- ""
  #  })
  
  observeEvent(input$map1_zoom, {
    v$msg6 <- paste("Zoom is", input$map1_zoom)
  })
  observeEvent(input$map1_bounds, {
    v$msg7 <- paste("Bounds: lat",
                    substr(paste(input$map1_bounds[1]),start = 1, stop = 6),"long",
                    substr(paste(input$map1_bounds[4]),start = 1, stop = 6),"(topleft); lat", 
                    substr(paste(input$map1_bounds[3]),start = 1, stop = 6),"long", 
                    substr(paste(input$map1_bounds[2]),start = 1, stop = 6),"(bottomright)")
    
    #      "Bounds: lat", (input$map1_bounds[1]),"long", round(input$map1_bounds[2],3), "(topright);")#,
    #                    "lat", round(input$map1_bounds[3],3), "long", round(input$map1_bounds[4],3), "(bottomleft)") #, collapse = ", "
  })
  #   observeEvent(input$clearMarkers, {
  #     leafletProxy("map1") %>% clearMarkers()
  #   })
  
  output$message1 <- renderText(v$msg1)
  output$message2 <- renderText(v$msg2)
  output$message3 <- renderText(v$msg3)
  output$message4 <- renderText(v$msg4)
  output$message5 <- renderText(v$msg5)
  output$message6 <- renderText(v$msg6)
  output$message7 <- renderText(v$msg7)
}

shinyApp(ui_gj, server_gj)

# library(shiny)
# library(leaflet)
# 
# geodata <- paste(readLines(system.file("examples/test.json", package = "leaflet")), collapse = "\n")
# 
# ui <- fluidPage(
#   leafletOutput("map1"),
#   checkboxInput("addMarker", "Add marker on click"),
#   actionButton("clearMarkers", "Clear all markers"),
#   textOutput("message", container = h3)
# )
# 
# server <- function(input, output, session) {
#   v <- reactiveValues(msg = "")
#   
#   output$map1 <- renderLeaflet({
#     leaflet() %>%
#       addGeoJSON(geodata) %>%
#       addCircles(-60, 60, radius = 5e5, layerId = "circle") %>%
#       fitBounds(-87.1875, 71.4131, 128.3203, 0.3515)
#   })
#   
#   observeEvent(input$map1_geojson_mouseover, {
#     v$msg <- paste("Mouse is over", input$map1_geojson_mouseover$featureId)
#   })
#   observeEvent(input$map1_geojson_mouseout, {
#     v$msg <- ""
#   })
#   observeEvent(input$map1_geojson_click, {
#     v$msg <- paste("Clicked on", input$map1_geojson_click$featureId)
#   })
#   observeEvent(input$map1_shape_mouseover, {
#     v$msg <- paste("Mouse is over shape", input$map1_shape_mouseover$id)
#   })
#   observeEvent(input$map1_shape_mouseout, {
#     v$msg <- ""
#   })
#   observeEvent(input$map1_shape_click, {
#     v$msg <- paste("Clicked shape", input$map1_shape_click$id)
#   })
#   observeEvent(input$map1_click, {
#     v$msg <- paste("Clicked map at", input$map1_click$lat, "/", input$map1_click$lng)
#     if (input$addMarker) {
#       leafletProxy("map1") %>%
#         addMarkers(lng = input$map1_click$lng, lat = input$map1_click$lat)
#     }
#   })
#   observeEvent(input$map1_zoom, {
#     v$msg <- paste("Zoom changed to", input$map1_zoom)
#   })
#   observeEvent(input$map1_bounds, {
#     v$msg <- paste("Bounds changed to", paste(input$map1_bounds, collapse = ", "))
#   })
#   observeEvent(input$clearMarkers, {
#     leafletProxy("map1") %>% clearMarkers()
#   })
#   
#   output$message <- renderText(v$msg)
# }
# 
# shinyApp(ui, server)
# 
# 
# library(shiny)
# library(leaflet)
# 
# geodata <- paste(readLines(system.file("examples/test.json", package = "leaflet")), collapse = "\n")
# 
# ui <- fluidPage(
#   leafletOutput("map1"),
#   checkboxInput("addMarker", "Add marker on click"),
#   actionButton("clearMarkers", "Clear all markers"),
#   textOutput("message", container = h3)
# )
# 
# server <- function(input, output, session) {
#   v <- reactiveValues(msg = "")
#   
#   output$map1 <- renderLeaflet({
#     leaflet() %>%
#       addGeoJSON(geodata) %>%
#       addCircles(-60, 60, radius = 5e5, layerId = "circle") %>%
#       fitBounds(-87.1875, 71.4131, 128.3203, 0.3515)
#   })
#   
#   observeEvent(input$map1_geojson_mouseover, {
#     v$msg <- paste("Mouse is over", input$map1_geojson_mouseover$featureId)
#   })
#   observeEvent(input$map1_geojson_mouseout, {
#     v$msg <- ""
#   })
#   observeEvent(input$map1_geojson_click, {
#     v$msg <- paste("Clicked on", input$map1_geojson_click$featureId)
#   })
#   observeEvent(input$map1_shape_mouseover, {
#     v$msg <- paste("Mouse is over shape", input$map1_shape_mouseover$id)
#   })
#   observeEvent(input$map1_shape_mouseout, {
#     v$msg <- ""
#   })
#   observeEvent(input$map1_shape_click, {
#     v$msg <- paste("Clicked shape", input$map1_shape_click$id)
#   })
#   observeEvent(input$map1_click, {
#     v$msg <- paste("Clicked map at", input$map1_click$lat, "/", input$map1_click$lng)
#     if (input$addMarker) {
#       leafletProxy("map1") %>%
#         addMarkers(lng = input$map1_click$lng, lat = input$map1_click$lat)
#     }
#   })
#   observeEvent(input$map1_zoom, {
#     v$msg <- paste("Zoom changed to", input$map1_zoom)
#   })
#   observeEvent(input$map1_bounds, {
#     v$msg <- paste("Bounds changed to", paste(input$map1_bounds, collapse = ", "))
#   })
#   observeEvent(input$clearMarkers, {
#     leafletProxy("map1") %>% clearMarkers()
#   })
#   
#   output$message <- renderText(v$msg)
# }
# 
# shinyApp(ui, server)

