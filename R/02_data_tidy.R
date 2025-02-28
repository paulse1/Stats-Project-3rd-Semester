
data <- readRDS("data/intermediate/raw_data.RDS")


widened.data <- data |>
  group_by(event_id_cnty) |>
  mutate(actor = paste0("actor", seq_len(length(event_id_cnty)))) |>
  ungroup() |> 
  pivot_wider(names_from = actor, values_from = actor1)

saveRDS(widened.data, file = "data/intermediate/wide_data.RDS")