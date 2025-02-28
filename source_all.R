source("settings.R")

lapply(list.files("R",
                  pattern = "\\.R$",
                  ignore.case = TRUE,
                  full.names = TRUE,
                  recursive = TRUE),
       source
)
