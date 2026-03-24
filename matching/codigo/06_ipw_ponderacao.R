# ============================================================
# Guia Matching — FGV CLEAR
# Secao 5: Ponderacao pelo Propensity Score (IPW)
# ============================================================

library(estimatr)

dat <- dat %>% filter(pscore > 0.1, pscore < 0.9)

dat <- dat %>%
  mutate(
    w_ate = treat / pscore + (1 - treat) / (1 - pscore),
    w_att = ifelse(treat == 1, 1, pscore / (1 - pscore))
  )

fit_ate <- lm_robust(re78 ~ treat, data = dat, weights = w_ate)
fit_att <- lm_robust(re78 ~ treat, data = dat, weights = w_att)
summary(fit_ate)
summary(fit_att)
