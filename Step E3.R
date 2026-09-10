# Step E3. Obtain historical values for Condition indicators
library(terra)
library(tidyverse)

mapbiomas.files <- list.files("./Mapbiomas/", full.names = T)

# Collection 9 - MapBiomas

mapbiomas <- lapply(mapbiomas.files, terra::rast) 

# Naming Mapbiomas rasters
names(mapbiomas) <- paste0("mb_", c(2014:2023))

# Checking for NAs
plot(mapbiomas[[1]], colNA = "red")

# Reclassification

is <- c(1, 3, 4, 5, 6, 49,10, 11, 12, 32, 29, 50, 14, 15, 18, 19, 39, 20, 40, 62, 41, 36, 46, 47, 48, 9, 21, 22, 23, 24, 30, 25, 26, 33, 31, 27)

becomes <- c(1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4)

# 1 = Forest
# 2 = Other vegetation
# 3 = Antropic areas
# 4 = No vegetation areas

reclass_matrix <- matrix(c(is, becomes), ncol = 2)

# Forest estimation

i = names(mapbiomas[2])

if(!dir.exists("Results")){dir.create("Results")}
if(!dir.exists("Results/Rcl")){dir.create("Results/Rcl")}

dir_out <- "./Results/"
sub_dir <- "Rcl/"

for(i in names(mapbiomas)){
  message(i)
  mapbio.i <- mapbiomas[[i]] # Selecting a raster of i year
  mapbio_rcl <- terra::classify(mapbio.i, rcl = reclass_matrix ) # Reclassifying a raster
  
  # Saving reclassified raster
  terra::writeRaster(mapbio_rcl, paste0(dir_out, sub_dir, "ecoregion_", i, "_rcl.tiff"), overwrite = T)
}

# Improving mapbiomas rasters with Harpia Project data----

mapbiomas.files <- list.files("./Results/Rcl", full.names = T, pattern = "rcl.tiff" )
mapbiomas <- lapply(mapbiomas.files, terra::rast) 
eco_reg <- terra::vect("Ecoregion/Litoral_baixo.shp")
eco_reg <- terra::project(eco_reg, crs(mapbiomas[[1]]))
harpia <- terra::vect("harpia/harpia.shp") # Harpia data
eco_map <- terra::rast("Mapbiomas/ecoregion_mb_2014.tiff")

# Project to WGS84
harpia <- terra::project(harpia, "EPSG:4326") 

# Extracting deforestation occurrences within ecoregion
harpia_crop <- terra::crop(harpia, eco_reg)

# Create mask
harpia_mask <- terra::mask(harpia_crop, eco_reg)

# Convert view_date column to Date format
harpia_mask$view_date <- as.Date(harpia_mask$view_date, format = "%Y-%m-%d")

# Create year column 
harpia_mask$ano <- format(harpia_mask$view_date, "%Y")

# Obtain year date
anos <- sort(unique(harpia_mask$ano))

# Filter occurrence by year using indexation. Results in a list
lista_por_ano <- lapply(anos, function(ano) {
  harpia_mask[harpia_mask$ano == ano, ]
})

# plot(mapbiomas_harpia[[i]])
# plot(harpia[[i]])
# plot(r_mask)

# Naming the list
names(lista_por_ano) <- anos

# Naming Mapbiomas rasters
names(mapbiomas) <- paste0("mb_", c(2014:2023))

# Setting mapbiomas raster to be improved with Harpia project data
mapbiomas_harpia <- mapbiomas[3:10]
harpia <- lista_por_ano[1:8]

i = 1
for(i in 1:length(mapbiomas_harpia)){
  message(i)
  # Converting harpia vector to a binary raster (1 = within deforestation area, NA = without deforestation area)
  
  harpia_rast <- rasterize(harpia [[i]], mapbiomas_harpia[[i]], values = 1, background = NA)

  # Create mask of values = 1 in the original raster within polygons. Identify pixels:
  
  # - 1 Original raster (mapbioma == 1)
  # - and within polygon (!is.na(harpia_rast))
  mask <- mapbiomas_harpia[[i]] == 1 & !is.na(harpia_rast)
  
  # Create a copy of original raster and modify specific pixels
  mapbiomas_harpia[[i]][mask] <- 3  # replace pixels of values 1 to 3
  gc() # Garbage collection
}

