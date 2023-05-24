library(tidyverse)
library(ggokabeito)

data_one <- read_csv('153.csv')
data_two <- read_csv('154.csv')
data <- bind_rows(data_one, data_two) %>% 
  filter(row_number() %% 10 == 0)

cleaned_data <- data %>% 
  mutate(condition = case_when(
    grepl('8001', filename) ~ 'cell-1_Pre-trypsin_Na+',
    grepl('8002', filename) ~ 'cell-1_Pre-trypsin_K+',
    grepl('8003', filename) ~ 'cell-1_Pre-trypsin_Li+',
    grepl('8004', filename) ~ 'cell-1_Post-trypsin_Na+',
    grepl('8005', filename) ~ 'cell-1_Post-trypsin_K+',
    grepl('8006', filename) ~ 'cell-1_Post-trypsin_Li+',
    grepl('8007', filename) ~ 'cell-2_Pre-trypsin_Na+',
    grepl('8008', filename) ~ 'cell-2_Pre-trypsin_K+',
    grepl('8009', filename) ~ 'cell-2_Pre-trypsin_Li+',
    grepl('8019', filename) ~ 'cell-4_Pre-trypsin_Na+',
    grepl('8020', filename) ~ 'cell-4_Pre-trypsin_K+',
    grepl('8021', filename) ~ 'cell-4_Pre-trypsin_Li+',
    grepl('8022', filename) ~ 'cell-4_Post-trypsin_Na+',
    grepl('8023', filename) ~ 'cell-4_Post-trypsin_K+',
    grepl('8025', filename) ~ 'cell-4_Post-trypsin_Li+',
    filename == '22119004.abf' ~ 'cell-5_Pre-trypsin_Na+',
    filename == '22119006.abf' ~ 'cell-5_Pre-trypsin_K+',
    filename == '22119007.abf' ~ 'cell-5_Pre-trypsin_Li+',
    filename == '22119008.abf' ~ 'cell-5_Post-trypsin_Na+',
    filename == '22119009.abf' ~ 'cell-5_Post-trypsin_K+',
    filename == '22119010.abf' ~ 'cell-5_Post-trypsin_Li+'
  )) %>% 
  separate(condition, into = c('Cell', 'Trypsin', 'Salt'), sep = '_') %>% 
  # trick here. adding 1 makes all the 0s, which otherwise round to 0.002 or whatever,
  # actually go to 0. need this variable for grouping.
  mutate(set_potential = formatC(memb_potential + 1.5, digits = 1)) %>% 
  mutate(Trypsin = fct_relevel(Trypsin, c('Pre-trypsin', 'Post-trypsin'))) %>% 
  mutate(Salt = fct_relevel(as.factor(Salt), c('Na+', 'K+', 'Li+'))) %>% 
  filter(Cell != 'cell-2')

amil_currents <- cleaned_data %>% 
  filter(0.25 < time & time < 0.75) %>% 
  group_by(Cell, Trypsin, Salt, set_potential) %>% 
  summarize(amil_current = mean(current))

# get highest magnitude, but preserve sign
abs_max <- function(x) {
  x[which.max(abs(x))]
}

enac_current <- cleaned_data %>% 
  # won't have to do this filter anymore now that we can record barrel position.
  # but for now, here we are.
  filter(time > 1 & time < 3) %>% 
  left_join(amil_currents, by = c('Cell', 'Trypsin', 'Salt', 'set_potential')) %>% 
  mutate(enac_current = current - amil_current) %>% 
  group_by(Cell, Trypsin, Salt, set_potential) %>% 
  summarize(
    enac_current = abs_max(enac_current),
    pot = round(mean(memb_potential)),
    .groups = 'drop'
  )

enac_current %>% 
  ggplot(aes(x = pot, y = enac_current, color = Salt, shape = Salt, group = interaction(Cell, Salt))) +
  theme_minimal() +
  geom_hline(yintercept = 0, color = '#888888') +
  geom_vline(xintercept = 0, color = '#888888') +
  geom_line() +
  geom_point() +
  facet_grid(cols = vars(Trypsin)) +
  labs(
    y = 'Amiloride Sensitive Current (pA)',
    x = 'Membrane Potential (mV)'
  ) +
  MetBrewer::scale_color_met_d(
    'Java'
  ) +
  scale_x_continuous(
    breaks = seq(-100, 100, 20)
  )
ggsave('491_all-raw.png', height = 6, width = 6)

pret_na <- enac_current %>% 
  filter(Salt == 'Na+', Trypsin == 'Pre-trypsin', pot == -80) %>% 
  ungroup() %>% 
  select('PreTrypNa' = enac_current, Cell)

norm_mean_iv <- enac_current %>% 
  left_join(pret_na, by = c('Cell')) %>% 
  mutate(norm_current = enac_current / PreTrypNa) %>% 
  group_by(Salt, Trypsin, pot) %>% 
  summarize(current = mean(norm_current), sdev = sd(norm_current), .groups = 'drop_last') %>%
  mutate(low = current - sdev, high = current + sdev) %>% 
  ungroup()

