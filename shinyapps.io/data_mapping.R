# set working directory
if ((stringr::str_sub(getwd(), -23) == "git/Light_vs_Population") == FALSE) {
  setwd("git/Light_vs_Population")
}

source("data_tidying.R")

# load libraries  
library(rgdal)
library(rgeos)
library(maptools)
library(leaflet)
library(marray)

## load Shapefile data - not required if TopoJSON files we created are sufficient

# ward_MDB <- readOGR("SHP/Wards/Wards2011.shp", layer = "Wards2011", verbose = FALSE)
# ward_StatsSA <- readOGR("/media/mashudu/disk_a1/Murray/GIS/Census_2011_Spatial_Geography/WD_SA_2011.shp",
#                          layer = "WD_SA_2011", verbose = FALSE)
# town_MDB <- readOGR("SHP/LocalMunicipalities2011.shp", layer = "LocalMunicipalities2011", verbose = FALSE)
# province_MDB <- readOGR("SHP/Province_New_SANeighbours.shp", layer = "Province_New_SANeighbours", verbose = FALSE)
# 
# # check projections
# CRS_ward_MDB <- proj4string(obj = ward_MDB)
# CRS_ward_StatsSA <- proj4string(obj = ward_StatsSA)
# 
# # get current ID of polygons 
# slot_area_MDB <- sapply(slot(ward_MDB, "polygons"), function(x) slot(x, "ID"))
# 
# # get polygon slot: "area" (in sq degrees) to compare different sources of South African Shapefiles
# slot_area_MDB <- sapply(slot(ward_MDB, "polygons"), function(x) slot(x, "area"))
# slot_area_StatsSA <- sapply(slot(ward_StatsSA, "polygons"), function(x) slot(x, "area"))

# load the TopoJSON polygon data for Wards, Municipalities and Provinces
ward_tj_txt  <- readLines(con = "TopoJSON/Wards2011.json", warn = F)
town_tj_txt <- readLines(con = "TopoJSON/LocalMunicipalities2011.json", warn = F)
province_tj_txt <- readLines(con = "TopoJSON/Province_New_SANeighbours.json", warn = F)

ward_tj <- readOGR(dsn = "TopoJSON/Wards2011.json", layer = "Wards2011")
town_tj <- readOGR(dsn = "TopoJSON/LocalMunicipalities2011.json", layer = "LocalMunicipalities2011")
province_tj <- readOGR(dsn = "TopoJSON/Province_New_SANeighbours.json", layer = "Province_New_SANeighbours")

#exploration of the TopoJSON content for "ward_tj"
# class(ward_tj)
# ward_tj@proj4string
# ward_tj@bbox
# sum(gIsEmpty(ward_tj, byid = T))
# sum(gIsSimple(ward_tj, byid = T))
# which(gIsValid(ward_tj, byid = T) == F)
# which(gIsValid(town_tj, byid = T) == F) 
# which(gIsValid(province_tj, byid = T) == F) 
# slot_area_tj <- sapply(slot(ward_tj, "polygons"), function(x) slot(x, "area"))
# SA_Area_SQdegree_tj <- gArea(ward_tj, byid = F) # South Africa's surface area in sq degrees

# merge dbf and spatialpolygon data
ward_SA <- SpatialPolygonsDataFrame(data = ward_dbf, Sr = ward_tj, match.ID = "ORDER")
town_SA <- SpatialPolygonsDataFrame(data = town_dbf, Sr = town_tj, match.ID = "ORDER")
province_SA <- SpatialPolygonsDataFrame(data = province_dbf, Sr = province_tj, match.ID = "ORDER")

# choropleth palette for ward density. all density above 70th percentile (1474) is coded as "white"
night_colors <- maPalette(low = "navy", mid = "yellow", high = "white")
ventiles <- round(quantile(ward_SA@data$DENSITY, probs = seq(0, 1, 0.05)), digits = 0)
pal_night <- colorNumeric(palette = night_colors, domain = ventiles[1:15], na.color = "white")

