library(tidyverse)
library(showtext)
showtext_auto()
font_add_google('montserrat')

# pixel size scaling ---------------------------------------------------

showtext_opts(dpi = 300)

data <- tribble(
  ~pix, ~cor,
  1.290, .7199,
  1.200, .7443,
  1.250, .9279,
  1.255, .9175,
  1.245, .9327,
  1.247, .9315,
  1.243, .9330,
  1.240, .9317
) |> 
  mutate(pix = signif(pix * (0.43 / 1.29), digits = 3))

best_row <- data |> 
  filter(cor == max(cor))

data |> 
  mutate(is_nominal = pix == 1.290) |> 
  ggplot(aes(pix, cor, shape = is_nominal)) +
  theme_minimal(
    base_family = 'montserrat',
    base_size = 12
  ) +
  theme(
    panel.grid = element_blank()
  ) +
  geom_line(group = 1, linetype = 'dotted') +
  geom_hline(yintercept = best_row$cor, linetype = 'dashed', color = '#CCCCCC') +
  geom_vline(xintercept = best_row$pix, linetype = 'dashed', color = '#CCCCCC') +
  geom_point(show.legend = FALSE, size = 3) +
  geom_hline(yintercept = 1.00) +
  expand_limits(y = 0.7) +
  labs(
    x = expression(paste('Pixel Size (', ring(A), ')')),
    y = 'Map Correlation'
  ) +
  annotate(
    'label',
    x = best_row$pix,
    y = -Inf,
    vjust = -1,
    label = best_row$pix,
    family = 'montserrat'
  ) +
  annotate(
    'label',
    x = -Inf,
    y = best_row$cor,
    hjust = -0.6,
    label = best_row$cor,
    family = 'montserrat'
  )
ggsave('pixel-scaling.png', width = 5, height = 5, bg = 'white')

# model linear fit -----------------------------------------------

cko_ca <- read_csv('cko.csv') |> 
  select(-Model) |> 
  filter(Chain %in% c('A', 'B', 'C'))

cko_deg_ca <- read_csv('cko-deg.csv') |> 
  select(-Model) |> 
  filter(Chain %in% c('A', 'B', 'C'))

data <- inner_join(
  cko_ca,
  cko_deg_ca,
  by = c('Chain', 'ResNum'),
  suffix = c('.CKO', '.CD')
)

distance <- function(x1, x2, y1, y2, z1, z2) {
  sqrt((x1 - x2)**2 + (y1 - y2)**2 + (z1 - z2)**2)
}

# these are all resampled onto human cko ND, which has a asymm unit of
# 292.4, according to its PDB. So the center of the box is 146.2 in all
# dimensions

processed <- data |> 
  mutate(
    shift = distance(CA_X.CKO, CA_X.CD, CA_Y.CD, CA_Y.CKO, CA_Z.CKO, CA_Z.CD),
    meanX = (CA_X.CKO + CA_X.CD) / 2,
    meanY = (CA_Y.CD + CA_Y.CKO) / 2,
    meanZ = (CA_Z.CKO + CA_Z.CD) / 2,
    center_dist = distance(meanX, 146.2, meanY, 146.2, meanZ, 146.2)
  ) |> 
  filter(shift < 2.5)

processed |> 
  mutate(Chain = case_when(
    Chain == 'A' ~ '\u03b1',
    Chain == 'B' ~ '\u03b2',
    Chain == 'C' ~ '\u03b3'
  )) |> 
  ggplot(aes(x = center_dist, y = shift)) +
  theme_minimal() +
  geom_point(aes(color = Chain), show.legend = FALSE) +
  geom_smooth(method = 'lm', color = 'black', se = FALSE) +
  facet_grid(rows = vars(Chain)) +
  scale_color_manual(
    values = c('#5650C7', '#FF636E', '#FF57F7')
  ) +
  theme(
    axis.text = element_text(family = 'montserrat'),
    axis.title = element_text(family = 'montserrat')
  ) +
  labs(
    x = 'Distance from center of box',
    y = 'Shift between CKO and CKO/DEG'
  )
ggsave('linear-model.pdf', width = 5, height = 8)
