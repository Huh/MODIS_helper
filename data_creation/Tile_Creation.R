    #  MODIS tile selector
    #  Josh Nowak
    #  08/2016
################################################################################
    #  Load packages - Make sure they are installed first
    require(rgdal)
    require(sp)
    require(leaflet)
################################################################################
    #  MODIS_Tile file downloaded from 
    #  http://book.ecosens.org/modis-sinusoidal-grid-download/
    #  shapefile manually extracted using 7-zip

    #  Define the folder and layer name
    folder <- "C:/Users/josh.nowak/Downloads/modis_grid"
    file <- "modis_sinusoidal_grid_world"

    #  Read in shapefile of MODIS tiles
    shp <- readOGR(dsn = folder, layer = file)
    
    #  Read in WGS84 bounding box
    bbo <- readOGR("C:/tmp/bbox", layer = "ne_10m_wgs84_bounding_box")

    #  Transform bounding box into MODIS projection
    box <- spTransform(bbo, CRS(proj4string(shp)))

    #  Find intersection of bounding box and MODIS tiles
    #  The MODIS data buffers the earth by quite a ways and that will make our 
    #   WGS84 representation of the earth really ugly
    #  This step requires the raster package - called here by namespace
    intx <- raster::intersect(shp, box)

    #  Reproject MODIS tiles into WGS84 because it is required by leaflet
    tiles <- spTransform(
      intx, 
      CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
    )

    #  Add centroids to data
    coord <- do.call(rbind, lapply(slot(tiles, "polygons"), slot, "labpt"))
    
    tiles$x <- coord[,1]
    tiles$y <- coord[,2]
################################################################################
    #  Plot tiles in browser, clicking will produce a popup showing the 
    #   horizontal and vertical tile position
    leaflet(tiles) %>%
      addTiles() %>%
      addPolygons(
        stroke = T,
        fillOpacity = 0,
        popup = ~paste("H", h, "V", v)
      ) %>%
      setView(
        lng = -100,
        lat = 38,
        zoom = 5
      )
################################################################################
    #  If it looks good save it as an R object
    save(
      tiles, 
      file = "C:/Users/josh.nowak/Documents/GitHub/MODIS_helper/data/modis_tiles.RData"
    )
################################################################################
    #  Quick test
    rm(list = ls());gc()
    load("C:/Users/josh.nowak/Documents/GitHub/MODIS_helper/data/modis_tiles.RData")
    leaflet(tiles) %>%
      addTiles() %>%
      addPolygons(
        stroke = T,
        fillOpacity = 0,
        weight = 2,
        popup = ~paste("H", h, "V", v)
      ) %>%
      setView(
        lng = -100,
        lat = 38,
        zoom = 5
      )
################################################################################
    #  End