# popups on clicking polygons
ward_popup <- paste0("<strong>Ward: </strong>",
                     ward_SA@data$ID,
                     "<br />",
                     "<strong>Density: </strong>",
                     round(ward_SA@data$DENSITY, digits = 1),
                     " people/km",
                     "<sup>2</sup>")

town_popup <- paste0("<strong>Muncipality: </strong>",
                     town_SA@data$MUNICNAME,
                     "<br />",
                     "<strong>Density: </strong>",
                     round(town_SA@data$DENSITY, digits = 1),
                     " people/km",
                     "<sup>2</sup>")

# ward level choropleth spatial polygon map of population density over VIIRS City Light map tiles
ward_density_map <- leaflet(ward_SA) %>% setView(lng = 28.2, lat = -26, zoom = 5) %>%
# Base Groups
    addTiles(
      urlTemplate <- "http://map1.vis.earthdata.nasa.gov/wmts-webmerc/VIIRS_CityLights_2012/default/GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpeg", 
      group = "Night Light (default)",
      attribution = paste('Imagery provided by GIBS,',
                          'operated by the NASA/GSFC/<a href="https://earthdata.nasa.gov">EOSDIS</a>',
                          'with funding provided by NASA/HQ.')
      ) %>%
  addProviderTiles("CartoDB.DarkMatter", group = "CartoDB Dark Matter") %>%
  #addProviderTiles("Stamen.Toner", group = "Stamen Toner") %>%  
  #addProviderTiles("CartoDB.Positron") %>%
  #addProviderTiles("MtbMap") %>%
# Overlay Groups  
  addPolygons(data = ward_SA, stroke = T, weight = 0.5, opacity = 0, color = "navy", fillOpacity = 1, 
              smoothFactor = 0.5, fillColor = ~pal_night(DENSITY), 
              popup = ward_popup, options = popupOptions(), group =  "Population Density"
              ) %>%
  addProviderTiles("Stamen.TonerLines", group = "Labels, Roads & Borders") %>% 
  addProviderTiles("Stamen.TonerLabels", group = "Labels, Roads & Borders") %>%
  addLegend(position = "bottomright", pal = pal_night, 
            values = ~ventiles[seq(from = 1, to = 15, 2)],
              #ventiles[seq(from = 1, to = 16, 3)], # ventiles[seq(from = 1, to = 19, 3)], 
            title = "Population/km<sup>2</sup>", opacity = 1, na.label = "Over 1500", 
            labFormat = labelFormat(big.mark = " ")) %>%
# Layer Control  
  addLayersControl(baseGroups = c("Night Light (default)", "CartoDB Dark Matter"),
                   overlayGroups = c("Population Density"),
                   options = layersControlOptions(collapse = FALSE)
)

# ward AND municipal level spatial polygon choropleth map of population density over VIIRS City Light map tiles
wm_density_map <- leaflet(ward_SA) %>% setView(lng = 28.2, lat = -26, zoom = 5) %>%
  # Base Groups
  addTiles(urlTemplate = "http://map1.vis.earthdata.nasa.gov/wmts-webmerc/VIIRS_CityLights_2012/default/GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpeg", 
           group = "Night Light (default)", 
           attribution = paste('Imagery provided by GIBS,', 'operated by the NASA/GSFC/<a href="https://earthdata.nasa.gov">EOSDIS</a>',
                               'with funding provided by NASA/HQ.')
           ) %>%
  addProviderTiles("CartoDB.DarkMatter", group = "CartoDB Dark Matter") %>%