# Replace old mapbiomas raster by improved raster, and Saving 
mapbiomas[3:10] <- mapbiomas_harpia

if(!dir.exists("Results/Harpia")){dir.create("Results/Harpia")}
harpia_dir = "Harpia/"

for(i in names(mapbiomas)){
  message(paste("Saving",i, "Harpia"))
  terra::writeRaster(mapbiomas[[i]], paste0(dir_out, harpia_dir, "ecoregion_", i, "_Harpia.tiff"), overwrite = T)
}


# # Improving by excluding areas of UC strict protection
# 
# 
# mapbiomas.files <- list.files(paste0(dir_out, harpia_dir), full.names = T )
# mapbiomas <- lapply(mapbiomas.files, terra::rast) 
# eco_reg <- terra::vect("ecoregion.gpkg")
# eco_reg <- terra::project(eco_reg, crs(mapbiomas[[1]]))
# 
# ucf <- terra::vect("./CocoaBiodiverse/Shapes/UC_Federais.shp") # UCs federais
# uce <- terra::vect("./CocoaBiodiverse/Shapes/UC_Estadual_Protecao_Integral.shp") # UCs estaduais
# ucm <- terra::vect("./CocoaBiodiverse/Shapes/UC_Municipal_Protecao_Integral.shp") # UCs municipais
# 
# ucf <- project(ucf, crs(eco_reg))
# uce <- project(uce, crs(eco_reg))
# ucm <- project(ucm, crs(eco_reg))
# 
# # garantir mesma coluna e mesmo nome
# ucf <- ucf[,"nome"]
# uce <- uce[,"nome_ofici"]; names(uce) <- "nome"
# ucm <- ucm[,"nome_uc"];   names(ucm) <- "nome"
# 
# # garantir mesmo tipo (por exemplo: character)
# ucf$nome <- as.character(ucf$nome)
# uce$nome <- as.character(uce$nome)
# ucm$nome <- as.character(ucm$nome)
# 
# # checagens
# names(ucf); names(uce); names(ucm)
# sapply(as.data.frame(ucf), class)
# sapply(as.data.frame(uce), class)
# sapply(as.data.frame(ucm), class)
# 
# # empilhar
# uc_merged <- rbind(ucf, uce)
# uc_merged <- rbind(uc_merged, ucm)
# 
# # plot(eco_reg)
# # plot(ucf, add = T)
# # plot(uce, add = T)
# # plot(ucm, add = T)
# 
# uc_merged$nome
# plot(uc_merged, add = T)
# 
# library(terra)
# 
# # mapbiomas <- lista de SpatRaster
# # uc_merged <- SpatVector com as UCs
# 
# # Função para aplicar máscara invertida (excluir UCs)
# remove_uc <- function(raster_layer, uc_vector) {
#   mask(raster_layer, uc_vector, inverse = TRUE)
# }
# 
# # Aplicar a todos os rasters da lista
# mapbiomas_clean <- lapply(mapbiomas, remove_uc, uc_vector = uc_merged)
# 


# Final Table ----

if(!dir.exists("Results/Final")){dir.create("Results/Final")}
final_dir = "Final/"

habitat <- tibble(Ano = names(mapbiomas), n_pixels = as.double(NA), Percentage = as.double(NA))
i = 1
for(i in 1:length(mapbiomas)){
  message(i)
  mapbiomas.i <- mapbiomas[[i]]
  
  n_values <- freq(mapbiomas.i) 
  
  total <- sum(n_values$count)
  
  n_values <- n_values  %>% 
    mutate(Percentage = (count*100)/total)
  
  write_csv(n_values, paste0(dir_out, final_dir, "freq_", i, ".csv"))
  
  n_1 <- n_values[n_values$value == 1, "count"] 
  
  habitat[i,"n_pixels"] <- n_1
  habitat[i,"Percentage"] <- (n_1*100)/total
}
plot(mapbiomas.i)
write_csv(habitat, paste0(dir_out, "condition.csv"))

