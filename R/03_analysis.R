
source("code/utils.R")

library(dplyr)
library(ggplot2)


processed_data <- readRDS("data/intermediate/processed_data.RDS")



# Assuming processed_data is your data frame
event_type_pi <- processed_data |>
  group_by(event_type) |>  # Group by event_type
  summarise(count = n()) |>  # Count the number of occurrences for each event_type
  mutate(percentage = count / sum(count) * 100)  # Calculate percentage

# Create a pie chart
event_type_pi_plot <- ggplot(event_type_pi, aes(x = "", y = count, fill = event_type)) +
  geom_bar(stat = "identity", width = 1) +  # Create a stacked bar chart
  coord_polar("y", start = 0) +  # Convert to a pie chart
  theme_void() +  # Remove background and axes
  labs(fill = "Event Type") +  # Set legend title
  geom_text(aes(label = paste0(round(percentage, 1), "%")),  # Add percentage labels
            position = position_stack(vjust = 0.5))
ggsave("output/figures/event_type_pie_chart.png", plot = event_type_pi_plot, width = 8, height = 6, dpi = 300)



# Summarize the data: count sub_event_type within each event_type
event_subtype_counts <- processed_data |>
  group_by(event_type, sub_event_type) |>  
  summarise(count = n(), .groups = 'drop') |>  
  group_by(event_type) |> 
  mutate(percentage = count / sum(count) * 100,
         sub_event_type = substr(sub_event_type,1,6))
  

# Create the pie chart
event_subtype_pie_chart <- ggplot(event_subtype_counts, aes(x = "", y = percentage, fill = sub_event_type)) +
  geom_bar(stat = "identity", width = 1) +  # Create a stacked bar chart using percentages
  coord_polar("y", start = 0) +  # Convert the bar chart to a pie chart
  facet_wrap(~ event_type) +  # Create separate pie charts for each event_type
  theme_void() +  # Remove background, gridlines, and axes for a clean look
  labs(fill = "Sub Event Type") +  # Set the legend title (though the legend will be hidden)
  geom_text(
    aes(label = sub_event_type),  # Add labels with sub_event_type and percentage
    position = position_stack(vjust = 0.5),  # Position labels at the center of each pie slice
    size = 4, color = "white"  # Set label size and color for better readability
  ) +
  scale_fill_discrete(
    labels = function(x) sapply(strsplit(x, " "), `[`, 1)  # 只显示第一个单词
  ) +
  theme(legend.position = "none")  # Hide the default legend

# Display the plot
ggsave("output/figures/event_subtype_pie_chart.jpg", plot = event_subtype_pie_chart, width = 8, height = 6, dpi = 300)

