# ============================================================
# Guia Matching — FGV CLEAR
# Secao 6: Diagnosticos — Balanceamento e Sensibilidade
# ============================================================

library(estimatr)
library(Matching)

out_att <- Match(Y = Y, Tr = Tr, X = Xps,
                 M = 1, replace = TRUE, estimand = "ATT")

out_att$est
out_att$se

ci_lb <- out_att$est - 1.96 * out_att$se
ci_ub <- out_att$est + 1.96 * out_att$se
cat("IC 95%: [", round(ci_lb, 2), ",", round(ci_ub, 2), "]\n")

# OLS pos-pareamento com erros clusterizados
dados_pareados <- rbind(
  dat[out_att$index.treated, ],
  dat[out_att$index.control, ]
)

fit_cluster <- lm_robust(
  re78 ~ treat, data = dados_pareados,
  clusters = dados_pareados$municipio, se_type = "CR2"
)
summary(fit_cluster)

# Love Plot
library(cobalt)
love.plot(out_att, stats = "mean.diffs",
          thresholds = c(m = 0.1),
          var.order = "unadjusted",
          title = "Balanceamento: antes e apos o pareamento")

# Sensibilidade de Rosenbaum
library(rbounds)
y_tratado  <- dat$re78[out_att$index.treated]
y_controle <- dat$re78[out_att$index.control]
psens(y_tratado - y_controle, Gamma = 2, GammaInc = 0.1)
