cat("~ sourcing 3_plots.R ~")

## Code for Plots
## Notice that the numbers in file names are according to their position in the script
## and not the position in the presentation

## removing trailing whitespace from actor1 strings
## i know this should be in data tidying actually, but i dont want to touch working code

data <- data |> mutate(actor1 = gsub(" $", "", actor1))

categorized_data <- get_actor_cate(data)

## Find event count and associated deaths for armed groups (i.e. removing Civilians, Rioters, Protesters as 
## they are expected to be the victims, if they did any killings they wouldn't be in their respective categories)

main_actors_table <- categorized_data |>
  filter(!(actor1 %in% c("Civilians", "Protesters", "Rioters"))) |> 
  group_by(actor_category) |>
  summarise(n = n(),
            total_deaths_associated = sum(fatalities, na.rm = TRUE),
            fatalities_per_observation = total_deaths_associated / n) |>
  arrange(desc(total_deaths_associated))

## Using this to determine the Main Actors
main_actors <- head(main_actors_table, 5)$actor_category
main_actors3 <- head(main_actors_table, 3)$actor_category

## Which groups are especially harmful towards Civilians ?

##Use widened data

wide_data_categorized <- get_actor_cate(widened_actor1(data))

## Find the Perpetrator, this works because there is no case where civilian_targeting == TRUE,
## actor1 == "Civilian" and actor2 == "Civilian"
## also actor_category seems to be accurate as well, since there are no "Civilians" in there

work_data_vtc <- wide_data_categorized |>
  filter(civilian_targeting == TRUE, actor1 == "Civilians" | actor2 == "Civilians") |> 
  filter(!is.na(actor1) & !is.na(actor2))

## Use main_actors and work_data_vtc to determine Brutality towards Civilians

vtc_plot <- work_data_vtc |> 
  mutate(actor_category = case_when(
    actor_category %in% main_actors ~ actor_category,
    TRUE ~ "Unidentified Armed Group"
  )) |>
  mutate(actor_category = case_when(
    actor_category == "Unidentified Armed Group" ~ "Unidentified or small group",
    TRUE ~ actor_category
  )) |> 
  group_by(actor_category, event_date) |>
  summarise(deaths = sum(fatalities, na.rm = TRUE)) |> 
  mutate(cum_sum = cumsum(deaths)) |> 
  ggplot(aes(x = event_date, y = cum_sum, colour = actor_category)) +
  geom_line() +
  labs(title = "Cumulated Deaths of Civilians in Attacks Directly Aimed at Civilians by Perpetrator",
       y = "Cumulative Sum of Deaths",
       x = "Event Date") +
  scale_colour_discrete(name = "Perpetrator") +
  scale_x_continuous(breaks = pretty(work_data_vtc$event_date, n = 6))

ggsave("output/figures/01_grouped_violence_towards_civilians_plot.png",
       vtc_plot,
       width = 8,
       height = 6,
       units = "in")

## Notes: Boko Haram/IS and identity militias are the biggest murderers of civilians,
## Big Spike in ~ 2014
## Boko Haram is worse than IS
## Unidentified and small groups make up a large fraction

## Create Pie Chart for Overview

pie_chart <- wide_data_categorized |> 
  group_by(event_type) |> 
  summarise(n = n()) |>
  mutate(proportion = n/sum(n),
         label = paste0(round(proportion * 100), "%"),
         cumulative = cumsum(n) - (n/2)
         ) |> 
  ggplot(aes(x = "", y = proportion, fill = event_type)) +
  geom_bar(stat = "identity", width = 1) +  # Create bar chart
  coord_polar(theta = "y", start = 0) +  # Convert to pie chart
  theme_void() +  # Remove background
  labs(fill = "Event Type", title = "Proportions of Event Types") +
  geom_text(aes(label = label),
            position = position_stack(vjust = 0.5))

ggsave("output/figures/02_pie_chart_event_types.png",
       pie_chart,
       width = 8,
       height = 6,
       units = "in")

## Lineplot of event types over time

work_data_events <- wide_data_categorized |>
  year_function() |> 
  filter(year != 2025)

