library(tidyverse)
library(lubridate)
library(igraph)
library(tidygraph)
library(ggraph)

source("code/utils.R")
processed_data <- readRDS("data/intermediate/processed_data.RDS")


conflicts <- widened_actor1(processed_data)%>%
  filter(!is.na(actor1) & !is.na(actor2))
cat_data <- get_actor_cate(conflicts)
cat_data <- get_actor_cate2(cat_data)


edge_list <- conflicts %>%
  group_by(actor1, actor2) %>%
  summarise(
    count = n(),
    total_fatalities = sum(fatalities, na.rm = TRUE),
    event_types = paste(unique(event_type), collapse = ", "),
    .groups = "drop"
  )

g <- graph_from_data_frame(d = edge_list, directed = FALSE)

V(g)$degree <- degree(g)

threshold <- 20
g <- delete.vertices(g, which(V(g)$degree < threshold))

p1 <- ggraph(g, layout = "fr") +
  geom_edge_link(aes(width = count, alpha = total_fatalities), color = "dark blue", alpha = 0.1) +
  geom_node_point(aes(size = degree), color = "tomato") +
  geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  scale_edge_width(range = c(0.1, 3)) +
  theme_minimal() +
  ggtitle("Actor Connection Network")

print(p1)



### by category
edge_list2 <- cat_data %>%
  group_by(actor_category, actor_category2) %>%
  summarise(
    count = n(),
    total_fatalities = sum(fatalities, na.rm = TRUE),
    event_types = paste(unique(event_type), collapse = ", "),
    .groups = "drop"
  )

g2 <- graph_from_data_frame(d = edge_list2, directed = FALSE)

V(g2)$degree <- degree(g2)

# threshold <- 20
# g2 <- delete.vertices(g2, which(V(g2)$degree < threshold))

p2 <- ggraph(g2, layout = "fr") +
  geom_edge_link(aes(width = count, alpha = total_fatalities), color = "black", alpha = 0.08) +
  geom_node_point(aes(size = degree), color = "tomato") +
  geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  scale_edge_width(range = c(0.2, 2)) +
  theme_minimal() +
  ggtitle("Actor Category Connection Network")

print(p2)




