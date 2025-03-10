library(ggplot2)

# =================================
# 0 data prepare
# =================================


source("code/utils.R")
processed_data <- readRDS("data/intermediate/processed_data.RDS")
widened_data <- widened_actor1(processed_data)
cata_act_data <- get_actor_cate(processed_data)

# =================================
# 1 Single variables
# =================================

# ---------------------------------
# 1_1 event type - sub event type
# ---------------------------------

### use wide data to make event unique


# proportion of event types 
# pie chart

# Assuming processed_data is your data frame
# Assuming widened_data is your data frame
event_type_pi <- widened_data %>%
  group_by(event_type) %>%  # Group by event_type
  summarise(count = sum(fatalities), .groups = "drop") %>%  # Sum the fatalities for each event_type
  mutate(percentage = count / sum(count) * 100)  # Calculate percentage based on total fatalities

# Create a pie chart
event_type_pi_plot <- ggplot(event_type_pi, aes(x = "", y = count, fill = event_type)) +
  geom_bar(stat = "identity", width = 1) +  # Create a bar chart
  coord_polar("y", start = 0) +  # Convert to a pie chart
  theme_void() +  # Remove background and axes
  labs(title = "Fatalities Percentage in Each Event Type", fill = "Event Type") +  # Set legend title
  
  # Add percentage labels, but exclude those < 0.1%
  geom_text(aes(label = ifelse(percentage >= 0.5, paste0(round(percentage, 1), "%"), "")),  # Only show labels for percentages >= 0.1%
            position = position_stack(vjust = 0.5))  # Position labels in the middle of each slice

# Save the plot
ggsave("output/figures/event_type_pie_chart.jpg", plot = event_type_pi_plot, width = 8, height = 6, dpi = 300)

# compare counts of sub event types 
# Stacked Bar Chart of types and sub types

sub_event_typ_bar <- widened_data |>
  group_by(event_type,sub_event_type)|>
  summarise(count=n())

sub_event_typ_bar_plot <- ggplot(sub_event_typ_bar,aes(x=event_type,y = count, fill = sub_event_type))+
  geom_bar(stat = "identity", position = "stack") +  
  labs(title = "Stacked Bar Chart of Event Types and Subtypes",
       x = "Event Type", y = "Count", fill = "Sub Event Type") +
  theme_minimal() +  
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("output/figures/sub_event_typ_bar_plot.png", plot = sub_event_typ_bar_plot, width = 8, height = 6, dpi = 300)



# ---------------------------------
# 1_2 about actor
# ---------------------------------

### use long data to fully count actors

# detect most active actors: top 10 / top 20
# bar charts


top10_groups <- cata_act_data %>%
  group_by(actor1) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  top_n(10, count)

