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

##setting ggplot theme
theme_set(theme_bw())
