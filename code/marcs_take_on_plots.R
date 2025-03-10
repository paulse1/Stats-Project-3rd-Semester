##For this Skript "R/02_data_tidy.R" and "code/utils.R" need to be sourced

theme_set(theme_bw())

## removing trailing whitespace from actor1 strings
data <- data |> mutate(actor1 = gsub(" $", "", actor1))

categorized_data <- get_actor_cate(data)

# Total Fatalities for Grouped 5-Year Periods

month_line_grouped_years_plot <- widened_data |>
  mutate(
    month = month(event_date, label = TRUE, abbr = FALSE),  # Extract month as full name
    period = cut(year, breaks = seq(1997, 2027, by = 5), 
                 labels = paste0("[", paste(seq(1997, 2022, by = 5), 
                                seq(2002, 2027, by = 5), sep = "-"), ")"), 
                 include.lowest = TRUE)
  ) |>
  filter(as.numeric(time_precision) != 3) |>
  group_by(period, month) |>
  summarise(total_fatalities = sum(fatalities), .groups = "drop") |>
  complete(period, month = factor(month.name, levels = month.name), 
           fill = list(total_fatalities = 0)) |>
  ggplot(df_agg, aes(x = month, y = total_fatalities, color = period, group = period)) +
  geom_line(size = 1) +  # Line plot instead of area
  labs(title = "Line Plot of Fatalities by Month and 5-Year Period",
       x = "Month",
       y = "Total Fatalities",
       color = "5-Year Period") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# testing

test_month_line_grouped_years_plot <- widened_data |>
  mutate(
    month = month(event_date, label = TRUE, abbr = FALSE),  # Extract month as full name
    period = cut(year, breaks = seq(1997, 2025, by = 1), 
                 labels = paste0("[", paste(seq(1997, 2024, by = 1), 
                                            seq(1998, 2025, by = 1), sep = "-"), ")"), 
                 include.lowest = TRUE)
  ) |>
  filter(as.numeric(time_precision) != 3) |>
  group_by(period, month) |>
  summarise(total_fatalities = sum(fatalities), .groups = "drop") |>
  complete(period, month = factor(month.name, levels = month.name), 
           fill = list(total_fatalities = 0)) |>
  ggplot(df_agg, aes(x = month, y = total_fatalities, color = period, group = period)) +
  geom_line(size = 1) +  # Line plot instead of area
  labs(title = "Line Plot of Fatalities by Month and 5-Year Period",
       x = "Month",
       y = "Total Fatalities",
       color = "1-Year Period") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Cumulative number of events by event_types

number_of_events_per_type_plot <- data |> 
  group_by(event_type, event_date) |> 
  summarise(n_of_events = n()) |> 
  mutate(cum_events = cumsum(n_of_events)) |> 
  ggplot(aes(x = event_date, y = cum_events, colour = event_type)) +
  geom_line() +
  labs(title = "Cumulative number of Events over Time per Event Time",
       x = "Event Date",
       y = "Cumulative Events") +
  scale_color_discrete(name = "Event Type") +
  scale_x_continuous(breaks = pretty(data$event_date, n = 6))
number_of_events_per_type_plot



number_of_events_per_type_targeting_civ_plot <- data |> 
  filter(civilian_targeting,
         event_type != "Violence against civilians") |>
  group_by(event_type, event_date) |> 
  summarise(n_of_events = n(), .groups = "drop") |> 
  mutate(cum_events = cumsum(n_of_events)) |> 
  ggplot(aes(x = event_date, y = cum_events, colour = event_type)) +
  geom_line() +
  labs(title = "Cumulative number of Events targetting civilians",
       x = "Event Date",
       y = "Cumulative Events") +
  scale_color_discrete(name = "Event Type") +
  scale_x_continuous(breaks = pretty(data$event_date, n = 6))
number_of_events_per_type_targeting_civ_plot



number_of_events_per_type_not_targeting_civ_plot <- data |> 
  filter(!civilian_targeting) |>
  group_by(event_type, event_date) |> 
  summarise(n_of_events = n(), .groups = "drop") |> 
  mutate(cum_events = cumsum(n_of_events)) |> 
  ggplot(aes(x = event_date, y = cum_events, colour = event_type)) +
  geom_line() +
  labs(title = "Cumulative number of Events not targeting civilians",
       x = "Event Date",
       y = "Cumulative Events") +
  scale_color_discrete(name = "Event Type") +
  scale_x_continuous(breaks = pretty(data$event_date, n = 6))
number_of_events_per_type_not_targeting_civ_plot



# Number of events facetted by Civilian targeting 

facet_number_of_events_per_type_plot <- data |> 
  #filter(event_type != "Violence against civilians") |>
  group_by(event_type, event_date, civilian_targeting) |>
  summarise(n_of_events = n(), .groups = "drop") |> 
  group_by(event_type, civilian_targeting) |>
  mutate(cum_events = cumsum(n_of_events),
         civilian_targeting = ifelse(civilian_targeting, "Civilians Targeted", "No Civilians Targeted")) |> 
  ggplot(aes(x = event_date, y = cum_events, colour = event_type)) +
  geom_line() +
  labs(title = "Cumulative Number of Events per Event Type",
       x = "Event Date",
       y = "Cumulative Events") +
  scale_color_discrete(name = "Event Type") +
  scale_x_continuous(breaks = pretty(data$event_date, n = 6)) +
  facet_wrap(~ civilian_targeting)

facet_number_of_events_per_type_plot




# 2014

number_of_events_per_type_plot_2014 <- data |>
  filter(as.numeric(time_precision) != 3, year == 2013) |>
  mutate(month = month(event_date, label = TRUE)) |>
  group_by(event_type, event_date, month) |>
  summarise(n_of_events = n(), .groups = "drop") |>
  mutate(cum_events = cumsum(n_of_events)) |>
  ggplot(aes(x = event_date, y = cum_events, colour = event_type)) +
  geom_line() +
  labs(title = "Cumulative Number of Events per Event Type for 2014",
       x = "Event Date",
       y = "Cumulative Events") +
  scale_color_discrete(name = "Event Type") +
  scale_x_continuous(breaks = pretty(data$event_date, n = 6))
number_of_events_per_type_plot_2014




#pauls plot

test_fatalities_per_group_plot <- categorized_data |> 
  filter(actor_category %in% main_actors,
         year >=2014,
         year <= 2015,
         as.numeric(time_precision) == 1) |> 
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
test_fatalities_per_group_plot




# time diff per group

time_diff_per_group <- categorized_data |>
  filter(actor_category %in% main_actors) |>
  group_by(year, actor_category) |>
  mutate(meandiff = mean(time_diff)) |>
  ggplot(aes(x = event_date, y = time_diff)) +
  geom_smooth() +
  labs(title = "Mean Time Difference between the event and the publishing in News") +
  scale_color_discrete(name = "Actor Category") +
  scale_x_continuous(breaks = pretty(categorized_data$event_date, n = 6)) +
  facet_wrap(~ actor_category) +
  theme_bw()
time_diff_per_group



# test not working
test2 <- wide_data_categorized |>
  group_by(source_scale) |>
  summarise(n_of_events = n()) |>
  arrange(desc(n_of_events))
test2

test <- wide_data_categorized |>
  filter(actor_category %in% main_actors,
         source_scale %in% head(test2[1], 20)) |>
  group_by(actor_category, source_scale)|>
  summarize(n_of_news = n()) |>
  ggplot(aes(x = source_scale, y = n_of_news)) +
  geom_dotplot() +
  #facet_wrap(~ actor_category) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
test
