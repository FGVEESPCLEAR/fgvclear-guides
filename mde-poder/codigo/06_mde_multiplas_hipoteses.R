# ============================================================
# Guia MDE/Poder — FGV CLEAR
# Secao 6: Multiplas Hipoteses (Correcao de Sidak)
# ============================================================

rm(list=ls())
library(tidyverse)

t.kappa = 0.84
t.alpha = 1.96
P = 0.5

alpha.h = function(h){1 - (1 - 0.05)^(1/h)}
t.alpha.h = function(h){qnorm(1-alpha.h(h)/2)}
MDE.h = function(N,h){(t.kappa+t.alpha.h(h))*((1/(P*(1-P)))^0.5)*((1/N)^0.5)}

ggplot() + xlim(500, 3500) +
  geom_function(fun = MDE.h, args = list(h = 1), aes(colour = "h = 1"), linewidth = 0.8) +
  geom_function(fun = MDE.h, args = list(h = 2), aes(colour = "h = 2"), linewidth = 0.8) +
  geom_function(fun = MDE.h, args = list(h = 3), aes(colour = "h = 3"), linewidth = 0.8) +
  labs(y = "MDE", x = "N") +
  theme_classic() +
  guides(colour=guide_legend(title=""))
