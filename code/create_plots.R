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

## Nigeria Maps: Heat Map Categorized by Type of Militant groups

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

## Facetted Barplot counting events

categorized_data |>
  ggplot(aes(x = event_type)) +
  geom_bar() +
  facet_grid(rows = vars(group_association)) +
  scale_x_discrete(labels = c("Battles",
                             "Remote Violence",
                             "Protests",
                             "Riots",
                             "Strategics",
                             "VTC")
  ) +
  labs(x = "Event Type", y = "Count")

## Alternative Plot focussing on Death Tolls

categorized_data |> 
  group_by(event_type, group_association) |> 
  summarise(deaths = sum(fatalities, na.rm = TRUE)) |> 
  ungroup() |>
  filter(event_type != "Strategic developments" & event_type != "Protests") |> 
  ggplot(aes(x = event_type, y = deaths)) +
  geom_col() +
  facet_grid(rows = vars(group_association)) +
  labs(x = "Event Type", y = "Death Toll")

##Comments: This Analysis expects actor1 in categorized_data to be the perpetrator
##For this Analysis couting rioters as a unique group is senseless bacause they
##only commit Riots, would they have attacked someone they would be militants or
##Unidentified
