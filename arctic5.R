if (!require("ggmap")) install.packages("ggmap")
if (!require("rgeos")) install.packages("rgeos")
if (!require("maptools")) install.packages("maptools")

library(ggmap)
library(rgeos)
library(maptools)
library(proj4)
library(data.table)
library(rgdal)
library(dplyr)
library(raster)


#------
shpmaine <- readOGR("State_Boundary_Lines__Maine.shp")
gbif <- fread("tst/maine_plants.csv", sep = "\t", header = TRUE, na.strings = "\\N")
#------

#read shape file from CAFF
shpfile <- "Bioclimate_Subzones.shp"
#read downloaded GBIF csv file as data frame
gbif <- fread("arctic_plants.txt", sep = "\t", header = FALSE, na.strings = "\\N")

#'Filter georeferenced records by shapefile
#'
#' @param shapefile A shapefile object (.shp)
#' @param occurrence_df A data frame of georeferenced records. For large csv use fread()
#' @param lat The column name for latitude in the data frame
#' @param lon The column name for longitude in the data frame
#' @param gbifid A unique record key
#' @param map_crs The datum assigned to the occurrence data frame
#' @param mkplot Whether to draw the map plots. Can be very expensive
occurrence.from.shapefile <- function(shapefile, occurrence_df, lat, lon, gbifid, map_crs = "+proj=longlat +datum=WGS84", mkplot = FALSE){
  
  shape <- readOGR(shapefile)
  
  #subset the GBIF data into a data frame
  gbif.map <- data.frame(gbif[[lat]], gbif[[lon]], gbif[[gbifid]])
  #simplify column names
  names(gbif.map)[1:3] <- c('long', 'lat', 'gbifid')
  #turning the data frame into a "spatial points data frame"
  coordinates(gbif.map) <- c("long", "lat")
  #defining the datum 
  proj4string(gbif.map) <- CRS(map_crs)
  #reprojecting the 'gbif' data frame to the same as in the 'shape' object 
  gbif.map <- spTransform(gbif.map, proj4string(shape))
  
  #Identifying records from gbif that fall within the shape polygons
  inside <- gbif.map[apply(gIntersects(gbif.map, shape, byid = TRUE), 2, any),]
  
  if(mkplot){
    raster::plot(shape)
    points(inside, col = "olivedrab3")
  }  
  
  #Prepare data frame for joining with the occcurrence df so only records 
  #that fall inside the polygons get selected 
  res.gbif <- data.frame(inside@data)
  final.gbif <- gbif %>% semi_join(res.gbif, by = c(gbifid = "gbifid"))
  
  #write.csv(final.gbif, file = "gbif_records_by_shapefile.csv", sep = "\t", col.names = FALSE)
  return(final.gbif)
}  
  