# ============================================================
# Guia Matching — FGV CLEAR
# Secao 2: Experimento Aleatorizado (NSW)
# ============================================================

library(vtable)
library(estimatr)

nsw %>%
  select(c("treat", "age", "educ", "nodegree", "marr",
           "black", "hisp", "re74", "re75", "u74", "u75")) %>%
  sumtable(group = "treat", group.test = TRUE, digits = 3)

fit_nsw <- lm_robust(re78 ~ treat, se_type = "stata", data = nsw)
summary(fit_nsw)
