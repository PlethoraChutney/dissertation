library(tidyverse)

amiloride_current <- function(x) {
  return(as.numeric(!(x < 20 | x > 90)) * (-1000 - 5000 * exp(-x/10)))
}

ggplot() +
  theme_void() +
  geom_function(
    fun = amiloride_current,
    xlim = c(0, 100),
    n = 250
  )