top10_groups_bar <- ggplot(top10_groups, aes(x = reorder(actor1, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +  # Flip to make it horizontal
  labs(title = "Top 10 Most Active Actors",
       x = "Actor",
       y = "Number of Occurrences") +
  theme_minimal()

ggsave("output/figures/top10_groups_bar_plot.png", plot = top10_groups_bar, width = 8, height = 6, dpi = 300)


top20_groups <- cata_act_data %>%
  group_by(actor1) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  top_n(20, count)

top20_groups_bar <- ggplot(top20_groups, aes(x = reorder(actor1, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +  # Flip to make it horizontal
  labs(title = "Top 20 Most Active Actors",
       x = "Actor",
       y = "Number of Occurrences") +
  theme_minimal()

ggsave("output/figures/top20_groups_bar_plot.png", plot = top20_groups_bar, width = 8, height = 6, dpi = 300)




# to be noticed: top 5+ are civilians or official groups
# to get insight of rebellious armed group using filter
# bar charts: top 10, using color to represent if Nigeria






### as 439 different actors are beyond understandable
### categorize actors in 7 groups acc. inter. code (doc from ACLED)
### incomplete, need to be validated






# compare counts of categories 
# as incomplete categorization, do 2 versions of with / without uncategorized 
# bar chart





# =================================
# 2 Time Series Analysis
# =================================

# ---------------------------------
# 2_1 series analysis of event type
# ---------------------------------

### use wide data to make event unique
### ???: the value of 2025 be filtered out as incomplete statistics



# to explore the trend of total number of events
# line chart: year - count of event type (sum)

sort_dated_data <- widened_data %>%
  mutate(year = year(event_date),
         month = month(event_date, label = TRUE)) %>%
  filter(year != 2025)

conflicts_by_year <- sort_dated_data %>%
  group_by(year) %>%
  summarise(count = sum(fatalities))

# Plot 4a: Line Chart of Conflict Events by Year
conflict_fata_yr_lin <- ggplot(conflicts_by_year, aes(x = year, y = count)) +
  geom_line(color = "black") +
  geom_point(color = "black") +
  labs(title = "Number of Fatalities by Year",
       x = "Year", y = "Number of Fatalities")+
  theme_minimal()


ggsave("output/figures/conflict_fata_yr_lin_plot.jpg", plot = conflict_fata_yr_lin, width = 8, height = 6, dpi = 300)

sort_dated_data <- widened_data %>%
  mutate(year = year(event_date),
         month = month(event_date, label = TRUE)) %>%
  filter(year != 2025)

conflicts_by_year <- sort_dated_data %>%
  group_by(year) %>%
  summarise(count = n())

# Plot 4a: Line Chart of Conflict Events by Year
conflict_event_yr_lin <- ggplot(conflicts_by_year, aes(x = year, y = count)) +
  geom_line(color = "black") +
  geom_point(color = "black") +
  labs(title = "Confilict Events by Year",
       x = "Year", y = "Number of Events")+
  theme_minimal()


ggsave("output/figures/conflict_event_yr_lin_plot.jpg", plot = conflict_event_yr_lin, width = 8, height = 6, dpi = 300)





# to explore the trend of each type of event
# line chart: year - count of each event type, grouped by event type
# colored by different event types
conflicts_by_year_type <- sort_dated_data %>%
  group_by(year, event_type) %>%
  summarise(count = n(), .groups = "drop")

# Plot: Multiple lines grouped by event_type
conflict_event_yr_typ_lin <- ggplot(conflicts_by_year_type, aes(x = year, y = count, group = event_type, color = event_type)) +
  geom_line() +
  geom_point() +
  labs(title = "Conflict Events by Year and Event Type",
       x = "Year", y = "Number of Events", color = "Event Type") +
  theme_minimal()

ggsave("output/figures/conflict_event_yr_typ_lin_plot.png", plot = conflict_event_yr_typ_lin, width = 8, height = 6, dpi = 300)





group_yr_data <- sort_dated_data %>%
  mutate(five_year_group = cut(year, breaks = seq(min(year), max(year) + 5, by = 5), right = FALSE))%>%
  mutate(five_year_group = factor(five_year_group, levels = unique(five_year_group)))



monthly_totals <- group_yr_data %>%
  group_by(five_year_group, month) %>%
  summarise(total_events = n(), .groups = "drop")


month_total_confli_stack_line <- ggplot(monthly_totals, aes(x = month, y = total_events, fill = five_year_group, group = five_year_group)) +
  geom_area(position = "stack", alpha = 0.6) + 

  labs(title = "Stacked Line Plot of Monthly Conflict Events (Grouped by 5-Year Periods)",
       x = "Month", 
       y = "Total Number of Events",
       fill = "Five-Year Period") +
  theme_minimal()


ggsave("output/figures/month_total_confli_stack_line_plot.jpg", plot = month_total_confli_stack_line, width = 8, height = 6, dpi = 300)



monthly_totals_fat <- group_yr_data %>%
  group_by(five_year_group, month) %>%
  summarise(total_events = sum(fatalities), .groups = "drop")


month_total_fata_stack_line <- ggplot(monthly_totals_fat, aes(x = month, y = total_events, fill = five_year_group, group = five_year_group)) +
  geom_area(position = "stack", alpha = 0.6) + 
  
  labs(title = "Stacked Line Plot of Monthly Fatalities (Grouped by 5-Year Periods)",
       x = "Month", 
       y = "Total Number of Fatalities",
       fill = "Five-Year Period") +
  theme_minimal()

ggsave("output/figures/month_total_fata_stack_line_plot.jpg", plot = month_total_fata_stack_line, width = 8, height = 6, dpi = 300)




# line chart: month - count of event type (sum)

monthly_totals <- sort_dated_data %>%
  group_by(month) %>%
  summarise(total_events = n())

month_total_confli_lin <- ggplot(monthly_totals, aes(x = month, y = total_events, group = 1)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Monthly Total Conflict Events",
       x = "Month", y = "Total Number of Events") +
  theme_minimal()

ggsave("output/figures/month_total_confli_lin_plot.png", plot = month_total_confli_lin, width = 8, height = 6, dpi = 300)


# to explore the seasonal periodicity of each type of event
# line chart: month - count of each event type, grouped by event type
# colored by different event types

conflicts_by_month <- sort_dated_data %>%
  group_by(event_type, month) %>%
  summarise(count = n())

# Plot 4b: Line Chart of Monthly Conflict Trends (grouped by year)
month_conflict_lin <- ggplot(conflicts_by_month, aes(x = month, y = count, group = factor(event_type), color = factor(event_type))) +
  geom_line() +
  labs(title = "Monthly Conflict Trends by Event Type",
       x = "Month", y = "Number of Events", color = "Event Type")

ggsave("output/figures/month_conflict_lin_plot.png", plot = month_conflict_lin, width = 8, height = 6, dpi = 300)




# ---------------------------------
# 2_2 series analysis of actor
# ---------------------------------

### use long data to fully count actors
### use the categorized actor data




# to explore the trend of number of events caused by top 10
# line chart: year - count of event, grouped by actor
# colored by different actor


# Prepare dataset with event date information
sort_group_data <- cata_act_data %>%
  mutate(year = year(event_date)) %>%
  filter(year != 2025)%>% # Remove future years
  filter(actor1 %in% top10_groups$actor1)

# Filter only top 10 actors
trend_event <- sort_group_data %>%
  group_by(actor1,year) %>%
  summarise(count = n(), .groups = "drop")

# Line chart: Number of events per year, grouped by actor
trend_event_lin <- ggplot(trend_event, aes(x = year, y = count, group = actor1, color = actor1)) +
  geom_line(size = 1) +
  geom_point() +
  labs(title = "Yearly Event Trends for Top 10 Actors",
       x = "Year",
       y = "Number of Events",
       color = "Actor") +
  theme_minimal()


ggsave("output/figures/trend_event_lin_plot.png", plot = trend_event_lin, width = 8, height = 6, dpi = 300)



# to explore the seasonal periodicity of number of events caused by top 10
# line chart: month - count of event, grouped by actor
# colored by different actor


sort_group_data <- cata_act_data %>%
  mutate(year = year(event_date)) %>%
  mutate(month = month(event_date)) %>%
  filter(year != 2025)%>% # Remove future years
  filter(actor1 %in% top10_groups$actor1)

# Filter only top 10 actors
trend_event <- sort_group_data %>%
  group_by(actor1,month) %>%
  summarise(count = n(), .groups = "drop")

# Line chart: Number of events per year, grouped by actor
trend_event_month_lin <- ggplot(trend_event, aes(x = month, y = count, group = actor1, color = actor1)) +
  geom_line(size = 1) +
  geom_point() +
  labs(title = "Yearly Event Trends for Top 10 Actors",
       x = "Year",
       y = "Number of Events",
       color = "Actor") +
  theme_minimal()


ggsave("output/figures/trend_event_month_lin_plot.png", plot = trend_event_month_lin, width = 8, height = 6, dpi = 300)



# to explore the trend of number of events caused by actor category
# line chart: year - count of event, grouped by actor category
# colored by different actor category

# Filter only top 10 actors

# Filter original data to keep only top 10 actors
trend_event_filtered <- cata_act_data %>%
  filter(!is.na(actor_category)) %>%
  filter(year != 2025)%>%
  group_by(year, actor_category) %>%
  summarise(count = n(), .groups = "drop")

# Line chart: Number of events per year, grouped by actor category
act_cat_yr_lin <-ggplot(trend_event_filtered, aes(x = year, y = count, group = actor_category, color = actor_category)) +
  geom_line(size = 1) +
  geom_point() +
  labs(title = "Yearly Event Trends for Top 10 Actor Categories",
       x = "Year",
       y = "Number of Events",
       color = "Actor Category") +
  theme_minimal()

ggsave("output/figures/act_cat_yr_lin_plot.png", plot = act_cat_yr_lin, width = 8, height = 6, dpi = 300)




# to explore the seasonal periodicity of number of events caused by actor category
# line chart: month - count of event, grouped by actor category
# colored by different actor category

trend_event_filtered <- cata_act_data %>%
  filter(!is.na(actor_category)) %>%
  mutate(month = month(event_date)) %>%
  filter(year != 2025)%>%
  group_by(month, actor_category) %>%
  summarise(count = n(), .groups = "drop")

# Line chart: Number of events per year, grouped by actor category
act_cat_mo_lin <-ggplot(trend_event_filtered, aes(x = month, y = count, group = actor_category, color = actor_category)) +
  geom_line(size = 1) +
  geom_point() +
  labs(title = "Yearly Event Trends for Top 10 Actor Categories",
       x = "Year",
       y = "Number of Events",
       color = "Actor Category") +
  theme_minimal()

ggsave("output/figures/act_cat_mo_lin_plot.png", plot = act_cat_mo_lin, width = 8, height = 6, dpi = 300)






# =================================
# 3 Geographical distributions 
# =================================

### get map data for Nigeria
### ??? think of getting terrain data, such as contour lines
### one way could be using Google map by ggmap(), but API key required


# ---------------------------------
# 3_1 Overview of distribution
# ---------------------------------

### use wide data to make event unique




# to explore the distribution of total number of events
# map plot with all event points with transparency (alpha = 0.1)

library(maps)

nigeria_map <- map_data("world", region = "Nigeria")


# conflict events on the Nigeria map
map_conflict <- ggplot(widened_data, aes(longitude,latitude)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.1, size = 2) +
  # facet_wrap(~event_type) +
  theme_minimal() +
  labs(title = "Armed Conflict Events in Nigeria", x = "Longitude", y = "Latitude", color = "Event Type")

ggsave("output/figures/conflict_map_plot.png", plot = map_conflict, width = 8, height = 10, dpi = 300)






# alternatively making a geological heat map (bins)




# ---------------------------------
# 3_2 Distribution of event type
# ---------------------------------

### use wide data to make event unique




# to explore the distribution of each type of event
# faceted map plot charts: with each event type a subplot, grouped by event type
# colored by different event types


conflict_event_map <- ggplot(widened_data, aes(longitude,latitude,color=event_type)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.1, size = 2) +
  facet_wrap(~event_type) +
  theme_minimal() +
  labs(title = "Armed Conflict Events in Nigeria", x = "Longitude", y = "Latitude", color = "Event Type")

ggsave("output/figures/conflict_event_map_plot.png", plot = conflict_event_map, width = 14, height = 10, dpi = 300)





# ---------------------------------
# 3_3 Distribution of actors
# ---------------------------------

### use long data to fully count actors
### use the categorized actor data


top_10_act <- cata_act_data %>%
  filter(actor1 %in% top10_groups$actor1)

# to explore the distribution of each top 10 actor
# faceted map plot charts: with each event type a subplot, grouped by actor
# colored by different actors


conflict_actor_type_map <- ggplot(top_10_act, aes(longitude,latitude,color=actor1)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.1, size = 2) +
  facet_wrap(~event_type) +
  theme_minimal() +
  labs(title = "Armed Conflict Events in Nigeria", x = "Longitude", y = "Latitude", color = "Actor")

ggsave("output/figures/conflict_actor_type_map_plot.png", plot = conflict_actor_type_map, width = 14, height = 10, dpi = 300)



# to explore the distribution of each actor category
# faceted map plot charts: with each event type a subplot, grouped by actor category
# colored by different actor categories






# =================================
# 4 Association Analysis 
# =================================

# ---------------------------------
# 4_1 Casualty Analysis
# ---------------------------------

### use wide data to make event unique



# study on average / median / sum of fatalities per event type
# ??? which key value is the best
# bar chart
fata_event_typ <- widened_data %>%
  group_by(event_type) %>%
  summarise(fata_count = sum(fatalities), .groups = "drop")

# Bar chart for fatalities per event type
fata_event_bar <- ggplot(fata_event_typ, aes(x = event_type, y = fata_count, fill = event_type)) +
  geom_bar(stat = "identity") +
  labs(x = "Event Type", y = "Fatalities Count",
       title = "Fatalities per Event Type",fill = "Event Type") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


ggsave("output/figures/fata_event_bar_plot.png", plot = fata_event_bar, width = 8, height = 6, dpi = 300)


# alternatively study on event type and sub event type
# therefore stacked bar chart




# more alternatively: study on population influenced?





# ---------------------------------
# 4_2 Event types vs actor categories
# ---------------------------------

# Chi-Square Test


# Cramer’s V Coefficient






# ---------------------------------
# 4_3 Time vs Geography
# ---------------------------------




# =================================
# 5 Advanced Analysis 
# =================================



















