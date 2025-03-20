cat("~ sourcing 0_settings.R ~")

##Set locale
Sys.setlocale("LC_TIME", "en_US.UTF-8")

##accessing libraries

library(tidyverse)
library(lubridate)
library(checkmate)
library(terra)         # raster data 
library(sf)            # vector spatial data handling
library(elevatr)       # elevation data
library(stars)         # converting raster data and generating contours
library(rnaturalearth) # natural earth boundary data
library(ggrepel)       # nudging labels
library(RColorBrewer)  # brewer palettes
library(gganimate)
library(igraph)
library(tidygraph)
library(ggraph)
library(quarto)

##setting ggplot theme
custom_theme <- theme_bw() +
  theme(
    legend.text = element_text(size = 14),  
    legend.title = element_text(size = 16),
    axis.title = element_text(size = 16),
    title = element_text(size = 18),
    axis.text.x = element_text(size = 12)
  )
  
theme_set(custom_theme)

#creating brewer palettes, set2 is colorblindsafe, as well as dark2

palette_actors <- brewer.pal(n = 5, name = "Set2")

palette_events <- brewer.pal(n = 6, name = "Dark2")
