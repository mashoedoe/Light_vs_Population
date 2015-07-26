library(shiny)
library(leaflet)
library(DT)

wards_SA_ordered <- readRDS("RDS/wards_SA_ordered.rds")
wards_SA_ordered@data$DENSITY <- round(wards_SA_ordered@data$DENSITY, digits = 1)

navbarPage(
  title = "Night Light & Population Density",
  tabPanel(
    title = "Map", 
    leafletOutput(outputId = "map", width = "100%", height = "700px"),
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
