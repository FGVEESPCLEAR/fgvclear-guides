# ============================================================
# Guia Matching — FGV CLEAR
# Secao 5: AIPW — Estimador Duplamente Robusto
# ============================================================

library(AIPW)
library(SuperLearner)

aipw_obj <- AIPW$new(
  Y = dat$re78,
  A = dat$treat,
  W = dat[, covs],
  Q.SL.library = c("SL.glm", "SL.ranger"),
  g.SL.library  = c("SL.glm", "SL.ranger"),
  k_split = 5,
  verbose = FALSE
)
aipw_obj$fit()
aipw_obj$summary(g.bound = 0.025)
