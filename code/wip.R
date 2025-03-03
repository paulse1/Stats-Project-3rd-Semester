library(tidyverse)
library(lubridate)
library(maps)
library(ggplot2)
library(gganimate)
library(gifski)
# Data Acquisition
data <- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")




# Data Cleaning
data <- data %>%
  mutate(event_date = as.Date(event_date, format = "%Y-%m-%d"),
         year = year(event_date))

# Standardize text entries for the actor
data$actor <- trimws(data$actor1)

# Create a boolean variable for violence against civilians.
data <- data %>%
  mutate(violence_against_civilians = if_else(str_detect(event_type, regex("civilian", ignore_case = TRUE)), TRUE, FALSE))

# Categorize conflict groups into broader
data <- data %>%
  mutate(group_category = case_when(
    str_detect(actor, regex("Police", ignore_case = TRUE)) ~ "Police",
    str_detect(actor, regex("Military", ignore_case = TRUE)) ~ "Military",
    str_detect(actor, regex("Rebel|Militia|Insurgent", ignore_case = TRUE)) ~ "Rebel/Militia",
    TRUE ~ "Other"
  ))
summary(data)




# Analysis 
table(data$event_type)
table(data$actor)
table(data$group_category)


# distribution of event type
ggplot(data, aes(x = event_type)) +
  geom_bar(fill = "steelblue") +
  theme_minimal() +
  labs(title = "Distribution of Event Types", x = "Event Type", y = "Count")

# distribution of group categories
ggplot(data, aes(x = group_category)) +
  geom_bar(fill = "coral") +
  theme_minimal() +
  labs(title = "Distribution of Group Categories", x = "Group Category", y = "Count")

# contingency table:  group category vs. event type
cross_tab <- table(data$group_category, data$event_type)
print(cross_tab)



# association between group categories and event types
chi_test <- chisq.test(cross_tab)
print(chi_test)


# event counts by year and event type
temporal_data <- data %>%
  group_by(year, event_type) %>%
  summarise(count = n(), .groups = "drop")

# trends for each event type
ggplot(temporal_data, aes(x = year, y = count, color = event_type)) +
  geom_line(size = 1) +
  geom_point() +
  theme_minimal() +
  labs(title = "Temporal Trends of Event Types", x = "Year", y = "Count", color = "Event Type")


# with maps
# get map
nigeria_map <- map_data("world", region = "Nigeria")


# conflict events on the Nigeria map
ggplot() +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(data = data, aes(x = longitude, y = latitude, color = event_type),
             alpha = 0.6, size = 2) +
  theme_minimal() +
  labs(title = "Armed Conflict Events in Nigeria", x = "Longitude", y = "Latitude", color = "Event Type")


# Faceted map: one map per event type
ggplot() +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(data = data, aes(x = longitude, y = latitude),
             alpha = 0.6, size = 1.5, color = "red") +
  facet_wrap(~ event_type) +
  theme_minimal() +
  labs(title = "Faceted Map of Armed Conflict Events by Type", x = "Longitude", y = "Latitude")



# Filter for events that involve violence against civilians
civilians_data <- data %>% filter(violence_against_civilians == TRUE)

# count of violence against civilians by group
ggplot(civilians_data, aes(x = group_category)) +
  geom_bar(fill = "darkgreen") +
  theme_minimal() +
  labs(title = "Violence Against Civilians by Group Category", x = "Group Category", y = "Count")

animated_trends <- ggplot(temporal_data, aes(x = year, y = count, color = event_type)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Temporal Trends of Event Types (Year: {frame_time})",
       x = "Year", y = "Count", color = "Event Type") +
  transition_time(year) +  # 逐年变化
  ease_aes('linear')  # 线性过渡

# 渲染动画并保存
animate(animated_trends, renderer = gifski_renderer("output/figures/event_trends.gif"))

