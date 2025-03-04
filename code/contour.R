# Install required packages if not already installed
# install.packages(c("terra", "sf", "ggplot2", "elevatr", "stars", "rnaturalearth", "viridis"))

library(terra)         # raster data 
library(sf)            # vector spatial data handling
library(elevatr)       # elevation data
library(stars)         # converting raster data and generating contours
library(rnaturalearth) # natural earth boundary data

# Read in the processed data from the RDS file
data <- readRDS("data/intermediate/processed_data.RDS")



# Get Nigeria boundary data (rnaturalearth)
nigeria_sf <- ne_countries(country = "Nigeria", returnclass = "sf")

# Get elevation data (elevatr), higher z == higher resolution
elev_raster <- get_elev_raster(nigeria_sf, z = 6)

# Convert the elevation data to a terra raster object
elev_terra <- rast(elev_raster)

# Crop and mask to Nigeria's boundaries
elev_crop <- crop(elev_terra, vect(nigeria_sf))
elev_mask <- mask(elev_crop, vect(nigeria_sf))

# terra raster to a stars object
elev_stars <- st_as_stars(elev_mask, proxy = FALSE)

# give attr. name, should be numeric
names(elev_stars) <- "elevation"
elev_stars[["elevation"]] <- as.numeric(elev_stars[["elevation"]])
print(summary(elev_stars[["elevation"]]))

# contour levels, interval = 100 meters
min_val <- as.numeric(floor(min(elev_stars[["elevation"]], na.rm = TRUE)))
max_val <- as.numeric(ceiling(max(elev_stars[["elevation"]], na.rm = TRUE)))
breaks <- seq(min_val, max_val, by = 100)

# generate contour lines (stars)
contours <- st_contour(elev_stars["elevation"], breaks = breaks)

# stars object -> df
elev_df <- as.data.frame(elev_stars, xy = TRUE)

ggplot() +
  geom_raster(data = elev_df, aes(x = x, y = y, fill = elevation)) +
  scale_fill_gradient(low = "white", high = "dark green") +
  #geom_sf(data = contours, color = "white", size = 0.01, alpha = 0.1) + # optional contour lines
  geom_sf(data = nigeria_sf, fill = NA, color = "black") +
  geom_point(data = data, aes(x = longitude, y = latitude), alpha = 0.01, color = "dark red", size = 2) +
  coord_sf() +
  labs(title = "Nigeria Elevation Contour Map with Conflict Events",
       fill = "Elevation (m)",
       x = "Longitude",
       y = "Latitude") +
  theme_minimal()

