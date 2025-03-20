lapply(list.files("code",
                  pattern = "\\.R$",
                  ignore.case = TRUE,
                  full.names = TRUE,
                  recursive = TRUE),
       source
)

cat("~ end of source_all.R ~")

quarto_render("presentation.qmd", output_format = "revealjs")