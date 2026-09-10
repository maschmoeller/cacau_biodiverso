# Step E2. Choose Condition indicator(s) to estimate ecoregional rate of change

# Downloads Mapbiomas ----
library(fs)  
library(tidyverse)
library(terra)

# Define years
anos <- c(2014:2023)

# URL pathway (collection 9 - MapBiomas)
url_base <- "https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_9/lclu/coverage"

# Create folder to save files, if doesn´t exist
dir_create("dados_mapbiomas")

# Loop to download files

for (ano in anos) {
  message("Baixando ", ano)
  url <- sprintf("%s/brasil_coverage_%d.tif", url_base, ano)
  
  destino <- sprintf("dados_mapbiomas/brasil_coverage_%d.tif", ano)
  
  download.file(url, destino, mode = "wb", method = "curl")
}


# Creating ecoregion raster with mapbiomas data ----

ecoreg <- terra::vect("Ecoregion/Litoral_baixo.shp")

ecoreg <- terra::project(ecoreg, crs(mapbiomas[[1]]))

mapbiomas.files <- list.files("./dados_mapbiomas", full.names = T)

mapbiomas <- lapply(mapbiomas.files, terra::rast) 

names(mapbiomas) <- paste0("mb_", c(2014:2023))
mapbiomas[[1]]
i = names(mapbiomas)[1]

same.crs(mapbiomas[[i]], ecoreg)

if(!dir_exists("Mapbiomas")){dir_create("Mapbiomas")}

# plot(ecoreg.i)
for (i in names(mapbiomas)){
  message(i)
  ecoreg.i <- terra::crop(mapbiomas[[i]], ecoreg) %>% 
    terra::mask(ecoreg)
  terra::writeRaster(ecoreg.i,paste0("Mapbiomas/ecoregion_", i, ".tiff"))
}

# Checking
plot(mapbiomas[[i]])
plot(ecoreg, add = TRUE)

# Removing Mapbioma Rasters
unlink("dados_mapbiomas", recursive = T, force = T)
