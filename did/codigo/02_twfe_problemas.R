# ============================================================
# Guia DID — FGV CLEAR
# Secao: Quando e porque um DID escalonado da problema?
# Tres casos: homogeneo, heterogeneo por grupo, heterogeneo
# ============================================================

library(dplyr)
library(lmtest)
library(sandwich)
library(stargazer)

# --- Caso 1: Tratamento Homogeneo ---

rm(list=ls())
df <- read.csv("base_stagger_did_const.csv")

reg_TWFE = lm(y ~ as.factor(G) + as.factor(ano) + d_x_t +
  escolaridade + populacao, data = df)
cov1 <- sandwich::vcovHC(reg_TWFE, type = "HC0")
sd_robust = sqrt(diag(cov1))
stargazer(reg_TWFE, type = "text", se = list(sd_robust),
  title = "Caso 1: Tratamento Homogeneo")

# --- Caso 2: Heterogeneo entre Grupos ---

rm(list=ls())
df <- read.csv("base_stagger_did_const_group.csv")

reg_TWFE = lm(y ~ as.factor(G) + as.factor(ano) + d_x_t +
  escolaridade + populacao, data = df)
cov1 <- sandwich::vcovHC(reg_TWFE, type = "HC0")
sd_robust = sqrt(diag(cov1))
stargazer(reg_TWFE, type = "text", se = list(sd_robust),
  title = "Caso 2: Heterogeneo entre Grupos")

# --- Caso 3: Heterogeneo ao Longo do Tempo ---

rm(list=ls())
df <- read.csv("base_stagger_did.csv")

reg_TWFE = lm(y ~ as.factor(G) + as.factor(ano) + d_x_t +
  escolaridade + populacao, data = df)
cov1 <- sandwich::vcovHC(reg_TWFE, type = "HC0")
sd_robust = sqrt(diag(cov1))
stargazer(reg_TWFE, type = "text", se = list(sd_robust),
  title = "Caso 3: Heterogeneo ao Longo do Tempo")
