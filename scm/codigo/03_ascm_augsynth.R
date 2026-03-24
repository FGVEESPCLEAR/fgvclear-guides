# ============================================================
# Guia SCM — FGV CLEAR
# Seção 3.1: SCM Aumentado (ASCM) com augsynth
# Seção 3.4: Matrix Completion (MCPanel)
# ============================================================

install.packages("augsynth")
library(augsynth)

# --- ASCM com Ridge ---

data(california_prop99)

# ASCM com Ridge (recomendação padrão)
ascm_fit <- augsynth(
  PacksPerCapita ~ treated,
  unit = State, time = Year,
  data = california_prop99,
  progfunc = "Ridge",  # modelo de resultados
  scm = TRUE           # combinar com pesos SCM
)
summary(ascm_fit)
plot(ascm_fit)

# Comparação: SCM puro (sem correção)
scm_pure <- augsynth(
  PacksPerCapita ~ treated,
  unit = State, time = Year,
  data = california_prop99,
  progfunc = "None",
  scm = TRUE
)

# Comparar ajuste pré-tratamento
par(mfrow = c(1, 2))
plot(scm_pure, main = "SCM Puro")
plot(ascm_fit, main = "ASCM (Ridge)")

# --- Matrix Completion (MCPanel) ---

mc_fit <- augsynth(
  PacksPerCapita ~ treated,
  unit = State, time = Year,
  data = california_prop99,
  progfunc = "MCPanel",
  scm = FALSE
)
summary(mc_fit)
plot(mc_fit)
