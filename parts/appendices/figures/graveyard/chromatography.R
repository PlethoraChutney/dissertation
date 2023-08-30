library(tidyverse)
library(ggtext)

color_label <- "<span style='color: #2BAD32;'>Green</span> = GFP<br><span style='color: #FA579A;'>Red</span> = Trp"

read_csv("exp029_long-chrom.csv") |>
  mutate(
    Channel = if_else(grepl("280", Channel), "Trp", "GFP")
  ) |>
  filter(
    Sample == "Sizing 8"
  ) |>
  ggplot(aes(Time, Signal, color = Channel)) +
  geom_line(linewidth = 1) +
  theme_minimal() +
  theme(panel.grid.major = element_line(color = "#F0F0F0", linewidth = 0.2), panel.grid.minor = element_blank()) +
  scale_color_manual(
    values = c("#2BAD32", "#FA579A")
  ) +
  labs(
    x = "Retention Time (min)",
    y = "Fluorescence (AFU)"
  ) +
  annotate(
    "richtext",
    x = 6.125,
    y = 2000,
    label = color_label,
    hjust = 1,
    size = 8
  )
