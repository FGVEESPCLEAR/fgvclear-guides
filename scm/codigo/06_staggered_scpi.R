# ============================================================
# Guia SCM — FGV CLEAR
# Seção 3.6: Staggered SCM com Intervalos de Predição (scpi)
# ============================================================

install.packages("scpi")
library(scpi)

# Preparação dos dados para múltiplos tratados
# Formato: painel com coluna de ID, tempo, outcome, treatment
scd <- scdata(df = panel_data,
              id.var = "unit", time.var = "time",
              outcome.var = "Y", treatment.var = "treatment",
              period.pre = pre_periods,
              period.post = post_periods)

# Estimação com intervalos de predição
result <- scpi(scd, sims = 200, cores = 4)
scplot(result)
