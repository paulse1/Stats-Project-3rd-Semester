# Load required libraries
library(tidyverse)    
library(lubridate)   
library(reshape2) 
library(maps)
library(reshape2)

# Read in the processed data from the RDS file
data <- readRDS("data/intermediate/processed_data.RDS")

# -----------------------------
# 1. Descriptive Statistics
# -----------------------------

# (a) Conflict Type Distribution: Calculate counts and proportions per event type
conflict_type_dist <- data %>%
  group_by(event_type) %>%
  summarise(count = n()) %>%
  mutate(proportion = count / sum(count))

# Plot 1: Pie Chart for Conflict Type Distribution
ggplot(conflict_type_dist, aes(x = "", y = proportion, fill = event_type)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "Conflict Type Distribution (Proportions)",
       y = "Proportion", fill = "Event Type") +
  theme_void()

# -----------------------------
# 2. Major Conflict Groups
# -----------------------------


data <- data %>%
  mutate(actor = gsub("\\s*\\([^\\)]+\\)", "", actor1))

data <- data |>
  mutate(
    actor_category = case_when(
      # State forces: include "Military Forces" / "Police Forces"
      str_detect(actor1, regex("Military Forces|Police Forces", ignore_case = TRUE)) ~ "State forces",
      # Rebel groups: include "Rebel"
      str_detect(actor, regex("Rebel", ignore_case = TRUE)) ~ "Rebel group",
      # Identity militias: contains "militia" + identity-related keywords
      str_detect(actor, regex("militia", ignore_case = TRUE)) &
        str_detect(actor, regex("tribal|communal|ethnic|clan|religious|caste", ignore_case = TRUE)) ~ "Identity militia",
      # Political militias: contains "militia" (but not flagged as identity militias)
      str_detect(actor, regex("militia", ignore_case = TRUE)) ~ "Political militia",
      # Rioters
      str_detect(actor, regex("Rioters", ignore_case = TRUE)) ~ "Rioters",
      # Protesters
      str_detect(actor, regex("Protesters", ignore_case = TRUE)) ~ "Protesters",
      # Civilians
      str_detect(actor, regex("Civilians", ignore_case = TRUE)) ~ "Civilians",
      # External/Other forces
      str_detect(actor, regex("External|Other forces", ignore_case = TRUE)) ~ "External/Other forces",
      
      # Otherwise, NA
      TRUE ~ "Uncategorized"
    ),
    actor_category = gsub(":.*","",actor_category)
  )

# Identify the top 20 most active groups
top10_groups <- data %>%
  group_by(actor_category) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  filter(actor_category != "Uncategorized")

