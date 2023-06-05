library(tidyverse)

pd <- read_csv('pko-deg.csv')
mt <- read_csv('mouse-tryp.csv')

data <- bind_rows(pd, mt) |> 
  filter(Chain %in% c('A', 'B', 'C')) |> 
  mutate(
    Model = str_replace(Model, '/Users/posert/model-building/aligned-models/', ''),
    # we are going to want one residue from each half, where possible
    tm = if_else(ResNum < 156, 'TM1', 'TM2')
  ) |> 
  filter(ResNum < 120 | ResNum > 450) |> 
  filter(!(ResNum > 544 & Model == 'human_pko-deg' & Chain == 'A'))

palm_z <- data |> 
  filter(Model == 'human_pko-deg' & Chain == 'A' & ResNum == 115) |> 
  pull(CA_Z)

min_z <- 98

stepsize <- (palm_z - min_z) / 3

slices <- tibble()

for (slice in seq(min_z, palm_z, stepsize)) {
  slice <- round(slice)
  slices <- data |> 
    group_by(Model, Chain, tm) |> 
    mutate(dist = abs(CA_Z - slice)) |> 
    filter(dist == min(dist)) |> 
    filter(abs(dist) < stepsize) |>
    mutate(slice = slice) |> 
    bind_rows(slices)
}

lims <- c(135, 170)

negative <- function(x) {
  paste0('Residue closest to ', -1 * as.numeric(x), ' Z coordinate')
}

slices <- slices |> 
  mutate(
    slice = -slice,
    Model = if_else(Model == 'human_pko-deg', 'CKO/DEG', 'Mouse Trypsin'),
  )

lines <- slices |> 
  mutate(Model = if_else(Model == 'CKO/DEG', 'h', 'm')) |> 
  select(tm, CA_X, CA_Y, Chain, Model, slice) |> 
  pivot_wider(
    values_from = c('CA_X', 'CA_Y'),
    names_from = 'Model',
    names_glue = '{Model}.{.value}'
  )

tm_triangles <- slices |> 
  group_by(slice, Model) |> 
  filter(
    tm == 'TM2'
  ) |> 
  count() |> 
  right_join(slices) |> 
  filter(n == 3, tm == 'TM2')
  

slices |> 
  ggplot(aes(CA_X, CA_Y, fill = Chain, shape = tm, color = Model)) +
  theme_minimal() +
  geom_polygon(
    aes(group = interaction(tm, Model)),
    data = tm_triangles,
    fill = NA,
    linetype = 'dotted'
  ) +
  geom_point(size = 6, stroke = 1) +
  geom_segment(
    data = lines,
    mapping = aes(
      x = m.CA_X,
      y = m.CA_Y,
      xend = h.CA_X,
      yend = h.CA_Y,
      group = interaction(tm, Chain)
    ),
    inherit.aes = FALSE,
    color = 'black',
    linewidth = 1,
    arrow = arrow(length = unit(.1, 'inches'), type = 'closed')
  ) +
  facet_wrap(
    vars(slice),
    ncol = 1,
    labeller = labeller(slice = negative)
  ) +
  scale_shape_manual(values = c(21, 22)) +
  scale_fill_manual(values = c('blue', 'red', 'magenta')) +
  scale_color_manual(values = c('#CCCCCC', 'black')) +
  coord_fixed(xlim = lims, ylim = lims) +
  labs(
    x = expression(paste('C', alpha, ' X coordinate')),
    y = expression(paste('C', alpha, ' Y coordinate'))
  ) +
  scale_y_continuous(position = 'right') +
  theme(
    # legend.position = 'none',
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(color = '#222222'),
    strip.background = element_rect(fill = '#EEEEEE', color = NA)
  )
ggsave('model-slices_tm2-triangle.png', width = 4, height = 12, bg = 'white')
ggsave('model-slices_tm2-triangle.pdf', width = 4, height = 12)

# tm_connectors <- slices |> 
#   select(tm, CA_X, CA_Y, Chain, Model, slice) |> 
#   pivot_wider(
#     names_from = 'tm',
#     values_from = c('CA_X', 'CA_Y'),
#     names_glue = '{tm}.{.value}'
#   ) |> 
#   mutate(color = case_when(
#     Chain == 'A' ~ 'blue',
#     Chain == 'B' ~ 'red',
#     Chain == 'C' ~ 'magenta'
#   ))
# 
# slices |> 
#   mutate(color = case_when(
#     Model == 'CKO/DEG' ~ '#CCCCCC',
#     Model == 'Mouse Trypsin' ~ 'black'
#   )) |> 
#   ggplot(aes(CA_X, CA_Y, fill = Chain, shape = tm, color = color)) +
#   theme_minimal() +
#   geom_segment(
#     aes(
#       x = TM1.CA_X,
#       y = TM1.CA_Y,
#       xend = TM2.CA_X,
#       yend = TM2.CA_Y,
#       color = color,
#       linetype = Model
#     ),
#     data = tm_connectors,
#     inherit.aes = FALSE
#   ) +
#   geom_point(size = 6, stroke = 1) +
#   facet_wrap(
#     vars(slice),
#     ncol = 2,
#     labeller = labeller(slice = negative)
#   ) +
#   scale_shape_manual(values = c(21, 22)) +
#   scale_fill_manual(values = c('blue', 'red', 'magenta')) +
#   scale_color_identity() +
#   scale_linetype_manual(values = c('dashed', 'dotted')) +
#   coord_fixed(xlim = lims, ylim = lims) +
#   labs(
#     x = expression(paste('C', alpha, ' X coordinate')),
#     y = expression(paste('C', alpha, ' Y coordinate'))
#   ) +
#   theme(
#     legend.position = 'none',
#     panel.grid.major = element_blank(),
#     panel.grid.minor = element_blank(),
#     panel.background = element_rect(color = '#222222'),
#     strip.background = element_rect(fill = '#EEEEEE', color = NA)
#   )
# ggsave('model-slices_tm-connectors.png', width = 8, height = 12, bg = 'white')
# 
# last_plot() +
#   geom_segment(
#     data = lines,
#     mapping = aes(
#       x = m.CA_X,
#       y = m.CA_Y,
#       xend = h.CA_X,
#       yend = h.CA_Y,
#       group = interaction(tm, Chain)
#     ),
#     inherit.aes = FALSE,
#     color = 'black',
#     arrow = arrow(length = unit(.1, 'inches'), type = 'closed')
#   )
# ggsave('model-slices_tm-connectors_with-model-guides.png', width = 8, height = 12, bg = 'white')
