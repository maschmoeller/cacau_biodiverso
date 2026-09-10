# Step E4. Standardize historical ecoregional Condition indicator

library(terra)
library(tidyverse)

# Downloading Data manually, and save in ICMBio folder ----

# https://www.gov.br/icmbio/pt-br/assuntos/dados_geoespaciais/mapa-tematico-e-dados-geoestatisticos-das-unidades-de-conservacao-federais

#https://www.gov.br/icmbio/pt-br/assuntos/dados_geoespaciais/mapa-tematico-e-dados-geoestatisticos-das-unidades-de-conservacao-federais/limites_ucs_federais_18062025_a.zip

# Loading Data ----
una <- terra::vect("ICMBio/limites_ucs_federais_18062025_a.shp")
# Geospatial data from ICMBio
# https://www.gov.br/icmbio/pt-br/assuntos/dados_geoespaciais

una_shp <- una[una$NomeUC == "RESERVA BIOLÓGICA DE UNA",]

#mapbiomas.files <- list.files("./Results/Final", full.names = T, pattern = "final.tiff" )
mapbiomas.files <- list.files("./Results/Harpia", full.names = T, pattern = "Harpia.tiff" )

mapbiomas <- lapply(mapbiomas.files, terra::rast) 

# Naming Mapbiomas rasters
names(mapbiomas) <- paste0("mb_", c(2014:2023))

# Equal crs
una_wgs84 <- terra::project(una_shp, mapbiomas[[1]])

same.crs(mapbiomas[[1]], una_wgs84)

# Extracting values all step-time
# Test
ecoreg_2009 <- mapbiomas[[1]]

una_mb_2009 <- terra::crop(ecoreg_2009, una_wgs84) %>% 
  terra::mask(una_wgs84)

n_values <- freq(una_mb_2009)
n_1 <- n_values[n_values$value == 1, "count"]

# Running for all step-time ----

una_ref <- tibble(Ano = names(mapbiomas), n_pixels = as.double(NA), Percentage = as.double(NA))

for (i in names(mapbiomas)){
  message(i)
  mapbio.i <- mapbiomas[[i]] 
  mapbio.i_mask <- terra::crop(mapbio.i, una_wgs84) %>% 
    terra::mask(una_wgs84)
  
  n_values <- freq(mapbio.i_mask)
  total <- sum(n_values$count)
  n_1 <- n_values[n_values$value == 1, "count"]
  
  position <- which(names(mapbiomas) == i)
  
  una_ref[position,"n_pixels"] <- n_1
  una_ref[position,"Percentage"] <- (n_1*100)/total
}

write_csv(una_ref, "Results/una_ref.csv")

ref <- mean(una_ref$Percentage)

condition <- read_csv("Results/condition.csv")

# Calculating standardized values ----

# Standardize the ecoregional Condition indicator for each available time-step in the historical data by
# dividing it by the indicator’s reference value

una_condition <- condition %>% 
  mutate(stand_cond = Percentage/ref)

write_csv(una_condition, "Results/Stand_cond_Una.csv")