# Overlay Groups  
  addPolygons(data = ward_SA, stroke = T, weight = 0.5, opacity = 0, color = "navy", fillOpacity = 1, 
              smoothFactor = 0.5, fillColor = ~pal_night(DENSITY), 
              popup = ward_popup, options = popupOptions(), group =  "Ward Population Density"
              ) %>%
  addPolygons(data = town_SA, stroke = T, weight = 1, opacity = 0, color = "white", fillOpacity = 1, 
              smoothFactor = 1, fillColor = ~pal_night(DENSITY), 
              popup = town_popup, options = popupOptions(), group =  "Municipal Population Density"
              ) %>% 
  addTopoJSON(topojson = province_tj_txt, stroke = T, weight = 2, color = "black", fill = FALSE, 
              fillOpacity = 0.5, smoothFactor = 1,  
              #popup = ward_popup, 
              options = popupOptions(), group =  "Labels, Roads & Borders"
              ) %>%
  addProviderTiles("Stamen.TonerLines", group = "Labels, Roads & Borders", options = ) %>% 
  addProviderTiles("Stamen.TonerLabels", group = "Labels, Roads & Borders") %>%
  addLegend(position = "bottomright", pal = pal_night, 
            values = ~ventiles[seq(from = 1, to = 15, 2)],
            title = "Population/km<sup>2</sup>", opacity = 1, na.label = "Over 1500", 
            labFormat = labelFormat(big.mark = " ")) %>%
  # Layer Control  
  addLayersControl(baseGroups = c("Night Light (default)", "Ward Population Density"),
                   overlayGroups = c("Municipal Population Density", "CartoDB Dark Matter", 
                                     "Labels, Roads & Borders"),
                   options = layersControlOptions(collapse = FALSE)
  )


# topojson ward AND municipal map
topojson_density_map <- leaflet() %>% setView(lng = 28.2, lat = -26, zoom = 5) %>%
# Base Groups
  addProviderTiles("CartoDB.Positron", group = "CartoDB Positron") %>%
# Overlay Groups  
  addTopoJSON(topojson = ward_tj_txt, stroke = T, weight = 1, color = "grey", fill = T, 
              fillOpacity = 0.5, smoothFactor = 0.5, fillColor = "green", 
              options = popupOptions(), group =  "Population Density (Ward level)"
              ) %>%
  addTopoJSON(topojson = town_tj_txt, stroke = T, weight = 1.5, color = "red", fill = T, 
              fillOpacity = 0.5, smoothFactor = 0.5, fillColor = "yellow",
              options = popupOptions(), group =  "Population Density (Municipal level)"
              ) %>%
  addTopoJSON(topojson = province_tj_txt, stroke = T, weight = 2, color = "black", fill = F, 
              fillOpacity = 1, smoothFactor = 0.5, 
              options = popupOptions(), group =  "Population Density (Provincial level)"
              ) %>%
# Layer Control  
  addLayersControl(baseGroups = c("CartoDB Positron"),
                   overlayGroups = c("Population Density (Ward level)", 
                                     "Population Density (Municipal level)",
                                     "Population Density (Provincial level)"),
                   options = layersControlOptions(collapse = FALSE)
                   )

if (!dir.exists("RDS")) dir.create("RDS")

save.image(file = "gis.RData")
saveRDS(town_SA, file = "RDS/town_SA.rds")
saveRDS(town_tj, file = "RDS/town_tj.rds")
saveRDS(town_dbf, file = "RDS/town_dbf.rds")
saveRDS(ward_SA, file = "RDS/ward_SA.rds")
saveRDS(ward_tj, file = "RDS/ward_tj.rds")
saveRDS(ward_dbf, file = "RDS/ward_dbf.rds")

# steps to create wards_SA_ordered SpatialPolygonDataframe:
wards_SA <- rgdal::readOGR(dsn = "Mapshaper/Wards_2.5/Wards2011.shp", layer = "Wards2011")
wards_SA@data$WARD_ID <- as.integer(as.character(wards_SA@data$WARD_ID))
Population <- read.csv("data/Population2011.csv", header = T)
sum(Population$WARD == wards_SA@data$WARD_ID)
Population <- Population[order(Population$WARD), ]
wards_SA <- wards_SA[order(wards_SA@data$WARD_ID),]
if (sum(Population$WARD == wards_SA@data$WARD_ID) == 4277) {
wards_SA@data$POPULATION <- Population$Population
}
names(wards_SA@data) <- sub("^WARD_POP$", "VOTERS", names(wards_SA@data))
wards_SA@data$DENSITY <- wards_SA@data$POPULATION/wards_SA@data$Area
wards_SA_ordered <- wards_SA[order(wards_SA@data$DENSITY),]
saveRDS(object = wards_SA_ordered, file = "wards_SA_ordered.rds")
