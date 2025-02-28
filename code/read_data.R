## Read CSV

data <- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")

## Each conflict is identified by an ID (event_id_cnty)
## to make data "tidy" each observation needs to be one row, so the data needs to be pivoted wider
## before that one has to create a column to take names from though

widened.data <- data |>
  mutate(civilian_targeting = !is.na(civilian_targeting)) |>
  group_by(event_id_cnty) |>
  mutate(actor = paste0("actor", seq_len(length(event_id_cnty)))) |>
  ungroup() |> 
  pivot_wider(names_from = actor, values_from = actor1)

saveRDS(widened.data, file = "data/intermediate/wide_data.RDS")

## Categorization of Militant Groups

data |>
  mutate(group_association = case_when(str_detect(actor1, "Police") ~ "Police",
                                       str_detect(actor1, "Militia") ~ "Militia",
                                       str_detect(actor1, "Civilians") ~ "Civilians",
                                       str_detect(actor1, "(Islamic State|Boko Haram)") ~ "Islamist Terror",
                                       str_detect(actor1, "Military Forces of Nigeria") ~ "Nigerian Military",
                                       str_detect(actor1, "Rioters") ~ "Rioters",
                                       str_detect(actor1, "Unidentified Armed Group") ~ "Unidentified Armed Group"
                                       )
               ) |> 
  mutate(group_association = case_when(is.na(group_association) ~ "other"))

