## Plot casualties over time
## change width for different insights
## default width shows ,ost deaths in a day
## wider width might show multi day/week conflicts

widened.data |> 
  group_by(event_date) |> 
  summarise(casualties = sum(fatalities)) |> 
  ungroup() |> 
  ggplot(aes(x = event_date, y = casualties)) +
  geom_col(width = 100)

