# ============================================================
# Guia SCM — FGV CLEAR
# Seção 3.5: Synthetic Difference-in-Differences (SDID)
# ============================================================

install.packages("synthdid")
library(synthdid)

# Formato: matriz Y (unidades x tempo), indicadores N0, T0
setup <- panel.matrices(california_prop99,
                        unit = "State", time = "Year",
                        outcome = "PacksPerCapita",
                        treatment = "treated")

# Estimadores
tau_sdid <- synthdid_estimate(setup$Y, setup$N0, setup$T0)
tau_sc   <- sc_estimate(setup$Y, setup$N0, setup$T0)
tau_did  <- did_estimate(setup$Y, setup$N0, setup$T0)

cat("SDID:", round(tau_sdid, 2), "\n")
cat("SCM: ", round(tau_sc, 2), "\n")
cat("DiD: ", round(tau_did, 2), "\n")

# Gráfico comparativo
synthdid_plot(tau_sdid, se.method = "placebo")
