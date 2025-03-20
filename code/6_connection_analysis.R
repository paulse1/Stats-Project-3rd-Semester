cat("~ sourcing 6_connection_analysis.R ~")

## a bit of late tidying

conflicts <- get_actor_cate2(wide_data_categorized) |> 
  filter(!is.na(actor1), !is.na(actor2))

saveRDS(conflicts, "data/intermediate/conflict_for_network.RDS")


### Plot by category

## creating edge list

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

##Plotting

g2 <- graph_from_data_frame(d = edge_list2, directed = FALSE)

V(g2)$degree <- degree(g2)

#set seed for consistency
set.seed(1)

p2 <- ggraph(g2, layout = "fr") +
  geom_edge_link(aes(width = total_fatalities), color = "black", alpha = 0.3) +
  geom_node_point(size = 8, color = "tomato") +
  geom_node_text(aes(label = name), size = 6, repel = TRUE) +
  scale_edge_width(range = c(0.2, 3), name = "Total Fatalities") +
  labs(title = "Actor Category Network by Fatalities") +
  theme(
    axis.text.x = element_text(size = 0)
  )

ggsave("output/figures/10_network_graph.png",
      p2,
      width = 14,
      height = 6,
      units = "in")