event_type_year_plot <- work_data_events |> 
  group_by(event_type, year) |> 
  summarise(n = n()) |> 
  ggplot(aes(x = as.numeric(year), y = n, colour = event_type)) +
  geom_line() +
  labs(title = "Count of Yearly Events from 1997 to 2024 by Type",
       y = "Event Count",
       x = "Year") +
  scale_colour_discrete(name = "Event Type") +
  scale_x_continuous(breaks = seq(1, length(levels(work_data_events$year)), by = 3),
                     labels = levels(work_data_events$year)[seq(1, length(levels(work_data_events$year)), by = 3)])

ggsave("output/figures/03_lineplot_event_types.png",
       event_type_year_plot,
       width = 8,
       height = 6,
       units = "in")

## Fatalities as Alternative
fatalities_per_group_plot <- categorized_data |> 
  filter(actor_category %in% main_actors) |> 
  group_by(actor_category, event_date) |> 
  summarise(deaths = sum(fatalities, na.rm = TRUE)) |> 
  mutate(cum_deaths = cumsum(deaths)) |> 
  ggplot(aes(x = event_date, y = cum_deaths, colour = actor_category)) +
  geom_line() +
  labs(title = "Cumulative Deaths over Time per Group",
       x = "Event Date",
       y = "Cumulative Deaths") +
  scale_color_discrete(name = "Actor Category") +
  scale_x_continuous(breaks = pretty(categorized_data$event_date, n = 6))

ggsave("output/figures/04_fatalities_per_group_plot.png",
       fatalities_per_group_plot,
       width = 8,
       height = 6,
       units = "in")

## Facetted Barplot Actors/Event Type

group_names <- c("Identity militia" = "Identity Militia",
                 "ISWAP and/or Boko Haram" = "IS/Boko Haram",
                 "Political militia" = "Political Militia",
                 "State forces" = "State Forces",
                 "Unidentified Armed Group" = "Unidentified",
                 "Unidentified or small group" = "Unidentified/Small")

facetted_bar_plot_remote_violence <- categorized_data |> 
  filter(event_type %in% c("Explosions/Remote violence")) |>
  group_by(sub_event_type, actor_category) |>
  filter(n() > 20) |> 
  ungroup() |> 
  filter(actor_category %in% main_actors) |> 
  ggplot(aes(x = sub_event_type)) +
  geom_bar() +
  facet_grid(rows = vars(actor_category), labeller = as_labeller(group_names)) +
  scale_x_discrete(labels = c("Air/Drone Strike",
                              "IED/Landmine",
                              "Artillery/Missile",
                              "Suicide Bomb")
                   ) +
  labs(title = "Bar Plot of Counts of Remote Violence Associated with Actors",
       y = "Count of Event",
       x = "Event Type",
       caption = "Note: Due to the structure of the data, it is not possible to
       determine who the perpetrator is in these cases. So having used one type
       of violence and having received it are both counted in this plot!")

ggsave("output/figures/05_facetted_remote_violence.png",
       facetted_bar_plot_remote_violence,
       width = 8,
       height = 6,
       units = "in")

## Violence towards Civilians facetted Plot

facetted_bar_plot_violence_towards_civilians <- work_data_vtc |> 
  mutate(actor_category = case_when(
    actor_category %in% main_actors ~ actor_category,
    TRUE ~ "Unidentified Armed Group"
  )) |>
  mutate(actor_category = case_when(
    actor_category == "Unidentified Armed Group" ~ "Unidentified or small group",
    TRUE ~ actor_category
  )) |>
  group_by(sub_event_type, actor_category) |>
  filter(n() > 25) |> 
  ungroup() |>
  ggplot(aes(x = sub_event_type)) +
  geom_bar() +
  facet_grid(rows = vars(actor_category), labeller = as_labeller(group_names)) +
  labs(title = "Facetted Bar Plot of Type of Violence Towards Civilians by Actors",
       y = "Count of Event",
       x = "Event Type") +
  scale_x_discrete(labels = c("Abduction",
                              "Attack",
                              "Mob Violence",
                              "IED/Landmine",
                              "Sexual Violence",
                              "Suicide Bomb"))

ggsave("output/figures/06_facetted_sub_event_towards_civilians.png",
       facetted_bar_plot_violence_towards_civilians,
       width = 8,
       height = 6,
       units = "in")
