# Step E1. Identify relevant ecoregion

library(sf)

# 1. Read the shapefile
shp <- st_read("Ecoregion/Litoral_baixo.shp")

# 2. Write to GeoJSON
st_write(shp, "Ecoregion/Litoral_baixo.geojson", driver = "GeoJSON")
