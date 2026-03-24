# ============================================================
# Guia MDE/Poder — FGV CLEAR
# Secao 4: RCT Agrupado (Clustered)
# ============================================================

# --- Formula Analitica ---

rm(list=ls())
library(tidyverse)

t.kappa = 0.84
t.alpha = 1.96
P = 0.5

MDE.cluster = function(N,J,rho){(t.kappa+t.alpha)*((1/(P*(1-P)))^0.5)*((1/(N*J))^0.5*(1+(N - 1)*rho)^0.5)}

ggplot() + xlim(10, 70) +
  geom_function(fun = MDE.cluster, args = list(J = 50, rho = 0.05), aes(colour = "ICC = 0.05"), linewidth = 0.8) +
  geom_function(fun = MDE.cluster, args = list(J = 50, rho = 0.1), aes(colour = "ICC = 0.1"), linewidth = 0.8) +
  geom_function(fun = MDE.cluster, args = list(J = 50, rho = 0.15), aes(colour = "ICC = 0.15"), linewidth = 0.8) +
  labs(y = "MDE", x = "N") +
  theme_classic() +
  guides(colour=guide_legend(title="ICC"))

ggplot() + xlim(10, 70) +
  geom_function(fun = MDE.cluster, args = list(N = 30, rho = 0.05), aes(colour = "ICC = 0.05"), linewidth = 0.8) +
  geom_function(fun = MDE.cluster, args = list(N = 30, rho = 0.1), aes(colour = "ICC = 0.1"), linewidth = 0.8) +
  geom_function(fun = MDE.cluster, args = list(N = 30, rho = 0.15), aes(colour = "ICC = 0.15"), linewidth = 0.8) +
  labs(y = "MDE", x = "J") +
  theme_classic() +
  guides(colour=guide_legend(title="ICC"))

# --- Simulacao ---

rm(list=ls())
library(tidyverse)
library(randomizr)
library(lfe)

set.seed(42)
base_rct_cluster <- read.csv("Base/base_rct_cluster.csv")

se_cluster <- c(rep(NA, 100))

for (i in 1:100) {
  D <- simple_ra(N = length(unique(base_rct_cluster$id_escola)), prob = 0.5)
  match <- data.frame(id_escola = unique(base_rct_cluster$id_escola), D = D)
  df <- left_join(base_rct_cluster, match, by = "id_escola")
  reg_cluster <- felm(y ~ D|0|0|id_escola, data = df)
  se_cluster[i] <- summary(reg_cluster)$coefficients[2,2]
}

MDE_cluster = 2.8*mean(se_cluster)
print(MDE_cluster)
