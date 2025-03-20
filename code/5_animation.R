cat("~ sourcing 5_animation.R ~")

##Animating the Protest in Nigeria

animation_protest_data <- year_month_function(protest_data)

saveRDS(animation_protest_data, "data/intermediate/animation_protest_data.RDS")

protest_in_nigeria_animation <- ggplot() +
  geom_sf(data = nigeria_sf, fill = NA, color = "black", lwd = 1) +
  coord_sf() +
  geom_jitter(data = animation_protest_data, aes(x = longitude, y = latitude, colour = event_type), size = 2) +
  geom_point(data = top10_cities, aes(x = lng, y = lat, color = "Cities"), size = 3) +
  labs(title = "Map of Nigeria with Riots and Protests",
       subtitle = "{closest_state}",
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
  ) +
  transition_states(
    year_month,
    transition_length = 1,
    state_length = 1
  ) +
  enter_fade() +
  exit_fade() +
  ease_aes("cubic-in-out") +
  shadow_wake(wake_length = 0.15)

anim_protests <- animate(protest_in_nigeria_animation,
                         nframes = 600, fps = 20, width = 600, height = 350)

anim_save("output/gif/01a_protests.gif", animation = anim_protests)

##Animating Top 3 Conflicts in Nigeria

animation_top3_plot_data <- year_month_function(work_data_map)

saveRDS(animation_top3_plot_data, "data/intermediate/animation_top3_plot_data.RDS")

top_3_battles_animation <- ggplot() +
  geom_sf(data = nigeria_sf, fill = NA, color = "black", lwd = 1) +
  coord_sf() +
  labs(title = "Map of Nigeria with Battles grouped by Top 3 Actors",
       subtitle = "{closest_state}",
       x = "Longitude",
       y = "Latitude") +
  geom_jitter(data = animation_top3_plot_data, aes(x = longitude, y = latitude, color = actor_category), size = 2, alpha = 1) +
  geom_point(data = top10_cities, aes(x = lng, y = lat, color = "Cities"), size = 3) +
  scale_color_manual(name = "Cities and Battles",
                     values = c("Cities" = "black",
                                palette_actors),
                     breaks = c("Cities",
                                "Identity militia",
                                "ISWAP and/or Boko Haram",
                                "Political militia",
                                "State forces",
                                "Unidentified Armed Group")
  ) +
  theme_bw() +
  transition_states(
    year_month,
    transition_length = 1,
    state_length = 1
  ) +
  enter_fade() +
  exit_fade() +
  ease_aes("cubic-in-out") +
  shadow_wake(wake_length = 0.15)

anim_battles <- animate(top_3_battles_animation, nframes = 600, fps = 20, width = 600, height = 350)

anim_save("output/gif/02a_battles.gif", animation = anim_battles)
