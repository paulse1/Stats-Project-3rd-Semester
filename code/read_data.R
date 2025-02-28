## Read CSV

data <- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")

## Each conflict is identified by an ID (event_id_cnty)
## to make data "tidy" each observation needs to be one row, so the data needs to be pivoted wider
## before that one has to create a column to take names from though

widened.data <- data |>
  mutate(civilian_targeting = ifelse(replace_na(civilian_targeting, "") == "Civilian targeting", TRUE, FALSE)) |>
  group_by(event_id_cnty) |>
  mutate(actor = paste0("actor", seq_len(length(event_id_cnty)))) |>
  ungroup() |> 
  pivot_wider(names_from = actor, values_from = actor1)

saveRDS(widened.data, file = "data/intermediate/wide_data.RDS")
