# Installieren und Laden der benötigten Pakete
library(shiny)
library(leaflet)

# Erstellen der Shiny-App
ui <- fluidPage(
  titlePanel("Durchschnittsnote berechnen"),

  fluidRow(
      column(1,wellPanel(
             h4("2. Halbjahr 5. Klasse"),
             numericInput("deutsch1", "Deutsch", value = 2, min = 1, max = 6),
             numericInput("mathe1", "Mathe", value = 1, min = 1, max = 6),
             numericInput("englisch1", "Englisch", value = 2, min = 1, max = 6),
             numericInput("natur1", "Nawi", value = 1, min = 1, max = 6),
             numericInput("gesellschaft1", "Gewi", value = 1, min = 1, max = 6),
             numericInput("kunst1", "Kunst", value = 1, min = 1, max = 6),
             numericInput("musik1", "Musik", value = 1, min = 1, max = 6),
             numericInput("sport1", "Sport", value = 1, min = 1, max = 6),
      )),
      column(1,wellPanel(
             h4("1. Halbjahr 6. Klasse"),
             numericInput("deutsch2", "Deutsch", value = 1, min = 1, max = 6),
             numericInput("mathe2", "Mathe", value = 1, min = 1, max = 6),
             numericInput("englisch2", "Englisch", value = 1, min = 1, max = 6),
             numericInput("natur2", "Nawi", value = 1, min = 1, max = 6),
             numericInput("gesellschaft2", "Gewi", value = 1, min = 1, max = 6),
             numericInput("kunst2", "Kunst", value = 1, min = 1, max = 6),
             numericInput("musik2", "Musik", value = 1, min = 1, max = 6),
             numericInput("sport2", "Sport", value = 1, min = 1, max = 6),
      )),
      column(10,wellPanel(
        h4("Auswertung"),
        actionButton("berechnen", "Durchschnitt berechnen"),
        h4("Durchschnittswerte"),
        textOutput("durchschnitt"),
        textOutput(" "),
        h4("Karte"),
        leafletOutput("berlin_karte")
    ))
  )
)

server <- function(input, output, session) {
  observeEvent(input$berechnen, {
    noten <- c(input$deutsch1,
               input$deutsch1,
               input$deutsch2,
               input$deutsch2,
               input$mathe1,
               input$mathe1,
               input$mathe2,
               input$mathe2,
               input$englisch1,
               input$englisch1,
               input$englisch2,
               input$englisch2,
               input$natur1,
               input$natur2,
               input$gesellschaft1,
               input$gesellschaft2,
               input$kunst1,
               input$kunst2,
               input$musik1,
               input$musik2,
               input$sport1,
               input$sport2,
               input$natur1,
               input$natur2,
               input$gesellschaft1,
               input$gesellschaft2)

    durchschnitt <- sum(noten) / length(noten)
    output$durchschnitt <-
      renderText({
        paste("Die berechnete Durchschnittsnote beträgt:", round(durchschnitt, 2))
      })

      source("get_schools_from_fis_broker.R")
      schuldaten <- schulen %>%
        rename(lon = X, lat = Y) %>%
        filter(schultyp %in% c("Integrierte Sekundarschule", "Gymnasium"))

      output$berlin_karte <- renderLeaflet({
        leaflet(schuldaten) %>%
          addTiles() %>%
          setView(lng = 13.4049, lat = 52.5200, zoom = 11) %>%
          addCircleMarkers(
            lng = ~lon,
            lat = ~lat,
            color = ~schultyp,
            radius = 8,
            popup = ~name
          ) %>%
          addLegend(position = "bottomright", colors = c("red", "yellow", "green"),
                  labels = c("Rot", "Gelb", "Grün"), title = "Farben")
    })

  })
}

shinyApp(ui = ui, server = server)
