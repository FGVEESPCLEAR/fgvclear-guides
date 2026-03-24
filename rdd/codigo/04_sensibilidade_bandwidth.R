# ============================================================
# Guia RDD — FGV CLEAR
# Seção 5.4: Sensibilidade ao Bandwidth
# ============================================================

library(rdrobust)

h_otimo <- rdd_sharp$bws[1, 1]
fatores <- c(0.5, 0.75, 1.0, 1.25, 1.5)

resultados <- sapply(fatores, function(f) {
  r <- rdrobust(y = df$freq_escolar, x = df$x, c = 0,
                h = h_otimo * f, kernel = "triangular", p = 1)
  c(h = round(h_otimo * f, 1),
    coef = round(r$coef[1], 3),
    pv   = round(r$pv[3], 3))
})
print(t(resultados))
