## Read CSV

data<- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")
data1<- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")

## Each conflict is identified by an ID (event_id_cnty)
## to make data "tidy" each observation needs to be one row, so the data needs to be pivoted wider
## before that one has to create a column to take names from though

clean.data <- data |>
  mutate(across(everything(), ~ gsub('["\']', "", .))) |>
  mutate(population_best = str_extract(population_best, "[0-9]+,*",)) |>
  mutate(across(everything(), ~ gsub(',{2,}', "", .))) |>
  group_by(event_id_cnty) |>
  mutate(fatalities = ifelse(is.na(fatalities), first(na.omit(fatalities)), fatalities)) |>
  mutate(timestamp = ifelse(is.na(timestamp), first(na.omit(timestamp)), timestamp)) |>
  mutate(notes = notes[which.max(nchar(notes))]) 
  
widened.data <- clean.data |>
  mutate(civilian_targeting = ifelse(replace_na(civilian_targeting, "") == "Civilian targeting", TRUE, FALSE)) |>
  group_by(event_id_cnty) |>
  mutate(actor = paste0("actor", seq_len(length(event_id_cnty)))) |>
  ungroup() |> 
  pivot_wider(names_from = actor, values_from = actor1)

saveRDS(widened.data, file = "data/intermediate/wide_data.RDS")

duplicates <- widened.data |>
             group_by(event_id_cnty) |>
             filter(n() > 1)
