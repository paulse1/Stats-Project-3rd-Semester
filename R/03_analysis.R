
widened.data <- readRDS("data/intermediate/wide_data.RDS")

daily_casualties <- widened.data |> 
  group_by(event_date) |> 
  summarise(casualties = sum(fatalities)) |> 
  ungroup()

saveRDS(daily_casualties, file = "data/intermediate/daily_casualties.RDS")