# Plot 2: Bar Chart for Top 20 Conflict Groups
ggplot(top10_groups, aes(x = reorder(actor_category, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Active Conflict Categories",
       x = "Category", y = "Number of Conflict Events")


top10_cat <- data %>%
  group_by(actor_category) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  filter(actor_category != "Uncategorized")

ggplot(top10_cat, aes(x = reorder(actor_category, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Active Actor Categories",
       x = "Category", y = "Number of Conflict Events")

# -----------------------------
# 3. Casualty Analysis
# -----------------------------

# Compute average fatalities per event type
casualty_analysis <- data %>%
  group_by(event_type) %>%
  summarise(avg_fatalities = mean(fatalities, na.rm = TRUE))

# Plot 3: Bar Chart for Average Fatalities by Event Type
ggplot(casualty_analysis, aes(x = reorder(event_type, avg_fatalities), y = avg_fatalities)) +
  geom_bar(stat = "identity", fill = "firebrick") +
  coord_flip() +
  labs(title = "Average Fatalities by Event Type",
       x = "Event Type", y = "Average Fatalities")

# -----------------------------
# 4. Time Trend Analysis
# -----------------------------

# Extract year and month from event_date for time trend analysis
data <- data %>%
  mutate(year = year(event_date),
         month = month(event_date, label = TRUE)) %>%
filter(year != 2025)
# (a) Overall conflict events per year
conflicts_by_year <- data %>%
  group_by(year) %>%
  summarise(count = n())

# Plot 4a: Line Chart of Conflict Events by Year
ggplot(conflicts_by_year, aes(x = year, y = count)) +
  geom_line(color = "darkgreen") +
  geom_point(color = "darkgreen") +
  labs(title = "Conflict Events by Year",
       x = "Year", y = "Number of Events")

# Summarize conflict events per year by event_type
conflicts_by_year_type <- data %>%
  group_by(year, event_type) %>%
  summarise(count = n(), .groups = "drop")

# Plot: Multiple lines grouped by event_type
ggplot(conflicts_by_year_type, aes(x = year, y = count, group = event_type, color = event_type)) +
  geom_line() +
  geom_point() +
  labs(title = "Conflict Events by Year and Event Type",
       x = "Year", y = "Number of Events", color = "Event Type") +
  theme_minimal()

# (b) Conflict events per month for each year (if needed)
conflicts_by_month <- data %>%
  group_by(event_type, month) %>%
  summarise(count = n())

# Plot 4b: Line Chart of Monthly Conflict Trends (grouped by year)
ggplot(conflicts_by_month, aes(x = month, y = count, group = factor(event_type), color = factor(event_type))) +
  geom_line() +
  labs(title = "Monthly Conflict Trends by Event Type",
       x = "Month", y = "Number of Events", color = "Event Type")


monthly_totals <- data %>%
  group_by(month) %>%
  summarise(total_events = n())

ggplot(monthly_totals, aes(x = month, y = total_events, group = 1)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Monthly Total Conflict Events",
       x = "Month", y = "Total Number of Events") +
  theme_minimal()


# -----------------------------
# 5. Conflict Type Distribution by Group
# -----------------------------

# Focus on top 10 groups for group-specific preferences
data_top10 <- data %>%
  filter(actor %in% top10_groups$actor)

# Summarize event type counts per group
group_event <- data_top10 %>%
  group_by(actor, event_type) %>%
  summarise(count = n())

# Plot 5: Stacked Bar Chart of Event Types for Top 10 Groups
ggplot(group_event, aes(x = reorder(actor, -count), y = count, fill = event_type)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Event Type Distribution for Top 10 Groups",
       x = "Group", y = "Event Count", fill = "Event Type")

# -----------------------------
# 6. Geographical Heat Map
# -----------------------------

# Ensure your data includes 'latitude' and 'longitude' columns.
# Plot 6: Basic Heat Map using binning (adjust bins as needed)
ggplot(data, aes(x = longitude, y = latitude)) +
  geom_bin2d(bins = 50) +
  scale_fill_gradient(low = "yellow", high = "red") +
  labs(title = "Geographical Heat Map of Conflict Events",
       x = "Longitude", y = "Latitude")+
  theme_minimal()

# Alternatively, for a more advanced map using ggmap (requires API key for Google Maps):
# check geological features relation 
# register_google(key = "YOUR_API_KEY")
# map_base <- get_map(location = c(lon = mean(data$longitude), lat = mean(data$latitude)),
#                     zoom = 6, maptype = "terrain")
# ggmap(map_base) +
#   geom_point(data = data, aes(x = longitude, y = latitude), alpha = 0.5, color = "red") +
#   labs(title = "Geographical Distribution of Conflict Events")
# Plot the base map of Nigeria
# Get map data for Nigeria
nigeria_map <- map_data("world", region = "Nigeria")

# Create the map plot
ggplot() +
  # Draw Nigeria polygon
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  # Add conflict event points
  geom_point(data = data, aes(x = longitude, y = latitude),
             alpha = 0.1, color = "red", size = 2) +
  # Use fixed coordinates for correct aspect ratio
  coord_fixed(1.3) +
  labs(title = "Geographical Distribution of Conflict Events",
       x = "Longitude", y = "Latitude")
