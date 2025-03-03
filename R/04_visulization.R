
daily_casualties <- readRDS("data/intermediate/daily_casualties.RDS")


p <- ggplot(daily_casualties, aes(x = event_date, y = casualties)) +
  geom_col(width = 100) +
  labs(title = "Daily Casualties Over Time",
       x = "Date",
       y = "Casualties")


ggsave("output/figures/daily_casualties.png", plot = p, width = 10, height = 6, dpi = 300)

## Barplot counting events, facetted by groups, leaving out Civilians and Rioters and Protesters
##kicked out Civilians

data_with_actor <- get_actor_cate(widened_actor1(data))

event_counter_plot <- data_with_actor |>
  filter(event_type != "Strategic developments") |> 
  filter(actor_category %in% c("State forces",
                               "Rebel group",
                               "Identity militia",
                               "Political militia",
                               "External/Other forces",
                               "Protesters",
                               "Rioters"
                               )
         ) |> 
  ggplot(aes(x = event_type)) +
  geom_bar() +
  facet_grid(rows = vars(actor_category)) +
  labs(x = "Event Type", y = "Count", title = "Count of Events by Acting Group") +
  scale_x_discrete(labels = c("Battles",
                              "Remote Violence",
                              "Protests",
                              "Riots",
                              "VTC")
  )

ggsave("output/figures/event_counter_plot.png",
       plot = event_counter_plot,
       width = 10,
       height = 6,
       dpi = 300)

## Alternative Plot focussing on Death Tolls

death_toll_plot <- data_with_actor |> 
  filter(actor_category %in% c("State forces",
                               "Rebel group",
                               "Identity militia",
                               "Political militia",
                               "External/Other forces",
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
  labs(x = "Event Type", y = "Death Toll", title = "Death Count by acting Group")

ggsave("output/figures/death_toll_plot.png",
       plot = death_toll_plot,
       width = 10,
       height = 6,
       dpi = 300)

##Comments: This Analysis expects actor1 in data_with_actor to be the perpetrator
##For this Analysis couting rioters as a unique group is senseless bacause they
##only commit Riots, would they have attacked someone they would be militants or
##Unidentified

cumulative_deaths <-data_with_actor |> 
  group_by(event_date) |> 
  summarise(deaths = sum(fatalities, na.rm = TRUE)) |> 
  mutate(cum_sum = cumsum(deaths)) |> 
  ggplot(aes(x = event_date, y = cum_sum)) +
  geom_line() +
  labs(x = "Date",
       y = "Cumulative Sum of Deaths",
       title = "Cumulative Deaths in Nigerian Conflicts from 1997 to 2025") +
  scale_x_continuous(breaks = pretty(data_with_actor$event_date, n = 6))

ggsave("output/figures/cumulative_deaths.png",
       plot = cumulative_deaths,
       width = 10,
       height = 6,
       dpi = 300)
