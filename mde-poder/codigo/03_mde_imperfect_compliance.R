# ============================================================
# Guia MDE/Poder — FGV CLEAR
# Secao 3: Imperfect Compliance (LATE/IV)
# ============================================================

# --- Formula Analitica ---

rm(list=ls())
library(tidyverse)

t.kappa = 0.84
t.alpha = 1.96
P = 0.5

MDE.IV = function(N,take.up){(t.kappa+t.alpha)*((1/(P*(1-P)))^0.5)*((1/N)^0.5*(1/take.up))}

ggplot() + xlim(500, 3500) +
  geom_function(fun = MDE.IV, args = list(take.up = 0.50), aes(colour = "Take Up = 50%"), linewidth = 0.8) +
  geom_function(fun = MDE.IV, args = list(take.up = 0.60), aes(colour = "Take Up = 60%"), linewidth = 0.8) +
  geom_function(fun = MDE.IV, args = list(take.up = 0.70), aes(colour = "Take Up = 70%"), linewidth = 0.8) +
  labs(y = "MDE", x = "N") +
  theme_classic() +
  guides(colour=guide_legend(title="Take Up"))

# --- Simulacao ---

rm(list=ls())
library(tidyverse)
library(randomizr)
library(ivreg)

set.seed(42)
base_rct <- read.csv("Base/base_rct.csv")

se_late <- c(rep(NA, 100))

for (i in 1:100) {
  Z <- simple_ra(N = nrow(base_rct), prob = 0.5)
  df <- cbind(base_rct, Z)
  df <- df %>%
    mutate(aux = runif(nrow(base_rct))) %>%
    mutate(D = case_when(Z==0 & aux<0.2 ~ 1,
                         Z==0 & aux>0.2 ~ 0,
                         Z==1 & aux<0.75 ~ 1,
                         Z==1 & aux>0.75 ~ 0)) %>%
    select(-aux)
  reg_late <- ivreg(y ~ D|Z, data = df)
  se_late[i] <- summary(reg_late)$coefficients[2,2]
}

MDE_late = 2.8*mean(se_late)
print(MDE_late)
