# ============================================================
# Guia RDD — FGV CLEAR
# Seção 5: Testes de Validade e Análise de Robustez
# ============================================================

library(rdrobust)
library(rddensity)

# --- 5.1 Teste de Densidade (McCrary) ---

density_test <- rddensity(X = df$x, c = 0)
summary(density_test)
# p-valor > 0.05: nao rejeitar H0 (sem evidencia de manipulacao)

# --- 5.2 Balanceamento de Covariáveis ---

covariaveis <- c("num_filhos", "escolaridade_resp", "area_urbana")
for (cov in covariaveis) {
  r <- rdrobust(y = df[[cov]], x = df$x, c = 0,
                kernel = "triangular", p = 1, bwselect = "mserd")
  cat(cov, "| Coef:", round(r$coef[1], 3),
      "| p-valor:", round(r$pv[3], 3), "\n")
}
# Resultado esperado: p-valores > 0.05 para todas as covariaveis

# --- 5.3 Placebo Cutoffs ---

for (info in list(list(c = -68, lbl = "R$150"),
                  list(c =  62, lbl = "R$280"))) {
  r <- rdrobust(y = df$freq_escolar, x = df$x, c = info$c,
                kernel = "triangular", p = 1, bwselect = "mserd")
  cat(info$lbl, "| Coef:", round(r$coef[1], 3),
      "| p-valor:", round(r$pv[3], 3), "\n")
}
# Resultado esperado: efeitos nao significativos nos placebos
