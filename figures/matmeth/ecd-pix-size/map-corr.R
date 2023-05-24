library(tidyverse)
library(showtext)
showtext_auto()
font_add_google('montserrat')

maps <- c('hCKO', 'hCKO/DEG', 'mUncleaved', 'hCD-MF', 'hCKO-ND', 'mJanelia2', 'mTrypsin')
sources <- c('PNCC', 'SLAC', 'Janelia', 'PNCC', 'SLAC', 'Janelia', 'PNCC')

# J255
hpko <- c(1.00, 0.7705, 0.8567, 0.8214, 0.7749, 0.8232, 0.7789)

# J211
hpkodeg <- c(0.7705, 1.00, 0.641, 0.6852, 0.9257, 0.6003, 0.6405)

# J69
mjan1 <- c(0.8567, 0.641, 1.00, 0.8418, 0.7151, 0.8651, 0.883)

# J111
hpip <- c(0.8214, 0.6852, 0.8418, 1.00, 0.8428, 0.8169, 0.895)

# J111
hnfnd <- c(0.7749, 0.9257, 0.7151, 0.8428, 1.00, 0.677, 0.7323)

# J42
mJan2 <- c(0.8232, 0.6003, 0.8651, 0.8169, 0.677, 1.00, 0.8301)

# J71
mTryp <- c(0.7789, 0.6405, 0.883, 0.895, 0.7323, 0.8301, 1.00)

data <- tibble(
  source_a = rep(sources, each = length(maps)),
  map_a = rep(maps, each = length(maps)),
  source_b = rep(sources, length(maps)),
  map_b = rep(maps, length(maps)),
  corr = c(hpko, hpkodeg, mjan1, hpip, hnfnd, mJan2, mTryp)
)

data |> 
  mutate(map_a = fct_relevel(
    map_a, 'hCKO', 'hCD-MF', 'mTrypsin', 'hCKO/DEG', 'hCKO-ND', 'mUncleaved', 'mJanelia2'
  )) |> 
  mutate(map_b = fct_relevel(
    map_b, 'hCKO', 'hCD-MF', 'mTrypsin', 'hCKO/DEG', 'hCKO-ND', 'mUncleaved', 'mJanelia2'
  )) |> 
  ggplot(aes(map_a, map_b, fill = corr)) +
  theme_minimal(
    base_family = 'montserrat'
  ) +
  geom_tile(color = 'black') +
  scale_fill_viridis_c() +
  geom_hline(yintercept = c(3.5, 5.5), color = 'white') +
  geom_vline(xintercept = c(3.5, 5.5), color = 'white') +
  annotate(
    'label',
    x = 2, y = 2,
    label = 'PNCC'
  ) +
  annotate(
    'label',
    x = 4.5, y = 4.5,
    label = 'SLAC'
  ) +
  annotate(
    'label',
    x = 6.5, y = 6.5,
    label = 'Janelia'
  ) +
  theme(
    axis.text.x = element_text(color = c('blue', 'blue', 'blue', 'red', 'red', 'black', 'black')),
    axis.text.y = element_text(color = c('blue', 'blue', 'blue', 'red', 'red', 'black', 'black'))
  ) +
  scale_x_discrete(guide = guide_axis(n.dodge = 2)) +
  coord_equal() +
  labs(
    x = '',
    y = '',
    fill = 'Map\nCorrelation'
  )
ggsave('all-map-corr.png', width = 8, height = 8, bg = 'white')
ggsave('all-map-corr.pdf', width = 8, height = 8, bg = 'white')
