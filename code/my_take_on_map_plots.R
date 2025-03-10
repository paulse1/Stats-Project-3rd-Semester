## Run this after "my_take_on_map_plots.R"
## Map Code taken from CU's wip branch

#load packages
library(terra)         # raster data 
library(sf)            # vector spatial data handling
library(elevatr)       # elevation data
library(stars)         # converting raster data and generating contours
library(rnaturalearth) # natural earth boundary data
library(ggrepel)       # nudiging labels

## Additional Data
##Petroleum Fields: https://www.nuprc.gov.ng/oil-production-status-report/
pet_fields <- data.frame(name = c("Bonny", "Brass", "Qua Iboe", "Forcados", "Escravos", "Odudu"),
                         Latitude = c(4.4355, 4.3020, 4.5429, 5.1833, 5.5166, 4.0000),
                         Longitude = c(7.1594, 6.2482, 8.0159, 5.1666, 5.0000, 7.7500)
)

##Cities: https://simplemaps.com/data/ng-cities

cities <- read_csv("data/raw/ng.csv")
top10_cities <- cities |>
  arrange(desc(population)) |> 
  head(10)

##Data to be plotted
work_data_map <- categorized_data |> 
  filter(actor_category %in% main_actors, event_type == "Battles", geo_precision %in% c(1, 2))

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
  # geom_sf(data = contours, color = "white", size = 0.01, alpha = 0.1) + # optional contour lines
  geom_sf(data = nigeria_sf, fill = NA, color = "black", lwd = 1) +
  # geom_point(data = data, aes(x = longitude, y = latitude), alpha = 0.01, color = "dark red", size = 2) +
  coord_sf() +
  labs(title = "Nigeria Elevation Contour Map with Conflict Events",
       fill = "Elevation (m)",
       x = "Latitude",
       y = "Longitude") +
  geom_point(data = work_data_map, aes(x = longitude, y = latitude, color = actor_category), size = 0.5, alpha = 1) +
  geom_point(data = pet_fields, aes(x = Longitude, y = Latitude, color = "Oil Fields"),  size = 3) +
  geom_point(data = top10_cities, aes(x = lng, y = lat, color = "Cities"), size = 3) +
  geom_text_repel(data = top10_cities, aes(x = lng, y = lat, label = city)) +
  # scale_color_manual(name = "Points of Interest",
  #                    values = c("Oil Fields" = "blue",
  #                               "Cities" = "red")
  #                    ) +
  scale_color_manual(name = "Battles and Points of Interest",
                     values = c("Oil Fields" = "blue",
                                "Cities" = "red",
                                "Identity militia" = "purple",
                                "ISWAP and/or Boko Haram" = "yellow3",
                                "Political militia" = "orangered3",
                                "State forces" = "cyan",
                                "Unidentified Armed Group" = "pink"),
                     breaks = c("Cities",
                                "Oil Fields",
                                "Identity militia",
                                "ISWAP and/or Boko Haram",
                                "Political militia",
                                "State forces",
                                "Unidentified Armed Group")
  ) +
  theme_minimal()


