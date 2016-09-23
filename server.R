    require(shiny)
    require(leaflet)
    require(DT)
    require(dplyr)
    load("data/modis_tiles.RData")

    tile_df <- as.data.frame(tiles, stringsAsFactors = F)

    modis_prods <- rts::modisProducts() %>%
      mutate_each(funs(as.character)) %>%
      filter(product %in% MODISTools::GetProducts())

    shinyServer(function(input, output, session){

      output$map <- renderLeaflet({
        req(tiles)

        leaflet(tiles) %>%
          addTiles() %>%
          addPolygons(
            stroke = T,
            fillOpacity = 0,
            weight = 2,
            popup = ~paste("MODIS Tile<br>", "H", h, "V", v)
          ) %>%
          setView(
            lng = -100,
            lat = 38,
            zoom = 4
          )

      })

      output$prod_tbl <- DT::renderDataTable({
        req(modis_prods, input$prod_select)

        DT::datatable(modis_prods %>% filter(product == input$prod_select),
                escape = T,
                style = 'bootstrap',
                selection = 'multiple',
                rownames = FALSE,
                extensions = c('ColReorder'),
    		    options = list(
    		        pageLength = 5,
                    dom = 'C<"clear">tr',
                    lengthMenu = list(c(5, 10, 20, -1),
                                      c('5', '10', '20', 'All')),
                    tableTools = list(sSwfPath = copySWF())))
      })

      observe({
        updateSelectInput(session, "prod_select",
          choices = MODISTools::GetProducts())
      })

      output$date_tbl <- DT::renderDataTable({
        req(input$prod_select, input$h_tile, input$v_tile)

        xy <- tile_df %>%
          filter(h %in% input$h_tile, v %in% input$v_tile) %>%
          select(x, y, h, v)

        withProgress(message = "Retrieving Dates", {
          mdts <- bind_rows(lapply(1:nrow(xy), function(i){
            incProgress(amount = i/nrow(xy))
            dts <- MODISTools::GetDates(
              Product = input$prod_select,
              Lat = xy$y[i],
              Long = xy$x[i]
            )

            data.frame(
              Product = input$prod_select,
              Tile = paste0("h", xy$h[i], "v", xy$v[i]),
              MODISDate = dts,
              Date = as.Date(gsub("A", "", dts), "%Y%j")
            )

          }))
        })

        DT::datatable(mdts,
                escape = T,
                style = 'bootstrap',
                selection = 'multiple',
                rownames = FALSE,
                filter = list(position = 'top', clear = F),
                extensions = c('ColReorder'),
    		    options = list(
    		        pageLength = 5,
                    dom = 'C<"clear">T<"clear">Rltirp',
                    lengthMenu = list(c(5, 10, 20, -1),
                                      c('5', '10', '20', 'All')),
                    tableTools = list(sSwfPath = copySWF())))
      })

      output$band_tbl <- DT::renderDataTable({
        req(input$prod_select, input$h_tile, input$v_tile)

        bands <- data.frame(
          Band = MODISTools::GetBands(input$prod_select)
        )

        DT::datatable(bands,
                escape = T,
                style = 'bootstrap',
                selection = 'multiple',
                rownames = FALSE,
                filter = list(position = 'top', clear = F),
                extensions = c('ColReorder'),
    		    options = list(
    		        pageLength = 5,
                    dom = 'C<"clear">T<"clear">Rltirp',
                    lengthMenu = list(c(5, 10, 20, -1),
                                      c('5', '10', '20', 'All')),
                    tableTools = list(sSwfPath = copySWF())))

      })





    })