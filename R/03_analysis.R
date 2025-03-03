
get_actor_region <- function(data) {
  data <- data |>
    mutate(
      actor_region = str_extract(actor1, "\\(.*?\\)"),  
      actor_region = gsub("\\(|\\)", "", actor_region), 
      actor_region = str_squish(actor_region),         
      actor_region = if_else(str_detect(actor_region, "\\d"), NA_character_, actor_region),  
      actor1 = gsub("\\(.*?\\)", "", actor1)  
    )
  
  return(data)
}


widened_actor1 <- function(data) {
  data <- data |>
    mutate(civilian_targeting = !is.na(civilian_targeting)) |>
    group_by(event_id_cnty) |>
    mutate(actor = paste0("actor", seq_len(length(event_id_cnty)))) |>
    ungroup() |>
    pivot_wider(names_from = actor, values_from = actor1)
  
  return(data)
}


get_actor_cate <- function(data) {
  
  data <- data |>
    mutate(
      actor1 = gsub("\\(.*?\\)", "", actor1),
      
      actor_category = case_when(
        # State forces: include "Military Forces" / "Police Forces"
        str_detect(actor1, regex("Military Forces|Police Forces", ignore_case = TRUE)) ~ "State forces",
        # Rebel groups: include "Rebel"
        str_detect(actor1, regex("Rebel", ignore_case = TRUE)) ~ "Rebel group",
        # Identity militias: contains "militia" + identity-related keywords
        str_detect(actor1, regex("militia", ignore_case = TRUE)) &
          str_detect(actor1, regex("tribal|communal|ethnic|clan|religious|caste", ignore_case = TRUE)) ~ "Identity militia",
        # Political militias: contains "militia" (but not flagged as identity militias)
        str_detect(actor1, regex("militia", ignore_case = TRUE)) ~ "Political militia",
        # Rioters
        str_detect(actor1, regex("Rioters", ignore_case = TRUE)) ~ "Rioters",
        # Protesters
        str_detect(actor1, regex("Protesters", ignore_case = TRUE)) ~ "Protesters",
        # Civilians
        str_detect(actor1, regex("Civilians", ignore_case = TRUE)) ~ "Civilians",
        # External/Other forces
        str_detect(actor1, regex("External|Other forces", ignore_case = TRUE)) ~ "External/Other forces",
        
      
        # Otherwise, NA
        TRUE ~ actor1
      ),
      actor_category = gsub(":.*","",actor_category)
    )
  
  return(data)
}



longer_source_scale <- function(data) {
  data <- data |>
    
    
    separate(source_scale, into = c("source_scale1", "source_scale2"), sep = "-", fill = "right") |>
    pivot_longer(cols = c("source_scale1","source_scale2"), 
                 names_to = "source_scale_type", 
                 values_to = "source_scale") |>
    drop_na(source_scale) |>
    select(-source_scale_type)
  
  return(data)
}



# str_detect(actor1, regex("Islamic State West Africa Province|Boko Haram", ignore_case = TRUE)) ~ "ISWAP and/or Boko Haram",
# 
# str_detect(actor1, regex("Islamic State West Africa Province", ignore_case = TRUE)) ~ "ISWAP",
# 
# str_detect(actor1, regex("Unidentified Armed Group", ignore_case = TRUE)) ~ "Unidentified",






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

