library(gapminder)
library(maps)
library(gifski)

processed_data <- readRDS("data/intermediate/processed_data.RDS")

nigeria_map <- map_data("world", region = "Nigeria")


# conflict events on the Nigeria map
ggplot() +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(data = data, aes(x = longitude, y = latitude, color = event_type),
             alpha = 0.6, size = 2) +
  facet_wrap(~event_type) +
  theme_minimal() +
  labs(title = "Armed Conflict Events in Nigeria", x = "Longitude", y = "Latitude", color = "Event Type")+
  transition_time(year) +
  ease_aes('linear')


month_day = month(processed_data$event_date)

pmonth<-ggplot(processed_data, aes(longitude,latitude,colour = event_type)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.7, show.legend = FALSE) +
  
  # scale_size(range = c(2, 12)) +
  # scale_x_log10() +
  facet_wrap(~event_type) +
  # Here comes the gganimate specific bits
  labs(title = "Armed Conflict Events in Nigeria month: {frame_time}", x = "Longitude", y = "Latitude", color = "Event Type")+
  transition_time(as.integer(month_day)) +
  ease_aes('linear')
animate(pmonth,duration = 40)
anim_save("output/figures/event_type_month.gif",pmonth)

pyear<-ggplot(processed_data, aes(longitude,latitude,colour = event_type)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.7, show.legend = FALSE) +
  
  # scale_size(range = c(2, 12)) +
  # scale_x_log10() +
  facet_wrap(~event_type) +
  # Here comes the gganimate specific bits
  labs(title = "Armed Conflict Events in Nigeria year: {frame_time}", x = "Longitude", y = "Latitude", color = "Event Type")+
  transition_time(as.integer(year)) +
  ease_aes('linear')
animate(pyear,duration = 40)
anim_save("output/figures/event_type_year.gif", pyear)