
data <- read_csv("data/raw/1997-01-01-2025-01-01-Nigeria.csv")

saveRDS(data, file = "data/intermediate/raw_data.RDS")