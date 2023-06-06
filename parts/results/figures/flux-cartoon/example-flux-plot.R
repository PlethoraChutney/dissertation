library(tidyverse)
library(showtext)

sysfonts::font_add_google('Montserrat')

fn_equil <- function(x, no_channels) {
  (30 + 70 * no_channels) * exp(-x/300) + 1000 + 30 * no_channels
}

fn_cccp <- function(x, no_channels) {
  (400 - 390 * no_channels) * exp(-x/200) + 300 + 600 * no_channels
}

fn_iono <- function(x, no_channels) {
  (-0.04 + .02 * no_channels) * x + 150 - 25 * no_channels
}

base_data <- tibble(
  Time = seq(1,1200),
  Stage = c(rep('Equil', 300), rep('CCCP', 300), rep('Iono', 600))
)

base_data <- bind_rows(base_data, base_data) |> 
  mutate(no_channels = rep(c(TRUE, FALSE), each = 1200))

final_data <- base_data |> 
  mutate(Flr = case_when(
    Stage == 'Equil' ~ fn_equil(Time, no_channels),
    Stage == 'CCCP' ~ fn_cccp(Time, no_channels),
    Stage == 'Iono' ~ fn_iono(Time, no_channels)
  )) |> 
  mutate(Flr = Flr + rnorm(2400, mean = 10, sd = 5))

final_data <- final_data |> 
  group_by(no_channels) |> 
  filter(Stage == 'Equil') |> 
  summarize(min = min(Flr)) |> 
  right_join(final_data, by = 'no_channels', multiple = 'all') |> 
  mutate(Flr = Flr / min) |> 
  mutate(Time = case_when(
    Stage == 'Equil' ~ Time,
    Stage == 'CCCP' ~ Time + 20,
    Stage == 'Iono' ~ Time + 50
  ))

joiners <- final_data |> 
  group_by(no_channels, Stage) |> 
  mutate(Stage = case_when(
    Stage == 'Equil' ~ 'A',
    Stage == 'CCCP' ~ 'B',
    Stage == 'Iono' ~ 'C'
  )) |> 
  summarize(
    min = min(Flr), max = max(Flr),
    end = min(Time), start = max(Time) # this looks backwards but it's not
  ) |> 
  group_by(no_channels) |> 
  mutate(end = lead(end, 1), max = lead(max, 1))
  

showtext_auto()

final_data |> 
  ggplot(aes(
    Time, Flr, color = no_channels,
    group = interaction(Stage, no_channels))
  ) +
  theme_minimal(base_family = 'Montserrat') +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
  ) +
  geom_segment(
    data = joiners,
    inherit.aes = FALSE,
    mapping = aes(
      x = start,
      xend = end,
      y = min,
      yend = max,
      color = no_channels
    ),
    linetype = 'dashed'
  ) +
  geom_line() +
  expand_limits(y = c(1, 0)) +
  scale_color_manual(
    values = c('#6699EE', '#C2C2C2'),
    guide = NULL
  ) +
  scale_y_continuous(
    breaks = c(0, .25, .50, .75, 1),
    labels = c('0%', '25%', '50%', '75%', '100%')
  ) +
  labs(
    x = 'Time (s)',
    y = 'Rel. ACMA Fluorescence'
  )
ggsave('flux-example.pdf', width = 4.5, height = 3)
