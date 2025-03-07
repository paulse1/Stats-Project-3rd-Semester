library(gapminder)
library(maps)
library(gifski)
library(ggplot2)
library(gganimate)
library(magick)

# =================================
# 0 data prepare
# =================================


source("code/utils.R")
processed_data <- readRDS("data/intermediate/processed_data.RDS")
widened_data <- widened_actor1(processed_data)
cata_act_data <- get_actor_cate(processed_data)




nigeria_map <- map_data("world", region = "Nigeria")

# 
# # conflict events on the Nigeria map
# ggplot() +
#   geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
#                fill = "gray90", color = "black") +
#   geom_point(data = data, aes(x = longitude, y = latitude, color = event_type),
#              alpha = 0.6, size = 2) +
#   facet_wrap(~event_type) +
#   theme_minimal() +
#   labs(title = "Armed Conflict Events in Nigeria", x = "Longitude", y = "Latitude", color = "Event Type")+
#   transition_time(year) +
#   ease_aes('linear')
# 
# 
# month_day = month(processed_data$event_date)
# 
# pmonth<-ggplot(processed_data, aes(longitude,latitude,colour = event_type)) +
#   geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
#                fill = "gray90", color = "black") +
#   geom_point(alpha = 0.7, show.legend = FALSE) +
#   
#   # scale_size(range = c(2, 12)) +
#   # scale_x_log10() +
#   facet_wrap(~event_type) +
#   # Here comes the gganimate specific bits
#   labs(title = "Armed Conflict Events in Nigeria month: {frame_time}", x = "Longitude", y = "Latitude", color = "Event Type")+
#   transition_time(as.integer(month_day)) +
#   ease_aes('linear')
# animate(pmonth,duration = 40)
# anim_save("output/figures/event_type_month.gif",pmonth)
# 
# pyear<-ggplot(processed_data, aes(longitude,latitude,colour = event_type)) +
#   geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
#                fill = "gray90", color = "black") +
#   geom_point(alpha = 0.7, show.legend = FALSE) +
#   
#   # scale_size(range = c(2, 12)) +
#   # scale_x_log10() +
#   facet_wrap(~event_type) +
#   # Here comes the gganimate specific bits
#   labs(title = "Armed Conflict Events in Nigeria year: {frame_time}", x = "Longitude", y = "Latitude", color = "Event Type")+
#   transition_time(as.integer(year)) +
#   ease_aes('linear')
# animate(pyear,duration = 40)
# anim_save("output/figures/event_type_year.gif", pyear)
# 


top10_groups <- cata_act_data %>%
  group_by(actor1) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  top_n(10, count)


top_10_act <- cata_act_data %>%
  filter(actor1 %in% top10_groups$actor1)

# to explore the distribution of each top 10 actor
# faceted map plot charts: with each event type a subplot, grouped by actor
# colored by different actors


armed_conf_evt_act_year <- ggplot(top_10_act, aes(longitude, latitude, color = actor1)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.5, size = 2) + 
  facet_wrap(~event_type) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1") + 
  theme(
    legend.background = element_rect(fill = "white", color = NA), 
    legend.key = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = "Armed Conflict Events in Nigeria year: {frame_time}",
    x = "Longitude", y = "Latitude", color = "Actor"
  ) +
  transition_time(as.integer(year)) +
  ease_aes('linear')
# 动画渲染（增加宽度、高度和分辨率）

armed_conf_evt_act_year <- animate(
  armed_conf_evt_act_year, 
  duration = 10, 
  width = 1200,  # 增加宽度
  height = 800,  # 增加高度
  res = 150       # 提高分辨率
)
# 
# animate(armed_conf_evt_act_year,duration = 30)
anim_save("output/gif/armed_conf_evt_act_year.gif", armed_conf_evt_act_year)


armed_conf_evt_act_year_plot <- ggplot(top_10_act, aes(longitude, latitude, color = actor1)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.5, size = 2) + 
  facet_wrap(~event_type) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1") + 
  theme(
    legend.background = element_rect(fill = "white", color = NA), 
    legend.key = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = "Armed Conflict Events in Nigeria",
    x = "Longitude", y = "Latitude", color = "Actor"
  ) 
  
# 动画渲染（增加宽度、高度和分辨率）

# 
# animate(armed_conf_evt_act_year,duration = 30)
ggsave("output/figures/armed_conf_evt_act_year_plt.png", armed_conf_evt_act_year_plot, width = 12, height = 8, dpi = 150)


armed_conf_cumulative <- ggplot(top_10_act, aes(longitude, latitude, color = actor1)) +
  geom_polygon(data = nigeria_map, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "black") +
  geom_point(alpha = 0.2, size = 2) +
  facet_wrap(~event_type) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  theme(
    legend.background = element_rect(fill = "white", color = NA),
    legend.key = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = "Armed Conflict Events in Nigeria",
    x = "Longitude", y = "Latitude", color = "Actor"
  ) +
  transition_time(as.integer(year)) +
  ease_aes('linear') +
  shadow_mark(alpha = 0.2)  # 让前面的数据残留，形成叠加效果

# 选取最后一帧（完整叠加后的图）
final_frame <- animate(armed_conf_cumulative, duration = 30, fps = 10, width = 1200, height = 800, res = 150, nframes = 300)

# 提取最后一帧并保存为 PNG
image_write(image_read(final_frame)[300], path = "output/figures/armed_conf_cumulative.png", format = "png")
# ggsave("output/figures/armed_conf_cumulative.png", final_frame, width = 12, height = 8, dpi = 150)

