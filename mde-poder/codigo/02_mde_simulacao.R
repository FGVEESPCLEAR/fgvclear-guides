# ============================================================
# Guia MDE/Poder — FGV CLEAR
# Secao 2: Calculo de Poder — Simulacao
# ============================================================

rm(list=ls())
library(tidyverse)
library(randomizr)

set.seed(42)
base_rct <- read.csv("Base/base_rct.csv")

se <- c(rep(NA, 100))

for (i in 1:100) {
  D <- simple_ra(N = nrow(base_rct), prob = 0.5)
  df <- cbind(base_rct, D)
  reg <- lm(y ~ D, data = df)
  se[i] <- summary(reg)$coefficients[2,2]
}

MDE = 2.8*mean(se)
print(MDE)
