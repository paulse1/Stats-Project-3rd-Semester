## Read CSV
# library("tidyverse")
library("lubridate")
library("checkmate")
raw_data <- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")
# data <- data %>%
#   mutate(time = timestamp(timestamp))



data <- raw_data %>%
  mutate(
    civilian_targeting = replace_na(str_detect(civilian_targeting, "Civilian targeting"), FALSE),
    region = gsub('"','',region),
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
  rename(publisch_time = timestamp)%>%
  distinct()


saveRDS(data, "data/intermediate/processed_data.RDS")
write.csv(data, "data/intermediate/processed_data.csv", row.names = FALSE)

