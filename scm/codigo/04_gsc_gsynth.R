# ============================================================
# Guia SCM — FGV CLEAR
# Seção 3.3: Controle Sintético Generalizado (GSC) com gsynth
# ============================================================

install.packages("gsynth")
library(gsynth)

# Dados em painel (unidades, tempo, outcome, treatment, covariáveis)
gsc_fit <- gsynth(
  Y ~ D + X1 + X2,             # Y = outcome, D = treatment
  data = panel_data,
  index = c("unit", "time"),
  force = "two-way",           # unit + time FE
  CV = TRUE,                   # cross-validation para num. fatores
  r = c(0, 5),                 # range de fatores a testar
  se = TRUE,                   # erros padrão
  nboots = 1000,               # bootstrap para inferência
  parallel = TRUE
)

print(gsc_fit)
plot(gsc_fit)                          # trajetória tratados vs controle
plot(gsc_fit, type = "counterfactual") # contrafactual por unidade
plot(gsc_fit, type = "gap")           # gap ao longo do tempo
