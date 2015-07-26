## Only run this example in interactive R sessions
if (interactive()) {
  shinyApp(
    ui = fluidPage(
      sidebarLayout(
        sidebarPanel(
          p("The first slider controls the second"),
          selectInput("control", "Controller:", choices = seq(from = 0, to = 20, by = 1),
                      selected = 10), 
          sliderInput("receive", "Receiver:", min=0, max=20, value=10,
                       step=1)

        ),
        mainPanel()
      )
    ),
    server = function(input, output, session) {
      observe({
        val <- input$control
        # Control the value of slider with the drop down.
        updateSliderInput(session, "receive", value = val)
                          
      })
    }
  )
}

shinyApp(ui, server)

## Only run this example in interactive R sessions
if (interactive()) {
  shinyApp(
    ui = fluidPage(
      sidebarLayout(
        sidebarPanel(
          p("The first slider controls the second"),
          sliderInput("control", "Controller:", min=0, max=20, value=10,
                       step=1),
          sliderInput("receive", "Receiver:", min=0, max=20, value=10,
                       step=1)
        ),
        mainPanel()
      )
    ),
    server = function(input, output, session) {
      observe({
        val <- input$control
        # Control the value, min, max, and step.
        # Step size is 2 when input value is even; 1 when value is odd.
        updateSliderInput(session, "receive", value = val, 
                          min = floor(val/2), max = val+4, step = (val+1)%%2 + 1)
      })
    }
  )
}
