# ============================================================
# Guia MDE/Poder — FGV CLEAR
# Secao 2: Calculo de Poder — Formula Analitica
# ============================================================

rm(list=ls())
library(tidyverse)

t.kappa = 0.84
t.alpha = 1.96
P = 0.5

MDE = function(N){(t.kappa+t.alpha)*((1/(P*(1-P)))^0.5)*((1/N)^0.5)}

MDE(1000)

ggplot() + xlim(500, 3500) +
  geom_function(fun = MDE, colour = "blue", linewidth = 0.8) +
  labs(y = "MDE", x = "N") +
  theme_classic()

# MDE com Y binario
sigma.max = 1/4
MDE.max = function(N){(t.kappa+t.alpha)*((1/(P*(1-P)))^0.5)*((sigma.max/N)^0.5)}

ggplot() + xlim(500, 3500) +
  geom_function(fun = MDE.max, colour = "blue", linewidth = 0.8) +
  labs(y = "MDE", x = "N") +
  theme_classic()
