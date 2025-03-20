cat("~ sourcing 2_data_tidy.R ~")

## Read CSV

raw_data <- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")

## Additional Data

##Petroleum Fields: https://www.nuprc.gov.ng/oil-production-status-report/

pet_fields <- data.frame(name = c("Bonny", "Brass", "Qua Iboe", "Forcados", "Escravos", "Odudu"),
                         Latitude = c(4.4355, 4.3020, 4.5429, 5.1833, 5.5166, 4.0000),
                         Longitude = c(7.1594, 6.2482, 8.0159, 5.1666, 5.0000, 7.7500)
)

saveRDS(pet_fields, "data/intermediate/pet_fields.RDS")

##Cities: https://simplemaps.com/data/ng-cities

cities <- read_csv("data/raw/ng.csv")
top10_cities <- cities |>
  arrange(desc(population)) |> 
  head(10)

saveRDS(top10_cities, "data/intermediate/top10_cities.RDS")

## Data tidying pipeline

data <- raw_data %>%
  mutate(
    civilian_targeting = replace_na(str_detect(civilian_targeting, "Civilian targeting"), FALSE),
    region = gsub('"','',region),
    location = gsub('["\']', '', location),
    timestamp = as.POSIXct(timestamp, origin = "1970-01-01", tz = "Africa/Lagos"),
    event_date = parse_date_time(event_date, orders = c("d B Y", "m/d/Y")), 
    time_diff = round(timestamp - event_date, 0), 
    time_precision = as.factor(time_precision),
    geo_precision = as.factor(geo_precision),  
    actor1 = gsub('"', '', actor1),
    population_best = gsub(',','',population_best),
    population_best = na_if(population_best, "NA"),
    sub_event_type = gsub('"','',sub_event_type),
    source_scale = gsub('"', '', source_scale)
  )%>%
  drop_na(timestamp)%>%
  rename(publish_time = timestamp)%>%
  distinct()%>%
  mutate(
    actor1 = gsub("\\(.*?\\)", "", actor1),
    actor1 = case_when(
      str_detect(actor1, regex("Islamic State West Africa Province (ISWAP) and/or Boko Haram",
                               ignore_case = TRUE)) ~ "ISWAP and/or Boko Haram",
      str_detect(actor1, regex("Boko Haram",
                               ignore_case = TRUE)) ~ "Boko Haram",
      str_detect(actor1, regex("Islamic State West Africa Province",
                               ignore_case = TRUE)) ~ "ISWAP",
      # Otherwise, NA
      TRUE ~ actor1
    )) |>
  mutate(actor1 = gsub(" $", "", actor1))
  
saveRDS(data, "data/intermediate/processed_data.RDS")

