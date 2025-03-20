cat("~ sourcing 4_maps.R ~")

## (credit) Map Code taken from CU's wip branch

##Data to be plotted
work_data_map <- categorized_data |> 
  filter(actor_category %in% main_actors3, event_type == "Battles", geo_precision %in% c(1, 2))

saveRDS(work_data_map, "data/intermediate/work_data_map.RDS")

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
# print(summary(elev_stars[["elevation"]]))

# contour levels, interval = 100 meters
min_val <- as.numeric(floor(min(elev_stars[["elevation"]], na.rm = TRUE)))
max_val <- as.numeric(ceiling(max(elev_stars[["elevation"]], na.rm = TRUE)))
breaks <- seq(min_val, max_val, by = 100)

# generate contour lines (stars)
contours <- st_contour(elev_stars["elevation"], breaks = breaks)

# stars object -> df
elev_df <- as.data.frame(elev_stars, xy = TRUE)

##Plotting just the Map

just_map <- ggplot() +
  geom_raster(data = elev_df, aes(x = x, y = y, fill = elevation)) +
  scale_fill_gradient(low = "white", high = "dark green") +
  geom_sf(data = nigeria_sf, fill = NA, color = "black", lwd = 1) +
  coord_sf() +
  labs(title = "Nigeria Elevation Contour Map with Points of Interest",
       fill = "Elevation (m)",
       x = "Longitude",
       y = "Latitude") +
  geom_point(data = pet_fields, aes(x = Longitude, y = Latitude, color = "Oil Fields"),  size = 3) +
  geom_point(data = top10_cities, aes(x = lng, y = lat, color = "Cities"), size = 3) +
  geom_text_repel(data = top10_cities, aes(x = lng, y = lat, label = city), size = 4) +
  scale_color_manual(name = "Points of Interest",
                     values = c("Oil Fields" = "blue",
                                "Cities" = "black"),
                     breaks = c("Cities",
                                "Oil Fields")
  )

ggsave("output/figures/07_just_nigeria_map.png",
       just_map,
       width = 12,
       height = 7,
       units = "in")

## Plotting Battles colored by Actors

battles_in_nigeria <- ggplot() +
  geom_sf(data = nigeria_sf, fill = NA, color = "black", lwd = 1) +
  coord_sf() +
  labs(title = "Map of Nigeria with Battles Grouped by Top 3 Actors",
       fill = "Elevation (m)",
       x = "Longitude",
       y = "Latitude") +
  geom_jitter(data = work_data_map, aes(x = longitude, y = latitude, color = actor_category), size = 1.25, alpha = 1) +
  geom_point(data = top10_cities, aes(x = lng, y = lat, color = "Cities"), size = 3) +
  scale_color_manual(name = "Cities and Battles",
                     values = c("Cities" = "black",
                                palette_actors),
                     breaks = c("Cities",
                                "Identity militia",
                                "ISWAP and/or Boko Haram",
                                "State forces")
  )

ggsave("output/figures/08_nigeria_map_with_battles.png",
       battles_in_nigeria,
       width = 12,
       height = 7,
       units = "in")

## Plotting Protest in Nigeria

protest_data <- wide_data_categorized |> 
  filter(event_type %in% c("Riots", "Protests"), geo_precision %in% c(1, 2))

saveRDS(protest_data, "data/intermediate/protest_data.RDS")

protest_in_nigeria <- ggplot() +
  geom_sf(data = nigeria_sf, fill = NA, color = "black", lwd = 1) +
  coord_sf() +
  geom_jitter(data = protest_data, aes(x = longitude, y = latitude, colour = event_type)) +
  geom_point(data = top10_cities, aes(x = lng, y = lat, color = "Cities"), size = 3) +
  labs(title = "Map of Nigeria with Riots and Protests",
       x = "Longitude",
       y = "Latitude") +
  scale_color_manual(name = "Cities, Protests and Riots",
                     values = c("Cities" = "black",
                                palette_events
                     ),
                     breaks = c("Cities",
                                "Riots",
                                "Protests"
                                )
  )

ggsave("output/figures/09_map_with_protest_and_riots.png",
       protest_in_nigeria,
       width = 12,
       height = 7,
       units = "in")
