
daily_casualties <- readRDS("data/intermediate/daily_casualties.RDS")


p <- ggplot(daily_casualties, aes(x = event_date, y = casualties)) +
  geom_col(width = 100) +
  labs(title = "Daily Casualties Over Time",
       x = "Date",
       y = "Casualties")


ggsave("output/figures/daily_casualties.png", plot = p, width = 10, height = 6, dpi = 300)

## Barplot counting events, facetted by groups, leaving out Civilians and Rioters and Protesters

data_with_actor <- get_actor_cate(widened_actor1(data))

data_with_actor |>
  filter(event_type != "Strategic developments") |> 
  filter(actor_category %in% c("State forces",
                               "Rebel group",
                               "Identity militia",
                               "Political militia",
                               "External/Other forces",
                               "Civilians",
                               "Protesters",
                               "Rioters"
                               )
         ) |> 
  ggplot(aes(x = event_type)) +
  geom_bar() +
  facet_grid(rows = vars(actor_category)) +
  labs(x = "Event Type", y = "Count") +
  scale_x_discrete(labels = c("Battles",
                              "Remote Violence",
                              "Protests",
                              "Riots",
                              "VTC")
  )


## Alternative Plot focussing on Death Tolls

data_with_actor |> 
  filter(actor_category %in% c("State forces",
                               "Rebel group",
                               "Identity militia",
                               "Political militia",
                               "External/Other forces",
                               "Civilians",
                               "Protesters",
                               "Rioters"
  )
  ) |> 
  group_by(event_type, actor_category) |> 
  summarise(deaths = sum(fatalities, na.rm = TRUE)) |> 
  ungroup() |>
  filter(event_type != "Strategic developments" & event_type != "Protests") |> 
  ggplot(aes(x = event_type, y = deaths)) +
  geom_col() +
  facet_grid(rows = vars(actor_category)) +
  labs(x = "Event Type", y = "Death Toll")

##Comments: This Analysis expects actor1 in data_with_actor to be the perpetrator
##For this Analysis couting rioters as a unique group is senseless bacause they
##only commit Riots, would they have attacked someone they would be militants or
##Unidentified

data_with_actor |> 
  group_by(event_date) |> 
  summarise(deaths = sum(fatalities, na.rm = TRUE)) |> 
  mutate(cum_sum = cumsum(deaths)) |> 
  ggplot(aes(x = event_date, y = cum_sum)) +
  geom_line()