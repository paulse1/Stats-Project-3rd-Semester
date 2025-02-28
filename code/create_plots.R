## Plot casualties over time
## change width for different insights
## default width shows ,ost deaths in a day
## wider width might show multi day/week conflicts

widened.data |> 
  group_by(event_date) |> 
  summarise(casualties = sum(fatalities)) |> 
  ungroup() |> 
  ggplot(aes(x = event_date, y = casualties)) +
  geom_col(width = 100)

## Nigeria Maps

nigeria_map <- map_data("world", region = "Nigeria")

ggplot() +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat),
               fill = "lightgray") +
  geom_point(data = categorized_data,
             aes(x = long, y = lat, group = group_association),
             color = "red",
             size = 0.3) +
  facet_wrap(vars(group_association)) +
  theme_bw()
