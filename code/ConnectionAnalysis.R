#Run this after utils.R

library(igraph)
library(tidygraph)
library(ggraph)


conflicts <- get_actor_cate2(wide_data_categorized) |> 
  filter(!is.na(actor1), !is.na(actor2))


edge_list <- conflicts %>%
  group_by(actor1, actor2) %>%
  summarise(
    count = n(),
    total_fatalities = sum(fatalities, na.rm = TRUE),
    event_types = paste(unique(event_type), collapse = ", "),
    .groups = "drop"
  )

## Big Plot
g <- graph_from_data_frame(d = edge_list, directed = FALSE)

V(g)$degree <- degree(g)

threshold <- 20
g <- delete_vertices(g, which(V(g)$degree < threshold))

p1 <- ggraph(g, layout = "fr") +
  geom_edge_link(aes(width = count, alpha = total_fatalities), color = "dark blue", alpha = 0.1) +
  geom_node_point(aes(size = degree), color = "tomato") +
  geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  scale_edge_width(range = c(0.1, 3)) +
  theme_minimal() +
  ggtitle("Actor Connection Network")




### by category
edge_list2 <- conflicts %>%
  filter(actor_category %in% c(main_actors, "Rioters", "Civilians", "Protesters")) |> 
  filter(actor_category2 %in% c(main_actors, "Rioters", "Civilians", "Protesters")) |>
  filter(actor_category != "Unidentified Armed Group", actor_category2 != "Unidentified Armed Group") |> 
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

#set seed for consistency
set.seed(1)

p2 <- ggraph(g2, layout = "fr") +
  geom_edge_link(aes(width = total_fatalities), color = "black", alpha = 0.08) +
  geom_node_point(size = 8, color = "tomato") +
  geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  scale_edge_width(range = c(0.2, 3), name = "Total Fatalities") +
  labs(title = "Actor Category Network by Fatalities")

ggsave("output/figures/08_network_graph.png",
      p2,
      width = 8,
      height = 6,
      units = "in")
