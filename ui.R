    #  A simple application to find MODIS tiles
    #  Josh Nowak
    #  08/2016
################################################################################
    #  Load packages
    require(shiny)
    require(DT)
    require(leaflet)
################################################################################
    #  Define user interface
    shinyUI(
      navbarPage(
        tags$a(
          href = "http://popr.cfc.umt.edu/",
          "PopR MODIS Helper",
          target = "blank"
        ),
        tabPanel("Tile Finder",
          fixedPage(
            h5("Click on the map to see the horizontal and vertical coordinates for each MODIS tile."),
            leaflet::leafletOutput("map"),
            tags$i("Tile data sourced from",
              tags$a(
                href = "http://book.ecosens.org/modis-sinusoidal-grid-download/",
                "book.ecosens.org",
                target = "blank"
              ),
              "and reprojected to EPSG 4326."
            )
          )
        ),
        tabPanel("Data Summary",
          fixedPage(
          wellPanel(
            fluidRow(
              column(4,
                tags$div(
                  title = "Define a MODIS product to see data summary",
                  selectInput("prod_select",
                    "Select product",
                    choices = "No Data",
                    multiple = F
                  )
                )
              ),
              column(4,
                tags$div(
                  title = "Enter horizontal tiles of interest",
                  selectInput("h_tile",
                    "Horizontal Tile(s)",
                    choices = 0:35,
                    multiple = T
                  )
                )
              ),
              column(4,
                tags$div(
                  title = "Enter horizontal tiles of interest",
                  selectInput("v_tile",
                    "Vertical Tile(s)",
                    choices = 0:17,
                    multiple = T
                  )
                )
              )
            )
          ),
          fluidRow(
            hr(),
            h4("Product Summary"),
            DT::dataTableOutput("prod_tbl")
          ),
          fluidRow(
            hr(),
            h4("Date Summary"),
            DT::dataTableOutput("date_tbl")
          ),
          fluidRow(
            hr(),
            h4("Bands"),
            DT::dataTableOutput("band_tbl")
          ),
          tags$div(style = "padding-bottom:100px")
          )
        )
      , id = "tile", windowTitle = "PopR"
      )  #  navbarPage
    )  # shinyUI