norm_mean_iv %>% 
  ggplot(aes(x = pot, y = current, color = Salt, shape = Salt)) +
  theme_minimal() +
  geom_hline(yintercept = 0, color = '#888888') +
  geom_vline(xintercept = 0, color = '#888888') +
  geom_line() +
  geom_errorbar(aes(ymin = low, ymax = high), width = 5) +
  geom_point(size = 3) +
  facet_grid(cols = vars(Trypsin)) +
  labs(
    y = 'Mean Relative\nAmiloride Sensitive Current',
    x = 'Membrane Potential (mV)'
  ) +
  MetBrewer::scale_color_met_d(
    'Java'
  ) +
  scale_x_continuous(
    breaks = seq(-100, 100, 20)
  ) +
  scale_y_reverse()
ggsave('491-mean-iv.png', width = 6, height = 4, bg = 'white')

fitted <- norm_mean_iv %>% 
  group_by(Salt, Trypsin) %>% 
  nest() %>% 
  mutate(fit = map(data, ~ lm(current ~ pot, .x))) %>% 
  mutate(fit = map(fit, coef)) %>% 
  mutate(slope = map_dbl(fit, ~.x[[2]]), intercept = map_dbl(fit, ~.x[[1]]))

mean_pt_na <- mean(pret_na$PreTrypNa)



norm_mean_iv %>% 
  left_join(fitted) %>% 
  mutate(fit_line = pot * slope + intercept) %>% 
  ggplot(aes(x = pot, y = current, color = Salt, shape = Salt)) +
  theme_minimal() +
  theme(legend.position = 'top') +
  geom_hline(yintercept = 0, color = '#888888') +
  geom_vline(xintercept = 0, color = '#888888') +
  geom_line(aes(x = pot, y = fit_line)) +
  geom_errorbar(aes(ymin = low, ymax = high), width = 5) +
  geom_point() +
  facet_grid(cols = vars(Trypsin)) +
  labs(
    y = 'Mean Amiloride Sensitive Current relative to -80 mV/Na+ (pA)',
    x = 'Membrane Potential (mV)'
  ) +
  scale_color_manual(
    values = c('#DDAA33', '#BB5566', '#004488')
  ) +
  scale_x_continuous(
    breaks = seq(-100, 100, 20)
  ) +
  scale_y_reverse(
    sec.axis = sec_axis(~ . * mean_pt_na, breaks = seq(-4000, 2000, 800))
  )
ggsave('491-fit-lines.png', width = 6, height = 6)


norm_mean_iv %>% 
  mutate(current = current * mean_pt_na * 1e-12, pot = pot * 1e-3) %>% 
  group_by(Salt, Trypsin) %>% 
  nest() %>% 
  mutate(fit = map(data, ~ lm(current ~ pot, .x))) %>% 
  mutate(fit = map(fit, coef)) %>% 
  mutate(slope = map_dbl(fit, ~.x[[2]]), intercept = map_dbl(fit, ~.x[[1]])) %>% 
  select(Salt, Trypsin, 'Conductance' = slope, 'Intercept' = intercept) %>% 
  mutate(Reversal = -Intercept / Conductance) %>% 
  select(-Intercept) %>% 
  mutate(Reversal = Reversal * 1000, Conductance = Conductance * 1e9) %>% 
  pivot_longer(Conductance:Reversal, names_to = 'Parameter', values_to = 'Value') %>% 
  mutate(Parameter = case_when(
    Parameter == 'Conductance' ~ 'Macro Conductance (nS)',
    Parameter == 'Reversal' ~ 'Reversal Potential (mV)'
  )) %>% 
  mutate(Trypsin = case_when(
    Trypsin == 'Pre-trypsin' ~ 'Pre',
    Trypsin == 'Post-trypsin' ~ 'Post'
  )) %>% 
  mutate(Trypsin = ordered(Trypsin, levels = c('Pre', 'Post'))) %>%
  ggplot(aes(x = Salt, fill = Trypsin, y = Value)) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = 'white'),
    legend.position = 'top'
  ) +
  geom_col(position = 'dodge') +
  facet_grid(rows = vars(Parameter), scales = 'free') +
  scale_fill_okabe_ito() +
  labs(
    y = element_blank()
  )
ggsave('ephys_pko-deg-param.png', width = 2.5, height = 4)

norm_mean_iv %>% 
  mutate(current = current * mean_pt_na * 1e-12, pot = pot * 1e-3) %>% 
  group_by(Salt, Trypsin) %>% 
  nest() %>% 
  mutate(fit = map(data, ~ lm(current ~ pot, .x))) %>% 
  mutate(fit = map(fit, coef)) %>% 
  mutate(slope = map_dbl(fit, ~.x[[2]]), intercept = map_dbl(fit, ~.x[[1]])) %>% 
  select(Salt, Trypsin, 'Conductance' = slope, 'Intercept' = intercept) %>% 
  mutate(Reversal = -Intercept / Conductance) %>% 
  select(-Intercept) %>% 
  mutate(Reversal = Reversal * 1000, Conductance = Conductance * 1e9) %>% 
  pivot_wider(names_from = Trypsin, values_from = c(Conductance, Reversal)) %>% 
  transmute(Increase = `Conductance_Post-trypsin`/`Conductance_Pre-trypsin` - 1)
