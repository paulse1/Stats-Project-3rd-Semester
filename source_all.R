lapply(list.files("code",
                  pattern = "\\.R$",
                  ignore.case = TRUE,
                  full.names = TRUE,
                  recursive = TRUE),
       source
)

quarto_render("presentation.qmd", output_format = "revealjs")
quarto_render("summary.qmd", output_format = "pdf")

cat("~ end of source_all.R ~")