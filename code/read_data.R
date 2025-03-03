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

##supposed to be a function with the same use as parse_date, but does not work

as_date_function <- function(x) {
  assertCharacter(x)
  months <- c(January = 1, February = 2, March = 3, April = 4, May = 5,
              June = 6, July = 7, August = 8, September = 9,
              October = 10, November = 11, December = 12)
  marker <- str_detect(x, paste0("(", paste(names(months), collapse = "|"), ")"))
  x[marker] <- as_date(x, format = "%e %B %Y")
  x[!marker] <- as_date(x, format = "%m/%d/%Y")
  x
}

## Categorization of Militant Groups, changing longitude and latitude var name,
## using as_date_function to transform dates

categorized_data <- widened.data |>
  mutate(group_association = case_when(str_detect(actor1, "Police") ~ "Police",
                                       str_detect(actor1, "Militia") ~ "Militia",
                                       str_detect(actor1, "Civilians") ~ "Civilians",
                                       str_detect(actor1, "(Islamic State|Boko Haram)") ~ "Islamist",
                                       str_detect(actor1, "Military Forces of Nigeria") ~ "Military",
                                       str_detect(actor1, "Rioters") ~ "Rioters",
                                       str_detect(actor1, "Unidentified Armed Group") ~ "Unidentified"
                                       )
               ) |> 
  mutate(group_association = ifelse(is.na(group_association), "Other", group_association)) |> 
  rename(long = longitude, lat = latitude) |> 
  mutate(event_date = as_date_function(event_date))


