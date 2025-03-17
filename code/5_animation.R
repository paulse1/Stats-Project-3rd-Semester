cat("~ sourcing 5_animation.R ~")

##Animating the Protest in Nigeria

animation_protest_data <- year_month_function(protest_data)

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
                     values = c("Oil Fields" = "blue",
                                "Cities" = "black",
                                "Riots" = palette[[1]],
                                "Protests" = palette[[2]]
                     ),
                     breaks = c("Cities",
                                "Oil Fields",
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

anim_protests <- animate(protest_in_nigeria_animation, nframes = 800, fps = 20)

anim_save("output/gif/01a_protests.gif", animation = anim_protests)

##Animating Top 3 Conflicts in Nigeria

animation_top3_plot_data <- year_month_function(work_data_map)

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
                     values = c("Oil Fields" = "blue",
                                "Cities" = "black",
                                "Identity militia" = palette[[1]],
                                "ISWAP and/or Boko Haram" = palette[[2]],
                                "Political militia" = palette[[5]],
                                "State forces" = palette[[3]],
                                "Unidentified Armed Group" = palette[[4]]),
                     breaks = c("Cities",
                                "Oil Fields",
                                "Identity militia",
                                "ISWAP and/or Boko Haram",
                                "Political militia",
                                "State forces",
                                "Unidentified Armed Group")
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

anim_battles <- animate(top_3_battles_animation, nframes = 800, fps = 20)

anim_save("output/gif/02a_battles.gif", animation = anim_battles)
