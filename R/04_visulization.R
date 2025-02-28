
daily_casualties <- readRDS("data/intermediate/daily_casualties.RDS")


p <- ggplot(daily_casualties, aes(x = event_date, y = casualties)) +
  geom_col(width = 100) +
  labs(title = "Daily Casualties Over Time",
       x = "Date",
       y = "Casualties")


ggsave("output/figures/daily_casualties.png", plot = p, width = 10, height = 6, dpi = 300)