# We did not know if people were comfortable installing packages
# without checking which ones they were, so it is excluded from the source_all.R
# Source this file to install required packages

# Package names
packages <- c("tidyverse", "lubridate", "checkmate", "terra", "sf", "elevatr", "stars", "rnaturalearth",
              "ggrepel", "RColorBrewer", "gganimate", "igraph", "tidygraph", "ggraph", "quarto")

# Install packages not yet installed
installed_packages_boolean <- packages %in% rownames(installed.packages())
if (any(installed_packages_boolean == FALSE)) {
  install.packages(packages[!installed_packages_boolean])
}
